import sys
import os
import io
from pathlib import Path
import yaml
import torch
import numpy as np
from matplotlib.figure import Figure
from matplotlib.colors import LinearSegmentedColormap
from mpl_toolkits.axes_grid1 import make_axes_locatable
import base64
from dataclasses import dataclass
from typing import Dict, List, Tuple, Any, Union

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import generate_groundtruth as gt
from networks.unet import UNet

import utils.visualization as visualize
import preprocessing.prepare_1ststage as prep_1hp
import preprocessing.prepare_2ndstage as prep_2hp
from data_stuff.transforms import (ComposeTransform, NormalizeTransform,
                             PowerOfTwoTransform, ReduceTo2DTransform,
                             SignedDistanceTransform, ToTensorTransform)
from domain_classes.heat_pump import HeatPump
from torch import stack, load, unsqueeze, save, Tensor
import domain_classes.domain as domain

from model_communication import ModelConfiguration, ReturnData

def prepare_demonstrator_input(config: ModelConfiguration, permeability: float, pressure: float):
    """
    Generate a prepared dataset directly from the input parameters of the demonstrator app.
    The input preperation is based on the gksi-input with a fixed position.
    """
    transforms = prep_1hp.get_transforms(reduce_to_2D=True, reduce_to_2D_xy=True, power2trafo=True)
    pflotran_settings = prep_1hp.get_pflotran_settings(config.dataset_info.dataset_path)

    dims = np.array(pflotran_settings["grid"]["ncells"])

    tensor_transform = ToTensorTransform()

    # Eingaben laden:
    x = dict()
    x["Pressure Gradient [-]"] = torch.ones(list(dims)).float() * pressure
    x["Permeability X [m^2]"] = torch.tensor(np.full(dims, permeability, order='F')).float()
    x["SDF"] = torch.ones(list(dims)).float() 
    x["SDF"][9][23][0] = 2
    x["Material ID"] = x["SDF"]

    y, method = gt.generate_groundtruth(config.dataset_info, permeability, pressure)

    loc_hp = prep_1hp.get_hp_location(x)
    x = transforms(x, loc_hp=loc_hp)
    x = tensor_transform(x).to(config.device)
    y = transforms(y, loc_hp=loc_hp)
    y = tensor_transform(y)

    norm = NormalizeTransform(config.model_1hp_info)
    x = norm(x, "Inputs")
    y = norm(y, "Labels")

    return x, y, method, norm

def prepare_demonstrator_input_2hp(config: ModelConfiguration, pressure: float, permeability: float, positions: list):
    """
    assumptions:
    - 1hp-boxes are generated already
    - 1hpnn is trained
    - cell sizes of 1hp-boxes and domain are the same
    - boundaries of boxes around at least one hp is within domain
    - device: attention, all stored need to be produced on cpu for later pin_memory=True and all other can be gpu
    """

    single_hps, corner_ll = build_inputs(config, pressure, permeability, positions)
    hp_inputs = prepare_hp_boxes_demonstrator(config, single_hps)

    return hp_inputs, corner_ll

# Vorbedingung: # Pressure Gradient [-] oder Permeability X [m^2] in [0,1]
def build_inputs(config, pressure, permeability, positions):

    pos_hps = [torch.tensor(positions[0]), torch.tensor(positions[1])]

    field_size = config.model_2hp_info["CellsNumber"]
    inputs = torch.empty(size=(4, field_size[0], field_size[1]))

    gradient_idx = config.model_1hp_info["Inputs"]["Pressure Gradient [-]"]["index"]
    inputs[gradient_idx] = torch.ones(field_size).float() * pressure

    permeability_idx = config.model_1hp_info["Inputs"]["Permeability X [m^2]"]["index"]
    inputs[permeability_idx] = torch.tensor(np.full(field_size, permeability, order='F')).float()

    material_id_idx = config.model_1hp_info["Inputs"]["Material ID"]["index"]
    inputs[material_id_idx] = torch.ones(field_size)
    inputs[material_id_idx][pos_hps[0][0], pos_hps[0][1]] = 2
    inputs[material_id_idx][pos_hps[1][0], pos_hps[1][1]] = 2
    material_ids = inputs[material_id_idx]

    norm = NormalizeTransform(config.model_1hp_info)
    inputs = norm(inputs, "Inputs")


    size_hp_box = torch.tensor([config.model_1hp_info["CellsNumber"][0], config.model_1hp_info["CellsNumber"][1],])
    distance_hp_corner = torch.tensor([config.model_1hp_info["PositionLastHP"][1], config.model_1hp_info["PositionLastHP"][0]-2])
    pos_hps = torch.stack(pos_hps)

    hp_boxes = []
    corners_ll = []

    for idx in range(len(pos_hps)):
        
        pos_hp = pos_hps[idx]

        corner_ll, corner_ur = domain.get_box_corners(pos_hp, size_hp_box, distance_hp_corner, inputs.shape[1:])
        corners_ll.append(corner_ll)

        tmp_input = inputs[:, corner_ll[0] : corner_ur[0], corner_ll[1] : corner_ur[1]].detach().clone()
        tmp_mat_ids = torch.stack(list(torch.where(tmp_input == torch.max(material_ids))), dim=0).T

        if len(tmp_mat_ids) > 1:
            for i in range(len(tmp_mat_ids)):
                tmp_pos = tmp_mat_ids[i]
                if (tmp_pos[1:2] != distance_hp_corner).all():
                    tmp_input[tmp_pos[0], tmp_pos[1], tmp_pos[2]] = 0
            
        tmp_hp = HeatPump(id=idx, pos=pos_hp, orientation=0, inputs=tmp_input, names=[], dist_corner_hp=distance_hp_corner, label=None, device=config.device,)
            
        if "SDF" in config.model_1hp_info["Inputs"]: # 0.00071s anstatt 0.088s mit tmp_hp.recalc_sdf(info)
            index_sdf = config.model_1hp_info["Inputs"]["SDF"]["index"]
            distances = torch.tensor(np.moveaxis(np.mgrid[:tmp_input[index_sdf].shape[0],:tmp_input[index_sdf].shape[1]], 0, -1)) - distance_hp_corner
            distances = torch.linalg.vector_norm(distances.float(), dim=2)
            tmp_hp.inputs[index_sdf] = 1 - distances / distances.max()

        hp_boxes.append(tmp_hp)

    return hp_boxes, corners_ll


def prepare_hp_boxes_demonstrator(config, single_hps: List[HeatPump]):
    hp: prep_2hp.HeatPump
    hp_inputs = []

    for hp in single_hps:   
        hp.primary_temp_field = hp.apply_nn(config.model_1hp)
        hp.primary_temp_field = prep_2hp.reverse_temperature_norm(hp.primary_temp_field, config.model_2hp_info)

    for hp in single_hps:
        hp.get_other_temp_field(single_hps)

    for hp in single_hps:
        hp.primary_temp_field = prep_2hp.norm_temperature(hp.primary_temp_field, config.model_2hp_info)
        hp.other_temp_field = prep_2hp.norm_temperature(hp.other_temp_field, config.model_2hp_info)
        inputs = stack([hp.primary_temp_field, hp.other_temp_field])

        hp_inputs.append(inputs)

    return stack(hp_inputs)


def get_plots(config: ModelConfiguration, x: torch.Tensor, y: torch.Tensor, norm) -> ReturnData:

    x = torch.unsqueeze(x, 0)
    y_out = config.model_1hp(x).to(config.device)

    # reverse transform for plotting real values
    x = norm.reverse(x.detach().squeeze(), "Inputs").cpu()
    y = norm.reverse(y.detach(),"Labels")[0].cpu()
    y_out = norm.reverse(y_out.detach()[0],"Labels")[0].cpu()

    dict_to_plot = visualize.prepare_data_to_plot(x, y, y_out, config.model_1hp_info)
    return_data = ReturnData(config.color_palette)
    return_data.set_figure("model_result", dict_to_plot["t_out"].data.T, **dict_to_plot["t_out"].imshowargs)
    return_data.set_figure("groundtruth", dict_to_plot["t_true"].data.T, **dict_to_plot["t_true"].imshowargs)
    return_data.set_figure("error_measure", dict_to_plot["error"].data.T, **dict_to_plot["error"].imshowargs)
    return_data.set_return_value("average_error", torch.mean(torch.abs(y_out - y)).item())

    return return_data


def get_2hp_plots(config: ModelConfiguration, hp_inputs, corners_ll, corner_dist) -> ReturnData:
    # TODO: Hier noch langsam

    size_hp_box = config.model_2hp_info["CellsNumberPrior"]
    image_shape = config.model_2hp_info["OutFieldShape"]
    out_image = torch.full(image_shape, 10.6)

    with torch.no_grad():
        config.model_2hp.eval()
        y_out = config.model_2hp(hp_inputs.detach()) # TODO: Zwischen 0.02s und 0.25s ...

    for i in range(2):
        y = y_out[i].detach()[0]
        y = prep_2hp.reverse_temperature_norm(y, config.model_2hp_info).cpu()

        ll_x = corners_ll[i][0] - corner_dist[1]
        ll_y = corners_ll[i][1] - corner_dist[0]
        ur_x = ll_x + size_hp_box[0]
        ur_y = ll_y + size_hp_box[1]
        clip_ll_x = max(ll_x, 0)
        clip_ll_y = max(ll_y, 0)
        clip_ur_x = min(ur_x, image_shape[0])
        clip_ur_y = min(ur_y, image_shape[1])

        out_image[clip_ll_x : clip_ur_x, clip_ll_y : clip_ur_y] = torch.maximum(y[clip_ll_x - ll_x : y.shape[0] - ur_x + clip_ur_x, clip_ll_y - ll_y : y.shape[1] - ur_y + clip_ur_y], 
                                                                                out_image[clip_ll_x : clip_ur_x, clip_ll_y : clip_ur_y])

    extent_highs = out_image.shape * np.array(config.model_2hp_info["CellsSize"][:2])
    return_data = ReturnData(config.color_palette)
    return_data.set_figure("model_result", out_image.T, cmap="RdBu_r", extent=(0, extent_highs[0], extent_highs[1], 0))

    return return_data
import sys
import os
import torch
import numpy as np
from typing import Dict, List, Tuple, Any, Union

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import utils.visualization as visualize
import preprocessing.prepare_2ndstage as prep_2hp
from data_stuff.transforms import NormalizeTransform

from model_communication import ModelConfiguration, ReturnData

def get_1hp_plots(config: ModelConfiguration, x: torch.Tensor, y: torch.Tensor, norm: NormalizeTransform) -> ReturnData:

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
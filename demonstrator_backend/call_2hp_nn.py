import os
import pathlib
import sys
import yaml
import multiprocessing
import numpy as np
import time

import matplotlib.pyplot as plt
from matplotlib.figure import Figure
import generate_groundtruth as gt

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import main as hp_nn
from utils.visualization import plot_avg_error_cellwise, infer_all_and_summed_pic, get_2hp_plots
from utils.measurements import measure_loss, save_all_measurements
import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prep_1hp
import preprocessing.prepare_2ndstage as prep_2hp
from utils.prepare_paths import Paths2HP
from data_stuff.utils import SettingsTraining
import model_communication as mc


def test_2hp_model_communication():

    ## Einstellungen

    path_to_project_dir = pathlib.Path((os.path.dirname(os.path.abspath(__file__)))) / ".." / ".."
    paths_file = path_to_project_dir / "1HP_NN" / "paths.yaml"

    if os.path.exists(paths_file):
        with open(paths_file, "r") as f:
            paths_file = yaml.safe_load(f)
    else:
        print(f"WO: {paths_file}")

    # prepare_data_and_paths(settings):

    datasets_raw_domain_dir      = pathlib.Path(paths_file["datasets_raw_domain_dir"])
    datasets_prepared_domain_dir = pathlib.Path(paths_file["datasets_prepared_domain_dir"])
    prepared_1hp_dir             = pathlib.Path(paths_file["prepared_1hp_best_models_and_data_dir"])
    destination_dir              = pathlib.Path(paths_file["models_2hp_dir"])
    datasets_prepared_2hp_dir    = pathlib.Path(paths_file["datasets_prepared_dir_2hp"])

    settings = SettingsTraining(
        dataset_raw = "dataset_2hps_demonstrator_1dp",
        inputs = "gksi1000",
        device = "cpu",
        epochs = 10000,
        case = "test",
        model = destination_dir / "1000dp_1000gksi_separate" / "current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1",
        visualize = True
    )

    # TODO gksi durch split-Funktion
    dataset_model_trained_with_prep_path = prepared_1hp_dir / settings.inputs / "dataset_raw_demonstrator_input_1dp inputs_gksi"
    model_1hp_path           = prepared_1hp_dir / settings.inputs / "current_unet_dataset_2d_small_1000dp_gksi_v7"
    dataset_raw_path         = datasets_raw_domain_dir / "dataset_2hps_demonstrator_1dp"
    dataset_1st_prep_path    = datasets_prepared_domain_dir / "dataset_2hps_demonstrator_1dp inputs_gksi"
    datasets_boxes_prep_path = datasets_prepared_2hp_dir / "dataset_2hps_demonstrator_1dp inputs_gksi1000 boxes"

    paths = Paths2HP(
        dataset_raw_path,
        dataset_model_trained_with_prep_path,
        dataset_1st_prep_path,
        model_1hp_path,
        datasets_boxes_prep_path,
    )
    settings.dataset_prep = paths.datasets_boxes_prep_path

    with open(paths.dataset_1st_prep_path / "info.yaml", "r") as f:
        info = yaml.safe_load(f)


    corner_dist = info["PositionHPPrior"]
    pos_2nd_hp = [10, 10]

    pressure = -2.142171334025262316e-04
    permeability = 7.350276541753949086e-10
    positions = [[corner_dist[1] + 50, corner_dist[0] + 50], [corner_dist[1] + pos_2nd_hp[0], corner_dist[0] + pos_2nd_hp[1]]]

    model_1HP = UNet(in_channels=len("gksi")).float()
    model_1HP.load(paths.model_1hp_path, settings.device)

    hp_inputs, corners_ll = prep_2hp.prepare_demonstrator_input_2hp(info, model_1HP, pressure, permeability, positions)

    ## Modellanwendung

    #multiprocessing.set_start_method("spawn", force=True)
    dataset, dataloaders = hp_nn.init_data(settings)

    model = UNet(in_channels=dataset.input_channels).float()
    model.load(pathlib.Path(settings.model), settings.device)
    model.to(settings.device)

    color_palette = mc.ColorPalette(
        cmap_list        = [(0.1,0.27,0.8), (1,1,1), (1,0.1,0.1)],
        background_color = (1,1,1),
        text_color       = (0,0,0) 
    )

    ## Visualisierung
    if settings.visualize:
        dat = get_2hp_plots(model, hp_inputs, corners_ll, corner_dist, dataloaders["test"], color_palette, device=settings.device)
        show_figure(dat.get_figure("result"))


def show_figure(figure: Figure):
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = figure
    figure.set_canvas(canvas_manager.canvas)
    plt.show()

if __name__ == "__main__":
    test_2hp_model_communication()
import os
import pathlib
import sys
import yaml
import multiprocessing

import matplotlib.pyplot as plt
from matplotlib.figure import Figure

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import main as hp_nn
import utils.visualization as visualize
from networks.unet import UNet
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
        try:
            default_raw_1hp_dir = pathlib.Path(paths_file["default_raw_dir"])
            prepared_domain_dir = pathlib.Path(paths_file["datasets_prepared_domain_dir"])
            prepared_boxes_dir  = pathlib.Path(paths_file["datasets_prepared_dir_2hp"])
            models_1hp_dir      = pathlib.Path(paths_file["models_1hp_dir"])
            models_2hp_dir      = pathlib.Path(paths_file["models_2hp_dir"])
        except:
            print(f'Error loading "{paths_file}"')
    else:
        print(f'1HP_NN/info.yaml not found, trying default path')
        default_raw_1hp_dir = path_to_project_dir / "datasets_raw"
        prepared_domain_dir = path_to_project_dir / "datasets_prepared_domain"
        prepared_boxes_dir  = path_to_project_dir / "datasets_prepared"
        models_1hp_dir      = path_to_project_dir / "models_1hpnn"
        models_2hp_dir      = path_to_project_dir / "models_2hpnn"


    model_2hp_dir = models_2hp_dir / "1000dp_1000gksi_separate" / "current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1"
    model_1hp_dir = models_1hp_dir / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"

    dataset_2hpnn_names = ["dataset_2hps_demonstrator_1dp"]
    dataset_1hpnn_names = ["dataset_2d_small_1000dp", "datasets_raw_1000_1HP"]
    dataset_domain_prepared_name = None
    dataset_boxes_prepared_name = None
    raw_dataset_1hpnn_name = None

    for name in dataset_1hpnn_names:
        if os.path.exists(default_raw_1hp_dir / name):
            raw_dataset_1hpnn_name = name

    for name in dataset_2hpnn_names:
        if os.path.exists(prepared_domain_dir / (name + " inputs_gksi")):
            dataset_domain_prepared_name = name + " inputs_gksi"
        if os.path.exists(prepared_boxes_dir / (name + " inputs_gksi1000 boxes")):
            dataset_boxes_prepared_name = name + " inputs_gksi1000 boxes"

    if raw_dataset_1hpnn_name is None:
        raise FileNotFoundError(f'1HP raw dataset not found at "{default_raw_1hp_dir}"')
    
    if dataset_domain_prepared_name is None:
        raise FileNotFoundError(f'2HP prepared domain dataset not found at "{prepared_domain_dir}"')

    if dataset_boxes_prepared_name is None:
        raise FileNotFoundError(f'2HP prepared boxes dataset not found at "{prepared_boxes_dir}"')
    
    # prepare_data_and_paths(settings):

    paths = Paths2HP(
        default_raw_1hp_dir / raw_dataset_1hpnn_name, # nötig 1hp wegen Grundwahrheit
        "",
        prepared_domain_dir / dataset_domain_prepared_name, # nötig 2hp wegen info.yaml
        model_1hp_dir,
        prepared_boxes_dir / dataset_boxes_prepared_name, # nötig 2hp wegen /Inputs
    )

    settings = SettingsTraining(
        dataset_raw = raw_dataset_1hpnn_name,
        inputs = "gksi1000",
        device = "cpu",
        epochs = 1,
        case = "test",
        model = model_2hp_dir,
        visualize = True,
        dataset_prep = paths.datasets_boxes_prep_path
    )

    with open(paths.dataset_1st_prep_path / "info.yaml", "r") as f:
        info = yaml.safe_load(f)


    print(paths.dataset_1st_prep_path)


    corner_dist = info["PositionHPPrior"]
    pos_2nd_hp = [40, 45]

    pressure = -2.142171334025262316e-03
    permeability = 7.350276541753949086e-11
    positions = [[corner_dist[1] + 50, corner_dist[0] + 50], [corner_dist[1] + pos_2nd_hp[0], corner_dist[0] + pos_2nd_hp[1]]]

    multiprocessing.set_start_method("spawn", force=True) #TODO ???

    model_1HP = UNet(in_channels=len("gksi")).float()
    model_1HP.load(paths.model_1hp_path, settings.device)

    model_2HP = UNet(in_channels=2).float()
    model_2HP.load(settings.model, settings.device)
    model_2HP.to(settings.device)

    color_palette = mc.ColorPalette(
        cmap_list        = [(0.1,0.27,0.8), (1,1,1), (1,0.1,0.1)],
        background_color = (1,1,1),
        text_color       = (0,0,0) 
    )

    hp_inputs, corners_ll = prep_2hp.prepare_demonstrator_input_2hp(info, model_1HP, pressure, permeability, positions)
    dat = visualize.get_2hp_plots(model_2HP, info, hp_inputs, corners_ll, corner_dist, color_palette, device=settings.device)
    show_figure(dat.get_figure("result"))


def show_figure(figure: Figure):
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = figure
    figure.set_canvas(canvas_manager.canvas)
    plt.show()

if __name__ == "__main__":
    test_2hp_model_communication()
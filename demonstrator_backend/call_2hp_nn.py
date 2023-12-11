import os
import pathlib
import sys
import yaml
import multiprocessing
import numpy as np
import time

import generate_groundtruth as gt

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import main as hp_nn
from utils.visualization import plot_avg_error_cellwise, visualizations_demonstrator, infer_all_and_summed_pic, visualizations
from utils.measurements import measure_loss, save_all_measurements
import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prep_1hp
import preprocessing.prepare_2ndstage as prep_2hp
from utils.prepare_paths import Paths2HP
from data_stuff.utils import SettingsTraining


def test_2hp_model_communication():

    ## Einstellungen

    settings = SettingsTraining(
        dataset_raw = "dataset_2hps_demonstrator_1dp",
        inputs = "gksi1000",
        device = "cpu",
        epochs = 10000,
        case = "test",
        model = "1000dp_1000gksi_separate/current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1",
        visualize = True
    )

    path_to_project_dir = pathlib.Path((os.path.dirname(os.path.abspath(__file__)))) / ".." / ".."
    paths_file = path_to_project_dir / "1HP_NN" / "paths.yaml"

    if os.path.exists(paths_file):
        with open(paths_file, "r") as f:
            paths_file = yaml.safe_load(f)

    # prepare_data_and_paths(settings):

    datasets_raw_domain_dir      = pathlib.Path(paths_file["datasets_raw_domain_dir"])
    datasets_prepared_domain_dir = pathlib.Path(paths_file["datasets_prepared_domain_dir"])
    prepared_1hp_dir             = pathlib.Path(paths_file["prepared_1hp_best_models_and_data_dir"])
    destination_dir              = pathlib.Path(paths_file["models_2hp_dir"])
    datasets_prepared_2hp_dir    = pathlib.Path(paths_file["datasets_prepared_dir_2hp"])

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
    settings.make_destination_path(destination_dir)
    settings.make_model_path(destination_dir)

    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    groundtruth_info = gt.GroundTruthInfo(path_to_dataset, 10.6)

    hp_inputs = prep_2hp.prepare_demonstrator_input_2nd_stage(paths, "gksi", groundtruth_info, device=settings.device)

    ## Modellanwendung

    #multiprocessing.set_start_method("spawn", force=True)
    dataset, dataloaders = hp_nn.init_data(settings)

    model = UNet(in_channels=dataset.input_channels).float()
    model.load(settings.model, settings.device)
    model.to(settings.device)

    ## Visualisierung
    if settings.visualize:
        visualizations_demonstrator(model, hp_inputs, dataloaders["test"], settings.device, plot_path=settings.destination / f"plot_test", amount_datapoints_to_visu=1, pic_format="png")
        #visualizations(model, dataloaders["test"], settings.device, plot_path=settings.destination / f"plot_test", amount_datapoints_to_visu=1, pic_format="png")
        _, summed_error_pic = infer_all_and_summed_pic(model, dataloaders["test"], settings.device)
        plot_avg_error_cellwise(dataloaders["test"], summed_error_pic, {"folder" : settings.destination, "format": "png"})


    # (x, y, info, norm) = prepare.prepare_demonstrator_input_1st_stage(self.paths1HP, self.settings, self.groundtruth_info, permeability, pressure)
    # visualize.get_plots(self.model, x, y, info, norm, self.figures)

if __name__ == "__main__":
    test_2hp_model_communication()
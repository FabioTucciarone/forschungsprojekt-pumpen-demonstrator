import os
import pathlib
import numpy as np
import sys
import logging 
import torch
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from torch import load
import yaml

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import main as hp1_nn
import preprocessing.prepare_1ststage as prepare
from utils.prepare_paths import Paths1HP
from data_stuff.utils import SettingsTraining

class ModelCommunication:

    paths1HP: Paths1HP = None
    settings: SettingsTraining = None

    def get_settings(self, dataset: str = "datasets_raw_1000_1HP"):
        """
        Read in settings.yaml
        """
        default_raw_dir = self.paths1HP.raw_dir
        path_to_settings = os.path.join(default_raw_dir, dataset, "inputs")
        settings = prepare.get_pflotran_settings(path_to_settings)
        return settings


    def __init__(self, dataset_name: str = "datasets_raw_1000_1HP", full_model_path: str = None):
        """ 
        Initialize paths and model settings.

        Parameters
        ----------
        dataset_name: str
            Name of "dataset" containing the settings.yaml file from which the pflortran settings are extracted.
        full_model_path: str
            Full path to a gksi1000 model. Default path: see README.md (or Notion)
        """
        path_to_project_dir = pathlib.Path((os.path.dirname(os.path.abspath(__file__)))) / ".." / ".."
        if full_model_path is None:
            full_model_path = path_to_project_dir / "data" / "models_1hpnn" / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"

        paths_file = path_to_project_dir / "1HP_NN" / "paths.yaml"

        if not os.path.exists(paths_file):
            raise FileNotFoundError(f"{paths_file} not found")

        with open(paths_file, "r") as f:
            paths = yaml.safe_load(f)
            default_raw_dir = paths["default_raw_dir"]
            datasets_prepared_dir = paths["datasets_prepared_dir"]
            dataset_prepared_full_path = pathlib.Path(datasets_prepared_dir) / f"{dataset_name} inputs_gksi"

            self.paths1HP = Paths1HP(default_raw_dir, datasets_prepared_dir, dataset_prepared_full_path)

        self.settings = SettingsTraining(
            dataset_raw = dataset_name,
            inputs = "gksi",
            device = "cpu",
            epochs = 10000,
            case = "test",
            model = full_model_path,
            visualize = True,
            destination_dir=""
        )
        self.settings.datasets_dir = self.paths1HP.datasets_prepared_dir
        self.settings.dataset_prep = f"{dataset_name} inputs_gksi"


    def get_1hp_model_results(self, permeability: float, pressure: float):
        """
        Prepare a dataset and run the model.

        Parameters
        ----------
        permeability: float
            The permeability input parameter of the demonstrator app.
        pressure: float
            The pressure input parameter of the demonstrator app.
        """
        prepare.prepare_demonstrator_input_1st_stage(self.paths1HP, self.settings, permeability, pressure)
        return hp1_nn.run(self.settings, return_to_demonstrator=True)


# Test: Ausführen dieser Datei zeigt festes Testbild.

if __name__ == "__main__":
    mc = ModelCommunication()
    res = mc.get_1hp_model_results(2.646978938535798940e-10, -2.830821194764205056e-03)

    # Anzeigen des Bilds (Achtung, schlecht, nur zum Testen):
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = res[0]
    res[0].set_canvas(canvas_manager.canvas)
    plt.show()







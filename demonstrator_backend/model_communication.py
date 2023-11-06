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
import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prepare
from utils.prepare_paths import Paths1HP
from data_stuff.utils import SettingsTraining
from data_stuff.transforms import NormalizeTransform

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

        if os.path.exists(paths_file):
            with open(paths_file, "r") as f:
                paths = yaml.safe_load(f)
                default_raw_dir = paths["default_raw_dir"]
                datasets_prepared_dir = paths["datasets_prepared_dir"]
        else:
            default_raw_dir = path_to_project_dir / "data" / "datasets_raw"
            datasets_prepared_dir = path_to_project_dir / "data" / "datasets_prepared"

        if not os.path.exists(os.path.join(default_raw_dir, dataset_name)):
            raise FileNotFoundError(f"Dataset path {os.path.join(default_raw_dir, dataset_name)} does not exist")

        self.paths1HP = Paths1HP(default_raw_dir, datasets_prepared_dir, "")

        self.settings = SettingsTraining(
            dataset_raw = dataset_name,
            inputs = "gksi",
            device = "cpu", # TODO: GPU?
            epochs = 10000,
            case = "test",
            model = full_model_path,
            visualize = True,
            destination_dir = ""
        )
        self.settings.datasets_dir = self.paths1HP.datasets_prepared_dir


    def prepare_model(self):
        dataset, dataloaders = hp1_nn.init_data(self.settings)
        self.dataloaders = dataloaders
        # init, load and save model
        self.model = UNet(in_channels=dataset.input_channels).float() # len(self.info["Inputs"])
        self.model.load_state_dict(torch.load(f"{self.settings.model}/model.pt", map_location=torch.device(self.settings.device)))
        self.model.to(self.settings.device)
        self.model.eval()


    def get_1hp_model_results(self, permeability: float, pressure: float, id: int):
        """
        Prepare a dataset and run the model.

        Parameters
        ----------
        permeability: float
            The permeability input parameter of the demonstrator app.
        pressure: float
            The pressure input parameter of the demonstrator app.
        """
        self.settings.dataset_prep = f"{self.settings.dataset_raw} demonstrator id_{id}"
        self.paths1HP.dataset_1st_prep_path = pathlib.Path(self.paths1HP.datasets_prepared_dir) / self.settings.dataset_prep

        (x, y, info) = prepare.prepare_demonstrator_input_1st_stage(self.paths1HP, self.settings, permeability, pressure)
        norm = NormalizeTransform(info)

        #dataset, dataloaders = hp1_nn.init_data(self.settings)
        #self.dataloaders = dataloaders
        # init, load and save model
        self.model = UNet(in_channels=len(info["Inputs"])).float() # len(self.info["Inputs"])
        self.model.load_state_dict(torch.load(f"{self.settings.model}/model.pt", map_location=torch.device(self.settings.device)))
        self.model.to(self.settings.device)
        self.model.eval()

        return visualize.get_plots(self.model, x, y, info, norm, self.settings.device)

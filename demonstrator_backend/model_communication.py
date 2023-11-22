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
import generate_groundtruth as gt
from mpl_toolkits.axes_grid1 import make_axes_locatable

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import main as hp1_nn
import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prepare
from utils.prepare_paths import Paths1HP
from data_stuff.utils import SettingsTraining


class Figures:
    figures: list
    axes: list
    colorbar_axis: list

    def __init__(self):
        self.figures = [Figure(figsize=(20, 2)) for i in range(3)]
        self.axes = [self.figures[i].add_subplot(1, 1, 1) for i in range(3)]
        self.colorbar_axis = [None, None, None]
        for i in range(3):
            self.axes[i].invert_yaxis()
            self.figures[i].tight_layout()
            self.colorbar_axis[i] = make_axes_locatable(self.figures[i].gca()).append_axes("right", size=0.3, pad=0.05)

    def update_figure(self, i, pixel_data, **imshowargs):
        axes_image = self.axes[i].imshow(pixel_data, **imshowargs)
        self.figures[i].colorbar(axes_image, cax=self.colorbar_axis[i])

    def get_figure(self, i):
        return self.figures[i]


class ModelCommunication:

    paths1HP: Paths1HP = None
    settings: SettingsTraining = None
    figures: Figures
    groundtruth_info: gt.GroundTruthInfo
    
    
    def get_min_max_perm(self) :
        """
        Read out min/max values
        """
        settings = prepare.get_pflotran_settings(self.paths1HP.raw_dir / "inputs")
        print(settings["permeability"].size())
        min_max = [settings["permeability"][7], settings["permeability"][6]]
        return min_max


    def __init__(self, dataset_name: str = "datasets_raw_1000_1HP"):
        """ 
        Initialize paths and model settings.
        Model is searched according to the paths.yaml file.
        If no such file exists default folder structure is assumed (see README.md).

        Parameters
        ----------
        dataset_name: str
            Name of "dataset" containing the settings.yaml file from which the pflortran settings are extracted.
        """
        path_to_project_dir = pathlib.Path((os.path.dirname(os.path.abspath(__file__)))) / ".." / ".."
        paths_file = path_to_project_dir / "1HP_NN" / "paths.yaml"

        if os.path.exists(paths_file):
            with open(paths_file, "r") as f:
                paths = yaml.safe_load(f)

                raw_path = pathlib.Path(paths["default_raw_dir"]) / dataset_name
                if not os.path.exists(raw_path):
                    print(f"Could not find '{raw_path}', searching for 'dataset_2d_small_1000dp'")
                    raw_path = pathlib.Path(paths["default_raw_dir"]) / "dataset_2d_small_1000dp"
                
                model_path = pathlib.Path(paths["models_1hp_dir"]) / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"
                if not os.path.exists(raw_path):
                    raise FileNotFoundError(f"Model path '{model_path}' does not exist")
        else:
            print(f"Could not find '1HP_NN/paths.yaml', assuming for default folder structure.")

            raw_path = path_to_project_dir / "data" / "datasets_raw" / dataset_name
            if not os.path.exists(raw_path):
                print(f"Could not find '{raw_path}', searching for 'dataset_2d_small_1000dp'")
                raw_path = path_to_project_dir / "data" / "datasets_raw" / "dataset_2d_small_1000dp"  
            
            model_path = path_to_project_dir / "data" / "models_1hpnn" / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"

        if not os.path.exists(raw_path):
            raise FileNotFoundError(f"Dataset path '{raw_path}' does not exist")


        self.paths1HP = Paths1HP(raw_path, "")

        self.settings = SettingsTraining(
            dataset_raw = dataset_name,
            inputs = "gksi",
            device = "cpu", # TODO: GPU?
            epochs = 10000,
            case = "test",
            model = model_path,
            visualize = True
        )
        self.prepare_model()

        self.groundtruth_info = gt.GroundTruthInfo(raw_path, 10.6, use_interpolation=True)
        self.figures = Figures()
    

    def prepare_model(self):
        self.model = UNet(in_channels=4).float() # 4 = len(info["Inputs"]) TODO: Aus Rohdaten einlesen?
        self.model.load_state_dict(torch.load(f"{self.settings.model}/model.pt", map_location=torch.device(self.settings.device)))
        self.model.to(self.settings.device)
        self.model.eval()


    def update_1hp_model_results(self, permeability: float, pressure: float):
        """
        Prepare a dataset and run the model.

        Parameters
        ----------
        permeability: float
            The permeability input parameter of the demonstrator app.
        pressure: float
            The pressure input parameter of the demonstrator app.
        """
        (x, y, info, norm) = prepare.prepare_demonstrator_input_1st_stage(self.paths1HP, self.settings, self.groundtruth_info, permeability, pressure)
        visualize.get_plots(self.model, x, y, info, norm, self.figures)

# ?????
class ModelCommunication_2HP:
    def prepare_1hpnn():
        """
        2HP-NN expects that 1HP-NN exists and trained on
        """

    def prepare_2hpnn(one_hpnn_prepared_dir):
        """
        for running a 2HP-NN you need the prepared 2HP-dataset in datasets_prepared_dir_2hp
        TODO: python3 main.py --dataset "dataset_raw_demonstrator_input_1dp inputs_gksi" --case_2hp True --inputs gksi1000
        """
import os
import io
import pathlib
import sys
import torch
from matplotlib.figure import Figure
import yaml
import generate_groundtruth as gt
from mpl_toolkits.axes_grid1 import make_axes_locatable
from dataclasses import dataclass
import base64


sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prepare
from utils.prepare_paths import Paths1HP
from data_stuff.utils import SettingsTraining


class DisplayData:
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

    def encode_image(self, buffer):
        return str(base64.b64encode(buffer.getbuffer()).decode("ascii"))

    def set_figure(self, i, pixel_data, **imshowargs):
        axes_image = self.axes[i].imshow(pixel_data, **imshowargs)
        self.figures[i].colorbar(axes_image, cax=self.colorbar_axis[i])

    def get_figure(self, i):
        return self.figures[i]

    def get_encoded_figure(self, i):
        image_bytes = io.BytesIO()
        self.figures[i].savefig(image_bytes, format="png")
        return self.encode_image(image_bytes)


@dataclass
class ModelConfiguration:

    paths1HP: Paths1HP = None
    settings: SettingsTraining = None
    groundtruth_info: gt.GroundTruthInfo = None
    model_info: dict = None

    def __post_init__(self):
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

                raw_path = pathlib.Path(paths["default_raw_dir"]) / "datasets_raw_1000_1HP"
                dataset_name = "datasets_raw_1000_1HP"
                if not os.path.exists(raw_path):
                    print(f"Could not find '{raw_path}', searching for 'dataset_2d_small_1000dp'")
                    raw_path = pathlib.Path(paths["default_raw_dir"]) / "dataset_2d_small_1000dp"
                    dataset_name = "dataset_2d_small_1000dp"
                
                model_path = pathlib.Path(paths["models_1hp_dir"]) / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"
                if not os.path.exists(raw_path):
                    raise FileNotFoundError(f"Model path '{model_path}' does not exist")
        else:
            print(f"Could not find '1HP_NN/paths.yaml', assuming default folder structure.")

            raw_path = path_to_project_dir / "data" / "datasets_raw" / "datasets_raw_1000_1HP"
            if not os.path.exists(raw_path):
                print(f"Could not find '{raw_path}', searching for 'dataset_2d_small_1000dp'")
                raw_path = path_to_project_dir / "data" / "datasets_raw" / "dataset_2d_small_1000dp"
                dataset_name = "dataset_2d_small_1000dp"
            
            model_path = path_to_project_dir / "data" / "models_1hpnn" / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"

        if not os.path.exists(raw_path):
            raise FileNotFoundError(f"Dataset path '{raw_path}' does not exist")


        self.settings = SettingsTraining(
            dataset_raw = dataset_name,
            inputs = "gksi",
            device = "cpu", 
            epochs = 10000,
            case = "test",
            model = model_path,
            visualize = True
        )
        self.paths1HP = Paths1HP(raw_path, "")
        self.groundtruth_info = gt.GroundTruthInfo(raw_path, 10.6, use_interpolation=True)

        with open(os.path.join(os.getcwd(), self.settings.model, "info.yaml"), "r") as file:
            self.model_info = yaml.safe_load(file)



def get_1hp_model_results(model_configuration, permeability: float, pressure: float, name: str):
    """
    Prepare a dataset and run the model.

    Parameters
    ----------
    permeability: float
        The permeability input parameter of the demonstrator app.
    pressure: float
        The pressure input parameter of the demonstrator app.
    """

    model = UNet(in_channels=4).float() # 4 = len(info["Inputs"]) TODO: Aus Rohdaten einlesen?
    model.load_state_dict(torch.load(f"{model_configuration.settings.model}/model.pt", map_location=torch.device(model_configuration.settings.device)))
    model.to(model_configuration.settings.device)
    model.eval()

    (x, y, info, norm) = prepare.prepare_demonstrator_input(model_configuration.paths1HP, model_configuration.groundtruth_info, permeability, pressure, info=model_configuration.model_info)
    return visualize.get_plots(model, x, y, info, norm)

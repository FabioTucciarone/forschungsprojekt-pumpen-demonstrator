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
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prepare
from utils.prepare_paths import Paths1HP
from data_stuff.utils import SettingsTraining


@dataclass
class ColorPalette:
    cmap_list: list = None
    background_color: tuple = (1,1,1)
    text_color: tuple = (0,0,0)


class DisplayData:
    figures: list
    axes: list
    colorbar_axis: list
    color_palette: ColorPalette
    color_map: LinearSegmentedColormap = None

    # fig.patch.set_facecolor('xkcd:mint green')

    # cmap = LinearSegmentedColormap.from_list("demonstrator", cmap_list, N=20)
    
    # ax.spines['bottom'].set_color('red')
    # ax.spines['top'].set_color('red')
    # ax.xaxis.label.set_color('red')
    # ax.tick_params(axis='x', colors='red')

    def __init__(self, color_palette: ColorPalette):
        self.figures = [Figure(figsize=(21, 2)) for i in range(3)]
        self.axes = [self.figures[i].add_subplot(1, 1, 1) for i in range(3)]
        self.colorbar_axis = [None, None, None]
        self.color_palette = color_palette
        if self.color_palette.cmap_list is not None:
            self.color_map = LinearSegmentedColormap.from_list("demonstrator", color_palette.cmap_list, N=100)
        for i in range(3):
            self.axes[i].invert_yaxis()
            self.axes[i].tick_params(colors=self.color_palette.text_color)
            self.figures[i].patch.set_facecolor(self.color_palette.background_color)
            self.figures[i].tight_layout()
            self.colorbar_axis[i] = make_axes_locatable(self.figures[i].gca()).append_axes("right", size=0.3, pad=0.05)
            self.colorbar_axis[i].yaxis.set_tick_params(colors=self.color_palette.text_color)

        

    def encode_image(self, buffer):
        return str(base64.b64encode(buffer.getbuffer()).decode("ascii"))

    def set_figure(self, i, pixel_data, **imshowargs):
        if self.color_map is not None:
            imshowargs['cmap'] = self.color_map
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
    color_palette: ColorPalette = None

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
        raw_path, model_path, dataset_name = self.load_paths()
        self.paths1HP = Paths1HP(raw_path, "")

        self.settings = SettingsTraining(
            dataset_raw = dataset_name,
            inputs = "gksi",
            device = "cpu", 
            epochs = 10000,
            case = "test",
            model = model_path,
            visualize = True
        )
        
        self.groundtruth_info = gt.GroundTruthInfo(raw_path, 10.6, use_interpolation=True)

        self.color_palette = ColorPalette()

        with open(os.path.join(os.getcwd(), self.settings.model, "info.yaml"), "r") as file:
            self.model_info = yaml.safe_load(file)


    def load_paths(self):
        path_to_project_dir = pathlib.Path((os.path.dirname(os.path.abspath(__file__)))) / ".." / ".."
        paths_file = path_to_project_dir / "1HP_NN" / "paths.yaml"

        if os.path.exists(paths_file):
            with open(paths_file, "r") as f:
                paths = yaml.safe_load(f)

                raw_path = pathlib.Path(paths["default_raw_dir"]) / "datasets_raw_1000_1HP"
                dataset_name = "datasets_raw_1000_1HP"
                default_raw_dir = pathlib.Path(paths["default_raw_dir"])

                if not os.path.exists(default_raw_dir / dataset_name):
                    print(f"Could not find '{default_raw_dir / dataset_name}', searching for 'dataset_2d_small_1000dp'")
                    dataset_name = "dataset_2d_small_1000dp"

                raw_path = default_raw_dir / dataset_name
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
            
        return raw_path, model_path, dataset_name


    def set_color_palette(self, color_palette):
        self.color_palette = color_palette


def get_1hp_model_results(config: ModelConfiguration, permeability: float, pressure: float, name: str):
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
    model.load_state_dict(torch.load(f"{config.settings.model}/model.pt", map_location=torch.device(config.settings.device)))
    model.to(config.settings.device)
    model.eval()

    (x, y, info, norm) = prepare.prepare_demonstrator_input(config.paths1HP, config.groundtruth_info, permeability, pressure, info=config.model_info)
    return visualize.get_plots(model, x, y, info, norm, config.color_palette)

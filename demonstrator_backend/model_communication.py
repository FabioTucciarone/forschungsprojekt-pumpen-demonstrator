import os
import io
import pathlib
import sys
import torch
from matplotlib.figure import Figure
import yaml
import generate_groundtruth as gt
from dataclasses import dataclass
import base64
from matplotlib.colors import LinearSegmentedColormap
import matplotlib.pyplot as plt

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prep_1hp
import preprocessing.prepare_2ndstage as prep_2hp
from utils.prepare_paths import Paths2HP
from data_stuff.utils import SettingsTraining
from mpl_toolkits.axes_grid1 import make_axes_locatable


@dataclass
class ColorPalette:
    cmap_list: list = None
    background_color: tuple = (1,1,1)
    text_color: tuple = (0,0,0)


class DisplayData:
    figures: dict
    color_palette: ColorPalette
    color_map: LinearSegmentedColormap = None
    average_error = None

    def __init__(self, color_palette: ColorPalette):
        self.figures = dict()
        self.colorbar_axis = dict()
        self.color_palette = color_palette
        if self.color_palette.cmap_list is not None:
            self.color_map = LinearSegmentedColormap.from_list("demonstrator", color_palette.cmap_list, N=100)

    def encode_image(self, buffer):
        return str(base64.b64encode(buffer.getbuffer()).decode("ascii"))


    def set_figure(self, figure_name, pixel_data, **imshowargs):
        self.figures[figure_name] = Figure(figsize=(21, 2))
        axis = self.figures[figure_name].add_subplot(1, 1, 1)
        axis.invert_yaxis()
        axis.tick_params(colors=self.color_palette.text_color)
        self.figures[figure_name].patch.set_facecolor(self.color_palette.background_color)
        self.figures[figure_name].tight_layout()
        colorbar_axis = make_axes_locatable(self.figures[figure_name].gca()).append_axes("right", size=0.3, pad=0.05)
        colorbar_axis.yaxis.set_tick_params(colors=self.color_palette.text_color)

        if self.color_map is not None:
            imshowargs['cmap'] = self.color_map
        axes_image = axis.imshow(pixel_data, **imshowargs)
        self.figures[figure_name].colorbar(axes_image, cax=colorbar_axis)

    def get_figure(self, figure_name):
        return self.figures[figure_name]

    def get_encoded_figure(self, figure_name):
        image_bytes = io.BytesIO()
        self.figures[figure_name].savefig(image_bytes, format="png")
        return self.encode_image(image_bytes)


@dataclass
class ModelConfiguration:

    stage: int
    paths2HP: Paths2HP = None
    settings: SettingsTraining = None
    groundtruth_info: gt.GroundTruthInfo = None
    info: dict = None
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
        self.set_paths_and_settings(self.stage)
        if self.stage == 1:
            with open(os.path.join(os.getcwd(), self.settings.model, "info.yaml"), "r") as file:
                self.info = yaml.safe_load(file)
            self.groundtruth_info = gt.GroundTruthInfo(self.paths2HP.raw_path, 10.6)
        elif self.stage == 2:
            with open(self.paths2HP.dataset_1st_prep_path / "info.yaml", "r") as f:
                self.info = yaml.safe_load(f)
        else:
            raise f"stage {self.stage} does not exist"

        self.color_palette = ColorPalette()


    def set_paths_and_settings(self, stage):
        path_to_project_dir = pathlib.Path((os.path.dirname(os.path.abspath(__file__)))) / ".." / ".."
        paths_file = path_to_project_dir / "1HP_NN" / "paths.yaml"

        if os.path.exists(paths_file):
            with open(paths_file, "r") as f:
                paths_file = yaml.safe_load(f)
            try:
                default_raw_1hp_dir = pathlib.Path(paths_file["default_raw_dir"])
                prepared_domain_dir = pathlib.Path(paths_file["datasets_prepared_domain_dir"])
                models_1hp_dir      = pathlib.Path(paths_file["models_1hp_dir"])
                models_2hp_dir      = pathlib.Path(paths_file["models_2hp_dir"])
            except:
                print(f'Error loading "{paths_file}"')
        else:
            print(f'1HP_NN/info.yaml not found, trying default path')
            default_raw_1hp_dir = path_to_project_dir / "datasets_raw"
            prepared_domain_dir = path_to_project_dir / "datasets_prepared_domain"
            models_1hp_dir      = path_to_project_dir / "models_1hpnn"
            models_2hp_dir      = path_to_project_dir / "models_2hpnn"


        model_2hp_dir = models_2hp_dir / "1000dp_1000gksi_separate" / "current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1"
        model_1hp_dir = models_1hp_dir / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"

        dataset_2hpnn_names = ["dataset_2hps_demonstrator_1dp"]
        dataset_1hpnn_names = ["dataset_2d_small_1000dp", "datasets_raw_1000_1HP"]
        dataset_domain_prepared_name = ""
        raw_dataset_1hpnn_name = ""

        for name in dataset_1hpnn_names:
            if os.path.exists(default_raw_1hp_dir / name):
                raw_dataset_1hpnn_name = name

        for name in dataset_2hpnn_names:
            if os.path.exists(prepared_domain_dir / (name + " inputs_gksi")):
                dataset_domain_prepared_name = name + " inputs_gksi"

        if stage == 1 and raw_dataset_1hpnn_name == "":
            raise FileNotFoundError(f'1HP raw dataset not found at "{default_raw_1hp_dir}"')
        
        if not os.path.exists(model_1hp_dir):
            raise FileNotFoundError(f'1HP model not found at "{model_1hp_dir}"')
        
        if stage == 2:
            if dataset_domain_prepared_name == "":
                raise FileNotFoundError(f'2HP prepared domain dataset not found at "{prepared_domain_dir}"')
            if not os.path.exists(model_2hp_dir):
                raise FileNotFoundError(f'2HP model not found at "{model_2hp_dir}"') 

        self.paths2HP = Paths2HP(
            default_raw_1hp_dir / raw_dataset_1hpnn_name,       # 1HP: wegen Grundwahrheit
            "",
            prepared_domain_dir / dataset_domain_prepared_name, # 2HP: wegen info.yaml
            model_1hp_dir,
            ""
        )

        self.settings = SettingsTraining(
            dataset_raw = raw_dataset_1hpnn_name,
            inputs = "gksi1000",
            device = "cpu",
            epochs = 1,
            case = "test",
            model = model_1hp_dir if stage == 1 else model_2hp_dir,
            visualize = True,
            dataset_prep = self.paths2HP.datasets_boxes_prep_path
        )


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

    model = UNet(in_channels=len("gksi")).float()
    model.load_state_dict(torch.load(f"{config.settings.model}/model.pt", map_location=torch.device(config.settings.device)))
    model.to(config.settings.device)
    model.eval()

    (x, y, info, norm) = prep_1hp.prepare_demonstrator_input(config.paths2HP, config.groundtruth_info, permeability, pressure, info=config.info)
    return visualize.get_plots(model, x, y, info, norm, config.color_palette)


def get_2hp_model_results(config: ModelConfiguration, permeability: float, pressure: float, pos_2nd_hp):

    corner_dist = config.info["PositionHPPrior"]
    positions = [[corner_dist[1] + 50, corner_dist[0] + 50], [corner_dist[1] + pos_2nd_hp[0], corner_dist[0] + pos_2nd_hp[1]]]

    model_1HP = UNet(in_channels=len("gksi")).float()
    model_1HP.load(config.paths2HP.model_1hp_path, config.settings.device)

    model_2HP = UNet(in_channels=2).float() # TODO: Achtung: Fest gekodet
    model_2HP.load(config.settings.model, config.settings.device)
    model_2HP.to(config.settings.device)

    hp_inputs, corners_ll = prep_2hp.prepare_demonstrator_input_2hp(config.info, model_1HP, pressure, permeability, positions, device=config.settings.device)
    return visualize.get_2hp_plots(model_2HP, config.info, hp_inputs, corners_ll, corner_dist, config.color_palette, device=config.settings.device)
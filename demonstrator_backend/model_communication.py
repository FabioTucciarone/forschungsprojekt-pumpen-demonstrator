import os
import io
import numpy as np
from pathlib import Path
import sys
import torch
from matplotlib.figure import Figure
import yaml
import generate_groundtruth as gt
from dataclasses import dataclass
import base64
from matplotlib.colors import LinearSegmentedColormap

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import utils.visualization as visualize
from networks.unet import UNet
import preprocessing.prepare_1ststage as prep_1hp
import preprocessing.prepare_2ndstage as prep_2hp
from utils.prepare_paths import Paths2HP
from mpl_toolkits.axes_grid1 import make_axes_locatable


@dataclass
class ColorPalette:
    """
    Used to set the RGB values (range: [0,1]) of the output images:
    cmap_list: list of RGB value tuples used for interpolating the color gradient
    """
    cmap_list: list = None
    background_color: tuple = (1,1,1)
    text_color: tuple = (0,0,0)



class ReturnData:
    """
    dict wrapper to easily add or change return parameters and generate encoded matplotlib figures.
    """

    return_values: dict
    figures: dict
    color_palette: ColorPalette
    color_map: LinearSegmentedColormap = None
    average_error = None


    def __init__(self, color_palette: ColorPalette):
        self.figures = dict()
        self.return_values = dict()
        self.colorbar_axis = dict()
        self.color_palette = color_palette
        if self.color_palette.cmap_list is not None:
            self.color_map = LinearSegmentedColormap.from_list("demonstrator", color_palette.cmap_list, N=100)


    def encode_image(self, buffer: io.BytesIO):
        return str(base64.b64encode(buffer.getbuffer()).decode("ascii"))


    def set_figure(self, figure_name: str, pixel_data: type[np.ndarray | torch.Tensor], **imshowargs):
        self.figures[figure_name] = Figure(dpi=200)
        axis = self.figures[figure_name].add_subplot(1, 1, 1)
        axis.invert_yaxis()
        axis.tick_params(labelsize=6)
        axis.tick_params(colors=self.color_palette.text_color)
        self.figures[figure_name].patch.set_facecolor(self.color_palette.background_color)
        self.figures[figure_name].tight_layout()
        colorbar_axis = make_axes_locatable(self.figures[figure_name].gca()).append_axes("right", size=0.3, pad=0.05)
        colorbar_axis.yaxis.set_tick_params(colors=self.color_palette.text_color, labelsize=6)

        if self.color_map is not None:
            imshowargs['cmap'] = self.color_map
        axes_image = axis.imshow(pixel_data, **imshowargs)
        self.figures[figure_name].colorbar(axes_image, cax=colorbar_axis)


    def get_figure(self, figure_name: str):
        return self.figures[figure_name]


    def get_encoded_figure(self, figure_name: str):
        image_bytes = io.BytesIO()
        self.figures[figure_name].savefig(image_bytes, format="png", bbox_inches='tight')
        return self.encode_image(image_bytes)
    

    def set_return_value(self, key, value):
        self.return_values[key] = value
    

    def get_return_value(self, key):
        return self.return_values[key]



@dataclass
class ModelConfiguration:
    """
    Dataclass used to store all model and groundtruth settings.
    """

    device: str = "cpu"
    inputs: str = "gksi1000"
    paths2HP: Paths2HP = None
    dataset_info: gt.DatasetInfo = None
    model_1hp_info: dict = None
    model_2hp_info: dict = None
    color_palette: ColorPalette = None


    def __post_init__(self):
        """ 
        Initialize paths and model settings.
        Model is searched according to the paths.yaml file.
        If no such file exists default folder structure is assumed (see README.md).
        """

        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"> Initialing with device = '{self.device}'")

        model_1hp_dir, model_2hp_dir = self.set_paths_and_settings()

        self.model_1hp = UNet(in_channels=len("gksi")).float()
        self.model_1hp.load(model_1hp_dir, self.device)

        self.model_2hp = UNet(in_channels=2).float() # TODO: Achtung: Fest gekodet
        self.model_2hp.load(model_2hp_dir, self.device)

        self.dataset_info = gt.DatasetInfo(self.paths2HP.raw_path, 10.6)

        size_hp_box = self.model_2hp_info["CellsNumberPrior"]
        domain_shape = self.model_2hp_info["CellsNumber"]

        # TODO: Achtung: Fest für ein Modell/Datensatz gekodet:
        border_distance_x = 115
        border_distance_y_upper = 20
        border_distance_y_lower = 233
        
        max_height = min(domain_shape[1] - 2 * border_distance_x, 2 * size_hp_box[1] - 2)
        max_width = min(domain_shape[0] - border_distance_y_upper - border_distance_y_lower, domain_shape[0] - size_hp_box[0] - 1)

        self.model_2hp_info["OutFieldShape"] = [min(domain_shape[0] - size_hp_box[0] - 1, max_width), min(2 * size_hp_box[1] - 2, max_height)]
        self.model_2hp_info["OutFieldOffset"] = [border_distance_x, border_distance_y_upper]

        self.color_palette = ColorPalette()


    def set_paths_and_settings(self):
        """
        Configures all paths of the project.
        - Read paths from paths.yaml if available.
        - Load default paths if no paths.yaml file was found.
        Checks if necessary files are available and throws errors accordingly.

        Returns
        ----------
        (model_1hp_dir, model_2hp_dir): tuple[Path, Path]
            path to the one-heatpump and two-heatpump models (where the info.yaml files are located)
        """

        path_to_project_dir = Path((os.path.dirname(os.path.abspath(__file__)))) / ".."
        paths_file = path_to_project_dir / "paths.yaml"

        if os.path.exists(paths_file):
            with open(paths_file, "r") as f:
                paths_file = yaml.safe_load(f)
            try:
                default_raw_1hp_dir = Path(paths_file["default_raw_dir"])
                model_1hp_dir       = Path(paths_file["models_1hp_dir"])
                model_2hp_dir       = Path(paths_file["models_2hp_dir"])
            except:
                print(f'Error loading "{paths_file}"')
        else:
            print(f'WARNING: forschungsprojekt-pumpen-demonstrator/paths.yaml not found, trying default path')
            default_raw_1hp_dir = path_to_project_dir / ".." / "data" / "datasets_raw"
            model_1hp_dir       = path_to_project_dir / ".." / "data" / "models_1hpnn" / "gksi1000" / "current_unet_dataset_2d_small_1000dp_gksi_v7"
            model_2hp_dir       = path_to_project_dir / ".." / "data" / "models_2hpnn" / "1000dp_1000gksi_separate" / "current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1"

            dataset_1hpnn_names = ["dataset_2d_small_1000dp", "datasets_raw_1000_1HP"]
            found = False
            for name in dataset_1hpnn_names:
                if os.path.exists(default_raw_1hp_dir / name):
                    default_raw_1hp_dir = default_raw_1hp_dir / name
                    found = True
            if not found:
                raise FileNotFoundError(f'Couldn\'t find raw dataset folders at default path: "{default_raw_1hp_dir}"')
        
        if not (os.path.exists(model_1hp_dir / "info.yaml") and os.path.exists(model_1hp_dir / "model.pt")):
            raise FileNotFoundError(f'1HP model not found at "{model_1hp_dir}"')    
        if not (os.path.exists(model_2hp_dir / "info.yaml") and os.path.exists(model_2hp_dir / "model.pt")):
            raise FileNotFoundError(f'2HP model not found at "{model_2hp_dir}"') 
        
        with open(os.path.join(os.getcwd(), model_2hp_dir, "info.yaml"), "r") as file:
            self.model_2hp_info = yaml.safe_load(file)
        with open(os.path.join(os.getcwd(), model_1hp_dir, "info.yaml"), "r") as file:
            self.model_1hp_info = yaml.safe_load(file)

        if not os.path.exists(default_raw_1hp_dir / "RUN_0" / "pflotran.h5"):
            raise FileNotFoundError(f'1HP raw dataset not found at "{default_raw_1hp_dir}"') 
        if not os.path.exists(default_raw_1hp_dir / "inputs" / "settings.yaml"):
            raise FileNotFoundError(f'1HP raw dataset has no "{Path("inputs", "settings.yaml")}"') 

        self.paths2HP = Paths2HP(default_raw_1hp_dir, "", "", model_1hp_dir, "")

        return model_1hp_dir, model_2hp_dir


    def set_color_palette(self, color_palette: ColorPalette):
        self.color_palette = color_palette


    def get_value_ranges(self):
        """
        Get the value ranges supported by the used model in the following format:
        [ [min permeability, max permeability], [min pressure, max pressure] ]
        """

        k_info = self.model_1hp_info["Inputs"]["Permeability X [m^2]"]
        p_info = self.model_1hp_info["Inputs"]["Pressure Gradient [-]"]
        return [k_info["min"], k_info["max"]], [p_info["min"], p_info["max"]]


def get_1hp_model_results(config: ModelConfiguration, permeability: float, pressure: float):
    """
    Prepare a dataset and run the model.

    Parameters
    ----------
    permeability: float
        The permeability input parameter of the demonstrator app.
    pressure: float
        The pressure input parameter of the demonstrator app.

    Returns
    ---------- 
    return_data: ReturnData
        ReturnData object containing "model_result" (Figure), 
        "groundtruth" (Figure), "error_measure" (Figure), 
        "average_error" (float), "groundtruth_method" (str)
    """

    config.model_1hp.eval()

    (x, y, method, norm) = prep_1hp.prepare_demonstrator_input(config.paths2HP, config.dataset_info, permeability, pressure, config.model_1hp_info, config.device)
    return_data = visualize.get_plots(config.model_1hp, x, y, config.model_1hp_info, norm, config.color_palette)
    return_data.set_return_value("groundtruth_method", method)
    return return_data


def get_2hp_model_results(config: ModelConfiguration, permeability: float, pressure: float, pos_2nd_hp):
    """
    Prepare a dataset and run the model of the second stage.

    Parameters
    ----------
    permeability: float
        The permeability input parameter of the demonstrator app.
    pressure: float
        The pressure input parameter of the demonstrator app.
    pos_2nd_hp: list[int]
        Position describing the pixel position of the heat pump in the range of ModelConfiguration::model_2hp_info["OutFieldShape"]

    Returns
    ---------- 
    return_data: ReturnData
        ReturnData object containing "model_result" (Figure)
    """
    corner_dist = [0, 0]
    corner_dist[0] = max(config.model_1hp_info["PositionLastHP"][0], config.model_2hp_info["OutFieldOffset"][0])
    corner_dist[1] = max(config.model_1hp_info["PositionLastHP"][1], config.model_2hp_info["OutFieldOffset"][1])
    field_shape_2hp = config.model_2hp_info["OutFieldShape"]
    pos_fix = [corner_dist[1] + min(field_shape_2hp[0], 50), corner_dist[0] + int(field_shape_2hp[1] / 2)]
    pos_var = [corner_dist[1] + pos_2nd_hp[0], corner_dist[0] + pos_2nd_hp[1]]

    positions = [pos_fix, pos_var]

    config.model_2hp.to(config.device)

    hp_inputs, corners_ll = prep_2hp.prepare_demonstrator_input_2hp(config.model_1hp_info, config.model_2hp_info, config.model_1hp, pressure, permeability, positions, config.device)
    return visualize.get_2hp_plots(config.model_2hp, config.model_2hp_info, hp_inputs, corners_ll, corner_dist, config.color_palette, config.device)

from dataclasses import dataclass
import numpy as np
import os
import yaml
import h5py
import torch

@dataclass
class DataPoint:
    k: np.float64 # permeability
    p: np.float64 # pressure


@dataclass
class HPBounds:
    x0: int = -1
    x1: int = 20
    y0: int = -1
    y1: int = 256


@dataclass
class GroundTruthInfo:
    dataset_path: str
    base_temp: float
    datapoints: list = None
    threshold_temp: float = 0
    visualize: bool = False
    dims: list = None
    hp_pos = [9, 23]

    def __post_init__(self):
        self.datapoints = load_data_points(self.dataset_path)
        self.threshold_temp = self.base_temp + 0.5 # TODO: Achtung: fest gekodet!
        pflotran_settings = get_pflotran_settings(self.dataset_path)
        self.dims = pflotran_settings["grid"]["ncells"]


# TODO: Achtung: skaliertes laden!
def load_data_points(path_to_dataset):
    permeability_values_path = os.path.join(path_to_dataset, "inputs", "permeability_values.txt")
    pressure_values_path = os.path.join(path_to_dataset, "inputs", "pressure_values.txt")

    permeability_values = []
    with open(permeability_values_path) as file:
        permeability_values = [float(line.rstrip()) for line in file]

    pressure_values = []
    with open(pressure_values_path) as file:
        pressure_values = [float(line.rstrip()) for line in file]

    datapoints = [DataPoint(k * 1e10, p * 1e3) for k, p in zip(permeability_values, pressure_values)]
    return datapoints


def load_temperature_field(info: GroundTruthInfo, run_index: int):
    temperature_field = load_temperature_field_raw(info, run_index)["Temperature [C]"].detach().cpu().squeeze().numpy()
    return temperature_field


# TODO: Kopiert von Julia (Imports in Python machen mich wahnsinnig)

def get_pflotran_settings(dataset_path_raw: str):
    with open(os.path.join(dataset_path_raw, "inputs", "settings.yaml"), "r") as f:
        pflotran_settings = yaml.safe_load(f)
    return pflotran_settings


def load_temperature_field_raw(info: GroundTruthInfo, run_index: int):
    path = os.path.join(info.dataset_path, f"RUN_{run_index}", "pflotran.h5")
    data = dict()
    with h5py.File(path, "r") as file:
        data["Temperature [C]"] = torch.tensor(np.array(file["   4 Time  2.75000E+01 y"]["Temperature [C]"]).reshape(info.dims, order='F')).float()
    return data
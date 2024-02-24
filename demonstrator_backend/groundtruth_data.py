from dataclasses import dataclass
import numpy as np
import os
import yaml
import h5py
import torch
from pathlib import Path 
from typing import Dict, List, Tuple, Any, Union

@dataclass
class DataPoint:
    """
    Represents a data point in parameter space.
    """
    k: float # permeability
    p: float # pressure


@dataclass
class HPBounds:
    """
    Stores the approximate extents of a heat plume in each direction around the pump location.
    """
    x0: int = -1
    x1: int = 20
    y0: int = -1
    y1: int = 256


@dataclass
class DatasetInfo:
    """
    Dataclass to store information about a dataset and the generation of the ground truth.
    Stores all simulated input parameters, the heat pump location, and a threshold temperature (0.5 + base temperature).
    """

    dataset_path: Path
    base_temp: float
    datapoints: list = None
    threshold_temp: float = None
    dims: List[int] = None
    hp_pos: List[int] = None

    def __post_init__(self):
        self.datapoints = load_data_points(self.dataset_path)
        self.threshold_temp = self.base_temp + 0.5 # TODO: Achtung: fest gekodet!
        pflotran_settings = get_pflotran_settings(self.dataset_path)
        self.dims = pflotran_settings["grid"]["ncells"]

        settings_path = Path(self.dataset_path) / "inputs" / "settings.yaml"
        if os.path.exists(settings_path):
            with open(settings_path, "r") as f:
                settings = yaml.safe_load(f)
                self.hp_pos = settings["grid"]["loc_hp"]
                self.hp_pos[0] = int(self.hp_pos[0] / 5) 
                self.hp_pos[1] = int(self.hp_pos[1] / 5)  
        else:
            print("WARNING: no settings.yaml found in dataset")


# TODO: Achtung: skaliertes laden!
def load_data_points(path_to_dataset: Path):
    permeability_values_path = path_to_dataset / "inputs" / "permeability_values.txt"
    pressure_values_path = path_to_dataset / "inputs" / "pressure_values.txt"

    permeability_values = []
    with open(permeability_values_path) as file:
        permeability_values = [float(line.rstrip()) for line in file]

    pressure_values = []
    with open(pressure_values_path) as file:
        pressure_values = [float(line.rstrip()) for line in file]

    datapoints = [DataPoint(k * 1e10, p * 1e3) for k, p in zip(permeability_values, pressure_values)]
    return datapoints


def load_temperature_field(info: DatasetInfo, run_index: int):
    temperature_field = load_temperature_field_raw(info, run_index)["Temperature [C]"].detach().cpu().squeeze().numpy()
    return temperature_field


# TODO: Kopiert von Julia (Imports in Python machen mich wahnsinnig)

def get_pflotran_settings(dataset_path_raw: Path):
    with open(dataset_path_raw / "inputs" / "settings.yaml", "r") as f:
        pflotran_settings = yaml.safe_load(f)
    return pflotran_settings


def load_temperature_field_raw(info: DatasetInfo, run_index: int):
    path = os.path.join(info.dataset_path, f"RUN_{run_index}", "pflotran.h5")
    data = dict()
    with h5py.File(path, "r") as file:
        data["Temperature [C]"] = torch.tensor(np.array(file["   4 Time  2.75000E+01 y"]["Temperature [C]"]).reshape(info.dims, order='F')).float()
    return data
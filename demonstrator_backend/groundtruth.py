import os
import pathlib
import time
import h5py
import numpy as np
import sys
import logging 
import matplotlib.pyplot as plt
import numpy
import torch

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))
import prepare_dataset
from networks.models import load_model


class DataSet:

    permeability_values = []
    pressure_values = []
    number_of_runs: int = 0
    dimensions: tuple = (0, 0)
    dataset_path: pathlib.Path

    def read_dataset(self, dataset_path_str: str):

        if not os.path.exists(dataset_path_str):
            raise ValueError(f"Dataset {dataset_path_str} does not exist")
        if len(os.listdir(dataset_path_str)) == 0:
            raise ValueError(f"Dataset {dataset_path_str} is empty")

        self.dataset_path = pathlib.Path(dataset_path_str)
        input_path = self.dataset_path.joinpath("inputs") # TODO: Fehler, wenn nicht existiert

        self.permeability_values = []
        with open(input_path.joinpath("permeability_values.txt")) as file:
            self.permeability_values = [float(line.rstrip()) for line in file]

        self.pressure_values = []
        with open(input_path.joinpath("pressure_values.txt")) as file:
            self.pressure_values = [float(line.rstrip()) for line in file]

        self.number_of_runs = len(self.permeability_values) # fehler wenn ungleich?

        pflotran_settings = prepare_dataset.get_pflotran_settings(self.dataset_path)
        self.dimensions = np.array(pflotran_settings["grid"]["ncells"])


    # Ermittle Index des nächsten Datenpunkts: RUN_n
    def get_closest(self, permeability: float, pressure: float):
        """
        Erster Test, um die Grundwahrheit zu ermitteln: Suche den nächsten Datenpunkt.
        closest_run: Index des Datenpunkts mit der geringsten Distanz
        """
        closest_run = 0 
        min_distance = np.sqrt((self.permeability_values[0] - permeability)**2 + (self.pressure_values[0] - pressure)**2)

        for i in range(1, self.number_of_runs):
            p, d = self.permeability_values[i], self.pressure_values[i]
            distance = np.sqrt((p - permeability)**2 + (d - pressure)**2)
            if distance < min_distance:
                min_distance = distance
                closest_run = i
        
        return closest_run


    # Test: Temperaturfeld des Trainingsdatensatzes anzeigen
    def load_run(self, n: int):
        data = prepare_dataset.load_data(self.dataset_path.joinpath(f"RUN_{n}").joinpath("pflotran.h5"), "   4 Time  2.75000E+01 y", {"Temperature [C]" : "?"}, self.dimensions)
        plt.imshow(data["Temperature [C]"],interpolation="none", cmap="RdBu_r")
        plt.colorbar()
        plt.show()

inputs_prep = "pksi" #??
model_1HP = load_model({"model_choice": "unet", "in_channels": len(inputs_prep)}, "/mnt/d/Entwicklung/02 Studium/Forschungsprojekt/simulation_files/pksi1000/current_unet_dataset_2d_small_1000dp_pksi_v1", "model", "cpu")

logging.basicConfig(level=logging.INFO)
d = DataSet()
d.read_dataset("/mnt/d/Entwicklung/02 Studium/Forschungsprojekt/simulation_files/datasets/datasets_raw_1000_1HP")
#d.read_dataset("D:\\Entwicklung\\02 Studium\\Forschungsprojekt\\simulation_files\\datasets\\datasets_raw_1000_1HP") # Testpfad
#d.get_closest(10**(-9),-0.003)
#d.load_run(d.get_closest(10**(-9),-0.003))










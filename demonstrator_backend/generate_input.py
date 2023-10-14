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

# Achtung, bisher alles noch Tests, die höchstwahrscheinlich nur bei mir lokal funktionieren
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

from main import run_from_demonstrator 

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


# ignoriere mal alles oben!

# Achtung paths.yaml muss jetzt in diesem Ordner sein
def test():
    "Aufrufen des manuell erstellten ein-Datenpunkt-Datensatzes im .h5-Format"
    path_to_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data")
    path_to_1hp_models = os.path.join(path_to_data, "models_1hpnn")
    results = run_from_demonstrator("dataset_raw_demonstrator_input_1dp", os.path.join(path_to_1hp_models,"pksi1000","current_unet_dataset_2d_small_1000dp_pksi_v1"), inputs="pksi")
    predicted_temperature = results[0]
    groundtruth_temperature = results[1]
    error_temperature = results[2]
    predicted_temperature.savefig("predicted_temperature.png", format="png")
    groundtruth_temperature.savefig("groundtruth_temperature.png", format="png")
    error_temperature.savefig("error_temperature.png", format="png")

test()









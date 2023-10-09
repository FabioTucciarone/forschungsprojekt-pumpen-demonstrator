import os
import pathlib
import time
import h5py
import numpy as np
import sys
import logging 
import matplotlib.pyplot as plot
import numpy

sys.path.insert(0, '../../simulation_files/1HP_NN')
import prepare_dataset


class DataSet:

    permeability_values = []
    pressure_values = []
    number_of_runs = 0

    def read_dataset(self, raw_dataset_path: str):

        if not os.path.exists(raw_dataset_path):
            raise ValueError(f"Dataset {raw_dataset_path} does not exist")
        if len(os.listdir(raw_dataset_path)) == 0:
            raise ValueError(f"Dataset {raw_dataset_path} is empty")

        logging.info(f"Directory of currently used dataset is: {raw_dataset_path}")

        raw_dataset_path = pathlib.Path(raw_dataset_path)
        input_path = raw_dataset_path.joinpath("inputs") # TODO: Fehler, wenn nicht existiert

        self.permeability_values = []
        with open(input_path.joinpath("permeability_values.txt")) as file:
            self.permeability_values = [float(line.rstrip()) for line in file]

        self.pressure_values = []
        with open(input_path.joinpath("pressure_values.txt")) as file:
            self.pressure_values = [float(line.rstrip()) for line in file]

        number_of_runs = len(self.permeability_values) # fehler wenn ungleich?


    def get_closest(self, permeability: float, density:float):
        """
        Erster Test, um die Grundwahrheit zu ermitteln: Suche den nächsten Datenpunkt.
        closest_run: Index des Datenpunkts mit der geringsten Distanz
        """
        closest_run = 0 
        min_distance = np.sqrt((self.permeability_values[0] - permeability)**2 + (self.pressure_values[0] - density)**2)

        for i in range(1, self.number_of_runs):
            p, d = self.permeability_values[i], self.pressure_values[i]
            distance = np.sqrt((p - permeability)**2 + (d - density)**2)
            if distance < min_distance:
                min_distance = distance
                closest_run = i
        
        return closest_run



logging.basicConfig(level=logging.INFO)
d = DataSet()
d.read_dataset("/mnt/d/Entwicklung/02 Studium/Forschungsprojekt/simulation_files/datasets/datasets_raw_1000_1HP") # Testpfad









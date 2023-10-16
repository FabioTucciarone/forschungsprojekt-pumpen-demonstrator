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
from main import init_data 

# Achtung paths.yaml muss jetzt in diesem Ordner sein
def test():
    "Aufrufen des manuell erstellten ein-Datenpunkt-Datensatzes im .h5-Format"
    path_to_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data")
    path_to_1hp_model = os.path.join(path_to_data, "models_1hpnn","pksi1000","current_unet_dataset_2d_small_1000dp_pksi_v1")
    results = run_from_demonstrator("dataset_raw_demonstrator_input_1dp", path_to_1hp_model, inputs="pksi")
    predicted_temperature = results[0]
    groundtruth_temperature = results[1]
    error_temperature = results[2]

test()









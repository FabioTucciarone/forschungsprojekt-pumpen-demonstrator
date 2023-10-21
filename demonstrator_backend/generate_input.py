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
import main as h1_nn

# Achtung paths.yaml muss jetzt in diesem Ordner sein
def test():
    "Aufrufen des manuell erstellten ein-Datenpunkt-Datensatzes im .h5-Format"
    path_to_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data")
    path_to_1hp_model = os.path.join(path_to_data, "models_1hpnn","gksi1000","current_unet_dataset_2d_small_1000dp_gksi_v7")

    results = h1_nn.demonstrator_run_1st_stage("dataset_raw_demonstrator_input_1dp", path_to_1hp_model, -1.0e-10, 2.0e-3)

    predicted_temperature = results[0]
    groundtruth_temperature = results[1]
    error_temperature = results[2]

    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = predicted_temperature
    predicted_temperature.set_canvas(canvas_manager.canvas)
    plt.show()

    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = groundtruth_temperature
    predicted_temperature.set_canvas(canvas_manager.canvas)
    plt.show()

    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = error_temperature
    predicted_temperature.set_canvas(canvas_manager.canvas)
    plt.show()
test()









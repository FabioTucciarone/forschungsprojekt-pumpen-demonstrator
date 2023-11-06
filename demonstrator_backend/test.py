import os
import sys
import time
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from dataclasses import dataclass
from model_communication import ModelCommunication

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

import main as hp1_nn
import preprocessing.prepare_1ststage as prepare
from utils.prepare_paths import Paths1HP
from data_stuff.utils import SettingsTraining


def show_figure(figure: Figure):
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = figure
    results[0].set_canvas(canvas_manager.canvas)
    plt.show()



model_communication = ModelCommunication()

st = time.time()
results = model_communication.get_1hp_model_results(2.646978938535798940e-10, -2.830821194764205056e-03, 0)
et = time.time()
print('Gesamtzeit:', et - st, 'seconds')

show_figure(results[0])

results = model_communication.get_1hp_model_results(1e-10, -0.5e-03, 1)

show_figure(results[0])
show_figure(results[1])
show_figure(results[2])
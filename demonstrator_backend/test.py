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
    figure.set_canvas(canvas_manager.canvas)
    plt.show()


st1 = time.time()
model_communication = ModelCommunication()
et1 = time.time()
print('Initialisierung:', et1 - st1, 'seconds')

st2 = time.time()
model_communication.update_1hp_model_results(2.646978938535798940e-10, -2.830821194764205056e-03)
et2 = time.time()
print('Antwortzeit:', et2 - st2, 'seconds')
print('Gesamtzeit:', et2 - st2 + et1 - st1, 'seconds')

show_figure(model_communication.figures.get_figure(0))
show_figure(model_communication.figures.get_figure(1))
show_figure(model_communication.figures.get_figure(2))

model_communication.update_1hp_model_results(1e-10, -0.5e-03)

show_figure(model_communication.figures.get_figure(0))

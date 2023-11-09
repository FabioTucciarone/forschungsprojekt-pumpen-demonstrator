import os
import sys
import time
import matplotlib.pyplot as plt
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from dataclasses import dataclass
import model_communication as mc
import generate_groundtruth as gt

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
model_communication = mc.ModelCommunication()
et1 = time.time()
print('Initialisierung:', et1 - st1, 'seconds')

k = 3.1e-10
p = -2.1e-03

x = gt.DataPoint(p, k)
path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")

groundtruth = gt.GroundTruth(path_to_dataset)
groundtruth.start(p, k)

st2 = time.time()
model_communication.update_1hp_model_results(k, p)
et2 = time.time()
print('Antwortzeit:', et2 - st2, 'seconds')
print('Gesamtzeit:', et2 - st2 + et1 - st1, 'seconds')


show_figure(model_communication.figures.get_figure(0))


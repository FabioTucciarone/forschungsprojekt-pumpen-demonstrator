import os
import sys
import numpy as np
import scipy as sp
import torch
import matplotlib.pyplot as plt
from matplotlib.path import Path
from torch.utils.tensorboard import SummaryWriter
# tensorboard --logdir=runs/ --host localhost --port 8088

# Sollte mit Pfadspezifikation aus Notion funktionieren
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

from data_stuff.dataset import SimulationDataset, _get_splits
from data_stuff.utils import SettingsTraining
from networks.unet import UNet
from preprocessing.prepare_1ststage import load_data, get_pflotran_settings
from utils.prepare_paths import set_paths_1hpnn, Paths1HP
from utils.visualization import plt_avg_error_cellwise, plot_sample
from utils.measurements import measure_loss, save_all_measurements
from main import run_from_demonstrator 
from main import init_data 
from scipy.ndimage import zoom


def generate_groundtruth_closest(self, permeability: float, pressure: float):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    permeability_values, pressure_values = read_input_lists(path_to_dataset)
    closest_dp = index_of_closest_datapoints(permeability_values, pressure_values, permeability, pressure)

    dp_path = os.path.join(path_to_dataset, f"RUN_{closest_dp}", "pflotran.h5")
    y1 = load_data(dp_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], (20, 256, 1)) # TODO: Dimensionen aus Pflortran-Einstellungen holen
    y1 = y1["Temperature [C]"].detach().cpu().squeeze()
    
    return y1 #TODO: bestes Format?


def index_of_closest_datapoints(permeability_values, pressure_values, permeability, pressure):
    closest_dp = 0 
    min_distance = np.sqrt((permeability_values[0] - permeability)**2 + (pressure_values[0] - pressure)**2)

    for i in range(1, len(permeability_values)):
        p, d = permeability_values[i], pressure_values[i]
        distance = np.sqrt((p - permeability)**2 + (d - pressure)**2)
        if distance < min_distance:
            min_distance = distance
            closest_dp = i
    
    return closest_dp


def read_input_lists(path_to_dataset):
    permeability_values_path = os.path.join(path_to_dataset, "inputs", "permeability_values.txt")
    pressure_values_path = os.path.join(path_to_dataset, "inputs", "pressure_values.txt")

    permeability_values = []
    with open(permeability_values_path) as file:
        permeability_values = [float(line.rstrip()) for line in file]

    pressure_values = []
    with open(pressure_values_path) as file:
        pressure_values = [float(line.rstrip()) for line in file]

    return permeability_values, pressure_values


# ACHTUNG: Hier funktioniert gar nichts!!
# alles nur grobe Tests

def show_contours_of(run_index1):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    pflotran_settings = get_pflotran_settings(path_to_dataset)

    dp1_path = os.path.join(path_to_dataset, f"RUN_{run_index1}", "pflotran.h5")

    dims = np.array(pflotran_settings["grid"]["ncells"])
    print(f"dimensions = {dims}")

    fig, axes = plt.subplots(1, 1, sharex=True)

    y1 = load_data(dp1_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
    y1 = y1["Temperature [C]"].detach().cpu().squeeze()

    c2 = plt.contour(y1)
    segments = c2.allsegs[0]

    plt.show()

    return

    contour = np.ndarray((1,2))
    if len(segments) > 0:
        contour[0] = segments[-1][0]

    for seg in segments:
        contour = np.concatenate((seg, contour))

    for i, seg in enumerate(segments):
        plt.plot(seg[:,0], seg[:,1], '-', marker='.', label=i)
    plt.plot(contour[:,0], contour[:,1], '-', marker='.', color='r', label=0)

    plt.legend(fontsize=9, loc='best')

    # c2.allsegs[Level][Segment der Linie falls unterbrochen][Punkt auf der Linie]
    # find_nearest_contour(x, y, indices=None, pixel=True) ???

    # Konturenproblem: Große Fahnen haben teilweise nicht mehr rettbare Konturen, kleine Fahnen teilweise keine


def show_isoline_graphs(run_index1, run_index2, run_index3):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    pflotran_settings = get_pflotran_settings(path_to_dataset)

    dp1_path = os.path.join(path_to_dataset, f"RUN_{run_index1}", "pflotran.h5")
    dp2_path = os.path.join(path_to_dataset, f"RUN_{run_index2}", "pflotran.h5")
    dp3_path = os.path.join(path_to_dataset, f"RUN_{run_index3}", "pflotran.h5")

    dims = np.array(pflotran_settings["grid"]["ncells"])
    print(f"dimensions = {dims}")

    fig, axes = plt.subplots(7, 1, sharex=True)

    y1 = load_data(dp1_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
    y1 = y1["Temperature [C]"].detach().cpu().squeeze()
    
    # position y1[9][23] = 20 # berechne aus settings.yaml
    plt.sca(axes[0])
    plt.imshow(y1, cmap="RdBu_r")

    y2 = load_data(dp2_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
    plt.sca(axes[1])
    y2 = y2["Temperature [C]"].detach().cpu().squeeze()
    plt.imshow(y2, cmap="RdBu_r")  

    y3 = load_data(dp3_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
    y3 = y3["Temperature [C]"].detach().cpu().squeeze()
    plt.sca(axes[2])
    plt.imshow(y3, cmap="RdBu_r")

    print(f"min = {torch.min(y2)}, max = {torch.max(y2)}")

    threshhold = 11.6

    # y >, x ^
    # Für alle drei Fahnen finde Länge und Breite 

    if run_index1 != 0 or run_index2 != 3 or run_index3 != 4:
        plt.show()
        return
    
    # Für drei feste Testfahnen interpolieren:

    position = [9, 23]
    base_temperature = torch.min(y2) # hole auch aus irgendwelchen yamls
    print(base_temperature)

    ybounds = [[], [], []]
    xbounds = [[], [], []]

    ybounds[0] = [22, 255]
    xbounds[0] = [6, 11]

    ybounds[1] = [20, 148]
    xbounds[1] = [1, 18]

    ybounds[2] = [0, 78]
    xbounds[2] = [0, 19]
    
    r1 = np.ndarray((dims[0],dims[1]))
    r2 = np.ndarray((dims[0],dims[1]))
    r3 = np.ndarray((dims[0],dims[1]))
    result = np.ndarray((dims[0],dims[1]))

    weight1 = 1/3
    weight2 = 1/3
    weight3 = 1/3

    ybounds_res = [weight1*ybounds[0][0] + weight2*ybounds[1][0] + weight3*ybounds[2][0], weight1*ybounds[0][1] + weight2*ybounds[1][1] + weight3*ybounds[2][1]]
    xbounds_res = [weight1*xbounds[0][0] + weight2*xbounds[1][0] + weight3*xbounds[2][0], weight1*xbounds[0][1] + weight2*xbounds[1][1] + weight3*xbounds[2][1]]

    for j in range(0, 256):
        for i in range(0, 20):
            r1[i][j] = get_result(base_temperature, y1, i, j, xbounds[0], ybounds[0], xbounds_res, ybounds_res)
            r2[i][j] = get_result(base_temperature, y2, i, j, xbounds[1], ybounds[1], xbounds_res, ybounds_res)
            r3[i][j] = get_result(base_temperature, y3, i, j, xbounds[2], ybounds[2], xbounds_res, ybounds_res)

    plt.sca(axes[3])
    sigma = [0.5, 0.5]
    r1 = sp.ndimage.filters.gaussian_filter(r1, sigma, mode='constant', cval=base_temperature)
    plt.imshow(r1, cmap="RdBu_r")

    plt.sca(axes[4])
    sigma = [0.5, 0.5]
    r2 = sp.ndimage.filters.gaussian_filter(r2, sigma, mode='constant', cval=base_temperature)
    plt.imshow(r2, cmap="RdBu_r")

    plt.sca(axes[5])
    sigma = [0.5, 0.5]
    r3 = sp.ndimage.filters.gaussian_filter(r3, sigma, mode='constant', cval=base_temperature)
    plt.imshow(r3, cmap="RdBu_r")

    for j in range(0, 256):
        for i in range(0, 20):
            result[i][j] = r1[i][j]*weight1 + r2[i][j]*weight2 + r3[i][j]*weight3

    plt.sca(axes[6])
    sigma = [1.5, 1.5]
    result = sp.ndimage.filters.gaussian_filter(result, sigma, mode='constant', cval=base_temperature)
    plt.imshow(result, cmap="RdBu_r")
    plt.show()


def get_result(base_temperature, y_pump, i, j, xbounds, ybounds, xbounds_res, ybounds_res):
    pos = [9, 23]
    it = pos[0]
    jt = pos[1]
    if i < pos[0]:
        it = pos[0] + (pos[0] - xbounds[0]) / (pos[0] - xbounds_res[0]) * (i - pos[0])
    elif i > pos[0]:
        it = pos[0] + (pos[0] - xbounds[1]) / (pos[0] - xbounds_res[1]) * (i - pos[0])
    if j < pos[1]:
        jt = pos[1] + (pos[1] - ybounds[0]) / (pos[1] - ybounds_res[0]) * (j - pos[1])
    elif j > pos[1]:
        jt = pos[1] + (pos[1] - ybounds[1]) / (pos[1] - ybounds_res[1]) * (j - pos[1])

    if in_bounds(it, jt): # einfach Abschneiden liefert ganz schlechte Ergebnisse
        return y_pump[int(it)][int(jt)]
    else:
        return base_temperature

def in_bounds(i, j):
    i_in_bounds = i < 20 and i >= 0
    j_in_bounds = j < 256 and j >= 0
    return i_in_bounds and j_in_bounds

show_isoline_graphs(0, 3, 4)
import os
import sys
import numpy as np
import scipy as sp
import torch
import matplotlib.pyplot as plt
from matplotlib.path import Path
from torch.utils.tensorboard import SummaryWriter

from scipy.spatial import Delaunay

# tensorboard --logdir=runs/ --host localhost --port 8088

# Sollte mit Pfadspezifikation aus Notion funktionieren
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))
import preprocessing.prepare_1ststage as prepare


def generate_groundtruth_closest(permeability: float, pressure: float):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    permeability_values, pressure_values = read_input_lists(path_to_dataset)
    closest_dp = index_of_closest_datapoints(permeability_values, pressure_values, permeability, pressure)

    dp_path = os.path.join(path_to_dataset, f"RUN_{closest_dp}", "pflotran.h5")
    return prepare.load_data(dp_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], (20, 256, 1)) # TODO: Dimensionen aus Pflortran-Einstellungen holen


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

def distance(p1, p2):
    return np.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)


def triangulate_data_point(permeability: float, pressure: float, show_triangulation=False):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    permeability_values, pressure_values = read_input_lists(path_to_dataset)

    x = [permeability, pressure]

    simulated_points = np.c_[permeability_values, pressure_values]
    triangulation = Delaunay(simulated_points)
    simplex_index = triangulation.find_simplex(x)

    if simplex_index == -1:
        return generate_groundtruth_closest(permeability_values, pressure_values)

    point_indices = triangulation.simplices[simplex_index]

    p1 = simulated_points[point_indices[0]]
    p2 = simulated_points[point_indices[1]]
    p3 = simulated_points[point_indices[2]]

    w1 = distance(x, p2) * distance(x, p3) / (distance(p1, p2) * distance(p1, p3))
    w2 = distance(x, p1) * distance(x, p3) / (distance(p2, p1) * distance(p2, p3))
    w3 = distance(x, p1) * distance(x, p2) / (distance(p3, p1) * distance(p3, p2))
     
    interpolate_experimental(point_indices, (w1, w2, w3))

    if show_triangulation:
        plt.plot(simulated_points[:,0], simulated_points[:,1], '+')
        plt.plot(permeability, pressure, 'ro')
        for k in range(0, 3):
            plt.plot(simulated_points[point_indices[k]][0], simulated_points[point_indices[k]][1], 'ro')
        plt.show()


def interpolate_experimental(run_indices: tuple[int,int,int], weights: tuple[float, float, float], show_result: bool = True):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    pflotran_settings = prepare.get_pflotran_settings(path_to_dataset)

    # Load temperature fields
    dp_paths = [[], [], []]
    dp_paths[k] = os.path.join(path_to_dataset, f"RUN_{run_indices[k]}", "pflotran.h5")

    dims = np.array(pflotran_settings["grid"]["ncells"])

    temp_fields = [[], [], []]

    for k in range(0, 3):
        temp_fields[k] = prepare.load_data(dp_paths[k], "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
        temp_fields[k] = temp_fields[k]["Temperature [C]"].detach().cpu().squeeze().numpy()
    
    hp_pos = [9, 23] # TODO: Aus Datei einlesen
    base_temperature = 10.6 # TODO: Aus Datei einlesen

    # Calculate rough bounding boxes around heat plumes

    ybounds = [[], [], []]
    xbounds = [[], [], []]

    if run_indices[0] != 0 or run_indices[1] != 3 or run_indices[2] != 4:  # TODO: Ausrechnen
        return
    ybounds[0] = [22, 255]
    xbounds[0] = [6, 11]
    ybounds[1] = [20, 148]
    xbounds[1] = [1, 18]
    ybounds[2] = [0, 78]
    xbounds[2] = [0, 19]

    fig, axes = plt.subplots(7, 1, sharex=True)

    for k in range(0, 3):
        plt.sca(axes[k])
        plt.imshow(temp_fields[k], cmap="RdBu_r")

    transformed_temp_fields = [np.ndarray((dims[0], dims[1])) for i in range(3)]
    result_temp_field = np.ndarray((dims[0], dims[1]))

    ybounds_res = [weights[0]*ybounds[0][0] + weights[1]*ybounds[1][0] + weights[2]*ybounds[2][0], weights[0]*ybounds[0][1] + weights[1]*ybounds[1][1] + weights[2]*ybounds[2][1]]
    xbounds_res = [weights[0]*xbounds[0][0] + weights[1]*xbounds[1][0] + weights[2]*xbounds[2][0], weights[0]*xbounds[0][1] + weights[1]*xbounds[1][1] + weights[2]*xbounds[2][1]]

    for j in range(0, 256):
        for i in range(0, 20):
            for k in range(0, 3):
                transformed_temp_fields[k][i][j] = get_result(base_temperature, temp_fields[k], i, j, xbounds[k], ybounds[k], xbounds_res, ybounds_res)

    for k in range(0, 3):
        plt.sca(axes[3 + k])
        plt.imshow(transformed_temp_fields[k], cmap="RdBu_r")

    for j in range(0, 256):
        for i in range(0, 20):
            result_temp_field[i][j] = transformed_temp_fields[0][i][j]*weight1 + transformed_temp_fields[1][i][j]*weight2 + transformed_temp_fields[2][i][j]*weight3

    plt.sca(axes[6])
    plt.imshow(result_temp_field, cmap="RdBu_r")
    plt.show()


def get_result(base_temperature, values, i, j, xbounds, ybounds, xbounds_res, ybounds_res):
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

    # y = y_pump_spline.ev([it],[jt])[0]
    y = sp.interpolate.interpn((range(20), range(256)), values, [it,jt], bounds_error=False, fill_value=None, method='linear')[0]

    if y < base_temperature: # einfach Abschneiden liefert ganz schlechte Ergebnisse
        return base_temperature
    else:
        return y

if __name__ == "__main__":
    #interpolate_experimental(0, 3, 4)
    triangulate_data_point(3.8e-9, -0.0024)
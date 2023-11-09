import os
import sys
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
from matplotlib.path import Path
from scipy.spatial import Delaunay
from scipy.spatial import ConvexHull
import model_communication as mc
from numpy.linalg import norm
from dataclasses import dataclass

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

@dataclass
class DataPoint:
    k: np.float64 # permeability
    p: np.float64 # pressure

@dataclass
class GroundTruthInfo:
    dataset_path: str
    base_temp: float
    datapoints: list = None
    threshold_temp: float = 0
    visualize: bool = False
    dims: list = None
    hp_pos = [9, 23]

    def __post_init__(self):
        self.datapoints = load_data_points(self.dataset_path)
        self.threshold_temp = self.base_temp + 0.5
        pflotran_settings = prepare.get_pflotran_settings(path_to_dataset)
        self.dims = [pflotran_settings["grid"]["ncells"][0], pflotran_settings["grid"]["ncells"][1]]

def load_data_points(path_to_dataset):
    permeability_values_path = os.path.join(path_to_dataset, "inputs", "permeability_values.txt")
    pressure_values_path = os.path.join(path_to_dataset, "inputs", "pressure_values.txt")

    permeability_values = []
    with open(permeability_values_path) as file:
        permeability_values = [float(line.rstrip()) for line in file]

    pressure_values = []
    with open(pressure_values_path) as file:
        pressure_values = [float(line.rstrip()) for line in file]

    datapoints = [DataPoint(k * 1e10, p * 1e3) for k, p in zip(permeability_values, pressure_values)]
    # plt.plot(np.array(permeability_values) * 1e10, np.array(pressure_values) * 1e3, '+c')
    return datapoints


def get_line_determinant(a1: DataPoint, a2: DataPoint, b: DataPoint):
    return (a2.k - a1.k) * (b.p - a1.p) - (a2.p - a1.p) * (b.k - a1.k) #k=x, p=y

def square_distance(a: DataPoint, b: DataPoint):
    return (b.k - a.k)**2 + (b.p - a.p)**2

def distance(a: DataPoint, b: DataPoint):
    return np.sqrt((b.k - a.k)**2 + (b.p - a.p)**2)

def get_closest_point(p: DataPoint, datapoints: list):
    closest_i = 0
    min_distance = square_distance(p, datapoints[0])
    for i, x in enumerate(datapoints):
        d = square_distance(p, x)
        if d < min_distance:
            min_distance = d
            closest_i = i
    return closest_i

def triangulate_data_point(info: GroundTruthInfo, p: DataPoint):
    p = DataPoint(p.k * 1e10, p.p * 1e3)
    closest_i = get_closest_point(p, info.datapoints)
    c = info.datapoints[closest_i]
    q = DataPoint(p.k + (p.p - c.p), p.p - (p.k - c.k))
    
    closest_left_i = 0
    closest_right_i = 0

    dist_left = np.inf
    dist_right = np.inf

    if info.visualize: plt.gca().set_aspect('equal')

    for i, x in enumerate(info.datapoints):
        pos_sp = get_line_determinant(c, p, x)
        pos_sq = get_line_determinant(p, q, x)
        if pos_sp >= 0 and pos_sq >= 0: # left 
            if info.visualize and x.k < 15: plt.plot(x.k, x.p, 'r+')
            d = square_distance(p, x)
            if (dist_left > d):
                dist_left = d
                closest_left_i = i
        elif pos_sp < 0 and pos_sq >= 0: # right
            if info.visualize and x.k < 15: plt.plot(x.k, x.p, 'c+')
            d = square_distance(p, x)
            if (dist_right > d):
                dist_right = d
                closest_right_i = i
        else:
            if info.visualize and x.k < 15: plt.plot(x.k, x.p, 'g+')

    if info.visualize: 
        plt.plot(p.k, p.p, 'ro')
        plt.plot(c.k, c.p, 'bo')
        plt.text(p.k, p.p, 'p')
        plt.text(c.k, c.p, 'c')
        
        plt.plot(info.datapoints[closest_left_i].k, info.datapoints[closest_left_i].p, 'bo')
        plt.text(info.datapoints[closest_left_i].k, info.datapoints[closest_left_i].p, 'cl')
        plt.plot(info.datapoints[closest_right_i].k, info.datapoints[closest_right_i].p, 'bo')
        plt.text(info.datapoints[closest_right_i].k, info.datapoints[closest_right_i].p,'cr')
        plt.show()
    
    if dist_left < np.inf and dist_right < np.inf:      
        return [closest_i, closest_left_i, closest_right_i]
    else:
        return closest_i

def calculate_barycentric_weights(info: GroundTruthInfo, triangle_i: list, x: DataPoint):
    x = DataPoint(x.k * 1e10, x.p * 1e3)
    t1 = info.datapoints[triangle_i[0]]
    t2 = info.datapoints[triangle_i[1]]
    t3 = info.datapoints[triangle_i[2]]
    d = (t2.p - t3.p) * (t1.k - t3.k) + (t3.k - t2.k) * (t1.p - t3.p)
    w1 = ((t2.p - t3.p) * (x.k - t3.k) + (t3.k - t2.k) * (x.p - t3.p)) / d
    w2 = ((t3.p - t1.p) * (x.k - t3.k) + (t1.k - t3.k) * (x.p - t3.p)) / d
    w3 = 1 - w1 - w2

    return [w1, w2, w3]

def triangulate_data_point_delauny(permeability: float, pressure: float, show_triangulation=False):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    permeability_values, pressure_values = read_input_lists(path_to_dataset)

    permeability_values.append(permeability)
    pressure_values.append(pressure)
    x = [permeability, pressure]

    simulated_points = np.c_[permeability_values, pressure_values]
    plt.plot(simulated_points[:,0], simulated_points[:,1], '+')
    plt.plot(permeability, pressure, 'ro')

    triangulation = Delaunay(simulated_points)
    simplex_index = triangulation.find_simplex(x)

    if simplex_index == -1:
        return generate_groundtruth_closest(permeability, pressure)

    point_indices = triangulation.simplices[simplex_index]

    p1 = simulated_points[point_indices[0]]
    p2 = simulated_points[point_indices[1]]
    p3 = simulated_points[point_indices[2]]

    return [p1, p2, p3]

    # w1 = norm(x - p2) * norm(x - p3) / (norm(p1 - p2) * norm(p1 - p3))
    # w2 = norm(x - p1) * norm(x - p3) / (norm(p2 - p1) * norm(p2 - p3))
    # w3 = norm(x - p1) * norm(x - p2) / (norm(p3 - p1) * norm(p3 - p2))

    # sum = w1 + w2 + w3 # Gut?
    # w1 /= sum
    # w2 /= sum
    # w3 /= sum

    # print(f"Lagrangeartig: {[w1, w2, w3]}, summe = {w1 + w2 + w3}")

    weights = [0, 0, 0]
    d = (p2[1] - p3[1]) * (p1[0] - p3[0]) + (p1[1] - p3[1]) * (p3[0] - p2[0])
    weights[0] = ((p2[1] - p3[1]) * (x[0] - p3[0]) + (p3[0] - p2[0]) * (x[1] - p3[1])) / d
    weights[1] = ((p3[1] - p1[1]) * (x[0] - p3[0]) + (p1[0] - p3[0]) * (x[1] - p3[1])) / d
    weights[2] = 1 - weights[0] - weights[1]

    print(f"Barycentric: {weights}, sum = {weights[0] + weights[1] + weights[2]}")
     

    if show_triangulation:
        plt.plot(simulated_points[:,0], simulated_points[:,1], '+')
        plt.triplot(simulated_points[:,0], simulated_points[:,1], simulated_points.simplices)
        plt.plot(permeability, pressure, 'ro')
        for k in range(0, 3):
            plt.plot(simulated_points[point_indices[k]][0], simulated_points[point_indices[k]][1], 'r+')
            plt.text(simulated_points[point_indices[k]][0], simulated_points[point_indices[k]][1], str(weights[k]))
        plt.show()

    interpolate_experimental(point_indices, weights)

def interpolate_experimental(info: GroundTruthInfo, triangle_i, weights):

    # Load temperature fields

    dp_paths = ["", "", ""]
    for k in range(0, 3):
        dp_paths[k] = os.path.join(info.dataset_path, f"RUN_{triangle_i[k]}", "pflotran.h5")

    temp_fields = [[], [], []]
    for k in range(0, 3):
        temp_fields[k] = prepare.load_data(dp_paths[k], "   4 Time  2.75000E+01 y", ["Temperature [C]"], info.dims)
        temp_fields[k] = temp_fields[k]["Temperature [C]"].detach().cpu().squeeze().numpy()

    # Calculate rough bounding boxes around heat plumes

    ybounds = [[-1, 256], [-1, 256], [-1, 256]]
    xbounds = [[-1, 20], [-1, 20], [-1, 20]]

    for k in range(0, 3):
        for j in range(0, info.hp_pos[1]):
            flound_edge = False
            for i in range(0, info.dims[0]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            ybounds[k][0] += 1
            if flound_edge:
                break
    for k in range(0, 3):
        for j in reversed(range(info.hp_pos[1]+1, 256)):
            flound_edge = False
            for i in range(0, info.dims[0]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            ybounds[k][1] -= 1
            if flound_edge:
                break
    for k in range(0, 3):
        for i in range(0, info.hp_pos[0]):
            flound_edge = False
            for j in range(0, info.dims[1]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            xbounds[k][0] += 1
            if flound_edge:
                break
    for k in range(0, 3):
        for i in  reversed(range(info.hp_pos[0]+1, 20)):
            flound_edge = False
            for j in range(0, info.dims[1]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            xbounds[k][1] -= 1
            if flound_edge:
                break

    transformed_temp_fields = [np.ndarray((info.dims[0], info.dims[1])) for i in range(3)]
    result_temp_field = np.ndarray((info.dims[0], info.dims[1]))

    ybounds_res = [weights[0]*ybounds[0][0] + weights[1]*ybounds[1][0] + weights[2]*ybounds[2][0], weights[0]*ybounds[0][1] + weights[1]*ybounds[1][1] + weights[2]*ybounds[2][1]]
    xbounds_res = [weights[0]*xbounds[0][0] + weights[1]*xbounds[1][0] + weights[2]*xbounds[2][0], weights[0]*xbounds[0][1] + weights[1]*xbounds[1][1] + weights[2]*xbounds[2][1]]

    for j in range(0, 256):
        for i in range(0, 20):
            for k in range(0, 3):
                transformed_temp_fields[k][i][j] = get_result(info, temp_fields[k], i, j, xbounds[k], ybounds[k], xbounds_res, ybounds_res)

    for j in range(0, 256):
        for i in range(0, 20):
            result_temp_field[i][j] = transformed_temp_fields[0][i][j]*weights[0] + transformed_temp_fields[1][i][j]*weights[1] + transformed_temp_fields[2][i][j]*weights[2]

    if info.visualize:
        fig, axes = plt.subplots(7, 1, sharex=True)
        for k in range(0, 3):
            plt.sca(axes[k])
            plt.imshow(temp_fields[k], cmap="RdBu_r")
        for k in range(0, 3):
            plt.sca(axes[3 + k])
            plt.imshow(transformed_temp_fields[k], cmap="RdBu_r")
        plt.sca(axes[6])
        plt.imshow(result_temp_field, cmap="RdBu_r")
        plt.show()

def get_result(info: GroundTruthInfo, values, i, j, xbounds, ybounds, xbounds_res, ybounds_res):
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
    y = sp.interpolate.interpn((range(info.dims[0]), range(info.dims[1])), values, [it,jt], bounds_error=False, fill_value=None, method='linear')[0]

    if y < info.base_temp: # einfach Abschneiden liefert ganz schlechte Ergebnisse
        return info.base_temp
    else:
        return y

if __name__ == "__main__":
    x = DataPoint(3.1e-10, -2e-3)

    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    groundtruth_info = GroundTruthInfo(path_to_dataset, 10.6)
    groundtruth_info.visualize = True

 
    triangle_i = triangulate_data_point(groundtruth_info, x)
    if isinstance(triangle_i, list):
        weights = calculate_barycentric_weights(groundtruth_info, triangle_i, x)
        interpolate_experimental(groundtruth_info, triangle_i, weights)

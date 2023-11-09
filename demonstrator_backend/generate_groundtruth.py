import os
import sys
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
from dataclasses import dataclass

sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))
import preprocessing.prepare_1ststage as prepare


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
        pflotran_settings = prepare.get_pflotran_settings(self.dataset_path)
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
    return datapoints


def get_line_determinant(a1: DataPoint, a2: DataPoint, b: DataPoint):
    return (a2.k - a1.k) * (b.p - a1.p) - (a2.p - a1.p) * (b.k - a1.k) #k=x, p=y

def square_distance(a: DataPoint, b: DataPoint):
    return (b.k - a.k)**2 + (b.p - a.p)**2

def distance(a: DataPoint, b: DataPoint):
    return np.sqrt((b.k - a.k)**2 + (b.p - a.p)**2)

def get_closest_point(p: DataPoint, datapoints: list):
    closest_i = 0
    min_distance = np.inf
    for i, x in enumerate(datapoints):
        if not x == None: # Für Fehlertests
            d = square_distance(p, x)
            if d < min_distance:
                min_distance = d
                closest_i = i
    return closest_i

def triangulate_data_point(info: GroundTruthInfo, p: DataPoint):
    p = DataPoint(p.k, p.p)
    closest_i = get_closest_point(p, info.datapoints)
    c = info.datapoints[closest_i]
    q = DataPoint(p.k + (p.p - c.p), p.p - (p.k - c.k))
    
    closest_left_i = 0
    closest_right_i = 0

    dist_left = np.inf
    dist_right = np.inf

    for i, x in enumerate(info.datapoints):
        if not x == None: # Für Fehlertests
            pos_sp = get_line_determinant(c, p, x)
            pos_sq = get_line_determinant(p, q, x)
            if pos_sp >= 0 and pos_sq >= 0: # left 
                d = square_distance(p, x)
                if (dist_left > d):
                    dist_left = d
                    closest_left_i = i
            elif pos_sp < 0 and pos_sq >= 0: # right
                d = square_distance(p, x)
                if (dist_right > d):
                    dist_right = d
                    closest_right_i = i
    
    if dist_left < np.inf and dist_right < np.inf:      
        return [closest_i, closest_left_i, closest_right_i]
    else:
        return closest_i

def calculate_barycentric_weights(info: GroundTruthInfo, triangle_i: list, x: DataPoint):
    t1 = info.datapoints[triangle_i[0]]
    t2 = info.datapoints[triangle_i[1]]
    t3 = info.datapoints[triangle_i[2]]
    d = (t2.p - t3.p) * (t1.k - t3.k) + (t3.k - t2.k) * (t1.p - t3.p)
    w1 = ((t2.p - t3.p) * (x.k - t3.k) + (t3.k - t2.k) * (x.p - t3.p)) / d
    w2 = ((t3.p - t1.p) * (x.k - t3.k) + (t1.k - t3.k) * (x.p - t3.p)) / d
    w3 = 1 - w1 - w2

    return [w1, w2, w3]


def load_temperature_field(info: GroundTruthInfo, run_index: int):
    path = os.path.join(info.dataset_path, f"RUN_{run_index}", "pflotran.h5")
    temperature_field = prepare.load_data(path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], info.dims)
    temperature_field = temperature_field["Temperature [C]"].detach().cpu().squeeze().numpy()
    return temperature_field


def interpolate_experimental(info: GroundTruthInfo, triangle_i, weights):

    # Load temperature fields

    temp_fields = [[], [], []]
    for k in range(0, 3):
        temp_fields[k] = load_temperature_field(info, triangle_i[k])

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

    transformed_temp_fields = [np.ndarray(info.dims) for i in range(3)]
    result_temp_field = np.ndarray((info.dims[0], info.dims[1]))

    ybounds_res = [weights[0]*ybounds[0][0] + weights[1]*ybounds[1][0] + weights[2]*ybounds[2][0], weights[0]*ybounds[0][1] + weights[1]*ybounds[1][1] + weights[2]*ybounds[2][1]]
    xbounds_res = [weights[0]*xbounds[0][0] + weights[1]*xbounds[1][0] + weights[2]*xbounds[2][0], weights[0]*xbounds[0][1] + weights[1]*xbounds[1][1] + weights[2]*xbounds[2][1]]

    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            for k in range(3):
                transformed_temp_fields[k][i][j] = get_result(info, temp_fields[k], i, j, xbounds[k], ybounds[k], xbounds_res, ybounds_res)

    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
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
        
    return result_temp_field

def get_result(info: GroundTruthInfo, values, i, j, xbounds, ybounds, xbounds_res, ybounds_res):
    it = info.hp_pos[0]
    jt = info.hp_pos[1]
    if i < info.hp_pos[0]:
        it = info.hp_pos[0] + (info.hp_pos[0] - xbounds[0]) / (info.hp_pos[0] - xbounds_res[0]) * (i - info.hp_pos[0])
    elif i > info.hp_pos[0]:
        it = info.hp_pos[0] + (info.hp_pos[0] - xbounds[1]) / (info.hp_pos[0] - xbounds_res[1]) * (i - info.hp_pos[0])
    if j < info.hp_pos[1]:
        jt = info.hp_pos[1] + (info.hp_pos[1] - ybounds[0]) / (info.hp_pos[1] - ybounds_res[0]) * (j - info.hp_pos[1])
    elif j > info.hp_pos[1]:
        jt = info.hp_pos[1] + (info.hp_pos[1] - ybounds[1]) / (info.hp_pos[1] - ybounds_res[1]) * (j - info.hp_pos[1])

    # TODO: Ersetzen durch schnellere Interpolation
    y = sp.interpolate.interpn((range(info.dims[0]), range(info.dims[1])), values, [it,jt], bounds_error=False, fill_value=None, method='linear')[0]

    if y < info.base_temp: 
        return info.base_temp
    else:
        return y


def generate_groundtruth(info: GroundTruthInfo, permeability: float, pressure: float):
    x = DataPoint(permeability, pressure)
    triangle_i = triangulate_data_point(info, x)
    if isinstance(triangle_i, list):
        weights = calculate_barycentric_weights(info, triangle_i, x)
        return interpolate_experimental(info, triangle_i, weights)
    else:
        return load_temperature_field(info, triangle_i)

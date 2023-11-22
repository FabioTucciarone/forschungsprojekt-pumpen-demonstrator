import os
import sys
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import torch
from dataclasses import dataclass


@dataclass
class DataPoint:
    k: np.float64 # permeability
    p: np.float64 # pressure


@dataclass
class GroundTruthInfo:
    dataset_path: str
    base_temp: float
    use_interpolation: bool = True
    datapoints: list = None
    threshold_temp: float = 0
    visualize: bool = False
    dims: list = None
    hp_pos = [9, 23]

    def __post_init__(self):
        self.datapoints = load_data_points(self.dataset_path)
        self.threshold_temp = self.base_temp + 0.5
        pflotran_settings = prepare.get_pflotran_settings(self.dataset_path)
        self.dims = pflotran_settings["grid"]["ncells"]


@dataclass
class HPBounds:
    x0: int = -1
    x1: int = 20
    y0: int = -1
    y1: int = 256


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


def load_temperature_field_raw(info: GroundTruthInfo, run_index: int):
    path = os.path.join(info.dataset_path, f"RUN_{run_index}", "pflotran.h5")
    return prepare.load_data(path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], info.dims) # TODO: DIMS


def load_temperature_field(info: GroundTruthInfo, run_index: int):
    temperature_field = load_temperature_field_raw(info, run_index)["Temperature [C]"].detach().cpu().squeeze().numpy()
    return temperature_field


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


def calculate_hp_bounds(info, temp_fields):
    bounds = [HPBounds(), HPBounds(), HPBounds()]

    for k in range(0, 3):
        for j in range(0, info.hp_pos[1]):
            flound_edge = False
            for i in range(0, info.dims[0]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].y0 += 1
            if flound_edge:
                break
    for k in range(0, 3):
        for j in reversed(range(info.hp_pos[1]+1, 256)): # TODO?
            flound_edge = False
            for i in range(0, info.dims[0]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].y1 -= 1
            if flound_edge:
                break
    for k in range(0, 3):
        for i in range(0, info.hp_pos[0]):
            flound_edge = False
            for j in range(0, info.dims[1]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].x0 += 1
            if flound_edge:
                break
    for k in range(0, 3):
        for i in  reversed(range(info.hp_pos[0]+1, 20)):
            flound_edge = False
            for j in range(0, info.dims[1]):
                flound_edge = flound_edge or temp_fields[k][i][j] >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].x1 -= 1
            if flound_edge:
                break

    return bounds


def get_temperature_value(temp_field: np.ndarray, info: GroundTruthInfo, i: int, j: int):
    if i < 0 or i >= info.dims[0] or j < 0 or j >= info.dims[1]:
        return info.base_temp


def interpolate_linearly(temp_field, i, j):
    i1 = int(i + 0.5) # richtig runden
    j1 = int(j + 0.5)





def interpolate_experimental(info: GroundTruthInfo, triangle_i, weights):

    # Load temperature fields

    temp_fields = [[], [], []]
    for k in range(0, 3):
        temp_fields[k] = load_temperature_field(info, triangle_i[k])

    # Calculate rough bounding boxes around heat plumes
    bounds = calculate_hp_bounds(info, temp_fields)

    transformed_temp_fields = [np.ndarray(info.dims) for i in range(3)]
    result_temp_field = np.ndarray((info.dims[0], info.dims[1]))

    result_bounds = HPBounds()
    result_bounds.x0 = weights[0] * bounds[0].x0 + weights[1] * bounds[1].x0 + weights[2] * bounds[2].x0
    result_bounds.x1 = weights[0] * bounds[0].x1 + weights[1] * bounds[1].x1 + weights[2] * bounds[2].x1
    result_bounds.y0 = weights[0] * bounds[0].y0 + weights[1] * bounds[1].y0 + weights[2] * bounds[2].y0
    result_bounds.y1 = weights[0] * bounds[0].y1 + weights[1] * bounds[1].y1 + weights[2] * bounds[2].y1
    pos_i = info.hp_pos[0] # (result_bounds.x0 + result_bounds.x1) / 4 alles kagga?
    pos_j = info.hp_pos[1] # (result_bounds.y0 + result_bounds.y1) / 2 alles kagga?

    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            for k in range(3):
                it, jt = get_sample_indices(pos_i, pos_j, i, j, bounds[k], result_bounds)

                y = sp.interpolate.interpn((range(info.dims[0]), range(info.dims[1])), temp_fields[k], [it,jt], bounds_error=False, fill_value=None, method='linear')[0]
                #y = interpolate_linearly(temp_fields[k], it, jt)
                if y < info.base_temp: y = info.base_temp

                transformed_temp_fields[k][i][j] = y

    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            result_temp_field[i][j] = transformed_temp_fields[0][i][j]*weights[0] + transformed_temp_fields[1][i][j]*weights[1] + transformed_temp_fields[2][i][j]*weights[2]
        
    return {"Temperature [C]": torch.tensor(result_temp_field).unsqueeze(2)}


def get_sample_indices(pos_i, pos_j, i, j, bounds: HPBounds, result_bounds: HPBounds):
    it = pos_i
    jt = pos_j
    if i < pos_i:
        it = pos_i + (pos_i - bounds.x0) / (pos_i - result_bounds.x0) * (i - pos_i)
    elif i > pos_i:
        it = pos_i + (pos_i - bounds.x1) / (pos_i - result_bounds.x1) * (i - pos_i)
    if j < pos_j:
        jt = pos_j + (pos_j - bounds.y0) / (pos_j - result_bounds.y0) * (j - pos_j)
    elif j > pos_j:
        jt = pos_j + (pos_j - bounds.y1) / (pos_j - result_bounds.y1) * (j - pos_j)
    return it, jt


def generate_groundtruth(info: GroundTruthInfo, permeability: float, pressure: float):
    x = DataPoint(permeability * 1e10, pressure * 1e3) #TODO: skalieren?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    if info.use_interpolation == True:
        triangle_i = triangulate_data_point(info, x)
        if isinstance(triangle_i, list):
            weights = calculate_barycentric_weights(info, triangle_i, x)
            return interpolate_experimental(info, triangle_i, weights)
        else:
            return load_temperature_field_raw(info, triangle_i)
    else:
        return load_temperature_field_raw(info, get_closest_point(x))


# ACHTUNG:
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))
import preprocessing.prepare_1ststage as prepare

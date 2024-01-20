import os
import numpy as np
import torch

from groundtruth_data import DataPoint, GroundTruthInfo, HPBounds, load_temperature_field_raw
from extrapolation import TaylorInterpolatedField, PolyInterpolatedField
from multiprocessing import Pool
from itertools import repeat

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


def calculate_hp_bounds(info, temp_field):
    bounds = HPBounds()

    for j in range(0, info.hp_pos[1]):
        flound_edge = False
        for i in range(0, info.dims[0]):
            flound_edge = flound_edge or temp_field.at(i, j) >= info.threshold_temp
            if flound_edge:
                break
        bounds  .y0 += 1
        if flound_edge:
            break
    for j in reversed(range(info.hp_pos[1]+1, 256)): # TODO?
        flound_edge = False
        for i in range(0, info.dims[0]):
            flound_edge = flound_edge or temp_field.at(i, j) >= info.threshold_temp
            if flound_edge:
                break
        bounds.y1 -= 1
        if flound_edge:
            break
    for i in range(0, info.hp_pos[0]):
        flound_edge = False
        for j in range(0, info.dims[1]):
            flound_edge = flound_edge or temp_field.at(i, j) >= info.threshold_temp
            if flound_edge:
                break
        bounds.x0 += 1
        if flound_edge:
            break
    for i in  reversed(range(info.hp_pos[0]+1, 20)):
        flound_edge = False
        for j in range(0, info.dims[1]):
            flound_edge = flound_edge or temp_field.at(i, j) >= info.threshold_temp
            if flound_edge:
                break
        bounds.x1 -= 1
        if flound_edge:
            break

    return bounds


def get_result_bounds(bounds, weights):
    result_bounds = HPBounds()
    result_bounds.x0 = weights[0] * bounds[0].x0 + weights[1] * bounds[1].x0 + weights[2] * bounds[2].x0
    result_bounds.x1 = weights[0] * bounds[0].x1 + weights[1] * bounds[1].x1 + weights[2] * bounds[2].x1
    result_bounds.y0 = weights[0] * bounds[0].y0 + weights[1] * bounds[1].y0 + weights[2] * bounds[2].y0
    result_bounds.y1 = weights[0] * bounds[0].y1 + weights[1] * bounds[1].y1 + weights[2] * bounds[2].y1
    return result_bounds


def interpolate_experimental(info: GroundTruthInfo, triangle_i: list, weights: list):
    
    temp_fields = []
    bounds = []
    transformed = []

    pool = Pool(3)

    for k in range(3):
        temp_fields.append(PolyInterpolatedField(info, run_index=triangle_i[k]))
        transformed.append(PolyInterpolatedField(info))
    
    bounds = pool.starmap(calculate_hp_bounds, zip(repeat(info), temp_fields))
    result_bounds = get_result_bounds(bounds, weights)
    transformed = pool.starmap(transform_fields, zip(repeat(info), temp_fields, bounds, repeat(result_bounds)))

    result = transformed[0].T * weights[0] + transformed[1].T * weights[1] + transformed[2].T * weights[2]

    return {"Temperature [C]": torch.tensor(result).unsqueeze(2)}


def transform_fields(info, temp_fields, bounds, result_bounds):
    t = PolyInterpolatedField(info)
    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            it, jt = get_sample_indices(info.hp_pos, i, j, bounds, result_bounds)
            t.set(i, j, temp_fields.at(it, jt))
    return t

def b(info, temp_field, transformed, field_bounds, result_bounds):
    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            it, jt = get_sample_indices(info.hp_pos, i, j, field_bounds, result_bounds)
            transformed.set(i, j, temp_field.at(it, jt))


def get_sample_indices(hp_pos, i, j, bounds: HPBounds, result_bounds: HPBounds):
    it = hp_pos[0]
    jt = hp_pos[1]
    if i < hp_pos[0]:
        it = hp_pos[0] + (hp_pos[0] - bounds.x0) / (hp_pos[0] - result_bounds.x0) * (i - hp_pos[0])
    elif i > hp_pos[0]:
        it = hp_pos[0] + (hp_pos[0] - bounds.x1) / (hp_pos[0] - result_bounds.x1) * (i - hp_pos[0])
    if j < hp_pos[1]:
        jt = hp_pos[1] + (hp_pos[1] - bounds.y0) / (hp_pos[1] - result_bounds.y0) * (j - hp_pos[1])
    elif j > hp_pos[1]:
        jt = hp_pos[1] + (hp_pos[1] - bounds.y1) / (hp_pos[1] - result_bounds.y1) * (j - hp_pos[1])
    return it, jt


def generate_groundtruth(info: GroundTruthInfo, permeability: float, pressure: float, use_interpolation: bool = True):
    x = DataPoint(permeability * 1e10, pressure * 1e3)  # TODO: skalieren?

    if use_interpolation:
        triangle_i = triangulate_data_point(info, x)
        if isinstance(triangle_i, list):
            weights = calculate_barycentric_weights(info, triangle_i, x)
            return interpolate_experimental(info, triangle_i, weights), "interpolation"
        else:
            return load_temperature_field_raw(info, triangle_i), "closest"
    else:
        return load_temperature_field_raw(info, get_closest_point(x)), "closest"


def main():
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = GroundTruthInfo(path_to_dataset, 10.6)
    interpolate_experimental(info, [1, 2, 3], [1/3, 1/3, 1/3])

if __name__ == "__main__":
    main()
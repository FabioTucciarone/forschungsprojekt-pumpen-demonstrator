import os
import numpy as np
import torch

from groundtruth_data import DataPoint, GroundTruthInfo, HPBounds, load_temperature_field_raw
from extrapolation import TaylorInterpolatedField


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
                flound_edge = flound_edge or temp_fields[k].at(i, j) >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].y0 += 1
            if flound_edge:
                break
        for j in reversed(range(info.hp_pos[1]+1, 256)): # TODO?
            flound_edge = False
            for i in range(0, info.dims[0]):
                flound_edge = flound_edge or temp_fields[k].at(i, j) >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].y1 -= 1
            if flound_edge:
                break
        for i in range(0, info.hp_pos[0]):
            flound_edge = False
            for j in range(0, info.dims[1]):
                flound_edge = flound_edge or temp_fields[k].at(i, j) >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].x0 += 1
            if flound_edge:
                break
        for i in  reversed(range(info.hp_pos[0]+1, 20)):
            flound_edge = False
            for j in range(0, info.dims[1]):
                flound_edge = flound_edge or temp_fields[k].at(i, j) >= info.threshold_temp
                if flound_edge:
                    break
            bounds[k].x1 -= 1
            if flound_edge:
                break

    return bounds


def interpolate_experimental(info: GroundTruthInfo, triangle_i: list, weights: list):

    temp_fields = [[], [], []]
    for k in range(0, 3):
        temp_fields[k] = TaylorInterpolatedField(info, run_index=triangle_i[k]) 

    bounds = calculate_hp_bounds(info, temp_fields)

    transformed = [TaylorInterpolatedField(info) for i in range(3)]
    result = TaylorInterpolatedField(info)

    result_bounds = HPBounds()
    result_bounds.x0 = weights[0] * bounds[0].x0 + weights[1] * bounds[1].x0 + weights[2] * bounds[2].x0
    result_bounds.x1 = weights[0] * bounds[0].x1 + weights[1] * bounds[1].x1 + weights[2] * bounds[2].x1
    result_bounds.y0 = weights[0] * bounds[0].y0 + weights[1] * bounds[1].y0 + weights[2] * bounds[2].y0
    result_bounds.y1 = weights[0] * bounds[0].y1 + weights[1] * bounds[1].y1 + weights[2] * bounds[2].y1
    pos_i = info.hp_pos[0] 
    pos_j = info.hp_pos[1] 

    # TODO: Paralellisieren? Torch ausnutzen?
    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            for k in range(3):
                it, jt = get_sample_indices(pos_i, pos_j, i, j, bounds[k], result_bounds)

                y = temp_fields[k].at(it, jt)
                if y < info.base_temp: y = info.base_temp # TODO: Loswerden? Auch torch verwenden?

                transformed[k].set(i, j, y)

    # TODO: Paralellisieren? Torch ausnutzen?
    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            result.set(i, j, transformed[0].at(i, j)*weights[0] + transformed[1].at(i, j)*weights[1] + transformed[2].at(i, j)*weights[2])

    return {"Temperature [C]": torch.tensor(result.T).unsqueeze(2)}


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


def generate_groundtruth(info: GroundTruthInfo, permeability: float, pressure: float, use_interpolation: bool = True):
    x = DataPoint(permeability * 1e10, pressure * 1e3)  # TODO: skalieren?

    if use_interpolation:
        triangle_i = triangulate_data_point(info, x)
        if isinstance(triangle_i, list):
            weights = calculate_barycentric_weights(info, triangle_i, x)
            return interpolate_experimental(info, triangle_i, weights)
        else:
            return load_temperature_field_raw(info, triangle_i)
    else:
        return load_temperature_field_raw(info, get_closest_point(x))


def main():
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = GroundTruthInfo(path_to_dataset, 10.6)
    interpolate_experimental(info, [1, 2, 3], [1/3, 1/3, 1/3])

if __name__ == "__main__":
    main()
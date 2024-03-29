import numpy as np
import torch
from multiprocessing import Pool
from itertools import repeat
from typing import Dict, List, Tuple, Any, Union

from groundtruth_data import ParameterPoint, DatasetInfo, HPBounds, load_temperature_field_raw
from extrapolation import TemperatureField, TaylorInterpolatedField, PolyInterpolatedField


def get_line_determinant(a1: ParameterPoint, a2: ParameterPoint, b: ParameterPoint) -> float:
    """
    return > 0 => b is left of a1->a2
    return < 0 => b is right of a1->a2
    return = 0 => b is on a1->a2
    """
    return (a2.k - a1.k) * (b.p - a1.p) - (a2.p - a1.p) * (b.k - a1.k) #k=x, p=y


def square_distance(a: ParameterPoint, b: ParameterPoint) -> float:
    return (b.k - a.k)**2 + (b.p - a.p)**2


def distance(a: ParameterPoint, b: ParameterPoint) -> float:
    return np.sqrt((b.k - a.k)**2 + (b.p - a.p)**2)


def get_closest_point(p: ParameterPoint, datapoints: List[ParameterPoint]) -> int:
    """
    Returns the dataset index of the closest datapoint to p in parameter space.
    """
    closest_i = 0
    min_distance = np.inf
    for i, x in enumerate(datapoints):
        if not x == None: # Für Fehlertests
            d = square_distance(p, x)
            if d < min_distance:
                min_distance = d
                closest_i = i
    return closest_i


def find_sequential_heuristic_triangle(info: DatasetInfo, p: ParameterPoint) -> Union[int, List[int]]:
    """
    Tries to find a triangle that encloses p.
    Heuristic that usualy finds more triangles than find_quadrant_heuristic_triangle().
    Time complexity: O(n)

    Returns
    ---------
    A list of triangle indices or the index of the nearest point
    """
    closest_i = get_closest_point(p, info.datapoints)
    c = info.datapoints[closest_i]
    q = ParameterPoint(p.k + (p.p - c.p), p.p - (p.k - c.k))

    below_i = 0
    last_i = 0
    dist_below = np.inf
    dist_last = np.inf

    for i, x in enumerate(info.datapoints):
        if not x == None: # Für Fehlertests
            det_pq = get_line_determinant(p, q, x)

            if det_pq >= 0: # links
                d = square_distance(p, x)
                if (d < dist_below):
                    dist_below = d
                    below_i = i

    c1 = info.datapoints[below_i]
    det_cp_c1 = get_line_determinant(c, p, c1)

    if not det_cp_c1 == 0:
        for i, x in enumerate(info.datapoints):
            if not x == None: # Für Fehlertests
                det_cp_x = get_line_determinant(c, p, x)

                if det_cp_c1 * det_cp_x <= 0:
                    det_c1p_x = get_line_determinant(c1, p, x)
                    
                    if det_cp_c1 * det_c1p_x >= 0:
                        d = square_distance(p, x)
                        if (d < dist_last):
                            dist_last = d
                            last_i = i
    else:
        for i in range(len(info.datapoints)):
            if not i == below_i and not i == closest_i:
                last_i = i
                break

    if dist_below < np.inf and dist_last < np.inf:      
        return [closest_i, below_i, last_i]
    else:
        return closest_i


def find_minimal_triangle(info: DatasetInfo, p: ParameterPoint) -> Union[int, List[int]]:
    """
    Tries to find a triangle that encloses p.
    Minimizes the sum of distances from the corner points to p.
    Slow: O(n^2)

    Returns
    ---------
    A list of triangle indices or the index of the nearest point
    """
    c_i = get_closest_point(p, info.datapoints)

    min_sum = np.inf
    c1_i = 0
    c2_i = 0

    for i in range(len(info.datapoints)):
        for j in range(i+1, len(info.datapoints)):
            c1 = info.datapoints[i]
            c2 = info.datapoints[j]
            if not (c1 == None or c2 == None or i == c_i or j == c_i): # Fehlertests
                w1, w2, w3 = calculate_barycentric_weights(info, [c_i, i, j], p)
                if 0 <= w1 <= 1 and 0 <= w2 <= 1 and 0 <= w3 <= 1:
                    d = square_distance(c1, p) + square_distance(c2, p)
                    if d < min_sum:
                        min_sum = d
                        c1_i = i
                        c2_i = j

    if min_sum < np.inf:      
        return [c_i, c1_i, c2_i]
    else:
        return c_i


def find_quadrant_heuristic_triangle(info: DatasetInfo, p: ParameterPoint) -> Union[int, List[int]]:
    """
    Tries to find a triangle that encloses p.
    Heuristic that usualy finds more triangles than find_quadrant_heuristic_triangle().
    Time complexity: O(n)

    Returns
    ---------
    A list of triangle indices or the index of the nearest point
    """
    p = ParameterPoint(p.k, p.p)
    closest_i = get_closest_point(p, info.datapoints)
    c = info.datapoints[closest_i]
    q = ParameterPoint(p.k + (p.p - c.p), p.p - (p.k - c.k))
    
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


def calculate_barycentric_weights(info: DatasetInfo, triangle_i: List[int], x: ParameterPoint) -> Tuple[float, float, float]:
    """
    Calculates the barycentric coordinates of x with respect to the triangle defined by triangle_i.
    """
    t1 = info.datapoints[triangle_i[0]]
    t2 = info.datapoints[triangle_i[1]]
    t3 = info.datapoints[triangle_i[2]]
    d = (t2.p - t3.p) * (t1.k - t3.k) + (t3.k - t2.k) * (t1.p - t3.p)
    w1 = ((t2.p - t3.p) * (x.k - t3.k) + (t3.k - t2.k) * (x.p - t3.p)) / d
    w2 = ((t3.p - t1.p) * (x.k - t3.k) + (t1.k - t3.k) * (x.p - t3.p)) / d
    w3 = 1 - w1 - w2

    return (w1, w2, w3)


def calculate_hp_bounds(info: DatasetInfo, temp_field: TemperatureField) -> HPBounds:
    """
    Tries to estimate the size of a heat plume by calculating a box around the plume using a threshold temperature (info.threshold_temp).


    Returns
    ---------
    bounds: HPBounds
        Extend of the HP-box around info.hp_pos.
    """
    bounds = HPBounds()

    for j in range(0, info.hp_pos[1]):
        flound_edge = False
        for i in range(0, info.dims[0]):
            flound_edge = flound_edge or temp_field.at(i, j) >= info.threshold_temp
            if flound_edge:
                break
        bounds.y0 += 1
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


def get_result_bounds(bounds: List[HPBounds], weights: List[float]) -> HPBounds:
    """
    Interpolates three HPBound-boxes.
    """
    result_bounds = HPBounds()
    result_bounds.x0 = weights[0] * bounds[0].x0 + weights[1] * bounds[1].x0 + weights[2] * bounds[2].x0
    result_bounds.x1 = weights[0] * bounds[0].x1 + weights[1] * bounds[1].x1 + weights[2] * bounds[2].x1
    result_bounds.y0 = weights[0] * bounds[0].y0 + weights[1] * bounds[1].y0 + weights[2] * bounds[2].y0
    result_bounds.y1 = weights[0] * bounds[0].y1 + weights[1] * bounds[1].y1 + weights[2] * bounds[2].y1
    return result_bounds


def interpolate_experimental(info: DatasetInfo, triangle_i: List[int], weights: List[float]) -> Dict[str, torch.Tensor]:
    """
    Combines three temperature fields by calculating and interpolating their bounding boxes, 
    transforming them to the same size, and overlaying them using the weights.

    Returns
    ---------
    A dictionary with only one entry at "Temperature [C]" to be compatible with the transformations in 1HP_NN.
    Needs to be corrected: Remove redundant transformations and return temperature field of correct size!
    """
    
    temp_fields = []
    bounds = []
    transformed = []
    pool = Pool(3)

    for k in range(3):
        temp_fields.append(TaylorInterpolatedField(info, run_index=triangle_i[k]))
        transformed.append(TaylorInterpolatedField(info))
    
    bounds = pool.starmap(calculate_hp_bounds, zip(repeat(info), temp_fields))
    result_bounds = get_result_bounds(bounds, weights)
    transformed = pool.starmap(transform_fields, zip(repeat(info), temp_fields, bounds, repeat(result_bounds)))
    result = transformed[0].T * weights[0] + transformed[1].T * weights[1] + transformed[2].T * weights[2]

    return {"Temperature [C]": torch.tensor(result).unsqueeze(2)}


def transform_fields(info: DatasetInfo, temp_fields: List[TemperatureField], bounds: HPBounds, result_bounds: HPBounds) -> TemperatureField:
    """
    Distort all three temperature fields with the coordinate transformation that results from the interpolated bounds.
    """
    t = TaylorInterpolatedField(info)
    for j in range(info.dims[1]):
        for i in range(info.dims[0]):
            it, jt = get_sample_indices(info.hp_pos, i, j, bounds, result_bounds)
            t.set(i, j, temp_fields.at(it, jt))
    return t


def get_sample_indices(hp_pos: List[int], i: int, j: int, bounds: HPBounds, result_bounds: HPBounds) -> List[float]:
    """
    Transform coordinates so that the transformed input bounds equal result_bounds.
    """
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


def generate_groundtruth(info: DatasetInfo, permeability: float, pressure: float, use_interpolation: bool=True):
    x = ParameterPoint(permeability * 1e10, pressure * 1e3)  # TODO: skalieren?

    if use_interpolation:
        triangle_i = find_sequential_heuristic_triangle(info, x)
        if isinstance(triangle_i, list):
            weights = calculate_barycentric_weights(info, triangle_i, x)
            return interpolate_experimental(info, triangle_i, weights), "interpolation"
        else:
            return load_temperature_field_raw(info, triangle_i), "closest"
    else:
        return load_temperature_field_raw(info, get_closest_point(x)), "closest"

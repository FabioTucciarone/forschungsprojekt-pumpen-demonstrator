import time
import numpy as np
from tqdm.auto import tqdm
import random
import requests
import traceback 
from os import path
import sys
import csv
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from matplotlib.image import AxesImage
from mpl_toolkits.axes_grid1 import make_axes_locatable
from pathlib import Path
from typing import Dict, List, Tuple, Any, Union, Callable

from groundtruth_data import DatasetInfo, ParameterPoint, load_temperature_field
from model_communication import ModelConfiguration
import generate_groundtruth as gt
import model_communication as mc


def show_figure(figure: Figure):
    """
    Display a matplotlib Figure in a new window without much formatting.
    """
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = figure
    figure.set_canvas(canvas_manager.canvas)
    plt.show()


def add_plot_info(image: AxesImage, title: str):
    """
    Add a colorbar and title to a plt.inshow image.
    """
    axis = plt.gca()
    plt.colorbar(image, cax = make_axes_locatable(axis).append_axes("right", size="5%", pad=0.05))
    axis.xaxis.set_label_position('top')
    axis.set_xlabel(title, fontsize='small')


def interpolate_2hp_example():
    """
    Generates bad example from project presentation.
    """
    path_to_dataset = Path(path.dirname(path.abspath(__file__))) / ".." / ".." / "data" / "datasets_domain" / "dataset_2hps_1fixed_1000dp"
    info = DatasetInfo(path_to_dataset, 10.6)
    info.hp_pos = [24, 40]
    y = gt.interpolate_experimental(info, [5, 9, 7], [0, 0.5, 0.5])["Temperature [C]"]

    plt.xlabel("Länge [m]")
    plt.ylabel("Breite [m]")
    image = plt.imshow(y, cmap="RdBu_r", extent=[0,5*y.shape[1],5*y.shape[0],0])
    axis = plt.gca()
    cbar = plt.colorbar(image, cax = make_axes_locatable(axis).append_axes("right", size="5%", pad=0.05))
    cbar.set_label('°C')

    plt.show()


def test_groundtruth(n_from: int, n_to: int, type: str="interp_heuristic", visualize: bool=True, print_all: bool=True):
    """
    Measure and store accuracy and time of the given ground truth generation method.

    Parameters:
    ----------
    n_from:    Index of first datapoint (RUN_<n_from>)
    n_to:      Index of last datapoint (RUN_<n_to>)
    type:      Type of interpolation used: "interp_seq_heuristic", "interp_quad_heuristic", "interp_min", "closest"
    visualize: Whether to show images of the results and comparisons
    print_all: Whether to print the error values
    """

    model_configuration = ModelConfiguration()

    info = model_configuration.dataset_info
    info.visualize = visualize

    average_error_ges = 0
    successful_runs = 0
    rmse = 0

    Path("measurements").mkdir(exist_ok=True)

    with open(f'measurements/performance_{type}.csv', 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(["average_error", "min_error", "max_error", "time"])

        for i in tqdm(range(n_from, n_to+1), desc=f"> Testen type='{type}'", total=n_to-n_from, disable=print_all):
            x = info.datapoints[i]
            info.datapoints[i] = None

            if type == "interp_seq_heuristic":
                total_square_error, average_error, min_error, max_error, time = test_interpolation_groundtruth(info, x, i, gt.find_sequential_heuristic_triangle)
            elif type == "interp_min":
                total_square_error, average_error, min_error, max_error, time = test_interpolation_groundtruth(info, x, i, gt.find_minimal_triangle)
            elif type == "interp_quad_heuristic":
                total_square_error, average_error, min_error, max_error, time = test_interpolation_groundtruth(info, x, i, gt.find_quadrant_heuristic_triangle)
            elif type == "closest":
                total_square_error, average_error, min_error, max_error, time = test_closest_groundtruth(info, x, i)
            else:
                print("> Interpolationstyp existiert nicht")
                break


            if not time == np.inf: csv_writer.writerow([average_error, min_error, max_error, time])

            if not average_error == None:
                rmse += total_square_error
                average_error_ges += average_error
                successful_runs += 1
            info.datapoints[i] = x

            if print_all: 
                print(f"> Datenpunkt {i : <2}: av = {str(average_error) + ',' : <23} min = {str(min_error) + ',' : <23} max = {str(max_error) + ',' : <23}")
    
    rmse = rmse / (info.dims[0] * info.dims[1]) / successful_runs
    print(f"> Erfolgreiche Durchläufe: {successful_runs},  Gesamtergebnis mittlerer Fehler: {average_error_ges / successful_runs}, RMSE: {rmse}")


def test_interpolation_groundtruth(info: DatasetInfo, x: ParameterPoint, i: int, find_triangle: Callable):
    """
    Test some triangle finding algorithm of the input point x against the known data point with the index i.

    Parameters:
    ----------
    info: Information object passed to interpolation function. Contains loaded dataset.
    x:    The input parameters of the point to be interpolated
    i:    Index of the correct result in the dataset (RUN_i)
    find_triangle: triangle finding function
                   call: find_triangle(info, x)

    Returns:
    ----------
    average_error: average error of all cells
    min_error: minimal error of all cells
    max_error: maximal error of all cells
    run_time:  duration of the interpolation
    """

    min_error = None
    max_error = None
    average_error = None
    total_square_error = None

    a = time.perf_counter()
    b = np.inf

    triangle_i = find_triangle(info, x)
    if isinstance(triangle_i, list):
        weights = gt.calculate_barycentric_weights(info, triangle_i, x)
        interp_result = gt.interpolate_experimental(info, triangle_i, weights)["Temperature [C]"]
        b = time.perf_counter()

        interp_result = interp_result.detach().cpu().squeeze().numpy()

        closest_result = load_temperature_field(info, triangle_i[0])
        true_result = load_temperature_field(info, i)

        error = np.abs(np.array(true_result) - np.array(interp_result))
        error_closest = np.abs(np.array(true_result) - np.array(closest_result))

        max_temp = np.max(true_result)
        average_error = np.average(error)
        total_square_error = np.sum(error**2)
        min_error = np.min(error)
        max_error = np.max(error)

        vmax = max(1, np.max(error), np.max(error_closest))
        
        if info.visualize:
            fig, axes = plt.subplots(7, 1, sharex=True)
            fig.set_figheight(7)
            fig.set_figwidth(10)
                       
            for j in range(3):
                plt.sca(axes[j])
                interpolant = load_temperature_field(info, triangle_i[j])
                image = plt.imshow(interpolant, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
                add_plot_info(image, f"Interpolant: {j},  Gewicht: {weights[j]},  Nummer: {triangle_i[j]}")

            plt.sca(axes[3])
            image = plt.imshow(interp_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
            add_plot_info(image, f"Interpolation von Nummer: {i}")

            plt.sca(axes[4])
            image = plt.imshow(true_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
            add_plot_info(image, f"Echtes Ergebnis")

            plt.sca(axes[5])
            image = plt.imshow(error, cmap="RdBu_r", vmin=0, vmax=vmax)
            add_plot_info(image, f"Interpolationsfehler,  Durchschnittlich: {average_error} °C,  Nummer: {i}")

            plt.sca(axes[6])
            image = plt.imshow(error_closest, cmap="RdBu_r", vmin=0, vmax=vmax)
            add_plot_info(image, f"Fehler nächster Punkt,  Durchschnittlich: {np.average(error_closest)} °C,  Nummer: {i}")

            plt.show()

    return total_square_error, average_error, min_error, max_error, b-a
        

def test_closest_groundtruth(info: gt.DatasetInfo, x: ParameterPoint, i: int):
    """
    Exactly like test_interpolation_groundtruth(...) but uses the closest data point as a groundtruth.
    """

    a = time.perf_counter()

    j = gt.get_closest_point(x, info.datapoints)
    closest_result = load_temperature_field(info, j)

    b = time.perf_counter()

    true_result = load_temperature_field(info, i)
    error = np.abs(np.array(true_result) - np.array(closest_result))
            
    max_temp = np.max(true_result)
    average_error = np.average(error)
    total_square_error = np.sum(error**2)
    min_error = np.min(error)
    max_error = np.max(error)

    if info.visualize:
        fig, axes = plt.subplots(3, 1, sharex=True)
        fig.set_figheight(5)
        fig.set_figwidth(10)

        plt.sca(axes[0])
        image = plt.imshow(closest_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
        add_plot_info(image, f"Nächster Punkt,  Nummer: {j}")

        plt.sca(axes[1])
        image = plt.imshow(true_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
        add_plot_info(image, f"Echtes Ergebnis,  Nummer: {i}")

        plt.sca(axes[2])
        image = plt.imshow(error, cmap="RdBu_r", vmin=0, vmax=max(1, np.max(error)))
        add_plot_info(image, f"Fehler,  Durchschnittlich: {average_error} °C,  Nummer: {i}")

        plt.show()

    return total_square_error, average_error, min_error, max_error, b-a


def test_1hp_model_communication(visualize: bool=True):
    st1 = time.time()
    model_configuration = ModelConfiguration()
    et1 = time.time()

    k = 7.350276541753949086e-10
    p = -2.142171334025262316e-03

    st2 = time.time()
    return_data = mc.get_1hp_model_results(model_configuration, k, p)
    et2 = time.time()
    
    print('> Initialization:', et1 - st1, 'seconds')
    print('> Response time:', et2 - st2, 'seconds')
    print('> Total time:', et2 - st2 + et1 - st1, 'seconds')

    print(f"> Error: {return_data.get_return_value('average_error')}")

    if visualize:
        show_figure(return_data.get_figure("model_result"))


def test_2hp_model_communication(visualize: bool=True):
    st1 = time.time()
    model_configuration = ModelConfiguration()
    et1 = time.time()

    k = 1.053944076782911543e-09
    p = -3.040452194657028689e-03
    
    max_x = model_configuration.model_2hp_info["OutFieldShape"][0]
    max_y = model_configuration.model_2hp_info["OutFieldShape"][1]
    positions = [[0, 0], [max_x, 0], [0, max_y], [max_x, max_y], [random.randint(0, max_x), random.randint(0, max_y)]]

    for pos in positions:
        st2 = time.time()
        return_data = mc.get_2hp_model_results(model_configuration, k, p, pos)
        et2 = time.time()
    
    print('> Initialization:', et1 - st1, 'seconds')
    print('> Response time:', et2 - st2, 'seconds')
    print('> Total time:', et2 - st2 + et1 - st1, 'seconds')

    if visualize:
        show_figure(return_data.get_figure("model_result"))


def test_flask_interface():
    localhost = "http://127.0.0.1:5000/"

    try:
        requests.get(url = localhost + "test_response")
    except:
        raise Exception(f"ERROR: Server did not respond! Is it running correctly?")

    r = requests.post(url = localhost + "get_model_result",     json ={"permeability": 1e-9, "pressure": -1e-3, "name": "test.py"})
    assert r.status_code == 200, f"ERROR: get_model_result response code = {r.status_code}!"
    print("SUCCESS: Flask Test: get_model_result response valid.")

    r = requests.post(url = localhost + "get_2hp_model_result", json = {"permeability": 1e-9, "pressure": -1e-3, "pos": [10, 10]})
    assert r.status_code == 200, f"ERROR: get_2hp_model_result response code = {r.status_code}!"
    print("SUCCESS: Flask Test: get_2hp_model_result response valid.")

    get_methods = ["get_value_ranges", "get_2hp_field_shape", "get_highscore_and_name", "get_top_ten_list", "get_2hp_field_shape"]

    for get_method in get_methods:
        r = requests.get( url = localhost + get_method)
        assert r.status_code == 200, f"ERROR: {get_method} response code = {r.status_code}!"
        print(f"SUCCESS: Flask Test: {get_method} response valid.")


def test_installation():

    print("TESTING: Initialization")
    try:
        model_configuration = ModelConfiguration()
        print(f"SUCCESS: All datasets and models found! No errors whilst initializing.")
    except:
        traceback.print_exc()
        print("ERROR: Something went wrong while initializing the datasets and models.")
        return

    print("TESTING: Groundtruth methods")
    methods = ["closest", "interp_quad_heuristic", "interp_seq_heuristic", "interp_min"]
    for method in methods:
        try:
            test_groundtruth(2, 2, visualize=False, type=method, print_all=False)
            print(f"SUCCESS: Groundtruth generation {method} did not fail.")
        except:
            traceback.print_exc()
            print(f"ERROR: Groundtruth generation {method} and comparison failed!")
            return
        
    print("TESTING: 1HP model response")
    try:
        test_1hp_model_communication(visualize=False)
    except:
        traceback.print_exc()
        print("ERROR: 1HP Model communication failed!")
        return
    
    print("TESTING: 2HP model response")
    try:
        test_2hp_model_communication(visualize=False)
    except:
        traceback.print_exc()
        print("ERROR: 2HP Model communication failed!")
        return
    
    print("RESULT: Tests successful!")


def measure_performance(n_runs: int, visualize: bool):
    test_groundtruth(0, n_runs - 1, visualize=visualize, type="interp_seq_heuristic", print_all=False)
    test_groundtruth(0, n_runs - 1, visualize=visualize, type="interp_min", print_all=False)
    test_groundtruth(0, n_runs - 1, visualize=visualize, type="interp_quad_heuristic", print_all=False)
    test_groundtruth(0, n_runs - 1, visualize=visualize, type="closest", print_all=False)


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "-t":
        if sys.argv[2] == "installation": test_installation()
        if sys.argv[2] == "server": test_flask_interface()
    elif len(sys.argv) >= 3 and sys.argv[1] == "-m":
        N = int(sys.argv[2])
        if len(sys.argv) == 3:
            measure_performance(N, False)
        elif len(sys.argv) == 4 and sys.argv[3] == "-v":
            measure_performance(N, True)
        else:
            print(f"Did you mean: test.py -m {N} -v")
    else:
        print("Invalid arguments! Try the following:")
        print(" - Measure Groundtruth: test.py -m <N> (-v)")
        print("   - <N>: Number of measured datapoints: 0,...,N-1")
        print("   - -v: Show results")
        print(" - Test functionality:  test.py -t <Method>")
        print("   - <Method>: server, installation")
   
    
if __name__ == "__main__":
    main()
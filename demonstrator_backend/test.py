import time
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
import numpy as np
import os
from mpl_toolkits.axes_grid1 import make_axes_locatable
from tqdm.auto import tqdm
import random
import requests
from groundtruth_data import GroundTruthInfo, DataPoint, load_temperature_field
import generate_groundtruth as gt
import model_communication as mc
import csv

def show_figure(figure: Figure):
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = figure
    figure.set_canvas(canvas_manager.canvas)
    plt.show()


def add_plot_info(image, title):
    axis = plt.gca()
    plt.colorbar(image, cax = make_axes_locatable(axis).append_axes("right", size="5%", pad=0.05))
    axis.xaxis.set_label_position('top')
    axis.set_xlabel(title, fontsize='small')


def test_groundtruth(n_from, n_to, type = "interp_heuristic", visualize=True, print_all=True):

    model_configuration = mc.ModelConfiguration()

    info = model_configuration.groundtruth_info
    info.visualize = visualize

    average_error_ges = 0
    successful_runs = 0

    with open(f'performance_{type}.csv', 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        csv_writer.writerow(["average_error", "min_error", "max_error", "time"])

        for i in tqdm(range(n_from, n_to+1), desc=f"Testen type='{type}'", total=n_to-n_from, disable=print_all):
            x = info.datapoints[i]
            info.datapoints[i] = None

            if type == "interp_heuristic":
                average_error, min_error, max_error, time = test_interpolation_groundtruth(info, x, i, gt.find_heuristic_triangle)
            elif type == "interp_min":
                average_error, min_error, max_error, time = test_interpolation_groundtruth(info, x, i, gt.find_minimal_triangle)
            elif type == "interp_old_triangle":
                average_error, min_error, max_error, time = test_interpolation_groundtruth(info, x, i, gt.find_old_triangle)
            elif type == "closest":
                average_error, min_error, max_error, time = test_closest_groundtruth(info, x, i)
            else:
                print("Interpolationstyp existiert nicht")
                break

            if not time == np.inf: csv_writer.writerow([average_error, min_error, max_error, time])

            if not average_error == None:
                average_error_ges += average_error
                successful_runs += 1
            info.datapoints[i] = x

            if print_all: 
                print(f"Datenpunkt {i : <2}: av = {str(average_error) + ',' : <23} min = {str(min_error) + ',' : <23} max = {str(max_error) + ',' : <23}")
    
    print(f"Erfolgreiche Durchläufe: {successful_runs},  Gesamtergebnis: {average_error_ges / successful_runs}")


def test_interpolation_groundtruth(info: GroundTruthInfo, x: DataPoint, i: int, find_triangle):

    min_error = None
    max_error = None
    average_error = None

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

    return average_error, min_error, max_error, b-a
        

def test_closest_groundtruth(info: gt.GroundTruthInfo, x: gt.DataPoint, i: int):

    a = time.perf_counter()

    j = gt.get_closest_point(x, info.datapoints)
    closest_result = load_temperature_field(info, j)

    b = time.perf_counter()

    true_result = load_temperature_field(info, i)
    error = np.abs(np.array(true_result) - np.array(closest_result))
            
    max_temp = np.max(true_result)
    average_error = np.average(error)
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

    return average_error, min_error, max_error, b-a


def test_1hp_model_communication(visualize=True):
    st1 = time.time()
    model_configuration = mc.ModelConfiguration()
    et1 = time.time()

    k = 7.350276541753949086e-10
    p = -2.142171334025262316e-03

    st2 = time.time()
    return_data = mc.get_1hp_model_results(model_configuration, k, p)
    et2 = time.time()
    
    print('Initialisierung:', et1 - st1, 'seconds')
    print('Antwortzeit:', et2 - st2, 'seconds')
    print('Gesamtzeit:', et2 - st2 + et1 - st1, 'seconds')

    print(f"Error: {return_data.get_return_value('average_error')}")

    if visualize:
        show_figure(return_data.get_figure("model_result"))


def test_2hp_model_communication(visualize=True):
    st1 = time.time()
    model_configuration = mc.ModelConfiguration()
    et1 = time.time()


    k = 1.053944076782911543e-09
    p = -3.040452194657028689e-03
    
    max_x = model_configuration.model_2hp_info["OutFieldShape"][0]
    max_y = model_configuration.model_2hp_info["OutFieldShape"][1]
    pos = [random.randint(0, max_x), random.randint(0, max_y)]

    st2 = time.time()
    return_data = mc.get_2hp_model_results(model_configuration, k, p, pos)
    et2 = time.time()
    
    print('Initialisierung:', et1 - st1, 'seconds')
    print('Antwortzeit:', et2 - st2, 'seconds')
    print('Gesamtzeit:', et2 - st2 + et1 - st1, 'seconds')

    if visualize:
        show_figure(return_data.get_figure("model_result"))


def test_flask_interface():
    localhost = "http://127.0.0.1:5000/"

    r = requests.post(url = localhost + "get_model_result",     json ={"permeability": 1e-9, "pressure": -1e-3, "name": "test.py"})
    assert r.status_code == 200, f"ERROR: get_model_result response code = {r.status_code}"

    r = requests.post(url = localhost + "get_2hp_model_result", json = {"permeability": 1e-9, "pressure": -1e-3, "pos": [10, 10]})
    assert r.status_code == 200, f"ERROR: get_2hp_model_result response code = {r.status_code}"

    r = requests.get( url = localhost + "get_value_ranges")
    assert r.status_code == 200, f"ERROR: get_value_ranges response code = {r.status_code}"

    r = requests.get( url = localhost + "get_2hp_field_shape")
    assert r.status_code == 200, f"ERROR: get_2hp_field_shape response code = {r.status_code}"

    r = requests.get( url = localhost + "get_highscore_and_name")
    assert r.status_code == 200, f"ERROR: get_highscore_and_name response code = {r.status_code}"


def test_all():
    try:
        test_flask_interface()
    except:
        raise Exception("Flask app response not valid!")
    try:
        test_groundtruth(0, 0, visualize=False, type="closest", print_all=False)
        test_groundtruth(2, 2, visualize=False, type="interpolation", print_all=False)
    except:
        raise Exception("Groundtruth generation and comparison failed!")
    try:
        test_1hp_model_communication(visualize=False)
    except:
        raise Exception("1HP Model communication failed!")
    try:
        test_2hp_model_communication(visualize=False)
    except:
        raise Exception("2HP Model communication failed!")
    print("Tests successful!")


def main():
    test_groundtruth(0, 100, visualize=False, type="interp_heuristic", print_all=False)
    test_groundtruth(0, 100, visualize=False, type="interp_min", print_all=False)
    test_groundtruth(0, 100, visualize=False, type="interp_old_triangle", print_all=False)
    test_groundtruth(0, 100, visualize=False, type="closest", print_all=False)

if __name__ == "__main__":
    # test_all()
    main()
import time
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
import model_communication as mc
import generate_groundtruth as gt
import numpy as np
import os
from mpl_toolkits.axes_grid1 import make_axes_locatable


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


def test_groundtruth(range, type = "interpolation", visualize=True):

    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = gt.GroundTruthInfo(path_to_dataset, 10.6)
    info.visualize = visualize

    average_error_ges = 0
    successful_runs = 0

    for i in range:
        x = info.datapoints[i]
        info.datapoints[i] = None

        if type == "interpolation":
            average_error, min_error, max_error = test_interpolation_groundtruth(info, x, i)
        elif type == "closest":
            average_error, min_error, max_error = test_closest_groundtruth(info, x, i)
        else:
            print("Interpolationstyp existiert nicht")
            break

        if not average_error == None:
            average_error_ges += average_error
            successful_runs += 1
        info.datapoints[i] = x

        print(f"Datenpunkt {i : <2}: av = {str(average_error) + ',' : <23} min = {str(min_error) + ',' : <23} max = {str(max_error) + ',' : <23}")
    
    print(f"Erfolgreiche Durchläufe: {successful_runs},  Gesamtergebnis: {average_error_ges / successful_runs}")


def test_interpolation_groundtruth(info: gt.GroundTruthInfo, x: gt.DataPoint, i: int):

    min_error = None
    max_error = None
    average_error = None

    triangle_i = gt.triangulate_data_point(info, x)
    if isinstance(triangle_i, list):
        weights = gt.calculate_barycentric_weights(info, triangle_i, x)
        interp_result = gt.interpolate_experimental(info, triangle_i, weights)
        closest_result = gt.load_temperature_field(info, triangle_i[0])

        true_result = gt.load_temperature_field(info, i)
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
                interpolant = gt.load_temperature_field(info, triangle_i[j])
                image = plt.imshow(interpolant, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
                add_plot_info(image, f"Interpolant: {j},  Gewicht: {weights[j]},  Nummer: {triangle_i[j]}")

            plt.sca(axes[3])
            image = plt.imshow(interp_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
            add_plot_info(image, f"Interpolation,  Nummer: {i}")

            plt.sca(axes[4])
            image = plt.imshow(true_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
            add_plot_info(image, f"Echtes Ergebnis,  Nummer: {i}")

            plt.sca(axes[5])
            image = plt.imshow(error, cmap="RdBu_r", vmin=0, vmax=vmax)
            add_plot_info(image, f"Interpolationsfehler,  Durchschnittlich: {average_error} °C,  Nummer: {i}")

            plt.sca(axes[6])
            image = plt.imshow(error_closest, cmap="RdBu_r", vmin=0, vmax=vmax)
            add_plot_info(image, f"Fehler nächster Punkt,  Durchschnittlich: {np.average(error_closest)} °C,  Nummer: {i}")

            plt.show()

    return average_error, min_error, max_error
        

def test_closest_groundtruth(info: gt.GroundTruthInfo, x: gt.DataPoint, i: int):

    j = gt.get_closest_point(x, info.datapoints)

    closest_result = gt.load_temperature_field(info, j)
    true_result = gt.load_temperature_field(info, i)
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

    return average_error, min_error, max_error   


def test_model_communication():
    st1 = time.time()
    model_communication = mc.ModelCommunication()
    et1 = time.time()
    print('Initialisierung:', et1 - st1, 'seconds')

    k = 3.1e-10
    p = -2.1e-03

    st2 = time.time()
    model_communication.update_1hp_model_results(k, p)
    et2 = time.time()
    print('Antwortzeit:', et2 - st2, 'seconds')
    print('Gesamtzeit:', et2 - st2 + et1 - st1, 'seconds')

    show_figure(model_communication.figures.get_figure(0))

test_model_communication()
# test_groundtruth(range(35, 40), type="closest", visualize=False)
# test_groundtruth(range(0, 100), type="interpolation", visualize=True)
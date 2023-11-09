import time
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
import model_communication as mc
import generate_groundtruth as gt
import numpy as np
import os

def show_figure(figure: Figure):
    managed_fig = plt.figure()
    canvas_manager = managed_fig.canvas.manager
    canvas_manager.canvas.figure = figure
    figure.set_canvas(canvas_manager.canvas)
    plt.show()


def test_ground_truth():
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = gt.GroundTruthInfo(path_to_dataset, 10.6)

    for i in range(100):

        x = info.datapoints[i]
        info.datapoints[i] = None

        st = time.time()

        triangle_i = gt.triangulate_data_point(info, x)
        if isinstance(triangle_i, list):
            weights = gt.calculate_barycentric_weights(info, triangle_i, x)
            interp_result = gt.interpolate_experimental(info, triangle_i, weights)

            et = time.time()

            true_result = gt.load_temperature_field(info, i)
            max_temp = np.max(true_result)
            
            error = np.abs(np.array(true_result) - np.array(interp_result))
            average_error = np.average(error)
            print(f"Datenpunkt: {i}: {average_error}, Zeit: {et - st}s")
        
            if info.visualize:
                fig, axes = plt.subplots(3, 1, sharex=True)
                plt.sca(axes[0])
                plt.imshow(interp_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
                plt.sca(axes[1])
                plt.imshow(true_result, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
                plt.sca(axes[2])
                plt.imshow(error, cmap="RdBu_r", vmin=10.6, vmax=max_temp)
                plt.show()
        
        info.datapoints[i] = x
        


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


test_ground_truth()
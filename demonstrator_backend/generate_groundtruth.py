import os
import sys
import numpy as np
import torch
import matplotlib.pyplot as plt
from matplotlib.path import Path
from torch.utils.tensorboard import SummaryWriter
# tensorboard --logdir=runs/ --host localhost --port 8088

# Sollte mit Pfadspezifikation aus Notion funktionieren
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))

from data_stuff.dataset import SimulationDataset, _get_splits
from data_stuff.utils import SettingsTraining
from networks.unet import UNet
from preprocessing.prepare_1ststage import load_data, get_pflotran_settings
from utils.prepare_paths import set_paths_1hpnn, Paths1HP
from utils.visualization import plt_avg_error_cellwise, plot_sample
from utils.measurements import measure_loss, save_all_measurements
from main import run_from_demonstrator 
from main import init_data 


def show_isoline_graphs(run_index1, run_index2):
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    pflotran_settings = get_pflotran_settings(path_to_dataset)

    dp1_path = os.path.join(path_to_dataset, f"RUN_{run_index1}", "pflotran.h5")
    dp2_path = os.path.join(path_to_dataset, f"RUN_{run_index2}", "pflotran.h5")

    dims = np.array(pflotran_settings["grid"]["ncells"])
    print(f"dimensions = {dims}")

    extent_highs :tuple = (1280,100)
    extent = (0,int(extent_highs[0]),int(extent_highs[1]),0)
    T_gwf = 10.6
    contourargs = {"levels" : [np.round(T_gwf + 1, 1)], "cmap" : "Pastel1"}

    print(f"levels = {np.round(T_gwf + 1, 1)}")
    
    # https://stackoverflow.com/questions/1560424/how-can-i-get-the-x-y-values-of-the-line-that-is-plotted-by-a-contour-plot

    fig, axes = plt.subplots(4, 1, sharex=True)

    y1 = load_data(dp1_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
    y1 = y1["Temperature [C]"].detach().cpu().squeeze()
    plt.sca(axes[0])
    plt.imshow(y1, cmap="RdBu_r")
    plt.sca(axes[1])
    plt.contourf(y1, cmap="RdBu_r")

    y2 = load_data(dp2_path, "   4 Time  2.75000E+01 y", ["Temperature [C]"], dims)
    plt.sca(axes[2])
    y2 = y2["Temperature [C]"].detach().cpu().squeeze()
    plt.imshow(y2, cmap="RdBu_r")
    plt.sca(axes[3])
    plt.contourf(y2, cmap="RdBu_r")
    
    c2 = plt.contour(y2, levels=[np.round(T_gwf + 1, 1)])

    print(f"min = {torch.min(y2)}, max = {torch.max(y2)}")

    # c2.allsegs[Level][Segment der Linie falls unterbrochen][Punkt auf der Linie]
    # find_nearest_contour(x, y, indices=None, pixel=True) ???

    segments = c2.allsegs[0]


    for i, seg in enumerate(segments):
        plt.plot(seg[:,0], seg[:,1], '-', color='y', marker='.', label=i)

    plt.plot([segments[1][0][0], segments[1][-1][0]], [segments[0][-1][1], segments[1][0][1]], '-', color='r', marker='+', label=3)
    plt.show()


show_isoline_graphs(0, 4)
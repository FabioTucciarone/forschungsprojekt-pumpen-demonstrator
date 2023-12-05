import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
import generate_groundtruth as gt
import os

# i von oben nach unten, j von links nach rechts
def get_1st_derivative(it: int, jt: int , T: np.ndarray):
    h = 3/8
    # derivative it
    # at it-edge back (left)    --> forward derivative
    if it == 0:
        id = (T[it + 1, jt] - T[it, jt]) / h
    # at it-edge front (right)  --> backward derivative
    elif it == T.shape[0]-1: #Fehler
        id = (T[it, jt] - T[it - 1, jt]) / h
    # in the center             --> central derivative
    else:
        id = (T[it + 1, jt] - T[it - 1, jt]) / (2*h)

    # derivative jt
    # at jt-edge back (top)     --> forward derivative
    if jt == 0:
        jd = (T[it, jt + 1] - T[it, jt]) / h
    # at jt-edge front (bottom) --> backward derivative
    elif jt == T.shape[1]-1:
        jd = (T[it, jt] - T[it, jt - 1]) / h
    # in the center             --> central derivative
    else:
        jd = (T[it, jt + 1] - T[it, jt - 1]) / (2*h)

    return id, jd


def get_2nd_derivative(it: int, jt: int , T: np.ndarray):
    h = 1
    # derivative it
    # at it-edge back (left)    --> forward derivative
    if it == 0:
        id = (T[it + 2, jt] - 2*T[it + 1, jt] + T[it, jt]) / pow(h, 2)
    # at it-edge front (right)  --> backward derivative
    elif it == T.shape[0]-1:
        id = (T[it, jt] - 2 * T[it - 1, jt] + T[it - 2, jt]) / pow(h, 2)
    # in the center             --> central derivative
    else:
        id = (T[it + 1, jt] - 2*T[it, jt] + T[it - 1, jt]) / pow(h, 2)

    # derivative jt
    # at jt-edge back (top)     --> forward derivative
    if jt == 0:
        jd = (T[it, jt + 2] - 2*T[it, jt + 1] + T[it, jt]) / pow(h, 2)
    # at jt-edge front (bottom) --> backward derivative
    elif jt == T.shape[1]-1:
        jd = (T[it, jt] - 2 * T[it, jt - 1] + T[it, jt - 2]) / pow(h, 2)
    # in the center             --> central derivative
    else:
        jd = (T[it, jt + 1] - 2*T[it, jt] + T[it, jt - 1]) / pow(h, 2)
    return id, jd


def get_value(i: float, j: float, T: np.ndarray):
    m = T.shape[0]
    n = T.shape[1]

    i0: int # nächstgelegener i-Wert
    j0: int # nächstgelegener j-Wert 

    if -0.5 >= i:
        i0 = 0
    elif i >= m - 0.5:
        i0 = m-1
    else:
        i0 = int(round(i))

    if -0.5 >= j:
        j0 = 0
    elif j >= n - 0.5:
        j0 = n-1
    else:
        j0 = int(round(j))

    # Berechne erste und zweite Ableitung in (i0, j0) in beide Richtungen 
    # Zentraldifferenz 1. Abl.: (T[i0 + 1] - T[i0 - 1]) / 2
    # Zentraldifferenz 2. Abl.:  (T[i0 + 1] - 2 * T[i0] + T[i0 - 1]) / 1**2
    # Achtung am Rand! Verwende: Vorwärts- / Rückwärtsdifferenz? Zentraldifferenz in vorherigem Pixel? 
    #                            https://www.wikiwand.com/en/Finite_difference#Higher-order_differences

    id, jd = get_1st_derivative(i0, j0, T)
    idd, jdd = get_2nd_derivative(i0, j0, T)

    # Berechne Ergebnis mit Taylorsumme des zweiten Grades (also bis zur zweiten Ableitung)
    y = T[i0, j0] + (id*(i - i0) + jd*(j - j0)) + (1/2) * (idd*(i - i0) + jdd*(j - j0)) # Taylor Ergebnis

    return max(y, 10.6), id, jd, idd, jdd

def main():

    fig, axes = plt.subplots(6, 1)
    plt.sca(axes[0])

    run_idx = 2
    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = gt.GroundTruthInfo(path_to_dataset, 10.6)
    T0 = gt.load_temperature_field(info, run_idx)

    T1 = [np.ndarray((T0.shape[0] + 30, T0.shape[1] + 30)),
          np.ndarray(T0.shape),
          np.ndarray(T0.shape),
          np.ndarray(T0.shape),
          np.ndarray(T0.shape)]
    
    for i in range(-15, T0.shape[0] + 15):
        for j in range(-15, T0.shape[1] + 15):
            y, id, jd, idd, jdd = get_value(i, j, T0)
            T1[0][i + 15, j + 15] = y
            if i >= 0 and i < T0.shape[0] and j >= 0 and j < T0.shape[1]: 
                T1[1][i, j] = id
                T1[2][i, j] = jd
                T1[3][i, j] = idd
                T1[4][i, j] = jdd


    plt.sca(axes[0])
    image = plt.imshow(T0, cmap="RdBu_r", vmin=10.6, vmax=15)
    plt.colorbar(image, cax = make_axes_locatable(axes[0]).append_axes("right", size="5%", pad=0.05))

    for i in range(0, 5):
        plt.sca(axes[i+1])
        image = plt.imshow(T1[i], cmap="RdBu_r")
        plt.colorbar(image, cax = make_axes_locatable(axes[i+1]).append_axes("right", size="5%", pad=0.05))


    plt.show()

main()
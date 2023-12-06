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

"""
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


def get_2nd_derivative(it: int, jt: int , T: np.ndarray):
    h = 1
    #delta_i = h + it
    #delta_j = h + jt
    delta_i = 1
    delta_j = 1
    # derivative it
    # at it-edge back (left)    --> forward derivative
    if it == 0:
        id = (2*T[it, jt]-5*T[it+delta_i,jt]+4*T[it+2*delta_i,jt]-T[it+3*delta_i,jt])/pow(h+it,3)
    # at it-edge front (right)  --> backward derivative
    elif it == T.shape[0]-1:
        id = (2*T[it, jt]-5*T[it-delta_i,jt]+4*T[it-2*delta_i,jt]-T[it-3*delta_i,jt])/pow(h+it,3)
    # in the center             --> central derivative
    else:
        id = (T[it+delta_i,jt]-2*T[it,jt]+T[it-delta_i,jt])/pow(h+it,2)

    # derivative jt
    # at jt-edge back (top)     --> forward derivative
    if jt == 0:
        jd = (2*T[it, jt]-5*T[it,jt+delta_j]+4*T[it,jt+2*delta_j]-T[it,jt+3*delta_j])/pow(h+jt,3)
    # at jt-edge front (bottom) --> backward derivative
    elif jt == T.shape[1]-1:
        jd = (2*T[it, jt]-5*T[it,jt-delta_j]+4*T[it,jt-2*delta_j]-T[it,jt-3*delta_j])/pow(h+jt,3)
    # in the center             --> central derivative
    else:
        jd = (T[it,jt+delta_j]-2*T[it,jt]+T[it,jt-delta_j])/pow(h+jt,2)
    return id, jd
"""
    

def get_2nd_derivative(it: int, jt: int , T: np.ndarray):
    h = 1
    #delta_i = h + it
    #delta_j = h + jt
    # derivative it
    # at it-edge back (left)    --> forward derivative
    if it == 0:
        id = (2*T[it, jt]-5*T[it+h,jt]+4*T[it+h,jt]-T[it+h,jt])/pow(h,3)
    # at it-edge front (right)  --> backward derivative
    elif it == T.shape[0]-1:
        id = (2*T[it, jt]-5*T[it-h,jt]+4*T[it-h,jt]-T[it-h,jt])/pow(h,3)
    # in the center             --> central derivative
    else:
        id = (T[it+h,jt]-2*T[it,jt]+T[it-h,jt])/pow(h,2)

    # derivative jt
    # at jt-edge back (top)     --> forward derivative
    if jt == 0:
        jd = (2*T[it, jt]-5*T[it,jt+h]+4*T[it,jt+h]-T[it,jt+h])/pow(h,3)
    # at jt-edge front (bottom) --> backward derivative
    elif jt == T.shape[1]-1:
        jd = (2*T[it, jt]-5*T[it,jt-h]+4*T[it,jt-h]-T[it,jt-h])/pow(h,3)
    # in the center             --> central derivative
    else:
        jd = (T[it,jt+h]-2*T[it,jt]+T[it,jt-h])/pow(h,2)
    return id, jd


def get_value(i: float, j: float, T: np.ndarray):
    m = T.shape[0]
    n = T.shape[1]

    i0: int # nächstgelegener i-Wert
    j0: int # nächstgelegener j-Wert 

    if -0.5 >= i:
        #i0 = 0
        i0 = m-1
    elif i >= m - 0.5:
        #i0 = m-1
        i0 = 0
    else:
        i0 = int(round(i))

    if -0.5 >= j:
        #j0 = 0
        j0 = n-1
    elif j >= n - 0.5:
        #j0 = n-1
        j0 = 0
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

    #return max(y, 10.6)
    # TODO Ecken stimmen nicht
    return jdd

def main():

    fig, axes = plt.subplots(2, 1)
    plt.sca(axes[0])

    zahl = 2

    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = gt.GroundTruthInfo(path_to_dataset, 10.6)
    T = gt.load_temperature_field(info, zahl)
    y = np.ndarray((T.shape[0] + 30, T.shape[1] + 30))
    for i in range(-15, T.shape[0] + 15):
        for j in range(-15, T.shape[1] + 15):
            y[i+15, j+15] = get_value(i, j, T)
    image = plt.imshow(T, cmap="RdBu_r", vmin=10.6, vmax=15)

    axis = plt.gca()
    plt.colorbar(image, cax = make_axes_locatable(axis).append_axes("right", size="5%", pad=0.05))
    axis.xaxis.set_label_position('top')
    axis.set_xlabel("taylor", fontsize='small')

    plt.sca(axes[1])
    image = plt.imshow(y, cmap="RdBu_r")#, vmin=10.6, vmax=15)

    axis = plt.gca()
    plt.colorbar(image, cax = make_axes_locatable(axis).append_axes("right", size="5%", pad=0.05))
    axis.xaxis.set_label_position('top')
    axis.set_xlabel("taylor", fontsize='small')


    plt.show()

main()
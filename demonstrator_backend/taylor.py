import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
import generate_groundtruth as gt
import os
import cv2 #Filter, pip install opencv-python

h = 1/3

# i von oben nach unten, j von links nach rechts
def get_1st_derivative(it: int, jt: int , T: np.ndarray):
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

def get_2nd_derivative_filter(it: int, jt: int , T: np.ndarray):
    # derivative it
    # at it-edge back (left)    --> forward derivative
    if it == 0:
        id = (get_value_by_filter(it + 2, jt, T) - 2*get_value_by_filter(it+1, jt, T) + get_value_by_filter(it, jt, T)) / pow(h, 2)
    # at it-edge front (right)  --> backward derivative
    elif it == T.shape[0]-1:
        id = (get_value_by_filter(it, jt, T) - 2 * get_value_by_filter(it-1, jt, T) + get_value_by_filter(it-2, jt, T)) / pow(h, 2)
    # in the center             --> central derivative
    else:
        id = (get_value_by_filter(it+1, jt, T) - 2*get_value_by_filter(it, jt, T) + get_value_by_filter(it-1, jt, T)) / pow(h, 2)

    # derivative jt
    # at jt-edge back (top)     --> forward derivative
    if jt == 0:
        jd = (get_value_by_filter(it, jt+2, T) - 2*get_value_by_filter(it, jt+1, T) + get_value_by_filter(it, jt, T)) / pow(h, 2)
    # at jt-edge front (bottom) --> backward derivative
    elif jt == T.shape[1]-1:
        jd = (get_value_by_filter(it, jt, T) - 2 * get_value_by_filter(it, jt-1, T) + get_value_by_filter(it, jt-2, T)) / pow(h, 2)
    # in the center             --> central derivative
    else:
        jd = (get_value_by_filter(it, jt+1, T) - 2*get_value_by_filter(it, jt, T) + get_value_by_filter(it, jt-1, T)) / pow(h, 2)
    return id, jd

def get_2nd_derivative_higher_order(it: int, jt: int , T: np.ndarray):
    # derivative it
    # at it-edge back (left)    --> forward derivative
    if it == 0:
        id = (2*T[it, jt]-5*T[it+1,jt]+4*T[it+2,jt]-T[it+3,jt])/pow(h,3)
    # at it-edge front (right)  --> backward derivative
    elif it == T.shape[0]-1:
        id = (2*T[it, jt]-5*T[it-1,jt]+4*T[it-2,jt]-T[it-3,jt])/pow(h,3)
    # in the center             --> central derivative
    else:
        id = (T[it+1,jt]-2*T[it,jt]+T[it-1,jt])/pow(h,2)

    # derivative jt
    # at jt-edge back (top)     --> forward derivative
    if jt == 0:
        jd = (2*T[it, jt]-5*T[it,jt+1]+4*T[it,jt+2]-T[it,jt+3])/pow(h,3)
    # at jt-edge front (bottom) --> backward derivative
    elif jt == T.shape[1]-1:
        jd = (2*T[it, jt]-5*T[it,jt-1]+4*T[it,jt-2]-T[it,jt-3])/pow(h,3)
    # in the center             --> central derivative
    else:
        jd = (T[it,jt+1]-2*T[it,jt]+T[it,jt-1])/pow(h,2)
    return id, jd


def get_value(i: float, j: float, T: np.ndarray, method: int = 0):
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
    if method == 1:
        idd, jdd = get_2nd_derivative(i0, j0, T)
    elif method == 1:
        idd, jdd = get_2nd_derivative_filter(i0, j0, T)
    else:
        idd, jdd = get_2nd_derivative_higher_order(i0, j0, T)
    

    # Berechne Ergebnis mit Taylorsumme des zweiten Grades (also bis zur zweiten Ableitung)
    y = T[i0, j0] + (id*(i - i0)*h + jd*(j - j0)*h) + (1/2) * (idd*(i - i0)*h + jdd*(j - j0)*h) # Taylor Ergebnis

    #return max(y, 10.6)
    # TODO Ecken stimmen nicht
    return max(y, 10.6), id, jd, idd, jdd

def get_value_by_filter(i: float, j: float, T: np.ndarray):
    m = T.shape[0]
    n = T.shape[1]
    result = 0
    if i == 0:
        if j == 0:
            result = (1/3)*(T[i,j]+T[i,j+1]+T[i+1,j])
        elif j == n-1:
            result = (1/3)*(T[i,j]+T[i,j-1]+T[i+1,j])
        else:
            result = (1/4)*(T[i,j]+T[i,j-1]+T[i,j+1]+T[i+1,j])
    elif i == m-1:
        if j == 0:
            result = (1/3)*(T[i,j]+T[i,j+1]+T[i-1,j])
        elif j == n-1:
            result = (1/3)*(T[i,j]+T[i,j-1]+T[i-1,j])
        else:
            result = (1/4)*(T[i,j]+T[i,j-1]+T[i,j+1]+T[i-1,j])
    else:
        if j == 0:
            result = (1/4)*(T[i,j]+T[i, j+1]+T[i-1,j]+T[i+1,j])
        elif j == n-1:
            result = (1/4)*(T[i,j]+ T[i, j-1]+ T[i-1,j]+T[i+1,j])
        else:
            result = (1/5)*(T[i,j]+T[i-1,j]+T[i+1,j]+T[i,j-1]+T[i,j+1])
    return result


    """
    kernel = np.ndarray([1,2,1],
                        [2,4,2],
                        [1,2,1])
    for m in range(0, T.shape[0]):
        for n in range(0, T.shape[1]):
            image_buffer[m,n] = T[m,n] #cv2.imread('image.jpg') | r1 = image[:,:,0] # get blue channel | g1 = image[:,:,1] # get green channel | b1 = image[:,:,2] # get red channel

    result = cv2.filter2D(image_buffer, -1, kernel) #def filter2D(src: UMat, ddepth: int, kernel: UMat, dst: UMat | None = ..., anchor: cv2.typing.Point = ..
    return result[i,j]
    """

def main():
    for method in range(3):
        fig, axes = plt.subplots(6, 1)
        plt.sca(axes[0])

        run_index = 1 # Superzahl 2

        path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
        info = gt.GroundTruthInfo(path_to_dataset, 10.6)
        T0 = gt.load_temperature_field(info, run_index)
        size = (T0.shape[0] + 30, T0.shape[1] + 30)

        T1 = [np.ndarray(size) for i in range(5)]

        for i in range(-15, T0.shape[0] + 15):
            for j in range(-15, T0.shape[1] + 15):
                y, id, jd, idd, jdd = get_value(i, j, T0, method = method)
                T1[0][i+15, j+15] = y 
                T1[1][i+15, j+15] = id 
                T1[2][i+15, j+15] = jd 
                T1[3][i+15, j+15] = idd 
                T1[4][i+15, j+15] = jdd
        

        plt.sca(axes[0])
        image = plt.imshow(T0, cmap="RdBu_r", vmin=10.6, vmax=15)
        plt.colorbar(image, cax = make_axes_locatable(axes[0]).append_axes("right", size="5%", pad=0.05))

        plt.sca(axes[1])
        image = plt.imshow(T1[0], cmap="RdBu_r", vmin=10.6, vmax=15)
        plt.colorbar(image, cax = make_axes_locatable(axes[1]).append_axes("right", size="5%", pad=0.05))

        for i in range(1,5):
            plt.sca(axes[i + 1])
            r = np.max(np.abs(T1[i]))
            image = plt.imshow(T1[i], cmap="RdBu_r", vmin=-r, vmax=r)
            plt.colorbar(image, cax = make_axes_locatable(axes[i + 1]).append_axes("right", size="5%", pad=0.05))

        plt.show()

main()
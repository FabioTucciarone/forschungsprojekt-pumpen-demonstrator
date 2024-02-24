import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
from scipy.interpolate import RectBivariateSpline
import numpy as np
import os

from groundtruth_data import DatasetInfo, load_temperature_field


class TemperatureField:
    info: DatasetInfo
    T: np.ndarray

    def __init__(self, info: DatasetInfo, run_index: int=None):
        if run_index == None:
            self.T = np.ndarray((info.dims[0], info.dims[1]))
        else:
            self.T = load_temperature_field(info, run_index)
        self.info = info

    def at(self, i: float, j: float):
        pass

    def set(self, i: int, j: int, value: float):
        self.T[i][j] = value


class PolyInterpolatedField(TemperatureField):
    interp: RectBivariateSpline
    max: float

    def __init__(self, info: DatasetInfo, run_index: int=None):
        TemperatureField.__init__(self, info, run_index)
        X = list(range(info.dims[0]))
        Y = list(range(info.dims[1]))
        self.interp = RectBivariateSpline(X, Y, self.T, kx=3, ky=3)

    def at(self, i: float, j: float):
        return max(10.6, self.interp(i,j))

    def interpolate_inner_pixel(self, x: float, y: float):
        x1 = int(np.floor(x)) 
        y1 = int(np.floor(y))
        x2 = int(np.ceil(x)) 
        y2 = int(np.ceil(y))

        if y1 == y2 and x1 == x2:
            return self.T[x1, y1]

        if x1 == x2:
            return self.T[x1, y1] * (y2 - y) / (y2 - y1) + self.T[x1, y2] * (y - y1) / (y2 - y1)

        if y1 == y2:
            return self.T[x1, y1] * (x2 - x) / (x2 - x1) + self.T[x2, y1] * (x - x1) / (x2 - x1)

        d = (x2 - x1) * (y2 - y1)
        w11 = (x2 - x) * (y2 - y) / d
        w12 = (x2 - x) * (y - y1) / d
        w21 = (x - x1) * (y2 - y) / d
        w22 = (x - x1) * (y - y1) / d

        return w11 * self.T[x1, y1] + w12 * self.T[x1, y2] + w21 * self.T[x2, y1] + w22 * self.T[x2, y2]
    

class TaylorInterpolatedField(TemperatureField):
    h = 1
    
    def __init__(self, info: DatasetInfo, run_index: int=None):
        TemperatureField.__init__(self, info, run_index)
        self.h = 1/(self.T.shape[1] + 1)


    def filter(self, i: float, j: float):
        T = self.T
        m = T.shape[0]
        n = T.shape[1]

        if i == 0:
            if j == 0:     result = 1/3 * (T[i,j] + T[i,j+1] + T[i+1,j])
            elif j == n-1: result = 1/3 * (T[i,j] + T[i,j-1] + T[i+1,j])
            else:          result = 1/4 * (T[i,j] + T[i,j-1] + T[i,j+1] + T[i+1,j])
        elif i == m-1:
            if j == 0:     result = 1/3 * (T[i,j] + T[i,j+1] + T[i-1,j])
            elif j == n-1: result = 1/3 * (T[i,j] + T[i,j-1] + T[i-1,j])
            else:          result = 1/4 * (T[i,j] + T[i,j-1] + T[i,j+1] + T[i-1,j])
        else:
            if j == 0:     result = 1/4 * (T[i,j] + T[i, j+1] + T[i-1,j] + T[i+1,j])
            elif j == n-1: result = 1/4 * (T[i,j] + T[i, j-1] + T[i-1,j] + T[i+1,j])
            else:          result = 1/5 * (T[i,j] + T[i-1,j] + T[i+1,j] + T[i,j-1] + T[i,j+1])
        
        return result

    def get_1st_derivative(self, it: int, jt: int):
        T = self.T
        h = self.h
        m = T.shape[0]
        n = T.shape[1]

        if it == 0:     id = (T[it+1, jt] - T[it, jt])   / h
        elif it == m-1: id = (T[it, jt]   - T[it-1, jt]) / h
        else:           id = (T[it+1, jt] - T[it-1, jt]) / (2*h)

        if jt == 0:     jd = (T[it, jt+1] - T[it, jt])   / h
        elif jt == n-1: jd = (T[it, jt]   - T[it, jt-1]) / h
        else:           jd = (T[it, jt+1] - T[it, jt-1]) / (2*h)

        return id, jd

    def get_1st_derivative_filter(self, it: int, jt: int):
        T = self.T
        h = self.h
        m = T.shape[0]
        n = T.shape[1]

        if it == 0:     id = (self.filter(it+1, jt) - self.filter(it, jt))   / h
        elif it == m-1: id = (self.filter(it, jt)   - self.filter(it-1, jt)) / h
        else:           id = (self.filter(it+1, jt) - self.filter(it-1, jt)) / (2*h)

        if jt == 0:     jd = (self.filter(it, jt+1) - self.filter(it, jt))   / h
        elif jt == n-1: jd = (self.filter(it, jt)   - self.filter(it, jt-1)) / h
        else:           jd = (self.filter(it, jt+1) - self.filter(it, jt-1)) / (2*h)

        return id, jd

    def get_2nd_derivative(self, it: int, jt: int):
        T = self.T
        h = self.h
        m = T.shape[0]
        n = T.shape[1]

        if it == 0:     id = (T[it+2, jt] - 2*T[it+1, jt] + T[it, jt])   / h**2
        elif it == m-1: id = (T[it, jt]   - 2*T[it-1, jt] + T[it-2, jt]) / h**2
        else:           id = (T[it+1, jt] - 2*T[it, jt]   + T[it-1, jt]) / h**2

        if jt == 0:     jd = (T[it, jt+2] - 2*T[it, jt+1] + T[it, jt])   / h**2
        elif jt == n-1: jd = (T[it, jt]   - 2*T[it, jt-1] + T[it, jt-2]) / h**2
        else:           jd = (T[it, jt+1] - 2*T[it, jt]   + T[it, jt-1]) / h**2

        return id, jd

    def get_2nd_derivative_filter(self, it: int, jt: int):
        T = self.T
        h = self.h
        m = T.shape[0]
        n = T.shape[1]

        if it == 0:     id = (self.filter(it+2, jt) - 2*self.filter(it+1, jt) + self.filter(it, jt)) / h**2
        elif it == m-1: id = (self.filter(it, jt)   - 2*self.filter(it-1, jt) + self.filter(it-2, jt)) / h**2
        else:           id = (self.filter(it+1, jt) - 2*self.filter(it, jt)   + self.filter(it-1, jt)) / h**2

        if jt == 0:     jd = (self.filter(it, jt+2) - 2*self.filter(it, jt+1) + self.filter(it, jt)) / h**2
        elif jt == n-1: jd = (self.filter(it, jt)   - 2*self.filter(it, jt-1) + self.filter(it, jt-2)) / h**2
        else:           jd = (self.filter(it, jt+1) - 2*self.filter(it, jt)   + self.filter(it, jt-1)) / h**2

        return id, jd

    def get_2nd_derivative_higher_order(self, it: int, jt: int):
        T = self.T
        h = self.h
        m = T.shape[0]
        n = T.shape[1]

        if it == 0:     id = (2*T[it, jt]   - 5*T[it+1, jt] + 4*T[it+2, jt] - T[it+3, jt]) / h**3
        elif it == m-1: id = (2*T[it, jt]   - 5*T[it-1, jt] + 4*T[it-2, jt] - T[it-3, jt]) / h**3
        else:           id = (  T[it+1, jt] - 2*T[it, jt]   +   T[it-1, jt]) / h**2

        if jt == 0:     jd = (2*T[it, jt]   - 5*T[it, jt+1] + 4*T[it, jt+2] - T[it, jt+3]) / h**3
        elif jt == n-1: jd = (2*T[it, jt]   - 5*T[it, jt-1] + 4*T[it, jt-2] - T[it, jt-3]) / h**3
        else:           jd = (  T[it, jt+1] - 2*T[it, jt]   +   T[it, jt-1]) / h**2

        return id, jd
    
    def get_values(self, i: float, j: float, method: int = 0, use_second_order: bool = False):
        T = self.T
        m = T.shape[0]
        n = T.shape[1]
        h = self.h

        i0: int # nächstgelegener i-Wert
        j0: int # nächstgelegener j-Wert 

        if -0.5 >= i: i0 = 0
        elif i >= m - 0.5: i0 = m-1
        else: i0 = int(round(i))

        if -0.5 >= j: j0 = 0
        elif j >= n - 0.5: j0 = n-1
        else: j0 = int(round(j))

        # Tij = np.diff(np.diff(T,0),1) / h**2
        # ijdd = Tij[min(i0, Tij.shape[0]-2), min(j0, Tij.shape[1]-2)]


        if method == 0:
            id, jd = self.get_1st_derivative(i0, j0)
        elif method == 1:
            id, jd = self.get_1st_derivative_filter(i0, j0)
        else:
            id, jd = self.get_1st_derivative(i0, j0)

        y = T[i0, j0] 
        y += (id * (i - i0)*h + jd * (j - j0)*h)

        if use_second_order:
            Tij = np.diff(np.diff(T,0),1) / h**2 # TODO: provisorisch und unschön
            ijdd = Tij[min(i0,254), min(j0,254)]
            if method == 0:
                idd, jdd = self.get_2nd_derivative(i0, j0)
            elif method == 1:
                idd, jdd = self.get_2nd_derivative_filter(i0, j0)
            else:
                idd, jdd = self.get_2nd_derivative_higher_order(i0, j0)
            y += 1/2 * (idd * (i - i0)**2 + 2 * ijdd * (j - j0)*(i - i0) + jdd * (j - j0)**2) * h**2 

        return max(y, 10.6)

    def at(self, i: float, j: float):
        return self.get_values(i, j)


def main():

    method = 0
    run_index = 2 # Superzahl 2
    use_second_order_derivatives = False

    names = { 0 : "Normal", 1 : "Filter", 2 : "Höhere Ordnung"}

    fig, axes = plt.subplots(6, 1)
    plt.sca(axes[0])

    path_to_dataset = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "datasets_raw", "datasets_raw_1000_1HP")
    info = DatasetInfo(path_to_dataset, 10.6)
    T0 = TaylorInterpolatedField(info, run_index)
    size = (T0.T.shape[0] + 30, T0.T.shape[1] + 30)

    T1 = [np.ndarray(size) for i in range(5)]

    for i in range(-15, T0.T.shape[0] + 15):
        for j in range(-15, T0.T.shape[1] + 15):
            y, id, jd, idd, jdd = T0.get_values(i, j, method=method, use_second_order=use_second_order_derivatives)
            T1[0][i+15, j+15] = y 
            T1[1][i+15, j+15] = id 
            T1[2][i+15, j+15] = jd 
            T1[3][i+15, j+15] = idd 
            T1[4][i+15, j+15] = jdd
        

    plt.sca(axes[0])
    plt.title(names[method] + (" (2. Abl)" if use_second_order_derivatives else " (1. Abl)"))
    image = plt.imshow(T0.T, cmap="RdBu_r", vmin=10.6, vmax=15)
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

if __name__ == "__main__":
    main()
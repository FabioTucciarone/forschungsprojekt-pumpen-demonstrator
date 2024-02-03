import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

def generate_boxplot(csv_file_name):
    data_csv = pd.read_csv(csv_file_name)
    average_error_dp = np.array(data_csv['average_error'])
    min_error_dp = np.array(data_csv['min_error'])
    max_error_dp = np.array(data_csv['max_error'])
    time_dp = np.array(data_csv['time'])

    plt.figure(figsize=(10, 3))
    plt.boxplot([average_error_dp, min_error_dp, max_error_dp], vert = False, widths=[0.6, 0.6, 0.6])
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.gca().set_yticklabels(['Rvaluereferenz', 'NRVO', 'kein NRVO'])
    plt.xlabel("Zeit in µs")
    plt.show()


import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

show_title = True

def generate_boxplot(csv_file_name, title):
    data_csv = pd.read_csv(csv_file_name)
    average_error_dp = np.array(data_csv['average_error'])
    min_error_dp = np.array(data_csv['min_error'])
    max_error_dp = np.array(data_csv['max_error'])
    time_dp = np.array(data_csv['time'])

    plt.figure(figsize=(10, 3))
    if show_title: plt.title(title)
    plt.boxplot([average_error_dp, min_error_dp, max_error_dp], vert = False, widths=[0.6, 0.6, 0.6])
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.gca().set_yticklabels(['Mittlerer Fehler', 'Min. Fehler', 'Max. Fehler'])
    plt.xlabel("Fehler in °C")
    plt.show()

    plt.figure(figsize=(10, 3))
    if show_title: plt.title(title)
    plt.boxplot(time_dp, vert = False)
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.xlabel("Zeit in s")
    plt.show()

def main():
    generate_boxplot("interp_heuristic.csv", "Heuristik+Taylor")
    generate_boxplot("interp_min.csv", "Min+Taylor")
    generate_boxplot("interp_triangle_old.csv", "Quadranten+Taylor")
    generate_boxplot("closest.csv", "Nächster")

if __name__ == "__main__":
    main()
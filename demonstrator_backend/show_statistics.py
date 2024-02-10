import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

def load_measurements():
    files = {}
    files["closest"] = pd.read_csv("measurements/performance_closest.csv")
    files["min"] = pd.read_csv("measurements/performance_interp_min.csv")
    files["seq_heuristic"] = pd.read_csv("measurements/performance_interp_seq_heuristic.csv")
    files["quad_heuristic"] = pd.read_csv("measurements/performance_interp_quad_heuristic.csv")
    return files

def generate_boxplot(show_title=True):
    try:
        files = load_measurements()
    except:
        print("First create measurements by running test.py -m <n>")

    method_names = ["Nächster", "Minimum", "Seq. Heuristik", "Quadr. Heuristik"]
    fields = ["average_error", "max_error", "time"]
    tick_distances = [0.01, 0.1, 0.05]

    for i, field in enumerate(fields):
        plt.figure(figsize=(10, 3))
        plt.grid(color='lightgray', linestyle='-', linewidth=0.5)

        data_frames = [files[method_name][field] for method_name in files.keys()]
        max_value = 0
        for data_frame in data_frames:
            max_value = max(max_value, np.max(data_frame))

        x_ticks = list(np.arange(0, max_value, tick_distances[i]))
        plt.gca().set_xticks(x_ticks)

        boxplot = plt.boxplot(data_frames, vert = False, showfliers=False)

        for median_line in boxplot['medians']:
            y = median_line.get_ydata()[0]
            x = median_line.get_xdata()[0]
            plt.text(x - max_value / 300, y - 0.2, np.round(x, decimals=5), size="small")
                
        if show_title: plt.title(field)
        plt.subplots_adjust(top=0.95, bottom=0.2)
        plt.gca().set_yticklabels(method_names)
        if field == "average_error" or field == "max_error":
            plt.xlabel("Fehler in °C")
        else:
            plt.xlabel("Zeit in s")
        plt.show()


def print_statistics():
    try:
        files = load_measurements()
    except:
        print("First create measurements by running test.py -m <n>")
    
    fields = ["average_error", "max_error", "time"]
    for method_name in files.keys():
        for field in fields:
            values = files[method_name][field]
            print(f"{field} of {method_name} method:")
            print(f" > mean = {values.mean()}")
            print(f" > median = {values.median()}")
            print(f" > std = {values.std()}")


def main():
    if len(sys.argv) == 2:
        if sys.argv[1] == "-boxplot":
            generate_boxplot(show_title=True)
        elif sys.argv[1] == "-print":
            print_statistics()
        else:
            print("Unknown argument. Try: -boxplot, -print")
    else:
        print("Invalid number of arguments! Try the following:")
        print(" show_statistics.py -boxplot")
        print(" show_statistics.py -print")


if __name__ == "__main__":
    main()
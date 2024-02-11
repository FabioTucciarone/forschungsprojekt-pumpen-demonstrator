import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import sys

def load_groundtruth_measurements():
    files = {}
    files["closest"] = pd.read_csv("measurements/performance_closest.csv")
    files["min"] = pd.read_csv("measurements/performance_interp_min.csv")
    files["seq_heuristic"] = pd.read_csv("measurements/performance_interp_seq_heuristic.csv")
    files["quad_heuristic"] = pd.read_csv("measurements/performance_interp_quad_heuristic.csv")
    fields = ["average_error", "max_error", "time"]
    tick_distances = [0.01, 0.1, 0.05]
    fig_size = (10, 3)
    return files, fields, tick_distances, fig_size


def load_1hp_response_measurements():
    data = pd.read_csv("measurements/performance_1hp.csv")
    fields = ["groundtruth", "prepare", "model", "total"]
    tick_distance = 0.05
    fig_size = (7, 3)
    return data, fields, tick_distance, fig_size


def load_2hp_response_measurements():
    data = pd.read_csv("measurements/performance_2hp.csv")
    fields = ["model_1hp", "model_2hp", "prepare", "total"]
    tick_distance = 0.01
    fig_size = (7, 3)
    return data, fields, tick_distance, fig_size


def generate_compare_datasets_boxplots(data: dict, fields: list, tick_distances: list, fig_size, show_title=False):

    for i, field in enumerate(fields):
        plt.figure(figsize=fig_size)
        plt.grid(color='lightgray', linestyle='-', linewidth=0.5)

        data_frames = [data[method_name][field] for method_name in data.keys()]
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
        plt.gca().set_yticklabels(data.keys())
        if field == "average_error" or field == "max_error":
            plt.xlabel("Fehler in °C")
        else:
            plt.xlabel("Zeit in s")
        plt.show()


def generate_dataset_boxplot(data: dict, fields: list, tick_distance: float, fig_size):

    plt.figure(figsize=fig_size)
    plt.grid(color='lightgray', linestyle='-', linewidth=0.5)

    data_frames = [data[field] for field in fields]
    max_value = 0
    for data_frame in data_frames:
        max_value = max(max_value, np.max(data_frame))

    x_ticks = list(np.arange(0, max_value, tick_distance))
    plt.gca().set_xticks(x_ticks)

    boxplot = plt.boxplot(data_frames, vert = False, showfliers=False)

    for median_line in boxplot['medians']:
        y = median_line.get_ydata()[0]
        x = median_line.get_xdata()[0]
        plt.text(x - max_value / 300, y - 0.2, np.round(x, decimals=5), size="small")
                
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.gca().set_yticklabels(fields)
    plt.xlabel("Zeit in s")
    plt.show()


def print_statistics(data: dict, fields: dict):
    
    for method_name in data.keys():
        for field in fields:
            values = data[method_name][field]
            print(f"{field} of {method_name} method:")
            print(f" > mean = {values.mean()}")
            print(f" > median = {values.median()}")
            print(f" > std = {values.std()}")


def main():
    if len(sys.argv) == 2:
        if sys.argv[1] == "-gt":
            try:
                data, fields, tick_distances, fig_size = load_groundtruth_measurements()
            except:
                print("Could not find measurements. Run test.py -m <number>.")
                return
            generate_compare_datasets_boxplots(data, fields, tick_distances, fig_size)
            print_statistics(data, fields)
        elif sys.argv[1] == "-time":
           
                data, fields, tick_distance, fig_size = load_1hp_response_measurements()
                generate_dataset_boxplot(data, fields, tick_distance, fig_size)

                data, fields, tick_distance, fig_size = load_2hp_response_measurements()
                generate_dataset_boxplot(data, fields, tick_distance, fig_size)
           
                print("Could not find measurements. Run test.py -m <number> on 'messung' branch.")
                return
        else:
            print("Unknown argument. Try: -gt, -time")
            return   
    else:
        print("Invalid number of arguments! Try the following:")
        print(" show_statistics.py -gt")
        print(" show_statistics.py -time")


if __name__ == "__main__":
    main()
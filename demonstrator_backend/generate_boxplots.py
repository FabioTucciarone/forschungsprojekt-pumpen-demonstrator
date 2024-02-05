import matplotlib.pyplot as plt
import pandas as pd
import numpy as np


def generate_boxplot(show_title=True):
    closest_csv = pd.read_csv("measurements/performance_closest.csv")
    interp_min_csv = pd.read_csv("measurements/performance_interp_min.csv")
    interp_heuristic_csv = pd.read_csv("measurements/performance_interp_seq_heuristic.csv")
    interp_old_triangle_csv = pd.read_csv("measurements/performance_interp_quad_heuristic.csv")

    fields = ["average_error", "max_error", "time"]
    tick_distances = [0.01, 0.1, 0.1]

    for i, field in enumerate(fields):
        plt.figure(figsize=(10, 3))
        plt.grid(color='lightgray', linestyle='-', linewidth=0.5)

        max_value = np.max(closest_csv)
        x_ticks = list(np.arange(0, max_value, tick_distances[i]))
        plt.gca().set_xticks(x_ticks)

        boxplot = plt.boxplot([closest_csv[field], interp_min_csv[field], interp_heuristic_csv[field], interp_old_triangle_csv[field]], vert = False, showfliers=False)
        
        if show_title: plt.title(field)
        plt.subplots_adjust(top=0.95, bottom=0.2)
        plt.gca().set_yticklabels(["Nächster", "Minimum", "Seq. Heuristik", "Quadr. Heuristik"])
        if field == "average_error" or field == "max_error":
            plt.xlabel("Fehler in °C")
        else:
            plt.xlabel("Zeit in s")
        plt.show()


def main():
    generate_boxplot(show_title=False)

if __name__ == "__main__":
    main()
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np


def generate_boxplot(show_title=True):
    closest_csv = pd.read_csv("measurements/performance_closest.csv")
    interp_min_csv = pd.read_csv("measurements/performance_interp_min.csv")
    interp_heuristic_csv = pd.read_csv("measurements/performance_interp_seq_heuristic.csv")
    interp_old_triangle_csv = pd.read_csv("measurements/performance_interp_quad_heuristic.csv")

    plt.figure(figsize=(10, 3))
    if show_title: plt.title("Mittlerer Fehler")
    plt.boxplot([closest_csv["average_error"], interp_min_csv["average_error"], interp_heuristic_csv["average_error"], interp_old_triangle_csv["average_error"]], vert = False, showfliers=False)
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.gca().set_yticklabels(["Nächster", "Minimum", "Seq. Heuristik", "Quadr. Heuristik"])
    plt.xlabel("Fehler in °C")
    plt.show()

    plt.figure(figsize=(10, 3))
    if show_title: plt.title("Maximaler Fehler")
    plt.boxplot([closest_csv["max_error"], interp_min_csv["max_error"], interp_heuristic_csv["max_error"], interp_old_triangle_csv["max_error"]], vert = False, showfliers=False)
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.gca().set_yticklabels(["Nächster", "Minimum", "Seq. Heuristik", "Quadr. Heuristik"])
    plt.xlabel("Fehler in °C")
    plt.show()

    plt.figure(figsize=(10, 3))
    if show_title: plt.title("Zeit")
    plt.boxplot([closest_csv["time"], interp_min_csv["time"], interp_heuristic_csv["time"], interp_old_triangle_csv["time"]], vert = False, showfliers=False)
    plt.subplots_adjust(top=0.95, bottom=0.2)
    plt.gca().set_yticklabels(["Nächster", "Minimum", "Seq. Heuristik", "Quadr. Heuristik"])
    plt.xlabel("Zeit in s")
    plt.show()


def main():
    generate_boxplot(show_title=False)

if __name__ == "__main__":
    main()
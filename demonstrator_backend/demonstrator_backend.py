from flask import Flask, request, jsonify, redirect, url_for, Response
import io
import os
import sys
import random
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from dataclasses import dataclass
import yaml
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "1HP_NN"))
import preprocessing.prepare_1ststage as prepare

app = Flask(__name__)

# Bilder kodieren und zusammen zurückschicken? Oder: Daten Senden und dann Bilder einzeln abfragen?
# Vorerst einzeln!

last_groundtruth_bytes: bytes
last_model_result_bytes: bytes
last_error_measure_bytes: bytes

@dataclass
class Paths1HP:
    raw_dir: str # boxes
    datasets_prepared_dir: str
    dataset_1st_prep_path: str

@app.route('/send_input',methods = ['POST'])
def send_input():
    """
    Send the input values and "await" the response in Flutter.
    Then: Request the resulting images using the Image-Widget
          Image.network('https://http://127.0.0.1:5000/<image-name>.png')
    See:  https://docs.flutter.dev/cookbook/images/network-image
    """

    global last_groundtruth_bytes
    global last_model_result_bytes
    global last_error_measure_bytes

    data = request.json
    print(data.get('permeability'))
    print(data.get('density'))

    #TODO: Berechne hier alles: Abwarten in Flutter, dann unten auf Bilder zugreifen

    # Kleiner Test:
    # d = DataSet()
    # d.read_dataset("<Dein Pfad zu den Daten>\\datasets_raw_1000_1HP")
    # fig = d.get_temperature_field(2)

    fig = get_example_figure()
    image_bytes = io.BytesIO()
    FigureCanvas(fig).print_png(image_bytes)

    last_groundtruth_bytes = image_bytes.getvalue()
    last_model_result_bytes = image_bytes.getvalue()
    last_error_measure_bytes = image_bytes.getvalue()

    return "sent sucessfully"


@app.route('/last_groundtruth.png')
def get_last_groundtruth():
    """Image at: https://http://127.0.0.1:5000/last_groundtruth.png"""
    return Response(last_groundtruth_bytes, mimetype='image/png')


@app.route('/last_model_result.png')
def get_last_model_result():
    """Image at: https://http://127.0.0.1:5000/last_model_result.png"""
    return Response(last_model_result_bytes, mimetype='image/png')


@app.route('/last_error_measure.png')
def get_last_error_measure():
    """Image at: https://http://127.0.0.1:5000/last_error_measure.png"""
    return Response(last_error_measure_bytes.getvalue(), mimetype='image/png')


def get_example_figure():
    """Some test image"""
    fig = Figure()
    fig.set_size_inches(10, 2)
    axis = fig.add_subplot(1, 1, 1)
    xs = range(100)
    ys = [random.randint(1, 50) for x in xs]
    axis.plot(xs, ys)
    return fig


def initialize_test_images():
    global last_groundtruth_bytes
    global last_model_result_bytes
    global last_error_measure_bytes
    fig = get_example_figure()
    image_bytes = io.BytesIO()
    FigureCanvas(fig).print_png(image_bytes)
    last_groundtruth_bytes = image_bytes.getvalue()
    last_model_result_bytes = image_bytes.getvalue()
    last_error_measure_bytes = image_bytes.getvalue()

def get_settings(dataset: str = "dataset_raw_demonstrator_input_1dp"):
    paths = get_paths()
    default_raw_dir = paths["default_raw_dir"]
    path_to_settings = os.path.join(default_raw_dir, dataset, "inputs")
    settings = prepare.get_pflotran_settings(path_to_settings)
    return settings

def get_paths():
    paths_file = os.path.join(os.path.abspath(__file__), "..", "..", "1HP_NN")
    with open(paths_file, "r") as f:
        paths = yaml.safe_load(f)
    return paths

def get_path_to_data():
    path_to_data = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data")
    return path_to_data

# Debug run
if __name__ == '__main__':
    initialize_test_images()
    app.run(port=5000)
from flask import Flask, request, jsonify, redirect, url_for, Response
import io
import os
import sys
import random
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from dataclasses import dataclass

from model_communication import ModelCommunication

app = Flask(__name__)

# Bilder kodieren und zusammen zurückschicken? Oder: Daten Senden und dann Bilder einzeln abfragen?
# Vorerst einzeln!

last_images: list = None
image_bytes: list = None
model_communication: ModelCommunication = None

@app.route('/send_input', methods = ['POST'])
def send_input():
    """
    Send the input values and "await" the response in Flutter.
    Then: Request the resulting images using the Image-Widget
          Image.network('https://http://127.0.0.1:5000/<image-name>.png')
    See:  https://docs.flutter.dev/cookbook/images/network-image
    """

    global last_images
    global image_bytes
    global model_communication

    data = request.json
    permeability = float(data.get('permeability'))
    pressure = float(data.get('pressure'))

    model_communication.update_1hp_model_results(permeability, pressure)

    for i in range(3):
        FigureCanvas(model_communication.figures.get_figure(i)).print_png(image_bytes[i])
        last_images[i] = image_bytes[i].getvalue()

    return "sent sucessfully"


@app.route('/last_model_result.png')
def get_last_model_result():
    """Image at: https://http://127.0.0.1:5000/last_model_result.png"""
    return Response(last_images[0], mimetype='image/png')


@app.route('/last_groundtruth.png')
def get_last_groundtruth():
    """Image at: https://http://127.0.0.1:5000/last_groundtruth.png"""
    return Response(last_images[1], mimetype='image/png')


@app.route('/last_error_measure.png')
def get_last_error_measure():
    """Image at: https://http://127.0.0.1:5000/last_error_measure.png"""
    return Response(last_images[2], mimetype='image/png')


def get_example_figure():
    """Some test image"""
    fig = Figure()
    fig.set_size_inches(10, 2)
    axis = fig.add_subplot(1, 1, 1)
    xs = range(100)
    ys = [random.randint(1, 50) for x in xs]
    axis.plot(xs, ys)
    return fig


def initialize_backend():
    global model_communication
    global last_images
    global image_bytes

    image_bytes = [io.BytesIO(), io.BytesIO(), io.BytesIO()]
    model_communication = ModelCommunication()
    last_images = [None, None, None]


# Debug run
if __name__ == '__main__':
    initialize_backend()
    app.run(port=5000)
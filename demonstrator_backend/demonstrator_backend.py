from flask import Flask, request
import io
from dataclasses import dataclass
import base64

from model_communication import ModelCommunication

app = Flask(__name__)


last_images: list = None
image_bytes: list = None
model_communication: ModelCommunication = None


def encode_image(buffer):
    return str(base64.b64encode(buffer.getbuffer()).decode("ascii"))


@app.route('/', methods = ['POST'])
def send_input():
    """
    Returns a JSON object of all three resulting images.
    The images are encoded as a base64 string.
    Example: {"model_result": "iVB...YII=", "groundtruth": "iVB...IYI=" , "error_measure": "iVB...mCC"}
    """

    global last_images
    global image_bytes
    global model_communication

    permeability = float(request.json.get('permeability'))
    pressure = float(request.json.get('pressure'))

    model_communication.update_1hp_model_results(permeability, pressure)

    for i in range(3):
        model_communication.figures.get_figure(i).savefig(image_bytes[i], format="png")
        last_images[i] = image_bytes[i].getvalue()

    return {"model_result": encode_image(image_bytes[0]), "groundtruth":  encode_image(image_bytes[1]), "error_measure": encode_image(image_bytes[2])}


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
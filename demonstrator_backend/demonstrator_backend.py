from flask import Flask, request
import io
import base64

from model_communication import ModelCommunication

# Global Variables:

app = Flask(__name__)

last_images: list = None
image_bytes: list = None
model_communication: ModelCommunication = None


# Backend Interface:


@app.route('/get_model_result', methods = ['POST'])
def get_model_result(): # TODO: Namen des "Spielers" für Fehlerdokumentation / Höchstpunktzahl mitsenden
    """
    Returns a JSON object of all three resulting images.
    The images are encoded as a base64 string.
    Parameters:
    ----------
    {"permeability": <float>, "pressure": <float>, "name": <string>}
    Return:
    ----------
    {"model_result": "iVB...YII=", "groundtruth": "iVB...IYI=" , "error_measure": "iVB...mCC"}
    """

    global image_bytes
    global model_communication

    permeability = float(request.json.get('permeability'))
    pressure = float(request.json.get('pressure'))

    model_communication.update_1hp_model_results(permeability, pressure)

    for i in range(3):
        model_communication.figures.get_figure(i).savefig(image_bytes[i], format="png")

    return {"model_result": encode_image(image_bytes[0]), "groundtruth":  encode_image(image_bytes[1]), "error_measure": encode_image(image_bytes[2])}


@app.route('/get_value_ranges', methods = ['GET'])
def get_value_ranges():
    """
    Returns a JSON object containing the maximum and minimum permeability and pressure values that can be selected on the frontend.
    """
    print("WARNUNG: Provisorisch implementiert")
    return {"permeability_range": [1e-11, 5e-9], "pressure_range": [-4e-03, -1e-03]} # TODO: Aus Datei einlesen


@app.route('/get_highscore_and_name', methods = ['GET'])
def get_highscore_and_name(): # TODO: Implementieren
    """
    Returns the current hiscore (maximum average error) and the name of the person who achieved it.
    """
    print("WARNUNG: Noch nicht implementiert")
    return {"name": "<Name Placeholder>", "score": -1}


# Internal Methods:


def encode_image(buffer):
    return str(base64.b64encode(buffer.getbuffer()).decode("ascii"))


def initialize_backend():
    global model_communication
    global image_bytes

    image_bytes = [io.BytesIO(), io.BytesIO(), io.BytesIO()]
    model_communication = ModelCommunication()


# Start Debug Server:


if __name__ == '__main__':
    initialize_backend()
    app.run(port=5000)
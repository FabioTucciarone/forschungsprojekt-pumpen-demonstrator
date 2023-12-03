from flask import Flask, request, session
from flask_session import Session
from flask_caching import Cache
import io

import model_communication as mc
from flask import current_app

# Global Variables:

app = Flask(__name__)
# SESSION_TYPE = 'filesystem'
# app.config.from_object(__name__)
# Session(app)

app.config['CACHE_TYPE'] = 'FileSystemCache' 
app.config['CACHE_DIR'] = 'cache' # path to your server cache folder
app.config['CACHE_THRESHOLD'] = 100000 # number of 'files' before start auto-delete

cache = Cache(app)
cache.init_app(app)



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

    
    model_configuration = cache.get("model_configuration")


    permeability = float(request.json.get('permeability'))
    pressure = float(request.json.get('pressure'))
    name = request.json.get('name')

    display_data = mc.get_1hp_model_results(model_configuration, permeability, pressure, name)

    return { "model_result":  display_data.get_encoded_figure(0), 
             "groundtruth":   display_data.get_encoded_figure(1), 
             "error_measure": display_data.get_encoded_figure(2) }


@app.route('/', methods=['GET', 'POST'])
def browser_input():

    model_configuration = cache.get("model_configuration")
    print(model_configuration)
    input_form = """<form method="post">
                        <label>Durchlässigkeit und Druck eingeben: &nbsp</label>
                        <input type="text" id="permeability" name="permeability" required />
                        <input type="text" id="pressure" name="pressure" required />
                        <button type="submit">Submit</button
                    </form> <br>"""

    if request.method == 'POST':
        permeability = float(request.form['permeability'])
        pressure = float(request.form['pressure'])
        display_data = mc.get_1hp_model_results(model_configuration, permeability, pressure, "Browser")
        return f"""
            {input_form}
            <img src="data:image/png;base64, {display_data.get_encoded_figure(0)}" alt="Fehler: model_result" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data.get_encoded_figure(1)}" alt="Fehler: groundtruth" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data.get_encoded_figure(2)}" alt="Fehler: error_measure" width="60%" /> <br>
            """

    return input_form


@app.route('/test_response', methods = ['GET'])
def test_response():
    return 'success'

  
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

def initialize_backend():
    cache.set("model_configuration", mc.ModelConfiguration())


# Start Debug Server:

if __name__ == '__main__':
    initialize_backend()
    app.run(port=5000, host='0.0.0.0') # threaded=True, processes=10
from flask import Flask, request
from flask_caching import Cache
import csv
import model_communication as mc
import os

# Global Variables:

app = Flask(__name__)

app.config['CACHE_TYPE'] = 'FileSystemCache' 
app.config['CACHE_DIR'] = '../../data/cache' # Server Cache Pfad: TODO: Systemunabhängig machen
app.config['CACHE_THRESHOLD'] = 100          # Datei Maximum

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
    Example: {"model_result": "iVB...YII=", "groundtruth": "iVB...IYI=" , "error_measure": "iVB...mCC", "average_error" : 0.005788 }
    """

    
    model_configuration = cache.get("model_configuration")


    permeability = float(request.json.get('permeability'))
    pressure = float(request.json.get('pressure'))
    name = request.json.get('name')

    display_data = mc.get_1hp_model_results(model_configuration, permeability, pressure, name)

    insert_highscore(name, display_data.average_error)

    return { "model_result":  display_data.get_encoded_figure("model_result"), 
             "groundtruth":   display_data.get_encoded_figure("groundtruth"), 
             "error_measure": display_data.get_encoded_figure("error_measure"),
             "average_error" : display_data.average_error }


@app.route('/', methods=['GET', 'POST'])
def browser_input():

    model_configuration = cache.get("model_configuration")  

    if request.method == 'POST':
        permeability = float(request.form['permeability'])
        pressure = float(request.form['pressure'])

        display_data = mc.get_1hp_model_results(model_configuration, permeability, pressure, "Browser")
        
        return f"""
            <form method="post">
                <label>Durchlässigkeit und Druck eingeben: &nbsp</label>
                <input type="text" id="permeability" name="permeability" value="{permeability}" required />
                <input type="text" id="pressure" name="pressure" value="{pressure}" required />
                <button type="submit">Submit</button
            </form> <br>
            <img src="data:image/png;base64, {display_data.get_encoded_figure("model_result")}" alt="Fehler: model_result" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data.get_encoded_figure("groundtruth")}" alt="Fehler: groundtruth" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data.get_encoded_figure("error_measure")}" alt="Fehler: error_measure" width="60%" /> <br>
            """

    return f"""
        <form method="post">
            <label>Durchlässigkeit und Druck eingeben: &nbsp</label>
            <input type="text" id="permeability" name="permeability" value="{7.350e-10}" required />
            <input type="text" id="pressure" name="pressure" value="{-2.142e-03}" required />
            <button type="submit">Submit</button
        </form> <br>"""   


@app.route('/test_response', methods = ['GET'])
def test_response():
    return 'success'

  
@app.route('/get_value_ranges', methods = ['GET'])
def get_value_ranges():
    """
    Returns a JSON object containing the maximum and minimum permeability and pressure values that can be selected on the frontend.
    """
    print("WARNUNG: Provisorisch implementiert")
    return {"permeability_range": [1e-11, 1e-10], "pressure_range": [-4e-03, -1e-03]} # TODO: Aus Datei einlesen


@app.route('/get_highscore_and_name', methods = ['GET'])
def get_highscore_and_name():
    """
    Returns the current hiscore (maximum average error) and the name of the person who achieved it.
    """
    name, average_error = cache.get("current_highscore")
    return {"name": name, "score": average_error}


@app.route('/save_highscore', methods = ['GET'])
def save_highscore(): 
    """
    Save the highscores in a csv file.
    """
    highscores = cache.get("highscores")
    with open('../../data/saved_files/highscores.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        for score in highscores:
            writer.writerow(score)
    return 0


# Internal Methods:

def insert_highscore(name: str, average_error: float):
    current_highscore = cache.get("current_highscore")
    print(current_highscore)
    if average_error > current_highscore[1]:
        cache.set("current_highscore", current_highscore, timeout=0)
    if cache.get("save_to_file"):
        highscores = cache.get("highscores")
        highscores.append([name, average_error])
        cache.set("highscores", highscores, timeout=0)


def initialize_backend():

    # TODO: Hier einfach das einstellen, was hübsch aussieht!
    # Farbtupel: (R, G, B) mit 0 <= R, G, B <= 1
    color_palette = mc.ColorPalette(
        cmap_list        = [(0.1,0.27,0.8), (1,1,1), (1,0.1,0.1)],
        background_color = (1,1,1),
        text_color       = (0,0,0) 
    )

    model_configuration = mc.ModelConfiguration()
    model_configuration.set_color_palette(color_palette)
    cache.set("model_configuration", model_configuration, timeout=0)

    if os.path.exists('../../data/saved_files/highscores.csv'):
        with open('../../data/saved_files/highscores.csv', newline='') as csvfile:
            highscores = list(csv.reader(csvfile, delimiter=','))
            max_error = 0.0
            max_name = "init"
            for name, average_error in reversed(highscores):  # neuste haben Priorität
                average_error = float(average_error)
                if float(average_error) > max_error:
                    max_error = average_error
                    max_name = name
            cache.set("current_highscore", [max_name, average_error], timeout=0)

    else:
        highscores = []
        cache.set("current_highscore", ["init", 0.0], timeout=0)

    cache.set("highscores", highscores, timeout=0)
    cache.set("save_to_file", True, timeout=0)  # TODO: Einstellbar machen

    # TODO: Doppelte Namen?
    # TODO: Pfade Variabel machen

# Start Debug Server:

if __name__ == '__main__':

    initialize_backend()
    app.run(port=5000, host='0.0.0.0') # threaded=True, processes=10
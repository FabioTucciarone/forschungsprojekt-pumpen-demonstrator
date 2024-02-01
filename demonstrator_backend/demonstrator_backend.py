from flask import Flask, request
from flask_caching import Cache
import csv
import model_communication as mc
import os
import time

# Global Variables:

app = Flask(__name__)

app.config['CACHE_TYPE'] = 'FileSystemCache' 
app.config['CACHE_DIR'] = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "cache") # Server Cache Pfad
app.config['CACHE_THRESHOLD'] = 100          # Datei Maximum

cache = Cache(app)
cache.init_app(app)

# Backend Interface:

@app.route('/choose_dataset', methods=['GET', 'POST'])
def choose_dataset():

    """
    Returns a string with the choosen dataset.

    Parameters:
    ----------
    {"dataset": <string>}

    Return:
    ----------
    {"dataset": <string>}
    """

    if request.method == 'POST':
        dataset = str(request.json.get('dataset'))
        insert_dataset(dataset)
    return f"""
            <form method="post">
                <label>Gewünschten Datensatz: &nbsp</label>
                <input type="text" id="dataset" name="dataset" value="{dataset}" required />
                <button type="submit">Submit</button
            </form> <br>
            """


@app.route('/get_model_result', methods = ['POST'])
def get_model_result():
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

    return_data = mc.get_1hp_model_results(model_configuration, permeability, pressure)

    insert_highscore(name, return_data.get_return_value("average_error"))

    return { "model_result": return_data.get_encoded_figure("model_result"), 
             "groundtruth": return_data.get_encoded_figure("groundtruth"), 
             "error_measure": return_data.get_encoded_figure("error_measure"),
             "average_error": return_data.get_return_value("average_error"),
             "groundtruth_method": return_data.get_return_value("groundtruth_method") }


@app.route('/get_2hp_model_result', methods = ['POST'])
def get_2hp_model_result():
    """
    Returns a base64 encoded images as a string.

    Parameters:
    ----------
    {"permeability": <float>, "pressure": <float>, "pos": <list[int]>}
    pos needs to be in the range returned by get_2hp_field_shape()

    Return:
    ----------
    Example: "iVB...YII="
    """

    model_configuration = cache.get("model_configuration")

    permeability = float(request.json.get('permeability'))
    pressure = float(request.json.get('pressure'))
    pos = [int(request.json.get('pos')[0]), int(request.json.get('pos')[1])]

    display_data = mc.get_2hp_model_results(model_configuration, permeability, pressure, pos)

    return { "model_result": display_data.get_encoded_figure("model_result") }#, 


@app.route('/', methods=['GET', 'POST'])
def browser_input():

    model_configuration = cache.get("model_configuration")

    if request.method == 'POST':
        permeability = float(request.form['permeability'])
        pressure = float(request.form['pressure'])
        name = request.form['name']

        a = time.perf_counter()
        display_data_1hp = mc.get_1hp_model_results(model_configuration, permeability, pressure)
        b = time.perf_counter()
        print(f"Zeit :: get_1hp_model_results(): {b-a}\n")
        a = time.perf_counter()
        display_data_2hp = mc.get_2hp_model_results(model_configuration, permeability, pressure, [10, 10])
        b = time.perf_counter()
        print(f"Zeit :: get_2hp_model_results(): {b-a}\n")
        insert_highscore(name, display_data_1hp.get_return_value("average_error"))
        
        return f"""
            <form method="post">
                <label>Durchlässigkeit und Druck eingeben: &nbsp</label>
                <input type="text" id="permeability" name="permeability" value="{permeability}" required />
                <input type="text" id="pressure" name="pressure" value="{pressure}" required />
                <input type="text" id="name" name="name" value="{name}" required />
                <button type="submit">Submit</button
            </form> <br>
            <img src="data:image/png;base64, {display_data_1hp.get_encoded_figure("model_result")}" alt="Fehler: model_result" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data_1hp.get_encoded_figure("groundtruth")}" alt="Fehler: groundtruth" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data_1hp.get_encoded_figure("error_measure")}" alt="Fehler: error_measure" width="60%" /> <br>
            <img src="data:image/png;base64, {display_data_2hp.get_encoded_figure("model_result")}" alt="Fehler: model_result 2hp" width="60%" /> <br>
            """

    return f"""
        <form method="post">
            <label>Durchlässigkeit und Druck eingeben: &nbsp</label>
            <input type="text" id="permeability" name="permeability" value="{7.350e-10}" required />
            <input type="text" id="pressure" name="pressure" value="{-2.142e-03}" required />
            <input type="text" id="name" name="name" value="test" required />
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
    k_range, p_range = cache.get("model_configuration").get_value_ranges()
    return {"permeability_range": k_range, "pressure_range": p_range}


@app.route('/get_highscore_and_name', methods = ['GET'])
def get_highscore_and_name():
    """
    Returns the current highscore (maximum average error) and the name of the person who achieved it.
    """
    top_ten_list = cache.get("top_ten_list")
    name = None
    score = None
    if len(top_ten_list) > 0:
        name = top_ten_list[0][0]
        score = top_ten_list[0][1]
    return {"name": name, "score": score}


@app.route('/get_top_ten_list', methods = ['GET'])
def get_top_ten_list():
    """
    Possibly empty list of ten tuples.
    """
    return cache.get("top_ten_list")


@app.route('/save_highscores_to_csv', methods = ['GET'])
def save_highscore(): 
    """
    Save the highscores into a csv file.
    """
    data_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "saved_files", "scores.csv")
    scores = cache.get("top_ten_list")
    with open(data_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',')
        for score in scores:
            writer.writerow(score)
    return 0


@app.route('/get_2hp_field_shape', methods = ['GET'])
def get_2hp_field_shape():
    return cache.get("model_configuration").model_2hp_info["OutFieldShape"]


# Internal Methods:

# sets current dataset in cache
def insert_dataset(dataset: str):
    dataset_old = cache.get("dataset")
    if(dataset != dataset_old):
        cache.set("dataset", dataset, timeout=0)

def insert_highscore(name: str, average_error: float):
    top_ten_list = cache.get("top_ten_list")

    for i, entry in enumerate(top_ten_list):
        if entry[0] == name:
            if entry[1] < average_error:
                top_ten_list[i] = (name, average_error)
            else:
                return

    if len(top_ten_list) < 10:
        top_ten_list.append((name, average_error))
    else:
        top_ten_list[9] = (name, average_error)
    top_ten_list = sorted(top_ten_list, key=lambda entry: entry[1], reverse=True)
    cache.set("top_ten_list", top_ten_list, timeout=0)

def initialize_backend():

    # TODO: Hier einfach das einstellen, was hübsch aussieht!
    # Farbtupel: (R, G, B) mit 0 <= R, G, B <= 1
    color_palette = mc.ColorPalette(
        cmap_list        = [(0.019,0.188,0.38), (1,1,1), (0.4,0.1,0.1)],
        background_color = (1,1,1),
        text_color       = (0,0,0) 
    )

    data_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data", "saved_files", "scores.csv")

    model_configuration = mc.ModelConfiguration(device="cuda")
    model_configuration.set_color_palette(color_palette)
    cache.set("model_configuration", model_configuration, timeout=0)

    if os.path.exists(data_path):
        with open(data_path, newline='') as csvfile:
            scores = list(csv.reader(csvfile, delimiter=','))
            top_ten_list = []
            for i, score in enumerate(scores):
                if i == 10: break
                top_ten_list.append(score)
    else:
        cache.set("top_ten_list", [], timeout=0)

    # TODO: Pfade Variabel machen

# Start Debug Server:

if __name__ == '__main__':
    initialize_backend()
    print("Flask-Debug: Initialized")
    app.run(port=5000, host='0.0.0.0', threaded=True)
else:
    initialize_backend()
    print("Initialized")

from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/", methods=['POST'])
def generate_output():
    request_data = request.get_json()
    return jsonify([2 * n for n in request_data])
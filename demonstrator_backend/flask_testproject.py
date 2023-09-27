from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/", methods=['POST'])
def hello_world():
    request_data = request.get_json()
    numbers = {
        'a': request_data["a"],
        'b': request_data["b"],
    }
    print(numbers)
    x = numbers['b']
    numbers['b'] = numbers['b'] + numbers['a']
    numbers['a'] = x
    return jsonify(numbers)
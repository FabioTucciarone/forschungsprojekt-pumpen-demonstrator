from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/")
def generate_output():
    return "Huhu"

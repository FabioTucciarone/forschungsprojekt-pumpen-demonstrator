from flask import Flask, request, jsonify, redirect, url_for

app = Flask(__name__)

@app.route("/")
def generate_output():
    return "Huhu"

@app.route('/',methods = ['POST'])
def add():
    data = request.json
    print(data.get('permeability'))
    print(data.get('density'))
    return data.get('permeability') + data.get('density')


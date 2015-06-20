#!/usr/bin/env python
'''
Acts as a simple server to server index and data
'''
from flask import Flask, request, render_template

app = Flask(__name__, static_url_path='')

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)

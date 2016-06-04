import os

from pymongo import MongoClient
from bottle import route, run, template, static_file, TEMPLATE_PATH


client = MongoClient()
db = client.dba

@route('/static/:path#.+#', name='static')
def index(path):
    return static_file(path, root='static')

@route('/hello')
def hello():
    return "Hello World!"

@route('/a')
def index():
    return template()


@route('/b')
def index():
    return template()


@route('/c')
def index():
    return template()

run(host='0.0.0.0', port=8080, debug=True)

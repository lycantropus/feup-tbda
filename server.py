# -*- coding: utf-8 -*-
import os

from pymongo import MongoClient
from bottle import route, run, SimpleTemplate, template, static_file, TEMPLATE_PATH
import json
import urllib.request
import requests
from requests.auth import HTTPBasicAuth
from html.parser import HTMLParser
import re
import pprint


client = MongoClient('64.137.179.6', 27017)


db = client.trab3

years = db.years
alus = db.alus
cands = db.cands


@route('/static/:path#.+#', name='static')
def index(path):
    return static_file(path, root='static')


@route('/hello')
def hello():
    return "Hello World!"


@route('/loadyears')
def index():
    response = requests.get(
        'http://oraalu.fe.up.pt:8888/aulas/WEB_DATA.json_years', auth=HTTPBasicAuth('ei12060', 'Vitor'))
    h = HTMLParser()
    document = json.loads(h.unescape(response.text))
    years.insert_one(document)

    return "putas e VV"


@route('/loadcands')
def index():
    response = requests.get(
        'http://oraalu.fe.up.pt:8888/aulas/WEB_DATA.json_cands', auth=HTTPBasicAuth('ei12060', 'Vitor'))
    h = HTMLParser()
    document = json.loads(h.unescape(response.text))
    cands.insert_one(document)

    return "vape nation \//\ "


@route('/loadalus')
def index():
    response = requests.get(
        'http://oraalu.fe.up.pt:8888/aulas/WEB_DATA.json_alus', auth=HTTPBasicAuth('ei12060', 'Vitor'))
    h = HTMLParser()

    document = json.loads(h.unescape(response.text))
    alus.insert_one(document)
    return "putas e VV"


@route('/years')
def index():
    result = years.find()

    info = {'title': 'Listagem de Anos',
            'content': result[0]['anos'],

            }

    print (result[0]['anos'])

    return template('page.tpl', info)


@route('/alus')
def index():
    result = alus.find()
    info = {'title': 'Listagem de Anos',
            'content': result[0]['alus']
            }

    return template('page.tpl', info)


@route('/cands')
def index():
    result = cands.find()

    info = {'title': 'Listagem de Anos',
            'content': result[0]['cands']
            }

    # print (result[0]['anos'])

    return template('page.tpl', info)


@route('/a')
def index():
    print ('hey!')
    # query = alus.find()[0]['alus'].aggregate([
    #    {'$match': {'curso.sigla': {'$in': ['EM', 'EC']}}},
    #    {'$project': {'curso.nome': True}}])

    pipeline = [
        {"$unwind": "$alus"},
        {"$group": {"_id": "$alus"}}]
    # result = alus.find()

    pipelinecera = [
        {"$match": {"a_lect_matricula": {"$gt": 1991}}},
        {"$group": {'alus.a_lect_matricula': True, "count": {"$sum": 1}}}]
    info = {'title': 'Query 3a)',
            'content': list(alus.aggregate(pipelinecera))
            }
    list(alus.aggregate(pipeline))

    return template('page.tpl', info)

run(host='0.0.0.0', port=8080, debug=True, reloader=True)

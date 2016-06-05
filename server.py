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
    years.insert(document)

    return "putas e VV"


@route('/loadcands')
def index():
    response = requests.get(
        'http://oraalu.fe.up.pt:8888/aulas/WEB_DATA.json_cands', auth=HTTPBasicAuth('ei12060', 'Vitor'))
    h = HTMLParser()
    document = json.loads(h.unescape(response.text))
    cands.insert(document)

    return "vape nation \//\ "


@route('/loadalus')
def index():
    response = requests.get(
        'http://oraalu.fe.up.pt:8888/aulas/WEB_DATA.json_alus', auth=HTTPBasicAuth('ei12060', 'Vitor'))
    h = HTMLParser()

    document = json.loads(h.unescape(response.text))
    alus.insert(document)
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

    # for ele in test[0]['alus']:
    # print(ele)
    # input()

    cursor = alus.aggregate([
        {'$match': {'a_lect_matricula': {'$gt': 1991}}},
        {'$group': {'_id': {'ano': '$a_lect_matricula',
                            'curso': '$curso.nome'}, 'count': {'$sum': 1}}},
        {'$sort': {'_id': 1}}
        #{'$project': {'_id': 1, 'curso': 1, 'count': 1}}
    ])

    filtered = list()
    for document in cursor:
        filtered.append(document)

    info = {'title': 'Query 3a)',
            'content': filtered
            }

    return template('page.tpl', info)


@route('/b')
def index():
    # cursor = alus.aggregate([
     #   {'$where': 'this.med_final > this.cand.media'},
      #  {'$group': {'_id': {'BI': '$bi', 'Numero': '$numero'}}}
    #])
    cursor = alus.aggregate([
        {'$project': {
            'bi': 1,
            'numero': 1,
            '_id': 0,
            'med_maior': {'$gt': ['$med_final', '$cand.media']}, }},
        {'$match': {'med_maior': True}}]
    )

    filtered = list()
    for document in cursor:
        filtered.append(document)
    info = {'title': 'Query 3b)',
            'content': filtered
            }

    return template('page.tpl', info)


@route('/c')
def index():
    cursor = alus.aggregate([
        #{'$project': {'numero_anos' : {'$subtract': ['a_lect_conclusao', 'a_lect_matricula' ] }}},
        {'$project': {'_id': 0}},
        {'$group': {'_id': 'null', 'numero_anos': {'$subtract': ['a_lect_conclusao', 'a_lect_matricula']},
                    'avgmedia': {'$avg': 'med_final'}}}
    ])

    for document in cursor:
        print(document)

    return 'c'

run(host='0.0.0.0', port=8080, debug=True, reloader=True)

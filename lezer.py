#! /usr/bin/python3

from urllib import request
import json
from datetime import datetime
import sys
import secret # import api key as var KEY

mode, value = sys.argv[1:3]

url = (
    'http://10.0.0.1:8080/api/irma_api.php?'
    'apikey=%s&%s=%s') % (secret.KEY, mode, value) # mode = thalia_username | student_number, value = thalia root | student number

data = None

try:
    with request.urlopen(url) as p:
        data = json.loads(p.read().decode('utf-8'))
except IOError as e:
    data['status'] = 'error'
    data['message'] = str(e)

if data['status'] != 'ok':
    print(data.get('message', 'unknown error') if data else 'unknown error')
    exit(1)

now = datetime.now()

over18 = False

try:
    if (now.replace(year=now.year - 18)
            > datetime.strptime(data['birthday'], '%Y-%m-%d %H:%M:%S')):
        over18 = True
except ValueError:
    pass

lidtype = 'unknown'

if data['membership_type'] in ('Study Membership', 'Yearly Membership'):
    lidtype = 'member'
elif data['membership_type'] == 'Benefactor':
    lidtype = 'begunstiger'
elif data['membership_type'] == 'Honorary Member':
    lidtype = 'honoraryMember'

print(data['username'], lidtype, over18)

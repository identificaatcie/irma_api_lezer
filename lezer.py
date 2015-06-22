#! /usr/bin/python3

from urllib import request
import json
from datetime import datetime
import sys

mode, value = sys.argv[1:3]

url = (
    'http://localhost:8080/api/irma_api.php?'
    'apikey=2qTNHEm9wGYZS7o01Bpvhfw0EPe6ya2HOAR9eQl8wZoBCOSlqUvIudTKHngMH6aV'
    '&%s=%s') % (mode, value)

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

if data['membership_type'] == 'Jaarlid':
    lidtype = 'member'
elif data['membership_type'] == 'Begunstiger':
    lidtype = 'begunstiger'
elif data['membership_type'] == 'Erelid':
    lidtype = 'honoraryMember'

print(data['username'], lidtype, over18)

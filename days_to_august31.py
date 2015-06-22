#!/usr/bin/env python
from datetime import date

target = date.today()
now = date.today()

target = target.replace(month=8, day=31)

if now.month >= 9:
    target = target.replace(year=now.year+1)

print((target - now).days)

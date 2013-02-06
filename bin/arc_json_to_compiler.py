#!/usr/bin/python

# Converts arc lint's json output to something vim can easily parse

import json, sys

filename = None
if len(sys.argv) > 1:
    filename = sys.argv[1]
x = json.loads(sys.stdin.read());
for (file, data) in x.items():
    if filename is not None:
        file = filename
    for issue in data:
        if issue['char'] is None:
            issue['char'] = 1
        print ":".join((file, str(issue['line']), str(issue['char']), issue['severity'], issue['name'], '', issue['description']))

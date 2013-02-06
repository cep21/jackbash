#!/bin/bash
# Runs arc lint and converts the output to something vim can parse
arc lint --output json $1 | arc_json_to_compiler.py $1

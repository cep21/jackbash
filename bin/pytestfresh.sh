#!/bin/bash

set -euo pipefail
if [ ! -d venv ]; then
	echo "no venv directory!"
	exit 1
fi
if [ ! -f requirements.txt ]; then
	echo "no reqs to install!"
	exit 1
fi
echo "Removing venv ..."
rm -rf ./venv
echo "Reinstalling venv ..."
python -m venv venv
echo "Activating ..."
source ./venv/bin/activate
echo "Installing reqs ..."
pip install -r requirements.txt
echo "Running unittest ..."
python -m unittest

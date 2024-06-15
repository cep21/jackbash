#!/bin/bash

set -euo pipefail
if [ ! -d venv ]; then
	echo "no venv directory!"
	exit 1
fi
mkdir -p ~/.config
DESTINATION="$HOME/.config/.pycharm-venv"
if [ -L "${DESTINATION}" ]; then
	echo "Currently pointing at $(readlink -f "${DESTINATION}")"
fi
rm -f "${DESTINATION}"
ln -s $(pwd)/venv "${DESTINATION}"
echo "File ${DESTINATION} is now pointing to $(readlink -f "$DESTINATION")"
echo "Run this: source ./venv/bin/activate"

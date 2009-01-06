#!/bin/bash
# Mail you a file from the command line.  For example,
# $ mailme.sh  neat_file.txt
echo "Email attachment sent from command line" | mutt -s "Email attachment: $1" -a $1 $EMAIL

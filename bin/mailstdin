#!/bin/bash
# Mail standard input to you.  For example,
#  $ execute_command.sh | mailstdin.sh
# I cannot -a /dev/stdin so I cat it to a file first
cat /dev/stdin > /tmp/mailfile.txt
mutt -s "Email sent from sandbox" -a /tmp/mailfile.txt $EMAIL < /tmp/mailfile.txt
rm -f /tmp/mailfile.txt

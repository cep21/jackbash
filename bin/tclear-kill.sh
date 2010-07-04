#!/bin/bash
# When I have multiple tmux shells running, this will kill the other ones
a=`w | grep 'tmux attach' | cut -d' ' -f2 | xargs -i -n1 echo "ps auwx | grep {}" | /bin/bash -s | grep sshd | grep -oP '^\d+\s+(\d+)' | grep -oP '\d+$' | ruby -ne 'puts $_.strip'`
if [ -z $a ]
then
  echo "None to kill"
else
  echo $a | xargs kill
fi;

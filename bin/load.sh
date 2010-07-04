#!/bin/bash
# Shows uptime in a way that tmux can parse
uptime | sed -le 's/^.*: \(.*\)$/\1/'

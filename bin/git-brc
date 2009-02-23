#!/bin/sh
FORMAT='git log -1 --pretty=format:%%ct\\ %(refname)\\ %%cr %(objectname)'
git for-each-ref --shell --format="$FORMAT" refs/heads | \
while read entry ; do
  eval "$entry"
  echo
done | sort -n | cut -d' ' -f 2- | sed 's:^refs/heads/::' | \
awk '{ printf "%16s ", $1; print substr($0, length($1)+1, length($0)-length($1)); }'


#!/bin/bash
git blame -wMC $@ | colorize_git_blame.pl | less -R

#!/bin/bash
git blame $@ | colorize_git_blame.pl | less -R

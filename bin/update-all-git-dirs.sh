#!/bin/bash

# Update all .git directories that are a direct subdirectory of $(pwd)

set -euo pipefail

if [[ "${DEBUG-}" == "true" ]]; then
  set -x
fi

function is_clean() {
  [[ -z "$(git status -s)" ]]
}

function branch_name() {
  branch_name=$(git symbolic-ref -q HEAD)
  branch_name=${branch_name##refs/heads/}
  branch_name=${branch_name:-HEAD}
  echo "$branch_name"
}

function update_dir() {
  cd $d
  if [ ! -d .git ]; then
    echo "$d is not a git directory: skipping"
    exit 0
  fi
  git fetch -avp
  if ! is_clean ; then
    echo "$d is not clean: skipping"
    exit 0
  fi
  if [[ "$(branch_name)" == "main" ]]; then
    git rebase origin/main
  fi
  git-prune-branches
}

for d in */ ; do
(
  echo "On directory $d"
  update_dir "$d"
)
done


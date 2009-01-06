#!/usr/local/bin/python
# Author: Jack Lindamood
# git-tonotify.py
# Given a git commit, this program will blame {commit}^ to try
#  to see who should be notified by the commit's changes.
#
# 3 ways someone should know about a change
# (1) Modified or removed lines
# (1a)  Notify who owned the old lines
# (2) New lines
# (2a)  Notify whoever owned the above and below lines

import sys, subprocess, re, pprint

linepat   = re.compile('^@@[\d+\-,\s]*@@',re.MULTILINE)

#Find the first ( and its closest ) group by the first non-whitespace separated part
authorpat = re.compile('^.*?\(([\S]*?)\s.*?\s(\d*?)\).*$')

def rungit(cmd):
  git_proc = subprocess.Popen(
             ["git",'--no-pager'] + cmd,
             stdout=subprocess.PIPE,
             stderr=subprocess.PIPE
             )
  (git_out, git_err) = git_proc.communicate()
  status = git_proc.poll()
  if status:
    print 'Git command error!' + git_out + git_err
    sys.exit(1)
  return git_out

def usage():
  print "Usage: " + sys.argv[0] + " <revision>"

def get_files_changed(rev):
  return rungit(['show','--name-only','--pretty=format:%H',rev]).splitlines()[1:]

def parts_changed(rev, file):
  diff = rungit(['diff',rev+'^',rev,'-U0','--',file])
  authors = {}
  for hunk in linepat.findall(diff):
    parts = hunk.split(' ')
    if len(parts) != 4:
      print "Invalid assumptions:"
      print [rev,file,hunk]
      sys.exit(2)
    (prev, cur) = (parts[1], parts[2])
    if prev[0] != '-':
      print "Invalid prev assumptions:"
      print [rev,file,hunk]
      sys.exit(2)
    prev=prev[1:]
    if cur[0] != '+':
      print "Invalid cur assumptions:"
      print [rev,file,hunk]
      sys.exit(2)
    cur=cur[1:]
    cur=cur.split(',')
    prev=prev.split(',')
    if len(prev) == 1:
      prev = prev + ['1']
    if len(cur) == 1:
      cur = cur + ['1']

    if cur[1] == '0' and prev[1] == 0:
      print "Invalid zero assumptions:"
      print [rev,file,hunk]
      sys.exit(2)
    if cur[1] == '0':
      # Someone removed content
      # Were you the owner of that content?
      new_authors = get_authors(rev+'^', file, int(prev[0]), int(prev[1]))
      for author in new_authors:
        if author not in authors:
          authors[author] = set()
        authors[author].add(hunk)
    elif prev[1] == '0':
      # Someone added new content.  Who owned the surrounding content?
      if prev[0] == '0':
        #nobody, new file
        continue
      new_authors = get_authors(rev+'^', file, int(prev[0]), 1)
      for author in new_authors:
        if author not in authors:
          authors[author] = set()
        authors[author].add(hunk)
    else:
      # Someone replaced content.  Did you own the replaced content?
      new_authors = get_authors(rev+'^', file, int(prev[0]), int(prev[1]))
      for author in new_authors:
        if author not in authors:
          authors[author] = set()
        authors[author].add(hunk)

  return authors


def process_rev(rev):
  rev_blame = {}
  for file in get_files_changed(rev):
    changed = parts_changed(rev,file)
    for author in changed:
      rev_blame.setdefault(author,{})[file] = set([])
      for hunk in changed[author]:
        rev_blame[author][file].add(hunk)
  return rev_blame

def get_authors(rev, file, start_line, num_line):
  if file not in get_authors.dp.setdefault(rev,{}):
    auth = rungit(['blame', rev, '-MCC', '-w', '--', file])
    authors = []
    for line in auth.splitlines():
      authors.append(authorpat.match(line).groups()[0])
    get_authors.dp[rev][file] = authors
  authors = set(get_authors.dp[rev][file][start_line-1:start_line-1+num_line])
  return authors


get_authors.dp = {}

if len(sys.argv) > 2:
  usage()
  sys.exit(1)
elif len(sys.argv) == 1:
  revision = 'HEAD'
else:
  revision = sys.argv[1]
blame_map = process_rev(revision)
#Maybe we want more information, like which parts the author is responsible for
pprint.pprint(blame_map)
#for author in blame_map:
#  print author
sys.exit(0)

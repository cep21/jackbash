#!/usr/local/bin/python
import sys, subprocess, tempfile, pprint
# Visual diff of two commit objects
#   usage: git-kdiff3 commit1 commit2

# Pipe cmd1 into cmd2
def safe_pipe(cmd1, cmd2):
  proc1 = subprocess.Popen(
    cmd1,
    stdout=subprocess.PIPE
    )
  proc2 = subprocess.Popen(
    cmd2,
    stdin =proc1.stdout,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
    )
  (out, err) = proc2.communicate()
  status = proc2.poll()
  if status:
    print 'Error!' + out + err
    sys.exit()
  return out


def safe_exec(cmd):
  proc = subprocess.Popen(
    cmd,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE
    )
  (out, err) = proc.communicate()
  status = proc.poll()
  if status:
    print cmd
    print 'Error!' + out + err
    sys.exit()
  return out


if len(sys.argv) == 1:
  cur = 'HEAD'
  prev = safe_exec(['git','merge-base','git-svn',cur]).strip()
elif len(sys.argv) == 2:
  prev = sys.argv[1]
  cur  = 'HEAD'
elif len(sys.argv) == 3:
  prev = sys.argv[1]
  cur  = sys.argv[2]
else:
  usage()
  sys.exit()

prev = safe_exec(['git','rev-parse',prev]).strip()
cur  = safe_exec(['git','rev-parse',cur]).strip()

tempdir = tempfile.mkdtemp(prefix = '.git-kdiff3-tmp', dir = '/tmp')
list = safe_exec(['git','diff','--name-only','-z',prev,cur])
list_array = []
for line in list.split(chr(0)):
  if line:
    list_array.append(line)

base = safe_exec(['git','merge-base',prev,cur]).strip()

safe_pipe(
  ['git','archive','--prefix=a/',prev] + list_array,
  ['tar','xf','-','-C',tempdir]
)

safe_pipe(
  ['git','archive','--prefix=b/',cur ] + list_array,
  ['tar','xf','-','-C',tempdir]
)

if base == prev or base==cur:
   subprocess.call(['kdiff3 '+tempdir+'/a '+tempdir+'/b &> /dev/null'],shell=True)
else:
  safe_pipe(
    ['git','archive','--prefix=c/',base] + list_array,
    ['tar','xf','-','-C',tempdir]
  )
  subprocess.call(['kdiff3 '+tempdir+'/c '+tempdir+'/a '+tempdir+'/b &> /dev/null'],shell=True)


# Less robust, but MUCH smaller bash script
#tempdir="/tmp/.git-kdiff3-tmp-$$"
#rm -rf $tempdir
#mkdir $tempdir
#list="$tempdir/list"
#git diff --name-only -z $1 $2 > $list

#cat $list | xargs -0 git archive --prefix=a/ $1                     | tar xf - -C $tempdir
#cat $list | xargs -0 git archive --prefix=b/ $2                     | tar xf - -C $tempdir
#cat $list | xargs -0 git archive --prefix=c/ `git merge-base $1 $2` | tar xf - -C $tempdir

#kdiff3 $tempdir/c $tempdir/a $tempdir/b &> /dev/null

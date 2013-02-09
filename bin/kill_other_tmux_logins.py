#!/usr/bin/python
import subprocess
import os
import getpass
import re
import signal

def execute_required(commands):
    """
    Execute a set of command and fail if command return code is not zero.
    """
    last_pipe = None
    pipes = []
    for command in commands:
        if last_pipe is not None:
            stdin = last_pipe.stdout
        else:
            stdin = None
        this_pipe=subprocess.Popen(command, stdout=subprocess.PIPE, stdin=stdin)
        if last_pipe is not None:
            last_pipe.stdout.close()
        last_pipe=this_pipe
        pipes.append(last_pipe)
    (stdout, stderr)= last_pipe.communicate()
    out = stdout
    if last_pipe.returncode != 0:
        raise Exception("None zero return code: %d" % last_pipe.returncode)
    return out


class LoggedInSessions(object):
    def __init__(self, login_line):
        self.login_line = login_line
        self.parts = re.split("\s+", self.login_line)

    def getHostmatch(self):
        return self.parts[2]

    def getPts(self):
        return self.parts[1]

whoami = getpass.getuser()
still_in = execute_required([
    ["last"],
    ["grep", whoami],
    ["grep", "still logged in"],
])

sessions = []
for line in still_in.split("\n"):
    if not line.strip():
        continue
    print "Line is *" + line
    sessions.append(LoggedInSessions(line.strip()))

if len(sessions) < 2:
    print "not enough sessions"
    sys.exit(0)

first_session_host = sessions[0].getHostmatch()
for session in sessions:
    if session.getHostmatch() != first_session_host:
        pts = session.getPts()
        tokill_line = execute_required([
            ["ps", "auwxxx"],
            ["grep", "sshd.*" + pts + "$"],
        ])
        tokill_parts = re.split("\s+", tokill_line.strip())
        tokill_id = int(tokill_parts[1])
        print "Killing %d" % tokill_id
        os.kill(tokill_id, signal.SIGTERM)

# .bashrc
# Welcome to the most awesome bash startup script you'll ever see.
#   It tries to be BSD and GNU compatable, which means it works on
#   your MAC and sandbox server.  It also tries to be safe to add
#   as a source to your .bashrc and .bash_profile.  I usually just
#   source this file from both.
#   It is split into three files
#   (1) Generic bash stuff
#       * This is the stuff you would want to show and run anywhere
#         you ever use bash: Work, home, your personal web-site, share
#         with the internet, etc
#   (2) Per group files
#       * This is the file you would want to always run in whatever
#         group you're in.  For example, at work on every server or at
#         school on every server, these commands make sense.
#   (3) Per hostname files
#       * These are the commands you want to run only on the specified
#         host
#
#
#
#  This also sources binary files, inside 'bin' split the same way


# Source global definitions
GLOBAL_BASH_DEF='/etc/bashrc'
if [ -f $GLOBAL_BASH_DEF ]
then
  source $GLOBAL_BASH_DEF
fi;


# Create a scrubed hostname
export HOSTNAME_SCRUB=`hostname | sed -e s/[^a-z0-9_]//g`


# Global variables
# Sometimes EDITOR require a complete path
export EDITOR=`which vim`
export SVN_EDITOR=`which vim`
export GIT_EDITOR=`which vim`
export PAGER=`which less`
export LS_COLORS="no=00:\
fi=00:\
di=01;36:\
ln=01;36:\
pi=40;33:\
so=01;35:\
do=01;35:\
bd=40;33;01:\
cd=40;33;01:\
or=40;31;01:\
ex=01;32:\
*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:\
*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:\
*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:\
*.ogg=01;35:*.mp3=01;35:*.wav=01;35:\
";
export GREP_OPTIONS='--color=auto'
# Make the git ceil dir /home from /home/uname
#   or, on a mac /Users from /Users/uname
export GIT_CEILING_DIRECTORIES=`echo $HOME | sed 's#/[^/]*$##'`
export HISTFILESIZE=1000000000
export HISTSIZE=1000000
export PROMPT_COMMAND='history -a'

# export the first java home we find
(which java &> /dev/null)
if [ $? -eq 0 ]; then
  JAVA_IN_PATH=`ls -la \`which java\` | sed s/.*-\>[^/]*// | sed s#/bin/java##`
fi;
for x in [ $JAVA_IN_PATH ]; do
  if [ -d $x ]; then
    export JAVA_HOME=$x
    break
  fi
done


# Compatability options
# The BSD sed on mac uses -E, while the GNU one on linux uses -r
(echo '' | sed -r /GG/g &> /dev/null)
if [ $? -eq "0" ]; then
  export SED_EXT='-r'
else
  export SED_EXT='-E'
fi

# GNU vs BSD hostname
(hostname -i &> /dev/null)
if [ $? -eq 0 ]; then
  export MY_IP=`hostname -i`
else
  # default to eth0 IP, for MAC
  export MY_IP=`ipconfig getifaddr en0`
fi;

# GNU vs BSD ls for color
(ls --color=tty &> /dev/null)
if [ $? -eq 0 ]; then
  export LS_COLOR='--color=tty'
else
  export LS_COLOR='-G'
fi;

#GNU vs BSD top command line arguments
# Delay updates by 10 sec and sort by CPU
(man top 2>&1 | grep Linux> /dev/null)
if [ $? -eq 0 ]; then
  export TOP_OPTIONS='-c -d10'
else
  export TOP_OPTIONS='-s10 -ocpu'
fi;


# Options
shopt -s checkwinsize
shopt -s histappend

# Aliases
alias ls='ls -h $LS_COLOR'
alias la='ls -lah $LS_COLOR'
alias ll='ls -lh $LS_COLOR'
alias ssh='ssh -A'
alias g='git'
alias top='top $TOP_OPTIONS'

#### RANDOM FUNCTIONS #####
#autocomplete ant commands... but it doesn't work!
#complete -C complete-ant-cmd ant.pl build.sh
#autocomplete ssh commands with the hostname
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh
# awesome!  CD AND LA. I never use 'cd' anymore...
function cl(){ cd $@ && la; }
# cat the contents of a command
function catw(){
# TODO: This doesn't work.  Why?
  FILE_NAME="`which $1`"
  if [ -r $FILE_NAME ]; then
    cat $FILE_NAME
  else
    echo "Cannot find file"
  fi;
}
complete -c default catw
# Two standard functions to change $PATH
add_path() { export PATH="$PATH:$1"; }
# Misc utilities:

# Repeat a command N times.  You can do something like
#  repeat 3 echo 'hi'
function repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do  # --> C-like syntax
        eval "$@";
    done
}

# Lets you ask a command.  Returns '0' on 'yes'
#  ask 'Do you want to rebase?' && git svn rebase || echo 'Rebase aborted'
function ask()
{
    echo -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}


# Global path manipulation
add_path $HOME/bin
add_path $HOME/.bash/bin
add_path $HOME/.bash/group/bin

# Set up git completion
source $HOME/.bash/config/git-completion.bash

###### PROMPT ######
# Set up the prompt colors
source $HOME/.bash/term_colors
PROMPT_COLOR=$G
if [ ${UID} -eq 0 ]; then
  PROMPT_COLOR=$R ### root is a red color prompt
fi
ESCAPED_HOME=`echo $HOME | sed $SED_EXT "s:/:\\\\\\/:g"`
# The first little bit of insanity lets screen read the title of the running program
# The pwd | sed lets me only see the last three directories
#   deep so my prompt doens't get too huge!
# Sample Prompt:
#
# 01:35:03 uname@server(branch):path/to/thing
# $
#
PS1='\[\033k\033\\\]'$Y'\t'$N' '${PROMPT_COLOR}'\u@\h'$W'$(__git_ps1 "(%s)")'$N':`pwd | sed '$SED_EXT' "s/${ESCAPED_HOME}/~/" | sed '$SED_EXT' "s/^.*\/(.*)(\/.*)(\/.*)$/\1\2\3/"`\n\$ '


#### Source group
GROUP_FILE="$HOME/.bash/group/group.bash"
if [ -f $GROUP_FILE ]
then
  source $GROUP_FILE
fi;

##### Source the correct per-host file
PERHOST_FILE="$HOME/.bash/group/hostnames/$HOSTNAME_SCRUB.bash"
if [ -f $PERHOST_FILE ]
then
  source $PERHOST_FILE  
fi;


# remove duplicate path entries
#  There seem to be some bugs in this.  Inspect more later
export PATH=$(echo $PATH | awk -F: '
    { for (i = 1; i <= NF; i++) arr[$i]; }
    END { for (i in arr) printf "%s:" , i; printf "\n"; } ')


# .bashrc
# === INTRO ===
#
# Welcome to the most awesome bash startup script you'll ever see.
#   It tries to be BSD and GNU compatable, which means it works on
#   your MAC, cygwin, and sandbox server.  It also tries to be safe 
#   to add as a source to your .bashrc and .bash_profile.  I usually 
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
#  This also sources executable files, inside 'bin' split the same way
#
#  === FILE STRUCTURE ===
#
#  The file is organized into the following parts
#
#  (1) Source global definitions
#  (2) Create global shell variables
#  (3) Create BSD vs GNU compatable variables
#  (4) Set shell options
#  (5) Set aliases
#  (6) Set autocomplete options
#  (7) Create useful utility bash functions()
#  (8) Setup global path
#  (9) Setup the prompt
#  (10) Source per group file
#  (11) Source per hostname file
#  (12) Clean up PATH
#
#
#  === HOW TO INSTAL ===
#  Execute
#    ./install_bashrc
#
# === HOW TO MAINTAIN ===
#
# It is split into two .git repositories.  The first is public and you can get
#   that code by executing:
#  git clone git://github.com/cep21/jackbash.git
#
# The second is private.  You should make your own .git repository inside $HOME/.bash/group
#   Put private information there, like your email address or SSH keys
#


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
export GIT_CEILING_DIRECTORIES=`echo $HOME | sed 's#/[^/]*$##'`  # Either /home(linux) or /Users(mac)
export HISTFILESIZE=1000000000
export HISTSIZE=1000000
export PROMPT_COMMAND='history -a'
export BROWSER='firefox'
export LANG='en_US.utf8'
if [ -f "$HOME/.inputrc" ]; then
  export INPUTRC="$HOME/.inputrc"
fi;
export MAN_AUTOCOMP_FILE="/tmp/man_completes_`whoami`"

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
shopt -s histappend   # Append to history rather than overwrite

# Aliases
alias ls='ls -h $LS_COLOR'
alias la='ls -lah $LS_COLOR'
alias ll='ls -lh $LS_COLOR'
alias ssh='ssh -A'
alias g='git'
alias top='top $TOP_OPTIONS'
alias rcopy='rsync -az --stats --progress --delete'
alias ..='cl ..'

# Auto completion
complete -cf sudo
complete -cf which
#autocomplete ssh commands with the hostname
complete -W "$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\["`;)" ssh

# autocomplete man commands
function listmans_raw() {
  for dir in $(/usr/bin/man -W | /usr/bin/tr ':' '\n'); do
    find "${dir}" ! -type d -name "*.*" 2>/dev/null | sed -e 's#/.*/##g' | sed -e 's#.[^.]*$##g' | sed -e 's#\.[0123456789].*##g'
  done
}
function regen_man_args() {
  listmans_raw | sort -u > $MAN_AUTOCOMP_FILE
}
function listmans() {
  if [ ! -f $MAN_AUTOCOMP_FILE ]; then
    regen_man_args
  fi;
  cat $MAN_AUTOCOMP_FILE
}
complete -W "$(listmans)" man


#### RANDOM FUNCTIONS #####
# awesome!  CD AND LA. I never use 'cd' anymore...
function cl(){ cd "$@" && la; }
# Two standard functions to change $PATH
add_path() { export PATH="$PATH:$1"; }
add_pre_path() { export PATH="$1:$PATH"; }
# Misc utilities:

# Repeat a command N times.  You can do something like
#  repeat 3 echo 'hi'
function repeat()
{
    local i max
    max=$1; shift;
    for ((i=1; i <= max ; i++)); do
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

#Simple blowfish encryption
function blow()
{
    [ -z "$1" ] && echo 'Encrypt: blow FILE' && return 1
    openssl bf-cbc -salt -in "$1" -out "$1.bf"
}
function fish()
{
    test -z "$1" -o -z "$2" && echo \
        'Decrypt: fish INFILE OUTFILE' && return 1
    openssl bf-cbc -d -salt -in "$1" -out "$2"
}

# Extract based upon file ext
function ex() {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xvjf $1        ;;
             *.tar.gz)    tar xvzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       unrar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xvf $1        ;;
             *.tbz2)      tar xvjf $1      ;;
             *.tgz)       tar xvzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
# Compress with tar + bzip2
function bz2 () {
  tar cvpjf $1.tar.bz2 $1
}

# Google the parameter
function google () {
  links http://google.com/search?q=$(echo "$@" | sed s/\ /+/g)
}

function myip () { 
 # GNU vs BSD hostname
 (hostname -i &> /dev/null)
  if [ $? -eq 0 ]; then
    echo `hostname -i`
  else
    # default to eth0 IP, for MAC
    echo `ipconfig getifaddr en0`
  fi;
}


# anyvi <file>
# run EDITOR on a script no matter where it is
function anyvi()
{
    if [ -e "$1" ] || [ -f "$1" ]; then
        $EDITOR $1
    else
        $EDITOR `which $1`
    fi
}
complete -cf anyvi        #autocomplete the anyvi command

# Grep for a process while at the same time ignoring the grep that
# you're running.  For example
#   ps awxxx | grep java
# will show "grep java", which is probably not what you want
function psgrep(){
  local OUTFILE=`mktemp /tmp/psgrep.XXXXX`
  ps awxxx > $OUTFILE
  grep $@ $OUTFILE
  rm $OUTFILE
}

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

# I like this prompt for a few reasons:
# (1) The time shows when each command was executed, when I get back to my terminal
# (2) Git information really important for git users
# (3) Prompt color is red if I'm root
# (4) The last part of the prompt can copy/paste directly into an SCP command
# (5) Color highlight out the current directory because it's important
# (6) The export PS1 is simple to understand!
# (7) If the prev command error codes, the prompt '>' turns red
export PS1="$Y\t$N $W"'$(__git_ps1 "(%s) ")'"$N$PROMPT_COLOR\u@\H$N:$C\w$N\n"'$CURSOR_PROMPT '
# TODO: Find out why my $R and $N shortcuts don't work here!!!
export PROMPT_COMMAND='if [ $? -ne 0 ]; then CURSOR_PROMPT=`echo -e "\033[0;31m>\033[0m"`; else CURSOR_PROMPT=">"; fi;'

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

# remove duplicate path entries and preserve PATH order
export PATH=$(echo $PATH | awk -F: '
{ start=0; for (i = 1; i <= NF; i++) if (!($i in arr) && $i) {if (start!=0) printf ":";start=1; printf "%s", $i;arr[$i]}; }
END { printf "\n"; } ')


# .bashrc   -*- shell-script -*-

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

## make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
unset LESSOPEN LESSCLOSE

# set true for a colored prompt, if the terminal has the capability
force_color_prompt=true

# set a fancy prompt (non-color, unless we know we "want" color)
case $TERM in
    (*-color)
        color_prompt=true
        ;;
    (xterm*|rxvt*|eterm*)
        color_prompt=false
        ;;
esac

if ${force_color_prompt}; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=true
    else
	color_prompt=false
    fi
fi

if ${color_prompt}; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Set our shell prompt
if [[ -x ~/.local/bin/my-prompt-command.sh ]]; then
    __my_prompt_command () { PS1=$( ~/.local/bin/my-prompt-command.sh "$?" ); }
    PROMPT_COMMAND=( __my_prompt_command )
else
    unset PROMPT_COMMAND
fi

shopt -s globstar extglob # nullglob

# Email
case $( hostname -d ) in
    "" | *mauger* | *michael* )
        EMAIL='michael@mauger.com'
        ;;
    *)
        EMAIL=${LOGNAME}@$( hostname -d )
        ;;
esac
export EMAIL

# Function definitions.
if [ -f ~/.bash_functions ]; then
    # shellcheck source=.bash_functions
    source ~/.bash_functions
fi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    # shellcheck source=.bash_aliases
    source ~/.bash_aliases
fi

# Set PATH
clean_path
add_path ~/go/bin
add_path ~/bin
add_path ~/.local/bin

# Set things for the location
if [[ ${MY_LOCATION} ]]; then
    if [[ -f ~/.bashrc_${MY_LOCATION} ]]; then
        # shellcheck source=/dev/null
        source ~/.bashrc_"${MY_LOCATION}"
    fi

    if [[ -f ~/.bash_aliases_${MY_LOCATION} ]]; then
        # shellcheck source=/dev/null
        source ~/.bash_aliases_"${MY_LOCATION}"
    fi

    if [[ -f ~/.bash_functions_${MY_LOCATION} ]]; then
        # shellcheck source=/dev/null
        source ~/.bash_functions_"${MY_LOCATION}"
    fi
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    # shellcheck source=/dev/null
    source /etc/bash_completion
fi

#

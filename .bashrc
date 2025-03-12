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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case $TERM in
    (*-color)
        color_prompt=true
        ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=true

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
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case $TERM in
xterm*|rxvt*|eterm*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
__my_prompt_command () { PS1=$( ~/Projects/my-config/bin/prompt.sh "$?" ); }
PROMPT_COMMAND=( __my_prompt_command )

shopt -s globstar extglob

# enable color support of ls and also add handy aliases
if [[ $- = *i* ]]; then
    if [ -x /usr/bin/dircolors ]; then
        if [[ -r ~/.dircolors ]]; then
            eval $(TERM=ansi dircolors -b ~/.dircolors)
        else
            eval $(TERM=ansi dircolors -b)
        fi

        alias ls='ls --color=auto'
        alias dir='dir --color=auto'
        alias vdir='vdir --color=auto'

        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
fi

# some more ls aliases
alias ll='ls -AlhG --color=auto --group-directories-first --file-type '  # including -B hides ~ backups
alias la='ls -A --file-type '
alias l='ls -C --file-type '

alias open='xdg-open '
alias pbcopy='xsel --clipboard --input '
alias pbpaste='xsel --clipboard --output '

# Emacs
export ALTERNATE_EDITOR=
if [[ -z $( type -t e ) ]]; then
    alias e='emacsclient --create-frame '
fi
export EDITOR=e
if [[ -z ${INSIDE_EMACS} ]]; then
    alias ee='emacs --quick --no-window-system --eval "(set-variable '"'"'frame-background-mode '"'"'dark)"'
    alias ekill='emacsclient --alternate-editor false --tty --eval \(save-buffers-kill-emacs\) '
fi

alias cp='cp -i '
alias mv='mv -i '
alias rm='rm -i '

alias uctl='systemctl --user '
alias ujnl='journalctl --user --pager-end --unit '

# export PGDATA=/usr/local/pgsql/data/

if [[ -z $( type -t guile ) ]]; then
    if [[ $( type -t guile3.0 ) == file ]]; then
        alias guile=$( type -p guile3.0 )
    elif [[ $( type -t guile2.2 ) == file ]]; then
        alias guile=$( type -p guile2.2 )
    fi
fi

# Enable powerline in non emacs shell sessions
if [[ -z ${INSIDE_EMACS} ]]; then
    if [[ -x $(/usr/bin/which powerline-daemon 2> /dev/null) ]]; then
        powerline-daemon -q
        POWERLINE_BASH_COMPLETION=1
        POWERLINE_BASH_SELECT=1
        . /usr/share/powerline/bash/powerline.sh
    fi
fi

# Path definitions
if [[ -d ${HOME}/.local/bin ]]; then
    PATH="${HOME}/.local/bin:${PATH}"
fi

if [[ -d ${HOME}/bin ]]; then
    PATH="${HOME}/bin:${PATH}"
fi

if [[ -d ${HOME}/go/bin ]]; then
    PATH="${HOME}/go/bin:${PATH}"
fi
export PATH

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

alias pkgup='sudo dnf --refresh -y update '
#

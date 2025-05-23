# .bash_aliases  -*- shell-script -*-

# enable color support of ls and also add handy aliases
if [[ $- = *i* ]]; then
    if type -p dircolors &>/dev/null; then
        if [[ -r ~/.dircolors ]]; then
            eval $( sort ~/.dircolors | TERM=ansi dircolors --sh )
        else
            eval $( TERM=ansi dircolors --sh )
        fi

        alias ls='ls --color=auto '
        alias dir='dir --color=auto '
        alias vdir='vdir --color=auto '

        alias grep='grep --color=auto '
        alias fgrep='fgrep --color=auto '
        alias egrep='egrep --color=auto '
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

#

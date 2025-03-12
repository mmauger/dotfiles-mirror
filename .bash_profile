# .bash_profile

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

# User specific environment and startup programs

# if [[ -d ${HOME}/pgdata ]]; then
#     PGDATA="${HOME}/pgdata"
#     export PGDATA
# fi

MY_EMACS_CONFIG=home
export MY_EMACS_CONFIG

# (sleep 10 && systemctl --user restart emacs) &

#

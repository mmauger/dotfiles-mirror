# .bash_profile

MY_LOCATION=home
export MY_LOCATION

MY_EMACS_CONFIG=home
export MY_EMACS_CONFIG

export PATH
clean_path
add_path ~/.local/bin
add_path ~/bin
add_path ~/go/bin

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

#

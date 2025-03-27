# .bash_profile

MY_LOCATION=home
export MY_LOCATION

MY_EMACS_CONFIG=home
export MY_EMACS_CONFIG

# Propagate location-specific configuration
function location-config { # config-path printf-include
    local CONFIG=$1
    local INCLUDE=$2
    local CONFIG_DIR;  CONFIG_DIR="$( dirname "${CONFIG}" )"
    local CONFIG_BASE; CONFIG_BASE="$( basename "${CONFIG}" )"
    local CONFIG_EXT;  CONFIG_EXT="${CONFIG_BASE##*.}"
    if [[ ${CONFIG_EXT} == "${CONFIG_BASE}" ]]; then
        CONFIG_EXT=
    else
        CONFIG_EXT=".${CONFIG_EXT}"
        CONFIG_BASE="${CONFIG_BASE%${CONFIG_EXT}}"
    fi
    local LOCATION_CONFIG="${CONFIG_DIR}/${CONFIG_BASE}_${MY_LOCATION}${CONFIG_EXT}"
    local INCLUDE_LINE; INCLUDE_LINE="$( printf "${INCLUDE}" "${LOCATION_CONFIG}" )"

    if [[ -f ${CONFIG} && -f ${LOCATION_CONFIG} ]] \
           && ! grep --quiet --fixed-strings --regexp "${INCLUDE_LINE}" "${CONFIG}"
    then
        sed --in-place='~' "\$a ${INCLUDE_LINE}" "${CONFIG}"
    fi
}

location-config ~/.ssh/config 'Include %s'

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
    source ~/.bashrc
fi

export PATH

#

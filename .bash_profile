# .bash_profile
if [ -f /etc/profile ]; then source /etc/profile; fi

MY_LOCATION=home
export MY_LOCATION

MY_EMACS_CONFIG=home
export MY_EMACS_CONFIG

# Propagate location-specific configuration
function location-config { # config-path printf-include
    local CONFIG=$1
    local INCLUDE=$2
    local CONFIG_DIR; CONFIG_DIR=$( dirname "${CONFIG}" )
    local CONFIG_BASE; CONFIG_BASE=$( basename "${CONFIG}" )
    local CONFIG_EXT=${CONFIG_BASE##*.}
    if [[ ${CONFIG_EXT} == "${CONFIG_BASE}" ]]; then
        CONFIG_EXT=
    else
        CONFIG_EXT=".${CONFIG_EXT}"
        CONFIG_BASE=${CONFIG_BASE%"${CONFIG_EXT}"}
    fi
    local LOCATION_CONFIG="${CONFIG_DIR}/${CONFIG_BASE}_${MY_LOCATION}${CONFIG_EXT}"
    local INCLUDE_LINE
    # spellcheck disable=SC2059
    INCLUDE_LINE=$( printf "${INCLUDE}" "${LOCATION_CONFIG}" )

    if [[ -f ${CONFIG} && -f ${LOCATION_CONFIG} ]] \
           && ! grep --quiet --fixed-strings --regexp "${INCLUDE_LINE}" "${CONFIG}"
    then
        sed --in-place='~' "\$a ${INCLUDE_LINE}" "${CONFIG}"
    fi
}

location-config ~/.ssh/config 'Include %s'

# add flatpak commands so that elisp (executable-find) will succeed
function flatpak-wrapper { # dir
    local DIR=$1
    local APP CMD FIL LIN VER
    local -a APP_LIST=()
    local APPS=''
    local WRAP=' FLATPAK EXEC WRAPPER '
    if command -v flatpak &> /dev/null; then
        APPS=$( flatpak list --app --columns=application | sed 1d )
        mapfile -t APP_LIST <<< "${APPS}"
    fi

    # Remove unneeded wrappers
    while read -r -d $'\0' FIL; do
        if [[ ${FIL} != *~ ]]; then
            LIN=$( grep --regexp "^#${WRAP}" "${FIL}" )
            APP=$( cut --delimiter ' ' --fields 5 <<< "${LIN}" )
            VER=$( cut --delimiter ' ' --fields 6 <<< "${LIN}" )
            if [[ ${VER} != ${FLATPAK_WRAPPER_VERSION} ]] \
                   || ! grep --quiet --fixed-strings --line-regexp --regexp "${APP}" <<< "${APPS}"; then
                mv --force "${FIL}" "${FIL}~"
            fi
        fi
    done < <( find "${DIR}" \
                   -mindepth 1 \
                   -maxdepth 1 \
                   -type f \
                   -executable \
                   -exec grep --regexp "^#${WRAP}" --files-with-matches --null {} \;
         )

    # Create new wrappers
    for APP in "${APP_LIST[@]}"; do
        : "${APP##*.}"
        CMD=${_,,}
        FIL="${DIR}/${CMD}"
        if [[ ! -f ${FIL} ]]; then
            cat > "${FIL}" <<EOF
#! /usr/bin/env sh
#${WRAP} ${APP} ${FLATPAK_WRAPPER_VERSION}

DISPLAY=\${DISPLAY:-':0'}; export DISPLAY
GNOME_SETUP_DISPLAY=\${GNOME_SETUP_DISPLAY:-':1'}; export GNOME_SETUP_DISPLAY
WAYLAND_DISPLAY=\${WAYLAND_DISPLAY:-'wayland-0'}; export WAYLAND_DISPLAY
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${UID}/bus; export DBUS_SESSION_BUS_ADDRESS
flatpak run ${APP} "\$@" > "${TMPDIR:=/tmp}/${CMD}.log" 2>&1 &
EOF
            chmod +x "${FIL}"
        fi
    done
}
FLATPAK_WRAPPER_VERSION=$( type flatpak-wrapper | md5sum | cut -d ' ' -f 1 )

# flatpak-wrapper ~/.local/bin

# Get the aliases and functions
if [[ -f ~/.bashrc ]]; then
    # spellcheck source=./.bashrc
    source ~/.bashrc
fi

export PATH

#

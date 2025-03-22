# .bash_functions -*- shell-script -*-

# Path definitions

## CLEAN_PATH

function clean_path { #
    local oldpath
    mapfile -t oldpath <<< "${PATH//:/$'\n'}"
    local newpath=':'
    for p in "${oldpath[@]}"; do
        if [[ ${newpath} =~ :${p}: ]]; then
            echo >&2 "Remove \`${p}'"
        else
            newpath+="${p}:"
        fi
    done
    : "${newpath##:}"
    PATH="${_%%:}"
}
declare -x clean_path

## ADD_PATH

function add_path { # ENTRY [--before|--after|--prepend|--append]
    local entry
    local prepend=true

    while (( $# > 0 )); do
        case $1 in
            --before | --prepend)
                prepend=true
                shift
                ;;
            --after | --append)
                prepend=false
                shift
                ;;
            *)
                entry=${1%/}
                shift
                ;;
        esac
    done

    if ! grep --fixed-strings --line-regexp --quiet --regexp "${entry}" <<< "${PATH//:/$'\n'}"; then
        if [[ -d ${entry} ]]; then
            if ${prepend}; then
                PATH="${entry}:${PATH}"
            else
                PATH="${PATH}:${entry}"
            fi
        fi
    fi
}
declare -x add_path

## REM_PATH

function rem_path { # ENTRY
    local entry=${1%/}
    local path=":${PATH}:"

    : "${path//:${entry}:/:}"
    : "$( sed 's/::*/:/g' <<< "${_}" )"
    : "${_##:}"
    : "${_%%:}"
    PATH=${_}
}
declare -x rem_path

#

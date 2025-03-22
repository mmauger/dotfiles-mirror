#! /usr/bin/env bash
set -eu -o pipefail

PROG="$( basename "$0" )"
PDIR="$( cd "$( dirname "$0" )" && pwd )"

if (( $# > 0 )) && [[ $1 =~ \'[-]+[Hh](elp)?\' ]]; then
    cat >&2 <<-ENDHELP
	usage: ${PROG}
		Installs files in this repository in your HOME folder.
	ENDHELP
    exit 2
elif (( $# != 0 )); then
    echo >&2 "${PROG}: no arguments accepted"
    exit 1
fi

#

function link-file {  # file
    local -x FILEPATH=$1
    local DIR=$( dirname "${FILEPATH}" )
    local FILE=$( basename "${FILEPATH}" )

    local -x SRC="${PDIR}/${FILEPATH}"
    local RSRC=$( realpath --canonicalize-missing "${SRC}" )
    local -x DST="${HOME}/${FILEPATH}"
    local DDST=$( sed <<< "${DST}" "s#^${HOME}#~#" )
    local RDST=$( realpath --canonicalize-missing "${DST}" )

    echo >&2 '===[' "${DDST}" ']===================='

    if [[ -e ${SRC} ]]; then
        if [[ -e ${DST} ]]; then
            if [[ -h ${DST} && ${RDST} == "${RSRC}" ]]; then
                echo >&2 "${PROG}: file \"${FILEPATH}\" already installed"
            else
                echo >&2 "${PROG}: Destination file \"${DDST}\" is not a link to the source file"
                git diff --stat "${FILEPATH}" "${RDST}"
            fi
        else
            mkdir --parents "$( dirname "${DST}" )"
            ln --symbolic --relative --verbose "${SRC}" "${DST}"
        fi
    else
        echo >&2 "${PROG}: Source file \"${FILEPATH}\" does not exist"
        exit 1
    fi
}

#

cd "${PDIR}"

tree -a \
     -I ${PROG} \
     -I .git \
     -I LICENSE \
     -I README.org

find . -type f -print | sed 's#^[.]/##' | while read -r FILE; do
    case ${FILE} in
        ${PROG})
            ;;
        .git/*)
            ;;
        README*)
            ;;
        LICENSE*)
            ;;
        *)
            link-file "${FILE}"
            ;;
    esac
done

#

#! /usr/bin/env bash
set -eu -o pipefail

PROG="$( basename "$0" )"
PDIR="$( cd "$( dirname "$0" )" && pwd )"

DO_FORCE=false
if (( $# > 0 )) && [[ $1 == --help || $1 == -h ]]; then
    cat >&2 <<-ENDHELP
	usage: ${PROG} [-f | --force]
		Installs files in this repository in your HOME folder.
	options:
	    -f or --force:
	        Link installed files to their source regardless of whether they exist
	        or not.
	ENDHELP
    exit 2
elif (( $# == 1 )); then
    if [[ $1 == --force || $1 == -f ]]; then
        DO_FORCE=true
    else
        echo >&2 "${PROG}: Unrecognized option -- $*"
        exit 1
    fi
elif (( $# > 1 )); then
    echo >&2 "${PROG}: Only one option can be specified -- $*"
    exit 1
fi

#

function link-file { # path/name
    local PATHFILE=$1
    local SRC="${PDIR}/${PATHFILE}"
    local DST="${HOME}/${PATHFILE}"

    if [[ -e "${SRC}" ]]; then
        if [[ -L "${DST}" ]]; then
            if ! [[ "${SRC}" -ef "${DST}" ]]; then
                echo >&2 "${PROG}: ${PATHFILE} is a link but to a different file"
                ls -l "${DST}"
                ( diff --ignore-all-space "${SRC}" "${DST}" | diffstat -s ) || true

                if ${DO_FORCE}; then
                    ln --symbolic --backup --verbose "${SRC}" "${DST}"
                fi

            else
                # file is already linked; do nothing unless --force
                if ${DO_FORCE}; then
                    ln --symbolic --backup --verbose "${SRC}" "${DST}"
                fi
            fi

        elif [[ -e "${DST}" ]]; then
            echo >&2 "${PROG}: ${PATHFILE} is not a link"
            ls -l "${DST}"
            ( diff --ignore-all-space "${SRC}" "${DST}" | diffstat -s ) || true

            if ${DO_FORCE}; then
                ln --symbolic --backup --verbose "${SRC}" "${DST}"
            fi

        else
            ln --symbolic --verbose "${SRC}" "${DST}"
        fi
    fi
}

function set-prot { # DIR
    local DIR=$1
    local SRCDIR="${PDIR}/${DIR}"
    local DSTDIR="${HOME}/${DIR}"
    MODE=$( stat --format=%a "${SRCDIR}" )

    [[ -d "${DSTDIR}" ]] || mkdir --verbose "${DSTDIR}"
    chmod --changes "${MODE}" "${DSTDIR}"
}

#

cd "${PDIR}"

tree -a \
     -I "${PROG}" \
     -I .git \
     -I LICENSE \
     -I README.org
echo

find . -maxdepth 1 -type f -name .\*    -exec chmod --changes 644 \{\} +

if [[ -d .gnupg ]]; then
    find .gnupg -type d                 -exec chmod --changes 700 \{\} +
    find .gnupg -type f                 -exec chmod --changes 600 \{\} +
fi

if [[ -d .ssh ]]; then
    find .ssh   -type d                 -exec chmod --changes 700 \{\} +
    find .ssh   -type f -name \*.pub -prune -o -type f \
                                        -exec chmod --changes 600 \{\} +
    find .ssh   -type f -name \*.pub    -exec chmod --changes 644 \{\} +
fi

if [[ -d .local ]]; then
    find .local -type d                 -exec chmod --changes 755 \{\} +
    if [[ -d .local/share ]]; then
        find .local/share   -type f     -exec chmod --changes 600 \{\} +
    fi
    if [[ -d .local/bin ]]; then
        find .local/bin     -type f     -exec chmod --changes 755 \{\} +
    fi
fi

find . -type d -print | sed 's#^[.]/##' | while read -r DIR; do
    case ${DIR} in
        "${PROG}" | .git* | README* | LICENSE*)
            # Skip. Do nothing
            ;;
        *)
            set-prot "${DIR}"
            ;;
    esac
done

find . -type f -print | sed 's#^[.]/##' | while read -r FILE; do
    case ${FILE} in
        "${PROG}" | .git/* | README* | LICENSE*)
            # Skip. Do nothing
            ;;
        *)
            link-file "${FILE}"
            ;;
    esac
done

#

#!/usr/bin/env bash
set -eu -o pipefail

PROG="$( basename "$0" )"
PDIR="$( cd "$( dirname "$0" )" && pwd )"

if (( $# > 0 )) && [[ $1 =~ \<[-]+[Hh](elp)?\> ]]; then
    cat >&2 <<-ENDHELP
	usage: ${PROG} LOCAL REMOTE [MERGED BASE]
	where:
	    All supplied by `git mergetool`
	    LOCAL - local repo file
	    REMOTE - remote repo file
	    MERGED
	    BASE
	ENDHELP
    exit 2
fi

# test args
if ! (( $# == 2 + 1 || $# == 4 + 1 )); then
    echo 1>&2 "Usage: ${PROG} LOCAL REMOTE [MERGED BASE]"
    exit 1
fi

# args
_LOCAL=$1
_REMOTE=$2
_MERGED=${3:-${_REMOTE}}
_BASE=${4:-""}
if [[ -n ${_BASE} ]]; then
    _EDIFF=ediff-merge-files-with-ancestor
    _EVAL="${_EDIFF} \"${_LOCAL}\" \"${_REMOTE}\" \"${_BASE}\" nil \"${_MERGED}\""
elif [[ ${_REMOTE} == ${_MERGED} ]]; then
    _EDIFF=ediff
    _EVAL="${_EDIFF} \"${_LOCAL}\" \"${_REMOTE}\""
else
    _EDIFF=ediff-merge-files
    _EVAL="${_EDIFF} \"${_LOCAL}\" \"${_REMOTE}\" nil \"${_MERGED}\""
fi

# run emacs
emacsclient --eval "(${_EVAL})"

# check modified file
if grep --extended-regexp '^(<<<<<<<|=======|>>>>>>>|####### Ancestor)' "${_MERGED}"; then
    _TMPNAM=$( basename "${_MERGED}" )
    _MERGEDSAVE=$( mktemp --dry-run --tmpdir "${PWD}" "${_TMPNAM}.XXXXXXXXXX" )
    cp "${_MERGED}" "${_MERGEDSAVE}"
    echo 1>&2 "${PROG}: Oops! Conflict markers detected in \"${_MERGED}\"."
    echo 1>&2 "    Saved your changes to \"${_MERGEDSAVE}\"."
    echo 1>&2 "    Exiting with code 1."
    exit 1
fi

exit
#

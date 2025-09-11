# sourced file   -*- shell-script; sh-shell: bash -*-
# shellcheck shell=bash

# In ~/.bashrc
#   __my_prompt_command () { PS1=$( source ~/my-config/prompt.sh "$?" ); }
#   PROMPT_COMMAND=( __my_prompt_command )
#

RC=$1

## Establish colors
declare -A COLORS=()
if [[ -n $( tput setaf 0 ) ]]; then
    # color settings for setaf/setab
    FGCOLOR=setaf
    BGCOLOR=setab
    COLORS=( [black]=0 [red]=1 [green]=2 [yellow]=3
             [blue]=4 [magenta]=5 [cyan]=6 [white]=7 )
else
    # color settings for setf/setb
    FGCOLOR=setf
    BGCOLOR=setb
    COLORS=( [black]=0 [blue]=1 [green]=2 [cyan]=3
             [red]=4 [magenta]=5 [yellow]=6 [white]=7 )
fi

NORM="\\[$( tput sgr0 )\\]"
for C in ${!COLORS[@]}; do
    V=${C^^}
    FG=$( tput ${FGCOLOR} ${COLORS[$C]} )
    BG=$( tput ${BGCOLOR} ${COLORS[$C]} )
    declare ${V}="\\[${FG}\\]"
    declare R${V}="\\[${BG}\\]"
done

## user and host
WHONAME='\u@\h'
case "${USER}@${HOSTNAME}" in
    "michael@michael-laptop")
        WHONAME="(my-laptop)"
        ;;
    *)
        ;;
esac
WHO="${GREEN}${WHONAME}${NORM}"

## working directory
: "${PWD}"
: "${_#"${HOME}/Projects/"}"
: "${_#"${HOME}/Project/"}"
: "${_#"${HOME}/Development/"}"
: "${_#"${HOME}/Develop/"}"
PROJECT=$_
if [[ ${PROJECT} == "${PWD}" ]];then
    PROJECT='\w'
fi
WHERE="  ${YELLOW}${PROJECT}${NORM}"

## vc state
has_vc() { command -v "$1" 2> /dev/null; }
BRANCHNAME=
if [[ -z ${BRANCHNAME} && -n $( has_vc git ) ]]; then
    : "$( git branch --show-current 2>/dev/null )"
    BRANCHNAME=${_:+git:$_}
fi
if [[ -z ${BRANCHNAME} && -n $( has_vc svn ) ]]; then
    : "$( svn info 2>/dev/null \
              | grep -Ee '^URL:' \
              | grep -Eo '(tags|branches)/[^/]+|trunk' \
              | grep -Eo '[^/]+$' )"
    BRANCHNAME=${_:+svn:$_}
fi
WHAT=
if [[ -n ${BRANCHNAME} ]]; then
    WHAT="  ${CYAN}${BRANCHNAME}${NORM}"
fi

## python env
VENV=
if (( PIPENV_ACTIVE == 1 )); then
    if [[ -n ${VIRTUAL_ENV+set} && -f ${VIRTUAL_ENV}/pyvenv.cfg ]]; then
        VENVNAME=$( awk -F '[ ]*[=][ ]*' '$1 == "prompt" { print $2 }' \
                        "${VIRTUAL_ENV}/pyvenv.cfg" )
        VENV="  ${MAGENTA}${VENVNAME}${NORM}"
    fi
fi

## Prompt time
WHEN="[${WHITE}\\D{%a%b%d %-I:%M%P}${NORM}] "

## Last error
if (( RC != 0 )); then
    ERR="${RRED} ${RC} ${NORM} "
else
    ERR=''
fi

# return our new prompt string
printf "\n╭╴%s%s%s%s\n╰╴%s%s\\$ " \
       "${WHO}" "${WHERE}" "${WHAT}" "${VENV}" "${ERR}" "${WHEN}"

#

# sourced file   -*- shell-script -*-
# In ~/.bashrc
#   __my_prompt_command () { PS1=$( source ~/my-config/prompt.sh "$?" ); }
#   PROMPT_COMMAND=( __my_prompt_command )
#

RC=$1

GREEN='\[\e[;32m\]'
YELLOW='\[\e[;33m\]'
MAGENTA='\[\e[;35m\]'
CYAN='\[\e[;36m\]'
RRED='\[\e[;41m\]'
NORMAL='\[\e[0m\]'

# user and host
case "${USER}@${HOSTNAME}" in
    "michael@michael-laptop")
        WHONAME="(my-laptop)"
        ;;
    *)
        WHONAME='\u@\h'
        ;;
esac
WHO="${GREEN}${WHONAME}${NORMAL}"

# working directory
: ${PWD}
: ${_#${HOME}/Projects/}
: ${_#${HOME}/Project/}
: ${_#${HOME}/Development/}
: ${_#${HOME}/Develop/}
PROJECT=$_
if [[ ${PROJECT} == ${PWD} ]];then
    PROJECT='\w'
fi
WHERE="  ${YELLOW}${PROJECT}${NORMAL}"

# vc state
WHAT=
BRANCHNAME=$( git branch --show-current 2>/dev/null )
if [[ -n ${BRANCHNAME} ]]; then
    WHAT="  ${CYAN}git:${BRANCHNAME}${NORMAL}"
fi

# python env
VENV=
if (( PIPENV_ACTIVE == 1 )); then
    if [[ -n ${VIRTUAL_ENV+set} && -f ${VIRTUAL_ENV}/pyvenv.cfg ]]; then
        VENVNAME=$( awk -F '[ ]*[=][ ]*' '$1 == "prompt" { print $2 }' "${VIRTUAL_ENV}/pyvenv.cfg" )
        VENV="  ${MAGENTA}${VENVNAME}${NORMAL}"
    fi
fi

# Last error
if (( RC != 0 )); then
    ERR="${RRED} ${RC} ${NORMAL} "
else
    ERR=''
fi

# return our new prompt string
echo $"\n╭╴${WHO}${WHERE}${WHAT}${VENV}\n╰╴${ERR}\$ "

#

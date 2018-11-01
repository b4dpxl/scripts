#! /bin/sh

## Script to prompt to launch "script" when opening a terminal to log all output
## Put a call at the end of ~/.bashrc
## and update the LOG_FOLDER path below

LOG_FOLDER="PATH_TO_LOGS_FOLDER"

# end if in "script"
if pstree -s $PPID | grep -qP "\bscript\b" ; then exit 0 ; fi

yes_or_no() {
    while true; do
        read -p "$* [Y/n]: " yn
        case $yn in
            [Yy]*) return 0 ;;  
            [Nn]*) return 1 ;;
            # default = "Y". Change return to "1" to make default "N"
            "") return 0 ;;
        esac
    done
}

RED=$(tput setaf 9)
GRN=$(tput setaf 2)
NC=$(tput sgr0)
PROMPT="[${RED}** ${GRN}\\u${NC}@\\h \\W]\\$ "
yes_or_no "${RED}Log this session?${NC}" && ( script -f ${LOG_FOLDER}/log_`date +'%Y%m%d_%H%M%S.%N'`.txt -c "source ~/.bashrc; env PS1='${PROMPT}' /bin/bash --norc" )

#! /bin/sh

## Script to prompt to launch "script" when opening a terminal to log all output
## Put a call at the end of ~/.bashrc
## and update the LOG_FOLDER path below

LOG_FOLDER=<PATH_TO_LOGS_FOLDER>

SHELL_PROCESS=$(ps -o command= -p `ps -p $PPID -o ppid=` | awk '{print $1}')
test "${SHELL_PROCESS}" = "script" && exit 0
#echo "Not logging yet"

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
NC=$(tput sgr0)
yes_or_no "${RED}Log this session?${NC}" && script -f ${LOG_FOLDER}/log_`date +'%Y%m%d_%H%M%S.%N'`.txt

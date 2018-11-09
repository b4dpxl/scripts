#! /bin/sh

LOG_FOLDER=/pentest/_clients/__logs/
CONSOLE=terminator

yes_or_no() {
    while true; do
        read -p "$* [Y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) return  1 ;;
	    "") return 0 ;;
        esac
    done
}

yes_or_no_or_terminal() {
    while true; do
        read -p "$* [y/n/T]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) return  1 ;;
	    [Tt]*) return 2 ;;
	    "") return 2 ;;
        esac
    done
}

RED=$(tput setaf 9)
GRN=$(tput setaf 2)
NC=$(tput sgr0)
PROMPT="[\[${RED}\]** \[${GRN}\]\\u\[${NC}\]@\\h \\W]\\$ "

if pstree -s $PPID | grep -qP "\-script\b" ; then 
	# already logging, do nothing
	exit 0

elif pstree -s $PPID | grep -qP "\-${CONSOLE}\b" ; then
	# inside terminal, prompt to log or not
	yes_or_no "${RED}Log this session?${NC}" && ( script -f ${LOG_FOLDER}/log_`date +'%Y%m%d_%H%M%S.%N'`.txt -c "source ~/.bashrc; env PS1='${PROMPT}' /bin/bash --norc" )

else
	# inside a regular shell, prompt to launch tmux/terminator or log.
	yes_or_no_or_terminal "${RED}Launch ${CONSOLE} (T) or log (Y/N) this session?${NC}"
	ret=$?
	if [ $ret -eq 2 ]; then
		nohup ${CONSOLE} &
		# the sleep seems to be necesary to allow terminator to load before killing the current terminal
		# there's probaly a more elegant way to do this, but (shrug)
		sleep 1
		kill -9 $PPID
	elif [ $ret -eq 0 ] ; then
		script -f ${LOG_FOLDER}/log_`date +'%Y%m%d_%H%M%S.%N'`.txt -c "source ~/.bashrc; env PS1='${PROMPT}' /bin/bash --norc" 
	fi
fi


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

yes_or_no_or_tmux() {
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

#SHELL_PROCESS=$(ps -o command= -p `ps -p $PPID -o ppid=` | awk '{print $1}')

if pstree -sAp $PPID | grep -qP "\-script\b" ; then 
	# already logging, do nothing
	exit 0

#if [ "`basename ${SHELL_PROCESS}`" = "${console}" ] ; then
elif pstree -sAp $PPID | grep -qP "\-${console}\b" ; then
	# inside tmux, prompt to log or not
	yes_or_no "${RED}Log this session?${NC}" && ( script -f ${LOG_FOLDER}/log_`date +'%Y%m%d_%H%M%S.%N'`.txt -c "source ~/.bashrc; env PS1='${PROMPT}' /bin/bash --norc" )

#elif [ "`basename ${SHELL_PROCESS}`" != "script" ] ; then
else
	# inside a regular shell, prompt to launch tmux/terminator or log.
	yes_or_no_or_tmux "${RED}Launch ${console} (t) or log (y/n) this session?${NC}"
	ret=$?
	if [ $ret -eq 2 ]; then
		exec $console
	elif [ $ret -eq 0 ] ; then
		( script -f ${LOG_FOLDER}/log_`date +'%Y%m%d_%H%M%S.%N'`.txt -c "source ~/.bashrc; env PS1='${PROMPT}' /bin/bash --norc" )
	fi
fi


#!/bin/bash
#
# Amiel Martin <amiel.martin@gmail.com> 2009-06-03


FUNCTIONS="$(if [[ -f "$f" ]];then echo "$f"; else echo "/etc/backupscripts/$f";fi)"
source functions.sh
source $(conf_file)



rsync_file() {
	if $DORSYNC; then
		for r in ${RSYNC_TO:?no rsync to set, please set RSYNC_TO in conf}; do
			vebegin "rysincing $1 to $r"
			$RSYNC -t -W ${1:?file not set} $r
			veend $?
		done
	else
		vewarn "not running rsync because DORSYNC is false"
	fi
}
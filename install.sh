#!/bin/bash
#
# Amiel Martin <amiel.martin@gmail.com> 2009-06-03
#


FUNCTIONS="$(if [[ -f "$f" ]];then echo "$f"; else echo "/etc/backupscripts/$f";fi)"
source functions.sh
source $(conf_file)

DESTINATION="/etc/backupscripts"

INSTALL_FILES="backupscripts.conf.example functions.sh backup.sh rsync_functions.sh"

if [[ `whoami` != 'root' ]]; then
	eerror "you must run this install script as root"
	exit 1
fi

if [[ -d $DESTINATION ]]; then
	eerror "it looks like the destination ($DESTINATION) already exists. to re-install please remove it"
else
	mkdir $DESTINATION
fi


einfo "coping files"
for file in $INSTALL_FILES; do
	cp -i $file $DESTINATION

done


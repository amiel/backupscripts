#!/bin/bash
#
# Amiel Martin <amiel.martin@gmail.com> 2009-06-03
#


FUNCTIONS="$(if [[ -f "$f" ]];then echo "$f"; else echo "/etc/backupscripts/$f";fi)"
source functions.sh

DESTINATION="/etc/backupscripts"
INSTALL_FILES="backupscripts.conf.example functions.sh backup.sh rsync_functions.sh"
CRONDIR="/etc/cron.daily"


#
# SETUP
#

if [[ `whoami` != 'root' ]]; then
	eerror "you must run this install script as root"
	exit 2
fi

for arg in "$@" ; do
	case "${arg}" in
		-f|--force|--force-install)
			FORCE_INSTALL="yes"
			;;
	esac
done

show_conf_reminder=false
show_reminder() {
	if $show_conf_reminder; then
		echo
		ewarn "Don't forget to configure your conf file at $installed_conf_file"
	fi
}
trap "show_reminder" EXIT


#
# SETUP DESTINATION
#

if [[ -d $DESTINATION ]]; then
	ewarn "it looks like the destination ($DESTINATION) already exists"
	if [[ -z $FORCE_INSTALL ]]; then
		eerror "re-run with -f to force re-instillation (your backupscripts.conf file will remain intact)"
		exit 1
	fi
	ewarn "-f option supplied, overwriting previous instillation"
else
	einfo "creating install destination: $DESTINATION"
	mkdir $DESTINATION
fi


einfo "coping files"
for file in $INSTALL_FILES; do
	cp $file $DESTINATION
done

chmod 755 "$DESTINATION/backup.sh"


installed_conf_file="$DESTINATION/backupscripts.conf"
if [[ -e $installed_conf_file ]]; then
	einfo "keeping your current conf intact"
	source $installed_conf_file
	if [[ -z $CONFIGURED ]] || ! $CONFIGURED; then
		show_conf_reminder=true
	fi
else
	einfo "creating an example conf file at $(conf_file)"
	show_conf_reminder=true
	cp -i "$DESTINATION/backupscripts.conf.example" "$installed_conf_file"
fi


if [[ ! -d "$CRONDIR" ]]; then
	eerror "cannot install symlink for cron because CRONDIR ($CRONDIR) does not exist"
	exit 3
fi

cron_script="$CRONDIR/backup.sh"

if [[ -f $cron_script ]]; then
	ewarn "$cron_script is already a file, backing up to $cron_script.install_backup"
	mv -i $cron_script $cron_script.backup
fi

if [[ -h $cron_script ]]; then
	ewarn "a $cron_script symlink already exists, we'll go ahead and delete it for you"
fi

einfo "installing a symlink from $cron_script to backup.sh"
ln -s "$DESTINATION/backup.sh" $cron_script

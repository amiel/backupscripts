#!/bin/bash
# full and incremental backup script
# created 07 February 2000
# Based on a script by Daniel O'Callaghan <danny@freebsd.org>
# and modified by Gerhard Mourani <gmourani@videotron.ca>
# and modified again (and very heavily) by Amiel Martin <amiel.martin@gmail.com>

FUNCTIONS="$(f=functions.sh; if [[ -f "$f" ]];then echo "$f"; else echo "/etc/backupscripts/$f";fi)"
source $FUNCTIONS
source $(conf_file)
source $(include_file rsync_functions.sh)


if [[ -z $CONFIGURED ]] || ! $CONFIGURED; then
	eerror "Please configure your backupscripts.conf file at $(conf_file)"
	exit 1
fi




DOW=`date +%a`		# Day of the week e.g. Mon
DOM=`date +%d`		# Date of the Month e.g. 27
DM=`date +%d%b`		# Date and Month e.g. 27Sep

# On the 1st of the month a permanet full backup is made
# Every Sunday a full backup is made - overwriting last Sundays backup
# The rest of the time an incremental backup is made. Each incremental
# backup overwrites last weeks incremental backup of the same name.

generate_filename() {
	echo "$BACKUPDIR/$BACKUP_NAME-$1.$TAREXT"
}

# $1 is the filename
# $2 are extra TAR options
do_tar() {
	vebegin "starting backup of $DIRECTORIES"
	$TAR $2 $TAROPTS $1 $DIRECTORIES
	veend $?
}

update_backup_date() {
	# Update full backup date
	local NOW=`date +%d-%b`
	echo $NOW > $TIMEDIR/$BACKUP_NAME-full-date
}



setup_directories() {
	[ -d $BACKUPDIR ] || mkdir -p $BACKUPDIR
	[ -d $TIMEDIR ] || mkdir -p $TIMEDIR
}


setup_directories



# Monthly full backup
if [ $DOM = "01" ]; then
	veinfo "Monthly perminant full backup"
	
	update_backup_date
	file=$(generate_filename $DM)
	do_tar $file
	rsync_file $file
fi

if [ $DOW = "Sun" ]; then # Weekly full backup - overwrite last weeks
	veinfo "Sunday full backup"
	
	update_backup_date
	file=$(generate_filename $DOW)
	do_tar $file
	rsync_file $file

else # Make incremental backup - overwrite last weeks
	veinfo "Daily incremental backup"
	einfo "DAILING BACKUP"
	
	# if there is no backup date, set it to now so we can move on with our lives
	[ -f $TIMEDIR/$BACKUP_NAME-full-date ] || update_backup_date
	
	# Get date of last full backup
	file=$(generate_filename $DOW)
	do_tar $file "--newer `cat $TIMEDIR/$BACKUP_NAME-full-date`"
fi

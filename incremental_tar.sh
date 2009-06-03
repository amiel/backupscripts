#!/bin/sh
# full and incremental backup script
# created 07 February 2000
# Based on a script by Daniel O'Callaghan <danny@freebsd.org>
# and modified by Gerhard Mourani <gmourani@videotron.ca>
# and modified again (and very heavily) by Amiel Martin <amiel.martin@gmail.com>

FUNCTIONS="$(if [[ -f "$f" ]];then echo "$f"; else echo "/etc/backupscripts/$f";fi)"
source functions.sh
source $(conf_file)
source $(include_file rsync_functions.sh)


DOW=`date +%a`		# Day of the week e.g. Mon
DOM=`date +%d`		# Date of the Month e.g. 27
DM=`date +%d%b`		# Date and Month e.g. 27Sep

# On the 1st of the month a permanet full backup is made
# Every Sunday a full backup is made - overwriting last Sundays backup
# The rest of the time an incremental backup is made. Each incremental
# backup overwrites last weeks incremental backup of the same name.


# $1 is what to put in the filename
# $2 are extra TAR options
do_tar(){
	local file="$BACKUPDIR/$COMPUTER-$1.$TAREXT"
	$TAR $2 $TAROPTS $file $DIRECTORIES
	echo $file
}

update_backup_date(){
	# Update full backup date
	local NOW=`date +%d-%b`
	echo $NOW > $TIMEDIR/$COMPUTER-full-date
}

# Monthly full backup
if [ $DOM = "01" ]; then
	local file=$(do_tar $DM)
	rsync_file $file
fi

if [ $DOW = "Sun" ]; then # Weekly full backup

	update_backup_date
	local file=$(do_tar $DOW)
	rsync_file $file

else # Make incremental backup - overwrite last weeks
	# if there is no backup date, set it to now so we can move on with our lives
	[ -f $TIMEDIR/$COMPUTER-full-date ] || update_backup_date
	
	# Get date of last full backup
	local file=$(do_tar $DOW "--newer `cat $TIMEDIR/$COMPUTER-full-date`")
fi

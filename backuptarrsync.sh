#!/bin/sh
# full and incremental backup script
# created 07 February 2000
# Based on a script by Daniel O'Callaghan <danny@freebsd.org>
# and modified by Gerhard Mourani <gmourani@videotron.ca>
# and modified again by Amiel Martin <amiel.martin@gmail.com>

# Change the variables below to fit your computer/backup

COMPUTER=intranet.networktext.com                               # name of this computer
DIRECTORIES="/home_ldap"                        # directoris to backup
BACKUPDIR=/backup/homes                         # where to store the backups
TIMEDIR=/backup/homes/last-full                 # where to store time of full backup
TAR=/bin/tar                                            # name and locaction of tar
TAROPTS="-czf"
TAREXT="tgz"
RSYNC=/usr/bin/rsync
DORSYNC=true    # set to false for it to not rsync
RSYNC_TO="backup@q1.networktext.com:homes_from_intranet"

# You should not have to change anything below here

PATH=/usr/local/bin:/usr/bin:/bin
DOW=`date +%a`                          # Day of the week e.g. Mon
DOM=`date +%d`                          # Date of the Month e.g. 27
DM=`date +%d%b`                 # Date and Month e.g. 27Sep

# On the 1st of the month a permanet full backup is made
# Every Sunday a full backup is made - overwriting last Sundays backup
# The rest of the time an incremental backup is made. Each incremental
# backup overwrites last weeks incremental backup of the same name.


# if NEWER = "", then tar backs up all files in the directories
# otherwise it backs up files newer than the NEWER date. NEWER
# gets it date from the file written every Sunday.
do_tar(){
        local file="$BACKUPDIR/$COMPUTER-$1.$TAREXT"
        $TAR $NEWER $TAROPTS $file $DIRECTORIES


        if $DORSYNC; then
                rsync -t -W $file $RSYNC_TO
        fi
}



# Monthly full backup
if [ $DOM = "01" ]; then
        NEWER=""
        do_tar $DM
fi

# Weekly full backup
if [ $DOW = "Sun" ]; then
        NEWER=""
        NOW=`date +%d-%b`

        # Update full backup date
        echo $NOW > $TIMEDIR/$COMPUTER-full-date
        do_tar $DOW

# Make incremental backup - overwrite last weeks
else   
        # Get date of last full backup
        NEWER="--newer `cat $TIMEDIR/$COMPUTER-full-date`"
        do_tar $DOW
fi


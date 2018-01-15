#!/bin/bash
ver="10.00"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  # get cur dir of this script
progName=$(basename -- "$0")
cd $DIR
echo "$progName $ver  written by Claude Pageau"
: '
 If lockCheckFile=True then script checks pi-timolo.sync file exists
 Otherwise no sync is attempted.  This can be useful for
 Low Bandwidth connections with low frequency of motion tracking events
'

#  Customize rclone sync variables Below
# ---------------------------------------

lockFileCheck=false       # true= Checks for pi-timolo.sync file. false = No Check (case sensitive)
rcloneName="pi-timolo"     # Name of Remote Storage Service
syncRoot="/home/pi/pi-timolo"       # Root Folder to Start
localDir="media/rclone-samples"     # Source Folder on Local
remoteDir="mycam/rclone-samples"    # Destination Folder on Remote
rcloneParam="sync"       # rclone option to perform  Eg  sync, copy, move
                         # IMPORTANT: sync will make remoteDir identical to localDir
                         # so remoteDir Files that do not exist on localDir will be Deleted.
# ---------------------------------------


# Display Users Settings
echo "----------- SETTINGS -------------
Test rclone and will sync rclone-samples folder

lockFileCheck : $lockFileCheck
rcloneName    : $rcloneName
syncRoot      : $syncRoot
localDir      : $localDir
remoteDir     : $remoteDir
rcloneParam   : $rcloneParam   (Options are sync, copy or move)

---------------------------------"

cd $syncRoot   # Change to local rclone root folder
if pidof -o %PPID -x "$progName"; then
    echo "WARN  - $progName Already Running. Only One Allowed."
else
    if [ -f /usr/bin/rclone ]; then    #  Check if rclone installed
        rclone version   # Display rclone version
        if [ ! -d "$localDir" ] ; then   # Check if Local sync Folder Exists
           echo "---------------------------------------------------"
           echo "ERROR : localDir=$localDir Does Not Exist."
           echo "        Please Investigate Bye ..."
           exit 1
        fi
        /usr/bin/rclone listremotes | grep "$rcloneName"  # Check if remote storage name exists
        if [ $? == 0 ]; then    # Check if listremotes found anything
            if $lockFileCheck ; then
                if [ -f /home/pi/pi-timolo/pi-timolo.sync ] ; then  # Check if sync lock file exists
                    echo "INFO  : Found Lock File /home/pi/pi-timolo/pi-timolo.sync"
                    echo "        rclone $rcloneParam is Required."
                else
                    echo "INFO  : Lock File Not Found: /home/pi/pi-timolo/pi-timolo.sync"
                    echo "        rclone $rcloneParam is Not Required."
                    echo "Exiting $progName ver $ver"
                    exit 0
                fi
            fi
            echo "INFO  : /usr/bin/rclone $rcloneParam -v $localDir $rcloneName:$remoteDir"
            echo "        One Moment Please ..."
            /usr/bin/rclone $rcloneParam -v $localDir $rcloneName:$remoteDir
            if [ ! $? -eq 0 ]; then
                echo "---------------------------------------------------"
                echo "ERROR : rclone $rcloneParam Failed."
                echo "        Review rclone %rcloneParam Output for Possible Cause."
            else
                echo "INFO  : rclone $rcloneParam Successful ..."
                if [ -f /home/pi/pi-timolo/pi-timolo.sync ] ; then
                    echo "INFO  : Delete File /home/pi/pi-timolo/pi-timolo.sync"
                    rm -f /home/pi/pi-timolo/pi-timolo.sync
                fi
            fi
        else
            echo "---------------------------------------------------"
            echo "ERROR : rcloneName=$rcloneName Does not Exist"
            echo "INFO  : List Remote Storage Names that are Setup."
            echo "rclone listremotes"
            echo "-------------------"
            rclone listremotes
            echo "--------------------"
            echo "INFO  : If listremotes Listing is Empty, Read pi-timolo Wiki"
            echo "        How to Setup a Remote Storage Name."
        fi
    else
        echo "ERROR : /usr/bin/rclone Not Installed."
        echo "        You Must Install and Configure rclone"
        echo "        See pi-timolo Wiki for Details"
    fi
fi
echo "---------------------------------------------------"
echo "Exiting $progName ver $ver
Bye ..."

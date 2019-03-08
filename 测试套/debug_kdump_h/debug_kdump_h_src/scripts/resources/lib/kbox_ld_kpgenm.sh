#!/bin/bash

#****************************************************************************
#file name	: ld_kpgenm.sh
#description	: bash script for loading panic generator kernel module
#author		: wanghainan
#data		: 2007-07-24
#****************************************************************************

module="kpgen_kbox.ko"
device="kpgen_kbox"
mode="664"

ModName=`lsmod | grep -w $device | awk '{print $1}'`
if [ "$ModName" != "" ]
then
	echo "Module $device has been loaded!"
	exit 0
fi


# Group: since distributions do it differently, look for wheel or use staff
if grep '^staff:' /etc/group > /dev/null; then
    group="staff"
else
    group="wheel"
fi

# remove stale nodes
rm -f /dev/${device}
RProcessTimeout="121"
DProcessTimeout="481"

while getopts "d:r:h" OPTIONS
do
        case $OPTIONS in
                r) RProcessTimeout="$OPTARG";;
                d) DProcessTimeout="$OPTARG";;
                \?) echo "ERROR - Invalid parameter"; echo "ERROR - Invalid parameter" >&2; exit 1;;
                *) echo "ERROR - Invalid parameter"; echo "ERROR - Invalid parameter" >&2; exit 1;;
        esac
done


# invoke insmod with all arguments we got
# and use a pathname, as newer modutils don't look in . by default
/sbin/insmod  ./${module} \
              RProcessTimeout="${RProcessTimeout}"\
              DProcessTimeout="${DProcessTimeout}"

if [ $? -ne 0 ]; then
    exit 1
fi


#########################################
major=`cat /proc/devices | awk "\\$2==\"$device\" {print \\$1}"`

if [ "$major" = "" ]; then
    echo "can't  get major device (kpgenm) number"
    exit 1
else
    :
fi

mknod /dev/${device}1 c $major 1
ln -sf ${device}1  /dev/${device}
# give appropriate group/permissions
#chgrp $group /dev/${device}[0-3]
chmod $mode  /dev/${device}[0-3]

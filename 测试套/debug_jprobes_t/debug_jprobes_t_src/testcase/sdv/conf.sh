#!/bin/bash

### $1 : name of ko
### $2 : grep message
### $3 : echo message
### $4 : grep other message

insmod_success()
{
    if ! insmod $1;then
        echo "insmod $1 fail!\n"
        return 1
    fi
}

insmod_fail()
{
    insmod $1
    dmesg | grep "$2" > /dev/null
    if [ $? -ne 0 ];then
        echo "$1 test fail\n"
        rmmod $1
        return 1
    fi

    return 0
}

grep_mesg()
{
    dmesg | grep "$2" && dmesg | grep "$4" > /dev/null
    if [ $? -ne 0 ];then
        echo "$3\n"
        return 1
    fi
}

set_up()
{
    dmesg -c > /dev/null
}

mount_debugfs()
{
	mount | grep "/sys/kernel/debug"
	if [ $? -ne 0 ];then
	    mount -t debugfs nodev /sys/kernel/debug
	    if [ $? -ne 0 ];then
	        echo "Error: can't mount /sys/kernel/debug and End Test"
	        exit -1
	    fi
	fi
}

clean_up()
{
    rmmod $1
}

rmmod_ko()
{
    rmmod $1
    if [ $? -ne 0 ];then
        echo "rmmod $1 fail\n"
        return 1
    fi
}

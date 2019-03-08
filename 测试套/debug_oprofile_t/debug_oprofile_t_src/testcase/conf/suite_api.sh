#!/bin/bash

#*****************************************************************
#Copyright (C), 1988-2012, Huawei Tech. Co., Ltd.
#Author1:longzhijian@huawei.com
#Date: 2012-01-18
#Description: RATF shell api functions. 
#    
#Modify history:
#--------------------------------------------------------
#Version: 2.1
#Date: 2012-01-18 
#By:shanks
#Modify Description: Add detailed remark 
#******************************************************************/

RTOS_ECHO()
{
    if [ "$1" == "FAIL" ];then
        echo "........ $2 >>>>$1<<<<"
    elif [ "$1" == "PASS" ];then
        echo "........ $2 >>>>$1<<<<"
    else
        echo "....$1"
    fi	
}

rtos_msg_color_help()
{
    rtos_msg_color 35 "rtos_msg_color 35 string: for prompt" 
    rtos_msg_color 31 "rtos_msg_color 31 string: for fail " 
    rtos_msg_color 32 "rtos_msg_color 32 string: for pass " 
    rtos_msg_color 34 "rtos_msg_color 34 string: for nomorl" 
}

rtos_msg_color()
{
    if [ $# -ne 2 ];then
        rtos_msg_color_help
    fi
    echo -e "\033[1;$1m$2\033[0m"

}

RTOS_PASS()
{
    echo "success:$1" >>$2
}

RTOS_FAIL()
{
    echo "error:$1">>$2
}

######################################
#
#check the input is a num or not
#$1 a string
#
str_is_num()
{
    if [ -n "$1" ];then
        local rt=`echo "$1" | sed 's/[0-9]//g'`
        if [ -z $rt ];then
            return 0
        else
            return 1
        fi	
    else
        return 2
    fi	
}

######################################
#
#check a string is an ip or not
#$1 ip string 
#
check_ip_address()
{
    local ip=$1
    local len=`echo $ip | awk -F . '{print NF}'`
    local tmp=""

    if [ $len -ne 4 ];then
        return 1
    fi

    for i in 1 2 3 4
    do   
        tmp=`echo $ip |awk -F . '{print $'$i'}'`
        str_is_num $tmp
        if [ $? -ne 0 ];then
            return 1
        fi
        if [ $tmp -gt 255 ]||[ $tmp -lt 0 ];then
            return 1
        fi    
    done    
    return 0
}

oprofile_ko_check()
{
#    lsmod |grep oprofile  
#    if [ $? -ne 0 ];then
#        rtos_msg_color 31 "there's no oprofile ko has insmod" 
#        return 1
#    fi
    opcontrol --reset
    opcontrol --no-vmlinux
    if [ $? -ne 0 ];then
        rtos_msg_color 31 "opcontrol --no-vmlinux fail"
        return 1
    fi
    
    opcontrol --init
    if [ $? -ne 0 ];then
        rtos_msg_color 31 "opcontrol --init fail"
        return 1
    fi


    if [ ! -d /dev/oprofile ];then
        rtos_msg_color 31 "cannot find /dev/oprofile dir after opcontrol --init"
        return 1
    else
        OPFILES=`ls /dev/oprofile`
        if [ -z "$OPFILES" ];then
            rtos_msg_color 31 "there's no files in /dev/oprofile dir after opcontrol --init"
            return 1
        fi
    fi

    opcontrol --session-dir=/var/lib/oprofile
    if [ $? -ne 0 ];then
        rtos_msg_color 31 "opcontrol --session-dir=/var/lib/oprofile fail"
        return 1
    fi

    return 0
}

get_available_events_str()
{
    ophelp |grep "(counter:">events
    LINE=`cat events |wc -l`
    i=1
    EVENTS_STR=""
    while [ 1 ]
    do
        STR=`cat events |sed -n "$i"p|awk -F : '{print $1}'`
        if [ $i -eq 1 ];then
            EVENTS_STR="$STR"
        else
            EVENTS_STR="$EVENTS_STR $STR"
        fi
        if [ $i -lt $LINE ];then
            i=`expr $i + 1`
        else
            break
        fi
    done
    EVENTS_NUM=$i
    export EVENTS_STR
    export EVENTS_NUM
}

#!/bin/bash

Test_KO=testSysKprobesEnable_003-2.ko
Modue_Name=testSysKprobesEnable_003_2
check_msg="Called jprobe_cpuinfo before cpuinfo_proc_show"

flag=0

creat_cpuinfo_process(){
    for i in `seq 1 10`
    do
        cat /proc/cpuinfo_open > /dev/null 2>&1
    done
}

do_setup(){
    dmesg -c > /dev/null 2>&1

    lsmod | grep "$Modue_Name"
    if [ $? -eq 0 ];then
        rmmod $Modue_Name
    fi

    #mount debugfs
    mount | grep "/sys/kernel/debug"
    if [ $? -eq 0 ];then
        umount /sys/kernel/debug
        if [ $? -ne 0 ];then
            echo "Error: can't umount /sys/kernel/debug and End Test"
            exit -1
        fi
    fi
}

do_test(){
    #Test1: Disable jprobe in KO, and expected jprobe fail
    echo "Test 1 ----------------------------------------------"
    insmod $Test_KO
    if [ $? -ne 0 ];then
        echo "Error: insmod $Test_KO fail"
        flag=`expr $flag + 1`
        return 1
    else
        echo "Pass: insmod $Test_KO success"
    fi

    creat_cpuinfo_process > /dev/null
    dmesg | grep "$check_msg"
    if [ $? -eq 0 ];then
        echo "Error: dmesg contain jprobe info($check_msg) when disable jprobe in KO"
        flag=`expr $flag + 1`
        return 1
    else
        echo "Pass: dmesg don't contain jprobe info($check_msg) when disable jprobe in KO"
    fi
    rmmod $Modue_Name 
    if [ $? -ne 0 ];then
        echo "Error: rmmod $Modue_Name fail"
        flag=`expr $flag + 1`
        return 1
    fi

    #Test2: Echo 1 into /sys/kernel/debug/kprobes/enabled, and expected jprobe still fail
    echo "Test 2 ----------------------------------------------"
    dmesg -c > /dev/null 2>&1
    mount -t debugfs -o debug none /sys/kernel/debug
    echo 1 > /sys/kernel/debug/kprobes/enabled
    if [ $? -ne 0 ];then
        echo "Error: write 1 into /sys/kernel/debug/kprobes/enabled fail"
        flag=`expr $flag + 1`
        return 1
    else
        echo "Pass: write 1 into /sys/kernel/debug/kprobes/enabled success"
    fi

    insmod $Test_KO
    if [ $? -ne 0 ];then
        echo "Error: insmod $Test_KO fail"
        flag=`expr $flag + 1`
        return 1
    else
        echo "Pass: insmod $Test_KO success"
    fi
    creat_cpuinfo_process > /dev/null
    dmesg | grep "$check_msg"
    if [ $? -eq 0 ];then
        echo "Error: dmesg contain jprobe info($check_msg) when echo 1 into /sys/kernel/debug/kprobes/enabled"
        flag=`expr $flag + 1`
        return 1
    else
        echo "Pass: dmesg don't contain jprobe info($check_msg) when echo 1 into /sys/kernel/debug/kprobes/enabled"
    fi 
}

clean_env(){
    lsmod | grep "$Modue_Name" | grep -v 'grep'
    if [ $? -eq 0 ];then
        rmmod $Modue_Name
        if [ $? -ne 0 ];then
            echo "Error in clean_env: rmmod $Modue_Name fail"
            flag=`expr $flag + 1`
        fi
    fi

    mount | grep "/sys/kernel/debug"
    if [ $? -eq 0 ];then
        umount /sys/kernel/debug
        if [ $? -ne 0 ];then
            echo "Error in clean_env: can't umount /sys/kernel/debug and End Test"
            flag=`expr $flag + 1`
        fi
    fi

    dmesg -c > /dev/null 2>&1
}

do_setup && do_test
clean_env

exit $flag


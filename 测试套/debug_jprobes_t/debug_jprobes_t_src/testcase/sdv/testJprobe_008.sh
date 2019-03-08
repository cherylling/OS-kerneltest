#!/bin/bash

. conf.sh

KO=testJprobe_008.ko
grep_dmesg1="register_jprobe pass"
echo_mesg1="register_jprobe failed!"
grep_dmesg2="jprobe_icmp_echo"
echo_mesg2="Active jprobe failed!"
ip=`ifconfig |grep "inet addr:"| grep -v "127" | awk -F":" '{print $2}'|awk '{print $1}'`
ip_flag=`ifconfig |grep "inet addr:"| grep -v "127" | grep "128" | wc -l`
hostip=128.20.221.100

set_up
insmod_success $KO || exit 1

if ! grep_mesg "$KO" "$grep_dmesg1" "$echo_mesg1" ; then
        clean_up $KO
        exit 1
fi

if [ $ip_flag -lt 1 ]; then
	rmmod_ko $KO || exit 1
	exit 0
fi

ssh -o "StrictHostKeyChecking no" root@$hostip "ping -c 3 -w 4 $ip" 2>/dev/null &
sleep 5

if ! grep_mesg "$KO" "$grep_dmesg2" "$echo_mesg2" ; then
        clean_up $KO
        exit 1
fi

rmmod_ko $KO || exit 1

exit 0

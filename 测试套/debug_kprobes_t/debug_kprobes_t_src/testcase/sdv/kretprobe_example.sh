#!/bin/bash

RET=0

if [ "$(uname -r)" \< "4.2" ];then
	addr=`cat /proc/kallsyms | grep "\<do_fork\>" | awk '{print $1}'`
	symbol_name=do_fork
else
	addr=`cat /proc/kallsyms | grep "\<_do_fork\>" | awk '{print $1}'`
	symbol_name=_do_fork
fi
dmesg -c > /dev/null

insmod ./kretprobe_example.ko
if [ $? -ne 0 ];then
	RET=$(($RET+1))
fi

dmesg | grep "Planted return probe at $symbol_name: $addr"
if [ $? -ne 0 ];then
	echo "Set kretprobe failed!"
	RET=$(($RET+2))
fi

ls > /dev/null
dmesg | grep "do_fork returned"
if [ $? -ne 0 ];then
        echo "Active kretprobe failed!"
	RET=$(($RET+4))
fi

rmmod kretprobe_example.ko
if [ $? -ne 0 ];then
        RET=$(($RET+8))
fi
             
echo RET=$RET
exit $RET

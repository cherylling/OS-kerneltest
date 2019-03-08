#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
ret=0

file_rrr="affected_cpus bios_limit cpuinfo_max_freq cpuinfo_min_freq cpuinfo_transition_latency \
        related_cpus scaling_available_frequencies scaling_available_governors scaling_cur_freq \
        scaling_driver"
file_rwrr="scaling_governor scaling_max_freq scaling_min_freq scaling_setspeed"
file_r="cpuinfo_cur_freq"

i=1
while [ $i -lt $cpu_num ]
do
	saved_state=`cat /sys/devices/system/cpu/cpu$i/online`
	
	echo "offline cpu $i"
        echo 0 > /sys/devices/system/cpu/cpu$i/online
        for file in $cpufreq_files
        do
                if [ -e /sys/devices/system/cpu/cpu$i/cpufreq/$file ]
                then
                        echo "/sys/devices/system/cpu/cpu$i/cpufreq/$file is exist"
                        ret=$(($ret+1))
                fi
        done

	echo "online cpu $i"
	echo 1 > /sys/devices/system/cpu/cpu$i/online

	for file in $file_rrr
        do
                ls -l /sys/devices/system/cpu/cpu$i/cpufreq/$file |grep "\-r--r--r--"
                if [ $? -ne 0 ]
                then
                        ret=$(($ret + 1))
                fi
        done

        for file in $file_rwrr
        do
                ls -l /sys/devices/system/cpu/cpu$i/cpufreq/$file |grep "\-rw-r--r--"
                if [ $? -ne 0 ]
                then
                        ret=$(($ret + 1))
                fi
        done

        for file in $file_r
        do
                ls -l /sys/devices/system/cpu/cpu$i/cpufreq/$file |grep "\-r--------"
                if [ $? -ne 0 ]
                then
                        ret=$(($ret + 1))
                fi
        done

	echo $saved_state > /sys/devices/system/cpu/cpu$i/online
	i=$(($i+1))
done

exit $ret


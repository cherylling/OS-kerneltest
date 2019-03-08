#!/bin/bash

source ./cpufreq_conf.sh
cpu_num=`./cpu_num`

ret=0
i=0

for (( i=0; i<$cpu_num; i++ ))
do
	governor="`cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor`"
	if [ "$governor" != "performance" ]; then
		echo "cpu$i is not performance governor."
		ret=$(($ret + 1))
	fi
done

exit $ret

#!/bin/bash

source ./cpufreq_conf.sh

cpu_num=`./cpu_num`
if [ $cpu_num -lt 2 ]; then
	echo "this cases is running in smp system"
	exit 1
fi

ret=0

# save cpu0 and cpu1 env
saved_governors0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
saved_governors1=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor`

#cpu0 to test userspace governor and cpu1 to test performance governor
list_freq0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`
list_freq1=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_available_frequencies`
mid_freq=`middle $list_freq0`
max_freq=`max $list_freq1`

echo "userspace" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo $mid_freq > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed

./cpu_load 0 80 &
pid=$!
sleep 1
cur_freq=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
if [ $cur_freq != $mid_freq ]
then
        echo "core 0 : userspace governor test failed !"
        ret=$(($ret+1))
else
        echo "core 0 : userspace governor test passed !"
fi

cur_freq=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`
if [ $cur_freq != $max_freq ]
then
        echo "core 1 : performance governor test failed !"
        ret=$(($ret+1))
else
        echo "core 1 : performance governor test passed !"
fi

#restore governors
kill -9 $pid
echo $saved_governors0 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $saved_governors1 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor


exit $ret


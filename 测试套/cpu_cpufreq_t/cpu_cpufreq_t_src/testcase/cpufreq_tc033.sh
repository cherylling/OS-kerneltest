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
max_freq0=`max $list_freq0`
max_freq1=`max $list_freq1`

echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "conservative" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

./cpu_load 0 80 &
pid0=$!
./cpu_load 1 80 &
pid1=$!
sleep 5

cur_freq0=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
sleep 1
cur_freq1=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`
sleep 1
cur_freq2=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`

cur_freq=`max $cur_freq0 $cur_freq1 $cur_freq2`
if [ $cur_freq != $max_freq0 ]
then
        echo "core 0 : ondemand governor test failed !"
        ret=$(($ret+1))
else
        echo "core 0 : ondemand governor test passed !"
fi

cur_freq0=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`
sleep 1
cur_freq1=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`
sleep 1
cur_freq2=`cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq`

cur_freq=`max $cur_freq0 $cur_freq1 $cur_freq2`
if [ $cur_freq != $max_freq1 ]
then
        echo "core 1 : conservative governor test failed !"
        ret=$(($ret+1))
else
        echo "core 1 : conservative governor test passed !"
fi

#restore governors
kill -9 $pid0
kill -9 $pid1
echo $saved_governors0 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo $saved_governors1 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

exit $ret


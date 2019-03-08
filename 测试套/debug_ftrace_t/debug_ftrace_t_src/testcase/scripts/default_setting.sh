#!/bin/bash
set -x

[ -d /sys/kernel/debug -a $(ls /sys/kernel/debug |wc -l) -gt 0 ] && umount /sys/kernel/debug

mount -t debugfs nodev /sys/kernel/debug
if [ $? -ne 0 ];then
    echo "mount -t debugfs nodev /sys/kernel/debug fail"
    exit 1
fi

echo "default_tracer test pass"
exit 0

#!/bin/bash

. conf.sh

KO=testDisableJprobe_005.ko
grep_dmesg="disable_jprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

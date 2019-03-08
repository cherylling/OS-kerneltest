#!/bin/bash

. conf.sh

KO=testDisableKretprobe_004.ko
grep_dmesg="disable_kretprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

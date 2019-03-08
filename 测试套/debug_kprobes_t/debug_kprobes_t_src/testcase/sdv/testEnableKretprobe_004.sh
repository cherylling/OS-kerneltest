#!/bin/bash

. conf.sh

KO=testEnableKretprobe_004.ko
grep_dmesg="enable_kretprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

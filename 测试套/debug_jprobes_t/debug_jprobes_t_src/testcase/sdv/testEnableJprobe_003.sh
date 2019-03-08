#!/bin/bash

. conf.sh

KO=testEnableJprobe_003.ko
grep_dmesg="enable_jprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

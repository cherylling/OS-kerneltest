#!/bin/bash

. conf.sh

KO=testEnableKretprobe_003.ko
grep_dmesg="enable_kretprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

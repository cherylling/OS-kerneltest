#!/bin/bash

. conf.sh

KO=testEnableKprobe_004.ko
grep_dmesg="enable_kprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

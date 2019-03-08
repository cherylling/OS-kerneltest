#!/bin/bash

. conf.sh

KO=testDisableKprobe_004.ko
grep_dmesg="disable_kprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

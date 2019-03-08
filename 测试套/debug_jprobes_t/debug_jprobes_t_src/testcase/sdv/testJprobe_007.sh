#!/bin/bash

. conf.sh

KO=testJprobe_007.ko
grep_dmesg="register_jprobe2 fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

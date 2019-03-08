#!/bin/bash

. conf.sh

KO=testRegKprobe_004.ko
grep_dmesg="register_kprobe failed"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

#!/bin/bash

. conf.sh

KO=testRegKretprobes_004.ko
grep_dmesg="register_kretprobe failed"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

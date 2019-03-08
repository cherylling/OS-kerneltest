#!/bin/bash

. conf.sh

KO=testKprobes_009.ko
grep_dmesg="register_kretprobe fail"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

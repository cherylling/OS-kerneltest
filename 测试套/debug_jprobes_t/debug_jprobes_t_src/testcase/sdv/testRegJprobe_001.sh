#!/bin/bash

. conf.sh

KO=testRegJprobe_001.ko
grep_dmesg="register_jprobe failed"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

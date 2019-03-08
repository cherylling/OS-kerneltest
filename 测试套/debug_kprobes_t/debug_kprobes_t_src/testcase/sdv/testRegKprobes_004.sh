#!/bin/bash

. conf.sh

KO=testRegKprobes_004.ko
grep_dmesg="register_kprobes failed"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

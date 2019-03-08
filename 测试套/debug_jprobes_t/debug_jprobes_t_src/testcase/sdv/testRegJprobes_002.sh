#!/bin/bash

. conf.sh

KO=testRegJprobes_002.ko
grep_dmesg="register_jprobes failed"

set_up
insmod_fail "$KO" "$grep_dmesg" || exit 1

exit 0

#!/bin/bash

. conf.sh

KO=testRegJprobes_001.ko
grep_dmesg="register_jprobes failed"

for num in -1 0
do
	set_up
	insmod_fail "$KO num=$num" "$grep_dmesg" || exit 1
done

exit 0

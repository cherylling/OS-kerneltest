#!/bin/bash

. conf.sh

KO=testRegKprobes_001.ko
grep_dmesg="register_kprobes failed"

#test : register_kprobes failed
for num in -1 0
do
	set_up
	insmod_fail "$KO num=$num" "$grep_dmesg" || exit 1
done

exit 0

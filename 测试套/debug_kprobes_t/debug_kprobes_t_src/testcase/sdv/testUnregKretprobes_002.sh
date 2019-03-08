#!/bin/bash

. conf.sh

KO=testUnregKretprobes_002.ko

#for num in -1 0 1 3 4
for num in 1 2 3
do
	set_up
	insmod_success "$KO num=$num" || exit 1

	rmmod_ko $KO || exit 1
done

exit 0

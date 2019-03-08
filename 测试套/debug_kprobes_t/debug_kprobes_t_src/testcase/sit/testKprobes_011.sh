#!/bin/bash

. conf.sh

KO=testKprobes_011.ko

for num in `seq 0 1 100`
do
	insmod_success $KO || exit 1	
	
	rmmod_ko $KO || exit 1
done

exit 0

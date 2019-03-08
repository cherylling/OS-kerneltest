#!/bin/bash -x

nr_run=1
loop=${1:-100}

while [ $nr_run -lt $loop ]
do
	./perf_v1r1c01_probe_tc009.sh
	if [ $? -ne 0 ];then
		echo "failed at $nr_run times"
		exit 1
	fi
	echo
	echo ------------$nr_run---------------
	echo

	nr_run=`expr $nr_run + 1`
done

[ -e perf.data ] && rm perf.data* -rf
exit 0

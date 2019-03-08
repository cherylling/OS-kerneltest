#!/bin/bash -x

nr_run=1
loop=${1:-100}

while [ $nr_run -lt $loop ]
do
	perf probe -a schedule >/dev/null 2>&1
	perf probe -l >/dev/null 2>&1
	perf record -o /tmp/perf.data -e probe:schedule -aR sleep 1
	perf report -i /tmp/perf.data >/dev/null 2>&1
	perf probe -d schedule
	echo
	echo ------------$nr_run---------------
	echo

	nr_run=`expr $nr_run + 1`
done


[ -e /tmp/perf.data ] && rm /tmp/perf.data* -rf

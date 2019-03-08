#!/bin/bash
######################################################################
# Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
# File name:   perf_v1r2c00_record-e_tc001.sh
# Author1:     y00197803
# Date:        2013-04-16
# Description: FIX ME, Tell me what this program will do
######################################################################
. ${TCBIN}./common_perf.sh
. ${TCBIN}./record-e_common.sh
######################################################################
# Description: prepare,set the init env.
######################################################################
prepareenv()
{
	prepare_tmp
	./common_realtime_1 &
	PID=$!
	cd ${TCTMP}
}

######################################################################
#Description: check events in hackbench_event.cfg of perf_event.cfg
######################################################################
do_test()
{
	local lines=`cat ${TCBIN}../config/perf_event.cfg | wc -l`
	local linei=0
	while [ $linei -lt $lines ];
	do
		linei=`expr $linei + 1`
		local line=`sed -n "$linei"p ${TCBIN}../config/perf_event.cfg`

		# for DTS -- DTS2013052307321
		if [ "$line" == "iTLB-load-misses" ];then
			perf record -e $line -c 100 -o $line.data -f -p $PID sleep 1 >/dev/null 2>&1
		else
			perf record -e $line -o $line.data -f -p $PID sleep 1 >/dev/null 2>&1
		fi

		perf report -i $line.data > $line.report
		check_ret_code $?
		rm -f $line.data
		check_event_keyinfo $line.report $line common_realtime_1
		if [ $? -eq 0 ];then
			check_event_event $line.report $line
			[ $? -eq 0 ] && continue
		fi
		echo "TFAIL: event ${event_chk}"
		RC=$((RC + 1))
	done
}

######################################################################
#Description: ending,clear the program env.
######################################################################
cleanenv()
{
	kill -9 $PID
	clean_end
}

######################################################################
#Description:  main function
######################################################################
prepareenv
do_test
cleanenv

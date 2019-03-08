#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: 
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 
##- @Brief: perf record -e基本功能验证1：验证hack_bench可触发的77种事件
##- @Detail: 1.对列表每个事件进行perf record -e记录
#            2.perf report
##- @Expect: perf report得到的信息输出正确，包含必备关键字
##- @Level: Level 2
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./record-e_common.sh
######################################################################
##- Description: prepare,set the init env.
######################################################################

# linux 3.11 delete 'perf record -f'
# commit: 4a4d371a4dfbd3b84a7eab8d535d4c7c3647b09e
# patch name: perf record: Remove -f/--force option
perf_vcmp 3 11
if [ $? -eq 1 ];then
	opt=""
else
	opt="-f"
fi

prepareenv()
{
	prepare_tmp
}

######################################################################
##- Description: check events in hackbench_event.cfg of perf_event.cfg
######################################################################
normal_event_test()
{
	cd ${TCTMP}
	local lines=`cat ${TCBIN}../config/hackbench_event.cfg | wc -l`
	local linei=0
	while [ $linei -lt $lines ];
	do
		linei=`expr $linei + 1`
		local line=`sed -n "$linei"p ${TCBIN}../config/hackbench_event.cfg`
		grep $line ${TCBIN}../config/perf_event.cfg >/dev/null 2>&1
		if [ $? -ne 0 ];then
			echo "TPASS: event $line not supported"
			continue
		fi

		# for DTS -- DTS2013052307321
		if [ "$line" == "iTLB-load-misses" ];then
			perf record -e $line -c 1000 -o $line.data $opt ${USE_HUGE}hackbench 1 1>/dev/null 2>${line}.err
		else
			perf record -e $line -o $line.data $opt ${USE_HUGE}hackbench 1 1>/dev/null 2>${line}.err
		fi
		ret=$?
		perf report -i $line.data > $line.report
		if [ $ret -eq 0 ];then
			check_ret_code $ret
			rm -f $line.data
			check_event_keyinfo $line.report $line ${USE_HUGE}hackbench
			if [ $? -eq 0 ];then
				check_event_event $line.report $line
				[ $? -eq 0 ] && continue
			fi
			echo "TFAIL: event ${event_chk}"
			RC=$((RC + 1))
		else
			check_in_file "Error: perfcounter syscall returned with -1" ${line}.err
		fi
	done
}

######################################################################
##- Description: check events in perf_event_or.cfg
######################################################################
or_event_test()
{
	cd ${TCTMP}
	local lines=`cat ${TCBIN}../config/perf_event_or.cfg | wc -l`
	local linei=0
	while [ $linei -lt $lines ];
	do
		linei=`expr $linei + 1`
		local line=`sed -n "$linei"p ${TCBIN}../config/perf_event_or.cfg`
		event_chk1=${line%OR*}
		event_chk2=${line#*OR}
		for event_chki in $event_chk1 $event_chk2
		do
			perf record -e $event_chki -o $event_chki.data -f ${USE_HUGE}hackbench 1 1>/dev/null 2>$event_chki.err
			ret=$?
			perf report -i $event_chki.data > $event_chki.report
			if [ $ret -eq 0 ];then
				check_ret_code $?
				rm -f $event_chki.data
				check_event_keyinfo $event_chki.report $event_chki ${USE_HUGE}hackbench
				if [ $? -eq 0 ];then
					check_event_event $event_chki.report $event_chk1
					[ $? -eq 0 ] && continue
					check_event_event $event_chki.report $event_chk2
					[ $? -eq 0 ] && continue
				fi
				echo "TFAIL: event ${event_chk}"
				RC=$((RC + 1))
			else
				check_in_file "Error: perfcounter syscall returned with -1" $event_chki.err
			fi

			#cyclesORcpu-cycles is as same as cpu-clock in some platform
			if [ "x$line" == "xcpu-cyclesORcycles" -a $RC -ne 0 ];then
				check_event_keyinfo $event_chki.report cpu-clock ${USE_HUGE}hackbench
				RC=$((RC - 1))
			fi
		done
	done
}

######################################################################
##- Description: 
######################################################################
do_test()
{
	normal_event_test
	#or_event_test
}

######################################################################
##- Description: ending,clear the program env.
######################################################################
cleanenv()
{
	clean_end
}

######################################################################
##- Description:  main function
######################################################################
use_huge $*
prepareenv
do_test
cleanenv

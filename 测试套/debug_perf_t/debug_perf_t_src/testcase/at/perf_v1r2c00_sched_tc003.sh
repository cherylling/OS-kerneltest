#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_sched_tc003
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf sched map
##- @Detail: test for 
#       1.perf sched map
#       2.perf sched replay
#       3.perf sched trace
#       according to the option
##- @Expect: 能输出结果
##- @Level: Level 1
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp
    cd $TCTMP
    perf sched record -o /tmp/perf.data sleep 2 2>/dev/null
    report_file=sched_tc-$$.report
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    for cmd in map replay latency script;do
		if [ "$cmd" == "replay" ];then
			perf sched -i /tmp/perf.data $cmd -r 0 > ${report_file}-${cmd}
		else
			perf sched -i /tmp/perf.data $cmd > ${report_file}-${cmd}
		fi
        check_ret_code $?
        has_content ${report_file}-${cmd}
    done
}

cleanenv()
{
    rm /tmp/perf.data -rf
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv

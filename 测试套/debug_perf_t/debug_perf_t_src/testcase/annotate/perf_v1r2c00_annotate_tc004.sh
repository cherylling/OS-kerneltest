#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_common_while_lib
##- @Author: y00197803
##- @Date: 2013-4-28
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: 1.编写可执行程序，使用动态库/静态库，程序中含有热点aa，库中含有热点bb
#            2.perf record ./test
#            3.perf report
#            4.perf annotate -l -s aa;perf annotate -l -s bb
##- @Expect: 能输出结果
##- @Level: Level 2
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
	reportfile=${TCTMP}/annotate_tc004-$$.report
	annotatefile=${TCTMP}/annotate_tc004-$$.annotate
	datafile=${TCTMP}/annotate_tc004-$$.data
	hotspot_in_lib=anno_hotspot1
	hotspot_in_app=anno_hotspot2
	[ -e /tmp/${USE_HUGE}common_while_lib_s ] && rm -rf /tmp/${USE_HUGE}common_while_lib_s
	[ -e /tmp/${USE_HUGE}common_while_lib_d ] && rm -rf /tmp/${USE_HUGE}common_while_lib_d
	cp ${USE_HUGE}common_while_lib_s /tmp
	cp ${USE_HUGE}common_while_lib_d /tmp

}
######################################################################
##- @Description: do perf record then 
######################################################################
dotest()
{
	#test for libcommon_while_lib.a
	/tmp/${USE_HUGE}common_while_lib_s &
	STATIC_PID=$!
	perf record -p $STATIC_PID -o ${datafile}-static sleep 5 2>/dev/null

	perf report -i ${datafile}-static > ${reportfile}-static
	check_ret_code $?
	check_in_file $hotspot_in_lib ${reportfile}-static
	check_in_file $hotspot_in_app ${reportfile}-static

	perf annotate -l -s $hotspot_in_lib -i ${datafile}-static > ${annotatefile}-static1
	check_ret_code $?
	check_in_file 'libcommon_while_lib.c:[[:digit:]]' ${annotatefile}-static1

	perf annotate -l -s $hotspot_in_app -i ${datafile}-static > ${annotatefile}-static2
	check_ret_code $?
	check_in_file 'common_while_lib.c:[[:digit:]]' ${annotatefile}-static2
	kill -9 ${STATIC_PID}

	echo "=================NOW DYNAMIC================="
	#test for libcommon_while_lib.so
	LD_LIBRARY_PATH=${TCBIN}../../lib /tmp/${USE_HUGE}common_while_lib_d &
	DYNAMIC_PID=$!
	perf record -p $DYNAMIC_PID -o ${datafile}-dynamic sleep 2 2>/dev/null

	perf report -i ${datafile}-dynamic > ${reportfile}-dynamic
	check_ret_code $?
	check_in_file $hotspot_in_lib ${reportfile}-dynamic
	check_in_file $hotspot_in_app ${reportfile}-dynamic

	perf annotate -l -s $hotspot_in_lib -i ${datafile}-dynamic > ${annotatefile}-dynamic1
	check_ret_code $?
	check_in_file 'libcommon_while_lib.c:[[:digit:]]' ${annotatefile}-dynamic1

	perf annotate -l -s $hotspot_in_app -i ${datafile}-dynamic > ${annotatefile}-dynamic2
	check_ret_code $?
	check_in_file 'common_while_lib.c:[[:digit:]]' ${annotatefile}-dynamic2
	kill -9 ${DYNAMIC_PID}
}

cleanenv()
{
	[ -e /tmp/${USE_HUGE}common_while_lib_s ] && rm -rf /tmp/${USE_HUGE}common_while_lib_s
	[ -e /tmp/${USE_HUGE}common_while_lib_d ] && rm -rf /tmp/${USE_HUGE}common_while_lib_d
	clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv

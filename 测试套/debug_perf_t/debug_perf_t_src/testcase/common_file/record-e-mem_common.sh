#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: record-e-mem_common.sh
##- @Author: y00197803
##- @Date: 2013-4-24
##- @Precon: 1.支持RTOS自研perf数据断点
##- @Brief: functions for perf report test
##- @Detail: 
#######################################################################*/
. ${TCBIN}./common_perf.sh

DEF_VAL_INT=5
W_VAL_INT=9

IS_BIG_ENDIAN=`common_is_big_endian`

######################################################################
##- @Description: these will be modified when doing configure
######################################################################
## -Description: 0:not support (default)
#                1:support (when do configure in $(TOP_SRC))
is_support=1
######################################################################
##- @Description: check is_support, if not support return 1
######################################################################
exit_if_not_support()
{
	if [ ${is_support} -ne 1 ];then
		echo "TFAIL: not support perf record -e mem:(rtos)"
		exit 1
	fi
	sleep 0.2
}

######################################################################
##- @Description: just get prepared for test
######################################################################
prepare_tmp_recordemem()
{
	exit_if_not_support
	prepare_tmp
	temp_num=$$
}

######################################################################
##- @Description: get the addr of the object to monitor
##-     $1:program file path
##-     $2:object to be monitored
##-     $3:function or not, 0:not function(default) 1:function
######################################################################
get_monitor_addr()
{
	local program=$1
	local object=$2
	local func=${3:-0}
	if [ $func -eq 0 ];then
		readelf $program -a | grep "$object" | grep OBJ | awk '{print $2}'
	else
		readelf $program -a | grep "$object" | grep FUNC | awk '{print $2}'
	fi
}

######################################################################
##- @Description: value in memory is diffrent between armbe8 and armle
##-     be8:0x12345678 is 12 34 56 78
##-     bl:0x12345678 is 78 56 34 12
######################################################################
get_check_val()
{
	if [ $IS_BIG_ENDIAN -eq 1 ];then
		echo $1 $2 $3 $4 $5 $6 $7 $8
	else
		case $# in
			1)
				echo $1
				;;
			2)
				echo $2 $1
				;;
			4)
				echo $4 $3 $2 $1
				;;
			8)
				echo $8 $7 $6 $5 $4 $3 $2 $1
				;;
		esac
	fi
}

######################################################################
##- @Description: value in memory is diffrent between armbe8 and armle
##-     converse value in memory to 0xaabbccdd
######################################################################
get_check_memval()
{
	local val
	if [ $IS_BIG_ENDIAN -eq 1 ];then
		val=$1$2$3$4$5$6$7$8
	else
		val=$8$7$6$5$4$3$2$1
	fi

	while [ $val != ${val#0} ];do
		val=${val#0}
	done
	echo 0x$val
}

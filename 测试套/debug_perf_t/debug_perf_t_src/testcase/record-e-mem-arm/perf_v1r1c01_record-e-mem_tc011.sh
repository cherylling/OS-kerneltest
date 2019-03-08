#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-15
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record同时监控5个断点(arm和x86上只有4个PMU寄存器)
##- @Detail: 1.构建用户态程序，运行
##-          2.监控报错，无法监控多于4个断点
##- @Expect: 监控报错
##- @Level: Level 3
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./record-e-mem_common.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp_recordemem
    cmd="${USE_HUGE}common_record-e-mem_1"
    program=${TCBIN}./${USE_HUGE}common_record-e-mem_1
    addr_ro=`get_monitor_addr ${program} read_only`
    addr_wo=`get_monitor_addr ${program} write_only`
    addr_rw=`get_monitor_addr ${program} read_write`
    addr_write_same=`get_monitor_addr ${program} write_same`
    addr_nothing=`get_monitor_addr ${program} nothing`
    cd ${TCTMP}
}
######################################################################
##-@ Description:  main function
######################################################################
dotest()
{
    perf record -e mem:0x${addr_ro}:r -e mem:0x${addr_wo}:w -e mem:0x${addr_rw}:rw -e mem:0x${addr_nothing}:r -e mem:0x${addr_write_same}:w $cmd 2>perf_record.err
    check_ret_code $? 1
    check_in_file "perfcounter syscall returned with" perf_record.err
}

######################################################################
##-@ Description:  main function
######################################################################
cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv

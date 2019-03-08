#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-14
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record同时监控4个断点(arm和x86上只有4个PMU寄存器)
##- @Detail: 1.构建用户态程序，运行
##-          2.对4个地址addr分别进行监控，并且触发事件
##- @Expect: 每个被触发的事件均被记录(不检验记录次数，armA9底层存在问题，导致记录次数不正确。资料中说明，同时监控多个地址，只要有一个地址被触发，会同时记录其他地址的数据)
##- @Level: Level 2
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
    tmp_file=usr_gvar_addr.tmp
    perf_data_file=/tmp/perf.data
    perf_report_file=/tmp/report.data
    cd ${TCTMP}
}

######################################################################
##- @Description:
######################################################################
get_record_para_rw_addr()
{
    [ -e $tmp_file ] && rm -rf $tmp_file
    ${TCBIN}./${USE_HUGE}common_record-e-mem_1 &
    PID=$!
    cmd="-p $PID"
    sleep 1
    addr_ro=`cat $tmp_file | sed -n '1p'`
    addr_wo=`cat $tmp_file | sed -n '2p'`
    addr_write_same=`cat $tmp_file | sed -n '3p'`
    addr_nothing=`cat $tmp_file | sed -n '4p'`
    addr_rw=`cat $tmp_file | sed -n '5p'`
    addr_func_unused=`cat $tmp_file | sed -n '6p'`
    addr_func_write=`cat $tmp_file | sed -n '7p'`
}

######################################################################
##-@ Description:  main function
######################################################################
dotest()
{
    def_val=`get_check_val 00 00 00 0${DEF_VAL_INT}`
    w_val=`get_check_val 00 00 00 0${W_VAL_INT}`
    get_record_para_rw_addr
    perf record -o $perf_data_file -e mem:${addr_ro}:rw -e mem:${addr_wo}:rw -e mem:${addr_rw}:rw -e mem:${addr_write_same}:rw $cmd 2>/dev/null
    sleep 0.1
    perf report -i $perf_data_file > $perf_report_file
    check_in_file "mem:$addr_ro:rw" $perf_report_file
    check_in_file "mem:$addr_wo:rw" $perf_report_file
    check_in_file "mem:$addr_rw:rw" $perf_report_file
    check_in_file "mem:$addr_write_same:rw" $perf_report_file
    do_read_num=`cat $perf_report_file | grep func_do_read | wc -l`
    [ $do_read_num -ne 2 ] && RC=$((RC + 1))
    do_write_num=`cat $perf_report_file | grep func_do_write | wc -l`
    [ $do_write_num -ne 3 ] && RC=$((RC + 1))
}

######################################################################
##-@ Description:  main function
######################################################################
cleanenv()
{
    rm -rf $perf_data_file
    rm -rf $perf_report_file
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv

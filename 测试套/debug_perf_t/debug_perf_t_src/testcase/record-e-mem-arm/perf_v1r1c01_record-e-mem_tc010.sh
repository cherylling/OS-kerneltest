#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-15
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record同时监控4个断点(arm和x86上只有4个PMU寄存器)
##- @Detail: 1.构建用户态程序，运行
##-          2.对4个地址addr分别进行监控，并且分别触发事件
##- @Expect: armA15和x86支持记录次数正确）
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
##-@ Description:  $1:should have $1 check
#                  $2:check get $2 check
######################################################################
check_in_file_nm()
{
    exp=$1
    res=$2
    if [ $exp -ne $res ];then
        echo "TFAIL: should have $exp checked, but checked $res"
        RC=$((RC + 1))
    else
        echo "TPASS: $exp=$res"
    fi
}

######################################################################
##-@ Description:  main function
######################################################################
dotest()
{
    def_val=`get_check_val 00 00 00 0${DEF_VAL_INT}`
    w_val=`get_check_val 00 00 00 0${W_VAL_INT}`
    #do record addr_ro
    perf record -e mem:0x${addr_ro}:r -e mem:0x${addr_wo}:r -e mem:0x${addr_nothing}:r -e mem:0x${addr_write_same}:r $cmd 2>/dev/null
    perf report > perf_ro.report
    if [ `arch` != "aarch64" ];then
        check_in_file "memval:   0x5" perf_ro.report
        check_in_file_nm 1 $?
        check_in_file "memval:   0x9" perf_ro.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_ro: $def_val" perf_ro.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_wo" perf_ro.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_nothing" perf_ro.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_write_same" perf_ro.report 0
        check_in_file_nm 1 $?
    else
        check_in_file "Samples: 1  of event 'mem:0x${addr_ro}:r'" perf_ro.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_wo}:r'" perf_ro.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_nothing}:r'" perf_ro.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_write_same}:r'" perf_ro.report
        check_in_file_nm 1 $?
    fi
    #do record addr_wo
    perf record -e mem:0x${addr_ro}:w -e mem:0x${addr_wo}:w -e mem:0x${addr_nothing}:r -e mem:0x${addr_write_same}:r $cmd 2>/dev/null
    perf report > perf_wo.report
    if [ `arch` != "aarch64" ];then
        check_in_file "memval:   0x5" perf_wo.report 0
        check_in_file_nm 1 $?
        check_in_file "memval:   0x9" perf_wo.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_ro" perf_wo.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_wo: $w_val" perf_wo.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_nothing" perf_wo.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_write_same" perf_wo.report 0
        check_in_file_nm 1 $?
    else
        check_in_file "Samples: 0  of event 'mem:0x${addr_ro}:w'" perf_wo.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 1  of event 'mem:0x${addr_wo}:w'" perf_wo.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_nothing}:r'" perf_wo.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_write_same}:r'" perf_wo.report
        check_in_file_nm 1 $?
    fi
    #do record addr_rw
    perf record -e mem:0x${addr_ro}:w -e mem:0x${addr_wo}:r -e mem:0x${addr_rw}:r -e mem:0x${addr_write_same}:r $cmd 2>/dev/null
    perf report > perf_rw.report
    if [ `arch` != "aarch64" ];then
        check_in_file "memval:   0x5" perf_rw.report
        check_in_file_nm 1 $?
        check_in_file "memval:   0x9" perf_rw.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_ro" perf_rw.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_wo" perf_rw.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_rw: $def_val" perf_rw.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_write_same" perf_rw.report 0
        check_in_file_nm 1 $?
    else
        check_in_file "Samples: 0  of event 'mem:0x${addr_ro}:w'" perf_rw.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_wo}:r'" perf_rw.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 1  of event 'mem:0x${addr_rw}:r'" perf_rw.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_write_same}:r'" perf_rw.report
        check_in_file_nm 1 $?
    fi
    #do record addr_write_same
    perf record -e mem:0x${addr_ro}:w -e mem:0x${addr_wo}:r -e mem:0x${addr_nothing}:r -e mem:0x${addr_write_same}:w $cmd 2>/dev/null
    perf report > perf_same.report
    if [ `arch` != "aarch64" ];then
        check_in_file "memval:   0x5" perf_same.report
        check_in_file_nm 1 $?
        check_in_file "memval:   0x9" perf_same.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_ro" perf_same.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_wo" perf_same.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_nothing" perf_same.report 0
        check_in_file_nm 1 $?
        check_in_file "===> $addr_write_same: $def_val" perf_same.report
        check_in_file_nm 1 $?
    else
        check_in_file "Samples: 0  of event 'mem:0x${addr_ro}:w'" perf_same.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_wo}:r'" perf_same.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 0  of event 'mem:0x${addr_nothing}:r'" perf_same.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 1  of event 'mem:0x${addr_write_same}:w'" perf_same.report
        check_in_file_nm 1 $?
    fi
    #do record all
    perf record -e mem:0x${addr_ro}:r -e mem:0x${addr_wo}:w -e mem:0x${addr_rw}:r -e mem:0x${addr_write_same}:w $cmd 2>/dev/null
    perf report > perf_all.report
    if [ `arch` != "aarch64" ];then
        check_in_file "memval:   0x5" perf_all.report
        check_in_file_nm 3 $?
        check_in_file "memval:   0x9" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_ro: $def_val" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_wo: $w_val" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_rw: $def_val" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "===> $addr_write_same: $def_val" perf_all.report
        check_in_file_nm 1 $?
    else
        check_in_file "Samples: 1  of event 'mem:0x${addr_ro}:r'" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 1  of event 'mem:0x${addr_wo}:w'" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 1  of event 'mem:0x${addr_rw}:r'" perf_all.report
        check_in_file_nm 1 $?
        check_in_file "Samples: 1  of event 'mem:0x${addr_write_same}:w'" perf_all.report
        check_in_file_nm 1 $?
    fi
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

#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc004.sh
##- @Author: z00314551
##- @Date: 2018-11-24
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: perf数据断点基本读写监控功能验证
##- @Detail: 1.构建用户态程序，运行
##-          2.执行perf的相关命令对程序的变量进行执行监测
##-          4.执行perf的report命令，验证程序是否触发perf记录相关的信息
##- @Expect: 1.地址1的可执行监控无效
##-          9.所有生效的监控，perf report所得数据正确，无效的监控perf report无数据
##- @Level: Level 1
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
    step1=step1.tmp
    step2=step2.tmp

    # linux 3.11 delete 'perf record -f'
    # commit: 4a4d371a4dfbd3b84a7eab8d535d4c7c3647b09e
    # patch name: perf record: Remove -f/--force option
    perf_vcmp 3 11
    if [ $? -eq 1 ];then
           opt=""
    else
           opt="-f"
    fi

    cd ${TCTMP}
}

######################################################################
##- @Description:
######################################################################
get_record_para_rw_addr()
{
    [ -e $tmp_file ] && rm -rf $tmp_file
    [ -e $step1 ] && rm -rf $step1
    [ -e $step2 ] && rm -rf $step2
    ${TCBIN}./${USE_HUGE}common_record-e-mem_3 &
    PID=$!
    cmd="-p $PID"
    while([ ! -e $step1 ])
    do
        sleep 1
    done

    addr_ro=`cat $tmp_file | sed -n '1p'`
    addr_wo=`cat $tmp_file | sed -n '2p'`
    addr_write_same=`cat $tmp_file | sed -n '3p'`
    addr_nothing=`cat $tmp_file | sed -n '4p'`
    addr_rw=`cat $tmp_file | sed -n '5p'`
    addr_func_unused=`cat $tmp_file | sed -n '6p'`
    addr_func_write=`cat $tmp_file | sed -n '7p'`
}

######################################################################
##- @Description:
######################################################################
dotest()
{
    get_record_para_rw_addr
    touch $step2
    perf record -o addr_func_write-${temp_num}.data -e mem:${addr_func_write}:x $opt ${cmd} 2>/dev/null
    sleep 1
    perf report -i addr_func_write-${temp_num}.data > addr_func_write-${temp_num}.report1
    check_in_file "func_do_write" addr_func_write-${temp_num}.report1
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

#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-09
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record监控栈、堆、mmap的地址，以及正数、0、负数的验证
##- @Detail: 1.构建用户态程序，运行
##-          2.对地址addr分别进行监控r,w
##-          3.使用-k一次对正数、0、负数进行监控
##- @Expect: 触发到的数据断点记录正确的信息
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
    cmd="${USE_HUGE}common_record-e-mem_2"
    pos=1
    neg=-1
    zero=0
    cd ${TCTMP}
}

######################################################################
##- @Description: 
##-              $1:stack,heap,mmap
######################################################################
do_record()
{
    local recordon=$1
    local filename eq_num lt_num gt_num chk_addr g_e_l

    for mode in pos neg zero;do
        eq_num=`eval echo '$'$mode`
        lt_num=$((eq_num - 1))
        gt_num=$((eq_num + 1))
        chk_addr=`eval echo '$'addr_${mode}`
        for which_k in gt eq lt;do
            g_e_l="`echo $which_k | sed 's/gt/>/' | sed 's/eq/=/' | sed 's/lt/</'`"
            for rw in r w;do
                filename=${recordon}_addr_${mode}_${which_k}_gt_$rw
                perf record -o ${filename}.data -e mem:${chk_addr}:$rw -k "s:$g_e_l$lt_num" -p $PID kill -USR1 $PID 2>/dev/null
                sleep 0.1
                perf report -i ${filename}.data > ${filename}.report0
                [ $which_k = gt ] && mv ${filename}.report0 ${filename}.report1
                filename=${recordon}_addr_${mode}_${which_k}_eq_$rw
                perf record -o ${filename}.data -e mem:${chk_addr}:$rw -k "s:$g_e_l$eq_num" -p $PID kill -USR1 $PID 2>/dev/null
                sleep 0.1
                perf report -i ${filename}.data > ${filename}.report0
                [ $which_k = eq ] && mv ${filename}.report0 ${filename}.report1
                filename=${recordon}_addr_${mode}_${which_k}_lt_$rw
                perf record -o ${filename}.data -e mem:${chk_addr}:$rw -k "s:$g_e_l$gt_num" -p $PID kill -USR1 $PID 2>/dev/null
                sleep 0.1
                perf report -i ${filename}.data > ${filename}.report0
                [ $which_k = lt ] && mv ${filename}.report0 ${filename}.report1
            done
        done
    done
}

######################################################################
##- @Description: 
##-              $1:stack,heap,mmap
######################################################################
do_check()
{
    local recordon=$1
    local has_content_file_list="`ls ${recordon}*.report1`"
    local no_content_file_list=`ls ${recordon}*.report0`

    has_content $has_content_file_list
    has_content 0 $no_content_file_list
    for chk_file in `ls ${recordon}_addr_pos*.report1`;do
        check_in_file "memval:   $pos_memval$" $chk_file
        check_in_file "===> 0*${addr_pos#0x}: $pos_val" $chk_file
    done
    for chk_file in `ls ${recordon}_addr_neg*.report1`;do
        check_in_file "memval:   $neg_memval$" $chk_file
        check_in_file "===> 0*${addr_neg#0x}: $neg_val" $chk_file
    done
    for chk_file in `ls ${recordon}_addr_zero*.report1`;do
        check_in_file "memval:   $zero_memval$" $chk_file
        check_in_file "===> 0*${addr_zero#0x}: $zero_val" $chk_file
    done
}

######################################################################
##- @Description: 
######################################################################
check_stack()
{
    #*.report0:report nothing
    #*.report1:do report something

    #record addr on stack
    $cmd 1&
    PID=$!
    sleep 1
    #will create get_addr.sh
    kill -USR1 $PID
    sleep 1
    source get_addr.sh
    do_record stack
    kill -9 $PID
    #address on stack maybe used in more than one place
    for reportfile in `ls stack*.report0`;do
        cp $reportfile ${reportfile%0}
        grep func_on_stack $reportfile > stack_report.tmp
        mv stack_report.tmp $reportfile
    done

    for reportfile in `ls stack*.report1`;do
        cp $reportfile ${reportfile%1}
        local line_start=`grep -n "\-\-\- func_on_stack" $reportfile | awk -F : '{print $1}'`
        local line_end=$((line_start + 16))
        sed -i -n "$line_start,$line_end"p $reportfile
    done
    do_check stack
}

######################################################################
##- @Description: 
######################################################################
check_heap()
{
    #record addr on heap
    $cmd 2&
    PID=$!
    sleep 1
    #will create get_addr.sh
    kill -USR1 $PID
    sleep 1
    source get_addr.sh
    do_record heap
    kill -9 $PID
    do_check heap
}

######################################################################
##- @Description: 
######################################################################
check_mmap()
{
    #record addr on heap
    $cmd 3&
    PID=$!
    sleep 1
    #will create get_addr.sh
    kill -USR1 $PID
    sleep 1
    source get_addr.sh
    do_record mmap
    kill -9 $PID
    do_check mmap
}

######################################################################
##-@ Description:  main function
######################################################################
dotest()
{
    pos_val="`get_check_val 00 00 00 01`"
    pos_memval=`get_check_memval $pos_val`
    neg_val="ff ff ff ff"
    neg_memval=0xffffffff
    zero_val="00 00 00 00"
    zero_memval=0x0

    check_stack
    check_heap
    check_mmap
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

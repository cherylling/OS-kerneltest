#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc003.sh
##- @Author: y00197803
##- @Date: 2013-5-07
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record 新增-k选项
##- @Detail: 1.构建用户态程序，运行
##-          2.对监控地址分别通过-k筛选监控>xx,=xx, <xx,>=xx,<=xx,>xx<
##-          3.对于以上每种情况监控地址的值分别大于，等于，小于xx个进行一次record
##-          4.使用两次-k，以后一个-k为准
##- @Expect: 1.符合-k条件的监控生效，不符合条件的监控无效
##-          2.所有生效的监控，perf report所得数据正确，无效的监控perf report无数据
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

    cmd="$CETAFORK ${USE_HUGE}common_record-e-mem_1"
    program=${TCBIN}./${USE_HUGE}common_record-e-mem_1
    read_only=`get_monitor_addr ${program} read_only`
    write_only=`get_monitor_addr ${program} write_only`

    cd ${TCTMP}
}

######################################################################
##- @Description: 
######################################################################
record_read()
{
    #DEF_VAL_INT is defined in record-e-mem_common.sh, the same with DEF_VAL_INT in common_record-e-mem_1.c
    local lt_num=$((DEF_VAL_INT-1))
    local gt_num=$((DEF_VAL_INT+1))
    #monitor value of read_only > xx
    perf record -o read_gt_gt-${temp_num}.data -e mem:0x${read_only}:r -k ">${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_gt_gt-${temp_num}.data > read_gt_gt-${temp_num}.report1
    perf record -o read_gt_eq-${temp_num}.data -e mem:0x${read_only}:r -k ">${DEF_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_gt_eq-${temp_num}.data > read_gt_eq-${temp_num}.report0
    perf record -o read_gt_lt-${temp_num}.data -e mem:0x${read_only}:r -k ">${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_gt_lt-${temp_num}.data > read_gt_lt-${temp_num}.report0
    #monitor value of read_only = xx
    perf record -o read_eq_gt-${temp_num}.data -e mem:0x${read_only}:r -k "=${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_eq_gt-${temp_num}.data > read_eq_gt-${temp_num}.report0
    perf record -o read_eq_eq-${temp_num}.data -e mem:0x${read_only}:r -k "=${DEF_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_eq_eq-${temp_num}.data > read_eq_eq-${temp_num}.report1
    perf record -o read_eq_lt-${temp_num}.data -e mem:0x${read_only}:r -k "=${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_eq_lt-${temp_num}.data > read_eq_lt-${temp_num}.report0
    #monitor value of read_only < xx
    perf record -o read_lt_gt-${temp_num}.data -e mem:0x${read_only}:r -k "<${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_lt_gt-${temp_num}.data > read_lt_gt-${temp_num}.report0
    perf record -o read_lt_eq-${temp_num}.data -e mem:0x${read_only}:r -k "<${DEF_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_lt_eq-${temp_num}.data > read_lt_eq-${temp_num}.report0
    perf record -o read_lt_lt-${temp_num}.data -e mem:0x${read_only}:r -k "<${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_lt_lt-${temp_num}.data > read_lt_lt-${temp_num}.report1
    #monitor value of read_only >= xx
    perf record -o read_ge_gt-${temp_num}.data -e mem:0x${read_only}:r -k ">${lt_num}||=${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_ge_gt-${temp_num}.data > read_ge_gt-${temp_num}.report1
    perf record -o read_ge_eq-${temp_num}.data -e mem:0x${read_only}:r -k ">${DEF_VAL_INT}||=${DEF_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_ge_eq-${temp_num}.data > read_ge_eq-${temp_num}.report1
    perf record -o read_ge_lt-${temp_num}.data -e mem:0x${read_only}:r -k ">${gt_num}||=${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_ge_lt-${temp_num}.data > read_ge_lt-${temp_num}.report0
    #monitor value of read_only <= xx
    perf record -o read_le_gt-${temp_num}.data -e mem:0x${read_only}:r -k "<${lt_num}||=${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_le_gt-${temp_num}.data > read_le_gt-${temp_num}.report0
    perf record -o read_le_eq-${temp_num}.data -e mem:0x${read_only}:r -k "<${DEF_VAL_INT}||=${DEF_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_le_eq-${temp_num}.data > read_le_eq-${temp_num}.report1
    perf record -o read_le_lt-${temp_num}.data -e mem:0x${read_only}:r -k "<${gt_num}||=${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_le_lt-${temp_num}.data > read_le_lt-${temp_num}.report1
    #monitor value of read_only >xx<
    perf record -o read_in_gt-${temp_num}.data -e mem:0x${read_only}:r -k ">0&&<${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_in_gt-${temp_num}.data > read_in_gt-${temp_num}.report0
    perf record -o read_in_eq_r-${temp_num}.data -e mem:0x${read_only}:r -k ">0&&<${DEF_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_in_eq_r-${temp_num}.data > read_in_eq_r-${temp_num}.report0
    perf record -o read_in_in-${temp_num}.data -e mem:0x${read_only}:r -k ">0&&<${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_in_in-${temp_num}.data > read_in_in-${temp_num}.report1
    perf record -o read_in_eq_l-${temp_num}.data -e mem:0x${read_only}:r -k ">${DEF_VAL_INT}&&<${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_in_eq_l-${temp_num}.data > read_in_eq_l-${temp_num}.report0
    perf record -o read_in_lt-${temp_num}.data -e mem:0x${read_only}:r -k ">${gt_num}&&<$((gt_num+2))" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i read_in_lt-${temp_num}.data > read_in_lt-${temp_num}.report0
}
######################################################################
##- @Description: 
######################################################################
record_write()
{
    #W_VAL_INT is defined in record-e-mem_common.sh, the same with W_VAL_INT in common_record-e-mem_1.c
    local lt_num=$((W_VAL_INT-1))
    local gt_num=$((W_VAL_INT+1))
    #monitor value of write_only > xx
    perf record -o write_gt_gt-${temp_num}.data -e mem:0x${write_only}:w -k ">${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_gt_gt-${temp_num}.data > write_gt_gt-${temp_num}.report1
    perf record -o write_gt_eq-${temp_num}.data -e mem:0x${write_only}:w -k ">${W_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_gt_eq-${temp_num}.data > write_gt_eq-${temp_num}.report0
    perf record -o write_gt_lt-${temp_num}.data -e mem:0x${write_only}:w -k ">${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_gt_lt-${temp_num}.data > write_gt_lt-${temp_num}.report0
    #monitor value of write_only = xx
    perf record -o write_eq_gt-${temp_num}.data -e mem:0x${write_only}:w -k "=${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_eq_gt-${temp_num}.data > write_eq_gt-${temp_num}.report0
    perf record -o write_eq_eq-${temp_num}.data -e mem:0x${write_only}:w -k "=${W_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_eq_eq-${temp_num}.data > write_eq_eq-${temp_num}.report1
    perf record -o write_eq_lt-${temp_num}.data -e mem:0x${write_only}:w -k "=${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_eq_lt-${temp_num}.data > write_eq_lt-${temp_num}.report0
    #monitor value of write_only < xx
    perf record -o write_lt_gt-${temp_num}.data -e mem:0x${write_only}:w -k "<${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_lt_gt-${temp_num}.data > write_lt_gt-${temp_num}.report0
    perf record -o write_lt_eq-${temp_num}.data -e mem:0x${write_only}:w -k "<${W_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_lt_eq-${temp_num}.data > write_lt_eq-${temp_num}.report0
    perf record -o write_lt_lt-${temp_num}.data -e mem:0x${write_only}:w -k "<${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_lt_lt-${temp_num}.data > write_lt_lt-${temp_num}.report1
    #monitor value of write_only >= xx
    perf record -o write_ge_gt-${temp_num}.data -e mem:0x${write_only}:w -k ">${lt_num}||=${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_ge_gt-${temp_num}.data > write_ge_gt-${temp_num}.report1
    perf record -o write_ge_eq-${temp_num}.data -e mem:0x${write_only}:w -k ">${W_VAL_INT}||=${W_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_ge_eq-${temp_num}.data > write_ge_eq-${temp_num}.report1
    perf record -o write_ge_lt-${temp_num}.data -e mem:0x${write_only}:w -k ">${gt_num}||=${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_ge_lt-${temp_num}.data > write_ge_lt-${temp_num}.report0
    #monitor value of write_only <= xx
    perf record -o write_le_gt-${temp_num}.data -e mem:0x${write_only}:w -k "<${lt_num}||=${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_le_gt-${temp_num}.data > write_le_gt-${temp_num}.report0
    perf record -o write_le_eq-${temp_num}.data -e mem:0x${write_only}:w -k "<${W_VAL_INT}||=${W_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_le_eq-${temp_num}.data > write_le_eq-${temp_num}.report1
    perf record -o write_le_lt-${temp_num}.data -e mem:0x${write_only}:w -k "<${gt_num}||=${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_le_lt-${temp_num}.data > write_le_lt-${temp_num}.report1
    #monitor value of write_only >xx<
    perf record -o write_in_gt-${temp_num}.data -e mem:0x${write_only}:w -k ">0&&<${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_in_gt-${temp_num}.data > write_in_gt-${temp_num}.report0
    perf record -o write_in_eq_r-${temp_num}.data -e mem:0x${write_only}:w -k ">0&&<${W_VAL_INT}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_in_eq_r-${temp_num}.data > write_in_eq_r-${temp_num}.report0
    perf record -o write_in_in-${temp_num}.data -e mem:0x${write_only}:w -k ">0&&<${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_in_in-${temp_num}.data > write_in_in-${temp_num}.report1
    perf record -o write_in_eq_l-${temp_num}.data -e mem:0x${write_only}:w -k ">${W_VAL_INT}&&<${gt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_in_eq_l-${temp_num}.data > write_in_eq_l-${temp_num}.report0
    perf record -o write_in_lt-${temp_num}.data -e mem:0x${write_only}:w -k ">${gt_num}&&<$((gt_num+2))" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i write_in_lt-${temp_num}.data > write_in_lt-${temp_num}.report0
}
######################################################################
##- @Description: 
######################################################################
record_doublek()
{
    #DEF_VAL_INT is defined in record-e-mem_common.sh, the same with DEF_VAL_INT in common_record-e-mem_1.c
    local lt_num=$((DEF_VAL_INT-1))
    local gt_num=$((DEF_VAL_INT+1))
    #first k triggered, second no trigger
    perf record -o doublek_1-${temp_num}.data -e mem:0x${read_only}:r -k ">${lt_num}" -k "<${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i doublek_1-${temp_num}.data > doublek_1-${temp_num}.report0
    #first k no trigger, second triggered
    perf record -o doublek_2-${temp_num}.data -e mem:0x${read_only}:r -k "<${lt_num}" -k ">${lt_num}" -f ${cmd} 2>/dev/null
    sleep 0.1
    perf report -i doublek_2-${temp_num}.data > doublek_2-${temp_num}.report1
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    record_read
    record_write
    record_doublek
    #*.report1 means has triggered to the event, *.report0 means no trigger to the event
    has_content_file_list=`ls *.report1`
    no_content_file_list=`ls *.report0`
    read_content_file_list="`ls read*.report1` doublek_2-${temp_num}.report1"
    write_content_file_list=`ls write*.report1`
    #check report files have content
    has_content $has_content_file_list
    has_content 0 $no_content_file_list

    check_val_read=`get_check_val 00 00 00 0${DEF_VAL_INT}`
    check_val_write=`get_check_val 00 00 00 0${W_VAL_INT}`
    #check addr:r of read_only
    for check_file in $has_content_file_list;do
        check_in_file "memval:" $check_file
        check_in_file "memblock" $check_file
    done
    for check_file in $read_content_file_list;do
        check_in_file "===> ${read_only}: $check_val_read" $check_file
    done
    for check_file in $write_content_file_list;do
        check_in_file "===> ${write_only}: $check_val_write" $check_file
    done
    #check report files do not have content
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

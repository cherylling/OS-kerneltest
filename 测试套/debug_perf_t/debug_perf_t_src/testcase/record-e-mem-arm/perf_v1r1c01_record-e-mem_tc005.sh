#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc007.sh
##- @Author: y00197803
##- @Date: 2013-5-06
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 验证perf record监控字节数与-k组合
##- @Detail: 1.构建用户态程序，运行
##-          2.对地址addr分别进行监控r1,r2,r4,w1,w2,w4
##-          3.使用-k >xx,=xx,<xx,对于1,2,4字节分别进行筛选
##- @Expect: 筛选以所监控的字节内容是否满足条件为准
##- @Level: Level 2
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
. ${TCBIN}./record-e-mem_common.sh

W_VAL_CHAR1=$((0x41))
if [ $IS_BIG_ENDIAN -eq 1 ];then
    W_VAL_CHAR2=$((0x4161))
    W_VAL_CHAR4=$((0x41616161))
else
    W_VAL_CHAR2=$((0x6141))
    W_VAL_CHAR4=$((0x61616141))
fi
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp_recordemem

    cmd="$CETAFORK ${USE_HUGE}common_record-e-mem_1"
    program=${TCBIN}./${USE_HUGE}common_record-e-mem_1
    addr_char_rw=`get_monitor_addr ${program} char_rw`

    cd ${TCTMP}
}

######################################################################
##- @Description: $1:read or write(r,w)
##-               $2:gt, eq, lt
##-               $3:>, =, <
######################################################################
dorecord()
{
    local read_or_write=$1
    local k_what1=$2
    local k_what2=$3
    local lt_num
    local gt_num
    local eq_num
    local filename1
    for ri in 1 2 4;do
        eq_num=`eval echo '$'W_VAL_CHAR${ri}`
        lt_num=$((eq_num - 5))
        gt_num=$((eq_num + 5))
        for hex_or_dec in hex dec;do
            if [ $hex_or_dec = hex ];then
                eq_num=0x`printf "%x" $eq_num`
                lt_num=0x`printf "%x" $lt_num`
                gt_num=0x`printf "%x" $gt_num`
            fi
            filename1=${hex_or_dec}_${read_or_write}${ri}_${k_what1}
            perf record -o ${filename1}_gt-${temp_num}.data -e mem:0x${addr_char_rw}:${read_or_write}${ri} -k "${k_what2}$lt_num" ${cmd} 1 2>/dev/null
            perf report -i ${filename1}_gt-${temp_num}.data > ${filename1}_gt-${temp_num}.report0
            [ $k_what1 = gt ] && mv ${filename1}_gt-${temp_num}.report0 ${filename1}_gt-${temp_num}.report1

            perf record -o ${filename1}_eq-${temp_num}.data -e mem:0x${addr_char_rw}:${read_or_write}${ri} -k "${k_what2}$eq_num" ${cmd} 1 2>/dev/null
            perf report -i ${filename1}_eq-${temp_num}.data > ${filename1}_eq-${temp_num}.report0
            [ $k_what1 = eq ] && mv ${filename1}_eq-${temp_num}.report0 ${filename1}_eq-${temp_num}.report1

            perf record -o ${filename1}_lt-${temp_num}.data -e mem:0x${addr_char_rw}:r${ri} -k "${k_what2}$gt_num" ${cmd} 1 2>/dev/null
            perf report -i ${filename1}_lt-${temp_num}.data > ${filename1}_lt-${temp_num}.report0
            [ $k_what1 = lt ] && mv ${filename1}_lt-${temp_num}.report0 ${filename1}_lt-${temp_num}.report1
        done
    done
}
######################################################################
##- @Description: 
######################################################################
dotest()
{
    #monitor addr of addr_char_rw:r1,2,4 -k ">xx"
    dorecord r gt ">"
    #monitor addr of addr_char_rw:r1,2,4 -k "=xx"
    dorecord r eq "="
    #monitor addr of addr_char_rw:r1,2,4 -k "<xx"
    dorecord r lt "<"
    #monitor addr of addr_char_rw:w1,2,4 -k ">xx"
    dorecord w gt ">"
    #monitor addr of addr_char_rw:w1,2,4 -k "=xx"
    dorecord w eq "="
    #monitor addr of addr_char_rw:w1,2,4 -k "<xx"
    dorecord w lt "<"

    has_content_file_list=`ls *.report1`
    no_content_file_list=`ls *.report0`
    #check report files have content or not
    has_content $has_content_file_list
    has_content 0 $no_content_file_list
    #check addr
    for check_file in $has_content_file_list;do
        check_in_file "memval:" $check_file
        check_in_file "memblock" $check_file
        check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" $check_file
    done
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

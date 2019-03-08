#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc002.sh
##- @Author: y00197803
##- @Date: 2013-5-06
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 对perf数据断点所监控地址的高低字节进行操作（8字节）
##- @Detail: 1.构建用户态程序，运行
##-          2.对地址addr分别进行监控：r8，w8
##-          2.1对于每个监控程序都分别对addr1,addr2,addr3…addr8进行操作
##- @Expect: 1.r8,w8监控对于addr1,addr2，addr3…addr8操作均生效
##-          2.所有生效的监控，perf report所得数据正确
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

    cmd="$CETAFORK ${USE_HUGE}common_record-e-mem_1"
    program=${TCBIN}./${USE_HUGE}common_record-e-mem_1
    addr_char_rw=`get_monitor_addr ${program} char_rw`

    cd ${TCTMP}
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    local readwrite
    #monitor addr of addr_char_rw:r8, do read&write addr_char_rw[1,2,3,...8]
    readwrite=1
    while [ $readwrite -le 8 ];do
        perf record -o r8_rw${readwrite}-${temp_num}.data -e mem:0x${addr_char_rw}:r8 -f ${cmd} ${readwrite} 1>/dev/null 2>&1
        perf report -i r8_rw${readwrite}-${temp_num}.data > r8_rw${readwrite}-${temp_num}.report
        readwrite=$((readwrite+1))
    done

    #monitor addr of addr_char_rw:w8, do read&write addr_char_rw[1,2,3,...8]
    readwrite=1
    while [ $readwrite -le 8 ];do
        perf record -o w8_rw${readwrite}-${temp_num}.data -e mem:0x${addr_char_rw}:w8 -f ${cmd} ${readwrite} 1>/dev/null 2>&1
        perf report -i w8_rw${readwrite}-${temp_num}.data > w8_rw${readwrite}-${temp_num}.report
        readwrite=$((readwrite+1))
    done

    has_content_file_list="`ls *.report`"
    #check report files have content
    has_content $has_content_file_list
    #check addr:r of read_only
    for check_file in $has_content_file_list;do
        check_in_file "memval:" $check_file
        check_in_file "memblock" $check_file
    done
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" r8_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" w8_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" r8_rw2-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" w8_rw2-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaAaaaaa" r8_rw3-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaAaaaaa" w8_rw3-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaAaaaa" r8_rw4-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaAaaaa" w8_rw4-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaAaaa" r8_rw5-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaAaaa" w8_rw5-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaaAaa" r8_rw6-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaaAaa" w8_rw6-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaaaAa" r8_rw7-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaaaAa" w8_rw7-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaaaaA" r8_rw8-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaaaaaA" w8_rw8-${temp_num}.report
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

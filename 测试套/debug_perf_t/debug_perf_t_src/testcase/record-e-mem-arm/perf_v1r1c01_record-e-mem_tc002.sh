#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r1c01_record-e-mem_tc002.sh
##- @Author: y00197803
##- @Date: 2013-5-06
##- @Precon: 1.支持perf功能
##-          2.支持perf数据断点
##- @Brief: 对perf数据断点所监控地址的高低字节进行操作
##- @Detail: 1.构建用户态程序，运行
##-          2.对地址addr分别进行监控：r1,r2,r4,w1,w2,w4
##-          2.1对于每个监控程序都分别对addr1,addr2,addr3,addr4进行操作
##- @Expect: 1.r1,w1监控对于addr1操作生效，其他地址操作无效
##-          2.r2,w2监控对于addr1,addr2操作生效，其他地址操作无效
##-          3.r4,w4监控对于addr1,addr2，addr3,addr4操作均生效
##-          4.所有生效的监控，perf report所得数据正确，无效的监控perf report无数据
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
    #monitor addr of addr_char_rw:r1, do read&write addr_char_rw[1,2,3,4]
    #monitor addr of addr_char_rw:r2, do read&write addr_char_rw[1,2,3,4]
    #monitor addr of addr_char_rw:r4, do read&write addr_char_rw[1,2,3,4]
    for ri in 1 2 4;do
        readwrite=1
        while [ $readwrite -le 4 ];do
            perf record -o monitor-r${ri}_rw${readwrite}-${temp_num}.data -e mem:0x${addr_char_rw}:r${ri} -f ${cmd} ${readwrite} 2>/dev/null
            sleep 0.1
            perf report -i monitor-r${ri}_rw${readwrite}-${temp_num}.data > monitor-r${ri}_rw${readwrite}-${temp_num}.report
            readwrite=$((readwrite+1))
        done
    done

    #monitor addr of addr_char_rw:r, do read&write addr_char_rw[1,2,3,4]
    readwrite=1
    while [ $readwrite -le 4 ];do
        perf record -o monitor-r_rw${readwrite}-${temp_num}.data -e mem:0x${addr_char_rw}:r -f ${cmd} ${readwrite} 2>/dev/null
        sleep 0.1
        perf report -i monitor-r_rw${readwrite}-${temp_num}.data > monitor-r_rw${readwrite}-${temp_num}.report
        readwrite=$((readwrite+1))
    done

    #monitor addr of addr_char_rw:w1, do read&write addr_char_rw[1,2,3,4]
    #monitor addr of addr_char_rw:w2, do read&write addr_char_rw[1,2,3,4]
    #monitor addr of addr_char_rw:w4, do read&write addr_char_rw[1,2,3,4]
    for ri in 1 2 4;do
        readwrite=1
        while [ $readwrite -le 4 ];do
            perf record -o monitor-w${ri}_rw${readwrite}-${temp_num}.data -e mem:0x${addr_char_rw}:w${ri} -f ${cmd} ${readwrite} 2>/dev/null
            sleep 0.1
            perf report -i monitor-w${ri}_rw${readwrite}-${temp_num}.data > monitor-w${ri}_rw${readwrite}-${temp_num}.report
            readwrite=$((readwrite+1))
        done
    done

    has_content_file_list="monitor-r1_rw1-${temp_num}.report monitor-r2_rw1-${temp_num}.report monitor-r2_rw2-${temp_num}.report monitor-r4_rw1-${temp_num}.report monitor-r4_rw2-${temp_num}.report monitor-r4_rw3-${temp_num}.report monitor-r4_rw4-${temp_num}.report monitor-w1_rw1-${temp_num}.report monitor-w2_rw1-${temp_num}.report monitor-w2_rw2-${temp_num}.report monitor-w4_rw1-${temp_num}.report monitor-w4_rw2-${temp_num}.report monitor-w4_rw3-${temp_num}.report monitor-w4_rw4-${temp_num}.report monitor-r_rw1-${temp_num}.report monitor-r_rw2-${temp_num}.report monitor-r_rw3-${temp_num}.report monitor-r_rw4-${temp_num}.report"
    no_content_file_list="monitor-r1_rw2-${temp_num}.report monitor-r1_rw3-${temp_num}.report monitor-r1_rw4-${temp_num}.report monitor-r2_rw3-${temp_num}.report monitor-r2_rw4-${temp_num}.report monitor-w1_rw2-${temp_num}.report monitor-w1_rw3-${temp_num}.report monitor-w1_rw4-${temp_num}.report monitor-w2_rw3-${temp_num}.report monitor-w2_rw4-${temp_num}.report"
    #check report files have content
    has_content $has_content_file_list
    #check addr:r of read_only
    for check_file in $has_content_file_list;do
        check_in_file "memval:" $check_file
        check_in_file "memblock" $check_file
    done
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-r1_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-r2_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-r4_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-w1_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-w2_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-w4_rw1-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*Aaaaaaaa" monitor-r_rw1-${temp_num}.report

    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" monitor-r2_rw2-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" monitor-r4_rw2-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" monitor-w2_rw2-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" monitor-w4_rw2-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aAaaaaaa" monitor-r_rw2-${temp_num}.report

    check_in_file "===> ${addr_char_rw}: .*aaAaaaaa" monitor-r4_rw3-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaAaaaaa" monitor-w4_rw3-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaAaaaaa" monitor-r_rw3-${temp_num}.report

    check_in_file "===> ${addr_char_rw}: .*aaaAaaaa" monitor-r4_rw4-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaAaaaa" monitor-w4_rw4-${temp_num}.report
    check_in_file "===> ${addr_char_rw}: .*aaaAaaaa" monitor-r_rw4-${temp_num}.report
    #check report files do not have content
    has_content 0 $no_content_file_list
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

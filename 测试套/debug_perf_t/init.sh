#!/bin/bash
######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: init.sh
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: RATF will source this file before running testcases
# @What you can do:
#     1.export some parameters, so that your testcases can use
#     2.create soft link files from ${BUSYBOX}
#     3.modify the system configuration before running testcases
#     4.do not do exit here, or RATF will exit here
######################################################################
pre_condition()
{
    export TCROOT=${PWD}/debug_perf_t
    export TCBIN=${TCROOT}/testcases/bin/
    export PATH=${PATH}:${TCBIN}
    export LD_LIBRARY_PATH=${TCROOT}/lib
    export IS_SUPPORT_HUGETLBFS=1
    export CROSS_COMPILE_SDK
}

do_config()
{
    :<<COMMENT 
    perf list > ${TCBIN}../config/perf_list 2>&1
    cat ${TCBIN}../config/perf_list | grep '\[' | awk -F [ '{$NF="";print}' | sed 's/[[:blank:]]*//g' | sed '/^mem:/d' | sed '/^rNNN/d' > ${TCBIN}../config/perf_event.cfg
    #some event contains OR
    grep OR ${TCBIN}../config/perf_event.cfg > ${TCBIN}../config/perf_event_or.cfg
    #normal event
    sed -i '/OR/d' ${TCBIN}../config/perf_event.cfg
    rm -f ${TCBIN}../config/perf_list
COMMENT

    perf record -h > ${TCBIN}../config/record.help 2>&1
    perf report -h > ${TCBIN}../config/report.help 2>&1
    perf sched -h > ${TCBIN}../config/sched.help 2>&1
    perf kmem -h > ${TCBIN}../config/kmem.help 2>&1
    perf stat -h > ${TCBIN}../config/stat.help 2>&1

    SKIP_BUILDID_TESTCASE=1
    BUILDID_DEBUG_DIR=~/.debug/
    DEBUG_PERF_TESTCASE_LIST=$TCROOT/../../tests/debug_perf_t
    if [ -d $BUILDID_DEBUG_DIR ]; then
        chmod +w $BUILDID_DEBUG_DIR
        DEBUG_DIR_WRITABLE=`ls -dl $BUILDID_DEBUG_DIR | awk '{print $1}' | grep w`
        if [ -n $DEBUG_DIR_WRITABLE ]; then
             SKIP_BUILDID_TESTCASE=0
        fi
    fi

    if [ $SKIP_BUILDID_TESTCASE -ne 0 ]; then
        sed -i '/perf_v1r3c00_archive_tc001.sh/d' $DEBUG_PERF_TESTCASE_LIST
        sed -i '/buildid-cache/d' $DEBUG_PERF_TESTCASE_LIST
    fi

    #mount hugetlbfs
    grep hugetlbfs /proc/filesystems > /dev/null
    if [ $? -ne 0 ];then
        echo "Do not support hugetlbfs"
        IS_SUPPORT_HUGETLBFS=0
        sed -i '/hugetlb/d' $DEBUG_PERF_TESTCASE_LIST
    else
        mount | grep hugetlbfs | grep /mnt/hugefs
        if [ $? -ne 0 ];then
            MOUNT_HUGETLBFS=1
            mkdir -p /mnt/hugefs
            mount -t hugetlbfs none /mnt/hugefs
            echo 20 > /proc/sys/vm/nr_hugepages
        else
            MOUNT_HUGETLBFS=0
            NR_HUGEPAGES=`cat /proc/sys/vm/nr_hugepages`
            [ $NR_HUGEPAGES -le 20 ] && echo 20 > /proc/sys/vm/nr_hugepages
        fi
    fi
}

do_platform_config()
{
    case $PRODUCT_NAME in
        "X86-MSG")
        #MSG do not support cpu-cycles,cycles
        sed -i '/cpu-cyclesORcycles/'d ${TCBIN}../config/hackbench_event.cfg
        ;;
        *)
        sed -i '/perf_mem/d' $DEBUG_PERF_TESTCASE_LIST
        ;;
    esac
}
pre_condition
do_config
do_platform_config

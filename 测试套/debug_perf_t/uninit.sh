#!/bin/bash
######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: uninit.sh
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: RATF will source this file before running testcases
# @What you can do:
#     1.modify the system configuration to the original value 
#       after running testcases
#     2.do not do exit here, or RATF will exit here
######################################################################

do_unset()
{
    #umount hugetlbfs
    if [ $MOUNT_HUGETLBFS -eq 0 ];then
        echo $NR_HUGEPAGES > /proc/sys/vm/nr_hugepages
    else
        echo 0 > /proc/sys/vm/nr_hugepages
        umount /mnt/hugefs
    fi
}
do_unset

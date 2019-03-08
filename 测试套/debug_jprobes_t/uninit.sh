#!/bin/bash
######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.  
##- @File name: uninit.sh
##- @Author1:z00189503
##- @Date: 2014-03-29
##- @Description: RATF will source this file before running testcases
##- @What you can do:
#     1.modify the system configuration to the original value 
#       after running testcases
#     2.do not do exit here, or RATF will exit here
######################################################################

do_unset()
{
    #echo ${modify_shmmax} > /proc/sys/kernel/shmmax
    echo "doing nothing"
}

reback_cgroup_env(){
    which cpuisolate_test
    if [ $? -eq 0 ];then
        #it's HI1381, we need to reback children of cpuset and close tick
        cpuisolate_test init
        if [ $? -ne 0 ];then
            echo "In uninit.sh: cpuisolate_test init fail"
            return -1
        else
            echo "In uninit.sh: cpuisolate_test init success"
        fi
    else
        echo "In uninit.sh: do nothing"
    fi
}

do_unset
reback_cgroup_env


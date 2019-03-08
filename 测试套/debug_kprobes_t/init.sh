#!/bin/bash
######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.  
##- @File name: init.sh
##- @Author1:z00189503
##- @Date: 2014-03-29
##- @Description: RATF will source this file before running testcases
##- @What you can do:
#     1.export some parameters, so that your testcases can use
#     2.create soft link files from ${BUSYBOX}
#     3.modify the system configuration before running testcases
#     4.do not do exit here, or RATF will exit here
######################################################################
pre_condition()
{
    export TCROOT=${PWD}/`basename ${PWD}`
    export TCBIN=${TCROOT}/testcase/bin
    export PATH=${PATH}:${TCBIN}
    export LD_LIBRARY_PATH=${TCROOT}/lib
}
#do_ln()
#{
#    case $PRODUCT_NAME in
#        "USP")
#        ln -s $BUSYBOX $TCBIN/ipcs
#        ;;
#        *)
#        ;;
#    esac
#}
#do_set()
#{
#    case $PRODUCT_NAME in
#        "IPTV")
#        export modify_shmmax=`cat /proc/sys/kernel/shmmax`
#        echo 131072 > /proc/sys/kernel/shmmax
#        ;;
#        *)
#        ;;
#    esac
#}

clean_cgroup_env(){
    which cpuisolate_test
    if [ $? -eq 0 ];then
        #it's HI1381, we need to clean children of cpuset and close tick
        cpuisolate_test clean
        if [ $? -ne 0 ];then
            echo "In init.sh: cpuisolate_test clean fail"
            return -1
        else
            echo "In init.sh: cpuisolate_test clean success"
        fi
    else
        #no need to clean env
        echo "In init.sh: do nothing in clean_cgroup_env"
    fi
}

pre_condition
clean_cgroup_env


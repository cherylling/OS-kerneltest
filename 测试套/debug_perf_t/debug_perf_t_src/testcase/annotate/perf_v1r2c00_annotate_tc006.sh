#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_annotate_tc006
##- @Author: z00314551
##- @Date: 2018-11-11
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: 1.编写可执行程序，使用到动态库
#            2.perf record ./test
#            3.perf annotate --cpu
##- @Expect: 长短选项输出相同
##- @Level: Level 1
##- @Auto:
##- @Modify:
#######################################################################*/
. ${TCBIN}./common_perf.sh
######################################################################
##- @Description: prepare,set the init env.
######################################################################
prepareenv()
{
    prepare_tmp
    annotatefile=annotate_tc001-$$.annotate
    datafile=annotate_tc002-$$.data
    hotspot_in_app1=longa
    cpuNum=`cat /proc/cpuinfo | grep -i "processor[[:blank:]]\{1,\}:[[:blank:]]\{1,\}[[:digit:]]" | wc -l`

    cd $TCTMP

}
######################################################################
##- @Description: do perf record then
######################################################################
dotest()
{
    perf record -a -o ${datafile} ${USE_HUGE}common_annotate_test_d 2>/dev/null
    perf annotate -i ${datafile} -C 0-${cpuNum}  > ${annotatefile}1
    check_ret_code $?
    check_in_file $hotspot_in_app1 ${annotatefile}1

}
######################################################################
##- @Description: ending,clear the program env.
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

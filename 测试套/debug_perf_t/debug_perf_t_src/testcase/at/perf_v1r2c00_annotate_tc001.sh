#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_annotate_tc001
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
#            2.支持expand,addr2line,objdump
#            3.可执行程序编译带-g选项
##- @Brief: perf annotate基本命令可用1
##- @Detail: 1.编写可执行程序，使用到动态库
#            2.perf record ./test
#            3.perf annotate -f -v -D --tui --stdio
#            4.perf annotate  --force --verbose --dump-raw-trace --tui --stdio
#            5.perf annotate -k /tmp -m /tmp
#            6.perf annotate --vmlinux /tmp --modules /tmp
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
    vmlinux_path=${TCBIN}../config/vmlinux
    annotatefile=annotate_tc001-$$.annotate
    perf_data_path=/tmp/perf.data
    cd $TCTMP
    ${USE_HUGE}common_while_1 > /dev/null &
    PID=$!
}
######################################################################
##- @Description: do perf record then
######################################################################
dotest()
{
    perf record -o $perf_data_path -p $PID sleep 5 2>/dev/null
    perf annotate -i $perf_data_path -f -v -D --tui --stdio > ${annotatefile}1 2>/dev/null
    ret=$?
    if [ $ret -ne 0 ]; then
	echo "If there arm some error such as : unknown option 'xxx',
		Then you need rebuild the perf command with necessary lib"
    fi

    check_ret_code $ret
    has_content ${annotatefile}1
    perf annotate -i $perf_data_path --force --verbose --dump-raw-trace --tui --stdio > ${annotatefile}2 2>/dev/null
    check_ret_code $?
    has_content ${annotatefile}2
    func_is_diff ${annotatefile}1 ${annotatefile}2

    perf annotate -i $perf_data_path -k $vmlinux_path -m > ${annotatefile}3 2>/dev/null
    check_ret_code $?
    perf annotate -i $perf_data_path --vmlinux $vmlinux_path --modules > ${annotatefile}4 2>/dev/null
    check_ret_code $?
}
######################################################################
##- @Description: ending,clear the program env.
######################################################################
cleanenv()
{
    kill -9 $PID > /dev/null 2>&1
    rm $perf_data_path -rf
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
use_huge $*
prepareenv
dotest
cleanenv

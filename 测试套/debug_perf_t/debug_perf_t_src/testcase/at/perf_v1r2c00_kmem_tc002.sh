#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: opt_perf_t
##- @Name: perf_v1r2c00_kmem_tc002
##- @Author: y00197803
##- @Date: 2013-4-17
##- @Precon: 1.支持perf功能
##- @Brief: perf kmem基本命令可用1
##- @Detail: perf kmem stat --alloc --raw-ip
##- @Expect: 能输出结果
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
    func_is_support file=${TCBIN}../config/kmem.help --alloc --raw-ip
    prepare_tmp
    cd $TCTMP
    report_file=${TCTMP}/perf_v1r2c00_kmem_tc-$$.report
    perf kmem record sleep 0.1 2>/dev/null
}

######################################################################
##- @Description: 
######################################################################
dotest()
{
    perf kmem stat --alloc --raw-ip > $report_file
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "If there arm some error such as : 'kmem' is not a perf-command,
                Then you need rebuild the perf command with necessary lib"
    fi

    check_ret_code $ret
    has_content $report_file
}
cleanenv()
{
    clean_end
}
######################################################################
##-@ Description:  main function
######################################################################
prepareenv
dotest
cleanenv

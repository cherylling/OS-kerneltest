#!/bin/bash

. ${TCBIN}./common_perf.sh

prepareenv()
{
    prepare_tmp
    probe_path=${TCTMP}/perf.result
    vmlinux_path=../config/vmlinux
    test_probe=schedule
}

dotest()
{
    perf probe -F $test_probe > ${probe_path}
    check_ret_code $?
    check_in_file $test_probe ${probe_path}

    perf probe -k $vmlinux_path --var="$test_probe" > ${probe_path}
    check_ret_code $?
    check_in_file $test_probe ${probe_path}
}

doclean()
{
    clean_end
}

prepareenv
dotest
doclean
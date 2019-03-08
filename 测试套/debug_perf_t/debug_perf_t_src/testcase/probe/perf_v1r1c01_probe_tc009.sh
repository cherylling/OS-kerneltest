#!/bin/bash

insmod ${TCBIN}../module/kernel_module.ko
cp ${TCBIN}../module/kernel_module.ko /tmp
. ${TCBIN}./common_perf.sh
report_path=/tmp/report.data
perf_data_path=/tmp/perf.data
vmlinux_path=/tmp/vmlinux
ret=0

#MARG="-M /tmp"
#echo "TEST_VERSION=$VERSION ; TEST_PRODUCT=$PRODUCT_NAME"
#
#echo "$VERSION" | grep V100R001 > /dev/null
#if [ $? -eq 0 ] ; then
#        MARG="-m /tmp"                           #V1R1 use -m option
#        NONEEDPRODUCT="PARC GGSN"
#        echo $NONEEDPRODUCT | grep "$PRODUCT_NAME"
#        if [ $? -eq 0 ] ; then
#                MARG=""
#        fi
#fi
MARG=""

# linux 4.0 change 'perf record -g' and 'perf record --call-graph'
# patch name: perf top: Support call-graph display options also
perf_vcmp 4 0
if [ $? -eq 1 ];then
	opt="--call-graph"
else
	opt="g"
fi

dotest()
{
    perf probe -m /tmp/kernel_module.ko planck_free_read
    perf record -o $perf_data_path $opt fp ${MARG} -e probe:planck_free_read -aR cat /proc/mykthread_free_enable > /dev/null
    perf report -i $perf_data_path > $report_path
    cat $report_path |grep planck_free_read
    if [ $? -ne 0 ];then
        {
            echo "perf probe -m -a planck_free_read command error"
            ret=$((ret+1))
            return 1
        }
    else
        {
            echo "TEST Succeed"
            return 0
        }
    fi
}

doclean()
{
    rm $report_path -rf
    rm $perf_data_path -rf
	[ -e perf.data ] && rm perf.data* -rf
    perf probe -d planck*
    rmmod kernel_module
    rm /tmp/kernel_module.ko
    echo "clean all the dirty file"
}

dotest
doclean
exit $ret

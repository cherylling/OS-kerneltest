#!/bin/sh

basedir=$(cd `dirname $0`;pwd)
topdir=$(cd `dirname $0`;cd ../../;pwd)
source $topdir/config/hi1213_arm64le.conf

#testcases="oops.ko panic.ko panic_oops.ko oops_oops.ko panic_panic.ko ppi.ko sgi.ko"

cd $topdir/resources/test_modules/${PRODUCT_NAME}/
testcases=$(ls *.ko | grep -v kpgen)
cd - > /dev/null

for kofile in $testcases
do
    logfile=$basedir/run.log.$kofile
    rm -rf $logfile
    echo "testcase begin: $(date)" >> $logfile
    sh $basedir/kdump_module.sh $kofile >> $logfile 2>&1
    echo "testcase finish: $(date)" >> $logfile
    sleep 30
done
echo "testcases finish, logs are all in $basedir"

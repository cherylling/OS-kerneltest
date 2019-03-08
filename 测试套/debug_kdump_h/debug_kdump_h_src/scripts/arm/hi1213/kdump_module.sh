#!/bin/sh
############################################
# test panic by ko such like oops.ko 
############################################

set -x

basedir=$(cd `dirname $0`;pwd)
source $basedir/kdump_lib.sh

test_module=$1
test -z $test_module && echo "usage: sh $0 <ko>, please specify ko" && exit 1

test_module_src="$topdir/resources/test_modules/${PRODUCT_NAME}/$test_module"
if [ ! -f $test_module_src ];then
    echo "$test_module_src cound not found!"
    exit 1
fi

#
#before executing,deploy the board
if [ -z ${TARGET_IP} -o -z ${TARGET_PASSWD} ];then
    echo "no TARGET_IP or TARGET_PASSWD..."
    exit 1
fi

base_deploy
# sleep enough time to finish bios setting,
# or following step may consider it's in os incorrectly
sleep 60

#rebootup testmathine [password] [user]
rebootup ${TARGET_IP} ${TARGET_PASSWD} root 240
if [ $? -ne 0 ];then
    echo "deploy failed....."
    exit 1
fi
# wait os boot finish
sleep 20

#scp capture kernel to board
scp_capturefiles
sleep 3

#do kexec
kexec_load
sleep 3

#do panic. only interrupt_tasklet_panic.ko need parameter "tasklet_num=2"
scp_file_to_dest $test_module_src
echo $test_module | grep 'interrupt_tasklet_panic' > /dev/null && panic_cmd="/sbin/insmod ${dst_capture_kernel_path}/${test_module} tasklet_num=2" || panic_cmd="/sbin/insmod ${dst_capture_kernel_path}/${test_module}"
sshcmd "${panic_cmd}" root ${TARGET_IP} ${TARGET_PASSWD} &
echo "panic_cmd ret : $?"
sleep 5

#waiting for capture kernel 
rebootup ${TARGET_IP} ${TARGET_PASSWD} root 240
if [ $? -ne 0 ];then
    echo "kdump failed....."
    exit 1
fi

#=============== makedumpfile will fail in the capture kernel ========
#=============== So, check the result by "ls /proc/vmcore =================
lsvmcore_cmd="ls /proc/vmcore"
sshcmd "${lsvmcore_cmd}" root ${TARGET_IP} ${TARGET_PASSWD}
if [ $? -ne 0 ];then
        echo "ls /proc/vmcore failed....."
        exit 1
fi

exit 0
#=============== and skip following steps =================

##do makedumpfile
#do_makedumpfile

##scp target vmcore_my to host
#scp_vmcore $test_module 
#
##reboot to first kernel
#do_reboot
#
##scp vmcore_my,vmlinux to target to crash
#for crash_file in vmcore_${test_module} vmlinux
#do
#    scp_file_to_dest $crash_file
#done
#
##crash vmcore
#cd ../../resources/lib/ 
#expect crash_bt_lib.exp vmcore_${test_module} vmlinux sysrq-trigger
#if [ $? -ne 0 ];then
#    echo " crash failed....."
#    cd -
#    exit 1
#fi
#cd -
#echo "kdump for $PRODUCT_NAME of $test_module PASS"
#exit 0 


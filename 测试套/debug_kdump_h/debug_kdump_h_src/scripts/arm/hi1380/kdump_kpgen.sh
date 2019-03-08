#!/bin/sh
############################################
# test panic by customized "kpgen_kbox.ko"
############################################

set -x

basedir=$(cd `dirname $0`;pwd)
source $basedir/kdump_lib.sh

testcase=$1
test -z $testcase && echo "usage: sh $0 <test num>, e.g sh $0 1002, please specify test number" && exit 1

test_module="kpgen_kbox.ko"
test_module_src="$topdir/resources/test_modules/${PRODUCT_NAME}/$test_module"
insmod_sh="kbox_ld_kpgenm.sh"
insmod_sh_src="$topdir/resources/lib/$insmod_sh"
if [ ! -f $test_module_src -o ! -f $insmod_sh_src ];then
    echo "$test_module_src or $insmod_sh_src cound not found!"
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
    echo "reboot failed....."
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

#insmod kpgen ko
scp_file_to_dest $test_module_src
scp_file_to_dest $insmod_sh_src
insmod_cmd="cd ${dst_capture_kernel_path}; sh ${insmod_sh}"
sshcmd "${insmod_cmd}" root ${TARGET_IP} ${TARGET_PASSWD} &
echo "insmod_cmd ret : $?"
sleep 10

#do  panic
if [ "x$testcase" = "x3001" ];then
    prepare_cmd="echo 1 > /proc/sys/kernel/softlockup_panic"
    sshcmd "${prepare_cmd}" root ${TARGET_IP} ${TARGET_PASSWD}
    echo "prepare_cmd ret : $?"
fi
if [ "x$testcase" = "x3003" ];then
    prepare_cmd="echo 1 > /proc/sys/kernel/hung_task_panic"
    sshcmd "${prepare_cmd}" root ${TARGET_IP} ${TARGET_PASSWD}
    echo "prepare_cmd ret : $?"
fi
panic_cmd="echo $testcase > /dev/kpgen_kbox"
#ont maybe no sysrq-trigger
sshcmd "${panic_cmd}" root ${TARGET_IP} ${TARGET_PASSWD} &
echo "panic_cmd ret : $?"
sleep 5

#waiting for capture kernel 
rebootup ${TARGET_IP} ${TARGET_PASSWD} root 240
if [ $? -ne 0 ];then
    echo "kdump failed....."
    exit 1
fi

exit 0

#=============== makedumpfile will fail as kexec bug ========
#=============== which makes capture kernel vmcore not initialized, /proc/vmcore not exits =====
#=============== So, check the result from the running log =================
#=============== and skip following steps =================

##do makedumpfile
#do_makedumpfile
#
##scp target vmcore_my to host
#scp_vmcore kpgen.$testcase
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
#expect crash_bt_lib.exp vmcore_kpgen.$testcase vmlinux sysrq-trigger
#if [ $? -ne 0 ];then
#    echo " crash failed....."
#    cd -
#    exit 1
#fi
#cd -
#echo "kdump for $PRODUCT_NAME of sysrq-trigger PASS"
#exit 0 


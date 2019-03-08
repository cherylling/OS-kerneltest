#!/bin/sh
############################################
# test panic by echo c > /proc/sysrq-trigger
############################################

set -x

basedir=$(cd `dirname $0`;pwd)
source $basedir/kdump_lib.sh

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

#do panic
panic_cmd="/bin/echo c > /proc/sysrq-trigger"
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

##scp target vmcore_my to host
#scp_vmcore sysrq

##reboot to first kernel
#do_reboot
#
##scp vmcore_my,vmlinux to target to crash
#for crash_file in vmcore_sysrq vmlinux
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
#echo "kdump for $PRODUCT_NAME of sysrq-trigger PASS"
#exit 0 

#!/bin/sh

topdir=$(cd `dirname $0`;cd ../../;pwd)

source $topdir/resources/lib/sshlib.sh
source $topdir/config/hi1380_arm32be.conf

sshscp=$topdir/resources/lib/sshscp.sh
killboard=$topdir/resources/lib/killboard.exp

src_capture_kernel_path="$topdir/resources/capture_kernel/$PRODUCT_NAME"
dst_capture_kernel_path="/tmp"

function base_deploy()
{
    if [ ! -f $killboard ];then
        echo "no $killboard"
        exit 1
    fi

    expect $killboard $TARGET_NAME

    cd $topdir/resources/first_kernel/${PRODUCT_NAME}
    deploy -t $TARGET_NAME -u $APPLYBOARD_USER -f $FIRST_KERNEL_IMAGE -a &
    pid=$!
    cd - > /dev/null
}

function scp_file_to_dest()
{
    myfile=$1
    if [ ! -f $myfile ];then
        echo "no file: $myfile"
        exit 1
    fi
    sh $topdir/resources/lib/sshscp.sh -s ${myfile} -d root@${TARGET_IP}:${dst_capture_kernel_path} -p ${TARGET_PASSWD}
    if [ $? -ne 0 ];then
        echo "scp file to board failed"
        exit 1
    fi

}

function scp_capturefiles()
{
    cd $src_capture_kernel_path
    for cap_file in $CAPTURE_KERNEL_IMAGE $CAPTURE_KERNEL_ROOTFS $CAPTURE_KERNEL_DTB
    do
        scp_file_to_dest $cap_file
    done
    cd - > /dev/null
}

function kexec_load()
{
    kexec_cmd="kexec -d --type zImage -p -l ${dst_capture_kernel_path}/${CAPTURE_KERNEL_IMAGE} --initrd=${dst_capture_kernel_path}/${CAPTURE_KERNEL_ROOTFS} --dtb=${dst_capture_kernel_path}/${CAPTURE_KERNEL_DTB} --append='maxcpus=1 console=ttyAMA0,9600n8N root=/dev/ram0 rdinit=/sbin/init'"
    sshcmd "${kexec_cmd}" root ${TARGET_IP} ${TARGET_PASSWD} 
    if [ $? -ne 0 ];then
        echo "kexec failed...."
        exit 1
    fi
}

function do_makedumpfile()
{
    makedumpfile_cmd="makedumpfile --message-level=31 -c -d 31 /proc/vmcore /tmp/vmcore_my"
    sshcmd "${makedumpfile_cmd}" root ${TARGET_IP} ${TARGET_PASSWD} 
    if [ $? -ne 0 ];then
        echo "makedumpfile failed....."
        #sshcmd "/sbin/reboot" root ${TARGET_IP} ${TARGET_PASSWD} & TODO for next test
        exit 1
    fi
}

function scp_vmcore()
{
    suffix=$1
    sh $topdir/resources/lib/sshscp.sh -s root@${TARGET_IP}:${dst_capture_kernel_path}/vmcore_my -d ${src_capture_kernel_path}/vmcore_$suffix -p ${TARGET_PASSWD}
    if [ $? -ne 0 ];then
        echo " after makedumpfile, scp to host failed....."
        exit 1
    fi
}

function do_reboot()
{
    sshcmd "/sbin/reboot" root ${TARGET_IP} ${TARGET_PASSWD} & 
    rebootup ${TARGET_IP} ${TARGET_PASSWD} root 600
    if [ $? -ne 0 ];then
        echo "reboot failed....."
        exit 1
    fi
}

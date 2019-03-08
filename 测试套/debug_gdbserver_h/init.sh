 #!/bin/bash

#. ./conf
 CDIR=`pwd`

 NFS_DIR="$CDIR/debug_gdbserver_h/testcase/bin/"

 echo $GDB_TOOL_DIR |sed 's/\//\\\//g' > 1
 GDB_DIR=`cat 1`
 rm 1 -rf

# HOST_GDB_TOOL "/opt/V1R2/opt/RTOS/bin/host_tools/arm-linux-gdb"
# HOST_SDK_LIB_DIR "/opt/V1R2/opt/RTOS/V100R002C00/armA9le/sdk/lib"
 echo $HOST_GDB_TOOL | sed 's/\//\\\//g' > 2
 HOST_GDB_TOOL=`cat 2`
 rm 2 -rf
 
# echo $HOST_SDK_LIB_DIR | sed 's/\//\\\//g' > 3
# HOST_SDK_LIB_DIR=`cat 3`
# rm 3 -rf

 cat /etc/exports |grep "$CDIR"
 if [ $? -eq 0 ];then
     echo "debug_gdbserver_h dir has in the exports file"
 else
     echo "" > /etc/exports
     echo "/home *(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
     echo "$CDIR *(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
     sudo /sbin/service nfsserver restart
     if [ $? -ne 0 ];then
         echo  "restart nfsserver fail"
         exit 1
     fi
 fi

 ssh root@$TARGET_IP ls /tmp/for_gdbserver_test
 if [ $? -ne 0 ];then
    ssh  root@$TARGET_IP  "umount /tmp/for_gdbserver_test"
    ssh root@$TARGET_IP ls /tmp/for_gdbserver_test
    if [ $? -ne 0 ];then
        ssh root@$TARGET_IP mkdir /tmp/for_gdbserver_test
        if [ $? -ne 0 ];then
            echo "mkdir /tmp/for_gdbserver_test in target fail"
            exit 1
        fi
    fi
 fi

# echo "ssh root@$TARGET_IP mount -t nfs -o nolock -o tcp $HOST_IP:$NFS_DIR /mnt/nfs"
 ssh  root@$TARGET_IP  "umount /tmp/for_gdbserver_test"
 ssh root@$TARGET_IP "mount -t nfs -o tcp,nolock $HOST_IP:$NFS_DIR /tmp/for_gdbserver_test"
 if [ $? -ne 0 ];then
     echo "mount debug_gdbserver_h dir onto target /tmp/for_gdbserver_test error"
     exit 2
 fi

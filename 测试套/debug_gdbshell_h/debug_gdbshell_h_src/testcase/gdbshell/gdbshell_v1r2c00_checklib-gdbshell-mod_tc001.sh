 #!/bin/bash

 ret=0
 if [ -f /usr/lib/libgdbhook.so ];then
     ls -l /usr/lib/libgdbhook.so |grep "\-rwxr-xr-x"  ||ret=`expr $ret + 1`
 fi
 
 if [ -f /usr/lib64/libgdbhook.so ];then
     ls -l /usr/lib64/libgdbhook.so |grep "\-rwxr-xr-x"  ||ret=`expr $ret + 1`
 fi


 if [ -f /usr/bin/gdbshell ];then
     ls -l /usr/bin/gdbshell |grep "\->" || ls -l /usr/bin/gdbshell |grep "\-rwxr-xr-x"  ||ret=`expr $ret + 1`
 fi
 
 if [ -f /usr/bin/gdbshell32 ];then
     ls -l /usr/bin/gdbshell32 |grep "\-rwxr-xr-x"  ||ret=`expr $ret + 1`
 fi

 if [ $ret -ne 0 ];then
     echo "FAIL"
 else
     echo "PASS"
 fi
 
 exit $ret


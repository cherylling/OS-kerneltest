#!/bin/bash

ssh  root@$TARGET_IP "killall gdb"

CDIR=`pwd`
ssh ConnectTimeout=5 -o ServerAliveInterval=5 -o ServerAliveCountMax=2 root@${TARGET_IP} "rm -rf /tmp/gdb_bin/"

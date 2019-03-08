#!/bin/bash

ssh  root@$TARGET_IP "killall gdbserver"
ssh  root@$TARGET_IP  "umount /tmp/for_gdbserver_test"


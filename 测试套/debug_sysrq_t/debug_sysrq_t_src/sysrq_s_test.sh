#!/bin/bash

echo s > /proc/sysrq-trigger
sleep 1
dmesg | tail -500 |  grep "Emergency Sync complete"

if [ $? -ne 0  ];then
        echo s > /proc/sysrq-trigger
        dmesg | tail -500 |  grep "Emergency Sync complete"
        if [ $? -ne 0  ];then
           echo "Test FAILED: sysrq s test fialed, emergency sync fialed."
           exit 1
        fi

fi

exit 0

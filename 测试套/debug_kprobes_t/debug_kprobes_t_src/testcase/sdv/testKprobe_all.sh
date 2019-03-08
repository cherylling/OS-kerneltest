#!/bin/bash

for ((i=1;i<20;i++))
do
	./testKprobeEvents_001.sh
done &

for ((i=1;i<20;i++))
do
        ./testKprobes_001.sh 
done &

for ((i=1;i<20;i++))
do
        ./testRegKprobe_001.sh
done &

for ((i=1;i<20;i++))
do
        ./testRegKprobe_007.sh
done &

for ((i=1;i<20;i++))
do
        ./testRegKprobes_002.sh
done &

for ((i=1;i<20;i++))
do
        ./testRegKretprobe_004.sh
done &

for ((i=1;i<20;i++))
do
        ./testUnregKprobes_002.sh
done &

for ((i=1;i<20;i++))
do
        ./testDisableKprobe_002.sh
done &

for ((i=1;i<20;i++))
do
        ./testEnableKretprobe_003.sh
done &

for ((i=1;i<20;i++))
do
        ./testSysKprobesEnable_002-2.sh
done &

for ((i=1;i<20;i++))
do
        ./testRegKprobe_007-1.sh
done &

for ((i=1;i<20;i++))
do
        ./testRegKprobe_007-2.sh
done &

for ((i=1;i<20;i++))
do
        ./testRegKprobe_007-3.sh
done &

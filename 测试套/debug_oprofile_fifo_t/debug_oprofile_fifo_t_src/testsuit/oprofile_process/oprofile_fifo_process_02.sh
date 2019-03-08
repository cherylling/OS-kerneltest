#! /bin/bash
ret=0


opcontrol --shutdown
opcontrol --reset
opcontrol --init
opcontrol --no-vmlinux --setup --event=CPU_CLK_UNHALTED:90000::0:1 --event=ITLB_MISSES:3000000::0:1
opcontrol -c 2
opcontrol --start

./oprofile_fifo_process_02 $2 &
sleep 200 
opcontrol --dump
opcontrol --stop

opreport -l > $1
grep ITLB_MISSES $1
if [ $? -ne 0 ];then
	echo FAIL
	ret=$((ret+1))
else
	echo PASS
fi
exit $ret

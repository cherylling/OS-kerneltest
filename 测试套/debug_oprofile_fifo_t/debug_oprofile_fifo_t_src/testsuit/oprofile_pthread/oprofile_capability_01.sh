#! /bin/bash
ret=0
opcontrol --shutdown
opcontrol --reset
opcontrol --init
opcontrol --no-vmlinux --setup --event=CPU_CLK_UNHALTED:90000::0:1 --event=DTLB_MISSES:3000000::0:1
opcontrol -c 2
opcontrol --start

sleep $1 
rate=`top -n 1 |awk ' NR==8{print $10}'`
if [ $rate -lt 20 ];then
	echo FAIL
	ret=$((ret+1))
else
	echo PASS
fi
opcontrol --dump
opcontrol --stop

exit $ret

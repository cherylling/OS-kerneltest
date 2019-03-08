#!/bin/bash
obj=$1
exe=$2
CROSS_COMPILE=$3
listfile=./${exe}.list

[ -f $listfile ] && rm -rf $listfile

symbol_list=`${CROSS_COMPILE}objdump -d $obj | grep "<.*>:" | awk '{print $2}' | awk -F: '{print $1}' | awk -F'<' '{print $2}' | awk -F'>' '{print $1}'`
for s in $symbol_list
do
	addr=`${CROSS_COMPILE}nm $exe | awk  -v aaa="$s" '{if($3==aaa) print "0x"$1}'`
	echo "$s  $addr " >> $listfile
done


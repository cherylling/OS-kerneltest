#!/bin/bash

# CPU event mode
# EVENTMODE  0:timer mode 1:event mode
EVENTMODE=0
ophelp | grep -i "oprofile: available events" && EVENTMODE=1
if [ $? -ne 0 ];then
	echo "Not support event mode"
	echo "Using timer mode as default..."
	#EVENTMODE=0
fi

# IF USE event mode
if [ $EVENTMODE == 1 ];then
	DefaultEvent=CPU_CYCLES
	ophelp > events.file 
	if [ $? -ne 0 ]
	then
		echo "error: ophelp fail"	
		exit 1
	fi
	line=`grep "$DefaultEvent" events.file | wc -l` 
	if [ $line -eq 0 ] 
	then 
		Event=`grep "CPU_CLK" events.file | grep "counter: all" |     awk -F':' '{print $1}'`
	else
		Event=$DefaultEvent
	fi
fi
# END event/timer mode 

## diff?
diff --help  
if [ $? -eq 0 ]
then 
	DIFF=diff
else
	DIFF="busybox diff"
fi 

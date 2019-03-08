#/bin/sh
if [ -r /proc/meminfo ]
then
    TMP=`grep 'MemTotal:' /proc/meminfo | awk '{print $2}'`
    if [ X$TMP != X ]
    then	
        MB=`echo $TMP / 1024 | bc 2>/dev/null`
	if [ X$MB = X ]
	then	
            MB=`expr $TMP / 1024 2>/dev/null`
	fi
    fi
    TMP=`grep 'Mem:' /proc/meminfo | awk '{print $2}'`
    if [ X$MB = X -a X$TMP != X ]
    then	
        MB=`echo $TMP / 1048576 | bc 2>/dev/null`
	if [ X$MB = X ]
	then	
            MB=`expr $TMP / 1048576 2>/dev/null`
	fi
    fi
fi
if [ X$MB = X ]
then	
	MB=`./memsize 4096`
fi
if [ $MB -gt 1790 ]
then
	MB=1790
fi
echo $MB

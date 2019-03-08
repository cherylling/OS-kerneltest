#!/bin/bash

LOG=/tmp/perf_no_buildid
ret=0

perf record --no-buildid sleep 5 > $LOG 2>&1
cat $LOG | grep "0.000 MB" > /dev/null
if [ $? -ne 0 ];then
        echo "PASS!"
else
        echo "FAILED!the size of perf.data displays 0.000 MB!"
        ret=1
fi

rm -f $LOG
exit $ret


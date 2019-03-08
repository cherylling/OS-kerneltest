#!/bin/bash
ret=0

dotest()
{
perf probe -a schedule
perf record -g -e probe:schedule -aR sleep 1
if [ $? -ne 0 ];then
    {
    echo perf record fail
    ret=$((ret+1))
    }
fi
perf report|grep "\-\-\- "
if [ $? -ne 0 ]; then
	{
		echo perf read write val error
		ret=$((ret+1))
	}
    else
        {
            echo perf rw val succeed
        }
fi
}

doclean()
{
    perf probe -d "*"
}
dotest
doclean
exit $ret

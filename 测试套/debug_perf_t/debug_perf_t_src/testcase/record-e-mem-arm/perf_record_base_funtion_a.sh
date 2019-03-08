#!/bin/bash
ret=0

dotest()
{
perf probe -a schedule
perf record -e probe:schedule sleep 1
if [ $? -ne 0 ];then
    {
    echo perf record fail
    ret=$((ret+1))
    }
fi
perf report|grep "100.00%"
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
perf record -a -e probe:schedule sleep 1
if [ $? -ne 0 ];then
    {
    echo perf record fail
    ret=$((ret+1))
    }
fi
perf report|grep "100.00%"
if [ $? -eq 0 ]; then
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

#!/bin/bash
ret=0

dotest()
{
perf record -e kmem:kfree sleep 1
if [ $? -ne 0 ];then
    {
    echo perf record fail
    ret=$((ret+1))
    }
fi
perf report|grep "sleep"
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

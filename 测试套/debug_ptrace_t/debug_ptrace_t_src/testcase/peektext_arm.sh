 #!/bin/bash

 ./sig_loop &
 PID=$!
 sleep 1
 ./ptrace_peektext_arm $PID
iret=$?
if [ $iret -eq 0 ] 
then
    echo PASS
	exit 0
	    else
	        echo FAILED
			exit 1
fi
sleep 1

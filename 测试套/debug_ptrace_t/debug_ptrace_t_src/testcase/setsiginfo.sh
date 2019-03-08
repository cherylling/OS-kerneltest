 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_setsiginfo $PID

 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_setfpregs $PID

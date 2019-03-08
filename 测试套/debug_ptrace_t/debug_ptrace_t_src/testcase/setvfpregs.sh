 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_setvfpregs $PID

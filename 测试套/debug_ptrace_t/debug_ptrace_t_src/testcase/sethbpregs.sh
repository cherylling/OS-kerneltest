 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_sethbpregs $PID

 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_setregs $PID

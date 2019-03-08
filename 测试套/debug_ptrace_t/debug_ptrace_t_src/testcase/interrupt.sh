 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_interrupt $PID

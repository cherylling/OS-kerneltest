 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_attach $PID

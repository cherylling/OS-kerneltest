 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_seize_fork $PID
 ./ptrace_seize_vfork $PID
 ./ptrace_seize_clone $PID

 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_listen $PID


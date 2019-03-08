 #!/bin/bash

 ./sig_loop &
 PID=$!
 ./ptrace_pokeuser $PID

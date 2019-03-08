 #!/bin/bash

 ssh root@$TARGET_IP "rm -rf /tmp/for_gdbshell_test/"
 ssh root@$TARGET_IP "mkdir -p /tmp/for_gdbshell_test"
 scp -r debug_gdbshell_h/testcase/bin/* root@$TARGET_IP:/tmp/for_gdbshell_test/

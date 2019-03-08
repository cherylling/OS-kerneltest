#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <syscall.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <errno.h>

int main(void)
{
    long long counter = 0;  /*  machine instruction counter */
    int wait_val;           /*  child's return value low=0x7f and High=05 (SIGTRAP) ,the wait_val is 0x05 << 8 | 0x7f = 0x57f = 1407
    */
    int pid;  
    puts("Please wait");

    switch (pid = fork()) {
        case -1:
            perror("fork");
            break;
        case 0:
            ptrace(PTRACE_TRACEME, 0, 0, 0);
            execl("/bin/ls", "ls", "/", NULL);
            break;
        default:
            wait(&wait_val);
            while (wait_val == 1407 ) {
                counter++;
                if (ptrace(PTRACE_SINGLESTEP, pid, 0, 0) != 0)
                    perror("ptrace");
                wait(&wait_val);
            }
    }
    printf("Number of machine instructions : %lld\n", counter);
    return 0;
}

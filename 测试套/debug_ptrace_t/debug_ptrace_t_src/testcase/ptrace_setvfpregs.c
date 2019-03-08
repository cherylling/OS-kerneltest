#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <asm/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/user.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[])
{   
    pid_t traced_process;
    struct user regs;
    int ret = 0;

    if(argc != 2) {
        printf("Usage: %s <pid to be traced>\n", argv[0]);
        exit(1);
    }
    traced_process = atoi(argv[1]);

    ret = ptrace(PTRACE_ATTACH, traced_process, NULL, NULL);
    if(ret != 0)
    {
        printf("PTRACE_ATTACH error, errno:%d\n",errno);
        return ret;
    }
    wait(NULL);
   
    ret = ptrace(PTRACE_GETVFPREGS, traced_process, NULL, &regs);
    if(ret != 0)
    {
        printf("PTRACE_GETVFPREGS error, errno:%d\n",errno);
        return ret;
    }

    // Setting the eip back to the original instruction to let 
    // the process continue 
    ret = ptrace(PTRACE_SETVFPREGS, traced_process, NULL, &regs);
    if(ret != 0)
    {
        printf("PTRACE_SETVFPREGS error, errno:%d\n",errno);
        return ret;
    }
    printf("PTRACE_SETVFPREGS SUCCESS \n");

    ptrace(PTRACE_DETACH, traced_process, NULL, NULL);
    return 0;
}

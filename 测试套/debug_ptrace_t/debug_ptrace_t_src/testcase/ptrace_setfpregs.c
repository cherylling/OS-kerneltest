#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/user.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[])
{   
    pid_t traced_process;
#if defined(__arm__)
    struct user regs;
#elif defined(__x86_64__)
    struct user_fpregs_struct regs;
#elif defined(__i386__)
    struct user_fpregs_struct regs;
#elif defined(__powerpc__)
    struct user regs;
#else
    printf("not supported");
    exit(1);
#endif
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
   
    ret = ptrace(PTRACE_GETFPREGS, traced_process, NULL, &regs);
    if(ret != 0)
    {
        printf("PTRACE_GETFPREGS error, errno:%d\n",errno);
        return ret;
    }

    ret = ptrace(PTRACE_SETFPREGS, traced_process, NULL, &regs);
    if(ret != 0)
    {
        printf("PTRACE_SETFPREGS error, errno:%d\n",errno);
        return ret;
    }
    printf("PTRACE_SETFPREGS SUCCESS \n");

    ptrace(PTRACE_DETACH, traced_process, NULL, NULL);
    return 0;
}

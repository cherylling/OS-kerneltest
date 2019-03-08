#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <asm/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

int main()
{
    struct user regs;
    pid_t child;
    int status;
    long ptrace_ret;

    child = fork();
    if(child < 0)
    {
        printf("fork error\n");
        exit(1);
    }
    else if(child == 0)
    {
        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
        execl("rmfile", "rmfile", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_GETWMMXREGS, child, NULL, &regs);
        if (0 != ptrace_ret)
        {
            printf("PTRACE_GETWMMXREGS TEST FAILED! errno : %d\n", errno);
            exit(1);
        }

        printf("uregs[0] %lu\n", regs.regs.uregs[0]);

        ptrace_ret = ptrace(PTRACE_SETWMMXREGS, child, NULL, &regs);
        if(ptrace_ret == 0)
        {
            printf("TEST PASSED!\n");
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(0);
        }
        else
        {
            printf("ptrace PTRACE_SETWMMXREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
    }

    exit(0);
}

#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <errno.h>

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
//        sleep(1);
        execl("/bin/ls", "ls", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_GETREGS, child, NULL, &regs);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_GETREGS success %ld \n", regs.u_tsize);

        ptrace_ret = ptrace(PTRACE_PEEKUSER, child, (void *) (sizeof (struct user) + 1), NULL);
        if (-1 == ptrace_ret && EIO == errno)
        {
            printf("ptrace PTRACE_PEEKUSER success\n");
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(0);
        }
        else
        {
            printf("PTRACE PEEKUSER FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
    }

    exit(0);
}

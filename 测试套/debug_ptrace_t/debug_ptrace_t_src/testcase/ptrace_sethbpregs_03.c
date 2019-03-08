#include <stdio.h>
#include <stdlib.h>
#include <generated/autoconf.h>
#include <sys/ptrace.h>
#include <asm/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

int main(int argc, char **argv)
{
    pid_t child;
    long ptrace_ret;
    int status;

    child = fork();
    if(child < 0)
    {
        printf("fork error\n");
        exit(1);
    }
    else if(child == 0)
    {
        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
       // sleep(1);
        execl("rmfile", "rmfile", NULL);
        exit(0);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   
      
        ptrace_ret = ptrace(PTRACE_SETHBPREGS, child, (void *) 1, NULL);
        if (0 !=  ptrace_ret && EFAULT == errno)
        {
            printf("TEST PASSED!\n");
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(0);
        }
        else
        {
            printf("ptrace PTRACE_SETHBPREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
    }
}

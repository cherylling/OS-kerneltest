#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <asm/ptrace.h>

int main()
{
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
 //       sleep(1);
        execl("/bin/ls", "ls", "/", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_SYSEMU, child, NULL, (void *) SIGCONT);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_SYSEMU error %d \n", errno);
            ptrace_ret = ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        else
        {
            printf("TEST PASSED!\n");
            ptrace_ret = ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(EXIT_SUCCESS);
        }
    }

    exit(0);
}

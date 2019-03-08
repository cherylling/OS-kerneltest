#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/user.h>

int main(int argc, char **argv)
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
        execl("rmfile", "rmfile", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_ATTACH, child, NULL, NULL);
        if (0 != ptrace_ret && EPERM == errno)
        {
            printf("TEST PASSED!\n");
            exit(0);
        }
        else
        {
            printf("PTRACE ATTACH TEST FAILED!\n errno %d\n", errno);
            exit(1);
        }


    }
    exit(0);
}

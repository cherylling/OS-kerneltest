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
 //       sleep(1);
        execl("rmfile", "rmfile", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_DETACH, child, NULL, (void *) SIGCONT);
        if (0 != ptrace_ret)
        {
            printf("errno : %d\n", errno);
            perror("test failed!\n");
            printf("TEST FAILED!\n");
            return 1;
        }
        else
        {
            printf("TEST PASSED!\n");
            return 0;
        }

    }
    exit(0);
}

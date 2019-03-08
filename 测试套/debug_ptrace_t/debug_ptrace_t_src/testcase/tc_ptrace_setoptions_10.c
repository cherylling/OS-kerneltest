#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

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
        exit(0);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_SETOPTIONS, child, NULL, PTRACE_O_MASK);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_SETOPTIONS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        else
        {
            printf("ptrace PTRACE_SETOPTIONS SUCCESS!\n");
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(0);
        }
    }
}

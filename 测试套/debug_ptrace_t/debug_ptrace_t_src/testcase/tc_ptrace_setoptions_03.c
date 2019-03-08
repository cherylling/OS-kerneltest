#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <signal.h>

int main()
{
    pid_t child;
    int status;
    long ptrace_ret;

    int result = SIGTRAP | 0x80;
    int stop_sig;

    child = fork();
    if(child < 0)
    {
        printf("fork error\n");
        exit(1);
    }
    else if(child == 0)
    {
        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
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
       
        ptrace_ret = ptrace(PTRACE_SETOPTIONS, child, NULL, PTRACE_O_TRACESYSGOOD);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_SETOPTIONS PTRACE_O_TRACESYSGOOD error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }

        
        ptrace_ret = ptrace(PTRACE_SYSCALL, child, NULL, (void *) SIGCONT);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_SYSCALL error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }

        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        stop_sig  = WSTOPSIG(status);
        if (result != stop_sig)
        {
            printf("TEST FAILED!\n");
            printf("the result must be %d, ", result);
            printf("but WSTOPSIG is %d\n", stop_sig);
            exit(1);
        }

        printf("the result is %d\n", result);
        printf("TEST PASSED!\n");
        exit(0);

    }
}

#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/user.h>
#include <linux/ptrace.h>
int main()
{
    siginfo_t child_sig;
   struct ptrace_peeksiginfo_args peeksiginfo_args;
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
       execl("/bin/ls", "ls","/", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_PEEKSIGINFO, child, &peeksiginfo_args, &child_sig);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_PEEKSIGINFO error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_PEEKSIGINFO success %d \n", child_sig.si_signo);

        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    exit(0);
}

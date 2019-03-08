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
    siginfo_t child_sig;
    pid_t child;
    int status;
    long ptrace_ret;
 /*   
    if(argc != 2) 
    {
        printf("Usage: %s <pid to be traced>\n", argv[0]);
        exit(1);
    }

    child = atoi(argv[1]);
    ptrace_ret = ptrace(PTRACE_ATTACH, child, NULL, NULL);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_ATTACH process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_ATTACH PASS\n");
    */

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

        ptrace_ret = ptrace(PTRACE_GETSIGINFO, child, NULL, &child_sig);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETSIGINFO error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_GETSIGINFO success %d \n", child_sig.si_signo);

        //        child_sig.si_signo = 18;
        //I don't known why it causes EFAULT error for arm     
        ptrace_ret = ptrace(PTRACE_SETSIGINFO, child, NULL, NULL);
        if(ptrace_ret != 0 && errno == EFAULT)
        {
            printf("TEST SUCCESS!\n");
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(EXIT_SUCCESS);
        }
        else
        {
            printf("ptrace PTRACE_SETSIGINFO error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
    }
    exit(0);
}

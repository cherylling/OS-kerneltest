#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <asm/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <linux/sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <asm/ldt.h>

int main()
{
    pid_t child;
    int status;
    long ptrace_ret;
    struct user_desc thinfo;
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

        ptrace_ret = ptrace(PTRACE_GET_THREAD_AREA, child, (void *) -1, &thinfo);
        if(ptrace_ret != 0 && EIO == errno)
        {
            printf("TEST PASSED!\n");
            exit(0);
        }
        else
        {
            printf("ptrace PTRACE_GET_THREAD_AREA error %d \n", errno);
            exit(1);
        }
    }

    exit(0);
}

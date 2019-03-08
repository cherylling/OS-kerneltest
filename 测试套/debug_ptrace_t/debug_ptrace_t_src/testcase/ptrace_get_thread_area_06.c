#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <asm/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <linux/sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <sys/uio.h>
#include <sys/procfs.h>  

//for arm
int main()
{
    pid_t child;
    int status;
    long ptrace_ret;
#if defined(__aarch64__)
    struct iovec regs;
    elf_gregset_t pt_regs;
    regs.iov_base = &pt_regs;
    regs.iov_len = sizeof (pt_regs);
#elif defined(__arm__)
   struct user regs;
#else
   print("not suported");
#endif

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
        
        ptrace_ret = ptrace(PTRACE_GET_THREAD_AREA, -1, NULL, &regs);
        if(ptrace_ret != 0 && errno == ESRCH)
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

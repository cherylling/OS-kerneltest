#include <stdio.h>
#include <stdlib.h>
//#include <generated/autoconf.h>
#include <sys/ptrace.h>
#include <asm/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include "hw_breakpoint.h"
#include <sys/uio.h>
#include <sys/procfs.h>
int main(int argc, char **argv)
{
    pid_t child;
    long ptrace_ret;
    int status;
#if defined(__aarch64__)
    struct iovec regs;
    elf_gregset_t pt_regs;
    regs.iov_base = &pt_regs;
    regs.iov_len = sizeof (pt_regs);
#elif defined(__arm__)
    struct user regs;
#else
    printf("not support");
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
      
        ptrace_ret = ptrace(PTRACE_SETHBPREGS, child, (void *)(-(ARM_MAX_BRP << 1) - 1), &regs);
        if (0 !=  ptrace_ret && EINVAL == errno)
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

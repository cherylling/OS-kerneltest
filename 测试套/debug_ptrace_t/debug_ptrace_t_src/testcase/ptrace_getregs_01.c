#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <asm/ptrace.h>
#include <sys/uio.h>
#include <sys/procfs.h> 
int main()
{
#if defined(__arm__)
    struct user regs;
#elif defined(__x86_64__)
    struct user_regs_struct regs;
#elif defined(__i386__)
    struct user_regs_struct regs;
#elif defined(__powerpc__)
    struct user regs;
#elif defined(__aarch64__)
    struct iovec regs;
    elf_gregset_t pt_regs;
    regs.iov_base = &pt_regs;
    regs.iov_len = sizeof (pt_regs);
    #define PTRACE_GETREGS PTRACE_GETREGSET

#else
    printf("not supported");
    exit(1);
#endif
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

        ptrace_ret = ptrace(PTRACE_GETREGS, -1, NULL, &regs);
        if(ptrace_ret != 0 && ESRCH == errno)
        {
            printf("TEST PASSED!\n");
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(0);
        }
        else
        {
            printf("ptrace PTRACE_GETREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
    }

    exit(0);
}

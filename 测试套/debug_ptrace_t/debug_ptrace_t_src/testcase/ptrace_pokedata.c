#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/user.h>
#include <sys/types.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <sys/uio.h>
#include <linux/elf.h>  
int main(int argc, char *argv[])
{   
    pid_t child;
#if defined(__aarch64__)
    struct iovec regs;
    elf_gregset_t pt_regs;
    regs.iov_base = &pt_regs;
    regs.iov_len = sizeof (pt_regs);
#else
    struct user regs;
#endif
    long ptrace_ret;

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
    wait(NULL);
#if defined(__aarch64__)
        ptrace_ret = ptrace(PTRACE_GETREGSET, child, NT_PRSTATUS, &regs);
#else
    ptrace_ret = ptrace(PTRACE_GETREGS, child, NULL, &regs);
#endif
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_GETREGS process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_GETREGS PASS\n");
/*
    ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.start_stack, NULL);
    printf("start_stack: %lx Instruction executed: %lx\n", regs.start_stack, ptrace_ret);

    ptrace_ret = ptrace(PTRACE_POKEDATA, child, (void *)regs.start_stack, ptrace_ret);
*/
#if defined(__arm__)
    ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.regs.uregs[1], NULL);

    if (-1 == ptrace_ret)
    {
        printf("ptrace PTRACE_PEEKDATA process %d error %d\n", child, errno);
        exit(1);
    }
    
    printf("ptrace PTRACE_PEEKDATA PASS\n");
    
    printf("regs.uregs[1]: %lx Instruction executed: %lx\n", regs.regs.uregs[1], ptrace_ret);

    ptrace_ret = ptrace(PTRACE_POKEDATA, child, (void *)regs.regs.uregs[1], (void *)&ptrace_ret);

#elif defined(__x86__)
   ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.regs.rsp, NULL);

    if (-1 == ptrace_ret)
    {
        printf("ptrace PTRACE_PEEKDATA process %d error %d\n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_PEEKDATA PASS\n");

    printf("rsp: %lx Instruction executed: %lx\n", regs.regs.rsp, ptrace_ret);

    ptrace_ret = ptrace(PTRACE_POKEDATA, child, (void *)regs.regs.rsp, (void *)&ptrace_ret);

#elif  defined(__aarch64__)
 ptrace_ret = ptrace(PTRACE_PEEKDATA, child, pt_regs[1], NULL);

    if (-1 == ptrace_ret)
    {
        printf("ptrace PTRACE_PEEKDATA process %d error %d\n", child, errno);
        exit(1);
    }

    printf("ptrace PTRACE_PEEKDATA PASS\n");
//    printf("regs.uregs[1]: %lx Instruction executed: %lx\n", pt_regs[1], ptrace_ret);
    ptrace_ret = ptrace(PTRACE_POKEDATA, child, (void *)pt_regs[1], (void *)&ptrace_ret);
#endif
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_POKEDATA process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_POKEDATA PASS\n");

    ptrace_ret = ptrace(PTRACE_DETACH, child, NULL, NULL);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_DETACH process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_DETACH PASS\n");

    return 0;
}

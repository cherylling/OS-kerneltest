#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <sys/uio.h>
#include <linux/elf.h>
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
//        sleep(1);
        execl("rmfile", "rmfile", NULL);
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   
#if defined(__aarch64__)
        ptrace_ret = ptrace(PTRACE_GETREGSET, child, NT_PRSTATUS, &regs);
#else
        ptrace_ret = ptrace(PTRACE_GETREGS, child, NULL, &regs);
#endif
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }

#if defined(__i386__)
        //get the eip
        printf("ptrace PTRACE_GETREGS success %lx \n", regs.eip);
        //set the eip
        ptrace_ret = ptrace(PTRACE_POKETEXT, child, regs.eip, NULL);
        if (-1 == ptrace_ret)
        {
            printf("PTRACE POKETEXT FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }  

        ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.eip, NULL);
#elif defined(__x86_64__)
        //get the rip
        printf("regs.regs.r15 success %lx \n", regs.rip);
        //set the rip
        ptrace_ret = ptrace(PTRACE_POKETEXT, child, regs.rip, NULL);
        if (-1 == ptrace_ret)
        {
            printf("PTRACE POKETEXT FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.rip, NULL);
#elif defined(__powerpc__)
        //get the nip
        printf("regs.regs.r15 success %lx \n", regs.regs.nip);
        //set the nip
        ptrace_ret = ptrace(PTRACE_POKETEXT, child, regs.regs.nip, NULL);
        if (-1 == ptrace_ret)
        {
            printf("PTRACE POKETEXT FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.regs.nip, NULL);
#elif defined(__arm__)
        //get the uregs[0]
        printf("ptrace PTRACE_GETREGS success %lx \n", regs.regs.uregs[15]);
        //set the uregs[0]
        ptrace_ret = ptrace(PTRACE_POKETEXT, child, regs.regs.uregs[15], NULL);
        if (-1 == ptrace_ret)
        {
            printf("PTRACE POKETEXT FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKDATA, child, regs.regs.uregs[15], NULL);
#elif defined(__aarch64__)
        //get the uregs[0]
        printf("ptrace PTRACE_GETREGS success %lx \n", pt_regs[15]);
        //set the uregs[0]
        ptrace_ret = ptrace(PTRACE_POKETEXT, child, pt_regs[15], NULL);
        if (-1 == ptrace_ret)
        {
            printf("PTRACE POKETEXT FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKDATA, child, pt_regs[15], NULL);
#else
        printf("not support!\n");
        exit(1);
#endif

        if (0 != ptrace_ret)
        {
            printf("ptrace_ret : %lx\n", ptrace_ret);
            printf("PTRACE POKETEXT FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }

        printf("ptrace PTRACE_POKETEXT success %lx \n", ptrace_ret);

        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    exit(0);
}

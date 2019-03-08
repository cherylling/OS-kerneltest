#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <stddef.h>

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
#else
    printf("not supported");
    exit(1);
#endif
    pid_t child;
    int status;
    long ptrace_ret;
    unsigned long regs_result;

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

        ptrace_ret = ptrace(PTRACE_GETREGS, child, NULL, &regs);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }

#if defined(__i386__)
        //get the old eip
        printf("ptrace PTRACE_GETREGS success %lu \n", regs.eip);
        regs_result = 0;
        //set the eip
        ptrace_ret = ptrace(PTRACE_POKEUSER, child, 4 * 12, 0);
        if (0 != ptrace_ret)
        {
            printf("PTRACE_POKEUSER TEST FAILED! errno : %d\n", errno);
            exit(1);
        }

        ptrace_ret = ptrace(PTRACE_PEEKUSER, child, 4 * 12, NULL);
#elif defined(__x86_64__)
        //get the rip
        printf("regs.regs.r15 success %lu \n", regs.rip);
        regs_result = 0;
        //set the rip
        ptrace_ret = ptrace(PTRACE_POKEUSER, child, 8 * 16, 0);
        if (0 != ptrace_ret)
        {
            printf("PTRACE_POKEUSER TEST FAILED! errno : %d\n", errno);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKUSER, child, 8 * 16, NULL);
#elif defined(__powerpc__)
        //get the nip
        printf("regs.regs.r15 success %lu \n", regs.regs.nip);
        regs_result = 0;
        //set the nip
        ptrace_ret = ptrace(PTRACE_POKEUSER, child, 4 * 32, 0);
        if (0 != ptrace_ret)
        {
            printf("PTRACE_POKEUSER TEST FAILED! errno : %d\n", errno);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKUSER, child, 4 * 32, NULL);
#elif defined(__arm__)
        //get the uregs[0]
        printf("ptrace PTRACE_GETREGS success %lu \n", regs.regs.uregs[15]);
        regs_result = 0;
        //set the uregs[0]
        ptrace_ret = ptrace(PTRACE_POKEUSER, child, 4 * 15, 0);
        if (0 != ptrace_ret)
        {
            printf("PTRACE_POKEUSER TEST FAILED! errno : %d\n", errno);
            exit(1);
        }
        ptrace_ret = ptrace(PTRACE_PEEKUSER, child, 4 * 15, NULL);
#else
        printf("not support!\n");
        exit(1);
#endif

        if (-1 == ptrace_ret || ptrace_ret != regs_result)
        {
            printf("ptrace_ret = %ld\n", ptrace_ret);
            printf("regs_result = %ld\n", regs_result);
            printf("PTRACE POKEUSER FAILED! errno %d\n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }

        printf("ptrace PTRACE_POKEUSER success\n");

        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    exit(0);
}

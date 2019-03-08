#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

int main()
{
#if defined(__arm__)
    struct user regs;
#elif defined(__x86_64__)
    struct user_fpregs_struct regs;
#elif defined(__i386__)
    struct user_fpregs_struct regs;
#elif defined(__powerpc__)
    struct user regs;
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

        ptrace_ret = ptrace(PTRACE_GETFPREGS, child, NULL, &regs);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETFPREGS error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_GETFPREGS success \n");
        
        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    exit(0);
}

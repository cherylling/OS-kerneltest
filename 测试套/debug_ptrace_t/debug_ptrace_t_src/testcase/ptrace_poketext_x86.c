#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/user.h>
#include <sys/types.h>
#include <sys/ptrace.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{   
    pid_t child;
    struct user regs;
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
    ptrace_ret = ptrace(PTRACE_GETREGS, child, NULL, &regs);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_GETREGS process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_GETREGS PASS\n");

/*    ptrace_ret = ptrace(PTRACE_PEEKTEXT, child, (void *)regs.start_stack, NULL);
    printf("start_stack : %lx Instruction executed: %lx\n", regs.start_stack, ptrace_ret);

    ptrace_ret = ptrace(PTRACE_POKETEXT, child, (void *)regs.start_stack, ptrace_ret);
*/   
//#ifdef CONFIG_X86_32    
//    ptrace_ret = ptrace(PTRACE_PEEKTEXT, child, regs.regs.esp, NULL);
//    printf("rsp: %lx Instruction executed: %lx\n", regs.regs.esp, ptrace_ret);
//    ptrace_ret = ptrace(PTRACE_POKETEXT, child, (void *)regs.regs.esp, ptrace_ret);
    ptrace_ret = ptrace(PTRACE_PEEKTEXT, child, regs.regs.rsp, NULL);
    
    if (-1 == ptrace_ret)
	{
        printf("ptrace PTRACE_PEEKTEXT process %d error %d\n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_PEEKTEXT PASS\n");

    printf("rsp: %lx Instruction executed: %lx\n", regs.regs.rsp, ptrace_ret);

    ptrace_ret = ptrace(PTRACE_POKETEXT, child, (void *)regs.regs.rsp, (void *)&ptrace_ret);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_POKETEXT process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_POKETEXT PASS\n");

    ptrace_ret = ptrace(PTRACE_DETACH, child, NULL, NULL);
    if(ptrace_ret != 0)
    {
        printf("ptrace PTRACE_DETACH process %d error %d \n", child, errno);
        exit(1);
    }
    printf("ptrace PTRACE_DETACH PASS\n");

    return 0;
}

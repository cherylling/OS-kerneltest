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
    struct iovec regs;
    elf_gregset_t pt_regs;
    regs.iov_base = &pt_regs;
    regs.iov_len = sizeof (pt_regs);

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
        execl("/bin/ls", "ls","/", NULL);
    }
     else
    {
        if ((waitpid(child, &status, 0)) < 0)
        {
            printf("waitpid() failed\n");
            exit(1);
        }

      ptrace_ret = ptrace(PTRACE_GETREGSET, child, NT_PRSTATUS , &regs);
      if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETREGSET error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_GETREGSET success\n");

        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    exit(0);
}

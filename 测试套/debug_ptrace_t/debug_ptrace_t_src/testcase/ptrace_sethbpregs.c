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
#include <sys/uio.h>
#include <sys/procfs.h>
int main(int argc, char **argv)
{
    pid_t child;
    long ptrace_ret;
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

    if (argc != 2)
    {
        printf("Usage: %s <pid to be traced>\n", argv[0]);
        exit(1);
    }

    child = atoi(argv[1]);

 //   child = fork();
//    if(child < 0)
 //   {
 //       printf("fork error\n");
  //      exit(1);
   // }
   // else if(child == 0)
   // {
     //   ptrace(PTRACE_TRACEME, 0, NULL, NULL);
       // sleep(1);
 //       execl("rmfile", "rmfile", NULL);
  //  }
//    else
//    {
      //  if ((waitpid(child, &status, 0)) < 0)  
      //  {   
      //      printf("waitpid() failed\n");
      //      exit(1);
      //  }   
      
    ptrace_ret = ptrace(PTRACE_ATTACH, child, NULL, NULL);
    if (0 != ptrace_ret)
    {
        printf("PTRACE_ATTACH error, errno:%d\n", errno);
        return ptrace_ret;
    }
    wait(NULL);

    ptrace_ret = ptrace(PTRACE_GETHBPREGS, child, 0, &regs);
    if (0 !=  ptrace_ret)
    {
        printf("ptrace PTRACE_GETHBPREGS error %d \n", errno);
        ptrace(PTRACE_CONT, child, NULL, NULL);
        exit(1);
    }
//    printf("ptrace PTRACE_GETHBPREGS uregs[0] success %ld\n", get_regs.regs.uregs[0]);
        
    ptrace_ret = ptrace(PTRACE_SETHBPREGS, child, 0, &get_regs);
    if (0 != ptrace_ret)
    {
        printf("PTRACE_SETHBPREGS error %d\n", errno);
        ptrace(PTRACE_CONT, child, NULL, NULL);
        exit(1);
    }
    printf("TEST PASSED!\n");
    ptrace(PTRACE_CONT, child, NULL, NULL);

    exit(0);
}

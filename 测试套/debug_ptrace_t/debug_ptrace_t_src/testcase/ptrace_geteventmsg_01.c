#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

int main()
{
    long ptrace_ret;
    unsigned long msg;

    ptrace_ret = ptrace(PTRACE_GETEVENTMSG, -1, NULL, &msg);
    if(ptrace_ret != 0 && ESRCH == errno)
    {
        printf("TEST PASSED!\n");
        exit(0);
    }
    else
    {
        printf("ptrace PTRACE_GETEVENTMSG error %d \n", errno);
        exit(1);
    }
        

}

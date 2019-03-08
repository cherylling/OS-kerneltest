#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/user.h>

int main(int argc, char **argv)
{
    long ptrace_ret;

    ptrace_ret = ptrace(PTRACE_ATTACH, -1, NULL, NULL);
    if(ptrace_ret != 0 && ESRCH == errno)
    {
        printf("TEST PASSED!\n");
        exit(0);
    }
    else
    {
        printf("ptrace PTRACE_ATTACH process -1 error %d \n", errno);
        exit(1);
    }
}

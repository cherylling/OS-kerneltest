#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ptrace.h>

int main()
{
    int ret;
    ret = ptrace(PTRACE_TRACEME, 0, NULL, NULL);
    if (0 != ret)
    {
        printf("errno %d\n", errno);
        perror("Test failed");
        printf("TEST FAILED\n");
        exit(EXIT_FAILURE);
    }
    printf("TEST SUCCESS\n");
    exit(EXIT_SUCCESS);
}

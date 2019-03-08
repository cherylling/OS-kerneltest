#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ptrace.h>

int main()
{
    int ret;
    ret = ptrace(-1, 1, NULL, NULL);
    if (ret !=0 && ESRCH == errno)
    {
        printf("TEST SUCCESS\n");
        exit(EXIT_SUCCESS);
    }
    else
    {
        printf("errno %d\n", errno);
        perror("Test failed");
        printf("TEST FAILED\n");
        exit(EXIT_FAILURE);
    }
}

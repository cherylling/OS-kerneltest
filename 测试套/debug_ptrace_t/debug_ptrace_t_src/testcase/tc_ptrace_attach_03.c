#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/user.h>
#include <pwd.h>

int main(int argc, char **argv)
{
    long ptrace_ret;
    struct passwd *pwd;
    int ret;

    pwd = getpwnam("nobody");
    if (NULL == pwd)
    {
        printf("get nobody pwdnam failed!\n");
        perror("error");
        exit(1);
    }

    printf("nobody uid : %d\n", pwd->pw_uid);
    ret = setuid(pwd->pw_uid);
    if (-1 == ret)
    {
        printf("set uid failed!\n");
        perror("error");
        exit(1);
    }

    ptrace_ret = ptrace(PTRACE_ATTACH, 1, NULL, NULL);
    if(ptrace_ret != 0 && EPERM == errno)
    {
        printf("TEST PASSED!\n");
        exit(0);
    }
    else
    {
        printf("ptrace PTRACE_ATTACH process 1 error %d \n", errno);
        exit(1);
    }
}

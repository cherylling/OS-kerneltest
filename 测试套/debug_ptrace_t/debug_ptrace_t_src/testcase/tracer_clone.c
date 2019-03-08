#define _GNU_SOURCE
#include <stdio.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <malloc.h>
#include <errno.h>

#define CHILD_STACK_SIZE (1024 * 8)

void *stack;
int do_fork()
{
    printf("create a child %d\n", getpid());
    sleep(1);
    exit(0);
}

int main()
{
    int ret = 0;
    int status;
    stack = malloc(CHILD_STACK_SIZE);
    if (NULL == stack)
    {
        printf("malloc failed! errno : %d\n", errno);
        exit(1);
    }
    printf("start clone!\n");

    ret = clone(&do_fork, (char *)stack + CHILD_STACK_SIZE, CLONE_PARENT, NULL);

    if (-1 == ret)
    {
        printf("clone failed with errno %d\n", errno);
        free(stack);
        exit(1);
    }
    else
    {
        printf("I'm a child and clone one subchild %d\n", ret);
        free(stack);
        exit(0);
    }
}

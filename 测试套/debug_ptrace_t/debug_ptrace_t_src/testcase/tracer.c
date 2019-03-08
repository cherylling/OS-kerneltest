#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

int main()
{
    printf("gofork\n");
    pid_t child = fork();
    int status;
    printf("fork\n");
    if (child) {
        if (-1 ==waitpid(-1 ,&status, 0))
        {
            printf("wait failed\n");
            exit(1);
        }
        printf("create a child %d\n", child);
        exit(0);
    }
    else if(0 == child)
    {
        printf("I'm a child\n");
        sleep(1);
        exit(0);
    }
    else
    {
        printf("fork failed!\n");
        exit(1);
    }
}

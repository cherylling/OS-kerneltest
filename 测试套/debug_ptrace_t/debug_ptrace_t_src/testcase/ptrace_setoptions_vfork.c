#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

int main()
{
    pid_t child;
    pid_t subchild;
    int status;
    long ptrace_ret;
    int i=0;
    int flag = 0;

    child = fork();
    if(child < 0)
    {
        printf("fork error\n");
        exit(1);
    }
    else if(child == 0)
    {
        ptrace(PTRACE_TRACEME, 0, NULL, NULL);
        subchild = fork();
        if(subchild < 0)
        {
            printf("sub process fork error\n");
            exit(1);
        }
        else if(subchild == 0)
        {
            printf("sub process fork success\n");
        }
        else
        {
            if ((waitpid(subchild, &status, 0)) < 0)  
            {   
                printf("waitpid() sub failed\n");
                exit(1);
            } 
            for(i=0 ;i<10; i++)
            {
                sleep(1);
            }
            flag = 1;
            exit(0);
        }
    }
    else
    {
        if ((waitpid(child, &status, 0)) < 0)  
        {   
            printf("waitpid() failed\n");
            exit(1);
        }   

        ptrace_ret = ptrace(PTRACE_SETOPTIONS, child, NULL, PTRACE_O_TRACEVFORK);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_SETOPTIONS  PTRACE_O_TRACEVFORK error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_SETOPTIONS PTRACE_O_TRACEVFORK success\n");


        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    if(flag == 1)
    {
        printf("ptrace PTRACE_SETOPTIONS PTRACE_O_TRACEVFORK error \n");
        printf("the first forked child process did not stoped while fork again unexpectedly  \n");
        exit(1);
    }
    exit(0);
}

#include <stdio.h>
#include <stdlib.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <signal.h>

int main()
{
    pid_t child;
    long exit_status;
    int status;
    int is_get_event = 0;
    long ptrace_ret;

    int result = SIGTRAP | (PTRACE_EVENT_EXIT<<8);

    child = fork();
    if(child < 0)
    {
        printf("fork error\n");
        exit(1);
    }
    else if(child == 0)
    {
        sleep(1);
        exit(127);
    }
    else
    {
        ptrace_ret = ptrace(PTRACE_ATTACH, child, NULL, NULL);
        if(ptrace_ret != 0)                                   
        {
            printf("ptrace PTRACE_ATTACH error %d \n", errno);
            exit(1);
        }

        printf("ATTACH SUCCESS\n");
        sleep(1);
       
        ptrace_ret = ptrace(PTRACE_SETOPTIONS, child, NULL, PTRACE_O_TRACEEXIT);
        if(ptrace_ret != 0)                                   
        {
            printf("ptrace PTRACE_SETOPTIONS PTRACE_O_TRACEFORK error %d \n", errno);
            ptrace(PTRACE_DETACH, child, NULL, NULL);
            exit(1);
        }

        printf("SETOPTIONS SUCCESS!\n");

        while(1)
        {
            usleep(1);
            pid_t pid;
            if ((pid = wait(&status)) == -1) {
                perror("wait");
                exit(1);
            };
   
            printf("pid : %d\n", pid);
            printf("the child process stops. status: %d, signal? %d, exit? %d, continue? %d, stop? %d\n" , WEXITSTATUS(status) , WIFSIGNALED(status) , WIFEXITED(status) , WIFCONTINUED(status) ,WIFSTOPPED(status));

            if (WSTOPSIG(status) == SIGTRAP)
            {
                printf("status : %d\n", status>>8);
                if (status>>8 == result)
                {
                    if (ptrace(PTRACE_GETEVENTMSG, child, NULL, &exit_status))
                    {
                        perror("error geteventmsg");
                        exit(1);
                    }
                
                    printf("exit_status %d\n", WEXITSTATUS((int)exit_status));

                    exit_status = WEXITSTATUS((int)exit_status);

                    if (exit_status != 127)
                    {
                        printf("exit status is not equal with 127!\n");
                        exit(1);
                    }
                    is_get_event = 1;
                }
            }

            if (WIFEXITED(status))
            {
                printf("child exit!\n");
                break;
            }

            if(ptrace(PTRACE_CONT, pid, NULL, (void *) SIGCONT))
            {
                printf("ptrace cont %d error %d\n", pid, errno);
                exit(1);
            }

        }

        if (is_get_event)
            exit(0);
        else
            exit(1);
    }
}

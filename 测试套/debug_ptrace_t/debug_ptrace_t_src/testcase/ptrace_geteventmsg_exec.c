#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ptrace.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>

/*
int fds[2];

ssize_t safe_read(int fd, void *buf, size_t count)
{
    ssize_t n;

    do 
    {
        n = read(fd, buf, count);
    }while (n < 0 && errno == EINTR);

    return n;
}

void do_child(pid_t pid)
{
    char wbuf[32];
    int len, wlen;

    sprintf(wbuf, "%d", pid);
    len = strlen(wbuf);

    close(fds[0]);		
    wlen = write(fds[1], wbuf, len);
    if(wlen != len )
    {
        printf("write pipe error\n");
        exit(1);
    }
    exit(1);
}
*/

int main()
{
    pid_t child;
    pid_t subchild;
    int status;
    long ptrace_ret;
    int i=0;
    int flag = 0;
    unsigned long msg;
/*    char rbuf[32];
    int rlen;

    flag = pipe(fds);
    if(flag != 0)
    {
        printf("crate pipe error %d\n", errno);
        return 1;
    }
*/
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
//            do_child(subchild);
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

        ptrace_ret = ptrace(PTRACE_SETOPTIONS, child, NULL, PTRACE_O_TRACEEXEC);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_SETOPTIONS  PTRACE_O_TRACEEXEC error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        printf("ptrace PTRACE_SETOPTIONS PTRACE_O_TRACEEXEC success\n");

/*        sleep(1);
        close(fds[1]);	
        memset(rbuf, 0, sizeof(rbuf));
        rlen = safe_read(fds[0], rbuf, 16);
        close(fds[0]);
*/
//        ptrace_ret = ptrace(PTRACE_GETEVENTMSG, atoi(rbuf), NULL, &msg);
        ptrace_ret = ptrace(PTRACE_GETEVENTMSG, child, NULL, &msg);
        if(ptrace_ret != 0)
        {
            printf("ptrace PTRACE_GETEVENTMSG error %d \n", errno);
            ptrace(PTRACE_CONT, child, NULL, NULL);
            exit(1);
        }
        
        printf("ptrace PTRACE_GETEVENTMSG SUCCESS %ld, %d\n",msg, PTRACE_EVENT_EXEC);

        ptrace(PTRACE_CONT, child, NULL, NULL);
    }

    if(flag == 1)
    {
        printf("ptrace PTRACE_SETOPTIONS PTRACE_O_TRACEFORK error \n");
        printf("the first forked child process did not stoped while fork again unexpectedly  \n");
        exit(1);
    }
    exit(0);
}

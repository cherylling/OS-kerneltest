#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#define BSZ   80*1024*1024


int create_tlbmiss(void)
{
	int i;
	char  *g_buf = NULL;
	int step = 5000;

	g_buf = (char *)malloc(sizeof(char) * BSZ + 1);
	if (g_buf== NULL)
	{
		perror("malloc");
		return 1;	
	}
	for (i = 0; i < BSZ; i += step)
	{
		g_buf[i] = 'a';
	}
	free(g_buf);
	return 0;
}
//sched_setaffinity
int set_policy(void)
{
	struct sched_param param;
	int maxpri;

	maxpri = sched_get_priority_max(SCHED_OTHER);
	if(maxpri == -1) 
	{
		perror("sched_get_priority_max");
		return -1;
	}

	param.sched_priority = maxpri;
	if (sched_setscheduler(getpid(), SCHED_OTHER, &param) == -1) 
	{
		perror("sched_setscheduler");
		return -1;
	} 
	return 0;
}

int main()
{
	int NCPU,i,status;
	cpu_set_t *mask;
	unsigned int len;
	NCPU=sysconf(_SC_NPROCESSORS_CONF);
	pid_t pid;
	printf("NCPU is %d\n",NCPU);
	for(i=0;i<NCPU;i++)
	{
	if ((pid = fork()) < 0)
	{
		printf("fork error\n");
		return -1;
	}
	else if (pid == 0)  /*child*/
	{
		int pid_child;
		pid_child=getpid();
		printf("get into %d child process,we set it as a other process.\n",pid_child);
		len = sizeof(cpu_set_t);
		mask = malloc(sizeof(cpu_set_t));
		CPU_ZERO(mask); 
		CPU_SET(i,mask);
		if(sched_setaffinity(pid_child,len,mask)!= 0)
		{	
			perror("sched_setaffinity\n");
		}
		if(set_policy()!=0)
		{
			printf("set_policy is error\n");
		}
		while(1)
		{	
			create_tlbmiss();
		}
	}
	else		/*parent*/
	{
		sleep(2);
		kill(pid,SIGKILL);
		if(waitpid(pid,&status,0)== -1){
			perror("Error waiting for child to exit\n");
		}
			if (WIFSIGNALED(status)) {
				printf("Child exited normally\n");
				printf("Test PASSED\n");
			} else {
				printf("Child did not exit normally.\n");
				printf("Test FAILED\n");
				return -1;
			}
	}
	}
	return 0;
}



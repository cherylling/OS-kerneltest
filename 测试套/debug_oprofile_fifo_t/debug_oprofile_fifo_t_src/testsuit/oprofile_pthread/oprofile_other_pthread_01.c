#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <stdio.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>
#include <errno.h>
#define BSZ   80*1024*1024

void a_thread_func()
{
	while(1)
	{	
		create_tlbmiss();
	}
}
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
	int NCPU,i;
	cpu_set_t *mask;
	unsigned int len;
	pthread_t new_th[20];
	NCPU=sysconf(_SC_NPROCESSORS_CONF);
	if(set_policy()!=0)
	{
		printf("set_policy is error\n");
	}
	pthread_attr_t attr[20];
	printf("NCPU is %d\n",NCPU);
	for(i=0;i<NCPU;i++)
	{
		pthread_attr_init(&attr[i]);
		if(pthread_create(&new_th[i], &attr[i], a_thread_func,NULL) != 0)
		{
			perror("Error creating thread\n");
			return -1;
		}
		printf("creat success\n");

		len = sizeof(cpu_set_t);
		mask = malloc(sizeof(cpu_set_t));
		CPU_ZERO(mask); 
		CPU_SET(i,mask);
		if (0!=pthread_attr_setaffinity_np(&attr[i], len, mask))
		{
			perror("set affinity failed");
		}

	}
	sleep(2);
	for(i=0;i<NCPU;i++)
	{	
		if(pthread_cancel(new_th[i]) !=0)
		{
			printf("Child did not exit normally.\n");
			printf("Test FAILED\n");
			return -1;
		}
		printf("Child exited normally\n");
		printf("PID %d Test PASSED\n",new_th);
	}
	return 0;
}

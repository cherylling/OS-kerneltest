#include<stdlib.h>
#include<stdio.h>
#include<sys/types.h>
#include<sys/sysinfo.h>
#include<unistd.h>

#define __USE_GNU
#include<sched.h>
#include<ctype.h>
#include<string.h>

//set current process sched-policy to fifo
void set_policy(void)
{
      struct sched_param param;
      int maxpri,minpri;
      
      maxpri = sched_get_priority_max(SCHED_RR);
      minpri = sched_get_priority_min(SCHED_RR);	
      if(maxpri == -1) 
      {
            perror("sched_get_priority_max");
            return;
      }
	printf("for SCHED_RR: maxpri = %d, minpri=%d\n", maxpri,minpri);
      param.sched_priority = 23;//maxpri;
      if (sched_setscheduler(getpid(), SCHED_RR, &param) == -1) 
      {
            perror("sched_setscheduler");
            return;
      } 
}

//set sched_setaffinity current process to a cpu 3
void set_affinity(void)
{	
	int myid = 3; //hard code,is very ugly
	cpu_set_t mask;
	cpu_set_t get;

	printf("now set  affinity current process to cpu3\n");
	CPU_ZERO(&mask);
	CPU_SET(myid, &mask);
	if (sched_setaffinity(0, sizeof(mask), &mask) == -1)
	{
		perror("sched_setaffinity");
		return;
	}
	printf("set curent process affinity to cpu3 has succeed\n");
}


static int rr_process(void)
{
	int child = 0;
	while(1)
	{	
		child ++;
	}

	return 0;
}

int main()
{
	printf("this is a rr-process.\n");
	set_policy();
	set_affinity();
	rr_process();
	return 0;
}



#define _GNU_SOURCE

#include <sched.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#define SAMPLE_POINT	1000
#define SAMPLE_TIME		1000


int get_tick_count()
{

	long long int sec , nsec;
	struct timespec now;
	clock_gettime(CLOCK_MONOTONIC, &now);
	sec = now.tv_sec;
	nsec = now.tv_nsec;
	return sec*1000 + nsec/1000000;
}

int main(int argc  , char **argv)
{
	int load;
	int i;
	long long int end;
	int cpu = atoi(argv[1]);
	int cpu_load = atoi(argv[2]);
	cpu_set_t cpu_info;
	
	CPU_ZERO(&cpu_info);
	CPU_SET(cpu , &cpu_info);
	sched_setaffinity(0 , sizeof(cpu_info) , &cpu_info);

	cpu_load = cpu_load * 10;

	//printf("load = %d\n" , cpu_load[1]);
	while(1)
	{
		usleep((SAMPLE_TIME - cpu_load)*1000);
		end=get_tick_count() + cpu_load;
		while(get_tick_count() <= end)
		{	
		}
	}
}

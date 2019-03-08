#include<stdio.h>
#include<unistd.h>
int main()
{
	int cpu_num;
	cpu_num = sysconf(_SC_NPROCESSORS_CONF);
	printf("%d\n",cpu_num);

	return 0;
}

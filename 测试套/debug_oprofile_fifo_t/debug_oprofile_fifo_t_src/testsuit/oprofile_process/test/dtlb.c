#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <stdlib.h>

#define __USE_GNU
#include <sched.h>
#include <ctype.h>
#include <string.h>


#define BSZ   80*1024*1024


int cfs_create_tlbmiss(void)
{
	int i,j;
	char  *g_buf = NULL;
	int step = 5000;

	g_buf = (char *)malloc(sizeof(char) * BSZ + 1);
	if (g_buf== NULL)
	{
		perror("malloc");
		return 1;
	}
	/*	
	for (i = 0; i < BSZ/step; i += step)
		for(j = 0; j < step; j ++)
			g_buf[i*step + j] = 'a';
	*/
	for (i = 0; i < BSZ; i += step)
	{
		g_buf[i] = 'a';
	}
	free(g_buf);
	return 0;
}



static int cfs_process(void)
{
        int parent = 0;

        while(1)
        {
                parent ++;
		cfs_create_tlbmiss();
        }
	
	return 0;
}


int main()
{
	int j;
	printf("cp-test process if a pri=120's normal cfs process\n");
	cfs_process();
	
	return 0;
}



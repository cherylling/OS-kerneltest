#include <unistd.h>
#include <stdio.h>
#include <sched.h>

//sched_setaffinity
void set_policy(void)
{
      struct sched_param param;
      int maxpri;
      
      maxpri = sched_get_priority_max(SCHED_FIFO);
      if(maxpri == -1) 
      {
            perror("sched_get_priority_max");
            return;
      }

      param.sched_priority = maxpri;
      if (sched_setscheduler(getpid(), SCHED_FIFO, &param) == -1) 
      {
            perror("sched_setscheduler");
            return;
      } 
}


static int child_process(void)
{
	int child = 0;
	while(1)
	{	
		child ++;
		if (child > 0xffff0000)
			break;
	}

	return 0;
}

static int parent_process(void)
{
        int parent = 0;
        while(1)
        {
                parent ++;
                if (parent > 0xffff0000)
                        break;
        }

	return 0;
}


int main()
{
	pid_t pid;

	if ((pid = fork()) < 0)
	{
		printf("fork error\n");
		return -1;
	}
	else if (pid == 0)  /*child*/
	{
		printf("get into child process,we set it as a fifo process.\n");
		set_policy();
		child_process();
	}
	else		/*parent*/
	{
		printf("get into parent process, it is a norm process\n");
		parent_process();
	}
	
	return 0;
}



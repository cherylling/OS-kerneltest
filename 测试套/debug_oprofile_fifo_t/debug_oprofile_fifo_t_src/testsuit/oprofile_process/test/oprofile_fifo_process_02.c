#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#define BSZ   80*1024*1024
void *insn;
int i=0;
//sched_setaffinity
int set_policy(void)
{
	struct sched_param param;
	int maxpri;

	maxpri = sched_get_priority_max(SCHED_FIFO);
	if(maxpri == -1) 
	{
		perror("sched_get_priority_max");
		return -1;
	}

	param.sched_priority = maxpri;
	if (sched_setscheduler(getpid(), SCHED_FIFO, &param) == -1) 
	{
		perror("sched_setscheduler");
		return -1;
	} 
	return 0;
}
//calculate the addr
struct jmp_insn {
   unsigned char opcode;
   unsigned char off[4];
};
void generate_jmp_insn(void *insn_place, void *target)
{
	unsigned int offset;
	struct jmp_insn *insn = (struct jmp_insn *)insn_place;
	offset = target - insn_place - 5;
	insn->opcode = 0xe9;
	printf("offset is %d\n",offset);
	*(unsigned int *)(insn->off) = offset;
}
int main()
{
	int NCPU,status;
	cpu_set_t *mask;
	unsigned int len;
	char tmpfname[50];
	void *pa=NULL;
	size_t size=257<<10;
	int prot = PROT_READ | PROT_WRITE |PROT_EXEC;
	int flag = MAP_SHARED;
	int fd;
	off_t off = 0;
	void *insn_start;
	void *target;

	//NCPU=sysconf(_SC_NPROCESSORS_CONF);
	NCPU=1;
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
			printf("get into %d child process,we set it as a fifo process.\n",pid_child);
			/*len = sizeof(cpu_set_t);
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
			}*/
			printf("1111");
			/*snprintf(tmpfname, sizeof(tmpfname), "/tmp/oprofile_fifo_process_02_%d",
					getpid());	
			fd = open(tmpfname, O_CREAT | O_RDWR | O_EXCL,
					S_IRUSR | S_IWUSR);
			if (fd == -1)
			{
				printf(" Error at open(): %s\n",
						strerror(errno));
				exit(0);
			}		
			pa = mmap(0x10000000, size, prot, flag, fd, off);*/
			pa = malloc(size);
			if (pa == NULL)
			{
				printf ("Test Fail: malloc error: %s\n",
						strerror(errno));
				exit(0);
			}
			generate_jmp_insn(pa, pa + (64 << 10));
			printf("the info is %p\n",pa);
			generate_jmp_insn(pa + (64 << 10),pa+(128<<10));
			printf("the info is %p\n",pa+(64<<10));
			generate_jmp_insn(pa + (128 << 10),pa+(192<<10));
			printf("the info is %p\n",pa+(128<<10));
			generate_jmp_insn(pa + (192 << 10),pa+(256<<10));
			printf("the info is %p\n",pa+(192<<10));
			generate_jmp_insn(pa + (256 << 10),pa);
			printf("the info is %p\n",pa+(256<<10));
			void (*fun)(void)=(void (*)(void))pa;
			fun();
			exit(1);
		}
		else		/*parent*/
		{
			sleep(4);
			kill(pid,SIGKILL);
			if(waitpid(pid,&status,0)== -1){
				perror("Error waiting for child to exit\n");
			}

			if (WIFEXITED(status)) {
				printf("Child exited normally, code = %d\n", WEXITSTATUS(status));
				printf("Test PASSED\n");
			} else if(WIFSIGNALED(status)) {
				printf("Child exited by signal %d\n", WTERMSIG(status));
			}
			else {
				printf("Child did not exit normally.\n");
				printf("Test FAILED\n");
				return -1;
			}
		}
	}
	return 0;
}



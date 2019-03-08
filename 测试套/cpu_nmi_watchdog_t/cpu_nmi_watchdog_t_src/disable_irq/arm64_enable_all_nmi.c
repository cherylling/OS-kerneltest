#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <asm/nmi.h>
#include <linux/kprobes.h>
#include <asm/traps.h>

static int cpu_num =0;
static int time_out=5;
static int cpu_status=1;
static int cpu_total=16;

module_param(cpu_num, int, 0644);
module_param(time_out, int, 0644);
module_param(cpu_status, int, 0644);
module_param(cpu_total, int, 0644);

int my_nmi_handler(void)
{
	//dump_stack();
	printk("register my nmi handler on all cpus: dump kernel stack.\n");
	return 0;
}

static int register_nmi_handler_init (void)
{
	int ret;
	int i;

	for(i=0;i<cpu_total;i++)
	{
		ret=register_nmi_handler(i,my_nmi_handler);
		if (ret != 0)
		{
			printk("register nmi handler failed on cpu%d!\n",i);
			return -1;
		}
		
		nmi_set_timeout(i,time_out);
		nmi_set_active_state(i,cpu_status);
	}

	return 0;  
}

static void register_nmi_handler_exit (void)
{
	int i;
	for(i=0;i<cpu_total;i++)
	{
		nmi_set_active_state(i,0);
	}
	printk("nmi watchdog test end!\n");
}

module_init(register_nmi_handler_init);
module_exit(register_nmi_handler_exit);
MODULE_LICENSE("GPL");



#include <linux/module.h>
#include <linux/delay.h>
#include <linux/kthread.h>
//#include <linux/smp_lock.h>
#include <linux/smp.h>
#include <linux/interrupt.h> 
#include<linux/slab.h>
#include<asm/io.h>

MODULE_LICENSE("GPL");
static ulong tasklet_num = 0;
module_param(tasklet_num, ulong, S_IRUGO);

static struct tasklet_struct *pt[500];

void my_do_tasklet(unsigned long data)
{
    printk(KERN_INFO"tasklet %d called!\n",data);
	//panic("tasklet is called.....");
	tasklet_schedule(pt[data+tasklet_num]);
}

void my_do_tasklet_next(unsigned long data)
{
    printk(KERN_INFO"tasklet %d called!\n",data);
	panic("tasklet is called by another.....");
	
}

static int __init my_module_init(void)
{
	int i=0;	
	printk("tasklet module init!\n");
	
	for(i=0;i<tasklet_num;i++)
	{
		pt[i]=kmalloc(sizeof(struct tasklet_struct),GFP_KERNEL);
		pt[i+tasklet_num]=kmalloc(sizeof(struct tasklet_struct),GFP_KERNEL);
		tasklet_init(pt[i], my_do_tasklet, i);
        tasklet_init(pt[i+tasklet_num], my_do_tasklet_next, i+tasklet_num);
		
		tasklet_schedule(pt[i]);
	}
	
	return 0;
}

static void __exit my_module_exit(void)
{
   	int i=0;	
	printk("tasklet module exit!\n");
	
	for(i=0;i<tasklet_num;i++)
	{
		tasklet_kill(pt[i]);
		kfree(pt[i]);
		tasklet_kill(pt[i+tasklet_num]);
		kfree(pt[i+tasklet_num]);
	}
}

module_init(my_module_init);
module_exit(my_module_exit);

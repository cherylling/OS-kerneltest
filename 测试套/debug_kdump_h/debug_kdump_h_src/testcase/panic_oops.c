#define _GNU_SOURCE
#include<linux/init.h>
#include<linux/module.h>
#include<linux/kernel.h>
#include<linux/kthread.h>
#include<linux/jiffies.h>
#include<linux/string.h>

static int gen_panic_process(void *junk)
{
	panic("call panic\n");

	return 0;
}
static int gen_oops_process(void *junk)
{
	char *null = NULL;

	/*access null point. OOps*/
	*null = 'a';

	return 0;
}

int gen_parallel_oops_panic(void* ptr)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	
	printk("Oops and panic function parallel.\n");
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_panic_process, NULL, "gen_panic_process/%d", 2);
	kthread_bind(p2, 2);
		
	wake_up_process(p1);
	wake_up_process(p2);

	return 0;
}

static int __init main_init(void)
{
	struct task_struct *p1 = NULL;

	p1 = kthread_create(gen_parallel_oops_panic, NULL, "gen_parallel_oops_panic/%d", 0);

	kthread_bind(p1, 0);
	wake_up_process(p1);

	return 0;
}

static void __exit main_exit(void)
{
}

module_init(main_init);
module_exit(main_exit);
MODULE_LICENSE("GPL");

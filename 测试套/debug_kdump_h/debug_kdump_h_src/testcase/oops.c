#define _GNU_SOURCE
#include<linux/init.h>
#include<linux/module.h>
#include<linux/kernel.h>
#include<linux/kthread.h>
#include<linux/jiffies.h>
#include<linux/string.h>

static int gen_oops_process(void *junk)
{
	char *null = NULL;

	/*access null point. OOps*/
	*null = 'a';

	return 0;
}

static int __init main_init(void)
{
	struct task_struct *p1 = NULL;

	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 0);
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

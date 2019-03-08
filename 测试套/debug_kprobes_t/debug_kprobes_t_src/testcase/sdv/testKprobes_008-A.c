#include <linux/kernel.h>
#include <linux/module.h>

int testA(void)
{
	printk(KERN_DEBUG "testA\n");
}
static int __init probe_init(void)
{
	testA();
	return 0;
}

static void __exit probe_exit(void)
{
	printk(KERN_DEBUG "testA end\n");
}

module_init(probe_init)
module_exit(probe_exit)
MODULE_LICENSE("GPL");

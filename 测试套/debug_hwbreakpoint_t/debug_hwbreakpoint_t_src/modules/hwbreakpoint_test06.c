#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

MODULE_LICENSE("GPL");

static char *dynamic_str;

#define size 4096

int dynamic_mem(void)
{
	dynamic_str = kmalloc(size, GFP_KERNEL);

	memset(dynamic_str, '0', size);
	
	printk("dynamic_str_addr=%llx\n", dynamic_str);

	return 0;
}

static int dynamic_str_init(void)
{
	printk("dynamic_str init\n");

	dynamic_mem();

	return 0;
}

static void dynamic_str_exit(void)
{
	printk("dynamic_str exit\n");

}

module_init(dynamic_str_init);
module_exit(dynamic_str_exit);

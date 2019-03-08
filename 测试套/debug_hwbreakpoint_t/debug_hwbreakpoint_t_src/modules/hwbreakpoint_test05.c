#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

MODULE_LICENSE("GPL");
#define size 4096

int static_mem(void)
{
	static char static_str[size];

	memset(static_str, '0', size);
	
	printk("static_str_addr=%llx\n", static_str);

	return 0;
}

static int static_str_init(void)
{
	printk("static_str init\n");

	static_mem();

	return 0;
}

static void static_str_exit(void)
{
	printk("static_str exit\n");

}

module_init(static_str_init);
module_exit(static_str_exit);

#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

MODULE_LICENSE("GPL");
#define size 4096

int const_mem(void)
{
	static char* const_str = "const_mem test\0";

	printk("const_str_addr=%llx\n", const_str);

	return 0;
}

const int const_str_init(void)
{
	printk("const_str init\n");

	const_mem();

	return 0;
}

const void const_str_exit(void)
{
	printk("const_str exit\n");

}

module_init(const_str_init);
module_exit(const_str_exit);

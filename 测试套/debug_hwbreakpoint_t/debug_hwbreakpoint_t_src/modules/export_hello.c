#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

MODULE_LICENSE("GPL");

int myhello(void)
{
	static char *str = "hello";
	
	printk("str:%s\n", str);

	return 0;
}

static int export_hello_init(void)
{
	printk("export_hello init\n");

	return 0;
}

static void export_hello_exit(void)
{

	printk("export_hello exit\n");

}

module_init(export_hello_init);
module_exit(export_hello_exit);

EXPORT_SYMBOL(myhello);

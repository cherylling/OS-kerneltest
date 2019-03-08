#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
extern int myhello(void);

static int call_hello_init(void)
{
	printk("call_hello init\n");
	myhello();

	return 0;
}

static void call_hello_exit(void)
{

	printk("call_hello exit\n");

}

module_init(call_hello_init);
module_exit(call_hello_exit);

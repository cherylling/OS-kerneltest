#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>

/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp = {
	.symbol_name	= "do_fork",
};
static int __init kprobe_init(void)
{
	int ret;
	ret = enable_kprobe(&kp);
	if (ret < 0) {
		printk(KERN_DEBUG "enable_kprobe fail\n" );
		return -1;
	}
	printk(KERN_DEBUG "enable_kprobe pass\n");
	return 0;
}

static void __exit kprobe_exit(void)
{
	printk(KERN_DEBUG "enable_kprobe end \n");
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

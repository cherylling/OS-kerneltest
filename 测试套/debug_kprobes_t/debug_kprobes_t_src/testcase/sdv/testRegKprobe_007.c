#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp = {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
        .symbol_name    = "_do_fork",
#else
        .symbol_name    = "do_fork",
#endif
};
static int __init kprobe_init(void)
{
	int ret;

	ret = register_kprobe(&kp);
	if (ret < 0) {
		printk(KERN_DEBUG "register_kprobe failed, returned %d\n", ret);
		return -1;
	}
	printk(KERN_DEBUG "Planted kprobe at %p\n", kp.addr);
	printk(KERN_DEBUG "register_kprobe pass\n");
	return 0;
}

static void __exit kprobe_exit(void)
{
	unregister_kprobe(&kp);
	printk(KERN_DEBUG "kprobe at %p unregistered\n", kp.addr);
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>


/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp;

static int __init kprobe_init(void)
{
	int ret;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	kp.symbol_name	= "_do_fork";
#else
	kp.symbol_name	= "do_fork";
#endif

	ret = register_kprobe(&kp);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_kprobe failed, returned %d\n", ret);
                return -1;
        }	
	printk(KERN_DEBUG "register_kprobe pass\n");
	return 0;
}

static void __exit kprobe_exit(void)
{
	
	kp.symbol_name  = "schedule";
	unregister_kprobe(&kp);
	printk(KERN_DEBUG "unregister_kprobe pass\n");
}
module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

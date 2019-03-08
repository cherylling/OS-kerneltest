#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/moduleparam.h>
#include <linux/version.h>

static uint kp_flag=KPROBE_FLAG_FTRACE;
module_param(kp_flag, uint, 0644);
/*
	KPROBE_FLAG_GONE 1     : breakpoint has already gone 
	KPROBE_FLAG_DISABLED 2 : probe is temporarily disabled 
	KPROBE_FLAG_OPTIMIZED 4
*/
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	static struct kprobe kp={.symbol_name    = "_do_fork",};
#else
	static struct kprobe kp={.symbol_name    = "do_fork",};
#endif
static int handler_pre(struct kprobe *p, struct pt_regs *regs)
{	 
	printk(KERN_DEBUG "pre_handler\n");
	return 0;
}

static int __init kprobe_init(void)
{
	int ret;
//	kp.flags = 0 || KPROBE_FLAG_GONE || KPROBE_FLAG_DISABLED || KPROBE_FLAG_OPTIMIZED || KPROBE_FLAG_FTRACE;
	kp.flags =kp_flag;
	kp.pre_handler=handler_pre;

	ret = register_kprobe(&kp);
	if (ret < 0) {
		printk(KERN_DEBUG "register_kprobe failed, returned %d\n", ret);
                return -1;
        }	
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

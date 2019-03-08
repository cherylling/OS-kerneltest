#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

static int handler_pre(struct kprobe *p, struct pt_regs *regs)
{
	printk(KERN_DEBUG "pre_handler\n");
        return 0;
}

static void handler_post(struct kprobe *p, struct pt_regs *regs,
                                unsigned long flags)
{
	printk(KERN_DEBUG "post_handler\n");
}
static int handler_fault(struct kprobe *p, struct pt_regs *regs, int trapnr)
{
        printk(KERN_DEBUG "fault_handler: p->addr = 0x%p, trap #%dn",
                p->addr, trapnr);
        /* Return 0 because we don't handle the fault. */
        return 0;
}
#if LINUX_VERSION_CODE < KERNEL_VERSION(4,19,0)
long jprobe_do_fork( unsigned long clone_flags,
		     unsigned long stack_start,
		     unsigned long stack_size,
		     int __user *parent_tidptr,
		     int __user *child_tidptr)
{
	printk(KERN_DEBUG "jprobe_do_fork\n");
	jprobe_return();
	return 0;
}	
#endif
static int ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
        printk(KERN_DEBUG "ret_handler\n");
        return 0;
}
static int entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
        printk(KERN_DEBUG "entry_handler\n");
        return 0;
}

static struct kprobe kp = {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
        .symbol_name    = "_do_fork",
#else
        .symbol_name    = "do_fork",
#endif
	.pre_handler    = handler_pre,
	.post_handler   = handler_post,
	.fault_handler  = handler_fault,
};
#if LINUX_VERSION_CODE < KERNEL_VERSION(4,19,0)
static struct jprobe jp = {
        .entry                  = jprobe_do_fork,
        .kp = {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
                .symbol_name    = "_do_fork",
#else
                .symbol_name    = "do_fork",
#endif
        },
};
#endif
static struct kretprobe rp= {
        .handler                = ret_handler,
        .entry_handler          = entry_handler,
        .data_size              = 1,
        /* Probe up to 20 instances concurrently. */
        .maxactive              = 20,
	.kp = {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
                .symbol_name    = "_do_fork",
#else
                .symbol_name    = "do_fork",
#endif
        },
};

static int __init probe_init(void)
{
	int ret;
	ret=register_kprobe(&kp);
	if (ret < 0)
	{ 	
		printk(KERN_DEBUG "register_kprobe fail\n");
		return -1;
	}
#if LINUX_VERSION_CODE < KERNEL_VERSION(4,19,0)
	ret=register_kprobe(&jp);
	if (ret < 0)
	{
		unregister_kprobe(&kp);
		printk(KERN_DEBUG "register_jprobe fail\n");
		return -1;
	}
#endif
	ret=register_kprobe(&rp);
	if (ret < 0)
	{
		unregister_kprobe(&kp);
#if LINUX_VERSION_CODE < KERNEL_VERSION(4,19,0)
		unregister_kprobe(&jp);
#endif
		printk(KERN_DEBUG "register_kretprobe fail\n");
		return -1;
	}
	printk(KERN_DEBUG "register_kprobe pass\n");
	return 0;
}

static void __exit probe_exit(void)
{
	unregister_kprobe(&kp);
#if LINUX_VERSION_CODE < KERNEL_VERSION(4,19,0)
        unregister_jprobe(&jp);
#endif
        unregister_kretprobe(&rp);
}

module_init(probe_init)
module_exit(probe_exit)
MODULE_LICENSE("GPL");

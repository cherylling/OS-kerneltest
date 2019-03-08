#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>


/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp1 = {
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	.symbol_name	= "_do_fork",
#else
	.symbol_name	= "do_fork",
#endif
};
static struct kprobe kp2 = {
        .symbol_name    = "cpuinfo_open",
};
struct kprobe *kps[2]={&kp1, &kp2};

/* kprobe pre_handler: called just before the probed instruction is executed */
static int handler_pre1(struct kprobe *p, struct pt_regs *regs)
{
	printk(KERN_DEBUG "pre_handler1\n");
	return 0;
}
/* kprobe post_handler: called after the probed instruction is executed */
static void handler_post1(struct kprobe *p, struct pt_regs *regs,
				unsigned long flags)
{
	printk(KERN_DEBUG "post_handler1\n");
}

/* kprobe pre_handler: called just before the probed instruction is executed */
static int handler_pre2(struct kprobe *p, struct pt_regs *regs)
{
        printk(KERN_DEBUG "pre_handler2\n");
        return 0;
}
/* kprobe post_handler: called after the probed instruction is executed */
static void handler_post2(struct kprobe *p, struct pt_regs *regs,
                                unsigned long flags)
{
        printk(KERN_DEBUG "post_handler2\n");
}

/*
 * fault_handler: this is called if an exception is generated for any
 * instruction within the pre- or post-handler, or when Kprobes
 * single-steps the probed instruction.
 */
static int handler_fault(struct kprobe *p, struct pt_regs *regs, int trapnr)
{
	printk(KERN_DEBUG "fault_handler: p->addr = 0x%p, trap #%dn",
		p->addr, trapnr);
	/* Return 0 because we don't handle the fault. */
	return 0;
}
static int __init kprobe_init(void)
{
	int ret;
	kp1.pre_handler = handler_pre1;
	kp1.post_handler = handler_post1;
	kp1.fault_handler = handler_fault;
	kp2.pre_handler = handler_pre2;
	kp2.post_handler = handler_post2;
	kp2.fault_handler = handler_fault;

	ret=register_kprobes(kps, 2);	
	if (ret < 0) {
                printk(KERN_DEBUG "register_probes failed\n");
                return -1;
        }
	printk(KERN_DEBUG "register_probes succeed\n");

	ret=disable_kprobe(&kp1);
	if (ret < 0) {
                unregister_kprobe(&kp1);
                unregister_kprobe(&kp2);
                printk(KERN_DEBUG "disable_kprobe kp1 failed\n");
                return -1;
        }
        printk(KERN_DEBUG "disable_kprobe kp1 succeed\n");

	ret=enable_kprobe(&kp2);
	if (ret < 0) {
                unregister_kprobe(&kp1);
                unregister_kprobe(&kp2);
		printk(KERN_DEBUG "enable_kprobe kp2 failed\n");
                return -1;
        }
	printk(KERN_DEBUG "enable_kprobe kp2 succeed\n");

	return 0;
}

static void __exit kprobe_exit(void)
{
	unregister_kprobes(kps, 2);
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

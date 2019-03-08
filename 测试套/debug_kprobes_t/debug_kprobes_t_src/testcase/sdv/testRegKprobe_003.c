#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp ={ .symbol_name	= NULL, .addr = NULL,};

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
        printk(KERN_DEBUG "fault_handler: p->addr = 0x%p, trap #%d\n",
                p->addr, trapnr);
        /* Return 0 because we don't handle the fault. */
        return 0;
}
static int __init kprobe_init(void)
{
	int ret;
	kp.pre_handler = handler_pre;
        kp.post_handler = handler_post;
        kp.fault_handler = handler_fault;

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
	unregister_kprobe(&kp);
	printk(KERN_DEBUG "kprobe  unregistered\n");
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp;

/* kprobe pre_handler: called just before the probed instruction is executed */
static int handler_pre(struct kprobe *p, struct pt_regs *regs)
{
        printk(KERN_DEBUG "pre_handler\n");
        /* A dump_stack() here will give a stack backtrace */
        return 0;
}

/* kprobe post_handler: called after the probed instruction is executed */
static void handler_post(struct kprobe *p, struct pt_regs *regs,
                                unsigned long flags)
{
         printk(KERN_DEBUG "post_handler\n");
}
/*
 * fault_handler: this is called if an exception is generated for any
 * instruction within the pre- or post-handler, or when Kprobes
 * single-steps the probed instruction.
 */
static int handler_fault(struct kprobe *p, struct pt_regs *regs, int trapnr)
{
        printk(KERN_DEBUG "fault_handler: p->addr = 0x%p, trap #%d\n",
                p->addr, trapnr);
        /* Return 0 because we don't handle the fault. */
        return 0;
}

void testC(void)
{
        printk(KERN_DEBUG "testC\n");
}
void testB(void)
{
        printk(KERN_DEBUG "testB\n");
        testC();
}
int testA(void)
{
	int ret;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif

	kp.pre_handler = handler_pre;
	kp.post_handler = handler_post;
	testB();
	ret = register_kprobe(&kp);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_kprobe failed, returned %d\n", ret);
		return -1;
	}
	printk(KERN_DEBUG "register_kprobe pass\n");
	return 0;
}

static int __init kprobe_init(void)
{
	testA();
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

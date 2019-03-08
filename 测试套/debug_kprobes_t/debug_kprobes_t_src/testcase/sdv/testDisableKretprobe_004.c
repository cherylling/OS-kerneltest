#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each peobe you need to allocate a oprobe structure */
static struct kretprobe rp;

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
static int __init kretprobe_init(void)
{
	int ret;
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
	rp.handler=ret_handler;
	rp.entry_handler=entry_handler;
	rp.maxactive = 1;

	ret = disable_kretprobe(&rp);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "disable_kretprobe fail\n");
		return -1;
	}
	else 
	{
		printk(KERN_DEBUG "disable_kretprobe pass\n");
		return 0;
	}
	
}

static void __exit kretprobe_exit(void)
{
	unregister_kretprobe(&rp);
	printk(KERN_DEBUG "kretprobe  unregistered\n");
}

module_init(kretprobe_init)
module_exit(kretprobe_exit)
MODULE_LICENSE("GPL");

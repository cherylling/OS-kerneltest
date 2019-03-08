#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>


/* For each peobe you need to allocate a oprobe structure */
static struct kretprobe rp;

static int ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	printk(KERN_DEBUG "ret_handler\n");
	return 0;
}

static int __init kretprobe_init(void)
{
	int ret;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif

	ret = register_kretprobe(&rp);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_kretprobe failed, returned %d\n", ret);
		return -1;
	}
	printk(KERN_DEBUG "register_kretprobe pass\n");
	return 0;	
}

static void __exit kretprobe_exit(void)
{
//	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("schedule");
	rp.kp.symbol_name="schedule";
	unregister_kretprobe(&rp);
	printk(KERN_DEBUG "unregister_kretprobe pass\n");
}

module_init(kretprobe_init)
module_exit(kretprobe_exit)
MODULE_LICENSE("GPL");

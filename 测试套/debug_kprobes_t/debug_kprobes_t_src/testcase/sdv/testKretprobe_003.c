#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>


/* For each peobe you need to allocate a oprobe structure */
static struct kretprobe rp1,rp2;

static int ret_handler1(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	printk(KERN_DEBUG "ret_handler1\n");
	return 0;
}
static int entry_handler1(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	printk(KERN_DEBUG "entry_handler1\n");
        return 0;
}
static int ret_handler2(struct kretprobe_instance *ri, struct pt_regs *regs)
{
        printk(KERN_DEBUG "ret_handler2\n");
        return 0;
}
static int entry_handler2(struct kretprobe_instance *ri, struct pt_regs *regs)
{
        printk(KERN_DEBUG "entry_handler2\n");
        return 0;
}
static int __init kretprobe_init(void)
{
	int ret;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	rp1.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	rp1.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif
	rp1.handler=ret_handler1;
	rp1.entry_handler=entry_handler1;
	rp1.maxactive = 1;
	rp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("cpuinfo_open");
        rp2.handler=ret_handler2;
        rp2.entry_handler=entry_handler2;
        rp2.maxactive = 1;
	
	ret=register_kretprobe(&rp1);
	if (ret < 0) {
                unregister_kretprobe(&rp1);
                printk(KERN_DEBUG "register_probes failed\n");
                return -1;
        }

	ret=register_kretprobe(&rp2);
	if (ret < 0) {
                unregister_kretprobe(&rp2);
		printk(KERN_DEBUG "register_probes2 failed\n");
                return -1;
        }

	ret=disable_kretprobe(&rp2);
	if (ret < 0) {
		unregister_kretprobe(&rp1);
                unregister_kretprobe(&rp2); 
                printk(KERN_DEBUG "disable_kretprobe failed\n");
                return -1;
        }

	return 0;	
}

static void __exit kretprobe_exit(void)
{
	unregister_kretprobe(&rp1);
	unregister_kretprobe(&rp2);
	printk(KERN_DEBUG "kretprobe  unregistered\n");
}

module_init(kretprobe_init)
module_exit(kretprobe_exit)
MODULE_LICENSE("GPL");

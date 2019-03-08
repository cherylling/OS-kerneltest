#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each peobe you need to allocate a oprobe structure */
static struct kretprobe rp,rp2,rp3;
struct  kretprobe *rps[3]={&rp ,&rp2,&rp3};
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
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
	rp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("cpuinfo_open");
	rp3.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("schedule");
	return 0;	
}

static void __exit kretprobe_exit(void)
{	
	unregister_kretprobes(rps,3);
	printk(KERN_DEBUG "unregister_kretprobe pass\n");
}

module_init(kretprobe_init)
module_exit(kretprobe_exit)
MODULE_LICENSE("GPL");

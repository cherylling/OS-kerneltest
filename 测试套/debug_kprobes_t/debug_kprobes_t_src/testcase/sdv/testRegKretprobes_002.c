#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kprobes.h>
#include <linux/version.h>

static int num =1;
module_param(num, int, 0644);

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
	int ret;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif
	rp.handler=ret_handler;
	rp.entry_handler=entry_handler;
	rp.maxactive = 1;

	ret = register_kretprobes(rps,num);
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
	unregister_kretprobes(rps,num);
	printk(KERN_DEBUG "kretprobe  unregistered\n");
}

module_init(kretprobe_init)
module_exit(kretprobe_exit)
MODULE_LICENSE("GPL");

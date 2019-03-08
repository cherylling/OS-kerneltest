#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>


static struct kretprobe rp,rp2,rp3;

static int ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
{
	printk(KERN_DEBUG "ret_handler1\n");
	return 0;
}
static int entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
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
static int ret_handler3(struct kretprobe_instance *ri, struct pt_regs *regs)
{
        printk(KERN_DEBUG "ret_handler3\n");
        return 0;
}
static int entry_handler3(struct kretprobe_instance *ri, struct pt_regs *regs)
{
        printk(KERN_DEBUG "entry_handler3\n");
        return 0;
}
static int __init kretprobe_init(void)
{
	int ret,ret2,ret3;
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
	rp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
	rp3.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	rp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
	rp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
	rp3.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif
	
	rp.handler=ret_handler;
	rp.entry_handler=entry_handler;
	rp.maxactive = 20;

        rp2.handler=ret_handler2;
        rp2.entry_handler=entry_handler2;
        rp2.maxactive = 20;

        rp3.handler=ret_handler3;
        rp3.entry_handler=entry_handler3;
        rp3.maxactive = 20;
	
	ret=register_kretprobe(&rp);
	if (ret < 0) 
        {
                printk(KERN_DEBUG "register_kretprobe failed, returned %d\n", ret);
                return -1;
        }
        else 
        {
                printk(KERN_DEBUG "register_kretprobe pass\n");
        }

	ret2=register_kretprobe(&rp2);
	if (ret2 < 0) 
        {
       		unregister_kretprobe(&rp);
	        printk(KERN_DEBUG "register_kretprobe failed, returned %d\n", ret2);
                return -1;
        }
        else 
        {
                printk(KERN_DEBUG "register_kretprobe pass\n");
        }

	ret3 = register_kretprobe(&rp3);
	if (ret3 < 0) 
	{
		unregister_kretprobe(&rp);
	        unregister_kretprobe(&rp2);
		printk(KERN_DEBUG "register_kretprobe failed, returned %d\n", ret3);
		return -1;
	}
	else 
	{
		printk(KERN_DEBUG "register_kretprobe pass\n");
		return 0;
	}
	
}

static void __exit kretprobe_exit(void)
{
	unregister_kretprobe(&rp);
	unregister_kretprobe(&rp2);
	unregister_kretprobe(&rp3);
	printk(KERN_DEBUG "kretprobe  unregistered\n");
}

module_init(kretprobe_init)
module_exit(kretprobe_exit)
MODULE_LICENSE("GPL");

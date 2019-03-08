#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

static struct jprobe jp,jp2;
struct jprobe *jps[2]={&jp,&jp2};
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
	
static int __init jprobe_init(void)
{
	int ret;
	jp.entry = (kprobe_opcode_t *)jprobe_do_fork; 

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif	

	ret = register_jprobes(jps,1);
	if (ret < 0)
        {
                printk(KERN_DEBUG "register_jprobes failed, returned %d\n", ret);
                return -1;
        }
	printk(KERN_DEBUG "register_jprobes pass\n");
        return 0;
}

static void __exit jprobe_exit(void)
{
	unregister_jprobes(jps,1);
	printk(KERN_DEBUG "jprobes unregistered\n");
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>

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
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
	
	ret = register_jprobes(jps,-1);
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

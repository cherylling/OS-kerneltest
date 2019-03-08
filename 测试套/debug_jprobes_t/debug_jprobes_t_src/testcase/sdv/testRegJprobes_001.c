#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kprobes.h>

static int num=0;
module_param(num, int, 0644);

struct jprobe *jps[2]={};
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
	ret = register_jprobes(jps,num);
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
	unregister_jprobes(jps,num);
	printk(KERN_DEBUG "jprobes unregistered\n");
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

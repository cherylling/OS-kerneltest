#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kprobes.h>
#include <linux/version.h>

static int num=3;
module_param(num, int, 0644);

static struct jprobe jp,jp2,jp3;
struct jprobe *jps[3] = {&jp,&jp2,&jp3};
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
int jdo_sys_settimeofday(const struct timespec *tv, const struct timezone *tz)
{
        printk(KERN_DEBUG "jdo_sys_settimeofday\n");
        jprobe_return();
        return 0;
}
void jdrop_slab(void)
{
        printk(KERN_DEBUG "jdrop_slab\n");
        jprobe_return();
}

static int __init jprobe_init(void)
{
	int ret;
	jp.entry = (kprobe_opcode_t *)jprobe_do_fork;
        jp2.entry = (kprobe_opcode_t *)jdo_sys_settimeofday;
        jp3.entry = (kprobe_opcode_t *)jdrop_slab;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
        jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,7,0)
        jp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_sys_settimeofday64");
#else
	jp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_sys_settimeofday");
#endif

        jp3.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("drop_slab");
	
	ret = register_jprobes(jps,3);
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
	printk(KERN_DEBUG "unregister_jprobes pass\n");
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

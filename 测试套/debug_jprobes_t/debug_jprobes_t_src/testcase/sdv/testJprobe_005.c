#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

/* For each probe you need to allocate a kprobe structure */
static struct jprobe jp;

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


void testC(void)
{
        printk(KERN_DEBUG "testC\n");
}
void testB(void)
{
        printk(KERN_DEBUG "testB\n");
        testC();
}
int testA(void)
{
	int ret;
	jp.entry = (kprobe_opcode_t *)jprobe_do_fork;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("_do_fork");
#else
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");
#endif

	testB();
	ret = register_jprobe(&jp);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_jprobe failed, returned %d\n", ret);
		return -1;
	}
	else 
	{
		printk(KERN_DEBUG "register_jprobe pass\n");
		return 0;
		}
}

static int __init jprobe_init(void)
{
	testA();
	return 0;
}

static void __exit jprobe_exit(void)
{
	unregister_jprobe(&jp);
	printk(KERN_DEBUG "jprobe  unregistered\n");
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>


/* For each probe you need to allocate a kprobe structure */
static struct jprobe jp,jp2;

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

int jprobe_do_sys_settimeofday(const struct timespec *tv, const struct timezone *tz)
{
	printk(KERN_DEBUG "jprobe_do_settime\n");
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

	jp2.entry = (kprobe_opcode_t *)jprobe_do_sys_settimeofday;
	jp2.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_sys_settimeofday");

	ret=register_jprobe(&jp);
	if (ret < 0) {
                printk(KERN_DEBUG "register_probes failed\n");
                return -1;
        }
	ret=register_jprobe(&jp2);
	if (ret < 0) {
		unregister_jprobe(&jp);
                printk(KERN_DEBUG "register_probes2 failed\n");
                return -1;
        }

	ret=disable_jprobe(&jp);
	if (ret < 0) {
                unregister_jprobe(&jp);
		unregister_jprobe(&jp2); 
                printk(KERN_DEBUG "disable_jprobe failed\n");
                return -1;
        }
	ret=enable_jprobe(&jp2);
	if (ret < 0) {
		unregister_jprobe(&jp);
                unregister_jprobe(&jp2); 
                printk(KERN_DEBUG "enable_jprobe failed\n");
                return -1;
        }
	return 0;	
}

static void __exit jprobe_exit(void)
{
	unregister_jprobe(&jp);
	unregister_jprobe(&jp2);
	printk(KERN_DEBUG "jprobe  unregistered\n");
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

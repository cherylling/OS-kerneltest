#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct jprobe jp;
long jprobe_cpuinfo( unsigned long clone_flags,
		     unsigned long stack_start,
		     unsigned long stack_size,
		     int __user *parent_tidptr,
		     int __user *child_tidptr)
{
	printk(KERN_DEBUG "Called jprobe_cpuinfo before cpuinfo_open\n");
	jprobe_return();
	return 0;
}
	
static int __init jprobe_init(void)
{
	int ret;	
	jp.entry = (kprobe_opcode_t *)jprobe_cpuinfo;
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("cpuinfo_open");

	ret=register_jprobe(&jp);
	if (ret < 0) {
                printk(KERN_DEBUG "register_probes failed\n");
                return -1;
        }

	ret=disable_jprobe(&jp);
	if (ret < 0) {
                unregister_jprobe(&jp); 
                printk(KERN_DEBUG "disable_jprobe failed\n");
                return -1;
        }

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

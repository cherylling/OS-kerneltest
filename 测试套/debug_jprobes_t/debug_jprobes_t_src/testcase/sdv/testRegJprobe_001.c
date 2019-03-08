#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct jprobe jp;
	
static int __init jprobe_init(void)
{
	int ret;
	jp.kp.addr = (kprobe_opcode_t *)kallsyms_lookup_name("do_fork");

	ret = register_jprobe(&jp);
	if (ret < 0) {
		printk(KERN_DEBUG "register_jprobe failed, returned %d\n", ret);
                return -1;
	}
        printk(KERN_DEBUG "register_jprobe pass\n");
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

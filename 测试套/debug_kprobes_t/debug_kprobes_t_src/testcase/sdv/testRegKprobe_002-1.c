#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp ={ .symbol_name	= "do_fork",};

static int __init kprobe_init(void)
{
	int ret;
	kp.addr=(kprobe_opcode_t*) kallsyms_lookup_name("schedule");
	ret = register_kprobe(&kp);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_kprobe failed, returned %d\n", ret);
                return -1;
        }
	printk(KERN_DEBUG "register_kprobe pass\n");
	return 0;
	
}

static void __exit kprobe_exit(void)
{
	unregister_kprobe(&kp);
	printk(KERN_DEBUG "kprobe  unregistered\n");
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp ={.symbol_name	= "do_fork",};
struct kprobe *kps[10]={&kp, &kp, &kp, &kp, &kp, &kp, &kp, &kp, &kp, &kp};
static int __init kprobe_init(void)
{
	int ret;
	ret = register_kprobes(kps, 10);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_kprobes failed, returned %d\n", ret);
                return -1;
        }
	printk(KERN_DEBUG "register_kprobes pass\n");
	return 0;	
}

static void __exit kprobe_exit(void)
{
	unregister_kprobes(kps, 10);
	printk(KERN_DEBUG "kprobes  unregistered\n");
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

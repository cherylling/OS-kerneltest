#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp ={.symbol_name = "cpuinfo_open",};
static struct kprobe kp2 ={.symbol_name	= "do_fork",};
static struct kprobe kp3 ={.symbol_name = "schedule",};
struct kprobe *kps[3]={&kp, &kp2,&kp3};
static int __init kprobe_init(void)
{
	int ret;
	ret = register_kprobes(kps, 4);
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
	unregister_kprobes(kps, 3);
	printk(KERN_DEBUG "kprobes  unregistered\n");
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

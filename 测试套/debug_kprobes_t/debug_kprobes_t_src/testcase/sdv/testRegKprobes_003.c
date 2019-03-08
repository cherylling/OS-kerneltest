#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kprobes.h>
#include <linux/version.h>

static int num=3;
module_param(num, int, 0644);
/* For each probe you need to allocate a kprobe structure */
static struct kprobe kp ={.symbol_name = "cpuinfo_open",};
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
	static struct kprobe kp2 ={.symbol_name	= "_do_fork",};
#else
	static struct kprobe kp2 ={.symbol_name	= "do_fork",};
#endif
static struct kprobe kp3 ={.symbol_name = "schedule",};
struct kprobe *kps[3]={&kp, &kp2,&kp3};
static int __init kprobe_init(void)
{
	int ret;
	ret = register_kprobes(kps, num);
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

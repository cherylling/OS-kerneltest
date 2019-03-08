#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kprobes.h>

static int num=0;
module_param(num, int, 0644);

struct kprobe *kps[2]={};
static int __init kprobe_init(void)
{
	int ret;
	ret = register_kprobes(kps, num);
	if (ret < 0) 
	{
		printk(KERN_DEBUG "register_kprobes failed\n");
                return -1;
        }
	printk(KERN_DEBUG "register_kprobes pass\n");
	return 0;	
}

static void __exit kprobe_exit(void)
{
	unregister_kprobes(kps, 0);
	printk(KERN_DEBUG "kprobes  unregistered\n");
}

module_init(kprobe_init)
module_exit(kprobe_exit)
MODULE_LICENSE("GPL");

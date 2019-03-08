#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>


/* For each probe you need to allocate a kprobe structure */
static struct jprobe jp,jp2,jp3;
struct jprobe *jps[3] = {&jp,&jp2,&jp3};
static int __init jprobe_init(void)
{
	jp.kp.symbol_name ="do_fork";
	jp2.kp.symbol_name ="schedule";
	jp3.kp.symbol_name ="cpuinfo_open";
	
	return 0;
	
}

static void __exit jprobe_exit(void)
{
	unregister_jprobes(jps,3);
	printk(KERN_DEBUG "unregister_jprobes pass\n");
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");


#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

/*
 * Jumper probe for icmp_echo.
 * Mirror principle enables access to arguments of the probed routine
 * from the probe handler.
 */

/* Proxy routine having the same arguments as actual icmp_echo() routine */
static long jicmp_echo(struct sk_buff *skb)
{
        pr_info("jprobe: skb = %p\n", skb);
        printk(KERN_DEBUG "jprobe_icmp_echo\n");
	/* Always end with a call to jprobe_return(). */
	jprobe_return();
	return 0;
}

static struct jprobe jp = {
	.entry			= jicmp_echo,
	.kp = {
		.symbol_name	= "icmp_echo",
	},
};

static int __init jprobe_init(void)
{
	int ret;

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
	printk(KERN_DEBUG "jprobe at %p unregistered\n", jp.kp.addr);
}

module_init(jprobe_init)
module_exit(jprobe_exit)
MODULE_LICENSE("GPL");

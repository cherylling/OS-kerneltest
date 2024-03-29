/*
 * Here's a sample kernel module showing the use of jprobes to dump
 * the arguments of do_fork().
 *
 * For more information on theory of operation of jprobes, see
 * Documentation/kprobes.txt
 *
 * Build and insert the kernel module as done in the kprobe example.
 * You will see the trace data in /var/log/messages and on the
 * console whenever do_fork() is invoked to create a new process.
 * (Some messages may be suppressed if syslogd is configured to
 * eliminate duplicate messages.)
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/kprobes.h>
#include <linux/version.h>

/*
 * Jumper probe for do_fork.
 * Mirror principle enables access to arguments of the probed routine
 * from the probe handler.
 */

/* Proxy routine having the same arguments as actual do_fork() routine */
static long jdo_fork(unsigned long clone_flags, unsigned long stack_start,
	      unsigned long stack_size, int __user *parent_tidptr,
	      int __user *child_tidptr)
{
	pr_info("jprobe: clone_flags = 0x%lx, stack_start = 0x%lx "
		"stack_size = 0x%lx\n", clone_flags, stack_start, stack_size);
	printk(KERN_DEBUG "jprobe_do_fork\n");
	/* Always end with a call to jprobe_return(). */
	jprobe_return();
	return 0;
}

static struct jprobe jp = {
	.entry			= jdo_fork,
	.kp = {

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,2,0)
		.symbol_name	= "_do_fork",
#else
		.symbol_name    = "do_fork",
#endif

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

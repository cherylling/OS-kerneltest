#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/smp.h>
#include <linux/irqchip/arm-gic-v3.h>
#include <linux/delay.h>

static long sgi = 0;
module_param(sgi, long, 0);

static void gic_write_ipitest(u64 val)
{
	asm volatile("msr_s " __stringify(ICC_SGI1R_EL1) ", %0" : : "r" (val));
}

static int __init trigger_IPI_init(void)
{

	if (!sgi)
		sgi = (long)2 << 32 | 8 << 24 | 0 << 16 | 2;

	pr_info("sgi:%lx cpu%d\n", sgi, smp_processor_id());	
	gic_write_ipitest(sgi);

	return 0;
}

static void __exit trigger_IPI_exit(void)
{
}

module_init(trigger_IPI_init);
module_exit(trigger_IPI_exit);
MODULE_LICENSE("GPL");

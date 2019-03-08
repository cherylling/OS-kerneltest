#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/delay.h>

static int disable_irq_init (void)
{
    	unsigned int cpu_id;
	int i;
	
	cpu_id = smp_processor_id(); 
	printk("current cpu id is %u\n", cpu_id);
	
	local_irq_disable();
	printk("Disable CPU%d local irq 20s\n", cpu_id);
	
	for (i = 0; i < 20000; i++)
	{
	    udelay(1000);
	}
	
	local_irq_enable();
	printk("Enable local irq!\n");
	
	return 0;
}

static void disable_irq_exit (void)
{
	printk("Disable_irq module removed,enable irq agin!\n");
}

module_init(disable_irq_init);
module_exit(disable_irq_exit);
MODULE_LICENSE("GPL");


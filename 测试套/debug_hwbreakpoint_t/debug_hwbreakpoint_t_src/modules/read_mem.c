#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

MODULE_LICENSE("GPL");

static unsigned long long addr = 0;

module_param(addr, ulong, S_IRUGO);

static int read_mem_init(void)
{
	if(addr == 0) {
                printk("usage: insmod read_mem.ko addr=0xd0000000\n");
                return 1;
        }

	char* sample_addr;
	sample_addr = addr;

	printk("addr:%s\n", sample_addr);

	return 0;
}

static void read_mem_exit(void)
{
}

module_init(read_mem_init);
module_exit(read_mem_exit);

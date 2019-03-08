#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

MODULE_LICENSE("GPL");

static unsigned long long addr = 0;
static unsigned long long size = 4096;

module_param(addr, ulong, S_IRUGO);
module_param(size, ulong, S_IRUGO);

static int set_mem_init(void)
{
	if(addr == 0 || size == 0) {
                printk("usage: insmod set_mem.ko addr=0xd0000000 size=0x1000\n");
                return 1;
        }

	memset(addr, '1', size);	

	printk("memset pass\n");

	return 0;
}

static void set_mem_exit(void)
{
}

module_init(set_mem_init);
module_exit(set_mem_exit);

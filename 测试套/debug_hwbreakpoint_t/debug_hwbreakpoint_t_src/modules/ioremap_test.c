#include <linux/module.h>
#include <asm/io.h>
//#include <asm/system.h>
#include <asm/current.h>
#include <linux/sched.h>

static unsigned long long addr = 0;
static unsigned long long size = 4096;

static void *ioremap_addr=NULL;

module_param(addr, ulong, S_IRUGO);
module_param(size, ulong, S_IRUGO);

static int __init ioremap_test_init(void)
{
	if(addr == 0 || size == 0) {
    		printk("usage: insmod ioremap_test.ko addr=0xd0000000 size=0x1000\n");
    		return 1;
	}

	ioremap_addr = (void *)ioremap(addr, size);
	if (ioremap_addr == NULL) {
		printk("ioremap(0x%llx,0x%llx) error.\n", addr,size);
		return 1;
	}

	printk("ioremap pass, addr:0x%llx\n", ioremap_addr);

	memset(ioremap_addr, 0, size);

	printk("memset pass\n");

	return 0;
}

static void __exit ioremap_test_exit(void)
{
	if (ioremap_addr != NULL)
	{
		iounmap(ioremap_addr);
		ioremap_addr = NULL;
	}

	return;
}

module_init(ioremap_test_init);
module_exit(ioremap_test_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("for dfx ioremap test");

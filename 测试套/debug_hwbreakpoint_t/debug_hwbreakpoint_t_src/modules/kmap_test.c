#include <linux/module.h>
#include <linux/highmem.h>
#include <linux/pagemap.h>
#include <linux/gfp.h>
#include <linux/mm_types.h>
#include <linux/mm.h>

static unsigned long long p_addr = 0;
static struct page *test_page = NULL;

module_param(p_addr, ulong, S_IRUGO);

static int __init kmap_test_init(void)
{
	if( p_addr == 0 ) {
		printk("usage: insmod kmap_test.ko p_addr=0xd0000000\n");
		return 1;
	}

	static char *addr = NULL ;

	test_page = p_addr;

	addr = kmap(test_page);
	if (addr == NULL) {
		printk("kmap error\n");
		return 1;
	} else {
		printk("kmap succeed, addr:%llx\n", addr);
	}
	
	return 0;
}

static void __exit kmap_test_exit(void)
{
	kunmap(test_page);

	return ;
}

module_init(kmap_test_init);
module_exit(kmap_test_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("kmap");

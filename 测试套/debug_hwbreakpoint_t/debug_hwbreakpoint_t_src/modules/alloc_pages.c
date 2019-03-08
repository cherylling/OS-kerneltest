#include <linux/module.h>
#include <linux/highmem.h>
#include <linux/pagemap.h>
#include <linux/gfp.h>
#include <linux/mm_types.h>
#include <linux/mm.h>

static struct page *test_page = NULL;

static int __init alloc_pages_init(void)
{
	test_page = alloc_pages(__GFP_HIGHMEM,1);
	if (!test_page) {
		printk("alloc_pages error\n");
		return 1;
	}
	
	printk("alloc_pages pass, addr=%llx\n", test_page);
	
	return 0;
}

static void __exit alloc_pages_exit(void)
{
	if (test_page)
		__free_pages(test_page,1);

	return ;
}

module_init(alloc_pages_init);
module_exit(alloc_pages_exit);
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("alloc_pages");


#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>


void trace_printk_init(void) 
{
     trace_printk("trace_printk testing\n");
}

void trace_printk_exit(void)
{
     trace_printk("trace_printk test end\n");
}
static int __init init(void)
{
    trace_printk_init();
    return 0;
}

static void __exit exit(void)
{
   trace_printk_exit();
}
MODULE_AUTHOR("Huawei Tech. CO., LTD.");
MODULE_DESCRIPTION("HULK tracing test");
MODULE_LICENSE("GPL");

module_init(init);
module_exit(exit);

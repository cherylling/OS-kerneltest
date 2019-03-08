
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Huawei Tech. CO., LTD.");
MODULE_DESCRIPTION("HULK tracing test");

void trace_printk_init(void)
{
    tracing_off();
    trace_printk("tracing_off testing\n");
    tracing_on();
    trace_printk("tracing_on testing\n");
}
void trace_printk_exit(void)
{
    tracing_off();
    trace_printk("tracing_off test end");
    tracing_on();
    trace_printk("tracing_on test end");
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

module_init(init);
module_exit(exit);

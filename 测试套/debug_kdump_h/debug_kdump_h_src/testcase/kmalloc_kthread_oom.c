#include<linux/kthread.h>
#include<linux/err.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/gfp.h>
#include <linux/types.h>

static char volatile *addr;

static unsigned long size=4096*10;
static unsigned long i = 0;

static struct task_struct* test_task=NULL;

void func_handler(void*arg)
{
   for(i=0; ; i++) {
        addr = (char *)kmalloc(size, GFP_KERNEL);
        if (addr == NULL) {
            printk("kmalloc %ld error\n", i);
            break;
        }

        printk("kmalloc %ld pass\n", i);
        memset(addr, 0, size);

        printk("memset %ld pass\n", i);
    }
    while(1)
    {
        addr = (char *)kmalloc(1, GFP_KERNEL);
        if(addr) memset(addr, 0, 1);
    }
}
static int __init kmalloc_kthread_init(void)
{
    int i = 0;
    int err;
    local_irq_disable();
    test_task = kthread_create(func_handler, NULL, (void*)&i);
     if(IS_ERR(test_task))
        {
            printk(KERN_ERR"create kernel thread ERROR......\n");
            err = PTR_ERR(test_task);
            test_task = NULL;
            return err;
        }
        wake_up_process(test_task);
    return 0;
}
static void __exit kmalloc_kthread_exit(void)
{
    int i = 0;
    if(test_task)
       {
           kthread_stop(test_task);
           test_task = NULL;
       }
   local_irq_enable();
}
module_init(kmalloc_kthread_init);
module_exit(kmalloc_kthread_exit);
MODULE_LICENSE("GPL");



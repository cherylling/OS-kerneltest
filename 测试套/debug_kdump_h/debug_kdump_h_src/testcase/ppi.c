#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/param.h>
#include <linux/jiffies.h>
#include <linux/sched.h>
#include <linux/kthread.h>
#include <asm/processor.h>
#include <asm/signal.h>
#include <linux/moduleparam.h>
#include <linux/syscalls.h>
#include <linux/hrtimer.h>
#include <linux/smp.h>
#include <asm/io.h>
 
MODULE_LICENSE("GPL");
#define MAX_LCORE_NUM 1
#define TIMER_INTERVAL 100000
 
struct rq_info
{
	unsigned long long period;
	struct hrtimer timer;
};
 
struct rq_info rq_in[MAX_LCORE_NUM];
 
struct page *page[MAX_LCORE_NUM];
 
static enum hrtimer_restart rq_balance_timer(struct hrtimer * timer)
{
	panic("ppi.\n");

        return HRTIMER_NORESTART;
}
 
void start_hrtime(void *info)
{	
	struct hrtimer *timer =(struct hrtimer *)info;

	hrtimer_start(timer, ktime_set(0,TIMER_INTERVAL), HRTIMER_MODE_REL);
}
 
 
static int __init timer_interrupt_panic_init(void)
{
        int cpu = 0;
	
	printk("module_init\n");
	printk("cur cpu id: %d\n", smp_processor_id()); 
        for(cpu = 0; cpu < MAX_LCORE_NUM; cpu++) {
		
                hrtimer_init(&rq_in[cpu].timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
                rq_in[cpu].timer.function = &rq_balance_timer;
		hrtimer_start(&rq_in[cpu].timer, ktime_set(0,TIMER_INTERVAL + (cpu << 2)), HRTIMER_MODE_REL);
        }

	return 0;
}
 
static void __exit timer_interrupt_panic_exit(void)
{
}

module_init(timer_interrupt_panic_init);
module_exit(timer_interrupt_panic_exit);




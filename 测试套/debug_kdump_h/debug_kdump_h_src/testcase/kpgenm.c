/****************************************************************************
****************************************************************************/

/* the only included header */
#include "kpgenm.h"

#include <linux/sched.h>
#include <linux/kallsyms.h>
#include <asm/processor.h>
#include <linux/hardirq.h>
#include <linux/rtc.h>
#include <linux/vmalloc.h>
#ifndef KERNEL_3_10_X86_64
#include <linux/os_event_type.h>
#include <linux/notifier.h>
#include <vos/lvos_reboot.h>
#endif

#define ACTION_BASE 10000
#define CPU_BASE 100
/* kernel panic generator device pointer */
static struct kpgen_dev *g_kpgdev = NULL;

/* kernel panic generator device functions */
/* kernel panic generator device read handler */
static ssize_t dev_rd_handler(struct file *filp, char __user *buf, size_t count, loff_t *f_pos);

/* kernel panic generator device write handler */
static ssize_t dev_wr_handler(struct file *filp, const char __user *buf, size_t count,loff_t *f_pos);

/* kernel panic generator device io control handler */
static int dev_ioctl_handler(struct inode *inode, struct file *filp,unsigned int cmd, unsigned long arg);

/* kernel panic generator device open handler */
static int dev_open_hanlder(struct inode *inode, struct file *filp);

/* kernel panic generator device release handler */
static int dev_release_handler(struct inode *inode, struct file *filp);

/* kernel panic generator module functions */
/* kernel panic generator module initialization */
static int __init kpgenm_init(void);

static int gen_parallel_panic(void *);
static int gen_parallel_oom_panic(void *);
static int gen_parallel_oom(void *);
static int gen_parallel_restart(void *);
static int gen_parallel_restart_oom(void *);
static int gen_parallel_restart_panic(void *);
static int call_emergency_restart(void *);
static int call_machine_emergency_restart(void *);
static int call_kernel_restart(void *);
static int gen_parallel_oops_restart(void *);
static int gen_parallel_oops_oom(void *);
static int gen_parallel_oops_panic(void *);
static int gen_parallel_oops(void *);
static int gen_seri_oops(void *);
static int gen_oom_same_cpu_i(void *);
static int gen_oops_same_cpu(void *);
static int gen_oops_panic_same_cpu(void *);
static int gen_oom_same_cpu(void *);
static int gen_oom_panic_same_cpu(void *);
static int gen_emerge_panic_same_cpu(void *);
static int gen_emerge_oops_same_cpu(void *);
static int gen_oops_same_cpu_i(void *);
static int gen_oops_panic_same_cpu_i(void *);
static int gen_oom_panic_same_cpu_i(void *);
static int gen_emerge_panic_same_cpu_i(void *);
static int gen_emerge_oops_same_cpu_i(void *);
static int gen_oops_oops_i(void *);
static int gen_oops_panic_i(void *);
static int gen_panic_panic_i(void *);
static int gen_oops_same_cpu_panic(void *);
static int gen_oom_same_cpu_panic(void *);
static int gen_oom_oops_panic(void *);
static int gen_show_registers(void *);
static int rse_nvram_printk_basic(void *);
static int rse_nvram_printk_muti(void *);
static int rse_nvram_printk_tmout(void *);
static int rse_nvram_printk_beyond(void *);
static void rse_nrame_printk_timer_func(unsigned long);
static int printk_comm(void *);

typedef int(*kbox_handleParcResetDump_fn)(void);
kbox_handleParcResetDump_fn fn_kbox_handleParcResetDump;

/* kernel panic generator module exit */
static void kpgenm_exit(void);
static long r_process_timeout=150;
static long d_process_timeout=150;
module_param_named(RProcessTimeout,r_process_timeout,long,S_IRUSR);
module_param_named(DProcessTimeout,d_process_timeout,long,S_IRUSR);




# define MAX_NAME 256
struct module_function {
        char module_name[MAX_NAME];
        char function_name[MAX_NAME];
};


extern int kallsyms_on_each_symbol(int (*fn)(void *, const char *, struct module *,
                                      unsigned long), void *data);

typedef unsigned long (*lookup_name)(const char *);
static lookup_name comm_kallsyms_lookup_name = NULL;

static int find_comm_kallsyms_lookup_name(void *data, const char *name, struct module *module, unsigned long addr)
{
        struct module_function *mf = (struct module_function *)data;
        if (!strcmp(name, mf->function_name))
        {
                if (mf->module_name[0] == '\0' || (module && strcmp(mf->module_name, module->name) == 0)) {
                        comm_kallsyms_lookup_name = (lookup_name)addr;
                        /* found, stop! */
                        return 1;
                }
        }
        return 0;
}

#ifndef KERNEL_4_1_ARM64
typedef void (*machine_emergency_restart_func)(void);
machine_emergency_restart_func machine_emergency_restart_addr = 0;
#endif
typedef void (*OOM_FUNC) (struct zonelist *zonelist, gfp_t gfp_mask,
						int order, nodemask_t *nodemask, bool force_kill);
			
OOM_FUNC out_of_memory_addr = 0;

typedef int (*sched_setscheduler_nocheck_fun)(struct task_struct *, int, const struct sched_param *);
sched_setscheduler_nocheck_fun sched_setscheduler_nocheck_addr = NULL;


//out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);


/* kernel time interrupt handlers */
void tmrhnd_nmiinter(unsigned long data);
void tmrhnd_accnptr(unsigned long data);
void tmrhnd_diverrfault(unsigned long data);
#ifndef KERNEL_4_1_ARM64
void tmrhnd_oftrap(unsigned long data);
void tmrhnd_brexcefault(unsigned long data);
void tmrhnd_copsegorfault(unsigned long data);
void tmrhnd_invtssfault(unsigned long data);
void tmrhnd_segnpresfault(unsigned long data);
void tmrhnd_ssegfault(unsigned long data);
void tmrhnd_aligchkfault(unsigned long data);
#endif
void tmrhnd_invopfault(unsigned long data);
void tmrhnd_geneprotfault(unsigned long data);
void tmrhnd_callpanic(unsigned long data);
void tmrhnd_callpanic_mask_int(unsigned long data);
void tmrhnd_call_emergency_restart(unsigned long data);

int noinline gen_dead_loop(void *data);
int  gen_printk_loop(void *data);
int gen_D_process(void *data);
int  gen_R_process(void *data);

static int gen_panic_process1(void*);
static int gen_panic_process2(void*);
static int gen_oom_process1(void*);
static int gen_oops_process(void*);

void out_of_memory_vmalloc_fun(void);
void out_of_memory_kmalloc_fun(void);
int testcase_vmalloc(void *data);
int testcase_kmalloc(void *data);


int up_stackinfo_fun_a(void);
int up_stackinfo_fun_b(void);
int g_inum=0;

void OUT_OF_STACK_OOPS_2_testA(void);
void OUT_OF_STACK_OOPS_2_testB(void);
#define  LEN  64
char *str = NULL;


/* gloable timer */
struct timer_list g_timer;

/* device parameters */
static int dev_major =   CDEV_MAJOR;
static int dev_minor =   CDEV_MINOR;
static int dev_nr_devs = CDEV_NR_DEVS;	
/* device name */
static char mod_name[] = "kpgen_kbox";

/* file operation function pointers struct */
static struct file_operations kpgen_fops = 
{
	.owner   =    THIS_MODULE,
	.read    =    dev_rd_handler,
	.write   =    dev_wr_handler,
	//.ioctl   =    dev_ioctl_handler,//chenjl
	.unlocked_ioctl   =    dev_ioctl_handler,
	.open    =    dev_open_hanlder,
	.release =    dev_release_handler,
};

/* device write actions */
static ssize_t dev_wr_actions(INT32 iActCode)
{
	OOM_FUNC out_of_memory_fun = (OOM_FUNC)out_of_memory_addr;	
	
    switch(iActCode%ACTION_BASE)
    {
	/* process context */
        /* nonemaskable external interrupt 1 */
        case PC_NMI_INTER:
	{
	    PDEBUG("nonemaskable external interrupt in process context.\n");
            local_irq_disable();
	    while(1);

        }
	break;

        /* access null pointer 2  */
        case PC_ACCESS_NPTR:
        {
            UINT8 *pNull = NULL;
	                
            PDEBUG("access NULL pointer in process context.\n");
            *pNull = 0;

        }
        break;
        
        /* divide error fault 3 */
        case PC_DIVIDE_ERR_FAULT:
        {
            __volatile__ UINT8 ucTmp = 0;

            PDEBUG("divide error fault in process context.\n");
            ucTmp = 1 / ucTmp;
	    PDEBUG("illegal value: %d.\n", ucTmp);

        }
        break;

	/* overflow trap 4 */
   #ifndef KERNEL_4_1_ARM64
        case PC_OVERFLOW_TRAP:
	{
	    long __res;
	    PDEBUG("overflow trap in process context.\n");
	    __asm__ volatile("int $0x04" : "=a"(__res):);

	}
	break;
	case PC_BR_EXCEEDED_FAULT:	
	/* bound range exceeded fault 5 */
	{
	    long __res;
	    
	    PDEBUG("bound range exceeded fault in process context.\n");
	    __asm__ volatile("int $0x05" : "=a"(__res):);
	    
	}
	break;
    #endif
	/* invalid opcode fault 6 */
        case PC_INVALID_OP_FAULT:
	{
	    PDEBUG("invalid opcode fault in process context.\n");
	    BUG();
            //__asm__ __volatile__("ud2\n");
        }
	break;

	/* coprocessor segment overrun fault 7 */
	#ifndef KERNEL_4_1_ARM64
        case PC_COPR_SEG_OVERRUN_FAULT:
	{
	    long __res;
	    PDEBUG("coprocessor segment overrun fault in process context.\n");
	    __asm__ volatile("int $0x09" : "=a"(__res):);
 
	}
	break;

	/* invalid TSS fault 8 */
        case PC_INVALID_TSS_FAULT:
	{
	    long __res;	
	    PDEBUG("invalid TSS fault in process context.\n");
           __asm__ volatile("int $0x0A" : "=a"(__res):);
		
	}
	break;

	/* segment not present fault 9 */
        case PC_SEG_NPRESENT_FAULT:	
	{
	    long __res;
	    PDEBUG("segment not present fault in process context.\n");  
	   __asm__ volatile("int $0x0B" : "=a"(__res):);
	  
	}
	break;

	/* stack segment fault 0 */
        case PC_STACK_SEG_FAULT:
        {
	    long __res;		
	    PDEBUG("stack segment fault in process context.\n");
	    __asm__ volatile("int $0x0C" : "=a"(__res):);

	} 
	break;
	#endif
	/* general protection fault a */
        case PC_GENERAL_PROT_FAULT:
	{
	  FPTR ptrFunc;
	  UINT32 Instr = 0x12345678;
	  
	  PDEBUG("general protection fault in process context.\n");
	  ptrFunc = (FPTR)(&Instr);
	  PDEBUG("the value of ptrFunc is: %p.\n", ptrFunc);
	  (*ptrFunc)();
	  
	}  
	break;

	/* alignment check fault b */
        /*case PC_ALIGNMENT_CHK_FAULT:
	{
	  long *unaldword;
	  union tag_aligdword{
	    UINT32  aldword;
	    char    a[3];
	  } aldword;

	  PDEBUG("alignment check fault in process context.\n");
	  
	  aldword.aldword = 0x12345678;
	  unaldword = &(aldword.a[2]);
	  PDEBUG("unaldword %ld.\n", *unaldword);
	}*/
	#ifndef KERNEL_4_1_ARM64
        case PC_ALIGNMENT_CHK_FAULT:
	{
	    long __res;		
	    PDEBUG("alignment check fault\n");
	    __asm__ volatile("int $0x11" : "=a"(__res):);
	}
	break;
	#endif
        /* call panic functions c */
        case PC_CALL_PANIC:
        {
	    PDEBUG("call panic() function in process context.\n");	  
            panic("call panic() function in process context.\n");
        }
        break;

	/* interrupt context */
        /* nonemaskable external interrupt d */
        case IC_NMI_INTER:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_nmiinter;

	    add_timer(&g_timer);
        }
	break;

        /* access null pointer e */
        case IC_ACCESS_NPTR:
        {
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_accnptr;

	    add_timer(&g_timer); 
        }
        break;
        
        /* divide error fault f */
        case IC_DIVIDE_ERR_FAULT:
        {
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_diverrfault;

	    add_timer(&g_timer); 
        }
        break;

	/* overflow trap g */
	#ifndef KERNEL_4_1_ARM64
        case IC_OVERFLOW_TRAP:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_oftrap;

	    add_timer(&g_timer); 
	}
	break;
	
	/* bound range exceeded fault h */
        case IC_BR_EXCEEDED_FAULT:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_brexcefault;

	    add_timer(&g_timer);	    
	}
	break;
	#endif
	/* invalid opcode fault i */
        case IC_INVALID_OP_FAULT:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_invopfault;

	    add_timer(&g_timer);
        }
	break;

	/* coprocessor segment overrun fault j */
	#ifndef KERNEL_4_1_ARM64
        case IC_COPR_SEG_OVERRUN_FAULT:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_copsegorfault;

	    add_timer(&g_timer);  
	}
	break;

	/* invalid TSS fault k */
        case IC_INVALID_TSS_FAULT:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_invtssfault;

	    add_timer(&g_timer);
	}
	break;

	/* segment not present fault l */
        case IC_SEG_NPRESENT_FAULT:	
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_segnpresfault;

	    add_timer(&g_timer);
	}
	break;

	/* stack segment fault m */
        case IC_STACK_SEG_FAULT:
        {
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_ssegfault;

	    add_timer(&g_timer);
	} 
	break;
	#endif
	/* general protection fault n */
        case IC_GENERAL_PROT_FAULT:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_geneprotfault;

	    add_timer(&g_timer);	  
	}  
	break;

	/* alignment check fault o */
	#ifndef KERNEL_4_1_ARM64
        case IC_ALIGNMENT_CHK_FAULT:
	{
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_aligchkfault;

	    add_timer(&g_timer);
      	}
	break;
	#endif
        /* Call Panic p */
        case IC_CALL_PANIC :
        {
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_callpanic;

	    add_timer(&g_timer);  
        }
        break;
        /* Call Panic mask int */
        case IC_CALL_PANIC_MASK_INT :
        {
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_callpanic_mask_int;

	    add_timer(&g_timer);  
        }
        break;
        /* Call emergency_restart p */
        case EULER_EMERGE_RESTART_INT :
        {
	    init_timer(&g_timer);

	    g_timer.expires = jiffies + 10;	/* fire in 10 clock */
	    g_timer.data = 0;
	    g_timer.function = tmrhnd_call_emergency_restart;

	    add_timer(&g_timer);  
        }
        break;


        /*deadlock context*/
        /*?????*/
/*        case DEAD_KERNEL_LOOP_FAULT:
        {
            PDEBUG("kernel endless loop !!!\n");
            kernel_thread(gen_dead_loop, NULL, CLONE_KERNEL);
        }
        break;*/
        case EULER_PRINTK_MANYMESSAGE:
        {
            PDEBUG("kernel endless printk !!!\n");
			#ifndef KERNEL_4_1_ARM64 || KERNEL_3_10_X86_64
            kernel_thread(gen_printk_loop, NULL, CLONE_KERNEL);
			#endif
        }
        break; 
        
        /*??2??????????Cpu R??*/
        case DEAD_R_LOCK_FAULT:
        {
            int cpu;
            unsigned long secs;
            struct task_struct *p = NULL;
            
            PDEBUG("R status deadlock.\n");
            cpu = iActCode/ACTION_BASE;
            cpu %= CPU_BASE;

            if (0 == cpu_online(cpu)){
                printk("cpu%02d offline\n", cpu);
                return -EFAULT;
            }
           /* secs = iActCode/ACTION_BASE/CPU_BASE;*/
            secs=r_process_timeout;
            
            p = kthread_create(gen_R_process, (void *)secs, "r_process/%d", cpu);
            kthread_bind(p, (unsigned int)cpu);
            wake_up_process(p);
        }
        break;
        
         /*????D????*/
        case DEAD_D_LOCK_FAULT:
        {
            struct task_struct *p = NULL;
            unsigned long secs=0;
            PDEBUG("D status deadlock.\n");
           /* secs = iActCode/ACTION_BASE;*/
            secs=d_process_timeout;
            p = kthread_create(gen_D_process, (void *)secs, "d_process");
            wake_up_process(p);
        }
        break;
        
        
        /*???euler kbox????*/
        /*machine_emergency_restart ??*/

        case EULER_MACHINE_EMERGE_RESTART:
        {
            PDEBUG("along?test machine_emergency_restart function begin.");
			#ifndef KERNEL_4_1_ARM64
            machine_emergency_restart_addr();
			#endif
        }
        break;
     
        /*kernel_power_off*/
        case EULER_KERNEL_POWER_OFF:
        {
            PDEBUG("along:test kernel_power_off function begin.");
            kernel_power_off();
        }
        break;
        
        /*kernel_restart*/
        case EULER_KERNEL_RESTART:
        {
            PDEBUG("along:test kernel_restart function begin.");
            kernel_restart("kernel_restart");
        }
        break;
        
        /*kernel_halt*/
        case EULER_KERNEL_HALT:
        {
            PDEBUG("along:test kernel_halt function begin.");
            kernel_halt();
        }
        break;
        
        /*emergency_restart*/
        case EULER_EMERGE_RESTART:
        {
            PDEBUG("along:test emergency_restart function begin.");
            emergency_restart();
        }
        break;
        
	case EULER_CALL_PANIC:
        {
	    PDEBUG("call panic() function in process context 3 times.\n");	  
            panic("call panic() function in process context.\n");
        }
        break;

        case EULER_SERI_CALL_PANIC:
        {
            PDEBUG("call panic() function in process context 3 times.\n");
            panic("call panic() function in process context.\n");
            panic("call panic() function in process context.\n");
            panic("call panic() function in process context.\n");
        }
        break;
	
	case EULER_SERI_PANIC_KERNEL_RESTART:
        {
	    PDEBUG("call panic() function in process context and then call kernel_restart.\n");	  
            kernel_restart(NULL);
            panic("call panic() function in process context.\n");

        }
        break;
		

        case EULER_SERI_MACHINE_EMERGE_RESTART:
        {
            PDEBUG("along?test machine_emergency_restart function 3 times.");
			#ifndef KERNEL_4_1_ARM64
            machine_emergency_restart_addr();
			machine_emergency_restart_addr();
			machine_emergency_restart_addr();
			#endif
        }
        break;
      
        /*kernel_power_off*/
        case EULER_SERI_KERNEL_POWER_OFF:
        {
            PDEBUG("along:test kernel_power_off function 3 times.");
            kernel_power_off();
	    kernel_power_off();
	    kernel_power_off();
        }
        break;
        
        /*emergency_restart*/
        case EULER_SERI_EMERGE_RESTART:
        {
            PDEBUG("along:test emergency_restart function 3 times..");
            emergency_restart();
	    emergency_restart();
	    emergency_restart();
        }
        break;
        
        /*kernel_restart*/
        case EULER_SERI_KERNEL_RESTART:
        {
            PDEBUG("along:test kernel_restart function 3 times..");
            kernel_restart(NULL);
	    kernel_restart(NULL);
	    kernel_restart(NULL);
        }
        break;
        
        /*kernel_halt*/
        case EULER_SERI_KERNEL_HALT:
        {
            PDEBUG("along:test kernel_halt function 3 times..");
            kernel_halt();
	    kernel_halt();
	    kernel_halt();
        }
	break;

        case EULER_OOM:
        {
            PDEBUG("along:test oom 3 times..");
            out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
        }
	break;
	
	case EULER_VMALLOC_OOM:
        {
            PDEBUG("along:test vmalloc\n");
            out_of_memory_vmalloc_fun();
        }
        break;

	case EULER_KMALLOC_OOM:
        {
            PDEBUG("along:test kmalloc\n");
            out_of_memory_kmalloc_fun();
        }
        break;

	case EULER_SERI_OOM:
	{
	    PDEBUG("along:test oom 3 times..");		
	    out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
	    out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
	    out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
	}
	break;		
	
	case EULER_SERI_PANIC_OOM:
	{
	    
	    OOM_FUNC out_of_memory_fun = (OOM_FUNC)out_of_memory_addr;
		PDEBUG("along:test oom and panic..");
	    out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
	    panic("along: my panic\n");
	}
	break;
		
		 /*??panic??*/
        case EULER_PARA_PANIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_panic, NULL, "gen_parallel_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
		
		/*panic?oom??*/
	case EULER_PARA_PANIC_OOM:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_oom_panic, NULL, "gen_parallel_oom_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOM:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_oom, NULL, "gen_parallel_oom/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_RESTART:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_restart, NULL, "gen_parallel_restart/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
		
	case EULER_PARA_RESTART_OOM:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_restart_oom, NULL, "gen_parallel_restart_oom/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;


	case EULER_PARA_RESTART_PANIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_restart_panic, NULL, "gen_parallel_restart_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_PARA_OOPS_RESTART:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_oops_restart, NULL, "gen_parallel_oops_restart/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_PARA_OOPS_OOM:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_oops_oom, NULL, "gen_parallel_oops_oom/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_PARA_OOPS_PANIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_oops_panic, NULL, "gen_parallel_oops_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_PARA_OOPS:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_parallel_oops, NULL, "gen_parallel_oops/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_SERI_OOPS:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_seri_oops, NULL, "gen_seri_oops/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOPS_SAME_CPU:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_same_cpu, NULL, "gen_oops_same_cpu/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOM_SAME_CPU:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oom_same_cpu, NULL, "gen_oom_same_cpu/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
		
	case EULER_PARA_OOPS_PANIC_SAME_CPU:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_panic_same_cpu, NULL, "gen_oops_panic_same_cpu/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_PARA_OOM_PANIC_SAME_CPU:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oom_panic_same_cpu, NULL, "gen_oom_panic_same_cpu/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
		
	case EULER_PARA_EMERGE_PANIC_SAME_CPU:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_emerge_panic_same_cpu, NULL, "gen_emerge_panic_same_cpu/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_EMERGE_OOPS_SAME_CPU:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_emerge_oops_same_cpu, NULL, "gen_emerge_oops_same_cpu/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOPS_SAME_CPU_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_same_cpu_i, NULL, "gen_oops_same_cpu_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOPS_PANIC_SAME_CPU_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_panic_same_cpu_i, NULL, "gen_oops_panic_same_cpu_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOM_PANIC_SAME_CPU_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oom_panic_same_cpu_i, NULL, "gen_oom_panic_same_cpu_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOM_SAME_CPU_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oom_same_cpu_i, NULL, "gen_oom_same_cpu_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
		
	case EULER_PARA_EMERGE_PANIC_SAME_CPU_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_emerge_panic_same_cpu_i, NULL, "gen_emerge_panic_same_cpu_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
	case EULER_PARA_EMERGE_OOPS_SAME_CPU_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_emerge_oops_same_cpu_i, NULL, "gen_emerge_oops_same_cpu_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOPS_OOPS_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_oops_i, NULL, "gen_oops_oops_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;


	case EULER_PARA_OOPS_PANIC_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_panic_i, NULL, "gen_oops_panic_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;


	case EULER_PARA_PANIC_PANIC_I:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_panic_panic_i, NULL, "gen_panic_panic_i/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOPS_SAME_CPU_PANIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oops_same_cpu_panic, NULL, "gen_oops_same_cpu_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOM_SAME_CPU_PANIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oom_same_cpu_panic, NULL, "gen_oom_same_cpu_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case EULER_PARA_OOM_OOPS_PANIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_oom_oops_panic, NULL, "gen_oom_oops_panic/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;
		
	case EULER_SHOW_REGITERS:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(gen_show_registers, NULL, "gen_show_registers/%d", 0);
		kthread_bind(p1, 0);
		wake_up_process(p1);
        }
        break;

	case RSE_NVRAM_PRINTK_BASIC:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(rse_nvram_printk_basic, NULL, "rse_nvram_printk_basic/%d", 0);
		wake_up_process(p1);
        }
        break;

	case RSE_NVRAM_PRINTK_MUTI:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(rse_nvram_printk_muti, NULL, "rse_nvram_printk_muti/%d", 0);
		wake_up_process(p1);
        }
        break;
	case RSE_NVRAM_PRINTK_TMOUT:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(rse_nvram_printk_tmout, NULL, "rse_nvram_printk_tmout/%d", 0);
		wake_up_process(p1);
        }
        break;
	case RSE_NVRAM_PRINTK_BEYOND:
        {
		struct task_struct *p1 = NULL;

		p1 = kthread_create(rse_nvram_printk_beyond, NULL, "rse_nvram_printk_beyond/%d", 0);
		wake_up_process(p1);
        }
        break;
	case EULER_DISABLE_IRQ:
	{
		unsigned int cpu_id = 20;
		int i = 0;

		cpu_id = smp_processor_id();
		#ifndef KERNEL_3_10_X86_64
		PDEBUG("disable irq 60s.\n");
		local_irq_disable();
		for (i = 0; i < 60000; i++)
	        {   
        	    udelay(1000);
        	}   
		#else
		PDEBUG("disable irq 80s.\n");
		local_irq_disable();
		for (i = 0; i < 80000; i++)
	        {   
        	    udelay(2000);
        	}
		#endif
	        local_irq_enable();
	}
	break;
	case EULER_DISABLE_SCHED:
	{
		unsigned int cpu_id = 20;
                int i = 0;

                cpu_id = smp_processor_id();
		#ifndef KERNEL_3_10_X86_64
		PDEBUG("disable sched 60s.\n");
		preempt_disable();
		for (i = 0; i < 60000; i++) 
                {    
                    udelay(1000);
                } 
		#else
		PDEBUG("disable sched 80s.\n");
		preempt_disable();
		for (i = 0; i < 80000; i++) 
                {    
                    udelay(2000);
                }
		#endif
		preempt_enable();
	}
	break;
		

	case PARC_SMALLDOG_RESET:
	{
		fn_kbox_handleParcResetDump = (kbox_handleParcResetDump_fn)kallsyms_lookup_name("kbox_HandleParcResetDump");
       		if (fn_kbox_handleParcResetDump == NULL ){
                	printk("kbox_handleParcResetDump is null\n");
	                return 1;}
		printk("PARC_SMALLDOG_RESET begin\n");
	        fn_kbox_handleParcResetDump();
	}
	break;
	
	#ifndef KERNEL_3_10_X86_64
	case EULER_PARA_LVOS_REBOOT:
	{
		unsigned long reset_type=21;
		unsigned int pid_num=10;
		char *message = "hello";

		printk("kbox test cui_8058 begin\n");
		LVOS_reboot(reset_type, pid_num, message);
		printk("kbox test cui_8058 end\n");
	}
	break;
	#endif
	
	case EULER_OUT_OF_STACK_OOPS_1:
        {
		int ret=0;
		printk("hello, test EULER_OUT_OF_STACK_OOPS_1 begin...\n");
        	ret=up_stackinfo_fun_a();
        	if (ret !=0 )
        	{
                	printk("test EULER_OUT_OF_STACK_OOPS failed\n");
        	}
        }
	break;	
	
	case EULER_OUT_OF_STACK_OOPS_2:
        {
                printk("hello, test EULER_OUT_OF_STACK_OOPS_2 begin...\n");
        	int time=123000;
		OUT_OF_STACK_OOPS_2_testA();
        }
        break;	
	
	case EULER_NMI_WATCHDOG_PANIC:
	{
		printk("hello, cui nmi_watchdog_panic test begin...\n");
        int time=123000;

        local_irq_disable();
        mdelay(time);
        local_irq_enable();

        printk("test_hard_lock_panic: FAIL\n");
	}
	break;
		
	
	default:
	{
		PDEBUG("Command error: Command code is %d\n", iActCode);
	}
	break;
    }

    return 1;
}

/*atoi*/
static int kpgen_atoi(const char *s)
{
	int k = 0;
	while (*s != '\0' && *s >= '0' && *s <= '9') {
		k = 10 * k + (*s - '0');
		s++;
	}
	return k;
}


/* kernel panic generator device read handler */
static ssize_t dev_rd_handler(struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
    return 0;
}

/* kernel panic generator device write handler */
static ssize_t dev_wr_handler(struct file *filp, const char __user *buf, size_t count,loff_t *f_pos)
{
    UINT8 uactcode[KPGEN_MAX_CMD_LEN];
    INT32 iactcode = 0;
    int iret;

    /*verify pramaters*/
    if( NULL == filp || NULL == buf || NULL == f_pos )
    {
        return -EFAULT;
    }

    /* command length should not be larger than KPGEN_MAX_CMD_LEN */
    if(count >= KPGEN_MAX_CMD_LEN)
    {
        PDEBUG("count:%d\n", (int)count);
        PDEBUG("Command error: Count larger than the max length!\n");
        return -EFAULT;
    }

    memset(uactcode, 0, KPGEN_MAX_CMD_LEN);

    /*get operation code*/
    if( copy_from_user(uactcode, buf, count) )
    {
        PDEBUG("copy from user error!");
        return -EFAULT;
    }

    iactcode = kpgen_atoi(uactcode);

    iret = dev_wr_actions(iactcode);
    if (0 > iret){
        return iret;
    }
    
    return count;
}

/* kernel panic generator device io control handler */
static int dev_ioctl_handler(struct inode *inode, struct file *filp,unsigned int cmd, unsigned long arg)
{
    return 0;
}

/* kernel panic generator device open handler */
static int dev_open_hanlder(struct inode *inode, struct file *filp)
{
    return 0;
}

/* kernel panic generator device release handler */
static int dev_release_handler(struct inode *inode, struct file *filp)
{
   return 0;
}

/* setup character device */
static int setup_cdev(struct kpgen_dev *dev, int index)
{
    int err;
    int devno = MKDEV(dev_major, dev_minor + index);
   
    cdev_init(&dev->cdev, &kpgen_fops);
    dev->cdev.owner = THIS_MODULE;
    dev->cdev.ops = &kpgen_fops;
    err = cdev_add (&dev->cdev, devno, 1);
	
    if (err)
    {
        PDEBUG("Error %d adding %s%d\n", err, mod_name, index);
        dev->registered = 0;
        return 1;
    }
	else
    {
        dev->registered = 1;
        return 0;
	}
}

/* kernel panic generator module initialization */
static int __init kpgenm_init(void)
{
    int init_res = 0;
    int i;
	dev_t dev;
	struct module_function kallsyms_looup_name_func = {"", "kallsyms_lookup_name"};

        if (NULL == comm_kallsyms_lookup_name) {
                kallsyms_on_each_symbol(find_comm_kallsyms_lookup_name, &kallsyms_looup_name_func);
        }

        if (NULL == comm_kallsyms_lookup_name) {
                return -1;
        }

	out_of_memory_addr = (OOM_FUNC)comm_kallsyms_lookup_name("out_of_memory");
	#ifndef KERNEL_4_1_ARM64
	machine_emergency_restart_addr = (machine_emergency_restart_func)comm_kallsyms_lookup_name("machine_emergency_restart");
	#endif
	sched_setscheduler_nocheck_addr = (sched_setscheduler_nocheck_fun)comm_kallsyms_lookup_name("sched_setscheduler_nocheck");


	if (out_of_memory_addr == NULL 
		#ifndef KERNEL_4_1_ARM64
		|| machine_emergency_restart_addr == NULL
		#endif
		|| sched_setscheduler_nocheck_addr == NULL) {
		 return -1;
	}

	
    if (init_res)
    {
        PDEBUG("can't get io base\n");
	return init_res;
    }
   
    init_res = alloc_chrdev_region(&dev, dev_minor, dev_nr_devs, mod_name);
    dev_major = MAJOR(dev);

    if (init_res < 0) 
    {
	PDEBUG("%s: can't get major %d\n", mod_name, dev_major);
	return init_res;
    }
    
    g_kpgdev = (struct kpgen_dev *)kmalloc(dev_nr_devs * sizeof(struct kpgen_dev), GFP_KERNEL);
    if (g_kpgdev == NULL) 
    {
	init_res = -ENOMEM;
	PDEBUG("can't get memmory\n");
	goto fail; 
    }
    memset(g_kpgdev, 0, dev_nr_devs * sizeof(struct kpgen_dev));

    for (i = 0; i < dev_nr_devs; i++) 
    {
	if (setup_cdev(&g_kpgdev[i], i))
	{
	    init_res = -EBUSY;
	    goto fail;
	}
    }

    return 0;
    
fail:
    kpgenm_exit();
    return init_res;

}

/* kernel panic generator module exit */
static void kpgenm_exit(void)
{

    int i;
    dev_t devno = MKDEV(dev_major, dev_minor);

    if (g_kpgdev) 
    {
	for (i = 0; i < dev_nr_devs; i++) 
	{
	    if(g_kpgdev[i].registered)
	    {
	        cdev_del(&g_kpgdev[i].cdev);
	    }
	}
	kfree(g_kpgdev);
	g_kpgdev = NULL;
    }
   
    unregister_chrdev_region(devno, dev_nr_devs);
    PDEBUG("module is unloaded.\n");
}

/* kernel time interrupt handlers */
void tmrhnd_nmiinter(unsigned long data)
{
    PDEBUG("nonemaskable interrupt in interrupt context.\n");
    local_irq_disable();
    while(1);

}

void tmrhnd_accnptr(unsigned long data)
{
    UINT8 *pNull = NULL;
	                
    PDEBUG("access NULL pointer in interrupt context.\n");
    *pNull = 0;

}

void tmrhnd_diverrfault(unsigned long data)
{
    __volatile__ UINT8 ucTmp = 0;

    PDEBUG("divide error fault in interrupt context.\n");
    ucTmp = 1 / ucTmp;
    PDEBUG("illegal value: %d.\n", ucTmp);

}

#ifndef KERNEL_4_1_ARM64
void tmrhnd_oftrap(unsigned long data)
{
    long __res;
    PDEBUG("over flow fault in interrupt context.\n");
    __asm__ volatile("int $0x04" : "=a"(__res):);


}

void tmrhnd_brexcefault(unsigned long data)
{
   long __res;
    PDEBUG("bound range exceeded fault in interrupt context.\n");  
   __asm__ volatile("int $0x05" : "=a"(__res):);
	

}
#endif
void tmrhnd_invopfault(unsigned long data)
{
    PDEBUG("invalid opcode fault in interrupt context.\n");
    BUG();
    //__asm__ __volatile__("ud2\n");

}
#ifndef KERNEL_4_1_ARM64
void tmrhnd_copsegorfault(unsigned long data)
{
    long __res;
    PDEBUG("coprocessor segment overrun fault in interrupt context.\n");
    __asm__ volatile("int $0x09" : "=a"(__res):);
  
}

void tmrhnd_invtssfault(unsigned long data)
{
    long __res;
    PDEBUG("invalid TSS fault in interrupt context.\n");
    __asm__ volatile("int $0x0A" : "=a"(__res):);
}

void tmrhnd_segnpresfault(unsigned long data)
{
    long __res;
    PDEBUG("segment not present fault in interrupt context.\n");
    __asm__ volatile("int $0x0B" : "=a"(__res):);
}

void tmrhnd_ssegfault(unsigned long data)
{
    long __res;
    PDEBUG("stack segment fault in interrupt context.\n");
    __asm__ volatile("int $0x0C" : "=a"(__res):);
}
#endif
void tmrhnd_geneprotfault(unsigned long data)
{
    FPTR ptrFunc;
    UINT32 Instr = 0x12345678;
	  
    PDEBUG("general protection fault in process context.\n");
    ptrFunc = (FPTR)(&Instr);
    PDEBUG("the value of ptrFunc is: %p.\n", ptrFunc);
    (*ptrFunc)();

}
#ifndef KERNEL_4_1_ARM64
void tmrhnd_aligchkfault(unsigned long data)
{
    long __res;		
    PDEBUG("alignment check fault\n");
    __asm__ volatile("int $0x11" : "=a"(__res):);

}
#endif
void tmrhnd_callpanic(unsigned long data)
{
    PDEBUG("call panic() in interrupt context.\n");
    del_timer(&g_timer);
    panic("call panic() in interrupt context.\n");
}

void tmrhnd_callpanic_mask_int(unsigned long data)
{
    unsigned long flags;
    PDEBUG("call panic() in interrupt context.\n");
    del_timer(&g_timer);

    local_irq_save(flags);
    panic("call panic() in interrupt context.\n");
    local_irq_restore(flags);
}

void tmrhnd_call_emergency_restart(unsigned long data)
{
    PDEBUG("call panic() in interrupt context.\n");
    del_timer(&g_timer);
    emergency_restart();
}

/* deadlock function */
void r_timer_func(unsigned long data)
{
    spinlock_t *lock = (spinlock_t *)data;
    spin_unlock(lock);
}


int gen_R_process(void *data)
{
//    spinlock_t lock = SPIN_LOCK_UNLOCKED; //chenjl
    DEFINE_SPINLOCK(lock);
    struct timer_list r_timer;
	#ifndef KERNEL_3_10_X86_64
		unsigned long timeout = (unsigned long)data;
	#else
		unsigned long timeout = 600;
	#endif
    if (0 < timeout){
        init_timer(&r_timer);

        r_timer.expires = jiffies + timeout * HZ;
        r_timer.data =(unsigned long)&lock;
        r_timer.function = r_timer_func;

        add_timer(&r_timer);
    }
    printk(KERN_ERR"%s(%d) go into R state\n", current->comm, current->pid);
    spin_lock(&lock);
    spin_lock(&lock);
    spin_unlock(&lock);
    printk(KERN_INFO"%s(%d) got out of R state\n", current->comm, current->pid);

    if (0 < timeout){
        del_timer_sync(&r_timer);
    }
    return 0;
}

void d_timer_func(unsigned long data)
{
    struct semaphore *sem = (struct semaphore *)data;
    up(sem);
}


int gen_D_process(void *data)
{
    struct semaphore semaA;
    struct semaphore semaB;
    struct timer_list d_timer;
    unsigned long timeout = (unsigned long)data;

    //init_MUTEX(&semaA); //chenjl
    //init_MUTEX_LOCKED(&semaB);
    sema_init(&semaA,1);
    sema_init(&semaB,0);
    if (0 < timeout){
        init_timer(&d_timer);

        d_timer.expires = jiffies + timeout * HZ;
        d_timer.data = (unsigned long)&semaB;
        d_timer.function = d_timer_func;

        add_timer(&d_timer);
    }
    
    down(&semaA);
    printk("<0>""%s(%d) go into D state\n", current->comm, current->pid);
     //??semaB???????????semaB??????????uninterruptible
    down(&semaB);
    printk("<0>""%s(%d) got out of D state\n", current->comm, current->pid);

    up(&semaA);
    if (0 < timeout){
        del_timer_sync(&d_timer);
    }
    return 0;
}

int noinline gen_dead_loop(void *data)
{
    while(1);
    return 0;
}
static int printk_test(void *data)
{
    while(1)
    {
        printk(KERN_EMERG"Hello World world world world world world world world!\n");
        msleep(1);
    }
    return 0;
}

int gen_printk_loop(void *data)
{

	int i = 10000l;
	
#if defined(UVP_KVM)
    	while(i--) {
		printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
		printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
		printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
		printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
		msleep(10);
	}
#else
/*	while(i--) {
                printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
                printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
                printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
                printk("printk many log(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)\n");
        } */
	struct task_struct **thr;
	int num=0;
	thr = (struct task_struct **) kmalloc(sizeof(struct task_struct *)*400, GFP_KERNEL);
        if(NULL==thr)
        {
                printk("LockTest: memory not enough\n");
                return -1;
        }
        for(num=0;num<400;num++)
        {
                thr[num] = kthread_create(printk_test, (void *)num, "printk_test");
                if(IS_ERR(thr[num]))
                        printk("LockTest: fail to create thread %d\n", num);
                else
                        printk("LockTest: thread %d created\n", num);
        }
        for(num=0; num<400; num++)
        {
                if( !IS_ERR(thr[num]) )
                        wake_up_process(thr[num]);
        }
#endif

    return 0;
}

static int  gen_panic_process1(void *junk)
{
	panic("call panic\n");

	return 0;
}

static int  gen_panic_process2(void *junk)
{
	panic("call panic\n");

	return 0;
}


static int gen_parallel_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	
	PDEBUG("panic function parallelly.\n");

	p1 = kthread_create(gen_panic_process1, NULL, "panic_process1/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_panic_process2, NULL, "panic_process2/%d", 2);
	kthread_bind(p2, 2);
	p3 = kthread_create(gen_panic_process2, NULL, "panic_process3/%d", 3);
	kthread_bind(p3, 3);
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}

static int gen_parallel_oom_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("panic and oom function parallel.\n");
	p1 = kthread_create(gen_panic_process1, NULL, "panic_process1/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_oom_process1, NULL, "panic_process2/%d", 2);
	kthread_bind(p2, 2);
	p3 = kthread_create(gen_oom_process1, NULL, "panic_process3/%d", 3);
	kthread_bind(p3, 3);

	wake_up_process(p2);
	wake_up_process(p1);
	wake_up_process(p3);
	
	return 0;
}


static int gen_parallel_oom(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("oom and oom function parallel.\n");
	p1 = kthread_create(gen_oom_process1, NULL, "oom_process1/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_oom_process1, NULL, "oom_process2/%d", 2);
	kthread_bind(p2, 2);

	p3 = kthread_create(gen_oom_process1, NULL, "oom_process3/%d", 3);
	kthread_bind(p3, 3);
		
	wake_up_process(p2);
	wake_up_process(p1);
	wake_up_process(p3);

	return 0;
}

static int call_emergency_restart(void *junk)
{
	emergency_restart();

	return 0;
}

static int call_machine_emergency_restart(void *junk)
{
	#ifndef KERNEL_4_1_ARM64
	machine_emergency_restart_addr();
	#endif
	return 0;
}

static int call_kernel_restart(void *junk)
{
	kernel_restart("Testforkbox");

	return 0;
}

static int gen_parallel_restart(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("call_emergency_restart and call_kernel_restart function parallel.\n");
	#ifndef KERNEL_4_1_ARM64
	p1 = kthread_create(call_machine_emergency_restart, NULL, "machine_emergency_restart_addr/%d", 1);
	kthread_bind(p1, 1);
	#endif
	p2 = kthread_create( call_kernel_restart, NULL, "kernel_restart/%d", 2);
	kthread_bind(p2, 2);

	p3 = kthread_create(call_emergency_restart, NULL, "emergency_restart/%d", 3);
	kthread_bind(p3, 3);
		
	wake_up_process(p2);
	#ifndef KERNEL_4_1_ARM64
	wake_up_process(p1);
	#endif
	wake_up_process(p3);
	
	return 0;
}

static int gen_parallel_restart_oom(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("oom and machine_emergency_restart function parallel.\n");
	#ifndef KERNEL_4_1_ARM64
	p1 = kthread_create(call_machine_emergency_restart, NULL, "machine_emergency_restart_addr/%d", 1);
	kthread_bind(p1, 1);
	#endif
	p2 = kthread_create( gen_oom_process1, NULL, "gen_oom_process1/%d", 2);
	kthread_bind(p2, 2);

	p3 = kthread_create(gen_oom_process1, NULL, "gen_oom_process1/%d", 3);
	kthread_bind(p3, 3);
		
	wake_up_process(p2);
	#ifndef KERNEL_4_1_ARM64
	wake_up_process(p1);
	#endif
	wake_up_process(p3);
	
	return 0;
}


static int gen_parallel_restart_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("emergency_restart and panic function parallel.\n");

	p1 = kthread_create(gen_panic_process1, NULL, "gen_panic_process1/%d", 1);
	kthread_bind(p1, 1);
	
	#ifndef KERNEL_4_1_ARM64
	p2 = kthread_create(call_machine_emergency_restart, NULL, "machine_emergency_restart_addr/%d", 2);
	kthread_bind(p2, 2);
	#endif
	p3 = kthread_create(call_emergency_restart, NULL, "emergency_restart/%d", 3);
	kthread_bind(p3, 3);
	
	#ifndef KERNEL_4_1_ARM64	
	wake_up_process(p2);
	#endif	
	wake_up_process(p1);
	wake_up_process(p3);

	return 0;
}



static int gen_parallel_oops_restart(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("emergency_restart and oops function parallel.\n");
	
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	#ifndef KERNEL_4_1_ARM64
	p2 = kthread_create(call_machine_emergency_restart, NULL, "machine_emergency_restart_addr/%d", 2);
	kthread_bind(p2, 2);
	#endif
	p3 = kthread_create(call_emergency_restart, NULL, "emergency_restart/%d", 3);
	kthread_bind(p3, 3);
	
	#ifndef KERNEL_4_1_ARM64	
	wake_up_process(p2);
	#endif
	wake_up_process(p1);
	wake_up_process(p3);

	return 0;
}


static int gen_parallel_oops_oom(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	
	PDEBUG("Oops and oom function parallel.\n");
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_oom_process1, NULL, "gen_oom_process1/%d", 2);
	kthread_bind(p2, 2);
		
	wake_up_process(p2);
	wake_up_process(p1);

	return 0;
}

static int gen_parallel_oops_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("Oops and panic function parallel.\n");
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_panic_process1, NULL, "gen_panic_process1/%d", 2);
	kthread_bind(p2, 2);
	p3 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 3);
	kthread_bind(p3, 3);	
		
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}

static int gen_parallel_oops(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	
	PDEBUG("Oops and oops function parallel.\n");
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	p2 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 2);
	kthread_bind(p2, 2);
	p3 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 3);
	kthread_bind(p3, 3);
		
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}


static int gen_seri_oops(void *junk)
{
	
	PDEBUG("Seri oops.\n");
	
	gen_oops_process(NULL);
	gen_oops_process(NULL);
	gen_oops_process(NULL);

	return 0;
}

static int gen_oops_same_cpu(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oops_same_cpu.\n");
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	
	p3 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p3, 1);
	//change sched_priority
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);
		
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}


static int gen_oom_same_cpu(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oom_same_cpu.\n");
	p1 = kthread_create(gen_oom_process1, NULL, "oom_process1/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_oom_process1, NULL, "oom_process2/%d",1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_oom_process1, NULL, "oom_process3/%d", 1);
	kthread_bind(p3, 1);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	wake_up_process(p1);	
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}


static int gen_oops_panic_same_cpu(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oops_panic_same_cpu.\n");

	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_panic_process2, NULL, "panic_process2/%d", 1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_process2, NULL, "panic_process3/%d", 1);
	kthread_bind(p3, 1);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}

static int gen_oom_panic_same_cpu(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oom_panic_same_cpu.\n");

	p1 = kthread_create(gen_oom_process1, NULL, "oom_process1/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	p2 = kthread_create(gen_panic_process2, NULL, "panic_process2/%d", 1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_process2, NULL, "panic_process3/%d", 1);
	kthread_bind(p3, 1);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}

static int gen_emerge_panic_same_cpu(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_emerge_panic_same_cpu.\n");

	p1 = kthread_create(call_emergency_restart, NULL, "call_emergency_restart/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	p2 = kthread_create(gen_panic_process2, NULL, "panic_process2/%d", 1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_process2, NULL, "panic_process3/%d", 1);
	kthread_bind(p3, 1);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}

static int gen_emerge_oops_same_cpu(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_emerge_panic_same_cpu.\n");

	p1 = kthread_create(call_emergency_restart, NULL, "call_emergency_restart/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	p2 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p3, 1);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}



static int  gen_oops_same_cpu_i(void *junk)
{
	char *null = NULL;
	struct timer_list d_timer;
	PDEBUG("gen_oops_same_cpu_i");
	
	init_timer(&d_timer);

	//200MS
	d_timer.expires = jiffies + 2 * HZ / 10;
	d_timer.data = NULL;
	d_timer.function = gen_oops_process;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	
	/*access null point. OOps*/
	*null = 'a';

	return 0;
}

static int  gen_oom_same_cpu_i(void *junk)
{
	struct timer_list d_timer;
	OOM_FUNC out_of_memory_fun = (OOM_FUNC)out_of_memory_addr;
	PDEBUG("gen_oom_same_cpu_i");

	init_timer(&d_timer);

	//200MS
	d_timer.expires = jiffies + 2 * HZ / 10;
	d_timer.data = NULL;
	d_timer.function = gen_oom_process1;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	
	
	out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);

	return 0;
}


static int  gen_oops_panic_same_cpu_i(void *junk)
{
	char *null = NULL;
	struct timer_list d_timer;

	PDEBUG("gen_oops_panic_same_cpu_i");	
	init_timer(&d_timer);

	//200MS
	d_timer.expires = jiffies + 2 * HZ / 10;
	d_timer.data = NULL;
	d_timer.function = gen_panic_process1;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	
	/*access null point. OOps*/
	*null = 'a';

	return 0;
}


static int  gen_oom_panic_same_cpu_i(void *junk)
{
	struct timer_list d_timer;
	OOM_FUNC out_of_memory_fun = (OOM_FUNC)out_of_memory_addr;
	PDEBUG("gen_oom_panic_same_cpu_i");

	init_timer(&d_timer);

	//200MS
	d_timer.expires = jiffies + 2 * HZ / 10;
	d_timer.data = NULL;
	d_timer.function = gen_panic_process1;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	
	
	out_of_memory_fun(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);

	return 0;
}


static int gen_emerge_panic_same_cpu_i(void *junk)
{
	struct timer_list d_timer;
	init_timer(&d_timer);
	
	PDEBUG("gen_oom_panic_same_cpu_i");
	//200MS
	d_timer.expires = jiffies + 2 * HZ / 10;
	d_timer.data = NULL;
	d_timer.function = gen_panic_process1;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	
	emergency_restart();

	return 0;
}

static int gen_emerge_oops_same_cpu_i(void *junk)
{
	
	struct timer_list d_timer;
	init_timer(&d_timer);

	PDEBUG("gen_emerge_oops_same_cpu_i");

	//200MS
	d_timer.expires = jiffies + 2 * HZ / 10;
	d_timer.data = NULL;
	d_timer.function = gen_oops_process;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	
	emergency_restart();

	return 0;
}


static int gen_oops_i(void *junk)
{
	struct timer_list d_timer;
	init_timer(&d_timer);
	PDEBUG("gen_oops_i");
	d_timer.expires = jiffies + 10;
	d_timer.data = NULL;
	d_timer.function = gen_oops_process;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
	return 0;
}

static int gen_panic_i(void *junk)
{
	struct timer_list d_timer;
	
	PDEBUG("gen_oops_panic_same_cpu_i");
	init_timer(&d_timer);

	d_timer.expires = jiffies + 10;
	d_timer.data = NULL;
	d_timer.function = gen_panic_process1;
	//add_timer(&d_timer);
	add_timer_on(&d_timer, smp_processor_id());
        msleep(20);
	/*access null point. OOps*/
	//*null = 'a';
	return 0;
}


static int gen_oops_oops_i(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oops_panic_same_cpu.\n");

	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_oops_i, NULL, "gen_oops_i/%d", 2);
	kthread_bind(p2, 2);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_oops_i, NULL, "gen_oops_i/%d", 3);
	kthread_bind(p3, 3);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}


static int gen_oops_panic_i(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oops_panic_same_cpu.\n");

	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 2);
	kthread_bind(p2, 2);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 3);
	kthread_bind(p3, 3);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}


static int gen_panic_panic_i(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;	
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_panic_panic_i.\n");

	p1 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 2);
	kthread_bind(p2, 2);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 3);
	kthread_bind(p3, 3);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}



static int gen_oops_same_cpu_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oops_same_cpu.\n");
	p1 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d", 1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	
	p3 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 3);
	kthread_bind(p3, 3);
	//change sched_priority
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);
		
	wake_up_process(p1);
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}


static int gen_oom_same_cpu_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oom_same_cpu.\n");
	p1 = kthread_create(gen_oom_process1, NULL, "oom_process1/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_oom_process1, NULL, "oom_process2/%d",1);
	kthread_bind(p2, 1);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 3);
	kthread_bind(p3, 3);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	wake_up_process(p1);	
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}

static int gen_oom_oops_panic(void *junk)
{
	struct task_struct *p1 = NULL;
	struct task_struct *p2 = NULL;
	struct task_struct *p3 = NULL;
	static const struct sched_param param0 = { .sched_priority = 15};
	static const struct sched_param param1 = { .sched_priority = 5};
	static const struct sched_param param2 = { .sched_priority = 5};
	static const struct sched_param param3 = { .sched_priority = 5};

	sched_setscheduler_nocheck_addr(current, SCHED_RR, &param0);
	
	PDEBUG("gen_oom_same_cpu.\n");
	p1 = kthread_create(gen_oom_process1, NULL, "oom_process1/%d", 1);
	kthread_bind(p1, 1);
	sched_setscheduler_nocheck_addr(p1, SCHED_RR, &param1);
	
	p2 = kthread_create(gen_oops_process, NULL, "gen_oops_process/%d",2);
	kthread_bind(p2, 2);
	sched_setscheduler_nocheck_addr(p2, SCHED_RR, &param2);
	p3 = kthread_create(gen_panic_i, NULL, "gen_panic_i/%d", 3);
	kthread_bind(p3, 3);
	sched_setscheduler_nocheck_addr(p3, SCHED_RR, &param3);

	wake_up_process(p1);	
	wake_up_process(p2);
	wake_up_process(p3);

	return 0;
}




typedef void (*my_show_registers)(struct pt_regs *regs);

static int gen_show_registers(void *junk)
{

	struct pt_regs *tmp_regs = (struct pt_regs *)task_pt_regs(current);
	my_show_registers sr_fun;
	
	PDEBUG("Show registers.\n");

	sr_fun=(my_show_registers)kallsyms_lookup_name("show_registers");
	if (sr_fun != NULL) {
		sr_fun(tmp_regs);
	} else {
		printk("Can not find show_registers\n");
	}

	return 0;
}


static int printk_comm(void *times)
{
	int i = (int)times;

	while(i-- > 0) {
		printk("test for NVRAM\n");
	}

	return 0;
}

static int rse_nvram_printk_basic(void *junk)
{
	printk_comm((void*)10);
	return 0;
}

static int rse_nvram_printk_muti(void *junk)
{
	struct task_struct *p_muti[100];
	int i;
	
	for (i = 0; i < 100; i++) {
		p_muti[i] = kthread_create(printk_comm, (void*)20, "printk_comm/%d", i);
	}
	for (i = 0; i < 100; i++) {
		wake_up_process(p_muti[i]);
	}
	return 0;	
}


static void rse_nrame_printk_timer_func(unsigned long data)
{
	int *out_flag = (int *)data;
	*out_flag = 0;
}

static int rse_nvram_printk_tmout(void *junk)
{
	struct timer_list d_timer;
	unsigned long timeout = (unsigned long)60;		
	volatile int out_flag = 1;


	init_timer(&d_timer);
	d_timer.expires = jiffies + timeout * HZ;
	d_timer.data = (unsigned long)&out_flag;
	d_timer.function = rse_nrame_printk_timer_func;
	add_timer(&d_timer);

	while (out_flag) {
		printk_comm((void*)100);
		msleep(100);
	}

  	if (0 < timeout){
        	del_timer_sync(&d_timer);
    	}
	return 0;
}

static int rse_nvram_printk_beyond(void *junk)
{
        int i = 0;
	int max_times = 1000000;

        for (i = 0; i < max_times; i++) {
                printk("test for NVRAM %d\n", i);
		if (i % 1000 == 0) {
			msleep(100);
		}
        }

	return 0;
}



static int  gen_oops_process(void *junk)
{
	char *null = NULL;

	/*access null point. OOps*/
	*null = 'a';

	return 0;
}


static int  gen_oom_process1(void *junk)
{
	OOM_FUNC out_of_memory_fun = (OOM_FUNC)out_of_memory_addr;
	PDEBUG("along:test oom ...");
	out_of_memory_fun(node_zonelist(0, GFP_KERNEL), (in_interrupt() ? GFP_ATOMIC : GFP_KERNEL), 0, NULL, true);

	return 0;
}

/*
imitate sigma warning interface
*/

extern void rtc_time_to_tm(unsigned long time, struct rtc_time *tm);

int kbox_get_date_str(char *buf, int size)
{
        struct rtc_time tm;
        struct timeval tv;
        int ret;

        if (!buf || size < 40)
        {
                return -1;
        }

        do_gettimeofday(&tv);
        rtc_time_to_tm(tv.tv_sec, &tm);
        ret = snprintf(buf, size, "%04d%02d%02d%02d%02d%02d-%lx",
                                   tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min,
                                   tm.tm_sec, tv.tv_usec);

        return ret;
}

#define KBOX_DATE_LENGTH      (100)

void test_sigma_warning_interface(int type)
{
        int length;
        char datetime[KBOX_DATE_LENGTH];

        length = kbox_get_date_str(datetime, KBOX_DATE_LENGTH - 1);
        datetime[length] = '\0';

	printk("test_sigma_warning_interface:%s %d\n", datetime, type);
        printk("junk:012345656789\n");

}

void out_of_memory_vmalloc_fun(void)
{
	void *data;
        while (1)
        {
                testcase_vmalloc(data);
        }
}

int testcase_vmalloc(void *data)
{
	unsigned long size=1024;
	char *addr=NULL;
        addr = (char *)vmalloc(size);
        if (addr == NULL) {
        	printk("__get_free_pages(vmalloc) error\n");
        	return 1;
        }

        memset(addr, 0, size);
        printk("(vmalloc)memset success, addr=0x%p\n", addr);
        return 0;
}

void out_of_memory_kmalloc_fun(void)
{
        void *data;
        while (1)
        {
                testcase_kmalloc(data);
        }
}

int testcase_kmalloc(void *date)
{
        unsigned long size=4 * 1024 * 1024;
        char *addr=NULL;
	addr = (char *)kmalloc(size,0);
        if (addr == NULL) {
        	printk("__get_free_pages(kmalloc) error\n");
        	return 1;
        }

        memset(addr, 0, size);
        printk("(kmalloc)memset success, addr=0x%p\n", addr);
        return 0;
}

int up_stackinfo_fun_a(void)
{
        int ret=0;
        printk("up_stackinfo_func aaaaaa test g_inum=%d\n",g_inum);
        ret=up_stackinfo_fun_b();
        if(ret != 0)
        {
                printk("this test is failed aaaa g_inum=%d\n",g_inum);
                return 1;
        }
        g_inum++;
        return 0;
}


int up_stackinfo_fun_b(void)
{
        int ret=0;
        printk("up_stackinfo_func bbbbbb test g_inum=%d\n",g_inum);
        ret=up_stackinfo_fun_a();
        if(ret != 0)
        {
                printk("this test is failed bbbb g_inum=%d\n",g_inum);
                return 1;
        }
        g_inum++;
        return 0;
}

void OUT_OF_STACK_OOPS_2_testB(void)
{
   char b[LEN];
   memset(b, 0, sizeof(b));
   b[2]='A';
   OUT_OF_STACK_OOPS_2_testA();
}

void OUT_OF_STACK_OOPS_2_testA(void)
{
   char a[LEN];
   memset(a, 0, sizeof(a));
   a[2]='A';
   OUT_OF_STACK_OOPS_2_testB();
}

EXPORT_SYMBOL(test_sigma_warning_interface);

/* module information macros */
MODULE_AUTHOR("Huawei Tech. CO., LTD.");
MODULE_DESCRIPTION("Huawei KBox Generator");
MODULE_LICENSE("GPL");

/* kernel module interface macros */
module_init(kpgenm_init);
module_exit(kpgenm_exit);

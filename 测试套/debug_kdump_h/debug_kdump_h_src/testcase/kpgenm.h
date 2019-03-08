/****************************************************************************
file name	: kpgenm.h
description	: header file for kernel panic generator module
author		: wanghainan
data		: 2007-07-24
****************************************************************************/

#ifndef _KPGENM_  /* _KPGENM_ */
#define _KPGENM_

#ifdef __cplusplus
extern "C"
{
#endif

/* included header file list */
#include <linux/module.h>
#include <linux/init.h>
//#include <linux/config.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>	/* printk() */
#include <linux/slab.h>		/* kmalloc() */
#include <linux/fs.h>		/* everything... */
#include <linux/errno.h>	/* error codes */
#include <linux/types.h>	/* size_t */
#include <linux/proc_fs.h>
#include <linux/fcntl.h>	/* O_ACCMODE */
#include <linux/seq_file.h>
#include <linux/cdev.h>
#include <linux/delay.h> 	/* mdelay */
#include <linux/bootmem.h>  	/* inb() outb() */
//#include <asm/system.h>		/* cli(), *_flags */
#include <asm/uaccess.h>	/* copy_*_user */
#include <linux/notifier.h> 	/* for panic notify */
#include <linux/ptrace.h>
#include <linux/kthread.h>
//#include <linux/dumpdev.h>
//xiejy delete it in X86 
//#include <asm/kdebug.h>
#include <linux/reboot.h>
#include <linux/notifier.h>
#include <asm/processor.h>
//xiejy delete it in MIPS
//#include <asm/desc.h>
#include <asm/unistd.h>
#include <linux/seq_file.h>

/* add for maps */
/* from seq_file.c */
#include <linux/fs.h>
#include <linux/module.h>
#include <linux/seq_file.h>
#include <linux/slab.h>
#include <asm/uaccess.h>
#include <asm/page.h>

/* from dcache.c */
//#include <linux/config.h>
#include <linux/syscalls.h>
#include <linux/string.h>
#include <linux/mm.h>
#include <linux/fs.h>
//xiejy delete it in X86 
//#include <linux/fsnotify.h>
#include <linux/slab.h>
#include <linux/init.h>
//#include <linux/smp_lock.h> //chenjl
#include <linux/hash.h>
#include <linux/cache.h>
#include <linux/module.h>
#include <linux/mount.h>
#include <linux/file.h>
#include <asm/uaccess.h>
#include <linux/security.h>
#include <linux/seqlock.h>
#include <linux/swap.h>
#include <linux/bootmem.h>

#include <linux/ioctl.h>  	/* needed for the _IOW etc stuff used later */

#include <asm/bug.h>
//#include <asm/system.h>

#include <linux/kallsyms.h>
#include <linux/hardirq.h>


#include <asm/emergency-restart.h>

#include <linux/version.h>

/* type definitions */
typedef unsigned char 	UINT8;
typedef signed char 	INT8;
typedef unsigned short 	UINT16;
typedef signed short 	INT16;
typedef unsigned int 	UINT32;
typedef signed int 	INT32;

/* macro definitions */
/*
 * Macros to help debugging
 */
#undef PDEBUG             /* undef it, just in case */
#define DEBUG

#ifdef DEBUG
     #ifdef __KERNEL__
         /* This one if debugging is on, and kernel space */
         #define PDEBUG(fmt, args...) printk( KERN_EMERG "kpgenm: " fmt, ## args)
     #else
         /* This one for user space */
         #define PDEBUG(fmt, args...) fprintf(stderr, fmt, ## args)
     #endif
#else
     #define PDEBUG(fmt, args...) /* not debugging: nothing */
#endif

//#undef PDEBUGG
//#define PDEBUGG(fmt, args...) /* nothing: it's a placeholder */

#ifndef CDEV_MAJOR
#define CDEV_MAJOR 		0   	/* dynamic major by default */
#endif

#ifndef CDEV_MINOR
#define CDEV_MINOR 		1   
#endif

#ifndef CDEV_NR_DEVS
#define CDEV_NR_DEVS 		1    
#endif


#define CDEV_IO_BASE_UNDEF 	0
#define CDEV_IO_BASE0 		0xc80 	/* fpga has two IO base address, which we need to detect fpga will use. */
#define CDEV_IO_BASE1 		0xa80 

typedef void (*FPTR)(void); 

/* total triger definations:
#define PC_DIVIDE_ERR_FAULT        '1'
#define PC_NMI_INTER               '2'
#define PC_BREAK_POINT_TRAP        '3'
#define PC_OVER_FLOW_TRAP          '4'
#define PC_BR_EXCEEDED_FAULT       '5'
#define PC_INVALID_OP_FAULT        '6'
#define PC_DEVICE_NAVAIL_FAULT     '7'
#define PC_DOUBLE_FAULT            '8'
#define PC_COPR_SEG_OVERRUN_FAULT  '9'
#define PC_INVALID_TSS_FAULT       '0'
#define PC_SEG_NPRESENT_FAULT      'a' 
#define PC_STACK_SEG_FAULT         'b'
#define PC_GENERAL_PROTECT_FAULT   'c'
#define PC_PAGE_FAULT              'd'
#define PC_x87FPU_FPERR_FAULT      'e'
#define PC_ALIGNMENT_CHK_FAULT     'f'
#define PC_MACHINE_CHK_ABOUT       'g'
#define PC_SIMD_FPEXCEPTION_FAULT  'h'

#define IC_DIVIDE_ERR_FAULT        'i'
#define IC_NMI_INTER               'j'
#define IC_BREAK_POINT_TRAP        'k'
#define IC_OVER_FLOW_TRAP          'l'
#define IC_BR_EXCEEDED_FAULT       'm'
#define IC_INVALID_OP_FAULT        'n'
#define IC_DEVICE_NAVAIL_FAULT     'o'
#define IC_DOUBLE_FAULT            'p'
#define IC_COPR_SEG_OVERRUN_FAULT  'q'
#define IC_INVALID_TSS_FAULT       'r'
#define IC_SEG_NPRESENT_FAULT      's' 
#define IC_STACK_SEG_FAULT         't'
#define IC_GENERAL_PROTECT_FAULT   'u'
#define IC_PAGE_FAULT              'v'
#define IC_x87FPU_FPERR_FAULT      'w'
#define IC_ALIGNMENT_CHK_FAULT     'x'
#define IC_MACHINE_CHK_ABOUT       'y'
#define IC_SIMD_FPEXCEPTION_FAULT  'z'
*/

/* original triger definations:
#define PC_ACC_NPTR	'1'
#define PC_DIV_ZERO	'2'
#define PC_CALL_PANIC	'3'
#define PC_DEAD_LOOP	'4'
#define PC_SHORT_DELAY	'5'
#define PC_LONG_DELAY	'6'
#define PC_ILLE_INSTR   '7' 
#define PC_GENE_PROTE   '8'

#define IC_ACC_NPTR	'a'
#define IC_DIV_ZERO	'b'
#define IC_CALL_PANIC	'c'
#define IC_DEAD_LOOP	'd'
#define IC_SHORT_DELAY	'e'
#define IC_LONG_DELAY	'f'
#define IC_ILLE_INSTR   'g'
#define IC_GENE_PROTE   'h'
*/




/* process context :
#define PC_NMI_INTER               '1'
#define PC_ACCESS_NPTR             '2'
#define PC_DIVIDE_ERR_FAULT        '3'
#define PC_OVERFLOW_TRAP           '4'
#define PC_BR_EXCEEDED_FAULT       '5'
#define PC_INVALID_OP_FAULT        '6'
#define PC_COPR_SEG_OVERRUN_FAULT  '7'
#define PC_INVALID_TSS_FAULT       '8'
#define PC_SEG_NPRESENT_FAULT      '9'
#define PC_STACK_SEG_FAULT         '0'
#define PC_GENERAL_PROT_FAULT      'a'
#define PC_ALIGNMENT_CHK_FAULT     'b'  
#define PC_CALL_PANIC              'c'
*/

/* interrupt context :
#define IC_NMI_INTER               'd'
#define IC_ACCESS_NPTR             'e'
#define IC_DIVIDE_ERR_FAULT        'f'
#define IC_OVERFLOW_TRAP           'g'
#define IC_BR_EXCEEDED_FAULT       'h'
#define IC_INVALID_OP_FAULT        'i'
#define IC_COPR_SEG_OVERRUN_FAULT  'j'
#define IC_INVALID_TSS_FAULT       'k'
#define IC_SEG_NPRESENT_FAULT      'l'
#define IC_STACK_SEG_FAULT         'm'
#define IC_GENERAL_PROT_FAULT      'n'
#define IC_ALIGNMENT_CHK_FAULT     'o'
#define IC_CALL_PANIC              'p'  
*/


/* begin: defined by c00146312 20081229*/
#define KPGEN_MAX_CMD_LEN (32)


/* process context :*/
#define PC_NMI_INTER                             (1001)           /* nonemaskable external interrupt */
#define PC_ACCESS_NPTR                        (1002)           /* access null pointer */
#define PC_DIVIDE_ERR_FAULT               (1003)           /* divide error fault */
#define PC_OVERFLOW_TRAP                   (1004)           /* overflow trap ???*/
#define PC_BR_EXCEEDED_FAULT            (1005)           /* bound range exceeded fault ???*/
#define PC_INVALID_OP_FAULT               (1006)           /* invalid opcode fault */
#define PC_COPR_SEG_OVERRUN_FAULT (1007)           /* coprocessor segment overrun fault ??? */
#define PC_INVALID_TSS_FAULT             (1008)           /* invalid TSS fault ???*/
#define PC_SEG_NPRESENT_FAULT          (1009)          /* segment not present fault ??? */
#define PC_STACK_SEG_FAULT                (1010)           /* stack segment fault ???*/
#define PC_GENERAL_PROT_FAULT          (1011)           /* general protection fault */
#define PC_ALIGNMENT_CHK_FAULT        (1012)          /* alignment check fault */
#define PC_CALL_PANIC                           (1013)           /* call panic functions */


/* interrupt context :*/
#define IC_NMI_INTER                          (2001)                          /* nonemaskable external interrupt */
#define IC_ACCESS_NPTR                        (2002)                       /* access null pointer */
#define IC_DIVIDE_ERR_FAULT                   (2003)                   /* divide error fault */
#define IC_OVERFLOW_TRAP                      (2004)                    /* overflow trap ???*/
#define IC_BR_EXCEEDED_FAULT                  (2005)                 /* bound range exceeded fault ???*/
#define IC_INVALID_OP_FAULT                   (2006)                   /* invalid opcode fault */
#define IC_COPR_SEG_OVERRUN_FAULT             (2007)           /* coprocessor segment overrun fault ??? */
#define IC_INVALID_TSS_FAULT                  (2008)                  /* invalid TSS fault ???*/
#define IC_SEG_NPRESENT_FAULT                 (2009)                /* segment not present fault ??? */
#define IC_STACK_SEG_FAULT                    (2010)                   /* stack segment fault ???*/
#define IC_GENERAL_PROT_FAULT                 (2011)                /* general protection fault */
#define IC_ALIGNMENT_CHK_FAULT                (2012)               /* alignment check fault */
#define IC_CALL_PANIC                         (2013)                          /* call panic functions */
#define IC_CALL_PANIC_MASK_INT                         (2014)                 /* call panic functions with mask interrupt*/

/* deadlock context */
#define DEAD_KERNEL_LOOP_FAULT    (3001)      /*?????*/
#define DEAD_R_LOCK_FAULT         (3002)           /*??2??????????Cpu R??*/
#define DEAD_D_LOCK_FAULT         (3003)           /*????D????*/


/* end: defined by c00146312 20081229*/

/*euler kbox test add*/
#define EULER_MACHINE_EMERGE_RESTART        (8001)   
#define EULER_KERNEL_POWER_OFF              (8002)
#define EULER_KERNEL_RESTART                (8003)
#define EULER_KERNEL_HALT                   (8004)
#define EULER_EMERGE_RESTART                (8005)
#define EULER_EMERGE_RESTART_INT            (7005)
#define EULER_CALL_PANIC 		    (8006)
#define EULER_SERI_CALL_PANIC		    (8007)
#define EULER_SERI_PANIC_KERNEL_RESTART	    (8008)
#define EULER_SERI_MACHINE_EMERGE_RESTART   (8009)   
#define EULER_SERI_KERNEL_POWER_OFF	    (8010)
#define EULER_SERI_KERNEL_RESTART	    (8011)
#define EULER_SERI_KERNEL_HALT 		    (8012)
#define EULER_SERI_EMERGE_RESTART	    (8013)
#define EULER_OOM			    (8014)
#define EULER_SERI_OOM			    (8015)
#define EULER_PARA_PANIC		    (8016)
#define EULER_PARA_PANIC_OOM		    (8017)
#define EULER_SERI_PANIC_OOM 		    (8018)
#define EULER_PARA_OOM 		  	    (8019)
#define EULER_PARA_RESTART 		    (8020)
#define EULER_PARA_RESTART_OOM 		  	    (8021)
#define EULER_PARA_RESTART_PANIC 		    (8022)

#define EULER_PRINTK_MANYMESSAGE 		    (8023)
#define EULER_SHOW_REGITERS 		    (8024)
#define EULER_SERI_OOPS 		    (8025)
#define EULER_PARA_OOPS 		    (8026)
#define EULER_PARA_OOPS_PANIC 		    (8027)
#define EULER_PARA_OOPS_OOM 		    (8028)
#define EULER_PARA_OOPS_RESTART 		    (8029)
/*for enhence test*/
#define EULER_PARA_OOPS_SAME_CPU 		    (8030)
#define EULER_PARA_OOM_SAME_CPU 		    (8031)
#define EULER_PARA_OOPS_PANIC_SAME_CPU 		    (8032)
#define EULER_PARA_OOM_PANIC_SAME_CPU 		    (8033)
#define EULER_PARA_EMERGE_PANIC_SAME_CPU 		    (8034)
#define EULER_PARA_EMERGE_OOPS_SAME_CPU 		    (8035)

#define EULER_PARA_OOPS_SAME_CPU_I 		    (8036)
#define EULER_PARA_OOM_SAME_CPU_I		    (8037)
#define EULER_PARA_OOPS_PANIC_SAME_CPU_I  		    (8038)
#define EULER_PARA_OOM_PANIC_SAME_CPU_I  		    (8039)
#define EULER_PARA_EMERGE_PANIC_SAME_CPU_I  		    (8040)
#define EULER_PARA_EMERGE_OOPS_SAME_CPU_I  		    (8041)

#define EULER_PARA_OOPS_OOPS_I  		    (8042)
#define EULER_PARA_OOPS_PANIC_I  		    (8043)
#define EULER_PARA_PANIC_PANIC_I  		    (8044)


/*MIX*/
#define EULER_PARA_OOPS_SAME_CPU_PANIC 		    (8045)
#define EULER_PARA_OOM_SAME_CPU_PANIC 		    (8046)
#define EULER_PARA_OOM_OOPS_PANIC 		    (8047)

#define RSE_NVRAM_PRINTK_BASIC 		    (8051)
#define RSE_NVRAM_PRINTK_MUTI 		    (8052)
#define RSE_NVRAM_PRINTK_TMOUT 		    (8053)
#define RSE_NVRAM_PRINTK_BEYOND 		(8054)

#define EULER_DISABLE_IRQ   (8055)
#define EULER_DISABLE_SCHED (8056)
#define PARC_SMALLDOG_RESET (8057)

/*kernel reboot*/
#define EULER_PARA_LVOS_REBOOT (8058)

/*malloc oom*/
#define EULER_VMALLOC_OOM (8059)
#define EULER_KMALLOC_OOM (8060)

/*up_stackinfo oops*/
#define EULER_OUT_OF_STACK_OOPS_1 (8061)
#define EULER_OUT_OF_STACK_OOPS_2 (8062)

/*NMI_Watchdog panic*/
#define EULER_NMI_WATCHDOG_PANIC (8063)

/* struct definition */
struct kpgen_dev 
{
    /* flag check this device is registered successfullly */	
    int registered;    
    /* mutual exclusion read semaphore */ 		
    struct semaphore r_sem;    
    /* mutual exclusion write semaphore */    
    struct semaphore w_sem;
    /* Char device structure */
    struct cdev cdev;	  			
	
};

#define LINUX_VERSION_CODE_XY	((LINUX_VERSION_CODE) & (~0xFF))
#define KERNEL_3_0 				(LINUX_VERSION_CODE_XY == KERNEL_VERSION(3, 0, 0)  ? 1 : 0)
#define KERNEL_3_4 				(LINUX_VERSION_CODE_XY == KERNEL_VERSION(3, 4, 0)  ? 1 : 0)
#define KERNEL_3_10 			(LINUX_VERSION_CODE_XY == KERNEL_VERSION(3, 10, 0) ? 1 : 0)
#define KERNEL_4_1 				(LINUX_VERSION_CODE_XY == KERNEL_VERSION(4, 1, 0)  ? 1 : 0)

#ifndef X86_64
#define X86_64					(0)
#endif

#ifndef ARM64
#define ARM64					(0)
#endif

#define KERNEL_3_0_X86_64		(KERNEL_3_0  && X86_64)
#define KERNEL_3_4_X86_64		(KERNEL_3_4  && X86_64)
#define KERNEL_3_10_X86_64		(KERNEL_3_10 && X86_64)
#define KERNEL_4_1_ARM64		(KERNEL_4_1  && ARM64)




#ifdef __cplusplus
}
#endif

#endif	/* _KPGENM_ */

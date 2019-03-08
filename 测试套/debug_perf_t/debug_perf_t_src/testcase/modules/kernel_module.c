#include<linux/module.h>
#include<linux/types.h>
#include<linux/errno.h>
#include<linux/mm.h>
#include<linux/init.h>
#include<asm/io.h>
#include<linux/kthread.h>
#include<linux/string.h>
#include<linux/proc_fs.h>
#include<linux/uaccess.h>
#include<linux/delay.h>
//char **p=NULL;
static int free_enable=0;
//int cryc=0;
static inline int func_count(void)
{
    int i=0,j=10,sum=0;
    for(i=0;i<=j;i++)
        sum=sum+i;
    return sum;
}
ssize_t planck_free_read(struct file *file,char __user *buf,size_t count,loff_t *ppos)
{
    char buffer[15]={0};
    int ret=func_count();
    printk("ret is %d\n",ret);
    snprintf(buffer,sizeof(buffer),"0x%1x\n",free_enable);
    return simple_read_from_buffer(buf,count,ppos,&buffer,strlen(buffer));
}
EXPORT_SYMBOL(planck_free_read);

ssize_t planck_free_write(struct file *file,const char __user *buf,size_t count,loff_t *ppos)
{
    char buffer[15],*end;
    unsigned long val=0;
    if(count>=sizeof(buffer)||*ppos)
    {
        printk("count > = sizeof buffer \n");
        return -EINVAL;
    }
    if(copy_from_user(buffer,buf,count))
    {
        printk("write data to proc error\n");
        return -1;
    }
    val=simple_strtoul(buffer,&end,0);
    if(buffer-end==0)
    {
        printk("buffer-end==0\n");
        return -EINVAL;
    }
    free_enable=val;
    return count;
}
EXPORT_SYMBOL(planck_free_write);

static struct file_operations f_ops={
    .write=planck_free_write,
    .read=planck_free_read,
};
static int proc_fs(void)
{
    struct proc_dir_entry *ps;
    ps=proc_create("mykthread_free_enable",0644,NULL,&f_ops);
    if(!ps)
    {
        printk("proc create error\n");
        return -EINVAL;
    }
    return 0;
}


static int proc_init(void)
{
    proc_fs();
    return 0;
}

static void proc_exit(void)
{
    remove_proc_entry("mykthread_free_enable",NULL);
    printk("rmmove mykthread_free_enable\n");
}

//module_param(cryc,int,S_IRUGO);

module_init(proc_init);
module_exit(proc_exit);

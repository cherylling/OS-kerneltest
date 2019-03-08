#include <linux/module.h>
#include <asm/io.h>
#include <linux/slab.h>
#include <linux/time.h>
#include <linux/random.h>
#include <linux/kthread.h>
#include <asm/hisi-llc.h>
#include <linux/fs.h>
#include <linux/seq_file.h>
#include <linux/proc_fs.h>
#include <asm/uaccess.h>
#include <asm/tlb.h>
#include <asm/barrier.h>
#include <asm/delay.h>
#include <linux/delay.h>
#include <linux/cpumask.h>

#define MNT_RANGE_GLOBAL	(0x0)	/* do global maintain */
#define MNT_RANGE_AREA		(0x1)	/* do specified address area maintain */
#define SZ_5K 			(SZ_4K + SZ_1K)
typedef unsigned char uchar;

enum mnt_type {
	MNT_TYPE_FLUSH		= 0x0,
	MNT_TYPE_CLEAN		= 0x1,
	MNT_TYPE_INV		= 0x2,
};

static int test_core = 0;
module_param(test_core, int, 0);
MODULE_PARM_DESC(test_core, "LLC test: 1, only single core test; 2, only multi core test."
		"Default: 0.");

static long base_addr = SZ_512M;
module_param(base_addr, long, 0);
MODULE_PARM_DESC(base_addr, "LLC test: base_addr: xxxx, Default: 512M");

MODULE_DESCRIPTION("LLC Driver Test");
MODULE_LICENSE("Dual BSD/GPL");
static int llc_passed;
static int llc_failed;

#define llc_fmt(fmt) "LLC_TEST: " fmt
#define llc_info(fmt, ...) \
	printk(KERN_INFO llc_fmt(fmt), ##__VA_ARGS__)
#define llc_err(fmt, ...) \
	printk(KERN_ERR llc_fmt(fmt), ##__VA_ARGS__)
#define llc_debug(fmt, ...) \
	printk(KERN_DEBUG llc_fmt(fmt), ##__VA_ARGS__)

#define llc_test_begin() \
	printk(KERN_INFO "LLC_TEST: %s begin.\n", __func__)

/* remove llc_flush_all for TAG360 because nonsupport now */
#define llc_test_finish() \
	do { \
		printk(KERN_INFO "LLC_TEST: %s finished.\n", __func__); \
		llc_flush_all(); \
		schedule(); \
	} while(0)
#define llc_test_init_failed() \
	printk(KERN_INFO "LLC_TEST: %s init failed.\n", __func__)
#define llc_test_failed() \
	do { \
		llc_failed++; \
		printk(KERN_INFO "LLC_TEST: %s failed.\n", __func__); \
	} while(0)
#define llc_test_passed() \
	do { \
		llc_passed++; \
		printk(KERN_INFO "LLC_TEST: %s passed.\n", __func__); \
	} while(0)

#define llc_test_begin_name(name) \
	printk(KERN_INFO "LLC_TEST: %s begin.\n", name)
//llc_flush_all();
/* remove llc_flush_all for TAG360 because nonsupport now */
#define llc_test_finish_name(name) \
	do { \
		printk(KERN_INFO "LLC_TEST: %s finish.\n", name); \
		llc_flush_all(); \
		schedule(); \
	} while(0)
#define llc_test_init_failed_name(name) \
	printk(KERN_INFO "LLC_TEST: %s init failed.\n", name)
#define llc_test_failed_name(name) \
	do { \
		llc_failed++; \
		printk(KERN_INFO "LLC_TEST: %s failed.\n", name); \
	} while(0)
#define llc_test_passed_name(name) \
	do { \
		llc_passed++; \
		printk(KERN_INFO "LLC_TEST: %s passed.\n", name); \
	} while(0)

#define PROT_NORMAL_SHARED (PROT_NORMAL | PTE_SHARED)
#define ioremap_cached_shared(addr, size)	__ioremap((addr), (size), __pgprot(PROT_NORMAL_SHARED))

#define LLC_CACHE_LINE_SIZE	128

#define SRC_ADDR	(base_addr + SZ_2M)	/* 640MB */
#define DST_ADDR	(base_addr + SZ_4M + SZ_16M)	/* 768MB */

/* used by cahce coherence test */
unsigned long phys_start; /* 512M */
unsigned long mem_size = SZ_1M;//SZ_16M + SZ_4M;

void *mymemset(void *s, char c, size_t count)
{
	size_t tmp = count;
	int times = 0;
	void *addr_s = s;

	int step = 64;
	while (tmp > step) {
		memset(addr_s, c, step);
		addr_s += step;
		tmp -= step;
		times++;

		if (times % 200 == 0)
			yield();
	}

	memset(addr_s, c, tmp);

	return s;
}

void (*global_maint_func[])(void) =
{
	llc_flush_all,
	llc_clean_all,
	llc_inv_all,
};

void (*area_maint_func[])(phys_addr_t, size_t) =
{
	llc_flush_range,
	llc_clean_range,
	llc_inv_range,
};


/*
 * maintain���ԵĹ���������֧�ֶ����к����Ĳ���
 * llc_clean_all()/llc_inv_all()/llc_flush_all()
 * llc_clean_range()/llc_inv_range()/llc_flush_range()
 * ���Բ���Ϊ:
 * 1. ʹ��ioremap_cacheӳ��ָ���ڴ��
 * 2. ʹ��cacheӳ�䷽ʽ����ڴ�д���������
 * 3. ����ȫ��cache maintain����
 * 4. ʹ��nocacheӳ�䷽ʽ��ȡ���ݣ��Ƚ���д�����ݵ�һ����
 * 5. ����һ��passed������failed
 */
static void maint_test_func(int range, enum mnt_type type,
		phys_addr_t start,
		size_t size, const char *name)
{
	uchar rnd = 0;
	uchar *cache_mem, *nocache_mem;
	size_t map_size = size;
	int i;
	unsigned long cnt;

	llc_test_begin_name(name);
	if (size == 0)
		map_size = LLC_CACHE_LINE_SIZE;

	cache_mem = ioremap_cached_shared(start, map_size);
	if (!cache_mem)
		goto error;

	get_random_bytes(&rnd, 1);
	memset(cache_mem, rnd, map_size);

	//__flush_dcache_area(cache_mem, map_size);
	if (range == MNT_RANGE_GLOBAL)
		global_maint_func[type]();
	else
		area_maint_func[type](start, map_size);

	iounmap(cache_mem);

	ssleep(1);
	nocache_mem = ioremap_wc(start, map_size);
	if (!nocache_mem)
		goto error;

	cnt = 0;
	for (i = 0; i < map_size; i++)
		if (*(nocache_mem + i) != rnd)
			cnt++;
	if ((type != MNT_TYPE_INV) && cnt) {
		llc_info("cnt:%lu\n", cnt);
		llc_test_failed_name(name);
	} else {
		llc_test_passed_name(name);
	}

	iounmap(nocache_mem);
	goto out;

error:
	llc_test_init_failed_name(name);
out:
	llc_test_finish_name(name);
}

/* global clean */
void test_llc_001_001(void)
{
	maint_test_func(MNT_RANGE_GLOBAL, MNT_TYPE_CLEAN, SRC_ADDR, 0, __func__);
}

/* global invalid */
void test_llc_001_002(void)
{
	//	pr_info("wkf %s skip....\n", __func__);
	maint_test_func(MNT_RANGE_GLOBAL, MNT_TYPE_INV, SRC_ADDR, 0, __func__);
}

/* global flush */
void test_llc_001_003(void)
{
	maint_test_func(MNT_RANGE_GLOBAL, MNT_TYPE_FLUSH, SRC_ADDR, 0, __func__);
}

/* range clean, size == 0 */
void test_llc_001_004(void)
{
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_CLEAN, SRC_ADDR, SZ_2M, __func__);
}

/* range clean, size == 2K,4K,5K */
void test_llc_001_005(void)
{
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_CLEAN, SRC_ADDR, SZ_2K, __func__);
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_CLEAN, SRC_ADDR, SZ_4K, __func__);
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_CLEAN, SRC_ADDR, SZ_5K, __func__);
}

/* range invalid, size == 0 */
void test_llc_001_006(void)
{
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_INV, SRC_ADDR, 0, __func__);
}

/* range invalid, size == 2K,4K,5K */
void test_llc_001_007(void)
{
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_INV, SRC_ADDR, SZ_2K, __func__);
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_INV, SRC_ADDR, SZ_4K, __func__);
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_INV, SRC_ADDR, SZ_5K, __func__);
}

/* range flush, size == 0 */
void test_llc_001_008(void)
{
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_FLUSH, SRC_ADDR, 0, __func__);
}

/* range flush, size == 2K,4K,5K */
void test_llc_001_009(void)
{
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_FLUSH, SRC_ADDR, SZ_2K, __func__);
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_FLUSH, SRC_ADDR, SZ_4K, __func__);
	maint_test_func(MNT_RANGE_AREA, MNT_TYPE_FLUSH, SRC_ADDR, SZ_5K, __func__);
}

void test_llc_001_010(int n)
{
	uchar *cache_mem, *nocache_mem;
	size_t map_size = 128 * n;
	uchar *origdata;
	int i, j;

	llc_test_begin();
	cache_mem = ioremap_cached_shared(SRC_ADDR, map_size);
	nocache_mem = ioremap_wc(SRC_ADDR, map_size);
	origdata = ioremap_wc(DST_ADDR, map_size);
	if (!cache_mem || !nocache_mem || !origdata)
		goto error;

	mymemset(nocache_mem, 0xAC, map_size);
	memcpy(origdata, nocache_mem, map_size);

	memset(cache_mem, 0xB3, map_size);

	for (j = 0; j < n; j++) {
		for (i = 0; i < 128; i++) {
			if (nocache_mem[i + 128 * j] != 0xAC) {
				pr_info("%d/%d: 0x%x\n", j, i, nocache_mem[i + 128 * j]);
			}
		}
	}
	llc_flush_range(SRC_ADDR, 128 * (n - 1)); /* only clean the first 15 cachelines */

	if (memcmp(cache_mem, nocache_mem, 128 * (n - 1)) == 0 &&
			memcmp(origdata + 128 * (n - 1), nocache_mem + 128 * (n - 1), 128) == 0)
		llc_test_passed();
	else
		llc_test_failed();

	goto out;

error:
	llc_test_init_failed();
out:
	iounmap(cache_mem);
	iounmap(nocache_mem);
	iounmap(origdata);
	llc_test_finish();
}

static void test_suit_001_001(void)
{
	test_llc_001_001();
	test_llc_001_002();
	test_llc_001_003();
	test_llc_001_004();
	test_llc_001_005();
	test_llc_001_006();
	test_llc_001_007();
	test_llc_001_008();
	test_llc_001_009();
	test_llc_001_010(5);
}

static void (*test_func[][30])(void) =
{
	{test_llc_001_001, },
	{test_llc_001_002, },
	{test_llc_001_003, },
	{test_llc_001_004, },
	{test_llc_001_005, },
	{test_llc_001_006, },
	{test_llc_001_007, },
	{test_llc_001_008, },
	{test_llc_001_009, },
};

static int major = 0;
static int minor = 0;
static int run = 0;
struct proc_dir_entry *proc_llc_test_root = NULL;

static int proc_major_show(struct seq_file *m, void *v)
{
	seq_printf(m, "%d\n", major);
	return 0;
}

static int major_open(struct inode *inode, struct file *file)
{
	return single_open(file, proc_major_show, NULL);
}

static ssize_t major_write(struct file *file, const char __user *buf,
		size_t count, loff_t *offs)
{
	char str[20];

	if (!count || *offs)
		return -EINVAL;

	memset(str, 0, sizeof(str));
	if (copy_from_user(str, buf, count))
		return -EINVAL;

	str[count] = '\0';
	major = (int)simple_strtoul(str, NULL, 0);
	return count;
}

static const struct file_operations major_file_ops = {
	.open = major_open,
	.read = seq_read,
	.llseek = seq_lseek,
	.release = single_release,
	.write = major_write,
};

static int minor_show(struct seq_file *m, void *v)
{
	seq_printf(m, "%d\n", minor);
	return 0;
}

static int minor_open(struct inode *inode, struct file *file)
{
	return single_open(file, minor_show, NULL);
}

static ssize_t minor_write(struct file *file, const char __user *buf,
		size_t count, loff_t *offs)
{
	char str[20];

	if (!count || *offs)
		return -EINVAL;

	memset(str, 0, sizeof(str));
	if (copy_from_user(str, buf, count))
		return -EINVAL;

	str[count] = '\0';
	minor = (int)simple_strtoul(str, NULL, 0);
	return count;
}

static const struct file_operations minor_file_ops = {
	.open = minor_open,
	.read = seq_read,
	.llseek = seq_lseek,
	.release = single_release,
	.write = minor_write,
};

static int proc_run_show(struct seq_file *m, void *v)
{
	seq_printf(m, "%d\n", run);
	return 0;
}

static int run_open(struct inode *inode, struct file *file)
{
	return single_open(file, proc_run_show, NULL);
}

static ssize_t run_write(struct file *file, const char __user *buf,
		size_t count, loff_t *offs)
{
	int llc_result;
	char str[20];

	if (!count || *offs)
		return -EINVAL;

	memset(str, 0, sizeof(str));
	if (copy_from_user(str, buf, count))
		return -EINVAL;

	llc_passed = llc_failed = 0;

	str[count] = '\0';
	run = (int)simple_strtoul(str, NULL, 0);

	if (run == 5) {
		test_suit_001_001();
		goto out;
	}

	if (major < 1 || minor < 1)
		goto out;
	test_func[major-1][minor-1]();

out:
	llc_result = llc_passed + llc_failed;
	printk(KERN_INFO "LLC_TEST: Total %d TestCase: %d passed, %d failed.\n",
			llc_result, llc_passed, llc_failed);
	return count;
}

static const struct file_operations run_file_ops = {
	.open = run_open,
	.read = seq_read,
	.llseek = seq_lseek,
	.release = single_release,
	.write = run_write,
};

struct task_struct *hip08_reg_daemon;

static void llc_test_proc_init(void)
{
	if (!proc_llc_test_root)
		proc_llc_test_root = proc_mkdir("llc_test", NULL);
	if (!proc_llc_test_root)
		return;

	proc_create("major", 0644, proc_llc_test_root, &major_file_ops);
	proc_create("minor", 0644, proc_llc_test_root, &minor_file_ops);
	proc_create("run", 0644, proc_llc_test_root, &run_file_ops);
}

static void llc_test_proc_fini(void)
{
	if (proc_llc_test_root) {
		remove_proc_entry("major", proc_llc_test_root);
		remove_proc_entry("minor", proc_llc_test_root);
		remove_proc_entry("run", proc_llc_test_root);
		proc_remove(proc_llc_test_root);
	}
}


static int llc_driver_test_init(void)
{
	llc_info("===LLC driver test begin===\n");

	llc_test_proc_init();

	phys_start = SRC_ADDR;

	llc_info("src_addr: %p; dst_addr: %p\n", (void *)SRC_ADDR, (void *)DST_ADDR);

	return 0;
}

static void llc_driver_test_exit(void)
{
	llc_test_proc_fini();

	llc_info("===LLC driver test finish===\n");
	return;
}

module_init(llc_driver_test_init);
module_exit(llc_driver_test_exit);

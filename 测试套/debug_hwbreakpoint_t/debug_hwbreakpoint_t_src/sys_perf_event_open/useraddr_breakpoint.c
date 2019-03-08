#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdbool.h>
#include <memory.h>
#include <sys/mman.h>
#include <errno.h>
#include <asm/unistd.h>
#include <signal.h>
#include <sys/syscall.h>
#include <sys/poll.h>
#include <linux/perf_event.h>
#include <linux/hw_breakpoint.h>

#ifndef __NR_bpf
# if defined(__i386__)
#  define __NR_perf_event_open 336
# elif defined(__x86_64__)
#  define __NR_perf_event_open 298
# elif defined(__aarch64__)
#  define __NR_perf_event_open 241
# else
#  error __NR_perf_event_open not defined.
# endif
#endif

#define KSYM_NAME_LEN 128
#define KSYM_SYMBOL_LEN (sizeof("%s+%#lx/%#lx [%s]") + (KSYM_NAME_LEN - 1) + \
			 2*(BITS_PER_LONG*3/10) + (MODULE_NAME_LEN - 1) + 1)

#define info(fmt...)	do { fprintf(stderr, "INFO: " fmt); } while(0)
#define error(fmt...)	do { fprintf(stderr, "BUG: " fmt); exit(1); } while(0)
#define BUG_ON(c)	do {if (c) error(#c " at line %d\n", __LINE__);} while(0)

typedef uint64_t u64;
typedef uint16_t u16;

struct ip_callchain {
	u64 nr;
	u64 ips[0];
};

static inline bool overflow(const void *endp, u16 max_size, const void *offset,
			    u64 size)
{
	return size > max_size || offset + size > endp;
}

#define OVERFLOW_CHECK(offset, size, max_size)				\
	do {								\
		BUG_ON(overflow(endp, (max_size), (offset), (size)));	\
	} while (0)

#define OVERFLOW_CHECK_u64(offset) \
	OVERFLOW_CHECK(offset, sizeof(u64), sizeof(u64))


static int hex(char ch)
{
	if ((ch >= '0') && (ch <= '9'))
		return ch - '0';
	if ((ch >= 'a') && (ch <= 'f'))
		return ch - 'a' + 10;
	if ((ch >= 'A') && (ch <= 'F'))
		return ch - 'A' + 10;
	return -1;
}
/*
 * While we find nice hex chars, build a long_val.
 * Return number of chars processed.
 */
static int hex2u64(const char *ptr, u64 *long_val)
{
	const char *p = ptr;
	*long_val = 0;

	while (*p) {
		const int hex_val = hex(*p);

		if (hex_val < 0)
			break;

		*long_val = (*long_val << 4) | hex_val;
		p++;
	}

	return p - ptr;
}

static int kallsyms__parse(const char *filename, void *arg,
			   int (*process_symbol)(void *arg, const char *name,
				   		 char type, u64 start))
{
	char *line = NULL;
	size_t n;
	int err = -1;
	FILE *file = fopen(filename, "r");

	if (file == NULL)
		goto out_failure;

	err = 0;

	while (!feof(file)) {
		u64 start;
		int line_len, len;
		char symbol_type;
		char *symbol_name;

		line_len = getline(&line, &n, file);
		if (line_len < 0 || !line)
			break;

		line[--line_len] = '\0'; /* \n */

		len = hex2u64(line, &start);

		len++;
		if (len + 2 >= line_len)
			continue;

		symbol_type = line[len];
		len += 2;
		symbol_name = line + len;
		len = line_len - len;

		if (len >= KSYM_NAME_LEN) {
			err = -1;
			break;
		}

		err = process_symbol(arg, symbol_name, symbol_type, start);
		if (err)
			break;
	}

	free(line);
	fclose(file);
	return err;

out_failure:
	return -1;
}

static inline int
sys_perf_event_open(struct perf_event_attr *attr,
		pid_t pid, int cpu, int group_fd,
		unsigned long flags)
{
	int fd;

	fd = syscall(__NR_perf_event_open, attr, pid, cpu,
			group_fd, flags);
	return fd;
}

static u64 sample_kaddr = (u64)(-1);

static int find_symbol(void *sym, const char *name,
		char type, u64 start)
{
	if (strcmp(sym, name) == 0) {
		sample_kaddr = start;
		return 1;
	}
	return 0;
}

struct perf_mmap {
	void *base;
	int mask;
	u64 head;
	u64 old;
};

#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))

#if defined(__i386__)
/*
 * Some non-Intel clones support out of order store. wmb() ceases to be a
 * nop for these.
 */
#define mb()    asm volatile("lock; addl -bash,0(%%esp)" ::: "memory")
#define rmb()   asm volatile("lock; addl -bash,0(%%esp)" ::: "memory")
#define wmb()   asm volatile("lock; addl -bash,0(%%esp)" ::: "memory")
#elif defined(__x86_64__)
#define mb()    asm volatile("mfence":::"memory")
#define rmb()   asm volatile("lfence":::"memory")
#define wmb()   asm volatile("sfence" ::: "memory")
#elif defined(__aarch64__)
#define mb()    asm volatile("dmb ish" ::: "memory")
#define wmb()   asm volatile("dmb ishst" ::: "memory")
#define rmb()   asm volatile("dmb ishld" ::: "memory")
#endif



static inline u64 perf_mmap__read_head(struct perf_mmap *mm)
{
	struct perf_event_mmap_page *pc = mm->base;
	u64 head = ACCESS_ONCE(pc->data_head);
	rmb();
	return head;
}

static inline void perf_mmap__write_tail(struct perf_mmap *md, u64 tail)
{
	struct perf_event_mmap_page *pc = md->base;

	/*
	 * ensure all reads are done before we write the tail out.
	 */
	mb();
	pc->data_tail = tail;
}

struct search_for_symbol_data {
	u64 addr;
	char *symbol_buf;
	u64 found_symbol;
};

static int find_ksym(void *_data, const char *name, char type, u64 start)
{
	struct search_for_symbol_data *data = _data;

	if (start > data->addr)
		return 0;

	if ((data->found_symbol == (u64)-1) || (start > data->found_symbol)) {
		strcpy(data->symbol_buf, name);
		data->found_symbol = start;
	}
	return 0;
}

static void parse_sample(void *sample, int size)
{
	u64 *array = sample + sizeof(struct perf_event_header);
	const void *endp = (void *)sample + size;
	const u64 max_callchain_nr = UINT64_MAX / sizeof(u64);
	struct ip_callchain *callchain;
	int i, sz;

	printf("IP:\t%p\n", *array);
	array ++;
	printf("TID:\t%d\n", *array & 0xffffffff);
	array ++;
	printf("TIME:\t%lld\n", (unsigned long long)*array);
	array ++;
	printf("ADDR:\t%p\n", *array);
	array ++;

	OVERFLOW_CHECK_u64(array);
	callchain = (struct ip_callchain *)array++;
	BUG_ON(callchain->nr > max_callchain_nr);

	sz = callchain->nr * sizeof(u64);
	OVERFLOW_CHECK(array, sz, size);

	for (i = 0; i < callchain->nr; i++) {
		char symbol[4096] = "";

		struct search_for_symbol_data data = {
			.addr = callchain->ips[i],
			.symbol_buf = &symbol[0],
			.found_symbol = (u64)-1,
		};
		kallsyms__parse("/proc/kallsyms", &data, find_ksym);
		printf("CALLCHAIN LEVEL %d: %p (%s)\n", i, (void *)callchain->ips[i], symbol);
	}
}

static u64 parse_samples(struct perf_mmap *mm, u64 old, u64 head)
{
	void *data = mm->base + sysconf(_SC_PAGE_SIZE);

	struct perf_event_header *header = data + (old & mm->mask);
	if (old & mm->mask + sizeof(*header) > (mm->mask + 1)) {
		printf("Ring buffer rewind, TODO...\n");
		exit(1);
	}
	if ((old + header->size) & mm->mask < old & mm->mask) {
		printf("Ring buffer rewind, TODO...\n");
		exit(1);
	}

	info("Receive sample of type %d\n", header->type);
	if (header->type != PERF_RECORD_SAMPLE)
		return old + header->size;

	parse_sample(header, header->size);
	return old + header->size;
}

static void read_samples(struct perf_mmap *mm)
{
	void *control_page = mm->base;
	u64 head = perf_mmap__read_head(mm);
	u64 old = mm->old;

	info("%d bytes\n", head - old);

	if (old < head)
		old = parse_samples(mm, old, head);

	mm->old = head;
	perf_mmap__write_tail(mm, head);
}

int main()
{
	struct perf_event_attr attr;
	int nr_cpus = sysconf(_SC_NPROCESSORS_ONLN), i;
	int event_buf_data_size = 4 * sysconf(_SC_PAGE_SIZE);
	struct pollfd *pollfds;
	struct perf_mmap *mmaps;
	int flags = 1;

	BUG_ON(geteuid() != 0);


	kallsyms__parse("/proc/kallsyms", "linux_proc_banner", find_symbol);
	BUG_ON(sample_kaddr == (u64)(-1));
	BUG_ON(sample_kaddr == 0);

	sample_kaddr = 0x410944;
	info("sample_kaddr: %llx\n", (unsigned long long)sample_kaddr);

	memset(&attr, '\0', sizeof(attr));

	attr.type = PERF_TYPE_BREAKPOINT;
	attr.bp_type = HW_BREAKPOINT_RW;
	attr.bp_addr = sample_kaddr;
	attr.bp_len = 4;
	attr.size = sizeof(attr);
	attr.sample_period = 1;
	attr.sample_type = PERF_SAMPLE_IP | PERF_SAMPLE_TID | PERF_SAMPLE_TIME |
			   PERF_SAMPLE_ADDR | PERF_SAMPLE_CALLCHAIN;
	attr.disabled = 1;
	attr.inherit = 0;

	attr.watermark = 0;
	attr.wakeup_events = 1;

	pollfds = malloc(sizeof(pollfds[0]) * nr_cpus);
	BUG_ON(!pollfds);
	memset(pollfds, -1, sizeof(int) * nr_cpus);

	mmaps = calloc(sizeof(mmaps[0]), nr_cpus);
	BUG_ON(!mmaps);

	for (i = 0; i < nr_cpus; i++) {
		int fd = sys_perf_event_open(&attr, -1, i, -1, 0);
		perror("sys_perf_event_open");
		BUG_ON(fd < 0);

		mmaps[i].base = mmap(NULL, event_buf_data_size + sysconf(_SC_PAGE_SIZE),
				     PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
		BUG_ON(mmaps[i].base == MAP_FAILED);
		mmaps[i].mask = event_buf_data_size - 1;

		pollfds[i].fd = fd;
		info("pollfds[%d].fd = %d\n", i, fd);
		pollfds[i].events = POLLIN;
		pollfds[i].revents = 0;
	}

	for (i = 0; i < nr_cpus; i++)
		BUG_ON(ioctl(pollfds[i].fd, PERF_EVENT_IOC_ENABLE, 0));

	while (flags) {
//		info("start polling; try 'cat /proc/version' on another console\n");
		poll(pollfds, nr_cpus, -1);
		info("poll return\n");

		for (i = 0; i < nr_cpus; i++) {
			if (pollfds[i].revents & POLLIN) {
				int data[16];

				info("cpu %d triggered\n", pollfds[i].fd);
				read(pollfds[i].fd, data, sizeof(data));

				read_samples(&mmaps[i]);

				flags = 0;
			}
		}

	}

	return 0;
}

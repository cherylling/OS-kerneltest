PWD :=$(shell pwd)
obj-m := arm64_enable_all_nmi.o arm64_register_nmi_handler.o arm64_register_nmi_handler_timeout.o \
         arm64_register_nmi_overwrite.o disable_irq_x86.o jprobe_example.o kprobe_example.o \
         kretprobe_example.o trace_printk.o kprobe_nmi.o kprobe_my_nmi.o

all:
	$(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) -C $(KERNEL_DIR) M=$(PWD) modules
install:
	cp *.ko $(TOOL_BIN_DIR)
clean:
	$(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) -C $(KERNEL_DIR) M=$(PWD) clean

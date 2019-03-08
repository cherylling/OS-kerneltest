# Makefile

export sourcepath   ?= $(shell pwd)
export sourcefile   ?= $(notdir $(shell ls *.c))
export objs         := $(patsubst %.c,%.o,$(sourcefile))

ifeq ("$(ARCH)", "arm64")
        EXTRA_CFLAGS += -DCONFIG_ARM64=1
endif

obj-m := oops.o oops_oops.o panic.o panic_oops.o panic_panic.o ppi.o sgi.o kpgen_kbox.o timer_interrupt_panic_test.o interrupt_tasklet_panic.o kmalloc_kthread_oom.o
kpgen_kbox-objs := kpgenm.o

default:
	$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH)  M=$(sourcepath) modules

install:
	chmod 755 *.sh
	cp -avf *.ko *.sh $(TOOL_BIN_DIR)
clean:
	rm -rf *.o *.mod.c *.mod.o *.ko .*.mod .*.cmd .tmp_versions modules.order Module.symvers

# Makefile

export sourcepath   ?= $(shell pwd)
export sourcefile   ?= $(notdir $(shell ls *.c |grep -v kmemleak-page.c ))
export objs         := $(patsubst %.c,%.o,$(sourcefile))

ifneq ($(KERNELRELEASE),)
        obj-m += $(objs)
else
default:
	$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH)  M=$(sourcepath) modules
	$(CROSS_COMPILE)gcc kmemleak-page.c -o kmemleak-page
clean:
	rm -rf kmemleak-page  *.o *.mod.c *.mod.o *.ko .*.mod .*.cmd .tmp_versions modules.order Module.symvers
endif

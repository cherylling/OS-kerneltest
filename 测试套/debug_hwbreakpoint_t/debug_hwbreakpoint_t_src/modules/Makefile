# Makefile

export sourcepath   ?= $(shell pwd)
export sourcefile   ?= $(notdir $(shell ls *.c))
export objs         := $(patsubst %.c,%.o,$(sourcefile))

ifneq ($(KERNELRELEASE),)
        obj-m += $(objs)
else
default:
	$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH)  M=$(sourcepath) modules
clean:
	rm -rf *.o *.mod.c *.mod.o *.ko .*.mod .*.cmd .tmp_versions modules.order Module.symvers
install:
	cp -avf *.ko $(TOOL_BIN_DIR)

endif

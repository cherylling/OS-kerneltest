PWD :=$(shell pwd)
obj-m := llc_test.o

all:
	$(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) -C $(KERNEL_DIR) M=$(PWD) modules
install:
	cp *.ko $(TOOL_BIN_DIR)
clean:
	$(MAKE) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) -C $(KERNEL_DIR) M=$(PWD) clean

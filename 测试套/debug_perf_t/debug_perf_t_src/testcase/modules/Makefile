######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Author1:yy
##- @Date: 2013-04-19
##- @Description: Makefile for kernel modules
##- @What you can do:
#     1.This is just an example, you can compile your modules as
#       you like. So just modify me.
######################################################################

######################################################################
##- @Description:if you do not want to compile filter1.c filter2.c
#     then FILTER_OUT_MAKE_TARGETS=filter1.o filter2.o
######################################################################
#FILTER_OUT_MAKE_TARGETS=

#export these variables to make sure the Makefile can use them
export sourcepath   ?= $(shell pwd)
export sourcefile   ?= $(notdir $(wildcard *.c))
export allobjs      := $(patsubst %.c,%.o,$(sourcefile))
export objs         := $(filter-out $(FILTER_OUT_MAKE_TARGETS),$(allobjs))

include $(sourcepath)/../../mk/config.mk
include $(TOP_SRC)/mk/kernel.mk

ifneq ($(KERNELRELEASE),)
	obj-m += $(objs)
else
#	KERNELDIR ?= /lib/modules/$(shell uname -r)/build
default:
	$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) M=$(sourcepath) modules

install:
	cp -avf *.ko $(TOOL_MOD_DIR)
	#cp -avf *.sh $(TOOL_BIN_DIR)

clean:
	rm -f *.ko *.o *.o.d *.mod.c *.order .*.cmd .*.swp Module.*
	rm -rf .tmp*
endif

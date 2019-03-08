######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Author1:z00189503
##- @Date: 2016-11-01
##- @Description: compile the directories in testcase
##- @What you can do:
#     1.modify FILTER_OUT_DIRS to decide who will not be compiled
#     ######################################################################

#export these variables to make sure the Makefile can use them
export sourcepath   ?= $(shell pwd)
export sourcefile   ?= $(notdir $(wildcard *.c))
export objs      := $(patsubst %.c,%.o,$(sourcefile))

obj-m += $(objs)

include $(sourcepath)/../../mk/kernel.mk

default:
	$(MAKE) -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) M=$(sourcepath) modules

install:
	cp -avf *.ko $(TOOL_BIN_DIR)
	cp -avf *.sh $(TOOL_BIN_DIR)

clean:
	rm -f *.ko *.o *.o.d *.mod.c *.order .*.cmd .*.swp Module.*
	rm -rf .tmp*

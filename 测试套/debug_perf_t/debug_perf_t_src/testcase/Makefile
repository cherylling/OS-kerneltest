######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: Makefile
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: compile the directories in testcase
# @What you can do:
#     1.modify FILTER_OUT_DIRS to decide who will not be compiled
######################################################################

include ../mk/config.mk

list             = $(wildcard *)
FILTER_OUT_DIRS  = Makefile kmem sched
MODULEDIR       := $(filter-out $(FILTER_OUT_DIRS), $(list))

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

######################################################################
##- @Copyright (C), 1988-2016, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Date: 2015-12-23
##- @Description: compile the directories in testcase
##- @What you can do:
#     1.modify FILTER_OUT_DIRS to decide who will not be compiled
######################################################################

include ../mk/config.mk

list             = $(wildcard *)
FILTER_OUT_DIRS  = Makefile user_prg 
MODULEDIR       := $(filter-out $(FILTER_OUT_DIRS), $(list))

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

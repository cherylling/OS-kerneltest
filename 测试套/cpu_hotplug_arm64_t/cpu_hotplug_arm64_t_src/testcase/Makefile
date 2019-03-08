######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Author1:l00176790
##- @Date: 2013-05-14
##- @Description: compile the directories in testcase
##- @What you can do:
#     1.modify FILTER_OUT_DIRS to decide who will not be compiled
######################################################################

#include ../mk/config.mk

#list             = $(wildcard *)
#FILTER_OUT_DIRS  = Makefile others opt
#MODULEDIR       := $(filter-out $(FILTER_OUT_DIRS), $(list))
MODULEDIR:= functional include tools

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: Makefile
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: compile the directories in src
# @What you can do:
#     1.modify install, make more directories if you need
######################################################################

include ./mk/config.mk

MODULEDIR=lib testcase

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	mkdir -p $(TOOL_BIN_DIR)
	mkdir -p $(TOOL_CFG_DIR)
	mkdir -p $(TOOL_MOD_DIR)
	mkdir -p $(TOOL_LIB_DIR)
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

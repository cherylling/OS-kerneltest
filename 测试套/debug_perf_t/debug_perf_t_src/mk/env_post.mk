######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: env_post.mk
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: set some parameters for Makefile
#      1.the parameter "src" get all the c source file(*.c)
#      2.the parameter FILTER_OUT_MAKE_TARGETS will be set in Makefile 
#      3.the parameter MAKE_TARGETS can be used in Makefile, so that
#        the Makefile can compile all the c source file except
#        the targets set in FILTER_OUT_MAKE_TARGETS
# @What you can do:
#     1.suggest: you can keep this file without modification
######################################################################

src              = $(notdir $(wildcard *.c))
objs            := $(patsubst %.c,%.o,$(src))
targets         := $(patsubst %.c,%,$(src))
MAKE_TARGETS    := $(filter-out $(FILTER_OUT_MAKE_TARGETS),$(targets))
INSTALL_FILES    = $(MAKE_TARGETS) $(INSTALL_TARGETS)
CLEAN_FILES      = $(MAKE_TARGETS) $(CLEAN_TARGETS)

CFLAGS          ?= -g -O2 -Wall

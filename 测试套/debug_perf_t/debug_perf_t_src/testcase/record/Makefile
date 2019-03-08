######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: Makefile
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: compile and install the testcases
# @What you can do:
#     1.modify INSTALL_TARGETS to decide which file to install to
#       TOOL_BIN_DIR in additional.
#     2.modify FILTER_OUT_MAKE_TARGETS to decide which c sourcefile
#       will not be compiled
#     3.modify CFLAGS, default : -g -O2 -Wall
#     4.modify CPPFLAGS to decide which directories with headfiles
#     5.modify LDFLAGS to decide which directories with libraries
#     6.modify LDLIBS to decide which libraries will be used
######################################################################

FILTER_OUT_MAKE_TARGETS=

INSTALL_TARGETS=*.sh
#CLEAN_TARGETS=

#CFLAGS         = 
#CPPFLAGS       = -I
#LDFLAGS        = -L
#LDLIBS         = -lpthread

include ../../mk/config.mk
include $(TOP_SRC)/mk/env_post.mk

all:$(MAKE_TARGETS)

#this Makefile will compile files like this, you can write your own Makefile
include $(TOP_SRC)/mk/Makefile

install:
	cp -avf $(INSTALL_FILES) $(TOOL_BIN_DIR)

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

INSTALL_TARGETS=*.sh $(HUGE_MAKE_TARGETS)
INSTALL_CONFIGS=*.cfg
CLEAN_TARGETS=$(HUGE_MAKE_TARGETS)

CFLAGS         = -g -Wall
#CPPFLAGS       = -I
#LDFLAGS        = -L
LDLIBS         = -lpthread

include ../../mk/config.mk
include $(TOP_SRC)/mk/env_post.mk

HUGE_MAKE_TARGETS=$(addprefix huge_,$(MAKE_TARGETS))
all:$(MAKE_TARGETS) $(HUGE_MAKE_TARGETS)

#this Makefile will compile files like this, you can write your own Makefile
include $(TOP_SRC)/mk/Makefile

$(HUGE_MAKE_TARGETS):huge_%:%.c
	$(CC) $(CFLAGS) -Wl,--script=$(TOP_SRC)/lib/ldscripts/$(ARCH)/2M.lds $(CPPFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@
install:
	cp -avf $(INSTALL_CONFIGS) $(TOOL_CFG_DIR)
	cp -avf $(INSTALL_FILES) $(TOOL_BIN_DIR)

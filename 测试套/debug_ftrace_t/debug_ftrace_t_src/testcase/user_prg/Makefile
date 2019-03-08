######################################################################
##- @Copyright (C), 1988-2016, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Date: 2015-12-23
##- @Description: compile and install the testcases
##- @What you can do:
#     1.modify INSTALL_TARGETS to decide which file to install to
#       TOOL_BIN_DIR in additional.
#     2.modify FILTER_OUT_MAKE_TARGETS to decide which c sourcefile
#       will not be compiled
#     3.modify CFLAGS, default : -g -O2 -Wall
#     4.modify CPPFLAGS to decide which directories with headfiles
#     5.modify LDFLAGS to decide which directories with libraries
#     6.modify LDLIBS to decide which libraries will be used
######################################################################

######################################################################
##- @Description:if you do not want to compile filter1.c filter2.c
#     then FILTER_OUT_MAKE_TARGETS=filter1 filter2
######################################################################
FILTER_OUT_MAKE_TARGETS=

#INSTALL_TARGETS= *.sh
#CLEAN_TARGETS  =

#CFLAGS         = 
#CPPFLAGS       = -I
#LDFLAGS        = -L
#LDLIBS         = -lpthread

include ../../mk/config.mk
include $(TOP_SRC)/mk/env_post.mk

all:$(MAKE_TARGETS)

######################################################################
##- @Description:you can write your own Makefile
#     this Makefile will:
#     1:compile : "a.c" to a, except FILTER_OUT_MAKE_TARGETS
#     2:install : a and INSTALL_TARGETS to TOOL_BIN_DIR, then do install INSTALL_MORE
#     3:clean   : a and CLEAN_TARGETS
######################################################################
include $(TOP_SRC)/mk/Makefile

install:
	cp -avf $(INSTALL_FILES) $(TOOL_BIN_DIR)

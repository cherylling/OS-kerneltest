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

FILTER_OUT_MAKE_TARGETS=libcommon_while_lib

CLEAN_TARGETS=*.a *.so *.o $(ALL_S) $(ALL_D)

CPPFLAGS      += -I.
LDFLAGS       += -L.
CFLAGS         = -g -Wall
LDLIBS         = -lcommon_while_lib

include ../../mk/config.mk
include $(TOP_SRC)/mk/env_post.mk

MAKE_TARGETS_S=$(addsuffix _s,$(MAKE_TARGETS))
MAKE_TARGETS_D=$(addsuffix _d,$(MAKE_TARGETS))
HUGE_S=$(addprefix huge_,$(MAKE_TARGETS_S))
HUGE_D=$(addprefix huge_,$(MAKE_TARGETS_D))
ALL_S=$(MAKE_TARGETS_S) $(HUGE_S)
ALL_D=$(MAKE_TARGETS_D) $(HUGE_D)

INSTALL_TARGETS=*.sh $(ALL_S) $(ALL_D)
#INSTALL_TARGETS=*.sh $(MAKE_TARGETS_S) $(MAKE_TARGETS_D) 

#to make sure *_s use libcommon_while_lib.a, *_s should before *_d
all:$(ALL_S) $(ALL_D)
#all:$(MAKE_TARGETS_S) $(MAKE_TARGETS_D) 

libcommon_while_lib.a:libcommon_while_lib.c
	$(CC) $(CFLAGS) -c $< -o $@.o
	$(AR) -rc $@ $@.o
libcommon_while_lib.so:libcommon_while_lib.c
	$(CC) $(CFLAGS) -o $@ $< -fPIC -shared

$(MAKE_TARGETS_S):%_s:%.c libcommon_while_lib.a
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@ 
$(MAKE_TARGETS_D):%_d:%.c libcommon_while_lib.so
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@ 

#for cetaidtlb make
$(HUGE_S):huge_%_s:%.c libcommon_while_lib.a
	$(CC) -g -Wall -Wl,--script=$(TOP_SRC)/lib/ldscripts/$(ARCH)/2M.lds $(CPPFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@
$(HUGE_D):huge_%_d:%.c libcommon_while_lib.so
	$(CC) -g -Wall -Wl,--script=$(TOP_SRC)/lib/ldscripts/$(ARCH)/2M.lds $(CPPFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

install:
	cp -avf $(INSTALL_TARGETS) $(TOOL_BIN_DIR)
	cp -avf *.so $(TOOL_LIB_DIR)
clean:
	rm -f $(CLEAN_FILES)

######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Author1:z00189503
##- @Date: 2014-03-29
##- @Description:
#     This Makefile is an example, and it can compile most
#     c source files
##- @What you can do:
#     1.if you don't want to use this Makefile, you can write your
#       own Makefile
#     2.suggest: keep the parameter MAKE_TARGETS in your Makefile
#       plz. it's usefull
######################################################################

CPPFLAGS        += -I$(TOP_SRC)/include
LDFLAGS         += -L$(TOP_SRC)/lib

$(MAKE_TARGETS):%:%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@

clean:
	rm -f $(CLEAN_FILES)

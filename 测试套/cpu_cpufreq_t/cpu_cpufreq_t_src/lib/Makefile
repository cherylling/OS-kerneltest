######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: Makefile
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-17
# @Description: compile the libraries in lib
# @What you can do:
#     1.include the file config.mk, and do include other files
#       via $(TOP_SRC), plz
#     2.write your functions in this directory, and this Makefile
#       will compile them to libxx_test.a, so that you can use your
#       functions like -llibxx_test
######################################################################

include ../mk/config.mk
include $(TOP_SRC)/mk/env_post.mk

CPPFLAGS = -I$(TOP_SRC)/include

all:$(objs) libxx_test

$(objs):%.o:%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@
libxx_test:$(objs)
	$(AR) -rc "$@".a $^
install:
	 
clean:
	rm -f *.o *.so

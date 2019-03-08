######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: Makefile
# @Author1:star<yexinxin@huawei.com> ID:00197803
# @Date: 2013-04-16
# @Description: compile the libraries in lib
# @What you can do:
#     1.include the file config.mk, and do include other files
#       via $(TOP_SRC), plz
#     2.write your functions in this directory, and this Makefile
#       will compile them to libopt_perf_t_test.a, so that you can use your
#       functions like -llibopt_perf_t_test
######################################################################

include ../mk/config.mk
include $(TOP_SRC)/mk/env_post.mk

dynamic_objs=
static_objs=$(filter-out $(dynamic_objs),$(objs))
dynamic_lib=
static_lib=libopt_perf_t_test

CPPFLAGS = -I$(TOP_SRC)/include

all:$(static_objs) $(dynamic_objs) $(static_lib) $(dynamic_lib)

$(static_objs):%.o:%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@
$(dynamic_objs):%.o:%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -fPIC -c $< -o $@
libopt_perf_t_test:$(static_objs)
	$(AR) -rc "$@".a $^
#libaa_test:$(dynamic_objs)
#	$(CC) -o "$@".so -shared $^
install:
	 
clean:
	rm -f *.o *.so *.a

######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.  
##- @File name: config.mk
##- @What you can do: 
#     1.If you want to install some files to other directories
#       (not TOOL_BIN_DIR), plz add a parameter here via modifying configure,
#       then use it in your Makefile. Like TOOL_MOD_DIR
#     2.If you want to add any other parameters which depends on the
#       tool-chain, plz get the value via configure and add them here,
#       then use them in your Makefile. Like AR
#     3.If you want to add some parameters that already have values,
#       plz add them to env_post.mk. Like CFLAGS
######################################################################
TOP_SRC         := /home/anio/code/ftrace/hulk_ftrace_t/hulk_ftrace_t_src
TOOL_BIN_DIR    := /home/anio/code/ftrace/hulk_ftrace_t/hulk_ftrace_t/testcase/bin
CC              := arm-euler-linux-gnueabi-gcc
AR              := arm-euler-linux-gnueabi-ar
#directory to install kos
#TOOL_MOD_DIR    := /home/anio/code/ftrace/hulk_ftrace_t/hulk_ftrace_t/testcase/bin/../modules
#TOOL_LIB_DIR    := /home/anio/code/ftrace/hulk_ftrace_t/hulk_ftrace_t/testcase/bin/../lib

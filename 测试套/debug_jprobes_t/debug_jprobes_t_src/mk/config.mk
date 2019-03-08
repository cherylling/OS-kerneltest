######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: config.mk
# @What you can do: 
#     1.If you want to install some files to other directories
#       (not TOOL_BIN_DIR), plz add a parameter here via modifying configure,
#       then use it in your Makefile. Like TOOL_MOD_DIR
#     2.If you want to add any other parameters which depends on the
#       tool-chain, plz get the value via configure and add them here,
#       then use them in your Makefile. Like AR
#     3.If you want to add some parameters that already have values,
#       plz add them to env_post.mk. Like CFLAGS
######################################################################
TOP_SRC         := /home/sky/kprobes_t/kprobes_t_src
TOOL_BIN_DIR    := /home/sky/kprobes_t/kprobes_t/testcase/bin
TOOL_LIB_DIR    := /home/sky/kprobes_t/kprobes_t/testcase/bin/../lib
CC              := armeb-linux-gnueabi-gcc
AR              := armeb-linux-gnueabi-ar
MMAPFLAG        := 
#directory to install kos
#TOOL_MOD_DIR    := /home/sky/kprobes_t/kprobes_t/testcase/bin/../modules

######################################################################
# @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.  
# @File name: kernel.mk
# @What you can do: 
#     1.These parameters are used in Makefile to make modules.
#       You can add anyother parameters if you need....
######################################################################
KERNEL_DIR      := /home/RATS/src/interface/V1R6C00SPC200B030_SD5856-PTN90X_POOL_NORM/sdk/opt/RTOS/V100R006C00/arm64le_4.1_ek_preempt/sdk/usr/src/modules_obj
ARCH            := arm64
CROSS_COMPILE   := aarch64-linux-gnu-
CC:= aarch64-linux-gnu-gcc
AR:= aarch64-linux-gnu-ar

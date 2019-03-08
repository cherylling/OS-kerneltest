#!/bin/bash
#######################################################################
##- @Copyright (C), 1988-2013, Huawei Tech. Co., Ltd.
##- @Suitename: debug_gdbshell_h
##- @Name: gdbshell_v1r2c00_1-RTSDZ-10_tc014
##- @Author: l00191161
##- @Date: 2013-10-17
##- @Precon: 支持gdbshell
##- @Brief: 单进程下不同状态子线程调试
##- @Detail: 1，启动单进程，Z状态。
#            2，gdbshell rtat该进程，info thread应该得到2个线程信息
#            3，rtint 非gdbshell线程infier id后，该线程进入T状态（整个PID下所有线程均为T）。
#            4，rtbt获取调用栈信息是否正确，rtbt后进程状态是否还原
#            5，rtint 非gdbshell线程infier id，rtir获取寄存器信息是否正确，rtir后进程状态是否还原
#            6，重复2-5 10次
#            7，对每个线程执2-6
#            8，退出
##- @Expect: rtat仅一次多出一个工作线程，原进程状态不变。 rtint后进程状态为T，rtbt获取调用栈信息、rtir获取寄存器信息正确，过程进程、线程状态不变。程序退出无异常
##- @Level: Level 3
##- @Auto: True
##- @Modify:
#######################################################################*/
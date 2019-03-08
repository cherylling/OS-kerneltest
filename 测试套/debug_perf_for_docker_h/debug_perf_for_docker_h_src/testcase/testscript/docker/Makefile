######################################################################
##- @Copyright (C), 1988-2014, Huawei Tech. Co., Ltd.  
##- @File name: Makefile
##- @Author1:z00189503
##- @Date: 2015-06-13
##- @Description: compile the directories in testcase
##- @What you can do:
######################################################################

CUR_DIR  := ${shell pwd}
LAST_DIR := ${shell basename ${CUR_DIR}}

default:
	@echo no need to compile

install:
	mkdir -p $(TOOL_BIN_DIR)/../testscript/${LAST_DIR}
	cp *.sh $(TOOL_BIN_DIR)/../testscript/${LAST_DIR}

clean:
	@echo no need to clean
	

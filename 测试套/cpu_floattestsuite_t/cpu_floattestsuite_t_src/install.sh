#!/bin/bash

FLOAT_DIR=/opt/floattestsuite
TESTCASE_DIR=/opt/floattestsuite/testcase
TOOL_BIN_DIR=/opt/floattestsuite/testcase/bin/

if [ -d "$FLOAT_DIR" ];then
	rm -rf $FLOAT_DIR
fi    
mkdir $FLOAT_DIR
mkdir $TESTCASE_DIR
mkdir $TOOL_BIN_DIR

cp -avf conf/    $TESTCASE_DIR
#cp -avf conf/  $TOOL_BIN_DIR/..

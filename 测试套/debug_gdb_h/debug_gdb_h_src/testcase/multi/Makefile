#include ../../conf/env.cfg
targets     	:= $(shell ls *.c | sed 's/\.c//g')
LIBFLAGS 	:=  -lpthread
INCLUDEDIR 	:= 
SHAREDFLAG 	:= 
CC:=$(CROSS_COMPILE)gcc
CFLAGS=-g -o

All:
	for i in $(targets); do $(CC) $(CFLAGS) $$i $$i.c $(INCLUDEDIR) $(LIBFLAGS); done

install:
	mkdir -p $(TOOL_BIN_DIR)/multi/
	cp -avf * $(TOOL_BIN_DIR)/multi/

clean:
	for i in $(targets); do rm -fr $$i; done

include ../../conf/env.cfg
#CC=gcc

cur		:= $(shell pwd)
subdir  := $(shell basename $(cur))
headers := 

APPENDLDFLAG := 
targets     := ${shell ls *.c | sed -e 's/\.c//g' -e '/^__/d'}

MODULEDIR=
All:
	for i in $(targets); do $(CC) $(CFLAGS) $(APPENDLDFLAG) -o $$i $$i.c; done
				
install:
	for i in $(targets); do cp -avf $$i $(TOOL_BIN_DIR); done
	cp -avf oprofile_fifo_process_01.sh $(TOOL_BIN_DIR)
	cp -avf oprofile_rr_process_01.sh $(TOOL_BIN_DIR)
	cp -avf oprofile_other_process_01.sh $(TOOL_BIN_DIR)

clean:
	for i in $(targets); do rm -fr $$i; done

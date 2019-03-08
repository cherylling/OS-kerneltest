#include ../../conf/env.cfg
targets     	:= $(shell ls *.c | sed 's/\.c//g' |grep -v "sep-proc"|grep -v "dfp-test" | grep -v "pie-execl"|grep -v "gcore-buffer-overflow"|grep -v "chng-syms")
LIBFLAGS 	:= 
INCLUDEDIR 	:= 
SHAREDFLAG 	:= 
CC:=$(CROSS_COMPILE)gcc
CFLAGS=-g -o

All:
	for i in $(targets); do $(CC) $(CFLAGS) $$i $$i.c $(INCLUDEDIR) $(LIBFLAGS); done
	$(CC) -g -o pie-execl1 pie-execl.c -fPIE -pie -DBIN=1
	$(CC) -g -o pie-execl2 pie-execl.c -fPIE -pie -DBIN=2
	$(CC) -g -o annota1-watch-non-mem watch-non-mem.c
	$(CC) -g -o chng-syms1 chng-syms.c -DVARIABLE=var1
	$(CC) -g -o chng-syms2 chng-syms.c -DVARIABLE=var2
	$(CC) -g -o gcore-buffer-overflow-01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 gcore-buffer-overflow.c
####################ycc
	$(CC) -g -o fullname1 $(PWD)/base_test/fullname_subdir/fullname_ssdir/tmp-fullname.c
	$(CC) -g -o fullname2 fullname_subdir/fullname_ssdir/tmp-fullname.c
	$(CC) -g -o fullname_subdir/fullname_ssdir/fullname fullname_subdir/fullname_ssdir/tmp-fullname.c

install:
	mkdir -p $(TOOL_BIN_DIR)/base_test/
	cp -avf * $(TOOL_BIN_DIR)/base_test/

clean:
	for i in $(targets); do rm -fr $$i; done
	rm -rf chng-syms chng-syms2  chng-syms1 gcore-buffer-overflow-01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 annota1-watch-non-mem pie-execl1 pie-execl2 
	#fullname1 fullname2 fullname_subdir/fullname_ssdir/fullname 

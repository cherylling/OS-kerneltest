
ifeq ($(CROSS_COMPILER_SDK), armA15be_2.6.34)
MMAPFLAG:=-DMMAP_64
endif

ifeq ($(CROSS_COMPILER_SDK), arm32A15be_4.1_ek)
MMAPFLAG:=-DMMAP_64
endif
CCFLAGS:=-O2 -Wall
targets     := ${shell ls *.c | sed 's/\.c//g'}

default:
	for i in $(targets); do $(CROSS_COMPILE)gcc -g -o $$i $$i.c $(MMAPFLAG); done

install:
	mkdir -p $(TOOL_BIN_DIR)/long_point/
	cp -avf * $(TOOL_BIN_DIR)/long_point/

clean:
	for i in $(targets); do rm -fr $$i; done
	rm -rf gdb.txt compile_txtx


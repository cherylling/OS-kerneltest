CC := $(CROSS_COMPILE)gcc

targets         := ${shell ls *.c | sed 's/\.c//g'}
all:
	for i in $(targets); do $(CC)  -o $$i $$i.c -lpthread; done
install:
	        for i in $(targets); do cp -avf unit $$i $(TOOL_BIN_DIR); done

clean:
	        for i in $(targets); do rm -fr $$i;done 

include ../../conf/env.cfg

targets := ${shell ls *.c | sed 's/\.c//g'}

all:
	for i in $(targets); do $(CC) $(CFLAGS) -o $$i $$i.c; done
install:
	cp -avf *.sh $(targets) $(TOOL_BIN_DIR) 
clean:
	for i in $(targets); do rm -rf $(targets); done

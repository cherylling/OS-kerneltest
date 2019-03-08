include ../conf/env.cfg 

targets=hackbench e-strlen

all:tooldir
tooldir:
	for i in $(targets); do $(CC) $(CFLAGS) -o $$i $$i.c -lpthread; done
install:
	cp -avf *.sh $(TOOL_BIN_DIR)
	cp -avf $(targets) $(TOOL_BIN_DIR)
clean:
	-rm -f $(targets)

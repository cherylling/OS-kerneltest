
targets     := ${shell ls *.c | sed 's/\.c//g'}
default:
	for i in $(targets); do $(CROSS_COMPILE)gcc -g -o $$i $$i.c -lpthread -lgdbhook; done
	$(CROSS_COMPILE)gcc -g -o process_Rt process_R.c 
	$(CROSS_COMPILE)gcc -g -o process_Tt process_T.c 

install:
	mkdir -p $(TOOL_BIN_DIR)/gdbshell
	cp -avf * $(TOOL_BIN_DIR)/gdbshell/

clean:
	for i in $(targets); do rm -fr $$i; done
	rm -rf process_Rt process_Tt

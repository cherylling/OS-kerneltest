include env.cfg

targets		:= ${shell ls *.c | sed 's/\.c//g'}

All:
	@echo $(MMAPFLAG)
	cp -avf conf.bak.exp conf.exp
	sed -i "s/XXXX/$(PRODUCT_NAME)/g" conf.exp
	sed -i "s/VVVV/$(DEF_VERSION)/g" conf.exp
	for i in $(targets); do $(CROSS_COMPILE)gcc -g -o $$i $$i.c $(MMAPFLAG); done
		
install:
	mkdir -p $(TOOL_BIN_DIR)/cetartlb
	cp -avf * $(TOOL_BIN_DIR)/cetartlb/

clean:
	for i in $(targets); do rm -fr $$i; done




MODULEDIR=base base_test cp modula2 multi threads cetartlb long_point

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done
	cp -avf lib/ $(TOOL_BIN_DIR)/
	cp -avf *.sh  $(TOOL_BIN_DIR)/
	
clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done
	

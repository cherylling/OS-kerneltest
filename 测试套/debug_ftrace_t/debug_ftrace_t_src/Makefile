include ./mk/config.mk

MODULEDIR=lib testcase

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	mkdir -p $(TOOL_BIN_DIR)
#	mkdir -p $(TOOL_LIB_DIR)
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

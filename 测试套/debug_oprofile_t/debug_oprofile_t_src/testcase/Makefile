MODULEDIR=oparchive  opcontrol  ophelp  opimport  opjitconv  opreport

all:tooldir
tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done
install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done
	cp -avf conf $(TOOL_BIN_DIR)/../
clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

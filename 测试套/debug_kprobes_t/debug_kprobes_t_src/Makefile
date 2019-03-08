MODULEDIR=testcase

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	mkdir -p $(TOOL_BIN_DIR)
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done



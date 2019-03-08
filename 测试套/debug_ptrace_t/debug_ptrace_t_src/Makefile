include conf/env.cfg

MODULEDIR=testcase
all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done
	
clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

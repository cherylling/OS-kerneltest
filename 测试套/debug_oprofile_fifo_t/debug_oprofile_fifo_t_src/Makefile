include ./conf/env.cfg
MODULEDIR=testsuit

all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	chmod u+x ./install.sh
	./install.sh
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done
	
clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

exec:
	for n in $(MODULEDIR); do $(MAKE) -C $$n exec; done

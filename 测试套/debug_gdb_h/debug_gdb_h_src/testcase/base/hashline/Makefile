


SSMODULEDIR=hashline_sub

all:tooldir

tooldir:
	for n in $(SSMODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(SSMODULEDIR); do $(MAKE) -C $$n install; done
	
clean:
	for n in $(SSMODULEDIR); do $(MAKE) -C $$n clean; done
	

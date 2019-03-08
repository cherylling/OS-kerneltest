list             = $(wildcard *)
FILTER_OUT_DIRS  = Makefile
MODULEDIR       := $(filter-out $(FILTER_OUT_DIRS), $(list))

all:tooldir

tooldir:
	        for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	        for n in $(MODULEDIR); do $(MAKE) -C $$n install; done

clean:
	        for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done
			


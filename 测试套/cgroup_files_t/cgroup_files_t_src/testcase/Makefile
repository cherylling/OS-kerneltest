list            = $(wildcard *)
FILTER_OUT_DIRS = Makefile
MODULEDIR      := $(filter-out $(FILTER_OUT_DIRS), $(list))

default:
	for dir in $(MODULEDIR); do $(MAKE) -C $$dir; done

install:
	for dir in $(MODULEDIR); do $(MAKE) -C $$dir install; done

clean:
	for dir in $(MODULEDIR); do $(MAKE) -C $$dir clean; done

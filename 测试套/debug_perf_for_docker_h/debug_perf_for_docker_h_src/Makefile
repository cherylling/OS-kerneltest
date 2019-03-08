include conf/env.cfg
SUB_DIRS := testcase conf results 

default:
	for n in $(SUB_DIRS) ; do $(MAKE) -C $$n ; done 

install:
	for n in $(SUB_DIRS) ; do $(MAKE) -C $$n install; done

clean:
	for n in $(SUB_DIRS) ; do $(MAKE) -C $$n clean; done

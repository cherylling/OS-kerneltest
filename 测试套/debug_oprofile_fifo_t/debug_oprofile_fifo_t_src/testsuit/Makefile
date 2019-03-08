# Makefile for testcase
# Author:Star
# Date:2011/09/29

include ../conf/env.cfg

ifeq ($(CROSS_COMPILE),ppcp4080-dl-linux-gnu-)
MODULEDIR=${shell ls | egrep -v "Makefile|pciconfig_iobase|pciconfig_read|pciconfig_write|delete_module|delete_module_ko|get_thread_area|lchown32|vserver"   }
else
ifeq ($(CROSS_COMPILE),armeb-linux-gnueabi-)
MODULEDIR=${shell ls | egrep -v "Makefile|pciconfig_iobase|pciconfig_read|pciconfig_write|delete_module|delete_module_ko|get_thread_area"   }
else
MODULEDIR=${shell ls | egrep -v "Makefile|pciconfig_iobase|pciconfig_read|pciconfig_write|delete_module|delete_module_ko"   }
endif
endif
all:tooldir

tooldir:
	for n in $(MODULEDIR); do $(MAKE) -C $$n; done

install:
	for n in $(MODULEDIR); do $(MAKE) -C $$n install; done
	
clean:
	for n in $(MODULEDIR); do $(MAKE) -C $$n clean; done

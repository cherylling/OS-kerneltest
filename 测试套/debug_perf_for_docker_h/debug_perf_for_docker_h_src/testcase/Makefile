CC=${CROSS_COMPILER_NAME}gcc
platform:=x86

#SUB_DIRS := bin testscript rtos_feature
SUB_DIRS := bin testscript

ifeq ($(platform), $(findstring $(platform), $(CC)))
	SUB_DIRS+=edf
endif

default:
	for n in $(SUB_DIRS) ; do $(MAKE) -C $$n ; done 

install:
	for n in $(SUB_DIRS) ; do $(MAKE) -C $$n install; done

clean:
	for n in $(SUB_DIRS) ; do $(MAKE) -C $$n clean; done

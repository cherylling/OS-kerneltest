# Makefile

export sourcepath   ?= $(shell pwd)
export sourcefile   ?= $(notdir $(shell ls *.patch))

default:
	cp -r $(KERNEL_DIR) /tmp/kernel.test
	for i in $(sourcefile); \
	do \
		kpatch-build -s /tmp/kernel.test $(sourcefile); \
	done
clean:
	rm -rf *.ko /tmp/kernel.test
#endif

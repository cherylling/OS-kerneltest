include ../conf/env.cfg

	fpxregs :=

ifeq ($(ARCH), arm)
	targets := $(shell ls | grep '\.c' | grep -v "x86" | grep -v "fpxreg" | grep -v "sysemu" | grep -v "set_thread_area" | grep -v "get_thread_area.c" | grep -v "get_thread_area_0[1-4]" | sed -e 's/\.c//g')

else
ifeq ($(ARCH), powerpc)
	targets := $(shell ls | grep '\.c'  | grep -v "x86" | grep -v "arm" | grep -v "set_syscall" | grep -v "thread_area" | grep -v "wmmxregs"| grep -v "crunch" | grep -v "sysemu" | grep -v "vfpregs" | grep -v "fpxregs" | grep -v "hbpregs" | sed -e 's/\.c//g')
else
ifeq ($(ARCH), arm64)
        targets := $(shell ls | grep '\.c' | grep -v "x86" |grep -v "arm"| grep -v "fpregs"|grep -v "vfpregs" |grep -v "wmmxregs"|grep -v "crunch"| grep -v "sysemu" | grep -v "set_thread_area" | grep -v "get_thread_area" | grep -v "fpxregs" | grep -v "set_syscall" | grep -v "hbpreg" |grep -v "evrregs" | sed -e 's/\.c//g')
else
	targets := $(shell ls | grep '\.c' | grep -v "arm" | grep -v "vfpregs" | grep -v "set_syscall" | grep -v "fpxreg" | grep -v "wmmxregs" | grep -v "hbpreg" | grep -v "crunch" | grep -v "get_thread_area_0[5-7]" | sed -e 's/\.c//g')
	fpxregs := $(shell ls | grep '\.c' | grep "fpxreg" | sed -e 's/\.c//g')
endif
endif
endif

All:
	if [ -f $(CROSS_COMPILER_DIR)/sdk/$(CROSS_COMPILER_SDK)/usr/include/asm/hw_breakpoint.h ];then cat $(CROSS_COMPILER_DIR)/sdk/$(CROSS_COMPILER_SDK)/usr/include/asm/hw_breakpoint.h | grep "#define ARM_MAX"> hw_breakpoint.h; echo "cat file"; fi
	for i in $(targets); do $(CC) $(CFLAGS)  -o $$i $$i.c ; done
	for i in $(fpxregs); do $(CC) $(CFLAGS) -m32 -o $$i $$i.c; done
install:
	for i in $(targets); do cp -avf $$i $(TOOL_BIN_DIR); done
	for i in $(fpxregs); do cp -avf $$i $(TOOL_BIN_DIR); done
	cp -avf *.sh $(TOOL_BIN_DIR)
clean:
	for i in $(targets); do rm -fr $$i; done
	for i in $(fpxregs); do rm -rf $$i; done
	rm -rf hw_breakpoint.h

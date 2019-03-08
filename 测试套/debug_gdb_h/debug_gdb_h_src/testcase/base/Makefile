#include ../../conf/env.cfg
INCLUDEDIR 	:= 
SHAREDFLAG 	:= 
CC:=$(CROSS_COMPILE)gcc
CXX:=$(CROSS_COMPILE)g++
CFLAGS=-g -o

SMODULEDIR=hashline
All:
	$(CC) -g -o whatis-exp int-type.c
	
	$(CC) -g -fpic -c watchpoint-solib-shr.c
	$(CC) -g -shared -o watchpoint-solib-shr.so watchpoint-solib-shr.o
	$(CC) -g -o watchpoint-solib watchpoint-solib.c -ldl
	
	$(CC) -g -c watchpoint-cond-gone-stripped.c
	$(CC) -g -o watchpoint-cond-gone watchpoint-cond-gone.c watchpoint-cond-gone-stripped.o
	
	$(CC) -g -o watch_thread_num watch_thread_num.c -pthread
	
	$(CC) -g -o volatile constvars.c 
	
	$(CC) -g -o until break.c break1.c
	
	$(CC) -g -fpic -c  unloadshr.c
	$(CC) -g -fpic -c  unloadshr2.c
	$(CC) -g -shared -o unloadshr.so unloadshr.o
	$(CC) -g -shared -o unloadshr2.so unloadshr2.o
	$(CC) -g -o unload unload.c -DSHLIB_NAME=\"unloadshr.so\" -DSHLIB_NAME2=\"unloadshr2.so\" -ldl
	
	$(CC) -g -o ui-redirect start.c
	
	$(CC) -g -fpic -c type-opaque-lib.c
	$(CC) -g -shared -o type-opaque-lib.so type-opaque-lib.o
	$(CC) -g -o type-opaque-main type-opaque-main.c type-opaque-lib.so
	
	$(CC) -g -o tui-layout start.c
	
	$(CC) -g -o term run.c
	
	$(CC) -g -c symbol-without-target_section.c
	$(CC) -g -o symbol-without-target_section start.c symbol-without-target_section.o
	
	$(CC) -g -shared -fpic -o weaklib1-dbg.sl weaklib1.c
	$(CC) -g -shared -fpic -o weaklib2-dbg.sl weaklib2.c
	$(CC) -shared -fpic -o weaklib1.sl weaklib1.c
	$(CC) -shared -fpic -o weaklib2.sl weaklib2.c
	$(CC) -g -o solib-weak12 solib-weak.c weaklib1.sl weaklib2.sl
	$(CC) -g -o solib-weak21 solib-weak.c weaklib2.sl weaklib1.sl
	$(CC) -g -o solib-weak-dbg1-2 solib-weak.c weaklib1-dbg.sl   weaklib2.sl
	$(CC) -g -o solib-weak-2-dbg1 solib-weak.c weaklib2.sl weaklib1-dbg.sl
	$(CC) -g -o solib-weak-dbg1-dbg2 solib-weak.c weaklib1-dbg.sl weaklib2-dbg.sl
	$(CC) -g -o solib-weak-dbg2-dbg1 solib-weak.c weaklib2-dbg.sl weaklib1-dbg.sl
	$(CC) -g -o solib-weak-dbg2-1 solib-weak.c weaklib2-dbg.sl weaklib1.sl
	$(CC) -g -o solib-weak-1-dbg2 solib-weak.c weaklib1.sl weaklib2-dbg.sl
	
	$(CC) -g -shared -fpic -o solib-symbol-lib.so solib-symbol-lib.c
	$(CC) -g -o solib-symbol-main solib-symbol-main.c solib-symbol-lib.so
	
	$(CC) -g -shared -fpic -o solib-overlap-lib1-0x40000000.so solib-overlap-lib.c
	$(CC) -g -shared -fpic -o solib-overlap-lib2-0x40000000.so solib-overlap-lib.c
	$(CC) -g -o solib-overlap-main-0x40000000 solib-overlap-main.c solib-overlap-lib1-0x40000000.so solib-overlap-lib2-0x40000000.so
	
	$(CC) -g -o solib-nodir.o -c start.c
	$(CC) -g -shared -fpic -o solib-nodir.so foo.c 
	$(CC) -g -o solib-nodir solib-nodir.o 
	$(CROSS_COMPILE)strip --strip-debug solib-nodir.so -o  solib-nodir.so.stripped 
	$(CROSS_COMPILE)strip --only-keep-debug solib-nodir.so -o  solib-nodir.so.debug 
	
	$(CC) -g -o int-type int-type.c
	$(CC) -g -o a2-run run.c
	
	$(CC) -g -o all-types all-types.c
	
	$(CC) -g -o bang args.c
	
	
	$(CC) -g -o break break.c break1.c
	$(CC) -g -O2 -o breako2 break.c break1.c
	
	$(CXX) -g -o break-on-linker-gcd-function break-on-linker-gcd-function.cc
	
	$(CC) -g -o call-signals call-signals.c
	
	$(CC) -g -o charset charset.c charset-malloc.c
	
	$(CC) -g -o cvexpr cvexpr.c
	
	$(CC) -g -ffunction-sections -fdata-sections -Wl,-gc-sections -Wl,-e,main -o code_elim2 code_elim2.c 
	$(CC) -g -ffunction-sections -fdata-sections -Wl,-gc-sections -Wl,-e,main -o code_elim1 code_elim1.c 
	
	$(CC) -g -o commands run.c -DFAKEARGV
	
	$(CC) -g -o break0.o -c break.c
	$(CC) -g -o break1.o -c break1.c
	$(CC) -g -o completion break0.o break1.o
	
	$(CC) -g -o cond-expr int-type.c
	
	$(CC) -g -o condbreak break0.o break1.o
	
	$(CC) -g -o coremaker coremaker.c
	
	$(CC) -g -c average.c
	$(CC) -g -c sum.c
	$(CC) -g -o dbx-test average.o sum.o
	
	$(CC) -g -o define break0.o break1.o
	
	$(CC) -g -o attach attach.c
	
	$(CC) -g -o disasm-end-cu disasm-end-cu-1.c disasm-end-cu-2.c
	
	$(CC) -g -o disp-step-vfork disp-step-vfork.c
	$(CC) -g -o disp-step-fork disp-step-fork.c
	
	$(CC) -c dmsym.c 
	$(CC) -g -c dmsym_main.c 
	$(CC) -g -o dmsym_main dmsym_main.o dmsym.o
	
	$(CC) -g -o dup-sect dup-sect.S start.c 
	
	$(CROSS_COMPILE)objcopy --rename-section sect2=sect1 dup-sect output 
	$(CROSS_COMPILE)strip --strip-debug dup-sect output
	
	$(CC) -g -o ena-dis-br break0.o break1.o
	
	$(CC) -g -o environ break0.o break1.o
	
	$(CC) -g -o exe-lock arrayidx.c
	
	$(CC) -g -c expand-psymtabs.c -DFIRST -o expand-psymtabs_1.o
	$(CC) -g -c expand-psymtabs.c -o expand-psymtabs_2.o 
	$(CC) -g -o expand-psymtabs expand-psymtabs_1.o expand-psymtabs_2.o
	
	$(CC) -g -o finish return2.c
	
	$(CC) -g -shared -fpic -o fixsectshr.sl fixsectshr.c
	$(CC) -g -o fixsection fixsection.c fixsectshr.sl
	
	$(CC) -g -shared -fpic -o gdb1555.so gdb1555.c
	$(CC) -g -o gdb1555-main gdb1555-main.c gdb1555.so
ifneq ($(ARCH), arm64)
	$(CC) -g -gstabs -c gdbindex-stabs.c
	$(CC) -g -gdwarf-2 -c gdbindex-stabs-dwarf.c
	$(CC) -o gdbindex-stabs gdbindex-stabs.o gdbindex-stabs-dwarf.o
endif
	$(CC) -g -o hashline1 hashline1.c -lgcc_eh -lc
	
	$(CC) -g -o hashline3 hashline/hashline_sub/hashline3.c -lgcc_eh -lc
	
	$(CC) -g -o info-proc break0.o break1.o
	
	$(CC) -g -o info-target start.c
	
	$(CC) -g -o jit-dlmain jit-dlmain.c -ldl
	$(CC) -g -shared -fpic -o jit-main.so jit-main.c -DMAIN=jit_dl_main
	$(CC) -shared -fpic -o jit-solib.so jit-solib.c
	$(CC) -shared -fpic -o jit-solib1.so jit-solib.c
	$(CC) -g -o jit-main jit-main.c
	$(CC) -g -c langs0.c
	$(CC) -g -c langs1.c
	$(CC) -g -c langs2.c
	$(CC) -g -o langs langs0.o langs1.o langs2.o
	$(CC) -g -o linespecs memattr.c
	$(CC) -g -o logical int-type.c 
	$(CC) -g -c list0.c
	$(CC) -g -c list1.c
	$(CC) -g -o list list0.o list1.o
	$(CC) -g -o macscp.o -c macscp1.c -DFROM_COMMANDLINE=ARG
	$(CC) -g -o macscp macscp.o -DFROM_COMMANDLINE=ARG
	$(CC) -g -o maint break0.o break1.o
	$(CC) -g -o moribund-step start.c 
	$(CC) -g -o nostdlib nostdlib.c -nostdlib -lgcc_eh -lc
	$(CC) -g -c opaque0.c
	$(CC) -g -c opaque1.c
	$(CC) -g -o opaque opaque0.o opaque1.o -lgcc_eh -lc
	$(CC) -g -c ovlymgr.c
	$(CC) -g -c foo.c
	$(CC) -g -c ovlymgr.c
	$(CC) -g -c bar.c
	$(CC) -g -c baz.c
	$(CC) -g -c grbx.c
#	$(CC) -g -o overlays overlays.o ovlymgr.o foo.o bar.o baz.o grbx.o -Wl,-Tspu.ld
	$(CC) -g -shared -fpic -o pendshr.sl pendshr.c
	$(CC) -g -o pending pending.c pendshr.sl -lgcc_eh -lc
	$(CC) -g -o pr10179 pr10179-a.c pr10179-b.c -lgcc_eh -lc
	$(CC) -g -c psymtab1.c
	$(CC) -g -c psymtab2.c
	$(CC) -g -o psymtab psymtab1.o psymtab2.o -lgcc_eh -lc
	$(CC) -g -c ptype.c -o ptype0.o
	$(CC) -g -c ptype1.c -o ptype1.o
	$(CC) -g -o ptype ptype0.o ptype1.o
	$(CC) -g -o relational int-type.c -lgcc_eh -lc
	$(CC) -g -c relocate.c -o relocate.o -lgcc_eh -lc
	$(CC) -g -o reread1.exe reread1.c
	$(CC) -g -o reread2.exe reread2.c -DNO_SECTIONS
	$(CC) -g -o return-nodebug-signed-char0.o -c return-nodebug.c -DTTYPE=singed_char
	$(CC) -o return-nodebug-signed-char1.o -c return-nodebug1.c -DTTYPE=signed_char
	$(CC) -g -o return-nodebug-signed-char return-nodebug-signed-char0.o return-nodebug-signed-char1.o -lgcc_eh -lc
	$(CC) -g -o return-nodebug-short0.o -c return-nodebug.c -DTTYPE=short
	$(CC) -o return-nodebug-short1.o -c return-nodebug1.c -DTTYPE=short
	$(CC) -g -o return-nodebug-short return-nodebug-short0.o return-nodebug-short1.o
	$(CC) -g -o return-nodebug-int0.o -c return-nodebug.c -DTTYPE=int
	$(CC) -o return-nodebug-int1.o -c return-nodebug1.c -DTTYPE=int
	$(CC) -g -o return-nodebug-int return-nodebug-int0.o return-nodebug-int1.o
	$(CC) -g -o return-nodebug-long0.o -c return-nodebug.c -DTTYPE=long
	$(CC) -o return-nodebug-long1.o -c return-nodebug1.c -DTTYPE=long
	$(CC) -g -o return-nodebug-long return-nodebug-long0.o return-nodebug-long1.o
	$(CC) -g -o return-nodebug-long-long0.o -c return-nodebug.c -DTTYPE=long_long
	$(CC) -o return-nodebug-long-long1.o -c return-nodebug1.c -DTTYPE=long_long
	$(CC) -g -o return-nodebug-long-long return-nodebug-long-long0.o return-nodebug-long-long1.o
	$(CC) -g -c scope0.c
	$(CC) -g -c scope1.c
	$(CC) -g -o scope scope0.o scope1.o -lgcc_eh -lc
	$(CC) -g -o sect-cmd break0.o break1.o
	$(CC) -g -o set-lang-auto start.c 
	$(CC) -g -shared -fpic -o shr1.sl -c shr1.c
	$(CC) -g -shared -fpic -o shr2.sl -c shr2.c
	$(CC) -g -o shmain shmain.c  shr1.sl  shr2.sl -lgcc_eh -lc
	$(CC) -g -shared -fpic -o shreloc1.sl -c shreloc1.c
	$(CC) -g -shared -fpic -o shreloc2.sl -c shreloc2.c
	$(CC) -g -o shreloc shreloc.c shreloc1.sl shreloc2.sl
	$(CC) -g skip-solib-lib.c -shared -fPIC -o libskip-solib.so
	$(CC) -g -o skip-solib-test.o -c skip-solib-main.c 
	$(CC) -g -o skip-solib-test skip-solib-test.o -L. -lskip-solib -lgcc_eh -lc
	$(CC) -g -o skip skip.c skip1.c -lgcc_eh -lc
	$(CC) -g -shared -fpic -o solib1.sl solib1.c
	$(CC) -g -o so-impl-ld so-impl-ld.c solib1.sl -lgcc_eh -lc
	$(CC) -g -fpic -c solib1.c -o solib1-cl.o
	$(CC) -g -shared -o solib1-cl.sl solib1-cl.o
	$(CC) -g -o so-indr-cl so-indr-cl.c solib1-cl.sl
	$(CC) -g -o solib-corrupted start.c 
	$(CC) -shared -fpic -o solib-display-lib-NO.so solib-display-lib.c
	$(CC) -g -o solib-display-main-NO solib-display-main.c solib-display-lib-NO.so -lgcc_eh -lc
	$(CC) -shared -fpic -o solib-display-lib-DNO_B_GLOBAL-NO.so solib-display-lib.c -DNO_B_GLOBAL
	$(CC) -g -shared -fpic -o solib-display-lib-IN.so solib-display-lib.c
	$(CC) -g -o solib-display-main-IN solib-display-main.c solib-display-lib-IN.so -lgcc_eh -lc
	$(CC) -g -shared -fpic -o solib-display-lib-DNO_B_GLOBAL-IN.so solib-display-lib.c -DNO_B_GLOBAL
	$(CC) -g -shared -fpic -o solib-display-lib-SEP.so solib-display-lib.c
	$(CC) -g -o solib-display-main-SEP solib-display-main.c solib-display-lib-SEP.so -lgcc_eh -lc
	$(CROSS_COMPILE)strip --strip-debug solib-display-main-SEP -o SEP.strip
	$(CC) -g -shared -fpic -o solib-display-lib-DNO_B_GLOBAL-SEP.so solib-display-lib.c -DNO_B_GLOBAL
	$(CROSS_COMPILE)strip --strip-debug solib-display-main-SEP -o DNO_B_GLOBAL-SEP.strip
	$(CC) -g -o permission start.c -lgcc_eh -lc
	$(CC) -g -o structs-tc structs.c -DtA=tc -lgcc_eh -lc
	$(CC) -g -o structs-ts structs.c -DtA=ts -lgcc_eh -lc
	$(CC) -g -o structs-ti structs.c -DtA=ti -lgcc_eh -lc
	$(CC) -g -o structs-tl structs.c -DtA=tl -lgcc_eh -lc
	$(CC) -g -o structs-tll structs.c -DtA=tll -lgcc_eh -lc
	$(CC) -g -o structs-tf structs.c -DtA=tf -lgcc_eh -lc
	$(CC) -g -o structs-td structs.c -DtA=td -lgcc_eh -lc
	$(CC) -g -o structs-tld structs.c -DtA=tld -lgcc_eh -lc
	$(CC) -g -o structs-ts-tc structs.c -DtA=ts -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-ti-tc structs.c -DtA=ti -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-tl-tc structs.c -DtA=tl -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-tll-tc structs.c -DtA=tll -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-tf-tc structs.c -DtA=tf -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-td-tc structs.c -DtA=td -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-tld-tc structs.c -DtA=tld -DtB=tc -lgcc_eh -lc
	$(CC) -g -o structs-tc-ts structs.c -DtA=tc -DtB=ts -lgcc_eh -lc
	$(CC) -g -o structs-tc-ti structs.c -DtA=tc -DtB=ti -lgcc_eh -lc
	$(CC) -g -o structs-tc-tl structs.c -DtA=tc -DtB=tl -lgcc_eh -lc
	$(CC) -g -o structs-tc-tll structs.c -DtA=tc -DtB=tll -lgcc_eh -lc
	$(CC) -g -o structs-tc-tf structs.c -DtA=tc -DtB=tf -lgcc_eh -lc
	$(CC) -g -o structs-tc-td structs.c -DtA=tc -DtB=td -lgcc_eh -lc
	$(CC) -g -o structs-tc-tld structs.c -DtA=tc -DtB=tld -lgcc_eh -lc
	$(CC) -g -o structs-td-tf structs.c -DtA=td -DtB=tf -lgcc_eh -lc
	$(CC) -g -o structs-tf-td structs.c -DtA=tf -DtB=td -lgcc_eh -lc
	$(CC) -g -o call-sc-tc call-sc.c  -DT=tc -lgcc_eh -lc
	$(CC) -g -o call-sc-td call-sc.c  -DT=td -lgcc_eh -lc
	$(CC) -g -o call-sc-te call-sc.c  -DT=te -lgcc_eh -lc
	$(CC) -g -o call-sc-tf call-sc.c  -DT=tf -lgcc_eh -lc
	$(CC) -g -o call-sc-ti call-sc.c  -DT=ti -lgcc_eh -lc
	$(CC) -g -o call-sc-tl call-sc.c  -DT=tl -lgcc_eh -lc
	$(CC) -g -o call-sc-tld call-sc.c  -DT=tld -lgcc_eh -lc
	$(CC) -g -o call-sc-tll call-sc.c  -DT=tll -lgcc_eh -lc
	$(CC) -g -o call-sc-ts call-sc.c  -DT=ts -lgcc_eh -lc
	$(CC) -g -o miscexprs miscexprs.c -DSTORAGE=static -lgcc_eh -lc
	$(CC) -g -o eval-skip int-type.c -lgcc_eh -lc
	$(CC) -g -O2 -o break-inline break-inline.c -lgcc_eh -lc
	$(CC) -g -o inferior-died inferior-died.c -lgcc_eh -lc
	for n in $(SMODULEDIR); do $(MAKE) -C $$n; done
#	$(CC) -g -o break-entry start.c -static
ifeq ($(ARCH),x86)   
	$(CC) -shared -fpic -o gnu-ifunc-lib.so gnu-ifunc-lib.c
	$(CC) -g -o gnu-ifunc gnu-ifunc.c gnu-ifunc-lib.so
endif

install:
	mkdir -p $(TOOL_BIN_DIR)/base/
	cp -avf * $(TOOL_BIN_DIR)/base/

clean:
	rm -rf *.o *.so *.sl whatis-exp watchpoint-solib watchpoint-cond-gone tui-layout type-opaque-main unload ui-redirect until volatile watch_thread_num  term  symbol-without-target_section solib-weak12 solib-weak21 solib-weak-dbg1-2 solib-weak-2-dbg1 solib-weak-dbg1-dbg2 solib-weak-dbg2-dbg1 solib-weak-dbg2-1 solib-weak-1-dbg2 solib-overlap-main-0x40000000  solib-nodir.so.stripped solib-nodir.so.debug int-type all-types bang break breako2 break-on-linker-gcd-function  call-signals   charset cvexpr code_elim1 code_elim2  commands completion cond-expr condbreak coremaker  dbx-test define  attach disasm-end-cu disp-step-vfork disp-step-fork dmsym_main dup-sect output ena-dis-br environ exe-lock expand-psymtabs finish fixsection gdb1555-main gdbindex-stabs gnu-ifunc hashline1 hashline3 info-proc info-target jit-dlmain jit-main langs linespecs  logical list macscp maint moribund-step nostdlib opaque overlays pending pr10179 psymtab ptype relational reread1.exe reread2.exe return-nodebug-signed-char return-nodebug-long-long return-nodebug-long return-nodebug-int return-nodebug-short scope sect-cmd set-lang-auto shmain shreloc skip-solib-test skip so-impl-ld so-indr-cl solib-corrupted *.strip solib-display-main-IN solib-display-main-NO  solib-display-main-SEP a2-run permission solib-nodir  solib-symbol-main structs-tc structs-tc-ts structs-tc-ti structs-tc-tl structs-tc-tll structs-tc-tf structs-tc-td structs-tc-tld  structs-td-tf structs-tf-td  structs-ts-tc structs-ti-tc structs-tl-tc structs-tll-tc structs-tf-tc structs-td-tc structs-tld-tc  structs-tld structs-td structs-tf  structs-tll structs-tl structs-ti  structs-ts call-sc-tc call-sc-td call-sc-te call-sc-tf call-sc-ti call-sc-tl call-sc-tld call-sc-tll call-sc-ts miscexprs eval-skip break-inline inferior-died
#	break-entry
	for n in $(SMODULEDIR); do $(MAKE) -C $$n clean; done 

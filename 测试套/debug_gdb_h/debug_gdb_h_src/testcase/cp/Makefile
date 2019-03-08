targets    	:= $(shell ls *.cc | sed 's/\.cc//g' |grep -v "call-c" |grep -v "cttiadd" |grep -v "expand-psymtabs-cxx" |grep -v "gdb2384" |grep -v "hang"|grep -v "infcall-dlopen" |grep -v "m-static"|grep -v "mb-inline"|grep -v "minsym-fallback"|grep -v "namespace-enum" |grep -v "namespace" |grep -v "no-dmgl-verbose"|grep -v "ovsrch"|grep -v "pr10728"|grep -v "psmang"|grep -v "psymtab-parameter" |grep -v "re-set-overloaded"|grep -v "rtti"|grep -v "static-print-quit" |grep -v "cp-relocate")
CC:=$(CROSS_COMPILE)gcc
CXX:=$(CROSS_COMPILE)g++
CFLAGS=-g -o

All:
	for i in $(targets); do $(CXX) $(CFLAGS) $$i $$i.cc ; done
	$(CC) -g -c call-c-1.c 
	$(CXX) -g -c call-c.cc
	$(CXX) -g -o call-c call-c-1.o call-c.o
	$(CXX) -g -c cttiadd.cc
	$(CXX) -g -c cttiadd1.cc
	$(CXX) -g -c cttiadd2.cc
	$(CXX) -g -c cttiadd3.cc
	$(CXX) -g -o cttiadd cttiadd.o cttiadd1.o cttiadd2.o cttiadd3.o
	$(CXX) -g -o expand-psymtabs-cxx.x -c expand-psymtabs-cxx.cc
	$(CXX) -g -fpic -c  gdb2384-base.cc
	$(CXX) -g -shared -o gdb2384-base.so gdb2384-base.o
	$(CXX) -g -o gdb2384 gdb2384.cc gdb2384-base.so
	$(CXX) -g -c hang1.cc
	$(CXX) -g -c hang2.cc
	$(CXX) -g -c hang3.cc
	$(CXX) -g -o hang hang1.o hang2.o hang3.o
	$(CXX) -g -fpic -c infcall-dlopen-lib.cc
	$(CXX) -g -shared -o infcall-dlopen.so infcall-dlopen-lib.o
	$(CXX) -g -o infcall-dlopen infcall-dlopen.cc infcall-dlopen.so -ldl
	$(CXX) -g -c m-static.cc
	$(CXX) -g -c m-static1.cc
	$(CXX) -g -o m-static m-static.o m-static1.o 
	$(CXX) -g -c mb-inline1.cc
	$(CXX) -g -c mb-inline2.cc
	$(CXX) -g -o mb-inline mb-inline1.o mb-inline2.o
	$(CXX) -g -c minsym-fallback.cc
	$(CXX) -g -c minsym-fallback-main.cc
	$(CXX) -g -o minsym-fallback minsym-fallback.o minsym-fallback-main.o
	$(CXX) -g -c namespace-enum.cc
	$(CXX) -g -c namespace-enum-main.cc
	$(CXX) -g -o namespace-enum namespace-enum.o namespace-enum-main.o
	$(CXX) -g -c namespace.cc
	$(CXX) -g -c namespace1.cc
	$(CXX) -g -o namespace namespace.o namespace1.o 
	$(CXX) -g -c no-dmgl-verbose.cc
	$(CXX) -g -o ovsrch ovsrch1.cc ovsrch2.cc ovsrch3.cc ovsrch4.cc
	$(CXX) -g -c pr10728-x.cc
	$(CXX) -g -c pr10728-y.cc
	$(CXX) -g -o pr10728 pr10728-x.o pr10728-y.o
	$(CXX) -g -c psmang1.cc
	$(CXX) -g -c psmang2.cc
	$(CXX) -g -o psmang psmang1.o psmang2.o
	$(CXX) -g -o psymtab-parameter.x -c psymtab-parameter.cc
	$(CXX) -g -fpic -c  re-set-overloaded.cc
	$(CXX) -g -shared -o re-set-overloaded.so re-set-overloaded.o
	$(CXX) -g -o re-set-overloaded bool.cc re-set-overloaded.so
	$(CXX) -g -c rtti1.cc
	$(CXX) -g -c rtti2.cc
	$(CXX) -g -o rtti rtti1.o rtti2.o
	$(CXX) -g -c static-print-quit.cc
	$(CXX) -g -c cp-relocate.cc
	$(CXX) -g -o namespace-nested-import namespace-nested-import.cc
 	
install:
	mkdir -p $(TOOL_BIN_DIR)/cp/
	cp -avf * $(TOOL_BIN_DIR)/cp/

clean:
	for i in $(targets); do rm -fr $$i; done
	rm *.o *.so *.x hang gdb2384 cttiadd call-c hang infcall-dlopen m-static mb-inline minsym-fallback namespace-enum  namespace psmang  pr10728 ovsrch re-set-overloaded  rtti namespace-nested-import -rf

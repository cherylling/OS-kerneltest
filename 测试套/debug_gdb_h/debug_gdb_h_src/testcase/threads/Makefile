#include ../../conf/env.cfg
targets     	:= $(shell ls *.c |grep -v "tls-shared.c" |grep -v "watchthreads.c" |grep -v "staticthreads.c" |grep -v "hand-call-in-threads.c" |grep -v "interrupted-hand-call.c" |grep -v "tls.c"|grep -v "tls-main.c" |grep -v "tls-var-main.c"|grep -v "tls2.c"|grep -v "step.c" |grep -v "watchthreads2.c" | grep -v "watchpoint-fork-child.c" |grep -v "watchpoint-fork-mt.c" |grep -v "watchpoint-fork-parent.c" |grep -v "watchpoint-fork-st.c" | grep -v "tls-var.c" |sed 's/\.c//g')
LIBFLAGS 	:= -lpthread -lrt
INCLUDEDIR 	:= 
SHAREDFLAG 	:= 
CC:=$(CROSS_COMPILE)gcc
CXX:=$(CROSS_COMPILE)g++
CFLAGS=-g -o

All:
	for i in $(targets); do $(CC) $(CFLAGS) $$i $$i.c $(INCLUDEDIR) $(LIBFLAGS); done
	$(CXX) -g -o tls tls.c tls2.c -lpthread -D_MIT_POSIX_THREADS
	$(CC) -g -o attach-into-signal-threads_nothr attach-into-signal.c $(LIBFLAGS)
	$(CC) -g -o attach-into-signal-threads_thr attach-into-signal.c -DUSE_THREADS $(LIBFLAGS)
	$(CC) -g -o attach-stopped2 attach-stopped.c -DUSE_THREADS $(LIBFLAGS)
	$(CC) -g -o gcore-thread pthreads.c  -lpthread
	$(CC) -g -o watchthreads2 watchthreads2.c -DNR_THREADS=4 -DX_INCR_COUNT=10 -pthread
	$(CC) -g -o watchthreads watchthreads.c -pthread
	$(CC) -g -c pthreads.c -pthread
	mv pthreads.o gcore-thread.o
	$(CC) -g -o hand-call-in-threads hand-call-in-threads.c -DNR_THREADS=4 $(LIBFLAGS)
	$(CC) -g -o interrupted-hand-call interrupted-hand-call.c -DNR_THREADS=4 $(LIBFLAGS)
	$(CC) -g -o pending-step pending-step.c  -pthread
	$(CC) -g -c tls-var.c -pthread
	$(CC) -g -c tls-var-main.c  -pthread
	$(CC) -g -o tls-var tls-var.o tls-var-main.o -pthread
	$(CC) -g -fpic -c tls-shared.c -pthread
	$(CC) -g -shared -o tls-main.so tls-shared.o -pthread
	$(CC) -g -o tls-main tls-main.c tls-main.so -pthread
	$(CC) -g -o corethreads corethreads.c -pthread
#	$(CC) -g -o mul_thread mul_thread.c -pthread
#	$(CC) -g -o staticthreads staticthreads.c -pthread -static
   
install:
	mkdir -p $(TOOL_BIN_DIR)/threads/
	cp -avf * $(TOOL_BIN_DIR)/threads/

clean:
	for i in $(targets); do rm -fr $$i; done
	rm tls gcore-thread tls-main.so tls-main *.o pending-step staticthreads tls-var hand-call-in-threads interrupted-hand-call watchthreads watchthreads2 attach-into-signal-threads  attach-stopped2  -rf

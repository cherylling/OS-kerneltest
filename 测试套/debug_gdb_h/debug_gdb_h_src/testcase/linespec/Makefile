
CC:=$(CROSS_COMPILE)gcc
CXX:=$(CROSS_COMPILE)g++
CFLAGS=-g -o

All:
	$(CXX) -g -o lspec lspec.cc base/one/thefile.cc base/two/thefile.cc
 	
install:
	mkdir -p $(TOOL_BIN_DIR)/linespec/
	cp -avf * $(TOOL_BIN_DIR)/linespec/

clean:
	rm lspec -rf

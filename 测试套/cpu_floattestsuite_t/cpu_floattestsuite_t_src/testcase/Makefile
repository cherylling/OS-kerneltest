
#gcc -g -o udp udp.c ../../lib/main.c ../../lib/random_int.c ../../lib/options.c -I ../../include
CC=$(CROSS_COMPILE)gcc
#CC=armeb-linux-gnueabi-gcc
#CFLAGS=-o2 -o

ARM_FLAG=${shell echo $(CROSS_COMPILE)|awk -F - '{print $$1}'}
ARM__FLAG=${shell echo $(CROSS_COMPILE)|awk -F _ '{print $$1}'}

ifeq ($(ARM_FLAG),armeb)
CFLAGS= -mfpu=vfp -mfloat-abi=softfp -o 
else
CFLAGS= -o 
endif

ifeq ($(findstring armA9le,$(CROSS_COMPILER_SDK)),armA9le)
CFLAGS= -mfpu=vfp -mfloat-abi=softfp -o
endif

ifeq ($(PRODUCT_NAME),SD5568-MXU)
CFLAGS= -mfpu=vfp -mfloat-abi=softfp -o
endif

#-fno-builtin

TARGET=floattest
SOURCE=floattest.c float_lib.c
INCLUDEDIR=
#INSTALLDIR=/opt/floattestsuite/testcase/bin/

OBJECTS=$(SOURCE:.c=.o)

$TARGET:$(OBJECTS)
	$(CC) $(M32) $(CFLAGS) $(TARGET) $(OBJECTS)  -lm -std=c99

$(OBJECTS):%.o:%.c
	$(CC) $(M32) -c $< $(CFLAGS) $@ 


install:
	echo $(ARM_FLAG)
	cp -avf $(TARGET) $(TOOL_BIN_DIR)
clean:
	rm -rf $(TARGET) *.o	


CC=gcc

TARGET=gpscap

OBJS = $(TARGET).o
OBJS += toolutil.o
OBJS += gpsutils.o
OBJS += mbgdevio.o

CFLAGS = -Wall
CFLAGS += -O2
CFLAGS += -c

LD_FLAGS=-o

#INCLUDE_DIR = -I../../Driver/Linux/mbgtools-lx-dev-2011-12-19/mbglib/common
#INCLUDE_DIR += -I../../Driver/Linux/mbgtools-lx-dev-2011-12-19
INCLUDE_DIR = -I../include

COPY=cp
REMOVE=rm
INST_DIR=/usr/local/bin

all: $(TARGET)

$(TARGET).o: $(TARGET).c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) $(TARGET).c

toolutil.o: toolutil.c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) toolutil.c

gpsutils.o: gpsutils.c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) gpsutils.c

mbgdevio.o: mbgdevio.c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) mbgdevio.c

$(TARGET): $(TARGET).o toolutil.o gpsutils.o mbgdevio.o
	$(CC) $(OBJS) $(LD_FLAGS) $(TARGET)

install: $(TARGET)
	$(COPY) $(TARGET) $(INST_DIR)

uninstall:
	test -e $(INST_DIR)/$(TARGET) && $(REMOVE) $(INST_DIR)/$(TARGET)

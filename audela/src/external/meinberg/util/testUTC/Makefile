CC=gcc

COPY=cp
REMOVE=rm

TARGET=testUTC

OBJS=$(TARGET).o
OBJS+=toolutil.o
OBJS+=gpsutils.o
OBJS+=mbgdevio.o

CFLAGS=-Wall -c -Iinclude

INCLUDE_DIR=-I../include

LIBS=-lrt
#LDFLAGS=-Lmbglib

INSTALL_DIR=/usr/local/bin

all: $(TARGET)

$(TARGET).o: $(TARGET).c
	$(CC) $(TARGET).c $(CFLAGS)

toolutil.o: toolutil.c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) toolutil.c

gpsutils.o: gpsutils.c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) gpsutils.c

mbgdevio.o: mbgdevio.c
	$(CC) $(INCLUDE_DIR) $(CFLAGS) mbgdevio.c

$(TARGET): $(TARGET).o toolutil.o gpsutils.o mbgdevio.o
	$(CC) $(OBJS) $(LIBS) -o $(TARGET)

install:
	$(COPY) $(TARGET) $(INSTALL_DIR)

clean:
	$(REMOVE) -f *.o $(TARGET)

uninstall:
	test -e $(INSTALL_DIR)/$(TARGET) && $(REMOVE) $(INSTALL_DIR)/$(TARGET)

#This makefile should suffice on most Unix systems. For other systems,
#you may well need to rewrite it. 
#
# If you already have gd installed, use the line below and comment out the
# following line
#       GD = /path/to/gd/directory
GD = gd-1.8.4
LIBDIRS = -L$(GD) -L/usr/local/web/lib
INCDIRS = -I$(GD) -I/usr/local/web/include
CC = gcc

CFLAGS = -O -pedantic -Wall $(INCDIRS) $(LIBDIRS)
LIBS = -lgd -lm -lz -lttf -lpng -ljpeg #-lXpm 

all: fly

fly: fly.o
	$(CC) $(CFLAGS) -o fly fly.o $(LIBS)

fly.o: fly.c fly.h
	$(CC) -c $(CFLAGS) fly.c

mostlyclean:
	rm -f fly.o temp.gif core; cd $(GD); make clean;
clean:
	rm -f fly.o fly temp.gif core; cd $(GD); make clean;


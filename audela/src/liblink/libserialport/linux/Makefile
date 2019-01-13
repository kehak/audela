LIBLINK = 1

OUTPUT = libserialport.so

SRC = $(LIBLINKDIR)/liblink.cpp $(SRCDIR)/cserial.cpp $(SRCDIR)/serial_tcl.cpp $(LIBLINKDIR)/useitem.cpp $(SRCDIR)/util.c

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(LIBLINKDIR)/%.cpp, %.o, $(filter $(LIBLINKDIR)/%.cpp, $(SRC)))



include ../../../Makefile1



LIBTEL = 1

OUTPUT = libcombit.so

SRC  = $(LIBTELDIR)/util.cpp
SRC += $(SRCDIR)/combit.c

OBJ  = $(patsubst $(LIBTELDIR)/%.cpp, %.o, $(filter $(LIBTELDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1


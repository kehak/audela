
LIBTEL = 1

OUTPUT = libascom.so

SRC  = $(LIBTELDIR)/util.c $(LIBTELDIR)/libtel.c
SRC += $(SRCDIR)/telescop.c $(SRCDIR)/teltcl.c

OBJ  = $(patsubst $(LIBTELDIR)/%.c, %.o, $(filter $(LIBTELDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

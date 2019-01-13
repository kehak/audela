OUTPUT = libfocusfli.so

SRC  = $(SRCDIR)/libfocusfli.c $(SRCDIR)/focusflitcl_1.c
SRC += $(SRCDIR)/focusfli_1.c 

OBJ  = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

A_LIBS = $(EXTLIB)/libfli.a

include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)

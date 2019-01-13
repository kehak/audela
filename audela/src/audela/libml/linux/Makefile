
OUTPUT   = libml.so

SRC  = $(SRCDIR)/libml.c $(SRCDIR)/ml_1.c $(SRCDIR)/mltcl_1.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS)


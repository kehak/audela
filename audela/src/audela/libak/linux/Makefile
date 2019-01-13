
OUTPUT   = libak.so

SRC  = $(SRCDIR)/libak.c $(SRCDIR)/ak_1.c $(SRCDIR)/aktcl_1.c
SRC += $(SRCDIR)/ak_2.c  $(SRCDIR)/ak_3.c $(SRCDIR)/ak_4.c $(SRCDIR)/chealpix.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS)


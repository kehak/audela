
OUTPUT   = libyd.so

SRC  = $(SRCDIR)/libyd.c $(SRCDIR)/yd_1.c $(SRCDIR)/ydtcl_1.c
SRC += $(SRCDIR)/yd_2.c  $(SRCDIR)/yd_3.c $(SRCDIR)/yd_4.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS)


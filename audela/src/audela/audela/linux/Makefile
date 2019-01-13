
OUTPUT = audela

SRC = $(SRCDIR)/lapin.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS = -c -fPIC -Wall -O2  -I $(INCLUDE) $(AUD_TCL_INCLUDE_SPEC) $(AUD_TK_INCLUDE_SPEC) -DUSE_COMPAT_CONST
LDFLAGS = -ldl -lm $(AUD_TCL_LIB_SPEC) $(AUD_TK_LIB_SPEC) -Wl,-rpath=$(OUTPUTDIR)

LD = $(CC)

LIBCAM = 1

OUTPUT = libepixraptor.so

SRC = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c
SRC += $(SRCDIR)/raptor.c $(SRCDIR)/serial.c

OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -Wextra -I $(EXTINC)/epix
LDFLAGS  += -L$(EXTLIB) -lkxclib_x86_64


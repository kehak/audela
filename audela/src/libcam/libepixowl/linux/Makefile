LIBCAM = 1

OUTPUT = libepixraptor.so

SRC = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp
SRC += $(SRCDIR)/raptor.cpp $(SRCDIR)/serial.cpp

OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -Wextra -I $(EXTINC)/epix
LDFLAGS  += -L$(EXTLIB) -lkxclib_x86_64


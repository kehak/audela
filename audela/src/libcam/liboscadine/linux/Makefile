LIBCAM = 1

OUTPUT = liboscadine.so

SRC = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp

OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CFLAGS += -Wextra -I $(EXTINC)
CXXFLAGS += -I $(EXTINC)
LDFLAGS  += -L$(EXTLIB) -lOscadineDriver

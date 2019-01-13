
LIBCAM = 1

OUTPUT = libcagire.so

SRC  = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

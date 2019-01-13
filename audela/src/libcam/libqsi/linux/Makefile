# $Id: Makefile 14024 2016-09-08 19:19:22Z jacquesmichelet $

LIBCAM = 1

OUTPUT = libqsi.so

SRC  = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera_linux.cpp $(SRCDIR)/camtcl.cpp

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I$(EXTINC)
LDFLAGS += -L$(EXTLIB) -lqsiapi -Wl,-rpath,$(EXTLIB)


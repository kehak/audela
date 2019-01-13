
LIBCAM = 1

OUTPUT = libwebcam.so

SRC  = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp $(SRCDIR)/Capture.cpp $(SRCDIR)/CaptureLinux.cpp $(SRCDIR)/CaptureListener.cpp

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

LDFLAGS += -lstdc++


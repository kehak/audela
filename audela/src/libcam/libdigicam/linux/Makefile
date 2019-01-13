
LIBCAM = 1

OUTPUT = libdigicam.so

SRC  = $(LIBCAMDIR)/libcam.cpp $(LIBCAMDIR)/util.cpp  
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp $(SRCDIR)/libdigicam_canon.cpp  $(SRCDIR)/libgphoto2.cpp

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)

#  libgphoto2.so required ( http://www.gphoto.org/  )
LDFLAGS += -lgphoto2 


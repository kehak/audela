
LIBCAM = 1

OUTPUT = libquicka.so

SRC  = $(LIBCAMDIR)/libcam.cpp $(LIBCAMDIR)/util.cpp 
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1
CXXFLAGS += -I $(EXTINC) -I $(EXTINC)/linux -I $(SRCDIR)
#--- la librairie ftd2xx est dans le repertoire external/lib pour compiler
LDFLAGS += -L$(EXTLIB) -lftd2xx

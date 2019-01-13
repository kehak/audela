LIBLINK = 1

OUTPUT = libquickremote.so

SRC = $(LIBLINKDIR)/liblink.cpp $(SRCDIR)/cquickremote.cpp $(SRCDIR)/quickremote_tcl.cpp $(SRCDIR)/../../useitem.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBLINKDIR)/%.cpp, %.o, $(filter $(LIBLINKDIR)/%.cpp, $(SRC)))



include ../../../Makefile1
CXXFLAGS += -I $(EXTINC) -I $(EXTINC)/linux -I $(SRCDIR)
#--- la librairie ftd2xx est dans le repertoire external/lib pour compiler
LDFLAGS += -L$(EXTLIB) -lftd2xx

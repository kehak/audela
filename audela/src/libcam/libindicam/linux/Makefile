LIBCAM = 1

OUTPUT = libindicam.so

SRC = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(wildcard $(SRCDIR)/*.cpp)

OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

#CFLAGS += -I $(EXTINC)   -I ../../../external/libindi/include
#CXXFLAGS += -I $(EXTINC)  -I ../../../external/libindi/include
CFLAGS += -I $(EXTINC)   -I /usr/include/libindi/ -std=c++11
CXXFLAGS += -I $(EXTINC)  -I /usr/include/libindi/ -std=c++11

LDFLAGS  += /usr/lib/x86_64-linux-gnu/libindiclient.a -L$(EXTLIB) -lm -lcfitsio -lpthread

LIBCAM = 1

OUTPUT_STATIC = libcamcommon.a

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CFLAGS += -I $(EXTINC)
CXXFLAGS += -I $(EXTINC) 
	
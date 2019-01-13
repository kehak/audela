OUTPUT = libtclmc.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -std=c++11 -fvisibility=hidden -DTCLMC_EXPORTS 
LDFLAGS  += -Wl,-rpath,. -L$(OUTPUTDIR) -labmc ../../../astrobrick/libabcommon/linux/libabcommon.a  ../../../tcl/libtclcommon/linux/libtclcommon.a



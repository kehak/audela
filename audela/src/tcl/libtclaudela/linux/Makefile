OUTPUT = libtclaudela.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -std=c++11 -fvisibility=hidden -DTCLAUDELA_EXPORTS 
LDFLAGS  += -Wl,-rpath,. -L$(OUTPUTDIR) -labaudela ../../../astrobrick/libabcommon/linux/libabcommon.a  ../../../tcl/libtclcommon/linux/libtclcommon.a



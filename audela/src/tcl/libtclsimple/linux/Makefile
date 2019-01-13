OUTPUT = libtclsimple.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))


include ../../../Makefile1

CXXFLAGS += -fvisibility=hidden -DTCLSIMPLE_EXPORTS
LDFLAGS  += -Wl,-rpath,. -L$(OUTPUTDIR) -labsimple ../../../astrobrick/libabcommon/linux/libabcommon.a  ../../../tcl/libtclcommon/linux/libtclcommon.a



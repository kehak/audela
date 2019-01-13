OUTPUT = libtclaudelatk.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -fvisibility=hidden 
LDFLAGS  += -Wl,-rpath,. -L$(OUTPUTDIR) -labaudela ../../../astrobrick/libabcommon/linux/libabcommon.a ../../../tcl/libtclcommon/linux/libtclcommon.a



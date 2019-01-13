LIBTCL = 1

OUTPUT_STATIC = libtclcommon.a

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -fvisibility=hidden -DTCLCOMMON_EXPORTS

	
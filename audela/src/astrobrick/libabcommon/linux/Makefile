LIBCAM = 1

OUTPUT_STATIC = libabcommon.a

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1
# -DABCOMMON_EXPORTS
CXXFLAGS +=  -std=c++11 -fvisibility=hidden 
	
#LIBCAM = 1

OUTPUT = libtelsimulator.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))


include ../../../Makefile1

CXXFLAGS +=  -std=c++11 -fvisibility=hidden -DLIBTEL_EXPORTS 
LDFLAGS  +=  ../../libtelcommon/linux/libtelcommon.a ../../../astrobrick/libabcommon/linux/libabcommon.a -L$(EXTLIB) \



$(OUTPUT) : ../../libtelcommon/linux/libtelcommon.a 

$(ROOT)/../astrobrick/python/$(OUTPUT): $(OUTPUT)
	$(CP)  $(OUTPUT) $@

all: $(OUTPUT) $(ROOT)/../astrobrick/python/$(OUTPUT)
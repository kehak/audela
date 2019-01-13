#LIBCAM = 1

OUTPUT = libcamsimulator.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))


include ../../../Makefile1

CXXFLAGS +=  -fvisibility=hidden -DLIBCAM_EXPORTS
LDFLAGS  +=  ../../libcamcommon/linux/libcamcommon.a \
             ../../../astrobrick/libabcommon/linux/libabcommon.a \
             -L$(EXTLIB) \

$(OUTPUT) : ../../libcamcommon/linux/libcamcommon.a 

$(ROOT)/../astrobrick/python/$(OUTPUT): $(OUTPUT)
	$(CP)  $(OUTPUT) $@

all: $(OUTPUT) $(ROOT)/../astrobrick/python/$(OUTPUT)
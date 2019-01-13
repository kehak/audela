LIBCAMAB = 1
OUTPUT = libcamindi.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))


include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)  -I ../../../external/libindi/include -fvisibility=hidden -DLIBCAM_EXPORTS 
LDFLAGS  +=  ../../libcamcommon/linux/libcamcommon.a \
             ../../../astrobrick/libabcommon/linux/libabcommon.a \
             ../../../external/libindi/lib/libindiclient.a \
             -L$(EXTLIB) -lindi -lm -lcfitsio -lpthread 


# copie la librairie dans le repertoire astrobrick/python
$(ROOT)/../astrobrick/python/$(OUTPUT): $(OUTPUT)
	$(CP)  $(OUTPUT) $@

all: $(OUTPUT) $(ROOT)/../astrobrick/python/$(OUTPUT)
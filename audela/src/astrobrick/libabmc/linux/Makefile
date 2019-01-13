OUTPUT = libabmc.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -std=c++11 -fvisibility=hidden -DABMC_EXPORTS -I$(EXTINC)
LDFLAGS  +=  ../../libabcommon/linux/libabcommon.a ../../../external/lib/libsofa.a -u IDataArray_releaseInstance -u IDataArray_size -u errorCode -u errorMessage

# copie la librairie dans le repertoire astrobrick/python
$(ROOT)/../astrobrick/python/$(OUTPUT): $(OUTPUT)
	$(CP)  $(OUTPUT) $@

all: $(OUTPUT) $(ROOT)/../astrobrick/python/$(OUTPUT)
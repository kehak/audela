OUTPUT = libabsimple.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -fvisibility=hidden -DABSIMPLE_EXPORTS -DABCOMMON_EXPORTS

LDFLAGS  +=  ../../libabcommon/linux/libabcommon.a -u IArray_deleteInstance -u IArray_size -u IIntArray_at -u IStringArray_at -u IStructArray_at -u IDataArray_releaseInstance -u IDataArray_size -u errorCode -u errorMessage

# copie la librairie dans le repertoire astrobrick/python
$(ROOT)/../astrobrick/python/$(OUTPUT): $(OUTPUT)
	$(CP)  $(OUTPUT) $@

all: $(OUTPUT) $(ROOT)/../astrobrick/python/$(OUTPUT)
OUTPUT = libabaudela.so

SRC = $(wildcard $(SRCDIR)/*.cpp)
OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -std=c++11 -fvisibility=hidden -DABAUDELA_EXPORTS -I$(INCLUDE) -I$(EXTINC)
LDFLAGS += -Wl,-rpath,. -L$(OUTPUTDIR) -ldcraw -ldcjpeg -lpthread -ltt -lltdl -labmc ../../libabcommon/linux/libabcommon.a -u IDataArray_releaseInstance -u IDataArray_size -u errorCode -u errorMessage
# Remarque : ajout de l'option "-rpath ."
# L'option -rpath permet d'eviter l'utilisation deconseillee de la variable
# LD_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquels les librairies
# dynamiques libdcraw.so et libdcjpeg.so et libtt.so seront recherchees en priorite au runtime.

$(ROOT)/../astrobrick/python/$(OUTPUT): $(OUTPUT)
	$(CP) $(OUTPUT) $@

all: $(OUTPUT) $(ROOT)/../astrobrick/python/$(OUTPUT)
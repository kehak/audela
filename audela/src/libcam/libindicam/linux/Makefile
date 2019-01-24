LIBCAM = 1

OUTPUT = libindicam.so

SRC = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(wildcard $(SRCDIR)/*.cpp)

OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

#CFLAGS += -I $(EXTINC)   -I ../../../external/libindi/include -I ../../../audela/src/audela/libaudela/src/
#CXXFLAGS += -I $(EXTINC)  -I ../../../external/libindi/include -I ../../../audela/src/audela/libaudela/src/
#LDFLAGS  += ../../../external/libindi/lib/libindiclient.a -L$(EXTLIB) -lindi -lm -lcfitsio -lpthread 

# Note : on lie vers notre propre version d'INDI :
CFLAGS += -I $(EXTINC)   -I /usr/local/include/libindi
CXXFLAGS += -I $(EXTINC)  -I /usr/local/include/libindi
#CFLAGS += -I $(EXTINC)   -I /usr/include/
#CXXFLAGS += -I $(EXTINC)  -I /usr/include/

# Note : idem, on lie avec la lib INDI statique compilée par nos soins
# Attention, -lindi dépréciée depuis libindi1.4 ! Remplacée par -lindidriver
# il faudra changer les entêtes et vérifier que ça marche avec les versions récentes.
# Vérifier le nom de la lib INDI avec "cat /usr/lib/x86_64-linux-gnu/pkgconfig/libindi.pc"

# - Adapter le chemin des libs ci-dessous
# - Penser à construire audela/external et audela/contrib avant de lancer le make
# - Désinstaller le citsio-dev de la distribution, il faut utiliser celui d'AudeLA.

#LDFLAGS  += ../../../external/libindi/lib/libindiclient.a -L/root/audela-code/audela/src/external/cfitsio/cfitsio3340 -L$(EXTLIB) -lindi -lm -lcfitsio -lpthread
LDFLAGS  += /usr/local/lib/libindiclient.a -L../../../audela/src/external/cfitsio/cfitsio3340 -L$(EXTLIB) -lindi -lm -lcfitsio -lpthread

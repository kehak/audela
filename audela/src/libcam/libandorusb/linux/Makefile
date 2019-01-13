
LIBCAM = 1

OUTPUT = libandorusb.so

SRC  = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.c $(SRCDIR)/camtcl.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1

# remarque : atmcdLXd.h  est recherche d'abord dans  /usr/local/include ou, a defaut dans ../driverAndor/include
CXXFLAGS += -I /usr/local/include -I../driverAndor/include -I$(INCLUDE)
LDFLAGS += -L/usr/local/lib -landor -L$(OUTPUTDIR) -laudela


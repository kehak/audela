
LIBCAM = 1

OUTPUT = libsbig.so libsbigparallel.so

SRC  = $(LIBCAMDIR)/util.cpp $(LIBCAMDIR)/libcam.cpp
SRC += $(SRCDIR)/camera.cpp $(SRCDIR)/camtcl.cpp ./bzero.c

OBJ  = $(patsubst $(LIBCAMDIR)/%.cpp, %.o, $(filter $(LIBCAMDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))
OBJ += $(patsubst ./%.c, %.o, $(filter ./%.c, $(SRC)))

# include Makefile1 initilise CXXFLAGS et LDFLAGS
# et doit etre place avant les modifications de CXXFLAGS et LDFLAGS
include ../../../Makefile1

CXXFLAGS += -I $(EXTINC)

# L'option -rpath permet d'eviter l'utilisation deconseillee de la
# variable LD_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquels les librairies
# dynamiques .so seront recherchees en priorite au runtime.
libsbig.so: $(OBJ)
	@echo "*** Linking library $@"
	#$(LD) $^ $(LDFLAGS)  -Wl,-rpath,. -L$(EXTLIB) -lsbigudrv.1.4.60 -lm  -o $@ 
	$(LD) $^ $(LDFLAGS)  -Wl,-rpath,. -L$(EXTLIB) -lsbigudrv -lm  -o $@ 
	$(CP) $@ $(OUTPUTDIR)

libsbigparallel.so: $(OBJ)
	@echo "*** Compiling libcam.o for parallel"
	$(RM) libcam.o
	$(CC) $(CXXFLAGS) -DCAM_ENTRYPOINT=Sbigparallel_Init -DCAM_LIBNAME='"libsbigparallel"' -DCAM_DRIVNAME='"sbigparallel"' -o libcam.o $(LIBCAMDIR)/libcam.cpp
	@echo "*** Linking library $@"
	$(LD) $^ $(LDFLAGS) -o $@ $(EXTLIB)/libsbigudrv.a
	$(CP) $@ $(OUTPUTDIR)
	$(RM) libcam.o



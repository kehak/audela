
OUTPUT   = libaudela.so

SRC =  $(SRCDIR)/libaudela.cpp $(SRCDIR)/libstd.cpp $(SRCDIR)/pool_tcl.cpp  \
       $(SRCDIR)/cdevice.cpp $(SRCDIR)/cpool.cpp  $(SRCDIR)/setip.cpp \
       $(SRCDIR)/history.cpp $(SRCDIR)/ping.cpp \
       $(SRCDIR)/fitskw.cpp $(SRCDIR)/stats.cpp \
       $(SRCDIR)/tel_tcl.cpp $(SRCDIR)/cam_tcl.cpp $(SRCDIR)/link_tcl.cpp \
       $(SRCDIR)/utils.cpp $(SRCDIR)/cerror.cpp  \
       $(SRCDIR)/MinimisationAndLinearAlgebraicSystems.cpp $(SRCDIR)/PsfFitter.cpp \
       $(SRCDIR)/psfimcce.cpp $(SRCDIR)/psfimcce_nr.cpp $(SRCDIR)/psfimcce_funcs.cpp  \
       $(SRCDIR)/cpixels.cpp $(SRCDIR)/cpixelsgray.cpp $(SRCDIR)/cpixelsrgb.cpp \
       $(SRCDIR)/cfile.cpp $(SRCDIR)/file_tcl.cpp \
       $(SRCDIR)/cbuffer.cpp $(SRCDIR)/buf_tcl.cpp \
       $(SRCDIR)/utf2Unicode_tcl.cpp

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile.defs

#-Wno-deprecated  -DUSE_COMPAT_CONST

CXXFLAGS += -I$(SRCDIR) -I$(INCLUDE) -I$(EXTINC) -Wno-deprecated 

# Remarque : ajout de l'option "-rpath ."
# L'option -rpath permet d'eviter l'utilisation deconseillee de la variable
# LD_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquels les librairies
# dynamiques libdcraw.so et libdcjpeg.so et libtt.so seront recherchees en priorite au runtime.

all: $(OUTPUT) $(INCLUDE)/libaudela.h

$(INCLUDE)/libaudela.h: $(SRCDIR)/libaudela.h
	cp -f $(SRCDIR)/libaudela.h   $(INCLUDE)

$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libdcraw.so $(OUTPUTDIR)/libdcjpeg.so $(OUTPUTDIR)/libtt.so
	$(LD) $(OBJ) $(LDFLAGS) -Wl,-rpath,. -L$(OUTPUTDIR) -ldcraw -ldcjpeg -lpthread -ltt -o $@
	$(CP) $@ $(OUTPUTDIR)
	
libdcraw.so : $(OBJ) $(A_LIBS)
	@echo "*** Linking library $@"
	$(LD) $^ $(LDFLAGS) -o $@ 
	$(CP) $@ $(OUTPUTDIR)

libdcjpeg.so : $(OBJ) $(A_LIBS)
	@echo "*** Linking library $@"
	$(LD) $^ $(LDFLAGS) -o $@ 
	$(CP) $@ $(OUTPUTDIR)
	
%.o: $(SRCDIR)/%.cpp
	@echo "*** Compiling $<"
	$(CXX) $(CXXFLAGS) -o $@ $<

%.o: $(SRCDIR)/%.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<

%.o: %.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<

.PHONY: clean cleanall
clean:
	$(RM) $(OBJ) $(OUTPUT) $(INCLUDE)/libaudela.h

cleanall: clean
	$(RM) makedep *~ *.bak *.BAK *.swp 

.PHONY: indent
indent:
	indent $(SRCDIR)/*.[ch] -kr -line-length1000 --ignore-newlines

.PHONY: local-clean src-clean vc60-clean distclean
vc60-clean:
	-$(RM) -rf ../vc60/Debug ../vc60/Release 
	-$(RM) ../vc60/*.mak ../vc60/*.ncb ../vc60/*.opt ../vc60/*.plg 
	-$(RM) ../vc60/*~ ../vc60/*.bak 
local-clean:
	-$(RM) *~ *.bak makedep
src-clean:
	-$(RM) $(SRCDIR)/*~ $(SRCDIR)/*.bak 
distclean: local-clean src-clean vc60-clean clean

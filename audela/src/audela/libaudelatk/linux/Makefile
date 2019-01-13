
OUTPUT   = libaudelatk.so

SRC = $(SRCDIR)/libaudelatk.cpp  $(SRCDIR)/visu_tcl.cpp  $(SRCDIR)/cvisu.cpp \
      $(SRCDIR)/cvisupool.cpp

OBJ  = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile.defs

CXXFLAGS += -I$(EXTINC) -I$(INCLUDE)

# Link 
# Remarque : ajout de l'option "-rpath ."
# L'option -rpath permet d'eviter l'utilisation deconseillee de la variable 
# LB_LIBRARY_PATH au runtime.
# L'option -rpath indique les repertoires dans lesquesl les librairies
# dynamiques libaudela.so sera recherche en priorite au runtime.

$(OUTPUT): $(OBJ) $(OUTPUTDIR)/libaudela.so $(INCLUDE)/libaudela.h 
	$(LD) $(OBJ) $(LDFLAGS) -Wl,-rpath,. -L $(OUTPUTDIR) -laudela -o $@ 
	$(CP) $@ $(OUTPUTDIR)

libaudela.so : $(OBJ) $(A_LIBS)
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

ifdef LIBCAM
CXXFLAGS += -I $(SRCDIR)
%.o: $(LIBCAMDIR)/%.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<
endif

ifdef LIBTEL
CXXFLAGS += -I $(SRCDIR)
%.o: $(LIBTELDIR)/%.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<
endif

ifdef LIBLINK
CXXFLAGS += -I $(SRCDIR)
%.o: $(LIBLINKDIR)/%.cpp
	@echo "*** Compiling $<"
	$(CXX) $(CXXFLAGS) -o $@ $<
endif


#########
###   ###
#########

depend: makedep
makedep:
	@echo "*** Building dependencies file"
	$(CXX) $(CXXFLAGS) -MM $(SRC) > makedep

.PHONY: clean cleanall
clean:
	$(RM) $(OBJ) $(OUTPUT)
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



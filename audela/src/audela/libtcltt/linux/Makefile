
OUTPUT =  $(OUTPUTDIR)/libtcltt.so

include ../../../Makefile.defs

SRC = $(SRCDIR)/libtt_tcl.cpp \
      $(SRCDIR)/libtt.cpp \
      $(SRCDIR)/utf2Unicode_tcl.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

#--- j'ajoute le repertoire des include d'audela (pour libtt.h)
CXXFLAGS += -I ../../include

$(OUTPUT): $(OBJ) $(A_LIBS) $(OUTPUTDIR)/libtt.so 
	@echo "*** Linking library $@"
	$(LD) $(OBJ) $(LDFLAGS) -Wl,-rpath,. -L$(OUTPUTDIR) -ltt -o $@

clean:
	$(RM) $(OBJ) $(OUTPUT)
cleanall: clean
	$(RM) makedep *~ *.bak *.BAK *.swp $(SRCDIR)/*~ $(SRCDIR)/*.bak $(SRCDIR)/*.BAK $(SRCDIR)/*.swp


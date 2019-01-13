
OUTPUT = libjm.so

SRC = $(SRCDIR)/libjm.cpp \
      $(SRCDIR)/erreur.cpp \
      $(SRCDIR)/calaphot_tcl.cpp $(SRCDIR)/calaphot.cpp \
      $(SRCDIR)/horloge.cpp $(SRCDIR)/horloge_tcl.cpp \
      $(SRCDIR)/divers.cpp $(SRCDIR)/divers_tcl.cpp \
      $(SRCDIR)/fourier_services.cpp $(SRCDIR)/fourier_calculs.cpp \
      $(SRCDIR)/fourier_images.cpp $(SRCDIR)/fourier_tcl.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS) -Wl,-rpath,. -L $(ROOT)/audela/libaudela/linux -laudela

.PHONY: clean cleanall
clean:
	$(RM) $(OBJ) $(OUTPUT)
cleanall: clean
	$(RM) makedep *~ *.bak *.BAK *.swp $(SRCDIR)/*~ $(SRCDIR)/*.bak $(SRCDIR)/*.BAK $(SRCDIR)/*.swp $(OUTPUTDIR)/$(OUTPUT)

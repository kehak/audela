
OUTPUT   = libbm.so

SRC = $(SRCDIR)/libbm.cpp $(SRCDIR)/bm_c_tcl.cpp $(SRCDIR)/Image_base.cpp $(SRCDIR)/Image_lecturepixel.cpp $(SRCDIR)/Image_ecriturepixel.cpp $(SRCDIR)/Image_conversion.cpp $(SRCDIR)/Image_trt.cpp $(SRCDIR)/Image_max.cpp  $(SRCDIR)/Image_maxxy.cpp $(SRCDIR)/Vecteur_base.cpp $(SRCDIR)/Vecteur_lectureelement.cpp $(SRCDIR)/Vecteur_ecritureelement.cpp $(SRCDIR)/Vecteur_conversion.cpp $(SRCDIR)/Vecteur_trt.cpp $(SRCDIR)/Vecteur_max.cpp  $(SRCDIR)/Vecteur_maxx.cpp 

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += $(AUD_GSL_CFLAGS) -DNO_STRING_H
LDFLAGS  += $(AUD_GSL_LIBS)

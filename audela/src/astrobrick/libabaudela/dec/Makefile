CXX = g++
LD = /usr/local/lib/gcc-lib/alpha-dec-osf4.0d/2.8.0/ld
CP = cp
RM = rm -f -v

SRCDIR    = ../src
OBJDIR    = .
INCDIR    = .
OUTPUTDIR = ../../../binlinux

OUTPUT   = libstd.so
CXXFLAGS = -Wall -O2

OBJ = $(OBJDIR)/angles.o $(OBJDIR)/animate.o $(OBJDIR)/buf_tcl.o \
      $(OBJDIR)/cam_tcl.o $(OBJDIR)/caudine.o $(OBJDIR)/cbuffer.o \
      $(OBJDIR)/ccamera.o $(OBJDIR)/cdevice.o $(OBJDIR)/chisis11.o \
      $(OBJDIR)/chisis22.o $(OBJDIR)/chisis24.o $(OBJDIR)/clx200.o \
      $(OBJDIR)/couranos.o $(OBJDIR)/cpool.o $(OBJDIR)/csercom.o \
      $(OBJDIR)/ctelesc.o $(OBJDIR)/cultima.o $(OBJDIR)/cvisu.o \
      $(OBJDIR)/ephem.o $(OBJDIR)/fitskw.o $(OBJDIR)/history.o \
      $(OBJDIR)/libstd.o $(OBJDIR)/pool_tcl.o $(OBJDIR)/stats.o \
      $(OBJDIR)/tel_tcl.o $(OBJDIR)/tt.o $(OBJDIR)/visu_tcl.o \
      $(OBJDIR)/utils.o $(OBJDIR)/cst7.o $(OBJDIR)/bzero.o

SRC = $(SRCDIR)/angles.cpp $(SRCDIR)/animate.cpp $(SRCDIR)/buf_tcl.cpp \
      $(SRCDIR)/cam_tcl.cpp $(SRCDIR)/caudine.cpp $(SRCDIR)/cbuffer.cpp \
      $(SRCDIR)/ccamera.cpp $(SRCDIR)/cdevice.cpp $(SRCDIR)/chisis11.cpp \
      $(SRCDIR)/chisis22.cpp $(SRCDIR)/chisis24.cpp $(SRCDIR)/clx200.cpp \
      $(SRCDIR)/couranos.cpp $(SRCDIR)/cpool.cpp $(SRCDIR)/csercom.cpp \
      $(SRCDIR)/ctelesc.cpp $(SRCDIR)/cultima.cpp $(SRCDIR)/cvisu.cpp \
      $(SRCDIR)/ephem.cpp $(SRCDIR)/fitskw.cpp $(SRCDIR)/history.cpp \
      $(SRCDIR)/libstd.cpp $(SRCDIR)/pool_tcl.cpp $(SRCDIR)/stats.cpp \
      $(SRCDIR)/tel_tcl.cpp $(SRCDIR)/tt.cpp $(SRCDIR)/visu_tcl.cpp \
      $(SRCDIR)/utils.cpp $(SRCDIR)/cst7.cpp ./bzero.c

all: $(OUTPUT)

$(OBJDIR)/%.o:
	@echo "*** Compilation de $<"
	$(CXX) $(CXXFLAGS) -c -fPIC -I $(INCDIR) $< -o $@
$(OBJDIR)/utils.o:
	@echo "*** Compilation specifique de $<"
	$(CXX) $(CXXFLAGS) -c -fPIC  -O2 -I $(INCDIR) $(SRCDIR)/utils.cpp -o $@
$(OUTPUT): $(OBJ)
	@echo "*** Linking library $(OUTPUT)"
	 g++ -o $(OUTPUT) -ltcl8.0 -ltk8.0  -lX11 -lm -lc $(OBJ)
depend: makedep
makedep:
	@echo "*** Building dependencies file"
	$(CXX) -MM -I $(INCDIR) $(SRC) > makedep
clean:
	$(RM) $(OBJ) $(OUTPUT) makedep

include makedep








OUTPUT   = libcatalog_tcl.so

SRC  = $(SRCDIR)/libcatalog_tcl.cpp $(SRCDIR)/common.cpp $(SRCDIR)/cs2mass.cpp $(SRCDIR)/csusnoa2.cpp
SRC += $(SRCDIR)/csucac2.cpp $(SRCDIR)/csucac3.cpp  $(SRCDIR)/csucac4.cpp $(SRCDIR)/csnomad1.cpp
SRC += $(SRCDIR)/csppmx.cpp $(SRCDIR)/csppmxl.cpp $(SRCDIR)/cswfibc.cpp $(SRCDIR)/cstycho.cpp 
SRC += $(SRCDIR)/csbmk.cpp $(SRCDIR)/csurat1.cpp $(SRCDIR)/csloneos.cpp $(SRCDIR)/cstgas.cpp
SRC += $(SRCDIR)/csgaia1.cpp $(SRCDIR)/csgaia2.cpp

OBJ = $(patsubst $(SRCDIR)/%.cpp, %.o, $(filter $(SRCDIR)/%.cpp, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -Wextra -I $(INCLUDE)

$(OUTPUT): $(OBJ) $(A_LIBS) $(OUTPUTDIR)/libcatalog.so 
	@echo "*** Linking library $@"
	$(LD) $(OBJ) $(LDFLAGS) -Wl,-rpath,. -L$(OUTPUTDIR) -lcatalog -o $@
	$(CP) $(OUTPUT) $(OUTPUTDIR)

	
CXX          = gcc
LD           = gcc
AR           = ar
CP           = cp
RM           = rm -f -v

OUTPUT       = libtt.dylib
OUTPUTDIR    = ../../../../bin
SRCDIR       = ../src

DEPENDENCIES = $(patsubst %.a,%.depend,$(OUTPUT))

CXXFLAGS     = -c -fno-common -fno-strict-aliasing -fPIC -Wall -O2 -I ../../../include -I ../../../external/include -I $(SRCDIR)
LDFLAGS      = -dynamiclib -ldl -lm

SRC = $(SRCDIR)/files.c $(SRCDIR)/fs_fsio1.c $(SRCDIR)/fs_fsio2.c \
      $(SRCDIR)/fs_macr1.c $(SRCDIR)/fs_macr2.c $(SRCDIR)/fs_macr3.c \
      $(SRCDIR)/fs_macr4.c $(SRCDIR)/tt.c $(SRCDIR)/tt_fits1.c \
      $(SRCDIR)/tt_fits2.c $(SRCDIR)/tt_fits3.c $(SRCDIR)/tt_fits4.c \
      $(SRCDIR)/tt_fits5.c $(SRCDIR)/tt_fsio2.c $(SRCDIR)/tt_poin1.c \
      $(SRCDIR)/tt_poin2.c $(SRCDIR)/tt_scri1.c $(SRCDIR)/tt_seri1.c \
      $(SRCDIR)/tt_seri2.c $(SRCDIR)/tt_seri3.c $(SRCDIR)/tt_seri4.c \
      $(SRCDIR)/tt_seri5.c $(SRCDIR)/tt_seri6.c \
      $(SRCDIR)/tt_stac1.c $(SRCDIR)/tt_stac2.c $(SRCDIR)/tt_time1.c \
      $(SRCDIR)/tt_user1.c $(SRCDIR)/tt_user2.c $(SRCDIR)/tt_user3.c \
      $(SRCDIR)/tt_user4.c $(SRCDIR)/tt_user5.c \
      $(SRCDIR)/tt_util1.c $(SRCDIR)/tt_util2.c $(SRCDIR)/tt_util3.c \
      $(SRCDIR)/tt_util4.c 

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

all: $(OUTPUT)

$(OUTPUT): $(OBJ)
	@echo "*** Linking library $@"
	$(LD) $(LDFLAGS) -o $@ $? ../../../external/lib/libcfitsio.a ../../../external/lib/libjpeg.a
	$(CP) $@ $(OUTPUTDIR)

%.o: $(SRCDIR)/%.c
	@echo "*** Compilation de $<"
	$(CXX) $(CXXFLAGS) -o $@ $<

makedep:
	@echo "*** Building dependencies file"
	$(CXX) $(CXXFLAGS) -MM $(SRC) > makedep

.PHONY: clean cleanall distclean
clean::
	$(RM) $(OBJ) $(OUTPUT)
cleanall:: clean
	$(RM) makedep *~ *.bak *.BAK *.swp $(SRCDIR)/*~ $(SRCDIR)/*.bak $(SRCDIR)/*.BAK $(SRCDIR)/*.swp
distclean: cleanall
	@-$(RM) -rf ../vc60/Debug ../vc60/Release
	@-$(RM) ../vc60/*.mak ../vc60/*.ncb ../vc60/*.opt ../vc60/*.plg
	@-$(RM) ../vc60/*~ ../vc60/*.bak

include makedep


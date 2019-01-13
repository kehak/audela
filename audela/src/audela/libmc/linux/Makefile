
OUTPUT    = libmc.so

SRC = $(SRCDIR)/libmc.c    $(SRCDIR)/libmc2.c   $(SRCDIR)/libmc3.c   \
      $(SRCDIR)/mc_corc1.c $(SRCDIR)/mc_cord1.c $(SRCDIR)/mc_file1.c \
      $(SRCDIR)/mc_file2.c $(SRCDIR)/mc_file3.c $(SRCDIR)/mc_intg1.c \
      $(SRCDIR)/mc_macr1.c $(SRCDIR)/mc_macr2.c $(SRCDIR)/mc_macr3.c \
      $(SRCDIR)/mc_math1.c $(SRCDIR)/mc_menu1.c $(SRCDIR)/mc_orbi1.c \
      $(SRCDIR)/mc_orbi2.c $(SRCDIR)/mc_orbi3.c $(SRCDIR)/mc_plnt1.c \
      $(SRCDIR)/mc_plnt2.c $(SRCDIR)/mc_plnt3.c $(SRCDIR)/mc_plnt4.c \
      $(SRCDIR)/mc_time1.c $(SRCDIR)/mc_util1.c $(SRCDIR)/mc_util2.c \
      $(SRCDIR)/mc_cart1.c $(SRCDIR)/mc_cata1.c $(SRCDIR)/mc_scdl1.c \
      $(SRCDIR)/mc_modl1.c $(SRCDIR)/mc_nora1.c $(SRCDIR)/mc_nora2.c \
      $(SRCDIR)/mc_elp10.c $(SRCDIR)/mc_elp11.c $(SRCDIR)/mc_elp12.c \
      $(SRCDIR)/mc_elp13.c \
      $(SRCDIR)/libmc_angles.c $(SRCDIR)/libmc_dates.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))

include ../../../Makefile1


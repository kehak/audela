OUTPUT   = libgzip.so

GZIPDIR = $(EXTDIR)/gzip/gzip

SRC =  $(GZIPDIR)/bits.c     $(GZIPDIR)/crypt.c   $(GZIPDIR)/deflate.c \
       $(GZIPDIR)/getopt.c   $(GZIPDIR)/gzip.c    $(GZIPDIR)/inflate.c \
       $(GZIPDIR)/lzw.c      $(GZIPDIR)/trees.c   $(GZIPDIR)/unlzh.c   \
       $(GZIPDIR)/unlzw.c    $(GZIPDIR)/unpack.c  $(GZIPDIR)/unzip.c   \
       $(GZIPDIR)/util.c     $(GZIPDIR)/zip.c

SRC += $(SRCDIR)/libgzip.c   $(SRCDIR)/xx_1.c     $(SRCDIR)/xxtcl_1.c

OBJ = $(patsubst $(SRCDIR)/%.c, %.o, $(filter $(SRCDIR)/%.c, $(SRC)))
OBJ += $(patsubst $(GZIPDIR)/%.c, %.o, $(filter $(GZIPDIR)/%.c, $(SRC)))

include ../../../Makefile1

CXXFLAGS += -I $(GZIPDIR)

%.o: $(GZIPDIR)/%.c
	@echo "*** Compiling $<"
	$(CC) $(CXXFLAGS) -o $@ $<

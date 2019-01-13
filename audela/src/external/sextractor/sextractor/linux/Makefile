.PHONY: build install clean distclean

include ../../../../Makefile.defs

DIR = $(EXTDIR)/sextractor/sextractor/sextractor-2.5.0

build:
	@if test ! -e $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
		chmod +x configure ; \
		./configure CFLAGS=-DHAVE_STRTOK_R ; \
		\
	fi;
	$(MAKE) -C $(DIR)

install: 
	$(CP) -f $(DIR)/src/sex $(OUTPUTDIR)

#####On n'utilise pas la methode standard qui recopie des fichiers qui ne nous interessent pas 
#####$(MAKE) -C $(DIR) install


clean:
	$(MAKE) -C $(DIR) clean

distclean: 
	$(MAKE) -C $(DIR) distclean
	

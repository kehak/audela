.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = fitstcl21
CFITSIO=$(ROOT)/external/cfitsio/cfitsio3340


#
build:
	@if test ! -f $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
      echo AUD_TCL_BIN_DIR=$(AUD_TCL_BIN_DIR) ; \
      echo include=$(ROOT)/external/tcl/tcl/include  ; \
		echo include=$(CFITSIO) ; \
		chmod +x configure ; \
		./configure --prefix=$(ROOT)/../bin --with-tcl=$(AUD_TCL_BIN_DIR) --with-tcl-includes=$(ROOT)/external/tcl/tcl/include  --with-cfitsio=$(CFITSIO) --enable-threads --prefix=`pwd`/../.. ; \
		 \
	fi;
	#--- create dynamic library libfitstcl.so
	make -C $(DIR) shared

install: build
	#--- copy libcfitsio.so to $(ROOT)/external/lib
	cp $(DIR)/libfitstcl.so $(ROOT)/../bin

clean:
	make -C $(DIR) clean
	rm -f $(DIR)/Makefile

distclean: clean
	rm -f *~ *.bak
	rm -f $(ROOT)/../lib/blt2.4/libBLT24.so
	rm -f $(ROOT)/../lib/blt2.4/pkgIndex.tcl

.PHONY: build install clean distclean

include ../../Makefile.defs

DIR = blt2.4z

build:
	@if test ! -e $(DIR)/Makefile || test ../../Makefile.defs -nt $(DIR)/Makefile; then \
		cd $(DIR) && \
		echo chmod +x configure ; \
		./configure --enable-threads --with-tcl=$(AUD_TCL_BIN_DIR) --with-tk=$(AUD_TK_BIN_DIR) --with-blt=$(ROOT)/../lib ; \
		 \
	fi;
	$(MAKE) -C $(DIR)

install: build
	$(MAKE) -C $(DIR) install

clean:
	$(MAKE) -C $(DIR) clean

distclean: 
	$(MAKE) -C $(DIR) distclean
	$(RM) -r $(ROOT)/../lib/blt2.4

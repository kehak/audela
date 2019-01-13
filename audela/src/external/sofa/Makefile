.PHONY: build install clean distclean

include ../../Makefile.defs
DIR=src

build:
	#--- create static library libsofa_c.a 
	make -C $(DIR)

install: build
	cp $(DIR)/libsofa_c.a $(EXTLIB)/libsofa.a
	cp $(DIR)/sofa.h  $(EXTINC)/sofa.h
	cp $(DIR)/sofam.h $(EXTINC)/sofam.h

clean:
	make -C $(DIR) clean
	$(RM) $(DIR)/libsofa_c.a
	$(RM) $(EXTLIB)/libsofa.a
	$(RM) $(EXTINC)/sofa.h
	$(RM) $(EXTINC)/sofam.h

distclean:
	make -C $(DIR) distclean
	rm -f *~ *.bak

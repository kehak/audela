include ../Makefile.defs

MYTARGETS = $(EXTERNAL)

all: $(MYTARGETS)

.PHONY: $(MYTARGETS) clean cleanall install

$(MYTARGETS):
	mkdir -p include
	mkdir -p lib
	(cd $@; make ; make install)

clean cleanall distclean install:
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR) $@ ; )


.PHONY: local-clean dist-clean dist

local-clean:
	$(RM) *~

dist-clean: local-clean
	@$(foreach DIR, $(MYTARGETS), make -C $(DIR) distclean ; )

dist: dist-clean
	mkdir $(distdir)
	cp readme.txt Makefile $(distdir)
	@$(foreach DIR, $(MYTARGETS), cp -r $(DIR) $(distdir); )
	cp -r gsl $(distdir)
	cp -r utils $(distdir)
	mkdir $(distdir)/include   # Le contenu du repertoire include est reconstitue au build
	mkdir $(distdir)/lib       # Le contenu du repertoire lib est reconstitue au build

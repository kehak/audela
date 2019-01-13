include Makefile.defs

all: $(ALL)

.PHONY: external contrib audela libcam libtel liblink $(ALL) dist distclean

$(EXTERNAL):
	make -C external/$@

$(CONTRIB):
	make -C contrib/$@/linux

$(AUDELA):
	make -C audela/$@/linux

$(LIBCAMS):
	make -C libcam/$@/linux

$(LIBTELS):
	make -C libtel/$@/linux

$(LIBLINKS):
	make -C liblink/$@/linux

external contrib: 
	$(MAKE) -C $@

clean cleanall:
	@$(foreach DIR, contrib audela libcam liblink libtel, make -C $(DIR) $@ ; )

distdir=$(ROOT)/$(PACKAGE)-$(VERSION)

distclean: local-clean
	@$(foreach DIR, contrib audela libcam liblink libtel, make -C $(DIR) $@ ; )

dist:
	if test -d "$(distdir)"; then \
	   rm -rf $(distdir); \
	fi;
	mkdir $(distdir)
	
	cp -r ../gui $(distdir)
	make -C audela   $@ distdir=$(distdir)/src/audela
	make -C ../bin   $@ distdir=$(distdir)/bin
	make -C contrib  $@ distdir=$(distdir)/src/contrib
	make -C external $@ distdir=$(distdir)/src/external
	make -C include  $@ distdir=$(distdir)/src/include
	make -C ../lib   $@ distdir=$(distdir)/lib
	make -C libcam   $@ distdir=$(distdir)/src/libcam
	make -C liblink  $@ distdir=$(distdir)/src/liblink
	make -C libtel   $@ distdir=$(distdir)/src/libtel
	make -C tools    $@ distdir=$(distdir)/src/tools

	cp aclocal.m4 audela.dsw ChangeLog configure configure.in copying $(distdir)/src
	cp Makefile Makefile1.in $(distdir)/src
	cp Makefile.defs.in Makefile.rules readme.txt readme.1.txt todo $(distdir)/src
	cp readme.txt ChangeLog todo copying $(distdir)
	if test -e "$(distdir).tar.gz"; then \
	   rm -rf $(distdir).tar.gz; \
	fi;
	tar -czf $(distdir).tar.gz $(PACKAGE)-$(VERSION)

dist.win32:
	if test -d "$(distdir)"; then \
	   rm -rf $(distdir); \
	fi;
	mkdir $(distdir)
	cp -r ../gui $(distdir)
	mkdir $(distdir)/bin
	-cp -f ../bin/*.tcl ../bin/*.gif ../bin/*.dll ../bin/*.exe ../bin/*.sys $(distdir)/bin
	cp -r ../lib $(distdir)
	cp ChangeLog copying readme.txt todo $(distdir)
	find $(PACKAGE)-$(VERSION) | grep cvs$ | xargs \rm -rf
	if test -e "$(distdir)-win32.tar.gz"; then \
	   rm -rf $(distdir)-win32.tar.gz; \
	fi;
	tar -czf $(distdir)-win32.tar.gz $(PACKAGE)-$(VERSION)

dist.linux:
	if test -d "$(distdir)"; then \
	   rm -rf $(distdir); \
	fi;
	mkdir $(distdir)
	cp -r gui $(distdir)
	mkdir $(distdir)/bin
	-cp -f bin/*.pl bin/*.sh bin/*.tcl bin/*.gif bin/audela bin/sex bin/*.so $(distdir)/bin
	cp -r lib $(distdir)
	cp ChangeLog copying readme.txt todo $(distdir)
	if test -e "$(distdir)-linux.tar.gz"; then \
	   rm -rf $(distdir)-linux.tar.gz; \
	fi;
	tar -czf $(distdir)-linux.tar.gz $(PACKAGE)-$(VERSION)

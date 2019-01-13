include ../Makefile.defs

.PHONY: local-clean dist-clean dist

local-clean:
	$(RM) *~
	#$(RM) version.h

dist-clean: local-clean

dist: dist-clean
	mkdir $(distdir)
	cp -rf * $(distdir)

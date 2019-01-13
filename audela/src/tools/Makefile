include ../Makefile.defs

.PHONY: local-clean dist-clean dist

local-clean:
	$(RM) *~

dist-clean: local-clean

dist: dist-clean
	mkdir -p $(distdir)
	cp -rf * $(distdir)

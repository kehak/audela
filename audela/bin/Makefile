include ../src/Makefile.defs

.PHONY: local-clean dist-clean dist

local-clean:
	$(RM) *~
	#$(RM) version.tcl

dist-clean: local-clean

dist: dist-clean
	mkdir -p $(distdir)
	cp -f audela.pl audela.sh audela.tcl langage.tcl version.tcl Makefile *.gif *.in $(distdir)

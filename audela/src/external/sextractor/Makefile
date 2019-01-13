# Makefile trampoline vers le repertoire sextractor situe dessous (heritage du passe)

.PHONY: build install clean distclean

build:
	$(MAKE) -C sextractor/linux

install:
	$(MAKE) -C sextractor/linux install

clean:
	$(MAKE) -C sextractor/linux clean

distclean: 
	$(MAKE) -C sextractor/linux distclean

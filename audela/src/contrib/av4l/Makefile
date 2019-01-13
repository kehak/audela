.PHONY: build install clean distclean

DIR = linux

install:

build:
	make -C $(DIR)

install: build
	make -C $(DIR) install

doc:
	make -C $(DIR) doc

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak

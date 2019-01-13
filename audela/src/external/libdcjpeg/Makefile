.PHONY: build install clean distclean

DIR = linux

build:
	make -C $(DIR)

install: build
	make -C $(DIR) install

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak

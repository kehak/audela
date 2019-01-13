.PHONY: build install clean distclean

DIR = fli-dist-1.104/libfli

build:
	make -C $(DIR)

install: build
	cp $(DIR)/libfli.h ../include
	cp $(DIR)/libfli.a ../lib

clean:
	rm  -f ../include/libfli.h
	rm  -f ../lib/libfli.a
	make -C $(DIR) clean
	
distclean: clean
	rm -f *~ *.bak

.PHONY: build install clean distclean

DIR = jpeg-6b

build:
	( cd $(DIR) ; chmod +x configure ; ./configure --prefix=`pwd`/../.. )
	make -C $(DIR)

install:
	make -C $(DIR) install-lib

clean:
	make -C $(DIR) clean

distclean: clean
	rm -f *~ *.bak

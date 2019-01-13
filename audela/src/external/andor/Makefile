.PHONY: build install clean distclean

build:

install:
	cp -f sdk_32bits_2_095_3/include/Atmcd32d.h ../include
	cp -f sdk_32bits_2_095_3/lib/atmcd32m.lib ../lib

clean:
	rm -f ../include/Atmcd32d.h
	rm -f ../lib/atmcd32m.lib

distclean: clean
	rm -f *~ *.bak

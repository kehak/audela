# Makefile stub: only for linux x86_64
.phony: build install clean distclean

build:

install:
	cp -fr ./include ../include/epix
	cp -f ./lib_64/libkxclib_x86_64.so ../lib/libkxclib_x86_64.so
	cp -f ./lib_64/libkxclib_x86_64.so ../../../bin

clean:
	rm -rf ../include/epix
	rm -f ../lib/libkxclib_x86_64.so
	rm -f ../../../bin/libkxclib_x86_64.so

distclean: clean

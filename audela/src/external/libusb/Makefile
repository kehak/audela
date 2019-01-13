.PHONY: build install clean distclean

build:

# install copy usb.h to ../include/linux
# libusb.so must be present in /lib or /usr/lib  or /usr/local/lib
install:
	mkdir -p  ../include/linux
	cp -f include/linux/usb.h ../include/linux

clean:
	rm -f ../include/linux/usb.h

distclean: clean
	rm -f *~ *.bak

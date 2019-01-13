.PHONY: build install clean distclean

# Verification architecture
os_version := $(shell sh -c 'uname -m 2>/dev/null || echo not')

lib_version := _32

ifneq ($(patsubst %64,%,$(os_version)),$(os_version))
        lib_version := _64
endif

build:

install:
	cp -f ./include/oscadine_driver.h ../include
	#--- je copie la librairie dynamique dans le repertoire des librairies pour l'edition de lien
	cp -f ./lib$(lib_version)/libOscadineDriver.so ../lib
	#--- je copie la librairie dynamique dans le repertoire des binaires pour l'execution
	cp -f ./lib$(lib_version)/libOscadineDriver.so ../../../bin

clean:
	rm -f ../include/oscadine_driver.h
	rm -f ../lib/libOscadineDriver.so
	rm -f ../../../bin/libOscadineDriver.so

distclean: clean
	rm -f *~ *.bak

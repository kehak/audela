.PHONY: build install clean distclean

include ../../Makefile.defs

lib_version := 1.4.73
os_version := $(shell sh -c 'uname -m 2>/dev/null || echo not')
os_archi := 32
ifneq ($(patsubst %64,%,$(os_version)),$(os_version))
	os_archi := 64
endif

build:

install:
	@if [ ! -d $(EXTINC) ]; then mkdir -p $(EXTINC); fi
	cp -f sbig/include/sbigudrv.h $(EXTINC)
	@if [ ! -d $(EXTLIB) ]; then mkdir -p $(EXTLIB); fi	
	$(CP) -f sbig/lib_$(os_archi)/libsbigudrv.$(lib_version).so  $(EXTLIB)/libsbigudrv.so
	$(CP) -f sbig/lib_$(os_archi)/libsbigudrv.$(lib_version).so  $(OUTPUTDIR)/libsbigudrv.so
	$(CP) -f sbig/lib_$(os_archi)/libsbigudrv.$(lib_version).a $(EXTLIB)/libsbigudrv.a

clean:
	$(RM) $(EXTINC)/sbigudrv.h
	$(RM) $(EXTLIB)/libsbigudrv.so
	$(RM) $(EXTLIB)/libsbigudrv.a
	$(RM) $(OUTPUTDIR)/libsbigudrv.so

distclean: clean
	$(RM) *~ *.bak

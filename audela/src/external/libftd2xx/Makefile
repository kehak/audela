.PHONY: build install clean distclean

# remarque : 
#     la librairie lftdxx doit s'appeler libftd2xx.so pour compiler audela
#     la librairie lftdxx doit s'appeler libftd2xx.so.0 pour executer audela

include ../../Makefile.defs

os_version := $(shell sh -c 'uname -m 2>/dev/null || echo not')
lib_version := _32
ifneq ($(patsubst %64,%,$(os_version)),$(os_version))
	lib_version := _64
endif
lib_cpu :=
ifneq ($(subst arm,,$(os_version)),$(os_version))
	lib_cpu := _arm
endif

build:

install:
	echo "os_version = $(os_version)"
	echo "lib_cpu = $(lib_cpu)"
	@if [ ! -d $(EXTINC)/linux ]; then mkdir -p $(EXTINC)/linux; fi
	$(CP) -f include/linux/1.1.12/*.h $(EXTINC)/linux
	@if [ ! -d $(EXTLIB) ]; then mkdir -p $(EXTLIB); fi
	$(CP) -f lib$(lib_cpu)$(lib_version)/libftd2xx.so.1.1.12    $(EXTLIB)/libftd2xx.so
	$(CP) -f lib$(lib_cpu)$(lib_version)/libftd2xx.so.1.1.12    $(OUTPUTDIR)/libftd2xx.so
	chmod +x $(OUTPUTDIR)/libftd2xx.so

clean:
	$(RM) $(EXTINC)/linux/ftd2xx.h
	$(RM) $(EXTINC)/linux/WinTypes.h
	$(RM) $(EXTLIB)/libftd2xx.so
	$(RM) $(OUTPUTDIR)/libftd2xx.so

distclean: clean
	$(RM) -f *~ *.bak


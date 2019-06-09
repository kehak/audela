# Generated automatically from Makefile.in by configure.
# ------------------------------------------------------------------------
#       Makefile for BLT distribution
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
#       Source and target installation directories
# ------------------------------------------------------------------------

prefix =	/usr
exec_prefix  =	/usr
srcdir =	.
bindir =	${exec_prefix}/bin
includedir =	${prefix}/include
libdir =	/usr/lib
version =	2.4
scriptdir =	$(prefix)/lib/blt$(version)

instdirs =	$(prefix) \
		$(exec_prefix) \
		$(bindir) \
		$(libdir) \
		$(includedir) \
		$(scriptdir)

# ------------------------------------------------------------------------
#       Don't edit anything beyond this point
# ------------------------------------------------------------------------

INSTALL =	/usr/bin/install -c
INSTALL_DATA =	${INSTALL} -m 644
INSTALL_ROOT =
SHELL =		/bin/sh
RM =		rm -f

subdirs =	src library

all:
	(cd src; $(MAKE) all)
	(cd library; $(MAKE) all)

install: install-all

install-all:
	(cd src; $(MAKE) install)
	(cd library; $(MAKE) install)

mkdirs:
	@for i in $(instdirs) ; do \
          if test -d $(INSTALL_ROOT)$$i ; then \
	    : ; \
	  else \
            echo " mkdir $(INSTALL_ROOT)$$i" ; \
            mkdir $(INSTALL_ROOT)$$i ; \
          fi ; \
        done

clean:
	(cd src; $(MAKE) clean)
	(cd library; $(MAKE) clean)
	$(RM) *.bak *\~ "#"* *pure* .pure*

GENERATED_FILES = \
	config.status config.cache config.log Makefile

distclean: clean
	$(RM) $(GENERATED_FILES)

# Generated automatically from Makefile.in by configure.
# ------------------------------------------------------------------------
# 	Makefile for library files and directories of BLT library
# ------------------------------------------------------------------------

prefix       = /usr
exec_prefix  = /usr
version      = 2.4
lib_prefix    = lib
srcdir       = .
libdir       = /usr/lib
scriptdir    = /home/jb/Compil/audela/audela/src/../lib/blt2.4

INSTALL      = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_ROOT = 
RM           = rm -f
SHELL        = /bin/sh

cursors = 	treeview.xbm \
		treeview_m.xbm

miscFiles     = \
		bltCanvEps.pro \
		bltGraph.pro \
		dnd.tcl \
		dragdrop.tcl \
		graph.tcl \
		hierbox.tcl \
		tabnotebook.tcl \
		tabset.tcl \
		treeview.tcl \
		tclIndex \
		$(cursors)

ddFiles      =  dd-color.tcl \
		dd-file.tcl \
		dd-number.tcl \
		dd-text.tcl \
		tclIndex

instdirs     =  $(prefix) $(exec_prefix) \
		$(libdir) $(prefix)/lib $(scriptdir) $(scriptdir)/dd_protocols

all: pkgIndex

pkgIndex: 
	rm -f pkgIndex.tcl
	sed -e 's/%VERSION%/$(version)/' $(srcdir)/pkgIndex.tcl.in | \
	sed -e 's/%LIB_PREFIX%/$(lib_prefix)/' | \
	sed -e 's;%LIB_DIR%;$(libdir);' > pkgIndex.tcl


install: mkdirs pkgIndex
	for i in $(ddFiles) ; do \
	    $(INSTALL_DATA) $(srcdir)/dd_protocols/$$i \
			$(INSTALL_ROOT)$(scriptdir)/dd_protocols ; \
	done 
	for i in $(miscFiles) ; do \
	    $(INSTALL_DATA) $(srcdir)/$$i $(INSTALL_ROOT)$(scriptdir) ; \
	done 
	$(INSTALL_DATA) pkgIndex.tcl $(scriptdir)

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
	$(RM) pkgIndex.tcl

distclean: clean
	$(RM) $(srcdir)/*.bak $(srcdir)/*\~ $(srcdir)/"#"* Makefile

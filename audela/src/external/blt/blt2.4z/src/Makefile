# Generated automatically from Makefile.in by configure.

# ------------------------------------------------------------------------
# 	Makefile for static version of BLT library
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# 	C Compiler options
# ------------------------------------------------------------------------

BLT_LIBRARY =	/home/jb/Compil/audela/audela/src/../lib/blt2.4
TCLLIBPATH   =	/usr/include/tcl8.6/tcl-private/unix/tcl8.6
CC =		gcc
CFLAGS =	-g -O2 -fPIC
SHLIB_LD =	gcc
DEFINES =	
EXTRA_CFLAGS =	-Wall
LDFLAGS =	 -Wl,-rpath,/usr/include/tcl8.6/tcl-private/unix:/usr/include/tcl8.6/tk-private/unix
version =	24

# ------------------------------------------------------------------------
# 	Source and targer installation directories
# ------------------------------------------------------------------------

bindir =	$(exec_prefix)/bin
exec_prefix =	/usr
incdir =	$(prefix)/include
libdir = 	/usr/lib
scriptdir =	$(exec_prefix)/lib

prefix =	/usr
srcdir =	.

instdirs =	$(prefix) $(exec_prefix) $(bindir) $(libdir) $(incdir)

# ------------------------------------------------------------------------
# 	Directories containing Tcl and Tk include files and libraries
# ------------------------------------------------------------------------

INCLUDES =	-I. -I$(srcdir)  -I/usr/include/tcl8.6/tk-private/generic -I/usr/include/tcl8.6

# ------------------------------------------------------------------------
#       Libraries directives for Tcl, Tk, X11, and BLT
# ------------------------------------------------------------------------

LIBS =		 -L/usr/include/tcl8.6/tk-private/unix -ltk8.6 -L/usr/include/tcl8.6/tcl-private/unix -ltcl8.6 -lX11 -lm -lnsl  -ldl
TCL_ONLY_LIBS = -L/usr/include/tcl8.6/tcl-private/unix -ltcl8.6 -lm -lnsl  -ldl

# ------------------------------------------------------------------------
# 	You don't need to edit anything beyond this point
# ------------------------------------------------------------------------

N_OBJS =	bltTed.o
V3_OBJS =	bltTri.o bltGrMt.o

TK_OBJS =	tkButton.o tkFrame.o bltScrollbar.o

GRAPH_OBJS =	bltGrAxis.o \
		bltGrBar.o \
		bltGrElem.o \
		bltGrGrid.o \
		bltGrHairs.o \
		bltGrLegd.o \
		bltGrLine.o \
		bltGrMarker.o \
		bltGrMisc.o \
		bltGrPen.o \
		bltGrPs.o \
		bltGraph.o

TCL_ONLY_OBJS =	bltAlloc.o \
		bltArrayObj.o \
		bltBgexec.o \
		bltChain.o \
		bltDebug.o \
		bltHash.o \
		bltList.o \
		bltNsUtil.o \
		bltParse.o \
		bltPool.o \
		bltSpline.o \
		bltSwitch.o \
		bltTree.o \
		bltTreeCmd.o \
		bltUnixPipe.o \
		bltUtil.o \
		bltVector.o \
		bltVecMath.o \
		bltVecCmd.o \
		bltVecObjCmd.o \
		bltWatch.o

OBJS =		$(GRAPH_OBJS) \
		$(TCL_ONLY_OBJS) \
		bltBeep.o \
		bltBind.o \
		bltBitmap.o \
		bltBusy.o \
		bltCanvEps.o \
		bltColor.o \
		bltConfig.o \
		bltContainer.o \
		bltCutbuffer.o \
		bltDragdrop.o \
		bltHierbox.o \
		bltHtext.o \
		bltImage.o \
		bltUnixImage.o \
		bltPs.o \
		bltTable.o \
		bltTabnotebook.o \
		bltTabset.o \
		bltText.o \
		bltTile.o \
		bltTreeView.o \
		bltTreeViewCmd.o \
		bltTreeViewEdit.o \
		bltTreeViewColumn.o \
		bltTreeViewStyle.o \
		bltUnixDnd.o \
		bltWindow.o \
		bltObjConfig.o \
		bltWinop.o \
		$(TK_OBJS) $(N_OBJS)

# GNU Make-specific macro
SRCS =		$(patsubst %.o,$(srcdir)/%.c,$(OBJS))

bltwish =	bltwish
bltsh =		bltsh
headers =	$(srcdir)/blt.h \
		$(srcdir)/bltBind.h \
		$(srcdir)/bltChain.h \
		bltHash.h \
		$(srcdir)/bltList.h \
		$(srcdir)/bltPool.h \
		$(srcdir)/bltTree.h \
		$(srcdir)/bltVector.h

lib_a =		libBLT.a
libvers_a =	libBLT$(version).a
tcl_only_lib_a =  libBLTlite.a
tcl_only_libvers_a = libBLTlite$(version).a
lib_so =		libBLT$(version).so

CC_SWITCHES =	$(EXTRA_CFLAGS) $(CFLAGS) $(DEFINES) $(INCLUDES)
INSTALL =	/usr/bin/install -c
INSTALL_DATA =	${INSTALL} -m 644
INSTALL_ROOT =
RANLIB =	ranlib
SHELL =		/bin/sh
AR =		ar rc
RM =		rm -f
LINT =		lint
LINTFLAGS =	-axhbns
XREF =		cxref
XREFFLAGS =	-dltR
LN_S =		ln -s

### all: $(bltsh) $(bltwish) build_shared
all: $(lib_so)

$(bltwish): $(lib_a) $(srcdir)/bltUnixMain.c
	$(RM) $(bltwish)
	$(CC) $(CC_SWITCHES) $(LDFLAGS) -o $(bltwish) \
		-DTCLLIBPATH=\"$(TCLLIBPATH)\" \
		$(srcdir)/bltUnixMain.c $(lib_a) $(LIBS)

$(bltsh): $(tcl_only_lib_a) $(srcdir)/bltUnixMain.c
	$(RM) $(bltsh)
	$(CC) $(CC_SWITCHES) $(LDFLAGS) -DTCL_ONLY -o $(bltsh) \
		-DTCLLIBPATH=\"$(TCLLIBPATH)\" \
		$(srcdir)/bltUnixMain.c $(tcl_only_lib_a) $(TCL_ONLY_LIBS)

$(lib_a): $(OBJS) $(srcdir)/bltInit.c
	$(CC) -c $(CC_SWITCHES) -DBLT_LIBRARY=\"$(BLT_LIBRARY)\" \
		$(srcdir)/bltInit.c
	$(RM) $@
	$(AR) $@ $(OBJS) bltInit.o
	$(RANLIB) $@

$(lib_so): $(OBJS)
	$(CC) -c $(CC_SWITCHES) -DBLT_LIBRARY=\"$(BLT_LIBRARY)\" \
		$(srcdir)/bltInit.c
	$(RM) $@
	$(SHLIB_LD) -shared $(SHLIB_LD_FLAGS) -o $@ bltInit.o $(OBJS) $(LIBS) $(EXTRA_SHLIB_FLAGS)

$(tcl_only_lib_a):  $(TCL_ONLY_OBJS) $(srcdir)/bltInit.c
	$(CC) -c $(CC_SWITCHES) -DTCL_ONLY -DBLT_LIBRARY=\"$(BLT_LIBRARY)\" \
		$(srcdir)/bltInit.c
	$(RM) $@
	$(AR) $@ $(TCL_ONLY_OBJS) bltInit.o
	$(RANLIB) $@

###install: mkdirs install-lib install-demo install-headers
install: install-so

install-demo: $(bltwish) $(bltsh)
	$(INSTALL) -m 0755 $(bltwish) $(INSTALL_ROOT)$(bindir)
	$(INSTALL) -m 0755 $(bltsh) $(INSTALL_ROOT)$(bindir)

install-lib: $(lib_a) $(tcl_only_lib_a)
	$(INSTALL_DATA) $(lib_a) $(INSTALL_ROOT)$(libdir)/$(libvers_a)
	(cd $(INSTALL_ROOT)$(libdir); $(RM) $(lib_a) ; $(LN_S) $(libvers_a) $(lib_a))
	$(RANLIB) $(INSTALL_ROOT)$(libdir)/$(libvers_a)
	$(INSTALL_DATA) $(tcl_only_lib_a) $(INSTALL_ROOT)$(libdir)/$(tcl_only_libvers_a)
	(cd $(INSTALL_ROOT)$(libdir); $(RM) $(tcl_only_lib_a) ; $(LN_S) $(tcl_only_libvers_a) $(tcl_only_lib_a))
	$(RANLIB) $(INSTALL_ROOT)$(libdir)/$(tcl_only_libvers_a)

install-so: $(lib_so)
	@if ! test -d $(BLT_LIBRARY) ; then \
		mkdir $(BLT_LIBRARY) ; \
	fi
	cp $(lib_so) $(BLT_LIBRARY)

mkdirs:
	@for i in $(instdirs) ; do \
          if test -d $(INSTALL_ROOT)$$i ; then \
            : ; \
          else \
            echo " mkdir $(INSTALL_ROOT)$$i" ; \
            mkdir $(INSTALL_ROOT)$$i ; \
          fi ; \
        done

install-headers:
	@for i in $(headers) ; do \
	    echo "installing $$i..." ; \
	    $(INSTALL_DATA) -m 0444 $$i $(INSTALL_ROOT)$(incdir) ; \
	done

lint:
	$(LINT) $(LINTFLAGS) $(DEFINES) $(INCLUDES) $(SRCS)

xref:
	$(XREF) $(XREFFLAGS) $(DEFINES) $(INCLUDES) $(SRCS)

clean:
	$(RM) $(OBJS) bltInit.o $(lib_a) $(tcl_only_lib_a) \
		$(bltsh)* $(bltwish)* *pure* .pure*

distclean: clean
	$(RM) $(srcdir)/*.bak $(srcdir)/*\~ $(srcdir)/"#"*  Makefile
	$(RM) bltConfig.h Makefile TAGS

.c.o:
	$(CC) -c $(CC_SWITCHES) $<

PUREFLAGS=
pure: $(lib_a)
	$(PURIFYHOME)/purify $(PUREFLAGS) $(CC) $(CC_SWITCHES) \
		$(srcdir)/bltUnixMain.c -o bltwish $(lib_a) $(LIBS)

QUANTIFYFLAGS=
quant: $(lib_a)
	$(QUANTIFYHOME)/quantify $(QUANTIFYFLAGS) $(CC) $(CC_SWITCHES) \
		$(srcdir)/bltUnixMain.c -o bltwish $(lib_a) $(LIBS)

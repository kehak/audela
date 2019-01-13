          ============================
             HOW TO COMPILE AUDELA
          ============================


That files explain how to compile sources of AudeLA.

N.B. source files are provided only in the Linux archive
distribution of AudeLA but they are the same for the
Win32 platforms.

Use the AudeLA-dev mailing list if you encouter any problem.

1) Copy files from archive audela-1.2.3-linux-ix86.zip
======================================================

Firstly, you must extract files from the audela-1.2.3-linux-ix86.zip archive.

audela-1.2.3/audace
audela-1.2.3/binlinux
audela-1.2.3/catalogues
audela-1.2.3/dev
audela-1.2.3/doc_html
audela-1.2.3/doc_pdf
audela-1.2.3/images
audela-1.2.3/lib
audela-1.2.3/palette
audela-1.2.3/profil
audela-1.2.3/scripts
audela-1.2.3/test
audela-1.2.3/tutorial
audela-1.2.3/tutorial_ethernaude

The folder dev contains all the source files of AudeLA.

In the case of Win32, first, install AudeLA with the
Win32 distribution (audela-1.2.3.exe). Then, copy ONLY
the dev folder of the Linux distribution in the Win32
audela-1.2.3 folder.

2) Description of files in the dev folder
=========================================

subfolders of audela-1.2.3/dev can be grouped by categories :

categories | folders

BASE       = libaudela libgzip libmc libtt main
LIBCAMS    = libaudine libcagire libcookbook libethernaude libhisis libkitty libstarlight libwebcam libsbig libaudinet libcamth libsynonyme
LIBTELS    = liblx200 libcompad liblxnet libaudecom libavrcom libouranos libtemma libmcmt libtelscript
EXTRA      = librgb libgsltcl libjm libak
DRVCAMS    = ethernaude

BASE : Mandatory files to compile a core-version of AudeLA
LIBCAMS : AudeLA/Tcl camera drivers
LIBTELS : AudeLA/Tcl telescope drivers
EXTRA : Some miscelaneous AudeLA/Tcl librairies that enrich AudeLA
DRVCAMS : Complementary libraries for camera drivers

audela-1.2.3/dev/common : common source files for all categories.
audela-1.2.3/dev/libxx : an example AudeLA/Tcl library.
audela-1.2.3/dev/sextractor : Sextractor software for star analysis.

N.B. A Linux libgsltcl compilation requires that libgsl is installed.
     If it is not the case, download it at http://sources.redhat.com/gsl/
     A Win32 libgsl compilation requires to include 4 .lib files (about
     20 Mo !) in the folder dev/libgsltcl/libgsl. These files are in the
     file special-1.2.3.zip.

3) Conversion of source file format
===================================

In order to be sure that source files will be compiled without problem
on a Linux platform, you must execute the Tcl script file dos2unix.tcl
provided in the folder audela-1.2.3/dev :

> is the Linux console prompt
% is the Tclsh prompt :

> cd ~/audela-1.2.3/dev
> tclsh
% source dos2unix.tcl
% exit

N.B. No operation is needed for Windows.

4) Compilation of AudeLA :
==========================

4.1) Linux :
------------

Be sure you have the Tcl/Tk 8.4 version (or higher) installed.

You can compile all the files with the following procedure :
     > cd ~/audela-1.2.3/dev
     > autoconf configure.in >configure
     > chmod +x configure
     > ./configure
     > make

If the autoconf procedure aborted, you can try that :
     > cd ~/audela-1.2.3/dev
     > make -f Makefile.old

N.B. With Linux, if you use a Red-Hat distribution, the
     compilation may abort caused by an error in "system.h".
     To avoid the error, edit the file
     ~/audela-1.2.3/dev/common/system.h
     Comment the line
     #include <asm/system.h>
     Uncomment the line
     #include "/usr/i386-glibc21-linux/include/asm/system.h"
     Save the system.h file and compile. It should be better !

N.B. For audela-1.2.3/dev/libgsl, you must have the libgsl
     installed for Linux and you must have .lib files for
     Win32. For Linux, verify that /usr/lib/libgsl.so
     and /usr/lib/libgslcblas.so exist (else make a link).

N.B. For Linux, you should to install Tcl-Extension named
     BLT for specific functions in the Aud'ACE interface.

     http://www.cs.cornell.edu/zeno/projects/tcldp/

N.B. For Linux, you might install Tcl-Extension named
     TclDP if you want to use AudeLA in a Network context :

     http://www.tcltk.com/blt

4.2) Win32 :
------------

The file audela-1.2.3/dev/audela.dsw is the VC++ 6.0 project
that allows you to compile all the librairies.

N.B. For audela-1.2.3/dev/libgsl, you must have .lib files for
     Win32 (see http://sources.redhat.com/gsl/).

5) Execute AudeLA with Linux
============================

Before executing AudeLA for a first time, don't
forget to put the correct environment variable
from a Unix console :

> typeset -x LD_LIBRARY_PATH=$HOME/audela-1.2.3/binlinux

Then

> cd ~/audela-1.2.3/binlinux
> ./audela &

Choice Aud'ACE interface for example.
You can load the image audela-1.2.3/images/m57.fit.

An alternative way to declare LD_LIBRARY_PATH is
to add the line $HOME/audela-1.2.3/binlinux in
the file /etc/ld.so.conf (if you have root privileges).


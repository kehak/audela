# Microsoft Developer Studio Project File - Name="sextractor" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=sextractor - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE
!MESSAGE NMAKE /f "sextractor.mak".
!MESSAGE
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE NMAKE /f "sextractor.mak" CFG="sextractor - Win32 Release"
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "sextractor - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "sextractor - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "sextractor - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "__STDC__" /YX /FD /c
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386 /out:"..\..\..\..\..\bin\sex.exe"

!ELSEIF  "$(CFG)" == "sextractor - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\Debug"
# PROP BASE Intermediate_Dir ".\Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\Debug"
# PROP Intermediate_Dir ".\Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "__STDC__" /FR /YX /FD /c
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /out:"..\..\..\..\..\bin\sex.exe"

!ENDIF

# Begin Target

# Name "sextractor - Win32 Release"
# Name "sextractor - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;for;f90"
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\analyse.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\assoc.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\astrom.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\back.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\bpro.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\catout.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\cel.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\check.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\clean.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\extract.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\field.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\filter.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitsbody.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitscat.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitscheck.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitscleanup.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitsconv.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitshead.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitskey.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitsmisc.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitsread.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitstab.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitsutil.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\fits\fitswrite.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\flag.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\graph.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\growth.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\image.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\interpolate.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\lin.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\main.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\makeit.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\manobjlist.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\misc.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\neurro.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\pc.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\photom.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\plist.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\poly.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\prefs.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\proj.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\psf.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\readimage.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\refine.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\retina.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\scan.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\som.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\sph.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\tnx.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\wcs.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\wcs\wcstrig.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\weight.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\winpos.c"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\xml.c"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\assoc.h"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\astrom.h"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\back.h"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\bpro.h"
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\wcs\cel.h
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\check.h"
# End Source File
# Begin Source File

SOURCE="..\sextractor-2.5.0\src\clean.h"
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\extract.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\field.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\filter.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\fitscat.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\flag.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\growth.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\image.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\interpolate.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\wcs\lin.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\neurro.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\photom.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\plist.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\poly.h
# End Source File
# Begin Source File

SOURCE=..\ssextractor-2.5.0\rc\prefs.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\wcs\proj.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\psf.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\retina.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\som.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\wcs\wcs.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\wcs\wcstrig.h
# End Source File
# Begin Source File

SOURCE=..\sextractor-2.5.0\src\weight.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project

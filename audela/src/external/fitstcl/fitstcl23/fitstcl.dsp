# Microsoft Developer Studio Project File - Name="fitstcl" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=fitstcl - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "fitstcl.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "fitstcl.mak" CFG="fitstcl - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "fitstcl - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "fitstcl - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "fitstcl - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
F90=df.exe
# ADD BASE F90 /compile_only /include:"Release/" /dll /nologo /warn:nofileopt
# ADD F90 /compile_only /include:"Release/" /dll /nologo /warn:nofileopt
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "FITSTCL_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "FITSTCL_EXPORTS" /D "__WIN32__" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib tcl83.lib /nologo /dll /machine:I386 /out:"fitstcl.dll"

!ELSEIF  "$(CFG)" == "fitstcl - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
F90=df.exe
# ADD BASE F90 /check:bounds /compile_only /debug:full /include:"Debug/" /dll /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD F90 /browser /check:bounds /compile_only /debug:full /include:"Debug/" /dll /nologo /traceback /warn:argument_checking /warn:nofileopt
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "FITSTCL_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "FITSTCL_EXPORTS" /D "__WIN32__" /FR /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo /o"fitstcl.bsc"
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib tcl83d.lib /nologo /dll /debug /machine:I386 /out:"fitstcl.dll" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "fitstcl - Win32 Release"
# Name "fitstcl - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;f90;for;f;fpp"
# Begin Source File

SOURCE=.\cfitsio\buffers.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\cfileio.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\checksum.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\compress.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\drvrfile.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\drvrmem.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\editcol.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\edithdu.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\eval_f.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\eval_l.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\eval_y.c
# End Source File
# Begin Source File

SOURCE=.\fitsCmds.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\fitscore.c
# End Source File
# Begin Source File

SOURCE=.\fitsInit.c
# End Source File
# Begin Source File

SOURCE=.\fitsIO.c
# End Source File
# Begin Source File

SOURCE=.\fitsTcl.c
# End Source File
# Begin Source File

SOURCE=.\fitstcl.def
# End Source File
# Begin Source File

SOURCE=.\fitsUtils.c
# End Source File
# Begin Source File

SOURCE=.\fvTcl.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcol.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcolb.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcold.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcole.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcoli.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcolj.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcolk.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcoll.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcols.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcolui.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcoluj.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getcoluk.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\getkey.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\group.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\grparser.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\histo.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\imcompress.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\iraffits.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\listhead.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\modkey.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\pliocomp.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcol.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcolb.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcold.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcole.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcoli.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcolj.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcolk.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcoll.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcols.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcolu.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcolui.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcoluj.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putcoluk.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\putkey.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\quantize.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\region.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\ricecomp.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\scalnull.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\swapproc.c
# End Source File
# Begin Source File

SOURCE=.\cfitsio\wcsutil.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\cfitsio\cfortran.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\compress.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\drvrsmem.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\eval_defs.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\eval_tab.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\f77_wrap.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\fitsio.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\fitsio2.h
# End Source File
# Begin Source File

SOURCE=.\fitsTcl.h
# End Source File
# Begin Source File

SOURCE=.\fitsTclInt.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\group.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\grparser.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\imcompress.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\longnam.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\pctype.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\region.h
# End Source File
# Begin Source File

SOURCE=.\cfitsio\ricecomp.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project

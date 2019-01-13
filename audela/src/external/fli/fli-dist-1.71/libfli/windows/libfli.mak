# Microsoft Developer Studio Generated NMAKE File, Based on libfli.dsp
!IF "$(CFG)" == ""
CFG=libfli - Win32 Debug
!MESSAGE No configuration specified. Defaulting to libfli - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "libfli - Win32 Release" && "$(CFG)" != "libfli - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "libfli.mak" CFG="libfli - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "libfli - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "libfli - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libfli - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

ALL : "$(OUTDIR)\libfli.dll"


CLEAN :
	-@erase "$(INTDIR)\libfli-camera-parport.obj"
	-@erase "$(INTDIR)\libfli-camera-usb.obj"
	-@erase "$(INTDIR)\libfli-camera.obj"
	-@erase "$(INTDIR)\libfli-debug.obj"
	-@erase "$(INTDIR)\libfli-filter-focuser.obj"
	-@erase "$(INTDIR)\libfli-mem.obj"
	-@erase "$(INTDIR)\libfli-serial.obj"
	-@erase "$(INTDIR)\libfli-usb.obj"
	-@erase "$(INTDIR)\libfli-windows-parport.obj"
	-@erase "$(INTDIR)\libfli-windows.obj"
	-@erase "$(INTDIR)\libfli.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\libfli.dll"
	-@erase "$(OUTDIR)\libfli.exp"
	-@erase "$(OUTDIR)\libfli.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MT /W3 /GX /O2 /I ".\\" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBFLI_EXPORTS" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\libfli.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib wsock32.lib /nologo /dll /incremental:no /pdb:"$(OUTDIR)\libfli.pdb" /machine:I386 /def:".\libfli.def" /out:"$(OUTDIR)\libfli.dll" /implib:"$(OUTDIR)\libfli.lib" 
DEF_FILE= \
	".\libfli.def"
LINK32_OBJS= \
	"$(INTDIR)\libfli-camera-parport.obj" \
	"$(INTDIR)\libfli-camera-usb.obj" \
	"$(INTDIR)\libfli-camera.obj" \
	"$(INTDIR)\libfli-debug.obj" \
	"$(INTDIR)\libfli-filter-focuser.obj" \
	"$(INTDIR)\libfli-mem.obj" \
	"$(INTDIR)\libfli-usb.obj" \
	"$(INTDIR)\libfli-windows-parport.obj" \
	"$(INTDIR)\libfli-windows.obj" \
	"$(INTDIR)\libfli.obj" \
	"$(INTDIR)\libfli-serial.obj"

"$(OUTDIR)\libfli.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

ALL : "$(OUTDIR)\libfli.dll" "$(OUTDIR)\libfli.bsc"


CLEAN :
	-@erase "$(INTDIR)\libfli-camera-parport.obj"
	-@erase "$(INTDIR)\libfli-camera-parport.sbr"
	-@erase "$(INTDIR)\libfli-camera-usb.obj"
	-@erase "$(INTDIR)\libfli-camera-usb.sbr"
	-@erase "$(INTDIR)\libfli-camera.obj"
	-@erase "$(INTDIR)\libfli-camera.sbr"
	-@erase "$(INTDIR)\libfli-debug.obj"
	-@erase "$(INTDIR)\libfli-debug.sbr"
	-@erase "$(INTDIR)\libfli-filter-focuser.obj"
	-@erase "$(INTDIR)\libfli-filter-focuser.sbr"
	-@erase "$(INTDIR)\libfli-mem.obj"
	-@erase "$(INTDIR)\libfli-mem.sbr"
	-@erase "$(INTDIR)\libfli-serial.obj"
	-@erase "$(INTDIR)\libfli-serial.sbr"
	-@erase "$(INTDIR)\libfli-usb.obj"
	-@erase "$(INTDIR)\libfli-usb.sbr"
	-@erase "$(INTDIR)\libfli-windows-parport.obj"
	-@erase "$(INTDIR)\libfli-windows-parport.sbr"
	-@erase "$(INTDIR)\libfli-windows.obj"
	-@erase "$(INTDIR)\libfli-windows.sbr"
	-@erase "$(INTDIR)\libfli.obj"
	-@erase "$(INTDIR)\libfli.sbr"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\libfli.bsc"
	-@erase "$(OUTDIR)\libfli.dll"
	-@erase "$(OUTDIR)\libfli.exp"
	-@erase "$(OUTDIR)\libfli.ilk"
	-@erase "$(OUTDIR)\libfli.lib"
	-@erase "$(OUTDIR)\libfli.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Oi /I ".\\" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "LIBFLI_EXPORTS" /FR"$(INTDIR)\\" /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\libfli.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\libfli-camera-parport.sbr" \
	"$(INTDIR)\libfli-camera-usb.sbr" \
	"$(INTDIR)\libfli-camera.sbr" \
	"$(INTDIR)\libfli-debug.sbr" \
	"$(INTDIR)\libfli-filter-focuser.sbr" \
	"$(INTDIR)\libfli-mem.sbr" \
	"$(INTDIR)\libfli-usb.sbr" \
	"$(INTDIR)\libfli-windows-parport.sbr" \
	"$(INTDIR)\libfli-windows.sbr" \
	"$(INTDIR)\libfli.sbr" \
	"$(INTDIR)\libfli-serial.sbr"

"$(OUTDIR)\libfli.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib wsock32.lib /nologo /version:0.0 /dll /incremental:yes /pdb:"$(OUTDIR)\libfli.pdb" /debug /machine:I386 /def:".\libfli.def" /out:"$(OUTDIR)\libfli.dll" /implib:"$(OUTDIR)\libfli.lib" /pdbtype:sept 
DEF_FILE= \
	".\libfli.def"
LINK32_OBJS= \
	"$(INTDIR)\libfli-camera-parport.obj" \
	"$(INTDIR)\libfli-camera-usb.obj" \
	"$(INTDIR)\libfli-camera.obj" \
	"$(INTDIR)\libfli-debug.obj" \
	"$(INTDIR)\libfli-filter-focuser.obj" \
	"$(INTDIR)\libfli-mem.obj" \
	"$(INTDIR)\libfli-usb.obj" \
	"$(INTDIR)\libfli-windows-parport.obj" \
	"$(INTDIR)\libfli-windows.obj" \
	"$(INTDIR)\libfli.obj" \
	"$(INTDIR)\libfli-serial.obj"

"$(OUTDIR)\libfli.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("libfli.dep")
!INCLUDE "libfli.dep"
!ELSE 
!MESSAGE Warning: cannot find "libfli.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "libfli - Win32 Release" || "$(CFG)" == "libfli - Win32 Debug"
SOURCE="..\libfli-camera-parport.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-camera-parport.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-camera-parport.obj"	"$(INTDIR)\libfli-camera-parport.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE="..\libfli-camera-usb.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-camera-usb.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-camera-usb.obj"	"$(INTDIR)\libfli-camera-usb.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE="..\libfli-camera.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-camera.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-camera.obj"	"$(INTDIR)\libfli-camera.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=".\libfli-debug.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-debug.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-debug.obj"	"$(INTDIR)\libfli-debug.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE="..\libfli-filter-focuser.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-filter-focuser.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-filter-focuser.obj"	"$(INTDIR)\libfli-filter-focuser.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE="..\libfli-mem.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-mem.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-mem.obj"	"$(INTDIR)\libfli-mem.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 

SOURCE=".\libfli-serial.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-serial.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-serial.obj"	"$(INTDIR)\libfli-serial.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE=".\libfli-usb.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-usb.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-usb.obj"	"$(INTDIR)\libfli-usb.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE=".\libfli-windows-parport.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-windows-parport.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-windows-parport.obj"	"$(INTDIR)\libfli-windows-parport.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE=".\libfli-windows.c"

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli-windows.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli-windows.obj"	"$(INTDIR)\libfli-windows.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

SOURCE=..\libfli.c

!IF  "$(CFG)" == "libfli - Win32 Release"


"$(INTDIR)\libfli.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "libfli - Win32 Debug"


"$(INTDIR)\libfli.obj"	"$(INTDIR)\libfli.sbr" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)


!ENDIF 


!ENDIF 


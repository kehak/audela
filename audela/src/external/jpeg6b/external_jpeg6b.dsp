# Microsoft Developer Studio Project File - Name="external_jpeg6b" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=external_jpeg6b - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE
!MESSAGE NMAKE /f "external_jpeg6b.mak".
!MESSAGE
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE NMAKE /f "external_jpeg6b.mak" CFG="external_jpeg6b - Win32 Debug"
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "external_jpeg6b - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "external_jpeg6b - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "external_jpeg6b - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Cmd_Line "NMAKE /f external_jpeg6b.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "external_jpeg6b.exe"
# PROP BASE Bsc_Name "external_jpeg6b.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Cmd_Line "install.bat"
# PROP Rebuild_Opt "-a"
# PROP Target_File "..\lib\jpeg.lib"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "external_jpeg6b - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Cmd_Line "NMAKE /f external_jpeg6b.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "external_jpeg6b.exe"
# PROP BASE Bsc_Name "external_jpeg6b.bsc"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Cmd_Line "nmake -nologo -f makefile.vc OPTS=symbols TCLDIR=..\..\..\tk8.4.12 MSVCDIR=IDE"
# PROP Rebuild_Opt "-a"
# PROP Target_File "Debug\external_jpeg6b26d.dll"
# PROP Bsc_Name ""
# PROP Target_Dir ""

!ENDIF

# Begin Target

# Name "external_jpeg6b - Win32 Release"
# Name "external_jpeg6b - Win32 Debug"

!IF  "$(CFG)" == "external_jpeg6b - Win32 Release"

!ELSEIF  "$(CFG)" == "external_jpeg6b - Win32 Debug"

!ENDIF

# Begin Source File

SOURCE=.\install.bat
# End Source File
# Begin Source File

SOURCE=".\jpeg-6b\makelib.ds"
# End Source File
# End Target
# End Project

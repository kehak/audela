================================
History and Installation Notes||
================================


Installation
============
To install the bc635PCI driver and demo software, follow these steps:

Windows 9x:
===========
1) Use the OEMSETUP.INF file when the Plug&Play asks for the bc635PCI Driver

2) Copy the files "bc637pci.dll", and "bc_int.dll" to: <drive letter>\Windows\system\

3) Add the registry keys by double clicking on the file "bc635Pci9x.reg" 

4) Reboot the system 

5) Compile the sample program under the \\Example Programs\bc635pciCpp folder

6) Run the program "bc635cpp.exe" to test your installation.


Windows NT:
===================
1) Copy the file "WinRT.sys" to: <drive letter>\Winnt\system32\drivers\

2) Copy the files "bc637pci.dll", and "bc_int.dll" to: <drive letter>\Winnt\system32\

3) Add the registry keys by double clicking on the file "bc635PciNT.reg" 

4) Reboot the system 

5) Compile the sample program under the \\Example Programs\bc635pciCpp folder

6) Run the program "bc635cpp.exe" to test your installation. 

Windows 2K and XP:
===================
1) Use the DatumPci.INF file when the Plug&Play asks for the bc635PCI Driver

2) Copy the file "Wrtdev.sys" to: <drive letter>\Winnt\system32\drivers\

3) Copy the files "bc637pci.dll", and "bc_int.dll" to: <drive letter>\Winnt\system32\

4) Add the registry keys by double clicking on the file "bc635PciNT.reg" 

5) Reboot the system 

5) Compile the sample program under the \\Example Programs\bc635pciCpp folder

6) Run the program "bc635cpp.exe" to test your installation. 


History
=======
March 2004 Version 7.1.0
========================
- Updated the Installer to InstallShield 6.31 to fix XP problems
- Updated the DLLs and demo programs to version 7.1.0

July 2003 Version 7.0.0
========================
- Support Plug & Play for Windows 2K/XP using INF.
- Updated installer to include INF file for Windows 2K/XP.
- Added SDK functions to support multiple interrupt souces.
- Added a GPS sample source code to the SDK.
- Updated the DLLs and the demo programs to version 7.0.0
- Updated software branding to Symmetricom.

March 2003 Version 6.0.0
========================
- Fixed the hour offset due to daylight savings
- Added a history file to the about dialog box
- Updated the DLLs and the demo programs to version 6.0.0

March 2000 Version 5.0.0
========================
- Changed interrupt implementation from Windows Messaging implementation to Event 
  Based implementation
- Updated demonstration program bc635cpp to use event based instead of
  message based interrupts
- Added event based interrupt sample program IntrSamp
- Updated the demonstration program bc635cpp to allow multiple cards of different 
  Datum hardware to run on the same machine at the same time
- Add delay in bc637pci DLL when accessing the DPRAM for faster machines
- Updated the DLLs and the demo programs to version 5.0.0


November 2000 Version 4.4.0
===========================
- Added Windows 2000 Support
- Added ACE II GPS packet support
- Updated installer InstallShield from V5.5 to V6.2 for Windows
  2000 compliance
- Updated the installer to clean-up the registry when performing uninstall


December 1999 Version 3.6.0
===========================
- Added 1/2 hour support to the Local and Generator time offset 
- File versions, DLLs and executables to version 3.6.0

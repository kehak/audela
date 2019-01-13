$Id: readme.txt,v 1.1 2011-02-23 14:18:15 myrtillelaas Exp $


Installing the Meinberg Driver Package for Windows
==================================================

The available Meinberg Driver Software for Windows can be used under 
Windows NT as well as Windows 2000/XP/Server 2003/Vista etc. to 
synchronize the system time of the computer. The package supports both 
the 32 bit and 64 bit version of the operating systems mentioned above.

All binaries in the package include an authenticated digital signature
to fulfill even the requirements of Windows Vista x64.
  
The driver supports all Meinberg PC plug-in boards with PCI, PCI Express 
(PCIe) or ISA bus. Alternatively the driver can receive the Meinberg 
standard time string from an external radio clock which is attached to a 
serial port of the computer (COM port). 
With the exception of Windows NT the driver package also supports Meinberg 
radio clocks with USB interface.

Detailed information on the program can be found in the online reference 
of the monitor program MbgMon. 

The synchronized time can be distributed on the network using the freely 
available program package NTP:  
http://www.meinberg.de/english/info/ntp.htm 


Upgrading an Existing Installation
----------------------------------

If an older version of the driver software has already been installed 
then the new version can simply be installed over the existing version.
If no program except the time adjustment service (e.g monitor program, 
3rd party application) accesses the board during the update then 
in the normal case there's not even a reboot required.



PCI/PCIe/USB devices under Windows 2000/XP and newer (PNP operating systems) 
---------------------------------------------------------------------------

- If the device has already been installed then the hardware 
  wizard is started automatically after the computer has booted,
  asking to install a new device. If the driver software has already 
  been installed the hardware wizard should be continued to
  finish the installation.

- If the driver software has not yet been installed, cancel execution
  of the hardware wizard.

- Run the installer to install the driver package.

- Select the installation directory for the software, the default is:
  C:\Program Files\Meinberg\MbgMon

- If the device has not yet been installed, shut down the computer and 
  install the board in a free slot or plug-in the USB device. After the 
  computer has rebooted the hardware assistant starts automatically and 
  you should proceed as described above.

- Run the monitor program MbgMon to configure the radio clock, check 
  its status, and activate the time adjustment service.  



ISA boards under Windows 2000/XP and newer (PNP operating systems)
------------------------------------------------------------------ 

- Shut down the computer and install the board in a free slot before
  you install the driver software.

- After the computer has rebooted run the installer to install 
  the driver package.

- Select the installation directory for the software, the default is:
  C:\Program Files\Meinberg\MbgMon

- Since Da eine ISA-Karte nicht automatisch erkannt wird, wird am Ende der
  Installation eine Meldung angezeigt, dass keine Funkuhr erkannt
  wurde. Die Meldung bietet die Möglichkeit, gleich im Anschluß
  an die Treiberinstallation den Hardware-Assistenten zu starten, 
  um die Karte manuell hinzuzufügen.

- Since a new ISA card is not detected automatically, a message will 
  appear at the end of the driver installation saying that no card 
  has been found. You need to run the hardware wizard to add the 
  new ISA card manually, and you can launch the hardware wizard 
  automatically after the driver installation has finished if you 
  confirm to do so.

- Start the hardware wizard. 

- It may be required to select the option "Add new hardware device",
  then the hardware wizard looks for plug and play devices. Since the 
  ISA card is not a Plug and Play device, it is not detected 
  automatically.

- Choose the option "Add a new hardware device" again to see a list of 
  device types. Select the type "Radio Clock" and the wizard shows all 
  supported radio clock types. Choose the type of ISA board you have.

- If the device type "Radio Clock" is not listed then you have to select
  the entry "Show all devices" first and click to continue. A list of 
  manufacturers and devices made by those manufacturers will be presented.
  Under manufacturer "Meinberg" you can select the type of card you are
  currently installing.

- If there are no resource conflicts then the driver will be installed
  and the wizard will terminate. Otherwise you are requested to change 
  resources for the ISA board.  

- Assignment of resources can be changed on the tab labeled "resources".  
  The standard setting for the port base address is 300 hex which 
  corresponds to the factory settings of the card. Shut down the 
  computer and configure the selected port address using the DIL 
  switches or the jumpers on the radio clock board. Detailed 
  configuration options can be found in the operating instructions 
  of your device.

- Run the monitor program MbgMon to configure the radio clock, check 
  its status, and start the time adjustment service.  



PCI/PCIe or ISA board under Windows NT (without PNP support)
----------------------------------------------------------- 

- Shut down the computer and install the board in a free slot before
  you install the driver software.

- After the computer has rebooted run the installer to install 
  the driver package.

- If the board is an ISA card, check "ISA clock" and enter the port 
  base address. The default value is 300 hex, which corresponds to 
  the default settings of the board when being shipped. If the 
  configuration conflicts With another device you have to choose a 
  different port address and configure the selected port address 
  using the DIL switches or the jumpers on the radio clock board
  accordingly. Detailed configuration options can be found in the 
  operating instructions for the card.

- If the board is a PCI card then it's not necessary to enter a
  port bas address since the card is detected automatically by the 
  driver software.

- Select the installation directory for the software,the default is:
  C:\Program Files\Meinberg\MbgMon

- If the board has not yet been installed, shut down the computer and
  install the board in a free slot. Then reboot the computer.

- Run the monitor program MbgMon to configure the radio clock, check 
  its status, and start the time adjustment service.  



External clock connected to a serial port
-----------------------------------------

- Run the installer to install the driver package.

- Select the installation directory for the software,the default is:
  C:\Program Files\Meinberg\MbgMon

- After the setup program has terminated, run the monitor program MbgMon 
  to set up the serial port of the computer. Select the COM port to which 
  the external device is connected, and configure transmission speed and 
  framing according to the settings of the external device. The default
  configuration depends on the type of the external device. Please refer 
  to the operating instructions shipped with the device for details.



Copyright (C) 2004-2009 Meinberg Funkuhren, Bad Pyrmont, Germany

Internet: http://www.meinberg.de
Email:    info@meinberg.de

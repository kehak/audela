/*
 * pmac.h
 *
 * 32-bit Motion Control Device Driver
 * Hardware-specific data structures for the Pmac.
 *
 *
 * This header describes the structures that are shared between
 * the hardware-specific user-mode code and the hardware-specific
 * kernel mode code.
 *
 * The mckernel library does not define the format of the
 * config structures passed to the config functions beyond the fact that
 * the first ULONG contains the length of the entire structure. Note that
 * any pointers within this struct will need special handling.
 *
 * Rick Schneeman, NIST, January 1995
 *
 * See readme.txt file for acknowledgements and support.
 *
 * Copyleft (c) US Dept. of Commerce, NIST, 1995.
 */


#ifndef _PMAC_H_
  #define _PMAC_H_

/*
 * default settings for port, interrupt and dpram
 */

  #define DEF_DEVICETYPE  0  // PMAC, TURBO etc.
  #define DEF_PCBUSTYPE  0   // ISA, VME etc.
  #define DEF_PORT       528 // 0x210
  #define DEF_INTERRUPT  0   // No interrupt, make them select!
  #define DEF_FIFO       0x0
  #define DEF_DPRROT1ADR 0x400
  #define DEF_DPRROT2ADR 0x0
  #define DEF_DPRROT3ADR 0x0
  #define DEF_DPRROT4ADR 0x0
  #define DEF_DPRROT5ADR 0x0
  #define DEF_DPRROT6ADR 0x0
  #define DEF_DPRROT7ADR 0x0
  #define DEF_DPRROT8ADR 0x0
  #define DEF_DPRVARADR  0xDDE0
  #define DEF_DPRUSERBUF 0
  #define DEF_FBSTART    40958
  #define DEF_FBTIMER    40958
  #define DEF_TIMEOUT    200
  #define DEF_FLUSHTIMEOUT   20

/*
 * Parameter Names:
 *
 * These are the names of Values in the Parameters key (or driver section
 * of the profile) used for communicating configuration information and errors
 * between the kernel and user-mode drivers.
 */

  #define PARAM_PCBUSTYPE   L"PCBusType"    // bus type isa, pci
  #define PARAM_PORT        L"Port"         // port i/o address
  #define PARAM_INTERRUPT   L"Interrupt"    // interrupt number
  #define PARAM_FIFO        L"DualPortRam"  // DP Ram physical addr
  #define PARAM_ERROR       L"InstallError" // config error/success code (below)
  #define PARAM_DPRROT1     L"DualPortRamRot1"
  #define PARAM_DPRROT2     L"DualPortRamRot2"
  #define PARAM_DPRROT3     L"DualPortRamRot3"
  #define PARAM_DPRROT4     L"DualPortRamRot4"
  #define PARAM_DPRROT5     L"DualPortRamRot5"
  #define PARAM_DPRROT6     L"DualPortRamRot6"
  #define PARAM_DPRROT7     L"DualPortRamRot7"
  #define PARAM_DPRROT8     L"DualPortRamRot8"
  #define PARAM_DPRVARADR   L"DualPortRamVar"
  #define PARAM_DPRUSERSIZE L"DualPortRamUserSize"
  #define PARAM_FBSTART     L"FunctionBlockStart"
  #define PARAM_FBTIMER     L"FunctionBlockTimer"
  #define PARAM_VMEBASE   L"VMEBase"
  #define PARAM_VMEDPRBASE  L"VMEDPRBase"
  #define PARAM_VMEINTERRUPT  L"VMEInterrupt"
  #define PARAM_VMEHOSTID   L"VMEHostID"
  #define PARAM_VMEAM     L"VMEAM"
  #define PARAM_VMEAMDC     L"VMEAMDontCare"
  #define PARAM_VMEIRQVECT  L"VMEIRQVector"
                                            /*
                                             * Error handling
                                             *
                                             * during startup of the kernel-driver, the PARAM_ERROR value is written with
                                             * one of the values below. These are the IDs of strings in
                                             * pmac\dll\pmac.rc that are produced in a dialog box by the user-mode
                                             * driver during configuration if not ERR_OK
                                             */

  #include "common.h"

#endif //_PMAC_H_


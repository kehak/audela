
/**************************************************************************
 *
 *  $Id: usbdefs.h,v 1.1 2011-02-23 14:19:10 myrtillelaas Exp $
 *
 *  Copyright (c) Meinberg Funkuhren, Bad Pyrmont, Germany
 *
 *  Description:
 *    Definitions used with USB devices.
 *
 * -----------------------------------------------------------------------
 *  $Log: not supported by cvs2svn $
 *  Revision 1.9  2009/03/13 09:02:24Z  martin
 *  Removed definitions for timeout intervals.
 *  Revision 1.8  2009/02/18 11:08:44  daniel
 *  Added new class code and device ID for SCU_USB
 *  Revision 1.7  2008/11/28 07:45:30Z  daniel
 *  Added new class code and device ID for WWVB51USB
 *  Revision 1.6  2008/01/09 10:39:18Z  daniel
 *  Added new class code and device ID for MSF51USB
 *  Revision 1.5  2007/10/29 08:23:26Z  daniel
 *  Added new class code and device ID for TCR51USB
 *  Revision 1.4  2007/09/25 09:59:50Z  daniel
 *  Added indices for endpoint definitions.
 *  Added timeout definitions.
 *  Revision 1.3  2006/12/20 16:11:36Z  daniel
 *  Added new device class and device_id for nCipher CMC-device.
 *  Revision 1.2  2006/12/07 09:10:57Z  daniel
 *  Added new class code and device ID for USB5131.
 *  Revision 1.1  2006/04/21 08:14:56Z  martin
 *  Initial revision
 *
 **************************************************************************/

#ifndef _USBDEFS_H
#define _USBDEFS_H


/* Other headers to be included */


/* Start of header body */

#ifdef __cplusplus
extern "C" {
#endif


/* Meinberg's USB vendor ID number (assigned by USB-IF Administration) */
#define USB_VENDOR_MEINBERG     0x1938


/*
 * USB device class codes (assigned by Meinberg) 
 */
enum
{
  MBG_USB_CLASS_NONE,   // (unknown or not defined)
  MBG_USB_CLASS_CPC,    // Control Panel Controller
  MBG_USB_CLASS_TSU,    // Time Stamp Unit
  MBG_USB_CLASS_DCF,    // DCF77 Radio Clock
  MBG_USB_CLASS_CMC,    // nCipher Crypto Module Carrier
  MBG_USB_CLASS_TCR,    // IRIG Time Code Receiver
  MBG_USB_CLASS_MSF,    // MSF Radio Clock
  MBG_USB_CLASS_WWVB,   // WWVB Radio Clock
  MBG_USB_CLASS_SCU,    // Meinberg Signal Changeover Unit
  N_MBG_USB_CLASS       // number of known device class codes
};


/*
 * USB device ID numbers (assigned by Meinberg) 
 *   High byte:  USB device class as specified above
 *   Low byte:   enumeration of device of a class
 */
#define USB_DEV_CPC_01      ( ( MBG_USB_CLASS_CPC << 8 )  | 0x01 )

#define USB_DEV_TSU_01      ( ( MBG_USB_CLASS_TSU << 8 )  | 0x01 )

#define USB_DEV_USB5131     ( ( MBG_USB_CLASS_DCF << 8 )  | 0x01 )

#define USB_DEV_CMC         ( ( MBG_USB_CLASS_CMC << 8 )  | 0x01 )

#define USB_DEV_TCR51USB    ( ( MBG_USB_CLASS_TCR << 8 )  | 0x01 )

#define USB_DEV_MSF51USB    ( ( MBG_USB_CLASS_MSF << 8 )  | 0x01 )

#define USB_DEV_WWVB51USB   ( ( MBG_USB_CLASS_WWVB << 8 ) | 0x01 )

#define USB_DEV_SCU_USB     ( ( MBG_USB_CLASS_SCU << 8 )  | 0x01 )

enum
{
  MBGUSB_EP_IDX_HOST_IN,          // transfers from device to host
  MBGUSB_EP_IDX_HOST_OUT,         // transfers from host to device
  MBGUSB_EP_IDX_HOST_IN_CYCLIC,   // cyclic auto-transfer to host
  MBGUSB_MAX_ENDPOINTS            // max number of supported endpoints
};


#ifdef __cplusplus
}
#endif

/* End of header body */

#endif  /* _USBDEFS_H */

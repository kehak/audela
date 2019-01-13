
/*
 * mcuser.h
 *
 * 32-bit Motion Control Device Driver
 * User-mode support library
 *
 * Define functions providing access to motion control hardware. On NT,
 * these functions will interface to the kernel-mode driver.
 *
 * Include mcstruct.h before this.
 *
 * Rick Schneeman, NIST, January 1995
 *
 * See readme.txt file for acknowledgements and support.
 *
 * Copyleft (c) US Dept. of Commerce, NIST, 1995.
 */

#ifndef _MCUSER_H_
  #define _MCUSER_H_

  #include "registry.h"

/*
 * capture device handle. This structure is opaque to the caller
 */
typedef struct _USER_HANDLE *PUSER_HANDLE;



/*
 * open the device and return a capture device handle that can be used
 * in future calls.
 * The device index is 0 for the first capture device up to N for the
 * Nth installed capture device.
 *
 * (Current implementation supports only one device per
 * drivername.)
 *
 * This function returns NULL if it is not able to open the device.
 */
//PUSER_HANDLE OpenDevice(int DeviceIndex);


/*
 * close a capture device. This will abort any operation in progress and
 * render the device handle invalid.
 */
//VOID CloseDevice(PUSER_HANDLE vh);




/*
 * debug macros
 *
 */

  #ifdef DBG
void dbgPrintf(PTCHAR szFormat, ...);
extern int vcuDebugLevel;


    #define dprintf(_x_)  dbgPrintf _x_
    #define dprintf1(_x_) if (vcuDebugLevel >= 1) dbgPrintf _x_
    #define dprintf2(_x_) if (vcuDebugLevel >= 2) dbgPrintf _x_
    #define dprintf3(_x_) if (vcuDebugLevel >= 3) dbgPrintf _x_
    #define dprintf4(_x_) if (vcuDebugLevel >= 4) dbgPrintf _x_

  #else

    #define dprintf(_x_)
    #define dprintf1(_x_)
    #define dprintf2(_x_)
    #define dprintf3(_x_)
    #define dprintf4(_x_)

  #endif

  #ifdef DBG
BOOL FAR PASCAL _Assert(BOOL fExpr, LPSTR szFile, int iLine);

    #define ASSERT(expr)     _Assert((expr), __FILE__, __LINE__)


  #else
    #define ASSERT(expr)

  #endif





#endif //_MCUSER_H_

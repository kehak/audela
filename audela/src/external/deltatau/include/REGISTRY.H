/****************************************************************************
 *
 *   registry.h
 *
 *   Copyright (c) 1992 Microsoft Corporation.  All Rights Reserved.
 *
 *   This file contains public definitions for maintaining registry information
 *   for drivers managing kernel driver registry related data.
 ****************************************************************************/

#ifndef _REGISTRY_H
  #define _REGISTRY_H

/****************************************************************************

 Driver types

 ****************************************************************************/

typedef enum {
    SoundDriverTypeNormal = 1,
    SoundDriverTypeSynth /* Go in the synth group */
} SOUND_KERNEL_MODE_DRIVER_TYPE;

/****************************************************************************

Our registry access data

****************************************************************************/
typedef struct {
    SC_HANDLE ServiceManagerHandle;           // Handle to the service controller
    TCHAR  DriverName[20];                    // Name of driver
    TCHAR  TempKeySaveFileName[MAX_PATH];     // Where parameters key is saved
    DWORD  dwDevice;                          // Number current device
    SOUND_KERNEL_MODE_DRIVER_TYPE DriverType; // Type of device driver
    DWORD  dwDeviceUsage;                     // How many users this device
} REG_ACCESS, *PREG_ACCESS;

/****************************************************************************

Test if configuration etc can be supported

****************************************************************************/

  #define DrvAccess(RegAccess) ((RegAccess)->ServiceManagerHandle != NULL)

/****************************************************************************

 Function prototypes

 ****************************************************************************/
  #ifdef __cplusplus
extern "C" {
  #endif

  //HKEY CALLBACK DrvCreateDeviceKey(PREG_ACCESS RegAccess);
  HKEY CALLBACK DrvOpenRegKey(PREG_ACCESS RegAccess,LPCTSTR Path);
  BOOL CALLBACK DrvSetKnownVxd(PREG_ACCESS pRegAccess);
  BOOL CALLBACK DrvCreateServicesNode(PREG_ACCESS RegAccess,BOOL Create);
  VOID CALLBACK DrvCloseServiceManager(PREG_ACCESS RegAccess);
  BOOL CALLBACK DrvDeleteServicesNode(PREG_ACCESS RegAccess);
  //BOOL CALLBACK DrvSaveParametersKey(PREG_ACCESS RegAccess);
  //BOOL CALLBACK DrvRestoreParametersKey(PREG_ACCESS RegAccess);
  HKEY CALLBACK DrvOpenDeviceKey(PREG_ACCESS RegAccess);

  //      Set a device DWORD parameter
  LONG CALLBACK DrvSetDeviceDword(
    PREG_ACCESS RegAccess,
    LPTSTR ValueName,
    DWORD dwValue);

  //     Read current DWORD parameter setting
  LONG CALLBACK DrvQueryDeviceDword(
    PREG_ACCESS RegAccess,
    PTCHAR ValueName,
    PDWORD pValue,
    DWORD  defValue);

  //      Set a device STRING parameter
  LONG CALLBACK DrvSetDeviceString(
    PREG_ACCESS RegAccess,
    PTCHAR ValueName,
    PTCHAR Value);

  //     Read current STRING parameter setting
  LONG CALLBACK DrvQueryDeviceString(
    PREG_ACCESS RegAccess,
    PTCHAR ValueName,
    PTCHAR pValue,
    DWORD  valuelength,
    PTCHAR defValue);

  BOOL CALLBACK DrvLoadKernelDriver(PREG_ACCESS RegAccess);
  BOOL CALLBACK DrvUnloadKernelDriver(PREG_ACCESS RegAccess);
  BOOL CALLBACK DrvIsDriverLoaded(PREG_ACCESS RegAccess);
  BOOL CALLBACK DrvConfigureDriver(PREG_ACCESS RegAccess,
    BOOL (* SetParms )(PREG_ACCESS,PVOID),PVOID Context);

  LRESULT CALLBACK DrvRemoveDriver(PREG_ACCESS RegAccess);
  BOOL CALLBACK DrvRemoveDevice(DWORD dwDeviceNum);
  LONG CALLBACK DrvNumberOfDevices();
  VOID CALLBACK DrvSetMapperName(LPTSTR SetupName);

  // Nc Specific
  HKEY CALLBACK DrvOpenNcKey(DWORD device,DWORD control,LPCTSTR Section);
  LONG CALLBACK DrvSetNcDword(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,DWORD Value);
  LONG CALLBACK DrvQueryNcDword(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,PDWORD pValue,
                  DWORD defValue);
  LONG CALLBACK DrvSetNcDouble(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,double Value);
  LONG CALLBACK DrvQueryNcDouble(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,double *pValue,
                  double defValue);
  LONG CALLBACK DrvSetNcString(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,LPTSTR Value);
  LONG CALLBACK DrvQueryNcString(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,LPTSTR pValue,
                  DWORD ValueLength,LPTSTR defValue);
  LONG CALLBACK DrvSetNcBool(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,BOOL Value);
  LONG CALLBACK DrvQueryNcBool(DWORD device,DWORD ControlNumber,LPCTSTR Section,LPTSTR ValueName,PBOOL pValue,
                  BOOL defValue);

  #ifdef __cplusplus
}
  #endif

#endif // _REGISTRY_H


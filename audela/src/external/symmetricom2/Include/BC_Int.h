//***************************************************************************
//
// BC_Int.h
//
// Version 10.0.0
//
// BCPCI Interrupt API definitions
//
// Copyright (c) Symmetricom - 2009
//
//***************************************************************************

#ifndef __BC_INT_H__
#define __BC_INT_H__

// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the BC637PCI_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// BC637PCI_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef BC637PCI_EXPORTS
#define BC637PCI_API __declspec(dllexport)
#else
#define BC637PCI_API __declspec(dllimport)
#endif

// Have to figure out how to support fastcall in x64.
#ifdef _WIN32
#define BC637PCI_CONV WINAPI
#else
#ifdef _WIN64
#define BC637PCI_CONV __fastcall
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

//***************************************************************************
// Interrupt Processing Functions 
//***************************************************************************
BC637PCI_API HANDLE	BC637PCI_CONV bcStartInt(INT);
BC637PCI_API INT    BC637PCI_CONV bcStopInt(void);
BC637PCI_API INT    BC637PCI_CONV bcSetInts(ULONG *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcReqInts(ULONG *, INT *);
BC637PCI_API INT    BC637PCI_CONV bcGetLastInts(ULONG *);	
BC637PCI_API INT    BC637PCI_CONV bcSetMultInts(INT);

#ifdef __cplusplus
}
#endif

#endif // __BC_INT_H__

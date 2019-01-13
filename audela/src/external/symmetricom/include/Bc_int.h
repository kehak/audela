//***************************************************************************
//
// bc_int.h
//
// Version 7.1.0
//
// API for bc635PCI hardware interrupts
//
// Copyright (c) Symmetricom - Formerly Datum
//
//***************************************************************************

#ifndef __BC_INT_H__
#define __BC_INT_H__

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _PCI_INTR_LINKAGE_
#define _PCI_INTR_LINKAGE_
#endif


//***************************************************************************
// API Functions 
//***************************************************************************
HANDLE	_PCI_INTR_LINKAGE_ bcStartInt(INT);
int		_PCI_INTR_LINKAGE_ bcStopInt(void);
int		_PCI_INTR_LINKAGE_ bcSetInts(ULONG *, INT *);
int		_PCI_INTR_LINKAGE_ bcReqInts(ULONG *, INT *);

int		_PCI_INTR_LINKAGE_ bcGetLastInts(ULONG *);	
int		_PCI_INTR_LINKAGE_ bcSetMultInts(INT);


#ifdef __cplusplus
}
#endif

#endif // __BC_INT_H__
/* libname.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2013 The AudeLA Core Team
 *
 * Initial author : Matteo SCHIAVON <ilmona89@gmail.com>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * Commands to send to the camera Raptor Photonics OSPREY - header
 */

#ifndef H_RAPTOR
#define H_RAPTOR

#include "serial.h"

// State modes
#define CHK_SUM_ON		0x40
#define	ACK_ON				0x10
#define UNHOLD_FPGA		0x02
#define	ENABLE_COMMS	0x01

// Status FPGA
#define FPGA_BOOTED		0x04			

// TEC modes
#define TEC_ON	0x01
#define TEC_OFF	0x00

// Clock frequency (Hz)
#define CLOCK 80000000

// Trigger modes
#define TRG_RISE	0x80
#define TRG_EXT		0x40
#define TRG_ABORT	0x08
#define TRG_CONT	0x04
#define TRG_FFR		0x02
#define TRG_SNAP	0x01

// Binning mode
#define BIN_1x1		0x00
#define BIN_2x2		0x11
#define BIN_4x4		0x22

// Dynamic range mode
#define HIGH_DYNAMIC	0x72
#define STD_DYNAMIC		0x60

// NUC map
#define NUC_ON		0x40
#define NUC_OFF		0x60

int serialInit();

int microReset();
int setState(uchar mode);
int setTEC(uchar mode);
int setFrameRate(double frate);
int setExposure(double exp);
int setTrigger(uchar mode);
int setGain(int gain);
int setBinning(uchar mode);
int setROIxsize(int size);
int setROIxoffset(int offset);
int setROIysize(int size);
int setROIyoffset(int offset);
int setDynamicRange(uchar mode);
int setViewNUCmap(uchar mode);

//TODO the get section

int getStatus(uchar *status);
int getTEC(uchar *tec);
int getFrameRate(double *frate);
int getExposure(double *exp);
int getGain(int *gain);
int getPCBtemp(double *temp);
int getCMOStemp(int *temp);
int getMicroVersion(uchar *version);
int getFPGAversion(uchar *version);
int getTrigger(uchar *mode);
int getBinning(uchar *mode);
int getROIxsize(int *size);
int getROIxoffset(int *offset);
int getROIysize(int *size);
int getROIyoffset(int *offset);
int getDynamicRange(uchar *mode);
int getSerialNumber(int *number);
int getManuData(uchar *data);

#endif //H_RAPTOR

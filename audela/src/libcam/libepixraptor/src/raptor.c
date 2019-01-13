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
 * Commands to send to the camera Raptor Photonics OSPREY
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include "raptor.h"
#include "serial.h"
#include "xcliball.h"

/* int serialInit()

	Arguments:

	Return:
		0		all ok
		<0	error

	Behaviour:
		initialize serial link
*/
int serialInit() {
	return ser_config();
}

/* int microReset()

	Arguments:

	Return:
		0		all ok
		<0	error

	Behaviour:
		send the Micro RESET command and perform the whole reset protocol
*/
int microReset() {
	int ret;
	uchar status;

	ret = ser_reset();
	if (ret<0)
		return ret;

	usleep(10000);

	do {
		ret = ser_set_state(ACK_ON|ENABLE_COMMS,2);
	} while (ret != 0);

	ret = ser_set_state(ACK_ON|UNHOLD_FPGA,2);
	printf("%d\n",ret);
	if (ret<0)
		return ret;

	do {
		ret = ser_get_status(&status,2);
		if (ret<0)
			return ret;
	} while ( ! (status & FPGA_BOOTED) );

	ret = ser_set_state(ACK_ON|UNHOLD_FPGA,2);
	if (ret<0)
		return ret;

	return 0;
		
}

/* int setState(uchar mode)

	Arguments:
		mode		state mode required

	Return:
		0		all ok
		<0	error

	Behaviour:
		set the system state (checksum, ack, FPGA reset, comms to FPGA EPROM)
*/
int setState(uchar mode) {
	return ser_set_state(mode,2);
}

/* int setTEC(uchar mode)

	Arguments:
		mode		TEC mode (TEC_ON or TEC_OFF)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		enables or disables TEC
*/
int setTEC(uchar mode) {
	return ser_write_reg(0x00,mode,2);
}

/* int setFrameRate(double frate)

	Arguments:
		frate		frame rate (in fps)

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the frame rate
*/
int setFrameRate(double frate) {
	int r;
	uchar i;
	uint32 cycles;
	uchar *p_cycles;

	cycles = (uint32)(CLOCK/frate);
	p_cycles = (uchar *)&cycles;

	for (i=0; i<4; i++) {
		r = ser_write_reg(0xdd+i,p_cycles[3-i],2);
		if ( r<0 )
			return r;
	}
	
	return 0;
}

/* int setExposure(double exp)

	Arguments:
		exp		exposure time [in s]

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the exposure time
*/
int setExposure(double exp) {
	int r;
	uchar i;
	uint64 cycles;
	uchar *p_cycles;

	cycles = (uint64)((CLOCK)*exp);
	p_cycles = (uchar *)&cycles;

	for (i=0; i<5; i++) {
		r = ser_write_reg(0xed+i,p_cycles[4-i],2);
		if ( r<0 )
			return r;
	}
	
	return 0;
}

/* int setTrigger(uchar mode)

	Arguments:
		mode		trigger mode (list defined in raptor.h)

	Return:
		0			all ok
		<0		error

	Behaviour:
		possible modes: TRG_RISE, TRG_EXT, TRG_ABORT, TRG_CONT, TRG_FFR, TRG_SNAP
*/
int setTrigger(uchar mode) {
	return ser_write_reg(0xd4,mode,2);
}

/* int setGain(int gain)

	Arguments:
		gain		digital video gain

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the digital video gain
*/
int setGain(int gain) {
	int r;
	uchar i;
	uint16 g;
	uchar *pg;

	g = (uint16)gain*512;
	pg = (uchar *)&g;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xd5+i,pg[1-i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setBinning(uchar mode)

	Arguments:
		mode		binning mode

	Return:
		0		all ok
		<0	error

	Behaviour:
		set the binning (BIN_1x1, BIN_2x2, BIN_4x4)
*/
int setBinning(uchar mode) {
	return ser_write_reg(0xdb,mode,2);
}

/* int setROIxsize(int size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the x size of the ROI
*/
int setROIxsize(int size) {
	int r;
	uchar i;
	uint16 s;
	uchar *ps;

	s = (uint16)size;
	ps = (uchar *)&s;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xd7+i,ps[1-i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setROIxoffset(int offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the x offset of the ROI
*/
int setROIxoffset(int offset) {
	int r;
	uchar i;
	uint16 o;
	uchar *po;

	o = (uint16)offset;
	po = (uchar *)&o;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xd9+i,po[1-i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setROIysize(int size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the y size of the ROI
*/
int setROIysize(int size) {
	int r;
	uchar i;
	uint16 s;
	uchar *ps;

	s = (uint16)size;
	ps = (uchar *)&s;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xf3,0x81+i,2);
		if ( r<0 )
			return r;
		r = ser_write_reg(0xf4,ps[i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setROIyoffset(int offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the y offset of the ROI
*/
int setROIyoffset(int offset) {
	int r;
	uchar i;
	uint16 o;
	uchar *po;

	o = (uint16)offset;
	po = (uchar *)&o;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xf3,0x83+i,2);
		if ( r<0 )
			return r;
		r = ser_write_reg(0xf4,po[i],2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int setDynamicRange(uchar mode)

	Arguments:
		mode		Dynamic range mode (HIGH_DYNAMIC or STD_DYNAMIC)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		enables or disables High Dynamic Range
*/
int setDynamicRange(uchar mode) {
	return ser_write_reg(0xf7,mode,2);
}

/* int setViewNUCmap(uchar mode)

	Arguments:
		mode		NUC_ON or NUC_OFF (default NUC_OFF)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		enables or disables the NUC (Non Uniformity Correction) view
		instead of the captured field view
*/
int setViewNUCmap(uchar mode) {
	return ser_write_reg(0xf7,mode,2);
}

/* START OF THE GET FUNCTIONS */

/* int getStatus(uchar *status)

	Arguments:
		status		system status (see Osprey documentation) - 1 byte

	Return:
		0		all ok
		<0	error

	Behaviour:
		read system status (checksum, ack, FPGA booted ok, ...)
*/
int getStatus(uchar *status) {
	return ser_get_status(status,2);
}

/* int getTEC(uchar *tec)

	Arguments:
		tec		tec on/off (TEC_ON=0x01 or TEC_OFF=0x00) - 1 byte

	Return:
		0		all ok
		<0	error

	Behaviour:
		return if TEC is enabled or not
*/
int getTEC(uchar *tec) {
	return ser_read_reg(0x00,tec,2);
}

/* int getFrameRate(double *frate)

	Arguments:
		frate		frame rate (in fps)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current frame rate
*/
int getFrameRate(double *frate) {
	int r;
	uchar i;
	uint32 cycles;
	uchar *p_cycles;

	p_cycles = (uchar *)&cycles;

	for (i=0; i<4; i++) {
		r = ser_read_reg(0xdd+i,&p_cycles[3-i],2);
		if ( r<0 )
			return r;
	}
	
	*frate=CLOCK/(double)cycles;
	return 0;
}

/* int getExposure(double *exp)

	Arguments:
		exp		exposure time [in s]

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the exposure time
*/
int getExposure(double *exp) {
	int r;
	uchar i;
	uint64 cycles=0;
	uchar *p_cycles;

	p_cycles = (uchar *)&cycles;

	for (i=0; i<5; i++) {
		r = ser_read_reg(0xed+i,&p_cycles[4-i],2);
		if ( r<0 )
			return r;
	}

	*exp = (cycles)/(double)CLOCK;
	
	return 0;
}

/* int getGain(int *gain)

	Arguments:
		gain		digital video gain

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current digital video gain
*/
int getGain(int *gain) {
	int r;
	uchar i;
	uint16 g;
	uchar *pg;

	pg = (uchar *)&g;

	for (i=0; i<2; i++) {
		r = ser_read_reg(0xd5+i,&pg[1-i],2);
		if ( r<0 )
			return r;
	}

	*gain=g/512;

	return 0;
}

/* int getPCBtemp(double *temp)

	Arguments:
		temp		PCB temperature (Celsius)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current temperature of the electronics
*/
int getPCBtemp(double *temp) {
	int r;
	uchar i;
	uint16 t;
	uchar *pt;

	pt = (uchar *)&t;

	for (i=0; i<2; i++) {
		r = ser_read_temp_reg(0x70+i,&pt[1-i],2);
		if ( r<0 )
			return r;
	}
	//extend the sign from 12 bit to 16 bit
	if ( pt[1] & 0x08 )
		pt[1] | 0xf0;

	*temp=(double)t/16.;

	return 0;
}

/* int getCMOStemp(int *temp)

	Arguments:
		temp		CMOS sensor temperature (to be extract -> see doc)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current temperature of the CMOS sensor
*/
int getCMOStemp(int *temp) {
	int r;
	uchar i;
	uint16 t;
	uchar *pt;

	pt = (uchar *)&t;

	for (i=0; i<2; i++) {
		r = ser_read_temp_reg( 0x6e + i,&pt[1-i],2);
		if ( r<0 )
			return r;
	}
	//extend the sign from 12 bit to 16 bit
	/*if ( pt[1] & 0x08 )
		pt[1] | 0xf0;*/

	*temp=t;

	return 0;
}

/* int getMicroVersion(uchar *version)

	Arguments:
		version		buffer where to put the version - 2 bytes

	Return:
		0		all ok
		<0	error

	Behaviour:
		version = {major_version, minor_version}
*/
int getMicroVersion(uchar *version) {
	return ser_get_micro(version,2);
}

/* int getFPGAversion(uchar *version)

	Arguments:
		version		FPGA version - 2 bytes

	Return:
		0			all ok
		<0		error

	Behaviour:
		version = {major_version, minor_version}
*/
int getFPGAversion(uchar *version) {
	int r;
	uchar i;

	for (i=0; i<2; i++) {
		r = ser_read_reg(0x7e + i,version+i,2);
		if ( r<0 )
			return r;
	}

	return 0;
}

/* int getTrigger(uchar *mode)

	Arguments:
		mode		trigger mode (list defined in raptor.h)

	Return:
		0			all ok
		<0		error

	Behaviour:
		return current trigger mode
		possible modes: TRG_RISE, TRG_EXT, TRG_CONT, TRG_FFR
*/
int getTrigger(uchar *mode) {
	return ser_read_reg(0xd4,mode,2);
}
/* int getBinning(uchar *mode)

	Arguments:
		mode		binning mode

	Return:
		0		all ok
		<0	error

	Behaviour:
		get the binning (BIN_1x1, BIN_2x2, BIN_4x4)
*/
int getBinning(uchar *mode) {
	return ser_read_reg(0xdb,mode,2);
}

/* int getROIxsize(int *size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current x size of the ROI
*/
int getROIxsize(int *size) {
	int r;
	uchar i;
	uint16 s;
	uchar *ps;

	ps = (uchar *)&s;

	for (i=0; i<2; i++) {
		r = ser_read_reg(0xd7+i,&ps[1-i],2);
		if ( r<0 )
			return r;
	}

	*size = s;

	return 0;
}

/* int getROIxoffset(int *offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current x offset of the ROI
*/
int getROIxoffset(int *offset) {
	int r;
	uchar i;
	uint16 o;
	uchar *po;

	po = (uchar *)&o;

	for (i=0; i<2; i++) {
		r = ser_read_reg(0xd9+i,&po[1-i],2);
		if ( r<0 )
			return r;
	}

	*offset = o;
	return 0;
}

/* int getROIysize(int *size)

	Arguments:
		size		size of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current y size of the ROI
*/
int getROIysize(int *size) {
	int r;
	uchar i;
	uint16 s;
	uchar *ps;

	ps = (uchar *)&s;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xf3,0x01+i,2);
		if ( r<0 )
			return r;
		r = ser_write_reg(0xf4,0x00,2);
		if ( r<0 )
			return r;
		r = ser_read_reg(0x73,&ps[i],2);
		if ( r<0 )
			return r;
	}

	*size = s;
	return 0;
}

/* int getROIyoffset(int *offset)

	Arguments:
		offset		offset of the ROI

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current y offset of the ROI
*/
int getROIyoffset(int *offset) {
	int r;
	uchar i;
	uint16 o;
	uchar *po;

	po = (uchar *)&o;

	for (i=0; i<2; i++) {
		r = ser_write_reg(0xf3,0x03+i,2);
		if ( r<0 )
			return r;
		r = ser_write_reg(0xf4,0x00,2);
		if ( r<0 )
			return r;
		r = ser_read_reg(0x73,&po[i],2);
		if ( r<0 )
			return r;
	}

	*offset = o;
	return 0;
}

/* int getDynamicRange(uchar *mode)

	Arguments:
		mode		Dynamic range mode (HIGH_DYNAMIC or STD_DYNAMIC) - 1 byte

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		get the current Dynamic Range mode
*/
int getDynamicRange(uchar *mode) {
	return ser_read_reg(0xf7,mode,2);
}

/* int getSerialNumber(int *number)

	Arguments:
		number		serial number

	Return:
		0		all ok
		<0	error

	Behaviour:
		get the current Unit Serial Number
*/
int getSerialNumber(int *number) {
	return ser_read_eeprom((uchar *)number,2,2);
}

/* int getManuData(uchar *data)

	Arguments:
		data		manufacturer data - 18 bytes (see Osprey doc)

	Return:
		0		all ok
		<0	error

	Behaviour:
		get the manufacturers data
*/
int getManuData(uchar *data) {
	int r;

	r = setState(ACK_ON|ENABLE_COMMS|UNHOLD_FPGA);
	if ( r<0 )
		return r;

	r = ser_read_eeprom(data,0x12,2);
	if ( r<0 )
		return r;

	r = setState(ACK_ON|UNHOLD_FPGA);
	if ( r<0 )
		return r;

	return 0;
}

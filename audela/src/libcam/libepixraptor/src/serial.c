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
 * Communication utilities with the CamLink serial interface
 * for the Raptor Photonics Osprey camera
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <time.h>
#include "serial.h"
#include <stdio.h>
#include <string.h>

//TODO: check the different serial errors
//TODO: rewrite the routines to use checksum

/* int ser_config()

	Arguments:

	Return:
		0		all ok
		<0	error

	Behaviour:
		configure the serial connection with the right BAUD and other parameters
*/
int ser_config() {
	return pxd_serialConfigure(0x1,0,115200,8,0,1,0,0,0);
}

/* int ser_read(uchar *buf_read, int n_read, time_t timeout)

	Arguments:
		buf_read	pointer to the buffer where to read the characters
		n_read		number of characters to be read
		timeout		time to wait for response

	Return:
		0		serial read ok
		-2	serial read error
		-4	timed out

	Behaviour:
		it waits until it reads n_read character or until it times out
		it ignores if the answer is a correct ack or something else
*/
int ser_read(uchar *buf_read, int n_read, time_t timeout) {
	int r,dataread=0;
	time_t in_time;

	in_time=time(NULL);
	for (;;) {
		r = pxd_serialRead(0x1,0,&buf_read[dataread],n_read-dataread);

		if ( r<0 )
			return -2;
		else if ( r==0 )
			usleep(1000); // 1 ms
		else {
			dataread += r;
			if ( dataread==n_read )
				break;
		}

		if ( (time(NULL) - in_time) >= timeout )
			return -4;
	}

	return 0;
}


/* int ser_write(uchar *buf_wr, int n_wr)

	Arguments:
		buf_wr		pointer to the buffer having the characters to write
		n_wr			number of characters to write
	
	Return:
		0			all ok
		-1		serial write error

	Behaviour:
		low level serial write, it doesn't wait for ack before returning
*/
int ser_write(uchar *buf_wr, int n_wr) {
	int r;

	r = pxd_serialWrite(0x1,0,buf_wr,n_wr);
	if ( r<0 )
		return -1;

	return 0;
}


/* int ser_flush_buffer()

	Arguments:

	Return:
		0 	all ok
		<0	read error
	
	Behaviour:
  	pxd_serialRead() until the buffer is empty
*/
int ser_flush_buffer() {
	int r;
	uchar ch;

	do {
		r = pxd_serialRead(0x1,0,&ch,1);
	} while ( r > 0 );

	return r;

}

/* int ser_write_reg(uchar reg, uchar val, time_t timeout)

	Arguments:
		reg			register to be written
		val			value to be written to the register
		timeout	maximum time for the response [s]

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		invalid ack
		-4		timed out

	Behaviour:
		write the value val in the reg register and wait for the ack
		from the camera
*/
int ser_write_reg(uchar reg, uchar val, time_t timeout) {
	int r;
	uchar inst[6] = {0x53, 0xe0, 0x02, 0x00, 0x00, ETX};
	uchar ack;
	time_t in_time;

	inst[3] = reg;
	inst[4] = val;

	ser_flush_buffer();

	r = ser_write(inst,6);	
	if (r<0)
		return r;

	r = ser_read(&ack,1,timeout);
	if (r<0)
		return r;

	if (ack != ETX)
		return -4;

	return 0;
}

/* int ser_read_reg(uchar reg, uchar *val,time_t timeout)

	Arguments:
		reg			register to be read
		val			place where to place the read value
		timeout	maximum time for the response [s]

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		ack error
		-4		timed out

	Behaviour:
		read the register and place the value in val
*/
int ser_read_reg(uchar reg, uchar *val, time_t timeout) {
	int r;
	uchar resp[2];
	uchar inst1[5] = {0x53, 0xe0, 0x01, 0x00, ETX};
	uchar inst2[4] = {0x53, 0xe1, 0x01, ETX};

	inst1[3] = reg;

	ser_flush_buffer();

	// write the first request byte
	r = ser_write(inst1,5);
	if (r<0)
		return -1;

	// read the response (ACK)
	r = ser_read(&resp[0],1,timeout);
	if ( r<0 )
		return r;

	if (resp[0] != ETX)
		return -3;

	ser_flush_buffer();

	// write the second request byte
	r = ser_write(inst2,4);
	if ( r<0 )
		return -1;
	
	// read the second response (VAL + ACK)
	r = ser_read(resp,2,timeout);
	if ( r<0 )
		return r;

	if (resp[1] != ETX)
		return -3;

	*val = resp[0];
	return 0;
}

/* int ser_read_temp_reg(uchar reg, uchar *val,time_t timeout)

	Arguments:
		reg			register to be read
		val			place where to place the read value
		timeout	maximum time for the response [s]

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		ack error
		-4		timed out

	Behaviour:
		read the temperature register and place the value in val
*/
int ser_read_temp_reg(uchar reg, uchar *val, time_t timeout) {
	int r;
	uchar resp[2];
	uchar inst1[6] = {0x53, 0xe0, 0x02, 0x00, 0x00, ETX};
	uchar inst2[4] = {0x53, 0xe1, 0x01, ETX};

	inst1[3] = reg;

	ser_flush_buffer();

	// write the first request byte
	r = ser_write(inst1,6);
	if (r<0)
		return -1;

	// read the response (ACK)
	r = ser_read(&resp[0],1,timeout);
	if ( r<0 )
		return r;

	if (resp[0] != ETX)
		return -3;

	ser_flush_buffer();

	// write the second request byte
	r = ser_write(inst2,4);
	if ( r<0 )
		return -1;
	
	// read the second response (VAL + ACK)
	r = ser_read(resp,2,timeout);
	if ( r<0 )
		return r;

	if (resp[1] != ETX)
		return -3;

	*val = resp[0];
	return 0;
}

/* int ser_reset()

	Arguments:

	Return:
		0		command sent
		-1	write error

	Behaviour:
		send micro RESET to the camera: no response
*/
int ser_reset() {
	int r;
	uchar reset[6] = {0x55, 0x99, 0x66, 0x11, ETX, 0xeb};

	r = pxd_serialWrite(0x1,0,reset,6);
	if ( r<0 )
		return -1;

	return 0;
}

/* int ser_set_state(uchar mode, time_t timeout)

	Arguments:
		mode		system mode to be set
		timeout	time to wait for response

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		invalid ack
		-4		timed out

	Behaviour:
		send the set system state command
*/
int ser_set_state(uchar mode, time_t timeout) {
	int r,dataread=0;
	uchar inst[3] = {0x4f, 0x00, ETX};
	uchar ack;
	time_t in_time;

	inst[1] = mode;

	ser_flush_buffer();

	r = ser_write(inst,3);
	if (r<0)
		return r;

	r = ser_read(&ack,1,timeout);
	if ( r < 0 )
		return r;

	if (ack != ETX)
		return -3;

	return 0;
}

/* int ser_get_status(uchar *status, time_t timeout)

	Arguments:
		status		buffer where to put the status
		timeout		maximum time to wait for the answer

	Return:
		0		all ok
		-1	serial write error
		-2	serial read error
		-3	invalid ack
		-4	timed out

	Behaviour:
		low level get status function
*/
int ser_get_status(uchar *status, time_t timeout) {
	int r;
	uchar inst[2] = {0x49, ETX};
	uchar resp[2];

	ser_flush_buffer();

	r = ser_write(inst,2);
	if ( r<0 )
		return r;

	r = ser_read(resp,2,timeout);
	if ( r<0 )
		return r;

	if ( resp[1] != ETX )
		return -3;

	*status = resp[0];

	return 0;
}

/* int ser_get_micro(uchar *version, time_t timeout)

	Arguments:
		version		buffer where to put the version (2 byte)
		timeout		maximum time to wait for the answer

	Return:
		0		all ok
		-1	serial write error
		-2	serial read error
		-3	invalid ack
		-4	timed out

	Behaviour:
		low level get Micro version
*/
int ser_get_micro(uchar *version, time_t timeout) {
	int r;
	uchar inst[2] = {0x56, ETX};
	uchar resp[3];

	ser_flush_buffer();

	r = ser_write(inst,2);
	if ( r<0 )
		return r;

	r = ser_read(resp,3,timeout);
	if ( r<0 )
		return r;

	if ( resp[2] != ETX )
		return -3;

	version[0] = resp[0];
	version[1] = resp[1];

	return 0;
}

/* int ser_read_eeprom(uchar *res,uchar n_res,time_t timeout)

	Arguments:
		res				buffer where to put the version
		n_res			number of bytes to read
		timeout		maximum time to wait for the answer

	Return:
		0		all ok
		-1	serial write error
		-2	serial read error
		-3	invalid ack
		-4	timed out

	Behaviour:
		for the functions Get Unit Serial Number (n_res = 2) and Get manufacturers Data (n_res = 18)
*/
int ser_read_eeprom(uchar *res, uchar n_res, time_t timeout) {
	int r;
	uchar inst1[9] = {0x53, 0xae, 0x05, 0x01, 0x00, 0x00, 0x02, 0x00, ETX};
	uchar inst2[4] = {0x53, 0xaf, 0x00, ETX};
	uchar resp[20];
	uchar i;

	memset(resp,'\0',20*sizeof(uchar));
	
	inst2[2] = n_res;

	ser_flush_buffer();

	r = ser_write(inst1,9);
	if ( r<0 )
		return r;

	usleep(100000); //wait for the command to be executed

	r = ser_read(&resp[0],1,timeout);
	if ( r<0 )
		return r;

	if ( resp[0] != ETX )
		return -3;

	ser_flush_buffer();

	r = ser_write(inst2,4);
	if ( r<0 )
		return r;

	r = ser_read(resp,n_res+1,timeout);
	if ( r<0 )
		return r;

	if ( resp[n_res] != ETX )
		return -3;

	for (i=0; i<n_res; i++) {
		res[i] = resp[i];
	}
	return 0;
}

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
 * for the Raptor Photonics Owl camera
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <libcam/util.h>

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

int conv_hexa2dec(char c) {
	int r=0;
	if (c=='0') { r=0; }
	else if (c=='1') { r=1; }
	else if (c=='2') { r=2; }
	else if (c=='3') { r=3; }
	else if (c=='4') { r=4; }
	else if (c=='5') { r=5; }
	else if (c=='6') { r=6; }
	else if (c=='7') { r=7; }
	else if (c=='8') { r=8; }
	else if (c=='9') { r=9; }
	else if ((c=='A')||(c=='a')) { r=10; }
	else if ((c=='B')||(c=='b')) { r=11; }
	else if ((c=='C')||(c=='c')) { r=12; }
	else if ((c=='D')||(c=='d')) { r=13; }
	else if ((c=='E')||(c=='e')) { r=14; }
	else if ((c=='F')||(c=='f')) { r=15; }
	else {
		r=0;
	}
	return r;
}

char *conv_dec2hexa(uchar r) {
	static char c[5];
	sprintf(c,"%02x",r);
	return c;
}

int ser_write_free(char *t,uchar *ret) {
	int len,r,k,ncom,msb,lsb;
	uchar commands[50];
	for (k=0;k<50;k++) {
		commands[k]='\0';
	}
	len=strlen(t);
	ncom=0;
	for (k=0;k<len;k++) {
		if (t[k]==' ') {
			ncom++;
		} else {
			msb=conv_hexa2dec(t[3*ncom]);
			lsb=conv_hexa2dec(t[3*ncom+1]);
			commands[ncom]=(uchar)(msb*16+lsb);
			k+=1;
		}
	}
	ncom++;
	ser_flush_buffer();
	r=ser_write(commands,ncom);
	if (r<0) {
		return r;
	}
	// read the response (ACK)
	if (ret!=NULL) {
		r = ser_read(ret,1,5);
		if ( r<0 ) {
			return r;
		}
	}
	return 0;
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
		r = pxd_serialRead(0x1,0,(char*)&buf_read[dataread],n_read-dataread);

		if ( r<0 )
			return -2;
		else if ( r==0 )
			libcam_sleep(1); // 1 ms
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

	r = pxd_serialWrite(0x1,0,(char*)buf_wr,n_wr);
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
		r = pxd_serialRead(0x1,0,(char*)&ch,1);
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
	//time_t in_time;

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
int ser_read_reg(uchar bank,uchar reg, uchar *val, time_t timeout) {
	int r;
	uchar resp[2];
	uchar inst1[5] = {0x53, 0xe0, 0x01, 0x00, ETX};
	uchar inst2[4] = {0x53, 0xe1, 0x01, ETX};

	inst1[2] = bank;
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
		reg			temperature register identifier (PCB: 0x97, Sensor: 0x91)
		val			place where to place the read value (2 bytes)
						val[0] = LSB, val[1] = MSB
		timeout	maximum time for the response [s]

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		ack error
		-4		timed out

	Behaviour:
		read the temperature register and place the returned bytes in adress data
*/
int ser_read_temp_reg(uchar reg, uchar *data, time_t timeout) {
	int r;
	uchar resp[3];
	uchar inst[4] = {0x53, 0x00, 0x02, ETX};

	inst[1] = reg;

	ser_flush_buffer();

	// write the first request byte
	r = ser_write(inst,4);
	if ( r<0 )
		return -1;
	
	// read the second response (VAL_1 + VAL_2 + ACK)
	r = ser_read(resp,3,timeout);
	if ( r<0 )
		return r;

	if (resp[2] != ETX)
		return -3;

	data[1] = resp[0];
	data[0] = resp[1];

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
	uchar reset[2] = {0x55, ETX};

	r = pxd_serialWrite(0x1,0,(char*)reset,2);
	if ( r<0 )
		return -1;

	return 0;
}

/* int ser_set_state(uchar mode, time_t timeout)
   OBSOLETE
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
	//time_t in_time;

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

	//usleep(100000); //wait for the command to be executed
	libcam_sleep(100);

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

/* int ser_set_tec_point(uchar *val, time_t timeout)

	Arguments:
		val			values to be written to the register (12 bit DAC value)
						val[0] = LL, val[1] = MM
		timeout	maximum time for the response [s]

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		invalid ack
		-4		timed out

	Behaviour:
		write the TEC set point (a 12 bit value with MSB and upper nibble of LSB)
		and wait for ACK
*/
int ser_set_tec_point(uchar *val, time_t timeout) {
	int r;
	uchar inst[7] = {0x53, 0x98, 0x03, 0x22, 0x00, 0x00, ETX};
	uchar ack;
	//time_t in_time;

	inst[4] = val[1];
	inst[5] = val[0];

	ser_flush_buffer();

	r = ser_write(inst,7);	
	if (r<0)
		return r;

	r = ser_read(&ack,1,timeout);
	if (r<0)
		return r;

	if (ack != ETX)
		return -4;

	return 0;
}

/* int ser_get_tec_point(uchar *val, time_t timeout)

	Arguments:
		val			values of the register (12 bit DAC value) - 2 bytes
						val[0] = LL, val[1] = MM
		timeout	maximum time for the response [s]

	Return:
		0			all ok
		-1		serial write error
		-2		serial read error
		-3		invalid ack
		-4		timed out

	Behaviour:
		read the TEC set point (a 12 bit value with MSB and upper nibble of LSB)
		and wait for ACK
*/
int ser_get_tec_point(uchar *val, time_t timeout) {
	int r;
	uchar inst1[5] = {0x53, 0x98, 0x01, 0x20, ETX};
	uchar inst2[4] = {0x53, 0x99, 0x02, ETX};
	//uchar ack;
	//time_t in_time;
	uchar resp[3];

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
	
	// read the second response (MSB + LSB + ACK)
	r = ser_read(resp,3,timeout);
	if ( r<0 )
		return r;

	if (resp[2] != ETX)
		return -3;

	val[1] = resp[0];
	val[0] = resp[1];

	return 0;
}

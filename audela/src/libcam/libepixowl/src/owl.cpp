/* owl.c 
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
 * Commands to send to the camera Raptor Photonics OWL
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <libcam/util.h>

#include "owl.h"
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
int microReset(int raptor_model) {
	int ret;
	if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		char command[255];
		strcpy(command,"55 99 66 11 50 EB");
		ret = ser_write_free(command,NULL);
	} else {

		ret = ser_reset();
		if (ret<0)
			return ret;

		libcam_sleep(10); // 10 ms

		do {
			ret = ser_set_state(ACK_ON|ENABLE_COMMS,2);
		} while (ret != 0);

		ret = ser_set_state(ACK_ON|UNHOLD_FPGA,2);
		//printf("%d\n",ret);
		if (ret<0)
			return ret;

		//do {} while ( ! (status & FPGA_BOOTED) );
		/*
			libcam_sleep(1);
			ret = ser_get_status(&status,2);
			if (ret<0)
				return ret;
		*/

		ret = ser_set_state(ACK_ON|UNHOLD_FPGA,2);
		if (ret<0)
			return ret;
	}

	return 0;
		
}

/* int setState(uchar mode)
   OBSOLETE
	Arguments:
		mode		state mode required

	Return:
		0		all ok
		<0	error

	Behaviour:
		set the system state (checksum, ack, FPGA reset, comms to FPGA EPROM)
*/
int setState(int raptor_model, uchar mode) {
	return ser_set_state(mode,2);
}

/* int setSystemState(uchar *status)

	Arguments:
		status[8]		system status

	Return:
		0		all ok
		<0	error

	Behaviour:
		read system status (checksum, ack, FPGA booted ok, ...)

		To access :
		status[ENABLE_COMMS_TO_FPGA]
		status[HOLD_FPGA_IN_RESET]
		etc...

*/
int setSystemState(int raptor_model, int *status) {
	int r;
	char command[255];
	uint32 y,entier=0,k;
	//uchar ret;
	for (k=0;k<8;k++) {
      entier+= (status[k] << k );
	}
	y = entier;
	sprintf(command,"4F %s 50",conv_dec2hexa((uchar)y));
	r=ser_write_free(command,NULL);
	return r;
}

/* int setFPGACTRLreg(uchar *status)

	Arguments:
		status[8]		FPGA CTRL reg

	Return:
		0		all ok
		<0	error

	Behaviour:

		To access :
		status[define ENABLE_TEC]
		status[define ENABLE_AUTO_EXP]
		etc...

*/
int setFPGACTRLreg(int raptor_model, int *status) {
	int r;
	char command[255];
	uint32 y,entier=0,k;
	//uchar ret;
	for (k=0;k<8;k++) {
      entier+= (status[k] << k );
	}
	y = entier;
	sprintf(command,"53 E0 02 00 %s 50",conv_dec2hexa((uchar)y));
	r=ser_write_free(command,NULL);
	return r;
}

/* int setTrigMode(uchar *status)

	Arguments:
		status[8]		system status

	Return:
		0		all ok
		<0	error

	Behaviour:
		trigger mode 
																RAPTOR_EAGLE RAPTOR_OWL640
																				 RAPTOR_NINOX
		bit 7 = 1 enable rising edge (0=falling)  x            0             
		bit 6 = 1 enable external trigger         x            x             
		bit 5 = Reserved                          .            .             
				= for -ve edge trig                 .            x             
		bit 4 = reserved                          .            .
				= 1 high gain trigger mode 2        .            x
		bit 3 = 1 to abort current exposure       x            0             
		bit 2 = 1 starts cont. sequence           x            .             
				= 1 high gain                       .            x
		bit 1 = 1 fixed frame rate (0=continuous) x            .
				= 1 high gain                       .            x
		bit 0 = 1 for snapshot                    x            0                          		

		To access :
		status[...]
		etc...

*/
int setTrigMode(int raptor_model, int *status) {
	int r=0;
	if ( raptor_model == RAPTOR_EAGLE || raptor_model == RAPTOR_OSPREY ) {
		char command[255];
		uint32 y,entier=0,k;
		for (k=0;k<8;k++) {
			entier+= (status[k] << k );
		}
		y = entier;
		sprintf(command,"53 E0 02 D4 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,NULL);
	} else if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		char command[255];
		uint32 y,entier=0,k;
		status[2]=status[1]; // high/low gain
		for (k=0;k<8;k++) {
			entier+= (status[k] << k );
		}
		y = entier;
		sprintf(command,"53 E0 02 F2 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,NULL);
	}
	return r;
}


/* int setTEC_AEXP(uchar mode)

	Arguments:
		mode		TEC mode (TEC_ON or TEC_OFF) | AEXP mode (AEXP_ON or AEXP_OFF)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		enables or disables TEC and Auto Exp
*/
int setTEC_AEXP(int raptor_model, uchar mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r = ser_write_reg(0x00,mode,2);
	} else if (raptor_model == RAPTOR_KINGFISHER ) {
		char command[255];
		if (mode==TEC_OFF) {
			strcpy(command,"53 E0 02 00 00 50");
		} else {
			strcpy(command,"53 E0 02 00 01 50");
		}
		r=ser_write_free(command,NULL);
	}
	return r;
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
int setFrameRate(int raptor_model, double frate) {
	int r;
	if ( (raptor_model==RAPTOR_OWL320) ) {
		/*
		int r;
		uchar i;
		uint32 cycles;
		uchar *p_cycles;

		cycles = (uint32)(CLOCK_FR/frate);
		p_cycles = (uchar *)&cycles;

		for (i=0; i<4; i++) {
			r = ser_write_reg(0xdd+i,p_cycles[3-i],2);
			if ( r<0 )
				return r;
		}
		*/
		uint32 counts = (uint32)(5e6*frate);
		uchar *p_cycles = (uchar *)&counts;
		for (uchar i=0; i<4; i++) {
			r = ser_write_reg(0xdd+i,p_cycles[3-i],2);
		}
	} else if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		/*
		uint32 counts = (uint32)(40e6*frate);
		uchar *p_cycles = (uchar *)&counts;
		for (uchar i=0; i<4; i++) {
			r = ser_write_reg(0xdd+i,p_cycles[3-i],2);
		}*/
		char command[255];
		uint64 y;
		uint64 cycles=0;
		uchar ret;
		cycles = (uint64)(frate*(double)40e6);
		y = cycles / 256/256/256;
		sprintf(command,"53 E0 02 DD %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256*256;
		y = cycles / 256/256;
		sprintf(command,"53 E0 02 DE %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256;
		y = cycles / 256;
		sprintf(command,"53 E0 02 DF %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles ;
		sprintf(command,"53 E0 02 E0 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);

	} else if (raptor_model == RAPTOR_EAGLE ) {
		/*
		uint64 counts = (uint64)(40e6*frate);
		uchar *p_cycles = (uchar *)&counts;
		for (uchar i=0; i<5; i++) {
			r = ser_write_reg(0xdc+i,p_cycles[4-i],2);
		}
		*/
		char command[255];
		uint64 y;
		uint64 cycles=0;
		uchar ret;
		cycles = (uint64)(frate*(double)40e6);
		y = cycles / 256/256/256/256;
		sprintf(command,"53 E0 02 DC %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256*256*256;
		y = cycles / 256/256/256;
		sprintf(command,"53 E0 02 DD %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256*256;
		y = cycles / 256/256;
		sprintf(command,"53 E0 02 DE %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256;
		y = cycles / 256;
		sprintf(command,"53 E0 02 DF %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles ;
		sprintf(command,"53 E0 02 E0 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
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
int setExposure(int raptor_model, double exp) {
	int r;

	if (raptor_model == RAPTOR_OWL320 ) {
		/*
		uchar i;
		uint32 cycles;
		uchar *p_cycles;

		cycles = (uint32)((CLOCK_EXP)*exp);
		p_cycles = (uchar *)&cycles;

		for (i=0; i<4; i++) {
			r = ser_write_reg(0xee+i,p_cycles[3-i],2);
			if ( r<0 )
				return r;
		}

		*/
		uint32 counts = (uint32)(160e6*exp);
		uchar *p_cycles = (uchar *)&counts;
		for (uchar i=0; i<4; i++) {
			r = ser_write_reg(0xed+i,p_cycles[3-i],2);
		}
	} else if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		/*
		uint32 counts = (uint32)(40e6*exp);
		uchar *p_cycles = (uchar *)&counts;
		for (uchar i=0; i<4; i++) {
			r = ser_write_reg(0xed+i,p_cycles[3-i],2);
		}
		*/
		char command[255];
		uint64 y;
		uint64 cycles=0;
		uchar ret;
		cycles = (uint64)(exp*(double)40e6);
		y = cycles / 256/256/256;
		sprintf(command,"53 E0 02 EE %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256*256;
		y = cycles / 256/256;
		sprintf(command,"53 E0 02 EF %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256;
		y = cycles / 256;
		sprintf(command,"53 E0 02 F0 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles ;
		sprintf(command,"53 E0 02 F1 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	} else if (raptor_model == RAPTOR_EAGLE || raptor_model == RAPTOR_KINGFISHER) {
		char command[255];
		uint64 y;
		uint64 cycles=0;
		uchar ret;
		cycles = (uint64)(exp*(double)40e6);
		y = cycles / 256/256/256/256;
		sprintf(command,"53 E0 02 ED %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256*256*256;
		y = cycles / 256/256/256;
		sprintf(command,"53 E0 02 EE %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256*256;
		y = cycles / 256/256;
		sprintf(command,"53 E0 02 EF %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256*256;
		y = cycles / 256;
		sprintf(command,"53 E0 02 F0 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles ;
		sprintf(command,"53 E0 02 F1 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return 0;
}

/* int setTrigger(uchar mode)

	Arguments:
		mode		trigger mode (list defined in owl.h)

	Return:
		0			all ok
		<0		error

	Behaviour:
		possible modes: TRG_EXT + (TRG_RISE or TRG_FALL) or TRG_INT
*/
int setTrigger(int raptor_model, uchar mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r = ser_write_reg(0xd4,mode,2);
	}
	return r;
}

/* int set_digital_video_gain(int gain)

	Arguments:
		gain		digital video gain

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the digital video gain
*/
int set_digital_video_gain(int raptor_model, double gain) {
	int r;
	/*
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;
		uint16 g;
		uchar *pg;

		g = (uint16)gain*256;
		pg = (uchar *)&g;

		for (i=0; i<2; i++) {
			r = ser_write_reg(0xd5+i,pg[1-i],2);
			if ( r<0 )
				return r;
		}
	}
	*/
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		char command[255];
		uint32 y;
		uint32 cycles=0;
		uchar ret;
		cycles = (uint32)(gain*256);
		y = cycles / 256;
		sprintf(command,"53 E0 02 C6 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles;
		sprintf(command,"53 E0 02 C7 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return 0;
}

/* int setTriggerDelay(double delay)

	Arguments:
		delay		trigger delay (in s)

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the external trigger delay
*/
int setTriggerDelay(int raptor_model, double delay) {
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;
		uint64 cycles;
		uchar *p_cycles;

		cycles = (uint64)((CLOCK_EXP)*delay);
		p_cycles = (uchar *)&cycles;

		for (i=0; i<5; i++) {
			r = ser_write_reg(0xe9+i,p_cycles[4-i],2);
			if ( r<0 )
				return r;
		}
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
int setDynamicRange(int raptor_model, uchar mode) {
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;
		uchar std[4] = { 0x2f, 0xfc, 0x00, 0x04 };
		uchar high[4] = { 0x3f, 0xfc, 0x00, 0x04 };
		uchar *selected = NULL;

		if ( mode == HIGH_DYNAMIC )
			selected = high;
		else if ( mode == STD_DYNAMIC )
			selected = std;
		else
			return -5;

		for (i=0; i<5; i++) {
			r = ser_write_reg(0xe4+i,selected[i],2);
			if ( r<0 )
				return r;
		}
	}
	
	return 0;

}

/* int setTECsetpoint(int temp)

	Arguments:
		temp		temperature (2 bytes)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		set the TEC temperature
*/
int setTECsetpoint(int raptor_model, double t_celcius, double DAC_0, double DAC_40) {
	int r=0;
	int dac;
	if ( (raptor_model == RAPTOR_OWL320) || (raptor_model == RAPTOR_OWL640) ) {
		if (t_celcius<0) {
			t_celcius=0;
		}
	} else if (raptor_model == RAPTOR_NINOX) {
		if (t_celcius<-25) {
			t_celcius=-25;
		}
	} else if (raptor_model == RAPTOR_EAGLE ) {
		if (t_celcius<-40) {
			t_celcius=-40;
		}
	}
	dac = (int) (DAC_0  + t_celcius*(DAC_40 - DAC_0)/40.);
	if (raptor_model == RAPTOR_OWL320) {
		uchar *pdac;
		dac = dac << 4;
		pdac = (uchar *)&dac;
		r = ser_set_tec_point(pdac,2);
	} else if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		char command[255];
		uint32 y;
		uint32 cycles=0;
		uchar ret;
		cycles = (uint32)(dac);
		y = cycles / 256;
		sprintf(command,"53 E0 02 FB %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles;
		sprintf(command,"53 E0 02 FA %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y;
		uint32 cycles=0;
		uchar ret;
		cycles = (uint32)(dac);
		y = cycles / 256;
		sprintf(command,"53 E0 02 03 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		cycles -= y*256;
		y = cycles;
		sprintf(command,"53 E0 02 04 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
}

/* int setNUC(uchar mode)

	Arguments:
		mode	NUC mode (see owl.h and the OWL manual)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		set the NUC mode
*/
int setNUCstate(int raptor_model, uchar mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		char command[255];
		sprintf(command,"53 E0 02 F9 %s 50",conv_dec2hexa((uchar)mode));
		r=ser_write_free(command,NULL);
		//r = ser_write_reg(0xf9,mode,2);
	}
	return r;
}

/* int setAutoLevel(int level)

	Arguments:
		level		value between 0 and 0x3fff

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the average video level detector
*/
int setAutoLevel(int raptor_model, int level) {
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;
		uint16 l;
		uchar *pl;
		l = (uint16)level;
		l = l << 2;
		pl = (uchar *)&l;
		for (i=0; i<2; i++) {
			r = ser_write_reg(0x23+i,pl[1-i],2);
			if ( r<0 )
				return r;
		}
	}

	return 0;
}

/* int setPeakAver(uchar mode)

	Arguments:
		mode	FULL_PEAK or FULL_AVERAGE

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the PEAK/Average option
*/
int setPeakAver(int raptor_model, uchar mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r = ser_write_reg(0x2d,mode,2);
	}
	return r;
}

/* int setAGCspeed(uchar speed)

	Arguments:
		speed		bits 7..4 GAIN speed, bits 3..0 EXP speed

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the AGC speed
*/
int setAGCspeed(int raptor_model, uchar speed) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r = ser_write_reg(0x2f,speed,2);
	}
	return r;
}

/* int setROIappearance(uchar mode)

	Arguments:
		mode	GAIN_1_OUT, GAIN_075_OUT, GAIN_1_BOX

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the ROI appearance
*/
int setROIappearence(int raptor_model, uchar mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r = ser_write_reg(0x31,mode,2);
	}
	return r;
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
int setROIxsize(int raptor_model, int size) {
	uchar s;
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		s = (uchar)(size/4);
		r = ser_write_reg(0x35,s,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		entier = (uint32)(size);
		y = entier / 256;
		sprintf(command,"53 E0 02 B4 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		entier -= y*256;
		y = entier;
		sprintf(command,"53 E0 02 B5 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
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
int setROIxoffset(int raptor_model, int offset) {
	uchar o;
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		o = (uchar)(offset/4);
		r = ser_write_reg(0x32,o,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		entier = (uint32)(offset);
		y = entier / 256;
		sprintf(command,"53 E0 02 B6 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		entier -= y*256;
		y = entier;
		sprintf(command,"53 E0 02 B7 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
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
int setROIysize(int raptor_model, int size) {
	uchar s;
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		s = (uchar)(size/4);
		r = ser_write_reg(0x36,s,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		entier = (uint32)(size);
		y = entier / 256;
		sprintf(command,"53 E0 02 B8 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		entier -= y*256;
		y = entier;
		sprintf(command,"53 E0 02 B9 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
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
int setROIyoffset(int raptor_model, int offset) {
	uchar o;
	int r;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		o = (uchar)(offset/4);
		r = ser_write_reg(0x33,o,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		entier = (uint32)(offset);
		y = entier / 256;
		sprintf(command,"53 E0 02 BA %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
		entier -= y*256;
		y = entier;
		sprintf(command,"53 E0 02 BB %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
}

/* int setXBinning(int binning)

	Arguments:
		binning   	binning along X

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the X binning
*/
int setXBinning(int raptor_model, int *binning) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		if (*binning<1) { *binning = 1; }
		if (*binning>64) { *binning = 64; }
		entier = (uint32)(*binning-1);
		y = entier;
		sprintf(command,"53 E0 02 A1 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
}

/* int setYBinning(int binning)

	Arguments:
		binning   	binning along Y

	Return:
		0			all ok
		<0		error

	Behaviour:
		set the Y binning
*/
int setYBinning(int raptor_model, int *binning) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		if (*binning<1) { *binning = 1; }
		if (*binning>64) { *binning = 64; }
		entier = (uint32)(*binning-1);
		y = entier;
		sprintf(command,"53 E0 02 A2 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	}
	return r;
}

/* int setShutterControlSatus(int raptor_model, int *status)

	Arguments:
		*status=
		0x00 = closed
		0x01 = opened
		0x02 = synchro

	Return:
		0			all ok
		<0		error

	Behaviour:
*/
int setShutterControlSatus(int raptor_model, int *status) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		if (*status<0) { *status = 0; }
		if (*status>2) { *status = 2; }
		y = entier;
		sprintf(command,"53 E0 02 A5 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	} else {
		*status=1;
	}
	return r;
}

/* int setPixelReadoutClock(int raptor_model, int *status)

	Arguments:
		*mode EAGLE =
			0 = 2MHz
			1 = 75kHz

	Return:
		0			all ok
		<0		error

	Behaviour:
*/
int setPixelReadoutClock(int raptor_model, int *mode) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		if (*mode==1) { 
			// 1 = 75kHz
			y = 0x43;
			sprintf(command,"53 E0 02 A3 %s 50",conv_dec2hexa((uchar)y));
			r=ser_write_free(command,&ret);
			y = 0x80;
			sprintf(command,"53 E0 02 A4 %s 50",conv_dec2hexa((uchar)y));
			r=ser_write_free(command,&ret);
		} else {
			// 0 = 2MHz
			*mode=0;
			y = 0x02;
			sprintf(command,"53 E0 02 A3 %s 50",conv_dec2hexa((uchar)y));
			r=ser_write_free(command,&ret);
			y = 0x02;
			sprintf(command,"53 E0 02 A4 %s 50",conv_dec2hexa((uchar)y));
			r=ser_write_free(command,&ret);
		}
	}
	return r;
}

/* int setReadoutMode(int raptor_model, int *status)

	Arguments:
		*mode EAGLE =
			0x00 = nomal reading (pixels)
			0x04 = patern test reading

		*mode KINGFISHER =
			0x00 = enable single acquire
			0x01 = enable live acquire

	Return:
		0			all ok
		<0		error

	Behaviour:
*/
int setReadoutMode(int raptor_model, int *mode) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		if (*mode==0x04) { 
			// Test patern reading
		} else {
			// Normal readout
			*mode=0;
		}
		y = *mode;
		sprintf(command,"53 E0 02 F7 %s 50",conv_dec2hexa((uchar)y));
		r=ser_write_free(command,&ret);
	} else if (raptor_model == RAPTOR_KINGFISHER ) {
		char command[255];
		uint32 y,entier=0;
		uchar ret;
		if (*mode==0x00) { 
			// enable single acquire
			strcpy(command,"53 E0 02 F2 00 50");
			r=ser_write_free(command,&ret);
			strcpy(command,"53 E0 02 EA 01 50");
			r=ser_write_free(command,&ret);
		} else {
			// enable live acquire
			strcpy(command,"53 E0 02 EA 00 50");
			r=ser_write_free(command,&ret);
			y = 0x10;
			sprintf(command,"53 E0 02 F2 %s 50",conv_dec2hexa((uchar)y));
			r=ser_write_free(command,&ret);
		}
	}
	return r;
}

/* =============================================================================== */
/* ========================START OF THE GET FUNCTIONS ============================ */
/* =============================================================================== */

/* int getStatus(uchar *status)
	OBSOLETE

	Arguments:
		status		system status (see Osprey documentation) - 1 byte

	Return:
		0		all ok
		<0	error

	Behaviour:
		read system status (checksum, ack, FPGA booted ok, ...)
*/
int getStatus(int raptor_model, uchar *status) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_get_status(status,2);
	}
	return r;
}

/* int getSystemState(uchar *status)

	Arguments:
		status[8]		system status

	Return:
		0		all ok
		<0	error

	Behaviour:
		read system status (checksum, ack, FPGA booted ok, ...)
                                                                     RAPTOR_OSPREY
		                                                               RAPTOR_KINGFISHER
                                                       RAPTOR_KITE   RAPTOR_OWL320
                                          RAPTOR_EAGLE RAPTOR_OWL320 RAPTOR_NINOX  
		bit 7 = Reserved                          .            .             .
		bit 6 = 1 check sum mode enabled          x            .             x             x
		bit 5 = Reserved                          .            .             .
		bit 4 = 1 to enable command ACK           x            x             x             x
		bit 3 = Reserved                          .            .             .
		bit 2 = 1 if FPGA booted ok               x            .             .
		bit 1 = 0 to Hold FPGA in RESET           x            x             x             x
		bit 0 = 1 to enable comms to FPGA         x            x             x             		

		To access :
		status[ENABLE_COMMS_TO_FPGA]
		status[HOLD_FPGA_IN_RESET]
		etc...

*/
int getSystemState(int raptor_model, int *status) {
	int r=0,k;
	uchar st;
	r=ser_write_free("49 50",&st);
	for (k=0;k<8;k++) {
		status[k]= ( st >> k ) & 0x01 ;
	}
	return r;
}

/* int getFPGACTRLreg(uchar *status)

	Arguments:
		status[8]		FPGA CTRL reg

	Return:
		0		all ok
		<0	error

	Behaviour:

		To access :
		status[ENABLE_TEC]
		status[ENABLE_AUTO_EXP]
		etc...

*/
int getFPGACTRLreg(int raptor_model, int *status) {
	int r=0,k;
	uchar st,ret;
	r=ser_write_free("53 E0 01 00 50",&ret);
	r=ser_write_free("53 E1 01 50",&st);
	for (k=0;k<8;k++) {
		status[k]= ( st >> k ) & 0x01 ;
	}
	return r;
}

/* int getTrigMode(uchar *status)

	Arguments:
		status[8]		system status

	Return:
		0		all ok
		<0	error

	Behaviour:
		read trigger mode 
                                          RAPTOR_OSPREY
                                          RAPTOR_EAGLE 
		bit 7 = 1 enable rising edge (0=falling)  x            .             
		bit 6 = 1 enable external trigger         x            .             
		bit 5 = Reserved                          .            .             
		bit 4 = reserved                          .            .             
		bit 3 = 1 to abort current exposure       x            .             
		bit 2 = 1 starts cont. sequence           x            .             
		bit 1 = 1 fixed frame rate (0=continuous) x            .             
		bit 0 = 1 for snapshot                    x            .                          		

		To access :
		status[...]
		etc...

*/
int getTrigMode(int raptor_model, int *status) {
	int r=0;
	if ( raptor_model == RAPTOR_EAGLE || raptor_model == RAPTOR_OSPREY ) {
		int k;
		uchar st,ret;
		r=ser_write_free("53 E0 01 D4 50",&ret);
		r=ser_write_free("53 E1 01 50",&st);
		for (k=0;k<8;k++) {
			status[k]= ( st >> k ) & 0x01 ;
		}
	} else if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		int k;
		uchar st,ret;
		r=ser_write_free("53 E0 01 F2 50",&ret);
		r=ser_write_free("53 E1 01 50",&st);
		for (k=0;k<8;k++) {
			status[k]= ( st >> k ) & 0x01 ;
		}
	}
	return r;
}

/* int getTEC_AEXP(uchar *mode)

	Arguments:
		mode		tec on/off (TEC_ON=0x01 or TEC_OFF=0x00) and 
						aexp on/off (AEXP_ON=0x02 or AEXP_OFF=0x00) - 1 byte

	Return:
		0		all ok
		<0	error

	Behaviour:
		return if TEC and Auto Exposure are enabled or not
*/
int getTEC_AEXP(int raptor_model, uchar *mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_read_reg(0x01,0x00,mode,2);
	}
	return r;
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
int getFrameRate(int raptor_model, double *frate) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		/*
		uchar i;
		uint32 cycles;
		uchar *p_cycles;

		p_cycles = (uchar *)&cycles;

		for (i=0; i<4; i++) {
			r = ser_read_reg(0x01,0xdd+i,&p_cycles[3-i],2);
			if ( r<0 )
				return r;
		}
		
		*frate=CLOCK_FR/(double)cycles;
		*/
		uint64 y1,y2,y3,y4;
		uint64 cycles=0;
		uchar ret;
		r=ser_write_free("53 E0 01 DD 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint64)(ret)*256*256*256;
		r=ser_write_free("53 E0 01 DE 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint64)(ret)*256*256;
		r=ser_write_free("53 E0 01 DF 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y3=(uint64)(ret)*256;
		r=ser_write_free("53 E0 01 E0 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y4=(uint64)(ret);
		cycles = y1+y2+y3+y4;
		*frate = (cycles)/(double)40e6;

	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint64 y1,y2,y3,y4,y5;
		uint64 cycles=0;
		uchar ret;
		r=ser_write_free("53 E0 01 DC 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint64)(ret)*256*256*256*256;
		r=ser_write_free("53 E0 01 DD 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint64)(ret)*256*256*256;
		r=ser_write_free("53 E0 01 DE 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y3=(uint64)(ret)*256*256;
		r=ser_write_free("53 E0 01 DF 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y4=(uint64)(ret)*256;
		r=ser_write_free("53 E0 01 E0 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y5=(uint64)(ret);
		cycles = y1+y2+y3+y4+y5;
		*frate = (cycles)/(double)40e6;
	}		
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
int getExposure(int raptor_model, double *exp) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;
		uint32 cycles=0;
		uchar *p_cycles;

		p_cycles = (uchar *)&cycles;

		for (i=0; i<4; i++) {
			r = ser_read_reg(0x01,0xee+i,&p_cycles[3-i],2);
			if ( r<0 )
				return r;
		}

		if (raptor_model == RAPTOR_OWL320) {
			*exp = (cycles)/(double)160e6;
		} else {
			*exp = (cycles)/(double)40e6;
		}

	} else if (raptor_model == RAPTOR_EAGLE || raptor_model == RAPTOR_KINGFISHER) {
		uint64 y1,y2,y3,y4,y5;
		uint64 cycles=0;
		uchar ret;
		r=ser_write_free("53 E0 01 ED 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint64)(ret)*256*256*256*256;
		r=ser_write_free("53 E0 01 EE 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint64)(ret)*256*256*256;
		r=ser_write_free("53 E0 01 EF 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y3=(uint64)(ret)*256*256;
		r=ser_write_free("53 E0 01 F0 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y4=(uint64)(ret)*256;
		r=ser_write_free("53 E0 01 F1 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y5=(uint64)(ret);
		cycles = y1+y2+y3+y4+y5;
		*exp = (cycles)/(double)40e6;
	}		
	return 0;
}

/* int get_digital_video_gain(int *gain)

	Arguments:
		gain		digital video gain

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current digital video gain
*/
int get_digital_video_gain(int raptor_model, double *gain) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		/*uchar i;
		uint16 g;
		uchar *pg;

		pg = (uchar *)&g;

		for (i=0; i<2; i++) {
			r = ser_read_reg(0x01,0xd5+i,&pg[1-i],2);
			if ( r<0 )
				return r;
		}

		*gain=g/256;
		*/
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 C6 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 C7 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		adu = (int)(y1+y2);
		*gain = (double)((adu)/(double)256);
	} else {
		*gain=1;
	}
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
int getPCBtemp(int raptor_model, double *temp) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar data[2];
		double t;

		r = ser_read_temp_reg(0x97,data,2);
		if ( r<0 )
			return r;

		t = 0.5*( (data[0]&0x80) >> 7 );
		t += (double)data[1];

		*temp = t;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 02 70 00 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 02 71 00 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		adu = (int)(y1+y2);
		*temp = (adu)/(double)16;
	}		

	return 0;
}

/* int getSensorTemp(int *temp)

	Arguments:
		temp		CMOS sensor temperature (to be extract -> see doc)

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the current temperature of the photon sensor
*/
int getSensorTemp(int raptor_model, int *temp, int ADC_0, int ADC_40, double *t_celcius) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320) {
		uchar data[2];
		ushort *t;

		r = ser_read_temp_reg(0x91,data,2);
		if ( r<0 )
			return r;

		t = (ushort *)data;

		*temp=(int)*t;
		*t_celcius = (double)(*temp - ADC_0)/(ADC_40 - ADC_0)*40.;
	} else if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		// Get sensor temperature
		r=ser_write_free("53 E0 01 6E 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 6F 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*temp = (int)(y1+y2);
		*t_celcius = (double)(*temp - ADC_0)/(ADC_40 - ADC_0)*40.;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 02 6E 00 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 02 6F 00 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		adu = (int)(y1+y2);
		*temp = adu;
		*t_celcius = (double)(*temp - ADC_0)/(ADC_40 - ADC_0)*40.;
	}
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
int getMicroVersion(int raptor_model, uchar *version) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_get_micro(version,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		libcam_sleep(100); // ms
		r=ser_write_free("56 50",NULL);
		r = ser_read(version,2,100);
	}
	return r;
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
int getFPGAversion(int raptor_model, uchar *version) {
	int r=0;
	uchar ret;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;

		for (i=0; i<2; i++) {
			r = ser_read_reg(0x01,0x7e + i,version+i,2);
			if ( r<0 )
				return r;
		}
	} else if (raptor_model == RAPTOR_EAGLE ) {
		//uchar ret;
		r=ser_write_free("53 E0 01 7E 50",&ret);
		r=ser_write_free("53 E1 01 50",&version[0]);
		r=ser_write_free("53 E0 01 7F 50",&ret);
		r=ser_write_free("53 E1 01 50",&version[1]);
	}
	return 0;
}

/* int getTrigger(uchar *mode)

	Arguments:
		mode		trigger mode (list defined in owl.h)

	Return:
		0			all ok
		<0		error

	Behaviour:
		return current trigger mode
		possible modes: TRG_RISE, TRG_EXT
*/
int getTrigger(int raptor_model, uchar *mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_read_reg(0x01,0xf2,mode,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uchar ret;
		r=ser_write_free("53 E0 01 D4 50",&ret);
		r=ser_write_free("53 E1 01 50",mode);
	}
	return r;
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
int getROIxsize(int raptor_model, int *size) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar s;

		r = ser_read_reg(0x01,0x35,&s,2);
		if ( r<0 )
			return r;

		*size = (int)s*4;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 B4 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 B5 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*size = (int)(y1+y2);
	}
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
int getROIxoffset(int raptor_model, int *offset) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar o;

		r = ser_read_reg(0x01,0x32,&o,2);
		if ( r<0 )
			return r;

		*offset = (int)o*4;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 B6 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 B7 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*offset = (int)(y1+y2);
	}
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
int getROIysize(int raptor_model, int *size) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar s;

		r = ser_read_reg(0x01,0x36,&s,2);
		if ( r<0 )
			return r;

		*size = (int)s*4;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 B8 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 B9 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*size = (int)(y1+y2);
	}
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
int getROIyoffset(int raptor_model, int *offset) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar o;

		r = ser_read_reg(0x01,0x33,&o,2);
		if ( r<0 )
			return r;

		*offset = (int)o*4;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 BA 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 BB 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*offset = (int)(y1+y2);
	}
	return 0;

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
int getSerialNumber(int raptor_model, int *number) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		*number = ser_read_eeprom((uchar *)number,2,2);
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 AE 05 01 00 00 02 00 50",&ret);
		y1=(uint32)(ret);
		r=ser_write_free("53 AF 02 50",&ret);
		y2=(uint32)(ret)*256;
		*number = (int)(y1+y2);
	}
	return 0;

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
int getManuData(int raptor_model, uchar *data) {
	int r;
	//uchar ret;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r = setState(raptor_model, ACK_ON|ENABLE_COMMS|UNHOLD_FPGA);
		if ( r<0 )
			return r;

		r = ser_read_eeprom(data,0x12,2);
		if ( r<0 )
			return r;

		r = setState(raptor_model, ACK_ON|UNHOLD_FPGA);
		if ( r<0 )
			return r;

	} else if (raptor_model == RAPTOR_EAGLE ) {
		libcam_sleep(200); // ms
		r=ser_write_free("53 AE 05 01 00 00 02 00 50",NULL);
		libcam_sleep(200); // ms
		r=ser_write_free("53 AF 12 50",NULL);
		libcam_sleep(200); // ms
		r = ser_read(data,18,5);
	}
	return 0;
}

/* int getTECtemp(int *temp)

	Arguments:
		temp		temperature (2 bytes)

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		get the TEC temperature
*/
int getTECtemp(int raptor_model, int *temp, double DAC_0, double DAC_40, double *t_celcius) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 ) {
		uchar data[2];
		ushort *pt;

		r = ser_get_tec_point(data,2);
		if (r<0)
			return r;

		pt = (ushort *)data;
		*pt = *pt >> 4;
		*temp = (int)(*pt);
		*t_celcius = (double)(*temp - DAC_0)/(DAC_40 - DAC_0)*40.;
		//dac = (ushort)((cam->check_temperature-0)/(40-0)*(cam->DAC_40-cam->DAC_0)+cam->DAC_0);
	} else if (raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		// Get TEC set point
		r=ser_write_free("53 E0 01 FB 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 FA 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*temp = (int)(y1+y2);
		*t_celcius = (double)(*temp - DAC_0)/(DAC_40 - DAC_0)*40.;
	} else if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		// Get TEC set point
		r=ser_write_free("53 E0 01 03 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 04 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*temp = (int)(y1+y2);
		*t_celcius = (double)(*temp - DAC_0)/(DAC_40 - DAC_0)*40.;
	} else if (raptor_model == RAPTOR_KINGFISHER ) {
		uint32 y1,y2;
		int adu=0;
		uchar ret;
		// Get CCD silicon temperature
		r=ser_write_free("53 E0 02 6E 00 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret)*256;
		r=ser_write_free("53 E0 01 6F 00 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y2=(uint32)(ret);
		*temp = (int)(y1+y2);
		*t_celcius = (double)(*temp - DAC_0)/(DAC_40 - DAC_0)*40.;
	}

	return 0;
}

/* int getNUC(uchar *mode)

	Arguments:
		mode	NUC mode (see owl.h and the OWL manual) -- 1 byte

	Retrun:
		0		all ok
		<0 	error

	Behaviour:
		get the NUC mode
*/
int getNUC(int raptor_model, uchar *mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_read_reg(0x01,0xf9,mode,2);
	}
	return r;
}

/* int getAutoLevel(int *level)

	Arguments:
		level		value between 0 and 0x3fff

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the average video level detector
*/
int getAutoLevel(int raptor_model, int *level) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		uchar i;
		uint16 *pl;
		uchar data[2];

		for (i=0; i<2; i++) {
			r = ser_read_reg(0x01,0x23+i,&data[1-i],2);
			if ( r<0 )
				return r;
		}
		pl=(uint16*)data;

		*pl = *pl >> 2;
		*level = *pl;
	}
	return 0;
}

/* int getPeakAver(uchar *mode)

	Arguments:
		mode	FULL_PEAK or FULL_AVERAGE -- 1 byte

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the PEAK/Average option
*/
int getPeakAver(int raptor_model, uchar *mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_read_reg(0x01,0x2d,mode,2);
	}
	return r;
}

/* int setAGCspeed(uchar *speed)

	Arguments:
		speed		bits 7..4 GAIN speed, bits 3..0 EXP speed

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the AGC speed
*/
int getAGCspeed(int raptor_model, uchar *speed) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_read_reg(0x01,0x2f,speed,2);
	}
	return r;
}

/* int getROIappearance(uchar *mode)

	Arguments:
		mode	GAIN_1_OUT, GAIN_075_OUT, GAIN_1_BOX

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the ROI appearance
*/
int getROIappearence(int raptor_model, uchar *mode) {
	int r=0;
	if (raptor_model == RAPTOR_OWL320 || raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX) {
		r=ser_read_reg(0x01,0x31,mode,2);
	}
	return r;
}

/* int getXBinning(int *binning)

	Arguments:

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the X binning
*/
int getXBinning(int raptor_model, int *binning) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 A1 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret);
		*binning = (int)(1+y1);
	} else {
		*binning=1;
	}
	return r;
}

/* int getYBinning(int *binning)

	Arguments:

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the Y binning
*/
int getYBinning(int raptor_model, int *binning) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		uint32 y1;
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 A2 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		y1=(uint32)(ret);
		*binning = (int)(1+y1);
	} else {
		*binning=1;
	}
	return r;
}

/* int getShutterControlSatus(int raptor_model, int *status)

	Arguments:

	Return:
		0			all ok
		<0		error

	Behaviour:
		get the shutter control status
		0x00 = closed
		0x01 = opened
		0x02 = synchro
*/
int getShutterControlSatus(int raptor_model, int *status) {
	int r;
	if (raptor_model == RAPTOR_EAGLE ) {
		int adu=0;
		uchar ret;
		r=ser_write_free("53 E0 01 A5 50",&ret);
		r=ser_write_free("53 E1 01 50",&ret);
		*status=(uint32)(ret);
	} else {
		*status=1;
	}
	return r;
}

int get_max_frame_buffer_size(int raptor_model) {
	return pxd_imageZdim();
}

//return the minimum exposure
double get_min_exposure(int raptor_model) {
	unsigned long maxex_cycles = 0;
	double exp=0;
	if ( raptor_model == RAPTOR_OWL320 ) {
		maxex_cycles = 80;
		exp = ((double)maxex_cycles)/80.e6;
	} else if ( raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX ) {
		maxex_cycles = 20;
		exp = ((double)maxex_cycles)/40.e6;
	} else if ( raptor_model == RAPTOR_EAGLE || raptor_model == RAPTOR_KINGFISHER ) {
		maxex_cycles = 1;
		exp = ((double)maxex_cycles)/40.e6;
	}
	return exp;
}

//return the maximum exposure
double get_max_exposure(int raptor_model) {
	uint64 maxex_cycles = 0;
	double exp=1;
	if ( raptor_model == RAPTOR_OWL320 ) {
		maxex_cycles = 0xffffffff;
		exp = ((double)maxex_cycles)/80.e6;
	} else if ( raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX ) {
		maxex_cycles = 0xffffffff;
		exp = ((double)maxex_cycles)/40.e6;
	} else if ( raptor_model == RAPTOR_EAGLE || raptor_model == RAPTOR_KINGFISHER ) {
		maxex_cycles = 0xffffffffff;
		exp = ((double)maxex_cycles)/40.e6;
	}
	return exp;
}

//return the maximum frame rate
double get_max_frame_rate(int raptor_model,int nlines) {
	unsigned long maxex_cycles = 0;
	double exp=0;
	double frq=1e6;
	if ( raptor_model == RAPTOR_OWL320 ) {
		frq = 80.e6 / ((double)(nlines*1028+27989));
	} else if ( raptor_model == RAPTOR_OWL640 ||  raptor_model == RAPTOR_NINOX ) {
		maxex_cycles = 499040;
		exp = ((double)maxex_cycles)/80.e6;
		frq = 1/(exp);
	}
	return frq;
}

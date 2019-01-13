/* owl.h
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
 * Commands to send to the camera Raptor Photonics OWL:browse confirm wa
 - header
 */

#ifndef H_OWL
#define H_OWL

#include "serial.h"
#include "camera.h"

// Supported Raptor cameras
#define RAPTOR_UNKNOWN 0
#define RAPTOR_OWL320 1
#define RAPTOR_OWL640 2
#define RAPTOR_NINOX 3
#define RAPTOR_EAGLE 4
#define RAPTOR_KINGFISHER 5
#define RAPTOR_KITE 6
#define RAPTOR_OSPREY 7

// Supported GPS for datation
#define GPS_NONE 0
#define GPS_SCHIAVON 1

// State modes
#define	ACK_ON				0x10
#define UNHOLD_FPGA		0x02
#define	ENABLE_COMMS	0x01

// TEC modes
#define TEC_ON	0x01
#define TEC_OFF	0x00
#define AEXP_ON 0x02
#define AEXP_OFF 0x00

// Clock frequency (Hz)
#define CLOCK_EXP 160000000
#define CLOCK_FR 5000000

/*
// NUC state
#define OFFSET_CORRECTED 			0x00
#define OFFSET_GAIN_CORRECTED 0x20
#define NORMAL 								0x40
#define OFFSET_GAIN_DARK			0x60
#define EIGHT_BIT_OFF_32					0x80
#define EIGHT_BIT_DARK						0xa0
#define EIGHT_BIT_GAIN_128				0xc0
#define OFF_GAIN_DARK_BADPIX	0xe0
*/

// PEAK/Average
#define FULL_PEAK 0x00
#define FULL_AVERAGE 0xff

// ROI Appearence
#define GAIN_1_OUT		0x00
#define GAIN_075_OUT	0x80
#define GAIN_1_BOX		0x40

// Trigger modes
#define TRG_EXT		0x40
#define TRG_RISE	0x20
#define TRG_FALL	0x00
#define TRG_INT		0x00

// Dynamic Range
#define HIGH_DYNAMIC 0x01
#define STD_DYNAMIC 0x00

// System Status
/* -------------------------------------------------------------------------------
                                                               RAPTOR_OSPREY
                                                               RAPTOR_KINGFISHER
                                                 RAPTOR_KITE   RAPTOR_OWL640
                                    RAPTOR_EAGLE RAPTOR_OWL320 RAPTOR_NINOX  
bit 7 = Reserved                          .            .             .
bit 6 = 1 check sum mode enabled          x            .             x            
bit 5 = Reserved                          .            .             .
bit 4 = 1 to enable command ACK           x            x             x            
bit 3 = Reserved                          .            .             .
bit 2 = 1 if FPGA booted ok               x            .             .
bit 1 = 0 to Hold FPGA in RESET           x            x             x            
bit 0 = 1 to enable comms to FPGA         x            x             x             		
------------------------------------------------------------------------------ */
#define ENABLE_COMMS_TO_FPGA   0
#define HOLD_FPGA_IN_RESET     1
#define FPGA_BOOTED            2
#define ENABLE_COMMAND_ACK     4
#define CHECK_SUM_MODE_ENABLED 6

// FPGA CTRL reg
/* -------------------------------------------------------------------------------------------------------------------
                                                             RAPTOR_OWL640               RAPTOR_OSPREY
                                                RAPTOR_EAGLE RAPTOR_NINOX  RAPTOR_OWL320 RAPTOR_KINGFISHER RAPTOR_KITE 
bit 7 = 0 to enable high preamp gain (ie 1e/ADU) (0)  x                           .            .                 .
        1 to enable horizontal flip (1)               .            x                                              
bit 6 = 1 to invert video                             .            x              .            .                 .
bit 5 = Reserved                                      .            .              .            .                 .
bit 4 = Reserved                                      .            .              .            .                 .
bit 3 = Reserved                                      .            .              .            .                 .
bit 2 = 1 enable the fan                              .            x              .            .                 .
bit 1 = 1 to reset the temperature trip flag          x                                        .                 
        1 if deep cooling is enabled                                                                             x
        1 if auto exp is enabled                                   x              x              
bit 0 = 1 to enable TEC (Default 0)                   x            x              x            x                 x
------------------------------------------------------------------------------------------------------------------- */
#define ENABLE_TEC              0
#define ENABLE_AUTO_EXP         1
#define ENABLE_DEEP_COOLING     1
#define RESET_TEMP_FLAG         1
#define ENABLE_FAN              2
#define ENABLE_INVERT_VIDEO     6
#define ENABLE_HIGH_PREAMP_GAIN 7
#define ENABLE_HORIZONTAL_FLIP  7


// Trig Mode and Gain/Trigger mode 
/* -------------------------------------------------------------------------------------------------------------------
                                          RAPTOR_EAGLE RAPTOR_OWL640 RAPTOR_OWL320
														             RAPTOR_NINOX
bit 7 = 1 enable rising edge (0=falling)  x            0             .
bit 6 = 1 enable external trigger         x            x             x
bit 5 = Reserved                          .            .             .
      = for -ve edge trig                 .            x             x
bit 4 = reserved                          .            .					.
      = 1 high gain trigger mode 2        .            x					.
bit 3 = 1 to abort current exposure       x            0             .
bit 2 = 1 starts cont. sequence           x            .             .
      = 1 high gain                       .            x					.
bit 1 = 1 fixed frame rate (0=continuous) x            .					.
      = 1 high gain                       .            x					.
bit 0 = 1 for snapshot                    x            0					.            		
------------------------------------------------------------------------------------------------------------------- */
// Trig mode
#define SELECT_SNAPSHOT_VIDEO        0
#define SELECT_FRAME_RATE_FIXED_CONT 1
#define START_CONT_SEQUENCE          2
#define ABORT_CURRENT_SEQUENCE       3
#define SELECT_EDGE_RISING_FALLING   7
// Gain/Trigger mode
#define SELECT_HIGH_GAIN             1
#define SELECT_HG_TRIG_MODE2         4
#define SELECT_TRIGGER_VE_PLUS       5
// Trig mode and Gain/Trigger mode
#define ENABLE_EXTERNAL_TRIGGER      6


// NUC state
/* -------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------- */
// owl320, Ninox, owl640
#define NUC_OFFSET_CORRECTED 			   0x00
#define NUC_OFFSET_GAIN_CORRECTED      0x20
#define NUC_NORMAL 							0x40
#define NUC_OFFSET_GAIN_DARK			   0x60
#define NUC_EIGHT_BIT_OFF_32				0x80
#define NUC_EIGHT_BIT_DARK					0xa0
#define NUC_EIGHT_BIT_GAIN_128			0xc0
#define NUC_OFF_GAIN_DARK_BADPIX	      0xe0
// Ninox & owl640
#define NUC_ENABLE_BAD_PIXEL_SHOW      0x01
#define NUC_RAMP_TEST_PATTERN          0x10


// ==============================================================================
int serialInit();

int microReset(int raptor_model);
int setSystemState(int raptor_model, int *status);
int setFPGACTRLreg(int raptor_model, int *status);
int setTrigMode(int raptor_model, int *status);

int setState(int raptor_model, uchar mode);
int setTEC_AEXP(int raptor_model,uchar mode);
int setFrameRate(int raptor_model,double frate);
int setExposure(int raptor_model,double exp);
int setTrigger(int raptor_model,uchar mode);
int set_digital_video_gain(int raptor_model,double gain);
int setTriggerDelay(int raptor_model,double delay);
int setDynamicRange(int raptor_model,uchar mode);
int setTECsetpoint(int raptor_model, double t_celcius, double DAC_0, double DAC_40);
int setNUCstate(int raptor_model, uchar mode);
int setAutoLevel(int raptor_model,int level);
int setPeakAver(int raptor_model,uchar mode);
int setAGCspeed(int raptor_model,uchar speed);
int setROIappearence(int raptor_model, uchar mode);
int setROIxsize(int raptor_model, int size);
int setROIxoffset(int raptor_model, int offset);
int setROIysize(int raptor_model, int size);
int setROIyoffset(int raptor_model, int offset);
int setViewNUCmap(int raptor_model, uchar mode);
int setXBinning(int raptor_model, int *binning);
int setYBinning(int raptor_model, int *binning);
int setShutterControlSatus(int raptor_model, int *status);
int setPixelReadoutClock(int raptor_model, int *mode);
int setReadoutMode(int raptor_model, int *mode);

//TODO the get section

int getStatus(int raptor_model, uchar *status);
int getFPGACTRLreg(int raptor_model, int *status);
int getSystemState(int raptor_model, int *status);
int getTrigMode(int raptor_model, int *status);

int getTEC_AEXP(int raptor_model, uchar *mode);
int getFrameRate(int raptor_model, double *frate);
int getExposure(int raptor_model, double *exp);
int get_digital_video_gain(int raptor_model, double *gain);
int getPCBtemp(int raptor_model, double *temp);
int getSensorTemp(int raptor_model, int *temp, int ADC_0, int ADC_40, double *t_celcius);
int getMicroVersion(int raptor_model, uchar *version);
int getFPGAversion(int raptor_model, uchar *version);
int getTrigger(int raptor_model, uchar *mode);
int getROIxsize(int raptor_model, int *size);
int getROIxoffset(int raptor_model, int *offset);
int getROIysize(int raptor_model, int *size);
int getROIyoffset(int raptor_model, int *offset);
int getDynamicRange(int raptor_model, uchar *mode);
int getSerialNumber(int raptor_model, int *number);
int getManuData(int raptor_model, uchar *data);
int getTECtemp(int raptor_model, int *temp, double DAC_0, double DAC_40, double *t_celcius);
int getNUC(int raptor_model, uchar *mode);
int getAutoLevel(int raptor_model, int *level);
int getPeakAver(int raptor_model, uchar *mode);
int getAGCspeed(int raptor_model, uchar *speed);
int getROIappearence(int raptor_model, uchar *mode);
int getXBinning(int raptor_model, int *binning);
int getYBinning(int raptor_model, int *binning);
int getShutterControlSatus(int raptor_model, int *status);

int get_max_frame_buffer_size(int raptor_model);
double get_min_exposure(int raptor_model);
double get_max_exposure(int raptor_model);
double get_max_frame_rate(int raptor_model,int nlines);

#endif //H_OWL

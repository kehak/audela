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
 * for the Raptor Photonics Osprey camera -- header
 */

#ifndef H_SERIAL
#define H_SERIAL

#include <time.h>
#include "xcliball.h"

// ETX/Error codes
#define ETX								0x50
#define ETX_SER_TIMEOUT		0x51
#define ETX_CK_SUM_ERR		0x52
#define	ETX_I2C_ERR				0x53
#define ETX_UNKNOWN_CMD		0x54
#define	ETX_DONE_LOW			0x55

int ser_config();
int ser_write_reg(uchar reg, uchar val, time_t timeout);
int ser_read_reg(uchar reg, uchar *val, time_t timeout);
int ser_read_temp_reg(uchar reg, uchar *val, time_t timeout);
int ser_set_state(uchar mode, time_t timeout);
int ser_get_status(uchar *status, time_t timeout);
int ser_get_micro(uchar *version, time_t timeout);
int ser_read_eeprom(uchar *res, uchar n_res, time_t timeout);

#endif //H_SERIAL

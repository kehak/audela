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
 * for the Raptor Photonics Owl camera -- header
 */

#ifndef H_SERIAL
#define H_SERIAL

#include <time.h>
#include "xcliball.h"

// ETX/Error codes
#define ETX								0x50

int ser_config();
int ser_write_reg(uchar reg, uchar val, time_t timeout);
int ser_read_reg(uchar bank,uchar reg, uchar *val, time_t timeout);
int ser_read_temp_reg(uchar reg, uchar *val, time_t timeout);
int ser_set_state(uchar mode, time_t timeout);
int ser_get_status(uchar *status, time_t timeout);
int ser_get_micro(uchar *version, time_t timeout);
int ser_read_eeprom(uchar *res, uchar n_res, time_t timeout);
int ser_set_tec_point(uchar *val, time_t timeout);
int ser_get_tec_point(uchar *val, time_t timeout);
int ser_reset();

int conv_hexa2dec(char c);
char *conv_dec2hexa(uchar r);
int ser_write_free(char *t,uchar *ret);
int ser_read(uchar *buf_read, int n_read, time_t timeout);
int ser_write(uchar *buf_wr, int n_wr);
int ser_flush_buffer(void);

#endif //H_SERIAL

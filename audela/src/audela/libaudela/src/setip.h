/* setip.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL <michel-pujol@wanadoo.fr>
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
 * $Id: setip.h,v 1.3 2009-05-01 13:42:18 jacquesmichelet Exp $
 */

#ifndef __SETIP_H__
#define __SETIP_H__

#ifdef __cplusplus
extern "C" {
#endif

int setip(const char *szClientIP, const char *szClientMAC, const char *szClientNM,
	  const char *szClientGW, char *errorMessage);

#ifdef __cplusplus
}
#endif


#endif

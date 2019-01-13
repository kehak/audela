/* liblink.cpp
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

// $Id: useitem.cpp,v 1.1 2006-09-29 19:53:43 michelpujol Exp $

#include <stdlib.h>
#include "liblink/useitem.h"


CUseItem::CUseItem(const char* deviceId, const char* usage, const char *comment) {
   this->deviceId = deviceId;
   this->usage  = usage;
   this->comment  = comment;
}

CUseItem::~CUseItem() {
}


const char * CUseItem::getDeviceId() {
   return this->deviceId.c_str();
}

const char * CUseItem::getUsage() {
   return this->usage.c_str();
}
const char * CUseItem::getComment() {
   return this->comment.c_str();
}

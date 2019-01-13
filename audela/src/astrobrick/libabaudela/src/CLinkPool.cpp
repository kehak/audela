/* CCameraPool.cpp
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL
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

#include <abcommon.h>
#include "CLink.h"


// Pool  
abcommon::CPool  linkPool;

// factory & pool management
abaudela::ILink*  abaudela::ILink::createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]) throw(abcommon::IError) {
   CLink* link = new CLink();
   link->init(libraryPath, libraryFileName, argc , argv ); 
   linkPool.add(link);
   return link;
}

void abaudela::ILink::deleteInstance(abaudela::ILink* link) {
   linkPool.remove(link);
   delete link;
}

abaudela::ILink* abaudela::ILink::getInstance(int linkNo) {
   return (abaudela::ILink*) linkPool.getInstance(linkNo);
}

int abaudela::ILink::getInstanceNo(abaudela::ILink* link) {
   return linkPool.getInstanceNo(link);
}

abcommon::IIntArray* abaudela::ILink::getIntanceNoList() {
   return linkPool.getIntanceNoList();
}


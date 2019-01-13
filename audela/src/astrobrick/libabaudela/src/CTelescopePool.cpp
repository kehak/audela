/* CTelescopePool.cpp
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
#include "CTelescope.h"


// Pool  
abcommon::CPool  telescopePool;

// factory & pool management
abaudela::ITelescope*  abaudela::ITelescope::createInstance(const char* libraryPath, const char * libraryFileName, int argc, const char *argv[]) throw(abcommon::IError) {
   CTelescope* telescope = new CTelescope();
   telescope->init(libraryPath, libraryFileName, argc , argv ); 
   telescopePool.add(telescope);
   return telescope;
}

void abaudela::ITelescope::deleteInstance(abaudela::ITelescope* telescope) {
   telescopePool.remove(telescope);
   ((CTelescope*)telescope)->close();
   delete telescope;
}

abaudela::ITelescope* abaudela::ITelescope::getInstance(int telescopeNo) {
   return (abaudela::ITelescope*) telescopePool.getInstance(telescopeNo);
}

int abaudela::ITelescope::getInstanceNo(abaudela::ITelescope* telescope) {
   return telescopePool.getInstanceNo(telescope);
}

abcommon::IIntArray* abaudela::ITelescope::getIntanceNoList() {
   return telescopePool.getIntanceNoList();
}


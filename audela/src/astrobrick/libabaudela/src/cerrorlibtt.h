/* cerror.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Denis MARCHAIS <denis.marchais@free.fr>
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

#ifndef __CERRORH__
#define __CERRORH__

#include <stdio.h>
#include <abaudela.h> // pour la liste des codes d'erreur
using namespace ::abaudela;
#include "abcommon.h" 

/*
 * Codes d'erreur de libstd : ils sont negatifs alors que
 * ceux de libtt sont positifs.
 */
extern char* message(int error);


//=====================================================================
//
//  class CError
//
//=====================================================================

class CErrorAudela : public abcommon::CError {
public:
	CErrorAudela(const int errnum)  throw();
   static const char * message(int error); // static pour pouvoir l'utiliser sans créer d'intance  de CError
                                             // cpour compatibilité avec l'ancien système d'erreur
                                             // qui n'utilisait pas les exceptions
};

//=====================================================================
//
//  class CErrorLibtt
//
//=====================================================================

class CErrorLibtt : public abcommon::CError{
private:
	const CErrorLibtt& operator=(const CErrorLibtt&);		// protect against accidents

public:
	CErrorLibtt(const int errnum)  throw();
};


#endif

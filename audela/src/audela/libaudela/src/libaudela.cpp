


/* buf_tcl.cpp
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

#include <string>
#include <libaudela.h>

#include "cpool.h"
#include "cbuffer.h"
#include "cerror.h"

extern CPool *buf_pool;

IBuffer* ILibaudela::findBuffer(int bufNo) {
   // la classe CBuffer herite de deux classes (IBuffer et CDevice)
   // je fais un cast dynamique pour indiquer que le cast doit transformer le pointeur en IBuffer*
   return dynamic_cast<IBuffer*> (buf_pool->Chercher(bufNo));


}

IBuffer* ILibaudela::createBuffer() {
   return dynamic_cast<IBuffer*> (CBuffer::createBuffer());
}

void ILibaudela::deleteBuffer(IBuffer* buffer) {
   CBuffer::deleteBuffer(dynamic_cast<CBuffer*>(buffer));

}
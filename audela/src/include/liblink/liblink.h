/* liblink.h
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
 * Foundation, Inc., 675 Mass Ave, Linkbridge, MA 02139, USA.
 */

// $Id: liblink.h,v 1.5 2009-05-01 16:10:33 michelpujol Exp $

#ifndef __LIBLINK_H__
#define __LIBLINK_H__

/*****************************************************************/
/*             This part is common for all cam drivers.          */
/*****************************************************************/
/*                                                               */
/* Please, don't change the source of this file!                 */
/*                                                               */
/*****************************************************************/

#include <list>
#include <tcl.h>
#include "liblink/useitem.h"

#define LINK_OK       0
#define LINK_ERROR    -1


class CLink {

 public:
   CLink();
   virtual ~CLink();
   virtual int openLink(int argc, const char **argv)=0;
   virtual int closeLink()=0;
   int init_common(int argc, const char **argv);
   int addUse(const char *deviceId, const char *usage, const char *comment);
   int removeUse(const char *deviceId, const char *usage);
   std::string getUse();

   char *getName();
   void setLastMessage(const char *format, ...);
   char * getLastMessage();
   void setAuthorized(int value);
   void setLinkNo(int value);


 protected:
   int authorized;
   char name[1024];
   char msg[1024];
   int linkno;
   std::list<CUseItem> useItemList;

};

struct cmditem {
    const char *cmd;
    Tcl_CmdProc *func;
};




#endif

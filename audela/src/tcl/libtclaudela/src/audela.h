/* audela.h
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

#ifndef __AUDELA_H__
#define __AUDELA_H__

/*
 * Types for image exchange between AudeLA and User's application.
 */
#define AUDELA_TYPE_BYTE   1
#define AUDELA_TYPE_SHORT  2
#define AUDELA_TYPE_USHORT 3
#define AUDELA_TYPE_LONG   4
#define AUDELA_TYPE_ULONG  5
#define AUDELA_TYPE_FLOAT  6
#define AUDELA_TYPE_DOUBLE 7

#if defined(OS_WIN)
#define CALLMETHOD __stdcall
#else
#define CALLMETHOD
#endif

/*
 * Exported functions.
 */
#if defined(__DLL__)
extern "C" void* CALLMETHOD audela_open();
extern "C" int   CALLMETHOD audela_close(void *handle);
extern "C" int   CALLMETHOD audela_eval(void *handle, char *s, int *reslen);
extern "C" int   CALLMETHOD audela_getresult(void *handle, int maxchar, char *s);
extern "C" int   CALLMETHOD audela_putbuf(void *handle, int bufno, int type, int w, int h, void *buffer);
extern "C" int   CALLMETHOD audela_getbuf(void *handle, int bufno, int type, int w, int h, void *buffer);
#else
typedef void* (*AUDELA_OPEN)();
typedef int   (*AUDELA_CLOSE)(void *handle);
typedef int   (*AUDELA_EVAL)(void *handle, char *s, int *reslen);
typedef int   (*AUDELA_GETRESULT)(void *handle, int maxchar, char *s);
typedef int   (*AUDELA_PUTBUF)(void *handle, int bufno, int type, int w, int h, void *buffer);
typedef int   (*AUDELA_GETBUF)(void *handle, int bufno, int type, int w, int h, void *buffer);
AUDELA_OPEN      CALLMETHOD audela_open;
AUDELA_CLOSE     CALLMETHOD audela_close;
AUDELA_EVAL      CALLMETHOD audela_eval;
AUDELA_GETRESULT CALLMETHOD audela_getresult;
AUDELA_PUTBUF    CALLMETHOD audela_putbuf;
AUDELA_GETBUF    CALLMETHOD audela_getbuf;
#endif

#endif /* __AUDELA_H__ */




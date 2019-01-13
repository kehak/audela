/* system.h
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

#if defined (OS_LIN)

/* the following line is proposed by Laurent Marsac (jko@rox0r.net) */
#undef CONFIG_X86_CMPXCHG


#if 0  // Following code is disabled

/* the following lines include the system.h */
#define __KERNEL__
#include <asm/types.h>
#undef __KERNEL__
#include <asm/system.h>
/* for Red-Hat
#include "/usr/i386-glibc21-linux/include/asm/system.h"
*/

#include <linux/version.h>

#if ((LINUX_VERSION_CODE & 0xFFFF00) == 0x020000)
#define AUDELA_CLI cli
#define AUDELA_STI sti
#elif ((LINUX_VERSION_CODE & 0xFFFF00) == 0x020200)
#define AUDELA_CLI cli
#define AUDELA_STI sti
#elif ((LINUX_VERSION_CODE & 0xFFFF00) == 0x020400)
#define AUDELA_CLI local_irq_disable
#define AUDELA_STI local_irq_enable
#elif ((LINUX_VERSION_CODE & 0xFFFF00) == 0x020600)
#define AUDELA_CLI local_irq_disable
#define AUDELA_STI local_irq_enable
#else
#define AUDELA_CLI cli_fonction_qui_n_existe_pas
#define AUDELA_STI sti_fonction_qui_n_existe_pas
#endif

#endif /* 0 */

/* Override of the local irq functions */
#if defined(PROCESSOR_INSTRUCTIONS_INTEL)
	#define AUDELA_CLI() __asm__ __volatile__ ("cli": : :"memory")
	#define AUDELA_STI() __asm__ __volatile__ ("sti": : :"memory")
#else
	#define AUDELA_CLI() 
	#define AUDELA_STI() 
#endif

#endif /* OS_LIN */

#endif /* __SYSTEM_H__ */

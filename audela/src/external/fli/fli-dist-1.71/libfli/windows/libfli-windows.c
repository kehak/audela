/*

  Copyright (c) 2002 Finger Lakes Instrumentation (FLI), L.L.C.
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

        Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

        Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials
        provided with the distribution.

        Neither the name of Finger Lakes Instrumentation (FLI), LLC
        nor the names of its contributors may be used to endorse or
        promote products derived from this software without specific
        prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
  REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.

  ======================================================================

  Finger Lakes Instrumentation, L.L.C. (FLI)
  web: http://www.fli-cam.com
  email: support@fli-cam.com

*/

#include <windows.h>
#include <winioctl.h>
#include <stdio.h>
#include <errno.h>

#include "../libfli-libfli.h"
#include "../libfli-debug.h"
#include "../libfli-mem.h"
#include "../libfli-camera.h"
#include "../libfli-filter-focuser.h"
#include "libfli-sys.h"
#include "libfli-parport.h"
#include "libfli-usb.h"
#include "libfli-serial.h"
#include "ezusbsys.h"

#define MAX_SEARCH 32
#define MAX_SEARCH_DIGITS 3

#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

static WSADATA WSAData;
static short WSEnabled;
static SOCKET sock = INVALID_SOCKET;
static OSVERSIONINFO OSVersionInfo;
static long OS = 0;

extern LARGE_INTEGER dlltime;

BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved )
{
	switch(ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
			QueryPerformanceCounter(&dlltime);
			WSEnabled = 0;
			if (WSAStartup(MAKEWORD(1, 1), &WSAData) == 0)
			{
				WSEnabled = 1;
			}

			if(GetFileAttributes("C:\\FLIDBG.TXT") != (-1))
			{
				FLISetDebugLevel("C:\\FLIDBG.TXT", FLIDEBUG_ALL);
			}

			OSVersionInfo.dwOSVersionInfoSize=sizeof(OSVERSIONINFO);
			if(GetVersionEx(&OSVersionInfo)==0)
				return FALSE;

			switch (OSVersionInfo.dwPlatformId)
			{
				case VER_PLATFORM_WIN32_WINDOWS:
					OS = VER_PLATFORM_WIN32_WINDOWS;
					break;

				case VER_PLATFORM_WIN32_NT:
					OS = VER_PLATFORM_WIN32_NT;
					break;

			 default:
				return FALSE;
			}
			return TRUE;
			break;

		case DLL_THREAD_ATTACH:
			return TRUE;
			break;

		case DLL_THREAD_DETACH:
			return TRUE;
			break;

		case DLL_PROCESS_DETACH:
			xfree_all();
			if(WSEnabled == 1)
				WSACleanup();
			return TRUE;
			break;
	}

  return TRUE;
}

long fli_connect(flidev_t dev, char *name, long domain)
{
  fli_io_t *io;
	char *tname, *mname;
	HANDLE mutex;
	fli_sysinfo_t *sys;
	Usb_Device_Descriptor usbdesc;
	DWORD read;
	int i;
	COMMCONFIG IO_Config;
	DWORD ConfigSize=sizeof(COMMCONFIG);

  CHKDEVICE(dev);

  if(name == NULL)
    return -EINVAL;

  /* Lock functions should be set before any other functions used */
  DEVICE->fli_lock = fli_lock;
  DEVICE->fli_unlock = fli_unlock;

  DEVICE->domain = domain & 0x00ff;
  DEVICE->devinfo.type = domain & 0xff00;

  debug(FLIDEBUG_INFO, "Domain: 0x%04x", DEVICE->domain);
  debug(FLIDEBUG_INFO, "  Type: 0x%04x", DEVICE->devinfo.type);

	if ((io = xcalloc(1, sizeof(fli_io_t))) == NULL)
	{
		fli_disconnect(dev);
		return -ENOMEM;
	}
	io->fd = INVALID_HANDLE_VALUE;
	DEVICE->io_data = io;

	if ((sys = xcalloc(1, sizeof(fli_sysinfo_t))) == NULL)
	{
		fli_disconnect(dev);
		return -ENOMEM;
	}
	DEVICE->sys_data = sys;
	sys->OS = OS;

	if (xasprintf(&tname, "\\\\.\\%s", name) == (-1))
	{
		tname = NULL;
		fli_disconnect(dev);
		return -ENOMEM;
	}
	DEVICE->name = tname;

  switch (DEVICE->domain)
  {
	  case FLIDOMAIN_PARALLEL_PORT:
    {
			if (OS == VER_PLATFORM_WIN32_NT)
			{
				io->fd = CreateFile(tname, GENERIC_READ | GENERIC_WRITE,
					0, NULL, OPEN_EXISTING, 0, NULL);
				if (io->fd == INVALID_HANDLE_VALUE)
				{
					fli_disconnect(dev);
					return -ENODEV;
				}
			}
			else
			{
				io->port = strtol(name, NULL, 0);
				if(stricmp(name, "ccdpar0") == 0)
				{
					io->port = 0x378;
				}

				if(stricmp(name, "ccdpar1") == 0)
				{
					io->port = 0x278;
				}
			}

			if(ECPInit(dev) != 0)
			{
				fli_disconnect(dev);
				return -ENODEV;
			}
			DEVICE->fli_io = parportio;
		}
    break;

	  case FLIDOMAIN_SERIAL:
	  case FLIDOMAIN_SERIAL_1200:
	  case FLIDOMAIN_SERIAL_19200:
    {
			debug(FLIDEBUG_INFO, "Serial, opening port.");

			io->fd = CreateFile(tname, GENERIC_READ | GENERIC_WRITE,
				0, NULL, OPEN_EXISTING, 0, NULL);
			if (io->fd == INVALID_HANDLE_VALUE)
			{
				fli_disconnect(dev);
				return -ENODEV;
			}
			DEVICE->fli_io = serportio;

			debug(FLIDEBUG_INFO, "Attempting at 19200 baud...");
		  GetCommConfig(io->fd, &IO_Config, &ConfigSize);
		  IO_Config.dcb.BaudRate = 19200;
		  IO_Config.dcb.Parity = NOPARITY;
		  IO_Config.dcb.ByteSize = 8;
		  IO_Config.dcb.StopBits = ONESTOPBIT;
			IO_Config.dcb.fRtsControl = RTS_CONTROL_DISABLE;
			IO_Config.dcb.fOutxCtsFlow = FALSE;
			if(SetCommConfig(io->fd, &IO_Config, ConfigSize)==FALSE)
			{
				fli_disconnect(dev);
				return -ENODEV;
			}

			/* We need to probe the serial port... */
			if (fli_filter_focuser_probe(dev) == 0)
			{
				debug(FLIDEBUG_INFO, "Found device at 19200 baud...");
				break;
			}

			Sleep(50);	/* Wait for probe to timeout */

			debug(FLIDEBUG_INFO, "Attempting at 1200 baud...");
		  GetCommConfig(io->fd, &IO_Config, &ConfigSize);
		  IO_Config.dcb.BaudRate = 1200;
		  IO_Config.dcb.Parity = NOPARITY;
		  IO_Config.dcb.ByteSize = 8;
		  IO_Config.dcb.StopBits = ONESTOPBIT;
			IO_Config.dcb.fRtsControl = RTS_CONTROL_DISABLE;
			IO_Config.dcb.fOutxCtsFlow = FALSE;
			if(SetCommConfig(io->fd, &IO_Config, ConfigSize)==FALSE)
			{
				fli_disconnect(dev);
				return -ENODEV;
			}

			/* We need to probe the serial port... */
			if (fli_filter_focuser_probe(dev) == 0)
			{
				debug(FLIDEBUG_INFO, "Found device at 1200 baud...");
				break;
			}

			debug(FLIDEBUG_INFO, "Did not find a serial device.");
			fli_disconnect(dev);
			return -ENODEV;
		}
    break;

	  case FLIDOMAIN_USB:
    {
			unsigned char buf[1024];
			DWORD bytes;
			PUSBD_INTERFACE_INFORMATION pInterface;
			PUSBD_PIPE_INFORMATION pPipe;
			int i;

			io->fd = CreateFile(tname, GENERIC_WRITE, FILE_SHARE_WRITE,
													NULL, OPEN_EXISTING, 0, NULL);
			if (io->fd == INVALID_HANDLE_VALUE)
			{
				fli_disconnect(dev);
				return -ENODEV;
			}

			debug(FLIDEBUG_INFO, "Getting Device configuration.");
			if (DeviceIoControl(io->fd, IOCTL_Ezusb_GET_DEVICE_DESCRIPTOR,
													  NULL, 0, &usbdesc, sizeof(usbdesc),
													  &read, NULL) == FALSE)
			{
				debug(FLIDEBUG_WARN, "Couldn't read device description, error: %d", GetLastError());
				fli_disconnect(dev);
				return -ENODEV;
			}

			DEVICE->devinfo.devid = usbdesc.idProduct;
			DEVICE->devinfo.fwrev = usbdesc.bcdDevice;

			/* Get pipe information */
			if (DeviceIoControl(io->fd, IOCTL_Ezusb_GET_PIPE_INFO,
													NULL, 0, buf, 1024, &bytes,	NULL) == FALSE)
			{
				debug(FLIDEBUG_FAIL, "Error getting USB pipe information, error: %d", GetLastError());
				fli_disconnect(dev);
				return -ENODEV;
			}

			pInterface = (PUSBD_INTERFACE_INFORMATION) buf;
			pPipe = pInterface->Pipes;

			for(i = 0; (i < (int) pInterface->NumberOfPipes) && (i < USB_MAX_PIPES); i++)
			{
				debug(FLIDEBUG_INFO, "Pipe: %d Type: %02x Endpoint: %02x MaxSize: %02x MaxXfer: %04x",
					i,
					pPipe[i].PipeType,
					pPipe[i].EndpointAddress,
					pPipe[i].MaximumPacketSize,
					pPipe[i].MaximumTransferSize
					);
				io->endpointlist[i] = pPipe[i].EndpointAddress;
			}

			debug(FLIDEBUG_INFO, "    id: 0x%04x", DEVICE->devinfo.devid);
			debug(FLIDEBUG_INFO, " fwrev: 0x%04x", DEVICE->devinfo.fwrev);
			DEVICE->fli_io = usbio;
    }
		break;

	  default:
			fli_disconnect(dev);
			return -EINVAL;
  }

  switch (DEVICE->devinfo.type)
  {
	  case FLIDEVICE_CAMERA:
	   DEVICE->fli_open = fli_camera_open;
	   DEVICE->fli_close = fli_camera_close;
	   DEVICE->fli_command = fli_camera_command;
		 break;

	  case FLIDEVICE_FOCUSER:
	   DEVICE->fli_open = fli_focuser_open;
	   DEVICE->fli_close = fli_focuser_close;
	   DEVICE->fli_command = fli_focuser_command;
	   break;

		case FLIDEVICE_FILTERWHEEL:
	   DEVICE->fli_open = fli_filter_open;
	   DEVICE->fli_close = fli_filter_close;
	   DEVICE->fli_command = fli_filter_command;
		 break;

	  default:
			fli_disconnect(dev);
			return -EINVAL;
  }

	/* Now create the synchronization object */
	mname = (char *) xcalloc(strlen(name) + 1 + 4, sizeof(char));
	if(mname != NULL) /* We can allocate the mutex */
	{
		strcpy(mname, "FLI_");
		strcat(mname, name);
		for(i = 0; mname[i] != '\0'; i++) /* Convert case */
		{
			mname[i] = toupper(mname[i]);
		}

		mutex = OpenMutex(MUTEX_ALL_ACCESS | SYNCHRONIZE, TRUE, mname);
		if(mutex == NULL)
		{
			mutex = CreateMutex(NULL, FALSE, mname);
		}

		if(mutex == NULL)
		{
			debug(FLIDEBUG_WARN, "Failed to create mutex object, error: %d", GetLastError());
		}

		((fli_sysinfo_t *) (DEVICE->sys_data))->mutex = mutex;
		xfree(mname);
	}
	else
	{
		debug(FLIDEBUG_WARN, "Failed to allocate name for mutex.");
	}

  DEVICE->io_timeout = 20 * 1000; /* 20 seconds. */

  return 0;
}

long fli_disconnect(flidev_t dev)
{
  int err = 0;
	fli_io_t *io;

  CHKDEVICE(dev);

	io = DEVICE->io_data;

  switch (DEVICE->domain)
  {
		case FLIDOMAIN_PARALLEL_PORT:
			ECPClose(dev);
			break;

		case FLIDOMAIN_USB:
			break;

		default:
			err = -EINVAL;
  }

	if(io != NULL)
	{
		if(io->fd != INVALID_HANDLE_VALUE)
		{
			if (CloseHandle(io->fd) == FALSE)
				err = -EIO;
			else
				err = 0;
		}
	}

	if(((fli_sysinfo_t *) (DEVICE->sys_data))->mutex != NULL)
	{
		CloseHandle(((fli_sysinfo_t *) (DEVICE->sys_data))->mutex);
	}

  if (DEVICE->io_data != NULL)
  {
    xfree(DEVICE->io_data);
    DEVICE->io_data = NULL;
  }

  if (DEVICE->sys_data != NULL)
  {
    xfree(DEVICE->sys_data);
    DEVICE->sys_data = NULL;
  }

	if(DEVICE->name != NULL)
	{
		xfree(DEVICE->name);
		DEVICE->name = NULL;
	}

  DEVICE->fli_lock = NULL;
  DEVICE->fli_unlock = NULL;
  DEVICE->fli_io = NULL;
  DEVICE->fli_open = NULL;
  DEVICE->fli_close = NULL;
  DEVICE->fli_command = NULL;

  return err;
}

long fli_lock(flidev_t dev)
{
	HANDLE mutex = ((fli_sysinfo_t *) (DEVICE->sys_data))->mutex;

	if (mutex != NULL)
	{
		switch(WaitForSingleObject(mutex, INFINITE))
		{
			case WAIT_OBJECT_0:
				return 0;
				break;

			default:
				debug(FLIDEBUG_WARN, "Could not acquire mutex: %d", GetLastError());
				return -ENODEV;
				break;
		}
	}
	return -ENODEV;
}

long fli_unlock(flidev_t dev)
{
	HANDLE mutex = ((fli_sysinfo_t *) (DEVICE->sys_data))->mutex;

	if (mutex != NULL)
	{
		if(ReleaseMutex(mutex) == FALSE)
		{
			debug(FLIDEBUG_WARN, "Could not release mutex: %d", GetLastError());
			return -ENODEV;
		}
		return 0;
	}
	return -ENODEV;
}

static long fli_list_usb(flidomain_t domain, char ***names);
static long fli_list_parport(flidomain_t domain, char ***names);
static long fli_list_serial(flidomain_t domain, char ***names);

long fli_list(flidomain_t domain, char ***names)
{
	*names = NULL;

  switch (domain & 0x00ff)
  {
	  case FLIDOMAIN_PARALLEL_PORT:
	    return fli_list_parport(domain, names);
	    break;

	  case FLIDOMAIN_SERIAL:
	  case FLIDOMAIN_SERIAL_1200:
		case FLIDOMAIN_SERIAL_19200:
	    return fli_list_serial(domain, names);
	    break;
		
	  case FLIDOMAIN_USB:
	    return fli_list_usb(domain, names);
	    break;

	  default:
	    return -EINVAL;
  }

  /* Not reached */
  return -EINVAL;
}

#define NAME_LEN_MAX 4096

static long fli_list_tree(const char *root, flidomain_t domain, char ***names)
{
  int matched = 0, device = 0, max_search = MAX_SEARCH;
  char fname[NAME_LEN_MAX], **list, name[NAME_LEN_MAX];
	flidev_t dev;
	char prefix[NAME_LEN_MAX];
	int cnt, index;

	/* Allocate the list */
  if ((list = xcalloc((MAX_SEARCH + 1) * sizeof(char *), 1)) == NULL)
    return -ENOMEM;

	index = 0;
	while (root[index] != '\0')
	{
		cnt = 0;
		while ((root[index] != '\0') &&
					 (root[index] != ',') &&
					 (cnt < NAME_LEN_MAX))
		{
			prefix[cnt] = root[index];
			cnt++;
			index++;
		}
		prefix[cnt] = '\0';
		if (root[index] != '\0')
			index++;

		device = 0;
		while(device < max_search)
		{
			if (snprintf(fname, NAME_LEN_MAX, "%s%d", prefix,
				device) >= NAME_LEN_MAX)
			{
				xfree(list);
				return -EOVERFLOW;
			}

			if (FLIOpen(&dev, fname, domain) == 0)
			{
				if (snprintf(name, NAME_LEN_MAX, "%s;%s", fname,
				DEVICE->devinfo.model) >= NAME_LEN_MAX)
				{
					xfree(list);
					return -EOVERFLOW;
				}

				list[matched++] = xstrdup(name);

				FLIClose(dev);
			}
			device++;
		}
	}

	if(matched == 0)
	{
		*names = NULL;
		xfree(list);
		return 0;
	}

  /* Terminate the list */
  list[matched++] = NULL;

//  list = xrealloc(list, matched * sizeof(char *));
  *names = list;
  return 0;
}

static long fli_list_usb(flidomain_t domain, char ***names)
{
	switch (domain & 0xff00)
	{
		case FLIDEVICE_CAMERA:
		  return fli_list_tree("flipro,flicam", domain, names);

		case FLIDEVICE_FOCUSER:
		  return fli_list_tree("flifoc", domain, names);

		case FLIDEVICE_FILTERWHEEL:
		  return fli_list_tree("flifil", domain, names);

		default:
			return -EINVAL;
	}

  /* Not reached */
	return -EINVAL;
}

static long fli_list_serial(flidomain_t domain, char ***names)
{
	switch (domain & 0xff00)
	{
		case FLIDEVICE_FOCUSER:
		  return fli_list_tree("COM", domain, names);

		case FLIDEVICE_FILTERWHEEL:
		  return fli_list_tree("COM", domain, names);

		default:
			return -EINVAL;
	}

  /* Not reached */
	return -EINVAL;
}

static long fli_list_parport(flidomain_t domain, char ***names)
{
	switch (domain & 0xff00)
	{
		case FLIDEVICE_CAMERA:
		  return fli_list_tree("ccdpar", domain, names);

		default:
			return -EINVAL;
	}

  /* Not reached */
	return -EINVAL;
}

#undef NAME_LEN_MAX


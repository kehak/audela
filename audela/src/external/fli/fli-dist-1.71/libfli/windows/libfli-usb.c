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

#include <errno.h>

#include "..\libfli-libfli.h"
#include "..\libfli-debug.h"
#include "libfli-sys.h"
#include <winioctl.h>
#include "libfli-usb.h"
#include "ezusbsys.h"
#include "stdio.h"

#define _DEBUG_IO

static LARGE_INTEGER time = { -1 };

long usb_bulktransfer(flidev_t dev, int ep, void *buf, long *len)
{
	BULK_TRANSFER_CONTROL pipe = { (-1) };
	unsigned long ioctl_code;
	int i, abort = 0;
	DWORD retval = 0;
	long tlen = 0, total = 0;

#ifdef _DEBUG_IO
	LARGE_INTEGER btime, etime, freq;
	double dtime;
#endif

	for (i = 0; (pipe.pipeNum == (-1)) && (i < USB_MAX_PIPES); i++)
	{
		if (((fli_io_t *)DEVICE->io_data)->endpointlist[i] == ep)
			pipe.pipeNum = i;
	}

	if (pipe.pipeNum == (-1))
	{
		debug(FLIDEBUG_FAIL, "Requested endpoint 0x%02x not found.", ep);
		return -EIO;
	}

#ifdef _DEBUG_IO
	debug(FLIDEBUG_INFO, "Got PIPE %d for endpoint 0x%02x.", pipe.pipeNum, ep);
#endif

	if ((ep & 0x80) == 0)
		ioctl_code = IOCTL_EZUSB_BULK_WRITE;
	else
		ioctl_code = IOCTL_EZUSB_BULK_READ;

#ifdef _DEBUG_IO

	if ((ep & 0x80) == 0)
	{
		char dbuf[100], cbuf[10];
		int i;

		snprintf(dbuf, 100, "IOW ep:%02x len:%04x : ", ep, *len);
		for(i = 0; i < (int) (*len < 24?*len:24); i++)
		{
			snprintf(cbuf, 10, "%02x ", ((unsigned char *) buf)[i]);
			strcat(dbuf, cbuf);
		}
		debug(FLIDEBUG_INFO, dbuf);
	}

	QueryPerformanceCounter(&btime);
#endif /* _DEBUG_IO */

#define MOD_USB
#ifdef MOD_USB
	while ( (total < *len) && (abort == 0) )
	{
		tlen = 0;

		retval = DeviceIoControl(((fli_io_t *)DEVICE->io_data)->fd,
														 ioctl_code,
														 &pipe,
														 sizeof(pipe),
														 (unsigned char *) buf + total,
														 *len - total,
														 &tlen,
														 NULL);

		total += tlen; /* Update our length transferred */

		debug(FLIDEBUG_WARN, "    Retval: %d", retval);

		/* Check for error status */
		if (retval == 0)
		{
			debug(FLIDEBUG_FAIL, "    Transfer failed, error: %d", GetLastError());

			abort = 1;
			continue;
		}

		if (total < *len) /* We didn't transfer everything */
		{
			DWORD urb_status = 0x00;
			DWORD iolen;

			DeviceIoControl(((fli_io_t *)DEVICE->io_data)->fd,
											IOCTL_EZUSB_GET_LAST_ERROR,
											NULL,
											0,
											&urb_status,
											sizeof(urb_status),
											&iolen,
											NULL);

			debug(FLIDEBUG_WARN, "    URB status: 0x%08x", urb_status);
			switch (urb_status)
			{
				case 0xC0000011:
					debug(FLIDEBUG_WARN, "    USBD_STATUS_XACT_ERROR, retrying...");
					break;

				case 0xC0000012:
					debug(FLIDEBUG_WARN, "    USBD_STATUS_BABBLE_DETECTED, retrying...");
					break;

				default:
					debug(FLIDEBUG_WARN, "    aborting transfer...");
					abort = 1;
					break;
			}
		}

		if (total != *len)
		{
			debug(FLIDEBUG_WARN, "    I/O operation lengths differ, %04x (desired) != %04x (actual)", *len, tlen);
		}

	}

	tlen = total;

#else
	if(*len > 0)
	{
		retval = DeviceIoControl(((fli_io_t *)DEVICE->io_data)->fd,
														 ioctl_code,
														 &pipe,
														 sizeof(pipe),
														 buf,
														 *len,
														 &tlen,
														 NULL);
	}

	if (tlen != *len)
	{
		debug(FLIDEBUG_WARN, "    I/O operation lengths differ, %04x (desired) != %04x (actual)", *len, tlen);
	}

	if (retval == 0)
	{
		unsigned long urb_status = 0x00;
		DWORD iolen, last;

		last = GetLastError();

		retval = DeviceIoControl(((fli_io_t *)DEVICE->io_data)->fd,
														 IOCTL_EZUSB_GET_LAST_ERROR,
														 NULL,
														 0,
														 &urb_status,
														 sizeof(urb_status),
														 &iolen,
														 NULL);

		debug(FLIDEBUG_WARN, "Last Error: %d URB Status: %d", last, urb_status);
	}
#endif

#ifdef _DEBUG_IO
	QueryPerformanceCounter(&etime);
	QueryPerformanceFrequency(&freq);

	if ((ep & 0x80) != 0)
	{
		char dbuf[100], cbuf[10];
		int i;

		snprintf(dbuf, 100, "IOR ep:%02x len:%04x : ", ep, *len);
		for(i = 0; i < (int) (*len < 16?*len:16); i++)
		{
			snprintf(cbuf, 10, "%02x ", ((unsigned char *) buf)[i]);
			strcat(dbuf, cbuf);
		}
		debug(FLIDEBUG_INFO, dbuf);
	}

	dtime = ((double) etime.QuadPart - (double) btime.QuadPart ) / (double) freq.QuadPart;
	debug(FLIDEBUG_INFO, "    ret:%02x len:%04x dtime:%09.6f",
		retval, tlen, dtime);
#endif /* _DEBUG_IO */

	*len = tlen;
	return (retval == 0)?-EIO:0;
}

long usbio(flidev_t dev, void *buf, long *wlen, long *rlen)
{
  int err = 0, locked = 0, epread = 0, epwrite = 0;
  long org_wlen = *wlen, org_rlen = *rlen;

  if ((err = fli_lock(dev)))
  {
    debug(FLIDEBUG_WARN, "Lock failed");
    goto done;
  }

  locked = 1;

	/* Determine which endpoint we should be using */
	switch (DEVICE->devinfo.devid)
	{
		case FLIUSB_FILTER_ID:
		case FLIUSB_FOCUSER_ID:
		case FLIUSB_CAM_ID:
			epwrite = 0x02;
			epread = 0x82;
		break;

		case FLIUSB_PROLINE_ID:
			epwrite = 0x01;
			epread = 0x81;
		break;

		default:
			debug(FLIDEBUG_FAIL, "Unknown device type.");
			return -EINVAL;
	}

	if (*wlen > 0)
	{
    if (err = usb_bulktransfer(dev, epwrite, buf, wlen))
		{
			debug(FLIDEBUG_WARN, "Bulkwrite failed, only %d of %d bytes written",
			*wlen, org_wlen);
			goto done;
		}
	}

  if (*rlen > 0)
  {
    if (err = usb_bulktransfer(dev, epread, buf, rlen))
    {
      debug(FLIDEBUG_WARN, "Bulkread failed, only %d of %d bytes read",
	    *rlen, org_rlen);
      goto done;
    }
  }

 done:

  if (locked)
  {
    int r;

    if ((r = fli_unlock(dev)))
      debug(FLIDEBUG_WARN, "Unlock failed");
    if (err == 0)
      err = r;
  }

  return err;
}

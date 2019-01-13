#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <errno.h>

#include "../libfli-libfli.h"
#include "../libfli-debug.h"
#include "../libfli-mem.h"

#define MAX_DEBUG_STRING (1024)

LARGE_INTEGER dlltime;
static int _level = 0;
static int _forced = 0;
static char *_debugfile = NULL;

#define _DEBUGSTRING

int debugclose(void)
{
	if(_debugfile != NULL)
	{
		debug(FLIDEBUG_ALL, "Closing debug file.");
		xfree(_debugfile);
		_debugfile = NULL;
	}

	return 0;
}

int debugopen(char *host)
{
	char date[12], time[12];

	_strdate(date);
	_strtime(time);
	QueryPerformanceCounter(&dlltime);

	debugclose();

	if(host != NULL)
	{
		_debugfile = xstrdup(host);
	}

	debug(FLIDEBUG_ALL, "*** %s %s ***", date, time);
	debug(FLIDEBUG_ALL, "%s - Compiled %s %s", version, __DATE__, __TIME__);
	return 0;
}

void debug(int level, char *format, ...)
{
	char stime[16];
	char buffer[MAX_DEBUG_STRING];
	char output[MAX_DEBUG_STRING];
	int ret;
	LARGE_INTEGER time, freq;
	double dtime;
	HANDLE dfile;
	
#ifndef _DEBUGSTRING
	if( (_debugfile != NULL ) && (level & _level) )
#endif
	{
		va_list ap;
		va_start(ap, format);
		ret = _vsnprintf(buffer, MAX_DEBUG_STRING - 1, format, ap);
		va_end(ap);

		QueryPerformanceCounter(&time);
		QueryPerformanceFrequency(&freq);

		dtime = ((double) time.QuadPart - (double) dlltime.QuadPart ) / (double) freq.QuadPart;

		_snprintf(stime, 15, "%8.3f", dtime);

		switch (level)
		{
			case FLIDEBUG_INFO:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, "INFO<%s>: %s\n", stime, buffer);
				break;

			case FLIDEBUG_WARN:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, "WARN<%s>: %s\n", stime, buffer);
				break;

			case FLIDEBUG_FAIL:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, "FAIL<%s>: %s\n", stime, buffer);
				break;

			default:
				ret = _snprintf(output, MAX_DEBUG_STRING - 1, " ALL<%s>: %s\n", stime, buffer);
				break;
		}

#ifdef _DEBUGSTRING
		OutputDebugString(output);
		//Sleep(1);
#endif

		if(ret >= 0)
		{
			dfile = CreateFile(_debugfile, GENERIC_WRITE, FILE_SHARE_READ, NULL,
				OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
			if(dfile != INVALID_HANDLE_VALUE)
			{
				DWORD bytes;
				SetFilePointer(dfile, 0, NULL, FILE_END);
				WriteFile(dfile, output, strlen(output), &bytes, NULL);
				CloseHandle(dfile);
			}
		}
	}

	return;
}

void setdebuglevel(char *host, int level)
{
	if (_forced == 1)
		return;

	if (stricmp(host, "C:\\FLIDBG.TXT") == 0)
		_forced = 1;

	debug(FLIDEBUG_INFO, "Changing debug level to %d.", level);

	_level = level;

	if (level == 0)
	{
		debug(FLIDEBUG_INFO, "Disabling debugging.");
		debugclose();
	}
	else
	{
		debugopen(host);
	}

	return;
}

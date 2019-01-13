/*! \file proto_filex.c
 *  \brief Modified file: protocol for libavformat
 *
 * filex: is the same as file: except that posix_fadvise() is called regularly
 *
 *
 * Buffered file io for ffmpeg system
 * Copyright (c) 2001 Fabrice Bellard
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#define _FILE_OFFSET_BITS 64
#define _LARGEFILE64_SOURCE

#include <libavutil/avstring.h>
#include <libavformat/avformat.h>
#include <fcntl.h>
#if HAVE_SETMODE
#include <io.h>
#endif
#include <unistd.h>
#include <sys/time.h>
#include <stdlib.h>
//#include <libavformat/os_support.h>


/* standard file protocol */

static int file_open(URLContext *h, const char *filename, int flags)
{
    int access;
    int fd;

    av_strstart(filename, "filex:", &filename);

    if (flags & URL_RDWR) {
        access = O_CREAT | O_TRUNC | O_RDWR;
    } else if (flags & URL_WRONLY) {
        access = O_CREAT | O_TRUNC | O_WRONLY;
    } else {
        access = O_RDONLY;
    }
#ifdef O_BINARY
    access |= O_BINARY;
#endif
    fd = open(filename, access, 0666);
    if (fd == -1)
        return AVERROR(ENOENT);
    h->priv_data = (void *) (intptr_t) fd;
    return 0;
}

static int file_read(URLContext *h, unsigned char *buf, int size)
{
    int fd = (intptr_t) h->priv_data;
    return read(fd, buf, size);
}

static int file_write(URLContext *h, const unsigned char *buf, int size)
{
    static long long int count = 0;
    int fd = (intptr_t) h->priv_data;
    if((count++ % 25) == 0) {
        if(posix_fadvise(fd,0,0,POSIX_FADV_DONTNEED) != 0) {
            abort();
        }
    }

    return write(fd, buf, size);
}

/* XXX: use llseek */
static int64_t file_seek(URLContext *h, int64_t pos, int whence)
{
    int fd = (intptr_t) h->priv_data;
    if (whence != SEEK_SET && whence != SEEK_CUR && whence != SEEK_END)
	    exit(1);
//        return AVERROR_NOTSUPP;
    return lseek(fd, pos, whence);
}

static int file_close(URLContext *h)
{
    int fd = (intptr_t) h->priv_data;
    return close(fd);
}

static int file_get_handle(URLContext *h)
{
    return (intptr_t) h->priv_data;
}

URLProtocol filex_protocol = {
    "filex",
    file_open,
    file_read,
    file_write,
    file_seek,
    file_close,
    .url_get_file_handle = file_get_handle,
};


/* vim:set et ts=4 sw=4:  */

/*
Copyright or © or Copr. [name of the author when individual or of the
legal entity when the software has been created under wage-earning status
adding underneath, if so required :" contributor(s) : [name of the
individuals] ([date of creation])

[e-mail of the author(s)]
stephane.vaillantAfree.fr

This software is a computer program whose purpose is to [describe
functionalities and technical features of your software].

This software is governed by the [CeCILL|CeCILL-B|CeCILL-C] license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the [CeCILL|CeCILL-B|CeCILL-C]
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the [CeCILL|CeCILL-B|CeCILL-C] license and that you accept its terms.
*/

/*! \file grab.c
 *  \brief Recorder program
 *
 * Frame grabber for video4linux2
 *
 * Author : Stephane Vaillant
 *
 * (C) 2011
 *
 * License : CeCILL or CeCILL-B http://www.cecill.info/
 *
 * \section Synopsis
 *
 * This command line tool records a video stream from a video4linux2 device,
 * such as a USB grabber, into a series of AVI files.
 *
 * Input device image format : 720x576 YUV422 packed at 25fps
 *
 * Output stream AVI 720x576 YUV422 planar at 25fps, frames are compressed
 * with the lossless codec huffyuv.
 *
 * A log file is produced to allow tracking of lost frames.
 *
 * \section motivations_sect Motivations
 *
 * The video4linux2 driver can bufferize up to 32 frames.
 * Depending of the configuration of the computer it may not be
 * sufficient to avoid the loss of frames.
 *
 * The purpose of this tool is to allow the user to record a video
 * reducing the risk of loosing frames. Moreover in the case of lost frames
 * this tool keep a log of when they were lost in order to ease the
 * post processing of the recorded video.
 *
 * \section details_sect Principles of Operation and Features
 *
 * The program uses the following elements.
 *  - A buffer that can hold a predefined number of frames (e.g. 300)
 *  - A reader thread  that fetches frames from the video device and
 *  puts them into the buffer. This thread is given a realtime scheduling priority.
 *  - A writer thread that encodes the frames and writes
 *  them to the AVI files. This thread is given the maximum unix priority.
 *
 *  - fadvise() is called periodicaly to avoid filling the disk cache.
 *  - memory is locked to avoid swapping
 *
 * The application writes a raw image in \c /dev/shm/pict.yuv422
 * When the cooperating application has processed this file it
 * can get a new one by deleting it.
 *
 * When the disk is almost full, the recording stops.
 *
 * The user can give the duration of the recording.
 *
 *
 * Software used :
 *  - video4linux2 from the linux kernel
 *  - libavformat, libavcodec, etc. from the ffmpeg project
 *
 * \todo TODO choose chunk by time or number of frames
 * \todo TODO choose chunk by size
 * \todo TODO E: av_interleaved_write_frame
 * \todo TODO add a communication interface to fetch the last frame
 * \todo TODO handle command line parameters for fps, width, height, etc.
 * \todo TODO detect low disk space
 * \todo TODO try harder to exit cleanly and to finish output file
 * \todo TODO check error with VLC : [0xc7de30] main subpicture error: blending YUVA to I422 failed
 *
 * - man 3p sched_setscheduler
 * - man 3p pthread_setschedparam
 *
 * \section usage_sect Setup and Usage
 *
 * \subsection Compilation
 *
 * The program can be compiled on a 32 or 64 bits powerful computer and then
 * copied to the laptop used for the video recording.
 *
 * The ffmpeg libraries are staticaly linked to the executable so there's no need to copy them along the executable.
 *
 * 1. Get ffmpeg: http://www.ffmpeg.org/download.html
 *
 * 2. Extract ffmpeg 0.8 source in /opt/ffmpeg32
\verbatim
cd /opt/ffmpeg32
CFLAGS='-march=i686 -m32 -msse4' ./configure
make \endverbatim
 *
 * 3. Return to the source dir and type \c make
 *
 *
 * \subsection Setup
 *
 * The user under which the grabber is run must have enough privileges.
 * For example, under OpenSUSE 11.4, do the following.
 *
 *  - edit \c /etc/groups to add the current user to the group 'video'
 *  - edit \c /etc/security/limits.conf and add the lines:
 *    \verbatim
@video            -       rtprio          10
@video            -       nice            -20
@video            -       memlock         unlimited \endverbatim
 *
 * It is necessary to log out and log in again for the changes to take effect.
 *
 * With some recent kernels the process priority system behave
 * differently and the writer thread seems not to have effectively
 * the expected priority.
 * To solve the problem the following command can be used:
 * \verbatim sysctl -w kernel.sched_autogroup_enabled=0 \endverbatim
 *
 * \subsection Example
 *
 * - Connect the grabber to a USB port.
 * - Create a directory that will receive the files, let's say /tmp/session1
 * - Run "grab -o /tmp/session1 -d 3m -c 1m"
 *
 * - The program will store the video in the directory /tmp/session1
 * - The record time will be 3 minutes ( argument: -c 3m )
 * - The recording is split into files of 1 minute ( -c 1m )
 * - The directory will contains 4 files:
 *   - \c session1-20110819T114619.log.txt
 *   - \c session1-20110819T114619-000.avi
 *   - \c session1-20110819T114619-001.avi
 *   - \c session1-20110819T114619-002.avi
 * 
 * Each file has the same prefix:
 *  - \c session1 that repeats the name of the directory
 *  - \c 20110819T114619 the time the program was run
 *
 *
 * \section recom_sect Recommendations
 *
 * NTFS is not recommended to store the files, the way it is implemented
 * defeats all the techniques used to avoid frame loss.
 *
 * It is mandatory to test many times your experimental setup and check that there are no lost frames during the recordings.
 *
 * Parameters to be watched for:
 *  - model of the grabber
 *  - processor speed and number of cores
 *  - internal hard drive (if used): SSD, 5400 rpm or 7200 rpm
 *  - external hard drive: USB Hi-speed ? 5400 or 7200 rpm
 *  - type of the filesystem: fat32 or ext3/4 seems ok but not NTFS
 *  - size of the filesystem
 *  - is the filesystem empty or nearly full?
 *  - has the filesystem been recently formatted?
 *  - if the computer has been heavilly used it may be better to reboot it before recording
 *
 *
 * \section logfile_sect The Log File
 *
 * The log file is self documented.
 *
 * Briefly : checking for dropped frames.
 * For each frame recorded the log file contains a line prefixed with the
 * two characters \c T:
 * - In this line, the fifth field is the number of dropped frames before this
 * frame: check for non-zero value.
 * - When recording at 25 fps, the value of the third field should be close
 * to 40000.
 *
 *
 * \section experiment_sect An Experimental Setup
 *
 * - DELL Inspiron Mini 910
 * - Dazzle DVC 1000
 * - B/W camera connected to the composite input of the Dazzle
 *
 * - Hardrives :
 *   - Internal SSD 16GB
 *   - External USB 2.0 HD 3.5" 500MB 7200 rpm
 *
 * - OpenSUSE 11.4 32bits
 *
 */


#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#define _FILE_OFFSET_BITS 64
#define _LARGEFILE64_SOURCE

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <poll.h>
#include <sys/mman.h>
#include <signal.h>
#include <sys/statvfs.h>
#include <sys/statfs.h>
#include <sys/utsname.h>

#include <pthread.h>
#include <sched.h>
#include <sys/resource.h>
#include <sys/syscall.h>

#include <linux/videodev2.h>

#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libavformat/url.h"
#include "libswscale/swscale.h"

const char * g_version_string = "20161003-1";

//! The threads will finish their job on this value
volatile int request_exit = 0;
//! Exit reason to be recorded in the log file
volatile char * g_exit_reason = "Unknown";

//! Set to 1 when realtime capabilities were requested
int g_realtime = 1;
int g_framerate = 25;
int g_width = 720;
int g_height = 576;
//! Value (4 bytes) of pixelformat used by the grabber
__u32 g_srcpixelformat = 0;
//! Value of pixelformat used by ffmpeg
enum PixelFormat g_pixelformat = 0;
//! Number of buffers for storing the frames
int g_nbufs = 300;
//! Set to 1 if device initialization has been requested
int g_auto = 0;
//! Frequency at which stats are printed
int g_stats_every_frames = 1*25;

//! Logged time stamps are relative to this origin
uint64_t g_timeorigin = 0;
uint64_t g_chunktimelimit = 0;
int g_chunkmaxframes = 0;
//! Free disk space limit below which recording stops
uint64_t g_free_disk_limit = UINT64_C(100)*1000*1000; // bytes

#define xabort() { fprintf(stderr, "\nabort() file %s line %d\n", __FILE__, __LINE__); abort(); }

//! True if file exists
int fexist( char *filename ) {
    struct stat buffer ;
    if ( stat( filename, &buffer ) == 0 ) return 1 ;
    return 0 ;
}

#if 0
int is_valid_fd(int fd)
{
    return fcntl(fd, F_GETFL) != -1 || errno != EBADF;
}
#endif

//! Prints usage and version string
void print_usage()
{
    printf(
            "grab version %s\n\n"
            "grab -o dir [-p prefix] [-d 99m] [-c 5m] [-i /dev/video9] [-w width] [-h height]\n"
            "grab -1 [-i /dev/video9]\n"
            " -o dir : output directory (must exist)\n"
            " -p prefix : prefix of avi files (defaults to last component of output directory)\n"
            " -d 40m : duration of recording in minutes\n"
            " -c 1m|60s|1500f : length of each chunk in minutes, seconds or frames\n"
            " -i /dev/video1 : force usage of this input device\n"
            " -w width : width e.g. 720\n"
            " -h height : height e.g. 576\n"
            " -a auto configure device\n"
            " -s size : stop recording when disk space drops below 'size' Mb\n"
            " -y TCL refresh rate (ms)\n"
            " -0 only print info\n"
            " -1 one shot : grab a picture and store it in /dev/shm/pict.yuv422\n"
            " -y time : send stats every time milliseconds\n"
            "\nSETUP\n"
            "/dev/shm/pict.yuv422 contains the latest image.\n"
            " To update it delete the file.\n"
            "\n"
            "Add the current user to the 'video' group.\n"
            "Add the following lines to /etc/security/limits.conf\n"
            "@video           -       rtprio          10\n"
            "@video           -       nice            -20\n"
            "@video           -       memlock         unlimited\n"
	    "\n"
            "As user root: sysctl -w kernel.sched_autogroup_enabled=0\n"
            "\n"
            "Example.\n"
            " Create a directory that will receive the files, let's say /tmp/session1\n"
            " Run \"grab -o /tmp/session1 -d 3m -c 1m\"\n"
            " The program will store the video in the directory /tmp/session1\n"
            " The record time will be 3 minutes ( argument: -c 3m )\n"
            " The recording is split into files of 1 minute ( -c 1m )\n"
            " The directory will contains 4 files:\n"
            "   session1-20110819T114619.log.txt\n"
            "   session1-20110819T114619-000.avi\n"
            "   session1-20110819T114619-001.avi\n"
            "   session1-20110819T114619-002.avi\n"
            "\n"
            " Each file has the same prefix:\n"
            "  session1 that repeats the name of the directory\n"
            "  20110819T114619 the time the program was run\n"
            "\n",
        g_version_string
            );
}

//! Holds a pointer to a video4linux2 buffer
struct videobuf_s {
    void *map;
    size_t len;
};

//! Statistics for each grabbed frame
struct timelog_s {
    uint64_t t1; //!< system time
    uint64_t t2; //!< timestamp given by the driver
    uint64_t dt; //!< delta t2
    uint64_t bufcount; //!< available buffers
    int dropped; //! frames dropped by the application before this frame
    int seq; //!< sequence number given by the driver
    uint64_t t3;
};

/*! \brief Interface to the video driver
 *
 * - Initialization sequence:
 *  - memset(&vc, 0, sizeof(vc));
 *  - video_open(&vc,NULL)
 *  - video_alloc_buffers(&vc);
 *
 * - Start streaming with ioctl VIDIOC_STREAMON
 * - Fetch buffer with ioctl VIDIOC_DQBUF
 * - Pointer to the raw image: vc.bufs[index].map
 * - Put back buffer with ioctl VIDIOC_QBUF
 * - Stop streaming with ioctl VIDIOC_STREAMOFF
 *
 */
struct video_context_s {
    char path[PATH_MAX]; //!< path to the v4l2 device
    int fd;
    struct v4l2_input input;
    struct v4l2_format fmt;
    struct v4l2_standard std;
    v4l2_std_id stdid;
    struct v4l2_requestbuffers reqbufs;
    struct v4l2_buffer buf;
    enum v4l2_buf_type type;
    struct videobuf_s *bufs; //!< v4l2 mmaped buffers
    ssize_t sizeimage; //!< Size of raw image in bytes
};


//! Returns the current timestamp in microseconds
uint64_t gettimeofday64()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec*UINT64_C(1000000) + tv.tv_usec;
}

//! Holds the timestamp of the beginning of processing
uint64_t g_gettimeofday0;

//! Returns the number of microseconds since the beginning of processing
uint64_t getelapsed()
{
    return gettimeofday64() - g_gettimeofday0;
}

//! File descriptor of the log file
FILE *fp_timelog = NULL;
int timelog_next = 0;
int timelog_num = 0;
struct timelog_s *timelog;
struct timelog_s timelog_cur;

//! print, flush and clear the timelog
void print_timelog(FILE *fp)
{
    int i;
    if(fp == NULL) return;
    for(i=0;i<timelog_next;i++) {
            fprintf(fp, "T: %"PRIu64" %"PRIu64" %"PRIu64" %"PRIu64" %d %d %"PRIu64"\n", 
                    timelog[i].t1,
                    timelog[i].t2,
                    timelog[i].dt,
                    timelog[i].bufcount,
                    timelog[i].seq,
                    timelog[i].dropped,
                    timelog[i].t3 - g_timeorigin
                    );
    }
    timelog_next=0;
    fflush(fp);
}


//! Allocates an AVPicture casted to an AVFrame
static AVFrame *alloc_picture(enum PixelFormat pix_fmt, int width, int height)
{
    AVFrame *picture;

    picture = avcodec_alloc_frame();
    if (!picture)
        return NULL;
    if(avpicture_alloc((AVPicture*)picture,pix_fmt,width,height)) {
        av_free(picture);
        return NULL;
    }

    picture->format = pix_fmt;
    picture->width = width;
    picture->height = height;

    return picture;
}

//! State of the AVI encoding process
struct ofile_s {

    char * filetpl; //!< filename template e.g. "filex:/tmp/stream%03d.avi"
    int filenumber;
    char * filename; //!< e.g. "filex:/tmp/stream000.avi"

    int chunk_limit_frame; //<! maximum number of frame per chunk
    off_t chunk_limit_size; //<! maximum size of a chunk
    uint64_t chunk_limit_time; //<! maximum time of recording for a chunk
    uint64_t chunk_time_start; //<! start time of this chunk

    AVFormatContext *oc;
    AVCodecContext *c;
    AVCodec *codec;
    AVStream *st;

    AVFrame *tmp_picture; //<! for converting packed to planar format

    int cc_width;
    int cc_height;
    enum PixelFormat cc_pix_fmt;
};

//! Initialize an already allocated ofile_s structure
void ofile_init(struct ofile_s *of, const char *template)
{
    memset(of,0,sizeof(*of));
    of->filetpl = strdup(template);
    of->filenumber = -1;
}

void ofile_free(struct ofile_s *of)
{
    if(of == NULL) return;

    if(of->filetpl) {
        free(of->filetpl);
        of->filetpl= NULL;
    }
    if(of->tmp_picture) {
	    avpicture_free((AVPicture*)of->tmp_picture);
	    av_freep((AVPicture**)&of->tmp_picture);
	    of->tmp_picture=NULL;
    }
    if(of->filename) free(of->filename);
}

//! Close the current chunk
void ofile_closecurrent(struct ofile_s *of)
{
    if(of->oc) {
        int i;
        av_write_trailer(of->oc);
        avcodec_close(of->st->codec);
        for(i = 0; i < of->oc->nb_streams; i++) {
            av_freep(&of->oc->streams[i]->codec);
            av_freep(&of->oc->streams[i]);
        }
        //av_freep(&of->oc->streams[0]->codec);
        //av_freep(&of->oc->streams[0]);
        if (!(of->oc->oformat->flags & AVFMT_NOFILE)) {
            avio_close(of->oc->pb);
        }
        av_free(of->oc);
        of->oc = NULL;
        of->c = NULL;
        of->codec = NULL;
        of->st = NULL;
    }
}

//! Create and write to the next chunk
void ofile_nextfile(struct ofile_s *of)
{
    ssize_t len;

    ofile_closecurrent(of);

    of->filenumber++;
    if(of->filename) free(of->filename);
    len = snprintf(NULL,0,of->filetpl,of->filenumber);
    if(len < 0) xabort();
    of->filename = malloc(len+1);
    sprintf(of->filename,of->filetpl,of->filenumber);

    print_timelog(fp_timelog);
    fprintf(fp_timelog, "# File: %s\n", strchr(of->filename,':')+1);

#if 0
    of->fmt = av_guess_format(NULL,of->filename,NULL);
    if(!of->fmt) {
        fprintf(stderr,"E: av_guess_format\n");
        exit(1);
    }
#endif

    avformat_alloc_output_context2(&of->oc, NULL, NULL, of->filename);
    if (!of->oc) {
        xabort();
    }


    // Add video stream
    of->st = av_new_stream(of->oc, 0);   
    if(!of->st) xabort();
    of->c = of->st->codec;
    //   c->codec_id = CODEC_ID_FFVHUFF;
    of->c->codec_id = CODEC_ID_HUFFYUV;
    of->c->codec_type = AVMEDIA_TYPE_VIDEO;

    //   c->bit_rate = 400000;
    of->c->width = g_width;
    of->c->height = g_height;
    of->c->time_base.den = g_framerate;
    of->c->time_base.num = 1;
    //   c->gop_size = 12;
    of->c->pix_fmt = PIX_FMT_YUV422P; // planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples) 

    if(of->oc->oformat->flags & AVFMT_GLOBALHEADER)
        of->c->flags |= CODEC_FLAG_GLOBAL_HEADER;

#if 0
    if (av_set_parameters(of->oc, NULL) < 0) {
        fprintf(stderr, "Invalid output format parameters\n");
        exit(1);
    }
#endif

    // Prints info
    av_dump_format(of->oc, 0, of->filename, 1);

    of->codec = avcodec_find_encoder(of->c->codec_id);
    if(!of->codec) xabort();
    if(avcodec_open(of->c,of->codec) < 0) xabort();



    if(of->tmp_picture == NULL) {
        if (g_pixelformat == 0) {
            fprintf(stderr, "E: output stream pixelformat not set.\n");
            exit(1);
        }
        of->tmp_picture = alloc_picture(g_pixelformat, of->c->width, of->c->height);
        if (!of->tmp_picture) xabort();
    }

    if (!(of->oc->oformat->flags & AVFMT_NOFILE)) {
        if (avio_open(&of->oc->pb, of->filename, AVIO_FLAG_WRITE) < 0) {
            fprintf(stderr, "E: Could not open '%s'\n", of->filename);
            exit(1);
        }
    }

    if(of->cc_width == 0) {
        of->cc_width = of->c->width;
        of->cc_height = of->c->height;
        of->cc_pix_fmt = of->c->pix_fmt;
    }


    avformat_write_header(of->oc, NULL);

    {
        struct statfs fs;
        if(statfs(strchr(of->filename,':')+1,&fs) == 0) {
            fprintf(fp_timelog,"# Filesystem type: 0x%lx\n",fs.f_type);
        } else {
            fprintf(fp_timelog,"# Filesystem type: unknown\n");
        }
    }

    // Will be set by the writer thread
    of->chunk_time_start = 0;
}


//! Print device capabilities
void video_print_capabilities(struct video_context_s *vc)
{
    struct v4l2_capability cap;

    memset(&cap,0,sizeof(cap));
    if ( ioctl(vc->fd, VIDIOC_QUERYCAP, &cap) < 0 ) {
        printf("cap_driver = %s\n", "undef");
        printf("cap_card = %s\n", "undef");
        printf("cap_bus_info = %s\n", "undef");
    } else {
        printf("cap_driver = %s\n", cap.driver);
        printf("cap_card = %s\n", cap.card);
        printf("cap_bus_info = %s\n", cap.bus_info);
    }

}

//! Enumerate Pixel Formats
void video_print_formats(struct video_context_s *vc)
{
    int rc;
    struct v4l2_fmtdesc fmtdesc;
    memset(&fmtdesc,0,sizeof(fmtdesc));
    fmtdesc.index=0;
    fmtdesc.type=V4L2_BUF_TYPE_VIDEO_CAPTURE;
    printf("#format;index;type;flags;description;pixelformat\n");
    for(;;) {
        rc = ioctl(vc->fd, VIDIOC_ENUM_FMT, &fmtdesc);
        if (rc<0) {
            break;
        } else {
            printf("format;%d;%d;%d;%s;%04X\n", fmtdesc.index, fmtdesc.type, fmtdesc.flags, fmtdesc.description, fmtdesc.pixelformat);
        }
        fmtdesc.index++;
    }
}

//! Prints Data Format
void video_print_format(struct video_context_s *vc)
{
    int rc;
    struct v4l2_format fmt;

    memset(&fmt,0,sizeof(fmt));
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if ( (rc = ioctl(vc->fd, VIDIOC_G_FMT, &fmt)) < 0 ) {
        perror("VIDIOC_G_FMT");
        exit(1);
    }

    struct v4l2_pix_format *p = (struct v4l2_pix_format *)&fmt.fmt;
    printf("format_width = %d\n", p->width);
    printf("format_height = %d\n", p->height);
    printf("format_pixelformat = 0x%04x\n", p->pixelformat);
    printf("format_field = %d\n", p->field);
    printf("format_bytesperline = %d\n", p->bytesperline);
    printf("format_sizeimage = %d\n", p->sizeimage);
    printf("format_colorspace = %d\n", p->colorspace);


}

//! Print device inputs
void video_print_inputs(struct video_context_s *vc)
{
    int rc;
    struct v4l2_input desc;
    int i;

    memset(&desc,0,sizeof(desc));
    printf("#video_input;index;name;type;audioset;tuner;std;status\n");
    for(i=0;;i++) {
        desc.index = i;
        if ( (rc = ioctl(vc->fd, VIDIOC_ENUMINPUT, &desc)) < 0 ) break;
        printf("video_input;%d;%s;%d;%d;%d;%08llX;%d\n", desc.index, desc.name, desc.type, desc.audioset, desc.tuner, desc.std, desc.status);
    }
}

//! Print device current parameters
void video_print_parameters(struct video_context_s *vc)
{

    fprintf(stdout,"video_device = %s\n",vc->path);
    
    video_print_capabilities(vc);
    
    {
        int input_num = -1;

        if (-1 == ioctl (vc->fd, VIDIOC_G_INPUT, &input_num)) {
            perror("VIDIOC_G_INPUT");
            printf("video_input_index = undef\n");
        } else {
            printf("video_input_index = %d\n", input_num);
        }
    }

    {
        v4l2_std_id stdid;
        if(-1==ioctl(vc->fd,VIDIOC_G_STD,&stdid)) {
            perror("VIDIOC_G_STD");
            printf("standard_id = undef\n");
        } else {
            printf("standard_id = %lld\n", stdid);
        }
    }

    video_print_format(vc);
}


/** \brief Device opening and initialization
 *
 * path : NULL for autodetection
 *
 */
int video_open(struct video_context_s *vc, const char *path)
{
    int rc;
    //int fd;
    int index;
    struct v4l2_format fmt;
    struct v4l2_standard std;
    v4l2_std_id stdid;

    if(path==NULL) {
        char p[100];
        int i;
        //fd = -1;
        for(i=0;i<9;i++) {
            sprintf(p,"/dev/video%d",i);
            if(access(p,R_OK|W_OK) == 0) {
                rc = video_open(vc,p);
                if(rc==0) return 0;
                if(vc->fd > 0) { close(vc->fd); } 
            }
        }
        return 1;
    }
  
    if(vc->fd > 0) { close(vc->fd); } 

    vc->fd = open(path, O_RDWR);
    if(vc->fd<0) {
        perror("E:video_open: can't open video device");
        return 1;
    }

//    fprintf(stdout,"video_device = %s\n",path);

    if(0)
    {
        struct v4l2_requestbuffers reqbuf;

        memset (&reqbuf, 0, sizeof (reqbuf));
        reqbuf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        reqbuf.memory = V4L2_MEMORY_USERPTR;

        if (ioctl (vc->fd, VIDIOC_REQBUFS, &reqbuf) == -1) {
            if (errno == EINVAL)
                printf ("Video capturing or user pointer streaming is not supported\n");
            else
                perror ("VIDIOC_REQBUFS");

            exit (EXIT_FAILURE);
        }
    }


    if(0)
    {
        struct v4l2_audio audio;

        memset (&audio, 0, sizeof (audio));

        if (-1 == ioctl (vc->fd, VIDIOC_G_AUDIO, &audio)) {
            perror ("VIDIOC_G_AUDIO");
            exit (EXIT_FAILURE);
        }

        printf ("I: Current audio input: %d %s\n", audio.index, audio.name);
    }

    if(0)
    {
        //struct v4l2_input input;
        int input_num = -1;

        //memset (&input, 0, sizeof (input));

        if (-1 == ioctl (vc->fd, VIDIOC_G_INPUT, &input_num)) {
            perror ("VIDIOC_G_INPUT");
            exit (EXIT_FAILURE);
        }

        printf ("video_input_index = %d\n", input_num);
    }

    if(0) {
        video_print_inputs(vc);
        video_print_formats(vc);
    }

    if(g_auto)
    {
        index = 0;
        if ( (rc = ioctl(vc->fd, VIDIOC_S_INPUT, &index)) < 0 ) {
            perror("VIDIOC_S_INPUT");
        }
    }

    memset(&std,0,sizeof(std));
    std.index=0;
    while((rc = ioctl(vc->fd, VIDIOC_ENUMSTD, &std)) == 0) {
        if (std.id & V4L2_STD_PAL_B) break;
        std.index++;
    }
    
    //printf("rc=%d stdidx=%d\n",rc, std.index);
    if(g_auto) {
    if((std.id & V4L2_STD_PAL_B) == 0) {
        fprintf(stderr,"W: Standard not found\n");
        return 1;
    }
    printf("I: First PAL standard found : index=%d id=%lld %s\n", std.index, std.id, std.name);


    if(1) {
        stdid=std.id;
        if(-1==ioctl(vc->fd,VIDIOC_S_STD,&stdid)) {
            perror("VIDIOC_S_STD");
            xabort();
        }
    }
    }
    
    if(0) {
        if(-1==ioctl(vc->fd,VIDIOC_G_STD,&stdid)) {
            perror("VIDIOC_G_STD");
            xabort();
        }
        printf("standard_id = %lld\n", stdid);
    }


    memset(&fmt,0,sizeof(fmt));
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if ( (rc = ioctl(vc->fd, VIDIOC_G_FMT, &fmt)) < 0 ) {
        perror("VIDIOC_G_FMT");
        xabort();
    }

    if(g_auto) {
        {
            struct v4l2_pix_format *p = (struct v4l2_pix_format *)&fmt.fmt;
            p->width=g_width;
            p->height=g_height;
            p->pixelformat=V4L2_PIX_FMT_YUYV; // Packed YUYV aka YUV 4:2:2, 0x56595559
            p->colorspace = 1;
            p->field = V4L2_FIELD_INTERLACED;

            if ( (rc = ioctl(vc->fd, VIDIOC_S_FMT, &fmt)) < 0 ) {
                perror("VIDIOC_S_FMT");
            }

            memset(&fmt,0,sizeof(fmt));
            fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            if ( (rc = ioctl(vc->fd, VIDIOC_G_FMT, &fmt)) < 0 ) {
                perror("VIDIOC_G_FMT");
                xabort();
            }
            g_srcpixelformat = p->pixelformat;

        }
    } else {
        struct v4l2_pix_format *p = (struct v4l2_pix_format *)&fmt.fmt;
        g_width = p->width;
        g_height = p->height;
        g_srcpixelformat = p->pixelformat;
    }

    if      (g_srcpixelformat == V4L2_PIX_FMT_YUYV) g_pixelformat = PIX_FMT_YUYV422; // grabby
    else if (g_srcpixelformat == V4L2_PIX_FMT_UYVY) g_pixelformat = PIX_FMT_UYVY422; // lindy USB 2.0 AV Grabber No. 42886
    else {
        fprintf(stderr, "E: Pixel format not recognised: 0x%04x\n", g_srcpixelformat);
        xabort();
    }

//    video_print_format(vc);

    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if ( (rc = ioctl(vc->fd, VIDIOC_G_FMT, &fmt)) < 0 ) {
        perror("VIDIOC_G_FMT");
        xabort();
    }
    {
        struct v4l2_pix_format *p = (struct v4l2_pix_format *)&fmt.fmt;
        vc->sizeimage = p->sizeimage;
    }

    if(1)
    {
        // Try to reset the cropping rectangle.

        struct v4l2_cropcap cropcap;
        struct v4l2_crop crop;
        int rc;

        memset(&cropcap,0,sizeof(cropcap));
        cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if( (rc = ioctl(vc->fd, VIDIOC_CROPCAP, &cropcap)) >= 0 ) {

            if(0) {
                printf("CROPCAP\n");
                printf(" %d %d %d %d\n", cropcap.bounds.left, cropcap.bounds.top,
                        cropcap.bounds.width, cropcap.bounds.height);
                printf(" %d %d %d %d\n", cropcap.defrect.left, cropcap.defrect.top,
                        cropcap.defrect.width, cropcap.defrect.height);
            }


            memset (&crop, 0, sizeof (crop));
            crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

            if (-1 == ioctl (vc->fd, VIDIOC_G_CROP, &crop)) {
                if (errno == EINVAL) {
                    /* Ignore if cropping is not supported (EINVAL). */
                } else {
                    /* Ignore for other errors.
                     * For instance kernel 3.4 returns ENOTTY (25) with Terratec Grabby */
                    perror ("VIDIOC_G_CROP");
                }
            } else {
                crop.c = cropcap.defrect;

                if (-1 == ioctl (vc->fd, VIDIOC_S_CROP, &crop)
                        && errno != EINVAL) {
                    perror ("VIDIOC_S_CROP");
                }
            }

        } else {
            if (errno == ENOTTY) {
                // Ignore if cropping is not supported (ENOTTY)
            } else {
                // Prints an error message and continue
                perror("VIDIOC_CROPCAP");
            }
        }

    }

    strcpy(vc->path, path);
    
    return 0;
}

//! v4l2 buffers release
void video_free_buffers(struct video_context_s *vc)
{
    if(vc->bufs) {
        free(vc->bufs);
        vc->bufs = NULL;
    }
}

//! v4l2 buffers allocation
void video_alloc_buffers(struct video_context_s *vc)
{
    int rc;
    struct v4l2_buffer buf;
    int n;

    memset(&vc->reqbufs, 0, sizeof(vc->reqbufs));
    vc->reqbufs.count = 64;
    vc->reqbufs.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    vc->reqbufs.memory = V4L2_MEMORY_MMAP;
    if( (rc = ioctl(vc->fd,VIDIOC_REQBUFS,&vc->reqbufs)) < 0 ) {
        perror("VIDIOC_REQBUFS");
        xabort();
    }

    // 32 buffers ?
    // printf("I: Device buffers allocated: %d\n",vc->reqbufs.count);
    if ((vc->bufs = calloc(vc->reqbufs.count, sizeof(struct videobuf_s))) == NULL) {
        perror("calloc");
        xabort();
    }

    for (n = 0; n < vc->reqbufs.count; n++) {
        memset(&buf, 0, sizeof(struct v4l2_buffer));

        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory = V4L2_MEMORY_MMAP;
        buf.index = n;

        if (ioctl(vc->fd, VIDIOC_QUERYBUF, &buf) < 0) {
            perror("VIDIOC_QUERYBUF");
            xabort();
        }

        vc->bufs[n].len = buf.length;
        vc->bufs[n].map = mmap(NULL, buf.length, PROT_READ | PROT_WRITE, MAP_SHARED, vc->fd, buf.m.offset);

        if (vc->bufs[n].map == MAP_FAILED) {
            perror("mmap");
            xabort();
        }
    }


    for (n = 0; n < vc->reqbufs.count; n++) {
        memset(&buf, 0, sizeof(buf));
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory = V4L2_MEMORY_MMAP;
        buf.index = n;

        if (ioctl(vc->fd, VIDIOC_QBUF, &buf) < 0)
            xabort();
    }
}


//! Element of a doubly linked list of images
struct buf_s {
    size_t size; //!< Size of data
    uint8_t *data; 
    struct timelog_s t;
    struct buf_s *next;
    struct buf_s *prev;
};

//! Doubly linked list of images
struct buf_head_s {
    int count;
    struct buf_s *first;
    struct buf_s *last;
};

//! Insert a buffer in first position
void buf_push(struct buf_head_s *h, struct buf_s *p)
{

    if(p==NULL) return;

    h->count++;

    p->next = h->first;
    p->prev = NULL;
    if(h->first != NULL) h->first->prev = p;
    if(h->last == NULL) h->last = p;
    h->first = p;
}

//! Append a buffer at the end of the list
void buf_addlast(struct buf_head_s *h, struct buf_s *p)
{
    if(p==NULL) return;
    h->count++;

    if(h->last == NULL) {
        h->first = h->last = p;
        p->prev = p->next = NULL;
        return;
    }

    h->last->next = p;
    p->prev = h->last;
    h->last = p;
}

/*! \brief Remove and return the first element of the list.
 * 
 * Returns NULL if the list is empty.
 */
struct buf_s* buf_pop(struct buf_head_s *h)
{
    struct buf_s *p;

    if(h->first == NULL) return NULL;

    h->count--;

    p = h->first;
    h->first = p->next;
    p->next = NULL;

    if(h->first != NULL) h->first->prev = NULL;
    if(h->first == NULL) h->last = NULL;

    return p;
}

//! mutex for buflist_free and buflist_full
pthread_mutex_t buflist_mutex = PTHREAD_MUTEX_INITIALIZER;
//! Buffers available to store acquired frames
struct buf_head_s buflist_free = { 0, NULL, NULL };
//! Buffers to be recorded to disk
struct buf_head_s buflist_full = { 0, NULL, NULL };


void buffers_alloc(AVCodecContext *cc, int n)
{
    struct buf_s *p;

    while(n--) {
        p = malloc(sizeof(struct buf_s));
        if(p==NULL) xabort();
        p->size=0;
        p->data = (uint8_t *) alloc_picture(cc->pix_fmt, cc->width, cc->height);
        p->next = p->prev = NULL;
        buf_push(&buflist_free, p);
    }
}

void buffers_free()
{
    struct buf_s *p;

    while((p = buf_pop(&buflist_free)) || (p = buf_pop(&buflist_full))) {
        AVPicture *pp;
        pp = (AVPicture *)p->data;
        avpicture_free(pp);
        av_free(pp);
        p->data = NULL;
        free(p);
    }

}


//! The chunked output file
struct ofile_s *ofile;
//! mutex used when creating threads
pthread_mutex_t mutex_create = PTHREAD_MUTEX_INITIALIZER;
//! thread identifiers
pid_t g_tid_reader, g_tid_writer;

//! Get the current thread identifier
pid_t gettid()
{
    return syscall(__NR_gettid);
}

//! mutex for exported raw image handling
pthread_mutex_t mutex_raw = PTHREAD_MUTEX_INITIALIZER;
uint8_t * shared_rawimage;
size_t shared_rawimage_size;
volatile int shared_rawimage_status;
//! Recording will stop when this time is reached
uint64_t g_timelimit = 0;

/** \brief This thread fetch frames from the buffer and stores them into
 * the output file.
 */
void* frame_write_thread(void *arg)
{
    struct buf_s *pbuf;
    AVPacket pkt;
    int ret;
    static uint64_t t0,t1 = 0;
    static int frame_count = 0;
    // Temporary buffer used for encoding the picture
    unsigned char * cbuf;
    ssize_t cbuf_size;
    int out_size;
    AVFrame *frame;
    struct statfs vfs;
    int freebufs;

    g_tid_writer = gettid();
    pthread_mutex_unlock(&mutex_create);

    // The temporary buffer used for encoding the picture is twice the size
    // of a raw picture ( should be enough ? )
    cbuf_size = 2 * avpicture_get_size(ofile->cc_pix_fmt, ofile->cc_width, ofile->cc_height);
    cbuf = malloc(cbuf_size);

    if(cbuf == NULL) {
        perror("E: malloc");
        xabort();
    }

    ofile->chunk_limit_frame = g_chunkmaxframes;
    ofile->chunk_limit_time = g_chunktimelimit;


    while(1) {
        pthread_mutex_lock(&buflist_mutex);
        pbuf = buf_pop(&buflist_full);
        pthread_mutex_unlock(&buflist_mutex);

        if( pbuf==NULL ) {
            if(request_exit != 0) {
                return NULL;
            }
            usleep(40000);
            continue;
        }

        frame = (AVFrame*) pbuf->data;
        out_size = avcodec_encode_video(ofile->st->codec, cbuf, cbuf_size, frame);

        // For example if buffer was too small
        if(out_size < 0) {
            // TODO discard frame and continue
            fprintf(stderr,"E: avcodec_encode_video\n");
            request_exit = 1;
            break;
        }

        // If more frames are needed to produce output
        if(out_size == 0) {
            // TODO
            fprintf(stderr,"E: avcodec_encode_video\n");
            request_exit = 1;
            break;
        }
        av_init_packet(&pkt);
        pkt.flags |= AV_PKT_FLAG_KEY;
        pkt.stream_index= ofile->st->index;
        pkt.data= cbuf;
        pkt.size= out_size;

        t0 = gettimeofday64();
        if(ofile->chunk_time_start == 0) {
            // TODO should be the time returned by the driver
            ofile->chunk_time_start = t0;
        }
        ret = av_interleaved_write_frame(ofile->oc, &pkt);
        if(ret != 0) {
            fprintf(stderr, "E: av_interleaved_write_frame : %d\n", ret);
            request_exit = 1;
            break;
        }
        t1 = gettimeofday64();
        frame_count++;

#if 0
        if(t1-t0 > 50000) {
            printf("W: av_interleaved_write_frame() delta T %llu usec\n", t1-t0);
        }
#endif


        freebufs = pbuf->t.bufcount;
        pbuf->t.t3=t1;
        timelog[timelog_next] = pbuf->t;
        timelog_next++;
        if(timelog_next>=timelog_num) {
            fprintf(stderr, "E: timelog is full");
            request_exit=1;
            break;
        }
        if(timelog_next == 25) print_timelog(fp_timelog);



        // Makes the buffer available for the reader thread
        pthread_mutex_lock(&buflist_mutex);
        buf_push(&buflist_free, pbuf);
        pthread_mutex_unlock(&buflist_mutex);


        // Prints stats every 5 seconds
        if(frame_count % g_stats_every_frames == 0) {
            struct stat st;
            char *path = strchr(ofile->filename,':')+1;
            int64_t free_disk;
            stat(path,&st);
            if(statfs(path,&vfs) == 0) {
                int64_t sz = vfs.f_bavail * vfs.f_bsize;
                int64_t duree = (gettimeofday64() - g_timeorigin) / 1000000;
                int64_t mean_rate;
                //fprintf(stderr,"fsid : 0x%x\n",vfs.f_type);
#if 0
                fprintf(stderr, "I: available buffers = %4d  free disk space = %lld MB(SI)\n", freebufs, sz/1000000LL);
#else
                free_disk = sz/1000000LL;
                if(duree==0) duree = 1;
                mean_rate = st.st_size  / duree; // bytes per sec
                fprintf(stderr, "tcl: { free_bufs %d } { free_disk  {%"PRId64" MB(SI)} } ", freebufs, free_disk);
                fprintf(stderr, "{ frame_count %d } ", frame_count);
                fprintf(stderr, "{ file_size_mb { %"PRId64" MB(SI)} } ", st.st_size / 1000000); // MiB
                fprintf(stderr, "{ duree %"PRId64" } ", duree); // seconds
                fprintf(stderr, "{ duree_rest %"PRId64" } ", (sz / mean_rate) ); // MiB/s
                fprintf(stderr, "{ fps %d } ", g_framerate);
                fprintf(stderr, "\n");
#endif
                if(sz <= g_free_disk_limit) {
                    fprintf(stderr,"I: Disk Free Space Low\n");
                    g_exit_reason = "Ran out of disk space";
                    request_exit = 1;
                }
            }
        }

        // End of recording if time limit is reached
        if(g_timelimit != 0 && t1 >= g_timelimit) {
            g_exit_reason = "Time limit reached";
            request_exit = 1;
            fprintf(stderr,"I: time limit reached\n");
            break;
        }

        // Start a new chunk if needed
        // TODO should not test on t0 but on device time of current frame
        if(ofile->chunk_limit_frame != 0 &&
                (frame_count % ofile->chunk_limit_frame) == 0) {
            ofile_nextfile(ofile);
        } else if ( ofile->chunk_limit_time != 0 &&
                (t0 >= (ofile->chunk_time_start + ofile->chunk_limit_time)) ) {
            ofile_nextfile(ofile);
        }
    }

    request_exit = 1;
    return NULL;
}



//! Helper for frame_read_thread
int frame_store(struct ofile_s *of, uint8_t *buf)
{
    static int dropped_frames = 0;
    static struct SwsContext *img_convert_ctx;
    int ret;
    struct buf_s *pbuf;
    AVFrame *frame;
    static uint64_t last_frame_t2 = 0;
    uint8_t *tmpptr;

    pthread_mutex_lock(&buflist_mutex);
    pbuf = buf_pop(&buflist_free);

    ret = 0;
    if(pbuf == NULL) {
        ret = 1;
        dropped_frames++;
        //fprintf(stderr, "W: no free buffer. Dropping frame.\n");
    }
    pthread_mutex_unlock(&buflist_mutex);

    if(ret != 0) return 1;

    timelog_cur.bufcount = buflist_free.count;
    timelog_cur.dropped = dropped_frames;
    timelog_cur.dt = timelog_cur.t2 - last_frame_t2;
    dropped_frames = 0;
    pbuf->t = timelog_cur; 
    last_frame_t2 = timelog_cur.t2;


    frame = (AVFrame*) pbuf->data;

    if (img_convert_ctx == NULL) {
        img_convert_ctx = sws_getContext(of->tmp_picture->width,
                of->tmp_picture->height, // source dimensions
                (enum PixelFormat)of->tmp_picture->format, // source image format (PIX_FMT_YUYV422)
                frame->width, frame->height, // dest dimensions
                frame->format, // dest image format (PIX_FMT_YUV422P)
                SWS_BICUBIC, NULL, NULL, NULL);
        if (img_convert_ctx == NULL) xabort();
    }

    tmpptr = of->tmp_picture->data[0];
    of->tmp_picture->data[0] = buf;
    sws_scale(img_convert_ctx,
            (const uint8_t * const * )of->tmp_picture->data, // pointers to the planes of the source slice
            of->tmp_picture->linesize, // strides for each plane of the source image
            0, // first row of the slice
            of->tmp_picture->height, // number of rows in the slice
            frame->data, // planes of the destination image
            frame->linesize); // strides for each plane of the destination image
    of->tmp_picture->data[0] = tmpptr;


    pthread_mutex_lock(&buflist_mutex);
    buf_addlast(&buflist_full, pbuf);
    pthread_mutex_unlock(&buflist_mutex);

    if(1)
    {
        pthread_mutex_lock(&mutex_raw);
        if(shared_rawimage_status == 0) {
            memcpy(shared_rawimage, buf, shared_rawimage_size);
            shared_rawimage_status = 1;
        }
        pthread_mutex_unlock(&mutex_raw);
    }

    return 0;
}

//! Interface to the v4l2 device
struct video_context_s vc;

/** \brief This thread fetches frames from the device and put them into the buffer
 *
 *
 */
void* frame_read_thread(void *arg)
{
    int ret;
    enum v4l2_buf_type type;
    struct v4l2_buffer buf;
    struct pollfd pollfd;

    g_tid_reader = gettid();
    pthread_mutex_unlock(&mutex_create);

    memset(&buf,0,sizeof(buf));

    pollfd.fd = vc.fd;
    pollfd.events = POLLIN;
    pollfd.revents = 0;

    fflush(NULL);


    g_timelimit += gettimeofday64();

    type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (ioctl(vc.fd, VIDIOC_STREAMON, &type) < 0) {
        perror("E: VIDIOC_STREAMON");
        request_exit = 1;
    }

    while(request_exit == 0) {
        ret = poll(&pollfd, 1, 100);

        if (ret < 0) {
            if(errno == EINTR) continue;
            perror("W: poll ");
            continue;
        }

        if (ret == 0) continue;

        if(0)
        {
            static int state = 0;
            static uint64_t t0 = 0;
            uint64_t t = getelapsed();
            if(t-t0 <= 10000) {
                usleep(10000);
            }
            t0 = t;
            if(t >= UINT64_C(2000000)) {
                if(state == 0) {
                    state = 1;
                    continue;
                } else if (state == 1 && t <= UINT64_C(13)*1000*1000) {
                    continue;
                }
            }

            if(t>=UINT64_C(15)*1000000) request_exit = 1;
        }

        //        memset(&buf, 0, sizeof(struct v4l2_buffer));
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory = V4L2_MEMORY_MMAP;

        if (ioctl(vc.fd, VIDIOC_DQBUF, &buf) < 0) {
            perror("E: VIDIOC_DQBUF");
            request_exit = 1;
            break;
        }

        if(0) {
            printf("buf: type = %d\n", buf.type);
            printf("buf: flags = %d\n", buf.flags);
            printf("buf: field = %d\n", buf.field);
            printf("buf: sequence = %d\n", buf.sequence);
            printf("buf: timestamp = %"PRIu64"\n", buf.timestamp.tv_sec*UINT64_C(1000000) + buf.timestamp.tv_usec);
        }

        {
            uint64_t now;

            now = gettimeofday64();
            timelog_cur.t1 = now - g_timeorigin;
            timelog_cur.t2 = buf.timestamp.tv_sec*UINT64_C(1000000) + buf.timestamp.tv_usec - g_timeorigin;
            timelog_cur.dt = 0;
            timelog_cur.seq = buf.sequence;
        }

        frame_store(ofile, vc.bufs[buf.index].map);

        if (ioctl(vc.fd, VIDIOC_QBUF, &buf) < 0) {
            perror("E: VIDIOC_QBUF");
            request_exit = 1;
        }


    } // while(1)


    type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    if (ioctl(vc.fd, VIDIOC_STREAMOFF, &type) < 0) {
        perror("E: VIDIOC_STREAMOFF");
    }

    request_exit = 1;

    return NULL;
}

//! Intercept ctrl-c
void signal_handler(int signal)
{
    g_exit_reason = "Interrupted by signal";
    request_exit = 1;
}

char * g_input_device = NULL;
char * g_output_dir = NULL;
char * g_outfilepath = NULL;
char * g_logfilepath = NULL;

//! Display details of one device
void do_list_devices1(char *path)
{
    int fd = -1;
    int rc;
    int i;
    int index;
    struct v4l2_capability cap;
    struct v4l2_input input;

    if(access(path,R_OK|W_OK) != 0) return;
    fd = open(path, O_RDWR);
    if(fd<0) return;

    memset(&cap,0,sizeof(cap));

    do {
        if ( ioctl(fd, VIDIOC_QUERYCAP, &cap) < 0 ) {
            break;
        }

        if ( ioctl (fd, VIDIOC_G_INPUT, &index) < 0 ) {
            break;
        }

        memset(&input,0,sizeof(input));
        for(i=0;;i++) {
            input.index = i;
            if ( (rc = ioctl(fd, VIDIOC_ENUMINPUT, &input)) < 0 ) break;
            printf("%s;%d;%s;%s;%s\n",
                    path,
                    input.index,
                    (input.index == index ? "y" : "n"),
                    cap.card,
                    input.name
                  );
//            printf("video_input;%d;%s;%d;%d;%d;%08llX;%d\n",
  //                  input.index, input.name, input.type, input.audioset, input.tuner, input.std, input.status);
        }

    } while(0);


   if(fd>=0) {
       close(fd);
   }

}

//! Lists all v4l2 devices on stdout
int do_list_devices()
{
    int i;
    char path[100];
    for(i=0;i<9;i++) {
        sprintf(path,"/dev/video%d",i);
        do_list_devices1(path);
    }
    return 0;
}


//! Specific procedure when program is to acquire just one image
int one_shot(int argc, char *argv[], int one_shot_mode)
{
    int ret;

    {
        extern URLProtocol filex_protocol;
        extern URLProtocol null_protocol;
        ffurl_register_protocol(&filex_protocol,sizeof(filex_protocol));
        ffurl_register_protocol(&null_protocol,sizeof(null_protocol));
    }

    // Video Input Device Init
    if(video_open(&vc,g_input_device) != 0) {
        if(g_input_device) {
            fprintf(stderr,"E: cannot open device %s\n", g_input_device);
        } else {
            fprintf(stderr,"E: no video device could be opened\n");
        }
        exit(1);
    }

    video_alloc_buffers(&vc);

    // Allocation of space for shared image
    shared_rawimage_status = 0;
    shared_rawimage_size = vc.sizeimage;
    shared_rawimage = malloc(shared_rawimage_size);
    if(shared_rawimage==NULL) { perror(""); xabort(); }

    unlink("/dev/shm/pict.yuv422");
    unlink("/dev/shm/pict.yuv422.tmp");

    // Video Output Init
    av_register_all();
    avcodec_register_all();

    // launch acquisition
    request_exit = 0;
    {
        int frame_count = 0;
        enum v4l2_buf_type type;
        struct v4l2_buffer buf;
        struct pollfd pollfd;

        memset(&buf,0,sizeof(buf));

        pollfd.fd = vc.fd;
        pollfd.events = POLLIN;
        pollfd.revents = 0;

        type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (ioctl(vc.fd, VIDIOC_STREAMON, &type) < 0) {
            perror("E: VIDIOC_STREAMON");
            request_exit = 1;
        }


        while(request_exit == 0) {
            ret = poll(&pollfd, 1, 100);

            if (ret < 0) {
                if(errno == EINTR) continue;
                perror("W: poll ");
                continue;
            }

            if (ret == 0) continue;

            //        memset(&buf, 0, sizeof(struct v4l2_buffer));
            buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            buf.memory = V4L2_MEMORY_MMAP;

            if (ioctl(vc.fd, VIDIOC_DQBUF, &buf) < 0) {
                perror("E: VIDIOC_DQBUF");
                request_exit = 1;
                break;
            }

            memcpy(shared_rawimage, vc.bufs[buf.index].map, shared_rawimage_size);
            frame_count++;

            if ( (one_shot_mode == 1) && (frame_count >= 10) ) request_exit = 1;

            if ( frame_count > 10 ) {
                if ( ! fexist("/dev/shm/pict.yuv422") ) {
                    int fd = open("/dev/shm/pict.yuv422.tmp",O_WRONLY|O_CREAT,0644);
                    if(fd >= 0) {
                        write(fd, &g_pixelformat, sizeof(g_pixelformat));
                        write(fd, shared_rawimage, shared_rawimage_size);
                        close(fd);
                        rename("/dev/shm/pict.yuv422.tmp","/dev/shm/pict.yuv422");
                    }
                }
            }

            if (ioctl(vc.fd, VIDIOC_QBUF, &buf) < 0) {
                perror("E: VIDIOC_QBUF");
                request_exit = 1;
            }


        } // while(1)


        type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        if (ioctl(vc.fd, VIDIOC_STREAMOFF, &type) < 0) {
            perror("E: VIDIOC_STREAMOFF");
        }


    }

    // Copy the raw image for external application
    {
        int fd;
        unlink("/dev/shm/pict.yuv422");
        unlink("/dev/shm/pict.yuv422.tmp");
        fd = open("/dev/shm/pict.yuv422.tmp",O_WRONLY|O_CREAT,0644);
        if(fd >= 0) {
            write(fd, &g_pixelformat, sizeof(g_pixelformat));
            write(fd, shared_rawimage, shared_rawimage_size);
            close(fd);
            rename("/dev/shm/pict.yuv422.tmp","/dev/shm/pict.yuv422");
        }
    }

    video_free_buffers(&vc);
    return 0;
}

int main(int argc, char *argv[])
{
    int rc;
    int opt;
    int i;
    int do_one_shot = 0;
    int do_print_info = 0;
    pthread_t thread_write,thread_read;
    pthread_mutexattr_t mutex_attr;
    char *outfileprefix = NULL;
    int warn_realtime = 0;

    memset(&vc, 0, sizeof(vc));

    g_gettimeofday0 = gettimeofday64();

    pthread_mutexattr_init(&mutex_attr);
    if(pthread_mutexattr_setprotocol(&mutex_attr, PTHREAD_PRIO_INHERIT) != 0) {
        perror("");
        exit(1);
    }
    if(pthread_mutex_init(&buflist_mutex, &mutex_attr) != 0) {
        perror("");
        exit(1);
    }

    if(argc == 1) {
        print_usage();
        exit(0);
    }

    while((opt=getopt(argc, argv, "ab:h:w:i:o:d:p:c:y:s:zl012")) != -1) {
        switch(opt) {
            case 'a':
                g_auto = 1;
                break;
            case 'b':
                g_nbufs = atoi(optarg);
                break;
            case 'h':
                g_height = atoi(optarg);
                break;
            case 'w':
                g_width = atoi(optarg);
                break;
            case 's':
                {
                    int n = atoi(optarg);
                    if(n<100) {
                       n = 100; // 100 Mbytes
                       fprintf(stderr,"W: option x, free disk space limit cannot be set under 100 Mbytes\n");
                    }
                    g_free_disk_limit = n; // Mbytes
                    g_free_disk_limit *= 1000000; // bytes
                }
                break;
            case 'y':
                {
                    int n = atoi(optarg);
                    if(n<100) n = 100; // 0.1 second
                    if(n>10000) n = 10000; // 10 seconds
                    g_stats_every_frames = n * g_framerate / 1000;
                }
                break;
            case 'i':
                g_input_device = optarg;
                break;
            case 'o':
                g_output_dir = optarg;
                break;
            case 'p':
                outfileprefix = optarg;
                break;
            case 'd':
                // duration minutes : eg 20m
                {
                    int n;
                    char c;
                    rc = sscanf(optarg,"%d%c",&n,&c);
                    if(rc < 0) {
                        perror("E: sscanf");
                        exit(1);
                    }
                    if(rc != 2 || ( c != 's' && c != 'm' && c != 'f' ) || n <= 0) {
                        fprintf(stderr,"E: bad value for -d option\n");
                        exit(1);
                    }
                    if(c == 'f') {
                        g_timelimit = (unsigned)n;
                    }
                    if(c == 'm') {
                        g_timelimit = (unsigned)n;
                        g_timelimit *= UINT64_C(60)*1000*1000;
                    }
                    if(c == 's') {
                        g_timelimit = (unsigned)n;
                        g_timelimit *= UINT64_C(1)*1000*1000;
                    }
//                    g_timelimit += g_gettimeofday0;
                }
                break;
            case 'c':
                // chunk size in minutes
                {
                    int n;
                    char c;
                    rc = sscanf(optarg,"%d%c",&n,&c);
                    if(rc < 0) {
                        perror("E: sscanf");
                        exit(1);
                    }
                    if(rc != 2 || ( c != 's' && c != 'm' && c != 'f' ) || n <= 0) {
                        fprintf(stderr,"E: bad value for -c option\n");
                        exit(1);
                    }
                    if(c == 'f') {
                        g_chunkmaxframes = (unsigned)n;
                    }
                    if(c == 'm') {
                        g_chunktimelimit = (unsigned)n;
                        g_chunktimelimit *= UINT64_C(60)*1000*1000;
                    }
                    if(c == 's') {
                        g_chunktimelimit = (unsigned)n;
                        g_chunktimelimit *= UINT64_C(1)*1000*1000;
                    }
                }
                break;
            case 'z':
                g_realtime = 0;
                break;
            case '0':
                do_print_info = 1;
            case '1':
                do_one_shot = 1;
                break;
            case '2':
                do_one_shot = 2;
                break;
            case 'l':
                return do_list_devices();
                break;
            default:
                printf("E: Argument parsing error\n");
                print_usage();
                exit(1);
        }
    }

    if(do_print_info){
        if(video_open(&vc,g_input_device) != 0) {
            if(g_input_device) {
                fprintf(stderr,"E: cannot open device %s\n", g_input_device);
            } else {
                fprintf(stderr,"E: no video device could be opened\n");
            }
            return 1;
        }
        
        video_print_parameters(&vc);
        return 0;
    }

    if(do_one_shot != 0) {
        return one_shot(argc,argv,do_one_shot);
    }

    
    if(optind > argc) {
        printf("E: Expected argument after options\n");
        print_usage();
        exit(1);
    }

    if(g_timelimit == 0) {
        printf("E: duration must be specified\n");
        exit(1);
    }

    if(g_chunktimelimit == 0 && g_chunkmaxframes == 0) {
        printf("E: chunk size must be specified\n");
        exit(1);
    }

    sync();

    {
        extern URLProtocol filex_protocol;
        extern URLProtocol null_protocol;
        ffurl_register_protocol(&filex_protocol,sizeof(filex_protocol));
        ffurl_register_protocol(&null_protocol,sizeof(null_protocol));
    }

    // Allocation of timelog
    timelog_num = 3600 * g_framerate;
    timelog = malloc(timelog_num*sizeof(struct timelog_s));
    if(timelog == NULL) xabort();


    // Check of output directory
    if( g_output_dir == NULL) {
        fprintf(stdout, "E: give output dir: -o /tmp/observ/asteroid1234\n");
        exit(1);
    } else {
        char path[PATH_MAX]; // TODO or +1 ?
        char *name;

        if(realpath(g_output_dir,path) < 0) {
            perror("E: realpath");
            exit(1);
        }

        name = basename(path);

        if(name[0] == '\0') {
            fprintf(stderr,"Cannot use root of filesystem as output dir.\n");
            exit(1);
        }

        if(access(path,F_OK) < 0) {
            perror("E: output_dir does not exist");
            exit(1);
        }

        {
            struct stat st;
            if(stat(path,&st) < 0) {
                perror("E: stat()");
                exit(1);
            }
            if( ! S_ISDIR(st.st_mode) ) {
                fprintf(stderr,"E: %s is not a directory\n", path);
                exit(1);
            }
        }

        {
            char outstr[200];
            char tmpname[PATH_MAX*2];
            time_t t;
            struct tm *tmp;

            t=time(NULL);
            tmp = gmtime(&t);
            if(tmp==NULL) {
                perror("E: gmtime");
                exit(1);
            }
            if (strftime(outstr, sizeof(outstr), "%Y%m%dT%H%M%S", tmp) == 0) {
                fprintf(stderr, "strftime returned 0");
                exit(EXIT_FAILURE);
            }

            if(outfileprefix) {
                sprintf(tmpname,"filex:%s/%s-%%03d.avi",path,outfileprefix);
                g_outfilepath = strdup(tmpname);
                sprintf(tmpname,"%s/%s.log.txt",path,outfileprefix);
                g_logfilepath = strdup(tmpname);
            } else {
                sprintf(tmpname,"filex:%s/%s-%s-%%03d.avi",path,outfileprefix?outfileprefix:name,outstr);
                g_outfilepath = strdup(tmpname);
                sprintf(tmpname,"%s/%s-%s.log.txt",path,outfileprefix?outfileprefix:name,outstr);
                g_logfilepath = strdup(tmpname);
            }
        }

#if 0
        if(access(g_outfilepath) == 0) {
            fprintf(stderr,"E: output file already exists");
            exit(1);
        }
#endif
        if(access(g_logfilepath,F_OK) == 0) {
            fprintf(stderr,"E: log file already exists");
            exit(1);
        }

    }


    // Opening of timelog
    fp_timelog = fopen(g_logfilepath,"a");
    if(fp_timelog == NULL) {
        perror("E: opening log file");
        exit(1);
    }
    {
            char outstr[200];
            time_t t;
            struct tm *tmp;

            t=time(NULL);
            tmp = gmtime(&t);
            if(tmp==NULL) {
                perror("E: gmtime");
                exit(1);
            }
            if (strftime(outstr, sizeof(outstr), "%Y%m%dT%H%M%S", tmp) == 0) {
                fprintf(stderr, "strftime returned 0");
                exit(EXIT_FAILURE);
            }
            fprintf(fp_timelog, "# grab version %s\n",g_version_string);
            fprintf(fp_timelog, "# Start of execution on %s UTC\n",outstr);
    }

    // outputs command line arguments
    fprintf(fp_timelog, "# Command line arguments:");
    for(i=1;i<argc;i++) {
        fprintf(fp_timelog, " %s", argv[i]);
    }
    fprintf(fp_timelog, "\n");
    fprintf(fp_timelog, "# Requested duration of recording: %"PRIu64" minutes\n", g_timelimit/1000000/60);
    {
        struct utsname u;
        if(uname(&u) < 0) {
            perror("E: uname");
            exit(1);
        } else {
            fprintf(fp_timelog, "# System info: OS = %s\n", u.sysname);
            fprintf(fp_timelog, "# System info: OS release = %s\n", u.release);
            fprintf(fp_timelog, "# System info: OS version = %s\n", u.version);
            fprintf(fp_timelog, "# System info: OS hardware = %s\n", u.machine);
        }
    }

    // get cpuinfo
    {
        FILE *fp;
        char buf[200];
        ssize_t len;
        fp = popen("cat /proc/cpuinfo | sed 's/\\(.*\\)/# cpuinfo: \\1/'", "r");
        if(fp == NULL) {
            perror("E: popen"); exit(1);
        }
        while(!feof(fp)) {
            len = fread(buf, 1, sizeof(buf), fp);
            fwrite(buf,1,len,fp_timelog);
        }
        pclose(fp);
    }

#define XSTR(s) XXSTR(s)
#define XXSTR(s) #s
    // TODO get version of different libav*
    fprintf(fp_timelog,"# ffmpeg avcodec version: " XSTR(LIBAVCODEC_VERSION) "\n");
    fprintf(fp_timelog,"# ffmpeg avformat version: " XSTR(LIBAVFORMAT_VERSION) "\n");
    fprintf(fp_timelog,"# ffmpeg swscale version: " XSTR(LIBSWSCALE_VERSION) "\n");

    // Registering of signal handler
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    signal(SIGHUP, SIG_IGN);

    // Video Input Device Init
    if(video_open(&vc,g_input_device) != 0) {
        if(g_input_device) {
            fprintf(stderr,"E: cannot open device %s\n", g_input_device);
        } else {
            fprintf(stderr,"E: no video device could be opened\n");
        }

        fprintf(fp_timelog, "# End of recording reason : %s\n", "video device opening failed");
        exit(1);
    }

    video_alloc_buffers(&vc);

    // Allocation of space for shared image
    shared_rawimage_status = 0;
    shared_rawimage_size = vc.sizeimage;
    shared_rawimage = malloc(shared_rawimage_size);
    if(shared_rawimage==NULL) { perror(""); xabort(); }

    g_timeorigin = gettimeofday64();
    fprintf(fp_timelog, "# Origin of times (unix time in usec): %"PRIu64"\n", g_timeorigin);

    // Video Output Init
    av_register_all();
    avcodec_register_all();
    ofile = malloc(sizeof(*ofile));
    ofile_init(ofile, g_outfilepath);
    ofile_nextfile(ofile);

    // Allocation of intermediate buffers
    buffers_alloc(ofile->c, g_nbufs);

    fprintf(fp_timelog,
            "# For each picture processed a line prefixed with 'T:' is recorded.\n"
            "# Detail of parameters:\n"
            "# Note: unix times in usec are relative to Origin of times\n"
            "#  1: unix time (usec) when the picture was read by the application\n"
            "#  2: unix time (usec) when the picture was processed by the driver\n"
            "#  3: difference of argument 2 of this picture and of the previous recorded one\n"
            "#  4: number of free buffers when the picture was read by the application\n"
            "#  5: sequence number attributed by the driver\n"
            "#  6: number of dropped frames between this picture and the\n"
            "#     previous recorded one by the application\n"
           );

    sync();

    if(g_realtime) {
        if(mlockall(MCL_CURRENT|MCL_FUTURE) != 0) {
            warn_realtime = 1;
            fprintf(fp_timelog, "# W: cannot lock memory: ");
            fprintf(fp_timelog, "unix error %d %s\n", errno, strerror(errno));
            perror("W: mlockall");
            fprintf(stderr,"I: maybe add a line of the following form to /etc/security/limits.conf\n");
            fprintf(stderr," @video - memlock unlimited\n");
        }
    }

    // This thread writes buffers to AVI files
    pthread_mutex_lock(&mutex_create);
    if(pthread_create(&thread_write, NULL, frame_write_thread, NULL) != 0) xabort();

    // This thread reads frames from the grabber and store them into buffers
    pthread_mutex_lock(&mutex_create);
    if(pthread_create(&thread_read, NULL, frame_read_thread, NULL) != 0) xabort();

    pthread_mutex_lock(&mutex_create);

    if(g_realtime)
    {
        struct sched_param sp;

        sp.__sched_priority = 10;
        if(pthread_setschedparam(thread_read, SCHED_FIFO, &sp) != 0) {
            warn_realtime = 1;
            fprintf(fp_timelog, "# W: cannot change reader thread scheduler: ");
            fprintf(fp_timelog, "unix error %d %s\n", errno, strerror(errno));
            perror("W: pthread_setschedparam");
            fprintf(stderr,"I: maybe add a line of the following form to /etc/security/limits.conf\n");
            fprintf(stderr," @video - rtprio 10\n");
        }

        errno = 0;
        rc = setpriority(PRIO_PROCESS, g_tid_writer, -20);
        if(rc == -1 && errno != 0) {
            warn_realtime = 1;
            fprintf(fp_timelog, "# W: cannot renice writer thread: ");
            fprintf(fp_timelog, "unix error %d %s\n", errno, strerror(errno));
            perror("W: cannot change priority of process");
            fprintf(stderr,"I: maybe add a line of the following form to /etc/security/limits.conf\n");
            fprintf(stderr," @video - nice -20\n");
        }
    }

    // display threads priority
    {
        struct sched_param sp;
        int policy;
        int prio;

        rc = nice(0);
        fprintf(fp_timelog,"# priority of main thread: %d\n", rc);

        if(pthread_getschedparam(thread_read,&policy,&sp)!=0) {
        } else {
            if(policy == 0) {
                prio = getpriority(PRIO_PROCESS,g_tid_reader);
                fprintf(fp_timelog,"# priority of reader thread: policy=%d, prio=%d, nice=%d\n", policy, sp.sched_priority, prio);
            } else {
                fprintf(fp_timelog,"# priority of reader thread: policy=%d, prio=%d\n", policy, sp.sched_priority);
            }
        }

        if(pthread_getschedparam(thread_write,&policy,&sp)!=0) {
        } else {
            if(policy == 0) {
                prio = getpriority(PRIO_PROCESS,g_tid_writer);
                fprintf(fp_timelog,"# priority of writer thread: policy=%d, prio=%d, nice=%d\n", policy, sp.sched_priority, prio);
            } else {
                fprintf(fp_timelog,"# priority of writer thread: policy=%d, prio=%d\n", policy, sp.sched_priority);
            }
        }

    }

    if(warn_realtime) {
        fprintf(fp_timelog, "# realtime mode: not properly set up.\n");
        fprintf(stderr, "W: realtime mode: not properly set up.\n");
    } else {
        if(!g_realtime) {
            fprintf(fp_timelog, "# realtime mode: not requested by user.\n");
        } else {
            fprintf(fp_timelog, "# realtime mode: ok.\n");
        }
    }

    // Copy the raw image for external application
    shared_rawimage_status = 0;
    while(request_exit == 0) {
        usleep(40000);
        if ( shared_rawimage_status == 2) {
            if ( ! fexist("/dev/shm/pict.yuv422") ) {
                pthread_mutex_lock(&mutex_raw);
                shared_rawimage_status = 0;
                pthread_mutex_unlock(&mutex_raw);
            }
        } else if ( shared_rawimage_status == 0 ) {
        } else if ( shared_rawimage_status == 1 ) {
            int fd = open("/dev/shm/pict.yuv422.tmp",O_WRONLY|O_CREAT,0644);
            if(fd >= 0) {
                write(fd, &g_pixelformat, sizeof(g_pixelformat));
                write(fd, shared_rawimage, shared_rawimage_size);
                close(fd);
                rename("/dev/shm/pict.yuv422.tmp","/dev/shm/pict.yuv422");
            }
            pthread_mutex_lock(&mutex_raw);
            shared_rawimage_status = 2;
            pthread_mutex_unlock(&mutex_raw);
        }
    }

    pthread_join(thread_read, NULL);
    pthread_join(thread_write, NULL);

    ofile_closecurrent(ofile);
    print_timelog(fp_timelog);


    {
        char outstr[200];
        time_t t;
        struct tm *tmp;

        t=time(NULL);
        tmp = gmtime(&t);
        if(tmp==NULL) {
            perror("E: gmtime");
            exit(1);
        }
        if (strftime(outstr, sizeof(outstr), "%Y%m%dT%H%M%S", tmp) == 0) {
            fprintf(stderr, "strftime returned 0");
            exit(EXIT_FAILURE);
        }
        fprintf(fp_timelog, "# End of recording on %s UTC\n",outstr);
        fprintf(fp_timelog, "# End of recording reason : %s\n",g_exit_reason);
    }
    fprintf(fp_timelog, "# Recording duration: %"PRIu64" minutes\n",(gettimeofday64()-g_timeorigin)/60/1000/1000);


    fclose(fp_timelog);
    fp_timelog=NULL;

    fflush(NULL); printf("\n"); fflush(NULL);

    sync();

    buffers_free();
    video_free_buffers(&vc);
    free(timelog);
    free(shared_rawimage);
    ofile_free(ofile);
    free(ofile);
    if(g_outfilepath) free(g_outfilepath);
    if(g_logfilepath) free(g_logfilepath);
    
    fprintf(stderr, "I: Finished.\n");

    exit(EXIT_SUCCESS);
}

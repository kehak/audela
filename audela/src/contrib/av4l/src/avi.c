/* :set ts=4 sw=4 et */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#ifdef WIN32
// ffmpeg utilise la directive inline
// Mais sous windows, inline n'existe plus car il a ete redefini en _inline
// je cree la definition de inline pour etre compatible avec linux
#define inline _inline
#else
#endif

#define _FILE_OFFSET_BITS 64
#define _LARGEFILE64_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <inttypes.h>

#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"

#include <sys/stat.h>

#include <tcl.h>

#define LIBNAME "av4l"

struct aviprop {
    Tcl_Interp * interp;
    int status;
    char *path; //!< chemin complet du fichier avi
    int current_image;
    AVFormatContext *pFormatCtx;
    int videoStream; //!< index du flux video
    AVCodecContext *pCodecCtx;
    AVCodec *pCodec;
    AVFrame *pFrame; //!< image provenant du flux
    AVFrame *pFrameDest; //!< image apres conversion
    enum PixelFormat pix_fmt_dest; //!< pixelformat de l'image apres conversion
    AVPacket packet;
    struct SwsContext * pSwsCtx;
    off_t filesize; //!< taille du fichier avi en octets
    off_t previous_offset;
};

static void
p_avi_close(struct aviprop * avi)
{

    if(avi == NULL) return;

    if(avi->pFrameDest) {
        avpicture_free((AVPicture*)avi->pFrameDest);
        av_freep(&(avi->pFrameDest));
    }

    if(avi->pFrame) {
        av_freep(&(avi->pFrame));
    }

    if(avi->pSwsCtx) {
        sws_freeContext(avi->pSwsCtx);
        avi->pSwsCtx = NULL;
    }

    if(avi->pCodecCtx) {
        avcodec_close(avi->pCodecCtx);
        avi->pCodecCtx = NULL;
    }

    if(avi->pFormatCtx) {
	av_close_input_file(avi->pFormatCtx);
        avi->pFormatCtx = NULL;
    }

}

static int
avi_load(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
    int i;
    char * path = argv[2];
    struct stat st;
    uint8_t *buffer;
    int numBytes;

    if(stat(path,&st) != 0) {
        Tcl_SetResult(interp, "File not found in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    avi->filesize = st.st_size;

    //fprintf(stderr,"file size = %ld\n", avi->filesize);

    p_avi_close(avi);

    if(avformat_open_input(&avi->pFormatCtx, path, NULL, NULL)!=0) {
        Tcl_SetResult(interp, "File open failed in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    if(av_find_stream_info(avi->pFormatCtx)<0) {
        Tcl_SetResult(interp, "Stream info not found in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    // Dump format on stdout/stderr
    av_dump_format(avi->pFormatCtx, 0, path, 0);

    // Find the video stream
    avi->videoStream=-1;
    for(i=0; i<avi->pFormatCtx->nb_streams; i++) {
        if(avi->pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            avi->videoStream=i;
            break;
        }
    }

    if(avi->videoStream==-1) {
        Tcl_SetResult(interp, "No video stream found in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    // Get a pointer to the codec context for the video stream
    avi->pCodecCtx = avi->pFormatCtx->streams[avi->videoStream]->codec;

    // Find the decoder for the video stream
    avi->pCodec = avcodec_find_decoder(avi->pCodecCtx->codec_id);
    if(avi->pCodec==NULL) {
        Tcl_SetResult(interp, "Unsupported codec in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    if(avcodec_open(avi->pCodecCtx, avi->pCodec)<0){
        Tcl_SetResult(interp, "Open codec failed in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }


    avi->pFrame = avcodec_alloc_frame();

    avi->pFrameDest = avcodec_alloc_frame();

    numBytes=avpicture_get_size(avi->pix_fmt_dest, avi->pCodecCtx->width,
            avi->pCodecCtx->height);

    buffer=(uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
    avpicture_fill((AVPicture *)avi->pFrameDest, buffer, avi->pix_fmt_dest,
            avi->pCodecCtx->width, avi->pCodecCtx->height);
    avi->pSwsCtx = sws_getContext(
            avi->pCodecCtx->width, avi->pCodecCtx->height, avi->pCodecCtx->pix_fmt,
            avi->pCodecCtx->width, avi->pCodecCtx->height, avi->pix_fmt_dest,
            SWS_BICUBIC,
            NULL, NULL,
            NULL
            );

    avi->current_image = -1;

    avi->previous_offset = 0;

    avi->status = 0;

    return TCL_OK;
}

// Procedure independante appelee uniquement par le module d'acquisition
// argv[1] chemin d'une image brute YUYV422 ( format packed )
static int
convert_shared_image(ClientData cdata, Tcl_Interp *interp, int argc, const char * argv[])
{
    static AVFrame *pFrame = 0, *pFrameDest = 0;
    static struct SwsContext * pSwsCtx = 0;

    int bufno;
    const char * path = argv[2];
    struct stat st;
    off_t filesize = 0;
    static enum PixelFormat in_pixelformat = 0;
    int width, height;
    static int numBytesSrc;
    static int numBytesDst;
    uint8_t *buffer;
    char cmd[1000];
    FILE *fp;

    
    Tcl_GetInt(interp, argv[1], &bufno);

    width = height = 0;
    if(stat(path,&st) != 0) {
        return TCL_ERROR;
    }
    filesize = st.st_size;
    //fprintf(stderr,"file size = %lld\n", filesize);
    if(filesize == 2*720*576+sizeof(in_pixelformat)) {
        width = 720; height=576;
    } else if (filesize == 2*640*480+sizeof(in_pixelformat)) {
        width = 640; height=480;
    } else {
        Tcl_SetResult(interp, "Size of image not detected in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }


    fp = fopen(path,"r");
    if (!fp) {
        Tcl_SetResult(interp, "Open file failed in " LIBNAME ".", TCL_VOLATILE);
        return TCL_ERROR;
    }

    {
        enum PixelFormat tmp_pixelformat = 0;
        fread(&tmp_pixelformat, sizeof(tmp_pixelformat), 1, fp);
        if ( tmp_pixelformat != in_pixelformat) {
            in_pixelformat = tmp_pixelformat;
            if ( pFrame != 0 ) {
                av_freep(&pFrame); // TODO
                pFrame = 0;
            }
        }
    }

    if(pFrame == 0) {
        pFrame=avcodec_alloc_frame();
        numBytesSrc=avpicture_get_size(in_pixelformat, width, height);
        //fprintf(stderr,"numBytesSrc = %d\n",numBytesSrc);
        buffer=(uint8_t *)av_malloc(numBytesSrc*sizeof(uint8_t));
        avpicture_fill((AVPicture *)pFrame, buffer, in_pixelformat, width, height);
        //fprintf(stderr," %d %d %d\n",pFrame->linesize[0], pFrame->linesize[1], pFrame->linesize[2]);
        pFrameDest=avcodec_alloc_frame();
        numBytesDst=avpicture_get_size(PIX_FMT_GRAY8, width, height);
        buffer=(uint8_t *)av_malloc(numBytesDst*sizeof(uint8_t));
        avpicture_fill((AVPicture *)pFrameDest, buffer, PIX_FMT_GRAY8, width, height);
        pSwsCtx = sws_getContext(
            width, height, in_pixelformat,
            width, height, PIX_FMT_GRAY8,
            SWS_BICUBIC,
            NULL, NULL,
            NULL
            );
    }

    fread(pFrame->data[0],numBytesSrc,1,fp);
    fclose(fp);

    sws_scale( pSwsCtx,
            (const uint8_t**)pFrame->data,
            pFrame->linesize,
            0,
            height,
            pFrameDest->data,
            pFrameDest->linesize
            );

    sprintf(cmd, "buf%d clear", bufno);
    if (Tcl_Eval(interp, cmd) == TCL_ERROR) {
        sprintf(cmd, "buf::create %d", bufno);
        if (Tcl_Eval(interp, cmd) == TCL_ERROR) {
            Tcl_SetResult(interp, "buf::create failed in " LIBNAME ".", TCL_VOLATILE);
            return TCL_ERROR;
        }
    }

    {
        char s[4000];
        sprintf(s,"buf%d setpixels CLASS_GRAY %d %d FORMAT_BYTE COMPRESS_NONE %ld -reverse_y 1", bufno, width, height, (long)pFrameDest->data[0]);
        if (Tcl_Eval(interp, s) == TCL_ERROR) {
            sprintf(cmd,"buf%d setpixels failed in %s.", bufno, LIBNAME);
            Tcl_SetResult(interp, cmd, TCL_VOLATILE);
            return TCL_ERROR;
        }

    }

    return TCL_OK;
}

static int
avi_next(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
    int frameFinished = 0;

    avi->previous_offset = avi->pFormatCtx->pb->pos;

    while(av_read_frame(avi->pFormatCtx, &avi->packet)>=0) {
        // Is this a packet from the video stream?
        if(avi->packet.stream_index==avi->videoStream) {
            // Decode video frame
            avcodec_decode_video2(avi->pCodecCtx, avi->pFrame, &frameFinished,
                    &avi->packet);

            // Did we get a video frame?
            if(frameFinished) {
                // Convert the image from its native format to RGB
                sws_scale( avi->pSwsCtx,
                        (const uint8_t**)avi->pFrame->data,
                        avi->pFrame->linesize,
                        0,
                        avi->pCodecCtx->height,
                        avi->pFrameDest->data,
                        avi->pFrameDest->linesize
                        );

                if (Tcl_Eval(interp, "buf1 clear") == TCL_ERROR) {
                    if (Tcl_Eval(interp, "buf::create 1") == TCL_ERROR) {
                        Tcl_SetResult(interp, "buf::create failed in " LIBNAME ".", TCL_VOLATILE);
                        return TCL_ERROR;
                    }
                }

                {
                    char s[4000];
		    if (avi->pix_fmt_dest == PIX_FMT_GRAY8) {
                      sprintf(s,"buf1 setpixels CLASS_GRAY %d %d FORMAT_BYTE COMPRESS_NONE %ld -reverse_y 1", avi->pCodecCtx->width, avi->pCodecCtx->height, (long)avi->pFrameDest->data[0]);
		    } else { // PIX_FMT_RGB24
                      sprintf(s,"buf1 setpixels CLASS_RGB %d %d FORMAT_BYTE COMPRESS_NONE %ld -reverse_y 1", avi->pCodecCtx->width, avi->pCodecCtx->height, (long)avi->pFrameDest->data[0]);
		    }
                    if (Tcl_Eval(interp, s) == TCL_ERROR) {
                        Tcl_SetResult(interp, "buf1 setpixels failed in " LIBNAME ".", TCL_VOLATILE);
                        return TCL_ERROR;
                    }

                }
                av_free_packet(&avi->packet);
                break;	
            }
        }

        // Free the packet that was allocated by av_read_frame
        av_free_packet(&avi->packet);
        return TCL_OK;
    }
    return TCL_OK;
}





// Test en tout genre
static int
avi_test(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[1000];
	sprintf(s,"%s","** pFormatCtx **\n");
	sprintf(s,"%s %s %"PRId64" \n",s,"nb img = ",avi->pFormatCtx->streams[avi->videoStream]->nb_frames);
	sprintf(s,"%s %s %d \n",s,"index = ",avi->packet.stream_index);
	sprintf(s,"%s %s %d \n",s,"bit_rate = ",avi->pFormatCtx->bit_rate);
	sprintf(s,"%s %s %d \n",s,"packed_size = ",avi->pFormatCtx->packet_size);
//	sprintf(s,"%s %s %d \n",s,"key = ",avi->pFormatCtx->key);
	sprintf(s,"%s %s %d \n",s,"keylen = ",avi->pFormatCtx->keylen);
	sprintf(s,"%s %s %d \n",s,"fps_probe_size = ", avi->pFormatCtx->fps_probe_size);

	sprintf(s,"%s %s",s,"** streams * *\n");
	sprintf(s,"%s %s %"PRId64" \n",s,"first_pts = ", avi->pFormatCtx->streams[avi->videoStream]->first_dts);
	sprintf(s,"%s %s %"PRId64" \n",s,"start_time = ", avi->pFormatCtx->streams[avi->videoStream]->start_time);
	sprintf(s,"%s %s %"PRId64" \n",s,"cur_dts = ", avi->pFormatCtx->streams[avi->videoStream]->cur_dts);
	sprintf(s,"%s %s %"PRId64" \n",s,"last_IP_pts = ", avi->pFormatCtx->streams[avi->videoStream]->last_IP_pts);
	sprintf(s,"%s %s %d \n",s,"nb_index_entries = ", avi->pFormatCtx->streams[avi->videoStream]->nb_index_entries);
	sprintf(s,"%s %s %"PRId64" \n",s,"duration = ", avi->pFormatCtx->streams[avi->videoStream]->duration);
	sprintf(s,"%s %s %d \n",s,"pts_wrap_bits = ", avi->pFormatCtx->streams[avi->videoStream]->pts_wrap_bits);




	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}






static int
avi_seekto_frame(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int ret;
	int frameno; // frame number, from 0 to ...
	int64_t timestamp;

	Tcl_GetInt(interp, argv[2], &frameno);
	timestamp = (int64_t) frameno * 1000000 / 25;
	ret = av_seek_frame(avi->pFormatCtx, -1, timestamp, 0);
	if (ret < 0) {
		Tcl_SetResult(interp, "Could not seek in " LIBNAME ".", TCL_VOLATILE);
		return TCL_ERROR;
	}
	return TCL_OK;
}


static int
avi_seek_percent(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int ret;
	double pos;
	off_t off;

	Tcl_GetDouble(interp, argv[2], &pos);
	off = pos * avi->filesize;
	//ff_read_frame_flush(avi->pFormatCtx);
	ret = av_seek_frame(avi->pFormatCtx, -1, off, AVSEEK_FLAG_BYTE);
	if (ret < 0) {
		Tcl_SetResult(interp, "Could not seek in " LIBNAME ".", TCL_VOLATILE);
		return TCL_ERROR;
	}
	avi->previous_offset = avi->pFormatCtx->pb->pos;
	return TCL_OK;
}

static int
avi_seek_byte(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int ret;
	int pos;
	off_t off;

	Tcl_GetInt(interp, argv[2], &pos);
	off = pos;

	ret = av_seek_frame(avi->pFormatCtx, -1, off, AVSEEK_FLAG_BYTE);
	if (ret < 0) {
		Tcl_SetResult(interp, "Could not seek in " LIBNAME ".", TCL_VOLATILE);
		return TCL_ERROR;
	}
	//fprintf(stderr,"seek pos %lld\n", avi->pFormatCtx->pb->pos);
	avi->previous_offset = avi->pFormatCtx->pb->pos;
	return TCL_OK;
    
}

static int
avi_get_offset(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%"PRId64,avi->pFormatCtx->pb->pos);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

static int
avi_get_previous_offset(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%"PRId64,avi->previous_offset);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

static int
avi_close(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	p_avi_close(avi);
	free(avi);
	return TCL_OK;
}

static int
avi_status(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%d",avi->status);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}

static int
avi_count(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	int posmin, posmax,pos;
	int count=0;
	char s[100];

	Tcl_GetInt(interp,argv[2],&posmin);
	Tcl_GetInt(interp,argv[3],&posmax);
	av_seek_frame(avi->pFormatCtx, -1, posmin, AVSEEK_FLAG_BYTE);
	for(;;) {
	 pos=avi->pFormatCtx->pb->pos;
	 if(pos>posmax) break;
	 {
		while(av_read_frame(avi->pFormatCtx, &avi->packet)>=0) {
			 if(avi->packet.stream_index==avi->videoStream) {
                                 break;
			 }
		 }

		av_free_packet(&avi->packet);
	 }
	 count++;
	}
	sprintf(s,"%d",count);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}






// Renvoit le nombre total d'images de la video
static int
avi_get_nb_frames(struct aviprop * avi, Tcl_Interp *interp, int argc, char * argv[])
{
	char s[100];
	sprintf(s,"%"PRId64,avi->pFormatCtx->streams[avi->videoStream]->nb_frames);
	Tcl_SetResult(interp,s,TCL_VOLATILE);
	return TCL_OK;
}







static int
cmdAvi(ClientData cdata, Tcl_Interp *interp, int argc, char * argv[])
{
    struct aviprop * avi = (struct aviprop *)cdata;

    if (argc == 1) {
        return TCL_ERROR;
    }

    if( strcmp(argv[1], "load") == 0 ) {
        return avi_load(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "next") == 0) {
        return avi_next(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "seekpercent") == 0) {
        return avi_seek_percent(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "seekbyte") == 0) {
        return avi_seek_byte(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "seektoframe") == 0) {
        return avi_seekto_frame(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "getoffset") == 0) {
        return avi_get_offset(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "getpreviousoffset") == 0) {
        return avi_get_previous_offset(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "count") == 0) {
        return avi_count(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "get_nb_frames") == 0) {
        return avi_get_nb_frames(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "test") == 0) {
        return avi_test(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "close") == 0) {
        return avi_close(avi,interp,argc,argv);
    } else if (strcmp(argv[1], "status") == 0) {
        return avi_status(avi,interp,argc,argv);
    } else {
        return TCL_ERROR;
    }
}

static int
Avi_Create(ClientData cdata, Tcl_Interp *interp, int argc, const char * argv[])
{
    char s[1000];
    struct aviprop * avi;
    const char *color_mode_str = Tcl_GetVar(interp, "::avi::default_color_mode", 0);

    avi = calloc(1, sizeof(struct aviprop));
    avi->status = -1;
    avi->interp = interp;
    if(strcmp(color_mode_str, "gray")==0) {
        avi->pix_fmt_dest = PIX_FMT_GRAY8;
    } else {
        avi->pix_fmt_dest = PIX_FMT_RGB24;
    }

    Tcl_CreateCommand(interp, argv[1], (Tcl_CmdProc *) cmdAvi, (ClientData) avi, NULL);

    sprintf(s,"%d",argc);
    Tcl_SetResult(interp, s, TCL_VOLATILE);
    return TCL_OK;
}


int
Avi_Init(Tcl_Interp *interp)
{
    Tcl_Namespace *nsPtr;

    av_register_all();

    if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
        return TCL_ERROR;
    }
    nsPtr = Tcl_CreateNamespace(interp, "avi", NULL, NULL);
    if (nsPtr == NULL) {
        return TCL_ERROR;
    }

    /* changed this to check for an error - GPS */
    if (Tcl_PkgProvide(interp, "Avi", "1.0") == TCL_ERROR) {
        return TCL_ERROR;
    }

    Tcl_CreateCommand(interp, "::avi::create", Avi_Create, NULL, NULL);

    Tcl_CreateCommand(interp, "::avi::convert_shared_image", convert_shared_image, NULL, NULL);

    Tcl_SetVar(interp, "::avi::default_color_mode", "gray", 0);

    return TCL_OK;
}

/* camtcl.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2013 The AudeLA Core Team
 *
 * Initial author : Matteo SCHIAVON <ilmona89@gmail.com>
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

/*
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

#include "raptor.h"

//void AcqRead(ClientData clientData);
extern struct camini CAM_INI[];

/*
 *  Definition a structure specific for this driver 
 */

/**
	* cmdCamFrameRate
	* sets the frame rate capture
	*
*/
int cmdCamFrameRate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;
	double fr;

	cam = (struct camprop *) clientData;

	if (argc == 2) {
		if ( getFrameRate(&fr) == 0 ) {
			cam->frameRate=fr;
			sprintf(line,"%f",fr);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else if (argc == 3) {
		if (Tcl_GetDouble(interp,argv[2],&fr)==TCL_OK) {
			if ( cam_set_framerate(cam,fr) == 0 ) {
				sprintf(line,"%f",cam->frameRate);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_OK;
			} else {
				Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
				result = TCL_ERROR;
			}
		} else {
			sprintf(line,"Usage: %s %s ?frame rate?\n error frame rate=%s, must be double",argv[0],argv[1],argv[2]);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else {
		sprintf(line,"Usage: %s %s ?frame rate?", argv[0], argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamExposure
	* sets the exposure time
	*
*/
int cmdCamExposure(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;
	double exp;

	cam = (struct camprop *) clientData;

	if (argc == 2) {
		if ( getExposure(&exp) == 0 ) {
			cam->exptime=exp;
			sprintf(line,"%f",exp);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else if (argc == 3) {
		if (Tcl_GetDouble(interp,argv[2],&exp)==TCL_OK) {
			if ( cam_set_exposure(cam,exp) == 0 ) {
				sprintf(line,"%f",cam->exptime);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_OK;
			} else {
				Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
				result = TCL_ERROR;
			}
		} else {
			sprintf(line,"Usage: %s %s ?exptime?\n error exptime=%s, must be double",argv[0],argv[1],argv[2]);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else {
		sprintf(line,"Usage: %s %s ?exptime?", argv[0], argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamRoi
	* sets the ROI
	*
*/
int cmdCamRoi(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;
	int x1,y1,w,h,x2,y2;
	char **listArgv;
	int listArgc;

	cam = (struct camprop *) clientData;

	if (argc == 2) {
		if (( getROIxoffset(&x1) == 0 ) && ( getROIyoffset(&y1) == 0 ) && ( getROIxsize(&w) == 0 ) && ( getROIysize(&h) == 0 )) {
			cam->x1=x1;
			cam->y1=y1;
			cam->w=w;
			cam->h=h;
			x2=cam->x2=x1+w-1;
			y2=cam->y2=y1+h-1;
			sprintf(line,"%d %d %d %d",x1,y1,x2,y2);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else if (argc == 3) {
		if (Tcl_SplitList(interp,argv[2],&listArgc,&listArgv) != TCL_OK) {
			sprintf(line,"ROI structure not valid: must be {x1 y1 x2 y2}");
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		} else if (listArgc != 4) {
			sprintf(line,"ROI structure not valid: must be {x1 y1 x2 y2}");
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		} else {
			if ((Tcl_GetInt(interp,listArgv[0],&x1) != TCL_OK) || (y2<0)){
				sprintf(line,"Usage: %s %s {x1 y1 x2 y2}\nx1 : must be a positive integer",argv[0],argv[1]);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			} else if ((Tcl_GetInt(interp,listArgv[1],&y1) != TCL_OK) || (y1<0)) {
				sprintf(line,"Usage: %s %s {x1 y1 x2 y2}\ny1 : must be a positive integer",argv[0],argv[1]);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			} else if ((Tcl_GetInt(interp,listArgv[2],&x2) != TCL_OK) || (x2<x1)){
				sprintf(line,"Usage: %s %s {x1 y1 x2 y2}\nx2 : must be an integer > x1",argv[0],argv[1]);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			} else if ((Tcl_GetInt(interp,listArgv[3],&y2) != TCL_OK) || (y2<y1)) {
				sprintf(line,"Usage: %s %s {x1 y1 x2 y2}\ny2 : must be an integer > y1",argv[0],argv[1]);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			} else {
				if ( cam_set_roi(cam,x1,y1,x2,y2) == 0 ) {
					sprintf(line,"{%d %d %d %d}",cam->x1,cam->y1,cam->x2,cam->y2);
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_OK;
				} else {
					Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
					result = TCL_ERROR;
				}
			}
		}
		Tcl_Free((char *) listArgv);
	} else {
		sprintf(line,"Usage: %s %s ?{x1 y1 x2 y2}?", argv[0], argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamDynamicRange
	* sets the exposure time
	*
*/
int cmdCamDynamicRange(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;
	uchar dyn;
  double exp=0.;

	cam = (struct camprop *) clientData;

	if (argc == 2) {
		if ( getDynamicRange(&dyn) == 0 ) {
			if ( dyn==HIGH_DYNAMIC ) {
				sprintf(line,"dynamic range on");
				cam->dynamicRange=1;
			} else {
				sprintf(line,"dynamic range off");
				cam->dynamicRange=0;
			}
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else if (argc == 3) {
		if (strcmp(argv[2],"on")==0) {
			if ( cam_set_dynamic(cam,1) == 0 ) {
				sprintf(line,"dynamic range on");
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_OK;
			} else {
				Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
				result = TCL_ERROR;
			}
		} else if (strcmp(argv[2],"off")==0) {
			if ( cam_set_dynamic(cam,0) == 0 ) {
				sprintf(line,"dynamic range off");
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_OK;
			} else {
				Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
				result = TCL_ERROR;
			}
		} else {
			sprintf(line,"Usage: %s %s ?on|off?",argv[0],argv[1]);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else {
		sprintf(line,"Usage: %s %s ?on|off?", argv[0], argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

//load the image in frame buffer fb in the current camera buffer
int cmdCamGetFrameBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[512];
	int fb;
	struct camprop *cam;
	unsigned short *p;

	cam = (struct camprop *)clientData;

	//cam_get_maxfb(cam);
	
	if ( argc==3 ) {
		if ((Tcl_GetInt(interp,argv[2],&fb) != TCL_OK) || (fb<1) || (fb>cam->max_buf)) {
			sprintf(line, "Usage: %s %s ?fb?\nfb must be an integer between 1 and %d",argv[0],argv[1],cam->max_buf);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		} else {
			//w = cam->x2-cam->x1+1;
			//h = cam->y2-y1+1;
			p=(unsigned short *)calloc(cam->w*cam->h,sizeof(unsigned short));
			if ( cam_get_framebuffer(cam,fb,p)<0 ) {
				sprintf(line,cam->msg);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			}
			// reverse the pixels if the mirror is set
			if ( cam->mirrorh == 1 )
				cam->pixels_reverse_y = 1;
			if ( cam->mirrorv == 1 )
				cam->pixels_reverse_x = 1;

			sprintf(line, "buf%d setpixels %s %d %d %s %s %ld -pixels_size %lu -reverse_x %d -reverse_y %d",cam->bufno,cam->pixels_classe,cam->w,cam->h,cam->pixels_format,cam->pixels_compression, (long)(void *)p, cam->pixel_size, cam->pixels_reverse_x, cam->pixels_reverse_y);
			if (Tcl_Eval(interp, line) == TCL_ERROR) {
				sprintf(line,"Errors setpixels: %s",Tcl_GetStringResult(interp));
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			}
			free(p);
		}
	} else {
		sprintf(line, "Usage: %s %s ?fb?",argv[0],argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;

}


//write the image in the current camera buffer in the frame buffer fb
int cmdCamSetFrameBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[512];
	int fb;
	struct camprop *cam;
	unsigned short *p;
	float *pf;
	int i,j;

	cam = (struct camprop *)clientData;

	//cam_get_maxfb(cam);
	
	if ( argc==3 ) {
		if ((Tcl_GetInt(interp,argv[2],&fb) != TCL_OK) || (fb<1) || (fb>cam->max_buf)) {
			sprintf(line, "Usage: %s %s ?fb?\nfb must be an integer between 1 and %d",argv[0],argv[1],cam->max_buf);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		} else {
			//w = x2-x1+1;
			//h = y2-y1+1;
			pf=(float *)calloc(cam->w*cam->h,sizeof(float));
			p=(unsigned short *)calloc(cam->w*cam->h,sizeof(unsigned short));
			sprintf(line, "buf%d getpixels %ld",cam->bufno, (long)(void *)pf);
			if (Tcl_Eval(interp, line) == TCL_ERROR) {
				sprintf(line,"Errors getpixels: %s",Tcl_GetStringResult(interp));
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			}
			//transform float into unsigned short
			for (i=0;i<cam->h;i++) {
				for (j=0;j<cam->w;j++) {
					p[i*cam->w+j] = (unsigned short)pf[i*cam->w+j];
				}
			}
			if ( cam_set_framebuffer(cam,fb,p)<0 ) {
				sprintf(line,cam->msg);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			}
			free(p);
			free(pf);
		}
	} else {
		sprintf(line, "Usage: %s %s ?fb?",argv[0],argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;

}

//reset the camera
int cmdCamReset(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;

	if ( microReset() != 0 ) {
		Tcl_SetResult(interp,"Unable to reset the camera",TCL_VOLATILE);
		result = TCL_ERROR;
	}

}

/**
	* cmdCamDigitalGain
	* sets the digital gain
	*
*/
int cmdCamDigitalGain(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;
	int gain;

	cam = (struct camprop *) clientData;

	if (argc == 2) {
		if ( getGain(&gain) == 0 ) {
			cam->gain=gain;
			sprintf(line,"%d",gain);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else if (argc == 3) {
		if (Tcl_GetInt(interp,argv[2],&gain)==TCL_OK) {
			if ( cam_set_gain(cam,gain) == 0 ) {
				sprintf(line,"%d",cam->gain);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_OK;
			} else {
				Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
				result = TCL_ERROR;
			}
		} else {
			sprintf(line,"Usage: %s %s ?gain?\n error gain=%s, must be double",argv[0],argv[1],argv[2]);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else {
		sprintf(line,"Usage: %s %s ?gain?", argv[0], argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamVideoStart
	* start a video sequence
	*
*/
int cmdCamVideoStart(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	uchar mode;
	struct camprop *cam;

	cam = (struct camprop *) clientData;

	if ( cam_video_start(cam) == 0 ) {
		sprintf(line,"Started video from frame %d at %f fps",cam->cur_buf,cam->frameRate);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_OK;
	} else {
		Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamVideoStop
	* stop a video sequence
	*
*/
int cmdCamVideoStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;

	cam = (struct camprop *) clientData;

	if ( cam_video_pause(cam) == 0 ) {
		sprintf(line,"%d %d",cam_get_acquired(),cam_get_read());
		cam->cur_buf = 0;
    cam_set_zero();
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_OK;
	} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamVideoPause
	* pause a video sequence
	*
*/
int cmdCamVideoPause(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;

	cam = (struct camprop *) clientData;

	if ( cam_video_pause(cam) == 0 ) {
		sprintf(line,"%d %d",cam_get_acquired(),cam_get_read());
		cam->cur_buf = cam_get_curbuf();
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_OK;
	} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamVideoMode
	* sets the video mode (FFR or ITR)
	*
*/
int cmdCamVideoMode(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	uchar mode;
	struct camprop *cam;

	cam = (struct camprop *) clientData;

	if (argc == 2) {
		if ( cam->videoMode == 1 ) {
			sprintf(line,"Fixed Frame Rate");
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else if ( cam->videoMode == 0 ) {
			sprintf(line,"Integrate Then Read");
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_OK;
		} else {
			Tcl_SetResult(interp,"Unknow video mode",TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else if (argc == 3) {
		if ( strcmp(argv[2],"ffr") == 0) {
			if (cam->video) {
				if ( setTrigger(TRG_FFR|TRG_CONT) ) {
					cam->videoMode = 1;
					sprintf(line,"Free Frame Rate");
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_OK;
				} else {
					sprintf(line,"Unable to change video mode");
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_ERROR;
				}
			} else {
					cam->videoMode = 1;
					sprintf(line,"Free Frame Rate");
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_OK;
			}
		} else if ( strcmp(argv[2],"itr") == 0 ) {
			if (cam->video) {
				if ( setTrigger(TRG_CONT) ) {
					cam->videoMode = 0;
					sprintf(line,"Integrate Then Read");
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_OK;
				} else {
					sprintf(line,"Unable to change video mode");
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_ERROR;
				}
			} else {
					cam->videoMode = 0;
					sprintf(line,"Integrate Then Read");
					Tcl_SetResult(interp,line,TCL_VOLATILE);
					result = TCL_OK;
			}
		} else {
			sprintf(line,"Usage: %s %s ?ffr|itr?", argv[0], argv[1]);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		}
	} else {
		sprintf(line,"Usage: %s %s ?ffr|itr?", argv[0], argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

//get the frame buffer time stamp
int cmdCamGetBufferTs(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[512];
	int fb;
	struct camprop *cam;

	cam = (struct camprop *)clientData;

	cam_get_maxfb(cam);
	
	if ( argc==3 ) {
		if ((Tcl_GetInt(interp,argv[2],&fb) != TCL_OK) || (fb<1) || (fb>cam->max_buf)) {
			sprintf(line, "Usage: %s %s ?fb?\nfb must be an integer between 1 and %d",argv[0],argv[1],cam->max_buf);
			Tcl_SetResult(interp,line,TCL_VOLATILE);
			result = TCL_ERROR;
		} else {
			if ( cam_get_bufferts(cam,fb,line)<0 ) {
				sprintf(line,cam->msg);
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_ERROR;
			} else {
				Tcl_SetResult(interp,line,TCL_VOLATILE);
				result = TCL_OK;
			}
		}
	} else {
		sprintf(line, "Usage: %s %s ?fb?",argv[0],argv[1]);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;

}

//get the buffer where the next video image will be saved
//(a video lets it to zero until it is paused)
int cmdCamCurrentBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char line[512];
	struct camprop *cam;

	cam = (struct camprop *)clientData;

  sprintf(line,"%d",cam->cur_buf+1);
  Tcl_SetResult(interp,line,TCL_VOLATILE);

	return TCL_OK;

}

//get the buffer where the last image has been saved
int cmdCamLastBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char line[512];
	struct camprop *cam;

	cam = (struct camprop *)clientData;

  sprintf(line,"%d",cam_get_curbuf());
  Tcl_SetResult(interp,line,TCL_VOLATILE);

	return TCL_OK;

}

//get the maximum available frame buffer
int cmdCamMaxBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char line[512];
	struct camprop *cam;

	cam = (struct camprop *)clientData;

  sprintf(line,"%d",cam->max_buf);
  Tcl_SetResult(interp,line,TCL_VOLATILE);

	return TCL_OK;

}

//get the maximum settable framerate
int cmdCamMaxFrameRate(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char line[512];
	struct camprop *cam;

	cam = (struct camprop *)clientData;

  sprintf(line,"%f",cam->max_frameRate);
  Tcl_SetResult(interp,line,TCL_VOLATILE);

	return TCL_OK;

}

//get the maximum settable exposure
int cmdCamMaxExposure(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	char line[512];
	struct camprop *cam;

	cam = (struct camprop *)clientData;

  sprintf(line,"%f",cam->max_exposure);
  Tcl_SetResult(interp,line,TCL_VOLATILE);

	return TCL_OK;

}

/**
	* cmdCamLiveStart
	* start a live sequence (show video but does not save it nor timestamps)
	*
*/
int cmdCamLiveStart(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	uchar mode;
	struct camprop *cam;

	cam = (struct camprop *) clientData;

	if ( cam_live_start(cam) == 0 ) {
		sprintf(line,"Started live video at %f fps",cam->frameRate);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_OK;
	} else {
		Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamLiveStop
	* stop a live video
	*
*/
int cmdCamLiveStop(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;

	cam = (struct camprop *) clientData;

	if ( cam_video_pause(cam) == 0 ) {
		sprintf(line,"%d %d",cam_get_acquired(),cam_get_read());
		printf("%d",cam->cur_buf);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_OK;
	} else {
			Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
			result = TCL_ERROR;
	}

	return result;
}

/**
	* cmdCamPcbTemp
	* return the temperature of the PCB
	*
*/
int cmdCamPcbTemp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {

	int result = TCL_OK;
	char line[256];
	struct camprop *cam;
	double temp;

	cam = (struct camprop *) clientData;

	if ( getPCBtemp(&temp) == 0 ) {
		sprintf(line,"%f",temp);
		Tcl_SetResult(interp,line,TCL_VOLATILE);
		result = TCL_OK;
	} else {
		sprintf(cam->msg,"Unable to get PCB temperature");
		Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
		result = TCL_ERROR;
	}

	return result;
}


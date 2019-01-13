/* tkimgvideo.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Michel PUJOL 
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

// $Id: tkimgvideo.c,v 1.3 2008-04-27 15:13:48 michelpujol Exp $

/* 
 * usage (WINDOWS only) :
 *  
 * //declare a new image type called "video" in TCL interpreter
 * Tkimgvideo_Init(Tcl_Interp *interp)
 *   
 *
 * // create a video widget instance  "image1" 
 * image create video "image1"  
 * 
 * // add "image1" in a canvas
 * .audace;can.canvas1 itemconfigure display -image "image1"
 *
 * // plug "image" to a video source 
 * image1 configure -source $HwndCapture
 * 
 * // set the zoom = 2 
 * image1 configure -zoom 2.0
 * 
 * // set the zoom = 1/2 
 * image1 configure -zoom 0.5
 * 
 * 
 * //unplug the video source
 * image1 configure -source 0
 * 
 * //delete video widget
 * image delete "image1"
 * 
 * 
*/


#include <tcl.h>
#include <tk.h>

#ifdef __WIN32__

#include <windows.h>       // for HWND and SetParent()
Window Tk_AttachHWND(Tk_Window tkwin, HWND hwnd);
HWND Tk_GetHWND(Window window);

#endif

/*
 * Definition of the data associated with each photo image master.
 */

typedef struct VideoMaster {
    Tk_ImageMaster tkMaster;	/* Tk's token for image master.  NULL means
				 * the image is being deleted. */
    Tcl_Interp *interp;		/* Interpreter associated with the
				 * application using this image. */
    Tcl_Command imageCmd;	/* Token for image command (used to delete
				 * it when the image goes away).  NULL means
				 * the image command has already been
				 * deleted. */
    int	flags;			/* Sundry flags, defined below. */
    int	width, height;		/* Dimensions of image. */
    double zoom;
    int  hwndOwner;
    struct VideoInstance *instancePtr;	/* First in the list of instances
				                            * associated with this master. */
} VideoMaster;


/*
 * The following data structure represents all of the instances of
 * a photo image in windows on a given screen that are using the
 * same colormap.
 */

typedef struct VideoInstance {
    VideoMaster *masterPtr;	/* Pointer to master for image. */
    Display *display;		/* Display for windows using this instance. */
    Colormap colormap;		/* The image may only be used in windows with
				 * this particular colormap. */
    struct VideoInstance *nextPtr;
				/* Pointer to the next instance in the list
				 * of instances associated with this master. */
    int refCount;		/* Number of instances using this structure. */
    //int width, height;		/* Dimensions of the pixmap. */
    int imageX, imageY;       // window relative position 
    Tk_Window  tkParentWindow;
    Tk_Window  tkVideoWindow;
} VideoInstance;

/*
 * Functions used in the type record for photo images.
 */

static int		ImgVideoCreate _ANSI_ARGS_((Tcl_Interp *interp,
			    char *name, int objc, Tcl_Obj *CONST objv[],
			    Tk_ImageType *typePtr, Tk_ImageMaster master,
			    ClientData *clientDataPtr));
static ClientData	ImgVideoGet _ANSI_ARGS_((Tk_Window tkwin,
			    ClientData clientData));
static void		ImgVideoDisplay _ANSI_ARGS_((ClientData clientData,
			    Display *display, Drawable drawable,
			    int imageX, int imageY, int width, int height,
			    int drawableX, int drawableY));
static void		ImgVideoFree _ANSI_ARGS_((ClientData clientData,
			    Display *display));
static void		ImgVideoDelete _ANSI_ARGS_((ClientData clientData));
static int		ImgVideoPostscript _ANSI_ARGS_((ClientData clientData,
			    Tcl_Interp *interp, Tk_Window tkwin,
			    Tk_PostscriptInfo psInfo, int x, int y, int width,
			    int height, int prepass));

/*
 * The type record itself for photo images:
 */

Tk_ImageType tkVideoImageType = {
    "video",			   // name 
    ImgVideoCreate,		// createProc 
    ImgVideoGet,		   // getProc 
    ImgVideoDisplay,		// displayProc 
    ImgVideoFree,		   // freeProc 
    ImgVideoDelete,		// deleteProc 
    ImgVideoPostscript, // postscriptProc 
    (Tk_ImageType *) NULL	/* nextPtr */
};

/*
 * Default configuration
 */

#define DEF_VIDEO_HEIGHT	"0"
#define DEF_VIDEO_WIDTH		"0"
#define DEF_VIDEO_ZOOM     "1.0"

/*
 * Information used for parsing configuration specifications:
 */
static Tk_ConfigSpec configSpecs[] = {
    {TK_CONFIG_DOUBLE, "-zoom", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_ZOOM, Tk_Offset(VideoMaster, zoom), 0},

    {TK_CONFIG_INT, "-height", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_HEIGHT, Tk_Offset(VideoMaster, height), 0},
    
    {TK_CONFIG_INT, "-width", (char *) NULL, (char *) NULL,
	 DEF_VIDEO_WIDTH, Tk_Offset(VideoMaster, width), 0},
    
    {TK_CONFIG_END, (char *) NULL, (char *) NULL, (char *) NULL,
	 (char *) NULL, 0, 0}
};


/*
 * Implementation of the Porter-Duff Source-Over compositing rule.
 */

#define PD_SRC_OVER(srcColor,srcAlpha,dstColor,dstAlpha) \
	(srcColor*srcAlpha/255) + dstAlpha*(255-srcAlpha)/255*dstColor/255
#define PD_SRC_OVER_ALPHA(srcAlpha,dstAlpha) \
	(srcAlpha + (255-srcAlpha)*dstAlpha/255)

/*
 * loacal Forward declarations
 */

int	ImgPhotoCmd _ANSI_ARGS_((ClientData clientData,
			      Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]));
void	ImgPhotoCmdDeletedProc _ANSI_ARGS_((
			      ClientData clientData));
int	ImgVideoConfigureMaster _ANSI_ARGS_((
			      Tcl_Interp *interp, VideoMaster *masterPtr,
			      int objc, Tcl_Obj *CONST objv[], int flags));
void ImgVideoConfigureInstance _ANSI_ARGS_((
			      VideoInstance *instancePtr));
void	 DisposeInstance _ANSI_ARGS_((ClientData clientData));

void setZoom( VideoMaster *masterPtr, double zoom);
int getWidth ( VideoMaster *masterPtr);
int getHeight ( VideoMaster *masterPtr);

/*
 *----------------------------------------------------------------------
 *
 * tkimgvideo_Init
 *
 *	Point d'entree TCL de la librairies
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	declare le nouveau type d'image "video"
 *
 *----------------------------------------------------------------------
 */

int Tkimgvideo_Init(Tcl_Interp *interp)
{
   /*
   if(Tcl_InitStubs(interp,"8.4",0)==NULL) {
      Tcl_SetResult(interp,"Tcl Stubs initialization failed in libak.",TCL_STATIC);
      return TCL_ERROR;
   }
   Tcl_PkgProvide(interp,"tkimgvideo","1.1");
   */

   Tk_CreateImageType(&tkVideoImageType);

   return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgVideoCreate --
 *
 *	This procedure is called by the Tk image code to create
 *	a new photo image.
 *
 * Parameters : 
 *    interp         Interpreter for application containing image. 
 *    char *name;		Name to use for image.
 *    int objc;		Number of arguments.
 *    objv[]         Argument objects for options (doesn't include image name or type)
 *    typePtr;	      Pointer to our type record (not used)
 *    master;	      Token for image, to be used by us in later callbacks.
 *    clientDataPtr;	 Store manager's token for image here; it will be returned in later callbacks.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	The data structure for a new photo image is allocated and
 *	initialized.
 *
 *----------------------------------------------------------------------
 */

static int
ImgVideoCreate(Tcl_Interp *interp, char *name, int objc, Tcl_Obj *CONST objv[], 
               Tk_ImageType *typePtr, Tk_ImageMaster master, ClientData *clientDataPtr)
{
   VideoMaster *masterPtr;
   
   
   // Allocate and initialize the photo image master record.
   masterPtr = (VideoMaster *) ckalloc(sizeof(VideoMaster));
   memset((void *) masterPtr, 0, sizeof(VideoMaster));
   masterPtr->tkMaster = master;
   masterPtr->interp = interp;
   masterPtr->imageCmd = Tcl_CreateObjCommand(interp, name, ImgPhotoCmd, (ClientData) masterPtr, ImgPhotoCmdDeletedProc);
   masterPtr->hwndOwner = 0;

   // Process configuration options given in the image create command.
   if (ImgVideoConfigureMaster(interp, masterPtr, objc, objv, 0) != TCL_OK) {
      ImgVideoDelete((ClientData) masterPtr);
      return TCL_ERROR;
   }
   
   *clientDataPtr = (ClientData) masterPtr;
   return TCL_OK;
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoCmd --
 *
 *	This procedure is invoked to process the Tcl command that
 *	corresponds to a photo image.  See the user documentation
 *	for details on what it does.
 *
 * Results:
 *	A standard Tcl result.
 *
 * Side effects:
 *	See the user documentation.
 *
 *----------------------------------------------------------------------
 */

static int
ImgPhotoCmd(ClientData clientData, Tcl_Interp * interp, int objc, Tcl_Obj *CONST objv[])

{
   int oldformat = 0;
   static char *photoOptions[] = {
      "cget", "configure", (char *) NULL
   };
   enum options {
      VIDEO_CGET, VIDEO_CONFIGURE
   };
   
   VideoMaster *masterPtr = (VideoMaster *) clientData;
   int result, index;
   int length;

   if (objc < 2) {
      Tcl_WrongNumArgs(interp, 1, objv, "option ?arg arg ...?");
      return TCL_ERROR;
   }

   if (Tcl_GetIndexFromObj(interp, objv[1], photoOptions, "option", 0, &index) != TCL_OK) {
      return TCL_ERROR;
   }
   
   switch ((enum options) index) {
   case VIDEO_CGET: {
      char *arg;
      
      if (objc != 3) {
         Tcl_WrongNumArgs(interp, 2, objv, "option");
         return TCL_ERROR;
      }
      arg = Tcl_GetStringFromObj(objv[2], &length);
      if (strcmp(arg,"-owner") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->hwndOwner));
      } else if (strcmp(arg,"-zoom") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewDoubleObj(masterPtr->zoom));
      } else if (strcmp(arg,"-width") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->width));
      } else if (strcmp(arg,"-height") == 0) {
         Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->height));
      } else {
         Tk_ConfigureValue(interp, Tk_MainWindow(interp), configSpecs,
            (char *) masterPtr, Tcl_GetString(objv[2]), 0);
      }
      return TCL_OK;
                    }
      
   case VIDEO_CONFIGURE:      
      if (objc == 2) {
         result = Tk_ConfigureInfo(interp, Tk_MainWindow(interp),
            configSpecs, (char *) masterPtr, (char *) NULL, 0);
         if (result != TCL_OK) {
            return result;
         }
         // return option list values
         Tcl_SetObjResult(interp, Tcl_GetObjResult(interp));
         return TCL_OK;
      } else if (objc == 3) {
         char *arg = Tcl_GetStringFromObj(objv[2], &length);         
         if (!strcmp(arg, "-zoom")) {
            Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),"-zoom {} {} {}", (char *) NULL);
            Tcl_SetObjResult(interp, Tcl_NewDoubleObj(masterPtr->zoom));
            return TCL_OK;
         } else if (!strcmp(arg, "-width")) {
            Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),"-width {} {} {}", (char *) NULL);
            Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->width));
            return TCL_OK;
         } else if (!strcmp(arg, "-height")) {
            Tcl_AppendStringsToObj(Tcl_GetObjResult(interp),"-height {} {} {}", (char *) NULL);
            Tcl_SetObjResult(interp, Tcl_NewIntObj(masterPtr->height));
            return TCL_OK;
         } else {
            return Tk_ConfigureInfo(interp, Tk_MainWindow(interp),
               configSpecs, (char *) masterPtr, arg, 0);
         }
      } else {
         return ImgVideoConfigureMaster(interp, masterPtr, objc-2, objv+2,
            TK_CONFIG_ARGV_ONLY);
      }
   }
   panic("unexpected fallthrough");
   return TCL_ERROR; /* NOT REACHED */
}

/*
 *----------------------------------------------------------------------
 *
 * ImgVideoConfigureMaster --
 *
 *	This procedure is called when a photo image is created or
 *	reconfigured.  It processes configuration options and resets
 *	any instances of the image.
 *
 * Results:
 *	A standard Tcl return value.  If TCL_ERROR is returned then
 *	an error message is left in the masterPtr->interp's result.
 *
 * Side effects:
 *	Existing instances of the image will be redisplayed to match
 *	the new configuration options.
 *
 *----------------------------------------------------------------------
 */

static int
ImgVideoConfigureMaster(Tcl_Interp * interp, VideoMaster *masterPtr, int objc, Tcl_Obj *CONST objv[], int flags)
    
{
   int i, j;
   
   for (i = 0, j = 0; i < objc; i++,j++) {
      if (!strcmp(Tcl_GetString(objv[i]), "-zoom")) {
         if (++i < objc) {
            double zoom = 0;
            if (Tcl_GetDoubleFromObj(interp,objv[i],&zoom)!=TCL_OK) {
               Tcl_AppendResult(interp, "value for \"-zoom\" not double", (char *) NULL);
               return TCL_ERROR;
            } else {
               setZoom(masterPtr, zoom);
               Tk_ImageChanged(masterPtr->tkMaster, 0, 0, 0,
	                  0, masterPtr->width, masterPtr->height);
            }
         } else {
            Tcl_AppendResult(interp, "value for \"-zoom\" missing", (char *) NULL);
            return TCL_ERROR;
         }
      } 
   }
   
   return TCL_OK;   
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoConfigureInstance --
 *
 *	This procedure is called to create displaying information for
 *	a photo image instance based on the configuration information
 *	in the master.  It is invoked both when new instances are
 *	created and when the master is reconfigured.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Generates errors via Tcl_BackgroundError if there are problems
 *	in setting up the instance.
 *
 *----------------------------------------------------------------------
 */
 
static void ImgVideoConfigureInstance(VideoInstance *instancePtr)
{
   VideoMaster *masterPtr = instancePtr->masterPtr;   

   if ( instancePtr->tkParentWindow != 0 ) {
      
      if ( instancePtr->tkVideoWindow == 0 ) {
         //instancePtr->tkVideoWindow = Tk_CreateAnonymousWindow(masterPtr->interp, instancePtr->tkParentWindow, (char*) NULL);
         //instancePtr->tkVideoWindow = Tk_CreateWindow(masterPtr->interp, instancePtr->tkParentWindow, "video", (char*) NULL);
         //tkParentPathName= Tk_PathName(instancePtr->tkParentWindow);
         //sprintf(tkPathName,"%s.video",tkParentPathName);
         //instancePtr->tkVideoWindow = Tk_CreateWindowFromPath (masterPtr->interp, instancePtr->tkParentWindow, tkPathName, (char*) NULL);
         //Tk_MapWindow(instancePtr->tkVideoWindow);
      }

#ifdef __WIN32__
      // je supprime la fenetre Windows cree par defaut 
      //DestroyWindow( (HWND) Tk_GetHWND(Tk_WindowId(instancePtr->tkVideoWindow)));
      // j'attache la hwnd a la tk_window
      //videoWindow= Tk_AttachHWND(instancePtr->tkVideoWindow,(HWND) masterPtr->source);
      // j'affecte la Window du canvas comme parent 
      //masterPtr->previousParentSource = (int) SetParent((HWND) masterPtr->source, (HWND) Tk_GetHWND(Tk_WindowId(Tk_Parent(instancePtr->tkVideoWindow))));
      //masterPtr->hwndOwner = (int) Tk_GetHWND(Tk_WindowId(Tk_Parent(instancePtr->tkVideoWindow)));
      masterPtr->hwndOwner = (int) Tk_GetHWND(Tk_WindowId(instancePtr->tkParentWindow));
      
#endif

   }

}


/*
*----------------------------------------------------------------------
*
* ImgVideoGet --
*
*	This procedure is called for each use of a photo image in a
*	widget.
*
* Parameters :
*    tkwin;		Window in which the instance will be used. 
*    masterData;	 Pointer to our master structure for the image.
*
* Results:
*	The return value is a token for the instance, which is passed
*	back to us in calls to ImgVideoDisplay and ImgVideoFree.
*
* Side effects:
*	A data structure is set up for the instance (or, an existing
*	instance is re-used for the new one).
*
*----------------------------------------------------------------------
*/

static ClientData ImgVideoGet(Tk_Window tkwin, ClientData masterData)
{
   VideoMaster *masterPtr = (VideoMaster *) masterData;
   VideoInstance *instancePtr;
   Display *tkWinDisplay;


   
   // See if there is already an instance for windows using
   // the same source.  If so then just re-use it.
   for (instancePtr = masterPtr->instancePtr; instancePtr != NULL; instancePtr = instancePtr->nextPtr) {
      tkWinDisplay = Tk_Display(tkwin);
      if (tkWinDisplay == instancePtr->display) {
         // Re-use this instance.
         if (instancePtr->refCount == 0) {
            //  We are resurrecting this instance.            
            Tcl_CancelIdleCall(DisposeInstance, (ClientData) instancePtr);
            instancePtr->refCount++;
            return (ClientData) instancePtr;
         } else {
            return (ClientData) instancePtr;
         }
      }
   }
   
   // Make a new instance of the video.
   instancePtr = (VideoInstance *) ckalloc(sizeof(VideoInstance));
   instancePtr->masterPtr = masterPtr;
   instancePtr->display = Tk_Display(tkwin);
   instancePtr->tkParentWindow = tkwin;
   instancePtr->tkVideoWindow = 0;
   instancePtr->refCount = 1;
   instancePtr->imageX = 0;
   instancePtr->imageY = 0;
   
   instancePtr->nextPtr = masterPtr->instancePtr;
   masterPtr->instancePtr = instancePtr;

   ImgVideoConfigureInstance(instancePtr);
        
   return (ClientData) instancePtr ; // for calls to ImgVideoDisplay and ImgVideoFree 
}


/*
 *----------------------------------------------------------------------
 *
 * ImgVideoDisplay --
 *
 *	This procedure is invoked to draw a photo image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A portion of the image gets rendered in a pixmap or window.
 *
 *----------------------------------------------------------------------
 */

static void
ImgVideoDisplay(ClientData clientData, Display *display, Drawable drawable, int imageX, int imageY, int width,
	int height, int drawableX, int drawableY)
{
   //VideoInstance *instancePtr = (VideoInstance *) clientData;


}


/*
 *----------------------------------------------------------------------
 *
 * ImgVideoFree --
 *
 *	This procedure is called when a widget ceases to use a
 *	particular instance of an image.  We don't actually get
 *	rid of the instance until later because we may be about
 *	to get this instance again.
 *
 *  parameters :
 *      clientData  Pointer to VideoInstance structure for for instance to be displayed. 
 *	 	  display      Display containing window that used image. 
 * Results:
 *	None.
 *
 * Side effects:
 *	Internal data structures get cleaned up, later.
 *
 *----------------------------------------------------------------------
 */

static void
ImgVideoFree(ClientData clientData, Display *display)
{
   VideoInstance *instancePtr = (VideoInstance *) clientData;
   
   instancePtr->refCount -= 1;
   if (instancePtr->refCount > 0) {
      return;
   }
   
   Tcl_DoWhenIdle(DisposeInstance, (ClientData) instancePtr);

}

/*
 *----------------------------------------------------------------------
 *
 * ImgVideoDelete --
 *
 *	This procedure is called by the image code to delete the
 *	master structure for an image.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Resources associated with the image get freed.
 *
 *----------------------------------------------------------------------
 */

static void ImgVideoDelete(ClientData masterData)
{
   VideoMaster *masterPtr = (VideoMaster *) masterData;
   VideoInstance *instancePtr;

   while ((instancePtr = masterPtr->instancePtr) != NULL) {
      if (instancePtr->refCount > 0) {
         panic("tried to delete photo image when instances still exist");
      }
      Tcl_CancelIdleCall(DisposeInstance, (ClientData) instancePtr);
      DisposeInstance((ClientData) instancePtr);
   }

   masterPtr->tkMaster = NULL;
   if (masterPtr->imageCmd != NULL) {
      Tcl_DeleteCommandFromToken(masterPtr->interp, masterPtr->imageCmd);
   }

   ckfree((char *) masterPtr);
}

/*
 *----------------------------------------------------------------------
 *
 * ImgPhotoCmdDeletedProc --
 *
 *	This procedure is invoked when the image command for an image
 *	is deleted.  It deletes the image.
 *
 * Parameters : 
 *    clientData Pointer to VideoMaster structure for image
 * Results:
 *	None.
 *
 * Side effects:
 *	The image is deleted.
 *
 *----------------------------------------------------------------------
 */

static void
ImgPhotoCmdDeletedProc(ClientData clientData)
{
   VideoMaster *masterPtr = (VideoMaster *) clientData;
    
   masterPtr->imageCmd = NULL;
}

/*
 *----------------------------------------------------------------------
 *
 * DisposeInstance --
 *
 *	This procedure is called to finally free up an instance
 *	of a photo image which is no longer required.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The instance data structure and the resources it references
 *	are freed.
 *
 *----------------------------------------------------------------------
 */

static void DisposeInstance(ClientData clientData)
{
   VideoInstance *instancePtr = (VideoInstance *) clientData;

   if (instancePtr->tkVideoWindow != NULL) {
      //Tk_UnmapWindow(instancePtr->tkVideoWindow);
      Tk_DestroyWindow(instancePtr->tkVideoWindow);
      instancePtr->tkVideoWindow = NULL;
   }
   
   
   if (instancePtr->masterPtr->instancePtr == instancePtr) {
      instancePtr->masterPtr->instancePtr = instancePtr->nextPtr;
   } else {
      VideoInstance *prevPtr;
      for (prevPtr = instancePtr->masterPtr->instancePtr;
         prevPtr->nextPtr != instancePtr; prevPtr = prevPtr->nextPtr) {
         /* Empty loop body */
      }
      prevPtr->nextPtr = instancePtr->nextPtr;
   }


   ckfree((char *) instancePtr);
}

 
/*
 *--------------------------------------------------------------
 *
 * TkPostscriptPhoto --
 *
 *	This procedure is called to output the contents of a
 *	photo image in Postscript by calling the Tk_PostscriptPhoto
 *	function.
 *
 * Results:
 *	Returns a standard Tcl return value.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */
static int
ImgVideoPostscript(ClientData clientData, Tcl_Interp *interp, Tk_Window tkwin, Tk_PostscriptInfo psInfo,
        int x, int y, int width, int height, int prepass)
{
    return TCL_ERROR;
}




/*
 *--------------------------------------------------------------
 *
 * setZoom (WIN32 only)
 *
 *	This procedure sets the zoom 
 *
 * Results:
 *	Returns a standard Tcl return value.
 *
 * Side effects:
 *	None.
 *
 *--------------------------------------------------------------
 */
void setZoom( VideoMaster *masterPtr, double zoom ) {
#ifdef WIN32

   masterPtr->zoom = zoom;   
   if ( masterPtr->hwndOwner != 0) {      
      //SendMessage((HWND) masterPtr->hwndOwner,WM_USER+1,0, MAKELONG(masterPtr->width, masterPtr->height));
      if ( zoom >= 1.0 ) {
         SendMessage((HWND) masterPtr->hwndOwner,WM_USER+1,0, MAKELONG((WORD)zoom, 1));
      } else {
         SendMessage((HWND) masterPtr->hwndOwner,WM_USER+1,0, MAKELONG((WORD)1.0/zoom, 0));
      }
   }
#endif   
}




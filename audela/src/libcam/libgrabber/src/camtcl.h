/** @file camtcl.h
 *
 * Functions C-Tcl specifics for this camera.
 *
 * Fonctions C-Tcl specifiques a cette camera. A programmer.
 *
 */

#ifndef __CAMTCL_H__
#define __CAMTCL_H__

#include <tcl.h>

#define COMMON_FUNCS \
   {"videoformat",          (Tcl_CmdProc *)cmdCamVideoFormat}, \
   {"longuepose",           (Tcl_CmdProc *)cmdCamLonguePose}, \
   {"longueposelinkno",     (Tcl_CmdProc *)cmdCamLonguePoseLinkno}, \
   {"convertbw",            (Tcl_CmdProc *)cmdCamConvertbw}, \

#if defined(OS_WIN)
#define OS_SPECIFIC_FUNCS \
   {"connect",                   (Tcl_CmdProc *)cmdCamConnect}, \
   {"widget",                    (Tcl_CmdProc *)cmdCamWidget}, \
   {"videosource",               (Tcl_CmdProc *)cmdCamVideoSource}, \
   {"startvideoview",            (Tcl_CmdProc *)cmdCamStartVideoView}, \
   {"stopvideoview",             (Tcl_CmdProc *)cmdCamStopVideoView}, \
   {"startvideocapture",         (Tcl_CmdProc *)cmdCamStartVideoCapture}, \
   {"stopvideocapture",          (Tcl_CmdProc *)cmdCamStopVideoCapture}, \
   {"setvideostatusvariable",    (Tcl_CmdProc *)cmdCamSetVideoSatusVariable}, \
   {"startvideocrop",            (Tcl_CmdProc *)cmdCamStartVideoCrop}, \
   {"stopvideocrop",             (Tcl_CmdProc *)cmdCamStopVideoCrop}, \
   {"setvideocroprect",          (Tcl_CmdProc *)cmdCamSetVideoCropRect},
#endif

#if defined(OS_LIN)
#define OS_SPECIFIC_FUNCS \
   {"framerate",      (Tcl_CmdProc *)cmdCamFrameRate}, \
   {"validframe",     (Tcl_CmdProc *)cmdCamValidFrame}, \
   {"getvideoparameter", (Tcl_CmdProc *)cmdCamGetVideoParameter}, \
   {"setvideoparameter", (Tcl_CmdProc *)cmdCamSetVideoParameter},
#endif


#define SPECIFIC_CMDLIST \
   COMMON_FUNCS \
   OS_SPECIFIC_FUNCS

#ifdef __cplusplus
extern "C" {			/* Assume C declarations for C++ */
#endif				/* __cplusplus */

    /* === Specific commands for that camera === */
	 int cmdCamConvertbw(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamConnect(ClientData clientData, Tcl_Interp * interp, int argc,char *argv[]);
    int cmdCamWidget(ClientData clientData, Tcl_Interp * interp, int argc, Tcl_Obj *CONST objv[]);
    int cmdCamVideoFormat(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePose(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamLonguePoseLinkno(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
#if defined(OS_LIN)
    int cmdCamFrameRate(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamValidFrame(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamGetVideoParameter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoParameter(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
#endif

/******************************************************************/
/*  Commandes utilisees pour la capture video WINDOWS (M. Pujol)          */
/*  Pour Windows uniquement                                       */
/******************************************************************/
#if defined(OS_WIN)
    int cmdCamVideoSource(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStartVideoView(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoView(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStartVideoCapture(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoCapture(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoSatusVariable(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStartVideoCrop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamStopVideoCrop(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
    int cmdCamSetVideoCropRect(ClientData clientData, Tcl_Interp * interp, int argc, char *argv[]);
#endif	//defined(OS_WIN)


#ifdef __cplusplus
}				/* End of extern "C" { */
#endif				/* __cplusplus */
#endif

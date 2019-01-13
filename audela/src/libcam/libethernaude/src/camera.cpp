/* camera.c
 *
 * Copyright (C) 2002-2004 Michel MEUNIER <michel.meunier@tiscali.fr>
 *
 * Mettre ici le texte de la license.
 *
 */

#include "sysexp.h"

#if defined(OS_WIN)
#include <windows.h>
#endif

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdio.h>

#include "camera.h"
#include <libcam/util.h>


//#define ETH_DEBUGFILE 1

#if defined ETH_DEBUGFILE
#define LOG_ETHDEBUGFILE(s) {FILE *f; f = fopen("ethernaude2.txt", "at"); fprintf(f, s); fclose(f);}
#else
#define LOG_ETHDEBUGFILE(s)
#endif

/*
 *  Definition of different cameras supported by this driver
 *  (see declaration in libstruc.h)
 */

struct camini CAM_INI[] = {
   {"Audine",		/* camera name */
   "audine",		/* camera product */
   "kaf401",			/* ccd name */
   768, 512,			/* maxx maxy */
   14, 14,			/* overscans x */
   4, 4,			/* overscans y */
   9e-6, 9e-6,		/* photosite dim (m) */
   32767.,			/* observed saturation */
   1.,			/* filling factor */
   11.,			/* gain (e/adu) */
   11.,			/* readnoise (e) */
   1, 1,			/* default bin x,y */
   1.,			/* default exptime */
   1,				/* default state of shutter (1=synchro) */
   0,				/* default port index (0=lpt1) */
   1,				/* default cooler index (1=on) */
   -15.,			/* default value for temperature checked */
   1,				/* default color mask if exists (1=cfa) */
   0,				/* default overscan taken in acquisition (0=no) */
   1.				/* default focal lenght of front optic system */
   },
   CAM_INI_NULL
};

static void AskForExecuteCCDCommand_Dump(TParamCCD * ParamCCDIn, TParamCCD * ParamCCDOut)
{
   int k;
   char result[MAXLENGTH];

   util_log("", 1);
   for (k = 0; k < ParamCCDIn->NbreParam; k++) {
      paramCCD_get(k, result, ParamCCDIn);
      util_log(result, 0);
   }
   AskForExecuteCCDCommand(ParamCCDIn, ParamCCDOut);
   util_log("", 2);
   for (k = 0; k < ParamCCDOut->NbreParam; k++) {
      paramCCD_get(k, result, ParamCCDOut);
      util_log(result, 0);
   }
   util_log("\n", 0);
}

static int cam_init(struct camprop *cam, int argc, const char **argv);
static int cam_close(struct camprop *cam);
static void cam_start_exp(struct camprop *cam, const char *amplionoff);
static void cam_stop_exp(struct camprop *cam);
static void cam_read_ccd(struct camprop *cam, float *p);
static void cam_shutter_on(struct camprop *cam);
static void cam_shutter_off(struct camprop *cam);
//static void cam_ampli_on(struct camprop *cam);
//static void cam_ampli_off(struct camprop *cam);
static void cam_measure_temperature(struct camprop *cam);
static void cam_cooler_on(struct camprop *cam);
static void cam_cooler_off(struct camprop *cam);
static void cam_cooler_check(struct camprop *cam);
static void cam_set_binning(int binx, int biny, struct camprop *cam);
static void cam_update_window(struct camprop *cam);

struct cam_drv_t CAM_DRV = {
   cam_init,			/* init */
   cam_close,			/* close */
   cam_set_binning,		/* set_binning */
   cam_update_window,		/* update_window */
   cam_start_exp,		/* start_exp */
   cam_stop_exp,		/* stop_exp */
   cam_read_ccd,		/* read_ccd */
   cam_shutter_on,		/* shutter_on */
   cam_shutter_off,		/* shutter_off */
   NULL,			/* ampli_on */
   NULL,			/* ampli_off */
   cam_measure_temperature,	/* measure_temperature */
   cam_cooler_on,		/* cooler_on */
   cam_cooler_off,		/* cooler_off */
   cam_cooler_check		/* cooler_check */
};

ETHERNAUDE_DIRECTCALL *ETHERNAUDE_DIRECTMAIN;

/* ========================================================= */
/* ========================================================= */
/* ===     Macro fonctions de pilotage de la camera      === */
/* ========================================================= */
/* ========================================================= */
/* Ces fonctions relativement communes a chaque camera.      */
/* et sont appelees par libcam.c                             */
/* Il faut donc, au moins laisser ces fonctions vides.       */
/* ========================================================= */

int cam_init(struct camprop *cam, int argc, const char **argv)
/* --------------------------------------------------------- */
/* --- cam_init permet d'initialiser les variables de la --- */
/* --- structure 'camprop'                               --- */
/* --- specifiques a cette camera.                       --- */
/* --------------------------------------------------------- */
/* --------------------------------------------------------- */
{
   int errnum;
   struct new_ethernaude_inp inparams;
   unsigned short ip[4];
   char ipstring[50];
   int k, kk, kdeb, nbp, klen;
#if defined OS_WIN
   HWND hwnd;
   int r;
   char exe_file[1000];
#endif
   char cmdline[1000];

   /* on n'utilise pas les fonctions du port // pour ce driver */
   cam->authorized = 1;

   /* --- Decode les options de cam::create en fonction de argv[>=3] --- */
   ip[0] = 192;
   ip[1] = 168;
   ip[2] = 123;
   ip[3] = 123;
   strcpy(ipstring, "");
   cam->ipsetting = 0;
   cam->canspeed = 4;
   cam->shuttertypeindex = 0;
   cam->shutteraudinereverse = 0;
   strcpy(cam->ipsetting_filename, "IPSetting.exe");
   ethernaude_debug = 0;
   if (argc >= 1) {
      for (kk = 0; kk < argc; kk++) {
         if (strcmp(argv[kk], "-ip") == 0) {
            if ((kk + 1) <= (argc - 1)) {
               strcpy(ipstring, argv[kk + 1]);
            }
         }
         if (strcmp(argv[kk], "-ipsetting") == 0) {
            cam->ipsetting = 1;
            if ((kk + 1) <= (argc - 1)) {
               strcpy(cam->ipsetting_filename, argv[kk + 1]);
            }
         }
         if (strcmp(argv[kk], "-shutterinvert") == 0) {
            if ((kk + 1) <= (argc - 1)) {
               cam->shutteraudinereverse = atoi(argv[kk + 1]);
            }
         }
         if (strcmp(argv[kk], "-canspeed") == 0) {
            if ((kk + 1) <= (argc - 1)) {
               cam->canspeed = atoi(argv[kk + 1]);
            }
         }
         if (strcmp(argv[kk], "-debug_eth") == 0) {
            ethernaude_debug = 1;
         }
      }
   }
   klen = (int) strlen(ipstring);
   nbp = 0;
   for (k = 0; k < klen; k++) {
      if (ipstring[k] == '.') {
         nbp++;
      }
   }
   if (nbp == 3) {
      kdeb = 0;
      nbp = 0;
      for (k = 0; k <= klen; k++) {
         if ((ipstring[k] == '.') || (ipstring[k] == '\0')) {
            ipstring[k] = '\0';
            ip[nbp] = (unsigned short) (unsigned char) atoi(ipstring + kdeb);
            kdeb = k + 1;
            nbp++;
         }
      }
   }

   cam->direct = 0;

   /* --- set the IP config to ethernaude --- */
   sprintf(cam->ip, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
#if defined OS_WIN
   if (cam->ipsetting == 1) {
      hwnd = GetDesktopWindow();
      strcpy(exe_file, cam->ipsetting_filename);
      sprintf(cmdline, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
      r = (int) ShellExecute(hwnd, "open", exe_file, cmdline, NULL, SW_HIDE);
      Sleep(200);
   }
#endif

   /* --- open and initialize the ethernaude --- */
   /* --- driver cam::create ethernaude udp -ip 192.168.123.123 --- */
   inparams.ip[0] = ip[0];
   inparams.ip[1] = ip[1];
   inparams.ip[2] = ip[2];
   inparams.ip[3] = ip[3];
   inparams.shutterinvert = cam->shutteraudinereverse;
   inparams.canspeed = cam->canspeed;
   errnum = new_ethernaude(&inparams, &(cam->ethvar));
   if (errnum != 0) {
      strcpy(cam->msg, cam->ethvar.message);
      return errnum;
   }
   if (cam->direct == 1) {
      /* should import direct function */
      if (direct_driver() != 0) {
         cam->direct = 0;
      }
   }

   /* === conversion des parametres Ethernaude -> AudeLA CAM_INI === */
   if (strcmp(cam->ethvar.SystemName,"Ethernaude")==0) strcpy(cam->ethvar.SystemName,"Audine");
   strcpy(CAM_INI[cam->index_cam].name, cam->ethvar.SystemName);
   strcpy(CAM_INI[cam->index_cam].ccd, cam->ethvar.InfoCCD_NAME);
   CAM_INI[cam->index_cam].maxx = cam->ethvar.WidthPixels;
   CAM_INI[cam->index_cam].maxy = cam->ethvar.HeightPixels;
   /* bug actuellement */
   CAM_INI[cam->index_cam].overscanxbeg = cam->ethvar.PixelsPrescanX;
   CAM_INI[cam->index_cam].overscanxend = cam->ethvar.PixelsOverscanX;
   CAM_INI[cam->index_cam].overscanybeg = cam->ethvar.PixelsPrescanY;
   CAM_INI[cam->index_cam].overscanyend = cam->ethvar.PixelsOverscanY;
   CAM_INI[cam->index_cam].celldimx = ((double) (cam->ethvar.InfoCCD_PixelsSizeX)) / 1000000000.;
   CAM_INI[cam->index_cam].celldimy = ((double) (cam->ethvar.InfoCCD_PixelsSizeY)) / 1000000000.;
   CAM_INI[cam->index_cam].maxconvert = pow(2, (double) cam->ethvar.BitPerPixels) - 1.;

   /* === intialisation des elements de la structure cam === */
   cam->inparams = inparams;
   cam->nb_photox = CAM_INI[cam->index_cam].maxx;	/* nombre de photosites sur X */
   cam->nb_photoy = CAM_INI[cam->index_cam].maxy;	/* nombre de photosites sur Y */
   if (cam->overscanindex == 0) {
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = CAM_INI[cam->index_cam].overscanxbeg;
      cam->nb_deadendphotox = CAM_INI[cam->index_cam].overscanxend;
      cam->nb_deadbeginphotoy = CAM_INI[cam->index_cam].overscanybeg;
      cam->nb_deadendphotoy = CAM_INI[cam->index_cam].overscanyend;
   } else {
      cam->nb_photox += (CAM_INI[cam->index_cam].overscanxbeg + CAM_INI[cam->index_cam].overscanxend);
      cam->nb_photoy += (CAM_INI[cam->index_cam].overscanybeg + CAM_INI[cam->index_cam].overscanyend);
      /* nb photosites masques autour du CCD */
      cam->nb_deadbeginphotox = 0;
      cam->nb_deadendphotox = 0;
      cam->nb_deadbeginphotoy = 0;
      cam->nb_deadendphotoy = 0;
   }
   cam->celldimx = CAM_INI[cam->index_cam].celldimx;	/* taille d'un photosite sur X (en metre) */
   cam->celldimy = CAM_INI[cam->index_cam].celldimy;	/* taille d'un photosite sur Y (en metre) */
   cam->x2 = cam->ethvar.WidthPixels - 1;
   cam->y2 = cam->ethvar.HeightPixels - 1;

   cam_update_window(cam);	/* met a jour x1,y1,x2,y2,h,w dans cam */
   cam->CCDStatus = 1;		/* effectue la commande CCDStatus a la prochaine cam_read_ccd */

   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.message[256]='%s'",		     cam->ethvar.message); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.Camera_ID=%d",		     cam->ethvar.Camera_ID); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.NbreParamSetup=%d",		     cam->ethvar.NbreParamSetup); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.CCDDrivenAmount=%d",		     cam->ethvar.CCDDrivenAmount); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.SystemName[50]='%s'",	     cam->ethvar.SystemName); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_NAME[50]='%s'",	     cam->ethvar.InfoCCD_NAME); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_ClockModes=%d",	     cam->ethvar.InfoCCD_ClockModes); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.WidthPixels=%d",		     cam->ethvar.WidthPixels); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.HeightPixels=%d",		     cam->ethvar.HeightPixels); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.PixelsPrescanX=%d",		     cam->ethvar.PixelsPrescanX); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.PixelsPrescanY=%d",		     cam->ethvar.PixelsPrescanY); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.PixelsOverscanX=%d",		     cam->ethvar.PixelsOverscanX); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.PixelsOverscanY=%d",		     cam->ethvar.PixelsOverscanY); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_MaxExposureTime=%d",	     cam->ethvar.InfoCCD_MaxExposureTime); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_PixelsSizeX=%d",	     cam->ethvar.InfoCCD_PixelsSizeX); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_PixelsSizeY=%d",	     cam->ethvar.InfoCCD_PixelsSizeY); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_IsGuidingCCD=%d",	     cam->ethvar.InfoCCD_IsGuidingCCD); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_HasTDICaps=%d",	     cam->ethvar.InfoCCD_HasTDICaps); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_HasVideoCaps=%d",	     cam->ethvar.InfoCCD_HasVideoCaps); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_HasRegulationTempCaps=%d",cam->ethvar.InfoCCD_HasRegulationTempCaps); util_log(cmdline, 0);
   sprintf(cmdline, "<LIBETHERNAUDE/cam_init> cam->ethvar.InfoCCD_HasGPSDatation=%d",	     cam->ethvar.InfoCCD_HasGPSDatation); util_log(cmdline, 0);

   return 0;
}

int cam_close(struct camprop *cam)
{
   /* --- close the ethernaude driver --- */
   delete_ethernaude();
   return 0;
}

void cam_start_exp(struct camprop *cam, const char *amplionoff)
{
   int exptime = 0;
   int binx, biny, x1, x2, y1, y2;
   char ligne[MAXLENGTH];
   char result[MAXLENGTH];
   int sortie, failed;
   FILE *fwipe;
#if defined ETH_DEBUGFILE
   FILE *f;
#endif
   strcpy(cam->msg, "");
   if (cam->authorized == 1) {
      cam->exptime_when_acq_stopped = -1.0f;
      sortie = 0;
      while (sortie == 0) {
         failed = 0;
         exptime = (int) (cam->exptime * 1000.);	/* en ms */
         binx = cam->binx;
         biny = cam->biny;

         x1 = cam->x1 + 1;
         x2 = cam->x2 + 1;
         sprintf(ligne,"<LIBETHERNAUDE/cam_start_exp:%d> cam->mirrorv=%d",__LINE__,cam->mirrorv); util_log(ligne,0);
         sprintf(ligne,"<LIBETHERNAUDE/cam_start_exp:%d>   x1=%d, x2=%d",__LINE__,x1,x2); util_log(ligne,0);
         if (cam->mirrorv == 0) {
            // La lecture avec ethernaude est inversee par rapport a
            // l'audine, donc on teste mirroirv a 0.
            int tmp;
            x1 = cam->nb_deadbeginphotox + cam->nb_photox - ( x1 - 1 );
            tmp = cam->nb_deadbeginphotox + cam->nb_photox - ( x2 - 1 );
            x2 = x1;
            x1 = tmp;
         } else {
            x1 = cam->nb_deadbeginphotox + x1;
            x2 = cam->nb_deadbeginphotox + x2;
         }
         sprintf(ligne,"<LIBETHERNAUDE/cam_start_exp:%d>   -> x1=%d, x2=%d",__LINE__,x1,x2); util_log(ligne,0);

         y1 = cam->y1 + 1;
         y2 = cam->y2 + 1;
         sprintf(ligne,"<LIBETHERNAUDE/cam_start_exp:%d> cam->mirrorh=%d",__LINE__,cam->mirrorh); util_log(ligne,0);
         sprintf(ligne,"<LIBETHERNAUDE/cam_start_exp:%d>   y1=%d, y2=%d",__LINE__,y1,y2); util_log(ligne,0);
         if (cam->mirrorh == 1) {
            int tmp;
            y1 = cam->nb_deadbeginphotoy + cam->nb_photoy - ( y1 - 1);
            tmp = cam->nb_deadbeginphotoy + cam->nb_photoy - ( y2 - 1);
            y2 = y1;
            y1 = tmp;
         } else {
            y1 = cam->nb_deadbeginphotoy + y1;
            y2 = cam->nb_deadbeginphotoy + y2;
         }
         sprintf(ligne,"<LIBETHERNAUDE/cam_start_exp:%d>   -> y1=%d, y2=%d",__LINE__,y1,y2); util_log(ligne,0);
         /* - ajouter la verif pour depassement */
         /* - InitExposure sur le CCD numero 1 clock mode 1- */
         paramCCD_clearall(&ParamCCDIn, 1);
         paramCCD_put(-1, "InitExposure", &ParamCCDIn, 1);
         paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
         paramCCD_put(-1, "ClockMode=1", &ParamCCDIn, 1);
         sprintf(ligne, "Exposure=%d", exptime);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         sprintf(ligne, "X1=%d", x1);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         sprintf(ligne, "X2=%d", x2);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         sprintf(ligne, "Y1=%d", y1);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         sprintf(ligne, "Y2=%d", y2);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         sprintf(ligne, "BinningX=%d", binx);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         sprintf(ligne, "BinningY=%d", biny);
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         if (cam->shutterindex == 0) {
            strcpy(ligne, "ShutterOpen=0");
         } else {
            strcpy(ligne, "ShutterOpen=1");
         }
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
         if (ParamCCDOut.NbreParam >= 1) {
            paramCCD_get(0, result, &ParamCCDOut);
            strcpy(cam->msg, "");
            if (strcmp(result, "FAILED") == 0) {
               failed = 1;
               paramCCD_get(1, result, &ParamCCDOut);
               sprintf(cam->msg, "InitExposure Failed\n%s", result);
            }
         }
#if defined ETH_DEBUGFILE
         f = fopen("ethernaude2.txt", "at");
         fprintf(f, "START_EXP : <%s>\n", cam->msg);
         fclose(f);
#endif
         if (failed == 0) {
            /* --- normal state --- */
            sortie = 1;
         } else {
            /* --- case when wipe failed. Why ? --- */
            if ((fwipe = fopen("ethbug.txt", "at")) != NULL) {
               sprintf(ligne, "mc_date2iso8601 now");
               Tcl_Eval(cam->interp, ligne);
               fprintf(fwipe, "%s : %s\n", Tcl_GetStringResult(cam->interp), cam->msg);
               fclose(fwipe);
            }
            sprintf(ligne, "cam%d reinit -ip %s", cam->camno, cam->ip);
            if (cam->ipsetting == 1) {
               sprintf(result, " -ipsetting \"%s\"", cam->ipsetting_filename);
               strcat(ligne, result);
            }
            sprintf(result, " -shutterinvert %d", cam->shutteraudinereverse);
            strcat(ligne, result);
            sprintf(result, " -canspeed %d", cam->canspeed);
            strcat(ligne, result);
            strcpy(cam->msg, "");
            if (Tcl_Eval(cam->interp, ligne) != TCL_OK) {
               sprintf(cam->msg, "%s", Tcl_GetStringResult(cam->interp));
            }
         }
      }
      cam->CCDStatus = 1;
   }
}

void cam_stop_exp(struct camprop *cam)
{
   char value[MAXLENGTH + 1];
   char result[MAXLENGTH];
   int paramtype;

   /* - AbortExposure sur le CCD numero 1 clock mode 1- */
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "AbortExposure", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, result, &ParamCCDOut);
      strcpy(cam->msg, "");
      if (strcmp(result, "FAILED") == 0) {
         if (ParamCCDOut.NbreParam >= 2) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(cam->msg, "AbortExposure Failed : %s", result);
         } else {
            strcpy(cam->msg, "AbortExposure Failed");
         }
      }

   }
   if (util_param_search(&ParamCCDOut, "TimeDone", value, &paramtype) == 0) {
      cam->exptime_when_acq_stopped = (float) (atof(value) / 1000.0);
   }
   cam->CCDStatus = 0;
}

void cam_read_ccd(struct camprop *cam, float *p)
{
   char value[MAXLENGTH + 1];
   char result[MAXLENGTH + 1];
   char ligne[MAXLENGTH + 1];
   int sortie, paramtype;
   long k;
   double t0, t1, dt, timeout = 60.;
   FILE *fwipe;
   int gps_non_synchro = 0;

   if (p == NULL)
      return;

   if (strcmp(cam->msg, "InitExposure Failed") == 0)
      return;

   if (cam->authorized != 1)
      return;

   /*- boucle d'attente de fin de pose -*/
   if (cam->CCDStatus == 1) {
      sortie = 0;
   } else {
      sortie = 1;
   }
   LOG_ETHDEBUGFILE("READ_CCD : boucle d'attente fin de pose\n");
   while (sortie == 0) {
      paramCCD_clearall(&ParamCCDIn, 1);
      paramCCD_put(-1, "CCDStatus", &ParamCCDIn, 1);
      paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
      AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
      if (util_param_search(&ParamCCDOut, "EXPOSURE_COMPLETED", value, &paramtype) == 0) {
         LOG_ETHDEBUGFILE("READ_CCD : sortie boucle d'attente fin de pose EXPOSURE_COMPLETED\n");
         sortie = 1;
      }
      if (util_param_search(&ParamCCDOut, "Idle", value, &paramtype) == 0) {
         LOG_ETHDEBUGFILE("READ_CCD : sortie boucle d'attente fin de pose Idle\n");
         sortie = 1;
      }
      if (sortie == 0) {
         libcam_sleep(100);
      }
   }

   /* - Demarre la lecture de l'image qui est finie - */
   LOG_ETHDEBUGFILE("READ_CCD : demarre la lecture\n");
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "StartReadoutCCD", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);

   unsigned short* pushort = (unsigned short*) malloc(  cam->w * cam->h * sizeof(unsigned short)); 
   if( pushort==NULL) {
      return;
   }

#if defined(OS_WIN)
   // Only 32 bits "pointers" are supported. Too bad ...
   sprintf(result, "ImageAddress=%d", (int) (void *) pushort);
#else
   sprintf(result, "ImageAddress=%p", p);
#endif
   paramCCD_put(-1, result, &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);

   /*- boucle d'attente de fin de transfert ethernet -*/
   sortie = 0;
   LOG_ETHDEBUGFILE("READ_CCD : boucle de lecture\n");
   Tcl_Eval(cam->interp, "mc_date2jd [mc_date2iso8601 now]");
   t0 = atof(Tcl_GetStringResult(cam->interp));
   while (sortie == 0) {
      paramCCD_clearall(&ParamCCDIn, 1);
      paramCCD_put(-1, "CCDStatus", &ParamCCDIn, 1);
      paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
      AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
      if (util_param_search(&ParamCCDOut, "READOUT_in_PROGRESS", value, &paramtype) == 0) {
         sortie = 0;
      } else {
         sortie = 1;
      }
      Tcl_Eval(cam->interp, "mc_date2jd [mc_date2iso8601 now]");
      t1 = atof(Tcl_GetStringResult(cam->interp));
      dt = (t1 - t0) * 86400;
      if (dt > timeout) {
         sortie = 1;
         if ((fwipe = fopen("ethbug.txt", "at")) != NULL) {
            Tcl_Eval(cam->interp, "mc_date2iso8601 now");
            fprintf(fwipe, "%s : sortie de lecture en timeout %f s", Tcl_GetStringResult(cam->interp), timeout);
            fclose(fwipe);
         }
      }
   }
   LOG_ETHDEBUGFILE("READ_CCD : fin de boucle de lecture\n");

   /* --- inversion des octets de l'entier court --- */
   //long pdim = cam->w * cam->h;
   //for (k = 0; k < pdim; k++) {
   //   p[k] = (float) ((pushort[k] >> 8) + (pushort[k] << 8));
   //}

   // inversion des octets de l'entier court 
   // et inversion des pixels gauche <-> droite de maniere a obtenir une image orientee
   // comme si elle avait ete acquise avec la liaison port parallele
   float * pOut = p;
   for (int y = 0 ; y < cam->h; y++) {
      for (int x = cam->w -1 ; x >=0 ; x--) {
         k = y * cam->w + x;
         *(pOut++) = (float) ((pushort[k] >> 8) + (pushort[k] << 8));
      }
   }
   
   free(pushort);

   /* --- Datation GPS si eventaude present --- */
   if (cam->ethvar.InfoCCD_HasGPSDatation == 1) {
      sprintf(ligne, "buf%d setkwd {CAMERA \"%s+GPS %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
      Tcl_Eval(cam->interp, ligne);

      // Debut de la pose
      paramCCD_clearall(&ParamCCDIn, 1);
      paramCCD_put(-1, "Get_JulianDate_beginLastExp", &ParamCCDIn, 1);
      paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
      AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
      if (util_param_search(&ParamCCDOut, "Date", value, &paramtype) == 0) {
         if (strcmp(value,"0")) {
            sprintf(ligne, "mc_date2iso8601 %s", value);
            if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
               sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
               util_log(ligne, 0);
               return;
            }
            strcpy(cam->date_obs, Tcl_GetStringResult(cam->interp));
         } else {
            gps_non_synchro = 1;
         }
      } else {
         sprintf(ligne,"Keyword 'Date' not found");
         util_log(ligne, 0);
      }

      // Fin de la pose
      paramCCD_clearall(&ParamCCDIn, 1);
      paramCCD_put(-1, "Get_JulianDate_endLastExp", &ParamCCDIn, 1);
      paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
      AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
      if (util_param_search(&ParamCCDOut, "Date", value, &paramtype) == 0) {
         if (strcmp(value,"0")) {
            sprintf(ligne, "mc_date2iso8601 %s", value);
            if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
                sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
                util_log(ligne, 0);
                return;
            }
            strcpy(cam->date_end, Tcl_GetStringResult(cam->interp));
         } else {
            gps_non_synchro = 1;
         }
      } else {
         sprintf(ligne,"Keyword 'Date' not found");
         util_log(ligne, 0);
      }

      if ( gps_non_synchro == 0 ) {
         cam->gps_date = 1;
      } else {
         cam->gps_date = 0;
      }
   } else {
      // Sans eventaude, en cas d'arret premature il faut mettre a jour date_end car c'est lui qui permet de calculer
      // le temps de pose reel.
      if ( cam->exptime_when_acq_stopped >= 0.0 ) {
         sprintf(ligne, "mc_date2iso8601 [ mc_datescomp %s + [expr %f/86400.] ]", cam->date_obs, cam->exptime_when_acq_stopped);
         if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
            sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
            util_log(ligne, 0);
            return;
         }
         strcpy(cam->date_end, Tcl_GetStringResult(cam->interp));
      }
   }

   cam->CCDStatus = 1;
}

void cam_shutter_on(struct camprop *cam)
{
}

void cam_shutter_off(struct camprop *cam)
{
}

void cam_measure_temperature(struct camprop *cam)
{
    char keyword[MAXLENGTH + 1];
    char value[MAXLENGTH + 1];
    char ligne[MAXLENGTH];
    char result[MAXLENGTH];
    int failed, paramtype;

    strcpy(cam->msg, "");
    // je verifie qu'il n'y a pas d'acquisition en cours, car la lecture de la temp�rature ne peut �tre lue pendant une acquisition.
    if ( cam->acquisitionInProgress == 0 ) {
       if (cam->authorized == 1) {
          if (!cam->ethvar.InfoCCD_HasRegulationTempCaps) {
             sprintf(ligne, "<LIBETHERNAUDE/cam_measure_temperature> camera does not support temperature regulation (%d) ; return bypassed.",cam->ethvar.InfoCCD_HasRegulationTempCaps); util_log(ligne, 0);
             // TODO: FIXME. return;
          }
          failed = 0;
          paramCCD_clearall(&ParamCCDIn, 1);
          paramCCD_put(-1, "GetCCD_tempe", &ParamCCDIn, 1);
          paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
          AskForExecuteCCDCommand(&ParamCCDIn, &ParamCCDOut);
          if (ParamCCDOut.NbreParam >= 1) {
             paramCCD_get(0, result, &ParamCCDOut);
             strcpy(cam->msg, "");
             if (strcmp(result, "FAILED") == 0) {
                failed = 1;
                paramCCD_get(1, result, &ParamCCDOut);
                sprintf(cam->msg, "GetCCD_tempe Failed\n%s", result);
             }
          }
          if (failed == 0) {
             /* --- normal state --- */
             sprintf(keyword,"Temperature");
             if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
                cam->temperature = atof(value);
             }
             sprintf(ligne,"<LIBETHERNAUDE/cam_measure_temperature> keyword='%s', value='%s', cam->temperature=%f",keyword,value,cam->temperature); util_log("\n", 0);
          } else {
             sprintf(ligne, "cam%d reinit -ip %s", cam->camno, cam->ip);
             if (cam->ipsetting == 1) {
                sprintf(result, " -ipsetting \"%s\"", cam->ipsetting_filename);
                strcat(ligne, result);
             }
             sprintf(result, " -shutterinvert %d", cam->shutteraudinereverse);
             strcat(ligne, result);
             sprintf(result, " -canspeed %d", cam->canspeed);
             strcat(ligne, result);
             strcpy(cam->msg, "");
             if (Tcl_Eval(cam->interp, ligne) != TCL_OK) {
                sprintf(cam->msg, "%s", Tcl_GetStringResult(cam->interp));
             }
          }
          cam->CCDStatus = 1;
       }
    } else {
       strcpy(cam->msg, "acquisition in progress");
    }
}

void cam_cooler_on(struct camprop *cam)
{
    cam_cooler_check(cam);
}

void cam_cooler_off(struct camprop *cam)
{
}

void cam_cooler_check(struct camprop *cam)
{
   char ligne[MAXLENGTH];
   char result[MAXLENGTH];
   int sortie, failed;

   strcpy(cam->msg, "");
   if ( cam->acquisitionInProgress == 0 ) {
      if (cam->authorized == 1) {
         if (!cam->ethvar.InfoCCD_HasRegulationTempCaps) {
            sprintf(ligne, "<LIBETHERNAUDE/cam_cooler_check> camera does not support temperature regulation (%d) ; return bypassed.",cam->ethvar.InfoCCD_HasRegulationTempCaps); util_log(ligne, 0);
            // TODO: FIXME. return;
         }
         failed = 0;
         paramCCD_clearall(&ParamCCDIn, 1);
         paramCCD_put(-1, "SetCCD_tempe", &ParamCCDIn, 1);
         paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
         sprintf(ligne, "Temperature=%f", (float)(cam->check_temperature));
         paramCCD_put(-1, ligne, &ParamCCDIn, 1);
         AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
         if (ParamCCDOut.NbreParam >= 1) {
            paramCCD_get(0, result, &ParamCCDOut);
            strcpy(cam->msg, "");
            if (strcmp(result, "FAILED") == 0) {
               failed = 1;
               paramCCD_get(1, result, &ParamCCDOut);
               sprintf(cam->msg, "SetCCD_tempe Failed\n%s", result);
            }
         }
         if (failed == 0) {
            /* --- normal state --- */
            sortie = 1;
         } else {
            sprintf(ligne, "cam%d reinit -ip %s", cam->camno, cam->ip);
            if (cam->ipsetting == 1) {
               sprintf(result, " -ipsetting \"%s\"", cam->ipsetting_filename);
               strcat(ligne, result);
            }
            sprintf(result, " -shutterinvert %d", cam->shutteraudinereverse);
            strcat(ligne, result);
            sprintf(result, " -canspeed %d", cam->canspeed);
            strcat(ligne, result);
            strcpy(cam->msg, "");
            if (Tcl_Eval(cam->interp, ligne) != TCL_OK) {
               sprintf(cam->msg, "%s", Tcl_GetStringResult(cam->interp));
            }
         }
         cam->CCDStatus = 1;
      }
   } else {
      strcpy(cam->msg, "acquisition in progress");
   }

}

void cam_set_binning(int binx, int biny, struct camprop *cam)
{
   if (binx <= 0)
      binx = 1;
   if (binx >= 255)
      binx = 255;
   if (biny <= 0)
      biny = 1;
   if (biny >= 255)
      biny = 255;
   cam->binx = binx;
   cam->biny = biny;
}

void cam_update_window(struct camprop *cam)
{
   int maxx, maxy;
   maxx = cam->nb_photox;
   maxy = cam->nb_photoy;
   if (cam->x1 > cam->x2)
      libcam_swap(&(cam->x1), &(cam->x2));
   if (cam->x1 < 0)
      cam->x1 = 0;
   if (cam->x2 > maxx - 1)
      cam->x2 = maxx - 1;

   if (cam->y1 > cam->y2)
      libcam_swap(&(cam->y1), &(cam->y2));
   if (cam->y1 < 0)
      cam->y1 = 0;
   if (cam->y2 > maxy - 1)
      cam->y2 = maxy - 1;

   cam->w = (cam->x2 - cam->x1) / cam->binx +1;
   cam->x2 = cam->x1 + cam->w * cam->binx - 1;
   cam->h = (cam->y2 - cam->y1) / cam->biny +1;
   cam->y2 = cam->y1 + cam->h * cam->biny - 1;
}


/* ================================================================ */
/* ================================================================ */
/* ===     Fonctions de base pour le pilotage de la camera      === */
/* ================================================================ */
/* ================================================================ */
/* Ces fonctions sont tres specifiques a chaque camera.             */
/* ================================================================ */


int test_driver()
{
#if defined(OS_WIN)
    ethernaude = LoadLibrary(ETHERNAUDE_NAME);
    if ((ethernaude != NULL)) {
        ETHERNAUDE_MAIN = (ETHERNAUDE_CALL *) GetProcAddress(ethernaude, ETHERNAUDE_MAINQ);
        if (ETHERNAUDE_MAIN == NULL) {
            close_ethernaude();
            return (2);
        }
        ETHERNAUDE_DIRECTMAIN = (ETHERNAUDE_DIRECTCALL *) GetProcAddress(ethernaude, ETHERNAUDE_DIRECTMAINQ);
        if (ETHERNAUDE_DIRECTMAIN == NULL) {
            close_ethernaude();
            return (3);
        }
    }
    else {
        return (1);
    }
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
    ethernaude = dlopen(ETHERNAUDE_NAME, RTLD_LAZY);
    if (ethernaude != NULL) {
        ETHERNAUDE_MAIN = (ETHERNAUDE_CALL *) dlsym(ethernaude, ETHERNAUDE_MAINQ);
        if (ETHERNAUDE_MAIN == NULL) {
            close_ethernaude();
            return (2);
        }
        ETHERNAUDE_DIRECTMAIN = (ETHERNAUDE_DIRECTCALL*) dlsym(ethernaude, ETHERNAUDE_DIRECTMAINQ);
        if (ETHERNAUDE_DIRECTMAIN == NULL) {
            close_ethernaude();
            return (3);
        }
    }
    else {
        return (1);
    }
#endif
    return (0);
}

int direct_driver()
{
#if defined(OS_WIN)
   if ((ethernaude != NULL)) {
      ETHERNAUDE_DIRECTMAIN = (ETHERNAUDE_DIRECTCALL *) GetProcAddress(ethernaude, ETHERNAUDE_DIRECTMAINQ);
      if (ETHERNAUDE_DIRECTMAIN == NULL) {
         return (3);
      }
   } else {
      return (1);
   }
#endif
#if defined(OS_LIN) || defined(OS_MACOS)
   if (ethernaude != NULL) {
      ETHERNAUDE_DIRECTMAIN = (ETHERNAUDE_DIRECTCALL*) dlsym(ethernaude, ETHERNAUDE_DIRECTMAINQ);
      if (ETHERNAUDE_DIRECTMAIN == NULL) {
         return (3);
      }
   } else {
      return (1);
   }
#endif
   return (0);
}


/* camtcl.c
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
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "camera.h"
#include <libcam/libcam.h>
#include "camtcl.h"
#include <libcam/util.h>

extern struct camini CAM_INI[];

/*
 *  Definition a structure specific for this driver
 */

char *cam_shuttertypes[] = {
    "audine",
    "thierry",
    NULL
};

typedef struct {
    char *dateobs;      /* Date du debut de l'observation (format FITS) */
    char *dateend;      /* Date de fin de l'observation (format FITS) */
    ClientData clientData;  /* Camera (CCamera*) */
    Tcl_Interp *interp;     /* Interpreteur */
    Tcl_TimerToken TimerToken;  /* Handler sur le timer */
    int width;          /* Largeur de l'image */
    int offset;         /* Offset en x (a partir de 1) */
    int height;         /* Hauteur totale de l'image */
    int bin;            /* binning across scan */
    int biny;           /* binning along scan */
    float dt;           /* intervalle de temps en millisecondes */
    int idt;                    /* intervalle de temps en ms, valeur entiere */
    int y;          /* nombre de lignes deja lues */
    unsigned long t0;       /* instant de depart en microsecondes */
    int line_size;      /* nombre de pixels par ligne */
    unsigned short *pix;    /* stockage de l'image */
    unsigned short *pix2;   /* pointeur defilant sur le contenu de pix */
    int stop;           /* indicateur d'arret (1=>pose arretee au prochain coup) */
    double ra;          /* RA at the bigining */
    double dec;         /* DEC at the bigining */
} ScanStruct;

/* --- Global variable for TDI acquisition mode ---*/
static ScanStruct *TheScanStruct = NULL;

static void EthernaudeScanCallback(ClientData clientData);
static void EthernaudeScanLibereStructure();
static void EthernaudeScanTerminateSequence(ClientData clientData, int camno, const char *reason);
static void EthernaudeScanTransfer(ClientData clientData);

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

/*
 * -----------------------------------------------------------------------------
 * -----------------------------------------------------------------------------
 */

int cmdEthernaudeDirectClear(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    char ligne[256];
    int res;
    int result = TCL_OK;
    struct camprop *cam;
    unsigned char a;
    cam = (struct camprop *) clientData;
    if (cam->direct == 1) {
    if (argc != 3) {
        sprintf(ligne, "Usage: %s %s nb_wipe", argv[0], argv[1]);
        Tcl_SetResult(interp, ligne, TCL_VOLATILE);
        result = TCL_ERROR;
    } else {
        a = (unsigned char) argv[2][0];
        res = ETHERNAUDE_DIRECTMAIN(DIRECT_SERVICE_CLEARCCD, 1, &a);
        sprintf(ligne, "%d", res);
    }
    } else {
    result = TCL_ERROR;
    sprintf(ligne, "This function cannot be used with this driver");
    }
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return result;
}

int cmdEthernaudeDirectReset(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    char ligne[256];
    char ligne2[256];
    int res;
    int result = TCL_OK;
    struct camprop *cam;
    unsigned char a[2];
    int n = 2, k;
    cam = (struct camprop *) clientData;
    if (cam->direct == 1) {
    res = ETHERNAUDE_DIRECTMAIN(DIRECT_SERVICE_RESET, n, &a[0], &a[1]);
    sprintf(ligne, "%d", res);
    if (res == DIRECT_OK) {
        sprintf(ligne, "{%d} {", res);
        for (k = 0; k < n; k++) {
        strcpy(ligne2, ligne);
        sprintf(ligne, "%s %u", ligne2, a[k]);
        }
        strcpy(ligne2, ligne);
        sprintf(ligne, "%s}", ligne2);
    }
    } else {
    result = TCL_ERROR;
    sprintf(ligne, "This function cannot be used with this driver");
    }
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return result;
}

int cmdEthernaudeDirectIdentity(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    char ligne[256];
    char ligne2[256];
    int res;
    int result = TCL_OK;
    struct camprop *cam;
    unsigned char a[28];
    int n = 28, k;
    cam = (struct camprop *) clientData;
    if (cam->direct == 1) {
    res = ETHERNAUDE_DIRECTMAIN(DIRECT_SERVICE_IDENTITY, n, &a[0], &a[1], &a[2], &a[3], &a[4], &a[5], &a[6], &a[7], &a[8], &a[9], &a[10], &a[11], &a[12], &a[13], &a[14], &a[15], &a[16], &a[17], &a[18], &a[19], &a[20], &a[21], &a[22], &a[23], &a[24], &a[25], &a[26], &a[27]);
    sprintf(ligne, "%d", res);
    if (res == DIRECT_OK) {
        sprintf(ligne, "{%d} {", res);
        for (k = 0; k < n; k++) {
        strcpy(ligne2, ligne);
        sprintf(ligne, "%s %u", ligne2, a[k]);
        }
        strcpy(ligne2, ligne);
        sprintf(ligne, "%s}", ligne2);
    }
    } else {
    result = TCL_ERROR;
    sprintf(ligne, "This function cannot be used with this driver");
    }
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return result;
}

/* ============================================================================= */

int cmdEthernaudeChannel(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    char ligne[256];
    struct camprop *cam;
    cam = (struct camprop *) clientData;
    sprintf(ligne, "%s", cam->channel);
    Tcl_SetResult(interp, ligne, TCL_VOLATILE);
    return TCL_OK;
}


int cmdEthernaudeReinit(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
    struct camprop *cam;
    cam = (struct camprop *) clientData;
#ifdef CAMTCL_DEBUG
    printf("close dans cmdEthernaudeReinit\n");
#endif
    CAM_DRV.close(cam);
    if (CAM_DRV.init(cam, argc, argv) != 0) {
    Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
    return TCL_ERROR;
    }
    Tcl_SetResult(interp, "", TCL_VOLATILE);
    return TCL_OK;
    /* cam1 reinit -ip 192.168.0.123 */
}


/*
 * -----------------------------------------------------------------------------
 *  TTTTT DDDD   III
 *    T   D   D   I
 *    T   D   D   I
 *    T   D   D   I    acquisition mode
 *    T   D   D   I
 *    T   D   D   I
 *    T   DDDD   III
 * -----------------------------------------------------------------------------
 */


 /*
  * -----------------------------------------------------------------------------
  *  cmdEthernaudeScan()
  *
  *  Lance un scan.
  *
  *  buf scan width height bin dt
  *    - width : largeur de l'image
  *    - height : hauteur de l'image
  *    - bin : facteur de binning (across scan)
  *    - dt : intervalle de temps entre chaque lecture de ligne (en ms, float)
  *    - -firstpix index : la fenetre commence au pixel numero (1 a DimX).
  *    - -biny int : binning vertical (along scan).
  *
  *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
  * -----------------------------------------------------------------------------
  */
int cmdEthernaudeScan(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int w;           /* parametre d'appel : largeur */
   int h;           /* parametre d'appel : hauteur */
   int b;           /* parametre d'appel : binning */
   int by = 1;          /* binning en along scan */
   double dt;           /* parametre d'appel : intervalle de temps */
   struct camprop *cam;
   char ligne[200];     /* Texte pour le retour */
   char ligne2[200];        /* Texte pour le retour */
//   char text[200];        /* Texte pour le retour */
   int offset = 1;
   int i;
   char result[256];
   int status;
   char msgtcl[] = "Usage: %s %s width height bin dt ?-firstpix index?";

   cam = (struct camprop *) clientData;
   if (cam->ethvar.InfoCCD_HasTDICaps == 0) {
      Tcl_SetResult(interp, "This Ethernaude camera doesn't support the TDI mode.", TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (argc < 6) {
      sprintf(ligne, msgtcl, argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (Tcl_GetInt(interp, argv[2], &w) != TCL_OK) {
      sprintf(ligne2, "%s\nwidth : must be an integer between 1 and %d", msgtcl, cam->nb_photox);
      sprintf(ligne, ligne2, argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (Tcl_GetInt(interp, argv[3], &h) != TCL_OK) {
      sprintf(ligne2, "%s\nheight : must be an integer >= 1", msgtcl);
      sprintf(ligne, ligne2, argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (Tcl_GetInt(interp, argv[4], &b) != TCL_OK) {
      sprintf(ligne2, "%s\nbin : must be an integer >= 1", msgtcl);
      sprintf(ligne, ligne2, argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (Tcl_GetDouble(interp, argv[5], &dt) != TCL_OK) {
      sprintf(ligne2, "%s\ndt : must be an floating point number >= 0, expressed in milliseconds", msgtcl);
      sprintf(ligne, ligne2, argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      return TCL_ERROR;
   }
   for (i = 6; i < argc; i++) {
      if ((strcmp(argv[i], "-offset") == 0) || (strcmp(argv[i], "-firstpix") == 0)) {
         if (Tcl_GetInt(interp, argv[++i], &offset) != TCL_OK) {
        sprintf(ligne, "Usage: %s %s width height bin dt ?-firstpix index? ?-blocking? ?-perfo?\nfirstpix index \"%s\" must be an integer", argv[0], argv[1], argv[i]);
        Tcl_SetResult(interp, ligne, TCL_VOLATILE);
        return TCL_ERROR;
     }
      }
      if (strcmp(argv[i], "-biny") == 0) {
     if (Tcl_GetInt(interp, argv[++i], &by) != TCL_OK) {
        sprintf(ligne, "Usage: %s %s width height bin dt ?-firstpix index? ?-biny int?\nfirstpix index \"%s\" must be an integer", argv[0], argv[1], argv[i]);
        Tcl_SetResult(interp, ligne, TCL_VOLATILE);
        return TCL_ERROR;
     }
      }
   }
   /* --- c'est parti pour l'Ethernaude -- */
   sprintf(ligne,"<LIBETHERNAUDE/cmdEthernaudeScan:%d> offset=%d, w=%d, cam->nb_photox=%d",__LINE__,offset,w,cam->nb_photox); util_log(ligne,0);
   if (w < 1) {
      w = 1;
   }
   if (b < 1) {
      b = 1;
   }
   if (by < 1) {
      by = 1;
   }
   if (dt < 0) {
      dt = -dt;
   }

   sprintf(ligne,"<LIBETHERNAUDE/cmdEthernaudeScan:%d> cam->mirrorv=%d",__LINE__,cam->mirrorv); util_log(ligne,0);
   sprintf(ligne,"<LIBETHERNAUDE/cmdEthernaudeScan:%d>   offset=%d, w=%d, cam->nb_photox=%d",__LINE__,offset,w,cam->nb_photox); util_log(ligne,0);
   if (cam->mirrorv == 0) {
      // La lecture avec ethernaude est inversee par rapport a
      // l'audine, donc on teste mirroirv a 0.
      offset = cam->nb_deadbeginphotox + cam->nb_photox - ( offset - 1 ) - ( w - 1);
   } else {
      offset = cam->nb_deadbeginphotox + offset;
   }
   sprintf(ligne,"<LIBETHERNAUDE/cmdEthernaudeScan:%d>   -> offset=%d",__LINE__,offset); util_log(ligne,0);
   if (offset < 1) {
      offset = 1;
      sprintf(ligne,"<LIBETHERNAUDE/cmdEthernaudeScan:%d>   => offset rounded to 1",__LINE__); util_log(ligne,0);
   }
   if ( offset + w - 1 > cam->nb_photox + cam->nb_deadbeginphotox + cam->nb_deadendphotox ) {
      offset = cam->nb_deadbeginphotox + cam->nb_photox + cam->nb_deadendphotox - ( w - 1 );
      sprintf(ligne,"<LIBETHERNAUDE/cmdEthernaudeScan:%d>   => offset clipped to %d",__LINE__, offset); util_log(ligne,0);
   }
   w = w / b;

   /* - INIT_TDIMode sur le CCD numero 1 - */
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "INIT_TDIMode", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   sprintf(ligne, "TimePerLineMs=%f", dt);
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   sprintf(ligne, "Xd=%d", offset); // La position du debut du scan doit etre donnee en photosites
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   sprintf(ligne, "DX=%d", w); // La largeur de l'image est en pixels, soit le nombre de photosites divise par le binning
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   sprintf(ligne, "BinningX=%d", b);
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   sprintf(ligne, "BinningY=%d", by);
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   sprintf(ligne, "Amount_Lines=%d", h);
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);

   if (cam->shutterindex == 0) {
      strcpy(ligne, "OpenCloseShutter=FALSE");
   } else {
      strcpy(ligne, "OpenCloseShutter=TRUE");
   }

   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);

   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, result, &ParamCCDOut);
      strcpy(cam->msg, "");
      if (strcmp(result, "FAILED") == 0) {
     if (ParamCCDOut.NbreParam >= 2) {
        paramCCD_get(1, result, &ParamCCDOut);
        sprintf(cam->msg, "INIT_TDIMode Failed : %s", result);
     } else {
        strcpy(cam->msg, "INIT_TDIMode Failed");
     }
     Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
     return TCL_ERROR;
      }
   }

   /* La commande ethernaude a reussi : mise en place du callback */
   //sprintf(ligne, "status_cam%d", cam->camno);
   //Tcl_SetVar(interp, ligne, "exp", TCL_GLOBAL_ONLY);
   setCameraStatus(cam,"exp");

   TheScanStruct = (ScanStruct *) calloc(1, sizeof(ScanStruct));
   TheScanStruct->clientData = clientData;
   TheScanStruct->interp = interp;
   TheScanStruct->dateobs = (char *) calloc(32, sizeof(char));
   TheScanStruct->dateend = (char *) calloc(32, sizeof(char));
   TheScanStruct->width = w;
   TheScanStruct->offset = offset;
   TheScanStruct->height = h;
   TheScanStruct->bin = b;
   TheScanStruct->biny = by;
   TheScanStruct->dt = (float)dt;
   TheScanStruct->idt = 10; // Il faut depiler les data plus vite que la camera ne les fournit pour eviter l'engorgement du buffer de CCD_Driver.
   TheScanStruct->y = 0;
   TheScanStruct->stop = 0;

   TheScanStruct->line_size = w;
   TheScanStruct->pix = (unsigned short*)calloc(TheScanStruct->line_size*h,sizeof(unsigned short));
   TheScanStruct->pix2 = TheScanStruct->pix;

   /* coordonnes du telescope au debut de l'acquisition */
   libcam_get_tel_coord(interp, &TheScanStruct->ra, &TheScanStruct->dec, cam, &status);
   if (status == 1) {
      TheScanStruct->ra = -1.;
   }

   TheScanStruct->TimerToken = Tcl_CreateTimerHandler(TheScanStruct->idt, EthernaudeScanCallback, (ClientData) cam);
   libcam_GetCurrentFITSDate(interp, TheScanStruct->dateobs);

   Tcl_ResetResult(interp);
   return TCL_OK;
}

void EthernaudeScanCallback(ClientData clientData)
{
   struct camprop *cam;
   char ligne[200];
   int readok = 1;

   cam = (struct camprop *)clientData;
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "ReadoutLine_TDIMode", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   sprintf(ligne, "RowAddress=%zu", (size_t)(TheScanStruct->pix2));
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   sprintf(ligne, "NumRow=%d", TheScanStruct->y+1);
   paramCCD_put(-1, ligne, &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);

   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, ligne, &ParamCCDOut);
      //strcpy(cam->msg, "");
      if (strcmp(ligne, "FAILED") == 0) {
     readok = 0;
      }
   }

   if (TheScanStruct->stop == 1) {
      // Arret a la demande de l'utilisateur
      EthernaudeScanTerminateSequence(clientData, cam->camno, "User aborted exposure.");
      return;
   }

   if (readok == 1) {
      // Lecture OK du driver ethernaude
      TheScanStruct->y += 1;
      TheScanStruct->pix2 += TheScanStruct->line_size;
      if (TheScanStruct->y == TheScanStruct->height) {
         // La derniere ligne du scan est atteinte.
         libcam_GetCurrentFITSDate(TheScanStruct->interp, TheScanStruct->dateend);
         cam = (struct camprop *)clientData;
         EthernaudeScanTerminateSequence(clientData, cam->camno, "Normal end: last line reached.");
      } else {
         TheScanStruct->TimerToken = Tcl_CreateTimerHandler(TheScanStruct->idt, EthernaudeScanCallback, (ClientData) cam);
      }
   } else {
      // Si la lecture de la ligne a echoue, alors on retente plus tard.
      TheScanStruct->TimerToken = Tcl_CreateTimerHandler(TheScanStruct->idt, EthernaudeScanCallback, (ClientData) cam);
   }
}

void EthernaudeScanTerminateSequence(ClientData clientData, int camno, const char *reason)
{
    //char s[200];

    EthernaudeScanTransfer(clientData);

    //sprintf(s, "scan_result%d", camno);
    //Tcl_SetVar(TheScanStruct->interp, s, reason, TCL_GLOBAL_ONLY);
    setScanResult((struct camprop *)clientData, reason);
    //sprintf(s, "status_cam%d", camno);
    //Tcl_SetVar(TheScanStruct->interp, s, "stand", TCL_GLOBAL_ONLY);
    setCameraStatus((struct camprop *)clientData,"stand");

    EthernaudeScanLibereStructure();
}


/*
 * EthernaudeScanTransfer --
 *
 * Transfere l'image accumulee dans un buffer accessible depuis les
 * scripts TCL.
 *
 * Effets de bord :
 *   - Buffer realloue et rempli de l'image acquise.
 *
 */
void EthernaudeScanTransfer(ClientData clientData)
{
   char value[MAXLENGTH + 1];
   int paramtype;
   int naxis1, naxis2, bin1, bin2;
   char s[200], ligne[200];
   double ra, dec;
   float *pp;
   struct camprop *cam;
   Tcl_Interp *interp;
   double exptime;
   double dt;
   int status;
   char dateobs_tu[50], dateend_tu[50];
   int nbpix;
   int gps_non_synchro = 0;

   interp = TheScanStruct->interp;
   cam = (struct camprop *) clientData;

   cam->clockbegin = 0;
   naxis1 = TheScanStruct->line_size;
   naxis2 = TheScanStruct->y;
   bin1 = TheScanStruct->bin;
   bin2 = TheScanStruct->biny;
   dt = TheScanStruct->dt / 1000.;
   exptime = -1;

   /* Creation automatique du buffer audela */
   sprintf(s, "buf%d bitpix", cam->bufno);
   if (Tcl_Eval(interp, s) == TCL_ERROR) {
      /* Creation du buffer car il n'existe pas */
      sprintf(s, "buf::create %d", cam->bufno);
      status=Tcl_Eval(interp, s);
   }

   /* Conversion des dates d'acquisition */
   strcpy(dateobs_tu, TheScanStruct->dateobs);
   strcpy(dateend_tu, TheScanStruct->dateend);

   /* Transfert de la memoire temporaire vers le buffer image AudeLA */
   nbpix = naxis1 * naxis2;
   pp = (float *) malloc(nbpix * sizeof(float));
   while (--nbpix >= 0) {
      pp[nbpix] = (float)(TheScanStruct->pix[nbpix] / 256 + (TheScanStruct->pix[nbpix] % 256) * 256);
   }

   // si cam->mirrorv vaut 0 , je redresse l'image  en inversant l'axe X
   // si cam->mirrorv vaut 1 , je laisse l'image inversee
   sprintf(s, "buf%d setpixels CLASS_GRAY %d %d FORMAT_FLOAT COMPRESS_NONE %zu -reverse_x %d",
      cam->bufno, naxis1, naxis2, (size_t) pp, (cam->mirrorv == 0) );
   Tcl_Eval(interp, s);
   free(pp);

   /* Ajout des mots cles pour l'entete FITS */
   sprintf(s, "buf%d setkwd {NAXIS 2 int \"\" \"\"}", cam->bufno);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {NAXIS1 %d int \"\" \"\"}", cam->bufno, naxis1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {NAXIS2 %d int \"\" \"\"}", cam->bufno, naxis2);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {BIN1 %d int \"\" \"\"}", cam->bufno, bin1);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {BIN2 %d int \"\" \"\"}", cam->bufno, bin2);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DATE-OBS %s string \"Begin of scan exposure.\" \"\"}", cam->bufno, dateobs_tu);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {EXPOSURE %f float \"\" \"\"}", cam->bufno, exptime);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DATE-END %s string \"Estimated end of scan exposure.\" \"\"}", cam->bufno, dateend_tu);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {DT %f float \"Asked Time Delay Integration\" \"s/line\"}", cam->bufno, dt);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd {CAMERA \"%s %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
   Tcl_Eval(interp, s);
   sprintf(s, "buf%d setkwd [list GPS-DATE 0 int {1 if datation is derived from GPS, else 0} {}]", cam->bufno);
   Tcl_Eval(cam->interp, s);

   /* Recuperation des coordonnees telescope le cas echeant */
   libcam_get_tel_coord(interp, &ra, &dec, cam, &status);
   if (status == 0) {
      sprintf(s, "buf%d setkwd {RA %f float \"Right ascension telescope at the end\" \"\"}", cam->bufno, ra);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {DEC %f float \"Declination telescope at the end\" \"\"}", cam->bufno, dec);
      Tcl_Eval(interp, s);
   }
   if (TheScanStruct->ra != -1.) {
      sprintf(s, "buf%d setkwd {RA_BEG %f float \"Right ascension telescope at the begining\" \"\"}", cam->bufno, TheScanStruct->ra);
      Tcl_Eval(interp, s);
      sprintf(s, "buf%d setkwd {DEC_BEG %f float \"Declination telescope at the begining\" \"\"}", cam->bufno, TheScanStruct->dec);
      Tcl_Eval(interp, s);
   }

   /* --- Datation GPS si eventaude present --- */
   if (cam->ethvar.InfoCCD_HasGPSDatation == 1) {
      sprintf(s, "buf%d setkwd {CAMERA \"%s+GPS %s %s\" string \"\" \"\"}", cam->bufno, CAM_INI[cam->index_cam].name, CAM_INI[cam->index_cam].ccd, CAM_LIBNAME);
      Tcl_Eval(interp, s);

      // Debut de la pose
      paramCCD_clearall(&ParamCCDIn, 1);
      paramCCD_put(-1, "Get_JulianDate_beginLastExp", &ParamCCDIn, 1);
      paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
      AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
      if (util_param_search(&ParamCCDOut, "Date", value, &paramtype) == 0) {
         if ( strcmp(value,"0") ) {
            sprintf(ligne, "mc_date2iso8601 %s", value);
            if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
               sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
               util_log(ligne, 0);
               return;
            }
            strcpy(cam->date_obs, Tcl_GetStringResult(cam->interp));
            sprintf(ligne, "buf%d setkwd {DATE-OBS %s string \"Begin of scan exposure (GPS).\" \"\"}", cam->bufno, cam->date_obs);
            if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
               sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
               util_log(ligne, 0);
               return;
            }
         } else {
            gps_non_synchro = 1;
         }
      } else {
         sprintf(ligne, "buf%d setkwd [list GPS_BEG -1 float {Error, could not get the value from ethernaude} {}]", cam->bufno);
         if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
            sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
            util_log(ligne, 0);
            return;
         }
      }

      // Fin de la pose
      paramCCD_clearall(&ParamCCDIn, 1);
      paramCCD_put(-1, "Get_JulianDate_endLastExp", &ParamCCDIn, 1);
      paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
      AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
      if (util_param_search(&ParamCCDOut, "Date", value, &paramtype) == 0) {
         if ( strcmp(value,"0") ) {
            sprintf(ligne, "mc_date2iso8601 %s", value);
            if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
               sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
               util_log(ligne, 0);
               return;
            }
            strcpy(cam->date_end, Tcl_GetStringResult(cam->interp));
            sprintf(ligne, "buf%d setkwd {DATE-END %s string \"End of scan exposure (GPS).\" \"\"}", cam->bufno, cam->date_end);
            if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
               sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
               util_log(ligne, 0);
               return;
            }
         } else {
            gps_non_synchro = 1;
         }
      } else {
         sprintf(ligne, "buf%d setkwd [list GPS_END -1 float {Error, could not get the value from ethernaude} {}]", cam->bufno);
         if (Tcl_Eval(cam->interp, ligne) == TCL_ERROR) {
            sprintf(ligne,"Error line %s@%d: interpretation of '%s'", __FILE__, __LINE__, ligne);
            util_log(ligne, 0);
            return;
         }
      }

      if ( gps_non_synchro == 0 ) {
         sprintf(s, "buf%d setkwd [list GPS-DATE 1 int {1 if datation is derived from GPS, else 0} {}]", cam->bufno);
         Tcl_Eval(cam->interp, s);
      }
   }

   //sprintf(s, "status_cam%d", cam->camno);
   //Tcl_SetVar(interp, s, "stand", TCL_GLOBAL_ONLY);
   setCameraStatus(cam,"stand");
}

/*
 * EthernaudeScanLibereStructure --
 *
 * Libere la structure necessaire au fonctionnement du scan.
 *
 * Effets de bord :
 *   - Structure liberee et remise a NULL.
 *
 */
void EthernaudeScanLibereStructure()
{
   free(TheScanStruct->dateobs);
   free(TheScanStruct->dateend);
   free(TheScanStruct->pix);
   free(TheScanStruct);
   TheScanStruct = NULL;
}



/*
 * -----------------------------------------------------------------------------
 *  cmdEthernaudeBreakScan --
 *
 *  Commande d'arret d'acquisition de scan.
 *
 *  Retourne TCL_OK/TCL_ERROR pour indiquer soit le succes, soit l'echec
 * -----------------------------------------------------------------------------
 */
int cmdEthernaudeBreakScan(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   int retour = TCL_OK;
   char result[MAXLENGTH];
   struct camprop *cam;
   cam = (struct camprop *) clientData;

   if (cam->ethvar.InfoCCD_HasTDICaps == 0) {
      Tcl_SetResult(interp, "This Ethernaude camera doesn't support the TDI mode ; return bypassed.", TCL_VOLATILE);
      return TCL_ERROR;
   }

   /* - END_TDIMode sur le CCD numero 1 - */
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "END_TDIMode", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, result, &ParamCCDOut);
      strcpy(result, "");
      if (strcmp(result, "FAILED") == 0) {
         retour = TCL_ERROR;
         if (ParamCCDOut.NbreParam >= 2) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(result, "END_TDIMode Failed : %s", result);
         } else {
            strcpy(result, "END_TDIMode Failed");
         }
      }
   }

   // La commande ethernaude a reussi : arret du scan.
   TheScanStruct->stop = 1;

   Tcl_SetResult(interp,result,TCL_VOLATILE);
   return retour;
}



/*
 * -----------------------------------------------------------------------------
 *  cmdEthernaudeCanSpeed()
 *
 * Setect the speed parameter for the CAN:
 *  value between 0 and 150 (default 4)
 *
 * -----------------------------------------------------------------------------
 */
int cmdEthernaudeCanSpeed(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[256];
   char ligne2[256];
   const char **argvv = NULL;
   int argcc;
   int result = TCL_OK, pb = 0, reinit = 0;
   struct camprop *cam;
   cam = (struct camprop *) clientData;
   if ((argc != 2) && (argc > 3)) {
      pb = 1;
   } else if (argc == 2) {
      pb = 0;
   } else {
      cam->canspeed = atoi(argv[2]);
      reinit = 1;
      pb = 0;
   }
   if (pb == 1) {
      sprintf(ligne, "Usage: %s %s ?value?", argv[0], argv[1]);
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      sprintf(ligne, "%d", cam->canspeed);
      if (reinit == 1) {
#ifdef CAMTCL_DEBUG
         printf("close dans cmdEthernaudeCanSpeed\n");
#endif

         CAM_DRV.close(cam);
         sprintf(ligne2, "-ip %d.%d.%d.%d -shutterinvert %d -canspeed %d ", cam->inparams.ip[0], cam->inparams.ip[1], cam->inparams.ip[2], cam->inparams.ip[3], cam->inparams.shutterinvert, cam->canspeed);
         util_splitline(ligne2, &argcc, &argvv);
         if (CAM_DRV.init(cam, argcc, argvv) != 0) {
            Tcl_SetResult(interp, cam->msg, TCL_VOLATILE);
            util_free((char *) argvv);
            return TCL_ERROR;
         }
         util_free((char *) argvv);
      }
      Tcl_SetResult(interp, ligne, TCL_VOLATILE);
   }
   return result;
}

int cmdEthernaudeDebug(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[200];
   if (argc==2) {
      sprintf(ligne,"%d",ethernaude_debug);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_OK;
   }
   if (argc==3) {
      ethernaude_debug = atoi(argv[2]);
      sprintf(ligne,"%d",ethernaude_debug);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_OK;
   }
   sprintf(ligne,"Usage: %s %s [0|1]",argv[0],argv[1]);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_ERROR;
}

int cmdEthernaudeGPS(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char ligne[MAXLENGTH];
   char result[MAXLENGTH];
   char keyword[MAXLENGTH + 1];
   char value[MAXLENGTH + 1];
   int paramtype;
   struct camprop *cam;

   float longitude, latitude, altitude;
   char dir;

   cam = (struct camprop *) clientData;

   // je verifie qu'il n'y a pas d'acquisition en cours, car la lecture de la position GPS ne peut pas se faire pendant une acquisition.
   if ( cam->acquisitionInProgress != 0 ) {
      Tcl_SetResult(interp,"acquisition in progress",TCL_VOLATILE);
      return TCL_ERROR;
   }
   if (cam->ethvar.InfoCCD_HasGPSDatation==0) {
      Tcl_SetResult(interp,"This camera does not support GPS coordinates query.",TCL_VOLATILE);
      return TCL_ERROR;
   }

   if (argc!=2) {
      sprintf(ligne,"Usage: %s %s",argv[0],argv[1]);
      Tcl_SetResult(interp,ligne,TCL_VOLATILE);
      return TCL_ERROR;
   }

   /* Requete de longitude */
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "Get_Longitude", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, result, &ParamCCDOut);
      strcpy(cam->msg, "");
      if (strcmp(result, "FAILED") == 0) {
         if (ParamCCDOut.NbreParam >= 2) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(cam->msg, "Get_Longitude Failed : %s", result);
         } else {
            strcpy(cam->msg, "Get_Longitude Failed");
         }
         Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
         return TCL_ERROR;
      }
   }
   sprintf(keyword,"Longitude");
   if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
      longitude = (float)atof(value);
      if (longitude < 0) {
         dir = 'W';
      } else {
         dir = 'E';
      }
      longitude = (float)(180.0*fabs(longitude)/(4.*atan((double)1)));
   } else {
      Tcl_SetResult(interp,"Internal error in longitude decoding.",TCL_VOLATILE);
      return TCL_ERROR;
   }

   /* Requete de latitude */
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "Get_Latitude", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, result, &ParamCCDOut);
      strcpy(cam->msg, "");
      if (strcmp(result, "FAILED") == 0) {
         if (ParamCCDOut.NbreParam >= 2) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(cam->msg, "Get_Latitude Failed : %s", result);
         } else {
            strcpy(cam->msg, "Get_Latitude Failed");
         }
         Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
         return TCL_ERROR;
      }
   }
   sprintf(keyword,"Latitude");
   if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
      latitude = (float)(180.0*atof(value)/(4*atan((double)1)));
   } else {
      Tcl_SetResult(interp,"Internal error in latitude decoding.",TCL_VOLATILE);
      return TCL_ERROR;
   }

   /* Requete de altitude */
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "Get_Altitude", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, result, &ParamCCDOut);
      strcpy(cam->msg, "");
      if (strcmp(result, "FAILED") == 0) {
         if (ParamCCDOut.NbreParam >= 2) {
            paramCCD_get(1, result, &ParamCCDOut);
            sprintf(cam->msg, "Get_Altitude Failed : %s", result);
         } else {
            strcpy(cam->msg, "Get_Altitude Failed");
         }
         Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
         return TCL_ERROR;
      }
   }
   sprintf(keyword,"Altitude");
   if (util_param_search(&ParamCCDOut, keyword, value, &paramtype) == 0) {
      altitude = (float)atof(value);
   } else {
      Tcl_SetResult(interp,"Internal error in altitude decoding.",TCL_VOLATILE);
      return TCL_ERROR;
   }

   sprintf(ligne,"GPS %f %c %f %f",longitude,dir,latitude,altitude);
   Tcl_SetResult(interp,ligne,TCL_VOLATILE);
   return TCL_OK;
}

int cmdEthernaudeGetCCDInfos(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   char s[200];
   int retour = TCL_ERROR;
   char keywordk[MAXLENGTH + 1], valuek[MAXLENGTH + 1];
   int k, paramtypek;
   Tcl_DString dsptr;
   struct camprop *cam;

   cam = (struct camprop *) clientData;
   paramCCD_clearall(&ParamCCDIn, 1);
   paramCCD_put(-1, "GetCCD_infos", &ParamCCDIn, 1);
   paramCCD_put(-1, "CCD#=1", &ParamCCDIn, 1);
   AskForExecuteCCDCommand_Dump(&ParamCCDIn, &ParamCCDOut);
   if (ParamCCDOut.NbreParam >= 1) {
      paramCCD_get(0, s, &ParamCCDOut);
      strcpy(cam->msg, "");
      if (strcmp(s, "FAILED") == 0) {
         if (ParamCCDOut.NbreParam >= 2) {
            paramCCD_get(1, s, &ParamCCDOut);
            sprintf(cam->msg, "GetCCD_infos failed : %s", s);
         } else {
            strcpy(cam->msg, "GetCCD_infos Failed");
         }
         Tcl_SetResult(interp,cam->msg,TCL_VOLATILE);
      } else {
         Tcl_DStringInit(&dsptr);
         paramCCD_get(0, s, &ParamCCDOut);
         Tcl_DStringAppend(&dsptr,s,-1);
         Tcl_DStringAppend(&dsptr," ",-1);

         for (k=1;k<ParamCCDOut.NbreParam;k++) {
            /* Decoder chaque argument ici */
            paramCCD_get(k, s, &ParamCCDOut);
            util_param_decode(s, keywordk, valuek, &paramtypek);
            sprintf(s,"{%s %s} ",keywordk, valuek);
            Tcl_DStringAppend(&dsptr,s,-1);
         }
         Tcl_DStringResult(interp,&dsptr);
         Tcl_DStringFree(&dsptr);
         retour = TCL_OK;
      }
   }

   return retour;
}

int cmdEthernaudeHasEventaude(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   struct camprop *cam = (struct camprop *) clientData;

   if (cam->ethvar.InfoCCD_HasGPSDatation==1) {
      Tcl_SetResult(interp,"1",TCL_STATIC);
   } else {
      Tcl_SetResult(interp,"0",TCL_STATIC);
   }
   return TCL_OK;
}

int cmdEthernaudeHasRegulation(ClientData clientData, Tcl_Interp * interp, int argc, const char *argv[])
{
   struct camprop *cam = (struct camprop *) clientData;

   if (cam->ethvar.InfoCCD_HasRegulationTempCaps==1) {
      Tcl_SetResult(interp,"1",TCL_STATIC);
   } else {
      Tcl_SetResult(interp,"0",TCL_STATIC);
   }
   return TCL_OK;
}

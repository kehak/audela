/* tt_util2.c
*
* This file is part of the AudeLA project : <http://software.audela.free.fr>
* Copyright (C) 1998-2004 The AudeLA Core Team
*
* Initial author : Alain KLOTZ <alain.klotz@free.fr>
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

#include "tt.h"

#ifdef TT_OLD_ASTROM
int tt_util_putnewkey_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   double vald;
   /* --- mots cles de la norme FITS >=1999 ---*/
   tt_imanewkey(p_ima,"RADESYS","FK5",TSTRING,"Mean Place IAU 1984 system","");
   vald=2000.;
   tt_imanewkey(p_ima,"EQUINOX",&(vald),TDOUBLE,"System of equatorial coordinates","");
   tt_imanewkey(p_ima,"CTYPE1","RA---TAN",TSTRING,"Gnomonic projection","");
   tt_imanewkey(p_ima,"CTYPE2","DEC--TAN",TSTRING,"Gnomonic projection","");
   vald=180.;
   tt_imanewkey(p_ima,"LONPOLE",&(vald),TDOUBLE,"Long. of the celest.NP in native coor.syst.","deg");
   tt_imanewkey(p_ima,"CUNIT1","deg",TSTRING,"Angles are degrees always","");
   tt_imanewkey(p_ima,"CUNIT2","deg",TSTRING,"Angles are degrees always","");
   tt_imanewkey(p_ima,"CRPIX1",&(p_ast->crpix1),TDOUBLE,"reference pixel for naxis1","pixel");
   tt_imanewkey(p_ima,"CRPIX2",&(p_ast->crpix2),TDOUBLE,"reference pixel for naxis2","pixel");
   vald=p_ast->crval1*(double)(180./(TT_PI));
   tt_imanewkey(p_ima,"CRVAL1",&(vald),TDOUBLE,"reference coordinate for naxis1","degree");
   vald=p_ast->crval2*180./(TT_PI);
   tt_imanewkey(p_ima,"CRVAL2",&(vald),TDOUBLE,"reference coordinate for naxis2","degree");
   vald=(double)(float)p_ast->cd11*180./(TT_PI);
   tt_imanewkey(p_ima,"CD1_1",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");
   vald=(double)(float)p_ast->cd12*180./(TT_PI);
   tt_imanewkey(p_ima,"CD1_2",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");
   vald=(double)(float)p_ast->cd21*180./(TT_PI);
   tt_imanewkey(p_ima,"CD2_1",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");
   vald=(double)(float)p_ast->cd22*180./(TT_PI);
   tt_imanewkey(p_ima,"CD2_2",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");

   /* --- mots cles de la norme FITS <1999 ---*/
   vald=(double)(float)p_ast->cdelta1*180./(TT_PI);
   tt_imanewkey(p_ima,"CDELT1",&(vald),TDOUBLE,"scale along naxis1","deg/pixel");
   vald=(double)(float)p_ast->cdelta2*180./(TT_PI);
   tt_imanewkey(p_ima,"CDELT2",&(vald),TDOUBLE,"scale along naxis2","deg/pixel");
   vald=(double)(float)p_ast->crota2*180./(TT_PI);
   tt_imanewkey(p_ima,"CROTA2",&(vald),TDOUBLE,"position angle","deg");

   /* --- mots cles des caracteristiques optiques calculees ---*/
   if ((p_ast->px!=0)&&(p_ast->cdelta1!=0)) {p_ast->foclen=fabs(p_ast->px/2./tan(p_ast->cdelta1/2.));} else {p_ast->foclen=0.;}
   if (p_ast->foclen!=0) {
      vald=(double)(float)p_ast->foclen;
      tt_imanewkey(p_ima,"FOCLEN",&(vald),TDOUBLE,"Focal length","m");
   }
   if (p_ast->px!=0.) {
      vald=(double)(float)p_ast->px*1e6;
      tt_imanewkey(p_ima,"PIXSIZE1",&vald,TDOUBLE,"Pixel size along naxis1","um");
   }
   if (p_ast->py!=0.) {
      vald=(double)(float)p_ast->py*1e6;
      tt_imanewkey(p_ima,"PIXSIZE2",&vald,TDOUBLE,"Pixel size along naxis2","um");
   }
   if (p_ast->pv_valid==TT_YES) {
      tt_imanewkey(p_ima,"PV1_0",&(p_ast->pv[1][0]),TDOUBLE,"Distortion 1 constant","pix");
      tt_imanewkey(p_ima,"PV1_1",&(p_ast->pv[1][1]),TDOUBLE,"Distortion 1 x","pix**-1");
      tt_imanewkey(p_ima,"PV1_2",&(p_ast->pv[1][2]),TDOUBLE,"Distortion 1 y","pix**-1");
      tt_imanewkey(p_ima,"PV1_3",&(p_ast->pv[1][3]),TDOUBLE,"Distortion 1 r","pix**-1");
      tt_imanewkey(p_ima,"PV1_4",&(p_ast->pv[1][4]),TDOUBLE,"Distortion 1 x2","pix**-2");
      tt_imanewkey(p_ima,"PV1_5",&(p_ast->pv[1][5]),TDOUBLE,"Distortion 1 xy","pix**-2");
      tt_imanewkey(p_ima,"PV1_6",&(p_ast->pv[1][6]),TDOUBLE,"Distortion 1 y2","pix**-2");
      tt_imanewkey(p_ima,"PV1_7",&(p_ast->pv[1][7]),TDOUBLE,"Distortion 1 x3","pix**-3");
      tt_imanewkey(p_ima,"PV1_8",&(p_ast->pv[1][8]),TDOUBLE,"Distortion 1 x2y","pix**-3");
      tt_imanewkey(p_ima,"PV1_9",&(p_ast->pv[1][9]),TDOUBLE,"Distortion 1 xy2","pix**-3");
      tt_imanewkey(p_ima,"PV1_10",&(p_ast->pv[1][10]),TDOUBLE,"Distortion 1 y3","pix**-3");
      tt_imanewkey(p_ima,"PV2_0",&(p_ast->pv[2][0]),TDOUBLE,"Distortion 2 constant","pix");
      tt_imanewkey(p_ima,"PV2_1",&(p_ast->pv[2][1]),TDOUBLE,"Distortion 2 y","pix**-1");
      tt_imanewkey(p_ima,"PV2_2",&(p_ast->pv[2][2]),TDOUBLE,"Distortion 2 x","pix**-1");
      tt_imanewkey(p_ima,"PV2_3",&(p_ast->pv[2][3]),TDOUBLE,"Distortion 2 r","pix**-1");
      tt_imanewkey(p_ima,"PV2_4",&(p_ast->pv[2][4]),TDOUBLE,"Distortion 2 y2","pix**-2");
      tt_imanewkey(p_ima,"PV2_5",&(p_ast->pv[2][5]),TDOUBLE,"Distortion 2 yx","pix**-2");
      tt_imanewkey(p_ima,"PV2_6",&(p_ast->pv[2][6]),TDOUBLE,"Distortion 2 x2","pix**-2");
      tt_imanewkey(p_ima,"PV2_7",&(p_ast->pv[2][7]),TDOUBLE,"Distortion 2 y3","pix**-3");
      tt_imanewkey(p_ima,"PV2_8",&(p_ast->pv[2][8]),TDOUBLE,"Distortion 2 xy2","pix**-3");
      tt_imanewkey(p_ima,"PV2_9",&(p_ast->pv[2][9]),TDOUBLE,"Distortion 2 x2y","pix**-3");
      tt_imanewkey(p_ima,"PV2_10",&(p_ast->pv[2][10]),TDOUBLE,"Distortion 2 x3","pix**-3");
   }
   return(OK_DLL);
}
#else
int tt_util_putnewkey_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   double vald;
   TT_WCS wcs;
   wcs=p_ast->wcs;
   /* --- mots cles de la norme FITS >=1999 ---*/
   tt_imanewkey(p_ima,"RADESYS","FK5",TSTRING,"Mean Place IAU 1984 system","");
   vald=2000.;
   tt_imanewkey(p_ima,"EQUINOX",&(vald),TDOUBLE,"System of equatorial coordinates","");
   tt_imanewkey(p_ima,"CTYPE1","RA---TAN",TSTRING,"Gnomonic projection","");
   tt_imanewkey(p_ima,"CTYPE2","DEC--TAN",TSTRING,"Gnomonic projection","");
   vald=180.;
   tt_imanewkey(p_ima,"LONPOLE",&(vald),TDOUBLE,"Long. of the celest.NP in native coor.syst.","deg");
   tt_imanewkey(p_ima,"CUNIT1","deg",TSTRING,"Angles are degrees always","");
   tt_imanewkey(p_ima,"CUNIT2","deg",TSTRING,"Angles are degrees always","");
   //
   tt_imanewkey(p_ima,"CRPIX1",&(wcs.crpix1),TDOUBLE,"reference pixel for naxis1","pixel");
   tt_imanewkey(p_ima,"CRPIX2",&(wcs.crpix2),TDOUBLE,"reference pixel for naxis2","pixel");
   vald=wcs.crval1;
   tt_imanewkey(p_ima,"CRVAL1",&(vald),TDOUBLE,"reference coordinate for naxis1","degree");
   vald=wcs.crval2;
   tt_imanewkey(p_ima,"CRVAL2",&(vald),TDOUBLE,"reference coordinate for naxis2","degree");
   vald=(double)(float)wcs.cd11;
   tt_imanewkey(p_ima,"CD1_1",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");
   vald=(double)(float)wcs.cd12;
   tt_imanewkey(p_ima,"CD1_2",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");
   vald=(double)(float)wcs.cd21;
   tt_imanewkey(p_ima,"CD2_1",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");
   vald=(double)(float)wcs.cd22;
   tt_imanewkey(p_ima,"CD2_2",&(vald),TDOUBLE,"coord. transf. matrix","deg/pixel");

   /* --- mots cles de la norme FITS <1999 ---*/
   vald=(double)(float)wcs.cdelt1;
   tt_imanewkey(p_ima,"CDELT1",&(vald),TDOUBLE,"scale along naxis1","deg/pixel");
   vald=(double)(float)wcs.cdelt2;
   tt_imanewkey(p_ima,"CDELT2",&(vald),TDOUBLE,"scale along naxis2","deg/pixel");
   vald=(double)(float)wcs.crota2;
   tt_imanewkey(p_ima,"CROTA2",&(vald),TDOUBLE,"position angle","deg");

   /* --- mots cles des caracteristiques optiques calculees ---*/
   if ((wcs.pixsize1!=0)&&(wcs.cdelt1!=0)) {wcs.foclen=fabs(wcs.pixsize1/1e6/2./tan(wcs.cdelt1/2.*TT_PI/180));} else {wcs.foclen=0.;}
   if (wcs.foclen!=0) {
      vald=(double)(float)wcs.foclen;
      tt_imanewkey(p_ima,"FOCLEN",&(vald),TDOUBLE,"Focal length","m");
   }
   if (wcs.pixsize1!=0.) {
      vald=(double)(float)wcs.pixsize1;
      tt_imanewkey(p_ima,"PIXSIZE1",&vald,TDOUBLE,"Pixel size along naxis1","um");
   }
   if (wcs.pixsize2!=0.) {
      vald=(double)(float)wcs.pixsize2;
      tt_imanewkey(p_ima,"PIXSIZE2",&vald,TDOUBLE,"Pixel size along naxis2","um");
   }
   return(OK_DLL);
}
#endif

int tt_util_getkey_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int msg,valid=TT_NO,k1,k2;

   if ((msg=tt_util_getkey0_astrometry(p_ima,p_ast,&valid))!=OK_DLL) {
      return(msg);
   }

   if (valid==TT_NO) {
      /* --- valeurs par defaut ---*/
      p_ast->px=18.e-6;
      p_ast->py=18.e-6;
      p_ast->foclen=1.;
      p_ast->ra0=0.;
      p_ast->dec0=0.;
      p_ast->crval1=0.;
      p_ast->crval2=0.;
      p_ast->cdelta1=0.;
      p_ast->cdelta2=0.;
      p_ast->crota2=0.;
      p_ast->crpix1=p_ima->naxis1/2.;
      p_ast->crpix2=p_ima->naxis2/2.;
      for (k1=1;k1<=2;k1++) {
         for (k2=0;k2<=10;k2++) {
            p_ast->pv[k1][k2]=0.;
         }
      }
      p_ast->pv[1][1]=1.;
      p_ast->pv[2][1]=1.;
      p_ast->pv_valid=TT_NO;
      //
      p_ast->wcs.pixsize1=18.e-6;
      p_ast->wcs.pixsize2=18.e-6;
      p_ast->wcs.foclen=1.;
      p_ast->wcs.crval1=0.;
      p_ast->wcs.crval2=0.;
      p_ast->wcs.cdelt1=0.;
      p_ast->wcs.cdelt2=0.;
      p_ast->wcs.crota2=0.;
      p_ast->wcs.crpix1=p_ima->naxis1/2.;
      p_ast->wcs.crpix2=p_ima->naxis2/2.;
   }

   return(OK_DLL);
}

int tt_util_getkey0_astrometry(TT_IMA *p_ima,TT_ASTROM *p_ast,int *valid)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   char keyname[FLEN_KEYWORD];
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   int datatype,v,k1,k2;
   int msg,crval1found=TT_NO,crval2found=TT_NO,crota2found=TT_NO;
   int crpix1found=TT_NO,crpix2found=TT_NO;
   int valid_optic=0,valid_crvp=0,valid_cd=0;
   double dvalue/*,det*/;
   int valid_pv=0;
   int is_pixsize1=0,is_pixsize2=0,is_foclen=0;
   int kcd,kc;
   TT_WCS *wcs;
   wcs = &(p_ast->wcs);
   wcs->valid=0;

   p_ast->crota2=0.;

   p_ast->foclen=0.; /* focale en m*/
   p_ast->px=0.;     /* pixel en m */
   p_ast->py=0.;
   p_ast->crota2=0.;
   p_ast->cd11=0.;
   p_ast->cd12=0.;
   p_ast->cd21=0.;
   p_ast->cd22=0.;
   p_ast->crpix1=0.;
   p_ast->crpix2=0.;
   p_ast->crval1=0.;
   p_ast->crval2=0.;
   p_ast->cdelta1=0.;
   p_ast->cdelta2=0.;
   p_ast->dec0=-100.;
   p_ast->ra0=-100.;
   for (k1=1;k1<=2;k1++) {
      for (k2=0;k2<=10;k2++) {
         p_ast->pv[k1][k2]=0.;
      }
   }
   p_ast->pv[1][1]=1.;
   p_ast->pv[2][1]=1.;
   p_ast->pv_valid=TT_NO;

   /* -- recherche des mots cles d'astrometrie '_optic' dans l'entete FITS --*/
   strcpy(keyname,"FOCLEN");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->foclen=dvalue; }
   }
   strcpy(keyname,"PIXSIZE1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->px=dvalue; }
      if (strcmp(unit,"m")==0) { p_ast->px*=1.; }
      else if (strcmp(unit,"mm")==0) { p_ast->px*=1e-3; }
      else { p_ast->px*=1e-6;}
   }
   strcpy(keyname,"PIXSIZE2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->py=dvalue; }
      if (strcmp(unit,"m")==0) { p_ast->py*=1.; }
      else if (strcmp(unit,"mm")==0) { p_ast->py*=1e-3; }
      else { p_ast->py*=1e-6;}
   }
   strcpy(keyname,"RA");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_optic++;
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->ra0=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->ra0*=(TT_PI/180.); }
      else if (strcmp(unit,"h")==0) { p_ast->ra0*=(15.*(TT_PI)/180.); }
      else { p_ast->ra0*=(TT_PI/180.);}
      p_ast->crval1=p_ast->ra0;
      crval1found=TT_YES;
   }
   strcpy(keyname,"DEC");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_optic++;
      dvalue=atof(value_char);
      if ((dvalue>=-90)&&(dvalue<=90)) { p_ast->dec0=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->dec0*=(TT_PI/180.); }
      else { p_ast->dec0*=(TT_PI/180.);}
      p_ast->crval2=p_ast->dec0;
      crval2found=TT_YES;
   }

   /* -- recherche des mots cles d'astrometrie '_cd' dans l'entete FITS --*/
   strcpy(keyname,"CD1_1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype!=0) {
      valid_cd++;
      p_ast->cd11=atof(value_char)*(TT_PI)/180.;
      strcpy(keyname,"CD1_2");
      if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
         return(msg);
      }
      if (datatype!=0) {
         valid_cd++;
         p_ast->cd12=atof(value_char)*(TT_PI)/180.;
      }
      strcpy(keyname,"CD2_1");
      if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
         return(msg);
      }
      if (datatype!=0) {
         valid_cd++;
         p_ast->cd21=atof(value_char)*(TT_PI)/180.;
      }
      strcpy(keyname,"CD2_2");
      if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
         return(msg);
      }
      if (datatype!=0) {
         valid_cd++;
         p_ast->cd22=atof(value_char)*(TT_PI)/180.;
      }
   }

   /* -- recherche des mots cles d'astrometrie '_crvp' dans l'entete FITS --*/
   strcpy(keyname,"CDELT1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_crvp++;
      dvalue=atof(value_char);
      p_ast->cdelta1=dvalue;
      if (strcmp(unit,"deg/pixel")==0) { p_ast->cdelta1*=(TT_PI/180.); }
      else { p_ast->cdelta1*=(TT_PI/180.);}
   }
   strcpy(keyname,"CDELT2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_crvp++;
      dvalue=atof(value_char);
      p_ast->cdelta2=dvalue;
      if (strcmp(unit,"deg/pixel")==0) { p_ast->cdelta2*=(TT_PI/180.); }
      else { p_ast->cdelta2*=(TT_PI/180.);}
   }
   strcpy(keyname,"CROTA2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      crota2found=TT_YES;
      valid_crvp++;
      valid_optic++;
      dvalue=atof(value_char);
      p_ast->crota2=dvalue;
      if (strcmp(unit,"deg")==0) { p_ast->crota2*=(TT_PI/180.); }
      else if (strcmp(unit,"radian")==0) { p_ast->crota2*=(1.); }
      else { p_ast->crota2*=(TT_PI/180.);}
   }

   /* -- recherche des mots cles d'astrometrie '_crvp' '_cd' '_optic' dans l'entete FITS --*/
   strcpy(keyname,"CRPIX1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      crpix1found=TT_YES;
      valid_crvp++;
      valid_cd++;
      valid_optic++;
      p_ast->crpix1=atof(value_char);
   }
   strcpy(keyname,"CRPIX2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      crpix2found=TT_YES;
      valid_crvp++;
      valid_cd++;
      valid_optic++;
      p_ast->crpix2=atof(value_char);
   }
   strcpy(keyname,"CRVAL1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
      p_ast->crval1=p_ast->ra0;
   } else {
      valid_crvp++;
      valid_cd++;
      if (crval1found==TT_NO) { valid_optic++; }
      dvalue=atof(value_char);
      if (dvalue>0) { p_ast->crval1=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->crval1*=(TT_PI/180.); }
      else if (strcmp(unit,"h")==0) { p_ast->crval1*=(15.*(TT_PI)/180.); }
      else { p_ast->crval1*=(TT_PI/180.);}
      if (dvalue<=0) {p_ast->crval1=p_ast->ra0;}
   }
   strcpy(keyname,"CRVAL2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
      p_ast->crval2=p_ast->dec0;
   } else {
      valid_crvp++;
      valid_cd++;
      if (crval2found==TT_NO) { valid_optic++; }
      dvalue=atof(value_char);
      if ((dvalue>=-90)&&(dvalue<=90)) { p_ast->crval2=dvalue; }
      if ((strcmp(unit,"deg")==0)||(strcmp(unit,"degrees")==0)) { p_ast->crval2*=(TT_PI/180.); }
      else { p_ast->crval2*=(TT_PI/180.);}
   }

   /* --- complete les validites --- */
   if (crota2found==TT_NO) {
      p_ast->crota2=0.;
      valid_optic++;
      valid_crvp++;
   }
   if ((crpix1found==TT_NO)) {
      p_ast->crpix1=p_ima->naxis1/2.;
      valid_optic++;
   }
   if ((crpix2found==TT_NO)) {
      p_ast->crpix2=p_ima->naxis2/2.;
      valid_optic++;
   }

   /* -- condition de validite --- */
   if ((valid_optic>=8)||(valid_cd>=8)||(valid_crvp>=7)) {
      v=TT_YES;
   } else {
      v=TT_NO;
   }
   *valid=v;

   /* --- transcodage --- */
   if ((valid_optic>=8)&&(valid_crvp<7)) {
      if ((p_ast->foclen!=0)&&(p_ast->px!=0)&&(p_ast->py!=0)) {
         p_ast->cdelta1=-2*atan(p_ast->px/2./p_ast->foclen);
         p_ast->cdelta2=2*atan(p_ast->py/2./p_ast->foclen);
      }
   }

   if (valid_cd>=8) {
      tt_util_cd2cdelt_old(p_ast->cd11,p_ast->cd12,p_ast->cd21,p_ast->cd22,&p_ast->cdelta1,&p_ast->cdelta2,&p_ast->crota2);
   } else if ((valid_optic>=8)||(valid_crvp>=7)) {
      p_ast->cd11=p_ast->cdelta1*cos(p_ast->crota2);
      p_ast->cd12=fabs(p_ast->cdelta2)*p_ast->cdelta1/fabs(p_ast->cdelta1)*sin(p_ast->crota2);
      p_ast->cd21=-fabs(p_ast->cdelta1)*p_ast->cdelta2/fabs(p_ast->cdelta2)*sin(p_ast->crota2);
      p_ast->cd22=p_ast->cdelta2*cos(p_ast->crota2);
   }

   if ((p_ast->foclen==0.)&&(p_ast->px!=0.)&&(p_ast->py!=0.)&&(p_ast->cdelta1!=0.)&&(p_ast->cdelta2!=0.)) {
      p_ast->foclen=fabs(p_ast->px/2./tan(p_ast->cdelta1/2.));
      p_ast->foclen+=fabs(p_ast->py/2./tan(p_ast->cdelta2/2.));
      p_ast->foclen/=2.;
   }

   /* --- TT_WCS structure --- */
   wcs->valid=1;
   strcpy(keyname,"CRPIX1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->crpix1 = atof(value_char);
   }
   strcpy(keyname,"CRPIX2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->crpix2 = atof(value_char);
   }
   strcpy(keyname,"CRVAL1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->crval1 = atof(value_char);
   }
   strcpy(keyname,"CRVAL2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->crval2 = atof(value_char);
   }
   strcpy(keyname,"EQUINOX");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      strcpy(wcs->equinox,value_char);
   } else {
      strcpy(wcs->equinox,"J2000");
   }
   strcpy(keyname,"RADECSYS");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      strcpy(wcs->radecsys,value_char);
   } else {
      strcpy(wcs->radecsys,"FK5");
   }
   // -- scale
   kcd=0;
   strcpy(keyname,"CD1_1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->cd11= atof(value_char);
      kcd++;
   }
   strcpy(keyname,"CD1_2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->cd12= atof(value_char);
      kcd++;
   }
   strcpy(keyname,"CD2_1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->cd21= atof(value_char);
      kcd++;
   }
   strcpy(keyname,"CD2_2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->cd22= atof(value_char);
      kcd++;
   }
   kc=0;
   strcpy(keyname,"CDELT1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->cdelt1= atof(value_char);
      kc++;
   }
   strcpy(keyname,"CDELT2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->cdelt2= atof(value_char);
      kc++;
   }
   strcpy(keyname,"CROTA2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->crota2= atof(value_char);
   }
   wcs->pi=4*atan(1.);
   if (kcd<4) {
      if (kc<2) {
         wcs->valid=0;
         return(TT_ERR_WCS_KEYWORD_NOT_FOUND);
      }
      tt_wcs_cdelt2cd(wcs);
   } else {
      tt_wcs_cd2cdelt(wcs);
   }
   tt_wcs_builder(wcs); 
   // ---
   strcpy(keyname,"FOCLEN");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->foclen= atof(value_char);
      is_foclen=1;
   } else {
      is_foclen=0;
   }
   strcpy(keyname,"PIXSIZE1");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->pixsize1= atof(value_char);
      is_pixsize1=1;
   } else {
      is_pixsize1=0;
   }
   strcpy(keyname,"PIXSIZE2");
   if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))==0) {
      wcs->pixsize2= atof(value_char);
      is_pixsize2=1;
   } else {
      is_pixsize2=0;
   }
   tt_wcs_update_optic(wcs,is_foclen,is_pixsize1,is_pixsize2);

   /* --- Distorsions ---*/
#ifdef TT_DISTORASTROM
   valid_pv=0;
   for (k1=1;k1<=2;k1++) {
      for (k2=0;k2<=10;k2++) {
         sprintf(keyname,"PV%d_%d",k1,k2);
         if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
            return(msg);
         }
         if (datatype!=0) {
            valid_pv++;
         }
      }
   }
   if (valid_pv>=20) {
      for (k1=1;k1<=2;k1++) {
         for (k2=0;k2<=10;k2++) {
            sprintf(keyname,"PV%d_%d",k1,k2);
            if ((msg=tt_imareturnkeyvalue(p_ima,keyname,value_char,&datatype,comment,unit))!=0) {
               return(msg);
            }
            if (datatype!=0) {
               p_ast->pv[k1][k2]=atof(value_char);
            }
         }
      }
      p_ast->pv_valid=TT_YES;
   }
#endif

   return(OK_DLL);
}

// =================================================================
//  WCS structure -> update FOCLEN or PIXSIZE1, PIXSIZE2 keywords
// -----------------------------------------------------------------
int tt_wcs_update_optic(TT_WCS *wcs,int is_foclen,int is_pixsize1,int is_pixsize2)
{
   double mult,pixsize1_mu=0,pixsize2_mu=0,foclen1_m=0,foclen2_m=0,foclen_m=0;
   mult = 1e-6;
   if ((is_pixsize1!=0)&&(is_pixsize2!=0)&&(is_pixsize1==0)&&(is_pixsize2==0)&&(is_foclen==0)) {
      pixsize1_mu = wcs->pixsize1; 
      pixsize2_mu = wcs->pixsize2;
      foclen1_m = pixsize1_mu*mult/(2.*tan(fabs(wcs->cdelt1)*wcs->pi/180/2));
      foclen2_m = pixsize2_mu*mult/(2.*tan(fabs(wcs->cdelt2)*wcs->pi/180/2));
      foclen_m = (foclen1_m+foclen2_m)/2.;
   }
   if ((is_foclen!=0)&&(pixsize1_mu!=0)&&(pixsize2_mu!=0)&&(foclen_m==0)) {
      foclen_m = wcs->foclen;
      pixsize1_mu = foclen_m/mult*(2.*tan(fabs(wcs->cdelt1)*wcs->pi/180/2));
      pixsize2_mu = foclen_m/mult*(2.*tan(fabs(wcs->cdelt2)*wcs->pi/180/2));
   }
   if ((pixsize1_mu!=0)&&(pixsize2_mu!=0)&&(foclen_m!=0)) {
      wcs->foclen = foclen_m;
      wcs->pixsize1 = pixsize1_mu;
      wcs->pixsize2 = pixsize2_mu;
   }
   return 0;
}

// =================================================================
// CDELT -> CD matrix
// -----------------------------------------------------------------
int tt_wcs_cdelt2cd(TT_WCS *wcs) 
{
   double rho,cosrho,sinrho;
   // formule (193)
   rho = wcs->crota2*wcs->pi/180;
   cosrho = cos(rho);
   sinrho = sin(rho);
   wcs->cd11 =  wcs->cdelt1*cosrho;
   wcs->cd12 = -wcs->cdelt1*sinrho;
   wcs->cd11 =  wcs->cdelt2*sinrho;
   wcs->cd22 =  wcs->cdelt2*cosrho;
   return 0;
}

// =================================================================
// CD matrix -> CDELT
// -----------------------------------------------------------------
int tt_wcs_cd2cdelt(TT_WCS *wcs) 
{
   double rho,cosrho,sinrho;
   double rhoa,rhob,pisur2,drho;
   // formule (191)
   if (wcs->cd21==0) {
      rhoa = 0;
   } else if (wcs->cd21<0) {
      rhoa = atan2( -wcs->cd21, -wcs->cd11);
   } else {
      rhoa = atan2(  wcs->cd21 ,  wcs->cd11);
   }
   if (wcs->cd12==0) {
      rhob = 0;
   } else if (wcs->cd12<0) {
      rhob = atan2( -wcs->cd12,  wcs->cd22);
   } else {
      rhob = atan2(  wcs->cd12, -wcs->cd22 );
   }
   // cas +/-pi
   drho = fabs(rhob-rhoa);
   pisur2 = wcs->pi/2.;
   if (drho>pisur2) {
      rhob = rhob+wcs->pi;
   }
   // formule (192)
   cosrho = (cos(rhoa) + cos(rhob))/2.;
   sinrho = (sin(rhoa) + sin(rhob))/2.;
   rho = atan2( sinrho , cosrho );
   // formule (193)
   wcs->cdelt1 = wcs->cd11 / cosrho;
   wcs->cdelt2 = wcs->cd22 / cosrho;
   wcs->crota2 = rho*180/wcs->pi;
   if (wcs->cdelt1>0) {
      wcs->cdelt1 = -1*wcs->cdelt1;
      wcs->cdelt2 = -1*wcs->cdelt2;
      wcs->crota2 = wcs->crota2+180;
      if (wcs->crota2>180) {
         wcs->crota2 -= 360;
      }
   }
   return 0;
}

// =================================================================
// kwd values -> WCS structure
// -----------------------------------------------------------------
int tt_wcs_builder(TT_WCS *wcs) 
{
   /* --- public+ ---*/
   wcs->wcsaxes = 2; // "WCS dimensionality" ""
   wcs->lonpole = 180; // "Long. of the celest.NP in native coor.syst." deg
   strcpy(wcs->ctype1,"RA---TAN"); // "Gnomonic projection" ""
   strcpy(wcs->ctype2,"DEC--TAN"); // "Gnomonic projection" ""
   strcpy(wcs->cunit1,"deg"); // "Angles are degrees always" ""
   strcpy(wcs->cunit2,"deg"); // "Angles are degrees always" ""
   /* === private ===*/
   wcs->pi = 4*atan(1.); // "Pi number" ""
   wcs->dr = wcs->pi/180; // "deg->rad factor" ""
   wcs->phip = wcs->pi; // "Phi pole gnomonic" "rad"
   wcs->r1 = wcs->crpix1; // "X pole along NAXIS1" "pix"
   wcs->r2 = wcs->crpix2; // "Y pole along NAXIS2" "pix"
   wcs->rap = wcs->crval1*wcs->pi/180; // "alpha pole" "rad"
   wcs->decp = wcs->crval2*wcs->pi/180; // "delta pole" "rad"
   wcs->cosdecp = cos(wcs->decp); // "cos delta pole" ""
   wcs->sindecp = sin(wcs->decp); // "sin delta pole" ""
   wcs->sm11 = wcs->cd11*wcs->pi/180; // "CD matrix 11" "rad/pix"
   wcs->sm12 = wcs->cd12*wcs->pi/180; // "CD matrix 12" "rad/pix"
   wcs->sm21 = wcs->cd21*wcs->pi/180; // "CD matrix 21" "rad/pix"
   wcs->sm22 = wcs->cd22*wcs->pi/180; // "CD matrix 22" "rad/pix"
   /* --- apparent parameters --- */
   /*
   wcs->date[30]; // "Date of mid exposure" ""
   wcs->home[30]; // home  $home private "Home" "GPS"
   */
   wcs->pressure_Pa = 101325; // "Atm. Pressure" "Pa"
   wcs->temperature_K = 290; // "Atm. Temperature" "K"
   wcs->humidity_percent = 40; // "Atm. humidity" "percent"
   wcs->wavelength_nm = 550; // "Wavelength" "nm"
   /* --- optic ---*/
   /*
   wcs->foclen; // focale en m
   wcs->pixsize1; // pixel en m
   wcs->pixsize2;
   wcs->dec0;
   wcs->ra0;
   */
   /*-----*/
   /*
   wcs->pv_valid;
   wcs->pv[3][11];
   */
   return 0;
}



int tt_astrom_release(TT_IMA *p)
/***************************************************************************/
/* transcode les mots cles d'astrometrie du DSS en mots cles standards.    */
/*                                                                         */
/* La lecture des mots cles d'astrometrie standard est prioritaire         */
/* par rapport a celle du DSS. Les mots cles du DSS ne sont donc pas       */
/* reconnus si les mots cles du FITS standard sont presents.               */
/* L'entete DSS est convertie en mots FITS standard a la sauvegarde.       */
/***************************************************************************/
{
   TT_ASTROM p_ast;
   char keyname[FLEN_KEYWORD];
   char value_char[FLEN_VALUE];
   char comment[FLEN_COMMENT];
   char unit[FLEN_COMMENT];
   int datatype;
   int msg;
   double xc=0.,yc=0.,px=0.,py=0.,a1=0.,pltrah=0.,pltram=0.,pltras=0.;
   double pltdecsn=0.,pltdecd=0.,pltdecm=0.,pltdecs=0.,cnpix1=0.,cnpix2=0.;
   int valid_dss=0;
   double lambda;
   int valid;
   /*double det;*/

   if ((msg=tt_util_getkey0_astrometry(p,&p_ast,&valid))!=OK_DLL) {
      return(PB_DLL);
   }
   if (valid==TT_YES) { return(OK_DLL); }

   /* --- mots cle du DSS http://archive.stsci.edu/cgi-bin/dss_form ---*/
   strcpy(keyname,"PPO3");
   if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {
      return(msg);
   }
   if (datatype==0) {
   } else {
      valid_dss++;
      xc=atof(value_char);
      strcpy(keyname,"PPO6");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         yc=atof(value_char);
      }
      strcpy(keyname,"XPIXELSZ");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         px=atof(value_char);
      }
      strcpy(keyname,"YPIXELSZ");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         py=atof(value_char);
      }
      strcpy(keyname,"AMDX1");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         a1=atof(value_char);
      }
      strcpy(keyname,"PLTRAH");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltrah=atof(value_char);
      }
      strcpy(keyname,"PLTRAM");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltram=atof(value_char);
      }
      strcpy(keyname,"PLTRAS");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltras=atof(value_char);
      }
      strcpy(keyname,"PLTDECSN");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltdecsn=(value_char[0]=='+')?1.:-1.;
      }
      strcpy(keyname,"PLTDECD");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltdecd=atof(value_char);
      }
      strcpy(keyname,"PLTDECM");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltdecm=atof(value_char);
      }
      strcpy(keyname,"PLTDECS");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         pltdecs=atof(value_char);
      }
      strcpy(keyname,"CNPIX1");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         cnpix1=atof(value_char);
      }
      strcpy(keyname,"CNPIX2");
      if ((msg=tt_imareturnkeyvalue(p,keyname,value_char,&datatype,comment,unit))!=0) {return(msg);} if (datatype==0) {} else {
         valid_dss++;
         cnpix2=atof(value_char);
      }
   }
   if (valid_dss>=14) {
      if ((px!=0)&&(py!=0)&&(a1!=0)) {
         p_ast.crpix1=(xc/px)-(cnpix1-.5);
         p_ast.crpix2=(yc/py)-(cnpix2-.5);
         p_ast.crval1=((pltrah+pltram/60.+pltras/3600.)*15.)*(TT_PI)/180.;
         p_ast.ra0=p_ast.crval1;
         p_ast.crval2=pltdecsn*(pltdecd+pltdecm/60.+pltdecs/3600.)*(TT_PI)/180.;
         p_ast.dec0=p_ast.crval2;
         lambda=3600./a1;
         p_ast.cd11=-px/(1000.*lambda)*(TT_PI)/180.;
         p_ast.cd12=0.;
         p_ast.cd21=0.;
         p_ast.cd22=py/(1000.*lambda)*(TT_PI)/180.;
         tt_util_cd2cdelt_old(p_ast.cd11,p_ast.cd12,p_ast.cd21,p_ast.cd22,&p_ast.cdelta1,&p_ast.cdelta2,&p_ast.crota2);
         p_ast.px=px*1e-6;
         p_ast.py=py*1e-6;
         // --- WCS
         p_ast.wcs.crpix1=p_ast.crpix1;
         p_ast.wcs.crpix2=p_ast.crpix2;
         p_ast.wcs.crval1=p_ast.crval1*180/TT_PI;
         p_ast.wcs.crval2=p_ast.crval2*180/TT_PI;
         p_ast.wcs.cd11=p_ast.cd11*180/TT_PI;
         p_ast.wcs.cd21=p_ast.cd21*180/TT_PI;
         p_ast.wcs.cd12=p_ast.cd12*180/TT_PI;
         p_ast.wcs.cd22=p_ast.cd22*180/TT_PI;
         p_ast.wcs.pixsize1=px;
         p_ast.wcs.pixsize2=px;
      }
      if ((msg=tt_util_putnewkey_astrometry(p,&p_ast))!=OK_DLL) {
         return(msg);
      }
      /* -- il faut maintenant ajouter les newkeys a la liste keys ---*/
   }
   return(OK_DLL);
}

int tt_util_update_wcs(TT_IMA *p_in,TT_IMA *p_out,double *a,int method,TT_ASTROM *p_ast)
/***************************************************************************/
/* Utilitaire de mise a jour des mots cles d'astrometrie apres une         */
/* transformation lineaire definie par 6 coefficients.                     */
/*                                                                         */
/* method=1 : calibration astrometrique                                    */
/* method=2 : transformation geometrique                                   */
/*                                                                         */
/* Si p_ast!=NULL alors on retourne la structure TT_ASTROM pour l'ordre 1  */
/***************************************************************************/
{
   TT_ASTROM p;
   int valid=TT_NO;
   if (method==1) {
      tt_util_get_new_wcs_crval(p_in,a,&p,&valid);
   } else {
      tt_util_get_new_wcs_crpix(p_in,a,&p,&valid);
   }
   if (valid==TT_YES) {
      tt_util_putnewkey_astrometry(p_out,&p);
   }
   if (p_ast!=NULL) {
      *p_ast=p;
      p_ast->pv_valid=TT_NO;
   }
   return(OK_DLL);
}

int tt_util_cd2cdelt_new(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2)
/***************************************************************************/
/* Utilitaire qui tranforme les mots wcs de la matrice cd vers les         */
/* vieux mots cle cdelt1, cdelt2 et crota2.                                */
/***************************************************************************/
{
   double cdp1,cdp2,crotap2;
   double deuxpi,pisur2,sina,cosa,sinb,cosb,cosab,sinab,ab,aa,bb,cosr,sinr;

   deuxpi=2.*(TT_PI);
   pisur2=(TT_PI)/2.;

   aa=fmod(deuxpi+atan2(cd21,cd11),deuxpi);
   bb=fmod(deuxpi+atan2(-cd12,cd22),deuxpi);

   cosa=cos(aa);
   sina=sin(aa);
   cosb=cos(bb);
   sinb=sin(bb);

   /* a-b */
   cosab=cosa*cosb+sina*sinb;
   sinab=sina*cosb-cosa*sinb;
   ab=fabs(atan2(sinab,cosab));

   /* cas |a-b| proche de PI */
   if (ab>pisur2) {
      if (cosa>cosb) {
         bb=fmod((TT_PI)+bb,deuxpi);
      } else {
         aa=fmod((TT_PI)+aa,deuxpi);
      }
   }

   /* mean (a+b)/2 */
   ab=bb-aa;
   if (ab>TT_PI) {
      aa=aa+deuxpi;
   }
   ab=aa-bb;
   if (ab>TT_PI) {
      bb=bb+deuxpi;
   }
   crotap2=fmod(deuxpi+(aa+bb)/2.,deuxpi);

   cosr=fabs(cos(crotap2));
   sinr=fabs(sin(crotap2));

   /* cdelt */
   if (cosr>sinr) {
      cdp1=cd11/cos(crotap2);
      cdp2=cd22/cos(crotap2);
   } else {
      cdp1= cd21/sin(crotap2);
      cdp2=-cd12/sin(crotap2);
   }

   *cdelt1=cdp1;
   *cdelt2=cdp2;
   *crota2=crotap2;
   return(OK_DLL);
}

int tt_util_cd2cdelt_old(double cd11,double cd12,double cd21,double cd22,double *cdelt1,double *cdelt2,double *crota2)
/***************************************************************************/
/* Utilitaire qui tranforme les mots wcs de la matrice cd vers les         */
/* vieux mots cle cdelt1, cdelt2 et crota2.                                */
/***************************************************************************/
{
   double cdp1,cdp2,crotap2;
   double deuxpi,pisur2,sina,cosa,sinb,cosb,cosab,sinab,ab,aa,bb,cosr,sinr;
   double signr,signc,signd;

   deuxpi=2.*(TT_PI);
   pisur2=(TT_PI)/2.;

   aa=fmod(deuxpi+atan2(cd21,cd11),deuxpi);
   bb=fmod(deuxpi+atan2(-cd12,cd22),deuxpi);

   cosa=cos(aa);
   sina=sin(aa);
   cosb=cos(bb);
   sinb=sin(bb);

   /* a-b */
   cosab=cosa*cosb+sina*sinb;
   sinab=sina*cosb-cosa*sinb;
   ab=fabs(atan2(sinab,cosab));

   /* cas |a-b| proche de PI */
   if (ab>pisur2) {
      if (cosa>cosb) {
         bb=fmod((TT_PI)+bb,deuxpi);
      } else {
         aa=fmod((TT_PI)+aa,deuxpi);
      }
   }

   /* mean (a+b)/2 */
   ab=bb-aa;
   if (ab>TT_PI) {
      aa=aa+deuxpi;
   }
   ab=aa-bb;
   if (ab>TT_PI) {
      bb=bb+deuxpi;
   }
   crotap2=fmod(deuxpi+(aa+bb)/2.,deuxpi);

   cosr=fabs(cos(crotap2));
   sinr=fabs(sin(crotap2));

   /* cdelt */
   if (cosr>sinr) {
      cdp1=cd11/cos(crotap2);
      cdp2=cd22/cos(crotap2);
   } else {
      cdp1=fabs(-cd21/sin(crotap2));
      cdp2=fabs( cd12/sin(crotap2));
      signr=sinr/fabs(sinr);
      /**/
      signc=cd12/fabs(cd12);
      signd=signc/signr;
      if (signd<0) { cdp1*=-1.; }
      /**/
      signc=cd21/fabs(cd21);
      signd=-signc/signr;
      if (signd<0) { cdp2*=-1.; }
   }

   *cdelt1=cdp1;
   *cdelt2=cdp2;
   *crota2=crotap2;
   return(OK_DLL);
}

int tt_util_get_new_wcs_crval(TT_IMA *p_in,double *a,TT_ASTROM *p,int *valid)
/***************************************************************************/
/* Utilitaire qui calcule les elements de la structure d'astrometrie       */
/* a partir de la transformation lineaire definie par 6 coefficients.      */
/*                                                                         */
/* On modifie CRVAL et on fixe CRPIX (calibration astrometrique)           */
/***************************************************************************/
{
   double cdp11,cdp12,cdp21,cdp22,valp1,valp2;
#ifdef TT_OLD_ASTROM
   double cdp1,cdp2,crotap2;
#endif
   /*double det;*/
   double x2,y2,x1,y1;

   /* --- recherche des parametres de la projection dans l'entete ---*/
   tt_util_getkey_astrometry(p_in,p);

#ifdef TT_OLD_ASTROM
   /* --- verifie si les mots cles WCS sont valides (=presents) ---*/
   *valid=TT_YES;
   if ((p->cdelta1==0.)&&(p->cdelta2==0.)) {
      /* --- pas de WCS dans l'entete, on sort ---*/
      *valid=TT_NO;
      return(OK_DLL);
   }

   /* --- calcule les nouveaux parametres de projection ---*/
   x1=p->crpix1-.5;y1=p->crpix2-.5;
   x2=a[0]*x1+a[1]*y1+a[2];
   y2=a[3]*x1+a[4]*y1+a[5];
   tt_util_astrom_xy2radec(p,x2,y2,&valp1,&valp2);
   cdp11=p->cd11*a[0]+p->cd12*a[3];
   cdp12=p->cd11*a[1]+p->cd12*a[4];
   cdp21=p->cd21*a[0]+p->cd22*a[3];
   cdp22=p->cd21*a[1]+p->cd22*a[4];

   /* --- calcule les parametres ancienne convention ---*/
   /*
   crotap2=tt_atan2((cdp12-cdp21),(cdp11+cdp22));
   cdp1=sqrt(cdp11*cdp11+cdp21*cdp21);
   det=cdp11*cos(crotap2);
   if (det<0) {cdp1*=-1.;}
   cdp2=sqrt(cdp12*cdp12+cdp22*cdp22);
   det=cdp22*cos(crotap2);
   if (det<0) {cdp2*=-1.;}
   */
   tt_util_cd2cdelt_old(cdp11,cdp12,cdp21,cdp22,&cdp1,&cdp2,&crotap2);

   p->cd11=cdp11;
   p->cd12=cdp12;
   p->cd21=cdp21;
   p->cd22=cdp22;
   p->crval1=valp1;
   p->crval2=valp2;
   p->cdelta1=cdp1;
   p->cdelta2=cdp2;
   p->crota2=crotap2;
#else
   /* --- verifie si les mots cles WCS sont valides (=presents) ---*/
   *valid=TT_YES;
   if ((p->wcs.cdelt1==0.)&&(p->wcs.cdelt2==0.)) {
      /* --- pas de WCS dans l'entete, on sort ---*/
      *valid=TT_NO;
      return(OK_DLL);
   }

   /* --- calcule les nouveaux parametres de projection ---*/
   x1=p->wcs.crpix1;y1=p->wcs.crpix2;
   x2=a[0]*x1+a[1]*y1+a[2];
   y2=a[3]*x1+a[4]*y1+a[5];
   tt_util_astrom_xy2radec(p,x2,y2,&valp1,&valp2);
   valp1/=p->wcs.dr;
   valp2/=p->wcs.dr;
   cdp11=p->wcs.cd11*a[0]+p->wcs.cd12*a[3];
   cdp12=p->wcs.cd11*a[1]+p->wcs.cd12*a[4];
   cdp21=p->wcs.cd21*a[0]+p->wcs.cd22*a[3];
   cdp22=p->wcs.cd21*a[1]+p->wcs.cd22*a[4];
   p->wcs.cd11=cdp11;
   p->wcs.cd12=cdp12;
   p->wcs.cd21=cdp21;
   p->wcs.cd22=cdp22;
   p->wcs.crval1=valp1;
   p->wcs.crval2=valp2;
   tt_wcs_cd2cdelt(&p->wcs); 
#endif
   return(OK_DLL);
}

int tt_util_get_new_wcs_crpix(TT_IMA *p_in,double *a,TT_ASTROM *p,int *valid)
/***************************************************************************/
/* Utilitaire qui calcule les elements de la structure d'astrometrie       */
/* a partir de la transformation lineaire definie par 6 coefficients.      */
/*                                                                         */
/* On modifie CRPIX et on fixe CRVAL (transformations geometriques)        */
/***************************************************************************/
{
   double cdp11,cdp12,cdp21,cdp22;
#ifdef TT_OLD_ASTROM
   double cdp1,cdp2,crotap2;
   int k1,k2;
#endif
   /*double det;*/
   double x2,y2,x1,y1;
   double aa[6];

   /* --- recherche des parametres de la projection dans l'entete ---*/
   tt_util_getkey_astrometry(p_in,p);

#ifdef TT_OLD_ASTROM
   /* --- verifie si les mots cles WCS sont valides (=presents) ---*/
   *valid=TT_YES;
   if ((p->cdelta1==0.)&&(p->cdelta2==0.)) {
      /* --- pas de WCS dans l'entete, on sort ---*/
      *valid=TT_NO;
      return(OK_DLL);
   }

   if (p->pv_valid==TT_YES) {
      /* --- il faudra regarder les PV un de ces jours */
      for (k1=0;k1<=2;k1++) {
         for (k2=0;k2<=10;k2++) {
            p->pv[k1][k2]=0.0;
         }
      }
      p->pv[1][1]=1.0;
      p->pv[2][1]=1.0;
   }

   tt_util_matrice_inverse_bilinaire(a,aa);

   /* --- calcule les nouveaux parametres de projection ---*/
   x1=p->crpix1;y1=p->crpix2;
   x2=aa[0]*x1+aa[1]*y1+aa[2];
   y2=aa[3]*x1+aa[4]*y1+aa[5];
   cdp11=(p->cd11*a[0]+p->cd12*a[3]);
   cdp12=(p->cd11*a[1]+p->cd12*a[4]);
   cdp21=(p->cd21*a[0]+p->cd22*a[3]);
   cdp22=(p->cd21*a[1]+p->cd22*a[4]);

   tt_util_cd2cdelt_old(cdp11,cdp12,cdp21,cdp22,&cdp1,&cdp2,&crotap2);

   p->cd11=cdp11;
   p->cd12=cdp12;
   p->cd21=cdp21;
   p->cd22=cdp22;
   p->crpix1=x2;
   p->crpix2=y2;
   p->cdelta1=cdp1;
   p->cdelta2=cdp2;
   p->crota2=crotap2;
#else
   /* --- verifie si les mots cles WCS sont valides (=presents) ---*/
   *valid=TT_YES;
   if ((p->wcs.cdelt1==0.)&&(p->wcs.cdelt2==0.)) {
      /* --- pas de WCS dans l'entete, on sort ---*/
      *valid=TT_NO;
      return(OK_DLL);
   }
   tt_util_matrice_inverse_bilinaire(a,aa);

   /* --- calcule les nouveaux parametres de projection ---*/
   x1=p->wcs.crpix1;y1=p->wcs.crpix2;
   x2=aa[0]*x1+aa[1]*y1+aa[2];
   y2=aa[3]*x1+aa[4]*y1+aa[5];
   cdp11=(p->wcs.cd11*a[0]+p->wcs.cd12*a[3]);
   cdp12=(p->wcs.cd11*a[1]+p->wcs.cd12*a[4]);
   cdp21=(p->wcs.cd21*a[0]+p->wcs.cd22*a[3]);
   cdp22=(p->wcs.cd21*a[1]+p->wcs.cd22*a[4]);
   p->wcs.cd11=cdp11;
   p->wcs.cd12=cdp12;
   p->wcs.cd21=cdp21;
   p->wcs.cd22=cdp22;
   p->wcs.crpix1=x2;
   p->wcs.crpix2=y2;
   tt_wcs_cd2cdelt(&p->wcs); 
#endif
   return(OK_DLL);
}

int tt_util_set_pv(TT_IMA *p_out,double *a,double *b,TT_ASTROM *p_ast)
/***************************************************************************/
/* Update of the second order astrometric calibration keywords of FITS     */
/* a=a et b=a2                                                             */
/*                                                                         */
/* Si p_ast!=NULL alors on retourne la structure TT_ASTROM pour l'ordre 3  */
/***************************************************************************/
{
   double delta1,c[20],vald;
   int k;
   for (k=0;k<20;k++) {
      c[k]=0.0;
   }
   c[0]=1.0;
   c[11]=1.0;
   delta1=(a[1]*a[3]-a[0]*a[4]);
   if (delta1!=0) {
      c[0]=(a[1]*b[10]-a[4]*b[0])/delta1;
      c[1]=(a[1]*b[11]-a[4]*b[1])/delta1;
      c[2]=(a[1]*b[12]-a[4]*(b[2]-a[2]))/delta1;
      c[3]=(a[1]*b[13]-a[4]*b[3])/delta1;
      c[4]=(a[1]*b[14]-a[4]*b[4])/delta1;
      c[5]=(a[1]*b[15]-a[4]*b[5])/delta1;
      c[6]=(a[1]*b[16]-a[4]*b[6])/delta1;
      c[7]=(a[1]*b[17]-a[4]*b[7])/delta1;
      c[8]=(a[1]*b[18]-a[4]*b[8])/delta1;
      c[9]=(a[1]*b[19]-a[4]*b[9])/delta1;
      c[10]=(a[3]*b[0]-a[0]*b[10])/delta1;
      c[11]=(a[3]*b[1]-a[0]*b[11])/delta1;
      c[12]=(a[3]*b[2]-a[0]*(b[12]-a[5]))/delta1;
      c[13]=(a[3]*b[3]-a[0]*b[13])/delta1;
      c[14]=(a[3]*b[4]-a[0]*b[14])/delta1;
      c[15]=(a[3]*b[5]-a[0]*b[15])/delta1;
      c[16]=(a[3]*b[6]-a[0]*b[16])/delta1;
      c[17]=(a[3]*b[7]-a[0]*b[17])/delta1;
      c[18]=(a[3]*b[8]-a[0]*b[18])/delta1;
      c[19]=(a[3]*b[9]-a[0]*b[19])/delta1;
   }
   vald=c[2];
   tt_imanewkey(p_out,"PV1_0",&(vald),TDOUBLE,"Distortion 1 constant","pix");
   vald=c[0];
   tt_imanewkey(p_out,"PV1_1",&(vald),TDOUBLE,"Distortion 1 x","pix**-1");
   vald=c[1];
   tt_imanewkey(p_out,"PV1_2",&(vald),TDOUBLE,"Distortion 1 y","pix**-1");
   vald=0.;
   tt_imanewkey(p_out,"PV1_3",&(vald),TDOUBLE,"Distortion 1 r","pix**-1");
   vald=c[4];
   tt_imanewkey(p_out,"PV1_4",&(vald),TDOUBLE,"Distortion 1 x2","pix**-2");
   vald=c[3];
   tt_imanewkey(p_out,"PV1_5",&(vald),TDOUBLE,"Distortion 1 xy","pix**-2");
   vald=c[5];
   tt_imanewkey(p_out,"PV1_6",&(vald),TDOUBLE,"Distortion 1 y2","pix**-2");
   vald=c[8];
   tt_imanewkey(p_out,"PV1_7",&(vald),TDOUBLE,"Distortion 1 x3","pix**-3");
   vald=c[6];
   tt_imanewkey(p_out,"PV1_8",&(vald),TDOUBLE,"Distortion 1 x2y","pix**-3");
   vald=c[7];
   tt_imanewkey(p_out,"PV1_9",&(vald),TDOUBLE,"Distortion 1 xy2","pix**-3");
   vald=c[9];
   tt_imanewkey(p_out,"PV1_10",&(vald),TDOUBLE,"Distortion 1 y3","pix**-3");
   vald=c[12];
   tt_imanewkey(p_out,"PV2_0",&(vald),TDOUBLE,"Distortion 2 constant","pix");
   vald=c[11];
   tt_imanewkey(p_out,"PV2_1",&(vald),TDOUBLE,"Distortion 2 y","pix**-1");
   vald=c[10];
   tt_imanewkey(p_out,"PV2_2",&(vald),TDOUBLE,"Distortion 2 x","pix**-1");
   vald=0.;
   tt_imanewkey(p_out,"PV2_3",&(vald),TDOUBLE,"Distortion 2 r","pix**-1");
   vald=c[15];
   tt_imanewkey(p_out,"PV2_4",&(vald),TDOUBLE,"Distortion 2 y2","pix**-2");
   vald=c[13];
   tt_imanewkey(p_out,"PV2_5",&(vald),TDOUBLE,"Distortion 2 yx","pix**-2");
   vald=c[14];
   tt_imanewkey(p_out,"PV2_6",&(vald),TDOUBLE,"Distortion 2 x2","pix**-2");
   vald=c[19];
   tt_imanewkey(p_out,"PV2_7",&(vald),TDOUBLE,"Distortion 2 x3","pix**-3");
   vald=c[17];
   tt_imanewkey(p_out,"PV2_8",&(vald),TDOUBLE,"Distortion 2 x2y","pix**-3");
   vald=c[16];
   tt_imanewkey(p_out,"PV2_9",&(vald),TDOUBLE,"Distortion 2 xy2","pix**-3");
   vald=c[18];
   tt_imanewkey(p_out,"PV2_10",&(vald),TDOUBLE,"Distortion 2 y3","pix**-3");
   if (p_ast!=NULL) {
      p_ast->pv[1][0]=c[2];
      p_ast->pv[1][1]=c[0];
      p_ast->pv[1][2]=c[1];
      p_ast->pv[1][3]=0.;
      p_ast->pv[1][4]=c[4];
      p_ast->pv[1][5]=c[3];
      p_ast->pv[1][6]=c[5];
      p_ast->pv[1][7]=c[8];
      p_ast->pv[1][8]=c[6];
      p_ast->pv[1][9]=c[7];
      p_ast->pv[1][10]=c[9];
      p_ast->pv[2][0]=c[12];
      p_ast->pv[2][1]=c[11];
      p_ast->pv[2][2]=c[10];
      p_ast->pv[2][3]=0.;
      p_ast->pv[2][4]=c[15];
      p_ast->pv[2][5]=c[13];
      p_ast->pv[2][6]=c[14];
      p_ast->pv[2][7]=c[19];
      p_ast->pv[2][8]=c[17];
      p_ast->pv[2][9]=c[16];
      p_ast->pv[2][10]=c[18];
      p_ast->pv_valid=TT_YES;
   }
   return(OK_DLL);
}

int tt_util_match_translate(TT_IMA *p_ref,TT_IMA *p_in,double *a,int *nbmatched)
/***************************************************************************/
/* matching de listes d'objets pour une contrainte en translation          */
/***************************************************************************/
/* le tableau a[6] contient la transformation :                            */
/*  x_in/ref = a[0]*x_in/in + a[1]*y_in/in + a[2]                          */
/*  y_in/ref = a[3]*x_in/in + a[4]*y_in/in + a[5]                          */
/*                                                                         */
/***************************************************************************/
{
   int nbap,nbapmax,nbsortie,nrows_in,nrows_ref,k,kk,kkmax;
   int nrows1_in,nrows1_ref;
   double tx,ty,x,y,xx,yy,dist_detec,ttx=0.,tty=0.;
   double *dist_in,*dist_ref;
   int k_ref,k_in,kk_ref,kk_in,kc_ref,kc_in,*index_in,*index_ref,msg;
   double n_in,n_ref,d_in,d_ref;
   double x0[5],y0[5];
   int nombre,taille;

   nrows_in=p_in->objelist->nrows;
   nrows_ref=p_ref->objelist->nrows;
   a[0]=1.;a[1]=0.;a[2]=0.;a[3]=0.;a[4]=1.;a[5]=0.;
   *nbmatched=0;
   if ((nrows_in==0)||(nrows_ref==0)) {
      return(OK_DLL);
   }
   nombre=nrows_in;
   taille=sizeof(double);
   dist_in=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dist_in,&nombre,&taille,"dist_in"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_match_translate for pointer dist_in");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nrows_in;
   taille=sizeof(int);
   index_in=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index_in,&nombre,&taille,"index_in"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_match_translate for pointer index_in");
      tt_free(dist_in,"dist_in");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nrows_ref;
   taille=sizeof(double);
   dist_ref=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&dist_ref,&nombre,&taille,"dist_ref"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_match_translate for pointer dist_ref");
      tt_free(index_in,"index_in");
      tt_free(dist_in,"dist_in");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nrows_ref;
   taille=sizeof(int);
   index_ref=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&index_ref,&nombre,&taille,"index_ref"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb calloc in tt_util_match_translate for pointer index_ref");
      tt_free(dist_ref,"dist_ref");
      tt_free(index_in,"index_in");
      tt_free(dist_in,"dist_in");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- definition des lieux de reference (4 coins et le centre) ---*/
   x0[0]=0.50*p_in->naxis1;y0[0]=0.50*p_in->naxis2;
   x0[1]=0.03*p_in->naxis1;y0[1]=0.03*p_in->naxis2;
   x0[2]=0.97*p_in->naxis1;y0[2]=0.03*p_in->naxis2;
   x0[3]=0.03*p_in->naxis1;y0[3]=0.97*p_in->naxis2;
   x0[4]=0.97*p_in->naxis1;y0[4]=0.97*p_in->naxis2;
   /* --- initialisation des variables de calcul ---*/
   dist_detec=2;
   nbapmax=0;
   nbsortie=0;
   /* --- boucle sur les etoiles les plus proches des lieus de reference ---*/
   for (k=0;k<5;k++) {
      /* --- calcule le nombre d'etoiles in ---*/
      for (k_in=0,kk_in=0;k_in<nrows_in;k_in++) {
         if (p_in->objelist->ident[k_in]!=TT_STAR) continue;
         kk_in++;
      }
      if (kk_in==0) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      /* --- calcule le nombre d'etoiles ref ---*/
      for (k_ref=0,kk_ref=0;k_ref<nrows_ref;k_ref++) {
         if (p_ref->objelist->ident[k_ref]!=TT_STAR) continue;
         kk_ref++;
      }
      if (kk_ref==0) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      /* --- calcule la distance moyenne des plus proches voisins ---*/
      n_in=(double)(p_in->naxis1*p_in->naxis2);
      n_ref=(double)(p_ref->naxis1*p_ref->naxis2);
      d_in=0.;
      d_ref=0.;
      if ((n_in!=0)&&(n_ref!=0)) {
         d_in=sqrt(n_in/kk_in)-1;
         d_ref=sqrt(n_ref/kk_ref)-1;
      } else {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      /* --- si la distance est trop petite ou le nombre d'etoiles trop grand ---*/
      /* --- alors on tronque les listes aux etoiles les plus brillantes.     ---*/
      if (kk_in<20) {
         nbsortie=kk_in;
      } else {
         nbsortie=(int)(20+kk_in*.1);
      }
      if (nbsortie>kk_in) { nbsortie=kk_in; }
      nrows1_in=nrows_in;
      nrows1_ref=nrows_ref;
      if ((kk_in>200)||(d_in<30)) {
         /* - on trie les valeurs en intensite decroissante -*/
         for (k_in=0,kk_in=0;k_in<nrows_in;k_in++) {
            if (p_in->objelist->ident[k_in]!=TT_STAR) continue;
            dist_in[kk_in]=-p_in->objelist->intensity[k_in];
            index_in[kk_in]=k_in;
            kk_in++;
         }
         if ((msg=tt_util_qsort_double(dist_in,0,kk_in,index_in))!=OK_DLL) {
            tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
            return(msg);
         }
         /* - on tronque la liste aux etoiles les plus brillantes -*/
         if (kk_in>200) {nrows1_in=200;}
         if (d_in<30) {nrows1_in=(int)(n_in/(30+1)/(30+1));}
         nbsortie=(int)(nrows1_in*.5);
      }
      if ((kk_ref>200)||(d_ref<30)) {
         /* - on trie les valeurs en intensite decroissante -*/
         for (k_ref=0,kk_ref=0;k_ref<nrows_ref;k_ref++) {
            if (p_ref->objelist->ident[k_ref]!=TT_STAR) continue;
            dist_ref[kk_ref]=-p_ref->objelist->intensity[k_ref];
            index_ref[kk_ref]=k_ref;
            kk_ref++;
         }
         if ((msg=tt_util_qsort_double(dist_ref,0,kk_ref,index_ref))!=OK_DLL) {
            tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
            return(msg);
         }
         /* - on tronque la liste aux etoiles les plus brillantes -*/
         if (kk_ref>200) {nrows1_ref=200;}
         if (d_ref<30) {nrows1_ref=(int)(n_ref/(30+1)/(30+1));}
      }
      /* --- on trie la premiere liste dans l'ordre croissant de dist_in ---*/
      for (k_in=0,kk_in=0;k_in<nrows_in;k_in++) {
         if (p_in->objelist->ident[k_in]!=TT_STAR) continue;
         x=p_in->objelist->x[k_in]-x0[k];
         y=p_in->objelist->y[k_in]-y0[k];
         dist_in[kk_in]=x*x+y*y;
         index_in[kk_in]=k_in;
         kk_in++;
         if (kk_in>nrows1_in) break;
      }
      if (kk_in==0) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      if ((msg=tt_util_qsort_double(dist_in,0,kk_in,index_in))!=OK_DLL) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(msg);
      }
      /* --- on trie la seconde liste dans l'ordre croissant de dist_ref ---*/
      for (k_ref=0,kk_ref=0;k_ref<nrows_ref;k_ref++) {
         if (p_ref->objelist->ident[k_ref]!=TT_STAR) continue;
         x=p_ref->objelist->x[k_ref]-p_in->objelist->x[index_in[0]];
         y=p_ref->objelist->y[k_ref]-p_in->objelist->y[index_in[0]];
         dist_ref[kk_ref]=x*x+y*y;
         index_ref[kk_ref]=k_ref;
         kk_ref++;
         if (kk_ref>nrows1_ref) break;
      }
      if (kk_ref==0) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      if ((msg=tt_util_qsort_double(dist_ref,0,kk_ref,index_ref))!=OK_DLL) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(msg);
      }
      nrows1_in=kk_in;
      nrows1_ref=kk_ref;
      kkmax=(int)(floor(1.+log((double)(nrows1_in)/10.)));
      for (kk=0;kk<kkmax;kk++) {
         /*printf("k=%d kk=%d/%d nbapmax=%d/%d\n",k,kk,kkmax,nbapmax,nbsortie);*/
         for (k_ref=0;k_ref<kk_ref;k_ref++) {
            /* --- on calcule la translation de cet appariement ---*/
            tx=p_ref->objelist->x[index_ref[k_ref]]-p_in->objelist->x[index_in[kk]];
            ty=p_ref->objelist->y[index_ref[k_ref]]-p_in->objelist->y[index_in[kk]];
            /* --- on compte les appariements reussis pour cette translation ---*/
            nbap=0;
            for (kc_in=0;kc_in<kk_in;kc_in++) {
               x=p_in->objelist->x[index_in[kc_in]]+tx;
               y=p_in->objelist->y[index_in[kc_in]]+ty;
               for (kc_ref=0;kc_ref<kk_ref;kc_ref++) {
                  xx=fabs(p_ref->objelist->x[index_ref[kc_ref]]-x);
                  yy=fabs(p_ref->objelist->y[index_ref[kc_ref]]-y);
                  if ((xx<=dist_detec)&&(yy<=dist_detec)) { nbap++; break; }
               }
               if ((kk_in-kc_in)<(nbsortie-nbap)) { break; }
            }
            if (nbap>nbapmax) {
               nbapmax=nbap;
               ttx=tx;
               tty=ty;
               if (nbapmax>=nbsortie) { break; }
            }
         }
         if (nbapmax>=nbsortie) { break; }
      }
      if (nbapmax>=nbsortie) { break; }
   }
   *nbmatched=0;
   if (nbapmax>1) {
      a[2]=-ttx;
      a[5]=-tty;
      if ((nrows1_in<nrows_in)||(nrows1_ref<nrows_ref)) {
         /* --- calcul le vrai nombre d'appariements ---*/
         nbapmax=0;
         for (kc_in=0;kc_in<kk_in;kc_in++) {
            x=p_in->objelist->x[index_in[kc_in]]+ttx;
            y=p_in->objelist->y[index_in[kc_in]]+tty;
            for (kc_ref=0;kc_ref<kk_ref;kc_ref++) {
               xx=fabs(p_ref->objelist->x[index_ref[kc_ref]]-x);
               yy=fabs(p_ref->objelist->y[index_ref[kc_ref]]-y);
               if ((xx<=dist_detec)&&(yy<=dist_detec)) { nbapmax++; break; }
            }
         }
      }
      *nbmatched=nbapmax;
   } else {
      /* --- s'il n'y a qu'une etoile en commun alors on apparie les ---*/
      /* --- plus brillantes meme saturees ---*/
      /* --- On trie la premiere liste dans l'ordre croissant de flux ---*/
      for (k_in=0,kk_in=0;k_in<nrows_in;k_in++) {
         if (p_in->objelist->ident[k_in]>TT_STAR) continue;
         dist_in[kk_in]=p_in->objelist->flux[k_in];
         index_in[kk_in]=k_in;
         kk_in++;
      }
      if (kk_in==0) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      if ((msg=tt_util_qsort_double(dist_in,0,kk_in,index_in))!=OK_DLL) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(msg);
      }
      /* --- On trie la seconde liste dans l'ordre croissant de flux ---*/
      for (k_ref=0,kk_ref=0;k_ref<nrows_ref;k_ref++) {
         if (p_ref->objelist->ident[k_ref]>TT_STAR) continue;
         dist_ref[kk_ref]=p_ref->objelist->flux[k_ref];
         index_ref[kk_ref]=k_ref;
         kk_ref++;
      }
      if (kk_ref==0) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(OK_DLL);
      }
      if ((msg=tt_util_qsort_double(dist_ref,0,kk_ref,index_ref))!=OK_DLL) {
         tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
         return(msg);
      }
      tx=p_ref->objelist->x[kk_ref-1]-p_in->objelist->x[kk_in-1];
      ty=p_ref->objelist->y[kk_ref-1]-p_in->objelist->y[kk_in-1];
      a[2]=-ttx;
      a[5]=-tty;
      *nbmatched=1;
   }
   /*printf("match de %d etoiles\n",nbapmax);*/
   a[0]=1.;
   a[1]=0.;
   a[3]=0.;
   a[4]=1.;
   tt_free(index_ref,"index_ref");tt_free(index_in,"index_in");tt_free(dist_in,"dist_in");tt_free(dist_ref,"dist_ref");
   return(OK_DLL);
}


void tt_util_uswapbytes(unsigned long* ptr, int n)
/***************************************************************************/
/* conversion de Format Big_ENDIAN -> LITTLE_ENDIAN pour les unsigned long */
/***************************************************************************/
/* n=1 pour un seul groupe de quatre octets.                               */
/***************************************************************************/
{
   char* cp;
   int j;
   cp = (char*)ptr;
   for(j=0;j<n; j++) {
      cp[0] ^= (cp[3]^=(cp[0]^=cp[3]));
      cp[1] ^= (cp[2]^=(cp[1]^=cp[2]));
      cp += 4;
   }
}

int tt_util_astrom_zoneusno(double ra,double dec,char *num_zone,int *num_ligne)
/***************************************************************************/
/* Retourne les parametres pour lire le catalogue USNO.                    */
/***************************************************************************/
{
   int zone,k;
   ra*=180./TT_PI;
   dec*=180./TT_PI;
   zone=(int)(75*floor((dec+90)/7.5));
   sprintf(num_zone,"%4d",zone);
   for (k=0;k<4;k++) { if (num_zone[k]==' ') num_zone[k]='0'; }
   *num_ligne=1+(int)floor(ra*4/15);
   return(OK_DLL);
}

#ifdef TT_OLD_ASTROM
int tt_util_astrom_xy2radec(TT_ASTROM *p, double x,double y,double *ra,double *dec)
/***************************************************************************/
/* Passage  x,y -> ra,dec                                                  */
/***************************************************************************/
/* ra,dec en radians.                                                      */
/***************************************************************************/
{
   double delta,gamma;
   double dra,ddec;
   /* --- cas de distorsion ---*/
#ifdef TT_DISTORASTROM
   double xp,yp;
   if (p->pv_valid==TT_YES) {
      xp = p->pv[1][1]*x + p->pv[1][2]*y + p->pv[1][0] + p->pv[1][5]*x*y + p->pv[1][4]*x*x + p->pv[1][6]*y*y + p->pv[1][7]*x*x*x + p->pv[1][8]*x*x*y + p->pv[1][9]*x*y*y + p->pv[1][10]*y*y*y;
      yp = p->pv[2][2]*x + p->pv[2][1]*y + p->pv[2][0] + p->pv[2][5]*x*y + p->pv[2][6]*x*x + p->pv[2][4]*y*y + p->pv[2][10]*x*x*x + p->pv[2][9]*x*x*y + p->pv[2][8]*x*y*y + p->pv[2][7]*y*y*y;
      x=xp;
      y=yp;
   }
#endif
   /* --- passage x,y -> ra,dec ---*/
   x+=0.5;
   y+=0.5;
   dra=p->cd11*(x-p->crpix1)+p->cd12*(y-p->crpix2);
   ddec=p->cd21*(x-p->crpix1)+p->cd22*(y-p->crpix2);
   delta=cos(p->crval2)-ddec*sin(p->crval2);
   gamma=sqrt(dra*dra+delta*delta);
   *ra=p->crval1+atan(dra/delta);
   if (*ra<0) {*ra+=(2*TT_PI);}
   if (*ra>(2*TT_PI)) {*ra-=(2*TT_PI);}
   *dec=atan((sin(p->crval2)+ddec*cos(p->crval2))/gamma);
   return(OK_DLL);
}
#else
int tt_util_astrom_xy2radec(TT_ASTROM *p, double x,double y,double *ra,double *dec)
{
   return(tt_util_astrom_p2radec(p,x,y,ra,dec));
}
#endif

int tt_util_astrom_p2radec(TT_ASTROM *p, double x,double y,double *ra,double *dec)
/***************************************************************************/
/* Passage  x,y -> ra,dec                                                  */
/***************************************************************************/
/* ra,dec en radians.                                                      */
/***************************************************************************/
{
   double x1,x2,phi,rth,theta,sinth,costh,sindec,cosdec,cosdecsinrarap,cosdeccosrarap,rarap;
   double p1,p2;
   TT_WCS wcs;
   wcs = p->wcs;
   p1=x+1;
   p2=y+1;
   /* --- passage x,y -> ra,dec ---*/
   x1 = wcs.sm11*(p1-wcs.r1) + wcs.sm12*(p2-wcs.r2);
   x2 = wcs.sm21*(p1-wcs.r1) + wcs.sm22*(p2-wcs.r2);
   //lassign [wcs_distorsion_compute $wcs $x1 $x2] x1 x2
   phi = atan2(x1,-x2);
   rth = sqrt(x1*x1+x2*x2);
   if (rth==0) {
      theta = wcs.pi/2;
   } else {
      theta = atan(1./rth);
   }
   sinth = sin(theta);
   costh = cos(theta);
   sindec = sinth*wcs.sindecp+costh*wcs.cosdecp*cos(phi-wcs.phip);
   cosdec = sqrt(1.-sindec*sindec);
   *dec = asin(sindec);
   cosdecsinrarap = -costh*sin(phi-wcs.phip);
   cosdeccosrarap = (sinth*wcs.cosdecp-costh*wcs.sindecp*cos(phi-wcs.phip));
   rarap = atan2(cosdecsinrarap,cosdeccosrarap);
   *ra = rarap + wcs.rap;
   *ra = fmod(*ra*180/wcs.pi+720,360)*wcs.dr;
   return(OK_DLL);
}

#ifdef TT_OLD_ASTROM
int tt_util_astrom_radec2xy(TT_ASTROM *p,double ra,double dec, double *x,double *y)
/***************************************************************************/
/* Passage ra,dec -> x,y                                                   */
/***************************************************************************/
/* ra,dec en radians.                                                      */
/***************************************************************************/
{
   double sindec,cosdec,sindec0,cosdec0,cosrara0,sinrara0;
   double h,det;
   double dra,ddec;
#ifdef TT_DISTORASTROM
   double xp,yp,x0,y0;
#endif
   /* --- passage ra,dec -> x,y ---*/
   sindec=sin(dec);
   cosdec=cos(dec);
   sindec0=sin(p->crval2);
   cosdec0=cos(p->crval2);
   cosrara0=cos(ra-p->crval1);
   sinrara0=sin(ra-p->crval1);
   h=sindec*sindec0+cosdec*cosdec0*cosrara0;
   dra=cosdec*sinrara0/h;
   ddec=(sindec*cosdec0-cosdec*sindec0*cosrara0)/h;
   det=p->cd22*p->cd11-p->cd12*p->cd21;
   if (det==0) {*x=*y=0.;} else {
      *x=p->crpix1 - (p->cd12*ddec-p->cd22*dra) / det -0.5;
      *y=p->crpix2 + (p->cd11*ddec-p->cd21*dra) / det -0.5;
   }
   /* --- cas de distorsion ---*/
#ifdef TT_DISTORASTROM
   if (p->pv_valid==TT_YES) {
      x0=*x;
      y0=*y;
      xp = p->pv[1][1]*x0 + p->pv[1][2]*y0 + p->pv[1][0] + p->pv[1][5]*x0*y0 + p->pv[1][4]*x0*x0 + p->pv[1][6]*y0*y0 + p->pv[1][7]*x0*x0*x0 + p->pv[1][8]*x0*x0*y0 + p->pv[1][9]*x0*y0*y0 + p->pv[1][10]*y0*y0*y0;
      yp = p->pv[2][2]*x0 + p->pv[2][1]*y0 + p->pv[2][0] + p->pv[2][5]*x0*y0 + p->pv[2][6]*x0*x0 + p->pv[2][4]*y0*y0 + p->pv[2][10]*x0*x0*x0 + p->pv[2][9]*x0*x0*y0 + p->pv[2][8]*x0*y0*y0 + p->pv[2][7]*y0*y0*y0;
      x0-=(xp-x0);
      y0-=(yp-y0);
      *x=x0;
      *y=y0;
   }
#endif
   return(OK_DLL);
}
#else
int tt_util_astrom_radec2xy(TT_ASTROM *p,double ra,double dec, double *x,double *y)
{
   return (tt_util_astrom_radec2p(p,ra,dec,x,y));
}
#endif

int tt_util_astrom_radec2p(TT_ASTROM *p,double ra,double dec, double *x,double *y)
/***************************************************************************/
/* Passage ra,dec -> x,y                                                   */
/***************************************************************************/
/* ra,dec en radians.                                                      */
/***************************************************************************/
{
   double cosdec,sindec,sinth,costh,costhsinphiphip,costhcosphiphip,phiphip,phi,theta;
   double tantheta,rth,x1,x2,pr1,pr2,delta;
   TT_WCS wcs;
   wcs = p->wcs;
   cosdec = cos(dec);
   sindec = sin(dec);
   sinth = sindec*wcs.sindecp+cosdec*wcs.cosdecp*cos(ra-wcs.rap);
   costh = sqrt(1.-sinth*sinth);
   costhsinphiphip = -cosdec*sin(ra-wcs.rap);
   costhcosphiphip = (sindec*wcs.cosdecp-cosdec*wcs.sindecp*cos(ra-wcs.rap));
   phiphip = atan2(costhsinphiphip,costhcosphiphip);
   phi = phiphip + wcs.phip;
   theta = atan2(sinth,costh);
   if (costh==0) {
      rth = 0;
   } else {
      tantheta = sinth/costh;
      rth = 1./tantheta;
   }
   x1 = rth*sin(phi);
   x2 = -rth*cos(phi);
   delta = (wcs.sm22*wcs.sm11 - wcs.sm12*wcs.sm21);
   if (delta==0) {
      pr1 = 0;
      pr2 = 0;
   } else {
      pr1 = (wcs.sm22*x1 - wcs.sm12*x2) / (wcs.sm22*wcs.sm11 - wcs.sm12*wcs.sm21);
      pr2 = (wcs.sm21*x1 - wcs.sm11*x2) / (wcs.sm21*wcs.sm12 - wcs.sm11*wcs.sm22);
   }
   *x = pr1+wcs.r1-1;
   *y = pr2+wcs.r2-1;
   return(OK_DLL);
}

int tt_util_dellastchar(char *chaine)
/***************************************************************************/
/* Retire le dernier caractere d'une chaine.                               */
/***************************************************************************/
/***************************************************************************/
{
   int len;
   len=strlen(chaine);
   if (len>0) { chaine[len-1]='\0'; }
   return(OK_DLL);
}

int tt_util_listpixima(TT_IMA *p,TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Analyse des pixels de l'image pour detecter les etoiles, les saturations*/
/* et les cosmics.                                                         */
/***************************************************************************/
/* Boucle generale.                                                        */
/***************************************************************************/
{
   int pixen,objen,msg;
   if ((msg=tt_util_listpixima2(p,pseries,1,&pixen,&objen))!=OK_DLL) {
      return(msg);
   }
   if ((pseries->object_list==TT_YES)||(pseries->pixel_list==TT_YES)) {
      if (pixen==0) {pixen=1;}
      tt_tblpixcreater(p->pixelist,pixen);
      if (objen==0) {objen=1;}
      tt_tblobjcreater(p->objelist,objen);
      if ((msg=tt_util_listpixima2(p,pseries,2,&pixen,&objen))!=OK_DLL) {
         tt_tblpixdestroyer(p->pixelist);
         tt_tblobjdestroyer(p->objelist);
         return(msg);
      }
      if (pixen==0) {
         p->pixelist->x[pixen]=(double)(0.);
         p->pixelist->y[pixen]=(double)(0.);
         p->pixelist->ident[pixen]=(short)(TT_STAR);
      }
      if (objen==0) {
         p->objelist->x[objen]=(double)(0.);
         p->objelist->y[objen]=(double)(0.);
         p->objelist->ident[objen]=(short)(TT_STAR);
         p->objelist->fwhmx[objen]=(double)(0.);
         p->objelist->fwhmy[objen]=(double)(0.);
         p->objelist->background[objen]=0.;
         p->objelist->intensity[objen]=1.;
         p->objelist->flux[objen]=(double)(0.);
      }
   }
   return(OK_DLL);
}

int tt_util_listpixima2(TT_IMA *p,TT_IMA_SERIES *pseries,int method,int *npix,int *nobj)
/***************************************************************************/
/* Analyse des pixels de l'image pour detecter les etoiles, les saturations*/
/* et les cosmics.                                                         */
/***************************************************************************/
/* Genere une liste de pixels et une liste d'objets.                       */
/*                                                                         */
/* Besoins en entree dans pseries :                                        */
/*  pseries->bgsigma : le bruit moyen du fond de ciel.                     */
/*  pseries->pixelsat_value : la valeur de saturation.                     */
/*                                                                         */
/* method=1 : premiere passe qui compte le nombre de pixels de la liste.   */
/*       =2 : remplit la liste (utiliser son constructeur au paravant).    */
/*                                                                         */
/* Sorties de cette fonction :                                             */
/*  pseries->nbstars                                                       */
/*  pseries->fwhm                                                          */
/*  pseries->d_fwhm                                                        */
/*                                                                         */
/* !!!! Les coordonnees pixels commencent en (0,0) !!!!                    */
/***************************************************************************/
{
   int k,y,x,ya,yb,yc,xxd,yyd,xxf,yyf,xx,yy;
   double i,mu_i,mu_ii=0.,sx_i,sx_ii=0.,delta,sigma,moyenne;
   double *v,fwhmx,fwhmy,fond,detection,flux,fwhm,intensite;
   int nbetoiles,nbii,xmax,ymax;
   int nbpixfond;
   double *val,sigma_detec,sigma_bruit,valfond;
   int pixen,objen,ident,msg,nullfond;
   int bordurex,bordurey;
   double seuil_sature,xcc,ycc,tot;
   int nombre,taille;
   /*FILE *ff;*/

   sigma_detec=pseries->detect_kappa;
   sigma_bruit=pseries->bgsigma;
   seuil_sature=pseries->pixelsat_value;
   /* --- bordure est la zone d'exclusion au bord de l'image ---*/
   /* --- pseries->bordure s'exprime en pourcents ---*/
   if (pseries->bordure<0.) {pseries->bordure=0.; }
   if (pseries->bordure>90.) {pseries->bordure=90.; }
   bordurex=(int)(pseries->bordure/100.*p->naxis1/2.);
   bordurey=(int)(pseries->bordure/100.*p->naxis2/2.);
   /* --- chercher les dimensions de l'image ---*/
   xmax=p->naxis1;
   ymax=p->naxis2;
   /* --- Calcul du critere de qualite stellaire ---*/
   nbetoiles=0;
   nbii=0;
   nombre=10;
   taille=sizeof(double);
   v=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&v,&nombre,&taille,"v"))!=OK_DLL) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_listpixima2 (pointer v)");
      return(TT_ERR_PB_MALLOC);
   }
   mu_i=0;
   sx_i=0;
   pixen=0;
   objen=0;
   i=0;
   for (y=2+bordurey;y<=(ymax-3-bordurey);y++) {
      if ((y>ymax)||(y<0)) { continue; }
      ya=xmax*(y-1);
      yb=xmax*y;
      yc=xmax*(y+1);
      for (x=2+bordurex;x<=(xmax-3-bordurey);x++) {
         if ((x>xmax)||(x<0)) { continue; }
         v[1]=p->p[ya+x-1];
         v[5]=p->p[yb+x  ];
         if (v[5]>v[1]) {
            v[2]=p->p[ya+x  ];
            v[3]=p->p[ya+x+1];
            v[4]=p->p[yb+x-1];
            if ((v[5]>v[2])&&(v[5]>v[3])&&(v[5]>v[4])) {
               v[6]=p->p[yb+x+1];
               v[7]=p->p[yc+x-1];
               v[8]=p->p[yc+x  ];
               v[9]=p->p[yc+x+1];
               if ((v[5]>=v[6])&&(v[5]>=v[7])&&(v[5]>=v[8])&&(v[5]>=v[9])) {
                  /* --- maximum local detecte ---*/
                  /* --- recherche le fond local ---*/
                  fwhmx=0;
                  for (k=x;k<=(xmax-2);k++) {
                     if ((p->p[xmax*y+k]-p->p[xmax*y+k+1])<=0) break;
                     else fwhmx+=1;
                  }
                  k--;
                  xxf=k;
                  /*printf("-> %d/%d\n",xmax*y+k+1,longueur);*/
                  fond=p->p[xmax*y+k+1];
                  for (k=x;k>=1;k--) {
                     if ((p->p[xmax*y+k]-p->p[xmax*y+k-1])<=0) break;
                     else fwhmx+=1;
                  }
                  k++;
                  xxd=k;
                  /*printf("-> %d/%d\n",xmax*y+k-1,longueur);*/
                  fond+=p->p[xmax*y+k-1];
                  fwhmy=0;
                  for (k=y;k<=(ymax-2);k++) {
                     if ((p->p[xmax*k+x]-p->p[xmax*(k+1)+x])<=0) break;
                     else fwhmy+=1;
                  }
                  k--;
                  yyf=k;
                  /*printf("-> %d/%d\n",xmax*(k+1)+x,longueur);*/
                  fond+=p->p[xmax*(k+1)+x];
                  for (k=y;k>=1;k--) {
                     if ((p->p[xmax*k+x]-p->p[xmax*(k-1)+x])<=0) break;
                     else fwhmy+=1;
                  }
                  k++;
                  yyd=k;
                  /*printf("-> %d %d/%d\n",k,xmax*(k-1)+x,longueur);*/
                  fond+=p->p[xmax*(k-1)+x];
                  fond/=4;
                  /* --- calcule le fond median ---*/
                  nbpixfond=(xxf-xxd+2+yyf-yyd)*2;
                  nullfond=TT_NO;
                  if (nbpixfond>0) {
                     nombre=nbpixfond+1;
                     taille=sizeof(double);
                     val=NULL;
                     if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&val,&nombre,&taille,"val"))!=OK_DLL) {
                        tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_listpixima2 (pointer val)");
                        tt_free(v,"v");
                        /*free(v);*/
                        return(TT_ERR_PB_MALLOC);
                     }
                     nbpixfond=0;
                     for (k=xxd;k<=xxf;k++) {
                        valfond=p->p[(int)(xmax*yyd)+k];
                        if (pseries->nullpix_exist==TT_YES) {
                           if (valfond<=pseries->nullpix_value) {
                              nullfond=TT_YES;
                           }
                        }
                        val[++nbpixfond]=valfond;
                        valfond=p->p[(int)(xmax*yyf)+k];
                        if (pseries->nullpix_exist==TT_YES) {
                           if (valfond<=pseries->nullpix_value) {
                              nullfond=TT_YES;
                           }
                        }
                        val[++nbpixfond]=valfond;
                     }
                     for (k=yyd;k<=yyf;k++) {
                        valfond=p->p[(int)(xmax*k)+xxd];
                        if (pseries->nullpix_exist==TT_YES) {
                           if (valfond<=pseries->nullpix_value) {
                              nullfond=TT_YES;
                           }
                        }
                        val[++nbpixfond]=valfond;
                        valfond=p->p[(int)(xmax*k)+xxf];
                        if (pseries->nullpix_exist==TT_YES) {
                           if (valfond<=pseries->nullpix_value) {
                              nullfond=TT_YES;
                           }
                        }
                        val[++nbpixfond]=valfond;
                     }
                     if ((msg=tt_util_qsort_double(val,1,nbpixfond,NULL))!=OK_DLL) {
                        /*tt_free(val,"val");tt_free(v,"v");*/
                        free(val);
                        free(v);
                        return(msg);
                     }
                     fond=val[(int)(floor((double)nbpixfond/(double)2))];
                     /*tt_free(val,"val");*/
                     free(val);
                  }
                  detection=fond+sigma_detec*sigma_bruit;
                  if ((v[5]>=(detection))&&(nbpixfond>0)&&(nullfond==TT_NO)) {
                     /* --- un objet a ete detecte ---*/
                     if (v[5]>=seuil_sature) {
                        ident=(short)(TT_SATYES);
                     } else {
                        ident=(short)(TT_SATNO);
                     }
                     intensite=v[5]-fond;
                     if (method==2) {
                        p->pixelist->x[pixen]=(double)(x);
                        p->pixelist->y[pixen]=(double)(y);
                        p->pixelist->ident[pixen]=(short)(ident);
                        p->objelist->x[objen]=(double)(x);
                        p->objelist->y[objen]=(double)(y);
                        p->objelist->ident[objen]=(short)(ident);
                        p->objelist->fwhmx[objen]=(double)(0.);
                        p->objelist->fwhmy[objen]=(double)(0.);
                        p->objelist->background[objen]=fond;
                        p->objelist->intensity[objen]=intensite;
                        p->objelist->flux[objen]=(double)(0.);
                     }
                     /* --- on cherche maintenant la nature de l'objet ---*/
                     if (((v[6]<detection)&&(v[4]<detection))||((v[2]<detection)&&(v[8]<detection))) {
                        if (method==2) {
                           p->objelist->ident[objen]*=(short)(TT_COSMIC);
                        }
                     }
                     else {
                        if (method==2) {
                           p->objelist->ident[objen]*=(short)(TT_STAR);
                        }
                        nbetoiles++;
                        flux=0;
                        for (xx=xxd;xx<=xxf;xx++) {
                           for (yy=yyd;yy<=yyf;yy++) {
                              tot=p->p[xmax*yy+xx]-fond;
                              if (tot>0.) {
                                 flux+=tot;
                              }
                           }
                        }
                        fwhm=((intensite>0.)&&(flux>0.)) ? (sqrt(flux/3.14/intensite)/.601) : 1.0 ;
                        if (method==2) {
                           p->objelist->flux[objen]=flux;
                           p->objelist->fwhmx[objen]=fwhm;
                           p->objelist->fwhmy[objen]=fwhm;
                           if (pseries->pixint==TT_NO) {
                              /* on affine la position du centre */
                              xxd=x-1; if (xxd<0) xxd=0;
                              xxf=x+1; if (xxf>=xmax) xxf=xmax-1;
                              yyd=y-1; if (yyd<0) yyd=0;
                              yyf=y+1; if (yyf>=ymax) yyf=ymax-1;
                              xcc=0.;
                              ycc=0.;
                              tot=0.;
                              for (xx=xxd;xx<=xxf;xx++) {
                                 for (yy=yyd;yy<=yyf;yy++) {
                                    flux=(p->p[xmax*yy+xx]-fond);
                                    if (flux>0.) {
                                       tot+=flux;
                                       xcc+=(flux*xx);
                                       ycc+=(flux*yy);
                                    }
                                 }
                              }
                              /*
                              ff=fopen("a.txt","at");
                              fprintf(ff,"====== tot=%lf objen=%ld\n",tot,objen);
                              fprintf(ff,"       fwhm=%lf intensite=%lf flux=%lf\n",fwhm,p->objelist->intensity[objen],p->objelist->flux[objen]);
                              fprintf(ff,"       x=%+6.3lf y=%+6.3lf\n",p->objelist->x[objen],p->objelist->y[objen]);
                              */
                              if (tot>0.) {
                                 xcc/=tot;
                                 ycc/=tot;
                                 /*
                                 fprintf(ff,"       x=%+6.3lf y=%+6.3lf\n",xcc,ycc);
                                 fprintf(ff,"       x=%+6.3lf y=%+6.3lf\n",p->objelist->x[objen]-xcc,p->objelist->y[objen]-ycc);
                                 */
                                 p->objelist->x[objen]=xcc;
                                 p->objelist->y[objen]=ycc;
                              }
                              /*
                              fclose(ff);
                              */
                           }
                        }
                        /*
                        printf("v[5]=%f seuil_sature=%f\n",v[5],seuil_sature);
                        */
                        if ((fwhm>0)&&(v[5]<seuil_sature)) {
                           /* noter aussi que l'etoile n'est pas saturee ? */
                           nbii++;
                           if (nbii==1) {
                              mu_i=fwhm;
                              sx_i=0;
                           } else {
                              /* --- algo de la valeur moy et ecart type de Miller ---*/
                              i=(double) (nbii);
                              delta=fwhm-mu_i;
                              mu_ii=mu_i+delta/(i);
                              sx_ii=sx_i+delta*(fwhm-mu_ii);
                              mu_i=mu_ii;
                              sx_i=sx_ii;
                           }
                        }
                        /*
                        printf("x/y=%d/%d fwhmx=%f fwhmy=%f fond=%f I=%f flux=%f fwhm=%f\n",x,y,fwhmx-1,fwhmy-1,fond,v[5]-fond,flux,fwhm);getch();
                        */
                     }
                     objen++;
                     pixen++;
                  }
               }
            }
         } else if (v[5]>=seuil_sature) {
            if (method==2) {
               p->pixelist->x[pixen]=(double)(x);
               p->pixelist->y[pixen]=(double)(y);
               p->pixelist->ident[pixen]=TT_SATURATED;
            }
            pixen++;
         }
      }
   }
   if (nbetoiles>=2) {
      moyenne=mu_ii;
      sigma=((sx_ii>=0)&&(i>0.))?sqrt(sx_ii/i):0.0;
   } else {
      moyenne=(nbetoiles==1)?mu_ii:0;
      sigma=0;
   }
   tt_free(v,"v");
   /*free(v);*/
   *npix=pixen;
   *nobj=objen;
   pseries->nbstars=nbetoiles;
   pseries->fwhm=moyenne;
   pseries->d_fwhm=sigma;
   /*
   printf("nbetoiles=%d fwhm=%f sigma=%f\n",nbetoiles,moyenne,sigma);
   */
   return(OK_DLL);
}

int tt_util_contrast(TT_IMA *p,double *contrast)
/***************************************************************************/
/* Statistiques (contrast) sur une image                                   */
/***************************************************************************/
{
   double contraste,valeur;
   int k,nelem;
   contraste=0;
   valeur=p->p[0];
   nelem=(p->naxis1)*(p->naxis2);
   for (k=1;k<nelem;k++) {
      contraste+=fabs((double)p->p[k]-valeur);
      valeur=p->p[k];
   }
   contraste*=-1;
   *contrast=contraste;
   return(OK_DLL);
}

int tt_util_histocuts(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,double *mode,double *mini,double *maxi)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/***************************************************************************/
/* Il faut que soient deja calculees les donnees suivantes :               */
/*  pseries->                                                              */
/*                                                                         */
/* pseries->lofrac=0.05 le seuil bas dans l'histogramme                    */
/* pseries->hifrac=0.97 le seuil haut dans l'histogramme                   */
/* pseries->cutscontrast=1.0 pour diminuer le contraste                    */
/***************************************************************************/
{
   double sb,sh,bg,mi,ma;
   int msg;

   if (pseries->lofrac>1.) {pseries->lofrac=1.;}
   if (pseries->lofrac<0.) {pseries->lofrac=0.;}
   if (pseries->hifrac>1.) {pseries->hifrac=1.;}
   if (pseries->hifrac<0.) {pseries->hifrac=0.;}
   if (pseries->lofrac>pseries->hifrac) {
      pseries->lofrac=0.05;
      pseries->hifrac=0.97;
   }
   if ((msg=tt_util_histocuts2b(p,pseries,pseries->lofrac,pseries->hifrac,&sb,&sh,&bg,&mi,&ma))!=OK_DLL) {
      return(msg);
   }
   /* --- amplification de constraste ---*/
   sb-=((bg-sb)*pseries->cutscontrast);
   sh-=((bg-sh)*pseries->cutscontrast);
   *hicut=sh;
   *locut=sb;
   *mode=bg;
   *mini=mi;
   *maxi=ma;
   return(OK_DLL);
}

int tt_util_histocuts2b(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode,double *minim,double *maxim)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/* Le pendant de la fonction tt_util_cuts2.                                */
/***************************************************************************/
{
   double sb,sh,sb0,sh0,delta;
   int *histo,k,sortie,modemax,kincr,taille,msg,nombre;
   int nb,nelem,nelem0=0,nullpix_exist,index_histo,nbtours;
   double mini,maxi,nullpix_value,valeur,*seuil,moyenne,deltam,rapport;

   nelem=(p->naxis1)*(p->naxis2);
   kincr=1+(int)(1.*nelem/100000);
   nullpix_exist=pseries->nullpix_exist;
   nullpix_value=pseries->nullpix_value;
   if (nullpix_exist==TT_NO) {
      nullpix_value=TT_MIN_DOUBLE;
   }
   nb=50;
   nombre=nb;
   taille=sizeof(int);
   histo=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&histo,&nombre,&taille,"histo"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_cuts2 (pointer histo)");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nb+1;
   taille=sizeof(double);
   seuil=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&seuil,&nombre,&taille,"seuil"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_cuts2 (pointer seuil)");
      tt_free(histo,"histo");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- calcul du mini et maxi ---*/
   pseries->maxi=TT_MIN_FLOAT;
   pseries->mini=TT_MAX_FLOAT;
   for (k=0;k<nelem;k+=kincr) {
      valeur=(double)(p->p[k]);
      if (valeur!=nullpix_value) {
         if (valeur>pseries->maxi) {pseries->maxi=valeur;}
         if (valeur<pseries->mini) {pseries->mini=valeur;}
      }
   }
   *minim=pseries->mini;
   *maxim=pseries->maxi;
   delta=fabs(pseries->maxi-pseries->mini);
   if ((delta!=0)&&(delta<1e-5)) {
      pseries->maxi=pseries->mini+1e-5;
   }
   sb0=mini=pseries->mini;
   sh0=maxi=pseries->maxi;
   sortie=TT_NO;
   nbtours=0;
   /* --- boucle sur l'histogramme ---*/
   do {
      nbtours++;
      if (mini==maxi) {
         *hicut=maxi;
         *locut=mini;
         *mode=(maxi+mini)/2.;
         tt_free(seuil,"seuil");
         tt_free(histo,"histo");
         return(OK_DLL);
      }
      /* --- initialise les seuils ---*/
      sb=mini;
      sh=maxi;
      /* --- remplit l'histogramme ---*/
      for (k=0;k<nb;k++) {
         histo[k]=0;
      }
      deltam=fabs(maxi-mini);
      if (deltam>1e-10) {
         for (k=0,nelem0=0,moyenne=0.;k<nelem;k+=kincr) {
            valeur=(double)(p->p[k]);
            if (valeur!=nullpix_value) {
               nelem0++;
               deltam=(valeur-mini)/(maxi-mini);
               index_histo=(int)(fabs(floor(deltam*nb)));
               if (index_histo>=nb) { index_histo=nb-1; }
               else if (index_histo<0) { index_histo=0; }
               histo[index_histo]++;
               moyenne+=valeur;
            }
         }
      } else {
         histo[0]=nelem;
         moyenne=(double)(p->p[0]);
      }
      /* --- calcule la moyenne ---*/
      if (nelem0==0) {
         *hicut=sh;
         *locut=sb;
         *mode=(sb+sh)/2.;
         return(OK_DLL);
      }
      moyenne/=nelem0;
      /* --- remplit les valeurs de seuil inf pour chaque baton ---*/
      for (k=0;k<=nb;k++) {
         seuil[k]=mini+(maxi-mini)*k/nb;
      }
      /* --- calcule le mode ---*/
      modemax=0;
      for (k=0;k<nb-1;k++) {
         if (histo[k]>modemax) {
            modemax=histo[k];
            *mode=(seuil[k+1]+seuil[k])/2.;
         }
      }
      /* --- calcule l'histogramme cumule ---*/
      for (k=1;k<nb;k++) {
         histo[k]+=histo[k-1];
      }
      /* --- calcule des nouveaux seuils plus serres ---*/
      for (k=0;k<nb;k++) {
         valeur=(double)(histo[k])/(double)(histo[nb-1]);
         if (valeur<=percent_sb) {sb=seuil[k];}
         if (valeur>=percent_sh) {sh=seuil[k+1];break;}
      }
      mini=sb-(sh-sb); if (mini<sb0) {mini=sb0;}
      maxi=sh+(sh-sb); if (maxi>sh0) {maxi=sh0;}
      if ((sh-sb)==0) {
         sortie=TT_YES;
      } else {
         rapport=fabs(1-(sh0-sb0)/(sh-sb));
         if (rapport<0.1) {
            sortie=TT_YES;
         }
      }
      if (nbtours>3) {
         sortie=TT_YES;
      }
      /*printf("seuils histo : sb=%f sh=%f mode=%f\n",sb,sh,mode);getch();*/
      sb0=sb;
      sh0=sh;
   } while (sortie==TT_NO);
   *hicut=sh;
   *locut=sb;
   tt_free(seuil,"seuil");
   tt_free(histo,"histo");
   return(OK_DLL);
}

int tt_util_cuts(TT_IMA *p,TT_IMA_SERIES *pseries,double *hicut,double *locut,int dejastat)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/***************************************************************************/
/* Il faut que soient deja calculees les donnees suivantes :               */
/*  pseries->                                                              */
/*                                                                         */
/* dejastat=TT_YES si pseries->maxi ->mini ->bgsigma ->bgmean sont connus. */
/***************************************************************************/
{
   double sb,sh,sb0,sh0,sb_bgk,sh_bgk,mode;
   double asymetrie,sigma,valeur,valeur1,valeur2,valeurmean;
   int msg,nelem,k,kincr;

   nelem=(p->naxis1)*(p->naxis2);
   kincr=1+(int)(1.*nelem/100000);
   if (dejastat==TT_NO) {
      pseries->maxi=TT_MIN_FLOAT;
      pseries->mini=TT_MAX_FLOAT;
      for (k=0,valeur2=0.,valeur1=1.,valeurmean=0.;k<nelem;k+=kincr) {
         valeur=(double)(p->p[k]);
         if (valeur>pseries->maxi) {pseries->maxi=valeur;}
         if (valeur<pseries->mini) {pseries->mini=valeur;}
         if (k<nelem-1) {
            valeurmean+=valeur;
            valeur-=(double)(p->p[k+1]);
            valeur2=valeur*valeur;
            valeur1+=1.;
         }
      }
      pseries->bgsigma=sqrt(valeur2/valeur1);
      pseries->bgmean=(valeurmean/valeur1);
   }
   if ((msg=tt_util_cuts2b(p,pseries,0.15,0.85,&sb,&sh,&mode))!=OK_DLL) {
      return(msg);
   }
   sb_bgk=pseries->bgmean-pseries->bgsigma*6;
   sh_bgk=pseries->bgmean+pseries->bgsigma*10;
   /*
   printf("image %s\n",pseries->p_in->load_name);
   printf("  seuils histo brutes   : sb=%f sh=%f\n",sb,sh);
   printf("  (+)/2=%f sigma(95)=%f mode=%f \n",(sb+sh)/2.,(sh-(sb+sh)/2.)/2.,mode);
   printf("  mode    BAS=%f HAUT=%f\n",mode-sb,sh-mode);
   printf("  bgk_mean=%f bgk_sigma=%f\n",pseries->bgmean,pseries->bgsigma);
   */
   sb0=(mode-sb);
   sh0=(sh-mode);
   if ((sb0!=0.)&&(sh0!=0.)) {
      asymetrie=(sb0>=sh0)?sb0/sh0:sh0/sb0;
   } else {
      asymetrie=1.;
   }
   if (pseries->bgsigma!=0.) {
      sigma=((sh-(sb+sh)/2.)/1.1)/pseries->bgsigma;
   } else {
      sigma=0.;
   }
   /*printf("  asymetrie=%f  sigma=%f\n",asymetrie,sigma);*/
   if ((asymetrie>2.)||(sigma>2.)) {
      /*printf("  motif\n");*/
      if ((msg=tt_util_cuts2b(p,pseries,0.05,0.97,&sb,&sh,&mode))!=OK_DLL) {
         return(msg);
      }
      sb=sb-sb0*0.5;
      sh=sh+sh0*0.4;
   } else {
      /*printf("  ciel profond\n");*/
      sb=sb_bgk;
      sh=sh_bgk;
   }
   *hicut=sh;
   *locut=sb;
   return(OK_DLL);
}

int tt_util_cuts2(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/***************************************************************************/
{
   double sb,sh,sb0,sh0,delta;
   int *histo,k,sortie,modemax,taille,msg;
   int nb,nelem,nelem0,nullpix_exist,index_histo;
   double mini,maxi,nullpix_value,valeur,*seuil,moyenne,deltam;
   nelem=(p->naxis1)*(p->naxis2);
   nullpix_exist=pseries->nullpix_exist;
   nullpix_value=pseries->nullpix_value;
   if (nullpix_exist==TT_NO) {
      nullpix_value=TT_MIN_DOUBLE;
   }
   nb=50;
   taille=sizeof(int);
   histo=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&histo,&nb,&taille,"histo"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_cuts2 (pointer histo)");
      return(TT_ERR_PB_MALLOC);
   }
   taille=sizeof(double);
   seuil=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&seuil,&nb,&taille,"seuil"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_cuts2 (pointer seuil)");
      tt_free(histo,"histo");
      return(TT_ERR_PB_MALLOC);
   }
   delta=fabs(pseries->maxi-pseries->mini);
   if ((delta!=0)&&(delta<1e-5)) {
      pseries->maxi=pseries->mini+1e-5;
   }
   sb0=mini=pseries->mini;
   sh0=maxi=pseries->maxi;
   sortie=TT_NO;
   do {
      if (mini==maxi) {
	 *hicut=maxi;
	 *locut=mini;
	 tt_free(seuil,"seuil");
	 tt_free(histo,"histo");
	 return(OK_DLL);
      }
      /* --- initialise les seuils ---*/
      sb=mini;
      sh=maxi;
      /* --- remplit l'histogramme ---*/
      for (k=0;k<nb;k++) {
	 histo[k]=0;
      }
      for (k=0,nelem0=0,moyenne=0.;k<nelem;k++) {
	 valeur=(double)(p->p[k]);
	 if (valeur>nullpix_value) {
	    nelem0++;
            deltam=fabs(maxi-mini);
            if (deltam>1e-10) {
               deltam=(valeur-mini)/(maxi-mini);
            } else {
               deltam=0.0;
            }
	    index_histo=(int)(fabs(floor(deltam*nb)));
	    if (index_histo>=nb) { index_histo=nb-1; }
	    else if (index_histo<0) { index_histo=0; }
	    histo[index_histo]++;
	    moyenne+=valeur;
	 }
      }
      /* --- calcule la moyenne ---*/
      if (nelem0==0) {
	 *hicut=sh;
	 *locut=sb;
	 tt_free(histo,"histo");
	 tt_free(seuil,"seuil");
	 return(OK_DLL);
      }
      moyenne/=nelem0;
      /* --- remplit les valeurs de seuil inf pour chaque baton ---*/
      for (k=0;k<=nb;k++) {
	 seuil[k]=mini+(maxi-mini)*k/nb;
      }
      /* --- calcule le mode ---*/
      modemax=0;
      for (k=0;k<nb-1;k++) {
	 if (histo[k]>modemax) {
	    modemax=histo[k];
	    *mode=(seuil[k+1]+seuil[k])/2.;
	 }
      }
      /* --- calcule l'histogramme cumule ---*/
      for (k=1;k<nb;k++) {
	 histo[k]+=histo[k-1];
      }
      /* --- calcule des nouveaux seuils plus serres ---*/
      for (k=0;k<nb;k++) {
	 valeur=(double)(histo[k])/(double)(histo[nb-1]);
	 if (valeur<=percent_sb) {sb=seuil[k];}
	 if (valeur>=percent_sh) {sh=seuil[k+1];break;}
      }
      mini=sb;
      maxi=sh;
      if ((sh-sb)==0) {
	 sortie=TT_YES;
      } else {
	 /*printf("rapport=%f\n",(sh0-sb0)/(sh-sb));*/
	 if (((sh0-sb0)/(sh-sb))<(1.+1./500.)) {
	    sortie=TT_YES;
	 }
      }
      /*printf("seuils histo : sb=%f sh=%f mode=%f\n",sb,sh,mode);getch();*/
      sb0=sb;
      sh0=sh;
   } while (sortie==TT_NO);
   *hicut=sh;
   *locut=sb;
   tt_free(seuil,"seuil");
   tt_free(histo,"histo");
   return(OK_DLL);
}

int tt_util_cuts2b(TT_IMA *p,TT_IMA_SERIES *pseries,double percent_sb,double percent_sh,double *locut,double *hicut,double *mode)
/***************************************************************************/
/* Statistiques (hicut et locut) sur une image                             */
/* remplace la fonction tt_util_cuts2.                                     */
/***************************************************************************/
{
   double sb,sh,sb0,sh0,delta;
   int *histo,k,sortie,modemax,kincr,taille,msg,nombre;
   int nb,nelem,nelem0=0,nullpix_exist,index_histo,nbtours;
   double mini,maxi,nullpix_value,valeur,*seuil,moyenne,deltam,rapport;
   nelem=(p->naxis1)*(p->naxis2);
   kincr=1+(int)(1.*nelem/100000);
   nullpix_exist=pseries->nullpix_exist;
   nullpix_value=pseries->nullpix_value;
   if (nullpix_exist==TT_NO) {
      nullpix_value=TT_MIN_DOUBLE;
   }
   nb=50;
   nombre=nb;
   taille=sizeof(int);
   histo=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&histo,&nombre,&taille,"histo"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_cuts2 (pointer histo)");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=nb+1;
   taille=sizeof(double);
   seuil=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&seuil,&nombre,&taille,"seuil"))!=0) {
      tt_errlog(pseries->tmp_dir,TT_ERR_PB_MALLOC,"Pb alloc in tt_util_cuts2 (pointer seuil)");
      tt_free(histo,"histo");
      return(TT_ERR_PB_MALLOC);
   }
   delta=fabs(pseries->maxi-pseries->mini);
   if ((delta!=0)&&(delta<1e-5)) {
      pseries->maxi=pseries->mini+1e-5;
   }
   sb0=mini=pseries->mini;
   sh0=maxi=pseries->maxi;
   sortie=TT_NO;
   nbtours=0;
   do {
      nbtours++;
      if (mini==maxi) {
	 *hicut=maxi;
	 *locut=mini;
         *mode=(maxi+mini)/2.;
	 tt_free(seuil,"seuil");
	 tt_free(histo,"histo");
	 return(OK_DLL);
      }
      /* --- initialise les seuils ---*/
      sb=mini;
      sh=maxi;
      /* --- remplit l'histogramme ---*/
      for (k=0;k<nb;k++) {
	 histo[k]=0;
      }
      deltam=fabs(maxi-mini);
      if (deltam>1e-10) {
         for (k=0,nelem0=0,moyenne=0.;k<nelem;k+=kincr) {
   	    valeur=(double)(p->p[k]);
	    if (valeur!=nullpix_value) {
	       nelem0++;
               deltam=(valeur-mini)/(maxi-mini);
	       index_histo=(int)(fabs(floor(deltam*nb)));
	       if (index_histo>=nb) { index_histo=nb-1; }
	       else if (index_histo<0) { index_histo=0; }
	       histo[index_histo]++;
	       moyenne+=valeur;
	    }
         }
      } else {
         histo[0]=nelem;
	 moyenne=(double)(p->p[0]);
      }
      /* --- calcule la moyenne ---*/
      if (nelem0==0) {
	 *hicut=sh;
	 *locut=sb;
         *mode=(sb+sh)/2.;
	 tt_free(histo,"histo");
	 tt_free(seuil,"seuil");
	 return(OK_DLL);
      }
      moyenne/=nelem0;
      /* --- remplit les valeurs de seuil inf pour chaque baton ---*/
      for (k=0;k<=nb;k++) {
	 seuil[k]=mini+(maxi-mini)*k/nb;
      }
      /* --- calcule le mode ---*/
      modemax=0;
      for (k=0;k<nb-1;k++) {
   	 if (histo[k]>modemax) {
	    modemax=histo[k];
	    *mode=(seuil[k+1]+seuil[k])/2.;
         }
      }
      /* --- calcule l'histogramme cumule ---*/
      for (k=1;k<nb;k++) {
	 histo[k]+=histo[k-1];
      }
      /* --- calcule des nouveaux seuils plus serres ---*/
      for (k=0;k<nb;k++) {
	 valeur=(double)(histo[k])/(double)(histo[nb-1]);
	 if (valeur<=percent_sb) {sb=seuil[k];}
	 if (valeur>=percent_sh) {sh=seuil[k+1];break;}
      }
      mini=sb-(sh-sb); if (mini<sb0) {mini=sb0;}
      maxi=sh+(sh-sb); if (maxi>sh0) {maxi=sh0;}
      if ((sh-sb)==0) {
	 sortie=TT_YES;
      } else {
         rapport=fabs(1-(sh0-sb0)/(sh-sb));
	 /*printf("rapport=%f\n",(sh0-sb0)/(sh-sb));*/
	 if (rapport<0.1) {
	    sortie=TT_YES;
	 }
      }
      if (nbtours>3) {
         sortie=TT_YES;
      }
      /*printf("seuils histo : sb=%f sh=%f mode=%f\n",sb,sh,mode);getch();*/
      sb0=sb;
      sh0=sh;
   } while (sortie==TT_NO);
   *hicut=sh;
   *locut=sb;
   tt_free(seuil,"seuil");
   tt_free(histo,"histo");
   return(OK_DLL);
}

int tt_util_statima(TT_IMA *p,double pixelsat_value,double *mean,double *sigma,double *mini,double *maxi,int *nbpixsat)
/***************************************************************************/
/* Statistiques (min,max,mean,sigma et nbpixsat) sur une image             */
/***************************************************************************/
{
   int k,nbsatures,nelem;
   double valeur,i=0.,mu_i,mu_ii=0.,sx_i,sx_ii=0.,delta;
   double epsdouble;
   nelem=(p->naxis1)*(p->naxis2);
   valeur=(double)(p->p[0]);
   *maxi=*mini=valeur;
   nbsatures=0;
   mu_i=valeur;
   sx_i=0;
   epsdouble=1.0e-300;
   if (valeur>=pixelsat_value) {nbsatures++;}
   for (k=1;k<nelem;k++) {
      valeur=(double)(p->p[k]);
      /* --- recherche des min-max-saturation ---*/
      if (valeur>=pixelsat_value) {nbsatures++;}
      if (valeur<*mini) {*mini=valeur;}
      if (valeur>*maxi) {*maxi=valeur;}
      /* --- algo de la valeur moy et ecart type de Miller ---*/
      i=(double) (k+1);
      delta=valeur-mu_i;
      if ( fabs(delta) < epsdouble) {
         if ( delta < 0 ) {
            delta = -epsdouble ;
         } else {
            delta = epsdouble ;
         }
      }
      mu_ii=mu_i+delta/(i);
      sx_ii=sx_i+delta*(valeur-mu_ii);
      if ( fabs(sx_ii) < epsdouble) {
         if ( sx_ii < 0 ) {
            sx_ii = -epsdouble ;
         } else {
            sx_ii = epsdouble ;
         }
      }
      mu_i=mu_ii;
      sx_i=sx_ii;
   }
   *mean=mu_ii;
   *sigma=((sx_ii>=0)&&(i>0.))?sqrt(sx_ii/i):0.0;
   *nbpixsat=nbsatures;
   return(OK_DLL);
}

int tt_util_meansigma(double *x,int kdeb,int n,double *mean,double *sigma)
/***************************************************************************/
/* Calcule la moyenne et l'ecart type d'un tableau.                        */
/***************************************************************************/
/* Algorithme en une seule passe de Miller                                 */
/* kdeb la valeur de l'indice a partir duquel il faut trier                */
/* n est le nombre d'elements                                              */
/***************************************************************************/
{
   int k,kfin;
   double valeur,i=0.,mu_i,mu_ii=0.,sx_i,sx_ii=0.,delta;
   kfin=n+kdeb-1;
   if (n==0) {
      *mean=0.;
      *sigma=0.;
   }
   valeur=x[kdeb];
   mu_i=valeur;
   sx_i=0;
   if (n==1) {
      *mean=valeur;
      *sigma=0.;
      return(OK_DLL);
   }
   for (k=kdeb+1;k<=kfin;k++) {
      valeur=x[k];
      i=(double) (k-kdeb+1);
      delta=valeur-mu_i;
      mu_ii=mu_i+delta/(i);
      sx_ii=sx_i+delta*(valeur-mu_ii);
      mu_i=mu_ii;
      sx_i=sx_ii;
   }
   *mean=mu_ii;
   *sigma=((sx_ii>=0)&&(i>0.))?sqrt(sx_ii/i):0.0;
   return(OK_DLL);
}

int tt_util_qsort_double(double *x,int kdeb,int n,int *index)
/***************************************************************************/
/* Quick sort pour un tableau de double                                    */
/***************************************************************************/
/* x est le tableau qui commence a l'indice 1                              */
/* kdeb la valeur de l'indice a partir duquel il faut trier                */
/* n est le nombre d'elements                                              */
/* index est le tableau des indices une fois le tri effectue (=NULL si on  */
/*  ne veut pas l'utiliser).                                               */
/***************************************************************************/
{
   double qsort_r[TT_QSORT],qsort_l[TT_QSORT];
   int s,l,r,i,j,kfin;
   double v,w;
   int wi;
   int kt1,kt2,kp;
   double m,a;
   int mi,ai;
   kfin=n+kdeb-1;
   /* --- retour immediat si n==1 ---*/
   if (n==1) { return(OK_DLL); }
   if (index!=NULL) {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
         for (kt1=kdeb;kt1<kfin;kt1++) {
            m=x[kt1];
            mi=index[kt1];
            kp=kt1;
            for (kt2=kt1+1;kt2<=kfin;kt2++) {
               if (x[kt2]<m) {
                  m=x[kt2];
                  mi=index[kt2];
                  kp=kt2;
               }
            }
            a=x[kt1];x[kt1]=m;x[kp]=a;
            ai=index[kt1];index[kt1]=mi;index[kp]=ai;
         }
         return(OK_DLL);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[tt_util_qsort_verif(kdeb)]=kdeb; qsort_r[tt_util_qsort_verif(kdeb)]=kfin;
      do {
         l=(int)(qsort_l[tt_util_qsort_verif(s)]); r=(int)(qsort_r[tt_util_qsort_verif(s)]);
         s=s-1;
         do {
            i=l; j=r;
            v=x[(int) (floor((double)(l+r)/(double)2))];
            do {
               while (x[i]<v) {i++;}
               while (v<x[j]) {j--;}
               if (i<=j) {
                  w=x[i];x[i]=x[j];x[j]=w;
                  wi=index[i];index[i]=index[j];index[j]=wi;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[tt_util_qsort_verif(s)]=i ; qsort_r[tt_util_qsort_verif(s)]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[tt_util_qsort_verif(s)]=l ; qsort_r[tt_util_qsort_verif(s)]=j;} l=i; }
         } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(OK_DLL);
   } else {
      /*--- effectue un tri simple si n<=15 ---*/
      if (n<=15) {
         for (kt1=kdeb;kt1<kfin;kt1++) {
            m=x[kt1];
            kp=kt1;
            for (kt2=kt1+1;kt2<=kfin;kt2++) {
               if (x[kt2]<m) {
                  m=x[kt2];
                  kp=kt2;
               }
            }
            a=x[kt1];x[kt1]=m;x[kp]=a;
         }
         return(OK_DLL);
      }
      /*--- trie le tableau dans l'ordre croissant avec quick sort ---*/
      s=kdeb; qsort_l[tt_util_qsort_verif(kdeb)]=kdeb; qsort_r[tt_util_qsort_verif(kdeb)]=kfin;
      do {
         l=(int)(qsort_l[tt_util_qsort_verif(s)]); r=(int)(qsort_r[tt_util_qsort_verif(s)]);
         s=s-1;
         do {
            i=l; j=r;
            v=x[(int) (floor((double)(l+r)/(double)2))];
            do {
                while (x[i]<v  && i < n) {i++;}
               while (v<x[j]  && j >= 0) {j--;}
               if (i<=j) {
                  w=x[i];x[i]=x[j];x[j]=w;
                  i++; j--;
               }
            } while (i<=j);
            if ((j-l)>=(r-i)) {if (i<r) {s++ ; qsort_l[tt_util_qsort_verif(s)]=i ; qsort_r[tt_util_qsort_verif(s)]=r;} r=j; } else { if (l<j) {s++ ; qsort_l[tt_util_qsort_verif(s)]=l ; qsort_r[tt_util_qsort_verif(s)]=j;} l=i; }
         } while (l<r);
      } while (s!=(kdeb-1)) ;
      return(OK_DLL);
   }
}

int tt_util_qsort_verif(int index)
/***************************************************************************/
/* Verifie que l'indice ne depasse pas le seuil maximal pour qsort_*       */
/***************************************************************************/
{
   static int indexout;
   if (index>=(int)(TT_QSORT)) {
      tt_errlog("",TT_WAR_INDEX_OUTMAX,"index out of high limit in tt_util_qsort_verif");
	   index=(int)(TT_QSORT-1);
	}
   if (index<0) {
      tt_errlog("",TT_WAR_INDEX_OUTMIN,"index out of low limit in tt_util_qsort_verif");
	   index=0;
	}
   indexout=index;
   return indexout;
}

int tt_util_bgk(TT_IMA *p,double *bgmean,double *bgsigma)
/***************************************************************************/
/* Statistiques de fond de ciel (bgk) sur une image                        */
/***************************************************************************/
{
   int imax,jmax,ijmax,x,y,xx,yy,k,indice,nb,nbb,nl1,nl2,methode;
   double *intens=NULL;
   double *vect1_fond=NULL, *vect1_sigma=NULL;
   double *vect2_fond=NULL, *vect2_sigma=NULL;
   double mini;
   double fond,sigma;
   double param_seuil,param_fond;
   int nombre,taille,msg;

   /* chercher les dimensions de l'image */
   imax=p->naxis1;
   jmax=p->naxis2;
   ijmax = (imax>jmax) ? imax : jmax ;
   nombre=10;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&intens,&nombre,&taille,"intens"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_bgk (pointer intens)");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=ijmax+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vect1_fond,&nombre,&taille,"vect1_fond"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_bgk (pointer vect1_fond)");
      tt_free(intens,"intens");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=ijmax/2+1;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vect1_sigma,&nombre,&taille,"vect1_sigma"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_bgk (pointer vect1_sigma)");
      tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=7;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vect2_fond,&nombre,&taille,"vect2_fond"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_bgk (pointer vect2_fond)");
      tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");
      return(TT_ERR_PB_MALLOC);
   }
   nombre=7;
   taille=sizeof(double);
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vect2_sigma,&nombre,&taille,"vect2_sigma"))!=0) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_bgk (pointer vect2_sigma)");
      tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");
      return(TT_ERR_PB_MALLOC);
   }
   param_seuil=0.;
   param_fond=0.;
   methode=1;
   do {
      nbb=0;
      for (yy=-1;yy<=1;yy++) {
	 y=(int) ((1.0+yy*0.8)*jmax/2);
	 if ((y<1)||(y>(jmax-2))) {
	    continue;
	 }
	 if (methode==1) {
	    nl1=1;
	    intens[1]=p->p[(int)((y-1)*imax)+(nl1-1)];
	    intens[2]=p->p[(int)((y-1)*imax)+(nl1  )];
	    intens[4]=p->p[(int)((y  )*imax)+(nl1-1)];
	    intens[5]=p->p[(int)((y  )*imax)+(nl1  )];
	    intens[7]=p->p[(int)((y+1)*imax)+(nl1-1)];
	    intens[8]=p->p[(int)((y+1)*imax)+(nl1  )];
	 }
	 for (nb=0,x=1;x<imax-1;x++) {
	    if (methode==1) {
	       intens[3]=p->p[(int)((y-1)*imax)+(x+1)];
	       intens[6]=p->p[(int)((y  )*imax)+(x+1)];
	       intens[9]=p->p[(int)((y+1)*imax)+(x+1)];
	       mini=intens[5];
	       indice=5;
	       for (k=1;k<=4;k++) {if (intens[k]<=mini) {indice=k;} }
	       for (k=6;k<=9;k++) {if (intens[k]<=mini) {indice=k;} }
	       if (indice==5) {
		  nb++;
		  fond=0;
		  for (k=1;k<=4;k++) {fond+=intens[k];}
		  for (k=6;k<=9;k++) {fond+=intens[k];}
		  fond=fond/8;
		  vect1_fond[nb]=fond;
		  sigma=0;
		  for (k=1;k<=4;k++) {sigma+=((fond-intens[k])*(fond-intens[k]));}
		  for (k=6;k<=9;k++) {sigma+=((fond-intens[k])*(fond-intens[k]));}
		  sigma=sqrt(sigma/(double)7);
		  vect1_sigma[nb]=sigma;
	       }
	       intens[1]=intens[2];
	       intens[4]=intens[5];
	       intens[7]=intens[8];
	       intens[2]=intens[3];
	       intens[5]=intens[6];
	       intens[8]=intens[9];
	    }
	    if (methode==2) {
	       vect1_fond[++nb]=p->p[(int)((y  )*imax)+(x  )];
	    }
	 }
	 if ((nb!=0)&&(methode==1)) {
	    nbb++;
	    if (tt_util_qsort_double(vect1_fond,1,nb,NULL)!=OK_DLL) {
	       tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	       return(TT_ERR_PB_MALLOC);
	    }
	    if (tt_util_qsort_double(vect1_sigma,1,nb,NULL)!=OK_DLL) {
	       tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	       return(TT_ERR_PB_MALLOC);
	    }
	    vect2_fond[nbb] =vect1_fond[(int)(floor((double)nb/(double)2))+1];
	    vect2_sigma[nbb]=vect1_sigma[(int)(floor((double)nb/(double)2))+1];
	 }
	 if (methode==2) {
	    if (tt_util_qsort_double(vect1_fond,1,nb,NULL)!=OK_DLL) {
	       tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	       return(TT_ERR_PB_MALLOC);
	    }
	    nb=(int)(floor(0.8*(double)nb))+1;
	    tt_util_meansigma(vect1_fond,1,nb,&fond,&sigma);
	    nbb++;
	    vect2_fond[nbb] =fond;
	    vect2_sigma[nbb]=sigma;
	 }
      }

      for (xx=-1;xx<=1;xx++) {
	 x=(int) ((1.0+xx*0.8)*imax/2);
	 if ((x<1)||(x>(imax-2))) {
	    continue;
	 }
	 if (methode==1) {
       if (jmax>1) {
   	   nl2=1;
	      intens[1]=p->p[(int)((nl2-1)*imax)+(x-1)];
	      intens[2]=p->p[(int)((nl2  )*imax)+(x-1)];
	      intens[4]=p->p[(int)((nl2-1)*imax)+(x  )];
	      intens[5]=p->p[(int)((nl2  )*imax)+(x  )];
	      intens[7]=p->p[(int)((nl2-1)*imax)+(x+1)];
	      intens[8]=p->p[(int)((nl2  )*imax)+(x+1)];
       } else {
   	   nl2=1;
	      intens[1]=p->p[(int)((nl2-1)*imax)+(x-1)];
	      intens[2]=intens[1];
	      intens[4]=p->p[(int)((nl2-1)*imax)+(x  )];
	      intens[5]=intens[4];
	      intens[7]=p->p[(int)((nl2-1)*imax)+(x+1)];
	      intens[8]=intens[7];
       }
	 }
	 //for (nb=0,y=1;y<jmax-1;y++) {
	 for (nb=0,y=0;y<jmax-2;y++) {
	    if (methode==1) {
          if (jmax>2) {
   	       intens[3]=p->p[(int)((y+2)*imax)+(x-1)];
	          intens[6]=p->p[(int)((y+2)*imax)+(x  )];
	          intens[9]=p->p[(int)((y+2)*imax)+(x+1)];
          } else {
   	       intens[3]=p->p[(int)((y+2)*imax)+(x-1)];
	          intens[6]=p->p[(int)((y+2)*imax)+(x  )];
	          intens[9]=p->p[(int)((y+2)*imax)+(x+1)];
          }
	       mini=intens[5];
	       indice=5;
	       for (k=1;k<=4;k++) {if (intens[k]<=mini) {indice=k;} }
	       for (k=6;k<=9;k++) {if (intens[k]<=mini) {indice=k;} }
	       if (indice==5) {
		  nb++;
		  fond=0;
		  for (k=1;k<=4;k++) {fond+=intens[k];}
		  for (k=6;k<=9;k++) {fond+=intens[k];}
		  fond=fond/8;
		  vect1_fond[nb]=fond;
		  sigma=0;
		  for (k=1;k<=4;k++) {sigma+=((fond-intens[k])*(fond-intens[k]));}
		  for (k=6;k<=9;k++) {sigma+=((fond-intens[k])*(fond-intens[k]));}
		  sigma=sqrt(sigma/(double)7);
		  vect1_sigma[nb]=sigma;
	       }
	       intens[1]=intens[2];
	       intens[4]=intens[5];
	       intens[7]=intens[8];
	       intens[2]=intens[3];
	       intens[5]=intens[6];
	       intens[8]=intens[9];
	    }
	    if (methode==2) {
	       vect1_fond[++nb]=p->p[(int)((y+1  )*imax)+(x  )];
	    }
	 }
	 if ((nb!=0)&&(methode==1)) {
	    nbb++;
	    if (tt_util_qsort_double(vect1_fond,1,nb,NULL)!=OK_DLL) {
	       tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	       return(TT_ERR_PB_MALLOC);
	    }
	    if (tt_util_qsort_double(vect1_sigma,1,nb,NULL)!=OK_DLL) {
	       tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	       return(TT_ERR_PB_MALLOC);
	    }
	    vect2_fond[nbb] =vect1_fond[(int)(floor((double)nb/(double)2))+1];
	    vect2_sigma[nbb]=vect1_sigma[(int)(floor((double)nb/(double)2))+1];
	 }
	 if (methode==2) {
	    if (tt_util_qsort_double(vect1_fond,1,nb,NULL)!=OK_DLL) {
	       tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	       return(TT_ERR_PB_MALLOC);
	    }
	    nb=(int)(floor(0.8*(double)nb))+1;
	    tt_util_meansigma(vect1_fond,1,nb,&fond,&sigma);
	    nbb++;
	    vect2_fond[nbb] =fond;
	    vect2_sigma[nbb]=sigma;
	 }
      }
      if (nbb!=0) {
	 if (tt_util_qsort_double(vect2_fond,1,nbb,NULL)!=OK_DLL) {
	    tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	    return(TT_ERR_PB_MALLOC);
	 }
	 if (tt_util_qsort_double(vect2_sigma,1,nbb,NULL)!=OK_DLL) {
	    tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
	    return(TT_ERR_PB_MALLOC);
	 }
	 param_fond =vect2_fond[(int)(floor((double)nbb/(double)2))+1];
	 param_seuil=vect2_sigma[(int)(floor((double)nbb/(double)2))+1];
	 /*--- corrections empiriques ---*/
	 if (methode==1) {
	    sigma=1+0.6*exp(-param_seuil/8.0);
	    param_seuil*=sigma;
	 }
	 if (methode==2) {param_seuil*=1.2;}
      }
      methode++;
   } while ((param_seuil==0)&&(methode<=2)) ;

   tt_free(intens,"intens");tt_free(vect1_fond,"vect1_fond");tt_free(vect1_sigma,"vect1_sigma");tt_free(vect2_fond,"vect2_fond");tt_free(vect2_sigma,"vect2_sigma");
   *bgmean=param_fond;
   *bgsigma=param_seuil;
   return(OK_DLL);
}

int tt_util_transima1(TT_IMA_SERIES *pseries,double trans_x,double trans_y)
/***************************************************************************/
/* Translation d'une image.                                                */
/***************************************************************************/
/* trans_x valeur de la translation sur l'axe x                            */
/* trans_y valeur de la translation sur l'axe y                            */
/***************************************************************************/
{
   int imax,jmax;
   int ka,kb,kc,kd,x1,y1,x2,y2,k2;
   double value,xc1,yc1,alpha,beta,coef_a=0.,coef_b=0.,coef_c=0.,coef_d=0.;
   double nulval;
   TT_IMA *p_in,*p_out;
   p_in=pseries->p_in;
   p_out=pseries->p_out;
   nulval=pseries->nullpix_value;
   imax=p_in->naxis1;
   jmax=p_in->naxis2;
   if (jmax==1) {
      trans_y=0;
   }
   if (imax==1) {
      trans_x=0;
   }
   /* - boucle du grand balayage en y -*/
   for (y2=0;y2<jmax;y2++) {
      yc1=(double)y2-trans_y;
      y1=(int)floor(yc1);
      /* -  boucle du grand balayage en x -*/
      for (x2=0;x2<imax;x2++) {
	 xc1=(double)x2-trans_x;
	 x1=(int)floor(xc1);
	 if ((y2==0)&&(x2==0)) {
	    alpha=xc1-(double)x1;
	    beta=yc1-(double)y1;
	    coef_a=(1-alpha)*(1-beta);
	    coef_b=(1-alpha)*beta;
	    coef_c=alpha*(1-beta);
	    coef_d=alpha*beta;
	 }
	 if (jmax==1) {
	    if ((x1>=0)&&(x1<(imax-1))) {
	       ka=x1+y1*imax;
	       kc=x1+1+y1*imax;
	       value=coef_a*p_in->p[ka]+coef_c*p_in->p[kc];
	    } else {
	       value=nulval;
	    }
	 } else if (imax==1) {
	    if ((y1>=0)&&(y1<(jmax-1))) {
	       kb=x1+(y1+1)*imax;
	       kd=x1+1+(y1+1)*imax;
	       value=coef_b*p_in->p[kb]+coef_d*p_in->p[kd];
	    } else {
	       value=nulval;
	    }
	 } else {
	    if ((x1>=0)&&(x1<(imax-1))&&(y1>=0)&&(y1<(jmax-1))) {
	       ka=x1+y1*imax;
	       kb=x1+(y1+1)*imax;
	       kc=x1+1+y1*imax;
	       kd=x1+1+(y1+1)*imax;
	       value=coef_a*p_in->p[ka]+coef_b*p_in->p[kb]+coef_c*p_in->p[kc]+coef_d*p_in->p[kd];
	    } else {
	       value=nulval;
	    }
	 }
	 k2=x2+y2*imax;
	 p_out->p[k2]=(TT_PTYPE)(value);
      }
   }
   return(OK_DLL);
}

int tt_util_matrice_inverse_bilinaire(double *a, double *b)
/***************************************************************************/
/* Registration lineaire d'une image                                       */
/***************************************************************************/
/* En entree, le tableau a[6] contient la transformation :                 */
/*  x2 = a[0]*x1 + a[1]*y1 + a[2]                                          */
/*  y2 = a[3]*x1 + a[4]*y1 + a[5]                                          */
/*                                                                         */
/* En sortie, le tableau b[6] contient la transformation :                 */
/*  x1 = b[0]*x2 + b[1]*y2 + b[2]                                          */
/*  y1 = b[3]*x2 + b[4]*y2 + b[5]                                          */
/*                                                                         */
/***************************************************************************/
{
   double a1,b1,c1,d1,e1,f1;
   double delta;
   a1=a[0];
   b1=a[1];
   c1=a[2];
   d1=a[3];
   e1=a[4];
   f1=a[5];
   delta=b1*d1-a1*e1;
   if (delta==0.) {
      b[0]=a[0];
      b[1]=a[1];
      b[2]=a[2];
      b[3]=a[3];
      b[4]=a[4];
      b[5]=a[5];
   } else {
      b[0]=-e1/delta;
      b[1]= b1/delta;
      b[2]=-(b1*f1-c1*e1)/delta;
      b[3]= d1/delta;
      b[4]=-a1/delta;
      b[5]=-(c1*d1-a1*f1)/delta;
   }
   return(OK_DLL);
}

int tt_util_regima1(TT_IMA_SERIES *pseries)
/***************************************************************************/
/* Registration lineaire d'une image                                       */
/***************************************************************************/
/* le tableau a[6] contient la transformation :                            */
/*  x_in/ref = a[0]*x_in/in + a[1]*y_in/in + a[2]                          */
/*  y_in/ref = a[3]*x_in/in + a[4]*y_in/in + a[5]                          */
/*                                                                         */
/***************************************************************************/
{
   int imax,jmax;
   int iimax,jjmax;
   int ka,kb,kc,kd,x1,y1,x2,y2,k2;
   double value,xc1,yc1,alpha,beta,coef_a=0.,coef_b=0.,coef_c=0.,coef_d=0.;
   double a0,a1,a2,a3,a4,a5;
   double nulval,mult;
   double va,vb,vc,vd;
   TT_IMA *p_in,*p_out;
   TT_COEFA *p_dum;

   p_in=pseries->p_in;
   p_out=pseries->p_out;
   /*p_dum=&(pseries->coefa[0]);*/
   p_dum=&(pseries->coefa[pseries->index-1]);
   imax=p_in->naxis1;
   jmax=p_in->naxis2;
   iimax=p_out->naxis1;
   jjmax=p_out->naxis2;
   nulval=pseries->nullpix_value;
   if (pseries->normaflux==0.) {
      /* - calcule le facteur de flux par le produit vectoriel.        -*/
      /* - mult represente l'aire du parallelogramme dans le systeme 1 -*/
      /* - du carre elementaire de cote 1/1 dans le systeme 2.         -*/
      mult=fabs(p_dum->a[1]*p_dum->a[3]-p_dum->a[4]*p_dum->a[0]);
   } else {
      mult=pseries->normaflux;
   }
   /* - boucle du grand balayage en y -*/
   a0=p_dum->a[0];
   a1=p_dum->a[1];
   a2=p_dum->a[2];
   a3=p_dum->a[3];
   a4=p_dum->a[4];
   a5=p_dum->a[5];
   for (y2=0;y2<jjmax;y2++) {
      /* -  boucle du grand balayage en x -*/
      for (x2=0;x2<iimax;x2++) {
         xc1=p_dum->a[0]*x2+p_dum->a[1]*y2+p_dum->a[2];
         yc1=p_dum->a[3]*x2+p_dum->a[4]*y2+p_dum->a[5];
			if (pseries->pixint==TT_YES) {
				y1=(int)floor(yc1+.51);
				x1=(int)floor(xc1+.51);
			} else {
				y1=(int)floor(yc1);
				x1=(int)floor(xc1);
			}
         k2=x2+y2*iimax;
         if ((x1>=-1)&&(x1<=(imax-1))&&(y1>=-1)&&(y1<=(jmax-1))) {
				if (pseries->pixint==TT_YES) {
					if (x1==-1) { x1=0; }
					if (y1==-1) { y1=0; }
					ka=x1+y1*imax;
					value=p_in->p[ka];
				} else {
					alpha=xc1-(double)x1;
					beta=yc1-(double)y1;
					coef_a=(1-alpha)*(1-beta);
					coef_b=(1-alpha)*beta;
					coef_c=alpha*(1-beta);
					coef_d=alpha*beta;
					ka=x1+y1*imax;
					kb=x1+(y1+1)*imax;
					kc=x1+1+y1*imax;
					kd=x1+1+(y1+1)*imax;
					if (x1==-1) {
					  if (y1==-1) {
						 vd=p_in->p[kd];
						 value=vd;
					  } else {
						 if (y1==(jmax-1)) {
							vc=p_in->p[kc];
							value=vc;
						 } else {
							vc=p_in->p[kc];
							vd=p_in->p[kd];
							value=((1-beta)*vc+beta*vd);
							}
						 }
					} else  {
					  if (x1==(imax-1)) {
						 if (y1==-1) {
							vb=p_in->p[kb];
							value=vb;
						 } else {
							if (y1==(jmax-1)) {
							  va=p_in->p[ka];
							  value=va;
							} else {
							  va=p_in->p[ka];
							  vb=p_in->p[kb];
							  value=((1-beta)*va+beta*vb);
							  }
							}
					  } else {
						 if (y1==-1) {
							vb=p_in->p[kb];
							vd=p_in->p[kd];
							value=((1-alpha)*vb+alpha*vd);
						 } else {
							if (y1==(jmax-1)) {
							  va=p_in->p[ka];
							  vc=p_in->p[kc];
							  value=((1-alpha)*va+alpha*vc);
							} else {
							  va=p_in->p[ka];
							  vb=p_in->p[kb];
							  vc=p_in->p[kc];
							  vd=p_in->p[kd];
							  value=(coef_a*va+coef_b*vb+coef_c*vc+coef_d*vd);
							  }
							}
						 }
					}
				}
            p_out->p[k2]=(TT_PTYPE)(value*mult);
         } else {
            p_out->p[k2]=(TT_PTYPE)(nulval);
         }
      }
   }
   return(OK_DLL);
}

int tt_util_geostat(TT_IMA *p,char *filename,double fwhmsat,double seuil,double xc0, double yc0, double radius, int *nbsats, char *centroide)
/***************************************************************************/
/* Analyse des pixels de l'image pour detecter les satellites geostats     */
/***************************************************************************/
/* Boucle generale.                                                        */
/***************************************************************************/
/*                                                                         */
/* fwhmsat est la longueur des trainees                                    */
/* !!!! Les coordonnees pixels commencent en (0,0) !!!!                    */
/* 31 37 */
/***************************************************************************/
{
   int k,y,x,ya,yb,yc,xxd,yyd,xxf,yyf;
   double fwhmx,fwhmy,fond[4],detection,intensite;
   int xmax,ymax;
   double *v,*vec,valfond;
   int nsats;
   int nombre,taille,msg;
   int trainee,k1,k2,kk;
   double detection2=0.;
   double ra,dec,xcc,ycc,r1,r11,r2,r22,r3,r33,sx,sy,flux,fwhmxy;
   double dx,dy,dx2,dy2,d2,value,fmoy,fmed,seuilf,f23,sigma;
   int xx1,xx2,yy1,yy2,n23,n23d,n23f,i,j,valid_ast;
   double dx0,dy0,d0;
   TT_ASTROM p_ast;
   FILE *fic;
//pour centroide
   double **mat, pp[6],ecart;
   int sizex, sizey;


   /* --- chercher les dimensions de l'image ---*/
   xmax=p->naxis1;
   ymax=p->naxis2;
   /* --- lit les parametres astrometriques de l'image ---*/
   valid_ast=1;
   tt_util_getkey0_astrometry(p,&p_ast,&valid_ast);
   /* --- Calcul du critere de qualite stellaire ---*/
   nsats=0;
   nombre=10;
   taille=sizeof(double);
   v=NULL;
   if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&v,&nombre,&taille,"v"))!=OK_DLL) {
      tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_geostat (pointer v)");
      return(TT_ERR_PB_MALLOC);
   }
   /* --- ouvre le fichier en ecriture ---*/
   fic=fopen(filename,"wt");
   /* --- grande boucle sur l'image ---*/
   d0=radius*radius;
   for (y=1;y<ymax-1;y++) {
      if ((y>ymax)||(y<0)) { continue; }
      ya=xmax*(y-1);
      yb=xmax*y;
      yc=xmax*(y+1);
      dy0=(y-yc0)*(y-yc0);
      for (x=1;x<xmax;x++) {
         if ((x>xmax)||(x<0)) { continue; }
         dx0=(x-xc0)*(x-xc0);
         if ((dy0+dx0)>d0) { continue; }
	      v[1]=p->p[ya+x-1];
	      v[5]=p->p[yb+x  ];
	      if (v[5]>v[1]) {
	         v[2]=p->p[ya+x  ];
	         v[3]=p->p[ya+x+1];
	         v[4]=p->p[yb+x-1];
	         if ((v[5]>v[2])&&(v[5]>v[3])&&(v[5]>v[4])) {
	            v[6]=p->p[yb+x+1];
	            v[7]=p->p[yc+x-1];
	            v[8]=p->p[yc+x  ];
	            v[9]=p->p[yc+x+1];
	            if ((v[5]>=v[6])&&(v[5]>=v[7])&&(v[5]>=v[8])&&(v[5]>=v[9])) {
		            /* --- maximum local detecte ---*/
  		            /* --- recherche le fond local ---*/
		            fwhmx=0;
		            for (k=x;k<=(xmax-2);k++) {
		               if ((p->p[xmax*y+k]-p->p[xmax*y+k+1])<=0) break;
		               else fwhmx+=1;
		            }
		            k--;
           		   xxf=k;
		            /*printf("-> %d/%d\n",xmax*y+k+1,longueur);*/
		            fond[0]=p->p[xmax*y+k+1];
		            for (k=x;k>=1;k--) {
		            if ((p->p[xmax*y+k]-p->p[xmax*y+k-1])<=0) break;
		            else fwhmx+=1;
		            }
		            k++;
		            xxd=k;
                  fwhmx/=2.;
		            /*printf("-> %d/%d\n",xmax*y+k-1,longueur);*/
		            fond[1]=p->p[xmax*y+k-1];
		            fwhmy=0;
           		   for (k=y;k<=(ymax-2);k++) {
		               if ((p->p[xmax*k+x]-p->p[xmax*(k+1)+x])<=0) break;
		               else fwhmy+=1;
		            }
		            k--;
		            yyf=k;
		            /*printf("-> %d/%d\n",xmax*(k+1)+x,longueur);*/
		            fond[2]=p->p[xmax*(k+1)+x];
		            for (k=y;k>=1;k--) {
		               if ((p->p[xmax*k+x]-p->p[xmax*(k-1)+x])<=0) break;
		               else fwhmy+=1;
		            }
		            k++;
		            yyd=k;
                  fwhmy/=2.;
		            /*printf("-> %d %d/%d\n",k,xmax*(k-1)+x,longueur);*/
		            fond[3]=p->p[xmax*(k-1)+x];
                  /* valfond est le fond mini */
                  valfond=fond[0];
                  for (k=1;k<4;k++) {
                     if (fond[k]<valfond) {
                        valfond=fond[k];
                     }
                  }
                  detection=valfond+seuil;
                  /* maximum local>detect ET ce n'est pas un cosmique */
                  if ((v[5]>=detection)&&(fwhmx>1.)&&(fwhmy>1.)) {
                     detection2=valfond+0.5*(v[5]-valfond);
                     trainee=0;
                     /* on recherche une trainee a gauche */
                     k1=(int)((double)x-0.4*fwhmsat);
                     if (k1<0) {k1=0;}
                     k2=x;
   		            for (kk=0,k=k1;k<=k2;k++) {
		                  if (p->p[xmax*y+k]>=detection2) {
                           kk++;
                        }
		               }
                     if (kk>(int)(0.8*(k2-k1))) {
                        trainee=-1;
                     }
                     /* on recherche une trainee a droite */
                     k1=x;
                     k2=(int)((double)x+0.4*fwhmsat);
                     if (k2>(xmax-1)) {k2=xmax-1;}
   		            for (kk=0,k=k1;k<=k2;k++) {
		                  if (p->p[xmax*y+k]>=detection2) {
                           kk++;
                        }
		               }
                     if (kk>(int)(0.8*(k2-k1))) {
                        trainee=1;
                     }
                     if ((trainee==0)&&(fwhmx<=(0.4*fwhmsat))&&(fwhmy<=(0.4*fwhmsat))) {
		                  /* --- Pas de trainee donc un objet ponctuel a ete detecte ---*/
                        nsats++;
		                  intensite=v[5]-valfond;
                        /* --- parametres de mesure precise ---*/
                        xcc=(double)x;
                        ycc=(double)y;
                        fwhmxy=(fwhmx>fwhmy)?fwhmx:fwhmy;
                        r1=1.5*fwhmxy;
                        r2=2.0*fwhmxy;
                        r3=2.5*fwhmxy;
                        r11=r1*r1;
                        r22=r2*r2;
                        r33=r3*r3;
                        /* --- fond de ciel precis (fmoy,fmed,sigma) ---*/
                        xx1=(int)(xcc-r3);
                        xx2=(int)(xcc+r3);
                        yy1=(int)(ycc-r3);
                        yy2=(int)(ycc+r3);
                        if (xx1<0) xx1=0;
                        if (xx1>=xmax) xx1=xmax-1;
                        if (xx2<0) xx2=0;
                        if (xx2>=xmax) xx2=xmax-1;
                        if (yy1<0) yy1=0;
                        if (yy1>=ymax) yy1=ymax-1;
                        if (yy2<0) yy2=0;
                        if (yy2>=ymax) yy2=ymax-1;
                        nombre=(xx2-xx1+1)*(yy2-yy1+1);
                        taille=sizeof(double);
                        vec=NULL;
                        if ((msg=libtt_main0(TT_UTIL_CALLOC_PTR,4,&vec,&nombre,&taille,"vf"))!=OK_DLL) {
                           tt_free(v,"v");
                           fclose(fic);
                           tt_errlog("",TT_ERR_PB_MALLOC,"Pb alloc in tt_util_geostat (pointer vec)");
                           return(TT_ERR_PB_MALLOC);
                        }
                        n23=0;
                        f23=0.;
                        for (j=yy1;j<=yy2;j++) {
                           dy=1.*j-ycc;
                           dy2=dy*dy;
                           for (i=xx1;i<=xx2;i++) {
                              dx=1.*i-xcc;
                              dx2=dx*dx;
                              d2=dx2+dy2;
                              if ((d2>=r22)&&(d2<=r33)) {
	                              vec[n23]=(double)p->p[xmax*j+i];
                                 f23 += (double)p->p[xmax*j+i];
                                 n23++;
                              }
                           }
                        }
                        tt_util_qsort_double(vec,0,n23,NULL);
                        fmoy=vec[0];
                        if (n23!=0) {fmoy=f23/n23;}
                        /* calcule la valeur du fond pour 50 pourcent de l'histogramme*/
                        fmed=(float)vec[(int)(0.5*n23)];
                        /*  calcul de l'ecart type du fond de ciel*/
                        /*  en excluant les extremes a +/- 10 %*/
                        sigma=0.;
                        n23d=(int)(0.1*(n23-1));
                        n23f=(int)(0.9*(n23-1));
                        for (i=n23d;i<=n23f;i++) {
                           d2=(vec[i]-fmed);
                           sigma+=(d2*d2);
                        }
                        if ((n23f-n23d)!=0) {
                           sigma=sqrt(sigma/(n23f-n23d));
                        }
                        tt_free(vec,"vec");

						//test sur le mot centroide
						if(strcmp (centroide,"gauss")==0) {
							//fitte une gaussienne pour la recherche du centroide
							/*
							pp = (double*)calloc(6,sizeof(double));
							ecart = (double*)calloc(1,sizeof(double));
							*/

							xx1=(int)(xcc-2*r1);
							xx2=(int)(xcc+2*r1);
							yy1=(int)(ycc-2*r1);
							yy2=(int)(ycc+2*r1);
							if (xx1<0) xx1=0;
							if (xx1>=xmax) xx1=xmax-1;
							if (xx2<0) xx2=0;
							if (xx2>=xmax) xx2=xmax-1;
							if (yy1<0) yy1=0;
							if (yy1>=ymax) yy1=ymax-1;
							if (yy2<0) yy2=0;
							if (yy2>=ymax) yy2=ymax-1;
							sizex=xx2-xx1+1;
							sizey=yy2-yy1+1;

							//fixe la taille de la fenêtre de travail: sizex et sizey
							mat = (double**)calloc(sizex,sizeof(double));
							for(k=0;k<sizex;k++) {
								*(mat+k) = (double*)calloc(sizey,sizeof(double));
							}
							//--- Mise a zero des deux buffers 
							for(k=0;k<sizex;k++) {
								for(k2=0;k2<sizey;k2++) {
									mat[k][k2]=(double)0.;
								}
							}

							for (j=0;j<sizey;j++) {  
							   for (i=0;i<sizex;i++) {	  
								  mat[i][j]=p->p[xmax*(j+yy1)+i+xx1];
							   }
							}

							tt_fitgauss2d (sizex,sizey,mat,pp,&ecart);
							xcc=pp[1]+xx1;
							ycc=pp[4]+yy1;
							for(k=0;k<sizex;k++) {
								free(mat[k]);
							}
							free(mat);
						} else {
							/* --- photocentre (xc,yc) ---*/
							xx1=(int)(xcc-r1);
							xx2=(int)(xcc+r1);
							yy1=(int)(ycc-r1);
							yy2=(int)(ycc+r1);
							if (xx1<0) xx1=0;
							if (xx1>=xmax) xx1=xmax-1;
							if (xx2<0) xx2=0;
							if (xx2>=xmax) xx2=xmax-1;
							if (yy1<0) yy1=0;
							if (yy1>=ymax) yy1=ymax-1;
							if (yy2<0) yy2=0;
							if (yy2>=ymax) yy2=ymax-1;
							seuilf=0.2*(v[5]-fmed);
							sx=0.;
							sy=0.;
							flux=0.;
							for (j=yy1;j<=yy2;j++) {
							   dy=1.*j-ycc;
							   dy2=dy*dy;
							   for (i=xx1;i<=xx2;i++) {
								  dx=1.*i-xcc;
								  dx2=dx*dx;
								  d2=dx2+dy2;
								  value=(double)p->p[xmax*j+i]-fmed;
								  if ((d2<=r11)&&(value>=seuilf)) {
									 flux += value;
									 sx += (double)(i * value);
									 sy += (double)(j * value);
								  }
							   }
							}
							if (flux!=0.) {
							   xcc = sx / flux ;
							   ycc = sy / flux ;
							}
						}


                        /* --- photometrie (flux) ---*/
                        xx1=(int)(xcc-r1);
                        xx2=(int)(xcc+r1);
                        yy1=(int)(ycc-r1);
                        yy2=(int)(ycc+r1);
                        if (xx1<0) xx1=0;
                        if (xx1>=xmax) xx1=xmax-1;
                        if (xx2<0) xx2=0;
                        if (xx2>=xmax) xx2=xmax-1;
                        if (yy1<0) yy1=0;
                        if (yy1>=ymax) yy1=ymax-1;
                        if (yy2<0) yy2=0;
                        if (yy2>=ymax) yy2=ymax-1;
                        flux=0.;
                        for (j=yy1;j<=yy2;j++) {
                           dy=1.*j-ycc;
                           dy2=dy*dy;
                           for (i=xx1;i<=xx2;i++) {
                              dx=1.*i-xcc;
                              dx2=dx*dx;
                              d2=dx2+dy2;
                              value=(double)p->p[xmax*j+i]-fmed;
                              if ((d2<=r11)) {
                                 flux += value;
                              }
                           }
                        }
                        /* --- astrometrie (ra,dec) ---*/
                        ra=0.;
                        dec=0.;
                        if (valid_ast==TT_YES) {
                           tt_util_astrom_xy2radec(&p_ast,xcc,ycc,&ra,&dec);
                        }
                        ra*=180./(TT_PI);
                        dec*=180./(TT_PI);
                        /* --- sortie du resultat ---*/
			               fprintf(fic,"%d %f %f %f %f %f %f %f %f\n",
                           nsats,xcc+1.,ycc+1.,flux,fmed,ra,dec,fwhmx,fwhmy);
                     }
                  }
               }
            }
         }
      }
   }
   tt_free(v,"v");
   fclose(fic);
   *nbsats=nsats;
   return(OK_DLL);
}

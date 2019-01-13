/* tt_time1.c
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

int tt_ima2jd(TT_IMA *p,int numlist,double *jd)
/***************************************************************************/
/***************************************************************************/
/* numlist=0 : pour rechercher dans la liste principale                    */
/* numlist=1 : pour rechercher dans la liste de reference                  */
/* numlist=2 : pour rechercher dans la liste nouvelle                      */
/***************************************************************************/
{
   int k,mjd_found=TT_NO;
   if (numlist==0) {
      if ((p->keyused==TT_YES)&&(p->nbkeys>0)) {
         for (k=0;k<(p->nbkeys);k++) {
            if (strcmp(p->keynames[k],"MJD-OBS")==0) {
               *jd=(atof(p->values[k])+2400000.5);
               mjd_found=TT_YES;
            }
            if (mjd_found==TT_NO) {
               if (strcmp(p->keynames[k],"DATE-OBS")==0) {
                  tt_dateobs2jd(p->values[k],jd);
               }
            }
         }
      }
      return(OK_DLL);
   }
   if (numlist==1) {
      if ((p->ref_keyused==TT_YES)&&(p->ref_nbkeys>0)) {
         for (k=0;k<(p->ref_nbkeys);k++) {
            if (strcmp(p->ref_keynames[k],"MJD-OBS")==0) {
               *jd=(atof(p->ref_values[k])+2400000.5);
               mjd_found=TT_YES;
            }
            if (mjd_found==TT_NO) {
               if (strcmp(p->ref_keynames[k],"DATE-OBS")==0) {
                  tt_dateobs2jd(p->ref_values[k],jd);
               }
            }
         }
      }
      return(OK_DLL);
   }
   if (numlist==2) {
      if ((p->new_keyused==TT_YES)&&(p->new_nbkeys>0)) {
         for (k=0;k<(p->new_nbkeys);k++) {
            if (strcmp(p->new_keynames[k],"MJD-OBS")==0) {
               *jd=(atof(p->new_values[k])+2400000.5);
               mjd_found=TT_YES;
            }
            if (mjd_found==TT_NO) {
               if (strcmp(p->new_keynames[k],"DATE-OBS")==0) {
                  tt_dateobs2jd(p->new_values[k],jd);
               }
            }
         }
      }
      return(OK_DLL);
   }
   return(OK_DLL);
}

int tt_ima2exposure(TT_IMA *p,int numlist,double *exposure)
/***************************************************************************/
/***************************************************************************/
/* numlist=0 : pour rechercher dans la liste principale                    */
/* numlist=1 : pour rechercher dans la liste de reference                  */
/* numlist=2 : pour rechercher dans la liste nouvelle                      */
/***************************************************************************/
{
   int k;
   int exp_found=TT_NO;

   if (numlist==0) {
      if ((p->keyused==TT_YES)&&(p->nbkeys>0)) {
         for (k=0;k<(p->nbkeys);k++) {
            if (strcmp(p->keynames[k],"EXPOSURE")==0) {
               *exposure=(double)atof(p->values[k]);
               exp_found = TT_YES;
            }
            if (exp_found==TT_NO) {
               if (strcmp(p->keynames[k],"EXPTIME")==0) {
                  *exposure=(double)atof(p->values[k]);
               }
            }
         }
      }
      return(OK_DLL);
   }
   if (numlist==1) {
      if ((p->ref_keyused==TT_YES)&&(p->ref_nbkeys>0)) {
         for (k=0;k<(p->ref_nbkeys);k++) {
            if (strcmp(p->ref_keynames[k],"EXPOSURE")==0) {
               *exposure=(double)atof(p->ref_values[k]);
               exp_found = TT_YES;
            }
            if (exp_found==TT_NO) {
               if (strcmp(p->ref_keynames[k],"EXPTIME")==0) {
                  *exposure=(double)atof(p->values[k]);
               }
            }
         }
      }
      return(OK_DLL);
   }
   if (numlist==2) {
      if ((p->new_keyused==TT_YES)&&(p->new_nbkeys>0)) {
         for (k=0;k<(p->new_nbkeys);k++) {
            if (strcmp(p->new_keynames[k],"EXPOSURE")==0) {
               *exposure=(double)atof(p->new_values[k]);
               exp_found = TT_YES;
            }
            if (exp_found==TT_NO) {
               if (strcmp(p->new_keynames[k],"EXPTIME")==0) {
                  *exposure=(double)atof(p->values[k]);
               }
            }
         }
      }
      return(OK_DLL);
   }
   return(OK_DLL);
}

void tt_date2jd(int annee, int mois, double jour, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/* annee : valeur de l'annee correspondante                                */
/* mois  : valeur du mois correspondant                                    */
/* jour  : valeur du jour decimal correspondant                            */
/* *jj   : valeur du jour julien converti                                  */
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   a=(double)annee;
   m=(double)mois;
   j=jour;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   *jj=jd;
}

void tt_jd2date(double jj, int *annee, int *mois, double *jour)
/***************************************************************************/
/* Donne la date correspondant a un jour julien                            */
/***************************************************************************/
/* jj     : valeur du jour julien a convertir                              */
/* *annee : valeur de l'annee correspondante                               */
/* *mois  : valeur du mois correspondant                                   */
/* *jour  : valeur du jour decimal correspondant                           */
/***************************************************************************/
{
   double alpha,a,z,f,b,c,d,e;
   jj+=.5;
   z=floor(jj);
   f=jj-z;
   alpha=floor((z-1867216.25)/36524.25);
   a=z+1+alpha-floor(alpha/4);
   b=a+1524;
   c=floor(((b-122.1)/365.25));
   d=floor(365.25*c);
   e=floor((b-d)/30.6001);
   *jour=b-d-floor(30.6001*e)+f;
   *mois= (e<14) ? (int)(e-1) : (int)(e-13) ;
   *annee= (*mois>2) ? (int)(c-4716) : (int)(c-4715) ;
}

void tt_dateobs2jd(char *date, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/* *date : au format FITS                                                  */
/* *jj   : valeur du jour julien converti                                  */
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   int annee,mois,jour,heure,minute;
   double seconde;
#ifdef OS_LINUX_GCC_SO
   sscanf(date,"%d-%d-%dT%d:%d:%lf",&annee,&mois,&jour,&heure,&minute,&seconde);
#else
   sscanf(date,"%ld-%ld-%ldT%ld:%ld:%lf",&annee,&mois,&jour,&heure,&minute,&seconde);
#endif
   a=(double)annee;
   m=(double)mois;
   j=(double)jour+((double)heure+((double)minute+seconde/60)/60)/24;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   *jj=jd;
}

void tt_jd2dateobs(double jj, char *date)
/***************************************************************************/
/* Donne la date correspondant a un jour julien                            */
/***************************************************************************/
/* jj     : valeur du jour julien a convertir                              */
/* *date : au format FITS                                                  */
/***************************************************************************/
{
   double alpha,a,z,f,b,c,d,e;
   int annee,mois,jour,heure,minute,k,seca,secb;
   double jourd,heured,minuted,seconde;
   jj+=.5;
   z=floor(jj);
   f=jj-z;
   alpha=floor((z-1867216.25)/36524.25);
   a=z+1+alpha-floor(alpha/4);
   b=a+1524;
   c=floor(((b-122.1)/365.25));
   d=floor(365.25*c);
   e=floor((b-d)/30.6001);
   jourd=b-d-floor(30.6001*e)+f; // j'ajoute un millime de seconde pour compenser les arrondis des divisions precedente
   mois= (e<14) ? (int)(e-1) : (int)(e-13) ;
   annee= (mois>2) ? (int)(c-4716) : (int)(c-4715) ;
   if ((annee>=0)&&(annee<=9999)) {
      jour=(int)floor(jourd);
      heured=(jourd-jour)*24;
      heure=(int)floor(heured);
      minuted=(heured-heure)*60;
      minute=(int)floor(minuted);
      seconde=(minuted-minute)*60;
   } else {
      annee=0;
      mois=0;
      jour=0;
      heure=0;
      minute=0;
      seconde=0.;
   }
   seca=(int)(floor(seconde));
   secb=(int)(floor((seconde-(double)seca)*1.e3));
#ifdef OS_LINUX_GCC_SO
   sprintf(date,"%4d-%2d-%2dT%2d:%2d:%2d.%3d",annee,mois,jour,heure,minute,seca,secb);
#else
   sprintf(date,"%4ld-%2ld-%2ldT%2ld:%2ld:%2ld.%3ld",annee,mois,jour,heure,minute,seca,secb);
#endif
   for (k=0;k<=(int)strlen(date);k++) {if (date[k]==' ') date[k]='0';}
}

int tt_dateobs_release(TT_IMA *p,int numlist)
/***************************************************************************/
/***************************************************************************/
/* numlist=0 : pour rechercher uniquement dans la liste principale         */
/* numlist=1 : pour rechercher uniquement dans la liste de reference       */
/* numlist=2 : pour rechercher dans la liste principale puis celle de ref  */
/* numlist=3 : pour rechercher dans la liste de ref puis celle principale  */
/***************************************************************************/
{
   int k;
   int ind_date_obs0=-1,ind_time_obs0=-1,ind_exptime0=-1,ind_mjd_obs0=-1;
   int ind_date_obs1=-1,ind_time_obs1=-1,ind_exptime1=-1,ind_mjd_obs1=-1;
   char new_date_obs0[FLEN_VALUE];
   char new_date_obs1[FLEN_VALUE];
   double new_exptime0=-1.;
   double new_exptime1=-1.;
   double dummy;

   strcpy(new_date_obs0,"");
   strcpy(new_date_obs1,"");
   if ((numlist==0)||(numlist==2)||(numlist==3)) {
      if ((p->keyused==TT_YES)&&(p->nbkeys>0)) {
	 for (k=0;k<(p->nbkeys);k++) {
	    if (strcmp(p->keynames[k],"MJD-OBS")==0) {ind_mjd_obs0=k;}
	    if (strcmp(p->keynames[k],"DATE-OBS")==0) {ind_date_obs0=k;}
	    if (strcmp(p->keynames[k],"DATE_OBS")==0) {ind_date_obs0=k;}
	    if (strcmp(p->keynames[k],"TM_START")==0) {ind_time_obs0=k;}
	    if (strcmp(p->keynames[k],"TM-START")==0) {ind_time_obs0=k;}
	    if (strcmp(p->keynames[k],"UT_START")==0) {ind_time_obs0=k;}
	    if (strcmp(p->keynames[k],"UT-START")==0) {ind_time_obs0=k;}
	    if (strcmp(p->keynames[k],"UTIME")==0)    {ind_time_obs0=k;}
	    if (strcmp(p->keynames[k],"TIME")==0)     {ind_time_obs0=k;}
	    if (strcmp(p->keynames[k],"EXPTIME")==0)  {ind_exptime0=k;}
	    if (strcmp(p->keynames[k],"INTTIME")==0)  {ind_exptime0=k;}
	    if (strcmp(p->keynames[k],"EXPOSURE")==0) {ind_exptime0=k;}
	    if (strcmp(p->keynames[k],"ITIME")==0)    {ind_exptime0=k;}
	 }
	 if (ind_date_obs0!=-1) {
	    if (p->datatypes[ind_date_obs0]==TSTRING) {
	       if (ind_time_obs0!=-1) {
		  if (p->datatypes[ind_time_obs0]==TSTRING) {
		     tt_dateobs_convert(p->values[ind_date_obs0],p->values[ind_time_obs0],new_date_obs0);
		  } else {
		     tt_dateobs_convert(p->values[ind_date_obs0],NULL,new_date_obs0);
		  }
	       } else {
		  tt_dateobs_convert(p->values[ind_date_obs0],NULL,new_date_obs0);
	       }
	    } else {
	       tt_jd2dateobs((double)atof(p->keynames[ind_date_obs0]),new_date_obs0);
	    }
	 }

	 if (ind_exptime0!=-1) {
	    if ((strcmp(p->units[ind_exptime0],"")==0)||(strcmp(p->units[ind_exptime0],"s")==0)) {
	       new_exptime0=(double)atof(p->values[ind_exptime0]);
	    } else if (strcmp(p->units[ind_exptime0],"min")==0) {
	       new_exptime0=60.*(double)atof(p->values[ind_exptime0]);
	    } else if (strcmp(p->units[ind_exptime0],"h")==0) {
	       new_exptime0=3600.*(double)atof(p->values[ind_exptime0]);
	    } else if (strcmp(p->units[ind_exptime0],"ms")==0) {
	       new_exptime0=0.001*(double)atof(p->values[ind_exptime0]);
	    }
	 }

	 if (ind_mjd_obs0!=-1) {
	    if ((p->datatypes[ind_mjd_obs0]==TFLOAT)||(p->datatypes[ind_mjd_obs0]==TDOUBLE)) {
           dummy=atof(p->values[ind_mjd_obs0])+2400000.5;
	       tt_jd2dateobs(dummy,new_date_obs0);
	    }
	 }

      }
   }

   if ((numlist==1)||(numlist==2)||(numlist==3)) {
      if ((p->ref_keyused==TT_YES)&&(p->ref_nbkeys>0)) {
	 for (k=0;k<(p->ref_nbkeys);k++) {
	    if (strcmp(p->ref_keynames[k],"MJD-OBS")==0) {ind_mjd_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"DATE-OBS")==0) {ind_date_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"DATE_OBS")==0) {ind_date_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"TM_START")==0) {ind_time_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"TM-START")==0) {ind_time_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"UT_START")==0) {ind_time_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"UT-START")==0) {ind_time_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"UTIME")==0)    {ind_time_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"TIME")==0)     {ind_time_obs1=k;}
	    if (strcmp(p->ref_keynames[k],"EXPTIME")==0)  {ind_exptime1=k;}
	    if (strcmp(p->ref_keynames[k],"INTTIME")==0)  {ind_exptime1=k;}
	    if (strcmp(p->ref_keynames[k],"EXPOSURE")==0) {ind_exptime1=k;}
	    if (strcmp(p->ref_keynames[k],"ITIME")==0)    {ind_exptime1=k;}
	 }
	 if (ind_date_obs1!=-1) {
	    if (p->ref_datatypes[ind_date_obs1]==TSTRING) {
	       if (ind_time_obs1!=-1) {
		  if (p->ref_datatypes[ind_time_obs1]==TSTRING) {
		     tt_dateobs_convert(p->ref_values[ind_date_obs1],p->ref_values[ind_time_obs1],new_date_obs1);
		  } else {
		     tt_dateobs_convert(p->ref_values[ind_date_obs1],NULL,new_date_obs1);
		  }
	       } else {
		  tt_dateobs_convert(p->ref_values[ind_date_obs1],NULL,new_date_obs1);
	       }
	    } else {
	       tt_jd2dateobs(atof(p->ref_keynames[ind_date_obs1]),new_date_obs1);
	    }
	 }
	 if (ind_exptime1!=-1) {
	    if ((strcmp(p->ref_units[ind_exptime1],"")==0)||(strcmp(p->ref_units[ind_exptime1],"s")==0)) {
	       new_exptime1=(double)atof(p->ref_values[ind_exptime1]);
	    } else if (strcmp(p->ref_units[ind_exptime1],"min")==0) {
	       new_exptime1=60.*(double)atof(p->ref_values[ind_exptime1]);
	    } else if (strcmp(p->ref_units[ind_exptime1],"h")==0) {
	       new_exptime1=3600.*(double)atof(p->ref_values[ind_exptime1]);
	    } else if (strcmp(p->ref_units[ind_exptime1],"ms")==0) {
	       new_exptime1=0.001*(double)atof(p->ref_values[ind_exptime1]);
	    }
	 }

	 if (ind_mjd_obs1!=-1) {
	    if ((p->ref_datatypes[ind_mjd_obs1]==TFLOAT)||(p->ref_datatypes[ind_mjd_obs1]==TDOUBLE)) {
           dummy=atof(p->ref_values[ind_mjd_obs1])+2400000.5;
	       tt_jd2dateobs(dummy,new_date_obs1);
	    }
	 }

      }
   }

   /* --- on remplit la nouvelle liste ---*/
   if (numlist==0) {
      if (strcmp(new_date_obs0,"")!=0) {
	 tt_imanewkey(p,"DATE-OBS",new_date_obs0,TSTRING,"Start of exposure. FITS standard","ISO 8601");
	 tt_dateobs2jd(new_date_obs0,&dummy);
	 dummy-=2400000.5;
	 tt_imanewkey(p,"MJD-OBS",&dummy,TDOUBLE,"Start of exposure. Modified JD","d");
      }
      if (new_exptime0>=0) {
	 tt_imanewkey(p,"EXPOSURE",&new_exptime0,TDOUBLE,"total exposure time","s");
      }
   } else if (numlist==1) {
      if (strcmp(new_date_obs1,"")!=0) {
	 tt_imanewkey(p,"DATE-OBS",new_date_obs1,TSTRING,"Start of exposure. FITS standard","ISO 8601");
	 tt_dateobs2jd(new_date_obs1,&dummy);
	 dummy-=2400000.5;
	 tt_imanewkey(p,"MJD-OBS",&dummy,TDOUBLE,"Start of exposure. Modified JD","d");
      }
      if (new_exptime1>=0) {
	 tt_imanewkey(p,"EXPOSURE",&new_exptime1,TDOUBLE,"total exposure time","s");
      }
   } else if (numlist==2) {
      if (strcmp(new_date_obs0,"")!=0) {
	 tt_imanewkey(p,"DATE-OBS",new_date_obs0,TSTRING,"Start of exposure. FITS standard","ISO 8601");
	 tt_dateobs2jd(new_date_obs0,&dummy);
	 dummy-=2400000.5;
	 tt_imanewkey(p,"MJD-OBS",&dummy,TDOUBLE,"Start of exposure. Modified JD","d");
      } else if (strcmp(new_date_obs1,"")!=0) {
	 tt_imanewkey(p,"DATE-OBS",new_date_obs1,TSTRING,"Start of exposure. FITS standard","ISO 8601");
	 tt_dateobs2jd(new_date_obs1,&dummy);
	 dummy-=2400000.5;
	 tt_imanewkey(p,"MJD-OBS",&dummy,TDOUBLE,"Start of exposure. Modified JD","d");
      }
      if (new_exptime0>=0) {
	 tt_imanewkey(p,"EXPOSURE",&new_exptime0,TDOUBLE,"total exposure time","s");
      } else if (new_exptime1>=0) {
	 tt_imanewkey(p,"EXPOSURE",&new_exptime1,TDOUBLE,"total exposure time","s");
      }
   } else if (numlist==3) {
      if (strcmp(new_date_obs1,"")!=0) {
	 tt_imanewkey(p,"DATE-OBS",new_date_obs1,TSTRING,"Start of exposure. FITS standard","ISO 8601");
	 tt_dateobs2jd(new_date_obs1,&dummy);
	 dummy-=2400000.5;
	 tt_imanewkey(p,"MJD-OBS",&dummy,TDOUBLE,"Start of exposure. Modified JD","d");
      } else if (strcmp(new_date_obs0,"")!=0) {
	 tt_imanewkey(p,"DATE-OBS",new_date_obs0,TSTRING,"Start of exposure. FITS standard","ISO 8601");
	 tt_dateobs2jd(new_date_obs0,&dummy);
	 dummy-=2400000.5;
	 tt_imanewkey(p,"MJD-OBS",&dummy,TDOUBLE,"Start of exposure. Modified JD","d");
      }
      if (new_exptime1>=0) {
	 tt_imanewkey(p,"EXPOSURE",&new_exptime1,TDOUBLE,"total exposure time","s");
      } else if (new_exptime0>=0) {
	 tt_imanewkey(p,"EXPOSURE",&new_exptime0,TDOUBLE,"total exposure time","s");
      }
   }
   return(OK_DLL);
}

int tt_dateobs_convert(char *date_obs, char *time_obs, char *new_date_obs)
/***************************************************************************/
/***************************************************************************/
/***************************************************************************/
{
   int annee,mois,jour,heure,minute,rien,seca,secb;
   int time_used,k;
   double seconde;
   /* --- conversion des formats de date et heure en norme FITS ---*/
   annee=0;
   mois=0;
   jour=0;
   heure=0;
   minute=0;
   seconde=0.;
   time_used=TT_NO;
   if (strlen(date_obs)>=10) {
      if (date_obs[10]=='T') {
#ifdef OS_LINUX_GCC_SO
	 if (sscanf(date_obs,"%d-%d-%dT%d:%d:%lf",&annee,&mois,&jour,&heure,&minute,&seconde)==6) {
#else
	 if (sscanf(date_obs,"%ld-%ld-%ldT%ld:%ld:%lf",&annee,&mois,&jour,&heure,&minute,&seconde)==6) {
#endif
	    time_used=TT_YES;
	 }
      }
   }
   if (date_obs[2]=='/') {
#ifdef OS_LINUX_GCC_SO
      sscanf(date_obs,"%d/%d/%d",&jour,&mois,&annee);
#else
      sscanf(date_obs,"%ld/%ld/%ld",&jour,&mois,&annee);
#endif
      if (jour>31) {rien=annee; annee=jour; jour=rien;}
      if (annee<75) {annee+=2000;} else if ((annee>=75)&&(annee<=99)) {annee+=1900;}
   } else if (date_obs[4]=='-') {
#ifdef OS_LINUX_GCC_SO
      sscanf(date_obs,"%d-%d-%d",&annee,&mois,&jour);
   } else if (date_obs[4]=='/') {
      sscanf(date_obs,"%d-%d-%d",&annee,&mois,&jour);
#else
      sscanf(date_obs,"%ld-%ld-%ld",&annee,&mois,&jour);
   } else if (date_obs[4]=='/') {
      sscanf(date_obs,"%ld-%ld-%ld",&annee,&mois,&jour);
#endif
   }
   if (time_obs!=NULL) {
#ifdef OS_LINUX_GCC_SO
      if (sscanf(time_obs,"%d:%d:%lf",&heure,&minute,&seconde)==3) {
#else
      if (sscanf(time_obs,"%ld:%ld:%lf",&heure,&minute,&seconde)==3) {
#endif
	 time_used=TT_YES;
      }
   }
   if (time_used==TT_YES) {
      seca=(int)(floor(seconde));
      secb=(int)(floor((seconde-(double)seca)*1.e3+.0001));
      sprintf(new_date_obs,"%4d-%2d-%2dT%2d:%2d:%2d.%3d",annee,mois,jour,heure,minute,seca,secb);
   } else {
      sprintf(new_date_obs,"%4d-%2d-%2dT",annee,mois,jour);
   }
   for (k=0;k<=(int)strlen(new_date_obs);k++) {if (new_date_obs[k]==' ') new_date_obs[k]='0';}
   return(OK_DLL);
}

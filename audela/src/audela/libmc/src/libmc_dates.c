/* libmc_dates.c
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

#include "libmc.h"

int Cmd_mctcl_dates_ut2bary(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit une date TT en date barycentrique                              */
/****************************************************************************/
/* Entrees :                                                                */
/* mc_tt2bary Dates Ra Dec Equinox ?Home?                                    */
/*                                                                          */
/* mc_tt2bary [mc_date2tt now0] 0h00 0d J2000.0                             */
/*                                                                          */
/****************************************************************************/

   double longi,rhocosphip,rhosinphip,asd2,dec2;
   char s[100];
   int planete;
   double jj,asd,dec,equinox;
   double v_helio,x_helio,y_helio,z_helio,vx_helio,vy_helio,vz_helio;
   double v_bary,x_bary,y_bary,z_bary,vx_bary,vy_bary,vz_bary;
   double xx,yy,zz,d,djd;
   double *jds,ut;
   char **argvv=NULL;
   int argcc,k,njd,code;
   Tcl_DString dsptr;
	double hjd,bjd;

   if(argc<=4) {
      sprintf(s,"Usage: %s ListDates_UT Angle_Ra Angle_Dec Equinox ?Home?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
 	   /* --- decode la date ---*/
      code=Tcl_SplitList(interp,argv[1],&argcc,&argvv);
      njd=argcc;
      if (code==TCL_OK) {
         jds=(double*)calloc(argcc,sizeof(double));
         if (jds==NULL) {
            return TCL_ERROR;
         }
         for (k=0;k<njd;k++) {
            mctcl_decode_date(interp,argvv[k],&jds[k]);
         }
         Tcl_Free((char *) argvv);
      } else {
         return TCL_ERROR;
      }
      /* --- decode l'angle RA ---*/
      mctcl_decode_angle(interp,argv[2],&asd);
      asd*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[3],&dec);
      dec*=(DR);
 	   /* --- decode la date de l'equinoxe ---*/
      mctcl_decode_date(interp,argv[4],&equinox);
      /* --- decode le Home ---*/
      longi=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      if (argc>=6) {
         mctcl_decode_topo(interp,argv[5],&longi,&rhocosphip,&rhosinphip);
      }
      planete=SOLEIL;
      Tcl_DStringInit(&dsptr);
      for (k=0;k<njd;k++) {
         ut=jds[k];
         /* --- convertir en TT ---*/
         mc_tu2td(ut,&jj);
			/* --- correction de la precession equinox -> a la date ---*/
			mc_precad(equinox,asd,dec,jj,&asd2,&dec2);
			/* --- correction de la nutation ---*/
			mc_nutradec(jj,asd2,dec2,&asd2,&dec2,1);
         /* --- calcul --- */
	      mc_baryvel(jj,longi,rhocosphip,rhosinphip,asd2,dec2,&x_helio,&y_helio,&z_helio,&vx_helio,&vy_helio,&vz_helio,&v_helio,&hjd,&x_bary,&y_bary,&z_bary,&vx_bary,&vy_bary,&vz_bary,&v_bary,&bjd);
         xx=cos(asd2)*cos(dec2);
         yy=sin(asd2)*cos(dec2);
         zz=sin(dec2);
         d=x_bary*xx+y_bary*yy+z_bary*zz;
         djd=d*UA/CLIGHT/86400.;
         sprintf(s,"%.10f ",bjd);
         Tcl_DStringAppendElement(&dsptr,s);
      }
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

int Cmd_mctcl_tt2bary(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit une date TT en date barycentrique                              */
/****************************************************************************/
/* Entrees :                                                                */
/* mc_tt2bary Date Ra Dec Equinox ?Home?                                    */
/*                                                                          */
/* mc_tt2bary [mc_date2tt now0] 0h00 0d J2000.0                             */
/*                                                                          */
/****************************************************************************/

   double longi,rhocosphip,rhosinphip,asd2,dec2;
   char s[100];
   int planete;
   double jj,asd,dec,equinox;
   double v_helio,x_helio,y_helio,z_helio,vx_helio,vy_helio,vz_helio;
   double v_bary,x_bary,y_bary,z_bary,vx_bary,vy_bary,vz_bary;
   double xx,yy,zz,d,djd;
	double hjd,bjd;

   if(argc<=4) {
      sprintf(s,"Usage: %s DateTT Angle_Ra Angle_Dec Equinox ?Home?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
 	   /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- decode l'angle RA ---*/
      mctcl_decode_angle(interp,argv[2],&asd);
      asd*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[3],&dec);
      dec*=(DR);
 	   /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[4],&equinox);
      /* --- decode le Home ---*/
      longi=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      if (argc>=6) {
         mctcl_decode_topo(interp,argv[5],&longi,&rhocosphip,&rhosinphip);
      }
      planete=SOLEIL;
      /* --- correction de la precession equinox -> a la date ---*/
      mc_precad(equinox,asd,dec,jj,&asd2,&dec2);
      /* --- correction de la nutation ---*/
		mc_nutradec(jj,asd2,dec2,&asd2,&dec2,1);
      /* --- calcul --- */
	   mc_baryvel(jj,longi,rhocosphip,rhosinphip,asd2,dec2,&x_helio,&y_helio,&z_helio,&vx_helio,&vy_helio,&vz_helio,&v_helio,&hjd,&x_bary,&y_bary,&z_bary,&vx_bary,&vy_bary,&vz_bary,&v_bary,&bjd);
      xx=cos(asd2)*cos(dec2);
      yy=sin(asd2)*cos(dec2);
      zz=sin(dec2);
      d=x_bary*xx+y_bary*yy+z_bary*zz;
      djd=d*UA/CLIGHT/86400.;
      sprintf(s,"%.10f ",bjd);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_tt2helio(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit une date TT en date heliocentrique                              */
/****************************************************************************/
/* Entrees :                                                                */
/* mc_tt2helio Date Ra Dec Equinox ?Home?                                    */
/*                                                                          */
/* mc_tt2helio [mc_date2tt now0] 0h00 0d J2000.0                             */
/*                                                                          */
/****************************************************************************/

   double longi,rhocosphip,rhosinphip,asd2,dec2;
   char s[100];
   int planete;
   double jj,asd,dec,equinox;
   double v_helio,x_helio,y_helio,z_helio,vx_helio,vy_helio,vz_helio;
   double v_bary,x_bary,y_bary,z_bary,vx_bary,vy_bary,vz_bary;
   double xx,yy,zz,d,djd;
	double hjd,bjd;

   if(argc<=4) {
      sprintf(s,"Usage: %s DateTT Angle_Ra Angle_Dec Equinox ?Home?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
 	   return TCL_ERROR;
   } else {
 	   /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- decode l'angle RA ---*/
      mctcl_decode_angle(interp,argv[2],&asd);
      asd*=(DR);
      /* --- decode l'angle DEC ---*/
      mctcl_decode_angle(interp,argv[3],&dec);
      dec*=(DR);
 	   /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[4],&equinox);
      /* --- decode le Home ---*/
      longi=0.;
      rhocosphip=0.;
      rhosinphip=0.;
      if (argc>=6) {
         mctcl_decode_topo(interp,argv[5],&longi,&rhocosphip,&rhosinphip);
      }
      planete=SOLEIL;
      /* --- correction de la precession equinox -> a la date ---*/
      mc_precad(equinox,asd,dec,jj,&asd2,&dec2);
      /* --- correction de la nutation ---*/
		mc_nutradec(jj,asd2,dec2,&asd2,&dec2,1);
      /* --- calcul --- */
      mc_baryvel(jj,longi,rhocosphip,rhosinphip,asd2,dec2,&x_helio,&y_helio,&z_helio,&vx_helio,&vy_helio,&vz_helio,&v_helio,&hjd,&x_bary,&y_bary,&z_bary,&vx_bary,&vy_bary,&vz_bary,&v_bary,&bjd);
      xx=cos(asd2)*cos(dec2);
      yy=sin(asd2)*cos(dec2);
      zz=sin(dec2);
      d=x_helio*xx+y_helio*yy+z_helio*zz;
      djd=d*UA/CLIGHT/86400.;
      sprintf(s,"%.10f ",hjd);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_mctcl_date2jd(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit une date gregorienne en jour julien				  			       */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* jd																		                   */
/****************************************************************************/
   int result;
   char s[100];
   double jj=0.;

   if(argc!=2) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      sprintf(s,"%.10f",jj);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2iso8601(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit une date gregorienne en jour julien							       */
/****************************************************************************/
/* Entrees : possibilites de type Date									             */
/*																			                   */
/* Sorties :																                */
/* Iso8601         													                   */
/****************************************************************************/
   double d,jj=0.,jour=0.;
   double hh,mm,ss;
   int result,y=0,m=0,k;
   char s[100],sec[10];

   if(argc!=2) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /*--- Calcul de la Date a partir du Jour Julien */
		for (k=0;k<=1;k++) {
			mc_jd_date(jj,&y,&m,&jour);
			d=floor(jour);
			d=(jour-d)*24.;
			hh=floor(d);
			d=(d-hh)*60.;
			mm=floor(d);
			ss=(d-mm)*60.;
			sprintf(sec,"%06.3f",ss);
			if (strcmp(sec,"60.000")!=0) { 
				break;
			} else {
				jj+=(0.0005/86400);
			}
		}
      sprintf(s,"%04d-%02d-%02dT%02d:%02d:%s",y,m,(int)floor(jour),(int)hh,(int)mm,sec);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_datescomp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Calcul sur les Dates                                                     */
/****************************************************************************/
/* mc_datescomp                                                             */
/*  Date1 Operande Date2                                                    */
/****************************************************************************/
{
   char s[524];
   int result,op;
   double date1,date2,date12;

   if(argc<4) {
      sprintf(s,"Usage: %s Date1 Operand days", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	   /* --- decode la date 1 ---*/
      mctcl_decode_date(interp,argv[1],&date1);
	   /* --- decode l'operande ---*/
		strcpy(s,argv[2]);
		if (strcmp(s,"-")==0) {op=-1;}
		else if (strcmp(s,"+")==0) {op=1;}
		else {
         strcpy(s,"Operand should be +|-");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         result = TCL_ERROR;
			return result;
		}
		date12=0.;
      if (fabs(op)<=1.) {
	      /* --- decode la date 2 ---*/
         /*mctcl_decode_date(interp,argv[3],&date2);*/
		  date2=atof(argv[3]);
			if (op>0) {
			   date12=date1+date2;
			} else {
			   date12=date1-date2;
			}
		}
		sprintf(s,"%.15f",date12);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
	}
	return result;
}

int Cmd_mctcl_date2listdates(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* cree une liste de dates a partir d'une date et d'un pas en jours         */
/****************************************************************************/
/* Entrees :                 												             */
/* date sous n'importe quel format                                          */
/* pas en jours                                                             */
/* nombre de pas                                                            */
/*																			                   */
/* Sorties :																                */
/* Liste de jd															                   */
/****************************************************************************/
   int result,nbstep,k,retour;
   char s[100];
   double jj=0.,step;
   Tcl_DString dsptr;

   if(argc!=4) {
      sprintf(s,"Usage: %s Date DateStep NbSteps", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
	  /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
	  /* --- decode le pas en jours ---*/
      retour = Tcl_GetDouble(interp, argv[2], &step);
      if(retour!=TCL_OK) return retour;
	  /* --- decode le nombre de pas ---*/
      retour = Tcl_GetInt(interp, argv[3], &nbstep);
      if(retour!=TCL_OK) return retour;
      /* --- cree la nouvelle liste ---*/
      Tcl_DStringInit(&dsptr);
	  strcpy(s,"");
      for (k=0;k<nbstep;k++) {
         sprintf(s,"%.15f ",jj+step*k);
         Tcl_DStringAppend(&dsptr,s,-1);
	  }
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
      result = TCL_OK;
   }
   return result;
}


int Cmd_mctcl_jd2date(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit un jour julien en une date gregorienne                         */
/****************************************************************************/
/* Entrees :                 												             */
/* jd        																                */
/*																			                   */
/* Sorties :																                */
/* y m d h m s.s   														                */
/****************************************************************************/
   double d,jj=0.,jour=0.;
   double hh,mm,ss;
   int result,y=0,m=0;
   char s[100];

   if(argc!=2) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /*--- Calcul de la Date a partir du Jour Julien */
      mc_jd_date(jj,&y,&m,&jour);
      d=floor(jour);
	  d=(jour-d)*24.;
	  hh=floor(d);
	  d=(d-hh)*60.;
	  mm=floor(d);
	  ss=(d-mm)*60.;
      sprintf(s,"%d %d %d %d %d %f",y,m,(int)floor(jour),(int)hh,(int)mm,ss);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2lst(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit un jour julien en un temps sideral                             */
/****************************************************************************/
/* Entrees :                 												             */
/* Date Home       								                                  */
/*																			                   */
/* Sorties :																                */
/* h m s.s   														                      */
/****************************************************************************/
   double jj=0.,eps,dpsi,deps;
   double ss=0.;
   double longi=0.,tsl=0.,rhocosphip,rhosinphip;
   int hhh=0,mmm=0;
   int result,do_nutation=1,type_format=0,ko;
	/*double tai_utc=0.;*/
	double ut1_utc=0.;
   char s[256];

   if(argc<=2) {
      //sprintf(s,"Usage: %s Date_UTC Home_cep ?-tai-utc TAI-UTC(sec)? ?-ut1-utc UT1-UTC(sec)? ?-nutation 1|0? ?-format hms|deg?", argv[0]);
      sprintf(s,"Usage: %s Date_UTC Home_cep ?-ut1-utc UT1-UTC(sec)? ?-nutation 1|0? ?-format hms|deg?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- decode le Home ---*/
      mctcl_decode_topo(interp,argv[2],&longi,&rhocosphip,&rhosinphip);
      /* --- decode les options ---*/
      for (ko=3;ko<argc-1;ko++) {
	      strcpy(s,argv[ko]);
		   mc_strupr(s,s);
	      if (strcmp(s,"-NUTATION")==0) {
			   do_nutation=(int)atoi(argv[ko+1]);
			}
	      if (strcmp(s,"-FORMAT")==0) {
				strcpy(s,argv[ko+1]);
				mc_strupr(s,s);
				if (strcmp(s,"HMS")==0) { type_format=0; }
				else if (strcmp(s,"DEG")==0) { type_format=1; }
			}
			/*
	      if (strcmp(s,"-TAI-UTC")==0) {
			   tai_utc=atof(argv[ko+1])/86400.;
			}
			*/
	      if (strcmp(s,"-UT1-UTC")==0) {
			   ut1_utc=atof(argv[ko+1]);
				if (ut1_utc>1)  { ut1_utc = 1.; }
				if (ut1_utc<-1) { ut1_utc = -1.; }
				ut1_utc/=86400;
			}
		}
		jj+=ut1_utc;
      /* --- calcul du TSL en radians ---*/
      mc_tsl(jj,-longi,&tsl);
		/* --- nutation ---*/
		if (do_nutation==0) {
			jj-=ut1_utc;
			mc_tu2td(jj,&jj);
			/* --- obliquite moyenne --- */
			mc_obliqmoy(jj,&eps);
			/* --- longitude vraie du soleil ---*/
			mc_nutation(jj,1,&dpsi,&deps);
			/* --- correction ---*/
			tsl+=dpsi*cos(eps);
		}
		/* --- formatage de sortie --- */
		if (type_format==0) {
			/* --- conversion radian vers hms ---*/
			mc_deg2h_m_s((tsl/(DR)),&hhh,&mmm,&ss);
	      sprintf(s,"%d %d %f",hhh,mmm,ss);
		} else {
			tsl/=(DR);
			tsl=fmod(720.+tsl,360);
	      sprintf(s,"%.7f",tsl);
		}
      /* --- sortie des resultats ---*/
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2tt(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Convertit une date en jour julien TT (Terrestrial Time)                  */
/****************************************************************************/
/* Entrees :                 												             */
/* Date            								                                  */
/*																			                   */
/* Sorties :																                */
/* jj expressed in TT                                                       */
/****************************************************************************/
   double jj=0.,tt=0.;
   int result;
   char s[100];

   if(argc<=1) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- convertir en TT ---*/
      mc_tu2td(jj,&tt);
      /* --- sortie des resultats ---*/
      sprintf(s,"%.15f",tt);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mctcl_date2ttutc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Retourne TT-UTC pour une date UTC                                        */
/****************************************************************************/
/* Entrees :                 												             */
/* Date            								                                  */
/*																			                   */
/* Sorties :																                */
/* TT-UTC expressed in days                                                 */
/****************************************************************************/
   double jj=0.,dt=0.;
   int result;
   char s[100];

   if(argc<=1) {
      sprintf(s,"Usage: %s Date", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode la date ---*/
      mctcl_decode_date(interp,argv[1],&jj);
      /* --- TT-UTC ---*/
		mc_tdminusut(jj,&dt);
      /* --- sortie des resultats ---*/
      sprintf(s,"%.10f",dt/86400.);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int mctcl_decode_date(Tcl_Interp *interp, char *argv0,double *jj)
/****************************************************************************/
/* Decode automatiquement des dates entree sous 5 formats differents.	    */
/****************************************************************************/
/* Now : Pour avoir la date actuelle										          */
/* Now0 : Pour avoir la date actuelle a 0h   								       */
/* Now1 : Pour avoir la date de demain a 0h   								       */
/* YYYY-MM-DDThh:mm:ss.ss : Format Iso8601 du Fits.								 */
/* nombre decimal >= 1000000 : Jour Julien									       */
/* nombre decimal <  1000000 : Jour Julien Modifie							       */
/* YYYY MM DD hh mm ss.ss : Format style Iso mais avec les espaces.			 */
/*																			                   */
/* Note : les formats YYYY... peuvent etre tronques (ex YYY-MM-DD)			 */
/* 																			                */
/****************************************************************************/
{
   int result=TCL_ERROR,code,retour;
   char **argvv=NULL;
   int argcc;
   double y=0.,m=0.,d=0.,jour=0.;
   double hh=0.,mm=0.,ss=0.;
   time_t ltime;
   char text[100];
   int millisec=0;
#if defined(_MSC_VER)
   /* cas special a Microsoft C++ pour avoir les millisecondes */
   struct _timeb timebuffer;
#endif

   code=Tcl_SplitList(interp,argv0,&argcc,&argvv);
   if (code==TCL_OK) {
      if (argcc==1) {
	      /* Un seul element dans la liste */
	      *jj=0.;
         /* recherche si c'est NOW */
         millisec=0;
#if defined(_MSC_VER)
         /* cas special a Microsoft C++ pour avoir les millisecondes */
         _ftime( &timebuffer );
         millisec=(int)(timebuffer.millitm);
#endif
         time( &ltime );
         strftime(text,50,"%Y %m %d %H %M %S",localtime( &ltime ));
         strftime(text,50,"%Y",localtime( &ltime )); y=atof(text);
         strftime(text,50,"%m",localtime( &ltime )); m=atof(text);
         strftime(text,50,"%d",localtime( &ltime )); d=atof(text);
         strftime(text,50,"%H",localtime( &ltime )); hh=atof(text);
         strftime(text,50,"%M",localtime( &ltime )); mm=atof(text);
         strftime(text,50,"%S",localtime( &ltime )); ss=atof(text)+((double)millisec)/1000.;
	      strcpy(text,argvv[0]);
	      mc_strupr(text,text);
	      if (strcmp(text,"NOW")==0) {
           jour=1.*d+(((ss/60+mm)/60)+hh)/24;
           /*--- Calcul du Jour Julien */
           mc_date_jd((int)y,(int)m,jour,jj);
           Tcl_Free((char *) argvv);
           return TCL_OK;
         }
	      if (strcmp(text,"NOW0")==0) {
           jour=1.*floor(d);
           /*--- Calcul du Jour Julien */
           mc_date_jd((int)y,(int)m,jour,jj);
           Tcl_Free((char *) argvv);
    	     return TCL_OK;
        }
        if (strcmp(text,"NOW1")==0) {
          jour=1.*floor(d+1.);
          /*--- Calcul du Jour Julien */
          mc_date_jd((int)y,(int)m,jour,jj);
          Tcl_Free((char *) argvv);
    	    return TCL_OK;
        }
        if ((text[0]=='J')||(text[0]=='B')) {
	        /* --- date du style J2000.0 ou B1950.0 ---*/
	        mc_equinoxe_jd(text,jj);
           Tcl_Free((char *) argvv);
    	     return TCL_OK;
        }
        /* recherche une date au format Fits */
        if ((strstr(argvv[0],"-")!=NULL)||(strstr(argvv[0],"T")!=NULL)||(strstr(argvv[0],"t")!=NULL)||(strstr(argvv[0],":")!=NULL)) {
	        mc_dateobs2jd(argvv[0],jj);
        }
        if (*jj==0.) {
	        /* La date est supposee en Jour Julien */
           retour = Tcl_GetDouble(interp, argvv[0], jj);
	        /* On corrige si on suppose que l'on a rentre un MJD */
	        if (*jj<1e6) {*jj+=2400000.5;}
           if(retour!=TCL_OK) {
              Tcl_Free((char *) argvv);
              return retour;
           }
        }
     } else {
        /* Plusieurs elements dans la liste */
		  if ((argcc==2)&&((strstr(argvv[0],"-")!=NULL)||(strstr(argvv[1],":")!=NULL))) {
           /* Deux elements dans la liste. Date a la MySQL */
			  sprintf(text,"%sT%s",argvv[0],argvv[1]);
	        mc_dateobs2jd(text,jj);
			  result = TCL_OK;
		  } else {
			  /* La date est une liste yyy mm dd ?hh mm ss.s? */
			  if (argcc>=1) { y=atof(argvv[0]); }
			  if (argcc>=2) { m=atof(argvv[1]); }
			  if (argcc>=3) { d=atof(argvv[2]); }
			  if (argcc>=4) { hh=atof(argvv[3]); }
			  if (argcc>=5) { mm=atof(argvv[4]); }
			  if (argcc>=6) { ss=atof(argvv[5]); }
			  jour=1.*d+(((ss/60+mm)/60)+hh)/24;
			  /*--- Calcul du Jour Julien */
			  mc_date_jd((int)y,(int)m,jour,jj);
			  result = TCL_OK;
		  }
      }
   } else {
      result = TCL_ERROR;
   }	
   if (argvv!=NULL) {
      Tcl_Free((char *) argvv);
   }
   return(result);
}

 int Cmd_mctcl_date2equinox(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[]) {
/****************************************************************************/
/* Calcul l'equinoxe d'une date gregorienne 				  			             */
/****************************************************************************/
/* Entrees : possibilites de type Date	(voir mctcl_decode_date              */
/*																			                   */
/* Sorties : equinoxe au format Jxxxx.x                                     */
/* 																		                   */
/****************************************************************************/
   int result;
   if(argc!=2) {
      char s[100];
      sprintf(s,"Usage: %s Date ", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      double jj =0;
      char chaine[100];
      int decodeResult;
      // je decode la date et je la transforme en jour julien
      decodeResult = mctcl_decode_date(interp,argv[1],&jj);
      if ( decodeResult == TCL_OK ) {
         double eps=1e-3,eps2=1e-4,a,annee;
         char chaine0[80];
         // calcul de l'equinox 
         mc_jd_equinoxe( jj, chaine);
         a=(jj-2451545.0)/365.25+2000.0;
         strcpy(chaine,"J");
         if (mc_frac(a)<eps2) {
            annee=a+0.1;
            mc_fstr(annee,PB,4,0,OK,chaine0);
            strcat(chaine,chaine0);
            strcat(chaine,".0");
         } else {
            // je formate la chaine avec 4 chiffres et 1 decimale
            mc_fstr(a,PB,4,1,OK,chaine0);
            strcat(chaine,chaine0);
         }
         if (fabs(jj-2415020.3135)<eps) {
            strcpy(chaine,"B1900.0");
         }
         if (fabs(jj-2433282.4235)<eps) {
            strcpy(chaine,"B1950.0");
         }
         Tcl_SetResult(interp,chaine,TCL_VOLATILE);
         result = TCL_OK;
      } else {
         // je retourne un message d'erreur au TCL
         char messageErreur[1024];
         sprintf(messageErreur, "Erreur de decodage de la date %s",argv[1]);
         Tcl_SetResult(interp,messageErreur,TCL_VOLATILE);
         result = TCL_ERROR;
      }
   }
   return result;
}


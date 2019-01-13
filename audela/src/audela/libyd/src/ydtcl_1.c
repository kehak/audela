/* ydtcl_1.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Yassine DAMERDJI <damerdji@obs-hp.fr>
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

/***************************************************************************/
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers yd_*.c.                              */
/***************************************************************************/
/* Le include ydtcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "ydtcl.h"

int Cmd_ydtcl_reduceusno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Troncate the USNO-A1 catalog file to a given R magnitude                 */
/****************************************************************************/
/*
load libyd ; yd_reduceusno c:/d/usno/ c:/d/usnoshort ZONE0750 10
*/
/****************************************************************************/
{
   char s[100],pathname_in[1024],pathname_out[1024];
   char zonename[1024],ligne[1024];
   FILE *catin,*catout,*accout;
   int n,nin,nout,noutold;
   int l,raL,deL,magL,raLL,deLL,magLL;
   double rmaglim,ra,de,mag_red,mag_bleue;
   double rah,rah0,drah;
   if(argc<5) {
      sprintf(s,"Usage: %s pathname_in pathname_out zonename rmaglim", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(ligne,argv[1]);
      n=(int)strlen(ligne);
      if (n==0) {
         return TCL_OK;
      }
      if ((ligne[n-1]!='/')||(ligne[n-1]!='\\')) {
         ligne[n]='/';
         ligne[n+1]='\0';
      }
      strcpy(pathname_in,ligne);
      strcpy(ligne,argv[2]);
      n=(int)strlen(ligne);
      if (n==0) {
         return TCL_OK;
      }
      if ((ligne[n-1]!='/')||(ligne[n-1]!='\\')) {
         ligne[n]='/';
         ligne[n+1]='\0';
      }
      strcpy(pathname_out,ligne);
      strcpy(zonename,argv[3]);
      rmaglim=(double)atof(argv[4]);
      /* -- opens the CAT files ---*/
      sprintf(ligne,"%s%s.CAT",pathname_in,zonename);
      if ((catin=fopen(ligne,"rb"))==NULL) {
         sprintf(s,"File %s not found\n",ligne);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      sprintf(ligne,"%s%s.CAT",pathname_out,zonename);
      if ((catout=fopen(ligne,"wb"))==NULL) {
         sprintf(s,"File %s cannot be created\n",ligne);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         fclose(catin);
         return TCL_ERROR;
      }
      /* -- opens the CAT files ---*/
      sprintf(ligne,"%s%s.ACC",pathname_out,zonename);
      if ((accout=fopen(ligne,"wt"))==NULL) {
         sprintf(s,"File %s cannot be created\n",ligne);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         fclose(catin);
         fclose(catout);
         return TCL_ERROR;
      }
      /* -- loop ---*/
      nin=nout=0;
      rah0=0.;
      drah=0.25;
      noutold=1;
      while (feof(catin)==0) {
         if (fread(&raL,1,4,catin)!=4) break;
         if (fread(&deL,1,4,catin)!=4) break;
         if (fread(&magL,1,4,catin)!=4) break;
         l=raL;
         raLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
         l=deL;
         deLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
         l=magL;
         magLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
         ra=(double)raLL/360000.0;
         de=(double)deLL/360000.0-90.0;
         mag_red=yd_GetUsnoRedMagnitude(magLL);
         mag_bleue=yd_GetUsnoBleueMagnitude(magLL);
         if (mag_red<=rmaglim) {
            nout++;
            fwrite(&raL,sizeof(raL),1,catout);
            fwrite(&deL,sizeof(deL),1,catout);
            fwrite(&magL,sizeof(magL),1,catout);
         }
         rah=ra/15.;
         if (rah>rah0+drah) {
            sprintf(ligne,"%5.2f%12d%12d\n",rah0,noutold,nout);
            fwrite(ligne,strlen(ligne),1,accout);
            noutold+=nout;
            rah0+=drah;
         }
         /*
         if (nin>60000) {
            break;
         }
         */
         nin++;
      }
      /* -- close CAT files --*/
      fclose(catin);
      fclose(catout);
      fclose(accout);
      /* -- opens the catout file and create the ACC file TBD */
      sprintf(s,"%d %d",nin,nout);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
   }
}

int Cmd_ydtcl_ref2field(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024];
   struct_htmref  htmref;
   FILE *f_in;
   double ra,dec,dist,distmax,x,y,z;
	int k,kmax,kmax0,kmax00,n_ref0,n_ref;
   double dr;
	double *cosras=NULL,*cosdecs=NULL,*sinras=NULL,*sindecs=NULL;
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
       /* --- decodage des arguments ---*/
      strcpy(path,argv[1]); /* d:/fufu/mystar.txt */
      strcpy(generic_filename,argv[2]); /* c:/toto/N012312312 */
      /* --- compte le nombre d'etoiles dans HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_ref0=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            n_ref0++;
         }
      }
      fclose(f_in);
      if (n_ref0==0) {
         return TCL_OK;
      }
      cosras=(double*)calloc(n_ref0,sizeof(double));
		if (cosras==NULL) {
         strcpy(s,"Problem of pointer cosras allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      cosdecs=(double*)calloc(n_ref0,sizeof(double));
		if (cosdecs==NULL) {
			free(cosras);
         strcpy(s,"Problem of pointer cosdecs allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      sinras=(double*)calloc(n_ref0,sizeof(double));
		if (sinras==NULL) {
			free(cosras);
			free(cosdecs);
         strcpy(s,"Problem of pointer sinras allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      sindecs=(double*)calloc(n_ref0,sizeof(double));
		if (sindecs==NULL) {
			free(cosras);
			free(cosdecs);
			free(sinras);
         strcpy(s,"Problem of pointer sindecs allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
			free(cosras);
			free(cosdecs);
			free(sinras);
			free(sindecs);
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
		dr=atan(1)/45.;
      n_ref=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
			   cosras[n_ref]=cos(htmref.ra*dr);
			   cosdecs[n_ref]=cos(htmref.dec*dr);
			   sinras[n_ref]=sin(htmref.ra*dr);
			   sindecs[n_ref]=sin(htmref.dec*dr);
				n_ref++;
         }
      }
      fclose(f_in);
		distmax=0;
		kmax00=-1;
		kmax0=0;
		kmax=0;
		while (1==1) {
			for (k=0;k<n_ref;k++) {
				if (k==kmax0) { continue; }
				// c=(sin(d1)*sin(d2)+cos(d1)*cos(d2)*cos(a1-a2));
				// dist = (sin(d1)*sin(d2)+cos(d1)*cos(d2)*( cos(a1)*cos(a2) + sin(a1)*sin(a2) )
				dist=sindecs[k]*sindecs[kmax0]+cosdecs[k]*cosdecs[kmax0]*( cosras[k]*cosras[kmax0] + sinras[k]*sinras[kmax0] );
				if (dist<-1) { dist=-1; }
				if (dist>1) { dist=1; }
				dist=acos(dist)/dr*60;
				if (dist>distmax) {
					kmax=k;
					distmax=dist;
				}
			}
			if (kmax==kmax00) {
				break;
			}
			kmax00=kmax0;
			kmax0=kmax;
		}
		x=(cosras[kmax]*cosdecs[kmax]+cosras[kmax0]*cosdecs[kmax0])/2.;
		y=(sinras[kmax]*cosdecs[kmax]+sinras[kmax0]*cosdecs[kmax0])/2.;
		z=(sindecs[kmax]+sindecs[kmax0])/2.;
		dist=sqrt(x*x+y*y+z*z);
		ra=fmod(atan2(y,x)/dr+720,360);
		dec=asin(z/dist)/dr;
		free(cosras);
		free(cosdecs);
		free(sinras);
		free(sindecs);
      sprintf(s,"%f %f %f",ra,dec,distmax/60); // distmax en deg
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_OK;
	}
	return TCL_OK;
}

int Cmd_ydtcl_cal2ref(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[100],ligne[256],texte[256];
   char path[1024];
   char filename_in[1024],generic_filename[1024];
   struct_htmref htmref,*htmrefs=NULL;
   FILE *f_in,*f_out;
   double ra,dec,ra0,dec0,dist,distmin;
	float mags[256];
	int k,kmin,n_ref0,n_ref,codefiltre,codecat;
   double dr;
	double sepmin=2.; // separation d'appariement en arcsec
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
       /* --- decodage des arguments ---*/
      strcpy(path,argv[1]); 
      strcpy(generic_filename,argv[2]); 
      /* --- compte le nombre d'etoiles dans HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_ref0=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            n_ref0++;
         }
      }
      fclose(f_in);
      if (n_ref0==0) {
         return TCL_OK;
      }
      htmrefs=(struct_htmref*)calloc(n_ref0,sizeof(struct_htmref));
		if (htmrefs==NULL) {
         strcpy(s,"Problem of pointer htmrefs allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
		dr=atan(1)/45.;
      n_ref=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
			   htmrefs[n_ref]=htmref;
				n_ref++;
         }
      }
      fclose(f_in);
      sprintf(filename_in,"%s%s_cal.txt",path,generic_filename);
      f_in=fopen(filename_in,"rt");
      if (f_in==NULL) {
			free(htmrefs);
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      do {
			if (fgets(ligne,255,f_in)!=NULL) {
	         strcpy(texte,"");
   	      sscanf(ligne,"%s",texte);
	         if ( (strcmp(texte,"")!=0) ) {
               /* ra dec B V R J H K */
				   sscanf(ligne,"%lf %lf %f %f %f %f %f %f",
               &ra0,&dec0,&mags[66],&mags[86],&mags[82],&mags[74],&mags[72],&mags[75]);
					ra0*=dr;
					dec0*=dr;
					distmin=1e9;
					kmin=0;
					for (k=0;k<n_ref;k++) {
						ra=htmrefs[k].ra;
						dec=htmrefs[k].dec;
						ra*=dr;
						dec*=dr;
						dist=(sin(dec0)*sin(dec)+cos(dec0)*cos(dec)*cos(ra0-ra));
						if (dist<-1) { dist=-1; }
						if (dist>1) { dist=1; }
						dist=acos(dist)/dr*3600;
						if (dist<=distmin) {
							distmin=dist;
							kmin=k;
						}
					}
					if (distmin<sepmin) {
						for (k=0;k<4;k++) {
							codefiltre=htmrefs[kmin].codefiltre[k];							
							codecat=5;
							if      ((codefiltre==66)&&(mags[66]!=-99.9)) { htmrefs[kmin].mag[k]=mags[66]; htmrefs[kmin].codecat[k]=codecat; }
							else if ((codefiltre==86)&&(mags[86]!=-99.9)) { htmrefs[kmin].mag[k]=mags[86]; htmrefs[kmin].codecat[k]=codecat; }
							else if ((codefiltre==82)&&(mags[82]!=-99.9)) { htmrefs[kmin].mag[k]=mags[82]; htmrefs[kmin].codecat[k]=codecat; }
							else if ((codefiltre==74)&&(mags[74]!=-99.9)) { htmrefs[kmin].mag[k]=mags[74]; htmrefs[kmin].codecat[k]=codecat; }
							else if ((codefiltre==72)&&(mags[72]!=-99.9)) { htmrefs[kmin].mag[k]=mags[72]; htmrefs[kmin].codecat[k]=codecat; }
							else if ((codefiltre==75)&&(mags[75]!=-99.9)) { htmrefs[kmin].mag[k]=mags[75]; htmrefs[kmin].codecat[k]=codecat; }
						}
					}
				}
			}
      } while (feof(f_in)==0) ;
      fclose(f_in);
		// --- on met a jour htmrefs ici
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_out=fopen(filename_in,"wb");
      for (k=0;k<n_ref;k++) {
         fwrite(&htmrefs[k],1,sizeof(struct_htmref),f_out);
      }
      fclose(f_out);
		free(htmrefs);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
      return TCL_OK;
	}
	return TCL_OK;
}

int Cmd_ydtcl_mes2mes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024];
   struct_htmref htmref,*htmrefs=NULL;
   struct_htmmes htmmes,*htmmess=NULL;
	double *vals=NULL,val,*cmags=NULL,cmag;
   FILE *f_in,*f_out;
	int n_ref0,n_ref,n_mes,n_mes0,ncalfiltre=0,nrefcal=0;
	unsigned char calfiltres[256],codefiltre;
	int k,km,kv,kr,kkr,kf,kcalfiltre,nouveau,nv;
	float codecat,mag;
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
       /* --- decodage des arguments ---*/
      strcpy(path,argv[1]); 
      strcpy(generic_filename,argv[2]); 
      /* --- compte le nombre d'etoiles dans HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_ref0=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            n_ref0++;
         }
      }
      fclose(f_in);
      if (n_ref0==0) {
         return TCL_OK;
      }
      htmrefs=(struct_htmref*)calloc(n_ref0,sizeof(struct_htmref));
		if (htmrefs==NULL) {
         strcpy(s,"Problem of pointer htmrefs allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
			free(htmrefs);
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_ref=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
			   htmrefs[n_ref]=htmref;
				n_ref++;
         }
      }
      fclose(f_in);
      /* --- compte le nombre d'etoiles dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
			free(htmrefs);
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_mes0=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            n_mes0++;
         }
      }
      fclose(f_in);
      if (n_mes0==0) {
         return TCL_OK;
      }
      htmmess=(struct_htmmes*)calloc(n_mes0,sizeof(struct_htmmes));
		if (htmmess==NULL) {
			free(htmrefs);
         strcpy(s,"Problem of pointer htmmess allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      vals=(double*)calloc(n_mes0,sizeof(double));
		if (vals==NULL) {
			free(htmrefs);
			free(htmmess);
         strcpy(s,"Problem of pointer vals allocation");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
		}
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
			free(htmrefs);
			free(htmmess);
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_mes=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
			   htmmess[n_mes]=htmmes;
				n_mes++;
         }
      }
      fclose(f_in);
		// --- scane les filtres calibres dans ref.
		//     la liste des filtres est dans calfiltres[ncalfiltre]
		ncalfiltre=0;
		for (kr=0;kr<n_ref;kr++) {
			for (kf=0;kf<4;kf++) {
				codefiltre=htmrefs[kr].codefiltre[kf];
				codecat=htmrefs[kr].codecat[kf];
				if ((codefiltre==0)||(codecat!=5)) {
					continue;
				}
				nouveau=1;
				for (k=0;k<ncalfiltre;k++) {
					if (codefiltre==calfiltres[k]) {
						nouveau=0;
					}
				}
				if (nouveau==1) {
					calfiltres[ncalfiltre]=codefiltre;
					ncalfiltre++;
				}

			}
		}
		if (ncalfiltre==0) {
			free(htmrefs);
			free(htmmess);
			free(vals);
			Tcl_SetResult(interp,"",TCL_VOLATILE);
			return TCL_OK;
		}
		// --- on scanne maintenant calfiltre par calfiltre
		for (kcalfiltre=0;kcalfiltre<ncalfiltre;kcalfiltre++) {
			// --- on compte le nombre d'etoiles calibrees nrefcal
			nrefcal=0;
			for (kr=0;kr<n_ref;kr++) {
				for (kf=0;kf<4;kf++) {
					codefiltre=htmrefs[kr].codefiltre[kf];
					codecat=htmrefs[kr].codecat[k];
					if ((codefiltre==0)||(codecat!=5)) {
						continue;
					}
					nrefcal++;
				}
			}
			// --- dimensionne le vecteur de constante des magnitudes
			if (nrefcal==0) { continue; }
	      cmags=(double*)calloc(nrefcal,sizeof(double));
			// --- on calcule la constante des magnitudes avec les etoiles calibrees pour ce filtre
			nrefcal=0;
			for (kr=0;kr<n_ref;kr++) {
				for (kf=0;kf<4;kf++) {
					codefiltre=htmrefs[kr].codefiltre[kf];
					codecat=htmrefs[kr].codecat[k];
					if ((codefiltre==0)||(codecat!=5)) {
						continue;
					}
					// --- une etoile calibree a ete trouvee dans ref
					mag=htmrefs[kr].mag[k];
					// --- recherche l'etoile dans mes
					kv=0;
					for (km=0;km<n_mes;km++) {
						kkr=htmmess[km].indexref;
						if (kkr==kr) {
							vals[kv]=htmmess[km].magcali;
							kv++;
						}
					}
					nv=kv;
					// --- calcule la magnitude mediane
			      yd_util_qsort_double(vals,0,nv,NULL);
					val=vals[nv/2];
					cmags[nrefcal]=val;
					nrefcal++;
				}
			}
			// --- calcule la constante de magnitude mediane
	      yd_util_qsort_double(cmags,0,nrefcal,NULL);
			cmag=cmags[nrefcal/2];
			free(cmags);
		}
		// --- c'est fini.
		// --- on met a jour htmrefs ici
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_out=fopen(filename_in,"wb");
      for (k=0;k<n_ref;k++) {
         fwrite(&htmrefs[k],1,sizeof(struct_htmref),f_out);
      }
      fclose(f_out);
		// --- on met a jour htmmess ici
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_out=fopen(filename_in,"wb");
      for (k=0;k<n_mes;k++) {
         fwrite(&htmmess[k],1,sizeof(struct_htmmes),f_out);
      }
      fclose(f_out);
		free(htmrefs);
		free(htmmess);
		free(vals);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
      return TCL_OK;
	}
	return TCL_OK;
}

int Cmd_ydtcl_radecinrefzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Extrait les parametres photometriques de l'etoile de coord ra,dec        */
/* On prend l'etoile la plus proche.                                        */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/****************************************************************************/
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmref  htmref,htmref0;
   struct_htmmes  htmmes;
   FILE *f_in,*f_out;
   double ra0,dec0,ra,dec,distmin,dist2,dra,ddec;
   double dr;
   int codefiltre,codecam;
   if(argc<6) {
      sprintf(s,"Usage: %s htm_generic_fullname out_fullname ra_deg dec_deg codefilter ?codecam?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(generic_filename,argv[1]); /* c:/toto/N012312312 */
      strcpy(path,argv[2]); /* d:/fufu/mystar.txt */
	   ra0=atof(argv[3]);
	   dec0=atof(argv[4]);
      codefiltre=atoi(argv[5]);
      codecam=-1;
      if (argc>=7) {
         codecam=atoi(argv[6]);
      }
      /* --- Recherche l'indice de l'etoile dans le fichier htm_ref.bin ---*/
      sprintf(filename_in,"%s_ref.bin",generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	   distmin=1e30;
	   dr=atan(1)/45.;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
			   dec=htmref.dec;
			   ddec=dec-dec0;
			   ra=htmref.ra;
			   dra=(ra-ra0)*cos(dr*dec0);
            dist2=dra*dra+ddec*ddec;
			   if (dist2<distmin) {
               distmin=dist2;
               htmref0=htmref;
            }
         }
      }
      fclose(f_in);
      /* --- Extrait des mesures valides de l'etoile de fichier htm_mes.bin ---*/
      sprintf(filename_in,"%s_mes.bin",generic_filename);
      sprintf(filename_out,"%s",path);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            if (htmmes.indexref<htmref0.indexref) {
               continue;
            }
            if (htmmes.indexref>htmref0.indexref) {
               break;
            }
            if (htmmes.indexref==htmref0.indexref) {
               if ((int)htmmes.codefiltre==codefiltre) {
                  if ((codecam<0)||((int)htmmes.codecam==codecam)) {
                     if (htmmes.magcali>-50) {
                        /*
                        fprintf(f_out,"%5d %5d %15.6f %3d %3d %8.4f %8.4f\n",
                        htmmes.indexref,htmmes.indexzmg,htmmes.jd,htmmes.codecam,htmmes.codefiltre,
                        htmmes.maginst,htmmes.magcali);
                        */
                        if (htmmes.jd>2e6) {
                           fprintf(f_out,"%15.6f %8.4f %6.3f\n",
                           htmmes.jd,htmmes.magcali,htmmes.dmag);
                        }
                     }
                  }
               }
            }
         }
      }
      fclose(f_in);
      fclose(f_out);
   }
   return TCL_OK;
}

int Cmd_ydtcl_refzmgmes2vars(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* genere les fichiers des etoiles variables                                */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/****************************************************************************/
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   struct_htmzmg  htmzmg,*htmzmgs=NULL;
   struct_htmref  htmref,*htmrefs=NULL;
   double *val=NULL,*erreurs=NULL;
   float *flt_mes=NULL;
   int *ind_refzmg=NULL;
   int *ind_ref=NULL;
   int n_mes,k,kcam,kfil,n_ref,kk,n_zmg,kref,kzmg;
   int n,kkzmg,n_val,n_ref0;
   unsigned char ukcam,ukfil;
   FILE *f_in,*f_out;
/*FILE *ff;*/
   int codes[256][256];
   double mean,sigma,magmax,magmin;
   /*double sigmoy,sigsig;
   int alljd,sigjd,nstar;*/
   /*modif Yassine 10 devient 2*/
   int critvar[2];
   /*fin*/
   double ra,dec;
   /*rajout Yassine*/
   int kvar,critvartot,kkkzmg,k_iter,k_photo,k_backg;
   double somme_sig_photo,somme_moy_photo,somme_sig_backg,somme_moy_backg;
   double val_droite,ordo_alorigine_photo,ordo_alorigine_backg;
   double ampli;
   int minobs;
   /*fin*/
	char observatory_symbol[50],ListKeyValues[1024];
	int nl,kl,nvar=0;
	Tcl_DString dsptr;
/*
#define DEBUG_refzmgmes2vars
*/
#if defined DEBUG_refzmgmes2vars
FILE *f;
#endif
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename ?minobs? ?observatory_symbol? ?ListKeyValues?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
       /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
		minobs=30;
		if (argc>=4) {
			 minobs=atoi(argv[3]);
		}
		strcpy(observatory_symbol,"TN");
		if (argc>=5) {
			strcpy(observatory_symbol,argv[4]);
		}
		strcpy(ListKeyValues,"{TAROT CALERN}");
		if (argc>=6) {
			strcpy(ListKeyValues,argv[5]);
		}
	  /*myfiltre=atof(argv[3]);
	  myfiltre2=(unsigned char)myfiltre;*/
      /* --- init des tableaux ---*/
      for (kcam=0;kcam<256;kcam++) {
         for (kfil=0;kfil<256;kfil++) {
            codes[kcam][kfil]=0;
         }
      }
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","wt");
fprintf(f,"On entre dans Cmd_ydtcl_refzmgmes2vars\n");
fclose(f);
#endif
      /* --- compte le nombre de dates-filtre dans HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            n_zmg++;
         }
      }
      fclose(f_in);
      if (n_zmg==0) {
         return TCL_OK;
      }
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," n_zmg=%d\n",n_zmg);
fclose(f);
#endif
      /* --- alloue la memoire ---*/
      htmzmgs=(struct_htmzmg*)malloc(n_zmg*sizeof(struct_htmzmg));
      if (htmzmgs==NULL) {
         sprintf(s,"error : htmzmgs pointer out of memory (%d elements)",n_zmg);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- lecture de htmzmgs a partir de HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            htmzmgs[k]=htmzmg;
            k++;
         }
      }
      fclose(f_in);
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      n_mes=0;
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            codes[(int)htmmes.codecam][(int)htmmes.codefiltre]++;
            n_mes++;
            if (htmmes.indexzmg>n_zmg) {
               n_zmg=htmmes.indexzmg;
            }
         }
      }
      n_ref=htmmes.indexref+1;
      n_zmg+=1;
      fclose(f_in);
      if (n_mes==0) {
         free(htmzmgs);
         return TCL_OK;
      }
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," n_ref=%d\n",n_ref);
fprintf(f," n_zmg=%d\n",n_zmg);
fclose(f);
#endif
      /* --- alloue la memoire pour htmmess---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      /* --- on dimensionne la matrice x=indexref y=indexjd val=kmes */
      /*     ce tableau est utile pour circuler rapidement dans htmmess */
      n=n_ref*n_zmg;
      ind_refzmg=(int*)calloc(n,sizeof(int));
      if (ind_refzmg==NULL) {
         sprintf(s,"error : ind_refzmg pointer out of memory (%d elements)",n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      for (k=0;k<n;k++) {
         ind_refzmg[k]=-1;
      }
      /* --- lecture des donnees pour htmmess ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmess[k]=htmmes;
            ind_refzmg[htmmes.indexref*n_zmg+htmmes.indexzmg]=k;
            k++;
         }
      }
      fclose(f_in);
      /* --- on dimensionne le tableau de l'histogramme ---*/
      flt_mes=(float*)calloc(n_ref*YD_FLTMES,sizeof(float));
      if (flt_mes==NULL) {
         sprintf(s,"error : flt_mes pointer out of memory (%d elements)",n_ref*YD_FLTMES);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      /* --- compte le nombre d'etoiles dans HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_ref0=0;
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            n_ref0++;
         }
      }
      fclose(f_in);
      if (n_ref0==0) {
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         return TCL_OK;
      }
      /* --- on dimensionne un vecteur pour les tris ---*/
      n_val=(n_ref>n_zmg)?n_ref:n_zmg;
      n_val=(n_ref0>n_val)?n_ref0:n_val;
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," n_ref0=%d\n",n_ref0);
fprintf(f," n_val=%d\n",n_val);
fclose(f);
#endif
      val=(double*)malloc(n_val*sizeof(double));
      if (val==NULL) {
         sprintf(s,"error : val pointer out of memory (%d elements)",n_val);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         return TCL_ERROR;
      }
	  /*-----Le vecteur des erreurs pour le calcul du sigma*/
	  erreurs=(double*)malloc(n_val*sizeof(double));
      if (val==NULL) {
         sprintf(s,"error : erreurs pointer out of memory (%d elements)",n_val);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
		 free(val);
         return TCL_ERROR;
      }
      /* --- alloue la memoire ---*/
      htmrefs=(struct_htmref*)malloc(n_ref0*sizeof(struct_htmref));
      if (htmrefs==NULL) {
         sprintf(s,"error : htmrefs pointer out of memory (%d elements)",n_ref0);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         free(val);
		 free(erreurs);
         return TCL_ERROR;
      }
      ind_ref=(int*)malloc(n_ref0*sizeof(int));
      if (ind_ref==NULL) {
         sprintf(s,"error : ind_ref pointer out of memory (%d elements)",n_ref0);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         free(val);
		 free(erreurs);
		 free(htmrefs);
         return TCL_ERROR;
      }
      /* --- lecture de htms a partir de HTM_ref.bin  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         free(val);
		 free(erreurs);
		 free(htmrefs);
         free(ind_ref);
         return TCL_ERROR;
      }
      k=0;
	  while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            htmrefs[k]=htmref;
            val[k]=(double)htmref.indexref;
            ind_ref[k]=k;
            k++;
         }
      }
      fclose(f_in);
      yd_util_qsort_double(val,0,n_ref0,ind_ref);
      /* === grande boucle sur les cam+filtre ===*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," GRANDE BOUCLE\n");
fclose(f);
#endif
      for (kcam=0;kcam<256;kcam++) {
         ukcam=(unsigned char)kcam;
         for (kfil=0;kfil<256;kfil++) {
            ukfil=(unsigned char)kfil;
			/*Modif Yassine : puisqu'on exige 10 mes pour 1 seule étoile
			if (codes[kcam][kfil]<2) {*/
			if (codes[kcam][kfil]<11) {
			/*fin*/
                /* --- Pas assez de mesures faites avec cette combinason cam+filtre ---*/
                continue;
			}
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"   kcam=%d  kfil=%d\n",kcam,kfil);
fclose(f);
#endif
            /* --- on commence par initialiser l'histogramme des mesures ---*/
            for (k=0;k<n_ref;k++) {
               flt_mes[YD_NJD*n_ref+k]=(float)0;
            }
			/* --- on remplit l'histogramme des mesures ---*/
            for (k=0;k<n_mes;k++) {
               if (htmmess[k].codecam!=ukcam) {
                  continue;
               }
               if (htmmess[k].codefiltre!=ukfil) {
                  continue;
               }
               flt_mes[YD_NJD*n_ref+htmmess[k].indexref]+=1.;
            }
            /* --- valeur moyenne et sigma de la magnitude des etoiles ---*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"   VALEUR MOYENNE\n");
fclose(f);
#endif
/*ff=fopen("toto.txt","w");*/
            for (kref=0;kref<n_ref;kref++) {
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"     kref=%d n_ref=%d\n",kref,n_ref);
fclose(f);
#endif
               /* --- init le vecteur ---*/
               flt_mes[YD_MAGMOY*n_ref+kref]=(float)-99.9;
               flt_mes[YD_SIGMOY*n_ref+kref]=(float)0;
               flt_mes[YD_ALLJD*n_ref+kref]=(float)0;
               flt_mes[YD_SIGJD*n_ref+kref]=(float)0;
			   /*rajout Yassine*/
			   flt_mes[YD_AMPLI*n_ref+kref]=(float)0;
			   flt_mes[YD_FIT*n_ref+kref]=(float)1000;
			   /*fin*/
               /* --- l'etoile doit etre observee au moins 10 fois ---*/
               /*Modif Yassine
			   if (flt_mes[YD_NJD*n_ref+kref]>=(float)3) {*/
               if (flt_mes[YD_NJD*n_ref+kref]>=(float)10) {
			   /*fin*/
                  kk=0;
                  /* --- boucle sur les seuls elements de htmmes concernes ---*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"     DEBUT DE BOUCLE SUR LES DATES\n");
fclose(f);
#endif
                  for (kzmg=0;kzmg<n_zmg;kzmg++) {
                     kkzmg=htmzmgs[kzmg].indexzmg;
                     k=ind_refzmg[kref*n_zmg+kkzmg];
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"       kref=%d kzmg=%d kkzmg=%d k=%d\n",kref,kzmg,kkzmg,k);
fclose(f);
#endif
                     /* --- l'etoile doit etre observee pour cette date ---*/
                     if (k>=0) {
						/* --- l'observation doit etre faite avec les bons filtres ---*/
                        if (htmmess[k].codefiltre!=ukfil) {
                           continue;
						}
                        if (htmmess[k].codecam!=ukcam) {
                           continue;
						}
                        /* --- la mesure de la magnitude doit avoir un sens a cette date ---*/
                        if ((double)htmmess[k].magcali>=-50.0) {
                           /*Modif Yassine
						   val[kk]=(double)htmmess[k].maginst;*/
						   val[kk]=(double)htmmess[k].magcali;
						   erreurs[kk]=(double)htmmess[k].dmag;
						   /*fin*/
                           kk++;
                        }
                     }
                  }
                  n=kk;
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"     FIN DE BOUCLE SUR LES DATES\n");
fprintf(f,"     n=%d\n",n);
fclose(f);
#endif
                  /*Modif Yassine: Au moins 10 mesures valables
                  if (n>=3) {*/
                  if (n>=10) {
                     /* --- moyenne et ecart type ---*/
					 yd_util_meansigma_poids(val,erreurs,0,n,1,&mean,&sigma);
                     flt_mes[YD_MAGMOY*n_ref+kref]=(float)mean;
					 if (mean<-50.) {
						 continue;
					 }
					 /*fin*/
                     flt_mes[YD_SIGMOY*n_ref+kref]=(float)sigma;
                     flt_mes[YD_ALLJD*n_ref+kref]=(float)n;
					 /*rajout Yassine : pour avoir l'amplitude*/
					 yd_util_qsort_double(val,0,n,NULL);
					 ampli = val[n-1]-val[0];
					 flt_mes[YD_AMPLI*n_ref+kref]=(float)ampli;
/*fprintf(ff,"%4d %7.4f %7.4f %7.4f %4d\n",kref,mean,sigma,ampli,n);*/
					 /*fin*/
                     /* --- nb de mesures superieures a 3*sigma ---*/
                     magmax=mean+3*sigma;
                     magmin=mean-3*sigma;
                     kk=0;
                     for (k=0;k<n;k++) {
                        if (val[k]<magmin) kk++;
                        if (val[k]>magmax) kk++;
                     }
                     flt_mes[YD_SIGJD*n_ref+kref]=(float)kk;


                  }
               }
            }
/*fclose(ff);*/
			k_iter=0;
			while (k_iter<NB_ITER) {
				somme_sig_photo=0;
				somme_moy_photo=0;
				somme_sig_backg=0;
				somme_moy_backg=0;
				k_photo=0;
				k_backg=0;
				for (kref=0;kref<n_ref;kref++) {
					mean=(double)flt_mes[YD_MAGMOY*n_ref+kref];
					sigma=(double)flt_mes[YD_SIGMOY*n_ref+kref];
					val_droite=(double)flt_mes[YD_FIT*n_ref+kref];
					/*La combinaison mean>-99.9 avec val_droite nous évite de prendre de mauvais points*/
					/*Au debut je prends tous les points car val_droite=1000 partout*/
					if (sigma<val_droite) {
						if ((mean<=MAG_PHOTO)&&(mean>-99.9)) {
							somme_sig_photo=somme_sig_photo+log(sigma);
							somme_moy_photo=somme_moy_photo+mean;
                            k_photo++;
						} else if ((mean<=MAG_BACKG)&&(mean>MAG_PHOTO)) {
							somme_sig_backg=somme_sig_backg+log(sigma);
							somme_moy_backg=somme_moy_backg+mean;
							k_backg++;
						}
					}
				}
				if (k_photo==0) {
					ordo_alorigine_photo=0;
				} else {
                    ordo_alorigine_photo=(somme_sig_photo-pente_photo*somme_moy_photo)/k_photo;
				}
				if (k_backg==0) {
					ordo_alorigine_backg=0;
				} else {
                    ordo_alorigine_backg=(somme_sig_backg-pente_backg*somme_moy_backg)/k_backg;
				}
                for (kref=0;kref<n_ref;kref++) {
					mean=(double)flt_mes[YD_MAGMOY*n_ref+kref];
                    val_droite=sqrt(exp(2*(pente_photo*mean+ordo_alorigine_photo))+exp(2*(pente_backg*mean+ordo_alorigine_backg)));
				    flt_mes[YD_FIT*n_ref+kref]=(float)(XMOYFIT*val_droite);
				}
                k_iter++;
			}
/*ff=fopen("resume.txt","wt");*/
			for (kref=0;kref<n_ref;kref++) {
				/*Init de critvar*/
				for (kvar=0;kvar<2;kvar++) {
                    critvar[kvar]=0;
				}
				mean=(double)flt_mes[YD_MAGMOY*n_ref+kref];
				sigma=(double)flt_mes[YD_SIGMOY*n_ref+kref];
				val_droite=XMOY*sqrt(exp(2*(pente_photo*mean+ordo_alorigine_photo))+exp(2*(pente_backg*mean+ordo_alorigine_backg)));
				/*val_droite=(double)flt_mes[YD_FIT*n_ref+kref]*XMOY;*/
				ampli=(float)flt_mes[YD_AMPLI*n_ref+kref];
				n=(int)flt_mes[YD_ALLJD*n_ref+kref];
/*fprintf(ff,"%4d %7.6f %7.6f %4d\n",kref,mean,sigma,n);*/
				if ((sigma>=val_droite)&&(ampli>sigma)&&(n>=minobs)) {
                    critvar[0]=1;
				}
				/*sigjd=(int)flt_mes[YD_SIGJD*n_ref+num_etoi];
                alljd=(int)flt_mes[YD_ALLJD*n_ref+num_etoi];
				if ((100.*(double)sigjd/(double)alljd>(100.-99.8))&&(alljd>100)) {
					critvar[1]=0;
				}*/
				critvar[1]=0;
				critvartot=critvar[0];/*+critvar[1];*/
                if (critvartot>0) {
                    ra=(double)htmrefs[ind_ref[kref]].ra;
                    dec=(double)htmrefs[ind_ref[kref]].dec;
                    /* --- ouvre le fichier de sortie ---*/
						  nvar++;
                    sprintf(filename_out,"%s%s-%s-%d-%d-%d.txt",path,observatory_symbol,generic_filename,kref,kfil,kcam);
                    f_out=fopen(filename_out,"wt");
				    if (f_out==NULL) {
						free(htmzmgs);
                        free(htmmess);
                        free(ind_refzmg);
                        free(flt_mes);
                        free(val);
						free(erreurs);
                        free(htmrefs);
                        free(ind_ref);
					}
                    /*             123456789 12345678 */
                    fprintf(f_out,"NAME      = %s-%s-%d \n",observatory_symbol,generic_filename,kref);
                    fprintf(f_out,"RA        = %10.6f \n",ra);
                    fprintf(f_out,"DEC       = %10.6f \n",dec);
                    fprintf(f_out,"EQUINOX   = J2000.0 \n");
                    /*fprintf(f_out,"FILTERNO= %u \n",ukfil);*/
                    fprintf(f_out,"FILTER    = %c \n",ukfil);
                    fprintf(f_out,"CAMERANO  = %u \n",ukcam);
                    //fprintf(f_out,"TAROT     = CALERN \n");
							sprintf(s,"llength {%s}",ListKeyValues);
						   Tcl_Eval(interp,s);
							nl=atoi(Tcl_GetStringResult(interp));
							for (kl=0;kl<nl;kl++) {
								sprintf(s,"lindex [lindex {%s} %d] 0",ListKeyValues,kl);
								Tcl_Eval(interp,s);
								strcpy(s,Tcl_GetStringResult(interp));
								if (strcmp(s,"")==0) {
									continue;
								}
								strcat(s,"           ");
								s[9]='\0';
								fprintf(f_out,"%s = ",s);
								sprintf(s,"lindex [lindex {%s} %d] 1",ListKeyValues,kl);
								Tcl_Eval(interp,s);
								strcpy(s,Tcl_GetStringResult(interp));
								fprintf(f_out,"%s\n",s);
							}
                    /*fprintf(f_out,"CRITVAR1= %d \n",critvar[1]);*/
                    fprintf(f_out,"MEAN      = %f \n",mean);
                    fprintf(f_out,"SIGMA     = %f \n",sigma);
                    fprintf(f_out,"AMPLITUDE = %f \n",ampli);
                    /*fprintf(f_out,"SIGMOY  = %f \n",sigmoy);
                    fprintf(f_out,"SIGSIG    = %f \n",sigsig);*/
                    fprintf(f_out,"CRITVAR   = %f \n",val_droite);
                    /*fprintf(f_out,"ALLJD   = %d \n",alljd);
                    fprintf(f_out,"SIGJD     = %d \n",sigjd);
                    fprintf(f_out,"PERCENT   = %f \n",100.*(double)sigjd/(double)alljd);*/
                    fprintf(f_out,"END\n");
                    /* --- boucle sur les seuls elements de htmmes concernes ---*/
                    for (kzmg=0;kzmg<n_zmg;kzmg++) {
						kkzmg=htmzmgs[kzmg].indexzmg;
                        kkkzmg=ind_refzmg[kref*n_zmg+kkzmg];
					    if (kkkzmg>=0) {
							htmmes=htmmess[kkkzmg];
                            if (htmmes.codefiltre!=ukfil) {
								continue;
						    }
                            if (htmmes.codecam!=ukcam) {
                                continue;
							}
                            if (htmmes.magcali>=-50.) {
                                /* --- on imprime les caracteristiques ---*/
                                fprintf(f_out,"%15.6f %7.3f %5.3f %3d\n",
                                htmmes.jd,htmmes.magcali,htmmes.dmag,htmmes.flag);
							}
						}
                    }
					fclose(f_out);
				}
			}
/*fclose(ff);*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f,"   FIN DE PETITE BOUCLE\n");
fclose(f);
#endif
         }
      }
      /* === fin de la grande boucle sur les cam+filtre ===*/
      /* --- Libere la memoire ---*/
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," DEBUT DES FREE\n");
fclose(f);
#endif
      free(htmzmgs);
      free(htmmess);
      free(ind_refzmg);
      free(flt_mes);
      free(val);
	  free(erreurs);
      free(htmrefs);
      free(ind_ref);
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","at");
fprintf(f," FIN DES FREE\n");
fclose(f);
#endif
   }
Tcl_DStringInit(&dsptr);
sprintf(s,"%d",nvar);
Tcl_DStringAppend(&dsptr,s,-1);
Tcl_DStringResult(interp,&dsptr);
Tcl_DStringFree(&dsptr);
   return TCL_OK;
}

int Cmd_ydtcl_updatezmg(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* mise a jour du fichier htm_zmg.bin                                       */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/* cmag est mis a jour.                                                     */
/****************************************************************************/
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   struct_htmzmg  htmzmg,*htmzmgs=NULL;
   double *val=NULL;
   double cmag;
   float *flt_mes=NULL;
   int *ind_refzmg=NULL;
   int n_mes,k,kcam,kfil,n_ref,kk,n_zmg,kref,kzmg;
   float maxik,maxik0,magmed;
   int n_selec_ref,n,kkzmg,n_val;
   unsigned char ukcam,ukfil;
   double magmax;
   double magsaturated,magtoofaint;
   FILE *f_in,*f_out;
   int codes[256][256];
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename ?magsaturated? ?magtoofaint?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      magsaturated=-99.9;
      if (argc>=4) {
         magsaturated=(double)atof(argv[3]);
      }
      magtoofaint=1e10;
      if (argc>=5) {
         magtoofaint=(double)atof(argv[4]);
      }
      /* --- init des tableaux ---*/
      for (kcam=0;kcam<256;kcam++) {
         for (kfil=0;kfil<256;kfil++) {
            codes[kcam][kfil]=0;
         }
      }
      /* --- compte le nombre de dates-filtre dans HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            n_zmg++;
         }
      }
      fclose(f_in);
      if (n_zmg==0) return TCL_OK;
      /* --- alloue la memoire ---*/
      htmzmgs=(struct_htmzmg*)malloc(n_zmg*sizeof(struct_htmzmg));
      if (htmzmgs==NULL) {
         sprintf(s,"error : htmzmgs pointer out of memory (%d elements)",n_zmg);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      /* --- lecture de htmzmgs a partir de HTM_zmg.bin  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
            htmzmgs[k]=htmzmg;
            k++;
         }
      }
      fclose(f_in);
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      n_mes=0;
      n_zmg=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            codes[(int)htmmes.codecam][(int)htmmes.codefiltre]++;
            n_mes++;
            if (htmmes.indexzmg>n_zmg) {
               n_zmg=htmmes.indexzmg;
            }
         }
      }
      n_ref=htmmes.indexref+1;
      n_zmg+=1;
      fclose(f_in);
      if (n_mes==0) return TCL_OK;
      /* --- alloue la memoire pour htmmess---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         return TCL_ERROR;
      }
      /* --- on dimensionne la matrice x=indexref y=indexjd val=kmes */
      /*     ce tableau est utile pour circuler rapidement dans htmmess */
      n=n_ref*n_zmg;
      ind_refzmg=(int*)calloc(n,sizeof(int));
      if (ind_refzmg==NULL) {
         sprintf(s,"error : ind_refzmg pointer out of memory (%d elements)",n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         return TCL_ERROR;
      }
      for (k=0;k<n;k++) {
         ind_refzmg[k]=-1;
      }
      /* --- lecture des donnees pour htmmess ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            htmmess[k]=htmmes;
            ind_refzmg[htmmes.indexref*n_zmg+htmmes.indexzmg]=k;
            k++;
         }
      }
      fclose(f_in);
      /* --- on dimensionne le tableau de l'histogramme ---*/
      flt_mes=(float*)calloc(n_ref*2,sizeof(float));
      if (flt_mes==NULL) {
         sprintf(s,"error : flt_mes pointer out of memory (%d elements)",n_ref*2);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         return TCL_ERROR;
      }
      /* --- on dimensionne un vecteur pour les tris ---*/
      n_val=(n_ref>n_zmg)?n_ref:n_zmg;
      val=(double*)malloc(n_val*sizeof(double));
      if (val==NULL) {
         sprintf(s,"error : val pointer out of memory (%d elements)",n_val);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmzmgs);
         free(htmmess);
         free(ind_refzmg);
         free(flt_mes);
         return TCL_ERROR;
      }
      /* === grande boucle sur les cam+filtre ===*/
      for (kcam=0;kcam<256;kcam++) {
         ukcam=(unsigned char)kcam;
         for (kfil=0;kfil<256;kfil++) {
            ukfil=(unsigned char)kfil;
            if (codes[kcam][kfil]<2) {
               /* --- Pas assez de mesures faites avec cette combinason cam+filtre ---*/
               continue;
            }
            /* --- on commence par initialiser l'histogramme des mesures ---*/
            for (k=0;k<n_ref;k++) {
               flt_mes[k]=(float)0;
			   /*Rajout Yassine : par simple précaution*/
			   flt_mes[n_ref+k]=(float)-99.9;
			   /*fin*/
            }
            /* --- on remplit l'histogramme des mesures ---*/
            for (k=0;k<n_mes;k++) {
               if (htmmess[k].codecam!=ukcam) {
                  continue;
               }
               if (htmmess[k].codefiltre!=ukfil) {
                  continue;
               }
			   /* Condition pour le flag Sextractor */
			   if (htmmess[k].flag==0) {
			   /*fin*/
			       flt_mes[htmmess[k].indexref]+=1.;
			   }

            }
            /* --- on recherche la valeur maximale de l'histogramme ---*/
            maxik=(float)0;
            for (k=0;k<n_ref;k++) {
               if (flt_mes[k]>maxik) {
                  maxik=flt_mes[k];
               }
            }
            /* --- on compte toutes les etoiles qui sont > 0.8*maxi ---*/
            maxik0=(float)(maxik*0.8);
            n_selec_ref=0;
            for (k=0;k<n_ref;k++) {
               if (flt_mes[k]>maxik0) {
                  n_selec_ref++;
                  flt_mes[n_ref+k]=(float)1.;
               } else {
                  flt_mes[n_ref+k]=(float)-99.9;
               }
            }
            /*
            load libyd ; yd_updatezmg c:/d/tarot/tarot6/f/pretraite/im/rrlyr/ N111120220 8 15 ; yd_refzmgmes2ascii c:/d/tarot/tarot6/f/pretraite/im/rrlyr/ N111120220
            */
            if (n_selec_ref<4) continue;
            /* --- valeur mediane de la magnitude des etoiles selectionnees ---*/
            for (kref=0;kref<n_ref;kref++) {
               /* --- l'etoile doit etre selectionnee pour le calcul de la mediane ---*/
               if (flt_mes[n_ref+kref]>0.) {
                  kk=0;
                  /* --- boucle sur les seuls elements de htmmes concernes ---*/
                  for (kzmg=0;kzmg<n_zmg;kzmg++) {
                     kkzmg=htmzmgs[kzmg].indexzmg;
                     k=ind_refzmg[kref*n_zmg+kkzmg];
                     if (k>=0) {
                        if (htmmess[k].codefiltre!=ukfil) {
                           continue;
                        }
                        if (htmmess[k].codecam!=ukcam) {
                           continue;
                        }
						/* Condition pour le flag Sextractor */
						if (htmmess[k].flag==0) {
						/*fin*/
                            val[kk]=(double)htmmess[k].maginst;
                            kk++;
						}
                     }
                  }
                  n=kk;
                  if (n<3) {
                     flt_mes[n_ref+kref]=(float)-99.9;
                  } else {
                     /* --- on trie les donnees ---*/
                     yd_util_qsort_double(val,0,n,NULL);
                     /* --- indice de la valeur mediane ---*/
                     k=(n+1)/2;
                     flt_mes[n_ref+kref]=(float)val[k];
                  }
               }
            }
            /* --- on va determiner automatiquement les seuils de magnitude */
            for (kref=0;kref<n_ref;kref++) {
               magmed=flt_mes[n_ref+kref];
               val[kref]=magmed;
            }
            /* on trie les donnees */
            yd_util_qsort_double(val,0,n_ref,NULL);
            /* seules les val[n_ref-n_selec_ref] a val[n_ref-1] sont valables */
            kk=0;
            magmax=1e10;
            for (k=n_ref-n_selec_ref;k<n_ref;k++) {
               if (val[k]>magsaturated) {
                  kk++;
               }
               magmax=val[k];
               if (kk>12) {
                  break;
			   }
            }
            /* --- CMAG = valeur mediane de la difference de magnitudes */
            /*     (mediane - instrumentale) des etoiles selectionnees ---*/
            for (kzmg=0;kzmg<n_zmg;kzmg++) {
               kkzmg=htmzmgs[kzmg].indexzmg;
               if (htmzmgs[kkzmg].codefiltre!=ukfil) {
                  continue;
               }
               if (htmzmgs[kkzmg].codecam!=ukcam) {
                  continue;
               }
               kk=0;
			   /* --- boucle sur les seuls elements de htmmes concernes ---*/
               for (kref=0;kref<n_ref;kref++) {
				  magmed=flt_mes[n_ref+kref];
				  if ((magmed<=magsaturated)) {
                     /* l'etoile risque de saturer */
                     continue;
                  }
				  if ((magmed>=magtoofaint)||(magmed>magmax)) {
                     /* l'etoile est trop faible */
                     continue;
                  }
				  k=ind_refzmg[kref*n_zmg+kkzmg];
                  if (k>=0) {
                     if (htmmess[k].codefiltre!=ukfil) {
                        continue;
                     }
                     if (htmmess[k].codecam!=ukcam) {
                        continue;
                     }
					 /* Condition pour le flag Sextractor */
			         if (htmmess[k].flag==0) {
			         /*fin*/
                         val[kk]=(double)(magmed-htmmess[k].maginst);
                         kk++;
					 }
                  }
               }
               n=kk;
			   /* --- on coupe à une seule étoile de reference (avant c'etait 5) --- */
               if (n<1) {
                  htmzmgs[kkzmg].cmag=(float)-99.9;
               } else if (n<3) {
                  htmzmgs[kkzmg].cmag=(float)(0);
               } else {
                  /* --- on trie les donnees ---*/
                  yd_util_qsort_double(val,0,n,NULL);
                  /* --- indice de la valeur mediane ---*/
                  k=(n+1)/2;
                  htmzmgs[kkzmg].cmag=(float)val[k];
               }
            }
         }
      }
      /* === fin de la grande boucle sur les cam+filtre ===*/
      sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename);
      f_out=fopen(filename_out,"wb");
      for (k=0;k<n_zmg;k++) {
         fwrite(&htmzmgs[k],1,sizeof(struct_htmzmg),f_out);
      }
      fclose(f_out);
      sprintf(filename_out,"%s%s_mes.bin",path,generic_filename);
      f_out=fopen(filename_out,"wb");
      for (k=0;k<n_mes;k++) {
         kkzmg=htmmess[k].indexzmg;
         cmag=(double)htmzmgs[kkzmg].cmag;
         if (cmag>-50.) {
            htmmess[k].magcali=htmmess[k].maginst+(float)cmag;
         } else {
            htmmess[k].magcali=(float)-99.9;
         }
         fwrite(&htmmess[k],1,sizeof(struct_htmmes),f_out);
      }
      fclose(f_out);
      /* --- Libere la memoire ---*/
      free(htmzmgs);
      free(htmmess);
      free(ind_refzmg);
      free(val);
      free(flt_mes);
   }
   return TCL_OK;
}

int Cmd_ydtcl_sortmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Trie les mesures selon les indices d'etoile et selon les dates.          */
/* Mise a jour du fichier htm_mes.bin                                       */
/* a partir du fichier htm_mes.bin                                          */
/****************************************************************************/
/* Doit etre effectue apres une serie de yd_file2refzmgmes et avant updates */
/****************************************************************************/
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmmes  htmmes,*htmmess=NULL;
   int *ind_ind_mes=NULL;
   double *val_ind_mes=NULL;
   int n_mes,k;
   FILE *f_in,*f_out;
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_mes=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            n_mes++;
         }
      }
      fclose(f_in);
      if (n_mes==0) return TCL_OK;
      /* --- alloue la memoire ---*/
      htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
      if (htmmess==NULL) {
         sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_ind_mes=(int*)malloc(n_mes*sizeof(int));
      if (ind_ind_mes==NULL) {
         sprintf(s,"error : ind_ind_mes pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmmess);
         return TCL_ERROR;
      }
      val_ind_mes=(double*)malloc(n_mes*sizeof(double));
      if (val_ind_mes==NULL) {
         sprintf(s,"error : val_ind_mes pointer out of memory (%d elements)",n_mes);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(htmmess);
         free(ind_ind_mes);
         return TCL_ERROR;
      }
      /* --- lecture des donnees ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      k=0;
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
 /*Rajout Yassine:pour nettoyer un petit bug*/
			if (htmmes.jd<2400000.){continue;}
/*fin du rajout Yassine*/
            htmmess[k]=htmmes;
            sprintf(s,"%d%f",htmmes.indexref,htmmes.jd);
            val_ind_mes[k]=(double)atof(s);
            ind_ind_mes[k]=k;
            k++;
         }
      }
      fclose(f_in);
/*Rajout Yassine:pour nettoyer un petit bug n_mes devient k*/
	  n_mes=k;
/*fin du rajout Yassine*/
      /* --- on trie les donnees ---*/
      yd_util_qsort_double(val_ind_mes,0,n_mes,ind_ind_mes);
      /* --- ecriture des donnees triees ---*/
      sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename);
      f_out=fopen(filename_out,"wb");
      if (f_out==NULL) {
         sprintf(s,"filename_out %s not found",filename_out);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      for (k=0;k<n_mes;k++) {
         fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
      }
      fclose(f_out);
      /* --- on renome le fichier ---*/
      sprintf(filename_in,"%s%s_mes.bin0",path,generic_filename);
      sprintf(filename_out,"%s%s_mes.bin",path,generic_filename);
      remove(filename_out);
      rename(filename_in,filename_out);
      /* --- libere la memoire ---*/
      free(val_ind_mes);
      free(ind_ind_mes);
      free(htmmess);
   }
   return TCL_OK;
}

int Cmd_ydtcl_refzmgmes2ascii(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Genere les trois fichiers htm_ref.txt, htm_zmg.txt, htm_ref.txt,         */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/* Fonction utile pour le debuggogage.                                      */
/****************************************************************************/
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename[1024],filename_out[1024];
   struct_htmref  htmref;
   struct_htmzmg  htmzmg;
   struct_htmmes  htmmes;
   FILE *f_in,*f_out;
   if(argc<3) {
      sprintf(s,"Usage: %s path generic_filename", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(path,argv[1]);
      strcpy(generic_filename,argv[2]);
      /* --- transcode le fichier htm_ref.bin => htm_ref.txt  ---*/
      sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
      sprintf(filename_out,"%s%s_ref.txt",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
            fprintf(f_out,"%5d %5d %10.6f %10.6f %3d %3d %8.4f %3d %3d %8.4f %3d %3d %8.4f %3d %3d %8.4f\n",
               htmref.indexref,htmref.nbmes,htmref.ra,htmref.dec,
               htmref.codecat[0],htmref.codefiltre[0],htmref.mag[0],
               htmref.codecat[1],htmref.codefiltre[1],htmref.mag[1],
               htmref.codecat[2],htmref.codefiltre[2],htmref.mag[2],
               htmref.codecat[3],htmref.codefiltre[3],htmref.mag[3]);
         }
      }
      fclose(f_in);
      fclose(f_out);
      /* --- transcode le fichier htm_zmg.bin => htm_zmg.txt  ---*/
      sprintf(filename_in,"%s%s_zmg.bin",path,generic_filename);
      sprintf(filename_out,"%s%s_zmg.txt",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmzmg,1,sizeof(struct_htmzmg),f_in)>1) {
			 fprintf(f_out,"%5d %15.6f %2d %3d %8.4f %6.2f %5.3f\n",
             htmzmg.indexzmg,htmzmg.jd,htmzmg.codecam,htmzmg.codefiltre,htmzmg.cmag,htmzmg.exposure,htmzmg.airmass);
         }
      }
      fclose(f_in);
      fclose(f_out);
      /* --- transcode le fichier htm_mes.bin => htm_mes.txt  ---*/
      sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
      sprintf(filename_out,"%s%s_mes.txt",path,generic_filename);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wt");
      while (feof(f_in)==0) {
         if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
            /*modif Yassine
			fprintf(f_out,"%5d %5d %15.6f %3d %3d %8.4f %8.4f\n",
            htmmes.indexref,htmmes.indexzmg,htmmes.jd,htmmes.codecam,htmmes.codefiltre,
            htmmes.maginst,htmmes.magcali);*/
            fprintf(f_out,"%5d %5d %15.6f %3d %3d %8.4f %8.4f %5.3f %3d\n",
            htmmes.indexref,htmmes.indexzmg,htmmes.jd,htmmes.codecam,htmmes.codefiltre,
            htmmes.maginst,htmmes.magcali,htmmes.dmag,htmmes.flag);
			/*fin*/
         }
      }
      fclose(f_in);
      fclose(f_out);
   }
   return TCL_OK;
}

int Cmd_ydtcl_filehtm2refzmgmes(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Genere les trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin,         */
/* a partir d'un fichier texte de catalogue d'observation d'un HTM donne.   */
/****************************************************************************/
/* Input : (issu de yd_file2htm                                             */
/* ra dec jd codecam codefiltre maginst exposure airmass dmag(en binaires)  */
/****************************************************************************/
{
   char s[100];
   char path[1024];
   char filename_in[1024],generic_filename_out[1024],filename_out[1024];
   FILE *f_in,*f_out;
   int n,n_file,n_ref,n_zmg;
   int k,k_file,k_ref,k_zmg,sortie;
   struct_htmfile htmfile,*htmfiles=NULL;
   struct_htmref  htmref, *htmrefs=NULL;
   struct_htmzmg  htmzmg, *htmzmgs=NULL;
   struct_htmmes  htmmes, *htmmess=NULL;
   int *ind_dec_file=NULL,*ind_dec_ref=NULL,*ind_jd_zmg=NULL,*ind_ind_mes=NULL;
   double *val_dec_file=NULL,*val_dec_ref=NULL,*val_jd_zmg=NULL,*val_ind_mes=NULL;
   int newref=0,newzmg=0;
   int newreffiltre,index_ref,index_zmg,index_mes;
   double dec0,ra0,dec,ra,cosdec0;
   double dr,ddec,dra,dangle,dangle2;
   int k_ref1,k_ref2;
   /*,k_ref_prog;*/
   int saveref=0,savezmg=0,savemes=0;
   int k_zmg1,k_zmg2;
   double djd,jd,jd0;
   unsigned char codefiltre0;
   float exposure0,airmass0;
   /* rajout Yassine*/
   unsigned char codecam0;
   unsigned char flagsext0;
   float dmag0;
   int nouvdate;
   /*fin*/
   int index_in=0;
   double jd_in=0.;
   unsigned char codecam_in=0x00,codefiltre_in=0x00;
   int index_out;
   double jd_out;
   unsigned char codecam_out,codefiltre_out;
   int lecture,sortie2;

   if(argc<5) {
      sprintf(s,"Usage: %s filename_in path generic_filename_out angle", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(filename_in,argv[1]);
      strcpy(path,argv[2]);
      strcpy(generic_filename_out,argv[3]);
      dr=4*atan(1.)/180.;
      dangle=fabs(atof(argv[4]));
      if (dangle==0) { dangle=10.; }
      dangle2=dangle*dangle;
      /* --- decode le fichier input ---*/
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n=0;
      do {
         fread(&htmfile,1,sizeof(struct_htmfile),f_in);
         n++;
      } while (feof(f_in)==0) ;
      fclose(f_in);
      n--;
      n_file=n;
      htmfiles=(struct_htmfile*)malloc(n*sizeof(struct_htmfile));
      if (htmfiles==NULL) {
         sprintf(s,"error : htmfiles pointer out of memory (%d elements)",n);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_in=fopen(filename_in,"rb");
      for (k=0;k<n;k++) {
         fread(&htmfiles[k],1,sizeof(struct_htmfile),f_in);
      }
      fclose(f_in);
      /* --- decode le fichier HTM_ref.bin ---*/
      sprintf(filename_out,"%s%s_ref.bin",path,generic_filename_out);
      f_out=fopen(filename_out,"rb");
      n=0;
      if (f_out!=NULL) {
         do {
            fread(&htmref,1,sizeof(struct_htmref),f_out);
            n++;
         } while (feof(f_out)==0) ;
         fclose(f_out);
         n--;
      }
      n_ref=n;
      n+=n_file;
      if (n>0) {
         htmrefs=(struct_htmref*)malloc(n*sizeof(struct_htmref));
         if (htmrefs==NULL) {
            sprintf(s,"error : htmrefs pointer out of memory (%d elements)",n);
            free(htmfiles);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         if (n_ref>0) {
            f_out=fopen(filename_out,"rb");
            for (k=0;k<n_ref;k++) {
               fread(&htmrefs[k],1,sizeof(struct_htmref),f_out);
            }
            fclose(f_out);
         }
      }
      /* --- decode le fichier HTM_zmg.bin ---*/
      sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename_out);
      f_out=fopen(filename_out,"rb");
      n=0;
      if (f_out!=NULL) {
         do {
            fread(&htmzmg,1,sizeof(struct_htmzmg),f_out);
            n++;
         } while (feof(f_out)==0) ;
         fclose(f_out);
         n--;
      }
      n_zmg=n;
	  /*Modif Yassine : on va rajouter une date au plus
	  n+=n_file;*/
	  n+=1;
	  /*fin*/
      if (n>0) {
         htmzmgs=(struct_htmzmg*)malloc(n*sizeof(struct_htmzmg));
         if (htmzmgs==NULL) {
            sprintf(s,"error : htmzmgs pointer out of memory (%d elements)",n);
            free(htmfiles);
            free(htmrefs);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
         if (n_zmg>0) {
            f_out=fopen(filename_out,"rb");
            for (k=0;k<n_zmg;k++) {
               fread(&htmzmgs[k],1,sizeof(struct_htmzmg),f_out);
            }
            fclose(f_out);
         }
      }
      /* --- tri de filehtm selon les DEC croissantes ---*/
      n=n_file;
      val_dec_file=(double*)malloc((n+1)*sizeof(double));
      if (val_dec_file==NULL) {
         sprintf(s,"error : val_dec_file pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_dec_file=(int*)malloc((n+1)*sizeof(int));
      if (val_dec_file==NULL) {
         sprintf(s,"error : ind_dec_file pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  if (n_file>0) {
         n=n_file;
         for (k=0;k<n;k++) {
            val_dec_file[k]=htmfiles[k].dec;
            ind_dec_file[k]=k;
         }
         /*yd_util_qsort_double(val_dec_file,0,n,ind_dec_file); : ce nest pas important*/
      }
      /* --- tri de ref selon les DEC croissantes ---*/
      n=n_ref;
      n+=n_file;
      val_dec_ref=(double*)malloc((n+1)*sizeof(double));
      if (val_dec_ref==NULL) {
         sprintf(s,"error : val_dec_ref pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_dec_ref=(int*)malloc((n+1)*sizeof(int));
      if (val_dec_ref==NULL) {
         sprintf(s,"error : ind_dec_ref pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         free(val_dec_ref);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  if (n_ref>0) {
         n=n_ref;
         for (k=0;k<n;k++) {
            val_dec_ref[k]=htmrefs[k].dec;
            ind_dec_ref[k]=k;
         }
         yd_util_qsort_double(val_dec_ref,0,n,ind_dec_ref);
      }
      /* --- tri de zmg selon les JD croissantes ---*/
      n=n_zmg;
	  /*Modif Yassine : on va rajouter une date au plus
	  n+=n_file;*/
	  n+=1;
	  /*fin*/
      val_jd_zmg=(double*)malloc((n+1)*sizeof(double));
      if (val_jd_zmg==NULL) {
         sprintf(s,"error : val_jd_zmg pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         free(val_dec_ref);
         free(ind_dec_ref);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      ind_jd_zmg=(int*)malloc((n+1)*sizeof(int));
      if (val_jd_zmg==NULL) {
         sprintf(s,"error : ind_jd_zmg pointer out of memory (%d elements)",n);
         free(htmfiles);
         free(htmrefs);
         free(htmzmgs);
         free(val_dec_file);
         free(ind_dec_file);
         free(val_dec_ref);
         free(ind_dec_ref);
         free(val_jd_zmg);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
	  if (n_zmg>0) {
         n=n_zmg;
         for (k=0;k<n;k++) {
            val_jd_zmg[k]=htmzmgs[k].jd;
            ind_jd_zmg[k]=k;
         }
         yd_util_qsort_double(val_jd_zmg,0,n,ind_jd_zmg);
      }
      /* --- Alloue de la memoire pour les nouvelles etoiles a ---*/
      /*     ajouter dans HTM_mes.txt */
      n=n_file;
      if (n>0) {
         htmmess=(struct_htmmes*)malloc(n*sizeof(struct_htmmes));
         if (htmmess==NULL) {
            sprintf(s,"error : htmmess pointer out of memory (%d elements)",n);
            free(htmfiles);
            free(htmrefs);
            free(htmzmgs);
            free(val_dec_file);
            free(ind_dec_file);
            free(val_dec_ref);
            free(ind_dec_ref);
            free(val_jd_zmg);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      }
      /* ==--- grande boucle sur les etoiles ---==*/
      index_ref=n_ref-1;
      index_zmg=n_zmg-1;
      index_mes=-1;
      /*Rajout Yassine: pour enlever le bug des dates anterieures a la derniere date de zmg*/
	  nouvdate=0;
	  /*fin*/
	  /*k_ref_prog=0; : j'abondonne l'idee de trier les 2 listes avec l'indice qui augmente
	  a chaque fois qu'on trouve une etoile car il peut y avoir plusieurs dec tres proche
	  et avec les incertitudes on cherche une nouvelle etoile alors qu elle existe deja : jai eu le bug
	  Du coup ce nest pas la peine de trier htmfiles*/
	  for (k_file=0;k_file<n_file;k_file++) {
		 dec0=htmfiles[k_file].dec;
         ra0=htmfiles[k_file].ra;
         jd0=htmfiles[k_file].jd;
	     codefiltre0=htmfiles[k_file].codefiltre;
         exposure0=htmfiles[k_file].exposure;
         airmass0=htmfiles[k_file].airmass;
		 codecam0=htmfiles[k_file].codecam;
		 dmag0=htmfiles[k_file].dmag;
		 flagsext0=htmfiles[k_file].flag;

         /* === On ajoute eventuellement l'etoile a HTM_ref.bin */
         newref=-1;
         if (n_ref>0) {
            cosdec0=cos(dec0*dr);
            /* --- on recherche si l'etoile existe deja dans ref ---*/
            /* --- on commence par chercher DEC le plus proche ---*/
			/*k_ref1=k_ref_prog;*/
			k_ref1=0;
            k_ref2=n_ref-1;
			sortie=0;
			while(sortie==0) {
               k_ref=(k_ref1+k_ref2+1)/2;
               if ((k_ref2-k_ref1)<=1) { break; }
               dec=htmrefs[ind_dec_ref[k_ref]].dec;
               if (dec0<=dec) {
                  k_ref2=k_ref;
               } else {
                  k_ref1=k_ref;
               }
            }
            newref=-1;
            for (k=k_ref;k>=0;k--) {
               dec=htmrefs[ind_dec_ref[k]].dec;
			   ddec=(dec0-dec)*3600.;
               if (ddec>dangle) { break; }
               if (ddec<-dangle) { continue; }
               ddec*=ddec;
               ra=htmrefs[ind_dec_ref[k]].ra;
               /*modif Yassine
			   dra=(ra-ra0)*3600./cosdec0;  */
               dra=(ra-ra0)*3600.*cosdec0;
			   /*fin*/
               dra*=dra;
               if ((dra+ddec)<dangle2) {
                  newref=ind_dec_ref[k] ;
				  /*k_ref_prog=k+1;*/
				  break;
               }
            }
            if (newref==-1) {
				for (k=k_ref+1;k<n_ref;k++) {
                  dec=htmrefs[ind_dec_ref[k]].dec;
				  ddec=(dec-dec0)*3600.;
                  if (ddec>dangle) { break; }
                  if (ddec<-dangle) { continue; }
                  ddec*=ddec;
                  ra=htmrefs[ind_dec_ref[k]].ra;
                  /*modif Yassine
			      dra=(ra-ra0)*3600./cosdec0; */
                  dra=(ra-ra0)*3600.*cosdec0;
			      /*fin*/
                  dra*=dra;
                  if ((dra+ddec)<dangle2) {
                     newref=ind_dec_ref[k] ;
					 /*k_ref_prog=k+1;*/
					 break;
                  }
               }
            }
         } else {
            newref=-2;
         }
         if (newref<=-1) {
            /* --- L'etoile n'existe pas dans le catalogue ref ---*/
            /* --- on ajoute une etoile de reference ---*/
            index_ref++;
            htmrefs[index_ref].indexref=index_ref;
            htmrefs[index_ref].nbmes=1;
            htmrefs[index_ref].ra=ra0;
            htmrefs[index_ref].dec=dec0;
            htmrefs[index_ref].codecat[0]=(unsigned char)1;
            htmrefs[index_ref].codefiltre[0]=codefiltre0;
			htmrefs[index_ref].mag[0]=htmfiles[ind_dec_file[k_file]].maginst;
            for (k=1;k<4;k++) {
               htmrefs[index_ref].codecat[k]=(unsigned char)0;
               htmrefs[index_ref].codefiltre[k]=(unsigned char)0;
               htmrefs[index_ref].mag[k]=(float)-99.9;
            }
            saveref=1;
            newref=index_ref;
         } else if (newref>=0) {
            /* --- L'etoile existe dans le catalogue ref ---*/
            /* --- on affine les coordonnées ---*/
            n=htmrefs[newref].nbmes;
            htmrefs[newref].nbmes++;
            dra=fabs(htmrefs[newref].ra-ra0);
            if (dra>180.) {
               ra0+=360.;
            }
            htmrefs[newref].ra=(htmrefs[newref].ra*n+ra0)/(double)(n+1);
            if (htmrefs[newref].ra>360.) htmrefs[newref].ra-=360.;
            if (htmrefs[newref].ra<0.) htmrefs[newref].ra+=360.;
            htmrefs[newref].dec=(htmrefs[newref].dec*n+dec0)/(double)(n+1);
            /* --- on verifie le code du filtre ---*/
            newreffiltre=-2;
            for (k=0;k<4;k++) {
               if (htmrefs[newref].codefiltre[k]==codefiltre0) {
                  newreffiltre=k;
                  break;
               }
            }
            if (newreffiltre==-2) {
               /* --- Le filtre n'existe pas dans le catalogue ref ---*/
               /* --- on ajoute le code du filtre ---*/
               for (k=0;k<4;k++) {
                  if (htmrefs[newref].codefiltre[k]==0) {
                     htmrefs[newref].codecat[k]=(unsigned char)1;
                     htmrefs[newref].codefiltre[k]=codefiltre0;
					htmrefs[newref].mag[k]=htmfiles[ind_dec_file[k_file]].maginst;
                     saveref=1;
                     break;
                  }
               }
            }
            newref=htmrefs[newref].indexref;
         }
         /* --- ici newref est l'indice de l'etoile courante ---*/
         /*     dans HTM_ref.bin --- */
         /* === On ajoute eventuellement le JD,FILTRE,CMAG a HTM_zmg.bin */
		 /*Rajout Yassine : je fais ce test "if (nouvdate==0)" pour enlever le bug des dates
		 anterieurs a la derniere date de zmg: car par construction filename_in contient une seul date*/
		 if (nouvdate==0) {
			 newzmg=-1;
		     if (n_zmg>0) {
                /* --- on recherche si le jd existe deja dans zmg ---*/
                /* --- on commence par chercher JD le plus proche ---*/
                k_zmg1=0;
                k_zmg2=n_zmg-1;
			    sortie=0;
                while(sortie==0) {
                   k_zmg=(k_zmg1+k_zmg2+1)/2;
                   if ((k_zmg2-k_zmg1)<=1) { break; }
                   jd=htmzmgs[ind_jd_zmg[k_zmg]].jd;
                   if (jd0<=jd) {
                       k_zmg2=k_zmg;
                   } else {
                       k_zmg1=k_zmg;
                   }
                }
                for (k=k_zmg;k>=0;k--) {
                   jd=htmzmgs[ind_jd_zmg[k]].jd;
                   djd=(jd0-jd)*86400.;
                   if (djd>1.) { break; }
                   if (djd<-1.) { continue; }
			       if (htmzmgs[ind_jd_zmg[k]].codefiltre==codefiltre0) {
                       newzmg=ind_jd_zmg[k] ; break;
                   }
                }
                if (newzmg==-1) {
                   for (k=k_zmg+1;k<n_zmg;k++) {
                       jd=htmzmgs[ind_jd_zmg[k]].jd;
                       djd=(jd-jd0)*86400.;
                       if (djd>1.) { break; }
                       if (djd<-1.) { continue; }
			           if (htmzmgs[ind_jd_zmg[k]].codefiltre==codefiltre0) {
                           newzmg=ind_jd_zmg[k] ; break;
                       }
                   }
                }
             } else {
                newzmg=-2;
             }
		     if (newzmg<=-1) {
                /*Par construction: le fichier d'entree contient une seule date*/
			    nouvdate=1;
			    /*fin de la modif*/
			    /* --- La date+filtre n'existe pas dans le catalogue zmg ---*/
                /* --- on ajoute une date+filtre pour le point zero ---*/
			    index_zmg++;
                htmzmgs[index_zmg].indexzmg=index_zmg;
                htmzmgs[index_zmg].jd=jd0;
                htmzmgs[index_zmg].codecam=codecam0;
			    htmzmgs[index_zmg].codefiltre=codefiltre0;
                htmzmgs[index_zmg].cmag=(float)-99.9;
                htmzmgs[index_zmg].exposure=(float)exposure0;
                htmzmgs[index_zmg].airmass=(float)airmass0;
                savezmg=1;
                n_zmg++;
                for (k=0;k<n_zmg;k++) {
                    val_jd_zmg[k]=htmzmgs[k].jd;
                    ind_jd_zmg[k]=k;
                }
                yd_util_qsort_double(val_jd_zmg,0,n_zmg-1,ind_jd_zmg);
                newzmg=index_zmg;
             } else if (newref>=0) {
                /* --- La date+filtre  existe dans le catalogue zmg ---*/
               newzmg=htmzmgs[newzmg].indexzmg;
             }
		 } /*fin du test sur nouvedate : Modif Yassine
		 /* === On ajoute l'etoile a HTM_mes.bin */
         index_mes++;
         htmmess[index_mes].indexref=newref;
         htmmess[index_mes].indexzmg=newzmg;
         htmmess[index_mes].jd=jd0;
		 htmmess[index_mes].codecam=codecam0;
		 htmmess[index_mes].codefiltre=codefiltre0;
         /*htmmess[index_mes].maginst=htmfiles[ind_dec_file[k_file]].maginst;*/
		 htmmess[index_mes].maginst=htmfiles[k_file].maginst;
         htmmess[index_mes].magcali=(float)-99.9;
         htmmess[index_mes].dmag=dmag0;
		 htmmess[index_mes].flag=flagsext0;
         savemes=1;
      } /* ==--- fin de grande boucle sur les etoiles ---==*/
      /* --- mise a jour du fichier de reference si necessaire ---*/
      if (saveref==1) {
		  n=index_ref+1;
		  for (k=0;k<n;k++) {
            val_dec_ref[k]=htmrefs[k].dec;
            ind_dec_ref[k]=k;
         }
         yd_util_qsort_double(val_dec_ref,0,n,ind_dec_ref);
         sprintf(filename_out,"%s%s_ref.bin",path,generic_filename_out);
         f_out=fopen(filename_out,"wb");
         for (k=0;k<n;k++) {
            fwrite(&htmrefs[ind_dec_ref[k]],1,sizeof(struct_htmref),f_out);
         }
         fclose(f_out);
      }
      /* --- mise a jour du fichier de point zero de magnitudes si necessaire ---*/
      if (savezmg==1) {
         n=index_zmg+1;
         for (k=0;k<n;k++) {
            val_jd_zmg[k]=htmzmgs[k].jd;
            ind_jd_zmg[k]=k;
         }
         yd_util_qsort_double(val_jd_zmg,0,n,ind_jd_zmg);
         sprintf(filename_out,"%s%s_zmg.bin",path,generic_filename_out);
         f_out=fopen(filename_out,"wb");
         for (k=0;k<n;k++) {
            fwrite(&htmzmgs[ind_jd_zmg[k]],1,sizeof(struct_htmzmg),f_out);
         }
         fclose(f_out);
      }
      /* --- mise a jour du fichier de mesures si necessaire ---*/
      if (savemes==1) {
         n=index_mes+1;
         /* on utilise l'adresse de val_dec_file pour economiser de la place */
         val_ind_mes=val_dec_file;
         ind_ind_mes=ind_dec_file;
         for (k=0;k<n;k++) {
            val_ind_mes[k]=(double)htmmess[k].indexref;
            ind_ind_mes[k]=k;
         }
         yd_util_qsort_double(val_ind_mes,0,n,ind_ind_mes);
         sprintf(filename_in,"%s%s_mes.bin",path,generic_filename_out);
         f_in=fopen(filename_in,"rb");
         sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename_out);
         f_out=fopen(filename_out,"wb");
         if (f_in!=NULL) {
            k=0;
            lecture=1;
            while (0==0) {
               if ((feof(f_in)!=0)&&(k>=n)) {
                  break;
               }
               sortie2=0;
               if (lecture==1) {
                  if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)<1) {
                     index_in+=(1+n);
                     sortie2++;
                  } else {
                     index_in=htmmes.indexref;
                     jd_in=htmmes.jd;
                     codecam_in=htmmes.codecam;
                     codefiltre_in=htmmes.codefiltre;
                     lecture=0;
                  }
               }
               if (k<n) {
                  index_out=htmmess[ind_ind_mes[k]].indexref;
               } else {
                  index_out=100000000;
                  sortie2++;
               }
               if (sortie2==2) { break; }
               if (index_in<index_out) {
                  /* on garde l'ancienne mesure */
                  fwrite(&htmmes,1,sizeof(struct_htmmes),f_out);
                  lecture=1;
                  continue;
               }
               if (index_in>index_out) {
                  /* la nouvelle mesure s'inserere dans les anciennes */
                  fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
                  k++;
                  lecture=0;
                  continue;
               }
               if (index_in==index_out) {
                  jd_out=htmmess[ind_ind_mes[k]].jd;
                  /* on garde l'ancienne mesure a priori */
                  sortie=0;
                  if (jd_in==jd_out) {
                     codecam_out=htmmess[ind_ind_mes[k]].codecam;
                     if (codecam_in==codecam_out) {
                        codefiltre_out=htmmess[ind_ind_mes[k]].codefiltre;
                        if (codefiltre_in==codefiltre_out) {
                           /* la nouvelle mesure remplace l'ancienne */
                           sortie=1;
                        }
                     }
                  }
				  /*Rajout yassine : j'inclus la fonction sortmes ici*/
				  if (jd_in>jd_out) {
					  sortie=1;
				  }
				  /*fin modif yassine*/
                  if (sortie==0) {
                     fwrite(&htmmes,1,sizeof(struct_htmmes),f_out);
                     lecture=1;
                     continue;
                  } else {
                     fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
                     k++;
                     lecture=1;
                     continue;
                  }
               }
            }
            fclose(f_in);
            fclose(f_out);
         } else {
            fclose(f_out);
            remove(filename_out);
            /* premiere creation du fichier */
            sprintf(filename_out,"%s%s_mes.bin0",path,generic_filename_out);
            f_out=fopen(filename_out,"wb");
            for (k=0;k<n;k++) {
               fwrite(&htmmess[ind_ind_mes[k]],1,sizeof(struct_htmmes),f_out);
            }
            fclose(f_out);
         }
         sprintf(filename_in,"%s%s_mes.bin0",path,generic_filename_out);
         sprintf(filename_out,"%s%s_mes.bin",path,generic_filename_out);
         remove(filename_out);
         rename(filename_in,filename_out);
      }
      /* --- libere la memoire ---*/
      free(htmfiles);
      free(htmrefs);
      free(htmzmgs);
      free(val_dec_file);
      free(ind_dec_file);
      free(val_dec_ref);
      free(ind_dec_ref);
      free(val_jd_zmg);
      free(ind_jd_zmg);
      free(htmmess);
      /* --- nombre de nouvelles sources ---*/
      sprintf(s,"%d",index_mes+1);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_ydtcl_file2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************/
/* Explose le fichier texte de catalogue d'observation en leur equivalents       */
/* binaires rassemblés par meme HTM.                                             */
/*********************************************************************************/
/* Input :                                                                       */
/* ra dec jd codecam codefiltre maginst exposure airmass dmag flagsext (ASCII)   */
/* Output : un fichier pour chaque HTM                                           */
/* ra dec jd codecam codefiltre maginst exposure airmass dmag flagsext (binaire) */
/*********************************************************************************/
{
   char s[100];
   char path[1024];
   char ligne[2000],texte[2000],filename_in[1024],generic_filename_out[1024],filename_out[1024];
   char htm[80],htm_only[80];
   FILE *f_in,*f_out;
   int htm_level,n;
   double ra, dec, jd, codecam, codefiltre, maginst, exposure, airmass;
   /*rajout Yassine*/
   double dmag,flagsext;
   /*fin*/
   double dr;
   int htm_onlyflag=0,gofile;
   struct_htmfile htmfile;

   if(argc<5) {
      sprintf(s,"Usage: %s filename_in path generic_filename_out htm_level ?htm_only?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      /* --- decodage des arguments ---*/
      strcpy(filename_in,argv[1]);
      strcpy(path,argv[2]);
      strcpy(generic_filename_out,argv[3]);
      htm_level=(int)atoi(argv[4]);
      /*if (htm_level<0) { htm_level=0; }*/
      if (htm_level>12) { htm_level=12; }
      strcpy(htm_only,"");
      if (argc>=6) {
         htm_onlyflag=1;
         strcpy(htm_only,argv[5]);
		 if ((htm_level>=0)&&((int)strlen(htm_only)!=htm_level+2)) {
			 sprintf(s,"Usage: %s (htm_only = %s) must be (htm_level = %d)+2 caracters ", argv[0],htm_only,htm_level);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		 }
      }
      /* --- ouverture du fichier d'entree ---*/
      f_in=fopen(filename_in,"rt");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      memset(htm,'\0',80*sizeof(char));
      dr=4*atan(1.)/180.;
      n=0;
      do {

		 if (fgets(ligne,255,f_in)!=NULL) {
	         strcpy(texte,"");
   	      sscanf(ligne,"%s",texte);
	         if ( (strcmp(texte,"")!=0) ) {
               /* ra dec jd codecam codefiltre maginst exposure airmass   /*
			   /* modif Yassine*/
			   sscanf(ligne,"%lf %lf %lf %lf %lf %lf %lf %lf %lf %lf",
               &ra,&dec,&jd,&codecam,&codefiltre,&maginst,&exposure,&airmass,&dmag,&flagsext);
               /* fin*/
			   if (htm_level<0) {
				   strcpy(htm,htm_only);
			   } else {
				   yd_radec2htm(ra*dr,dec*dr,htm_level,htm);
			   }
               /* === fichier (generic)_htm.bin === */
               sprintf(filename_out,"%s%s_%s.bin",path,generic_filename_out,htm);
               gofile=0;
               if (htm_onlyflag==0) {
                  gofile=1;
               } else if (strcmp(htm_only,htm)==0) {
                  gofile=1;
               }
               if (gofile==1) {
                  f_out=fopen(filename_out,"ab");
                  if (f_out==NULL) {
                     sprintf(s,"filename_out %s not found",filename_out);
                     Tcl_SetResult(interp,s,TCL_VOLATILE);
                     fclose(f_in);
                     return TCL_ERROR;
                  }
                  htmfile.ra=(double)ra;
                  htmfile.dec=(double)dec;
                  htmfile.jd=(double)jd;
                  htmfile.codecam=(unsigned char)codecam;
                  htmfile.codefiltre=(unsigned char)codefiltre;
                  htmfile.maginst=(float)maginst;
                  htmfile.exposure=(float)exposure;
                  htmfile.airmass=(float)airmass;
				  /*rajout Yassine*/
				  htmfile.dmag=(float)dmag;
				  htmfile.flag=(unsigned char)flagsext;
				  /*fin*/
                  fwrite(&htmfile,1,sizeof(struct_htmfile),f_out);
                  fclose(f_out);
                  n++;
               }
            }
         }
      } while (feof(f_in)==0) ;
      fclose(f_in);
   }
   return TCL_OK;
}

int Cmd_ydtcl_bugbias(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Ajoute le mot cle END a la fin de l'entete FITS d'images mal ecrites     */
/****************************************************************************/
/****************************************************************************/
{
   int result;
   char s[100];
   char ligne[2000],filename_in[1024],filename_out[1024];
   FILE *f_in,*f_out;
   int sortie,n;
   unsigned char c;

   if(argc<3) {
      sprintf(s,"Usage: %s filename_in filename_out", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      strcpy(filename_in,argv[1]);
      strcpy(filename_out,argv[2]);
      f_in=fopen(filename_in,"rb");
      if (f_in==NULL) {
         sprintf(s,"filename_in %s not found",filename_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      f_out=fopen(filename_out,"wb");
      if (f_out==NULL) {
         sprintf(s,"filename_out %s cannot be created",filename_out);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         fclose(f_in);
         return TCL_ERROR;
      }
      result = TCL_OK;
      sortie=0;
      while (sortie==0) {
         n=fread(ligne,sizeof(char),80,f_in);
         if (n<80) {
            break;
         }
         if (ligne[0]==' ') {
            ligne[0]='E';
            ligne[1]='N';
            ligne[2]='D';
            sortie=1;
         }
         fwrite(ligne,sizeof(char),80,f_out);
      }
      sortie=0;
      while (sortie==0) {
         n=fread(&c,sizeof(unsigned char),1,f_in);
         if (n<1) {
            break;
         }
         fwrite(&c,sizeof(unsigned char),1,f_out);
      }
      fclose(f_in);
      fclose(f_out);
      Tcl_SetResult(interp,"",TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_ydtcl_radec2htm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le code Hierarchical Triangle Mesh.                             */
/****************************************************************************/
/*
load libyd ; yd_radec2htm 12 45 4
*/
/****************************************************************************/
{
   int result,retour;
   char s[100];
   double dr;
   double ra,dec;
   int niter;
   char htm[80];

   if(argc<4) {
      sprintf(s,"Usage: %s ra dec niter", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      dr=4*atan(1.)/180.;
      memset(htm,'\0',80*sizeof(char));
      /* --- decode les parametres obligatoires ---*/
      retour = Tcl_GetDouble(interp,argv[1],&ra);
      if(retour!=TCL_OK) return retour;
      ra*=dr;
      retour = Tcl_GetDouble(interp,argv[2],&dec);
      if(retour!=TCL_OK) return retour;
      dec*=dr;
      retour = Tcl_GetInt(interp,argv[3],&niter);
      if(retour!=TCL_OK) return retour;
      if (niter>25) {niter=25;}
      yd_radec2htm(ra,dec,niter,htm);
      Tcl_SetResult(interp,htm,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_ydtcl_htm2radec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le ra,dec a partir du code Hierarchical Triangle Mesh.                             */
/****************************************************************************/
/*
load libyd ; yd_htm2radec N120321
*/
/****************************************************************************/
{
   int result;
   char s[1000];
   double dr;
   double ra,dec;
   double ra0,dec0;
   double ra1,dec1;
   double ra2,dec2;
   int niter;
   char htm[80];

   if(argc<2) {
      sprintf(s,"Usage: %s htm", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      dr=4*atan(1.)/180.;
      /* --- decode les parametres obligatoires ---*/
      strcpy(htm,argv[1]);
      yd_htm2radec(htm,&ra,&dec,&niter,&ra0,&dec0,&ra1,&dec1,&ra2,&dec2);
      sprintf(s,"%12f %12f %d %12f %12f %12f %12f %12f %12f ",ra/dr,dec/dr,niter,ra0/dr,dec0/dr,ra1/dr,dec1/dr,ra2/dr,dec2/dr);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_OK;
   }
   return result;
}

int Cmd_ydtcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le jour julien a partir des la date en clair.                   */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   double y=0.,m=0.,d=0.,hh=0.,mm=0.,ss=0.,jd=0.;

   if(argc<4) {
      sprintf(s,"Usage: %s year month day ?hour min sec?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/
      retour = Tcl_GetDouble(interp,argv[1],&y);
      if(retour!=TCL_OK) return retour;
      retour = Tcl_GetDouble(interp,argv[2],&m);
      if(retour!=TCL_OK) return retour;
      retour = Tcl_GetDouble(interp,argv[3],&d);
      if(retour!=TCL_OK) return retour;
      /* --- decode les parametres facultatifs ---*/
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&hh);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&mm);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=7) {
         retour = Tcl_GetDouble(interp,argv[6],&ss);
         if(retour!=TCL_OK) return retour;
      }
      /* --- le type DString (dynamic string) est une fonction de */
      /* --- l'interpreteur Tcl. Elle est tres utile pour remplir */
      /* --- une chaine de caracteres dont on ne connait pas longueur */
      /* --- a l'avance. On s'en sert ici pour stocker le resultat */
      /* --- qui sera retourne. */
      Tcl_DStringInit(&dsptr);
      /* --- calcule le jour julien ---*/
      yd_date2jd(y,m,d,hh,mm,ss,&jd);
      /* --- met en forme le resultat dans une chaine de caracteres ---*/
      sprintf(s,"%f",jd);
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
      /* --- retourne le code de succes a l'interpreteur Tcl */
      result = TCL_OK;
   }
   return result;
}

int Cmd_ydtcl_addcol(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Ajoute n colonnes de fond de ciel a partir de la ligne m                 */
/*
load libyd
yd_addcol 1 4 1034
*/
/****************************************************************************/
{
   int result;
   Tcl_DString dsptr;
   char s[100];
   yd_image image;
   int numbuf,ncols,begcol,col,lig;
   float value;
   double valuedeb,valuefin;
   int coldeb,colfin;

   if(argc<4) {
      sprintf(s,"Usage: %s numbuf ncols begcol", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      /* --- decode le parametre obligatoire ---*/
      numbuf=(int)atoi(argv[1]);
      ncols=(int)atoi(argv[2]);
      begcol=(int)atoi(argv[3])-1;
      /*value=(float)atof(argv[4]);*/
      /*--- initialise la dynamic string ---*/
      Tcl_DStringInit(&dsptr);
      /* --- recherche les infos ---*/
      result=ydtcl_getinfoimage(interp,numbuf,&image);
      for (col=image.naxis1-1;col>begcol;col--) {
         if (col<0) break;
         if ((col-ncols)<0) break;
         if (col>(begcol+ncols)) {
            for (lig=0;lig<image.naxis2;lig++) {
               image.ptr_audela[lig*image.naxis1+col]=image.ptr_audela[lig*image.naxis1+col-ncols];
            }
         } else {
            for (lig=0;lig<image.naxis2;lig++) {
               coldeb=begcol;
               colfin=begcol+ncols+1;
               valuedeb=image.ptr_audela[lig*image.naxis1+coldeb];
               valuefin=image.ptr_audela[lig*image.naxis1+colfin];
               value=(float)valuedeb+(float)(valuefin-valuedeb)*(float)(col-coldeb)/(float)(colfin-coldeb);
               image.ptr_audela[lig*image.naxis1+col]=value;
            }
         }
      }
      strcpy(s,"");
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
   }
   return result;

}

int Cmd_ydtcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   yd_image image;
   int numbuf;

   if(argc<2) {
      sprintf(s,"Usage: %s numbuf", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      result = TCL_OK;
      /* --- decode le parametre obligatoire ---*/
      retour = Tcl_GetInt(interp,argv[1],&numbuf);
      if(retour!=TCL_OK) return retour;
      /*--- initialise la dynamic string ---*/
      Tcl_DStringInit(&dsptr);
      /* --- recherche les infos ---*/
      result=ydtcl_getinfoimage(interp,numbuf,&image);
      /* --- met en forme le resultat dans une chaine de caracteres ---*/
      sprintf(s,"%p %d %d %s",image.ptr_audela,image.naxis1,image.naxis2,image.dateobs);
      /* --- on ajoute cette chaine a la dynamic string ---*/
      Tcl_DStringAppend(&dsptr,s,-1);
      /* --- a la fin, on envoie le contenu de la dynamic string dans */
      /* --- le Result qui sera retourne a l'utilisateur. */
      Tcl_DStringResult(interp,&dsptr);
      /* --- desaloue la dynamic string. */
      Tcl_DStringFree(&dsptr);
   }
   return result;
}

int ydtcl_getinfoimage(Tcl_Interp *interp,int numbuf, yd_image *image)
/****************************************************************************/
/* Retourne les infos d'une image presente dans le buffer numero numbuf     */
/* de AudeLA                                                                */
/****************************************************************************/
/* Note : ce type de fonction utilitaire est indispensable dans une         */
/* extension pour AudeLA.                                                   */
/****************************************************************************/
{
   char keyname[10],s[50],lignetcl[50],value_char[100];
   int ptr,datatype;

   strcpy(lignetcl,"lindex [buf%d getkwd %s] 1");
   image->naxis1=0;
   image->naxis2=0;
   strcpy(image->dateobs,"");
   /* -- recherche l'adresse du pointeur de l'image --*/
   sprintf(s,"buf%d pointer",numbuf);
   Tcl_Eval(interp,s);
   Tcl_GetInt(interp,Tcl_GetStringResult(interp),&ptr);
   image->ptr_audela=(float*)ptr;
   if (image->ptr_audela==NULL) {
      return(TCL_OK);
   }
   /* -- recherche le mot cle NAXIS1 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS1");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      image->naxis1=0;
   } else {
      image->naxis1=atoi(value_char);
   }
   /* -- recherche le mot cle NAXIS2 dans l'entete FITS --*/
   strcpy(keyname,"NAXIS2");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      image->naxis2=0;
   } else {
      image->naxis2=atoi(value_char);
   }
   /* -- recherche le mot cle DATE-OBS dans l'entete FITS --*/
   strcpy(keyname,"DATE-OBS");
   sprintf(s,lignetcl,numbuf,keyname);Tcl_Eval(interp,s);strcpy(value_char,Tcl_GetStringResult(interp));if (strcmp(value_char,"")==0) {datatype=0;} else {datatype=1;}
   if (datatype==0) {
      strcpy(image->dateobs,"");
   } else {
      strcpy(image->dateobs,value_char);
   }
   return(TCL_OK);
}

int Cmd_ydtcl_refzmgmes2vars_stetson(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* genere les fichiers des etoiles variables                                */
/* a partir des trois fichiers htm_ref.bin, htm_zmg.bin, htm_mes.bin        */
/****************************************************************************/
/****************************************************************************/
{
	char s[100];
	char path[1024];
	char filename_in[1024],generic_filename[1024],filename_out[1024];
	struct_htmmes  htmmes,*htmmess=NULL;
	struct_htmref  htmref;
	double *val=NULL,*erreurs=NULL,*ras=NULL,*decs=NULL,*deltas=NULL;
	int *ind_ref=NULL,*ind_mes=NULL,*codes2=NULL;
	int kmes,kmes_deb,kmes_deb2,kmes_end,n_mes,kcam,kkcam,kfil,n_ref,kref,n_ref0,kzmg,n_zmg;
	int k,kk,k1,k2,n,n_val,n_groupe,kgroupe_deb,kgroupe_end,nmes_filtre,kfaux,kgood;
	unsigned char ukcam,ukfil;
	FILE *f_in,*f_out;
/*FILE *ff;*/
	int codes[256];
	float moy_filtre[256];
	float mean;
	double ra,dec,somme_delta,somme_carr_delta,jd_deb,P_delta,abs_P,sign_P,eps,somme_poids,poids_unique,w,J,K,L;
	int minobs,nmes_ts_filtre,rien,config;
	double delta_temps,coef1,coef2,coef3,moyenne_totale,Lseuil,mag_bright,L_bright,barerreur; 
	char observatory_symbol[50],ListKeyValues[1024];
	int nl,kl,nvar=0;
	Tcl_DString dsptr;
/*int kvar;
double Lvar=0.,Meanvar=0.,Lseuilvar=0.;
ff=fopen("resultat.txt","wt");*/
/*
#define DEBUG_refzmgmes2vars
*/
#if defined DEBUG_refzmgmes2vars
FILE *f;
#endif
	if(argc<4) {
		sprintf(s,"Usage: %s path generic_filename config ?observatory_symbol? ?ListKeyValues?", argv[0]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
	} else {
		/* --- decodage des arguments ---*/
		strcpy(path,argv[1]);
		strcpy(generic_filename,argv[2]);
		config=atoi(argv[3]);
		if ((config!=0)&&(config!=1)) {
			sprintf(s,"Usage: config = %s must be 0 or 1", argv[3]);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		} 
		strcpy(observatory_symbol,"TN");
		if (argc>=5) {
			strcpy(observatory_symbol,argv[4]);
		}
		strcpy(ListKeyValues,"{TAROT CALERN}");
		if (argc>=6) {
			strcpy(ListKeyValues,argv[5]);
		}
/*
ff=fopen("c:/d/a/resultat.txt","wt");
fprintf(ff,"%s | %s | %s | %s\n",path,generic_filename,observatory_symbol,ListKeyValues);
fclose(ff);		
*/
/*kvar=atoi(argv[4]);*/
		eps=0.0001;
		poids_unique=0.5; /*le poids des mesures non appariees*/
		/*Le seuil de variabilité L = coef3*(coef1*<mag>+coef2) */
		coef1=1.2;
		coef2=-14.6;
		/* configuration GRB : tres peu d images, il faut baisser le seuil de detection*/
		delta_temps=10./1440; /*10mn*/
		minobs=29;
		coef3=1;
		if (config) {
			coef3=1;
			delta_temps=10./60/1440; /*10s*/
			minobs=2;
		}
		mag_bright=13.;
		L_bright=1.;
		barerreur=0.05;
		/* --- init des tableaux ---*/
		for (kcam=0;kcam<256;kcam++) {
			codes[kcam]=0;
		}
#if defined DEBUG_refzmgmes2vars
f=fopen("toto.txt","wt");
fprintf(f,"On entre dans Cmd_ydtcl_refzmgmes2vars\n");
fclose(f);
#endif
      /* --- compte le nombre d'entrees dans HTM_mes.bin  ---*/
		sprintf(filename_in,"%s%s_mes.bin",path,generic_filename);
		f_in=fopen(filename_in,"rb");
		if (f_in==NULL) {
			sprintf(s,"filename_in %s not found",filename_in);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		n_mes=0;
		/*n_zmg=0;*/
		while (feof(f_in)==0) {
			if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
				codes[(int)htmmes.codecam]++;
				n_mes++;
				/*if (htmmes.indexzmg>n_zmg) {
					n_zmg=htmmes.indexzmg;
				} : voir plus bas*/
			}
		}
		n_ref=htmmes.indexref+1;
		/*n_zmg+=1;*/
		fclose(f_in);
		if (n_mes==0) {
			return TCL_OK;
		}
		/*Je construis un 2eme tableau codes2 pour les filtres (pour les cam utilisees seulement*/
		kkcam=0;
		for(k=0;k<256;k++) {
			if(codes[k]>minobs) {
				codes[k]=kkcam;
				kkcam++;
			} else {
				codes[k]=-1;
			}
		}
		kkcam*=256;
		codes2=(int*)calloc(kkcam,sizeof(int));
		if (codes2==NULL) {
			sprintf(s,"error : codes2 pointer out of memory (%d elements)",kkcam);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}

		/* --- alloue la memoire pour htmmess---*/
		/* Je rajoute un element a la fin*/
		htmmess=(struct_htmmes*)malloc(n_mes*sizeof(struct_htmmes));
		if (htmmess==NULL) {
			sprintf(s,"error : htmmess pointer out of memory (%d elements)",n_mes);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			return TCL_ERROR;
		}
		/* --- on dimensionne la matrice x=indexref y=indexjd val=kmes */
		/*     ce tableau est utile pour circuler rapidement dans htmmess */
		n=2*n_ref;
		ind_mes=(int*)calloc(n,sizeof(int));
		if (ind_mes==NULL) {
			sprintf(s,"error : ind_mes pointer out of memory (%d elements)",n);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			return TCL_ERROR;
		}
		/* --- lecture des donnees pour htmmess ---*/
		f_in=fopen(filename_in,"rb");
		if (f_in==NULL) {
			sprintf(s,"filename_in %s not found",filename_in);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			return TCL_ERROR;
		}
		k=0;
		kmes_deb=0;
		kref=0;
		n_zmg=0;
		while (feof(f_in)==0) {
			if (fread(&htmmes,1,sizeof(struct_htmmes),f_in)>1) {
				htmmess[k]=htmmes;
				/*Pour chaque etoile, je repere les indices de la 1ere et la derniere mesures*/
				if(htmmes.indexref!=kref) {
					kmes_end=k-1;
					ind_mes[kref]=kmes_deb;
					ind_mes[kref+n_ref]=kmes_end;
					kzmg=k-kmes_deb;
					kmes_deb=k;
					kref++;
					if(kzmg>n_zmg) {
						n_zmg=kzmg;
						/*je le fait ici car j'ai trouve des etoiles avec 2 mag pour la meme date (bug de yd_filehtm2refzmgmes)*/
					}
				}
				kcam=(int)htmmes.codecam;
				kkcam=codes[kcam];
				if(kkcam>-1) {
					codes2[kkcam*256+(int)htmmes.codefiltre]++;
				}
				k++;
			}
		}
		fclose(f_in);
		/*Et pour la derniere etoile*/
		kmes_end=k-1;
		ind_mes[kref]=kmes_deb;
		ind_mes[kref+n_ref]=kmes_end;
		/* on met n_zmg++ (je ne sais trop pourquoi*/
		n_zmg++;
		/* --- compte le nombre d'etoiles dans HTM_ref.bin  ---*/
		sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
		f_in=fopen(filename_in,"rb");
		if (f_in==NULL) {
			sprintf(s,"filename_in %s not found",filename_in);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			return TCL_ERROR;
		}
		n_ref0=0;
		while (feof(f_in)==0) {
			if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
				n_ref0++;
			}
		}
		fclose(f_in);
		if (n_ref0==0) {
			free(codes2);
			free(htmmess);
			free(ind_mes);
			return TCL_OK;
		}
		/* --- on dimensionne un vecteur pour les tris ---*/
		n_val=(n_ref>n_zmg)?n_ref:n_zmg;
		n_val=(n_ref0>n_val)?n_ref0:n_val;
      
		val=(double*)malloc(n_val*sizeof(double));
		if (val==NULL) {
			sprintf(s,"error : val pointer out of memory (%d elements)",n_val);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			return TCL_ERROR;
		}
		/*-----Le vecteur des poids pour le calcul du sigma*/
		erreurs=(double*)malloc(n_val*sizeof(double));
		if (erreurs==NULL) {
			sprintf(s,"error : erreurs pointer out of memory (%d elements)",n_val);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			free(val);
			return TCL_ERROR;
		}
		/* --- alloue la memoire ---*/
		ras=(double*)malloc(n_ref0*sizeof(double));
		if (ras==NULL) {
			sprintf(s,"error : ras pointer out of memory (%d elements)",n_ref0);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			free(val);
			free(erreurs);
			return TCL_ERROR;
		}
		decs=(double*)malloc(n_ref0*sizeof(double));
		if (decs==NULL) {
			sprintf(s,"error : decs pointer out of memory (%d elements)",n_ref0);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			free(val);
			free(erreurs);
			free(ras);
			return TCL_ERROR;
		}
		ind_ref=(int*)malloc(n_ref0*sizeof(int));
		if (ind_ref==NULL) {
			sprintf(s,"error : ind_ref pointer out of memory (%d elements)",n_ref0);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			free(val);
			free(erreurs);
			free(ras);
			free(decs);
			return TCL_ERROR;
		}
		/* --- lecture de htms a partir de HTM_ref.bin  ---*/
		sprintf(filename_in,"%s%s_ref.bin",path,generic_filename);
		f_in=fopen(filename_in,"rb");
		if (f_in==NULL) {
			sprintf(s,"filename_in %s not found",filename_in);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			free(val);
			free(erreurs);
			free(ind_ref);
			free(ras);
			free(decs);
			return TCL_ERROR;
		}
		k=0;
		while (feof(f_in)==0) {
			if (fread(&htmref,1,sizeof(struct_htmref),f_in)>1) {
				ras[k]=htmref.ra;
				decs[k]=htmref.dec;
				val[k]=(double)htmref.indexref;
				ind_ref[k]=k;
				k++;
			}
		}
		fclose(f_in);
		yd_util_qsort_double(val,0,n_ref0,ind_ref);
		deltas=(double*)malloc(n_zmg*sizeof(double));
		if (deltas==NULL) {
			sprintf(s,"error : deltas pointer out of memory (%d elements)",n_ref0);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(codes2);
			free(htmmess);
			free(ind_mes);
			free(val);
			free(erreurs);
			free(ind_ref);
			free(ras);
			free(decs);
			return TCL_ERROR;
		}
		/* === grande boucle sur les cam+filtre ===*/
		for (kcam=0;kcam<256;kcam++) {
			ukcam=(unsigned char)kcam;
			kkcam=codes[kcam];
			if (kkcam<0) {
				/* --- Pas assez de mesures faites avec cette camera ---*/
				continue;
			}
			/*on commence la boucle sur les etoiles : cet indice de variabilite
			est independant de la magnitude de letoile*/
			for (kref=0;kref<n_ref;kref++) {
				kmes_deb=ind_mes[kref];
				kmes_end=ind_mes[kref+n_ref];
				/*Ce n est pas la peine de faire les calcul si l etoile possede moins de minobs mesures*/
				if (kmes_end+1-kmes_deb<minobs) {continue;}
				/*nmes_ts_filtre : le nombre de mesures valables dans tous les filtres avec cette camera*/
				nmes_ts_filtre=0;
				moyenne_totale=0;
				/*Je demarre la boucle sur les filtres*/
				for (kfil=0;kfil<256;kfil++) {
					ukfil=(unsigned char)kfil;
					/*if (kfil==67) {
						kfil=67;
					}*/
					if(codes2[kkcam*256+kfil]==0) {continue;}
					nmes_filtre=0;
					/* --- boucle sur les mesures d'une étoile ---*/
					for (kmes=kmes_deb;kmes<=kmes_end;kmes++) {
						if (htmmess[kmes].codecam!=ukcam) {
							continue;
						}
						if (htmmess[kmes].codefiltre!=ukfil) {
							continue;
						}
						if (htmmess[kmes].magcali<-50) {
							continue;
						}
						val[nmes_filtre]=(double)htmmess[kmes].magcali;
						/*erreurs[nmes_filtre]=(double)htmmess[kmes].dmag;*/
						erreurs[nmes_filtre]=barerreur;
						nmes_filtre++;
					}
					if (nmes_filtre==0) {continue;}
					nmes_ts_filtre+=nmes_filtre;
					/* --- moyenne et ecart type ---*/
					rien=yd_util_meansigma_poids_stetson(val,n_val,erreurs,0,nmes_filtre,&mean);
					if(rien) {
						Tcl_SetResult(interp,"Erreur d'allocation dans yd_util_meansigma_poids_stetson",TCL_VOLATILE);
						free(codes2);
						free(htmmess);
						free(ind_mes);
						free(val);
						free(erreurs);
						free(ind_ref);
						free(ras);
						free(decs);
						free(deltas);
						return TCL_ERROR;
					}
					moy_filtre[kfil]=mean;
					moyenne_totale+=nmes_filtre*mean;
					k=0;
					kk=-1;
					/*dans cette boucle je recupere les deltas*/
					for (kmes=kmes_deb;kmes<=kmes_end;kmes++) {
						kk++;
						/*Attention ici kk demarre de 0 car kdeb vaut 0 dans la fonction yd_util_meansigma_poids_stetson*/
						if (htmmess[kmes].codecam!=ukcam) {
							continue;
						}
						if (htmmess[kmes].codefiltre!=ukfil) {
							continue;
						}
						if (htmmess[kmes].magcali<-50) {
							continue;
						}
						deltas[kk]=val[k];
						k++;
					}
				}
				/*verifie si l'etoile possede au moins minobs mesures valables*/
				if (nmes_ts_filtre<minobs) {continue;}
				moyenne_totale/=nmes_ts_filtre;
			 
				/* --- boucle sur les mesures d'une étoile ---*/
				kmes=kmes_deb;
				kmes_deb2=kmes_deb;
				J=0.;
				somme_poids=0.;
				while(kmes<=kmes_end) {
				/*Je trouve kgroupe_deb car il se peut que la 1ere mesure soit a -99.9*/
					kgood=0;
					for (kk=kmes_deb2;kk<=kmes_end;kk++) {
						if (htmmess[kk].codecam!=ukcam) {
							continue;
						}
						if (htmmess[kk].magcali<-50) {
							continue;
						}
						kgood=1;
						break;
					}
					kgroupe_deb=kk;
					if(!kgood) {break;}
					jd_deb=htmmess[kgroupe_deb].jd;
					kfaux=0;
					kmes=kgroupe_deb+1;
					while(kmes<=kmes_end) {
						if (htmmess[kmes].codecam!=ukcam) {
							kfaux++;
						}
						if (htmmess[kmes].magcali<-50) {
							kfaux++;
						}
						if(fabs(htmmess[kmes].jd-jd_deb)>delta_temps) {break;}
						kmes++;
					}
					kmes_deb2=kmes;
					kgroupe_end=kmes-1;
					n_groupe=kgroupe_end-kgroupe_deb+1-kfaux;

					if(n_groupe<=1) {
						w=poids_unique;
						somme_poids+=w;
						P_delta=deltas[kgroupe_deb-kmes_deb];
						P_delta*=P_delta;
						P_delta=P_delta-1;
						abs_P=fabs(P_delta);
						if (P_delta>=0) {
							sign_P=1;
						}else {
							sign_P=-1;
						}
						/*if (abs_P>1000.) {
							abs_P=1000.;
						}*/
						J+=w*sign_P*sqrt(abs_P);
					} else {
						w=2./n_groupe;
						for (k1=kgroupe_deb;k1<kgroupe_end;k1++) {
							if (htmmess[k1].codecam!=ukcam) {
								continue;
							}
							if (htmmess[k1].magcali<-50) {
								continue;
							}
							for (k2=k1+1;k2<=kgroupe_end;k2++) {
								if (htmmess[k2].codecam!=ukcam) {
									continue;
								}
								if (htmmess[k2].magcali<-50) {
									continue;
								}
								somme_poids+=w;
								P_delta=deltas[k1-kmes_deb];
								P_delta*=deltas[k2-kmes_deb];
								abs_P=fabs(P_delta);
								if (P_delta>=0) {
									sign_P=1;
								}else {
									sign_P=-1;
								}
								/*if (abs_P>1000.) {
									abs_P=1000.;
								}*/
								J+=w*sign_P*sqrt(abs_P);
							}
						}
					}
				}
				J=J/somme_poids;
				/* on refait la boucle pour calculer K*/
				somme_delta=0.;
				somme_carr_delta=0.;
				k=0;
				for (kmes=kmes_deb;kmes<=kmes_end;kmes++) {
					if (htmmess[kmes].codecam!=ukcam) {
						continue;
					}
					if (htmmess[kmes].magcali<-50) {
						continue;
					}
					P_delta=deltas[kmes-kmes_deb];
					somme_delta+=fabs(P_delta);
					somme_carr_delta+=P_delta*P_delta;
					k++;
				}
				somme_carr_delta+=0.000000001; /*toujours pour le cas d'une seule mesure*/
				K=somme_delta/sqrt(k*somme_carr_delta);
				/*Et voici alors l'indice de variabilite*/
				L=J*K/0.798;
				if (moyenne_totale<mag_bright) {
					Lseuil=L_bright;
				} else {
                    Lseuil=coef3*(coef1*moyenne_totale+coef2);
				}
/*fprintf(ff,"%4d %10.7f %10.7f\n",kref,K,L);
	if (kref==kvar) {
		Lvar=L;
		Meanvar=moyenne_totale;
		Lseuilvar=Lseuil;
	}*/
				if (L>Lseuil) {
					ra=ras[ind_ref[kref]];
					dec=decs[ind_ref[kref]];
					/*on separe maintenant les mesures selon le filtre*/
					/*le fichier texte sera cree si le nombre de mesures avec ce filtre > minobs*/
					for (kfil=0;kfil<256;kfil++) {
						ukfil=(unsigned char)kfil;
						k=0;
						for (kmes=kmes_deb;kmes<=kmes_end;kmes++) {
							if (htmmess[kmes].codecam!=ukcam) {
								continue;
							}
							if (htmmess[kmes].codefiltre!=ukfil) {
								continue;
							}
							if (htmmess[kmes].magcali<-50) {
								continue;
							}
							k++;
						}
						if (k>minobs) {
							nvar++;
							mean=moy_filtre[kfil];
							sprintf(filename_out,"%s%s-%s-%d-%d-%d.txt",path,observatory_symbol,generic_filename,kref,kfil,kcam);
							f_out=fopen(filename_out,"wt");
							if (f_out==NULL) {
								free(codes2);
								free(htmmess);
								free(ind_mes);
								free(val);
								free(erreurs);
								free(ind_ref);
								free(ras);
								free(decs);
								free(deltas);
							}
							/*             123456789 12345678 */
							fprintf(f_out,"NAME      = %s-%s-%d \n",observatory_symbol,generic_filename,kref);
							fprintf(f_out,"RA        = %10.6f \n",ra);
							fprintf(f_out,"DEC       = %10.6f \n",dec);
							fprintf(f_out,"EQUINOX   = J2000.0 \n");
							fprintf(f_out,"FILTER    = %c \n",ukfil);
							fprintf(f_out,"CAMERANO  = %u \n",ukcam);
							//
							sprintf(s,"llength {%s}",ListKeyValues);
						   Tcl_Eval(interp,s);
							nl=atoi(Tcl_GetStringResult(interp));
							for (kl=0;kl<nl;kl++) {
								sprintf(s,"lindex [lindex {%s} %d] 0",ListKeyValues,kl);
								Tcl_Eval(interp,s);
								strcpy(s,Tcl_GetStringResult(interp));
								if (strcmp(s,"")==0) {
									continue;
								}
								strcat(s,"           ");
								s[9]='\0';
								fprintf(f_out,"%s = ",s);
								sprintf(s,"lindex [lindex {%s} %d] 1",ListKeyValues,kl);
								Tcl_Eval(interp,s);
								strcpy(s,Tcl_GetStringResult(interp));
								fprintf(f_out,"%s\n",s);
							}
							//
							fprintf(f_out,"MEAN      = %f \n",mean);
							fprintf(f_out,"CRITVAR   = %f \n",L);
							fprintf(f_out,"END\n");
							for (kmes=kmes_deb;kmes<=kmes_end;kmes++) {
								if (htmmess[kmes].codecam!=ukcam) {
									continue;
								}
								if (htmmess[kmes].codefiltre!=ukfil) {
									continue;
								}
								if (htmmess[kmes].magcali>-50) {
									htmmes=htmmess[kmes];
									/* --- on imprime les caracteristiques ---*/
									fprintf(f_out,"%15.6f %7.3f %5.3f %3d\n",
									htmmes.jd,htmmes.magcali,htmmes.dmag,htmmes.flag);
								}
							}
							fclose(f_out);
						}
					}
				}
			}
			/*fin de la boucle sur les etoiles*/
		}
		/*fin de la boucle sur les cameras*/
/*fclose(ff);*/
	free(codes2);
	free(htmmess);
	free(ind_mes);
	free(val);
	free(erreurs);
	free(ind_ref);
	free(ras);
	free(decs);
	free(deltas);


/*Tcl_DStringInit(&dsptr);
sprintf(s,"%7.3f",Lvar);
Tcl_DStringAppend(&dsptr,s,-1);
Tcl_DStringAppend(&dsptr," ",-1);
sprintf(s,"%7.3f",Meanvar);
Tcl_DStringAppend(&dsptr,s,-1);
Tcl_DStringAppend(&dsptr," ",-1);
sprintf(s,"%7.3f",Lseuilvar);
Tcl_DStringAppend(&dsptr,s,-1);
Tcl_DStringResult(interp,&dsptr);
Tcl_DStringFree(&dsptr);*/
	}
Tcl_DStringInit(&dsptr);
sprintf(s,"%d",nvar);
Tcl_DStringAppend(&dsptr,s,-1);
Tcl_DStringResult(interp,&dsptr);
Tcl_DStringFree(&dsptr);
	return TCL_OK;
}
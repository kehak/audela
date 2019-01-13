/* mltcl_1.c
 *
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Myrtille LAAS <Myrtille.Laas@oamp.fr>
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
/* sont disponibles dans les fichiers ml_*.c.                              */
/***************************************************************************/
/* Le include mltcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "mltcl.h"
#include <stdio.h>
#include <ctype.h>

//***************************************************************************
//					log 
//***************************************************************************
int WriteDisk(char *Chaine)
{

FILE *F;
char Nom[1000];
time_t ltime;
//SYSTEMTIME St;
char Buffer[300];
struct tm *timeinfo;
	
	printf("\n%s\n",Chaine);
    time( &ltime );
	timeinfo = localtime( &ltime );

    strftime(Buffer,150,"%Y-%m-%dT%H-%M-%S",timeinfo);
	//GetSystemTime(&St);
	//sprintf(Nom,"%lu%.2lu%.2lu-%s",St.wYear,St.wMonth,St.wDay,"log.txt");
	//sprintf(Nom,"%s-log.txt",Buffer);
	sprintf(Nom,"ml_log.txt");
	//sprintf(Buffer,"\n%dh%dm%ds : %s",St.wHour,St.wMinute,St.wSecond,Chaine);
	strcat(Buffer," : ");
	strcat(Buffer,Chaine);
	F = fopen(Nom,"at");
		
	if(F!=NULL)
	{
		fwrite(Buffer,sizeof(char),strlen(Buffer),F);
		fclose(F);
	}
	return 0;
}

int Cmd_mltcl_residutycho2usno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Troncate the USNO-A1 catalog file to a given R magnitude                 */
/****************************************************************************/
/*
load libml ; ml_residutycho2usno "D:/catalogs/usno_coupe" "D:/catalogs/tycho_format_usno"
*/
/****************************************************************************/
{
	char s[100],pathname_usno[200],pathname_tycho[200],zone[5];
	char ligne[1024];
    FILE *catusno,*cattycho,*f1;
	int k,k3,zonename,n,mink2ra,mink2dec;
//	int kk,k1,k2;
//	double zonera, nbusno, nbtycho;
	struct_texte_fichier *accusno,*acctycho;
	int l,raL,deL,magL,raLL,deLL,magLL;
    double ratycho,detycho,mag_red_tycho,mag_bleue_tycho,rausno,decusno,mag_red_usno,mag_bleue_usno;
	double differencera,differencedec,differencemagn1=0.,differencemagn2=0.,diffminra,minra,diffmindec,mindec;
//	long nbdebutusno, nbdebuttycho;
	double minra2=0.,diffra2=0.,mindec2=0.,diffdec2=0.,proche1,proche2;

	if(argc<3) {
		sprintf(s,"Usage: %s pathname_usno  pathname_tycho", argv[0]);
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
		strcpy(pathname_usno,ligne);

		strcpy(ligne,argv[2]);
		n=(int)strlen(ligne);
		if (n==0) {
			return TCL_OK;
		}
		if ((ligne[n-1]!='/')||(ligne[n-1]!='\\')) {
			ligne[n]='/';
			ligne[n+1]='\0';
		}
		strcpy(pathname_tycho,ligne);

		//boucle sur chaque zone
		for (k=9;k<24;k++) {
			zonename=k*75;
			sprintf (zone,"%04d", zonename);
		
			//ouverture des fichiers ACC
			sprintf(ligne,"%sZONE%s.ACC",pathname_tycho,zone);
			if ((f1=fopen(ligne,"rb"))==NULL) {
				sprintf(s,"File %s not found\n",ligne);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}

			while (feof(f1)==0) {
				if (fgets(ligne,sizeof(ligne),f1)!=NULL) {
					n++;
				}
			}
			acctycho=(struct_texte_fichier*)malloc(n*sizeof(struct_texte_fichier));
			if (acctycho==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(acctycho);
				return TCL_ERROR;
			}
			acctycho->nbligne=n+1;
			fclose(f1);
			n=0;
			sprintf(ligne,"%sZONE%s.ACC",pathname_tycho,zone);
			if ((f1=fopen(ligne,"rb"))==NULL) {
				sprintf(s,"File %s not found\n",ligne);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}

			while (feof(f1)==0) {
				if (fgets(ligne,sizeof(ligne),f1)!=NULL) {
					strcpy(acctycho[n].texte,ligne);
					n++;
				}
			}
			fclose(f1);
			n=0;

			sprintf(ligne,"%sZONE%s.ACC",pathname_usno,zone);
			if ((f1=fopen(ligne,"rb"))==NULL) {
				sprintf(s,"File %s not found\n",ligne);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}

			while (feof(f1)==0) {
				if (fgets(ligne,sizeof(ligne),f1)!=NULL) {
					n++;
				}
			}
			accusno=(struct_texte_fichier*)malloc(n*sizeof(struct_texte_fichier));
			if (accusno==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(accusno);
				return TCL_ERROR;
			}
			accusno->nbligne=n+1;
			fclose(f1);
			n=0;
			sprintf(ligne,"%sZONE%s.ACC",pathname_usno,zone);
			if ((f1=fopen(ligne,"rb"))==NULL) {
				sprintf(s,"File %s not found\n",ligne);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}

			while (feof(f1)==0) {
				if (fgets(ligne,sizeof(ligne),f1)!=NULL) {
					strcpy(accusno[n].texte,ligne);
					n++;
				}
			}
			fclose(f1);
			n=0;
		
			 
			//boucle sur chaque zone RA du fichier acc
			//for (k1=0;k1<97;k1++) {
				//zonera=k1*0.25;
				
				/* -- opens the CAT files ---*/
				sprintf(ligne,"%sZONE%s.CAT",pathname_tycho,zone);
				if ((cattycho=fopen(ligne,"rb"))==NULL) {
					sprintf(s,"File %s cannot be created\n",ligne);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					fclose(cattycho);
					return TCL_ERROR;
				}
				
				 while (feof(cattycho)==0) {
				//for (k2=(int)nbdebuttycho-1;k2<(int)nbdebuttycho+(int)nbtycho;k2++) {
					if (feof(cattycho)!=0) {continue;}
					if (fread(&raL,1,4,cattycho)!=4) continue;
					if (fread(&deL,1,4,cattycho)!=4) continue;
					if (fread(&magL,1,4,cattycho)!=4) continue;
					l=raL;
					raLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
					l=deL;
					deLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
					l=magL;
					magLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
					ratycho=(double)raLL/360000.0;
					detycho=(double)deLL/360000.0-90.0;
					mag_red_tycho=ml_GetUsnoRedMagnitude(magLL);
					mag_bleue_tycho=ml_GetUsnoBleueMagnitude(magLL);
					k3=0;

					sprintf(ligne,"%sZONE%s.CAT",pathname_usno,zone);
					if ((catusno=fopen(ligne,"rb"))==NULL) {
						sprintf(s,"File %s not found\n",ligne);
						Tcl_SetResult(interp,s,TCL_VOLATILE);
						fclose(catusno);
						return TCL_ERROR;
					}

					//init variables
					//fseek(catusno,(12)*(nbdebutusno-1),0);

					diffminra = diffmindec =0.02;
					minra=mindec=0.00;
					mink2ra=mink2dec=0;

					while (feof(catusno)==0) {
					//for (k3=(int)nbdebutusno-1;k3<(int)nbdebutusno+(int)nbusno;k3++) {
						if (feof(catusno)!=0) {continue;}
						if (fread(&raL,1,4,catusno)!=4) continue;
						if (fread(&deL,1,4,catusno)!=4) continue;
						if (fread(&magL,1,4,catusno)!=4) continue;
						l=raL;
						raLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
						l=deL;
						deLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
						l=magL;
						magLL= (l << 24) | ((l << 8) & 0x00FF0000) | ((l >> 8) & 0x0000FF00) | ((l >> 24) & 0x000000FF);
						rausno=(double)raLL/360000.0;
						decusno=(double)deLL/360000.0-90.0;
						mag_red_usno=ml_GetUsnoRedMagnitude(magLL);
						mag_bleue_usno=ml_GetUsnoBleueMagnitude(magLL);

						//recherche étoile la plus proche
						differencera = fabs(rausno-ratycho);
						differencedec = fabs(decusno-detycho);
						
						if (rausno-ratycho>0.5) {break;}

						if (differencera<diffminra) {
							diffminra=differencera;
							minra=rausno,
							mink2ra=k3;
							mindec2=decusno;
							diffdec2=differencedec;
							differencemagn1 = fabs(mag_bleue_tycho-mag_bleue_usno);
						}

						if (differencedec<diffmindec) {
							diffmindec=differencedec;
							mindec=decusno,
							mink2dec=k3;
							minra2=rausno;
							diffra2=differencera;
							differencemagn2 = fabs(mag_bleue_tycho-mag_bleue_usno);
						}
						
						k3++;

					}
					fclose(catusno);
					
				//	if ((mink2ra==mink2dec)&&(mink2dec==mink2magn)) {
					if ((mink2ra==mink2dec)&&(diffminra<0.00028)&&(diffmindec<0.00028)) {
						//il n'y a pas d'ambiguïté sur l'étoile
						sprintf(ligne,"%sdiffZONE%s.acc",pathname_usno,zone);
						f1=fopen(ligne,"a");
						if (f1==NULL) {
							sprintf(s,"file_0 %s not created",argv[2]);
							Tcl_SetResult(interp,s,TCL_VOLATILE);
							fclose(f1);
							return TCL_ERROR;
						}
						fprintf(f1,"%15.10f %15.10f 		%15.10f %15.10f %15.10f %15.10f %15.10f		%d	%d\n",diffminra,diffmindec,minra,mindec,ratycho,detycho, differencemagn1,mink2ra,mink2dec);
						fclose(f1);
		
					} else {
						//les étoiles les plus proches
						proche1=sqrt(diffminra*diffminra+diffdec2*diffdec2);
						proche2=sqrt(diffmindec*diffmindec+diffra2*diffra2);
						if ((proche1<proche2)&&(proche1<0.0004)&&(diffminra<0.00028)&&(diffdec2<0.00028)) {
							sprintf(ligne,"%sdiffZONE%s.acc",pathname_usno,zone);
							f1=fopen(ligne,"a");
							if (f1==NULL) {
								sprintf(s,"file_0 %s not created",argv[2]);
								Tcl_SetResult(interp,s,TCL_VOLATILE);
								fclose(f1);
								return TCL_ERROR;
							}
							fprintf(f1,"%15.10f %15.10f 		%15.10f %15.10f %15.10f %15.10f %15.10f		%d	%d\n",diffminra,diffdec2,minra,mindec2,ratycho,detycho,differencemagn1,mink2ra,mink2dec);
							fclose(f1);
						} else if  ((proche2<proche1)&&(proche2<0.0004)&&(diffra2<0.00028)&&(diffmindec<0.00028)) {
							sprintf(ligne,"%sdiffZONE%s.acc",pathname_usno,zone);
							f1=fopen(ligne,"a");
							if (f1==NULL) {
								sprintf(s,"file_0 %s not created",argv[2]);
								Tcl_SetResult(interp,s,TCL_VOLATILE);
								fclose(f1);
								return TCL_ERROR;
							}
							fprintf(f1,"%15.10f %15.10f 		%15.10f %15.10f %15.10f %15.10f %15.10f		%d	%d\n",diffra2,diffmindec,minra2,mindec,ratycho,detycho,differencemagn2,mink2ra,mink2dec);
							fclose(f1);
						}
					}	
				}
				fclose(cattycho);
			//}			
		}
	}
	return 0;
}


int Cmd_mltcl_geostatident(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Identification des satellites en comparant les coordonnees               */
/****************************************************************************/
/****************************************************************************/
/* pour tester dans Audace:*/
/* ml_geostatident "C:/Program Files/Apache Group/Apache2/htdocs/ros/geostat/bdd0_20060927.txt"
"C:/Program Files/Apache Group/Apache2/htdocs/ros/geostat/bdd_20060927.txt" */

{
	int result,retour,n_in,n_in1,kimage,nimages,kimage2,nimages2,k,k1,k2,k3,k4,date,temp,nsat;
	int kmin,kmini,pareil;	
	int code;
	double distmin,ra0,dec0, ra,dec,dist,angl,anglmin;
	char s[ML_STAT_LIG_MAX],ligne[2700],home[35],im[70],lign[2700],valid[4]; //,toto[1000]
	char pathGeo[1000],pathTle2[1000],pathHttp[1000],pathUrl[1000],file_0[1000],file_ident[1000];
	char satelname[30],noradname[30],cosparname[30]; //chaine [ML_STAT_LIG_MAX];	
	FILE *f_in1, *f_in2;	
	struct_ligsat *lignes,*lignes2;
	char *list, *distang;
	Tcl_Obj *list2, *list3;
	int argcc,argc2;
	char **argvv,**argv2;
	
	//int problemetelechargement,diffjour;
	//char lpszWrite[20],tempspc[20],lpszCreate[20];
	//FILETIME ftCreate, ftAccess, ftWrite;
	//SYSTEMTIME stUTC, stCreateLocal,stWriteLocal;
	//SYSTEMTIME St;
	//HANDLE hFile ;

	if(argc<3) {
      sprintf(s,"Usage: %s file_0 file_ident ?path_geo? ?path_http? ?url?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	}  else {
		/* --- decode les parametres obligatoires ---*/
		strcpy (file_0,argv[1]);
		strcpy (file_ident,argv[2]);
		/* --- decode les parametres facultatifs ---*/
		if(argc <= 3) {
			strcpy (pathGeo,".");
		} else {
			strcpy (pathGeo,argv[3]);
		}
		if(argc <= 4) {
			strcpy (pathHttp,"c:/Program Files/Apache Group/Apache2/htdocs/ros");
		} else {
			strcpy (pathHttp,argv[4]);
		}
		if(argc <= 5) {
			strcpy (pathUrl,"celestrak.com/NORAD/elements/geo.txt");
		} else {
			strcpy (pathUrl,argv[5]);
		}
		if (strcmp(pathGeo,".")==0) {
#if defined(LIBRARY_DLL)
			GetCurrentDirectory (400,pathGeo);
			GetCurrentDirectory (400,pathTle2);
#endif
#if defined(LIBRARY_SO)
			getcwd(pathGeo,400);
			getcwd(pathTle2,400);
#endif		
		}
		strcat(pathGeo,"/geo.txt");
		strcpy(pathTle2,"./tle2.txt");
		strcat(pathHttp,"/tle.txt");

		//problemetelechargement=0;
		/* récupère la date et heure des modifs du fichier */
		//hFile = CreateFile(argv[3],0,FILE_SHARE_READ | FILE_SHARE_WRITE,NULL,OPEN_EXISTING,0,NULL);
		//retour = GetFileTime(hFile, &ftCreate, &ftAccess, &ftWrite);

		/* Converti le temps de creation en temps local */
		//FileTimeToSystemTime(&ftCreate, &stUTC);
		//SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stCreateLocal);

		/* Converti le temps dern.modif en temps local. */
		//FileTimeToSystemTime(&ftWrite, &stUTC);
		//SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stWriteLocal);

		//wsprintf(lpszCreate, TEXT("%02d/%02d/%d %02d:%02d"),
		//stCreateLocal.wMonth, stCreateLocal.wDay, stCreateLocal.wYear,
        //stCreateLocal.wHour, stCreateLocal.wMinute);

		//wsprintf(lpszWrite, TEXT("%02d/%02d/%d %02d:%02d"),
        //stWriteLocal.wMonth, stWriteLocal.wDay, stWriteLocal.wYear,
        //stWriteLocal.wHour, stWriteLocal.wMinute);

		//GetLocalTime(&St);
		//wsprintf(tempspc, TEXT("%02d/%02d/%d %02d:%02d"),
		//St.wMonth, St.wDay, St.wYear,
        //St.wHour, St.wMinute);

		/* --- vérifie si le fichier est vieux d'un jour, si oui il y a un pb lors du telechargement --- */
		//diffjour = ml_differencejour(stWriteLocal.wDay,stWriteLocal.wMonth,stWriteLocal.wYear,St.wDay,St.wMonth,St.wYear);
		//if ( diffjour>1 ){
		//	problemetelechargement = 1;
		//}

		/* === on fabrique un fichier pathTle2 = pathGeo derriere lequel on ajoute les TLE personels pathHttp === */
		f_in1=fopen(pathGeo,"r");
		if (f_in1==NULL) {
			sprintf(s,"file %s not found, pas de fichier geo",pathGeo);
			WriteDisk("pas de fichier geo.txt");
			WriteDisk(pathGeo);
		}
		ml_file_copy (pathGeo,pathTle2);
		//WriteDisk("fichier tle2");		
		fclose(f_in1);

		f_in1=fopen(pathHttp,"r");
		if (f_in1==NULL) {
			/* --- pas fichier TLE perso ---*/
			sprintf(s,"file %s not found, pas de fichier tle",pathHttp);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
		} else {
			n_in1=0;
			/* --- compteur de lignes du fichier TLE perso ---*/
			while (feof(f_in1)==0) {
				if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					n_in1++;
				}
			}
			fclose(f_in1);
			if (n_in1!=0) {
				/* --- dimensionne la structure des donnees d'entree ---*/
				lignes=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
				if (lignes==NULL) {
					sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					free(lignes);
					return TCL_ERROR;
				}
				f_in1=fopen(pathHttp,"r");
				if (f_in1==NULL) {
					sprintf(s,"file %s not found, pas de fichier tle perso",pathHttp);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				}
				n_in = 0;
				while (feof(f_in1)==0) {
					if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
						strcpy(lignes[n_in].texte,ligne);
						n_in++;
					}
				}
				/* on ajoute les lignes de tle perso a la suite */
				f_in2=fopen(pathTle2,"a+");
				if (f_in2==NULL) {
					strcpy(s,"file pathTle2 not found");
				} else {
					for (k=0;k<n_in;k++) {
						fprintf(f_in2,"%s",lignes[k].texte);
					}
				}
				fclose(f_in1);
				fclose(f_in2);
				free(lignes);
			}
		}

		/* est-ce que le fichier bdd exist?*/
		f_in1=fopen(file_ident,"r");
		if (f_in1==NULL) {
			/* le fichier bdd n'existe pas */
			//WriteDisk("pas de fichier bdd");
			f_in2=fopen(file_0,"r");
			if (f_in2==NULL) {
				sprintf(s,"FILE: %s DOESN'T EXIST", file_0);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				result = TCL_ERROR;
			} else {
			retour = ml_file_copy (file_0,file_ident);
			fclose(f_in2);
			}
		} else {
			/* le fichier bdd existe deja */
			//WriteDisk("fichier bdd existe deja");
			/* comme on ne recopie pas le fichier, on va chercher les lignes différentes pour compléter le fichier de sortie */
			fclose(f_in1);
			/* --- dimensionne la structure des donnees d'entree ---*/
			n_in=0;
			/* dimensionne *lignes pour lire le fichier bdd0 */
			f_in1=fopen(file_0,"rt");
			if (f_in1==NULL) {
				sprintf(s,"file_0 %s not found",file_0);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			while (feof(f_in1)==0) {
				if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					n_in++;
				}
			}
			lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
			if (lignes==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			fclose(f_in1);
			/* dimensionne *lignes2 pour lire le fichier bdd */
			n_in1=0;
			f_in2=fopen(file_ident,"rt");
			if (f_in2==NULL) {
				sprintf(s,"file_ident %s not found",file_ident);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			while (feof(f_in2)==0) {
				if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
					n_in1++;
				}
			}
			lignes2=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
			if (lignes2==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			fclose(f_in2);

			/* Lecture de *lignes a partir du fichier bdd0 */
			n_in=0;
			date=0;
			kimage=0;
			k=0;
			f_in1=fopen(file_0,"rt");
			if (f_in1==NULL) {
				sprintf(s,"file_00 %s not found",file_0);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);
				return TCL_ERROR;
			}
			/* on cherche quand il y a une ligne blanche, correspond a un changement de date */
			//WriteDisk("recherche des lignes blanches");
			while (feof(f_in1)==0) {
				 if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					strcpy(lignes[n_in].texte,ligne);
					lignes[n_in].comment=12;
					lignes[n_in].nouvelledate=-12;
					if (strlen(ligne)>=3) {
						if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
							lignes[n_in].comment=0;
						}
						kimage++;
						if (date == 0) {
							lignes[n_in].nouvelledate=1;
						} else {
							lignes[n_in].nouvelledate=date;
						}

					} else {
						if (n_in <= 2) {
							date=0;
							lignes[n_in].nouvelledate=1;
						} else {
							k++;
							date=k+1;
							lignes[n_in].nouvelledate=k;
						}
					}
					n_in++;
				}
			}
			fclose(f_in1);
			nimages=kimage-2;

			/* Lecture de *lignes2 a partir du fichier bdd */
			kimage2=0;
			k=0;
			n_in1=0;
			f_in2=fopen(file_ident,"rt");
			if (f_in2==NULL) {
				sprintf(s,"file_ident %s not found",file_ident);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);
				return TCL_ERROR;
			}
			while (feof(f_in2)==0) {
				 if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
					strcpy(lignes2[n_in1].texte,ligne);
					lignes2[n_in1].comment=12;
					if (strlen(ligne)>=3) {
						if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
							lignes2[n_in1].comment=0;
						}
						kimage2++;
					}
					n_in1++;
				 }	 
			}
			fclose(f_in2);
			nimages2=kimage2-2;

			//sprintf(chaine,"nombre d'images = %d",nimages2);
			//WriteDisk(chaine);
			/* --- on cherche les lignes qui manquent dans le fichier de sortie --- */
			/*tester*/
			if (nimages2!=nimages) {	
				for (k=0;k<n_in;k++) {
					lignes[k].kimage1 = -12;
					if (lignes[k].comment!=0) {
						lignes[k].kimage1 = 0;
						continue;
					}
					for (k2=0;k2<n_in1;k2++) {
						lignes2[k2].kimage1 = -12;
						if (lignes2[k2].comment!=0) {
							continue;
						}
						if (lignes2[k2].kimage1 == 0) {
							continue;
						}
						pareil=0;
						for (k1=0; k1<140;k1++) {
							if (lignes2[k2].texte [k1] == lignes[k].texte [k1]) {
								pareil++;
							} else {
								break;
							}
							if (pareil>=120) {
								lignes[k].kimage1 = 0;
								lignes2[k2].kimage1 = 0;
								break;
							}
						}
						if (lignes[k].kimage1 == 0) {
							break;
						}
					}
				}
				/* --- on sauve le resultat dans le fichier de sortie ---*/
				f_in1=fopen(file_ident,"a+");
				if (f_in1==NULL) {
					sprintf(s,"file_ident %s not created",file_ident);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					free(lignes);
					free(lignes2);
					return TCL_ERROR;
				}
				temp=0;
				for (k=0;k<n_in;k++) {
					if (lignes[k].kimage1 != 0) {
						/* on a une nouvelle ligne*/
						/*il faut copier lignes[k1].ligne dans lignes[nimages2+1]*/
						if (temp == 0) {
								fprintf(f_in1,"\n%s",lignes[k].texte);
						} else {

							if ((lignes[k].nouvelledate != lignes[temp].nouvelledate)&&(temp!=0)) {
								fprintf(f_in1,"\n%s",lignes[k].texte);
							} else {
								fprintf(f_in1,"%s",lignes[k].texte);
							}
						}
						temp=k;
					}
				}
				fclose(f_in1);	
			}
			free(lignes);
			free(lignes2);
		}

		f_in2=fopen(file_ident,"rt");
		//WriteDisk(argv[2]);
		if (f_in2==NULL) {
			sprintf(s,"file_ident %s not found",file_ident);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		n_in1=0;
		while (feof(f_in2)==0) {
			if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
				n_in1++;
			}
		}
		fclose(f_in2);
		/* --- on recupère les données actuelles du fichier de sortie ---*/
		lignes2=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
		if (lignes2==NULL) {
			sprintf(s,"error : lignes2 pointer out of memory (%d elements)",n_in1);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		lignes=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
		if (lignes==NULL) {
			sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(lignes2);
			return TCL_ERROR;
		}
		n_in1=0;
		n_in=0;
		kimage2=0;
		nsat=0;
		strcpy(s,"");
		f_in1=fopen(file_ident,"rt");
		if (f_in1==NULL) {
			sprintf(s,"file_ident %s not found",file_ident);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(lignes);
			free(lignes2);
			return TCL_ERROR;
		}
		//WriteDisk("grande boucle d'identification");

		/* === Grande boucle d'identification === */
		while (feof(f_in1)==0) {
			if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
				lignes2[n_in1].comment=12;
				lignes2[n_in1].kobject=12;
				if (n_in1==0) {
					strcpy(lignes2[n_in1].texte,ligne);
					for (k=107;k<130;k++){
						/* on recupère les coordonnées GPS du lieu*/
						if ((ligne[k]=='G')&&(ligne[k+1]=='P')&&(ligne[k+2]=='S')) {
							for (k2=k+4;k2<145;k2++){
								if (ligne[k2]== ')') {
									for (k3=k;k3<k2;k3++) { s[k3-k]=ligne[k3]; } ; s[k3-k]='\0';
									strcpy(home,s);
									break;
								}
							}
							break;
						}
					}
				}
				if (strlen(ligne)>=3) {
					if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
						lignes2[n_in1].comment=0;
						kimage2++;
					}
				}
				if (lignes2[n_in1].comment==0) {
					if (strlen(ligne)>=156+44) {
						k1=146+44 ; k2=156+44 ; 
						for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					} else {
						strcpy(s,"");
					}
					strcpy(lignes2[n_in1].ident,s);
					result= strlen(lignes2[n_in1].ident);
					retour=-1;
					if (result>=1) {
						retour=0;
					}
					if (result>=3) {
						if ((lignes2[n_in1].ident[0]==' ')&&(lignes2[n_in1].ident[1]==' ')&&(lignes2[n_in1].ident[2]==' ')) {
							retour=-1;
						}
					}
					if ((retour==0) || (result<=3)) {
					//	WriteDisk("le satellite n'est pas identifie");
						/* --- le satellite n'est pas identifiée --- */
						k1=0; k2=144+44; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(lignes2[n_in1].texte,s); /* toute la ligne */
						k1=38; k2=60; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(im,s); /* date_obs */
						k1=104; k2=113; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						lignes2[n_in1].dec1=atof(s);
						k1=93 ; k2=101; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						lignes2[n_in1].ra1=atof(s);

						/* transforme le fichier de tle en ephemeride */						
						sprintf(lign,"mc_tle2ephem {%s} {%s} {%s}",im,pathTle2,home);
						//WriteDisk(lign);
						result = Tcl_Eval(interp,lign);	
						//WriteDisk("result");

						if (result==TCL_OK) {
							list=NULL;
							list2 = Tcl_GetObjResult  (interp);
							list = Tcl_GetString (list2);
							code = Tcl_SplitList(interp,list,&argcc,&argvv);
							
							if (argcc <= 1) {
								result=1;
								/* --- l'identification a un problème --- */
								strcpy(lignes2[n_in1].texte,ligne);
								lignes2[n_in1].kobject=0;
								nsat++;
								break;
							}
							if (code != TCL_OK) {
								sprintf(ligne, "Probleme sur le liste des ephemerides");
								Tcl_SetResult(interp, ligne, TCL_VOLATILE);
								free(lignes);
								free(lignes2);
								return TCL_ERROR;
							}
							kmin=0;
							kmini=-1;
							distmin=1e20;
							anglmin=0;
							ra0=lignes2[n_in1].ra1;
							dec0=lignes2[n_in1].dec1;
							for (k=0;k<argcc;k++) {
								result=strlen(argvv[k]);
								if (result<111) {
									continue;
								}
								//recherche de ra dans la tle
								for (k1=60;k1<70;k1++){
									if (argvv[k][k1]== '}') {
										break;
									}
								}
								for (k2=76;k2<89;k2++){
									if (argvv[k][k2]== ' ') {
										break;
									}
								}
								k1= k1+3; for (k3=k1;k3<k2;k3++) { s[k3-k1]=argvv[k][k3]; } ; s[k3-k1]='\0';
								ra=atof(s);
								//recherche de dec dans la tle
								for (k1=96;k1<111;k1++){
									if (argvv[k][k1]== ' ') {
										break;
									}
								}	
								k4=k2+1; for (k3=k4;k3<k1;k3++) { s[k3-k4]=argvv[k][k3]; } ; s[k3-k4]='\0';
								dec=atof(s);

								/* calcul la distance et angle entre les deux coordonnées */
								sprintf(lign,"mc_anglesep {%14.12f %14.12f %14.12f %14.12f}",ra0,dec0,ra,dec);
								result = Tcl_Eval(interp,lign);
								if (result!=TCL_OK) {
									WriteDisk("probleme avec mc_anglesep");
									dist=0.0;
									angl=0.0;
									distmin=1;
								} else {
									list3 = Tcl_GetObjResult  (interp);
									distang = Tcl_GetString (list3);
									code = Tcl_SplitList(interp,distang,&argc2,&argv2);
									Tcl_Free((char *) argv2);

									k2=0;
									k3=0;
									for (k1=0;k1<20;k1++){
										if (distang[k1]== ' ') {
											k2=k1;
											break;
										}
									}

									k1= 0; for (k3=k1;k3<k2;k3++) { s[k3-k1]=distang[k3]; } ; s[k3-k1]='\0';
									dist=atof(s);
									k1= k2+1; for (k3=k1;k3<=k2+13;k3++) { s[k3-k1]=distang[k3]; } ; s[k3-k1]='\0';
									angl=atof(s);
									if (dist <= distmin) {
										distmin = dist;
										kmini=kmin;
										anglmin=angl;
									}
									kmin++;
								}
							}
							if (distmin<=0.3) {
								strcpy(valid," 1 ");
							} else {
								strcpy(valid," 0 ");
							}
							if (kmini>=0) {
								/* il faut rajouter à ligne2[].texte satelname,noradname et cosparname*/
								for (k=2;k<30;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<30;k1++){
									if (argvv[kmini][k1]== '}') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';
										strcpy(satelname,s);
										break;
									}
								}
								for (k=k1+3;k<55;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<60;k1++){
									if (argvv[kmini][k1]== '}') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';
										strcpy(noradname,s);
										break;
									}
								}
								for (k=k1+3;k<75;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<80;k1++){
									if (argvv[kmini][k1]== ' ') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';
										strcpy(cosparname,s);
										break;
									}
								}
								k=strlen(satelname);
								k1=24-k;
								strcat(lignes2[n_in1].texte,valid);
								strcat(lignes2[n_in1].texte,satelname);

								for (k2=0;k2<k1;k2++) {
									strcat(lignes2[n_in1].texte," ");
								}

								k=strlen(noradname);
								k1=9-k;
								if (k1>0) {
									for (k2=0;k2<=k1;k2++) {
										strcat(noradname," ");
									}
								}
								strcpy(lignes2[n_in1].ident,"");
								strcat(lignes2[n_in1].ident,noradname);
								
								k=strlen(cosparname);
								k1=11-k;
								if (k1>0) {
									for (k2=0;k2<=k1;k2++) {
										strcat(cosparname," ");
									}
								}
								strcat(lignes2[n_in1].ident,cosparname);
								lignes2[n_in1].distance = distmin;
								lignes2[n_in1].angle = anglmin;

							} else {
								//WriteDisk(" on rajoute rien à  ligne[].texte");
								/* on rajoute rien à  ligne[].texte*/
								lignes2[n_in1].kobject=0;
							}
				         Tcl_Free((char *) argvv);
						} else {
							WriteDisk("Probleme avec les tle");
							sprintf(ligne, "Probleme avec les tle");

							k1=0; k2=144+44; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
							strcpy(lignes2[n_in1].texte,s);
							
							Tcl_SetResult(interp, ligne, TCL_VOLATILE);
							result = TCL_ERROR;
						}
					} else {
						/* --- le satellite est deja identifiée --- */
					//	WriteDisk("le satellite est deja identifiée");
					//	sprintf(chaine,"%s",ligne);
					//	WriteDisk(chaine);
						k1=0; k2=259; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(lignes2[n_in1].texte,s);
						lignes2[n_in1].kobject=0;
						nsat++;
					}
					
				} else {
					k1=0; k2=259; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes2[n_in1].texte,s);
				}
				n_in1++;
			}
			
		}
		fclose(f_in1);
		
		/* si on en a qui sont pas identifiés */
		//sprintf(chaine,"kimages2=%d et nsat=%d",kimage2,nsat);
		//WriteDisk(chaine);
		if (kimage2 != nsat) {
			/* delete file argv[2] puis reouvre le même*/
			if (remove(file_ident))  {
#if defined(LIBRARY_DLL)
				const char * const msg = strerror(errno); // MSG contient le message d'erreur
#endif
			}
			/* on recopie l'identification des satellites dans le fichier bdd */
			f_in1=fopen(file_ident,"w+");
			if (f_in1==NULL) {
				sprintf(s,"file_ident %s not created",file_ident);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);
				return TCL_ERROR;
			}
			fprintf(f_in1,"%s",lignes2[0].texte);
			fprintf(f_in1,"%s",lignes2[1].texte);
			fprintf(f_in1,"%s",lignes2[2].texte);
			if (lignes2[3].texte[0]!='I') {
				k1=4;
			} else {
				k1=3;
			}
			for (k=k1;k<n_in1;k++) {
				if (lignes2[k].comment==0){
					if (lignes2[k].kobject!=0) {
						fprintf(f_in1,"%s %09.5f %07.3f %s\n",lignes2[k].texte,lignes2[k].distance,lignes2[k].angle,lignes2[k].ident);
					} else {
						fprintf(f_in1,"%s\n",lignes2[k].texte);
					}
				} else {
					fprintf(f_in1,"\n");
				}
			}
			fclose(f_in1);
		}

		//WriteDisk("liberation des pointeurs");
		free(lignes2);
		free(lignes);
		result = TCL_OK;
	}
	//WriteDisk("return fonction");
	return result;
}

int Cmd_mltcl_geostatident2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])

/*#################  VERSION 2 pour Morpho MATH  ###########################*/
/****************************************************************************/
/* Identification des satellites en comparant les coordonnees               */
/****************************************************************************/
/****************************************************************************/
/* pour tester dans Audace:*/
/* ml_geostatident "C:/Program Files/Apache Group/Apache2/htdocs/ros/geostat/bdd0_20060927.txt"
"C:/Program Files/Apache Group/Apache2/htdocs/ros/geostat/bdd_20060927.txt" */

{
	int result,retour,n_in,n_in1,kimage,nimages,kimage2,nimages2,k,k1,k2,k3,date,temp,nsat;
	int kmin,kmini,pareil;	
	int code;
	double distmin,ra0,dec0, ra,dec,dist,angl,anglmin;
	char s[ML_STAT_LIG_MAX],ligne[2700],home[35],im[70],lign[2700],valid[4]; 
	char pathGeo[1000],pathTle2[1000],pathHttp[1000],pathUrl[1000],file_0[1000],file_ident[1000];
	char satelname[30],noradname[30],cosparname[30]; 	
	FILE *f_in1, *f_in2;	
	struct_ligsat *lignes,*lignes2;
	char *list, *distang;
	Tcl_Obj *list2, *list3;
	int argcc,argc2;
	char **argvv,**argv2;


	if(argc<3) {
      sprintf(s,"Usage: %s file_0 file_ident ?path_geo? ?path_http? ?url?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
	}  else {
		/* --- decode les parametres obligatoires ---*/
		strcpy (file_0,argv[1]);
		strcpy (file_ident,argv[2]);
		/* --- decode les parametres facultatifs ---*/
		if(argc <= 3) {
			strcpy (pathGeo,".");
		} else {
			strcpy (pathGeo,argv[3]);
		}
		if(argc <= 4) {
			strcpy (pathHttp,"c:/Program Files/Apache Group/Apache2/htdocs/ros");
		} else {
			strcpy (pathHttp,argv[4]);
		}
		if(argc <= 5) {
			strcpy (pathUrl,"celestrak.com/NORAD/elements/geo.txt");
		} else {
			strcpy (pathUrl,argv[5]);
		}
		if (strcmp(pathGeo,".")==0) {
#if defined(LIBRARY_DLL)
			GetCurrentDirectory (400,pathGeo);
			GetCurrentDirectory (400,pathTle2);
#endif
#if defined(LIBRARY_SO)
			getcwd(pathGeo,400);
			getcwd(pathTle2,400);
#endif		
		}
		strcat(pathGeo,"/geo.txt");
		strcpy(pathTle2,"./tle2.txt");
		strcat(pathHttp,"/tle.txt");

		/* === on fabrique un fichier pathTle2 = pathGeo derriere lequel on ajoute les TLE personels pathHttp === */
		f_in1=fopen(pathGeo,"r");
		if (f_in1==NULL) {
			sprintf(s,"file %s not found, pas de fichier geo",pathGeo);
			WriteDisk("pas de fichier geo.txt");
			WriteDisk(pathGeo);
		}
		ml_file_copy (pathGeo,pathTle2);
		//WriteDisk("fichier tle2");		
		fclose(f_in1);

		f_in1=fopen(pathHttp,"r");
		if (f_in1==NULL) {
			/* --- pas fichier TLE perso ---*/
			sprintf(s,"file %s not found, pas de fichier tle",pathHttp);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
		} else {
			n_in1=0;
			/* --- compteur de lignes du fichier TLE perso ---*/
			while (feof(f_in1)==0) {
				if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					n_in1++;
				}
			}
			fclose(f_in1);
			if (n_in1!=0) {
				/* --- dimensionne la structure des donnees d'entree ---*/
				lignes=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
				if (lignes==NULL) {
					sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					free(lignes);
					return TCL_ERROR;
				}
				f_in1=fopen(pathHttp,"r");
				if (f_in1==NULL) {
					sprintf(s,"file %s not found, pas de fichier tle perso",pathHttp);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
				}
				n_in = 0;
				while (feof(f_in1)==0) {
					if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
						strcpy(lignes[n_in].texte,ligne);
						n_in++;
					}
				}
				/* on ajoute les lignes de tle perso a la suite */
				f_in2=fopen(pathTle2,"a+");
				if (f_in2==NULL) {
					strcpy(s,"file pathTle2 not found");
				} else {
					for (k=0;k<n_in;k++) {
						fprintf(f_in2,"%s",lignes[k].texte);
					}
				}
				fclose(f_in1);
				fclose(f_in2);
				free(lignes);
			}
		}

		/* est-ce que le fichier bdd exist?*/
		f_in1=fopen(file_ident,"r");
		if (f_in1==NULL) {
			/* le fichier bdd n'existe pas */
			//WriteDisk("pas de fichier bdd");
			f_in2=fopen(file_0,"r");
			if (f_in2==NULL) {
				sprintf(s,"FILE: %s DOESN'T EXIST", file_0);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				result = TCL_ERROR;
			} else {
			retour = ml_file_copy (file_0,file_ident);
			fclose(f_in2);
			}
		} else {
			/* le fichier bdd existe deja */
			//WriteDisk("fichier bdd existe deja");
			/* comme on ne recopie pas le fichier, on va chercher les lignes différentes pour compléter le fichier de sortie */
			fclose(f_in1);
			/* --- dimensionne la structure des donnees d'entree ---*/
			n_in=0;
			/* dimensionne *lignes pour lire le fichier bdd0 */
			f_in1=fopen(file_0,"rt");
			if (f_in1==NULL) {
				sprintf(s,"file_0 %s not found",file_0);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			while (feof(f_in1)==0) {
				if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					n_in++;
				}
			}
			lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
			if (lignes==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			fclose(f_in1);
			/* dimensionne *lignes2 pour lire le fichier bdd */
			n_in1=0;
			f_in2=fopen(file_ident,"rt");
			if (f_in2==NULL) {
				sprintf(s,"file_ident %s not found",file_ident);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			while (feof(f_in2)==0) {
				if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
					n_in1++;
				}
			}
			lignes2=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
			if (lignes2==NULL) {
				sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				return TCL_ERROR;
			}
			fclose(f_in2);

			/* Lecture de *lignes a partir du fichier bdd0 */
			n_in=0;
			date=0;
			kimage=0;
			k=0;
			f_in1=fopen(file_0,"rt");
			if (f_in1==NULL) {
				sprintf(s,"file_00 %s not found",file_0);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);
				return TCL_ERROR;
			}
			/* on cherche quand il y a une ligne blanche, correspond a un changement de date */
			//WriteDisk("recherche des lignes blanches");
			while (feof(f_in1)==0) {
				 if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
					strcpy(lignes[n_in].texte,ligne);
					lignes[n_in].comment=12;
					lignes[n_in].nouvelledate=-12;
					if (strlen(ligne)>=3) {
						if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
							lignes[n_in].comment=0;
						}
						kimage++;
						if (date == 0) {
							lignes[n_in].nouvelledate=1;
						} else {
							lignes[n_in].nouvelledate=date;
						}

					} else {
						if (n_in <= 2) {
							date=0;
							lignes[n_in].nouvelledate=1;
						} else {
							k++;
							date=k+1;
							lignes[n_in].nouvelledate=k;
						}
					}
					n_in++;
				}
			}
			fclose(f_in1);
			nimages=kimage-2;

			/* Lecture de *lignes2 a partir du fichier bdd */
			kimage2=0;
			k=0;
			n_in1=0;
			f_in2=fopen(file_ident,"rt");
			if (f_in2==NULL) {
				sprintf(s,"file_ident %s not found",file_ident);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);
				return TCL_ERROR;
			}
			while (feof(f_in2)==0) {
				 if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
					strcpy(lignes2[n_in1].texte,ligne);
					lignes2[n_in1].comment=12;
					if (strlen(ligne)>=3) {
						if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
							lignes2[n_in1].comment=0;
						}
						kimage2++;
					}
					n_in1++;
				 }	 
			}
			fclose(f_in2);
			nimages2=kimage2-2;

			//sprintf(chaine,"nombre d'images = %d",nimages2);
			//WriteDisk(chaine);
			/* --- on cherche les lignes qui manquent dans le fichier de sortie --- */
			/*tester*/
			if (nimages2!=nimages) {	
				for (k=0;k<n_in;k++) {
					lignes[k].kimage1 = -12;
					if (lignes[k].comment!=0) {
						lignes[k].kimage1 = 0;
						continue;
					}
					for (k2=0;k2<n_in1;k2++) {
						lignes2[k2].kimage1 = -12;
						if (lignes2[k2].comment!=0) {
							continue;
						}
						if (lignes2[k2].kimage1 == 0) {
							continue;
						}
						pareil=0;
						for (k1=0; k1<140;k1++) {
							if (lignes2[k2].texte [k1] == lignes[k].texte [k1]) {
								pareil++;
							} else {
								break;
							}
							if (pareil>=120) {
								lignes[k].kimage1 = 0;
								lignes2[k2].kimage1 = 0;
								break;
							}
						}
						if (lignes[k].kimage1 == 0) {
							break;
						}
					}
				}
				/* --- on sauve le resultat dans le fichier de sortie ---*/
				f_in1=fopen(file_ident,"a+");
				if (f_in1==NULL) {
					sprintf(s,"file_ident %s not created",file_ident);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					free(lignes);
					free(lignes2);
					return TCL_ERROR;
				}
				temp=0;
				for (k=0;k<n_in;k++) {
					if (lignes[k].kimage1 != 0) {
						/* on a une nouvelle ligne*/
						/*il faut copier lignes[k1].ligne dans lignes[nimages2+1]*/
						if (temp == 0) {
								fprintf(f_in1,"\n%s",lignes[k].texte);
						} else {

							if ((lignes[k].nouvelledate != lignes[temp].nouvelledate)&&(temp!=0)) {
								fprintf(f_in1,"\n%s",lignes[k].texte);
							} else {
								fprintf(f_in1,"%s",lignes[k].texte);
							}
						}
						temp=k;
					}
				}
				fclose(f_in1);	
			}
			free(lignes);
			free(lignes2);
		}

		f_in2=fopen(file_ident,"rt");
		//WriteDisk(argv[2]);
		if (f_in2==NULL) {
			sprintf(s,"file_ident %s not found",file_ident);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		n_in1=0;
		while (feof(f_in2)==0) {
			if (fgets(ligne,sizeof(ligne),f_in2)!=NULL) {
				n_in1++;
			}
		}
		fclose(f_in2);
		/* --- on recupère les données actuelles du fichier de sortie ---*/
		lignes2=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
		if (lignes2==NULL) {
			sprintf(s,"error : lignes2 pointer out of memory (%d elements)",n_in1);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		lignes=(struct_ligsat*)malloc(n_in1*sizeof(struct_ligsat));
		if (lignes==NULL) {
			sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in1);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(lignes2);
			return TCL_ERROR;
		}
		n_in1=0;
		n_in=0;
		kimage2=0;
		nsat=0;
		strcpy(s,"");
		f_in1=fopen(file_ident,"rt");
		if (f_in1==NULL) {
			sprintf(s,"file_ident %s not found",file_ident);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			free(lignes);
			free(lignes2);
			return TCL_ERROR;
		}
		//WriteDisk("grande boucle d'identification");

		/* === Grande boucle d'identification === */
		while (feof(f_in1)==0) {
			if (fgets(ligne,sizeof(ligne),f_in1)!=NULL) {
				lignes2[n_in1].comment=12;
				lignes2[n_in1].kobject=12;
				if (n_in1==0) {
					strcpy(lignes2[n_in1].texte,ligne);
					for (k=115;k<145;k++){
						/* on recupère les coordonnées GPS du lieu*/
						if ((ligne[k]=='G')&&(ligne[k+1]=='P')&&(ligne[k+2]=='S')) {
							for (k2=k+4;k2<165;k2++){
								if (ligne[k2]== ')') {
									for (k3=k;k3<k2;k3++) { s[k3-k]=ligne[k3]; } ; s[k3-k]='\0';
									strcpy(home,s);
									break;
								}
							}
							break;
						}
					}
				}
				if (strlen(ligne)>=3) {
					if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
						lignes2[n_in1].comment=0;
						kimage2++;
					}
				}
				if (lignes2[n_in1].comment==0) {
					if (strlen(ligne)>=300) {
						k1=300 ; k2=310 ; 
						for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					} else {
						strcpy(s,"");
					}
					strcpy(lignes2[n_in1].ident,s);
					result= strlen(lignes2[n_in1].ident);
					retour=-1;
					if (result>=3) {
						if ((lignes2[n_in1].ident[0]==' ')&&(lignes2[n_in1].ident[1]==' ')&&(lignes2[n_in1].ident[2]==' ')) {
							retour=0;
						}
					}
					//vaut 2 si pas geo
					k1=269 ; for (k=k1;k<k1+1;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].typesatellite=atoi(s);
					if (((retour==0) || (result<=3)) && ((lignes[n_in].typesatellite!=2) )) {
					//	WriteDisk("le satellite n'est pas identifie");
						/* --- le satellite n'est pas identifiée --- */
						k1=0; k2=297; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(lignes2[n_in1].texte,s); /* toute la ligne */
						k1=38; k2=60; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(im,s); /* date_obs */
						k1=149; k2=158; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						lignes2[n_in1].dec1=atof(s);
						k1=138 ; k2=147; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						lignes2[n_in1].ra1=atof(s);

						/* transforme le fichier de tle en ephemeride */						
						sprintf(lign,"mc_tle2ephem {%s} {%s} {%s}",im,pathTle2,home);
						//WriteDisk(lign);
						result = Tcl_Eval(interp,lign);	
						//WriteDisk("result");

						if (result==TCL_OK) {
							list=NULL;
							list2 = Tcl_GetObjResult  (interp);
							list = Tcl_GetString (list2);
							code = Tcl_SplitList(interp,list,&argcc,&argvv);
							
							if (argcc <= 1) {
								result=1;
								/* --- l'identification a un problème --- */
								strcpy(lignes2[n_in1].texte,ligne);
								lignes2[n_in1].kobject=0;
								nsat++;
								break;
							}
							if (code != TCL_OK) {
								sprintf(ligne, "Probleme sur le liste des ephemerides");
								Tcl_SetResult(interp, ligne, TCL_VOLATILE);
								free(lignes);
								free(lignes2);
								return TCL_ERROR;
							}
							kmin=0;
							kmini=-1;
							distmin=1e20;
							anglmin=0;
							ra0=lignes2[n_in1].ra1;
							dec0=lignes2[n_in1].dec1;
							for (k=0;k<argcc;k++) {
								result=strlen(argvv[k]);
								if (result<111) {
									continue;
								}
								code = Tcl_SplitList(interp,argvv[k],&argc2,&argv2);
								ra=atof(argv2[1]);
								dec=atof(argv2[2]);
								Tcl_Free((char *) argv2);
								/* calcul la distance et angle entre les deux coordonnées */
								sprintf(lign,"mc_anglesep {%14.12f %14.12f %14.12f %14.12f}",ra0,dec0,ra,dec);
								result = Tcl_Eval(interp,lign);
								if (result!=TCL_OK) {
									WriteDisk("probleme avec mc_anglesep");
									dist=0.0;
									angl=0.0;
									distmin=1;
								} else {
									list3 = Tcl_GetObjResult  (interp);
									distang = Tcl_GetString (list3);
									code = Tcl_SplitList(interp,distang,&argc2,&argv2);
									dist=atof(argv2[0]);
									angl=atof(argv2[1]);
									Tcl_Free((char *) argv2);
									if (dist <= distmin) {
										distmin = dist;
										kmini=kmin;
										anglmin=angl;
									}
									kmin++;
								}
							}
							if (distmin<=0.3) {
								strcpy(valid," 1 ");
							} else {
								strcpy(valid," 0 ");
							}
							if (kmini>=0) {
								/* il faut rajouter à ligne2[].texte satelname,noradname et cosparname*/
								for (k=2;k<30;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<30;k1++){
									if (argvv[kmini][k1]== '}') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';
										strcpy(satelname,s);
										break;
									}
								}
								for (k=k1+3;k<55;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<60;k1++){
									if (argvv[kmini][k1]== '}') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';
										strcpy(noradname,s);
										break;
									}
								}
								for (k=k1+3;k<75;k++){
									if (argvv[kmini][k]!= ' ') {
										break;
									}
								}
								for (k1=k+1;k1<80;k1++){
									if (argvv[kmini][k1]== ' ') {
										for (k2=k;k2<k1;k2++) { s[k2-k]=argvv[kmini][k2]; } ; s[k2-k]='\0';
										strcpy(cosparname,s);
										break;
									}
								}
								k=strlen(satelname);
								k1=24-k;
								strcat(lignes2[n_in1].texte,valid);
								strcat(lignes2[n_in1].texte,satelname);

								for (k2=0;k2<k1;k2++) {
									strcat(lignes2[n_in1].texte," ");
								}

								k=strlen(noradname);
								k1=9-k;
								if (k1>0) {
									for (k2=0;k2<=k1;k2++) {
										strcat(noradname," ");
									}
								}
								strcpy(lignes2[n_in1].ident,"");
								strcat(lignes2[n_in1].ident,noradname);
								
								k=strlen(cosparname);
								k1=9-k;
								if (k1>0) {
									for (k2=0;k2<k1;k2++) {
										strcat(cosparname," ");
									}
								}
								strcat(lignes2[n_in1].ident,cosparname);
								lignes2[n_in1].distance = distmin;
								lignes2[n_in1].angle = anglmin;

							} else {
								//WriteDisk(" on rajoute rien à  ligne[].texte");
								/* on rajoute rien à  ligne[].texte*/
								lignes2[n_in1].kobject=0;
							}
				         Tcl_Free((char *) argvv);
						} else {
							WriteDisk("Probleme avec les tle");
							sprintf(ligne, "Probleme avec les tle");

							k1=0; k2=298; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
							strcpy(lignes2[n_in1].texte,s);
							
							Tcl_SetResult(interp, ligne, TCL_VOLATILE);
							result = TCL_ERROR;
						}
					} else {
						/* --- le satellite est deja identifiée ou pas géo --- */
					//	WriteDisk("le satellite est deja identifiée ou pas géo");
					//	sprintf(chaine,"%s",ligne);
					//	WriteDisk(chaine);
						k1=0; k2=362; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
						strcpy(lignes2[n_in1].texte,s);
						lignes2[n_in1].kobject=0;
						nsat++;
					}
					
				} else {
					k1=0; k2=362; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes2[n_in1].texte,s);
				}
				n_in1++;
			}
			
		}
		fclose(f_in1);
		
		/* si on en a qui sont pas identifiés */
		//sprintf(chaine,"kimages2=%d et nsat=%d",kimage2,nsat);
		//WriteDisk(chaine);
		if (kimage2 != nsat) {
			/* delete file argv[2] puis reouvre le même*/
			if (remove(file_ident))  {
#if defined(LIBRARY_DLL)
				const char * const msg = strerror(errno); // MSG contient le message d'erreur
#endif
			}
			/* on recopie l'identification des satellites dans le fichier bdd */
			f_in1=fopen(file_ident,"w+");
			if (f_in1==NULL) {
				sprintf(s,"file_ident %s not created",file_ident);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				free(lignes);
				free(lignes2);
				return TCL_ERROR;
			}
			fprintf(f_in1,"%s",lignes2[0].texte);
			fprintf(f_in1,"%s",lignes2[1].texte);
			fprintf(f_in1,"%s",lignes2[2].texte);
			if (lignes2[3].texte[0]!='I') {
				k1=4;
			} else {
				k1=3;
			}
			for (k=k1;k<n_in1;k++) {
				if (lignes2[k].comment==0){
					if (lignes2[k].kobject!=0) {
						fprintf(f_in1,"%s %09.5f %07.3f %s\n",lignes2[k].texte,lignes2[k].distance,lignes2[k].angle,lignes2[k].ident);
					} else {
						fprintf(f_in1,"%s\n",lignes2[k].texte);
					}
				} else {
					fprintf(f_in1,"\n");
				}
			}
			fclose(f_in1);
		}

		//WriteDisk("liberation des pointeurs");
		free(lignes2);
		free(lignes);
		result = TCL_OK;
	}
	//WriteDisk("return fonction");
	return result;
}


int Cmd_mltcl_geostatreduc(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Reduction des objets susceptibles etre des satellites geostationnaires.  */
/****************************************************************************/
/*
ml_geostatreduc bdd00_20070607.txt bdd0_20070607.txt [expr 3.3*5/3600.] [expr 60./3600.] 0.014 1
*/
/****************************************************************************/
{
   int result,retour;
   char s[1000],ligne[1000];
   char im0[40],im[40],*texte;
   double sepmin; /* minimum de distance pour deux objets dans la meme image (degrés) */
   double sepmax; /* maximum de distance pour deux objets dans la des images différentes (degrés) */
   double jjdifmin=0.014; /* differences de jours pour autoriser la comparaison */
   FILE *f_in;
   int k,k1,k2,k3,kimage,nimages,kobject=0;
   int n_in,ns;
   struct_ligsat *lignes;
   int *kdebs,*kfins;
   double annee, mois, jour, heure, minute, seconde, jd, pi, dr;
   double ra1,ra2,ra3,ha1,ha2,ha3,dec1,dec2,dec3,sep,pos,jd1,jd2,jd3,sep12,pos12,sep23,pos23,dec30,ha30,sep1,pos1,sep2,pos2,pos3,sep3,dha,ddec;
   int ki1,ki2,ki3;
   int matching_poursuit=1,nifin1,nifin2,matching_id;

   if(argc<3) {
      sprintf(s,"Usage: %s file_00 file_0 ?sepmin? ?sepmax? ?jjdifmin? ?matching_poursuit?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/

      /* --- decode les parametres facultatifs ---*/
      sepmin=3.3*5/3600.; /* default value = 5 pixels pour TAROT */
      if (argc>=4) {
         retour = Tcl_GetDouble(interp,argv[3],&sepmin);
         if(retour!=TCL_OK) return retour;
      }
      sepmax=60./3600.; /* default value = 60 arcsec pour TAROT */
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&sepmax);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&jjdifmin);
         if(retour!=TCL_OK) return retour;
      }
      if (argc>=7) {
         retour = Tcl_GetInt(interp,argv[6],&matching_poursuit);
         if(retour!=TCL_OK) return retour;
      }

      /* --- lecture du nombre de lignes dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
            n_in++;
         }
      }
      fclose(f_in);

      /* --- dimensionne la structure des donnees d'entree ---*/
      lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
      if (lignes==NULL) {
         sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      /* --- lecture des donnes ligne par ligne dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      strcpy(im0,"");
      kimage=-1;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
            strcpy(lignes[n_in].texte,ligne);
            lignes[n_in].comment=1;
            lignes[n_in].kimage1=-1;
            lignes[n_in].kobject1=-1;
            lignes[n_in].kimage2=-1;
            lignes[n_in].kobject2=-1;
            lignes[n_in].matched=0;
            lignes[n_in].sep=0.;
            lignes[n_in].pos=0.;
            strcpy(lignes[n_in].ident,"");
            strcpy(lignes[n_in].matching_id,"");
            if (strlen(ligne)>=3) {
               if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
                  lignes[n_in].comment=0;
               }
            }
            if (lignes[n_in].comment==0) {
			   k1=93 ; k2=101; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
			   lignes[n_in].ra1=atof(s);
               k1=115 ; k2=123 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               lignes[n_in].ha1=atof(s);
               k1=104 ; k2=113 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               lignes[n_in].dec1=atof(s);
               k1= 83 ; k2= 91 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               lignes[n_in].mag=atof(s);
               k1= 38 ; k2= 41 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               annee=atof(s);
               k1= 43 ; k2= 44 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               mois=atof(s);
               k1= 46 ; k2= 47 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               jour=atof(s); lignes[n_in].jour=atof(s);
               k1= 49 ; k2= 50 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               heure=atof(s); lignes[n_in].heure=atof(s);
               k1= 52 ; k2= 53 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               minute=atof(s); lignes[n_in].minute=atof(s);
               k1= 55 ; k2= 60 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               seconde=atof(s); lignes[n_in].seconde=atof(s);
               ml_date2jd(annee,mois,jour,heure,minute,seconde,&jd);
               lignes[n_in].jd=jd;
               k1=  0 ; k2= 36 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
               strcpy(im,s);
               if (strcmp(im,im0)!=0) {
                  kimage++;
                  kobject=0;
               }
               lignes[n_in].kimage=kimage;
               lignes[n_in].kobject=kobject;
               strcpy(im0,im);
               kobject++;
            } else {
               lignes[n_in].ha1=0.;
               lignes[n_in].dec1=0.;
               lignes[n_in].jd=0.;
               lignes[n_in].mag=99.;
               lignes[n_in].kimage=-1;
               lignes[n_in].kobject=-1;
            }
            n_in++;
         }
      }
      fclose(f_in);
      nimages=kimage+1;

      /* --- dimensionne les tableaux des indices de debut et de fin d'entree ---*/
      kdebs=(int*)calloc(nimages,sizeof(int));
      if (kdebs==NULL) {
         sprintf(s,"error : kdebs pointer out of memory (%d elements)",nimages);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         return TCL_ERROR;
      }
      for (k=0;k<nimages;k++) {
         kdebs[k]=-1;
      }
      kfins=(int*)calloc(nimages,sizeof(int));
      if (kdebs==NULL) {
         sprintf(s,"error : kfins pointer out of memory (%d elements)",nimages);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         free(kdebs);
         return TCL_ERROR;
      }
      for (k=0;k<nimages;k++) {
         kfins[k]=0;
      }

      /* --- affecte les tableaux des indices de debut et de fin d'entree ---*/
      for (k=0;k<n_in;k++) {
         kimage=lignes[k].kimage;
         if (kimage>=0) {
            if (kdebs[kimage]==-1) {
               kdebs[kimage]=k;
            }
            if (kfins[kimage]<=k) {
               kfins[kimage]=k;
            }
         }
      }

      /* --- premiere passe, on elimine les objets multiples sur chaque pose ---*/
      pi=4.*atan(1.);
      dr=pi/180.;
      for (k=0;k<nimages;k++) {
         for (k1=kdebs[k];k1<=kfins[k]-1;k1++) {
            if (lignes[k1].comment!=0) {
               continue;
            }
            ha1=lignes[k1].ha1;
            dec1=lignes[k1].dec1;
            for (k2=k1+1;k2<=kfins[k];k2++) {
               if (lignes[k2].comment!=0) {
                  continue;
               }
               ha2=lignes[k2].ha1;
               dec2=lignes[k2].dec1;
               ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep,&pos);
               sep=sep/dr;
               if (sep<sepmin) {
                  /* --- on elimine le moins brillant ---*/
                  if (lignes[k1].mag<lignes[k2].mag) {
                     lignes[k2].comment=2;
                  } else {
                     lignes[k1].comment=2;
                  }
               }
            }
         }
      }

      /* --- deuxieme passe, on apparie les objects sur les images differentes ---*/
      /* --- avec matching poursuit a 3 dates ---*/
      if (matching_poursuit==1) {
         nifin1=2;
         nifin2=1;
      } else {
         nifin1=1;
         nifin2=0;
      }
      matching_id=0;
      for (ki1=0;ki1<nimages-nifin1;ki1++) {
         for (k1=kdebs[ki1];k1<=kfins[ki1];k1++) {
            if (lignes[k1].comment!=0) {
               continue;
            }
            jd1=lignes[k1].jd;
            ha1=lignes[k1].ha1;
			ra1=lignes[k1].ra1;
            dec1=lignes[k1].dec1;
            for (ki2=ki1+1;ki2<nimages-nifin2;ki2++) {
               for (k2=kdebs[ki2];k2<=kfins[ki2];k2++) {
                  if (lignes[k2].comment!=0) {
                     continue;
                  }
                  jd2=lignes[k2].jd;
                  if (fabs(jd2-jd1)>jjdifmin) {
                     continue;
                  }
                  ha2=lignes[k2].ha1;
				  ra2=lignes[k2].ra1;
                  dec2=lignes[k2].dec1;
                  ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep12,&pos12);
                  sep12=sep12/dr;
					// calcul pour evaluer la vitesse angulaire des géo
					//pos1,sep1 diff entre premier image et deuxième image, pos2 et sep2 => 2 et 3ième images, pos3 et sep3 => 1et 3 images
				  ml_sepangle(ra1*dr,ra2*dr,dec1*dr,dec2*dr,&sep1,&pos1);
				  sep1=sep1/dr;
                  pos1=pos1/dr;
                  if (sep12>sepmax) {
                     continue;
                  }
                  if (matching_poursuit==0) {
					 lignes[k2].sep=lignes[k1].sep;
		             lignes[k2].pos=lignes[k1].pos;
                     lignes[k1].kimage1=ki2;
                     lignes[k1].kobject1=k2;
                     lignes[k1].matched++;
                     lignes[k2].matched++;
                     if (strcmp(lignes[k1].matching_id,"")!=0) {
                        strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
                     } else {
                        matching_id++;
                        sprintf(lignes[k1].matching_id,"%013d",matching_id);
                        strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
                     }
                     continue;
                  } else {
                     if ((strcmp(lignes[k1].matching_id,lignes[k2].matching_id)!=0)&&(strcmp(lignes[k2].matching_id,"")!=0)) {
                        continue;
                     }
                  }
                  for (ki3=ki2+1;ki3<nimages;ki3++) {
                     for (k3=kdebs[ki3];k3<=kfins[ki3];k3++) {
                        if (lignes[k3].comment!=0) {
                           continue;
                        }
                        jd3=lignes[k3].jd;
                        if (fabs(jd3-jd2)>jjdifmin) {
                           continue;
                        }
                        ha3=lignes[k3].ha1;
						ra3=lignes[k3].ra1;
                        dec3=lignes[k3].dec1;
                        ml_sepangle(ha2*dr,ha3*dr,dec2*dr,dec3*dr,&sep23,&pos23);
                        sep23=sep23/dr;
					
						ml_sepangle(ra2*dr,ra3*dr,dec2*dr,dec3*dr,&sep2,&pos2);
                        sep2=sep2/dr;
						pos2=pos2/dr;
                        if (sep23>sepmax) {
                            continue;
                        }
                        /* --- matching poursuit --- */
                        dha=(ha2-ha1);
                        if (dha>180) { dha=360.-dha; }
                        if (dha<-180) { dha=360.+dha; }
                        ha30=ha1+(ha2-ha1)*(jd3-jd1)/(jd2-jd1);
                        ddec=(dec2-dec1);
                        dec30=dec1+(dec2-dec1)*(jd3-jd1)/(jd2-jd1);
                        ml_sepangle(ha30*dr,ha3*dr,dec30*dr,dec3*dr,&sep,&pos);
                        sep=sep/dr;
                        //if (sep*3600>10.) {
                        if (sep>sepmax) {
                           continue;
                        }
                        ml_sepangle(ra1*dr,ra3*dr,dec1*dr,dec3*dr,&sep3,&pos3);
                        sep3=sep3/dr;
						pos3=pos3/dr;
                        lignes[k1].kimage1=ki2;
                        lignes[k1].kobject1=k2;
                        lignes[k1].kimage2=ki3;
                        lignes[k1].kobject2=k3;
                        lignes[k1].matched++;
                        lignes[k2].matched++;
                        lignes[k3].matched++;
	                    lignes[k1].sep=sep1*3600/(jd2-jd1)/86400;
			            lignes[k1].pos=pos1;
		                lignes[k2].sep=sep2*3600/(jd3-jd2)/86400;
			            lignes[k2].pos=pos2;
						lignes[k3].sep=sep3*3600/(jd3-jd1)/86400;
			            lignes[k3].pos=pos3;
                        if (strcmp(lignes[k1].matching_id,"")!=0) {
                           strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
                           strcpy(lignes[k3].matching_id,lignes[k1].matching_id);
                        } else {
                           matching_id++;
                           sprintf(lignes[k1].matching_id,"%013d",matching_id);
                           strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
                           strcpy(lignes[k3].matching_id,lignes[k1].matching_id);
                        }
                     }
                  }
               }
            }
         }
      }

      /* --- sauve le resultat dans le fichier de sortie ---*/
      f_in=fopen(argv[2],"wt");
      if (f_in==NULL) {
         sprintf(s,"file_0 %s not created",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         free(kdebs);
         free(kfins);
         return TCL_ERROR;
      }
      fprintf(f_in,"%s",lignes[0].texte);
      fprintf(f_in,"%s",lignes[1].texte);
      fprintf(f_in,"%s",lignes[2].texte);
      kimage=-1;
      for (k=3;k<n_in;k++) {
         if (lignes[k].matched>0) {
            if ((lignes[k].kimage!=kimage)&&(kimage!=-1)) {
               fprintf(f_in,"\n");
            }
			ns=(int)(strlen(lignes[k].texte));
			texte=lignes[k].texte;
			if (ns>=2) {
				texte[ns-1]='\0';
			}
			sprintf(s,"%s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
			fprintf(f_in,"%s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
			//strcat(lignes[k].texte,lignes[k].matching_id);
			//fprintf(f_in,"%s",lignes[k].texte);
            //fprintf(f_in," K=%d => matching_id=%s => matched=%d\n",k,lignes[k].matching_id,lignes[k].matched);
            kimage=lignes[k].kimage;
         }
      }
      fclose(f_in);

      /* --- libere les pointeurs --- */
      free(lignes);
      free(kdebs);
      free(kfins);
      result = TCL_OK;
   }
   return result;
}


int Cmd_mltcl_geostatreduc2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])

/*############################  VERSION 2 pour Morpho MATH  #####################################*/
/*************************************************************************************************/
/* Reduction des objets susceptibles etre des satellites geostationnaires.                       */
/*************************************************************************************************/
/*
ml_geostatreduc2 bdd00_20070607.txt bdd0_20070607.txt [expr 3.3*5/3600.] [expr 60./3600.] 0.014 1
*/
/*************************************************************************************************/
{
   int result,retour;
   char s[1000],ligne[1000];
   char im0[40],im[40],*texte;
   double sepmin; /* minimum de distance pour deux objets dans la meme image (degrés) */
   double sepmax; /* maximum de distance pour deux objets dans la des images différentes (degrés) */
   double jjdifmin=0.014; /* differences de jours pour autoriser la comparaison */
   FILE *f_in;
   int k,k1,k2,k3,kimage,nimages,kobject=0;
   int n_in,ns;
   struct_ligsat *lignes;
   int *kdebs,*kfins;
   double annee, mois, jour, heure, minute, seconde, jd, pi, dr;
   double ra1,ra2,ra3,ha1,ha2,ha3,dec1,dec2,dec3,sep,pos,jd1,jd2,jd3,sep12,pos12,sep23,pos23,dec30,ha30,sep1,pos1,sep2,pos2,pos3,sep3,dha,ddec;
   int ki1,ki2,ki3;
   int matching_poursuit=1,nifin1,nifin2,matching_id;
   double x11, x21, y11, y21 ,x12, x22, y12, y22, ba, bb;

   if(argc<3) {
      sprintf(s,"Usage: %s file_00 file_0 ?sepmin? ?sepmax? ?jjdifmin? ?matching_poursuit?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/

      /* --- decode les parametres facultatifs ---*/
      sepmin=3.3*5/3600.; /* default value = 5 pixels pour TAROT */
      if (argc>=4) {
         retour = Tcl_GetDouble(interp,argv[3],&sepmin);
         if(retour!=TCL_OK) return retour;
      }
      sepmax=300./3600.; /* default value = 120 arcsec pour TAROT */
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&sepmax);
         if(retour!=TCL_OK) return retour;
      }
	  jjdifmin=0.014;
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&jjdifmin);
         if(retour!=TCL_OK) return retour;
      }
	  matching_poursuit=1;
      if (argc>=7) {
         retour = Tcl_GetInt(interp,argv[6],&matching_poursuit);
         if(retour!=TCL_OK) return retour;
      }

      /* --- lecture du nombre de lignes dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
            n_in++;
         }
      }
      fclose(f_in);

      /* --- dimensionne la structure des donnees d'entree ---*/
      lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
      if (lignes==NULL) {
         sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      /* --- lecture des donnes ligne par ligne dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      strcpy(im0,"");
      kimage=-1;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
			strcpy(lignes[n_in].texte,ligne);
            lignes[n_in].comment=1;
            lignes[n_in].kimage1=-1;
            lignes[n_in].kobject1=-1;
            lignes[n_in].kimage2=-1;
            lignes[n_in].kobject2=-1;
            lignes[n_in].matched=0;
            lignes[n_in].sep=0.;
            lignes[n_in].pos=0.;
			lignes[n_in].typesatellite=0;
            strcpy(lignes[n_in].ident,"");
            strcpy(lignes[n_in].matching_id,"");
            if (strlen(ligne)>=3) {
               if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
                  lignes[n_in].comment=0;
               }
            }
			if (lignes[n_in].comment==0) {
			   k1=269 ; for (k=k1;k<k1+1;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
			   lignes[n_in].typesatellite=atoi(s);
				strcpy(lignes[n_in].texte,"");
				k1=0 ; k2=270; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				strcpy(lignes[n_in].texte,s);
			   if ((lignes[n_in].typesatellite==2)||(lignes[n_in].typesatellite==3)) { 
					
					strcpy(lignes[n_in].texte,"");
					k1=0 ; k2=84; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes[n_in].texte,s);
					k1=86 ; k2=95; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].gisement1=atof(s);
					k1=97 ; k2=105; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].site1=atof(s);
					k1=107 ; k2=116; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].gisement2=atof(s);
					k1=118 ; k2=126; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].site2=atof(s);
					k1=171 ; k2=181; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].ra2=atof(s);
					k1=182 ; k2=191 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].dec2=atof(s);
					k1=193 ; k2=202 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].ha2=atof(s);
					k1=204 ; k2=212; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].x1=atof(s);
					k1=214 ; k2=223; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].y1=atof(s);
					k1=224 ; k2=232; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].x2=atof(s);
					k1=234 ; k2=242; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].y2=atof(s);
					k1=244 ; k2=268; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes[n_in].texte2,s);
					k1=285 ; k2=290; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].sep=atof(s);
					k1=292 ; k2=297; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].pos=atof(s);
					
					if ((fabs(lignes[n_in].x1-lignes[n_in].x2)>20)||(fabs(lignes[n_in].y1-lignes[n_in].y2)>20)) {
						lignes[n_in].matched=1; // mettre a 1 pour qu'il soit tjrs dans le bdd final
						lignes[n_in].kimage=0; // mettre à 0 si on ne le passe pas dans le matching	
					} else {
						lignes[n_in].typesatellite=3; // Défilant qui passent dans la matching poursuite
					}
			   } 
			   	
				k1= 38 ; k2= 41 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				annee=atof(s);
				k1= 43 ; k2= 44 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				mois=atof(s);
				k1= 46 ; k2= 47 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				jour=atof(s); lignes[n_in].jour=atof(s);
				k1= 49 ; k2= 50 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				heure=atof(s); lignes[n_in].heure=atof(s);
				k1= 52 ; k2= 53 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				minute=atof(s); lignes[n_in].minute=atof(s);
				k1= 55 ; k2= 60 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				seconde=atof(s); lignes[n_in].seconde=atof(s);
				ml_date2jd(annee,mois,jour,heure,minute,seconde,&jd);
				lignes[n_in].jd=jd;
				k1=128 ; k2=136 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].mag=atof(s);
				k1=138 ; k2=146; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].ra1=atof(s);
				k1=149 ; k2=158 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].dec1=atof(s);
				k1=160 ; k2=169 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].ha1=atof(s);
				k1=  0 ; k2= 36 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				strcpy(im,s);
				if (strcmp(im,im0)!=0) {
					kimage++;
					kobject=0;
				}
				strcpy(im0,im);
				lignes[n_in].kimage=kimage;
				lignes[n_in].kobject=kobject;
				kobject++;

            } else {
               lignes[n_in].ha1=0.;
               lignes[n_in].dec1=0.;
               lignes[n_in].jd=0.;
               lignes[n_in].mag=99.;
               lignes[n_in].kimage=-1;
               lignes[n_in].kobject=-1;
            }
            n_in++;
         }
      }
      fclose(f_in);
      nimages=kimage+1;

	  
	  /* --- dimensionne les tableaux des indices de debut et de fin d'entree ---*/
	  kdebs=(int*)calloc(nimages,sizeof(int));
	  if (kdebs==NULL) {
		 sprintf(s,"error : kdebs pointer out of memory (%d elements)",nimages);
		 Tcl_SetResult(interp,s,TCL_VOLATILE);
		 free(lignes);
		 return TCL_ERROR;
	  }
	  for (k=0;k<nimages;k++) {
		 kdebs[k]=-1;
	  }
	  kfins=(int*)calloc(nimages,sizeof(int));
	  if (kdebs==NULL) {
		 sprintf(s,"error : kfins pointer out of memory (%d elements)",nimages);
		 Tcl_SetResult(interp,s,TCL_VOLATILE);
		 free(lignes);
		 free(kdebs);
		 return TCL_ERROR;
	  }
	  for (k=0;k<nimages;k++) {
		 kfins[k]=0;
	  }

	  /* --- affecte les tableaux des indices de debut et de fin d'entree ---*/
	  for (k=0;k<n_in;k++) {
		 kimage=lignes[k].kimage;
		 if (kimage>=0) {
			if (kdebs[kimage]==-1) {
			   kdebs[kimage]=k;
			}
			if (kfins[kimage]<=k) {
			   kfins[kimage]=k;
			}
		 }
	  }

	  /* --- premiere passe, on elimine les objets multiples sur chaque pose ---*/
	  pi=4.*atan(1.);
	  dr=pi/180.;
	  for (k=0;k<nimages;k++) {
		 for (k1=kdebs[k];k1<=kfins[k]-1;k1++) {
			if (lignes[k1].comment!=0) {
			   continue;
			}	
			if (lignes[k1].typesatellite!=2) {/* pour les geo */
				ha1=lignes[k1].ha1;
				dec1=lignes[k1].dec1;
				for (k2=k1+1;k2<=kfins[k];k2++) {
				   if ((lignes[k2].comment!=0)||(lignes[k2].typesatellite==2)) {
					  continue;
				   }
				   ha2=lignes[k2].ha1;
				   dec2=lignes[k2].dec1;
				   ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep,&pos);
				   sep=sep/dr;
				   if (sep<sepmin) {
					  /* --- on elimine le moins brillant ---*/
					  if (lignes[k1].mag<lignes[k2].mag) {
						 lignes[k2].comment=2;
					  } else {
						 lignes[k1].comment=2;
					  }
				   }
				}
			} else {/* pour les defilants */
				pos1=lignes[k1].pos;
				x11=lignes[k1].x1;
				y11=lignes[k1].y1;
				x21=lignes[k1].x2;
				y21=lignes[k1].y2;
				bb=ba=0;
				for (k2=k1+1;k2<=kfins[k];k2++) {
					if ((lignes[k2].comment!=0)||(lignes[k2].typesatellite!=2)) {
						continue;
					}
					pos2=lignes[k2].pos;
					x12=lignes[k2].x1;
					y12=lignes[k2].y1;
					x22=lignes[k2].x2;
					y22=lignes[k2].y2;
				   if (fabs(pos1-pos2)<=10) {
					   if ((x11!=0.0)||(x21!=0.0)) {
							ba=(y21-y11*x21/x11)/(1-x21/x11);
						} else {
						   if (x11==0.0) ba=y11;
						   if (x21==0.0) ba=y21;
						}
						if ((x12!=0.0)||(x22!=0.0)) {
							bb=(y22-y12*x22/x12)/(1-x22/x12);
						} else {
						   if (x12==0.0) bb=y12;
						   if (x22==0.0) bb=y22;
						}
						if (fabs(ba-bb)<=fabs(ba+bb)/100) { /* on apparie les mesures */
							lignes[k2].comment=2;
							lignes[k1].pos=(pos1+pos2)/2;
							// recalculer sep 
							// ra, dec
							if (x11<=x12) {
								lignes[k1].x2=x22;
								lignes[k1].y2=y22;
								lignes[k1].site2=lignes[k2].site2;
								lignes[k1].gisement2=lignes[k2].gisement2;
								lignes[k1].ra2=lignes[k2].ra2;
								lignes[k1].dec2=lignes[k2].dec2;
								lignes[k1].ha2=lignes[k2].ha2;
							} else {
								lignes[k1].x1=x12;
								lignes[k1].y1=y12;
								lignes[k1].site1=lignes[k2].site1;
								lignes[k1].gisement1=lignes[k2].gisement1;
								lignes[k1].ra1=lignes[k2].ra1;
								lignes[k1].dec1=lignes[k2].dec1;
								lignes[k1].ha1=lignes[k2].ha1;
							}
						}
				   }
				}
			}
		 }
	  }

	  /* --- deuxieme passe, on apparie les objects sur les images differentes ---*/
	  /* --- avec matching poursuit a 3 dates ---*/
	  if (matching_poursuit==1) {
		 nifin1=2;
		 nifin2=1;
	  } else {
		 nifin1=1;
		 nifin2=0;
	  }
	  matching_id=0;
	  for (ki1=0;ki1<nimages-nifin1;ki1++) {
		 for (k1=kdebs[ki1];k1<=kfins[ki1];k1++) {
			if ((lignes[k1].comment!=0)||(lignes[k1].typesatellite==2)) continue;
			if ((lignes[k1].typesatellite==2)&&(lignes[k1].sep>5)) continue;
			jd1=lignes[k1].jd;
			ha1=lignes[k1].ha1;
			ra1=lignes[k1].ra1;
			dec1=lignes[k1].dec1;
			for (ki2=ki1+1;ki2<nimages-nifin2;ki2++) {
			   for (k2=kdebs[ki2];k2<=kfins[ki2];k2++) {
				  if ((lignes[k2].comment!=0)||(lignes[k2].typesatellite==2)) {
					 continue;
				  }
				  jd2=lignes[k2].jd;
				  if (fabs(jd2-jd1)>jjdifmin) {
					 continue;
				  }
				  ha2=lignes[k2].ha1;
				  ra2=lignes[k2].ra1;
				  dec2=lignes[k2].dec1;
				  ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep12,&pos12);
				  sep12=sep12/dr;
					// calcul pour evaluer la vitesse angulaire des géo
					//pos1,sep1 diff entre premier image et deuxième image, pos2 et sep2 => 2 et 3ième images, pos3 et sep3 => 1et 3 images
				  ml_sepangle(ra1*dr,ra2*dr,dec1*dr,dec2*dr,&sep1,&pos1);
				  sep1=sep1/dr;
				  pos1=pos1/dr;
				  if (sep12>sepmax) {
					 continue;
				  }
				  if (matching_poursuit==0) {
					 lignes[k2].sep=lignes[k1].sep;
					 lignes[k2].pos=lignes[k1].pos;
					 lignes[k1].kimage1=ki2;
					 lignes[k1].kobject1=k2;
					 lignes[k1].matched++;
					 lignes[k2].matched++;
					 if (strcmp(lignes[k1].matching_id,"")!=0) {
						strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
					 } else {
						matching_id++;
						sprintf(lignes[k1].matching_id,"%013d",matching_id);
						strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
					 }
					 continue;
				  } else {
					 if ((strcmp(lignes[k1].matching_id,lignes[k2].matching_id)!=0)&&(strcmp(lignes[k2].matching_id,"")!=0)) {
						continue;
					 }
				  }
				  for (ki3=ki2+1;ki3<nimages;ki3++) {
					 for (k3=kdebs[ki3];k3<=kfins[ki3];k3++) {
						if ((lignes[k3].comment!=0)||(lignes[k3].typesatellite==2)) {
						   continue;
						}
						jd3=lignes[k3].jd;
						if (fabs(jd3-jd2)>jjdifmin) {
						   continue;
						}
						ha3=lignes[k3].ha1;
						ra3=lignes[k3].ra1;
						dec3=lignes[k3].dec1;
						ml_sepangle(ha2*dr,ha3*dr,dec2*dr,dec3*dr,&sep23,&pos23);
						sep23=sep23/dr;
					
						ml_sepangle(ra2*dr,ra3*dr,dec2*dr,dec3*dr,&sep2,&pos2);
						sep2=sep2/dr;
						pos2=pos2/dr;
						if (sep23>sepmax) {
							continue;
						}
						/* --- matching poursuit --- */
						dha=(ha2-ha1);
						if (dha>180) { dha=360.-dha; }
						if (dha<-180) { dha=360.+dha; }
						ha30=ha1+(ha2-ha1)*(jd3-jd1)/(jd2-jd1);
						ddec=(dec2-dec1);
						dec30=dec1+(dec2-dec1)*(jd3-jd1)/(jd2-jd1);
						ml_sepangle(ha30*dr,ha3*dr,dec30*dr,dec3*dr,&sep,&pos);
						sep=sep/dr;
						if (sep*3600>36.) {
						//if (sep>sepmax) {
						   continue;
						}
						ml_sepangle(ra1*dr,ra3*dr,dec1*dr,dec3*dr,&sep3,&pos3);
						sep3=sep3/dr;
						pos3=pos3/dr;
						lignes[k1].kimage1=ki2;
						lignes[k1].kobject1=k2;
						lignes[k1].kimage2=ki3;
						lignes[k1].kobject2=k3;
						lignes[k1].matched++;
						lignes[k2].matched++;
						lignes[k3].matched++;
						lignes[k1].sep=sep1*3600/(jd2-jd1)/86400;
						lignes[k1].pos=pos1;
						lignes[k2].sep=sep2*3600/(jd3-jd2)/86400;
						lignes[k2].pos=pos2;
						lignes[k3].sep=sep3*3600/(jd3-jd1)/86400;
						lignes[k3].pos=pos3;
						if (lignes[k1].typesatellite==3) {
							lignes[k1].typesatellite=4;
						}
						if (lignes[k2].typesatellite==3) {
							lignes[k2].typesatellite=4;
						}
						if (lignes[k3].typesatellite==3) {
							lignes[k3].typesatellite=4;
						}
						if (strcmp(lignes[k1].matching_id,"")!=0) {
						   strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
						   strcpy(lignes[k3].matching_id,lignes[k1].matching_id);
						} else {
						   matching_id++;
						   sprintf(lignes[k1].matching_id,"%013d",matching_id);
						   strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
						   strcpy(lignes[k3].matching_id,lignes[k1].matching_id);
						}
					 }
				  }
			   }
			}
		 }
	  }
  
      /* --- sauve le resultat dans le fichier de sortie ---*/
      f_in=fopen(argv[2],"wt");
      if (f_in==NULL) {
         sprintf(s,"file_0 %s not created",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         free(kdebs);
         free(kfins);
         return TCL_ERROR;
      }
      fprintf(f_in,"%s",lignes[0].texte);
      fprintf(f_in,"%s",lignes[1].texte);
      fprintf(f_in,"%s",lignes[2].texte);
      kimage=-1;
      for (k=3;k<n_in;k++) {
         if (lignes[k].matched>0) {
            if ((lignes[k].kimage!=kimage)&&(kimage!=-1)) {
               fprintf(f_in,"\n");
            }
			if ((lignes[k].typesatellite==2)&&(lignes[k].comment==0)) {
				sprintf(s,"%1d",lignes[k].typesatellite);
				strcat(lignes[k].texte2,s);
				strcat(lignes[k].texte2," -------------");
				sprintf(s,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
			} else if (lignes[k].typesatellite==4) {
				sprintf(s,"%1d",lignes[k].typesatellite);
				strcat(lignes[k].texte2,s);
				sprintf(s,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
			} else if (lignes[k].comment==0) {
				ns=(int)(strlen(lignes[k].texte));
				texte=lignes[k].texte;
				if (ns>=2) {
					texte[ns-1]='\0';
				}
				sprintf(s,"%s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
			} 
			//strcat(lignes[k].texte,lignes[k].matching_id);
			//fprintf(f_in,"%s",lignes[k].texte);
            //fprintf(f_in," K=%d => matching_id=%s => matched=%d\n",k,lignes[k].matching_id,lignes[k].matched);
            kimage=lignes[k].kimage;
         } else if (lignes[k].typesatellite==3) {
				sprintf(s,"%1d",lignes[k].typesatellite);
				strcat(lignes[k].texte2,s);
				strcat(lignes[k].texte2," -------------");
				sprintf(s,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
		 }
      }
      fclose(f_in);

      /* --- libere les pointeurs --- */
      free(lignes);
      free(kdebs);
      free(kfins);
      result = TCL_OK;
   }
   return result;
}

int Cmd_mltcl_geostatreduc3(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])

/*############################  VERSION 3 allégé pour 2 images  #################################*/
/*************************************************************************************************/
/* Reduction des objets susceptibles etre des satellites geostationnaires sur 2 images.          */
/*************************************************************************************************/
/*
ml_geostatreduc3 bdd00_20070607.txt bdd0_20070607.txt [expr 3.3*5/3600.] [expr 60./3600.] 0.014 1
*/
/*************************************************************************************************/
{
   int result,retour;
   char s[1000],ligne[1000];
   char im0[40],im[40],*texte;
   double sepmin; /* minimum de distance pour deux objets dans la meme image (degrés) */
   double sepmax; /* maximum de distance pour deux objets dans la des images différentes (degrés) */
   double jjdifmin=0.014; /* differences de jours pour autoriser la comparaison */
   FILE *f_in;
   int k,k1,k2,k3,kimage,nimages,kobject=0;
   int n_in,ns;
   struct_ligsat *lignes;
   int *kdebs,*kfins;
   double annee, mois, jour, heure, minute, seconde, jd, pi, dr;
   double ra1,ra2,ra3,ha1,ha2,ha3,dec1,dec2,dec3,sep,pos,jd1,jd2,jd3,sep12,pos12,sep23,pos23,dec30,ha30,sep1,pos1,sep2,pos2,pos3,sep3,dha,ddec;
   int ki1,ki2,ki3;
   int matching_poursuit=1,nifin1,nifin2,matching_id;
   double x11, x21, y11, y21 ,x12, x22, y12, y22, ba, bb;

   if(argc<3) {
      sprintf(s,"Usage: %s file_00 file_0 ?sepmin? ?sepmax? ?jjdifmin? ?matching_poursuit?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      result = TCL_ERROR;
   } else {
      /* --- decode les parametres obligatoires ---*/

      /* --- decode les parametres facultatifs ---*/
      sepmin=3.3*5/3600.; /* default value = 5 pixels pour TAROT */
      if (argc>=4) {
         retour = Tcl_GetDouble(interp,argv[3],&sepmin);
         if(retour!=TCL_OK) return retour;
      }
      sepmax=300./3600.; /* default value = 120 arcsec pour TAROT */
      if (argc>=5) {
         retour = Tcl_GetDouble(interp,argv[4],&sepmax);
         if(retour!=TCL_OK) return retour;
      }
	  jjdifmin=0.014;
      if (argc>=6) {
         retour = Tcl_GetDouble(interp,argv[5],&jjdifmin);
         if(retour!=TCL_OK) return retour;
      }
	  matching_poursuit=1;
      if (argc>=7) {
         retour = Tcl_GetInt(interp,argv[6],&matching_poursuit);
         if(retour!=TCL_OK) return retour;
      }

      /* --- lecture du nombre de lignes dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
            n_in++;
         }
      }
      fclose(f_in);

      /* --- dimensionne la structure des donnees d'entree ---*/
      lignes=(struct_ligsat*)malloc(n_in*sizeof(struct_ligsat));
      if (lignes==NULL) {
         sprintf(s,"error : lignes pointer out of memory (%d elements)",n_in);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }

      /* --- lecture des donnes ligne par ligne dans le fichier d'entree ---*/
      f_in=fopen(argv[1],"rt");
      if (f_in==NULL) {
         sprintf(s,"file_00 %s not found",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         return TCL_ERROR;
      }
      n_in=0;
      strcpy(im0,"");
      kimage=-1;
      while (feof(f_in)==0) {
         if (fgets(ligne,sizeof(ligne),f_in)!=NULL) {
			strcpy(lignes[n_in].texte,ligne);
            lignes[n_in].comment=1;
            lignes[n_in].kimage1=-1;
            lignes[n_in].kobject1=-1;
            lignes[n_in].kimage2=-1;
            lignes[n_in].kobject2=-1;
            lignes[n_in].matched=0;
            lignes[n_in].sep=0.;
            lignes[n_in].pos=0.;
			lignes[n_in].typesatellite=0;
            strcpy(lignes[n_in].ident,"");
            strcpy(lignes[n_in].matching_id,"");
            if (strlen(ligne)>=3) {
               if ((ligne[0]=='I')&&(ligne[1]=='M')&&(ligne[2]=='_')) {
                  lignes[n_in].comment=0;
               }
            }
			if (lignes[n_in].comment==0) {
			   k1=269 ; for (k=k1;k<k1+1;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
			   lignes[n_in].typesatellite=atoi(s);
				strcpy(lignes[n_in].texte,"");
				k1=0 ; k2=270; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				strcpy(lignes[n_in].texte,s);
			   if ((lignes[n_in].typesatellite==2)||(lignes[n_in].typesatellite==3)) { 
					
					strcpy(lignes[n_in].texte,"");
					k1=0 ; k2=84; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes[n_in].texte,s);
					k1=86 ; k2=95; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].gisement1=atof(s);
					k1=97 ; k2=105; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].site1=atof(s);
					k1=107 ; k2=116; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].gisement2=atof(s);
					k1=118 ; k2=126; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].site2=atof(s);
					k1=171 ; k2=181; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].ra2=atof(s);
					k1=182 ; k2=191 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].dec2=atof(s);
					k1=193 ; k2=202 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].ha2=atof(s);
					k1=204 ; k2=212; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].x1=atof(s);
					k1=214 ; k2=223; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].y1=atof(s);
					k1=224 ; k2=232; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].x2=atof(s);
					k1=234 ; k2=242; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].y2=atof(s);
					k1=244 ; k2=268; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					strcpy(lignes[n_in].texte2,s);
					k1=285 ; k2=290; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].sep=atof(s);
					k1=292 ; k2=297; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
					lignes[n_in].pos=atof(s);
					
					if ((fabs(lignes[n_in].x1-lignes[n_in].x2)>20)||(fabs(lignes[n_in].y1-lignes[n_in].y2)>20)) {
						lignes[n_in].matched=1; // mettre a 1 pour qu'il soit tjrs dans le bdd final
						lignes[n_in].kimage=0; // mettre à 0 si on ne le passe pas dans le matching	
					} else {
						lignes[n_in].typesatellite=3; // Défilant qui passent dans la matching poursuite
					}
			   } 
			   	
				k1= 38 ; k2= 41 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				annee=atof(s);
				k1= 43 ; k2= 44 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				mois=atof(s);
				k1= 46 ; k2= 47 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				jour=atof(s); lignes[n_in].jour=atof(s);
				k1= 49 ; k2= 50 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				heure=atof(s); lignes[n_in].heure=atof(s);
				k1= 52 ; k2= 53 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				minute=atof(s); lignes[n_in].minute=atof(s);
				k1= 55 ; k2= 60 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				seconde=atof(s); lignes[n_in].seconde=atof(s);
				ml_date2jd(annee,mois,jour,heure,minute,seconde,&jd);
				lignes[n_in].jd=jd;
				k1=128 ; k2=136 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].mag=atof(s);
				k1=138 ; k2=146; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].ra1=atof(s);
				k1=149 ; k2=158 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].dec1=atof(s);
				k1=160 ; k2=169 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				lignes[n_in].ha1=atof(s);
				k1=  0 ; k2= 36 ; for (k=k1;k<=k2;k++) { s[k-k1]=ligne[k]; } ; s[k-k1]='\0';
				strcpy(im,s);
				if (strcmp(im,im0)!=0) {
					kimage++;
					kobject=0;
				}
				strcpy(im0,im);
				lignes[n_in].kimage=kimage;
				lignes[n_in].kobject=kobject;
				kobject++;

            } else {
               lignes[n_in].ha1=0.;
               lignes[n_in].dec1=0.;
               lignes[n_in].jd=0.;
               lignes[n_in].mag=99.;
               lignes[n_in].kimage=-1;
               lignes[n_in].kobject=-1;
            }
            n_in++;
         }
      }
      fclose(f_in);
      nimages=kimage+1;

	  
	  /* --- dimensionne les tableaux des indices de debut et de fin d'entree ---*/
	  kdebs=(int*)calloc(nimages,sizeof(int));
	  if (kdebs==NULL) {
		 sprintf(s,"error : kdebs pointer out of memory (%d elements)",nimages);
		 Tcl_SetResult(interp,s,TCL_VOLATILE);
		 free(lignes);
		 return TCL_ERROR;
	  }
	  for (k=0;k<nimages;k++) {
		 kdebs[k]=-1;
	  }
	  kfins=(int*)calloc(nimages,sizeof(int));
	  if (kdebs==NULL) {
		 sprintf(s,"error : kfins pointer out of memory (%d elements)",nimages);
		 Tcl_SetResult(interp,s,TCL_VOLATILE);
		 free(lignes);
		 free(kdebs);
		 return TCL_ERROR;
	  }
	  for (k=0;k<nimages;k++) {
		 kfins[k]=0;
	  }

	  /* --- affecte les tableaux des indices de debut et de fin d'entree ---*/
	  for (k=0;k<n_in;k++) {
		 kimage=lignes[k].kimage;
		 if (kimage>=0) {
			if (kdebs[kimage]==-1) {
			   kdebs[kimage]=k;
			}
			if (kfins[kimage]<=k) {
			   kfins[kimage]=k;
			}
		 }
	  }

	  /* --- premiere passe, on elimine les objets multiples sur chaque pose ---*/
	  pi=4.*atan(1.);
	  dr=pi/180.;
	  for (k=0;k<nimages;k++) {
		 for (k1=kdebs[k];k1<=kfins[k]-1;k1++) {
			if (lignes[k1].comment!=0) {
			   continue;
			}	
			if (lignes[k1].typesatellite!=2) {/* pour les geo */
				ha1=lignes[k1].ha1;
				dec1=lignes[k1].dec1;
				for (k2=k1+1;k2<=kfins[k];k2++) {
				   if ((lignes[k2].comment!=0)||(lignes[k2].typesatellite==2)) {
					  continue;
				   }
				   ha2=lignes[k2].ha1;
				   dec2=lignes[k2].dec1;
				   ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep,&pos);
				   sep=sep/dr;
				   if (sep<sepmin) {
					  /* --- on elimine le moins brillant ---*/
					  if (lignes[k1].mag<lignes[k2].mag) {
						 lignes[k2].comment=2;
					  } else {
						 lignes[k1].comment=2;
					  }
				   }
				}
			} else {/* pour les defilants */
				pos1=lignes[k1].pos;
				x11=lignes[k1].x1;
				y11=lignes[k1].y1;
				x21=lignes[k1].x2;
				y21=lignes[k1].y2;
				bb=ba=0;
				for (k2=k1+1;k2<=kfins[k];k2++) {
					if ((lignes[k2].comment!=0)||(lignes[k2].typesatellite!=2)) {
						continue;
					}
					pos2=lignes[k2].pos;
					x12=lignes[k2].x1;
					y12=lignes[k2].y1;
					x22=lignes[k2].x2;
					y22=lignes[k2].y2;
				   if (fabs(pos1-pos2)<=10) {
					   if ((x11!=0.0)||(x21!=0.0)) {
							ba=(y21-y11*x21/x11)/(1-x21/x11);
						} else {
						   if (x11==0.0) ba=y11;
						   if (x21==0.0) ba=y21;
						}
						if ((x12!=0.0)||(x22!=0.0)) {
							bb=(y22-y12*x22/x12)/(1-x22/x12);
						} else {
						   if (x12==0.0) bb=y12;
						   if (x22==0.0) bb=y22;
						}
						if (fabs(ba-bb)<=fabs(ba+bb)/100) { /* on apparie les mesures */
							lignes[k2].comment=2;
							lignes[k1].pos=(pos1+pos2)/2;
							// recalculer sep 
							// ra, dec
							if (x11<=x12) {
								lignes[k1].x2=x22;
								lignes[k1].y2=y22;
								lignes[k1].site2=lignes[k2].site2;
								lignes[k1].gisement2=lignes[k2].gisement2;
								lignes[k1].ra2=lignes[k2].ra2;
								lignes[k1].dec2=lignes[k2].dec2;
								lignes[k1].ha2=lignes[k2].ha2;
							} else {
								lignes[k1].x1=x12;
								lignes[k1].y1=y12;
								lignes[k1].site1=lignes[k2].site1;
								lignes[k1].gisement1=lignes[k2].gisement1;
								lignes[k1].ra1=lignes[k2].ra1;
								lignes[k1].dec1=lignes[k2].dec1;
								lignes[k1].ha1=lignes[k2].ha1;
							}
						}
				   }
				}
			}
		 }
	  }

	  /* --- deuxieme passe, on apparie les objects sur les images differentes ---*/
	  /* --- avec matching poursuit a 2 dates ---*/
	  if (matching_poursuit==1) {
		 nifin1=2;
		 nifin2=1;
	  } else {
		 nifin1=1;
		 nifin2=0;
	  }
	  matching_id=0;
	  for (ki1=0;ki1<nimages-nifin1;ki1++) {
		 for (k1=kdebs[ki1];k1<=kfins[ki1];k1++) {
			if ((lignes[k1].comment!=0)||(lignes[k1].typesatellite==2)) continue;
			if ((lignes[k1].typesatellite==2)&&(lignes[k1].sep>5)) continue;
			jd1=lignes[k1].jd;
			ha1=lignes[k1].ha1;
			ra1=lignes[k1].ra1;
			dec1=lignes[k1].dec1;
			for (ki2=ki1+1;ki2<nimages-nifin2;ki2++) {
			   for (k2=kdebs[ki2];k2<=kfins[ki2];k2++) {
				  if ((lignes[k2].comment!=0)||(lignes[k2].typesatellite==2)) {
					 continue;
				  }
				  jd2=lignes[k2].jd;
				  if (fabs(jd2-jd1)>jjdifmin) {
					 continue;
				  }
				  ha2=lignes[k2].ha1;
				  ra2=lignes[k2].ra1;
				  dec2=lignes[k2].dec1;
				  ml_sepangle(ha1*dr,ha2*dr,dec1*dr,dec2*dr,&sep12,&pos12);
				  sep12=sep12/dr;
					// calcul pour evaluer la vitesse angulaire des géo
					//pos1,sep1 diff entre premier image et deuxième image, pos2 et sep2 => 2 et 3ième images, pos3 et sep3 => 1et 3 images
				  ml_sepangle(ra1*dr,ra2*dr,dec1*dr,dec2*dr,&sep1,&pos1);
				  sep1=sep1/dr;
				  pos1=pos1/dr;
				  if (sep12>sepmax) {
					 continue;
				  }
				  if (matching_poursuit==0) {
					 lignes[k2].sep=lignes[k1].sep;
					 lignes[k2].pos=lignes[k1].pos;
					 lignes[k1].kimage1=ki2;
					 lignes[k1].kobject1=k2;
					 lignes[k1].matched++;
					 lignes[k2].matched++;
					 if (strcmp(lignes[k1].matching_id,"")!=0) {
						strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
					 } else {
						matching_id++;
						sprintf(lignes[k1].matching_id,"%013d",matching_id);
						strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
					 }
					 continue;
				  } else {
					 if ((strcmp(lignes[k1].matching_id,lignes[k2].matching_id)!=0)&&(strcmp(lignes[k2].matching_id,"")!=0)) {
						continue;
					 }
				  }
				  for (ki3=ki2+1;ki3<nimages;ki3++) {
					 for (k3=kdebs[ki3];k3<=kfins[ki3];k3++) {
						if ((lignes[k3].comment!=0)||(lignes[k3].typesatellite==2)) {
						   continue;
						}
						jd3=lignes[k3].jd;
						if (fabs(jd3-jd2)>jjdifmin) {
						   continue;
						}
						ha3=lignes[k3].ha1;
						ra3=lignes[k3].ra1;
						dec3=lignes[k3].dec1;
						ml_sepangle(ha2*dr,ha3*dr,dec2*dr,dec3*dr,&sep23,&pos23);
						sep23=sep23/dr;
					
						ml_sepangle(ra2*dr,ra3*dr,dec2*dr,dec3*dr,&sep2,&pos2);
						sep2=sep2/dr;
						pos2=pos2/dr;
						if (sep23>sepmax) {
							continue;
						}
						/* --- matching poursuit --- */
						dha=(ha2-ha1);
						if (dha>180) { dha=360.-dha; }
						if (dha<-180) { dha=360.+dha; }
						ha30=ha1+(ha2-ha1)*(jd3-jd1)/(jd2-jd1);
						ddec=(dec2-dec1);
						dec30=dec1+(dec2-dec1)*(jd3-jd1)/(jd2-jd1);
						ml_sepangle(ha30*dr,ha3*dr,dec30*dr,dec3*dr,&sep,&pos);
						sep=sep/dr;
						if (sep*3600>36.) {
						//if (sep>sepmax) {
						   continue;
						}
						ml_sepangle(ra1*dr,ra3*dr,dec1*dr,dec3*dr,&sep3,&pos3);
						sep3=sep3/dr;
						pos3=pos3/dr;
						lignes[k1].kimage1=ki2;
						lignes[k1].kobject1=k2;
						lignes[k1].kimage2=ki3;
						lignes[k1].kobject2=k3;
						lignes[k1].matched++;
						lignes[k2].matched++;
						lignes[k3].matched++;
						lignes[k1].sep=sep1*3600/(jd2-jd1)/86400;
						lignes[k1].pos=pos1;
						lignes[k2].sep=sep2*3600/(jd3-jd2)/86400;
						lignes[k2].pos=pos2;
						lignes[k3].sep=sep3*3600/(jd3-jd1)/86400;
						lignes[k3].pos=pos3;
						if (lignes[k1].typesatellite==3) {
							lignes[k1].typesatellite=4;
						}
						if (lignes[k2].typesatellite==3) {
							lignes[k2].typesatellite=4;
						}
						if (lignes[k3].typesatellite==3) {
							lignes[k3].typesatellite=4;
						}
						if (strcmp(lignes[k1].matching_id,"")!=0) {
						   strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
						   strcpy(lignes[k3].matching_id,lignes[k1].matching_id);
						} else {
						   matching_id++;
						   sprintf(lignes[k1].matching_id,"%013d",matching_id);
						   strcpy(lignes[k2].matching_id,lignes[k1].matching_id);
						   strcpy(lignes[k3].matching_id,lignes[k1].matching_id);
						}
					 }
				  }
			   }
			}
		 }
	  }
  
      /* --- sauve le resultat dans le fichier de sortie ---*/
      f_in=fopen(argv[2],"wt");
      if (f_in==NULL) {
         sprintf(s,"file_0 %s not created",argv[1]);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
         free(lignes);
         free(kdebs);
         free(kfins);
         return TCL_ERROR;
      }
      fprintf(f_in,"%s",lignes[0].texte);
      fprintf(f_in,"%s",lignes[1].texte);
      fprintf(f_in,"%s",lignes[2].texte);
      kimage=-1;
      for (k=3;k<n_in;k++) {
         if (lignes[k].matched>0) {
            if ((lignes[k].kimage!=kimage)&&(kimage!=-1)) {
               fprintf(f_in,"\n");
            }
			if ((lignes[k].typesatellite==2)&&(lignes[k].comment==0)) {
				sprintf(s,"%1d",lignes[k].typesatellite);
				strcat(lignes[k].texte2,s);
				strcat(lignes[k].texte2," -------------");
				sprintf(s,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
			} else if (lignes[k].typesatellite==4) {
				sprintf(s,"%1d",lignes[k].typesatellite);
				strcat(lignes[k].texte2,s);
				sprintf(s,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
			} else if (lignes[k].comment==0) {
				ns=(int)(strlen(lignes[k].texte));
				texte=lignes[k].texte;
				if (ns>=2) {
					texte[ns-1]='\0';
				}
				sprintf(s,"%s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].matching_id,lignes[k].sep,lignes[k].pos);
			} 
			//strcat(lignes[k].texte,lignes[k].matching_id);
			//fprintf(f_in,"%s",lignes[k].texte);
            //fprintf(f_in," K=%d => matching_id=%s => matched=%d\n",k,lignes[k].matching_id,lignes[k].matched);
            kimage=lignes[k].kimage;
         } else if (lignes[k].typesatellite==3) {
				sprintf(s,"%1d",lignes[k].typesatellite);
				strcat(lignes[k].texte2,s);
				strcat(lignes[k].texte2," -------------");
				sprintf(s,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
				fprintf(f_in,"%s %010.6f %09.6f %010.6f %09.6f %09.6f %010.6f %+010.6f %010.6f %010.6f %+010.6f %010.6f %09.4f %09.4f %09.4f %09.4f %s %06.2f %06.2f\n",lignes[k].texte,lignes[k].gisement1, lignes[k].site1, lignes[k].gisement2, lignes[k].site2, lignes[k].mag, lignes[k].ra1, lignes[k].dec1, lignes[k].ha1, lignes[k].ra2, lignes[k].dec2,lignes[k].ha2,lignes[k].x1,lignes[k].y1,lignes[k].x2,lignes[k].y2,lignes[k].texte2,lignes[k].sep,lignes[k].pos);
		 }
      }
      fclose(f_in);

      /* --- libere les pointeurs --- */
      free(lignes);
      free(kdebs);
      free(kfins);
      result = TCL_OK;
   }
   return result;
}


int Cmd_mltcl_julianday(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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
      ml_date2jd(y,m,d,hh,mm,ss,&jd);
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

int Cmd_mltcl_infoimage(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne des infos sur l'image presente dans un buffer de AudeLA         */
/****************************************************************************/
/****************************************************************************/
{
   int result,retour;
   Tcl_DString dsptr;
   char s[100];
   ml_image image;
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
      result=mltcl_getinfoimage(interp,numbuf,&image);
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

int mltcl_getinfoimage(Tcl_Interp *interp,int numbuf, ml_image *image)
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

int Cmd_mltcl_fitquadratique(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne le maximum d'une courbe  extrapolee quadratiquement    	    */
/****************************************************************************/
/*  data1 est l'axe des ordonnees => e.g ecart type 			    */
/*  data2 est l'axe des abscisses => e.g valeur focus ADU 		    */
/****************************************************************************/
{
	float maxi_courbe;
	char texte[400];
	char * pEnd;
	double *x, *y;
	int xlenght, ylenght,k, kx, ky, kkx, result;
	double a, b, c, d, p, q, r, s, t, u, v;
	//FILE *fic;
	Tcl_DString dsptr;
	
	if(argc<2) {
      		sprintf(texte,"Usage: %s data_y data_x", argv[0]);
      		Tcl_SetResult(interp,texte,TCL_VOLATILE);
      		result = TCL_ERROR;
  	} else if ((strlen(argv[1])==0)||(strlen(argv[2])==0)) {
  		sprintf(texte,"Attention: %s data_y data_x, data_y et data_x ne doivent pas etre vides", argv[0]);
      		Tcl_SetResult(interp,texte,TCL_VOLATILE);
      		result = TCL_ERROR;
  	} else {
		xlenght=strlen(argv[1]);
		ylenght=strlen(argv[2]);
		/*fic=fopen("log_libml.txt","a");
		fprintf(fic,"%s, %s, %s, %d, %d \n", argv[0], argv[1], argv[2], xlenght, ylenght);	
		fclose(fic);*/
		kx=0; k=0;
		for (k=1; k<xlenght; k++) {
			if (isspace(argv[1][k])) kx++;
		}
		ky=0; k=0;
		for (k=1; k<ylenght; k++) {
			if (isspace(argv[2][k])) ky++;
		}
		// kx et ky sont les nombre d'espace donc kx+1 et ky+1 sont les nombres d'objects dans le liste
		kx++;
		ky++;
		/*fic=fopen("log_libml.txt","a");
		fprintf(fic,"kx %d, ky %d \n", kx, ky);	
		fclose(fic);*/	
		if (kx!=ky ) {
			sprintf(texte,"Attention: %s, data_y et data_x doivent avoir le meme nombre d elements", argv[0]);
      			Tcl_SetResult(interp,texte,TCL_VOLATILE);
      			result = TCL_ERROR;
		} else if ((kx==1)||(ky==1 )) {
			sprintf(texte,"Attention: %s, data_y et data_x doivent avoir plus d elements", argv[0]);
      			Tcl_SetResult(interp,texte,TCL_VOLATILE);
      			result = TCL_ERROR;
      		} else {
			kkx=0;
			x=(double*)calloc(kx,sizeof(double));
			if (x==NULL) {
				sprintf(texte,"error : x pointer out of memory (%d elements)",kx);
				Tcl_SetResult(interp,texte,TCL_VOLATILE);
				free(x);
				return TCL_ERROR;
      			}
			y=(double*)calloc(kx,sizeof(double));
			if (y==NULL) {
				sprintf(texte,"error : y pointer out of memory (%d elements)",kx);
				Tcl_SetResult(interp,texte,TCL_VOLATILE);
				free(y);
				free(x);
				return TCL_ERROR;
			}
			// remplissage de x
			x[0] = strtod (argv[1],&pEnd);
			for (k=1; k<kx-1; k++) {
				x[k] = strtod (pEnd,&pEnd);
			}
			x[kx-1] = strtod (pEnd,NULL);
			
			// remplissage de y
			y[0] = strtod (argv[2],&pEnd);
			for (k=1; k<kx-1; k++) {
				y[k] = strtod (pEnd,&pEnd);
			}
			y[kx-1] = strtod (pEnd,NULL);
		
			p=0; q=0; r=0; s=0; t=0; u=0; v=0;
			for (k=0; k<kx;k++) {
				p +=x[k];
				q +=x[k]*x[k];
				r +=x[k]*x[k]*x[k];
				s +=x[k]*x[k]*x[k]*x[k];
				t +=y[k];
				u +=x[k]*y[k];
				v +=x[k]*x[k]*y[k];
			}
			/* ---  calcul des parametre de la courbe y = ax2 + bx + c  --- */
			d=0; a=0; b=0; c=0;maxi_courbe=0;
			d=kx*q*s+2*p*q*r-q*q*q-p*p*s-kx*r*r;
			/*fic=fopen("log_libml.txt","a");
			fprintf(fic,"calcul des parametres p=%f, q=%f, r=%f, s=%f, t=%f, u=%f, v=%f , d=%f \n", p,q,r,s,t,u,v,d);	
			fclose(fic);*/
			if (d!=0) {
				a=(kx*q*v+p*r*t+p*q*u-q*q*t-p*p*v-kx*r*u)/d;
				b=(kx*s*u+p*q*v+q*r*t-q*q*u-p*s*t-kx*r*v)/d;
				//c=(q*s*t+q*r*u+p*r*v-q*q*v-p*s*u-r*r*t)/d;
				/* --- calcul du maximun de la courbe maxi_x=-b/(2*a) --- */
				maxi_courbe=-(float)(b/(2*a));
				/*fic=fopen("log_libml.txt","a");
				fprintf(fic,"calcul de a=%f, b=%f, maxi=%f \n", a, b, maxi_courbe);	
				fclose(fic);*/
				/*--- initialise la dynamic string ---*/
				Tcl_DStringInit(&dsptr);
				/* --- met en forme le resultat dans une chaine de caracteres ---*/
				sprintf(texte,"%f",maxi_courbe);
				/* --- on ajoute cette chaine a la dynamic string ---*/
				Tcl_DStringAppend(&dsptr,texte,-1);
				/* --- a la fin, on envoie le contenu de la dynamic string dans */
				/* --- le Result qui sera retourne a l'utilisateur. */
				Tcl_DStringResult(interp,&dsptr);
				/* --- desaloue la dynamic string. */
				Tcl_DStringFree(&dsptr);
				
				result = TCL_OK;
			} else {
				sprintf(texte,"Probleme: %s le denominateur est nul", argv[0]);
	      			Tcl_SetResult(interp,texte,TCL_VOLATILE);
	      			result = TCL_ERROR;
			}
			free(x);
			free(y);	
		}
   	}
	return result;
}




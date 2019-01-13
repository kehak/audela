/* ak_3.c
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

/***************************************************************************/
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Ce fichier contient les sources de Yassine.                             */
/***************************************************************************/
#include "ak_3.h"

int Cmd_aktcl_aliasing(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction aliasing                                                        */
/***************************************************************************/
/* Inputs: The jd vector
   Outputs The aliasing periods
/***************************************************************************/
{
	/*Nous allons chercher dans ce script toutes les périodes d'aliasing inférieures à 5j
	car leur influence diminue audela de cette limite : 
	fréquence d'artefact = frequence +/- x*frequence d'aliasing (x=0.5,1,2)*/
	char s[200];
    int code,nmes=0,nbad,nbad1,nbad2;
	double dj,badper,maxim1,maxim2,limit_inf,limit_sup,pgcd;
	int *hist1=NULL,*hist2=NULL;
	int nhist1,nhist2,kj1,kj2,k_hist,k_fact,val,kk,temoin,temoin2,nfact1,nfact2=13;
	gsl_vector *jds;
	double *maximums1=NULL,*maximums2=NULL,*badpers=NULL,facteurs[13];
	Tcl_DString dsptr;
/*FILE *f;*/
	if(argc!=2) {
		sprintf(s,"Usage: %s jd_vector", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		/*Je vais construire 2 histogrammes des périodes d'aliasing 
		1er: P<10.5h avec un pas constant de 10mn (60 cases)
		2eme : P>10h avec un pas constant de 4h centre sur 1 j (157 cases)
		       
		/*Je marrête à 20j : mon histogramme fait 20*12=240 cases */
		nhist1=60;
		nhist2=118;
		limit_sup=20;
		limit_inf=10/24.;
		nfact1=6;
		facteurs[0]=1.;
		facteurs[1]=0.5;
		facteurs[2]=1/3.;
		facteurs[3]=0.25;
		facteurs[4]=2.;
		facteurs[5]=3.;
		facteurs[6]=4;
		facteurs[7]=0.2;
		facteurs[8]=1/6.;
		facteurs[9]=1/7.;
		facteurs[10]=0.125;
		facteurs[11]=1/9.;
		facteurs[12]=0.1;
		/*J'alloue la mémoire: je n'utilise pas de vecteur gsl car c'est un vecteur d'entiers*/
		hist1=(int*)calloc(nhist1,sizeof(int));
		if (hist1==NULL) {
			sprintf(s,"error : hist1 pointer out of memory (%d elements)",nhist1);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            gsl_vector_free(jds);
            return TCL_ERROR;
        }
		hist2=(int*)calloc(nhist2,sizeof(int));
		if (hist2==NULL) {
			sprintf(s,"error : hist2 pointer out of memory (%d elements)",nhist2);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            gsl_vector_free(jds);
			free(hist1);
            return TCL_ERROR;
        }
		/*Je construis mon histogramme*/		
/*f=fopen("init.txt","wt");*/
		temoin=0;
		for (kj1=0;kj1<nmes-1;kj1++) {
            for (kj2=kj1+1;kj2<nmes;kj2++) {
				/*par construction jds est trié*/
                dj=jds->data[kj2]-jds->data[kj1];
				if (dj>limit_sup) {continue;}
				if (dj<limit_inf) {
/*fprintf(f,"%10.8f\n",dj);*/
					k_hist=(int)floor(144*dj);
					/*144=24*6*/
					hist1[k_hist]++;
					temoin++; 
					continue;
				} else {
/*fprintf(f,"%10.8f\n",dj);*/
					k_hist=(int)floor(6*(dj-limit_inf));
					hist2[k_hist]++;
					temoin++; 
				}
			}
		}
/*fclose(f);*/		
		if (temoin!=0) {
            /*Je cherche le maximum de l'histogramme*/
			maxim1=0.;
			for (k_hist=0;k_hist<nhist1;k_hist++) {
				val=hist1[k_hist];
				if (val>maxim1) {maxim1=(double)val;}
			}
			maxim1=0.5*maxim1;
			maxim2=0.;
			for (k_hist=0;k_hist<nhist2;k_hist++) {
				val=hist2[k_hist];
				if (val>maxim2) {maxim2=(double)val;}
			}
			maxim2=0.75*maxim2;

/*maxim=0.;*/
			/*Je compte le nombre de cases > maxim*/
			/*on applique un traitement séparé pour les périodes <0.5j (car divise ts les autres)*/
			kk=0;
			for (k_hist=0;k_hist<nhist2;k_hist++) {
				val=hist2[k_hist];
				if (val>=maxim2) {
					kk++;
				}
			}
            nbad2=kk;
			if (maxim1>maxim2) {
				kk=0;
				for (k_hist=0;k_hist<nhist1;k_hist++) {
					val=hist1[k_hist];
					if (val>=maxim1) {
						kk++;
					}
				}
				nbad1=kk;
				/*Allocation de la memoire*/
				maximums1=(double*)calloc(nbad1*nfact1,sizeof(double));
				if (maximums1==NULL) {
					sprintf(s,"error : maximums pointer out of memory (%d elements)",nbad1*nfact1);
					Tcl_SetResult(interp,s,TCL_VOLATILE);
					gsl_vector_free(jds);
					free(hist1);
					free(hist2);
					return TCL_ERROR;
				}
				/*Je remplis maximums1 en tenant compte des facteurs multiplicatifs*/
				kk=0;
				for (k_hist=0;k_hist<nhist1;k_hist++) {
					val=hist1[k_hist];
					if (val>=maxim1) {
                        for (k_fact=0;k_fact<nfact1;k_fact++) {
							badper=(k_hist+0.5)/144;
							maximums1[kk+k_fact*nbad1]=badper*facteurs[k_fact];;
						}
						kk++;
					}
				}
				nbad1*=nfact1;
			} else {
				nbad1=0;
			}
			/*J'alloue le vecteur des badpers*/
			if (nbad2<nfact2){nbad2=nfact2;} 
			maximums2=(double*)calloc(nbad2,sizeof(double));
			if (maximums2==NULL) {
				sprintf(s,"error : maximums2 pointer out of memory (%d elements)",nbad2);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				gsl_vector_free(jds);
				return TCL_ERROR;
			}
			/*je remplis ce vecteur*/
			kk=0;
			for (k_hist=0;k_hist<nhist2;k_hist++) {
				val=hist2[k_hist];
				if (val>=maxim2) {
					maximums2[kk]=(k_hist+0.5)/6.+limit_inf;
					kk++;
				}
			}
			ak_util_qsort_double(maximums2,0,kk,NULL);
			yd_util_pgcd(maximums2,kk,0.25,0.01,&pgcd,&temoin2);
			if (temoin2==1) {
				 for (k_fact=0;k_fact<nfact2;k_fact++) {
					maximums2[k_fact]=pgcd*facteurs[k_fact];;
				}
			} else {
				nbad2=0;
			}
			/*Je vais maintenant coller les 2 vecteurs maximums et les trier*/
			nbad=nbad1+nbad2;
			if (nbad==0) {nbad=1;}
            badpers=(double*)calloc(nbad,sizeof(double));
			if (badpers==NULL) {
				sprintf(s,"error : badpers pointer out of memory (%d elements)",nbad);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				gsl_vector_free(jds);
				free(hist1);
				free(hist2);
				return TCL_ERROR;
			}
			if (nbad1>0) {
				for (kk=0;kk<nbad1;kk++) {
					badpers[kk]=maximums1[kk];
				}
			}
			if (nbad2>0) {
				for (kk=0;kk<nbad2;kk++) {
					badpers[nbad1+kk]=maximums2[kk];
				}
			}
			ak_util_qsort_double(badpers,0,nbad,NULL);
		} else {
			nbad=1;
			badpers=(double*)calloc(nbad,sizeof(double));
			badpers[0]=0;
		}
	    /* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		for (kk=0;kk<nbad;kk++) {
            sprintf(s,"%14.6f",badpers[kk]);
			Tcl_DStringAppend(&dsptr,s,-1);
		}	
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		free(badpers);
		gsl_vector_free(jds);
		free(hist1);
		free(hist2);
		if (nbad1>0) {free(maximums1);}
		if (nbad2>0) {free(maximums2);}
		return TCL_OK;
    }
}


int Cmd_aktcl_minlong(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction minlong                                                        */
/***************************************************************************/
/* Inputs: 1) The jd vector
           2) The mag vector
		   3) The aliasing periods vector
		   4) The number of selected periods nper
		   5) The smallest authorized period per_range_min
		   6) The highest authorized period  per_range_max
   Outputs 1) The number of kept trial periods
		   2) Total trial periods number
		   3) The best periods vector
	       4) The best "Tetas" vector
		   5) The best phases matrix
/***************************************************************************/
{
	char s[200];
    int code,code2,code3;
    int n_jd=0,n_mag=0,nbad=0,nmes;
    Tcl_DString dsptr;
    gsl_matrix *phases;
    gsl_vector *jds,*mags,*badpers,*periodes,*tetas,*jds2,*mags2,*phase,*phase2,*temp,*temp2;
	/**histo_phase,*/
	int nper,nper2;
	double err,delmag,eps,minmag,maxmag,phi;
	double per,somme,maxim,phase_prec,phase_suiv,mag_prec,mag_suiv,nu,delta_mag,delta_phi;
	int k_x,k_xx,kk,k_per,nrej,k_bad,i_per;
	gsl_permutation *perm,*perm2;
    double ni_per,dper,dper_lim,accu;
	double per_range_min,per_range_max,duree,per_range_max2;
	int temoin,temoin2,indice_prem_date,indice_dern_date,compteur,compteur_date;
    /*FILE *f;*/
    if(argc!=9) {
		sprintf(s,"Usage: %s Invalid number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&badpers,&nbad);
		nper=atoi(argv[4]);
		per_range_min=atof(argv[5]);
		per_range_max=atof(argv[6]);
		accu=atof(argv[7]);
		dper_lim=atof(argv[8])/24./3600.;
        /* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"Input vectors must have the same dimension",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		nmes=n_jd;
		err=5e-2;
		/*A changer en gsl_vector_minmax*/
		gsl_vector_minmax(mags,&minmag,&maxmag);
		delmag=maxmag-minmag;
		eps=err/(2*delmag);
		/*accu=0.1;
		dper_lim=0.5/24/3600;*/
        
		/* Je calcule maintenant le vecteur des periodes en excluant les periodes d'aliasing*/
		yd_perchoice(jds,nmes,&temoin,&indice_prem_date,&indice_dern_date);
		/*Je n'ai plus besoin de badpers*/
		/*Nous savons que lorsque temoin=1 (la durée>1an et nmes_duree>10), et d'après des tests
		préalables : le nombre de périodes testées est supérieur à notre nper=100 ou 1000*/		
		
		per=per_range_min;
		dper=dper_lim;
		k_per=0;
		nrej=0;
		/*
		% 'effectue une boucle de k itérations dans laquelle je sauvegarde 
		% dans la variable 'matrice': la fréquence, Teta, et le vecteur phase 
		% correspondant à cette fréquence.
		*/
		compteur_date=indice_dern_date-indice_prem_date+1;
		jds2=gsl_vector_calloc(compteur_date);
		mags2=gsl_vector_calloc(compteur_date);
		/*je copie la partie de jds dans jds2*/
		for (k_x=0;k_x<compteur_date;k_x++) {
			jds2->data[k_x]=jds->data[k_x+indice_prem_date];
			mags2->data[k_x]=mags->data[k_x+indice_prem_date];
		}
		temp=gsl_vector_calloc(nmes);
		temp2=gsl_vector_calloc(compteur_date);
		phase2=gsl_vector_calloc(compteur_date);
		perm2=gsl_permutation_alloc(compteur_date);
		if (temoin==1) {
			per_range_max2=jds2->data[compteur_date-1]-jds2->data[0];
			duree=per_range_max2;
			phase=gsl_vector_calloc(nmes);
			perm=gsl_permutation_alloc(nmes);			
		} else {
            per_range_max2=per_range_max;
			duree=per_range_max/2;
		}		
        periodes=gsl_vector_calloc(nper);
		tetas=gsl_vector_calloc(nper);
		/*histo_phase=gsl_vector_calloc(nhisto);*/
		
		k_bad=0;

		while (k_per<nper) {
			if (per>=per_range_max2) {
				break;
			}
			/*je determine le pas pour la prochaine periode*/
			ni_per=floor(duree/per);
			if (ni_per==0.) {
				ni_per=ni_per+1;
			}
			dper=accu*per/ni_per;
			if (dper<dper_lim) {
				dper=dper_lim;
			}
			/*Je regarde si cette période correspond à une période aliasing*/
			yd_dichotomie(per,badpers,nbad,&temoin2,&k_bad);
			if (temoin2==1) {
				per=per+dper;
				nrej++;
				continue;
			}
			gsl_vector_memcpy(temp2,jds2);
			gsl_vector_scale(temp2,1/per);
			gsl_vector_add_constant(temp2,-temp2->data[0]);
			/*Je calcule en même temps l'histogramme des phase:toute phase remplie a moins de 30% sera rejetee*/ 
			/*for (ind_histo=0;ind_histo<nhisto;ind_histo++) {
				histo_phase->data[ind_histo]=0;
			}*/
			for (k_x=0;k_x<compteur_date;k_x++) {
				phase2->data[k_x]=temp2->data[k_x]-floor(temp2->data[k_x]);
				/*ind_histo=(int)floor(phase2->data[k_x]*10);
				if (ind_histo>9) {
					ind_histo=0;
				}
				histo_phase->data[ind_histo]++;*/
				
			}
			/*k_hist=0;
			for (ind_histo=0;ind_histo<nhisto;ind_histo++) {
				if (histo_phase->data[ind_histo]==0) {
					k_hist++;
				}
			}
			if (k_hist>3) {
				per=per+dper;
				continue;
			}*/
			gsl_sort_vector_index(perm2,phase2); 
			k_xx=perm2->data[compteur_date-1];
			phase_prec=phase2->data[k_xx];
			mag_prec=mags2->data[k_xx];
			nu=1.;
			/*nu=1 que pour le 1er élément*/
			k_x=1;
			somme=0;
			while (k_x<compteur_date+1) {
				k_xx=perm2->data[k_x-1];
				phase_suiv=phase2->data[k_xx];
				mag_suiv=mags2->data[k_xx];
				delta_phi=phase_suiv-phase_prec+nu+eps;
				delta_mag=mag_suiv-mag_prec;
				delta_mag*=delta_mag;
				somme+=delta_mag/delta_phi;
				k_x++;
				phase_prec=phase_suiv;
				mag_prec=mag_suiv;
				nu=0;
			}
			periodes->data[k_per]=per;
			tetas->data[k_per]=somme;
			k_per++;
			per=per+dper;
		}
        /*
		% Je fais une deuxième boucle sur le reste des fréquences en remplaçant 
		% les lignes de la variable 'matrice'par les lignes [fréquence, Teta, phase]
		% dont Teta est plus petit que celui dans la ligne remplacée.
		*/
		while (per<=per_range_max2) {
			/*je determine le pas pour la prochaine periode*/
			ni_per=floor(duree/per);
			if (ni_per==0.) {
				ni_per=ni_per+1;
			}
			dper=accu*per/ni_per;
			if (dper<dper_lim) {
				dper=dper_lim;
			}
			/*Je regarde si cette période correspond à une période aliasing*/
			yd_dichotomie(per,badpers,nbad,&temoin2,&k_bad);
			if (temoin2==1) {
				per=per+dper;
				nrej++;
				continue;
			}
			gsl_vector_memcpy(temp2,jds2);
			gsl_vector_scale(temp2,1/per);
			gsl_vector_add_constant(temp2,-temp2->data[0]);
			/*Je calcule en même temps l'histogramme des phase:toute phase remplie a moins de 30% sera rejetee*/ 
			/*for (ind_histo=0;ind_histo<nhisto;ind_histo++) {
				histo_phase->data[ind_histo]=0;
			}*/
			for (k_x=0;k_x<compteur_date;k_x++) {
				phase2->data[k_x]=temp2->data[k_x]-floor(temp2->data[k_x]);
				/*ind_histo=(int)floor(phase2->data[k_x]*10);
				if (ind_histo>9) {
					ind_histo=0;
				}
				histo_phase->data[ind_histo]++;*/
			}
			/*k_hist=0;
			for (ind_histo=0;ind_histo<nhisto;ind_histo++) {
				if (histo_phase->data[ind_histo]==0) {
					k_hist++;
				}
			}
			if (k_hist>3) {
				per=per+dper;
				continue;
			}*/
			gsl_sort_vector_index(perm2,phase2); 
			k_xx=perm2->data[compteur_date-1];
			phase_prec=phase2->data[k_xx];
			mag_prec=mags2->data[k_xx];
			nu=1.;
			/*nu=1 que pour le 1er élément*/
			k_x=1;
			somme=0;
			while (k_x<compteur_date+1) {
				k_xx=perm2->data[k_x-1];
				phase_suiv=phase2->data[k_xx];
				mag_suiv=mags2->data[k_xx];
				delta_phi=phase_suiv-phase_prec+nu+eps;
				delta_mag=mag_suiv-mag_prec;
				delta_mag*=delta_mag;
				somme+=delta_mag/delta_phi;
				k_x++;
				phase_prec=phase_suiv;
				mag_prec=mag_suiv;
				nu=0;
			}
			kk=gsl_vector_max_index(tetas);
			maxim=tetas->data[kk];
			if (somme<maxim) {
				periodes->data[kk]=per;
				tetas->data[kk]=somme;
			}
			k_per++;
			per=per+dper;
		}
		compteur=k_per;
		if (temoin==1) {
			/* je cherche en plus des periodes entre 2 mois et per_range_max*/ 
			per=60;
			while (per<=per_range_max) {
				/*je determine le pas pour la prochaine periode*/
				ni_per=floor(duree/per);
				if (ni_per==0.) {
					ni_per=ni_per+1;
				}
				dper=accu*per/ni_per;
				if (dper<dper_lim) {
					dper=dper_lim;
				}
				/*Je regarde si cette période correspond à une période aliasing*/
				yd_dichotomie(per,badpers,nbad,&temoin2,&k_bad);
				if (temoin2==1) {
					per=per+dper;
					nrej++;
					continue;
				}
				gsl_vector_memcpy(temp,jds);
				gsl_vector_scale(temp,1/per);
				gsl_vector_add_constant(temp,-temp->data[0]);
				/*Je calcule en même temps l'histogramme des phase:toute phase remplie a moins de 30% sera rejetee*/
				/*for (ind_histo=0;ind_histo<nhisto;ind_histo++) {
					histo_phase->data[ind_histo]=0;
				}*/
			    for (k_x=0;k_x<nmes;k_x++) {
					phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
					/*ind_histo=(int)floor(phase->data[k_x]*10);
					if (ind_histo>9) {
						ind_histo=0;
					}
					histo_phase->data[ind_histo]++;*/
				}
				/*k_hist=0;
				for (ind_histo=0;ind_histo<nhisto;ind_histo++) {
					if (histo_phase->data[ind_histo]==0) {
						k_hist++;
					}
				}
				if (k_hist>3) {
					per=per+dper;
					continue;
				}*/
				gsl_sort_vector_index(perm,phase); 
				k_xx=perm->data[nmes-1];
				phase_prec=phase->data[k_xx];
				mag_prec=mags->data[k_xx];
				nu=1.;
				/*nu=1 que pour le 1er élément*/
				k_x=1;
				somme=0;
				while (k_x<nmes+1) {
					k_xx=perm->data[k_x-1];
					phase_suiv=phase->data[k_xx];
					mag_suiv=mags->data[k_xx];
					delta_phi=phase_suiv-phase_prec+nu+eps;
					delta_mag=mag_suiv-mag_prec;
					delta_mag*=delta_mag;
					somme+=delta_mag/delta_phi;
					k_x++;
					phase_prec=phase_suiv;
					mag_prec=mag_suiv;
					nu=0;
				}
				if (compteur<nper) {
					periodes->data[compteur]=per;
					tetas->data[compteur]=somme;
					compteur++;
				} else {
                    kk=gsl_vector_max_index(tetas);
				    maxim=tetas->data[kk];
				    if (somme<maxim) {
						periodes->data[kk]=per;
						tetas->data[kk]=somme;
					}
				}
				k_per++;
				per=per+dper;
			}
        }
		/*Maintenant je compte le nombres de periodes car il se peut que c'est différent de nper
		Ensuite je recalcule la matrice des phases (1 vecteur phase pour chaque période)*/
		if (compteur>nper) {
			nper2=nper;
		} else {
			nper2=compteur;
		}
		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		sprintf (s,"%d",k_per);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf (s,"%d",nrej);
		Tcl_DStringAppend(&dsptr,s,-1);
		if (nper2>0) {
            phases=gsl_matrix_calloc(nper2,nmes);
			for (i_per=0;i_per<nper2;i_per++) {
				per=periodes->data[i_per];
				gsl_vector_memcpy(temp,jds);
				gsl_vector_scale(temp,1/per);
				gsl_vector_add_constant(temp,-temp->data[0]);
				for (k_x=0;k_x<nmes;k_x++) {
					phi=temp->data[k_x]-floor(temp->data[k_x]);
					gsl_matrix_set(phases,i_per,k_x,phi);
				}
			}
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,periodes,nper2);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,tetas,nper2);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslmatrix(interp,&dsptr,phases,nper2,nmes);
			/* --- liberation de la memoire ---*/		
			gsl_matrix_free(phases);
		}			
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(jds2);
		gsl_vector_free(mags2);
		gsl_vector_free(temp2);
		gsl_vector_free(phase2);
		gsl_permutation_free(perm2);
        gsl_vector_free(temp);
		if (temoin==1) {
            gsl_vector_free(phase);
	        gsl_permutation_free(perm);
		}
		gsl_vector_free(periodes);
		gsl_vector_free(tetas);
		gsl_vector_free(badpers);
		/*gsl_vector_free(histo_phase);*/
		return TCL_OK;
    }
}

/****************************************************************************/
int Cmd_aktcl_periodog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction periodog                                                        */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The perods vector
   Outputs: The periodogram vector (Scargle 1982)
*/
/***************************************************************************/
{
    char s[200];
    int code,code2,code3;
    int n_jd=0,n_mag=0,nper=0,nmes;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*periods;
    gsl_vector *Arg,*tem0,*Pxw;
	double Axc,Axs,Ax1,Ax2,Axc_som,Axs_som;
	int i,j;
	double pi,om,tau_s,tau_c,tau;
	double moy,noise;

    if(argc!=4) {
		sprintf(s,"Usage: %s Inputs must be 3 vectors", argv[0]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
    } else {
		/* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&periods,&nper);
		/* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
			Tcl_SetResult(interp,"JDS and MAG vectors must have the same length",TCL_VOLATILE);
			return TCL_ERROR;
		}
		/* --- inits ---*/
        Pxw=gsl_vector_calloc(nper);
		pi   = 4*atan(1);
		nmes=n_jd;
		moy=0.;
		noise=0.;
		for (i=0;i<nmes;i++){
			moy   += mags->data[i];
			noise += mags->data[i]*mags->data[i];
		}
        moy   = moy/nmes;
		noise = (noise-nmes*moy*moy)/(nmes-1);
        tem0=gsl_vector_calloc(nmes);
		gsl_vector_memcpy(tem0,mags);
		gsl_vector_add_constant(tem0, -moy);
        Arg =gsl_vector_calloc(nmes);
        for (i=0; i<nper;i++){
			om   = 2*pi/periods->data[i];
			tau_s=0;
            tau_c=0;
			for(j=0;j<nmes;j++){
				tau_s += sin(2*om*jds->data[j]);
				tau_c += cos(2*om*jds->data[j]);
			}
			tau = tau_s/tau_c;
			tau =atan(tau)/(2*om);
	 		gsl_vector_memcpy(Arg,jds);
			gsl_vector_add_constant(Arg,-tau);
			gsl_vector_scale (Arg,om);
			Ax1    =0;
			Ax2    =0;
			Axc_som=0;
			Axs_som=0;
			for (j=0;j<nmes;j++){
				Axc = cos(Arg->data[j]);
				Ax1 += tem0->data[j]*Axc;
				Axs = sin(Arg->data[j]);
				Ax2 += tem0->data[j]*Axs;
				Axc_som += Axc*Axc;
				Axs_som += Axs*Axs;
			}
			Ax1*=Ax1;
			Ax2*=Ax2;
            Pxw->data[i]=0.5*((Ax1/Axc_som)+(Ax2/Axs_som))/noise;
		}
		/* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        gsltcltcl_setgslvector(interp,&dsptr,Pxw,nper);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
	    gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(periods);
		gsl_vector_free(Pxw);
		gsl_vector_free(tem0);
		gsl_vector_free(Arg);
		}		
	return TCL_OK;
}

/****************************************************************************/
int Cmd_aktcl_entropie_pdm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction maillage                                                        */
/***************************************************************************/
/* Inputs : 1) The phase vector
			2) The mags vector
			3) The number of bins
   Outputs: 1) The entropy matrix (Cincotta 1995)
			2) The PDM value (Maraco 1982)
*/
/***************************************************************************/
{
    char s[200];
    int code,code2;
    int nbin=0,n_jd=0,n_mag=0,nmes;
    int n,i,j;
	Tcl_DString dsptr;
    gsl_matrix *EntMat,*ValMat;
    gsl_vector *phase,*mags,*somlig;
	double err,maxmag,minmag,delmag,val,PDM,eps=2.2204e-16,covar,valx,mag_variance,phase_variance,Entropie;
	int x_pos,y_pos;

    if(argc!=4) {
		sprintf(s,"Usage: %s Inputs must be 2 vectors and a number", argv[0]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
     } else {
		/* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&phase,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		nbin=atoi(argv[3]);
        /* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"The phase and the mags vectors must have the same length",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		err =0.05;
		nmes=n_jd;
		/*A changer en gsl_vector_minmax*/
		minmag   =gsl_vector_min(mags);
		maxmag   =gsl_vector_max(mags);
        delmag   =maxmag-minmag;

		n              =(int)floor(delmag/err)+1;
        EntMat         =gsl_matrix_calloc(n,nbin);
		ValMat         =gsl_matrix_calloc(nbin,5);
		somlig         =gsl_vector_calloc(nbin);
		
		for (i=0;i<nmes;i++) {
			x_pos=(int)floor(phase->data[i]*nbin);
			if (x_pos>=nbin) {
				x_pos=nbin-1;
			}
			if (x_pos<0) {
				x_pos=0;
			}
			y_pos=(int)floor(n*(mags->data[i]-minmag)/(delmag+1e-5));
			if (y_pos>=n) {
				y_pos=n-1;
			}
			if (y_pos<0) {
				y_pos=0;
			}
		    gsl_matrix_set(EntMat,y_pos,x_pos,gsl_matrix_get(EntMat,y_pos,x_pos)+1);
			val=gsl_vector_get(mags,i);
			valx=gsl_vector_get(phase,i);
			/* Somme des mag*/
		    gsl_matrix_set(ValMat,x_pos,0,gsl_matrix_get(ValMat,x_pos,0)+val);
            /* Somme des mag^2*/
		    gsl_matrix_set(ValMat,x_pos,1,gsl_matrix_get(ValMat,x_pos,1)+val*val);
            /* Somme des phase*/
            gsl_matrix_set(ValMat,x_pos,2,gsl_matrix_get(ValMat,x_pos,2)+valx);
			/* Somme des phase^2*/
			gsl_matrix_set(ValMat,x_pos,3,gsl_matrix_get(ValMat,x_pos,3)+valx*valx);
			/* Somme des phase*mag*/
			gsl_matrix_set(ValMat,x_pos,4,gsl_matrix_get(ValMat,x_pos,4)+valx*val);
		}
		PDM=0;
		for (i=0;i<nbin;i++) {
			for (j=0;j<n;j++) {
				somlig->data[i]+=gsl_matrix_get(EntMat,j,i);
			}
		    mag_variance=gsl_matrix_get(ValMat,i,1)-gsl_matrix_get(ValMat,i,0)*gsl_matrix_get(ValMat,i,0)/(somlig->data[i]+eps);
		    phase_variance=gsl_matrix_get(ValMat,i,3)-gsl_matrix_get(ValMat,i,2)*gsl_matrix_get(ValMat,i,2)/(somlig->data[i]+eps);
            covar = gsl_matrix_get(ValMat,i,4)-gsl_matrix_get(ValMat,i,0)*gsl_matrix_get(ValMat,i,2)/(somlig->data[i]+eps);
            PDM+=mag_variance-covar*covar/(phase_variance+eps);
		}
		/*Normalisation*/
		gsl_matrix_scale(EntMat,1./nmes);
		yd_entropie(EntMat,n,nbin,&Entropie);
		/* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        Tcl_DStringAppend(&dsptr,"{",-1);
		sprintf(s,"%f",Entropie);
		Tcl_DStringAppend(&dsptr,s,-1);
        Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%f",PDM);
		Tcl_DStringAppend(&dsptr,s,-1);
        Tcl_DStringAppend(&dsptr,"}",-1);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(phase);
		gsl_vector_free(mags);
		gsl_matrix_free(EntMat);
		gsl_matrix_free(ValMat);
		gsl_vector_free(somlig);
	}
	return TCL_OK;
}

/****************************************************************************/
int yd_entropie(gsl_matrix *EntMat,int n,int m,double *Entropie)
/***************************************************************************/
/* Fonction entropie                                                        */
/***************************************************************************/
/* Inputs : The probability matrix
   Outputs: The entropy value
*/
/***************************************************************************/
{
    int i,j;
    double val,eps=2.2204e-16;
	*Entropie=0;
	for (i=0;i<m;i++) {
		for (j=0;j<n;j++) {
			val       =gsl_matrix_get(EntMat,j,i);
			*Entropie+=-val*log(val+eps);
		}      
    }
	/*Normalisation*/
	*Entropie=*Entropie/(log(n*m));
	return TCL_OK;
}
/****************************************************************************/
int Cmd_aktcl_entropie_phase(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction entropie_phase                                                        */
/***************************************************************************/
/* Inputs : The probability vector along the phase axix (dimension=nbin)
   Outputs: The number of empty bins
*/
/***************************************************************************/
{
    char s[200];
    int code;
    int i,m=0;
    Tcl_DString dsptr;
    gsl_vector *somlig;
	double val;
	int Entropie_phase;
    if(argc!=2) {
		sprintf(s,"Usage: %s ListVector:somlig", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
		/* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&somlig,&m);
        /* --- inits ---*/
		Entropie_phase=0;
		for (i=0;i<m;i++) {
			val=gsl_vector_get(somlig,i);
			if (val==0) {
                Entropie_phase++;
			}
        }
		/* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        sprintf (s,"%d",Entropie_phase);
        Tcl_DStringAppend(&dsptr,s,-1);		
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(somlig);
	}
	return TCL_OK;
}
/****************************************************************************/
int Cmd_aktcl_entropie_modifiee(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction entropie_modifiee                                                        */
/***************************************************************************/
/* Inputs : 1) The total entropy value
			2) The entropy along the phase axis
   Outputs: The modified total entropy value
*/
/***************************************************************************/
{
    char s[200];
    int code,code2;
    int i,k1=0,k2=0,k;
    Tcl_DString dsptr;
    gsl_vector *Entropie,*Entropie_phase;
    double val,inf=1e+40;
    if(argc!=3) {
		sprintf(s,"Usage: %s ListVector:Entropie ListVector:Entropie_phase", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
		/* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&Entropie,&k1);
        code2=gsltcltcl_getgslvector(interp,argv[2],&Entropie_phase,&k2);
		/* --- validite des arguments ---*/
		if (k1!=k2) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"The input vectors must have the same length",TCL_VOLATILE);
            return TCL_ERROR;
		}		
		/* --- inits ---*/
		k=k1;
		for (i=0;i<k;i++) {
			val=gsl_vector_get(Entropie_phase,i);
			if (val>3) {
				/*plus de 3 cases vides*/
				Entropie->data[i]=inf;
			}
        }
		/* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        gsltcltcl_setgslvector(interp,&dsptr,Entropie,k);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(Entropie);
        gsl_vector_free(Entropie_phase);
	}
	return TCL_OK;
}
/****************************************************************************/
int Cmd_aktcl_classification(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction classification (with periodogram)                             */
/***************************************************************************/
/* Inputs : 1) The periods vector
			2) N (vector,weight): each vector represents a statistic
			3) The number of final periods
   Outputs: Final periods
*/
/***************************************************************************/
{
    char s[200];
    int code,code1,code2,code3,code4;
    int i,j,k=0,nper=0;
	double w_period,w_minlong,w_periodog,w_PDM,w_Entropie,somme_w;
	Tcl_DString dsptr;
    gsl_permutation *perm1,*rank1;
    gsl_permutation *perm2,*rank2;
	gsl_permutation *perm3,*rank3;
	gsl_permutation *perm4,*rank4;
	gsl_permutation *perm5,*rank5;
    gsl_permutation *perm6;
	gsl_vector *periods,*period_temp,*minlong,*periodog,*PDM,*Entropie,*best_periods, *perm;
	if(argc!=12) {
		sprintf(s,"Usage: %s Incorrect number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
      /* --- decodage des arguments ---*/
        code = gsltcltcl_getgslvector(interp,argv[1],&periods,&k);
		code1=gsltcltcl_getgslvector(interp,argv[2],&minlong,&k);
        code2=gsltcltcl_getgslvector(interp,argv[3],&periodog,&k);
	    code3=gsltcltcl_getgslvector(interp,argv[4],&PDM,&k);
		code4=gsltcltcl_getgslvector(interp,argv[5],&Entropie,&k);
		w_period=atof(argv[6]);
		w_minlong=atof(argv[7]);
		w_periodog=atof(argv[8]);
		w_PDM=atof(argv[9]);
		w_Entropie=atof(argv[10]);
        nper = atoi(argv[11]);	
		/* --- inits ---*/
		somme_w=w_period+w_minlong+w_periodog+w_PDM+w_Entropie;
		perm1=gsl_permutation_alloc(k);
		perm2=gsl_permutation_alloc(k);
		perm3=gsl_permutation_alloc(k);
		perm4=gsl_permutation_alloc(k);
		perm5=gsl_permutation_alloc(k);
		rank1=gsl_permutation_alloc(k);
		rank2=gsl_permutation_alloc(k);
		rank3=gsl_permutation_alloc(k);
		rank4=gsl_permutation_alloc(k);
		rank5=gsl_permutation_alloc(k);
		perm6=gsl_permutation_alloc(k);
        period_temp=gsl_vector_calloc(k);

		if (w_period!=0) {
			gsl_vector_memcpy(period_temp,periods);
			gsl_vector_scale(period_temp,-1);   
			gsl_sort_vector_index(perm1,period_temp);
			gsl_permutation_inverse (rank1,perm1);
		}
		if (w_minlong!=0) {
			gsl_sort_vector_index(perm2,minlong); 
			gsl_permutation_inverse (rank2,perm2);
		}
		if (w_periodog!=0) {
			gsl_vector_scale(periodog,-1);   
			gsl_sort_vector_index(perm3,periodog);
			gsl_permutation_inverse (rank3,perm3);
		}
		if (w_PDM!=0) {
            gsl_sort_vector_index(perm4,PDM); 
		gsl_permutation_inverse (rank4,perm4);
		}
        if (w_Entropie!=0) {
			gsl_sort_vector_index(perm5,Entropie);
			gsl_permutation_inverse (rank5,perm5);
		}
		
		perm=gsl_vector_alloc(k);
		for (i=0;i<k;i++) {
			perm->data[i]=w_period*rank1->data[i]+w_minlong*rank2->data[i]+w_periodog*rank3->data[i]+w_PDM*rank4->data[i]+w_Entropie*rank5->data[i];
			perm->data[i]=perm->data[i]/somme_w;
		}		
		gsl_sort_vector_index(perm6,perm);
		best_periods = gsl_vector_calloc(nper);
		if (k<nper) {nper=k;}
		for (i=0;i<nper;i++){
			j=perm6->data[i];
			best_periods->data[i]=periods->data[j];
        }
        /* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        gsltcltcl_setgslvector(interp,&dsptr,best_periods,nper);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(periods);
        gsl_vector_free(minlong);
		gsl_vector_free(periodog);
        gsl_vector_free(PDM);
        gsl_vector_free(Entropie);
		gsl_permutation_free(perm1);
        gsl_permutation_free(perm2);
		gsl_permutation_free(perm3);
		gsl_permutation_free(perm4);
		gsl_permutation_free(perm5);
		gsl_permutation_free(perm6);
		gsl_permutation_free(rank1);
        gsl_permutation_free(rank2);
		gsl_permutation_free(rank3);
		gsl_permutation_free(rank4);
		gsl_permutation_free(rank5);
		gsl_vector_free(period_temp);
		gsl_vector_free(best_periods);
		gsl_vector_free(perm);
      
	}
	return TCL_OK;
}
/****************************************************************************/
int Cmd_aktcl_ajustement(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction ajustement                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The error bars vector
			4) The best periods vector
			5) The number of harmonics in Fourier series
   Outputs: 1) The best periods vector sorted following the chi2 test
			2) The final number of harmonics (only for the best period)
			3) The Fourier coefficients vector (only for the best period)
*/
/***************************************************************************/
{
    char s[200];
    int code,code1,code2,code3;
    int nper=0,nhar=0,nmes=0;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*bars,*best_periods,*coefs,*phases;
	double residu,residu_min0,residu_min00,i_best0,nhar_best0;
    gsl_vector *residu_min,*i_bests, *nhar_bests;
    double res;
    double deltaphasemax;
    int nhar0,i,j,ii,i_bestbest,nhar_bestbest;
	
	if(argc!=6) {
        sprintf(s,"Usage: %s Incorrect number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
   } else {
        /* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		code1=gsltcltcl_getgslvector(interp,argv[2],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[3],&bars,&nmes);
        code3=gsltcltcl_getgslvector(interp,argv[4],&best_periods,&nper);
		nhar =atoi(argv[5]);
		/* --- inits ---*/
   	    residu_min00=1e+90;
		phases=gsl_vector_calloc(nmes);
		residu_min=gsl_vector_calloc(nper);
		i_bests=gsl_vector_calloc(nper);
		nhar_bests=gsl_vector_calloc(nper);
		for (i=0;i<nper;i++) {
			/* --- determine n_har0, le nombre d'harmoniques maximum à prendre ---*/
			for (j=0;j<nmes;j++) {
				res=(jds->data[j]-jds->data[0])/best_periods->data[i];
				phases->data[j]=res-floor(res);
			}
			gsl_sort_vector(phases);
			deltaphasemax=0.;
			for (j=0;j<nmes-1;j++) {
				res=phases->data[j+1]-phases->data[j];
				if (res>deltaphasemax) {
					deltaphasemax=res;
				}
			}
			res=phases->data[0]+1.-phases->data[nmes-1];
			if (res>deltaphasemax) {
				deltaphasemax=res;
			}
			nhar0=(int)(1./deltaphasemax/2.);
			if (nhar0>nhar) {
				nhar0=nhar;
			}
			if (nhar0<1) {
				nhar0=1;
			}
			coefs=gsl_vector_calloc(1+2*nhar0);
			yd_moin_carr(jds,mags,bars,best_periods->data[i],nhar0,nmes,coefs,&residu);
			gsl_vector_free(coefs);
			residu_min->data[i]=residu;
			i_bests->data[i]=i;
			nhar_bests->data[i]=nhar0;
		}
		/* --- tri les residus ---*/
		for (i=0;i<nper-1;i++) {
			for (ii=i;ii<nper;ii++) {
				if (residu_min->data[ii]<residu_min->data[i]) {
					residu_min0=residu_min->data[ii];
					residu_min->data[ii]=residu_min->data[i];
					residu_min->data[i]=residu_min0;
					i_best0=i_bests->data[ii];
					i_bests->data[ii]=i_bests->data[i];
					i_bests->data[i]=i_best0;
					nhar_best0=nhar_bests->data[ii];
					nhar_bests->data[ii]=nhar_bests->data[i];
					nhar_bests->data[i]=nhar_best0;
				}
			}
		}
		i_bestbest=(int)i_bests->data[0];
		nhar_bestbest=(int)nhar_bests->data[0];
		
		/* --- calcule les coefs pour la meilleure periode ---*/
		coefs=gsl_vector_calloc(1+2*nhar_bestbest);
		yd_moin_carr(jds,mags,bars,best_periods->data[i_bestbest],nhar_bestbest,nmes,coefs,&residu);
   		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr," {",-1);
		for (i=0;i<nper;i++) {
			ii=(int)i_bests->data[i];
			sprintf(s,"%.11f ",best_periods->data[ii]);
			Tcl_DStringAppend(&dsptr,s,-1);
		}
		Tcl_DStringAppend(&dsptr,"} ",-1);
		Tcl_DStringAppend(&dsptr," ",-1);
		sprintf(s,"%d",nhar_bestbest);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr," {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,coefs,1+2*nhar_bestbest);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(bars);
		gsl_vector_free(best_periods);
        gsl_vector_free(phases);
		gsl_vector_free(residu_min);
		gsl_vector_free(i_bests);		
		gsl_vector_free(coefs);
		gsl_vector_free(nhar_bests);
	}
	return TCL_OK;
}
/****************************************************************************/
int Cmd_aktcl_ajustement2(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction ajustement                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The error bars vector
			4) The best periods vector
			5) The number of harmonics in Fourier series
   Outputs: 1) The best periods vector sorted following the chi2 test
			2) The final number of harmonics (only for the best period)
			3) The Fourier coefficients vector (only for the best period)
*/
/***************************************************************************/
{
    char s[200];
    int code,code1,code2,code3;
    int nper=0,nhar=0,nmes=0;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*bars,*best_periods,*coefs,*phases;
	double residu,residu_min0,residu_min00,i_best0;
    gsl_vector *residu_min,*i_bests;
    double res;
    double deltaphasemax;
    int nhar0=2,i,j,ii,i_bestbest;
	
	if(argc!=6) {
        sprintf(s,"Usage: %s Incorrect number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
   } else {
        /* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		code1=gsltcltcl_getgslvector(interp,argv[2],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[3],&bars,&nmes);
        code3=gsltcltcl_getgslvector(interp,argv[4],&best_periods,&nper);
		nhar =atoi(argv[5]);
		/* --- inits ---*/
   	    residu_min00=1e+90;
		phases=gsl_vector_calloc(nmes);
		residu_min=gsl_vector_calloc(nper);
		i_bests=gsl_vector_calloc(nper);
		coefs=gsl_vector_calloc(1+2*nhar0);
		for (i=0;i<nper;i++) {
			yd_moin_carr(jds,mags,bars,best_periods->data[i],nhar0,nmes,coefs,&residu);
			residu_min->data[i]=residu;
			i_bests->data[i]=i;
		}
		gsl_vector_free(coefs);
		/* --- tri les residus ---*/
		for (i=0;i<nper-1;i++) {
			for (ii=i;ii<nper;ii++) {
				if (residu_min->data[ii]<residu_min->data[i]) {
					residu_min0=residu_min->data[ii];
					residu_min->data[ii]=residu_min->data[i];
					residu_min->data[i]=residu_min0;
					i_best0=i_bests->data[ii];
					i_bests->data[ii]=i_bests->data[i];
					i_bests->data[i]=i_best0;
				}
			}
		}
		i_bestbest=(int)i_bests->data[0];
		/* --- determine n_har0, le nombre d'harmoniques maximum à prendre ---*/
		for (j=0;j<nmes;j++) {
			res=(jds->data[j]-jds->data[0])/best_periods->data[i_bestbest];
			phases->data[j]=res-floor(res);
		}
		gsl_sort_vector(phases);
		deltaphasemax=0.;
		for (j=0;j<nmes-1;j++) {
			res=phases->data[j+1]-phases->data[j];
			if (res>deltaphasemax) {
				deltaphasemax=res;
			}
		}
		res=phases->data[0]+1.-phases->data[nmes-1];
		if (res>deltaphasemax) {
			deltaphasemax=res;
		}
		nhar0=(int)(1./deltaphasemax/2.);
		if (nhar0>nhar) {
			nhar0=nhar;
		}
		if (nhar0<1) {
			nhar0=1;
		}
		/* --- calcule les coefs pour la meilleure periode ---*/
		coefs=gsl_vector_calloc(1+2*nhar0);
		yd_moin_carr(jds,mags,bars,best_periods->data[i_bestbest],nhar0,nmes,coefs,&residu);
   		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr," {",-1);
		for (i=0;i<nper;i++) {
			ii=(int)i_bests->data[i];
			sprintf(s,"%.11f ",best_periods->data[ii]);
			Tcl_DStringAppend(&dsptr,s,-1);
		}
		Tcl_DStringAppend(&dsptr,"} ",-1);
		Tcl_DStringAppend(&dsptr," ",-1);
		sprintf(s,"%d",nhar0);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr," {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,coefs,1+2*nhar0);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(bars);
		gsl_vector_free(best_periods);
        gsl_vector_free(phases);
		gsl_vector_free(residu_min);
		gsl_vector_free(i_bests);		
		gsl_vector_free(coefs);
	}
	return TCL_OK;
}


/************************************************************************************/
int yd_moin_carr(gsl_vector *jds, gsl_vector *mags,gsl_vector *bars, double per , int n_arm,int nmes, gsl_vector *coefs, double *residu)
/***************************************************************************/
/* Fonction moin_carr                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The error bars vector
			4) The period
			5) The number of harmonics
			6) The jds length
   Outputs: The chi2 value
*/
/***************************************************************************/
{
   
    int i,j;
	double pi,w;
	gsl_matrix *A,*W,*Ap,*ApW,*ApWA,*ApWA_inv;
	gsl_vector *Y,*Y_aju;
	gsl_permutation *p;
	int signum;
	
	/* --- inits ---*/
	/* n_x = nb de points de mesure */
	/* 1+2*n_arm = nb de coefs a determiner */
	Y  =gsl_vector_calloc(nmes);
	Y_aju  =gsl_vector_calloc(nmes);
	A  =gsl_matrix_calloc(nmes,1+2*n_arm);
	Ap =gsl_matrix_calloc(1+2*n_arm,nmes);
	ApW=gsl_matrix_calloc(1+2*n_arm,nmes);
	ApWA=gsl_matrix_calloc(1+2*n_arm,1+2*n_arm);
	ApWA_inv=gsl_matrix_calloc(1+2*n_arm,1+2*n_arm);
	p=gsl_permutation_alloc(1+2*n_arm);
	pi=4*atan(1);
	for (i=1;i<n_arm+1;i++) {
		for (j=0;j<nmes;j++){
			gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*jds->data[j]/per));
			gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*jds->data[j]/per));
		}
	}
    for (j=0;j<nmes;j++) {
		gsl_matrix_set(A,j,2*n_arm,1.);
	}
    W=gsl_matrix_calloc(nmes,nmes);
	for (j=0;j<nmes;j++) {
		w=bars->data[j];
		/*Seuillage*/
		if (w==0) {w=0.001;}
		w=1/(w*w);
		gsl_matrix_set(W,j,j,w);
	}
	/* inv(A'*W*A)*A'*W*Y(mag) */
    gsl_matrix_transpose_memcpy(Ap,A);
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,Ap,W,0.0,ApW); 
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,ApW,A,0.0,ApWA); 
	gsl_linalg_LU_decomp(ApWA,p,&signum);
	gsl_linalg_LU_invert(ApWA,p,ApWA_inv);
	gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,ApWA_inv,ApW,0.0,Ap);
	gsl_vector_memcpy(Y,mags);
	gsl_blas_dgemv(CblasNoTrans,1.0,Ap,Y,0.0,coefs);
	/**/
	gsl_blas_dgemv(CblasNoTrans,1.0,A,coefs,0.0,Y_aju);
	gsl_vector_sub(Y,Y_aju);
	/**/
	*residu=0;
	for (j=0;j<nmes;j++) {
		*residu+=(Y->data[j]*Y->data[j]*W->data[j*nmes+j]);
	}
	/**/
	gsl_vector_free(Y);
	gsl_vector_free(Y_aju);
	gsl_matrix_free(A);
	gsl_matrix_free(Ap);
	gsl_matrix_free(ApW);
	gsl_matrix_free(ApWA);
	gsl_matrix_free(ApWA_inv);
	gsl_matrix_free(W);
    gsl_permutation_free(p);
	return 0;
}

/************************************************************************************/
int Cmd_aktcl_cour_final(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction cour_final                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
            2) The mags vector
			3) The error bars vector
			4) The period
			5) The Fourier series coefficients
			6) The sigma of mags
   Outputs: 1) The mags synthetic vector
			2) The sigma of mags
			3) 0 if k_good*k_bad!=0 - +1 if k_good==0 - -1 if k_bad==0 
			4) Index of jdgoods (point lyning on the curve)
			5) Index of jdbads (point don't lyning on the curve)
*/
/***************************************************************************/
{   char s[200];
    int code,code1,code2,code3;
    int i,j,nmes=0,n_arm,k=0,temoin=0;
	Tcl_DString dsptr;
    gsl_vector *coefs;
	double period,pi,stdmodel,deltamag,deltamag2,val1,val2,sigma,sigma2;
	gsl_matrix *A;
	gsl_vector *jds,*mags,*bars,*magpobss,*ind_jdgoods,*ind_jdbads;
	int k_good,k_bad;

	if(argc!=7) {
        sprintf(s,"Usage: %s Invalid number of inputs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		code1=gsltcltcl_getgslvector(interp,argv[2],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[3],&bars,&nmes);
	    period =atof(argv[4]);
		code3=gsltcltcl_getgslvector(interp,argv[5],&coefs,&k);
		sigma =atof(argv[6]);
		n_arm=(k-1)/2;
		/*-----init---------*/	
	
	    /* 1+2*n_arm = nb de coefs a determiner */
	    magpobss    =gsl_vector_calloc(nmes);
	    ind_jdgoods =gsl_vector_calloc(nmes);
		ind_jdbads  =gsl_vector_calloc(nmes);

        A=gsl_matrix_calloc(nmes,k);
	    pi=4*atan(1);
	    for (i=1;i<n_arm+1;i++) {
		    for (j=0;j<nmes;j++){
				gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*jds->data[j]/period));
			    gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*jds->data[j]/period));
			}
		}
        for (j=0;j<nmes;j++) {
		    gsl_matrix_set(A,j,2*n_arm,1.);
		}
	
	    /* AA*coefs */
   	    gsl_blas_dgemv(CblasNoTrans,1.0,A,coefs,0.0,magpobss);
	    /*Calcul de l'esart type de magpobss*/
	    val1=0;
	    val2=0;
	    for (j=0;j<nmes;j++) {
		    val1+=magpobss->data[j];
		    val2+=magpobss->data[j]*magpobss->data[j];
	    }
	    stdmodel=(val2-val1*val1/nmes)/(nmes-1);
	    /*Cherchons maintenant les ind_jdgoods et ind_jdbads*/
		sigma2=sigma/2;
	    k_good=0;
	    k_bad=0;
	    for (j=0;j<nmes;j++) {
		    deltamag=fabs(mags->data[j]-magpobss->data[j])-bars->data[j];
			deltamag2=fabs(mags->data[j]-magpobss->data[j])-sigma2;
		    if ((deltamag>0)&&(deltamag2>0)) {
			    ind_jdbads->data[k_bad]=j;
			    k_bad++;
		    } else {
			    ind_jdgoods->data[k_good]=j;
			    k_good++;
		    }
	    }
		if (k_good==0) {temoin=1;}
		if (k_bad==0) {temoin=-1;}

	    /* Sortie du résultat*/
	    Tcl_DStringInit(&dsptr);
        Tcl_DStringAppend(&dsptr,"{",-1);
        gsltcltcl_setgslvector(interp,&dsptr,magpobss,nmes);
		Tcl_DStringAppend(&dsptr,"} {",-1);
	    sprintf(s,"%f",stdmodel);
	    Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%d",temoin);
		Tcl_DStringAppend(&dsptr,s,-1);
	    if (k_good>0) {
			Tcl_DStringAppend(&dsptr,"} {",-1);
            gsltcltcl_setgslvector(interp,&dsptr,ind_jdgoods,k_good);
	    }
        if (k_bad>0) {
			Tcl_DStringAppend(&dsptr,"} {",-1);
	        gsltcltcl_setgslvector(interp,&dsptr,ind_jdbads,k_bad);
		}
	    Tcl_DStringAppend(&dsptr,"}",-1);
        Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
        /* --- liberation de la memoire ---*/
   	    gsl_vector_free(jds);
	    gsl_vector_free(mags);
	    gsl_vector_free(bars);
		gsl_vector_free(coefs);
        gsl_vector_free(magpobss);
	    gsl_vector_free(ind_jdbads);
	    gsl_vector_free(ind_jdgoods);
		gsl_matrix_free(A);
	}
	return TCL_OK;
}
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/
/*  UTILS                                                                   */
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/

int gsltcltcl_getvector(Tcl_Interp *interp, char *list, double **vec, int *n)
/****************************************************************************/
/* retourne un pointeur (double*) sur le vecteur defini par la liste Tcl.   */
/* retourne n, le nombre d'elements.                                        */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argv=NULL;
   int argc,code;
   int nn,k;
   double *v=NULL;
   
   *n=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {	 
	  v=(double*)calloc(1,sizeof(double));
	  return TCL_OK;
   }
   nn=argc;
	v=(double*)calloc(nn,sizeof(double));
   for (k=0;k<nn;k++) {
      v[k]=(double)atof(argv[k]);
   }
   Tcl_Free((char *) argv);
   *n=nn;
   *vec=v;
   return TCL_OK;
}  

int gsltcltcl_setvector(Tcl_Interp *interp, Tcl_DString *dsptr, double *vec, int n)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur (double*)                    */
/* n est le nombre d'elements.                                              */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int k;
   char s[200];
   for (k=0;k<n;k++) {
      sprintf(s,"%f",vec[k]);
      Tcl_DStringAppendElement(dsptr,s);
   }
   return TCL_OK;
}

int gsltcltcl_getmatrix(Tcl_Interp *interp, char *list, double **mat, int *nl, int *nc)
/****************************************************************************/
/* retourne un pointeur (double*) sur la matrice definie par la liste Tcl.  */
/* retourne nl et nc, respectivement le nombre de lignes et de colonnes.    */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argvv=NULL,**argv=NULL,s[200];
   int argcc,argc,code;
   int nlig,ncol=0,ncol1=0,klig,kcol;
   double *m=NULL;
   
   argvv=NULL;
   *nl=0;
   *nc=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
     gsltcl_mcalloc(&m,1,1);
	  return TCL_OK;
   }
   nlig=argc;
   for (klig=0;klig<nlig;klig++) {
      argvv=NULL;
      code=Tcl_SplitList(interp,argv[klig],&argcc,&argvv);
      if (argcc<=0) {
         if (m==NULL) {
		   gsltcl_mcalloc(&m,1,1);
		 }
	     return TCL_OK;
      }
      ncol=argcc;
      if (klig>0) {
         if (ncol!=ncol1) {
            sprintf(s,"%d elements instead of %d in line %d",ncol,ncol1,klig);
            Tcl_Free((char *) argv);
            Tcl_Free((char *) argvv);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      } else {
         ncol1=ncol;
		   gsltcl_mcalloc(&m,nlig,ncol);
      }
      for (kcol=0;kcol<ncol;kcol++) {      
         m[ncol*klig+kcol]=(double)atof(argvv[kcol]);
      }
      Tcl_Free((char *) argvv);
   }
   Tcl_Free((char *) argv);
   *nl=nlig;
   *nc=ncol;
   *mat=m;
   return TCL_OK;
}  


int gsltcltcl_setmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, double *mat, int nl, int nc)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur sur la matrice               */
/* nl est le nombre de lignes.                                              */
/* nc est le nombre de colonnes.                                            */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int kl,kc;
   char s[200];
   Tcl_DStringInit(dsptr);
   for (kl=0;kl<nl;kl++) {
      /*Tcl_DStringStartSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," { ",3);
      for (kc=0;kc<nc;kc++) {
         sprintf(s,"%f",mat[nc*kl+kc]);
         Tcl_DStringAppendElement(dsptr,s);
      }
      /*Tcl_DStringEndSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," } ",3);
   }
   return TCL_OK;
}

int gsltcltcl_getgslmatrix(Tcl_Interp *interp, char *list, gsl_matrix **gslmat, int *nl, int *nc)
/****************************************************************************/
/* retourne un pointeur (gsl_matrix *) sur la matrice definie par la liste Tcl.  */
/* retourne nl et nc, respectivement le nombre de lignes et de colonnes.    */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argvv=NULL,**argv=NULL,s[200];
   int argcc,argc,code;
   int nlig,ncol=0,ncol1=0,klig,kcol;
   gsl_matrix *m=NULL;
   
   argvv=NULL;
   *nl=0;
   *nc=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
	  return TCL_ERROR;
   }
   nlig=argc;
   for (klig=0;klig<nlig;klig++) {
      argvv=NULL;
      code=Tcl_SplitList(interp,argv[klig],&argcc,&argvv);
      if (argcc<=0) {
	     return TCL_ERROR;
      }
      ncol=argcc;
      if (klig>0) {
         if (ncol!=ncol1) {
            sprintf(s,"%d elements instead of %d in line %d",ncol,ncol1,klig);
            Tcl_Free((char *) argv);
            Tcl_Free((char *) argvv);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            return TCL_ERROR;
         }
      } else {
         ncol1=ncol;
         m=gsl_matrix_calloc(nlig,ncol);
      }
      for (kcol=0;kcol<ncol;kcol++) {      
         /*m[ncol*klig+kcol]=(double)atof(argvv[kcol]);*/
         gsl_matrix_set(m,klig,kcol,(double)atof(argvv[kcol]));
      }
      Tcl_Free((char *) argvv);
   }
   Tcl_Free((char *) argv);
   *nl=nlig;
   *nc=ncol;
   *gslmat=m;
   return TCL_OK;
}  

int gsltcltcl_setgslmatrix(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_matrix *gslmat, int nl, int nc)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur sur gsl_matrix               */
/* nl est le nombre de lignes.                                              */
/* nc est le nombre de colonnes.                                            */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int kl,kc;
   char s[200];
   for (kl=0;kl<nl;kl++) {
      /* Tcl_DStringStartSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," { ",3);
      for (kc=0;kc<nc;kc++) {
         sprintf(s,"%f",gsl_matrix_get(gslmat,kl,kc));
         Tcl_DStringAppendElement(dsptr,s);
      }
      /*Tcl_DStringEndSublist(dsptr);*/
      Tcl_DStringAppend(dsptr," } ",3);
   }
   return TCL_OK;
}

int gsltcltcl_getgslvector(Tcl_Interp *interp, char *list, gsl_vector **gslvec, int *n)
/****************************************************************************/
/* retourne un pointeur (gsl_vector *) sur la matrice definie par la liste Tcl.  */
/* retourne n le nombre d'elements.                                         */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   char **argv=NULL;
   int argc,code;
   int nn,k;
   gsl_vector *v=NULL;
   
   *n=0;
   code=Tcl_SplitList(interp,list,&argc,&argv);
   if (argc<=0) {
	  return TCL_ERROR;
   }
   nn=argc;
   v=gsl_vector_calloc(nn);
   for (k=0;k<nn;k++) {
      gsl_vector_set(v,k,(double)atof(argv[k]));
   }
   Tcl_Free((char *) argv);
   *n=nn;
   *gslvec=v;
   return TCL_OK;
}  


int gsltcltcl_setgslvector(Tcl_Interp *interp, Tcl_DString *dsptr, gsl_vector *vec, int n)
/****************************************************************************/
/* retourne une liste Tcl a partir du pointeur sur gsl_vectror              */
/* n est le nombre d'elements.                                              */
/*                                                                          */
/****************************************************************************/
/****************************************************************************/
{
   int k;
   char s[200];
   for (k=0;k<n;k++) {
      sprintf(s,"%f",gsl_vector_get(vec,k));
      Tcl_DStringAppendElement(dsptr,s);
   }
   return TCL_OK;
}

int gsltcl_mcalloc(double **mat,int nlig,int ncol)
/***************************************************************************/
/* Allocation memoire pour une matrice                                     */
/***************************************************************************/
/***************************************************************************/
{
   double *m=NULL;
   if (*mat==NULL) {
	  if (nlig*ncol==0) {
		  return 2;
	  }
      m=(double*)calloc(nlig*ncol,sizeof(double));         
	  if (m==NULL) {
	     return 1;
	  }
   }
   *mat=m;
   return 0;
}

int gsltcl_mfree(double **mat)
/***************************************************************************/
/* Liberation memoire pour une matrice                                     */
/***************************************************************************/
/***************************************************************************/
{
   if (*mat==NULL) {
	   free(*mat);
   }
   return 0;
}


/************************************************************************************/
int yd_perchoice(gsl_vector *jds, int nmes, int *temoin, int *indice_prem_date, int *indice_dern_date)
/***************************************************************************/
/* Fonction perchoice                                                       */
/***************************************************************************/
/* Fonction with the aim to choose trial periods following the criterion ni*delta_Pi=accu*Pi<<Pi,
   and eliminate aliasing periods  */
/* Inputs : 1) The jds vector
			2) The length of the jds vector
            2) Aliasing periods histogram
			3) The histogram limit value 
			4) The smallest authorized trial period
			5) The highest authorized trial period
   Outputs: 1) Temoin = 0 if data length is shorter than 1 year or there isn't enough data in 1 year
                      = 1 else
			2) The index of the first day of the choosen year (in jds vector)
			3) The index of the last day of the choosen year (in jds vector)
*/
/***************************************************************************/
{
    double delta_t,interval=180.;
	int imes,temoin2;
	int	compteur_date,compteur_date_temp,indice_prem_date_temp,indice_prem_date2,indice_dern_date2;
	
	compteur_date=0;
    compteur_date_temp=0;
	indice_prem_date2=0;
	indice_dern_date2=0;
	indice_prem_date_temp=0;
    imes=1;
	temoin2=0;

	while (imes<nmes) {
		delta_t=jds->data[imes]-jds->data[indice_prem_date_temp];
		if (delta_t>interval) {			
			temoin2=1;
			compteur_date_temp=imes-indice_prem_date_temp;
			/* le +1-1 s'annulent dans compteur_date_temp*/
			if (compteur_date_temp>compteur_date) {
				compteur_date=compteur_date_temp;
				indice_dern_date2=imes-1;
				indice_prem_date2=indice_prem_date_temp;
				indice_prem_date_temp=imes;
				compteur_date_temp=0;
			}
		}		
		imes++;
		compteur_date_temp++;
	}
	/*il se peut que dans la derniere annee on a plus d'observavation sans pour autant 
	qu'elle soit superieure a 6 mois*/
	compteur_date_temp=imes-indice_prem_date_temp+1;
	if (compteur_date_temp>compteur_date) {
 		compteur_date=compteur_date_temp;
		indice_dern_date2=imes-1;
		indice_prem_date2=indice_prem_date_temp;
	}	
	if (temoin2==0) {
		indice_dern_date2=nmes-1;
	}
	/*Si j'ai moins de 10 mesures par an, je prends toutes les mesures*/
	if (compteur_date<11) {
		indice_dern_date2=nmes-1;
		indice_prem_date2=0;
		temoin2=0;
	}
	/*Je sais que cest un peu bête mais j'ai encore (beaucoup) des doutes sur les pointeurs*/
	*indice_prem_date=indice_prem_date2;
	*indice_dern_date=indice_dern_date2;
	*temoin=temoin2;
	return 0;
}
/************************************************************************************/
int Cmd_aktcl_meansigma(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction meansigma                                                       */
/***************************************************************************/
/* Inputs : A vector
   Outputs: Its mean and sigma
*/
/***************************************************************************/
{
	char s[200];
    int code,i,n=0;
	double mean=0,sigma=0;
	Tcl_DString dsptr;
    gsl_vector *vect;
	if(argc!=2) {
        sprintf(s,"Usage: %s Invalid must be a vector", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&vect,&n);
		
		if (n>1) {
            for (i=0;i<n;i++) {
				mean+=vect->data[i];
				sigma+=vect->data[i]*vect->data[i];
			}
			mean=mean/n;
			sigma=(sigma-n*mean*mean)/(n-1);
			sigma=sqrt(sigma);
		} else {
			mean=vect->data[0];
		}
		Tcl_DStringInit(&dsptr);
        Tcl_DStringAppend(&dsptr,"{",-1);
	    sprintf(s,"%f",mean);
	    Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%f",sigma);
	    Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);

		gsl_vector_free(vect);
	}
	return TCL_OK;
}
/***************************************************************************/
int Cmd_aktcl_per_range(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction yd_per_range
   Inputs : 1) The jds vector
			2) The smallest real period
   Outputs: 1) The smallest authorized periog
			2) The highest authorized periog
*/
/***************************************************************************/
{
	char s[200];
    int code,nmes=0,i,temoin,nmes2;
	double per_range_minmin,per_range_max,per_range_min,pgcd;
	Tcl_DString dsptr;
    gsl_vector *jds;
	double *dt;
	if(argc!=3) {
		sprintf(s,"Usage: %s Invalid input : must be a vector", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		per_range_minmin=atof(argv[2]);
		nmes2=nmes-1;
		/*Je calcule les différences entre dates successives*/
		dt=(double*)calloc(nmes-1,sizeof(double));
		if (dt==NULL) {
			sprintf(s,"error : dt pointer out of memory (%d elements)",nmes2);
            Tcl_SetResult(interp,s,TCL_VOLATILE);
            gsl_vector_free(jds);
            return TCL_ERROR;
        }
		for (i=0;i<nmes2;i++) {
			dt[i]=jds->data[i+1]-jds->data[i];			
		}
		/*on trie le vecteur dt et on cherche le pgcd de ses elements*/
		ak_util_qsort_double(dt,0,nmes2,NULL);
		yd_util_pgcd(dt,nmes2,per_range_minmin/2.,0.01,&pgcd,&temoin);
		if (temoin==1) {
			per_range_min=2.*pgcd;
		} else {
			per_range_min=per_range_minmin;
		}	
		per_range_max=2*(jds->data[nmes-1]-jds->data[0]);
		
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		sprintf(s,"%f",per_range_min);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		sprintf(s,"%f",per_range_max);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		gsl_vector_free(jds);
		free(dt);
	}
    return TCL_OK;
}
/***************************************************************************/
int Cmd_aktcl_moy_bars_comp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction yd_per_range
   Inputs : 1) The mags vector
			2) The error bars vector
			3) The mags mean
   Outputs: The ratio of bad points
*/
/***************************************************************************/
{
	char s[200];
    int code,code2,nmes=0,i,temoin=0,compteur;
	double moyenne,res;
	Tcl_DString dsptr;
    gsl_vector *bars,*mags;
	if(argc!=4) {
		sprintf(s,"Usage: %s Invalid input : must be 2 vector and a scalar", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[2],&bars,&nmes);
		moyenne=atof(argv[3]);
		compteur=0;
		for (i=0;i<nmes;i++) {
			res=mags->data[i]-moyenne;
			if (res<bars->data[i]) {
				compteur++;
			}
		}
		res=compteur/nmes;
		if (res>=0.8) {
			temoin=1;
		}
		Tcl_DStringInit(&dsptr);
	    sprintf(s,"%d",temoin);
	    Tcl_DStringAppend(&dsptr,s,-1);
	    Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
	    gsl_vector_free(mags);
	    gsl_vector_free(bars);
	}
    return TCL_OK;
}
/************************************************************************************************************************************************************/
int yd_dichotomie(double per, gsl_vector *badpers, int nbad, int *temoin2, int *k_bad)
/*************************************************************************************************************************************************************/
/* Fonction que j'utilise dans yd_nettoyage, elle me sert de retrouver les éléments d'un vecteur
   grace à l'algo de dichotomie utilisé par Alain dans ak_filehtm2refzmgmes
*/
{
	int k,k_per,k_per1,k_per2,sortie;
	double dper,badper,deltaper,badpersmax,fact;

    *temoin2=0;
	fact=0.05;
	badpersmax=badpers->data[nbad-1]*(1+fact*badpers->data[nbad-1]);
	if (badpersmax>20) {
		badpersmax=20;
	}
	/** badpersmax voir yd_aliasing*/
	if (per>badpersmax) {
		return 0;
	}
    /*il n'y a pas de soucis: badpers est trié par construction
	je vais utiliser l'algorithme de dichotomie pour voir si la période
	est le résultat d'une combinaison linéaire avec les périodes d'aliasing:
	fréquence d'artefact = fréquence +/- x*fréquence d'aliasing (x=1,2,3,4)
	Nous allons donc chercher autour de chaque fréquence d'aliasing d'un pas 
	0.0075*10/per^2 : c'est à dire qui diminue avec la période
	le pas en période correspondant est : pas*(per^2)=0.075
	*/
	k_per=0;
    k_per1=*k_bad;
    k_per2=nbad-1;
	sortie=0;
	while(sortie==0) {
        if ((k_per2-k_per1)<=1) { break; }
		k_per=(k_per1+k_per2+1)/2;
        badper=badpers->data[k_per];
        if (per<=badper) {
			k_per2=k_per;
        } else {
            k_per1=k_per;
        }
    }
    for (k=k_per;k>=0;k--) {
		badper=badpers->data[k];
		deltaper=fact*badper;
		/*On determine le deltaper (largeur de l'histogramme)*/
        dper=per-badper;
        if (dper>deltaper) { break; }
		if (dper<-deltaper) { continue; }
        if (dper<deltaper) {
            *temoin2=1 ; 
			*k_bad=k;
			return 0; 
        }
    }
 	for (k=k_per+1;k<nbad;k++) {
		badper=badpers->data[k];
		deltaper=fact*badper;
		/*On determine le deltaper (largeur de l'histogramme)*/
		dper=badper-per;
        if (dper>deltaper) { break; }
		if (dper<-deltaper) { continue; }
		if (dper<deltaper) {
			*temoin2=1 ; 
			*k_bad=k;
			return 0; 
		}
    }
 
	return 0;
}
/************************************************************************************************************************************************************/
int yd_util_pgcd(double *vecteur, int taille, double limit,double tolerance,double *pgcd, int *temoin)
/*************************************************************************************************************************************************************/
{
	int i,j,sortie,temoin2;
	double delta,res,eps,eps2;
	/*Init*/
	eps=tolerance;
	eps2=1.-tolerance;
	/**/
	i=1;
	sortie=0;
	temoin2=0;
	delta=vecteur[0]/i;
	*pgcd=delta;
	*temoin=0;
	while (sortie==0) {
		delta=vecteur[0]/i;
		if (delta<limit) {break;}
		for (j=0;j<taille;j++) {
			res=vecteur[j]/delta;
			res=res-(int)floor(res);
			if((res<eps)||(res>eps2)) {
				temoin2=1;
			} else {
				temoin2=0;
				break;
			}		
		}
		if (temoin2>0) {
			*temoin=1;
			*pgcd=delta;
			break;
		}
		i++;
	}
	return 0;	
}
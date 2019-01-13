/* yd_3.c
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
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Ce fichier contient les sources de Yassine.                             */
/***************************************************************************/
#include "yd_3.h"

int yd_aliasing(gsl_vector *jds, int nmes)
/***************************************************************************/
/* Fonction aliasing                                                        */
/***************************************************************************/
/* Inputs: The jd vector
   Outputs 1 if there is aliasing, 0 else
/***************************************************************************/
{
	/*Nous allons chercher dans ce script toutes les périodes d'aliasing inférieures à 5j
	car leur influence diminue audela de cette limite :
	fréquence d'artefact = frequence +/- x*frequence d'aliasing (x=0.5,1,2)*/
	double dj,maxim,limit_inf,limit_sup,pgcd;
	int *hist=NULL;
	int nhist,kj1,kj2,k_hist,val,kk,temoin,nbad,temoin2,temoin3;
	double *maximums=NULL;
/*FILE *f;*/

	/*Je vais construire 1 histogramme des périodes d'aliasing dand le domaine 18h:4h:20h ncase=116*/
	nhist=116;
	temoin=0;
	temoin3=0;
	limit_inf=18./24;
    limit_sup=20.;
	/*J'alloue la mémoire: je n'utilise pas de vecteur gsl car c'est un vecteur d'entiers*/
	hist=(int*)calloc(nhist,sizeof(int));
	if (hist==NULL) {return 2;}
	/*Je construis mon histogramme*/
/*f=fopen("init.txt","wt");*/
	for (kj1=0;kj1<nmes-1;kj1++) {
		for (kj2=kj1+1;kj2<nmes;kj2++) {
			/*par construction jds est trié*/
            dj=jds->data[kj2]-jds->data[kj1];
/*fprintf(f,"%10.8f\n",dj);*/
			if (dj>limit_sup) {continue;}
			if (dj<limit_inf) {continue;}
			k_hist=(int)floor(6*(dj-limit_inf));
			/*6=24/6*/
			hist[k_hist]++;
			temoin3=1;
		}
	}
/*fclose(f);*/
	if (temoin3==1) {
        /*Je cherche le maximum de l'histogramme*/
		maxim=0.;
		for (k_hist=0;k_hist<nhist;k_hist++) {
			val=hist[k_hist];
			if (val>maxim) {maxim=(double)val;}
		}
		maxim=0.5*maxim;
/*maxim=0.;*/
		/*Je compte le nombre de cases > maxim*/
		kk=0;
		for (k_hist=0;k_hist<nhist;k_hist++) {
			val=hist[k_hist];
			if (val>maxim) {
				kk++;
			}
		}
		nbad=kk;
	   /*Allocation de la memoire : je suis sur que nbad>0 car temoin3>0*/

		maximums=(double*)calloc(nbad,sizeof(double));
		if (maximums==NULL) {return 2;}
		/*Par contre s'il y a une erreur dand l'allocation memoire je ne sais pas comment la remon*/
		kk=0;
		for (k_hist=0;k_hist<nhist;k_hist++) {
			val=hist[k_hist];
			if (val>maxim) {
				maximums[kk]=(k_hist+0.5)/6+limit_inf;
				kk++;
			}
		}
		yd_util_qsort_double(maximums,0,nbad,NULL);
		yd_util_pgcd(maximums,nbad,0.6,0.01,&pgcd,&temoin2);
		if (temoin2==1) {
			/*je normalise le pgcd a 1*/
			pgcd/=ceil(pgcd-0.5);
			if ((pgcd>0.92)&&(pgcd<1.08)) {temoin=1;}
		}
		free(maximums);
	}
	return temoin;
}
/*********************************************************************************************************/
int Cmd_ydtcl_minlong(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction minlong     $jds $mags $poids $longvar $per_range_min $per_range_max $pasfreq $nper1                                                                                */
/*********************************************************************************************************/
/* Inputs: 1) The jd vector
           2) The mag vector
		   3) The weight vector
		   4) The period vector
   Outputs 1) The minlog vector
/***************************************************************************/
{
	char s[200];
    int code,code2,code3,code4;
    int n_jd,n_mag,nmes,nper;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*errmags,*periods,*TETAS,*phase,*temp;
	double eps,delmag,minmag,maxmag;
	double phase_prec,phase_suiv,mag_prec,mag_suiv,poids_prec,poids_suiv,delta_mag,delta_phi;
	int k_x,k_xx,k_per;
	gsl_permutation *perm;
	double per,poids,somme,sommepoids;
    /*FILE *f;*/
    if(argc!=5) {
		sprintf(s,"Usage: %s jds mags poids periods", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&errmags,&n_mag);
		code4=gsltcltcl_getgslvector(interp,argv[4],&periods,&nper);
       /* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"jds and mags vectors must have the same dimension",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		nmes=n_jd;
		eps=5e-2;
		/*A changer en gsl_vector_minmax*/
		gsl_vector_minmax(mags,&minmag,&maxmag);
		delmag=maxmag-minmag;
		eps=eps/(2*delmag);
/*eps=0.00001;*/
		/*on va redefinir les bares d'erreur en inverses de poids (bares^2) pour les besoins du calcul*/
		for (k_x=0;k_x<nmes;k_x++) {
			/*errmags->data[k_x]+=0.001;
			errmags->data[k_x]*=errmags->data[k_x];*/
			errmags->data[k_x]=1./errmags->data[k_x];
		}
		TETAS=gsl_vector_calloc(nper);
		phase=gsl_vector_calloc(nmes);
		temp=gsl_vector_calloc(nmes);
		perm=gsl_permutation_alloc(nmes);
		gsl_vector_add_constant(jds,-jds->data[0]);

		gsl_vector_memcpy(temp,jds);
		
		
		for (k_per=0;k_per<nper;k_per++) {
			per	= periods->data[k_per];
			gsl_vector_scale(temp,1./per);

			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
			}
			gsl_sort_vector_index(perm,phase);
			k_xx=perm->data[0];
			phase_prec=phase->data[k_xx];
			mag_prec=mags->data[k_xx];
			poids_prec=errmags->data[k_xx];
			k_x=1;
			somme=0;
			sommepoids=0;
			while (k_x<nmes) {
				k_xx=perm->data[k_x];
				phase_suiv=phase->data[k_xx];
				mag_suiv=mags->data[k_xx];
				poids_suiv=errmags->data[k_xx];
				delta_phi=phase_suiv-phase_prec+eps;
				delta_mag=fabs(mag_suiv-mag_prec);
				/*poids=1./(delta_phi*(poids_suiv+poids_prec));
				delta_mag*=poids;
				sommepoids+=poids;
				somme+=delta_mag;*/
				poids=1./(poids_suiv+poids_prec);
				delta_mag*=poids;
				sommepoids+=poids;
				somme+=delta_mag/delta_phi;
				k_x++;
				phase_prec=phase_suiv;
				mag_prec=mag_suiv;
				poids_prec=poids_suiv;
			}
			somme=somme/sommepoids;
			TETAS->data[k_per]=somme;
		}

		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		gsltcltcl_setgslvector(interp,&dsptr,TETAS,nper);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(phase);
	    gsl_permutation_free(perm);
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(errmags);
		gsl_vector_free(temp);
		gsl_vector_free(periods);
		gsl_vector_free(TETAS);
		return TCL_OK;
    }
}

/****************************************************************************/
int Cmd_ydtcl_periodog(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction periodog                                                     */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) The mags vector
			3) The weigths of mags
			4) The periods vector
   Outputs: The periodogram vector (Scargle 1982)
*/
/***************************************************************************/
{
    char s[200];
    int code,code2,code3,code4;
    int n_jd=0,n_mag=0,nper=0,nmes;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*poids,*periods;
    gsl_vector *Arg,*tem0,*Pxw;
	double Axc,Axs,Ax1,Ax2,Axc_som,Axs_som;
	int i,j;
	double pi,om,tau_s,tau_c,tau;
	double moy,noise;

    if(argc!=7) {
		sprintf(s,"Usage: %s jds mags weigths periods moy noise", argv[0]);
		Tcl_SetResult(interp,s,TCL_VOLATILE);
		return TCL_ERROR;
    } else {
		/* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&poids,&n_mag);
		code4=gsltcltcl_getgslvector(interp,argv[4],&periods,&nper);
		moy=atof(argv[5]);
		noise=atof(argv[6]);
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
				Axc = poids->data[j]*cos(Arg->data[j]);
				Ax1 += tem0->data[j]*Axc;
				Axs = poids->data[j]*sin(Arg->data[j]);
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
		gsl_vector_free(poids);
		gsl_vector_free(periods);
		gsl_vector_free(Pxw);
		gsl_vector_free(tem0);
		gsl_vector_free(Arg);
		}
	return TCL_OK;
}

int yd_pdm_entropie(gsl_vector *phase, gsl_vector *mags, gsl_vector *poids, int nmes, int nbin, double *PDM, double *Entropie)
/***************************************************************************/
/* Fonction maillage                                                        */
/***************************************************************************/
/* Inputs : 1) The phase vector
			2) The mag vector
			3) The weight vector
			4) The number of measurements
			5) test1 : if we would do this test with ncol1
			6) test2 : if we would do this test with ncol2
			7) ncol2 (see shortorlong
   Outputs: 1) The entropy matrix (Cincotta 1995)
			2) The PDM value (Maraco 1982)
*/
/***************************************************************************/
{
    int nlig,ncol,i,j;
    gsl_matrix *EntMat,*ValMat;
	double err,maxmag,minmag,delmag,valm,valmm,valx,valp,mag_variance,eps=1e-20; /*,covar,phase_variance*/
	int x_pos,y_pos;

	/* --- inits ---*/
	err =0.05;
	gsl_vector_minmax(mags,&minmag,&maxmag);
	delmag=maxmag-minmag;
	ncol=nmes/10;
	ncol=(ncol>nbin)?nbin:ncol;
	
	nlig   = (int)floor(delmag/err)+1;
    EntMat = gsl_matrix_calloc(nlig,ncol);
	/*ValMat = gsl_matrix_calloc(ncol,7);*/
	ValMat = gsl_matrix_calloc(ncol,3);
	for (i=0;i<nmes;i++) {
		x_pos=(int)floor(phase->data[i]*ncol);
		if (x_pos>=ncol) {
			x_pos=ncol-1;
		}
		if (x_pos<0) {
			x_pos=0;
		}
		y_pos=(int)floor(nlig*(mags->data[i]-minmag)/(delmag+1e-5));
		if (y_pos>=nlig) {
			y_pos=nlig-1;
		}
		if (y_pos<0) {
			y_pos=0;
		}
		gsl_matrix_set(EntMat,y_pos,x_pos,gsl_matrix_get(EntMat,y_pos,x_pos)+1);
		valm=gsl_vector_get(mags,i);
		valp=gsl_vector_get(poids,i);
		valx=gsl_vector_get(phase,i);
		valmm=valp*valm;
		/*les poids des phases valent 1*/
		/* Somme des mag*/
		gsl_matrix_set(ValMat,x_pos,0,gsl_matrix_get(ValMat,x_pos,0)+valmm);
        /* Somme des mag^2*/
		gsl_matrix_set(ValMat,x_pos,1,gsl_matrix_get(ValMat,x_pos,1)+valmm*valm);
		/* Somme des poids (mags)*/
		gsl_matrix_set(ValMat,x_pos,2,gsl_matrix_get(ValMat,x_pos,2)+valp);
        /* Somme des phase*/
        /*gsl_matrix_set(ValMat,x_pos,3,gsl_matrix_get(ValMat,x_pos,3)+valx);*/
		/* Somme des phase^2*/
		/*gsl_matrix_set(ValMat,x_pos,4,gsl_matrix_get(ValMat,x_pos,4)+valx*valx);*/
		/* Somme des phase*mag*/
		/*gsl_matrix_set(ValMat,x_pos,5,gsl_matrix_get(ValMat,x_pos,5)+valm*valx);*/
		/* Somme des poids (phases)*/
		/*gsl_matrix_set(ValMat,x_pos,6,gsl_matrix_get(ValMat,x_pos,6)+1);*/
	}

	*PDM=0;
	*Entropie=0;

	for (i=0;i<ncol;i++) {
		mag_variance=gsl_matrix_get(ValMat,i,1)-gsl_matrix_get(ValMat,i,0)*gsl_matrix_get(ValMat,i,0)/(gsl_matrix_get(ValMat,i,2)+eps);
		/*mag_variance*=gsl_matrix_get(ValMat,i,6)/(gsl_matrix_get(ValMat,i,2)+eps);
		/*phase_variance=gsl_matrix_get(ValMat,i,4)-gsl_matrix_get(ValMat,i,3)*gsl_matrix_get(ValMat,i,3)/(gsl_matrix_get(ValMat,i,6)+eps);
		covar = (gsl_matrix_get(ValMat,i,5))-gsl_matrix_get(ValMat,i,3)*gsl_matrix_get(ValMat,i,0)/(gsl_matrix_get(ValMat,i,2)+eps);
		*PDM+=mag_variance-covar*covar/(phase_variance+eps);*/
		*PDM+=mag_variance;
	}
	/**PDM/=(nmes-2*ncol);*/
	gsl_matrix_scale(EntMat,1./nmes);
	for (i=0;i<ncol;i++) {
		for (j=0;j<nlig;j++) {
			valx      =gsl_matrix_get(EntMat,j,i);
			valx     +=eps;
			*Entropie +=-valx*log(valx);
		}
	}
	/*Normalisation*/
	*Entropie=*Entropie/(log(nlig*ncol));
	
	gsl_matrix_free(EntMat);
	gsl_matrix_free(ValMat);
	return 0;
}

/***************************************************************************/
int Cmd_ydtcl_classification(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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
    int i,j,nper=0,longvar,nmes,nper2;
	double w_period,w_minlong,w_periodog,w_PDM,w_Entropie,somme_w;
	Tcl_DString dsptr;
    gsl_permutation *perm1,*rank1;
    gsl_permutation *perm2,*rank2;
	gsl_permutation *perm3,*rank3;
	gsl_permutation *perm4,*rank4;
	gsl_permutation *perm5,*rank5;
    gsl_permutation *perm6;
	gsl_vector *periods,*period_temp,*minlong,*periodog,*PDM,*Entropie,*best_periods, *perm;
	if(argc!=9) {
		sprintf(s,"Usage: %s inputs must be periods minlong periodog PDM Entropie nmes longvar nper2", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
      /* --- decodage des arguments ---*/
        code = gsltcltcl_getgslvector(interp,argv[1],&periods,&nper);
		code1=gsltcltcl_getgslvector(interp,argv[2],&minlong,&nper);
        code2=gsltcltcl_getgslvector(interp,argv[3],&periodog,&nper);
	    code3=gsltcltcl_getgslvector(interp,argv[4],&PDM,&nper);
		code4=gsltcltcl_getgslvector(interp,argv[5],&Entropie,&nper);
		nmes=atoi(argv[6]);
		longvar=atoi(argv[7]);
		nper2=atoi(argv[8]);
		
		/* --- inits ---*/
		perm1=gsl_permutation_alloc(nper);
		perm2=gsl_permutation_alloc(nper);
		perm3=gsl_permutation_alloc(nper);
		perm4=gsl_permutation_alloc(nper);
		perm5=gsl_permutation_alloc(nper);
		rank1=gsl_permutation_alloc(nper);
		rank2=gsl_permutation_alloc(nper);
		rank3=gsl_permutation_alloc(nper);
		rank4=gsl_permutation_alloc(nper);
		rank5=gsl_permutation_alloc(nper);
		perm6=gsl_permutation_alloc(nper);
        period_temp=gsl_vector_calloc(nper);

		/*Attribution des poids*/
		if (longvar) {
			if (nmes>60) {
				w_period=5;
				w_periodog=0;
				w_minlong=1;
				w_PDM=10;
				w_Entropie=1;
			} else {
                w_period=1;
				w_periodog=0;
				w_minlong=1;
				w_PDM=10;
				w_Entropie=1;
			}
			/*nper2=5;*/
		} else {
            if (nmes>150) {
				w_period=0;
				w_minlong=1;
				w_periodog=0;                
				w_PDM=1;
				w_Entropie=1;
            } else {
				w_period=0;
				w_minlong=1;
				w_periodog=0;                
				w_PDM=1;
				w_Entropie=1;
            }
		}
		somme_w=w_period+w_minlong+w_periodog+w_PDM+w_Entropie;

		if (w_period!=0) {
			gsl_vector_memcpy(period_temp,periods);
			gsl_vector_scale(period_temp,w_period);
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

		perm=gsl_vector_alloc(nper);
		for (i=0;i<nper;i++) {
			perm->data[i]=w_period*rank1->data[i]+w_minlong*rank2->data[i]+w_periodog*rank3->data[i]+w_PDM*rank4->data[i]+w_Entropie*rank5->data[i];
			perm->data[i]=perm->data[i]/somme_w;
		}
		gsl_sort_vector_index(perm6,perm);
		best_periods = gsl_vector_calloc(nper2);
		if (nper<nper2) {nper2=nper;}
		for (i=0;i<nper2;i++){
			j=perm6->data[i];
			best_periods->data[i]=periods->data[j];
        }
        /* --- sortie du resultat ---*/
        Tcl_DStringInit(&dsptr);
        gsltcltcl_setgslvector(interp,&dsptr,best_periods,nper2);
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
int Cmd_ydtcl_ajustement(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction ajustement                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) jdphase0 (jd0 to compute phases)
			3) The mags vector
			4) The mags weigth vector
			5) The best periods vector
			6) The number of harmonics in Fourier series
   Outputs: 1) The best periods vector sorted following the chi2 test
			2) The final number of harmonics (only for the best period)
			3) The Fourier coefficients vector (only for the best period)
Example:
	set has "" ; set dfocs "" ; set poids ""
	set pi [expr 4*atan(1)]
	for {set kk -180} {$kk<=360} {incr kk 5} {
		set x [expr 1.*$kk]
		set y -500
		set y [expr $y+300*cos(1.*$x/$period*2*$pi)]
		set y [expr $y+200*sin(1.*$x/$period*2*$pi)]
		set y [expr $y+100*cos(2.*$x/$period*2*$pi)]
		set y [expr $y+ 50*sin(2.*$x/$period*2*$pi)]
		lappend has $x
		lappend dfocs $y
		lappend poids 1
	}
}
::plotxy::hold off
::plotxy::plot $has $dfocs '.o'
set res [yd_ajustement $has 0 $dfocs $poids {360} 4]
set period [expr [lindex $res 0]]
set nhar [lindex $res 1]
set coefs [lindex $res 2]
set xs ""
set ys ""
set pi [expr 4*atan(1)]
for {set kk -180} {$kk<=360} {incr kk 5} {
	set x [expr 1.*$kk]
	set y [lindex $coefs end]
	for {set k 1} {$k<=[expr 2*$nhar]} {incr k 2} {
		set harm [expr ($k+1)/2]
		set y [expr $y+[lindex $coefs [expr $k-1]]*cos($harm*$x/$period*2*$pi)]
		set y [expr $y+[lindex $coefs [expr $k  ]]*sin($harm*$x/$period*2*$pi)]
	}
	lappend xs $x
	lappend ys $y
}
::plotxy::hold on
::plotxy::plot $xs $ys '-b'

*/
/***************************************************************************/
{
    char s[200];
    int code,code1,code2,code3;
    int nper=0,nhar=0,nmes=0;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*poids,*best_periods,*coefs,*phases;
	double residu,residu_min0,residu_min00,i_best0,nhar_best0;
    gsl_vector *residu_min,*i_bests, *nhar_bests;
    double res;
    double deltaphasemax,jdphase0;
    int nhar0,i,j,ii,i_bestbest,nhar_bestbest,nmes1,valid=1;

	if(argc!=7) {
        sprintf(s,"Usage: %s jds jdphase0 mags poids best_periods nhar", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
   } else {
        /* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		  if (nmes==0) {
			  sprintf(s,"Error: jds has no data !");
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
		  }
		  nmes1=nmes;
		jdphase0=atof(argv[2]);
		code1=gsltcltcl_getgslvector(interp,argv[3],&mags,&nmes);
		  if (nmes!=nmes1) {
			  sprintf(s,"Error: mags has not the same length as jds (%d instead of %d) !",nmes,nmes1);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
		  }
		code2=gsltcltcl_getgslvector(interp,argv[4],&poids,&nmes);
		  if (nmes!=nmes1) {
			  sprintf(s,"Error: poids has not the same length as jds (%d instead of %d) !",nmes,nmes1);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
		  }
        code3=gsltcltcl_getgslvector(interp,argv[5],&best_periods,&nper);
		nhar =atoi(argv[6]);
		/* --- inits ---*/
   	    residu_min00=1e+90;
		phases=gsl_vector_calloc(nmes);
		residu_min=gsl_vector_calloc(nper);
		i_bests=gsl_vector_calloc(nper);
		nhar_bests=gsl_vector_calloc(nper);

		for (i=0;i<nper;i++) {
			/* --- determine n_har0, le nombre d'harmoniques maximum à prendre ---*/
			for (j=0;j<nmes;j++) {
				res=(jds->data[j]-jdphase0)/best_periods->data[i];
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
			/*nhar0=(int)(1./deltaphasemax/1.2);*/
			if (nhar0>nhar) {
				nhar0=nhar;
			}
			if (nhar0<1) {
				nhar0=1;
			}

			coefs=gsl_vector_calloc(1+2*nhar0);
			yd_moin_carr(phases,mags,poids,nhar0,nmes,coefs,&residu);
			
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
		/*calcule les phases pour cette periode*/
		for (j=0;j<nmes;j++) {
			res=(jds->data[j]-jdphase0)/best_periods->data[i_bestbest];
			phases->data[j]=res-floor(res);
		}
		yd_moin_carr(phases,mags,poids,nhar_bestbest,nmes,coefs,&residu);
				
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
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,phases,nmes);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(poids);
		gsl_vector_free(best_periods);
        gsl_vector_free(phases);
		gsl_vector_free(residu_min);
		gsl_vector_free(i_bests);
		gsl_vector_free(coefs);
		gsl_vector_free(nhar_bests);
	}
	return TCL_OK;
}
/************************************************************************************/
int yd_moin_carr(gsl_vector *phases, gsl_vector *mags,gsl_vector *poids, int n_arm,int nmes, gsl_vector *coefs, double *residu)
/***************************************************************************/
/* Fonction moin_carr                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
            2) jdphase0 (jd0 to compute phases)
			3) The weigth vector
			5) The period
			6) The number of harmonics
			7) The jds length
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
			gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*phases->data[j]));
			gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*phases->data[j]));
		}
	}
    for (j=0;j<nmes;j++) {
		gsl_matrix_set(A,j,2*n_arm,1.);
	}
    W=gsl_matrix_calloc(nmes,nmes);
	for (j=0;j<nmes;j++) {
		w=poids->data[j];
		/*w=1/(w*w);*/
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
int Cmd_ydtcl_cour_final(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction cour_final                                                       */
/***************************************************************************/
/* Inputs : 1) The phase vector
            2) The mags vector
			3) The error bars vector
			4) The Fourier series coefficients
			5) The sigma of mags
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
	double pi,stdmodel,deltamag,deltamag2,val1,val2,sigma,sigma2;
	gsl_matrix *A;
	gsl_vector *phases,*mags,*bars,*magpobss,*ind_jdgoods,*ind_jdbads;
	int k_good,k_bad;

	if(argc!=6) {
        sprintf(s,"Usage: %s phases mags bars coefs sigma", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&phases,&nmes);
		code1=gsltcltcl_getgslvector(interp,argv[2],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[3],&bars,&nmes);
		code3=gsltcltcl_getgslvector(interp,argv[4],&coefs,&k);
		sigma =atof(argv[5]);
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
				gsl_matrix_set(A,j,2*i-1,sin(2*pi*i*phases->data[j]));
			    gsl_matrix_set(A,j,2*i-2,cos(2*pi*i*phases->data[j]));
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
   	    gsl_vector_free(phases);
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
	  /*modif yassine %f -> %.12f pour etre compatible avec le reste*/
      sprintf(s,"%.12f",gsl_vector_get(vec,k));
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
int yd_perchoice(gsl_vector *jds, gsl_vector *mags, int nmes, double interval, int *temoin, int *indice_prem_date, int *indice_dern_date)
/***************************************************************************/
/* Fonction perchoice                                                       */
/***************************************************************************/
/* Fonction with the aim to choose trial periods following the criterion ni*delta_Pi=accu*Pi<<Pi,
/* and eliminate aliasing periods
/* Inputs : 1) The jds vector
			2) The jds vector length
   Outputs: 1) Temoin = 0 if data length is shorter than 1 year or there isn't enough data in 1 year
                      = 1 else
			2) The index of the first day of the choosen year (in jds vector)
			3) The index of the last day of the choosen year (in jds vector)
*/
/***************************************************************************/
{
    double delta_t;
	int imes,kdeb,kfin,kmil,kmes,ind1,ind2,temoin2;
	int	compteur_date,nmesmin;
	double amplitude,amplitude_tmp,mag,magmax,magmin;

	compteur_date=0;
	nmesmin=150;
	ind1=0;
	ind2=nmes-1;
    imes=1;
	temoin2=0;
	amplitude_tmp=0.;

	/*L'attribution du meilleur intervalle se basera sur le produit nmes*nmes*amplitude*/
	/*pour chaque mesure on determine l'indice de la date pour laquelle dt<interval*/
	imes=0;
	while (1) {
		kdeb=imes;
		kfin=nmes;
		kmil=0;
		while (1) {
			if (kfin-kdeb<2) {break;}
			kmil=(kdeb+kfin)/2;
            delta_t=jds->data[kmil]-jds->data[imes];
			if (delta_t>interval) {
				kfin=kmil;
				continue;
			}
			if (delta_t<interval) {
				kdeb=kmil;
				continue;
			}
		}
		if (kfin==nmes) {
			break;
		}
		compteur_date=kmil-imes;
		/*Maintenant l'amplitude, malheureusement par une boucle */
		magmin=1e10;
		magmax=-100.;
		for (kmes=imes;kmes<=kmil;kmes++) {
			mag = mags->data[kmes];
			if (mag<magmin) { magmin=mag; }
			if (mag>magmax) { magmax=mag; }
		}
		amplitude = magmax-magmin;
		amplitude*=compteur_date*compteur_date;
		if ((amplitude>amplitude_tmp)&&(compteur_date>nmesmin)) {
			amplitude_tmp=amplitude;
			ind1=imes;
			ind2=kmil;
			temoin2=1;
		}
		imes++;
	}
	/*Je sais que cest un peu bête mais j'ai encore (beaucoup) des doutes sur les pointeurs*/
	*indice_prem_date=ind1;
	*indice_dern_date=ind2;
	*temoin=temoin2;
	return 0;
}
/************************************************************************************/
int Cmd_ydtcl_meansigma(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction meansigma                                                       */
/***************************************************************************/
/* Inputs : A vector
   Outputs: Its mean and sigma
*/
/***************************************************************************/
{
	char **argvv1=NULL,**argvv2=NULL,s[200];
    int argcc1,argcc2;
    int code1,code2,i,n=0;
	double mean=0,sigma=0;
	double *vec=NULL,*err=NULL;
	Tcl_DString dsptr;
	if((argc<2)||(argc>3)) {
        sprintf(s,"Usage: %s Input must be a vector (and its errors) ", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
		code1=Tcl_SplitList(interp,argv[1],&argcc1,&argvv1);
		if (argcc1<=0) {
			Tcl_SetResult(interp,"Le vecteur est nul",TCL_VOLATILE);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			return TCL_ERROR;
        }
		vec=(double*)malloc(argcc1*sizeof(double));
		if (vec==NULL) {
			sprintf(s,"error : vec pointer out of memory (%d elements)",argcc1);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		err=(double*)malloc(argcc1*sizeof(double));
		if (err==NULL) {
			sprintf(s,"error : err pointer out of memory (%d elements)",argcc1);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		if (argc==2) {
			for (i=0;i<argcc1;i++) {
				vec[i]=(double)atof(argvv1[i]);
				err[i]=1.;
			}
			yd_util_meansigma_poids(vec,err,0,argcc1,0,&mean,&sigma);
		} else {
            code2=Tcl_SplitList(interp,argv[2],&argcc2,&argvv2);
			if (argcc1!=argcc2) {
				Tcl_SetResult(interp,"Les 2 vecteurs doivent avoir la meme dimension",TCL_VOLATILE);
				Tcl_Free((char *) argvv1);
				Tcl_Free((char *) argvv2);
				return TCL_ERROR;
			}

			for (i=0;i<argcc1;i++) {
				vec[i]=(double)atof(argvv1[i]);
				err[i]=(double)atof(argvv2[i]);
			}
			yd_util_meansigma_poids(vec,err,0,argcc1,0,&mean,&sigma);
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

		free(vec);
		free(err);
		Tcl_Free((char *) argvv1);
		Tcl_Free((char *) argvv2);
	}
	return TCL_OK;
}
/***************************************************************************/
int Cmd_ydtcl_per_range(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
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
		yd_util_qsort_double(dt,0,nmes2,NULL);
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
int Cmd_ydtcl_moy_bars_comp(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction yd_per_range
   Inputs : 1) The mags vector
			2) The error bars vector
			3) The mags mean
			4) The mags sigma
   Outputs: The ratio of bad points
*/
/***************************************************************************/
{
	char s[200];
    int code,code2,nmes=0,i,temoin=0,compteur;
	double moyenne,res,sigma;/*,mediane*/
	Tcl_DString dsptr;
    gsl_vector *bars,*mags;
	gsl_permutation *perm;
	if(argc!=5) {
		sprintf(s,"Usage: %s Invalid input : must be 2 vector and a scalar", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[2],&bars,&nmes);
		moyenne=atof(argv[3]);
		sigma=atof(argv[4]);

		perm=gsl_permutation_alloc(nmes);
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
		/*2eme critere sigma>5*mediane(bars)*/
		/*gsl_sort_vector_index(perm,bars);
		mediane=bars->data[perm->data[nmes/2]];
		if (sigma<5*mediane) {temoin = 1;}*/

		Tcl_DStringInit(&dsptr);
	    sprintf(s,"%d",temoin);
	    Tcl_DStringAppend(&dsptr,s,-1);
	    Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);
	    gsl_vector_free(mags);
	    gsl_vector_free(bars);
		gsl_permutation_free(perm);
	}
    return TCL_OK;
}
/************************************************************************************************************************************************************/
int yd_dichotomie(double per, gsl_vector *badpers, gsl_vector *deltabadpers, int nbad, int *temoin2, int *k_bad)
/*************************************************************************************************************************************************************/
/* Fonction que j'utilise dans yd_nettoyage, elle me sert de retrouver les éléments d'un vecteur
   grace à l'algo de dichotomie utilisé par Alain dans yd_filehtm2refzmgmes
*/
{
	int k,k_per,k_per1,k_per2,sortie;
	double dper,badper,deltaper,badpersmax;

    *temoin2=0;
	badpersmax=badpers->data[nbad-1]+deltabadpers->data[nbad-1];
	/** badpersmax voir yd_aliasing*/
	if (per>badpersmax) {
		return 0;
	}

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
		deltaper=deltabadpers->data[k];
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
		deltaper=deltabadpers->data[k];
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
/*Fonction pour calculer le PGCD
Inputs : 1) vecteur
		 2) Sa taille
		 3) La limite inferieure du pgcd
		 4) La tolerance
Outputs: 1) le PGCD (s'il existe)
		 2) 1 si PGCD existe, 0 sinon*/
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
int Cmd_ydtcl_shortorlong(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction shortorlong  : determine si on doit chercher une longue iu une courte periode                                                                                     */
/*********************************************************************************************************/
/* Inputs: 1) The jd vector
           2) The mag vector
		   3) The mag weitgh vector
		   4) The mag amplitude
		   5) The mag sigma
		   6) The lowest authorized period  per_range_max
		   7) The highest authorized period  per_range_max
		   8) The number of bins
  Outputs: 1) 1 if is a long term variable
           2) The frequency step
		   3) The best period if is a long term variable

/***************************************************************************/
{
	char s[200];
    int code,code2,code3,code4;
    int nmes,nbin,nbin2,nper,nper2;
    Tcl_DString dsptr;
    gsl_vector *jds,*mags,*poids,*vraipoids,*phase,*temp,*dtemp,*PERIODS,*PDM,*ENTROPIE,*PERIODS2,*PDM2,*ENTROPIE2;
	double amplitude,sigma,vraiesigma,freq,freqmax;
	double pdmmin,pdm,pdm2,entropie,pdmalias,pdmlong,vraipdmlong,vraipdmlong2,pdmlong2,maxim;
	double per_range_min,per_range_max,limit,limit2,limit3,limit4,pi,pasfreq,pasfreq2,pasfreq3,bestper,principale;
	int temoin,k_x,k_per,kk,iter,predisp;
/*FILE *f;*/
    if(argc!=12) {
		sprintf(s,"Usage: %s jds mags poids vraiepoids amplitude sigma per_range_min per_range_max nper nbin", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&nmes);
		code3=gsltcltcl_getgslvector(interp,argv[3],&poids,&nmes);
		code4=gsltcltcl_getgslvector(interp,argv[4],&vraipoids,&nmes);
		amplitude=atof(argv[5]);
		sigma=atof(argv[6]);
		vraiesigma=atof(argv[7]);
		per_range_min=atof(argv[8]);
		per_range_max=atof(argv[9]);
		nper=atoi(argv[10]);
		nbin=atoi(argv[11]);

		/* --- inits ---*/
		limit=0.4;
		limit2=0.6;
		limit3=0.15;
		limit4=0.65;
		pi=atan(1)*4;
		nbin2=4;
		/*on calcule le pas de frequence*/
        pasfreq=2*sqrt(6./nmes)*sigma/(pi*per_range_max*amplitude);
		/*Je le sature quand meme pour avoir au maximum 100000 periodes a tester*/
		pasfreq3=(5e-7>pasfreq)?5e-7:pasfreq;
		pasfreq2=(1e-4>pasfreq)?1e-4:pasfreq;
		if (per_range_max<=20) {
			/*Nous chercherons une courte periode*/
			temoin=0;
			predisp=0;
			Tcl_DStringInit(&dsptr);
			sprintf(s,"%1d",temoin);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%6.5e",pasfreq);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%6.5e",pasfreq3);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%1d",predisp);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringResult(interp,&dsptr);
			Tcl_DStringFree(&dsptr);
			return TCL_OK;
		}
		sigma*=sigma;
		gsl_vector_add_constant(jds,-jds->data[0]);
		temp=gsl_vector_calloc(nmes);
		dtemp=gsl_vector_calloc(nmes);
		phase=gsl_vector_calloc(nmes);
		if (per_range_min<=20) {
			/*Je cherche le PDM minimum pour P proche de 0.5j : on testera au maximum 1000 frequences*/
			freq=1.95;
			pdmmin=1e30;
			gsl_vector_memcpy(temp,jds);
			gsl_vector_scale(temp,freq);
			gsl_vector_memcpy(dtemp,jds);
			gsl_vector_scale(dtemp,pasfreq2);
			while (freq<2.05) {
				for (k_x=0;k_x<nmes;k_x++) {
					phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
				}
				yd_pdm_entropie(phase,mags,poids,nmes,nbin,&pdm,&entropie);
				if (pdmmin>pdm) {pdmmin=pdm;}
				freq+=pasfreq2;
				gsl_vector_add(temp,dtemp);
			}
			/*Je cherche le PDM minimum pour P proche de 1j : on testera au maximum 1000 frequences*/
			freq=0.95;
			gsl_vector_memcpy(temp,jds);
			gsl_vector_scale(temp,freq);
			gsl_vector_memcpy(dtemp,jds);
			gsl_vector_scale(dtemp,pasfreq2);
			while (freq<1.05) {
				for (k_x=0;k_x<nmes;k_x++) {
					phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
				}
				yd_pdm_entropie(phase,mags,poids,nmes,nbin,&pdm,&entropie);
				if (pdmmin>pdm) {pdmmin=pdm;}
				freq+=pasfreq2;
				gsl_vector_add(temp,dtemp);
			}
			/*J'ai trouve donc la valeur du pic daliasing de 1j et de 0.5j
			Je le compare avec le plus petit pic pour les longues periodes*/
			pdmalias=pdmmin/sigma;
			/*freqmax = 1/(20j)*/
			freqmax=0.05;
		} else {
			pdmalias=1.;
			freqmax=1./per_range_min;
		}
		/*Je cherche le PDM minimum pour les longues peiodes (de 20j  per_max*/
		PERIODS=gsl_vector_calloc(nper);
		PDM=gsl_vector_calloc(nper);
		ENTROPIE=gsl_vector_calloc(nper);
		freq=1./per_range_max;
		pdmlong=1e30;
		gsl_vector_add_constant(PDM,pdmlong);
		k_per=0;
		gsl_vector_memcpy(temp,jds);
		gsl_vector_scale(temp,freq);
		gsl_vector_memcpy(dtemp,jds);
		gsl_vector_scale(dtemp,pasfreq3);
		while (freq<freqmax) {
			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
			}
			yd_pdm_entropie(phase,mags,poids,nmes,nbin,&pdm,&entropie);

			kk=gsl_vector_max_index(PDM);
			maxim=PDM->data[kk];
			if (pdm<maxim) {
				PERIODS->data[kk]=freq;
				PDM->data[kk]=pdm;
				ENTROPIE->data[kk]=entropie;
			}
			k_per++;
			freq+=pasfreq3;
			gsl_vector_add(temp,dtemp);
		}
		/*J'ai trouve donc la valeur du pic daliasing de 1j et de 0.5j
		Je le compare avec le plus petit pic pour les longues periodes*/
		nper2=nper;
		if (k_per<nper) {nper2=k_per;}
		PERIODS2=gsl_vector_calloc(nper2);
		PDM2=gsl_vector_calloc(nper2);
		ENTROPIE2=gsl_vector_calloc(nper2);

		pdmlong=2.;
		for (k_per=0;k_per<nper2;k_per++) {
			PERIODS2->data[k_per]=1./PERIODS->data[k_per];			
			PDM2->data[k_per]=PDM->data[k_per]/sigma;
			ENTROPIE2->data[k_per]=ENTROPIE->data[k_per];
			if(PDM2->data[k_per]<pdmlong) {
				pdmlong=PDM2->data[k_per];
				bestper=PERIODS2->data[k_per];
			}
		}

		gsl_vector_free(PDM);
		gsl_vector_free(PERIODS);
        gsl_vector_free(ENTROPIE);
		freq=1./bestper;
		/*il vaut mieux la faire ici*/
		gsl_vector_memcpy(temp,jds);
		gsl_vector_scale(temp,freq);
		for (k_x=0;k_x<nmes;k_x++) {
			phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
		}
		yd_pdm_entropie(phase,mags,poids,nmes,nbin2,&pdmlong2,&entropie);
		pdmlong2/=sigma;
			
		temoin=0;
		/*if ((pdmlong2<limit2)&&(pdmalias<limit2)&&(pdmlong2<1.5*pdmalias)) {*/
		if ((pdmlong2<limit2)&&(pdmalias<limit)&&(pdmlong<limit)) {
			temoin = 1;
		} else if ((pdmlong<limit3)&&(pdmlong2<limit2)) {
			temoin=1;
		} else if (pdmlong<0.1) {
			temoin=1;
		}
vraipdmlong=1.;
vraipdmlong2=1.;
		if(!temoin){
			yd_pdm_entropie(phase,mags,vraipoids,nmes,nbin,&vraipdmlong,&entropie);
			vraipdmlong/=(vraiesigma*vraiesigma);
			yd_pdm_entropie(phase,mags,vraipoids,nmes,nbin2,&vraipdmlong2,&entropie);
			vraipdmlong2/=(vraiesigma*vraiesigma);
			vraipdmlong=(vraipdmlong<pdmlong)?vraipdmlong:pdmlong;
			vraipdmlong2=(vraipdmlong2<pdmlong2)?vraipdmlong2:pdmlong2;
			if((vraipdmlong<0.65)&&(vraipdmlong2<0.9)) {
                predisp=1;
			} else if(vraipdmlong<0.5) {
				predisp=1;
			} else {
				predisp=0;
			}
		}
		/*on teste si cette bestper n'est pas la sousharmonique d'une autre (utile pour les cepheides*/
		if ((temoin)&&(bestper<40)) {
            iter=2;
			while(iter<5) {
				principale=bestper/iter;
				if((principale<20)&&(principale<per_range_max)) {
					gsl_vector_memcpy(temp,jds);
					gsl_vector_scale(temp,1./principale);
					for (k_x=0;k_x<nmes;k_x++) {
						phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
					}
					yd_pdm_entropie(phase,mags,poids,nmes,nbin,&pdm,&entropie);
					pdm/=sigma;
					yd_pdm_entropie(phase,mags,poids,nmes,nbin2,&pdm2,&entropie);
					pdm2/=sigma;
					if ((pdm<1.5*pdmlong)&&(pdm2<1.5*pdmlong)) {
						temoin=0;
						predisp=0;
					}
					break;
				}
				iter++;
			}
		}

		if(temoin) {predisp=0;}

		if (per_range_min>=20) {
			/*Nous chercherons une longue periode*/
			temoin=1;
			predisp=0;
		}
/*f=fopen("toto.txt","a");
fprintf(f,"%.2f %.2f %.2f %.2f %1d %1d\n", pdmlong,pdmlong2,vraipdmlong,vraipdmlong2,temoin,predisp);
fclose(f);*/
		
		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		sprintf(s,"%1d",temoin);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr," ",-1);
		sprintf(s,"%6.5e",pasfreq);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr," ",-1);
		sprintf(s,"%6.5e",pasfreq3);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr," ",-1);
		sprintf(s,"%1d",predisp);
		Tcl_DStringAppend(&dsptr,s,-1);
		
		Tcl_DStringAppend(&dsptr," {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,PERIODS2,nper2);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,PDM2,nper2);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,ENTROPIE2,nper2);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		
		gsl_vector_free(mags);
		gsl_vector_free(jds);
		gsl_vector_free(poids);
		gsl_vector_free(vraipoids);
		gsl_vector_free(temp);
		gsl_vector_free(dtemp);
		gsl_vector_free(phase);
        gsl_vector_free(PERIODS2);
		gsl_vector_free(PDM2);
		gsl_vector_free(ENTROPIE2);
    }
	return TCL_OK;
}
int Cmd_ydtcl_poids(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction meansigma                                                       */
/***************************************************************************/
/* Inputs : A vector
   Outputs: Its mean and sigma
*/
/***************************************************************************/
{
	char **argvv1=NULL,**argvv2=NULL,s[200];
    int argcc1,argcc2;
    int code1,code2,i;
	double somme_poids;
	double *bars=NULL;
	int *flags=NULL;
	Tcl_DString dsptr;
	if(argc=!3) {
        sprintf(s,"Usage: %s bars ?flags ", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
    } else {
		code1=Tcl_SplitList(interp,argv[1],&argcc1,&argvv1);
		if (argcc1<=0) {
			Tcl_SetResult(interp,"Le vecteur bars est nul",TCL_VOLATILE);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			return TCL_ERROR;
        }
		bars=(double*)malloc(argcc1*sizeof(double));
		if (bars==NULL) {
			sprintf(s,"error : bars pointer out of memory (%d elements)",argcc1);
			Tcl_Free((char *) argvv1);
			Tcl_Free((char *) argvv2);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		if (argc==3) {
            code2=Tcl_SplitList(interp,argv[2],&argcc2,&argvv2);
			if (argcc2<=0) {
				Tcl_SetResult(interp,"Le vecteur flags est nul",TCL_VOLATILE);
				Tcl_Free((char *) argvv1);
				Tcl_Free((char *) argvv2);
				return TCL_ERROR;
			}
			if (argcc1!=argcc2) {
				sprintf(s,"Usage: %s bars flags have not the same size ", argv[0]);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			flags=(int*)malloc(argcc2*sizeof(int));
			if (flags==NULL) {
				sprintf(s,"error : flags pointer out of memory (%d elements)",argcc2);
				Tcl_Free((char *) argvv1);
				Tcl_Free((char *) argvv2);
				Tcl_SetResult(interp,s,TCL_VOLATILE);
				return TCL_ERROR;
			}
			for (i=0;i<argcc1;i++) {
				bars[i]=(double)atof(argvv1[i]);
				flags[i]=(int)atoi(argvv2[i]);
			}
			/*On calcule les poids et leur somme*/
			somme_poids=0;
			for (i=0;i<argcc1;i++) {
				bars[i]=1./(0.000001+bars[i]*bars[i]);
				if((flags[i]>0)&&(flags[i]<4)) {
					bars[i]=bars[i]/4.;
				}
				somme_poids+=bars[i];
			}
		} else {
			for (i=0;i<argcc1;i++) {
				bars[i]=(double)atof(argvv1[i]);
			}
			/*On calcule les poids et leur somme*/
			somme_poids=0;
			for (i=0;i<argcc1;i++) {
				bars[i]=1./(0.000001+bars[i]*bars[i]);
				somme_poids+=bars[i];
			}
		}

		/*On normalise*/
		for (i=0;i<argcc1;i++) {
			bars[i]=bars[i]/somme_poids;
		}
		Tcl_DStringInit(&dsptr);
        /*Tcl_DStringAppend(&dsptr,"{",-1);*/
		for (i=0;i<argcc1;i++) {
			sprintf(s,"%12.10f ",bars[i]);
			Tcl_DStringAppend(&dsptr,s,-1);
		}
		/*Tcl_DStringAppend(&dsptr,"}",-1);*/
		Tcl_DStringResult(interp,&dsptr);
        Tcl_DStringFree(&dsptr);

		free(bars);
		Tcl_Free((char *) argvv1);
		if (argc==3) {
            free(flags);
			Tcl_Free((char *) argvv2);
		}
	}
	return TCL_OK;
}
int Cmd_ydtcl_entropie_pdm(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction minlong     $jds $mags $poids $longvar $per_range_min $per_range_max $pasfreq $nper1                                                                                */
/*********************************************************************************************************/
/* Inputs: 1) The jd vector
           2) The mag vector
		   3) (The mag errors vector) The weight vector
		   4) 1 if we seek a long period - 0 else
		   5) The smallest authorized period per_range_min
		   6) The highest authorized period  per_range_max
		   7) The frequency step
		   8) The number of selected trial periods else
		   9) The number of bins
   Outputs 1) The best periods vector 
		   2) The PDM vector
		   3) The ENTROPIE vector
/***************************************************************************/
{
	char s[200];
    int code,code2,code3;
    int n_jd,n_mag,nmes,nper,nmes2;
    Tcl_DString dsptr;
    gsl_vector *jds,*jds2,*mags,*mags2,*poids,*poids2,*periods,*pdms,*entropies,*PERIODS,*PDM,*ENTROPIE,*phase,*temp,*dtemp;
	double maxim;
	int k_x,kk,k_per;
    double pasfreq,pasfreq2,pdm,entropie;
	double per_range_min,per_range_max,deltafreq,freq,nfreqmax,npermax,T2;
	int nper2,nbin,indice_prem_date,indice_dern_date,temoin,iter;
    /*FILE *f;*/
    if(argc!=9) {
		sprintf(s,"Usage: %s jds mags poids nper per_range_min per_range_max pasfreq nper nbin", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&jds,&n_jd);
		code2=gsltcltcl_getgslvector(interp,argv[2],&mags,&n_mag);
		code3=gsltcltcl_getgslvector(interp,argv[3],&poids,&n_mag);
		per_range_min=atof(argv[4]);
		per_range_max=atof(argv[5]);
		pasfreq=atof(argv[6]);
		nper=atoi(argv[7]);
		nbin=atoi(argv[8]);
        /* --- validite des arguments ---*/
		if (n_jd!=n_mag) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"jds and mags vectors must have the same dimension",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		nmes=n_jd;
		nfreqmax=100000.;

		periods=gsl_vector_calloc(nper);
		pdms=gsl_vector_calloc(nper);
		entropies=gsl_vector_calloc(nper);

		deltafreq=1./per_range_min-1./per_range_max;
		npermax=deltafreq/pasfreq;
		pasfreq2=deltafreq/nfreqmax;
		/*Dans le cas general, on cherchera des periodes entre 0.04 et 20j soit entre 0.05 et 25j-1
		Si on decide de chercher au maximum 100000 periodes (pas=2.5*10-4, nous devons reduire le nombre de mesure 
		et l'intervalle T, le rapport entre 2 pas (voir formule) est sqrt(N'/N)*T'/T* : donc nous reduisons T de ce rapport*/
		T2=floor(per_range_max/2.*pasfreq/pasfreq2);
		/*car T = per_range_max/2*/

		if (per_range_max>20) {per_range_max=20;}
		/*car cest comme ca que nous avons construit Cmd_ydtcl_shortoelong*/

		if (npermax>nfreqmax) {
			temoin=0;
			iter=1;
			while (iter<6) {
                yd_perchoice(jds,mags,nmes,iter*T2,&temoin,&indice_prem_date,&indice_dern_date);
				if (temoin) {break;}
				iter++;
			}
			if (temoin) {
				nmes2=indice_dern_date-indice_prem_date+1;
				jds2=gsl_vector_calloc(nmes2);
				mags2=gsl_vector_calloc(nmes2);
				poids2=gsl_vector_calloc(nmes2);
				kk=0;
				for (k_x=indice_prem_date;k_x<=indice_dern_date;k_x++) {
					jds2->data[kk]  = jds->data[k_x];
					mags2->data[kk] = mags->data[k_x];
					poids2->data[kk]= poids->data[k_x];
					kk++;
				}
				gsl_vector_free(jds);
				gsl_vector_free(mags);
				gsl_vector_free(poids);
				jds=gsl_vector_calloc(nmes2);
				mags=gsl_vector_calloc(nmes2);
				poids=gsl_vector_calloc(nmes2);
				gsl_vector_memcpy(jds,jds2);
				gsl_vector_memcpy(mags,mags2);
				gsl_vector_memcpy(poids,poids2);
				gsl_vector_free(jds2);
				gsl_vector_free(mags2);
				gsl_vector_free(poids2);
				nmes=nmes2;
			}
            npermax=nfreqmax;
			pasfreq=pasfreq2;
		}
		nper2=(int)npermax;

		phase=gsl_vector_calloc(nmes);
		temp=gsl_vector_calloc(nmes);
		gsl_vector_add_constant(jds,-jds->data[0]);
		dtemp=gsl_vector_calloc(nmes);
		gsl_vector_memcpy(dtemp,jds);
		gsl_vector_scale(dtemp,pasfreq);
		gsl_vector_memcpy(temp,jds);
		freq=1./per_range_max;
		gsl_vector_scale(temp,freq);
		k_per=0;
		while (k_per<nper2) {
			for (k_x=0;k_x<nmes;k_x++) {
				phase->data[k_x]=temp->data[k_x]-floor(temp->data[k_x]);
			}
			yd_pdm_entropie(phase,mags,poids,nmes,nbin,&pdm,&entropie);
			if (k_per<nper) {
				periods->data[k_per]=1./freq;
				pdms->data[k_per]=pdm;
				entropies->data[k_per]=entropie;
			} else {
				kk=gsl_vector_max_index(pdms);
				maxim=pdms->data[kk];
				if (pdm<maxim) {
					periods->data[kk]=1./freq;
					pdms->data[kk]=pdm;
					entropies->data[kk]=entropie;
				}
			}
			k_per++;
			freq+=pasfreq;
			gsl_vector_add(temp,dtemp);
		}
		
		nper2=nper;
		if (k_per<nper) {nper2=k_per;}
		PERIODS=gsl_vector_calloc(nper2);
		PDM=gsl_vector_calloc(nper2);
		ENTROPIE=gsl_vector_calloc(nper2);
		if (k_per<nper) {
			for (k_per=0;k_per<nper2;k_per++) {
				PERIODS->data[k_per]=periods->data[k_per];
				PDM->data[k_per]=pdms->data[k_per];
				ENTROPIE->data[k_per]=entropies->data[k_per];
			}
		} else {
			gsl_vector_memcpy(PERIODS,periods);
			gsl_vector_memcpy(PDM,pdms);
			gsl_vector_memcpy(ENTROPIE,entropies);
		}

		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		gsltcltcl_setgslvector(interp,&dsptr,PERIODS,nper2);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,PDM,nper2);
		Tcl_DStringAppend(&dsptr,"} {",-1);
		gsltcltcl_setgslvector(interp,&dsptr,ENTROPIE,nper2);
		Tcl_DStringAppend(&dsptr,"} ",-1);
		sprintf(s,"%6.5e",pasfreq2);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(phase);
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(poids);
		gsl_vector_free(temp);
		gsl_vector_free(dtemp);
		gsl_vector_free(periods);
		gsl_vector_free(pdms);
		gsl_vector_free(entropies);
		gsl_vector_free(PERIODS);
		gsl_vector_free(PDM);
		gsl_vector_free(ENTROPIE);
		return TCL_OK;
    }
}
int Cmd_ydtcl_ajustement_spec(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction ajustement                                                       */
/***************************************************************************/
/* Inputs : 1) The jds vector
			2) jdphase0 (jd0 to compute phases)
			3) The mags vector
			4) The mags weigth vector
			5) The best periods vector
			6) The number of harmonics in Fourier series
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
    gsl_vector *jds,*mags,*poids,*best_periods,*phases,*phases_long,*phases_short;
	double residu_short,residu_long;
    gsl_vector *coefs_long,*coefs_short;
    double res;
    double deltaphasemax,jdphase0,rapport,limit_per_long,eps,per_alias;
    int nhar0,i,j,temoin,nhar_long,nhar_short,temoin2,compteur;
	int k_phase,k_phasemax=8,k_phase_vide;
	int hist[8];

	if(argc!=7) {
        sprintf(s,"Usage: %s Inputs must be jds jdphase0 mags poids periods_shortlong nhar", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
       return TCL_ERROR;
   } else {
        /* --- decodage des arguments ---*/
        code=gsltcltcl_getgslvector(interp,argv[1],&jds,&nmes);
		jdphase0=atof(argv[2]);
		code1=gsltcltcl_getgslvector(interp,argv[3],&mags,&nmes);
		code2=gsltcltcl_getgslvector(interp,argv[4],&poids,&nmes);
        code3=gsltcltcl_getgslvector(interp,argv[5],&best_periods,&nper);
		nhar =atoi(argv[6]);
		/* --- inits ---*/
		phases=gsl_vector_calloc(nmes);
		phases_short=gsl_vector_calloc(nmes);
		phases_long=gsl_vector_calloc(nmes);
		temoin=1;
		eps=0.05;
		per_alias=0.5;
		/*Par construction nper=2 : 1ere periode est la periode courte, la 2eme est la periode longue*/
		limit_per_long=20.;

		for (i=0;i<nper;i++) {
			/* --- determine n_har0, le nombre d'harmoniques maximum à prendre ---*/
			for (j=0;j<nmes;j++) {
				res=(jds->data[j]-jdphase0)/best_periods->data[i];
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
			/*nhar0=(int)(1./deltaphasemax/1.2);*/
			if (nhar0>nhar) {
				nhar0=nhar;
			}
			if (nhar0<1) {
				nhar0=1;
			}

			/*Faire attention ici car il faut qu'il y ait 2 periodes a tester seulement*/
			if (i==0) {
				nhar_short=nhar0;
				coefs_short=gsl_vector_calloc(1+2*nhar_short);
				yd_moin_carr(phases,mags,poids,nhar_short,nmes,coefs_short,&residu_short);
				gsl_vector_memcpy(phases_short,phases);
			} else {
				nhar_long=nhar0;
				coefs_long=gsl_vector_calloc(1+2*nhar_long);
				yd_moin_carr(phases,mags,poids,nhar_long,nmes,coefs_long,&residu_long);
				gsl_vector_memcpy(phases_long,phases);
				/*je construis l'histogramme des phases*/
				for (k_phase=0;k_phase<k_phasemax;k_phase++) {
					hist[k_phase]=0;
				}
				for (j=0;j<nmes;j++) {
					k_phase=(int)floor(phases->data[j]*k_phasemax);
					if (k_phase==k_phasemax) {k_phase=k_phasemax-1;}
					hist[k_phase]++;
				}
				k_phase_vide=0;
				for (k_phase=0;k_phase<k_phasemax;k_phase++) {
					if (hist[k_phase]==0) {k_phase_vide++;}
				}
				if (k_phase_vide>0.5*k_phasemax) {temoin=0;}	
			}
		}
		
		/*je regarde si la periode trouvee est un sousmultiple de 1j*/
		temoin2=0;
		compteur=0;
		if(temoin) {
			if (best_periods->data[0]<=0.95*per_alias) {
				compteur++;
                rapport=2*per_alias/best_periods->data[0];
                rapport=rapport-floor(rapport);
				if((rapport>eps)&&(rapport<(1.-eps))) { temoin2++; }
			}
			if (best_periods->data[0]>0.95*per_alias) {
				compteur++;
                rapport=best_periods->data[0]/per_alias;
                rapport=rapport-floor(rapport);
				if((rapport>eps)&&(rapport<(1.-eps))) { temoin2++; }
			}
			if (best_periods->data[0]>1.5*per_alias) {
				compteur++;
                rapport=best_periods->data[0]/per_alias/2;
                rapport=rapport-floor(rapport);
				if((rapport>eps)&&(rapport<(1.-eps))) { temoin2++; }
			}
			if (best_periods->data[0]>10*per_alias) { temoin=0; }
		}
		if ((temoin)&&(residu_long>2.5*residu_short)) {
			temoin=0;
		}
		if ((temoin)&&(temoin2==compteur)) {
			temoin=0;
		}
		/*les periodes tres proches de 1j*/
		if ((best_periods->data[0]>1-eps)&&(best_periods->data[0]<1+eps)) {
			if (residu_long<5*residu_short) { temoin=1; }
		}

		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		if (temoin) {
			sprintf(s,"%.11f",best_periods->data[1]);
			Tcl_DStringAppend(&dsptr,s,-1);		
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%d",nhar_long);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,coefs_long,1+2*nhar_long);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,phases_long,nmes);
		} else {
			sprintf(s,"%.11f ",best_periods->data[0]);
			Tcl_DStringAppend(&dsptr,s,-1);		
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%d",nhar_short);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,coefs_short,1+2*nhar_short);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,phases_short,nmes);
		}			
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(jds);
		gsl_vector_free(mags);
		gsl_vector_free(poids);
		gsl_vector_free(best_periods);
        gsl_vector_free(phases);
		gsl_vector_free(coefs_short);
		gsl_vector_free(coefs_long);
		gsl_vector_free(phases_short);
		gsl_vector_free(phases_long);
	}
	return TCL_OK;
}
int Cmd_ydtcl_coefs_rucinski(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction Coefs_rucinski : rephase la courbe de lumiere par rapport au minimum (classification des binaires)*/
/*********************************************************************************************************/
/* Inputs  Fourier coefficients
   Outputs New Fourier coefficients
/***************************************************************************/
{
	char s[200];
    int code;
    int ncoef,nmes,nhar;
    Tcl_DString dsptr;
	gsl_vector *coefs,*new_coefs;
	double phimin,magmax,magmin,phase,magnitude,pi;
	int k_coef;
    double pasfreq,period,jdphi0_old,cos_phimin,sin_phimin,ai,bi;
    /*FILE *f;*/
    if(argc!=2) {
		sprintf(s,"Usage: %s coefs", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code=gsltcltcl_getgslvector(interp,argv[1],&coefs,&ncoef);
        /* --- validite des arguments ---*/
		if (ncoef<3) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"Coefs must have at least 3 elements",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		pi         = 4*atan(1);
		nmes       = 1000;
		pasfreq    = 1./nmes;
		period     = coefs->data[0];
		jdphi0_old = coefs->data[1];
		nhar       = (ncoef-3)/2;
		new_coefs  = gsl_vector_alloc(ncoef-1);

		phimin     = 0;
		magmax     = -1e10;
		magmin     = 1e10;
		phase      = 0;
		while (phase<1) {
			magnitude=coefs->data[2];
			for (k_coef=1;k_coef<=nhar;k_coef++) {
				magnitude=magnitude+coefs->data[2*k_coef+1]*cos(2*pi*k_coef*phase);
				magnitude=magnitude+coefs->data[2*k_coef+2]*sin(2*pi*k_coef*phase);
			}
			if (magnitude>magmax) {
				magmax=magnitude;
				phimin=phase;
			}
			if (magnitude<magmin) {
				magmin=magnitude;
			}
			phase+=pasfreq;
		}
		/*Le nouveau jdphase0*/
		new_coefs->data[0]=period*phimin+jdphi0_old;
		/*Le nouveau c1 : on multiplie par -1 pour inverser la courbe de lumiere*/
		new_coefs->data[1]=-(coefs->data[2]-magmin-1);
		/*Les nouveau ai,bi : on multiplie par -1 pour inverser la courbe de lumiere*/
		for (k_coef=1;k_coef<=nhar;k_coef++) {
			ai=coefs->data[2*k_coef+1];
			cos_phimin=cos(2*pi*k_coef*phimin);
			bi=coefs->data[2*k_coef+2];
			sin_phimin=sin(2*pi*k_coef*phimin);
			new_coefs->data[2*k_coef]= -(ai*cos_phimin+bi*sin_phimin);
			new_coefs->data[2*k_coef+1]= -(bi*cos_phimin-ai*sin_phimin);
		}

		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		gsltcltcl_setgslvector(interp,&dsptr,new_coefs,ncoef-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		/* --- liberation de la memoire ---*/
		gsl_vector_free(new_coefs);
		gsl_vector_free(coefs);
		return TCL_OK;
    }
}
int Cmd_ydtcl_detect_multiple_per(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction : permet de detecter les periodes multiples                    */
/***************************************************************************/
/* Inputs : 1) Fourier coefficients
			2) Periode
   Outputs: 1) New Fourier coefficients
			2) New periode
*/
/***************************************************************************/
{
    char s[200];
    int code;
    int ncoef,nmes,nhar,equidist;
    Tcl_DString dsptr;
	gsl_vector *coefs,*new_coefs,*mag_minima,*mag_maxima,*phi_minima,*phi_maxima,*magnitudes;
	gsl_matrix *A,*A_transp,*A_transp_A,*A_transp_A_inv,*A_transp2;
	gsl_permutation *p;
	double phase,phase2,magnitude,pi,periode,new_periode,magnitude1,magnitude2,magnitude3;
	int k_coef,kmag,signum,compt_extrema,compt_minima,compt_maxima,i,j,temoin,temoin1,temoin2;
    double pasfreq,dmag1,dmag2,dmag0,dmag,dphase,rien,dphasemax,dphasemin,dphilim,dmaglim;
	if(argc!=3) {
		sprintf(s,"Usage: %s coefs multiple", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code     = gsltcltcl_getgslvector(interp,argv[1],&coefs,&ncoef);
		periode  = atof(argv[2]);
        /* --- validite des arguments ---*/
		if (ncoef<3) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"Coefs must have at least 3 elements",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		pi         = 4*atan(1);
		nmes       = 200;
		pasfreq    = 1./nmes;
		nhar       = (ncoef-1)/2;
		dmaglim    = 0.1;
		dphilim    = 0.08;
		new_coefs  = gsl_vector_alloc(ncoef);
		mag_minima = gsl_vector_alloc(nmes/2);
		mag_maxima = gsl_vector_alloc(nmes/2);
		phi_minima = gsl_vector_alloc(nmes/2);
		phi_maxima = gsl_vector_alloc(nmes/2);
		magnitudes = gsl_vector_alloc(nmes);
		phase      = 0.;
		magnitude1 = coefs->data[0];
		for (k_coef=1;k_coef<nhar+1;k_coef++) {
			rien       = 2*pi*k_coef*phase;
			magnitude1 += coefs->data[2*k_coef-1]*cos(rien)+coefs->data[2*k_coef]*sin(rien);
		}
		magnitudes->data[0]=magnitude1;
		phase      += pasfreq;
		magnitude2 = coefs->data[0];
		for (k_coef=1;k_coef<nhar+1;k_coef++) {
			rien       = 2*pi*k_coef*phase;
			magnitude2 += coefs->data[2*k_coef-1]*cos(rien)+coefs->data[2*k_coef]*sin(rien);
		}
		magnitudes->data[1]=magnitude2;
		phase       += pasfreq;
		compt_minima = 0;
		compt_maxima = 0;
		kmag         = 2;
		temoin1      = 0;
		temoin2      = 0;
		dphasemax    = 0;
		dphasemin    = 0;
		while (kmag<nmes) {
			magnitude3 = coefs->data[0];
			for (k_coef=1;k_coef<nhar+1;k_coef++) {
				rien       = 2*pi*k_coef*phase;
				magnitude3 += coefs->data[2*k_coef-1]*cos(rien)+coefs->data[2*k_coef]*sin(rien);
			}
			magnitudes->data[kmag]=magnitude3;
			dmag1          = magnitude2-magnitude1;
			if (dmag1>=0) {
				dmag1 = 1;
			} else {
				dmag1 = -1;
			}
			dmag2          = magnitude3-magnitude2;
			if (dmag2>=0) {
				dmag2 = 1;
			} else {
				dmag2 = -1;
			}
			/*la derivee seconde*/
			dmag          = dmag2-dmag1;
			if (dmag==2) {
				/*c'est un minima local*/
				mag_minima->data[compt_minima]= magnitude2;
				if (temoin1) {
                    phi_minima->data[compt_minima]= phase-pasfreq-dphasemin;
				} else {
					phi_minima->data[compt_minima]=0;
				}
				temoin1=1;
				dphasemin=phase-pasfreq;
				compt_minima++;
			}
			if (dmag==-2) {
				/*c'est un maxima local*/
				mag_maxima->data[compt_maxima]= magnitude2;
				if (temoin2) {
                    phi_maxima->data[compt_maxima]= phase-pasfreq-dphasemax;
				} else {
					phi_maxima->data[compt_maxima]=0;
				}
				temoin2=1;
				dphasemax=phase-pasfreq;
				compt_maxima++;
			}
			magnitude1 = magnitude2;
			magnitude2 = magnitude3;
			phase     += pasfreq;
			kmag++;
		}
		
		/*Le nombre de maxima doit etre egal au nombre de minima*/
		/*on verifie que les minima sont equidistants en phase*/
		equidist = 1;
		if ((compt_minima<2)||(compt_maxima<2)) {
			equidist = 0;
		}
		compt_extrema=min(compt_minima,compt_maxima);
		if ((periode<1)&&(compt_extrema<3)) {
			equidist = 0;
			/*Je suppose que c'est une binaire donc la periode devrait etre bonne*/
		}
		if ((equidist)&&(compt_maxima>1)) {
			for (i=1;i<compt_maxima-1;i++) {
				for (j=i+1;j<compt_maxima;j++) {
					dphase=fabs(phi_maxima->data[j]-phi_maxima->data[i]);
					if (dphase>dphilim) {
						equidist=0;
						break;
					}
				}
				if (!equidist) {break;}
			}
		}
		if ((equidist)&&(compt_minima>1)) {
			for (i=1;i<compt_minima-1;i++) {
				for (j=i+1;j<compt_minima;j++) {
					dphase=fabs(phi_minima->data[j]-phi_minima->data[i]);
					if (dphase>dphilim) {
						equidist=0;
						break;
					}
				}
				if (!equidist) {break;}
			}
		}
		/*on verifie les differences de magnitude*/
		if ((equidist)&&(compt_maxima>1)) {
			dmag0=0;
			temoin  = 0;
			for (i=0;i<compt_maxima-1;i++) {
				for (j=i+1;j<compt_maxima;j++) {
					magnitude=fabs(mag_maxima->data[j]-mag_maxima->data[i]);
					dmag=magnitude-dmag0;
					if (temoin) {
						if (magnitude>dmaglim) {
							equidist=0;
							break;
						}
					}
					temoin  = 1;
					dmag0   = magnitude;
				}
				if (!equidist) {break;}
			}
		}
		if ((equidist)&&(compt_minima>1)) {
			dmag0=0;
			temoin  = 0;
			for (i=0;i<compt_minima-1;i++) {
				for (j=i+1;j<compt_minima;j++) {
					magnitude=fabs(mag_minima->data[j]-mag_minima->data[i]);
					dmag=magnitude-dmag0;
					if (temoin) {
						if (magnitude>dmaglim) {
							equidist=0;
							break;
						}
					}
					temoin  = 1;
					dmag0   = magnitude;
				}
				if (!equidist) {break;}
			}
		}
		if (equidist){
			A              = gsl_matrix_calloc(nmes,1+2*nhar);
			A_transp       = gsl_matrix_calloc(1+2*nhar,nmes);
			A_transp2      = gsl_matrix_calloc(1+2*nhar,nmes);
			A_transp_A     = gsl_matrix_calloc(1+2*nhar,1+2*nhar);
			A_transp_A_inv = gsl_matrix_calloc(1+2*nhar,1+2*nhar);
			p              = gsl_permutation_alloc(1+2*nhar);
			for (j=0;j<nmes;j++) {
				gsl_matrix_set(A,j,0,1.);
			}			
			for (i=1;i<nhar+1;i++) {
				phase = 0;
				for (j=0;j<nmes;j++){
					if (periode<1) {
						/*Je suppose que c'est une binaire*/
						/*je cherche la periode 2/compt_extrema car binaire 2 extrema*/
						phase2 = phase*compt_extrema/2;
						new_periode = periode*2/compt_extrema;
					} else {
						phase2 = phase*compt_extrema;
						new_periode = periode/compt_extrema;
					}
					phase2 = phase2-floor(phase2);
					phase2*= 2*pi*i;
					gsl_matrix_set(A,j,2*i-1,cos(phase2));
					gsl_matrix_set(A,j,2*i,sin(phase2));

					phase +=pasfreq;
				}
			}
			/*Ma matrice poids est la matrice identite*/
			/* inv(A'*A)*A'*magnitude*/
			gsl_matrix_transpose_memcpy(A_transp,A);
			gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,A_transp,A,0.0,A_transp_A);
			gsl_linalg_LU_decomp(A_transp_A,p,&signum);
			gsl_linalg_LU_invert(A_transp_A,p,A_transp_A_inv);
			gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,A_transp_A_inv,A_transp,0.0,A_transp2);
			gsl_blas_dgemv(CblasNoTrans,1.0,A_transp2,magnitudes,0.0,new_coefs);
			/**/
			gsl_matrix_free(A);
			gsl_matrix_free(A_transp);
			gsl_matrix_free(A_transp2);
			gsl_matrix_free(A_transp_A);
			gsl_matrix_free(A_transp_A_inv);
			gsl_permutation_free(p);
		}
		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		sprintf(s,"%1d",equidist);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringAppend(&dsptr,"}",-1);
		if (equidist) {
			Tcl_DStringAppend(&dsptr," {",-1);
			gsltcltcl_setgslvector(interp,&dsptr,new_coefs,ncoef);
			Tcl_DStringAppend(&dsptr,"} {",-1);
			sprintf(s,"%12.6f ",new_periode);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr,"}",-1);
		}
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);

		/* --- liberation de la memoire ---*/
		gsl_vector_free(new_coefs);
		gsl_vector_free(coefs);
		gsl_vector_free(mag_minima);
		gsl_vector_free(mag_maxima);
		gsl_vector_free(phi_minima);
		gsl_vector_free(phi_maxima);
		gsl_vector_free(magnitudes);
		return TCL_OK;
	}
}
int Cmd_ydtcl_phase_multiple_per(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/***************************************************************************/
/* Fonction : permet de detecter les periodes multiples                    */
/***************************************************************************/
/* Inputs : 1) Fourier coefficients
			2) Periode
   Outputs: 1) New Fourier coefficients
			2) New periode
*/
/***************************************************************************/
{
    char s[200];
    int code;
    int ncoef,nmes,nhar;
    Tcl_DString dsptr;
	gsl_vector *coefs,*new_coefs,*magnitudes;
	gsl_matrix *A,*A_transp,*A_transp_A,*A_transp_A_inv,*A_transp2;
	gsl_permutation *p;
	double phase,phase2,pi;
	int k_coef,kmag,signum;
    double pasfreq,rien,rien2,multiple;
/*FILE *f;*/
	if(argc!=3) {
		sprintf(s,"Usage: %s coefs multiple", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		code     = gsltcltcl_getgslvector(interp,argv[1],&coefs,&ncoef);
		multiple = atof(argv[2]);
        /* --- validite des arguments ---*/
		if (ncoef<3) {
			/* --- message d'erreur a propos des dimensions ---*/
            Tcl_SetResult(interp,"Coefs must have at least 3 elements",TCL_VOLATILE);
            return TCL_ERROR;
		}
		/* --- inits ---*/
		pi         = 4*atan(1);
		nmes       = 200;
		pasfreq    = 1./nmes;
		nhar       = (ncoef-1)/2;
		new_coefs  = gsl_vector_alloc(ncoef);
		/*if (multiple>1) {*/
			nmes   = nmes*(int)ceil(multiple);
		/*}*/
		magnitudes = gsl_vector_alloc(nmes);
		A          = gsl_matrix_calloc(nmes,1+2*nhar);
		A_transp   = gsl_matrix_calloc(1+2*nhar,nmes);
		A_transp2  = gsl_matrix_calloc(1+2*nhar,nmes);
		A_transp_A = gsl_matrix_calloc(1+2*nhar,1+2*nhar);
		A_transp_A_inv = gsl_matrix_calloc(1+2*nhar,1+2*nhar);
		p          = gsl_permutation_alloc(1+2*nhar);
		
		phase      = 0.;
		kmag = 0;
		while (kmag<nmes) {
			gsl_matrix_set(A,kmag,0,1.);
			phase2     = phase;
			phase2  = phase2/multiple;
			phase2  = phase2-floor(phase2);
			magnitudes->data[kmag]=coefs->data[0];
			for (k_coef=1;k_coef<nhar+1;k_coef++) {
				rien                    = 2*pi*k_coef*phase;
				rien2                   = 2*pi*k_coef*phase2;
				magnitudes->data[kmag] += coefs->data[2*k_coef-1]*cos(rien)+coefs->data[2*k_coef]*sin(rien);
				gsl_matrix_set(A,kmag,2*k_coef-1,cos(rien2));
				gsl_matrix_set(A,kmag,2*k_coef,sin(rien2));
			}
			phase     += pasfreq;
			kmag++;
		}

		/*Ma matrice poids est la matrice identite*/
		/* inv(A'*A)*A'*magnitude*/
		gsl_matrix_transpose_memcpy(A_transp,A);
		gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,A_transp,A,0.0,A_transp_A);
		gsl_linalg_LU_decomp(A_transp_A,p,&signum);
		gsl_linalg_LU_invert(A_transp_A,p,A_transp_A_inv);
		gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,A_transp_A_inv,A_transp,0.0,A_transp2);
		gsl_blas_dgemv(CblasNoTrans,1.0,A_transp2,magnitudes,0.0,new_coefs);
		/**/
		
		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		Tcl_DStringAppend(&dsptr,"{",-1);
		gsltcltcl_setgslvector(interp,&dsptr,new_coefs,ncoef);
		Tcl_DStringAppend(&dsptr,"}",-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);

		/* --- liberation de la memoire ---*/
		gsl_vector_free(new_coefs);
		gsl_vector_free(coefs);
		gsl_matrix_free(A);
		gsl_matrix_free(A_transp);
		gsl_matrix_free(A_transp2);
		gsl_matrix_free(A_transp_A);
		gsl_matrix_free(A_transp_A_inv);
		gsl_permutation_free(p);
		gsl_vector_free(magnitudes);
		return TCL_OK;
	}
}
int Cmd_ydtcl_util_reduit_nombre_digit(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/************************************************************************************************************/
/* Reduit le nombre de digit selon la valeur de l'incertitude                                     */
/************************************************************************************************************/
{
	char s[200],format[200];
    Tcl_DString dsptr;
	double x, dx,dx2;
	int ndigit;
    if(argc!=3) {
		sprintf(s,"Usage: %s value delta_value", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
		/* --- decodage des arguments ---*/
		x=atof(argv[1]);
		dx=atof(argv[2]);
		dx2=fabs(dx);

		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		if (dx2>10.) {
			sprintf(s,"%d",(int)x);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%d",(int)dx);
			Tcl_DStringAppend(&dsptr,s,-1);
		} else if (dx2>1.) {
			sprintf(s,"%.1f",x);
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%.1f",dx);
			Tcl_DStringAppend(&dsptr,s,-1);
		} else {
			ndigit=(int)fabs(floor(log10(dx2)));
			ndigit++;
			sprintf(format,"%c.%df",'%',ndigit);
			sprintf(s,format,x);  
			Tcl_DStringAppend(&dsptr,s,-1);
			Tcl_DStringAppend(&dsptr," ",-1);
			sprintf(s,"%1.1e",dx);
			Tcl_DStringAppend(&dsptr,s,-1);
		}
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		return TCL_OK;
    }
}
int Cmd_ydtcl_pasfreq(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Fonction pasfreq  : correction pour le referee (cherche le pas de frequence)                                                                                    */
/*********************************************************************************************************/
/* Inputs: 1) periode
           2) amplitudeobs
		   3) sigma
		   4) per_range_min
		   5) per_range_max
		   6) nmes
  Outputs: 1) pasfreqfinal
/***************************************************************************/
{
	char s[200];
    Tcl_DString dsptr;
	double periode,amplitude,sigma,deltafreq;
	double per_range_min,per_range_max,pasfreq,pasfreq2,pi,pasfreqfinal,nfreqmax,nfreq;
	int nmes;
    if(argc!=7) {
		sprintf(s,"Usage: %s periode amplitude sigma per_range_min per_range_max nper nmes", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		/*[yd_pasfreq $jds $mags $periode $amplitudeobs $sigma $per_range_min $per_range_max]*/
		periode=atof(argv[1]);
		amplitude=atof(argv[2]);
		sigma=atof(argv[3]);
		per_range_min=atof(argv[4]);
		per_range_max=atof(argv[5]);
		nmes=atoi(argv[6]);
		/* --- inits ---*/
		nfreqmax=100000.;
		pi=4*atan(1);
		/*on calcule le pas de frequence*/
        pasfreq=2*sqrt(6./nmes)*sigma/(pi*per_range_max*amplitude);
		/*Je le sature quand meme pour avoir au maximum 100000 periodes a tester*/
		pasfreq2=(5e-7>pasfreq)?5e-7:pasfreq;
		if (periode>20) {
			pasfreqfinal=pasfreq2;
		} else {
			pasfreqfinal=pasfreq;
            deltafreq=1./per_range_min-1./per_range_max;
			nfreq=deltafreq/pasfreq;
			if (nfreq>nfreqmax) {			
				pasfreqfinal=deltafreq/nfreqmax;
			}
		}
		/* --- sortie du resultat ---*/
		Tcl_DStringInit(&dsptr);
		sprintf(s,"%6.5e",pasfreqfinal);
		Tcl_DStringAppend(&dsptr,s,-1);
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		return TCL_OK;
    }
}


int Cmd_ydtcl_lireusno(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Reecrire les fichiers *.cat  de l'unso en fichier ascii 
/* Dans cette fonction, je divise le ciel en boites rectangulaires de memes surfaces            */
/*********************************************************************************************************/
/* Inputs: 1) path d'entree
           2  catalogue in
		   3) path de sortie
/***************************************************************************/
{
	char s[200],fichier_in[1000],fichier_in_tail[200],fichier_out[1000],path_in[1000],path_out[1000],ligne[40],numzone[10];
	struct {
		unsigned long ra;
		unsigned long dec;
		unsigned long divers;
	} etoile_usno;
	double ra,dec,dr;
	int magb,magr;
	char* cp;
	unsigned long ix,iy;
	FILE *f_in,*f_out;
	double deltadeb,deltafin;	
	char *resultat=NULL;
	int *compteurs=NULL;
	int indicedeb,indicefin,i,j,zonenumero,compteur,nres;
	int fact_glob_dec,fact_gran_dec,fact_gran_ra,fact_petit_dec;
	double size_gran_ra,fact_peti_ra;
	int grand_bte_dec_deb,grand_bte_dec_fin,nb_boite_delta,nligne,ncarac,ncarac_lignes,case_number;
	int ind_grande_bte_ra,ind_petite_bte_ra,ind_grande_bte_dec,ind_petite_bte_dec,indice_global_dec;

	/* Dans cette fonction, je divise le ciel en 20(ra)x10(dec) boites rectangulaires de memes surfaces :
	=> 200 tables : (20x18°)(ra) X (10x18°) (dec) : Attention pour dec cest une moyenne car on va utiliser
	des boites de meme surface donc cest delta_(sin(dec))=constant
	RA :  chaque table contient : 240 sous tables (240*4.5 arcmin)  : 240 pour faire un TINYINT en MYSQL
	      => ind_grande_bte_ra   = floor(ra/18)
		     ind_petite_bte_ra   = floor(60(ra-20Indice_grande_table)/4.5)  : 60 est pour convertie en arcmin
			                     = floor((40/3)*(ra-20Indice_grande_table))
	DEC:  chaque table contient : 240 sous tables (240*4.5 arcmin)  : 240 pour faire un TINYINT en MYSQL
	      => indice_global_dec   = floor[(240*10/2)(sin(dec)+1)] : +1 est sin(-90)(voir chapitre 3 de ma these)
		                         = floor[1200(sin(dec)+1)]
             ind_grande_bte_ra   = floor(indice_global_dec/240)
		     ind_petite_bte_ra   = indice_global_dec-10*ind_grande_bte_ra (division euclidienne)
    Donc constantes dont nous avons besoin (a changer si on veut refaire) :
	     fact_glob_dec = 1200 (int)
		 fact_gran_dec = 10   (int)
		 size_gran_ra  = 18   (double)
		 fact_peti_ra  = 40/3 (double)
		 fact_gran_ra  = 20   (int)
		 fact_petit_dec= 240  (int)
	*/
    if(argc!=4) {
		sprintf(s,"Usage: %s path_in fichier_in_tail path_out", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		strcpy(path_in,argv[1]);
		strcpy(fichier_in_tail,argv[2]);
		strcpy(path_out,argv[3]);
        /*init*/
		dr=4*atan(1.)/180.;
		fact_glob_dec = 1200; 
		fact_gran_dec = 10;
		size_gran_ra  = 18.;
		fact_peti_ra  = 40./3;
		fact_gran_ra  = 20;
		fact_petit_dec= 240;
		nligne        = 200; /*nombre de lignes cumulees avant ecriture dans le fichier_out (pour ne pas trop acceder au disque dur*/
		ncarac        = 38; /*nombre de caracteres dans la ligne*/
		ncarac_lignes = ncarac*nligne;
		/**************************************/
		/*je recupere le numero de la zone*/
		sprintf(numzone,"%c%c%c%c%c",fichier_in_tail[4],fichier_in_tail[5],fichier_in_tail[6],fichier_in_tail[7]);
		zonenumero=atoi(numzone);
		deltadeb=-90+0.1*zonenumero; /*voir formatage des zone USNO (zone de 7.5°)*/
		deltafin=deltadeb+7.5;
		grand_bte_dec_deb=(int)floor(fact_glob_dec*(1+sin(deltadeb*dr)));
		grand_bte_dec_deb=(int)floor(grand_bte_dec_deb/fact_petit_dec);
		grand_bte_dec_fin=(int)floor(fact_glob_dec*(1+sin(deltafin*dr)));
		grand_bte_dec_fin=(int)floor(grand_bte_dec_fin/fact_petit_dec);
		nb_boite_delta=1+grand_bte_dec_fin-grand_bte_dec_deb;
        /*J'alloue une chaine de caracteres de 10*38*200 = nb_boite_delta*76000 */
		nres=nb_boite_delta*fact_gran_ra;
		resultat=(char*)malloc(nres*ncarac_lignes*sizeof(char));
        if (resultat==NULL) {
			sprintf(s,"error : resultat pointer out of memory (%d elements)",nres);
		}
		compteurs=(int*)malloc(nres*sizeof(int));
        if (compteurs==NULL) {
			sprintf(s,"error : compteurs pointer out of memory (%d elements)",nres);
		}	
		/*initialise le compteur*/
		compteur=0;
		while (compteur<nres) {
			compteurs[compteur]=0;
			compteur++;
		}

        sprintf(fichier_in,"%s%s",path_in,fichier_in_tail);
		f_in=fopen(fichier_in,"rb");
		if (f_in==NULL) {
			sprintf(s,"fichier_in %s not found",fichier_in);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}
		while (feof(f_in)==0) {
			fread(&etoile_usno,sizeof(etoile_usno),1,f_in);
			/*conversion vers little_endian*/
			cp = (char*)&etoile_usno.ra;
			cp[0] ^= (cp[3]^=(cp[0]^=cp[3]));
			cp[1] ^= (cp[2]^=(cp[1]^=cp[2]));
			cp += 4;
			ra=(double)(etoile_usno.ra)/(360000);
			cp = (char*)&etoile_usno.dec;
			cp[0] ^= (cp[3]^=(cp[0]^=cp[3]));
			cp[1] ^= (cp[2]^=(cp[1]^=cp[2]));
			cp += 4;
			dec=(double)(etoile_usno.dec)/(360000)-90.;
			cp = (char*)&etoile_usno.divers;
			cp[0] ^= (cp[3]^=(cp[0]^=cp[3]));
			cp[1] ^= (cp[2]^=(cp[1]^=cp[2]));
			cp += 4;
			iy=etoile_usno.divers;
			ix=(unsigned long)((double)(iy)/1000)*1000;
			magr=(int)(iy-ix);
			iy=iy/1000;
			ix=(unsigned long)((double)(iy)/1000)*1000;
			magb=(int)(iy-ix);

			if ((dec<=90)&&(dec>=-90)&&(ra<=360)&&(ra>=0)) {
				ind_grande_bte_ra  =(int)floor(ra/size_gran_ra);
				ind_petite_bte_ra  =(int)floor(fact_peti_ra*(ra-size_gran_ra*ind_grande_bte_ra));
				indice_global_dec  =(int)floor(fact_glob_dec*(1+sin(dec*dr)));
				ind_grande_bte_dec =(int)floor((double)indice_global_dec/fact_petit_dec);
				ind_petite_bte_dec =indice_global_dec-fact_petit_dec*ind_grande_bte_dec;
			
				sprintf(ligne,"%03d|%03d|%010.6f|%010.6f|%03d|%03d\n",ind_petite_bte_ra,ind_petite_bte_dec,ra,dec,magb,magr);
                case_number=ind_grande_bte_dec-grand_bte_dec_deb;
				indicedeb=ncarac_lignes*case_number+ncarac*compteurs[case_number];
				indicefin=indicedeb+ncarac;
				j=0;
				for (i=indicedeb;i<indicefin;i++) {
					resultat[i]=ligne[j];
					j++;
				}
				compteurs[case_number]++;
				if(compteurs[case_number]>=nligne) {
					compteurs[case_number]=0;
					sprintf(fichier_out,"%susno_%02d_%1d.dat",path_out,ind_grande_bte_ra,ind_grande_bte_dec);
					f_out=fopen(fichier_out,"at");
					fwrite(resultat+ncarac_lignes*(case_number),sizeof(char),ncarac_lignes,f_out);
					fclose(f_out);
				}
			}
		}
		fclose(f_in);
		/*j'ecris le reste de la variable resultat*/
		for (i=0;i<nres;i++) {
			if(compteurs[i]>0) {
				/*il faut retrouver les indices correspondant*/
				ind_grande_bte_dec=(int)floor(i/fact_gran_ra)+grand_bte_dec_deb;
				ind_grande_bte_ra=(int)floor((double)(i)/ind_grande_bte_dec)*fact_gran_ra;
				sprintf(fichier_out,"%susno_%02d_%1d.dat",path_out,ind_grande_bte_ra,ind_grande_bte_dec);
				f_out=fopen(fichier_out,"at");
				fwrite(resultat+ncarac_lignes*i,sizeof(char),ncarac*compteurs[i],f_out);
				fclose(f_out);
			}
		}
		free(resultat);
		free(compteurs);
		return TCL_OK;
    }
}

int Cmd_ydtcl_lire2mass(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* Reecrire les fichiers psc du 2mass en fichier ascii (en ne gardant que quelques colonnes               */
/*********************************************************************************************************/
/* Inputs: 1) fichier d'entre
		   2) path de sortie
		   3) hemisphere (1=N, 2=S)
/***************************************************************************/
{
	char s[200],fichier_in[1000],fichier_out[1000],path_out[1000],ligne[1000];
	char riens[20],corresp[3],photomcal[5];/*,blend[3];*/
	double ra,dec,dr,rienf,magj,magh,magk;
	FILE *f_in,*f_out;
	char *resultat=NULL;
	int *compteurs=NULL;
	int case_number,indicedeb,indicefin,i,j,hemis,compteur;
	int magj2,magh2,magk2,blend,corresp2;
	int fact_glob_dec,fact_gran_dec,fact_gran_ra,fact_petit_dec;
	double size_gran_ra,fact_peti_ra;
	int grand_bte_dec_deb,nb_boite_delta,nligne,ncarac,ncarac_lignes,nres;
	int ind_grande_bte_ra,ind_petite_bte_ra,ind_grande_bte_dec,ind_petite_bte_dec,indice_global_dec;


    if(argc!=4) {
		sprintf(s,"Usage: %s fichier_in path_out hemis", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		strcpy(fichier_in,argv[1]);
		strcpy(path_out,argv[2]);
		hemis=atoi(argv[3]);
   		/*init*/
		dr=4*atan(1.)/180.;
		fact_glob_dec = 1200; 
		fact_gran_dec = 10;
		size_gran_ra  = 18.;
		fact_peti_ra  = 40./3;
		fact_gran_ra  = 20;
		fact_petit_dec= 240;
		nligne        = 150; /*nombre de lignes cumulees avant ecriture dans le fichier_out (pour ne pas trop acceder au disque dur*/
		ncarac        = 61; /*nombre de caracteres dans la ligne*/
		ncarac_lignes = ncarac*nligne;
		nb_boite_delta= 5;  /*car il y a 5 region delta dans chaque hemisphere*/
		grand_bte_dec_deb=0;
		if (hemis==1) {grand_bte_dec_deb=5;}
		/**************************************/
		/*J'alloue une chaine de caracteres de 10*38*200 = nb_boite_delta*76000 */
		nres=nb_boite_delta*fact_gran_ra;
		resultat=(char*)malloc(nres*ncarac_lignes*sizeof(char));
        if (resultat==NULL) {
			sprintf(s,"error : resultat pointer out of memory (%d elements)",nres);
		}
		compteurs=(int*)malloc(nres*sizeof(int));
        if (compteurs==NULL) {
			sprintf(s,"error : compteurs pointer out of memory (%d elements)",nres);
		}	
		/*initialise le compteur*/
		compteur=0;
		while (compteur<nres) {
			compteurs[compteur]=0;
			compteur++;
		}

		f_in=fopen(fichier_in,"rt");
		if (f_in==NULL) {
			sprintf(s,"fichier_in %s not found",fichier_in);
			Tcl_SetResult(interp,s,TCL_VOLATILE);
			return TCL_ERROR;
		}

		while (feof(f_in)==0) {
			magj=-1e60;
			magh=-1e60;
			magk=-1e60;

			if (fgets(ligne,1000,f_in)!=NULL) {
				sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
				&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
				&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
				&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
				&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);
				/*conversion en milieme de magnitude*/
				magj2=(int)(1000*magj);
				magh2=(int)(1000*magh);
				magk2=(int)(1000*magk);

				if (magj<-1e30) {
					/*je rescane la ligne avec le format*/
					sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%2s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
					&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
					&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
					&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
					&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);

					if (magh<-1e30) {
						/*je rescane la ligne avec le format*/
						sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%2s|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
						&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
						&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
						&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
						&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);

						if (magk<-1e30) {
							/*je rescane la ligne avec le format*/
							sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%2s|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
							&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
							&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
							&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
							&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);
							magk2=-32000;
						}
						magh2=-32000;
					}
					magj2=-32000;
				}
				if (magh<-1e30) {
					/*je rescane la ligne avec le format*/
					sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%lf|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
					&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
					&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
					&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
					&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);

					if (magk<-1e30) {
						/*je rescane la ligne avec le format*/
						sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%lf|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
						&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
						&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
						&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
						&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);
						magk2=-32000;
					}
					magh2=-32000;
				}
				if (magk<-1e30) {
					/*je rescane la ligne avec le format*/
					sscanf(ligne,"%lf|%lf|%lf|%lf|%lf|%17s |%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%lf|%3s|%3s|%3d|%3s|%6s|%lf|%lf|%lf|%lf|%lf|%lf|%1s|%10s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%2s|%lf|%lf|%1s|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf|%lf\n",
					&ra,&dec,&rienf,&rienf,&rienf,&riens,&magj,&rienf,&rienf,&rienf,&magh,&rienf,&rienf,&rienf,&magk,
					&rienf,&rienf,&rienf,photomcal,&riens,&blend,&riens,&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&riens,
					&riens,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,
					&rienf,&rienf,&rienf,&riens,&rienf,&rienf,corresp,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf,&rienf);
					magk2=-32000;
				}
				if (blend>255) {blend=255;}
				corresp2=0;
				if (strcmp(corresp,"U")==0) {corresp2=1;};
				if (strcmp(corresp,"T")==0) {corresp2=2;};
				ind_grande_bte_ra  =(int)floor(ra/size_gran_ra);
				ind_petite_bte_ra  =(int)floor(fact_peti_ra*(ra-size_gran_ra*ind_grande_bte_ra));
				indice_global_dec  =(int)floor(fact_glob_dec*(1+sin(dec*dr)));
				ind_grande_bte_dec =(int)floor((double)indice_global_dec/fact_petit_dec);
				ind_petite_bte_dec =indice_global_dec-fact_petit_dec*ind_grande_bte_dec;
			
				sprintf(ligne,"%03d|%03d|%010.6f|%010.6f|%06d|%06d|%06d|%3s|%03d|%1d\n",ind_petite_bte_ra,ind_petite_bte_dec,ra,dec,magj2,magh2,magk2,photomcal,blend,corresp2);
				case_number=(ind_grande_bte_dec-grand_bte_dec_deb)*fact_gran_ra+ind_grande_bte_ra;
				indicedeb=ncarac_lignes*case_number+ncarac*compteurs[case_number];
				indicefin=indicedeb+ncarac;
				j=0;
				for (i=indicedeb;i<indicefin;i++) {
					resultat[i]=ligne[j];
					j++;
				}
				compteurs[case_number]++;
				if(compteurs[case_number]>=nligne) {
					compteurs[case_number]=0;
					sprintf(fichier_out,"%s2mass_%02d_%1d.dat",path_out,ind_grande_bte_ra,ind_grande_bte_dec);
					f_out=fopen(fichier_out,"at");
					fwrite(resultat+ncarac_lignes*(case_number),sizeof(char),ncarac_lignes,f_out);
					fclose(f_out);
				}
			}
		}
		fclose(f_in);
		/*j'ecris le reste de la variable resultat*/
		for (i=0;i<nres;i++) {
			if(compteurs[i]>0) {
				/*il faut retrouver les indices correspondant*/
				ind_grande_bte_dec=(int)floor(i/fact_gran_ra);
				ind_grande_bte_ra=i-ind_grande_bte_dec*fact_gran_ra;
				ind_grande_bte_dec+=grand_bte_dec_deb;
				sprintf(fichier_out,"%s2mass_%02d_%1d.dat",path_out,ind_grande_bte_ra,ind_grande_bte_dec);
				f_out=fopen(fichier_out,"at");
				fwrite(resultat+ncarac_lignes*i,sizeof(char),ncarac*compteurs[i],f_out);
				fclose(f_out);
			}
		}
		/*libere la memoire*/
		free(resultat);
		free(compteurs);
		return TCL_OK;
    }
}


int Cmd_ydtcl_requete_table(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/*********************************************************************************************************/
/* calcule les indices dans les tables pour effectuer des requetes dans l'usno ou le 2mass              */
/*********************************************************************************************************/
/* Inputs: 1) ra
		   2) de
		   3) rayon
   Outputs:1) ind_ra_table
		   2) ind_ra_dans_table
		   3) ind_dec_table
		   4) ind_dec_dans_table
		   5) radeb
		   6) rafin
		   7) decdeb
		   8) decfin
/***************************************************************************/
{
	char s[200];
	double ra,dec,dr,radius,decfin,decdeb,rafin,radeb,radius2;
	int fact_glob_dec,fact_gran_dec,fact_gran_ra,fact_petit_dec,fact_petit_dec2;
	double size_gran_ra,fact_peti_ra;
	int indice_global_dec,kra,kdec;
	int ind_grande_bte_radeb,ind_grande_bte_rafin,nbr_grande_bte_ra,ind_petite_bte_radeb,ind_petite_bte_rafin;
	int ind_grande_bte_decdeb,ind_grande_bte_decfin,nbr_grande_bte_dec,ind_petite_bte_decdeb,ind_petite_bte_decfin;
	Tcl_DString dsptr;

    if(argc!=4) {
		sprintf(s,"Usage: %s ra dec radius", argv[0]);
        Tcl_SetResult(interp,s,TCL_VOLATILE);
        return TCL_ERROR;
	} else {
        /* --- decodage des arguments ---*/
		ra=atof(argv[1]);
		dec=atof(argv[2]);
		radius=atof(argv[3]);
   		/*init*/
		dr=4*atan(1.)/180.;
		fact_glob_dec = 1200; 
		fact_gran_dec = 10;
		size_gran_ra  = 18.;
		fact_peti_ra  = 40./3;
		fact_gran_ra  = 20;
		fact_petit_dec= 240;
		fact_petit_dec2=fact_petit_dec-1;
		/**************************************/
		decfin=dec+radius;
		decdeb=dec-radius;
		radius2=radius/(cos(dec*dr)+1e-10);
		rafin=ra+radius2;
		if (rafin>=360) {rafin = rafin-360;}
		if (rafin<0)    {rafin = rafin+360;}
		radeb=ra-radius2;
		if (radeb>=360) {radeb = radeb-360;}
		if (radeb<0)    {radeb = radeb+360;}

		ind_grande_bte_radeb = (int)floor(radeb/size_gran_ra);
		ind_grande_bte_rafin = (int)floor(rafin/size_gran_ra);
		nbr_grande_bte_ra    = abs(ind_grande_bte_rafin-ind_grande_bte_radeb);
		ind_petite_bte_radeb = (int)floor(fact_peti_ra*(radeb-size_gran_ra*ind_grande_bte_radeb));
		ind_petite_bte_radeb = (int)floor(fact_peti_ra*(radeb-size_gran_ra*ind_grande_bte_radeb));
		ind_petite_bte_rafin = (int)floor(fact_peti_ra*(rafin-size_gran_ra*ind_grande_bte_rafin));

		indice_global_dec    =(int)floor(fact_glob_dec*(1+sin(decdeb*dr)));
		ind_grande_bte_decdeb=(int)floor((double)indice_global_dec/fact_petit_dec);
		ind_petite_bte_decdeb=indice_global_dec-fact_petit_dec*ind_grande_bte_decdeb;
		indice_global_dec    =(int)floor(fact_glob_dec*(1+sin(decfin*dr)));
		ind_grande_bte_decfin=(int)floor((double)indice_global_dec/fact_petit_dec);
		ind_petite_bte_decfin=indice_global_dec-fact_petit_dec*ind_grande_bte_decfin;
		nbr_grande_bte_dec   = abs(ind_grande_bte_decfin-ind_grande_bte_decdeb);

		/*Sortie et resultat*/
		Tcl_DStringInit(&dsptr);
		if(nbr_grande_bte_ra+nbr_grande_bte_dec==0) {
			/*on est dans une seule zone*/
			sprintf(s,"{%f %f %f %f} {%02d %d %d %d %d %d}",radeb,rafin,decdeb,decfin,ind_grande_bte_radeb,\
				ind_petite_bte_radeb,ind_petite_bte_rafin,ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
            Tcl_DStringAppend(&dsptr,s,-1);
		} else {
			/*on est dans plusieurs zones*/
			sprintf(s,"{%f %f %f %f}",radeb,rafin,decdeb,decfin);
			Tcl_DStringAppend(&dsptr,s,-1);
			if (ind_grande_bte_radeb<=ind_grande_bte_rafin) {
				if(nbr_grande_bte_ra<1){
					/*nbr_grande_bte_dec est forcement > 0*/
					sprintf(s," {%02d %d %d %d %d %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,ind_petite_bte_rafin,\
						ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
					Tcl_DStringAppend(&dsptr,s,-1);
					kdec=ind_grande_bte_decdeb+1;
					while(kdec<ind_grande_bte_decfin) {
						sprintf(s," {%02d %d %d %d 0 %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,ind_petite_bte_rafin,\
							kdec,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kdec++;
					}
					sprintf(s," {%02d %d %d %d 0 %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,ind_petite_bte_rafin,\
						ind_grande_bte_decfin,ind_petite_bte_decfin);
					Tcl_DStringAppend(&dsptr,s,-1);
				} else {
					if(nbr_grande_bte_dec<1){
						sprintf(s," {%02d %d %d %d %d %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra=ind_grande_bte_radeb+1;
						while(kra<ind_grande_bte_rafin) {
							sprintf(s," {%02d 0 %d %d %d %d}",kra,fact_petit_dec2,\
								ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
							Tcl_DStringAppend(&dsptr,s,-1);
							kra++;
						}
						sprintf(s," {%02d 0 %d %d %d %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
					} else {
						sprintf(s," {%02d %d %d %d %d %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra=ind_grande_bte_radeb+1;
						while(kra<ind_grande_bte_rafin) {
							sprintf(s," {%02d 0 %d %d %d %d}",kra,fact_petit_dec2,\
								ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
							Tcl_DStringAppend(&dsptr,s,-1);
							kra++;
						}
						sprintf(s," {%02d 0 %d %d %d %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kdec=ind_grande_bte_decdeb+1;
						while(kdec<ind_grande_bte_decfin) {
							sprintf(s," {%02d %d %d %d 0 %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
								kdec,fact_petit_dec2);
							Tcl_DStringAppend(&dsptr,s,-1);
							kra=ind_grande_bte_radeb+1;
							while(kra<ind_grande_bte_rafin) {
								sprintf(s," {%02d 0 %d %d 0 %d}",kra,fact_petit_dec2,\
									kdec,fact_petit_dec2);
								Tcl_DStringAppend(&dsptr,s,-1);
								kra++;
							}
							sprintf(s," {%02d 0 %d %d 0 %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
								kdec,fact_petit_dec2);
							Tcl_DStringAppend(&dsptr,s,-1);
							kdec++;
						}
						sprintf(s," {%02d %d %d %d 0 %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
							ind_grande_bte_decfin,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra=ind_grande_bte_radeb+1;
						while(kra<ind_grande_bte_rafin) {
							sprintf(s," {%02d 0 %d %d 0 %d}",kra,fact_petit_dec2,\
								ind_grande_bte_decfin,ind_petite_bte_decfin);
							Tcl_DStringAppend(&dsptr,s,-1);
							kra++;
						}
						sprintf(s," {%02d 0 %d %d 0 %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
							ind_grande_bte_decfin,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
					}
				}
			} else {
				/*par exemple on passe de 350 à 5*/
				/*nbr_grande_bte_ra est forcement > 0*/
				if(nbr_grande_bte_dec<1){
					sprintf(s," {%02d %d %d %d %d %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
						ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
					Tcl_DStringAppend(&dsptr,s,-1);
					kra=ind_grande_bte_radeb+1;
					while(kra<20) {
                        sprintf(s," {%02d 0 %d %d %d %d}",kra,fact_petit_dec2,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra++;
					}
					kra=0;
					while(kra<ind_grande_bte_rafin) {
                        sprintf(s," {%02d 0 %d %d %d %d}",kra,fact_petit_dec2,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra++;
					}
					sprintf(s," {%02d 0 %d %d %d %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
						ind_grande_bte_decdeb,ind_petite_bte_decdeb,ind_petite_bte_decfin);
					Tcl_DStringAppend(&dsptr,s,-1);
				} else {
					sprintf(s," {%02d %d %d %d %d %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
						ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
					Tcl_DStringAppend(&dsptr,s,-1);
					kra=ind_grande_bte_radeb+1;
					while(kra<20) {
                       sprintf(s," {%02d 0 %d %d %d %d}",kra,fact_petit_dec2,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra++;
					}
					kra=0;
					while(kra<ind_grande_bte_rafin) {
                        sprintf(s," {%02d 0 %d %d %d %d}",kra,fact_petit_dec2,\
							ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra++;
					}
					sprintf(s," {%02d 0 %d %d %d %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
						ind_grande_bte_decdeb,ind_petite_bte_decdeb,fact_petit_dec2);
					Tcl_DStringAppend(&dsptr,s,-1);

					kdec=ind_grande_bte_decdeb+1;
					while(kdec<ind_grande_bte_decfin) {
						sprintf(s," {%02d %d %d %d 0 %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
							kdec,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra=ind_grande_bte_radeb+1;
						while(kra<20) {
							sprintf(s," {%02d 0 %d %d 0 %d}",kra,fact_petit_dec2,\
								kdec,fact_petit_dec2);
							Tcl_DStringAppend(&dsptr,s,-1);
							kra++;
						}
						kra=0;
						while(kra<ind_grande_bte_rafin) {
							sprintf(s," {%02d 0 %d %d 0 %d}",kra,fact_petit_dec2,\
								kdec,fact_petit_dec2);
							Tcl_DStringAppend(&dsptr,s,-1);
							kra++;
						}
						sprintf(s," {%02d 0 %d %d 0 %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
							kdec,fact_petit_dec2);
						Tcl_DStringAppend(&dsptr,s,-1);
						kdec++;
					}
					sprintf(s," {%02d %d %d %d 0 %d}",ind_grande_bte_radeb,ind_petite_bte_radeb,fact_petit_dec2,\
						ind_grande_bte_decfin,ind_petite_bte_decfin);
					Tcl_DStringAppend(&dsptr,s,-1);
					kra=ind_grande_bte_radeb+1;
					while(kra<20) {
                       sprintf(s," {%02d 0 %d %d 0 %d}}",kra,fact_petit_dec2,\
							ind_grande_bte_decfin,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra++;
					}
					kra=0;
					while(kra<ind_grande_bte_rafin) {
                        sprintf(s," {%02d 0 %d %d 0 %d}",kra,fact_petit_dec2,\
							ind_grande_bte_decfin,ind_petite_bte_decfin);
						Tcl_DStringAppend(&dsptr,s,-1);
						kra++;
					}
					sprintf(s," {%02d 0 %d %d 0 %d}",ind_grande_bte_rafin,ind_petite_bte_rafin,\
						ind_grande_bte_decfin,ind_petite_bte_decfin);
					Tcl_DStringAppend(&dsptr,s,-1);
				}
			}
		}
		Tcl_DStringResult(interp,&dsptr);
		Tcl_DStringFree(&dsptr);
		return TCL_OK;
    }
}


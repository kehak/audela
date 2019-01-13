/* gsltcltcl_1.c
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
/* Ce fichier contient du C melange avec des fonctions de l'interpreteur   */
/* Tcl.                                                                    */
/* Ainsi, ce fichier fait le lien entre Tcl et les fonctions en C pur qui  */
/* sont disponibles dans les fichiers gsltcl_*.c.                              */
/***************************************************************************/
/* Le include gsltcltcl.h ne contient des infos concernant Tcl.                */
/***************************************************************************/
#include "gsltcltcl.h"

int Cmd_gsltcltcl_msphharm(ClientData clientData, Tcl_Interp *interp, 
                           int argc, char *argv[])
/****************************************************************************/
/* calculates the spherical harmonics                                       */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   /*int code,n;*/
   int l, m;
   char * _endptr[1] = {NULL,};
   double d1;
   Tcl_DString dsptr;
   gsl_sf_result _result;
   int _status;
   /* double res; */

   if(argc!=4) {
      sprintf(s,"Usage: %s double l m ", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      d1 = strtod(argv[1], _endptr);
      l=atoi(argv[2]); m=atoi(argv[3]);   
      if( ( *_endptr[0] !='\0') || ( *_endptr==argv[1]) ) {
         sprintf(s," argv[1] no double: %s\n", argv[1]);
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;
      }
      if( ( fabs(d1) > 1 ) || (m<0) || (l<m) ){
         sprintf(s, 
            "The parameters must satisfy m >= 0, l >= m, |x| <= 1\n");
         Tcl_SetResult(interp, s, TCL_VOLATILE);
         return TCL_ERROR;  
      }    

      /* res = gsl_sf_legendre_sphPlm( l, m, d1 );*/
      _status = gsl_sf_legendre_sphPlm_e( l, m, d1, & _result);
/*
#ifdef DEBUG
      printf(" res= = %.18f \n", res );
      printf("status= %s \n", gsl_strerror( _status ) );
      printf(" sphP %d %d = %.18f +-%.18f\n", l, 
                                           m, 
                                           _result.val,
                                           _result.err );
#endif
 */
      sprintf(s,"%.6f", (double)_result.val);
      /* concat dsptr*/
      Tcl_DStringInit(&dsptr);
      Tcl_DStringAppend( &dsptr, s, 6);

      /* set result */
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_mindex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui retourne la valeur d'un element d'une ListMatrix.         */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code,retour;
   int nl=0,nc=0,l,c;
   gsl_matrix *gslmat;
   
   if(argc!=4) {
      sprintf(s,"Usage: %s ListMatrix IndexLig IndexCol", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmat,&nl,&nc);
      retour = Tcl_GetInt(interp,argv[2],&l);
      if(retour!=TCL_OK) {
			gsl_matrix_free(gslmat);
         return retour; 
      }
      retour = Tcl_GetInt(interp,argv[3],&c);
      if(retour!=TCL_OK) {
			gsl_matrix_free(gslmat);
         return retour; 
      }
      if (l<1) {
         strcpy(s,"IndexLig must be >= 1");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
      if (l>nl) {
         sprintf(s,"IndexLig must be <= %d",nl);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
      if (c<1) {
         strcpy(s,"IndexCol must be >= 1");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
      if (c>nc) {
         sprintf(s,"IndexCol must be <= %d",nc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
	   l--;
	   c--;
      sprintf(s,"%g",gsl_matrix_get(gslmat,l,c));
      Tcl_SetResult(interp,s,TCL_VOLATILE);
		gsl_matrix_free(gslmat);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_mlength(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui retourne les dimensions d'une ListMatrix.                 */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nl=0,nc=0;
   gsl_matrix *gslmat;
   
   if(argc!=2) {
      sprintf(s,"Usage: %s ListMatrix", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmat,&nl,&nc);
      sprintf(s,"%d %d",nl,nc);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
		gsl_matrix_free(gslmat);
   }
   return TCL_OK;
}


int Cmd_gsltcltcl_mreplace(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui remplace un element d'une ListMatrix                      */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code,retour;
   int nl,nc,l,c;
   double val;
   Tcl_DString dsptr;
   gsl_matrix *gslmat;

   if(argc!=5) {
      sprintf(s,"Usage: %s ListMatrix IndexLig IndexCol Value", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmat,&nl,&nc);
      retour = Tcl_GetInt(interp,argv[2],&l);
      if(retour!=TCL_OK) {
			gsl_matrix_free(gslmat);
         return retour; 
      }
      retour = Tcl_GetInt(interp,argv[3],&c);
      if(retour!=TCL_OK) {
			gsl_matrix_free(gslmat);
         return retour; 
      }
      retour = Tcl_GetDouble(interp,argv[4],&val);
      if(retour!=TCL_OK) {
			gsl_matrix_free(gslmat);
         return retour; 
      }
      if (l<1) {
         strcpy(s,"IndexLig must be >= 1");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
      if (l>nl) {
         sprintf(s,"IndexLig must be <= %d",nl);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
      if (c<1) {
         strcpy(s,"IndexCol must be >= 1");
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
      if (c>nc) {
         sprintf(s,"IndexCol must be <= %d",nc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
			gsl_matrix_free(gslmat);
         return TCL_ERROR ;
      }              
	   l--;
	   c--;
      gsl_matrix_set(gslmat,l,c,val);    
	   Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslmatrix(interp,&dsptr,gslmat,nl,nc);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmat);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_mtranspose(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui retourne la transposee d'une ListMatrix.                  */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nl=0,nc=0;
   Tcl_DString dsptr;
   gsl_matrix *gslmat,*gslmattransp;

   if(argc!=2) {
      sprintf(s,"Usage: %s ListMatrix", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmat,&nl,&nc);
      gslmattransp=gsl_matrix_calloc(nc,nl);
      gsl_matrix_transpose_memcpy(gslmattransp,gslmat);
      Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslmatrix(interp,&dsptr,gslmattransp,nc,nl);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmat);
	   gsl_matrix_free(gslmattransp);
   }
   return TCL_OK;
}


int Cmd_gsltcltcl_mmult(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui multiplie deux ListMatrix                                 */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nal,nac,nbl,nbc,ncl,ncc;
   Tcl_DString dsptr;
   gsl_matrix *gslmata,*gslmatb,*gslmatc;
		
	if(argc!=3) {
      sprintf(s,"Usage: %s ListMatrixA ListMatrixB", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmata,&nal,&nac);
      code=gsltcltcl_getgslmatrix(interp,argv[2],&gslmatb,&nbl,&nbc);
	   if (nac!=nbl) {
         sprintf(s,"NcolA (%d) must be equal to NligB (%d)",nac,nbl);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_matrix_free(gslmatb);
         return TCL_ERROR ;
      }
		ncl=nal;
		ncc=nbc;
      gslmatc=gsl_matrix_calloc(ncl,ncc);
      /* Compute C = A B */
      gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,gslmata,gslmatb,0.0,gslmatc);
      Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslmatrix(interp,&dsptr,gslmatc,ncl,ncc);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmata);
	   gsl_matrix_free(gslmatb);
	   gsl_matrix_free(gslmatc);
   }
   return TCL_OK;
}


int Cmd_gsltcltcl_madd(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui additionne deux ListMatrix                                */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nal,nac,ncl,ncc;
   Tcl_DString dsptr;
   gsl_matrix *gslmata,*gslmatb,*gslmatc;
	double cst;
		
	if(argc!=3) {
      sprintf(s,"Usage: %s ListMatrixA ListMatrixB", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmata,&nal,&nac);
      code=gsltcltcl_getgslmatrix(interp,argv[2],&gslmatc,&ncl,&ncc);
		if ((ncc==1)&&(ncl==1)) {
         cst=gsl_matrix_get(gslmatc,0,0);
	      gsl_matrix_free(gslmatc);
			ncl=nal;
			ncc=nac;
         gslmatc=gsl_matrix_calloc(ncl,ncc);
         gsl_matrix_set_all(gslmatc,cst);
		}
	   if (nac!=ncc) {
         sprintf(s,"NcolA (%d) must be equal to NcolB (%d)",nac,ncc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_matrix_free(gslmatc);
         return TCL_ERROR ;
      }
	   if (nal!=ncl) {
         sprintf(s,"NligA (%d) must be equal to NligB (%d)",nal,ncl);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_matrix_free(gslmatc);
         return TCL_ERROR ;
      }
      gslmatb=gsl_matrix_calloc(nac,nac);
      gsl_matrix_set_identity(gslmatb);
      /* Compute C = A B + C */
      gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,gslmata,gslmatb,1.0,gslmatc);
      Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslmatrix(interp,&dsptr,gslmatc,nal,nac);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmata);
	   gsl_matrix_free(gslmatb);
	   gsl_matrix_free(gslmatc);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_msub(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui soustrait deux ListMatrix                                 */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nal,nac,ncl,ncc;
   Tcl_DString dsptr;
   gsl_matrix *gslmata,*gslmatb,*gslmatc;
	double cst;
		
	if(argc!=3) {
      sprintf(s,"Usage: %s ListMatrixA ListMatrixB", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmata,&nal,&nac);
      code=gsltcltcl_getgslmatrix(interp,argv[2],&gslmatc,&ncl,&ncc);
		if ((ncc==1)&&(ncl==1)) {
         cst=gsl_matrix_get(gslmatc,0,0);
	      gsl_matrix_free(gslmatc);
			ncl=nal;
			ncc=nac;
         gslmatc=gsl_matrix_calloc(ncl,ncc);
         gsl_matrix_set_all(gslmatc,cst);
		}
	   if (nac!=ncc) {
         sprintf(s,"NcolA (%d) must be equal to NcolB (%d)",nac,ncc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_matrix_free(gslmatc);
         return TCL_ERROR ;
      }
	   if (nal!=ncl) {
         sprintf(s,"NligA (%d) must be equal to NligB (%d)",nal,ncl);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_matrix_free(gslmatc);
         return TCL_ERROR ;
      }
      gslmatb=gsl_matrix_calloc(nac,nac);
      gsl_matrix_set_identity(gslmatb);
      /* Compute C = A B + C */
      gsl_blas_dgemm(CblasNoTrans,CblasNoTrans,1.0,gslmata,gslmatb,-1.0,gslmatc);
      Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslmatrix(interp,&dsptr,gslmatc,nal,nac);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmata);
	   gsl_matrix_free(gslmatb);
	   gsl_matrix_free(gslmatc);
   }
   return TCL_OK;
}


int Cmd_gsltcltcl_meigsym(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui diagonalise une ListMatrix symetrique                     */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nl,nc,n;
   Tcl_DString dsptr;
   gsl_matrix *mat,*evec;
   gsl_vector *eval;
   gsl_eigen_symmv_workspace *w;

	if(argc!=2) {
      sprintf(s,"Usage: %s ListMatrix", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&mat,&nl,&nc);
	   if (nl!=nc) {
         sprintf(s,"Nlig (%d) must be equal to Ncol (%d)",nl,nc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(mat);
         return TCL_ERROR ;
      }
	  n=nl;
      eval=gsl_vector_alloc(n);
      evec=gsl_matrix_alloc(n,n);
	  w=gsl_eigen_symmv_alloc(n);
	  gsl_eigen_symmv(mat,eval,evec,w);
      gsl_eigen_symmv_free(w);
	  gsl_eigen_symmv_sort(eval,evec,GSL_EIGEN_SORT_VAL_DESC);
      Tcl_DStringInit(&dsptr);
      Tcl_DStringAppend(&dsptr," { ",3);
      gsltcltcl_setgslvector(interp,&dsptr,eval,n);
      Tcl_DStringAppend(&dsptr," } ",3);
      /*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);
      gsltcltcl_setgslmatrix(interp,&dsptr,evec,n,n);
      /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	  gsl_matrix_free(mat);
	  gsl_matrix_free(evec);
	  gsl_vector_free(eval);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_minv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui inverse une ListMatrix                                    */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nl,nc,n;
   Tcl_DString dsptr;
   gsl_matrix *mat,*inv;
   gsl_permutation *p;
   int signum;

	if(argc!=2) {
      sprintf(s,"Usage: %s ListMatrix", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&mat,&nl,&nc);
	   if (nl!=nc) {
         sprintf(s,"Nlig (%d) must be equal to Ncol (%d)",nl,nc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(mat);
         return TCL_ERROR ;
      }
	  n=nl;
      inv=gsl_matrix_alloc(n,n);
	  p=gsl_permutation_alloc(n);
	  gsl_linalg_LU_decomp(mat,p,&signum);
	  gsl_linalg_LU_invert(mat,p,inv);
      gsl_permutation_free(p);
      Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslmatrix(interp,&dsptr,inv,n,n);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	  gsl_matrix_free(mat);
	  gsl_matrix_free(inv);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_mdet(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui calcule le determinant d'une ListMatrix                   */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nl,nc,n;
   Tcl_DString dsptr;
   gsl_matrix *mat;
   gsl_permutation *p;
   int signum;
   double det=0.;

	if(argc!=2) {
      sprintf(s,"Usage: %s ListMatrix", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&mat,&nl,&nc);
	   if (nl!=nc) {
         sprintf(s,"Nlig (%d) must be equal to Ncol (%d)",nl,nc);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(mat);
         return TCL_ERROR ;
      }
	  n=nl;
	  p=gsl_permutation_alloc(n);
	  gsl_linalg_LU_decomp(mat,p,&signum);
	  det=gsl_linalg_LU_det(mat,signum);
      gsl_permutation_free(p);
      Tcl_DStringInit(&dsptr);
      sprintf(s,"%s",gsltcl_d2s(det));
      Tcl_DStringAppendElement(&dsptr,s);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	  gsl_matrix_free(mat);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_msolvelin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui calcule x d'apres : Ax=b                                  */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int nal,nac,nb;
   Tcl_DString dsptr;
   gsl_matrix *gslmata;
	gsl_vector *gslvecb,*gslvecx;
   gsl_permutation *p;
   int signum;
		
	if(argc!=3) {
      sprintf(s,"Usage: %s ListMatrixA ListVectorB", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslmatrix(interp,argv[1],&gslmata,&nal,&nac);
      code=gsltcltcl_getgslvector(interp,argv[2],&gslvecb,&nb);
	   if (nac!=nal) {
         sprintf(s,"NligA (%d) must be equal to NcolA (%d)",nal,nac);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_vector_free(gslvecb);
         return TCL_ERROR ;
      }
	   if (nb!=nal) {
         sprintf(s,"NelemB (%d) must be equal to NligA (%d)",nb,nal);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmata);
	      gsl_vector_free(gslvecb);
         return TCL_ERROR ;
      }
      gslvecx=gsl_vector_alloc(nb);
	   p=gsl_permutation_alloc(nb);
	   gsl_linalg_LU_decomp(gslmata,p,&signum);
	   gsl_linalg_LU_solve(gslmata,p,gslvecb,gslvecx);
      gsl_permutation_free(p);
      Tcl_DStringInit(&dsptr);
      gsltcltcl_setgslvector(interp,&dsptr,gslvecx,nb);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmata);
	   gsl_vector_free(gslvecb);
	   gsl_vector_free(gslvecx);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_mfitmultilin(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui calcule c d'apres : y=Xc                                  */
/****************************************************************************/
/* y is a vector of n observations                                          */
/* X is an n by p matrix of predictor variables                             */
/* c are the p unknown best-fit parameters                                  */
/* w is the weights of the y values (n elements).                           */
/****************************************************************************/
/* gsl_mfitmultilin ListVectorY ListMatrixX ListVectorW                     */
/****************************************************************************/
/* return :                                                                 */
/* ListVectorC                                                              */
/* chisq                                                                    */
/* ListMatrixCov                                                            */
/****************************************************************************/
{
   char s[200];
   int code;
   int ny,nxc,nxl,nw,k;
   Tcl_DString dsptr;
   gsl_matrix *gslmatx,*gslmatcov;
	gsl_vector *gslvecy,*gslvecw,*gslvecc;
   gsl_multifit_linear_workspace *work;
   double chisq,w,dif,var;
		
	if(argc!=4) {
      sprintf(s,"Usage: %s ListVectorY ListMatrixX ListVectorW", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getgslvector(interp,argv[1],&gslvecy,&ny);
      code=gsltcltcl_getgslmatrix(interp,argv[2],&gslmatx,&nxl,&nxc);
      code=gsltcltcl_getgslvector(interp,argv[3],&gslvecw,&nw);
		/* n=nxl p=nxc */
		/* ny and nw should be = n = nxl */
	   if (ny!=nxl) {
         sprintf(s,"NelemY (%d) must be equal to NligX (%d)",ny,nxl);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmatx);
	      gsl_vector_free(gslvecy);
	      gsl_vector_free(gslvecw);
         return TCL_ERROR ;
      }
	   if (nw!=ny) {
         sprintf(s,"NelemW (%d) must be equal to NelemY (%d)",nw,ny);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
	      gsl_matrix_free(gslmatx);
	      gsl_vector_free(gslvecy);
	      gsl_vector_free(gslvecw);
         return TCL_ERROR ;
      }
      gslvecc=gsl_vector_alloc(nxc);
      gslmatcov=gsl_matrix_alloc(nxc,nxc);
	   work=gsl_multifit_linear_alloc(nxl,nxc);
      if (nxc==1) {
         w=0.;
         gslvecc->data[0]=0.;
         for (k=0;k<nxl;k++) {
            gslvecc->data[0]+=gslvecy->data[k]/gslmatx->data[k]*gslvecw->data[k];
            w+=gslvecw->data[k];
         }
         gslvecc->data[0]/=w;
         chisq=0.;
         var=0.;
         for (k=0;k<nxl;k++) {
            dif=(gslvecy->data[k]-gslvecc->data[0]);
            chisq+=(dif*dif*gslvecw->data[k]);
            var+=(dif*dif);
         }
         chisq=sqrt(chisq/(nxl-1));
         gslmatcov->data[0]=var;
      } else {
   		gsl_multifit_wlinear(gslmatx,gslvecw,gslvecy,gslvecc,gslmatcov,&chisq,work);
      }
		gsl_multifit_linear_free(work);
      Tcl_DStringInit(&dsptr);
      /*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);
      gsltcltcl_setgslvector(interp,&dsptr,gslvecc,nxc);
      /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
      sprintf(s,"%s",gsltcl_d2s(chisq));
      Tcl_DStringAppendElement(&dsptr,s);
      /*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);
      gsltcltcl_setgslmatrix(interp,&dsptr,gslmatcov,nxc,nxc);
      /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
	   gsl_matrix_free(gslmatx);
	   gsl_matrix_free(gslmatcov);
	   gsl_vector_free(gslvecy);
	   gsl_vector_free(gslvecw);
	   gsl_vector_free(gslvecc);
   }
   return TCL_OK;
}


int Cmd_gsltcltcl_fft(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui calcule la FFT                                            */
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int n,k;
   Tcl_DString dsptr;
	double *vec,*data,*real,*imag,*t,*f,duree;
   gsl_fft_complex_workspace *workspace;
   gsl_fft_complex_wavetable *wavetable;
		
	if((argc!=2)&&(argc!=3)) {
      sprintf(s,"Usage: %s ListVector ?ListVectorTime?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getvector(interp,argv[1],&vec,&n);
      data=(double*)calloc(2*n,sizeof(double));
      real=(double*)calloc(n,sizeof(double));
      imag=(double*)calloc(n,sizeof(double));
		for (k=0;k<n;k++) {
			REAL(data,k)=vec[k];
		}
      workspace=gsl_fft_complex_workspace_alloc(n);
      wavetable=gsl_fft_complex_wavetable_alloc(n);
      gsl_fft_complex_forward(data,1,n,wavetable,workspace);
      gsl_fft_complex_workspace_free(workspace);
      gsl_fft_complex_wavetable_free(wavetable);
		for (k=0;k<n;k++) {
			real[k]=REAL(data,k);
			imag[k]=IMAG(data,k);
		}
      Tcl_DStringInit(&dsptr);		
		/*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);		
      gsltcltcl_setvector(interp,&dsptr,real,n);
      /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
		/*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);
      gsltcltcl_setvector(interp,&dsptr,imag,n);
      /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
		/* --- time vector -> frequency vector ---*/
		if (argc==3) {
         code=gsltcltcl_getvector(interp,argv[2],&t,&n);
         f=(double*)calloc(n,sizeof(double));
			duree=t[n-1]-t[0];
			if (duree!=0.) {
			   for (k=0;k<n;k++) {
               f[k]=(double)k/duree;
			   }
		      /*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);
		
            gsltcltcl_setvector(interp,&dsptr,f,n);
            /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
			}
		   free(t);
			free(f);
		}
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
      free(data);
		free(real);
		free(imag);
      free(vec);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_ifft(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Utilitaire qui calcule la FFT inverse                                    */
/****************************************************************************/
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int code;
   int n,k,nr,ni;
   Tcl_DString dsptr;
	double *vec,*data,*real,*imag,*t,*f,duree;
   gsl_fft_complex_workspace *workspace;
   gsl_fft_complex_wavetable *wavetable;
		
	if((argc!=3)&&(argc!=4)) {
      sprintf(s,"Usage: %s ListVectorReal ListVectorImag ?ListVectorFreq?", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      code=gsltcltcl_getvector(interp,argv[1],&real,&nr);
      code=gsltcltcl_getvector(interp,argv[2],&imag,&ni);
	   if (nr!=ni) {
         sprintf(s,"NelemReal (%d) must be equal to NelemImag (%d)",nr,ni);
         Tcl_SetResult(interp,s,TCL_VOLATILE);
		   free(real);
		   free(imag);
         return TCL_ERROR ;
      }
      n=nr;		
		vec=(double*)calloc(n,sizeof(double));
		data=(double*)calloc(2*n,sizeof(double));
		for (k=0;k<n;k++) {
			REAL(data,k)=real[k];
			IMAG(data,k)=imag[k];
		}
      workspace=gsl_fft_complex_workspace_alloc(n);
      wavetable=gsl_fft_complex_wavetable_alloc(n);
      gsl_fft_complex_inverse(data,1,n,wavetable,workspace);
      gsl_fft_complex_workspace_free(workspace);
      gsl_fft_complex_wavetable_free(wavetable);
		for (k=0;k<n;k++) {
			vec[k]=REAL(data,k);
		}
      Tcl_DStringInit(&dsptr);		
		/* --- time vector -> frequency vector ---*/
		if (argc==4) {
         code=gsltcltcl_getvector(interp,argv[3],&f,&n);
         t=(double*)calloc(n,sizeof(double));
			duree=f[n-1]-f[0];
			if (duree!=0.) {
			   for (k=0;k<n;k++) {
               t[k]=(double)k/duree;
			   }
		      /*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);		
            gsltcltcl_setvector(interp,&dsptr,vec,n);
            /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
		      /*Tcl_DStringStartSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," { ",3);
		
            gsltcltcl_setvector(interp,&dsptr,t,n);
            /*Tcl_DStringEndSublist(&dsptr);*/
      Tcl_DStringAppend(&dsptr," } ",3);
			}
		   free(t);
			free(f);
		} else {
         gsltcltcl_setvector(interp,&dsptr,vec,n);
		}
      Tcl_DStringResult(interp,&dsptr);
      Tcl_DStringFree(&dsptr);
      free(data);
		free(real);
		free(imag);
      free(vec);
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
      sprintf(s,"%s",gsltcl_d2s(vec[k]));
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
         sprintf(s,"%s",gsltcl_d2s(mat[nc*kl+kc]));
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
/*int gsltcltcl_setgslmatrix(Tcl_Interp *interp, Tcl_DString dsptr, gsl_matrix *gslmat, int nl, int nc)*/
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
      Tcl_DStringAppend(dsptr," { ",3);
      for (kc=0;kc<nc;kc++) {
         sprintf(s,"%s",gsltcl_d2s(gsl_matrix_get(gslmat,kl,kc)));
         Tcl_DStringAppendElement(dsptr,s);
      }
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
   for (k=0;k<n;k++) {
      Tcl_DStringAppendElement(dsptr,gsltcl_d2s(gsl_vector_get(vec,k)));
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_chisq_Qinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur double gsl_cdf_chisq_Qinv (double Q, double nu).      */
/* Q = densite de probabilite cumulee (0-1)                                 */
/* nu = degres de liberte                                                   */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double Q,nu,x;
   if(argc!=3) {
      sprintf(s,"Usage: %s probability_density_Q degrees_of_freedom_nu", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&Q); if(retour!=TCL_OK) { return TCL_ERROR ; }
      retour = Tcl_GetDouble(interp,argv[2],&nu); if(retour!=TCL_OK) { return TCL_ERROR ; }
		if (Q<0) { Q=0; }
		if (Q>1) { Q=1; }
		if (nu<0) { nu=0; }
		x = gsl_cdf_chisq_Qinv(Q,nu);
      sprintf(s,"%g",x);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_chisq_Pinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur double gsl_cdf_chisq_Pinv (double P, double nu).      */
/* P = densite de probabilite cumulee (0-1)                                 */
/* nu = degres de liberte                                                   */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double P,nu,x;
   if(argc!=3) {
      sprintf(s,"Usage: %s probability_density_P degrees_of_freedom_nu", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&P); if(retour!=TCL_OK) { return TCL_ERROR ; }
      retour = Tcl_GetDouble(interp,argv[2],&nu); if(retour!=TCL_OK) { return TCL_ERROR ; }
		if (P<0) { P=0; }
		if (P>1) { P=1; }
		if (nu<0) { nu=0; }
		x = gsl_cdf_chisq_Pinv(P,nu);
      sprintf(s,"%g",x);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_chisq_P(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur double gsl_cdf_chisq_P (double x, double nu).      */
/* x = valeur du chi2 critique                                             */
/* nu = degres de liberte                                                   */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double P,nu,x;
   if(argc!=3) {
      sprintf(s,"Usage: %s chi2_critic_x degrees_of_freedom_nu", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&x); if(retour!=TCL_OK) { return TCL_ERROR ; }
      retour = Tcl_GetDouble(interp,argv[2],&nu); if(retour!=TCL_OK) { return TCL_ERROR ; }
		if (x<0) { x=0; }
		if (nu<0) { nu=0; }
		P = gsl_cdf_chisq_P(x,nu);
      sprintf(s,"%g",P);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_chisq_Q(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur double gsl_cdf_chisq_Q (double x, double nu).      */
/* x = valeur du chi2 critique                                             */
/* nu = degres de liberte                                                   */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double Q,nu,x;
   if(argc!=3) {
      sprintf(s,"Usage: %s chi2_critic_x degrees_of_freedom_nu", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&x); if(retour!=TCL_OK) { return TCL_ERROR ; }
      retour = Tcl_GetDouble(interp,argv[2],&nu); if(retour!=TCL_OK) { return TCL_ERROR ; }
		if (x<0) { x=0; }
		if (nu<0) { nu=0; }
		Q = gsl_cdf_chisq_Q(x,nu);
      sprintf(s,"%g",Q);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_ugaussian_Q(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur gsl_cdf_ugaussian_Q(double x).                        */
/* x = valeur de l'abscisse                                                 */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double Q,x;
   if(argc!=2) {
      sprintf(s,"Usage: %s x", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&x); if(retour!=TCL_OK) { return TCL_ERROR ; }
		Q = gsl_cdf_ugaussian_Q(x);
      sprintf(s,"%g",Q);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_ugaussian_Qinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur gsl_cdf_ugaussian_Qinv(double Q).                     */
/* Q = valeur de integrale                                                  */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double Q,x;
   if(argc!=2) {
      sprintf(s,"Usage: %s Q", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&Q); if(retour!=TCL_OK) { return TCL_ERROR ; }
		x = gsl_cdf_ugaussian_Qinv(Q);
      sprintf(s,"%g",x);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_ugaussian_P(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur gsl_cdf_ugaussian_P(double x).                        */
/* x = valeur de l'abscisse                                                 */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double P,x;
   if(argc!=2) {
      sprintf(s,"Usage: %s x", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&x); if(retour!=TCL_OK) { return TCL_ERROR ; }
		P = gsl_cdf_ugaussian_P(x);
      sprintf(s,"%g",P);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

int Cmd_gsltcltcl_cdf_ugaussian_Pinv(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* Retourne la valeur gsl_cdf_ugaussian_Pinv(double P).                     */
/* P = valeur de integrale                                                  */
/****************************************************************************/
/****************************************************************************/
{
   char s[200];
   int retour;
	double P,x;
   if(argc!=2) {
      sprintf(s,"Usage: %s P", argv[0]);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
      retour = Tcl_GetDouble(interp,argv[1],&P); if(retour!=TCL_OK) { return TCL_ERROR ; }
		x = gsl_cdf_ugaussian_Pinv(P);
      sprintf(s,"%g",x);
      Tcl_SetResult(interp,s,TCL_VOLATILE);
   }
   return TCL_OK;
}

/* This function is called by the Simplex algorithm of Nelder and Mead. */
double my_f (const gsl_vector *v, void *params)
{
	double residu;
	Tcl_Interp *interp;
	int k,res;
	char s[2000],ss[200];
	struct_my_f *p;
	//interp=(Tcl_Interp*)params;
	p=(struct_my_f*)params;
	interp=p->interp;
	// boucle sur les inconnues à optimiser
	sprintf(s,"%s {",p->proc);
	for (k=0 ; k<(int)v->size ; k++ ) {
		//sprintf(ss,"%e ",gsl_vector_get(v, k));
		sprintf(ss,"%s ",gsltcl_d2s(gsl_vector_get(v, k)));
		strcat(s,ss);
	}
	strcat(s,"}");
	// evalue la proc Tcl
   res=Tcl_Eval(interp,s);
   if (res==TCL_OK) {
      residu=atof(Tcl_GetStringResult(interp));
	} else {
		residu=0;
	}
	return residu;
}

int Cmd_gsltcltcl_multimin_fminimizer_nmsimplex(ClientData clientData, Tcl_Interp *interp, int argc, char *argv[])
/****************************************************************************/
/* This is the Simplex algorithm of Nelder and Mead.                        */
/*                                                                          */
/* A Tcl proc computes and returns a scalar value according a given         */
/* vector values. gsl_multimin_fminimizer_nmsimplex calls this proc         */
/* and search the vector values which minimizes the scalar value of         */
/* the proc.                                                                */
/****************************************************************************/
/* Example:
proc toto { v } {
	set x0 [lindex $v 0]
	set x1 [lindex $v 1]
	set dp0 1.0
	set dp1 2.0
	set residu [expr 10.0 * ($x0 - $dp0) * ($x0 - $dp0) + 20.0 * ($x1 - $dp1) * ($x1 - $dp1) + 30.0] 
	return $residu
}
gsl_multimin_fminimizer_nmsimplex toto {5 7} 1e-2 100
*/
/****************************************************************************/
/* Bibliography:                                                            */
/* http://linux.math.tifr.res.in/programming-doc/gsl/gsl-ref_34.html        */
/****************************************************************************/
{
   char st[200];
	int code;
   
   if(argc<=4) {
      sprintf(st,"Usage: %s procname list_of_initial_values epsabs maxiter", argv[0]);
      Tcl_SetResult(interp,st,TCL_VOLATILE);
      return TCL_ERROR;
   } else {
		int np;
		const gsl_multimin_fminimizer_type *T = gsl_multimin_fminimizer_nmsimplex;
		gsl_multimin_fminimizer *s = NULL;
		gsl_vector *ss, *x;
		gsl_multimin_function minex_func;
		Tcl_DString dsptr;
		Tcl_DString dsptr2;
		struct_my_f p;
		double epsabs;
		int maxiter;

		size_t iter = 0, i;
		int status;
		double size;

		/* epsabs */
      epsabs=fabs(atof(argv[3]));

		/* maxiter */
      maxiter=atoi(argv[4]);

		/* Starting point */
      code=gsltcltcl_getgslvector(interp,argv[2],&x,&np);

		/* Initial vertex size vector */
		ss = gsl_vector_alloc (np);

		/* Set all step sizes to 1 */
		gsl_vector_set_all (ss, 1.0);

		/* Initialize method and iterate */
		minex_func.f = &my_f;
		minex_func.n = np;
		p.interp=interp;
		strcpy(p.proc,argv[1]);
		minex_func.params = (void *)&p;

		s = gsl_multimin_fminimizer_alloc (T, np);
		gsl_multimin_fminimizer_set (s, &minex_func, x, ss);

		Tcl_DStringInit(&dsptr);
		Tcl_DStringInit(&dsptr2);

		do
		 {
			iter++;
			status = gsl_multimin_fminimizer_iterate(s);
		   
			if (status) 
			  break;

			size = gsl_multimin_fminimizer_size (s);
			status = gsl_multimin_test_size (size, epsabs);

			if (status == GSL_SUCCESS)
			  {
				sprintf (st,"converged to minimum at\n");
		 		Tcl_DStringAppend(&dsptr,st,-1);
			  }

			sprintf (st,"iter = %d vector = ", iter);
		 	Tcl_DStringAppend(&dsptr,st,-1);
			for (i = 0; i < (size_t)np; i++)
			  {
				 sprintf (st,"%10.3e ", gsl_vector_get (s->x, i));
			 	Tcl_DStringAppend(&dsptr,st,-1);
			  }
			sprintf (st,"f = %e size = %e\n", s->fval, size);
		 	Tcl_DStringAppend(&dsptr,st,-1);
		 }
		while (status == GSL_CONTINUE && iter < maxiter);

		sprintf (st,"status=%d\n", status);
	 	Tcl_DStringAppend(&dsptr,st,-1);

		Tcl_DStringAppend(&dsptr2,"{",-1);
		for (i = 0; i < (size_t)np; i++)
		  {
         sprintf(st,"%s ",gsltcl_d2s(gsl_vector_get (s->x, i)));
		 	Tcl_DStringAppend(&dsptr2,st,-1);
		  }
		Tcl_DStringAppend(&dsptr2,"} {",-1);
		Tcl_DStringAppend(&dsptr2,dsptr.string,-1);
		Tcl_DStringAppend(&dsptr2,"}",-1);

		Tcl_DStringResult(interp,&dsptr2);
		Tcl_DStringFree(&dsptr);
		Tcl_DStringFree(&dsptr2);

		gsl_vector_free(x);
		gsl_vector_free(ss);
		gsl_multimin_fminimizer_free (s);

   }
   return TCL_OK;
}

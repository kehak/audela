/* 
 * This file is part of the AudeLA project : <http://software.audela.free.fr>
 * Copyright (C) 1998-2004 The AudeLA Core Team
 *
 * Initial author : Frederic Vachier <fv@imcce.fr>
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
#include <stdio.h>
#include "cpixels.h"
#include "psfimcce.h"
#include <math.h>

void CPixels::psfimcce_compute(int npt, double **z, double *p, float **residus, float **synthetic)
{
   int i, j;
   float *a, *pr;
   float *uncertainties;
   float **zs;

   a  = vector(1,MA);
   pr = vector(0,NB_PARAM);
	zs = matrix(0,npt-1,0,npt-1);
	uncertainties = vector(1,MA);

	/* Affectation de (float)zs a partir de (double)z */
   for(i=0;i<npt;i++) {
      for(j=0;j<npt;j++) {
         zs[i][j] = (float)z[i][j];
      }
   }

	/* Ajustement de la gaussienne */
   fit_gauss2D(npt, zs, a, uncertainties);
	/* Calcul des parametres */
   coeff2param(npt, zs, a, pr, uncertainties, synthetic, residus);

	/* Affectation des parametres */
	for(i=0;i<=NB_PARAM;i++) {
		p[i] = pr[i];
	}

   /* Clean memory */
   free_vector(a,1,MA);
   free_vector(pr,0,NB_PARAM);
	free_matrix(zs,0,npt-1,0,npt-1);
	free_vector(uncertainties,1,MA);

   return;
}

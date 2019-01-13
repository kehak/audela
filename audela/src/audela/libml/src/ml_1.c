/* ml_1.c
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
/* Ce fichier contient du C pur et dur sans une seule goute de Tcl.        */
/* Ainsi, ce fichier peut etre utilise pour d'autres applications C sans   */
/* rapport avec le Tcl.                                                    */
/***************************************************************************/
/* Le include ml.h ne contient pas d'infos concernant Tcl.                */
/***************************************************************************/
#include "ml.h"

void ml_sepangle(double a1, double a2, double d1, double d2, double *dist, double *posangle)
/***************************************************************************/
/* Calcul de l'angle de separation et de l'angle de position au pole nord  */
/* a partir de deux coordonnees spheriques.                                */
/***************************************************************************/
/***************************************************************************/
{
   double a,b,c,aa,d3,a3;
   double pi;
   pi=4.*atan(1);
   d3=pi/2;
   a3=0;
   a=(sin(d2)*sin(d3)+cos(d2)*cos(d3)*cos(a2-a3));
   if (a<-1.) {a=-1.;}
   if (a>1.) {a=1.;}
   a=acos(a);
   b=(sin(d1)*sin(d3)+cos(d1)*cos(d3)*cos(a1-a3));
   if (b<-1.) {b=-1.;}
   if (b>1.) {b=1.;}
   b=acos(b);
   c=(sin(d1)*sin(d2)+cos(d1)*cos(d2)*cos(a1-a2));
   if (c<-1.) {c=-1.;}
   if (c>1.) {c=1.;}
   c=acos(c);
   if (b*c!=0.) {
      aa=((cos(a)-cos(b)*cos(c))/(sin(b)*sin(c)));
      aa=(aa>1)?1.:aa;
      aa=(aa<-1)?-1.:aa;
      aa=acos(aa);
      if (sin(a2-a1)<0) {
         aa=-aa;
      }
      aa=fmod(aa+4*pi,2*pi);
   } else {
	  aa=0.;
   }
   *dist=c;
   *posangle=aa;
}


void ml_date2jd(double annee, double mois, double jour, double heure, double minute, double seconde, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/***************************************************************************/
{
   double a,m,j,aa,bb,jd;
   a=annee;
   m=mois;
   j=jour+((((seconde/60.)+minute)/60.)+heure)/24.;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   *jj=jd;
}


int ml_bissextile (int annee)
/***************************************************************************/
/* Teste si l'année est bissextile                                         */
/***************************************************************************/
/***************************************************************************/
{
  return annee % 4 == 0 && (annee % 100 != 0 || annee % 400 == 0);
}


int ml_nbjours (int jour, int mois, int annee)
/***************************************************************************/
/* combien de jours se sont ecoules depuis le debut de l'annee donnee      */
/***************************************************************************/
/***************************************************************************/
{
  int i, D = 0;
  const int Mois[12]= {31,28,31,30,31,30,31,31,30,31,30,31};

  if (mois == 1)
  {
    D = jour;
  }
  else
  {
    for (i = 0; i < (mois-1); i++)
    {
      D += Mois[i];
    }
    D+=jour;
  }
  if ((mois > 2) && (ml_bissextile(annee)))
  {
    D++;
  }
  return D;
}


int ml_differencejour (int jour1, int mois1, int annee1, int jour2, int mois2, int annee2)
/***************************************************************************/
/* Donne la différence de temps entre deux date                            */
/***************************************************************************/
/***************************************************************************/
{
  int NJ1, NJ2, i;
  int NJ = 0;

  NJ1 = ml_nbjours (jour1, mois1, annee1);
  NJ2 = ml_nbjours (jour2, mois2, annee2);
  if (annee2 == annee1)
  {
    NJ = NJ2 - NJ1;
  }
  else
  {
    for (i = 0; i < (annee2-annee1); i++)
    {
      NJ += 364;
      if (ml_bissextile (annee1+i))
      {
        NJ++;
      }
    }
    NJ -= NJ1;
    NJ += NJ2+1;
  }
  return NJ;
}


int ml_file_copy (const char *source, const char *dest)
/***************************************************************************/
/* copie un fichier source vers un fichier dest                            */
/***************************************************************************/
/***************************************************************************/
{
  int ret = 0;
  FILE *src = NULL;
  FILE *dst = NULL;
  char buffer[BUFSIZ];

  src = fopen (source, "r");
  if (src)
  {
    dst = fopen (dest, "w");
    if (dst)
    {
      while (fgets (buffer, BUFSIZ, src))
      {
         fprintf (dst, "%s", buffer);
      }

      if (ferror (src))
      {
        fprintf (stderr, "Erreur lors de la lecture du fichier source : %s\n", source);
        ret = -3;
      }

      if (ferror (dst))
      {
        fprintf (stderr, "Erreur lors de l'ecriture du fichier dst : %s\n", dest);
        ret = -4;
      }

      fclose (src), src = NULL;
      fclose (dst), dst = NULL;
    }
    else
    {
      fprintf (stderr, "Impossible d'ouvrir le fichier dest : %s\n", dest);
      fclose (src);
      ret = -2;
    }
  }
  else
  {
    fprintf (stderr, "Impossible d'ouvrir le fichier source : %s\n", source);
    ret = -1;
  }
  return ret;
}


/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On prend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double ml_GetUsnoBleueMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+4,3); *(buf2+3)='\0';
mag = (double)atof(buf2)/10.0;
if (mag==0.0)
   {
   strncpy(buf2,buf+1,3);
   *(buf2+3)='\0';
   if ((double)atof(buf2)==0.0)
      {
      strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
      mag = (double)atof(buf2)/10.0;
      }
   }
return mag;
}

/*===========================================================*/
/* Extraction de la magnitude (bleue ou rouge selon l'etat   */
/* de la variable 'UsnoDisplayBlueMag') a partir de l'entier */
/* 32 bits brut en provenance du fichier USNO.               */
/* On rpend en compte ici les petites subtilites expliquees  */
/* dans le fichier README de l'USNO (style mag a 99, ...).   */
/*===========================================================*/
double ml_GetUsnoRedMagnitude(int magL)
{
double mag;
char buf[11];
char buf2[4];

sprintf(buf,"%010ld",labs(magL));
strncpy(buf2,buf+7,3); *(buf2+3) = '\0';
mag=(double)atof(buf2)/10.0;
if (mag==999.0)
   {
   strncpy(buf2,buf+4,3); *(buf2+3) = '\0';
   mag=(double)atof(buf2)/10.0;
   }
return mag;
}


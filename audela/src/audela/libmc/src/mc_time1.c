/* mc_time1.c
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
/* MC : Utilitaire de meca celeste                                         */
/* Auteur : Alain Klotz                                                    */
/***************************************************************************/
/* Transformations du temps (jour julien, temps dynamique ...)             */
/***************************************************************************/
#include "mc.h"

void mc_equinoxe_jd(char *chaine,double *jj)
/***************************************************************************/
/* Donne le jour julien correspondant a un code d'equinoxe.                */
/***************************************************************************/
/* *chaine: code d'equinoxe a convertir                                    */
/* *jj    : valeur du jour julien converti                                 */
/***************************************************************************/
{
	int k,n,kp=-1;
   char chaine0[80],*stmp;
   double a;
   *jj=J2000;
   if (chaine[0]=='J') {
		n=(int)strlen(chaine);
		for (k=0;k<n;k++) {
			if (chaine[k]==',') {
				chaine[k]='.';
			}
		}
      strcpy(chaine0,chaine+1);
      a=atof(chaine0);
      *jj=2451545.0+(a-2000.0)*365.25;
   }
	strcpy(chaine0,chaine);
	n=(int)strlen(chaine0);
	for (k=0;k<n;k++) {
		if (chaine0[k]==',') {
			chaine0[k]='.';
		}
		if (chaine0[k]=='.') {
			kp=k;
		}
	}
	stmp=strstr(chaine0,".0");
	if (stmp!=NULL) {
		if (strcmp(stmp,".0")==0) {
			kp=0;
		}
	}
	if (kp<=-1) {
		strcat(chaine0,".0");
	}
   if (strcmp(chaine0,"B1850.0")==0) {
      *jj=B1850;
   }
   if (strcmp(chaine0,"B1900.0")==0) {
      *jj=B1900;
   }
   if (strcmp(chaine0,"B1950.0")==0) {
      *jj=B1950;
   }
   if (strcmp(chaine0,"B1975.0")==0) {
      *jj=B1975;
   }
   if (strcmp(chaine0,"B2000.0")==0) {
      *jj=B2000;
   }
   if (strcmp(chaine0,"B2025.0")==0) {
      *jj=B2025;
   }
   if (strcmp(chaine0,"B2050.0")==0) {
      *jj=B2050;
   }
   if (strcmp(chaine0,"B2100.0")==0) {
      *jj=B2100;
   }
   if (strcmp(chaine0,"J1900.0")==0) {
      *jj=J1900;
   }
   if (strcmp(chaine0,"J1950.0")==0) {
      *jj=J1950;
   }
   if (strcmp(chaine0,"J2000.0")==0) {
      *jj=J2000;
   }
   if (strcmp(chaine0,"J2050.0")==0) {
      *jj=J2050;
   }
   if (strcmp(chaine0,"J2100.0")==0) {
      *jj=J2100;
   }
}

void mc_date_jd(int annee, int mois, double jour, double *jj)
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
   a=annee;
   m=mois;
   j=jour;
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+bb-1524.5;
	jd=jd+j;
   if (jd<2299160.5) {
      /* --- julian date ---*/
      jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))-1524.5;
		jd=jd+j;
   }
   *jj=jd;
}

void mc_jd_date(double jj, int *annee, int *mois, double *jour)
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
   if (z<2299161.) {
      a=z;
   } else {
      alpha=floor((z-1867216.25)/36524.25);
      a=z+1+alpha-floor(alpha/4);
   }
   b=a+1524;
   c=floor(((b-122.1)/365.25));
   d=floor(365.25*c);
   e=floor((b-d)/30.6001);
   *jour=b-d-floor(30.6001*e)+f;
   *mois= (e<14) ? (int)(e-1) : (int)(e-13) ;
   *annee= (*mois>2) ? (int)(c-4716) : (int)(c-4715) ;
}

void mc_jd_equinoxe(double jj, char *chaine)
/***************************************************************************/
/* Donne le code d'equinoxe correspondant a un jour julien.                */
/***************************************************************************/
/* jj     : valeur du jour julien a convertir                              */
/* *chaine: code d'equinoxe correspondant                                  */
/***************************************************************************/
{
   double eps=1e-3,eps2=1e-4,a,annee;
   char chaine0[80];
   a=(jj-2451545.0)/365.25+2000.0;
   strcpy(chaine,"J");
   if (mc_frac(a)<eps2) {
      annee=a+0.1;
      mc_fstr(annee,PB,4,0,OK,chaine0);
      strcat(chaine,chaine0);
      strcat(chaine,".0");
   } else {
      mc_fstr(a,PB,4,5,OK,chaine0);
      strcat(chaine,chaine0);
   }
   if (fabs(jj-2415020.3135)<eps) {
      strcpy(chaine,"B1900.0");
   }
   if (fabs(jj-2433282.4235)<eps) {
      strcpy(chaine,"B1950.0");
   }
}

void mc_td2tu(double jjtd,double *jjtu)
/***************************************************************************/
/* Retourne la valeur de jj en TU a partir de jj en temps dynamique        */
/***************************************************************************/
/* Algo : Meeus "Astronomical Algorithms" p73 (9.1)                        */
/***************************************************************************/
{
   double dt=0.;
   mc_tdminusut(jjtd,&dt);
   *jjtu=jjtd-dt/86400.;
}

void mc_tu2td(double jjtu,double *jjtd)
/***************************************************************************/
/* Retourne la valeur de jj en temps dynamique a partir de jj en TU        */
/* UTC -> TT                                                               */
/***************************************************************************/
/* Algo : Meeus "Astronomical Algorithms" p73 (9.1)                        */
/***************************************************************************/
{
   double dt=0.;
   mc_tdminusut(jjtu,&dt);
   *jjtd=jjtu+dt/86400.;
}

void mc_tdminusut(double jj,double *dt)
/***************************************************************************/
/* Retourne la valeur dt(sec)=TT-UT partir de jj en TU                     */
/***************************************************************************/
/* Algo : Meeus "Astronomical Algorithms" p72                              */
/* and ftp://maia.usno.navy.mil/ser7/tai-utc.dat                           */
/*                                                ET 1960-1983             */
/*                                                TDT 1984-2000            */
/* UTC 1972-  GPS 1980-    TAI 1958-               TT 2001-                */
/*----+---------+-------------+-------------------------+-----             */
/*    |         |             |                         |                  */
/*    |<------ TAI-UTC ------>|<-----   TT-TAI    ----->|                  */
/*    |         |             |      32.184s fixed      |                  */
/*    |<GPS-UTC>|<- TAI-GPS ->|                         |                  */
/*    |         |  19s fixed  |                         |                  */
/*    |                                                 |                  */
/*    <> delta-UT = UT1-UTC                             |                  */
/*     | (max 0.9 sec)                                  |                  */
/*-----+------------------------------------------------+-----             */
/*     |<-------------- delta-T = TT-UT1 -------------->|                  */
/*    UT1 (UT)                                       TT/TDT/ET             */
/*                                                                         */
/* http://stjarnhimlen.se/comp/time.html                                   */
/***************************************************************************/
{
   double ds=0.,ds1,ds2,t=0.;
   int indexmax=201,k,k2;
   double jjmax,jj1,jj2;
   double table[202*2]={
      2312752.5, +124., /* 1620 */
      2313483.5, +115.,
      2314213.5, +106.,
      2314944.5,  +98.,
      2315674.5,  +91.,
      2316405.5,  +85.,
      2317135.5,  +79.,
      2317866.5,  +74.,
      2318596.5,  +70.,
      2319327.5,  +65.,
      2320057.5,  +62.,
      2320788.5,  +58.,
      2321518.5,  +55.,
      2322249.5,  +53.,
      2322979.5,  +50.,
      2323710.5,  +48.,
      2324440.5,  +46.,
      2325171.5,  +44.,
      2325901.5,  +42.,
      2326632.5,  +40.,
      2327362.5,  +37.,
      2328093.5,  +35.,
      2328823.5,  +33.,
      2329554.5,  +31.,
      2330284.5,  +28.,
      2331015.5,  +26.,
      2331745.5,  +24.,
      2332476.5,  +22.,
      2333206.5,  +20.,
      2333937.5,  +18.,
      2334667.5,  +16.,
      2335398.5,  +14.,
      2336128.5,  +13.,
      2336859.5,  +12.,
      2337589.5,  +11.,
      2338320.5,  +10.,
      2339050.5,   +9.,
      2339781.5,   +9.,
      2340511.5,   +9.,
      2341242.5,   +9.,
      2341972.5,    9.,   /* 1700 */
      2342702.5,    9.,   /* 1702 */
      2343432.5,    9.,   /* 1704 */
      2344163.5,    9.,   /* 1706 */
      2344893.5,   10.,   /* 1708 */
      2345624.5,   10.,   /* 1710 */
      2346354.5,   10.,   /* 1712 */
      2347085.5,   10.,   /* 1714 */
      2347815.5,   10.,   /* 1716 */
      2348546.5,   11.,   /* 1718 */
      2349276.5,   11.,   /* 1720 */
      2350007.5,   11.,   /* 1722 */
      2350737.5,   11.,   /* 1724 */
      2351468.5,   11.,   /* 1726 */
      2352198.5,   11.,   /* 1728 */
      2352929.5,   11.,   /* 1730 */
      2353659.5,   11.,   /* 1732 */
      2354390.5,   12.,   /* 1734 */
      2355120.5,   12.,   /* 1736 */
      2355851.5,   12.,   /* 1738 */
      2356581.5,   12.,   /* 1740 */
      2357312.5,   12.,   /* 1742 */
      2358042.5,   13.,   /* 1744 */
      2358773.5,   13.,   /* 1746 */
      2359503.5,   13.,   /* 1748 */
      2360234.5,   13.,   /* 1750 */
      2360964.5,   14.,   /* 1752 */
      2361695.5,   14.,   /* 1754 */
      2362425.5,   14.,   /* 1756 */
      2363156.5,   15.,   /* 1758 */
      2363886.5,   15.,   /* 1760 */
      2364617.5,   15.,   /* 1762 */
      2365347.5,   15.,   /* 1764 */
      2366078.5,   16.,   /* 1766 */
      2366808.5,   16.,   /* 1768 */
      2367539.5,   16.,   /* 1770 */
      2368269.5,   16.,   /* 1772 */
      2369000.5,   16.,   /* 1774 */
      2369730.5,   17.,   /* 1776 */
      2370461.5,   17.,   /* 1778 */
      2371191.5,   17.,   /* 1780 */
      2371922.5,   17.,   /* 1782 */
      2372652.5,   17.,   /* 1784 */
      2373383.5,   17.,   /* 1786 */
      2374113.5,   17.,   /* 1788 */
      2374844.5,   17.,   /* 1790 */
      2375574.5,   16.,   /* 1792 */
      2376305.5,   16.,   /* 1794 */
      2377035.5,   15.,   /* 1796 */
      2377766.5,   14.,   /* 1798 */
      2378496.5,   13.7,  /* 1800 */
      2379226.5,   13.1,  /* 1802 */
      2379956.5,   12.7,  /* 1804 */
      2380687.5,   12.5,  /* 1806 */
      2381417.5,   12.5,  /* 1808 */
      2382148.5,   12.5,  /* 1810 */
      2382878.5,   12.5,  /* 1812 */
      2383609.5,   12.5,  /* 1814 */
      2384339.5,   12.5,  /* 1816 */
      2385070.5,   12.3,  /* 1818 */
      2385800.5,   12.0,  /* 1820 */
      2386531.5,   11.4,  /* 1822 */
      2387261.5,   10.6,  /* 1824 */
      2387992.5,    9.6,  /* 1826 */
      2388722.5,    8.6,  /* 1828 */
      2389453.5,    7.5,  /* 1830 */
      2390183.5,    6.6,  /* 1832 */
      2390914.5,    6.0,  /* 1834 */
      2391644.5,    5.7,  /* 1836 */
      2392375.5,    5.6,  /* 1838 */
      2393105.5,    5.7,  /* 1840 */
      2393836.5,    5.9,  /* 1842 */
      2394566.5,    6.2,  /* 1844 */
      2395297.5,    6.5,  /* 1846 */
      2396027.5,    6.8,  /* 1848 */
      2396758.5,    7.1,  /* 1850 */
      2397488.5,    7.3,  /* 1852 */
      2398219.5,    7.5,  /* 1854 */
      2398949.5,    7.7,  /* 1856 */
      2399680.5,    7.8,  /* 1858 */
      2400410.5,    7.9,  /* 1860 */
      2401141.5,    7.5,  /* 1862 */
      2401871.5,    6.4,  /* 1864 */
      2402602.5,    5.4,  /* 1866 */
      2403332.5,    2.9,  /* 1868 */
      2404063.5,    1.6,  /* 1870 */
      2404793.5,   -1.0,  /* 1872 */
      2405524.5,   -2.7,  /* 1874 */
      2406254.5,   -3.6,  /* 1876 */
      2406985.5,   -4.7,  /* 1878 */
      2407715.5,   -5.4,  /* 1880 */
      2408446.5,   -5.2,  /* 1882 */
      2409176.5,   -5.5,  /* 1884 */
      2409907.5,   -5.6,  /* 1886 */
      2410637.5,   -5.8,  /* 1888 */
      2411368.5,   -5.9,  /* 1890 */
      2412098.5,   -6.2,  /* 1892 */
      2412829.5,   -6.4,  /* 1894 */
      2413559.5,   -6.1,  /* 1896 */
      2414290.5,   -4.7,  /* 1898 */
      2415020.5,   -2.7,  /* 1900 */
      2415750.5,   -0.0,  /* 1902 */
      2416480.5,   +2.6,  /* 1904 */
      2417211.5,    5.4,  /* 1906 */
      2417941.5,    7.7,  /* 1908 */
      2418672.5,   10.5,  /* 1910 */
      2419402.5,   13.4,  /* 1912 */
      2420133.5,   16.0,  /* 1914 */
      2420863.5,   18.2,  /* 1916 */
      2421594.5,   20.2,  /* 1918 */
      2422324.5,   21.2,  /* 1920 */
      2423055.5,   22.4,  /* 1922 */
      2423785.5,   23.5,  /* 1924 */
      2424516.5,   23.9,  /* 1926 */
      2425246.5,   24.3,  /* 1928 */
      2425977.5,   24.0,  /* 1930 */
      2426707.5,   23.9,  /* 1932 */
      2427438.5,   23.9,  /* 1934 */
      2428168.5,   23.7,  /* 1936 */
      2428899.5,   24.0,  /* 1938 */
      2429629.5,   24.3,  /* 1940 */
      2430360.5,   25.3,  /* 1942 */
      2431090.5,   26.2,  /* 1944 */
      2431821.5,   27.3,  /* 1946 */
      2432551.5,   28.2,  /* 1948 */
      2433282.5,   29.1,  /* 1950 */
      2434012.5,   30.0,  /* 1952 */
      2434743.5,   30.7,  /* 1954 */
      2435473.5,   31.4,  /* 1956 */
      2436204.5,   32.2,  /* 1958 */
      2436934.5,   33.1,  /* 1960 */
      2437665.5,   34.0,  /* 1962 */
      2438395.5,   35.0,  /* 1964 */
      2439126.5,   36.5,  /* 1966 */
      2439856.5,   38.3,  /* 1968 */
      2440587.5,   40.2,  /* 1970 */
      2441317.5, 42.184,  /* 1972 JAN  1 */
		2441499.5, 43.184,  /* 1972 JUL  1 */
		2441683.5, 44.184,  /* 1973 JAN  1 */
		2442048.5, 45.184,  /* 1974 JAN  1 */
		2442413.5, 46.184,  /* 1975 JAN  1 */
		2442778.5, 47.184,  /* 1976 JAN  1 */
		2443144.5, 48.184,  /* 1977 JAN  1 */
		2443509.5, 49.184,  /* 1978 JAN  1 */
		2443874.5, 50.184,  /* 1979 JAN  1 */
		2444239.5, 51.184,  /* 1980 JAN  1 */
		2444786.5, 52.184,  /* 1981 JUL  1 */
		2445151.5, 53.184,  /* 1982 JUL  1 */
		2445516.5, 54.184,  /* 1983 JUL  1 */
		2446247.5, 55.184,  /* 1985 JUL  1 */
		2447161.5, 56.184,  /* 1988 JAN  1 */
		2447892.5, 57.184,  /* 1990 JAN  1 */
      2448257.5, 58.184,  /* 1991 JAN  1 */
      2448804.5, 59.184,  /* 1992 JUL  1 */
      2449169.5, 60.184,  /* 1993 JUL  1 */
      2449534.5, 61.184,  /* 1994 JUL  1 */
      2450083.5, 62.184,  /* 1996 JAN  1 */
      2450630.5, 63.184,  /* 1997 JUL  1 */
      2451179.5, 64.184,  /* 1999 JAN  1 */
      2453736.5, 65.184,  /* 2006 JAN  1 */
      2454832.5, 66.184,  /* 2009 JAN  1 */
      2456109.5, 67.184   /* 2012 JUL  1 from 2012 July 1,    0h UTC, until further notice    : UTC-TAI = - 35s */
   };
   jjmax=table[(indexmax-1)*2];
   if (jj<=2067314.5) {
      /* --- date <= anne948 ---*/
      t=(jj-J2000)/36525.;
      ds=2715.6+573.36*t+46.5*t*t;
      *dt=ds;
      return;
   }
   if (jj<=2312752.5) {
      /* --- date <= anne1620 ---*/
      t=(jj-J2000)/36525.;
      ds=50.6+67.5*t+22.5*t*t;
      *dt=ds;
      return;
   }
   if (jj<=jjmax) {
      /* --- date <= indexmax ---*/
      k2=indexmax;
      for (k=1;k<indexmax;k++) {
         k2=k;
         jj2=table[k2*2];
         if (jj<=jj2) {
            break;
         }
      }
      jj2=table[k2*2];
      ds2=table[k2*2+1];
      jj1=table[(k2-1)*2];
      ds1=table[(k2-1)*2+1];
      ds=ds1+(jj-jj1)/(jj2-jj1)*(ds2-ds1);
      *dt=ds;
      return;
   }
   /* --- extrapolation ---*/
   ds=table[2*indexmax+1];
   *dt=ds;
}

void mc_tsl(double jj,double longitude,double *tsl)
/***************************************************************************/
/* Calcul du temps sideral local apparent (en radian)                      */
/* La longitude est comptee en radian positive vers l'ouest                */
/* jj = UT1  (on a toujours |UTC-UT1|<1 sec)                               */
/***************************************************************************/
/* Formules (11.1) et (11.4) de Meeus                                      */
/***************************************************************************/
{
   double t,j,theta0,dpsi,deps,eps;
   j=(jj-2451545.0);
   t=j/36525;
   theta0=280.460618375+360.98564736629*j+.000387933*t*t-t*t*t/38710000;
   mc_obliqmoy(jj,&eps);
   mc_nutation(jj,1,&dpsi,&deps);
	theta0+=(dpsi*cos(eps+deps)/(DR));
   theta0-=longitude/(DR);
   theta0=fmod(theta0,360.);
   theta0=fmod(theta0+720.,360.)*DR;
   *tsl=theta0;
}

void mc_dateobs2jd(char *date, double *jj)
/***************************************************************************/
/* Donne le jour juliene correspondant a la date                           */
/***************************************************************************/
/* *date : au format FITS                                                  */
/* *jj   : valeur du jour julien converti                                  */
/***************************************************************************/
{
   double j,jd;
   int annee=0,mois=0,jour=0,heure=0,minute=0,k,klen,kk,compteur,finmot;
   double seconde=0.;
   char chaine[256];
   klen=(int)strlen(date);
   kk=0;
   compteur=0;
   memset(chaine,'\0',256);
   finmot=PB;
   annee=1900+klen;
   for (k=0;k<klen;k++) {
      if (((date[k]>='0')&&(date[k]<='9'))||(date[k]=='.')) {
	     if (kk<(256-2)) { chaine[kk]=date[k]; chaine[kk+1]='\0'; kk++; finmot=PB; }
	     else {finmot=OK;}
	  } else { finmot=OK; }
	  if ((finmot==OK)||(k==klen-1)) {
		 if (compteur==0) {annee=atoi(chaine);}
		 else if (compteur==1) {mois=atoi(chaine);}
		 else if (compteur==2) {jour=atoi(chaine);}
		 else if (compteur==3) {heure=atoi(chaine);}
		 else if (compteur==4) {minute=atoi(chaine);}
		 else if (compteur==5) {seconde=atof(chaine);}
		 compteur++;
         memset(chaine,'\0',256);
		 kk=0;
		 finmot=PB;
	  }	  
   }
   /*
   a=(double)annee;
   m=(double)mois;
   */
   j=(double)jour+((double)heure+((double)minute+seconde/60)/60)/24;
   mc_date_jd(annee,mois,j,&jd);
   /*
   if (m<=2) {
      a=a-1;
      m=m+12;
   }
   aa=floor(a/100);
   bb=2-aa+floor(aa/4);
   jd=floor(365.25*(a+4716))+floor(30.6001*(m+1))+j+bb-1524.5;
   */
   *jj=jd;
}

void mc_jd2dateobs(double jj, char *date)
/***************************************************************************/
/* Donne la date correspondant a un jour julien                            */
/***************************************************************************/
/* jj     : valeur du jour julien a convertir                              */
/* *date : au format FITS                                                  */
/***************************************************************************/
{
   int annee,mois,jour,heure,minute,k,seca,secb;
   double jourd,heured,minuted,seconde;
   mc_jd_date(jj,&annee,&mois,&jourd);
   /*
   jj+=.5;
   z=floor(jj);
   f=jj-z;
   alpha=floor((z-1867216.25)/36524.25);
   a=z+1+alpha-floor(alpha/4);
   b=a+1524;
   c=floor(((b-122.1)/365.25));
   d=floor(365.25*c);
   e=floor((b-d)/30.6001);
   jourd=b-d-floor(30.6001*e)+f;
   mois= (e<14) ? (int)(e-1) : (int)(e-13) ;
   annee= (mois>2) ? (int)(c-4716) : (int)(c-4715) ;
   */
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
   secb=(int)(floor((seconde-(double)seca)*1.e2+.001));
#ifdef OS_LINUX_GCC_SO
   sprintf(date,"%4d-%2d-%2dT%2d:%2d:%2d.%2d",annee,mois,jour,heure,minute,seca,secb);
#else
   sprintf(date,"%4ld-%2ld-%2ldT%2ld:%2ld:%2ld.%2ld",annee,mois,jour,heure,minute,seca,secb);
#endif
   for (k=0;k<=(int)strlen(date);k++) {if (date[k]==' ') date[k]='0';}
}


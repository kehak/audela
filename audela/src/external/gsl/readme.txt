================================================================================
                          GSL - GNU Scientific Library                          
================================================================================

Voici l'extrait du fichier gsl.spec:
<<<<
  The GNU Scientific Library (GSL) is a numerical library for C and
C++ programmers.  It contains over 1000 mathematical routines written
in ANSI C.  The library follows modern coding conventions, and lends
itself to being used in very high level languages (VHLLs).

The library covers the following subject areas:

  Complex Numbers             Roots of Polynomials     Special Functions
  Vectors and Matrices        Permutations             Sorting
  BLAS Support                Linear Algebra           Eigensystems
  Fast Fourier Transforms     Quadrature               Random Numbers
  Quasi-Random Sequences      Random Distributions     Statistics
  Histograms                  N-Tuples                 Monte Carlo Integration
  Simulated Annealing         Differential Equations   Interpolation
  Numerical Differentiation   Chebyshev Approximation  Series Acceleration
  Discrete Hankel Transforms  Root-Finding             Minimization
  Least-Squares Fitting       Physical Constants       IEEE Floating-Point

Further information can be found in the GSL Reference Manual.

Install the gsl package if you need a library for high-level
scientific numerical analysis.
>>>>

Consulter le fichier readme_gsl.txt pour plus d'informations.

La version requise pour AudeLA est la 1.4.


Compilation Windows:
====================

Suivre les etapes suivantes pour compiler la gsl, et
obtenir les librairies statiques:
1/ installer les sources de la gsl dans le repertoire
   .../audela/external/gsl, de maniere a ce que le 
   fichier readme de la GSL ait pour chemin:
   .../audela/external/gsl/gsl-1.4/readme
2/ extraire l'archive gsl_msvc.zip afin de creer 
   notamment les repertoires:
   .../audela/external/gsl/gsl-1.4/msvc
   .../audela/external/gsl/gsl-1.4/GSLDLL
   .../audela/external/gsl/gsl-1.4/GSLLIBML
   .../audela/external/gsl/gsl-1.4/GSLLIBMT
3/ Copier tous les fichiers .h presents dans
   .../audela/external/gsl/gsl-1.4 et ses sous
   repertoires, dans le repertoire 
   .../audela/external/gsl/gsl-1.4/gsl
4/ Ouvrir .../audela/external/gsl/gsl-1.4/GSLLIBML.dsw
   avec visual studio, et generer les deux projets 
   (Build/Batch build, release). La taille des librairies
   doit etre environ:
   gsl.lib: 6288kB
   gslcblas.lib: 315kB
5/ Recuperer les deux librairies statiques, et les copier
   dans le repertoire :
   .../audela/external/lib
   Les renommer respectivement gslML.lib, et gslcblasML.lib

C'est tout...

Compilation Linux:
==================
Si la GSL n'est pas disponible sur le systeme, installer les
sources de la GSL comme indique en 1/. Aller ensuite dans le
repertoire gsl-1.4. Entrer les lignes de commandes suivantes
(specifier le bon chemin...):
   cd gsl-1.4
   ./configure --prefix=.../audela/external
   make
   make install

C'est tout...

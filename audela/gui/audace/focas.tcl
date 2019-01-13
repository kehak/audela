#
## @file focas.tcl
#  @brief Procs de reconnaissance de champ stellaire ou de raies spectrales
#  @author Alain KLOTZ
#  $Id: focas.tcl 14173 2017-02-28 19:47:07Z jberthier $
#  @todo traiter pour Doxygen
#

#  source $audace(rep_install)/gui/audace/focas.tcl
#

#
# =======================================================
# User guide with an example to calibrate WCS of an image
# -------------------------------------------------------
#
# In the Aud'ACE image folder you have cc.fit an image with
# approximate WCS keywords derived roughly from the telescope
# pointing and the optical characteristics.
#
# In the folder c:/d/usno we have the USNOA2 catalog.
#
# The magic function is focas_imagedb2pairs. Use it as:
# set couples [focas_imagedb2pairs cc USNOA2 c:/d/usno 1 20]
#
# The last parameter 1 is the uncertainties for matching (in pixels)
# and 20 is the number of the brightest stars for matching.
#
# The couples is a list of three elements:
#
# 1st element: Description of the 2nd element. Typically:
# {xs ys coordc idc xc yc fluxs fluxc ks kc totweight ntotvotes ntotquartet}
#
# 2nd element: A list of matched stars as described above:
# xs,ys are Sextractor coordinates in the image.
# coordc are the J2000 coordinates in the catalog
# idc is the ID of the star in the catalog
# xc,yc are projected coordc according the roughly WCS of the image.
# fluxs is the flux of the star in the image
# fluxc is the flux of the star in the catalog
# ks is the index of the star in the list of stars from the image
# kc is the index of the star in the list of stars from the catalog
# totweight is high when the matching is good
# ntotvotes is high when the matching is good
# ntotquartet is high when the matching is good
#
# 3rd element: Is the linear 2D tranform coefs {a b c} {d e f}
# to pass from (xs,ys) to (xc,yc):
# xc = a*xs + b*yc + d
# yc = e*xs + f*yc + e
# Note that this transform is based only on the three best
# stars matched.
#
# It remains to analyze the 2nd list to compute the accurate WCS.
# The following command update the WCS keywords in the buffer 1:
#
# wcs_wcs2buf [wcs_focaspairs2wcs $couples 1] 1
#
# N.B. It is possible to split the function focas_imagedb2pairs
# into three basic operations giving the same result:
#
# set star0s [focas_image2stars cc USNOA2]
# set cata0s [focas_db2catas USNOA2 c:/d/usno]
# set couples [focas_catastars2pairs $star0s $cata0s USNOA2 1 20]
#
# ===========================================================
# User guide with an example to calibrate an alpy600 spectrum
# -----------------------------------------------------------
#
# In the Aud'ACE image folder you have neon.fit an image of
# the argon-neon lamp of the Alpy600 spectrograph.
#
# The magic function is focas_imagedb2pairs. Use it as:
# set couples [focas_imagedb2pairs neon alpy600 "" 1.5 20]
#
# The last parameter 1.5 is the uncertainties for matching (in pixels)
# and 20 is the number of the brightest lines for matching.
#
# The couples is a list of three elements as described in the
# previous example.
#
# =================================================
# User guide with an example to match two 2D images
# -------------------------------------------------
#
# In the Aud'ACE image folder you have c1.fit and c2.fit
# two images of the same field of view. We can determine
# the transform matrix from an c1.fit to c2.fit by using
# the following commands:
#
# set star0s [focas_image2stars c1]
# set star1s [focas_image2stars c2]
# set couples [focas_catastars2pairs $star0s $star1s "" 1 20]
#
# star0s and star1s are lists described as:
# x,y are cartesian coordinates
# flux is the flux of the star
# fwhm is the FWHM of the star
# coord are the J2000 coordinates in the catalog
# id is the ID of the star
# flags is Sextractor like flag (not used)
#
# ===================================================================
# Format of star lists returned by focas_image2stars and focas_db2catas
# -------------------------------------------------------------------
#
# focas_image2stars and focas_db2catas return the same format of star lists:
#
# x y flux fwhm coords id flag
#
# coords = lambda in the case of a spectrum
# coords = {ra dec ?equinox?} in the case of a 2D image
#
# ===================================================================

# #############################################################################
# #############################################################################
# ### Proc utilities. No external call needed                               ###
# #############################################################################
# #############################################################################

package require math::linearalgebra
package require math::statistics

# -------------------------------------------------------------------------
# Calcule une liste de triplets a partir d'une liste de points (x,y)
#
# INPUT:
# stars : [list [list x y flux] [list x y flux] ... ]
# alim : valeur limite du grand coté (en pixels) en dessous duquel on n'enregistre pas le triangle
# dimension : =2 pour une liste (x,y) d'une image. =1 pour une liste (x,1) d'un spectre.
#
# ALGO:
#                k1              k2             k3
#                  ----- d1 -----  ----- d2 -----
#                  ------------- d3 -------------
# a est le plus grand des cotés
# b est le coté de grandeur médiane
# c est le plus petit des cotés
# ka est le point opposé au coté a
# kb est le point opposé au coté b
# kc est le point opposé au coté c
#
# OUTPUT:
# triplet : [list [list $ka $kb $kc $ba $ca $w $a] ... ]
# w est le critere de distance par rapport au pole de non ambiguité.
# w =1 au pole (tres bon triplet) et decroit jusqu'a =0 dans les cas d'ambiguite complete
#
# - En sortie on peut donc éliminer les triplet w < w_seuil.
# - Lorsque l'on comparera les triplets alors on pourra ajouter le critere de rapport
#   de flux pour eliminer les configuration de bonne geometrie mais de mauvais flux.
# -------------------------------------------------------------------------
proc focas_tools_compute_triplets { stars {alim 5} {dimension 2} } {
   set ns [llength $stars]
   set n1s [expr $ns-2]
   set n2s [expr $ns-1]
   set triplet ""
   set a2lim [expr $alim*$alim]
   set wmax 0.
   set wmax_attributs ""
   for {set k1 0} {$k1<$n1s} {incr k1} {
      lassign [lindex $stars $k1] x1 y1 f1
      for {set k2 [expr $k1+1]} {$k2<$n2s} {incr k2} {
         lassign [lindex $stars $k2] x2 y2 f2
         set dx [expr $x2-$x1]
         set dy [expr $y2-$y1]
         set d1 [expr $dx*$dx+$dy*$dy]
         for {set k3 [expr $k2+1]} {$k3<$ns} {incr k3} {
            lassign [lindex $stars $k3] x3 y3 f3
            set dx [expr $x3-$x2]
            set dy [expr $y3-$y2]
            set d2 [expr $dx*$dx+$dy*$dy]
            set dx [expr $x3-$x1]
            set dy [expr $y3-$y1]
            set d3 [expr $dx*$dx+$dy*$dy]
            if {$d1>$d2} {
               # d1 > d2
               if {$d2>$d3} {
                  # d1=|k2-k1|^2  d2=|k2-k3|^2  d3=|k3-k1|^2
                  # d1 > d2  d2 > d3
                  # d1 > d2 > d3  a=d1 b=d2 c=d3   ka=k3 kb=k1 kc=k2
                  set a $d1
                  set b $d2
                  set c $d3
                  set ka $k3
                  set kb $k1
                  set kc $k2
               } else {
                  if {$d1>$d3} {
                     # d1=|k2-k1|^2  d2=|k2-k3|^2  d3=|k3-k1|^2
                     # d1 > d2  d2 < d3  d1 > d3
                     # d1 > d3 > d2  a=d1 b=d3 c=d2   ka=k3 kb=k2 kc=k1
                     set a $d1
                     set b $d3
                     set c $d2
                     set ka $k3
                     set kb $k2
                     set kc $k1
                  } else {
                     # d1=|k2-k1|^2  d2=|k2-k3|^2  d3=|k3-k1|^2
                     # d1 > d2  d2 < d3  d1 < d3
                     # d3 > d1 > d2  a=d3 b=d1 c=d2   ka=k2 kb=k3 kc=k1
                     set a $d3
                     set b $d1
                     set c $d2
                     set ka $k2
                     set kb $k3
                     set kc $k1
                  }
               }
            } else {
               if {$d1>$d3} {
                  # d1=|k2-k1|^2  d2=|k2-k3|^2  d3=|k3-k1|^2
                  # d1 < d2  d1 > d3
                  # d2 > d1 > d3  a=d2 b=d1 c=d3   ka=k1 kb=k3 kc=k2
                  set a $d2
                  set b $d1
                  set c $d3
                  set ka $k1
                  set kb $k3
                  set kc $k2
               } else {
                  if {$d3>$d2} {
                     # d1=|k2-k1|^2  d2=|k2-k3|^2  d3=|k3-k1|^2
                     # d1 < d2  d1 < d3  d3 > d2
                     # d3 > d2 > d1  a=d3 b=d2 c=d1   ka=k2 kb=k1 kc=k3
                     set a $d3
                     set b $d2
                     set c $d1
                     set ka $k2
                     set kb $k1
                     set kc $k3
                  } else {
                     # d1=|k2-k1|^2  d2=|k2-k3|^2  d3=|k3-k1|^2
                     # d1 < d2  d1 < d3  d3 < d2
                     # d2 > d3 > d1  a=d2 b=d3 c=d1   ka=k1 kb=k2 kc=k3
                     set a $d2
                     set b $d3
                     set c $d1
                     set ka $k1
                     set kb $k2
                     set kc $k3
                  }
               }
            }
            # --- tests de validation pour eviter les triangles isocèles ou aplatis
            set valid 0
            set methode 1
            if {$methode==1} {
               # --- methode de ponderation par rapport aux bords
               if {$a<$a2lim} {
                  # --- on elimine les triangles trop petits
                  set cause "a<$alim"
               } else {
                  set a [expr sqrt($a)]
                  set b [expr sqrt($b)]
                  set c [expr sqrt($c)]
                  set ba [expr $b/$a]
                  set ca [expr $c/$a]
                  if {$dimension==2} {
                     # --- distance a la droite des triangles isoceles
                     #set h1 [expr 1-$ba]
                     # --- distance a la droite des triangles aplatis
                     #set aa -1.
                     #set bb 1.
                     #set beta [expr ($ca-$bb-$aa*$ba)/($aa+1./$aa)]
                     #set h2 [expr sqrt(1.+1./$aa/$aa)*abs($beta)]
                     # --- distance a la droite des triangles isoceles aplatis
                     #set aa 1.
                     #set bb 0.
                     #set beta [expr ($ca-$bb-$aa*$ba)/($aa+1./$aa)]
                     #set h3 [expr sqrt(1.+1./$aa/$aa)*abs($beta)]
                     # --- critere final de distance
                     #set h [expr $h1*$h2*$h3]
                     # --- critere final 2D apres simplifications
                     set h [expr -(1-$ba)*(1-$ba-$ca)*($ba-$ca)/2.]
                  } else {
                     # --- critere final de distance 1D
                     set h [expr ($ba-0.5)*(1-$ba)]
                  }
                  set valid 1
                  if {$dimension==2} {
                     # 2D : h est maximal h=1/108 pour b/a=5/6 c/a=0.5
                     set w [expr $h*108.]
                  } else {
                     # 1D : h est maximal h=1/16 pour b/a=3/4
                     set w [expr $h*16.]
                  }
                  lappend triplet [list $ka $kb $kc $ba $ca $w $a]
                  #lassign [lindex $stars $ka] xa ya fa
                  #lassign [lindex $stars $kb] xb yb fb
                  #lassign [lindex $stars $kc] xc yc fc
                  #::console::affiche_resultat "A=($xa,$ya) B=($xb,$yb) C=($xc,$yc)\n"
                  #::console::affiche_resultat "b/a=$ba c/a=$ca\n"
                  #::console::affiche_resultat "w=$w a=$a b=[expr $a*$ba]\n"
               }
            }
         }
      }
   }
   #::console::affiche_resultat ">>>>> wmax=$wmax $wmax_attributs\n"
   return $triplet
}

# =========================================================================
# procs graphiques de debug
# =========================================================================
proc focas_tools_plot_points { stars catas } {
   plotxy::clf 1
   plotxy::figure 1
   set ns [llength $stars]
   for {set k1 0} {$k1<$ns} {incr k1} {
      lassign [lindex $stars $k1] x1 y1 f1
      plotxy::plot $x1 $y1 "+b" 15
      plotxy::hold on
      #plotxy::text $x1 $y1 $k1
   }
   set nc [llength $catas]
   for {set k1 0} {$k1<$nc} {incr k1} {
      lassign [lindex $catas $k1] x1 y1 f1
      set rayon [expr 1+int(8*log10($f1))]
      #console::affiche_resultat "$x1 $y1 **===> f1=$f1 r=$rayon\n"
      plotxy::plot $x1 $y1 "or" $rayon
      plotxy::hold on
   }
   plotxy::xlabel "columns (pixels)"
   plotxy::ylabel "lines (pixels)"
}

proc focas_tools_plot_points_triangles { stars catas triplet_star triplet_cata } {
   plotxy::figure 1
   lassign $triplet_star ks1 ks2 ks3 bas cas
   set a [lindex $stars $ks1]
   set b [lindex $stars $ks2]
   set c [lindex $stars $ks3]
   lassign $a xa ya
   lassign $b xb yb
   lassign $c xc yc
   if {($ya==1)&&($yb==1)&&($yc==1)} {
      set yb 2
      set yc 3
   }
   plotxy::plot [list $xa $xb $xc $xa] [list $ya $yb $yc $ya] ":b"
   lassign $triplet_cata kc1 kc2 kc3 bac cac
   set a [lindex $catas $kc1]
   set b [lindex $catas $kc2]
   set c [lindex $catas $kc3]
   lassign $a xa ya
   lassign $b xb yb
   lassign $c xc yc
   if {($ya==1)&&($yb==1)&&($yc==1)} {
      set yb 2
      set yc 3
   }
   plotxy::plot [list $xa $xb $xc $xa] [list $ya $yb $yc $ya] "-r"
}

proc focas_tools_plot_triplets { triplet_stars triplet_catas } {
   plotxy::clf 2
   plotxy::figure 2
   set ns [llength $triplet_stars]
   for {set k1 0} {$k1<$ns} {incr k1} {
      lassign [lindex $triplet_stars $k1] a b c ba ca
      plotxy::plot $ba $ca "*b"
      plotxy::hold on
   }
   set ns [llength $triplet_catas]
   for {set k1 0} {$k1<$ns} {incr k1} {
      lassign [lindex $triplet_catas $k1] a b c ba ca
      plotxy::plot $ba $ca "or"
      plotxy::hold on
   }
   plotxy::axis [list 0 1 0 1]
   plotxy::xlabel "b/a"
   plotxy::ylabel "c/a"
   plotxy::setgcf 2 {position {460 40 400 400}}
}

proc focas_tools_plot_triplets_triangles { triplet_star triplet_cata } {
   plotxy::figure 2
   lassign $triplet_star ks1 ks2 ks3 bas cas
   plotxy::plot $bas $cas "+b" 15
   lassign $triplet_cata kc1 kc2 kc3 bac cac
   plotxy::plot $bac $cac "xr" 15
}

proc focas_tools_matrice3x3_determinant { m } {
   lassign $m l1 l2 l3
   lassign $l1 a11 a12 a13
   lassign $l2 a21 a22 a23
   lassign $l3 a31 a32 a33
   set det [expr $a11*($a22*$a33-$a32*$a23)-$a21*($a12*$a33-$a32*$a13)+$a31*($a12*$a23-$a22*$a13)]
   return $det
}

# --- proc de resolution d'un systeme de 3 equations a 3 inconnues
# pour (a,b,c) de x2_ = a*x1_ + b*y1_ + c
# pour (d,e,f) de y2_ = d*x1_ + e*y1_ + f
# et _=1 et _=2
# Exemple
# set a 2.5
# set b 3.1
# set c -2.8
# set d -3.1
# set e 2.5
# set f -0.04
# set x11 3 ; set y11 4
# set x21 [expr $a*$x11 + $b*$y11 + $c]
# set y21 [expr $d*$x11 + $e*$y11 + $f]
# set x12 -5 ; set y12 -3
# set x22 [expr  $a*$x12 + $b*$y12 + $c]
# set y22 [expr $d*$x12 + $e*$y12 + $f]
# set x13 0 ; set y13 12
# set x23 [expr  $a*$x13 + $b*$y13 + $c]
# set y23 [expr $d*$x13 + $e*$y13 + $f]
# set xy1s [list [list $x11 $y11] [list $x12 $y12] [list $x13 $y13] ]
# set xy2s [list [list $x21 $y21] [list $x22 $y22] [list $x23 $y23] ]
# set det_abcdef [focas_tools_linear_transform_3points $xy1s $xy2s]
proc focas_tools_linear_transform_3points { xy1s xy2s } {
   set a11 [lindex [lindex $xy1s 0] 0]
   set a12 [lindex [lindex $xy1s 0] 1]
   set a13 1.
   set a21 [lindex [lindex $xy1s 1] 0]
   set a22 [lindex [lindex $xy1s 1] 1]
   set a23 1.
   set a31 [lindex [lindex $xy1s 2] 0]
   set a32 [lindex [lindex $xy1s 2] 1]
   set a33 1.
   set m [list [list $a11 $a12 $a13] [list $a21 $a22 $a23] [list $a31 $a32 $a33] ]
   #::console::affiche_resultat "m = $m\n"
   set detm [focas_tools_matrice3x3_determinant $m]
   set res ""
   lappend res $detm
   for {set index2 0} {$index2<=1} {incr index2} {
      set b1 [lindex [lindex $xy2s 0] $index2]
      set b2 [lindex [lindex $xy2s 1] $index2]
      set b3 [lindex [lindex $xy2s 2] $index2]
      set m1 [list [list $b1 $a12 $a13] [list $b2 $a22 $a23] [list $b3 $a32 $a33] ]
      set detm1 [focas_tools_matrice3x3_determinant $m1]
      set m2 [list [list $a11 $b1 $a13] [list $a21 $b2 $a23] [list $a31 $b3 $a33] ]
      set detm2 [focas_tools_matrice3x3_determinant $m2]
      set m3 [list [list $a11 $a12 $b1] [list $a21 $a22 $b2] [list $a31 $a32 $b3] ]
      set detm3 [focas_tools_matrice3x3_determinant $m3]
      set rs ""
      if {$detm!=0} {
         lappend rs [expr 1.*$detm1/$detm]
         lappend rs [expr 1.*$detm2/$detm]
         lappend rs [expr 1.*$detm3/$detm]
      } else {
         if {$index2==0} {
            set rs {1 0 0}
         } else {
            set rs {0 1 0}
         }
      }
      lappend res $rs
   }
   return $res
}

proc focas_tools_matrice2x2_determinant { m } {
   lassign $m l1 l2
   lassign $l1 a11 a12
   lassign $l2 a21 a22
   set det [expr $a11*$a22-$a21*$a12]
   return $det
}

# --- proc de resolution d'un systeme de 2 equations a 2 inconnues
# pour (a,b) de x2_ = a*x1_ + b
# et _=1 et _=2
# Exemple
# set a 2.5
# set b 3.1
# set x11 3
# set x21 [expr $a*$x11 + $b]
# set x12 -5
# set x22 [expr  $a*$x12 + $b]
# set xy1s [list $x11 $x12 ]
# set xy2s [list $x21 $x22 ]
# set det_ab [focas_tools_linear_transform_2points $xy1s $xy2s]
proc focas_tools_linear_transform_2points { xy1s xy2s } {
   set a11 [lindex $xy1s 0]
   set a12 1
   set a21 [lindex $xy1s 1]
   set a22 1
   set m [list [list $a11 $a12 ] [list $a21 $a22 ] ]
   # ::console::affiche_resultat "m = $m\n"
   set detm [focas_tools_matrice2x2_determinant $m]
   set res ""
   lappend res $detm
   set b1 [lindex $xy2s 0]
   set b2 [lindex $xy2s 1]
   set m1 [list [list $b1 $a12 ] [list $b2 $a22 ] ]
   set detm1 [focas_tools_matrice2x2_determinant $m1]
   set m2 [list [list $a11 $b1 ] [list $a21 $b2 ] ]
   set detm2 [focas_tools_matrice2x2_determinant $m2]
   set rs ""
   if {$detm!=0} {
      lappend rs [expr 1.*$detm1/$detm]
      lappend rs [expr 1.*$detm2/$detm]
   } else {
      set rs {1 0}
   }
   lappend res $rs
   return $res
}

proc focas_tools_build_matrix {xvec degree} {
    set sums [llength $xvec]
    for {set i 1} {$i <= 2*$degree} {incr i} {
        set sum 0
        foreach x $xvec {
            set sum [expr {$sum + pow($x,$i)}]
        }
        lappend sums $sum
    }

    set order [expr {$degree + 1}]
    set A [math::linearalgebra::mkMatrix $order $order 0]
    for {set i 0} {$i <= $degree} {incr i} {
        set A [math::linearalgebra::setrow A $i [lrange $sums $i $i+$degree]]
    }
    return $A
}

proc focas_tools_build_vector {xvec yvec degree} {
    set sums [list]
    for {set i 0} {$i <= $degree} {incr i} {
        set sum 0
        foreach x $xvec y $yvec {
            set sum [expr {$sum + $y * pow($x,$i)}]
        }
        lappend sums $sum
    }

    set x [math::linearalgebra::mkVector [expr {$degree + 1}] 0]
    for {set i 0} {$i <= $degree} {incr i} {
        set x [math::linearalgebra::setelem x $i [lindex $sums $i]]
    }
    return $x
}

proc focas_tools_polyfit {x y degree} {
   set A [focas_tools_build_matrix $x $degree]
   set b [focas_tools_build_vector $x $y $degree]
   # solve it
   set coeffs [math::linearalgebra::solveGauss $A $b]
   return $coeffs
}

proc focas_tools_polyval { coefs x } {
   set np [llength $coefs]
   set lambda 0.
   for {set kp 0} {$kp<$np} {incr kp} {
      set l [expr [lindex $coefs $kp]*pow($x,$kp)]
      set lambda [expr $lambda+$l]
   }
   return $lambda
}

# #############################################################################
# #############################################################################
# ### Proc useful for users                                                 ###
# #############################################################################
# #############################################################################

proc focas_simulation2catastars { type {transform_star2cata "" } } {

   global audace
   set bufno $audace(bufNo)

   if {$type=="alpy600"} {
      set transform_star2cata {1.03 23.56}
      set ab $transform_star2cata
      lassign $ab a b
   } else {
      set pi [expr 4*atan(1)]
      set dr [expr $pi/180.]
      set theta 30.
      set cost [expr cos($theta*$dr)]
      set sint [expr sin($theta*$dr)]
      set mult 1.05
      set tx 23.56
      set ty -53.12
      set a11 [expr $mult*$cost]
      set a12 [expr $mult*$sint]
      set a21 [expr -$mult*$sint]
      set a22 [expr $mult*$cost]
      set transform_star2cata [list [list $a11 $a12 $tx] [list $a21 $a22 $ty] ]
      lassign $transform_star2cata abc def
      lassign $abc a b c
      lassign $def d e f
   }
   #console::affiche_resultat "Transform = $transform_star2cata\n"
   set simunaxis1 1024
   set simunaxis2 1024
   buf$bufno new CLASS_GRAY $simunaxis1 $simunaxis2 FORMAT_SHORT COMPRESS_NONE
   set dateobs [mc_date2iso8601 now]
   set commande "buf$bufno setkwd \{ \"DATE-OBS\" \"$dateobs\" \"string\" \"Begining of exposure UT\" \"Iso 8601\" \}"
   set err1 [catch {eval $commande} msg]
   set commande "buf$bufno setkwd \{ \"NAXIS\" \"2\" \"int\" \"\" \"\" \}"
   set err1 [catch {eval $commande} msg]
   #
   if {$type=="alpy600"} {
      set stars ""
      lappend stars [list  30    1 301 4 0 0 0]
      lappend stars [list 230    1 401 4 0 0 0]
      lappend stars [list 130    1 501 4 0 0 0]
      lappend stars [list 730    1 601 4 0 0 0]
      lappend stars [list 110    1 541 4 0 0 0]
      lappend stars [list 105    1 511 4 0 0 0]
      lappend stars [list  65    1 411 4 0 0 0]
      #
      set catas ""
      set id 0
      foreach star $stars {
         lassign $star xs ys is
         set xc [expr $a*$xs+$b]
         set yc 1
         set flux [expr 5*$is]
         set lambda 0
         set fwhm 2
         incr id
         lappend catas [list $xc $yc $flux $fwhm $lambda $id 0]
      }
   } else {
      set stars ""
      lappend stars [list 100  200 300 4 0 0 0]
      lappend stars [list 400  200 400 4 0 0 0]
      lappend stars [list 400  600 600 4 0 0 0]
      lappend stars [list  30   60  60 4 0 0 0]
      lappend stars [list 130  960  70 4 0 0 0]
      lappend stars [list 830  860  80 4 0 0 0]
      lappend stars [list 730  160  90 4 0 0 0]
      #
      set catas ""
      set id 0
      foreach star $stars {
         lassign $star xs ys is
         set xc [expr $a*$xs+$b*$ys+$c]
         set yc [expr $d*$xs+$e*$ys+$f]
         set flux [expr 5*$is]
         set ra 0
         set dec 0
         set fwhm 2
         incr id
         lappend catas [list $xc $yc $flux $fwhm [list $ra $dec] $id 0]
      }
   }
   set stars [lsort -decreasing -real -index 2 $stars]
   set catas [lsort -decreasing -real -index 2 $catas]
   return [list $stars $catas]
}

# type = "" for 2D classical images of the sky (calibrated WCS)
# type = alpy600 for 1D calibration spectrum
# focas_image2stars cc
proc focas_image2stars { filename {catatype ""} } {

   global audace
   set bufno $audace(bufNo)
   set fichier [ file join $audace(rep_images) $filename ]
   buf$::audace(bufNo) load $fichier
   set res [focas_buf2stars $bufno $catatype]
   buf$::audace(bufNo) load $fichier
   return $res
}

# type = "" for 2D classical images of the sky (calibrated WCS)
# type = alpy600 for 1D calibration spectrum
# focas_buf2stars 1
proc focas_buf2stars { bufno {catatype ""} {tmp_dir ""} } {

   global audace
   lassign $catatype type subtype

   #::console::affiche_resultat " type=$type subtype=$subtype\n"
  if {$type=="alpy600"} {

      # =========================================================================
      # === extraction d'une liste de toutes les raies de l'image de calibration en ordre d'eclat decroissant
      # =========================================================================

      if {$tmp_dir==""} {
         set tmp_dir $audace(rep_images)
      }
      set fichier [ file join $tmp_dir tmp.fit ]
      buf$::audace(bufNo) save $fichier
      # === Detection en aveugle de la zone où se trouve le spectre
      set naxis1 [buf1 getpixelswidth]
      set naxis2 [buf1 getpixelsheight]
      # --- profile du binning en vertical
      buf1 imaseries "BINX x1=1 x2=$naxis1 height=1"
      set xs ""
      set adus ""
      set dadus ""
      set value0 [lindex [buf1 getpix [list 1 1]] 1]
      for {set ky 2} {$ky<=[expr $naxis2-1]} {incr ky} {
         set value [lindex [buf1 getpix [list 1 $ky]] 1]
         set dvalue [expr $value-$value0]
         lappend xs $ky
         lappend dadus $dvalue
         lappend adus $value
         set value0 $value
      }
      set n [llength $adus]

      if {$subtype=="double_slit"} {
         # --- calcul du seuil par rapport au bruit
         set std [::math::statistics::stdev [lrange $dadus 10 60]]
         set pente_seuil [expr 20*$std]
         # --- recherche kx1 le debut du spectre
         set kx1 0
         for {set k 2} {$k<=$n} {incr k} {
            set df [lindex $dadus $k]
            if {$df>$pente_seuil} {
               set kx1 $k
               break
            }
         }
         # --- recherche kxf1 la pente maximale du debut du spectre
         set kxf1 0
         set df0 [lindex $dadus [expr $kx1+0]]
         set df1 [lindex $dadus [expr $kx1+1]]
         for {set k [expr $kx1+2]} {$k<=$n} {incr k} {
            set df2 [lindex $dadus $k]
            set ddf01 [expr $df1-$df0]
            set ddf12 [expr $df2-$df1]
            if {($ddf01>0)&&($ddf12<=0)} {
               set kxf1 $df1
               break
            }
            set df0 $df1
            set df1 $df2
         }
         # --- recherche kx2 la fin du spectre
         set kx2 [expr $n-1]
         for {set k [expr $n-2]} {$k>=0} {incr k -1} {
            set df [lindex $dadus $k]
            if {$df<-$pente_seuil} {
               set kx2 $k
               break
            }
         }
         # --- recherche kxf2 la pente maximale de fin du spectre
         set kxf2 0
         set df0 [lindex $dadus [expr $kx2-1]]
         set df1 [lindex $dadus [expr $kx2-2]]
         for {set k [expr $kx2-3]} {$k>=0} {incr k -1} {
            set df2 [lindex $dadus $k]
            set ddf01 [expr $df1-$df0]
            set ddf12 [expr $df2-$df1]
            if {($ddf01<0)&&($ddf12>=0)} {
               set kxf2 [expr -1*$df1]
               break
            }
            set df0 $df1
            set df1 $df2
         }
         # --- on compare kxf1 et kxf2 pour determiner qui est le bon coté
         # c'est la plus petite valeur qui correspond au bon spectre
         if {$kxf1<$kxf2} {
            set kdeb $kx1
            # --- on recherche kfin
            set kfin $kdeb
            for {set k [expr $kdeb+25]} {$k<=$naxis2} {incr k} {
               set df [lindex $dadus $k]
               if {$df>$pente_seuil} {
                  set kfin $k
                  break
               }
            }
         } else {
            set kfin $kx2
            # --- on recherche kdeb
            for {set k [expr $kfin-25]} {$k>=0} {incr k -1} {
               set df [lindex $dadus $k]
               if {$df<-$pente_seuil} {
                  set kdeb $k
                  break
               }
            }
         }
      } else {
         # --- calcul du seuil par rapport au bruit
         set std [::math::statistics::stdev [lrange $dadus 10 60]]
         set pente_seuil [expr 20*$std]
         # --- recherche kdeb le debut du spectre
         for {set k 2} {$k<=$n} {incr k} {
            set df [lindex $dadus $k]
            if {$df>$pente_seuil} {
               set kdeb $k
               break
            }
         }
         # --- recherche kfin la fin du spectre
         for {set k [expr $n-2]} {$k>=$kdeb} {incr k -1} {
            set df [lindex $dadus $k]
            if {$df<[expr -1*$pente_seuil]} {
               set kfin $k
               break
            }
         }
         set k [expr ($kdeb+$kfin)/2]
         set kdeb [expr $k-30]
         set kfin [expr $k+30]
      }
      #::console::affiche_resultat "kdeb=$kdeb kfin=$kfin\n"
      # --- a present on sait que le bon spectre se trouve entre kdeb et kfin

      # === On va maintenant extraire le profil du spectre de calibration
      buf$::audace(bufNo) load $fichier
      set exposure [lindex [buf1 getkwd EXPOSURE] 1]
      set biny 20
      set y1 [expr int(($kdeb+$kfin)/2-$biny/2)]
      set y2 [expr $y1+$biny]
      buf1 imaseries "BINY y1=$y1 y2=$y2 height=1"
      buf1 bitpix -32
      buf$::audace(bufNo) save profile
      buf$::audace(bufNo) load profile
      set naxis1 [buf1 getpixelswidth]
      set xs ""
      set adus ""
      set dadus ""
      set mini 1e12
      set maxi -1e12
      set lignes ""
      set value0 [lindex [buf1 getpix [list 1 1]] 1]
      for {set kx 1} {$kx<=$naxis1} {incr kx} {
         set value [lindex [buf1 getpix [list $kx 1]] 1]
         set dvalue [expr $value-$value0]
         if {$value>$maxi} { set maxi $value }
         if {$value<$mini} { set mini $value }
         lappend xs $kx
         lappend dadus $dvalue
         lappend adus $value
         set value0 $value
         append lignes "$kx $value\n"
      }
      #plotxy::plot $xs $adus b
      set f [open $audace(rep_images)/profile.txt w]
      puts -nonewline $f $lignes
      close $f
      # === Detection en aveugle des raies et calcul de l'abscisse precise en pixels
      # --- calcul du seuil par rapport au bruit
      set std [::math::statistics::stdev [lrange $dadus 0 20]]
      set seuil1 [expr 5*$std]
      # --- calcul du seuil par rapport au mini et maxi
      set seuil2 [expr 0.001*($maxi-$mini)]
      # --- on choisit le plus grand seuil
      if {$seuil1>$seuil2} {
         set seuil $seuil1
      } else {
         set seuil $seuil2
      }
      # --- algo de detection des pics
      set liste ""
      set liste2 ""
      set stars ""
      set id 0
      set value1 [lindex [buf1 getpix [list 1 1]] 1]
      set value2 [lindex [buf1 getpix [list 2 1]] 1]
      set value3 [lindex [buf1 getpix [list 3 1]] 1]
      set value4 [lindex [buf1 getpix [list 4 1]] 1]
      for {set kx 4} {$kx<=[expr $naxis1-2]} {incr kx} {
         set value5 [lindex [buf1 getpix [list [expr $kx+1] 1]] 1]
         if {$value3>$seuil} {
            set slope12 [expr $value2-$value1]
            set slope23 [expr $value3-$value2]
            set slope34 [expr $value4-$value3]
            set slope45 [expr $value5-$value4]
            if {($slope12>0)&&($slope23>0)&&($slope34<0)&&($slope45<0)} {
               set total 0.
               set total [expr $total+($value1-$mini)*($kx-3)]
               set total [expr $total+($value2-$mini)*($kx-2)]
               set total [expr $total+($value3-$mini)*($kx-1)]
               set total [expr $total+($value4-$mini)*($kx-0)]
               set total [expr $total+($value5-$mini)*($kx+1)]
               set deno [expr $value1+$value2+$value3+$value4+$value5-5*$mini]
               set pix [expr 1.*$total/$deno]
               set larg 4
               set x1 [expr int($pix-$larg)]
               set x2 [expr $x1+2*$larg]
               set y1 1
               set y2 1
               set box [list $x1 $y1 $x2 $y2]
               set valeurs [ buf1 fitgauss $box ]
               set dif 0.
               set intx [lindex $valeurs 0]
               set xc [lindex $valeurs 1]
               set fwhmx [lindex $valeurs 2]
               set bgx [lindex $valeurs 3]
               set inty [lindex $valeurs 4]
               set yc [lindex $valeurs 5]
               set fwhmy [lindex $valeurs 6]
               set bgy [lindex $valeurs 7]
               #
               # ::console::affiche_resultat "kx=$kx value3=$value3 fwhmx=$fwhmx  == $intx > $seuil \n"
               if {($fwhmx>0.8)&&($intx>$seuil)} {
                  set if0 [ expr $intx*$fwhmx*.601*sqrt(3.14159265) ]
                  #set lambda [polyval $polys $xc]
                  set lambda 0
                  append liste "[format %7.2f $xc] [format %6.0f [expr $intx/$exposure/$biny]] [format %.1f $lambda] [format %.1f $fwhmx]\n"
                  if {$lambda>3800} {
                     append liste2 "[format %.1f $lambda] [format %6.0f [expr $intx/$exposure/$biny]] [format %7.2f $xc]\n"
                  }
                  set x $xc
                  set y 1
                  set flux [expr $intx/$exposure/$biny]
                  set fluxerr 0
                  set background $mini
                  set fwhm $fwhmx
                  set flags 0
                  incr id
                  lappend stars [list $x $y $flux $fwhm $lambda $id $flags]
               }
            }
         }
         set value1 $value2
         set value2 $value3
         set value3 $value4
         set value4 $value5
      }
      set star0s [lsort -decreasing -real -index 2 $stars]
      set nstar0s [llength $star0s]
      #::console::affiche_resultat "$nstar0s calibration lines found\n"

   } else {

      # =========================================================================
      # === extraction d'une liste de toutes les sources de l'image en ordre d'eclat decroissant
      # =========================================================================
      if {$tmp_dir==""} {
         set tmp_dir .
      }
       # teste si WCS present
      set err [catch {wcs_buf2wcs $::audace(bufNo)} wcs]
      if {$err==1} {
         set wcs ""
      }
      set ext $::conf(extension,defaut)
      # --- Remplacement de "$::audace(rep_images)" par "." dans "mypath" - Cela permet a
      # --- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
      # --- espaces et ayant une longueur superieure a 70 caracteres
      set mypath $tmp_dir
      set sky0 dummy0
      set sky dummy
      buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
      createFileConfigSextractor $mypath
      sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"
     # --- params
      #::console::affiche_resultat "analyze $mypath/config.param\n"
      set f [open "$mypath/config.param" r]
      set lignes [split [read $f] \n]
      close $f
      set params ""
      foreach ligne $lignes {
         set ligne [lindex $ligne 0]
         if {$ligne==""} {
            continue
         }
         set diese [string index $ligne 0]
         if {$diese=="#"} {
            continue
         }
         lappend params $ligne
      }
      set k [lsearch $params X_IMAGE]
      set kx $k
      set k [lsearch $params Y_IMAGE]
      set ky $k
      set k [lsearch $params FLUX_BEST]
      set kflux $k
      set k [lsearch $params FLUXERR_BEST]
      set kfluxerr $k
      set k [lsearch $params FLAGS]
      set kflags $k
      set k [lsearch $params BACKGROUND]
      set kbackground $k
      set k [lsearch $params FWHM_IMAGE]
      set kfwhm_image $k
      #::console::affiche_resultat "indexes x=$kx y=$ky flux=$kflux fluxerr=$kfluxerr\n"
      # ---
      set vignetting 1
      #::console::affiche_resultat "vignetting=$vignetting\n"
      #::console::affiche_resultat "analyze star list\n"
      set f [open "$mypath/catalog.cat" r]
      set lignes [split [read $f] \n]
      close $f
      set t ""
      set stars ""
      set exposure 1.
      set vignetting2 [expr $vignetting*$vignetting]
      set id 0
      foreach ligne $lignes {
         if {([lindex $ligne 0]=="")||([string index [string trim $ligne] 0]=="#")} {
            continue
         }
         set x [lindex $ligne $kx]
         set y [lindex $ligne $ky]
         if {$vignetting<1} {
            set dx [expr 1.*($x-$naxis1/2)/($naxis1/2)]
            set dy [expr 1.*($y-$naxis2/2)/($naxis2/2)]
            set r2 [expr $dx*$dx+$dy*$dy]
            if {$r2>$vignetting2} {
               continue
            }
         }
         set flux [expr [lindex $ligne $kflux]/$exposure]
         set fluxerr [expr [lindex $ligne $kfluxerr]/$exposure]
         set background [lindex $ligne $kbackground]
         set fwhm [lindex $ligne $kfwhm_image]
         set flags [lindex $ligne $kflags]
         incr id
         if {$wcs!=""} {
            lassign [wcs_p2radec $wcs $x $y] ra dec
         } else {
            set ra 0
            set dec 0
         }
         lappend stars [list $x $y $flux $fwhm [list $ra $dec] $id $flags]
      }
      set star0s [lsort -decreasing -real -index 2 $stars]
      set nstar0s [llength $star0s]
      #::console::affiche_resultat "$nstar0s stars found by sextractor\n"
   }

   return $star0s

}

# focas_db2catas USNOA2 c:/d/usno
proc focas_db2catas { catatype catapath } {

   global audace
   set bufno $audace(bufNo)
   lassign $catatype type subtype

   if {$type=="alpy600"} {

      # =========================================================================
      # on construit une liste de type x y flux avec les etoiles du catalogue en magnitudes croissantes
      # =========================================================================

      # === Liste (x,lambda) des raies reconnues dans le profile (bin 1x1)
      set pics ""
      #             pix     adus/s    A      comment
      lappend pics " 774.94      3 3809.456 {Ar}"
      lappend pics " 834.08      5 3948.98  {Ar}"
      lappend pics " 853.06      2 3994.792 {Ar II}"
      lappend pics " 938.87     58 4200.67  {Ar}"
      lappend pics "1106.89     18 4609.567 {Ar II}"
      lappend pics "1170.82     32 4764.87  {Ar}"
      lappend pics "1252.93      8 4965.080 {Ar II}"
      lappend pics "1273.85     10 5017.163 {Ar II}"
      lappend pics "1292.00      2 5062.037 {Ar II}"
      lappend pics "1432.00      7 5400.562 {Ne}"
      lappend pics "1471.98      7 5495.874 {Ar}"
      lappend pics "1497.97      8 5558.702 {Ar}"
      lappend pics "1537.00      4 5650.704 {Ar}"
      lappend pics "1621.65    411 5852.49  {Ne}"
      lappend pics "1724.77     53 6096.163 {Ne}"
      lappend pics "1744.70     78 6143.06  {Ne}"
      lappend pics "1855.71    106 6402.248 {Ne}"
      lappend pics "1924.93     63 6562.8   {H}"
      #lappend pics "1975.05     93 6677.28  {Ar}"
      lappend pics "2101.96    699 6965.43  {Ar}"
      lappend pics "2147.70    362 7067.22  {Ar}"
      lappend pics "2239.97    134 7272.936 {Ar}"
      lappend pics "2290.78    481 7383.980 {Ar}"
      lappend pics "2345.90   2174 7503.869 {Ar}"
      lappend pics "2406.03   1272 7635.106 {Ar}"
      lappend pics "2553.84    257 7948.176 {Ar}"
      #lappend pics "2583       295 8103.693 {Ar}"
      lappend pics "2633.89    438 8115.311 {Ar}"
      lappend pics "2706.85    132 8264.522 {Ar}"
      lappend pics "2781       264 8424.648 {Ar}"

      set ls ""
      foreach pic $pics {
         set x [lindex $pic 0]
         set y 1
         set flux [lindex $pic 1]
         set fwhm 1
         set lambda [lindex $pic 2]
         set id [lindex $pic 3]
         lappend ls [list $x $y $flux $fwhm $lambda $id 0]
      }
      set cata0s [lsort -real -decreasing -index 2 $ls]

   } else {

      # info commands cs*
      # =========================================================================
      # === recupere ra dec radius filtre de l'image
      # =========================================================================
      # teste si WCS present
      set err [catch {wcs_buf2wcs $bufno} wcs]
      if {$err==1} {
         error "$wcs"
      }
      #wcs_dispkwd $wcs "" public
      set naxis1 [buf$bufno getpixelswidth]
      set naxis2 [buf$bufno getpixelsheight]
      set xc [expr $naxis1/2.]
      set yc [expr $naxis2/2.]
      set radec [wcs_p2radec $wcs $xc $yc]
      lassign $radec ra0 dec0
      set corners [list [list 0 0] [list $naxis1 0] [list 0 $naxis2] [list $naxis1 $naxis2]]
      set sepangles ""
      foreach corner $corners {
         set xc [lindex $corner 0]
         set yc [lindex $corner 1]
         set radec [wcs_p2radec $wcs $xc $yc]
         lassign $radec ra dec
         set sepangle [lindex [mc_sepangle $ra0 $dec0 $ra $dec] 0]
         #::console::affiche_resultat "$ra0 $dec0 $ra $dec ==> $sepangle\n"
         lappend sepangles $sepangle
      }
      set radius [expr 60.*[lindex [lsort -real -decreasing $sepangles] 0] ]
      set filtre [string trim [lindex [buf$bufno getkwd FILTER] 1]]
      set catalog $catatype
      set path $catapath

      set t0 [clock milliseconds]

      # =========================================================================
      # === recupere ra dec mag a partir du catalogue
      # =========================================================================
      # On limite le nombre d'etoiles en adapatant la magnitude limite
      set nstarlim 60 ; # nombre d'etoiles limites pour la liste de sortie
      set nstarmin 10 ; # nombre d'etoiles minimum pour la liste de sortie

      set filtre [string toupper $filtre]
      set Catalog [string toupper $catalog]
      set catalog [string tolower $catalog]
      set mag_bright -5
      set mag_faint 5
      set nstar0s -1
      set nstars 0
      set sortie 0
      while {$sortie==0} {
         #::console::affiche_resultat "ETAPE 1\ncs${catalog} $path $ra0 $dec0 $radius $mag_faint $mag_bright\n"
         #tk_messageBox -message "ETAPE 1"
         set command "cs${catalog} $path $ra0 $dec0 $radius $mag_faint $mag_bright"
         set res [eval $command]
         #tk_messageBox -message "ETAPE 2"
         lassign $res infos stars
         set nstars [llength $stars]
         #::console::affiche_resultat "nstars=$nstars nstarlim=$nstarlim nstars=$nstars nstar0s=$nstar0s\n"
         #tk_messageBox -message "ETAPE 3\nnstars=$nstars nstarlim=$nstarlim nstars=$nstars nstar0s=$nstar0s"
         if {$nstars<$nstarlim} {
            if {$nstars!=$nstar0s} {
               set mag_faint [expr $mag_faint + 1]
               set nstar0s $nstars
               #::console::affiche_resultat "mag_faint=$mag_faint\n"
               continue
            }
         }
         #::console::affiche_resultat "mag_faint=$mag_faint nstars=$nstars\n"
         #::console::affiche_resultat "res=$res\n"
         #tk_messageBox -message "ETAPE 4\nmag_faint=$mag_faint nstars=$nstars"

         # =========================================================================
         # on construit une liste de type ra dec mag avec les etoiles du catalogue en magnitudes croissantes
         # =========================================================================
         set ls ""
         set magmax -100
         foreach star $stars {
            set res [lindex [lindex $star 0] 2]
            if {$catalog=="usnoa2"} {
               set id [lindex $res 0]
               set ra [lindex $res 1]
               set dec [lindex $res 2]
               set equinox J2000
               set magb [lindex $res 6]
               set magr [lindex $res 7]
               if {($magb==0.10)&&($magr==0.10)} {
                  continue
               }
               if     {$filtre=="R"} { set mag $magr
               } elseif {$filtre=="B"} { set mag $magb
               } elseif {$filtre=="V"} { set mag $magr
               } else { set mag $magr
               }
               set l [list $ra $dec $mag $id ]
               lappend ls $l
            }
            if {$catalog=="tycho2"} {
               set id [lindex $res 1]-[lindex $res 2]-[lindex $res 3]
               set ra [lindex $res 5]
               set dec [lindex $res 6]
               set equinox J2000
               set mura_masyr [lindex $res 7]
               set mudec_masyr [lindex $res 8]
               set epoch [lindex $res 13]
               set plx_mas 0
               set magb [lindex $res 20]
               set magv [lindex $res 22]
               if     {$filtre=="R"} { set mag $magv
               } elseif {$filtre=="B"} { set mag $magb
               } elseif {$filtre=="V"} { set mag $magv
               } else { set mag $magv
               }
               set l [list $ra $dec $mag $id $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
               #console::affiche_resultat "$l\n"
               lappend ls $l
            }
            if {$catalog=="ucac2"} {
               set id [lindex $res 0]
               set ra [lindex $res 1]
               set dec [lindex $res 2]
               set equinox J2000
               set mura_masyr [lindex $res 12]
               set mudec_masyr [lindex $res 13]
               set epoch [lindex $res 13]
               set plx_mas 0
               set mag [lindex $res 19]
               set l [list $ra $dec $mag $id $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
               #console::affiche_resultat "$l\n"
               lappend ls $l
            }
            if {$catalog=="ucac3"} {
               set id [lindex $res 0]
               set ra [lindex $res 1]
               set dec [lindex $res 2]
               set equinox J2000
               set mura_masyr [lindex $res 16]
               set mudec_masyr [lindex $res 17]
               set epoch [expr ([lindex $res 14]+[lindex $res 15])/2.]
               set plx_mas 0
               set mag [lindex $res 27]
               if     {$filtre=="R"} { set mag [lindex $res 27]
               } elseif {$filtre=="I"} { set mag [lindex $res 28]
               } elseif {$filtre=="B"} { set mag [lindex $res 26]
               } elseif {$filtre=="V"} { set mag [lindex $res 27]
               } elseif {$filtre=="J"} { set mag [lindex $res 21]
               } elseif {$filtre=="H"} { set mag [lindex $res 22]
               } elseif {$filtre=="K"} { set mag [lindex $res 23]
               } else { set mag [lindex $res 27]
               }
               set l [list $ra $dec $mag $id $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
               #console::affiche_resultat "$l\n"
               lappend ls $l
            }
            if {$catalog=="ucac4"} {
               set id [lindex $res 0]
               set ra [lindex $res 1]
               set dec [lindex $res 2]
               set equinox J2000
               set mura_masyr [lindex $res 15]
               set mudec_masyr [lindex $res 16]
               set epoch [expr ([lindex $res 13]+[lindex $res 14])/2.]
               set plx_mas 0
               set mag [lindex $res 4]
               if     {$filtre=="R"} { set mag [lindex $res 32]
               } elseif {$filtre=="I"} { set mag [lindex $res 33]
               } elseif {$filtre=="B"} { set mag [lindex $res 26]
               } elseif {$filtre=="V"} { set mag [lindex $res 30]
               } elseif {$filtre=="J"} { set mag [lindex $res 20]
               } elseif {$filtre=="H"} { set mag [lindex $res 21]
               } elseif {$filtre=="K"} { set mag [lindex $res 22]
               } else { set mag [lindex $res 32]
               }
               set l [list $ra $dec $mag $id $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
               #console::affiche_resultat "$l\n"
               lappend ls $l
            }
            if {$catalog=="nomad1"} {
               set id [lindex $res 0]
               set ra [lindex $res 2]
               set dec [lindex $res 3]
               set equinox J2000
               set mura_masyr [lindex $res 6]
               set mudec_masyr [lindex $res 7]
               set epoch [expr ([lindex $res 10]+[lindex $res 11])/2.]
               set plx_mas 0
               set magb [lindex $res 13]
               set magv [lindex $res 14]
               set magr [lindex $res 14]
               if       {$filtre=="R"} { set mag $magr
               } elseif {$filtre=="B"} { set mag $magb
               } elseif {$filtre=="V"} { set mag $magv
               } else { set mag $magv
               }
               set l [list $ra $dec $mag $id $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
               #console::affiche_resultat "$l\n"
               lappend ls $l
            }
            if {$catalog=="gaia1"} {
               set id [lindex $res 0]
               set ra [lindex $res 2]
               set dec [lindex $res 4]
               set equinox J2000
               set mura_masyr [lindex $res 8]
               set mudec_masyr [lindex $res 10]
               set epoch [lindex $res 1]
               set plx_mas [lindex $res 6]
               set mag [lindex $res 16]
               set l [list $ra $dec $mag $id $equinox $epoch $mura_masyr $mudec_masyr $plx_mas]
               #console::affiche_resultat "$l\n"
               lappend ls $l
            }
            if {$mag>$magmax} {
               set magmax $mag
            }
         }
         set stars $ls
         # =========================================================================
         # on enleve les etoiles qui sont hors cadre de l'image
         # =========================================================================
         set ls ""
         foreach star $stars {
            #console::affiche_resultat "ETAPE 5.0 star = <${star}>\n"
            #tk_messageBox -message "ETAPE 5.0"
            lassign $star ra dec mag id equinox epoch mura_masyr mudec_masyr plx_mas
            #console::affiche_resultat "ETAPE 5.1 ra=$ra dec=$dec\n"
            set xy [wcs_radec2p $wcs $ra $dec]
            #console::affiche_resultat "ETAPE 5.2 xy=$xy\n"
            lassign $xy x y
            if {($x<0)||($x>$naxis1)||($y<0)||($y>$naxis2)} {
               continue
            }
            lappend ls $star
         }
         set nstarins [llength $ls]
         #tk_messageBox -message "ETAPE 6\nnstarins=$nstarins"
         if {$nstarins>=$nstarlim} {
            set sortie 1
         }
         if {($nstars>$nstarmin && $nstars==$nstar0s)} {
            set sortie 2
         }
         set mag_faint [expr $mag_faint + 1]
         set nstar0s $nstars
         #tk_messageBox -message "ETAPE 7"
         
      }
      
      # --- trie pes etoiles en brillance decroissante
      set stars [lsort -real -increasing -index 2 $ls]

      # =========================================================================
      # on construit une liste de type x y flux avec les etoiles du catalogue en magnitudes croissantes
      # =========================================================================
      set ls ""
      foreach star $stars {
         lassign $star ra dec mag id equinox epoch mura_masyr mudec_masyr plx_mas
         set xy [wcs_radec2p $wcs $ra $dec]
         lassign $xy x y
         if {($x<0)||($x>$naxis1)||($y<0)||($y>$naxis2)} {
            #::console::affiche_resultat "$x $y ==> OUT\n"
            continue
         }
         set flux [expr pow(10,-0.4*($mag-$magmax))]
         #::console::affiche_resultat "$x $y ==> mag=$mag magmax=$magmax flux=$flux\n"
         lappend ls [list $x $y $flux 2 [list $ra $dec] $id 0]
      }
      set cata0s [lsort -real -decreasing -index 2 $ls]
      #::console::affiche_resultat "Catalog {x y flux}:\n$cata0s\n"

   }

   return $cata0s

}

## @brief ??
#  @remark star0s et cata0s sont triés en flux décroissant
#  @param star0s ??
#  @param cata0s  ??
#  @param catatype { alpy600 | USNOA2 }
#  @param delta 1 par défaut
#  @param nmax  nombre d'étoiles en entrée, 50 par défut
#  @param flux_criterion
#  - 1 pour tenir compte de l'ordre des flux star et cata
#  - 0  par défaut
#  @return ???
#  @todo expliciter le brief, star0s et cata0s
#
proc focas_catastars2pairs { star0s cata0s catatype {delta 1.} {nmax 50} {flux_criterion 0} } {
   global audace

   set bufno $audace(bufNo)
   set naxis1 [buf$bufno getpixelswidth]
   set naxis2 [buf$bufno getpixelsheight]

   lassign $catatype type subtype
   if {$type=="alpy600"} {
      set dimension 1
   } else {
      set dimension 2
   }
   set verbose 0
   # --- trie en flux decroissant
   set star0s [lsort -decreasing -real -index 2 $star0s]
   set cata0s [lsort -decreasing -real -index 2 $cata0s]

   # =========================================================================
   # Calcule les deux listes de triplets
   # =========================================================================

   # --- on limite le nombre d'etoiles en entrée dans la liste
   set n $nmax
   set tlimite 1
   set catas [lrange $cata0s 0 [expr $n-1]]
   # --- on calcule les triplets et leur poids
   # --- on trie les triplets b/a croissants
   set triplet_catas [lsort -real -increasing -index 3 [focas_tools_compute_triplets $catas 5 $dimension]]
   set ntriplet_catas [llength $triplet_catas]
   set n0triplet_catas $ntriplet_catas
   if {$tlimite==1} {
      # --- on ne garde que les meilleurs triplets (= les plus grands poids)
      set nthreshold_w [expr round(0.4*$ntriplet_catas)]
      if {$nthreshold_w>10} {
         set triplet_ws [lsort -real -decreasing -index 5 $triplet_catas]
         set triplet_catas [lsort -real -increasing -index 3 [lrange $triplet_ws 0 $nthreshold_w]]
      }
   }
   set ntriplet_catas [llength $triplet_catas]

   # --- on limite le nombre d'etoiles en entrée dans la liste
   set stars [lrange $star0s 0 [expr $n-1]]
   # --- on calcule les triplets et leur poids
   # --- on trie les triplets b/a croissants
   set triplet_stars [lsort -real -increasing -index 3 [focas_tools_compute_triplets $stars 5 $dimension]]
   set ntriplet_stars [llength $triplet_stars]
   set n0triplet_stars $ntriplet_stars
   if {$tlimite==1} {
      # --- on ne garde que les meilleurs triplets (= les plus grands poids)
      set nthreshold_w [expr round(0.3*$ntriplet_stars)]
      if {$nthreshold_w>10} {
         set triplet_ws [lsort -real -decreasing -index 5 $triplet_stars]
         set triplet_stars [lsort -real -increasing -index 3 [lrange $triplet_ws 0 $nthreshold_w]]
      }
   }
   set ntriplet_stars [llength $triplet_stars]

   #::console::affiche_resultat "Nb objects: cata=[llength $catas] stars=[llength $stars]\n"
   #::console::affiche_resultat "Nb triplets avant elimination ambiguite: cata=$n0triplet_catas stars=$n0triplet_stars\n"
   #::console::affiche_resultat "Nb triplets apres elimination ambiguite: cata=$ntriplet_catas stars=$ntriplet_stars\n"

   set nstars [llength $stars]
   set ncatas [llength $catas]
   # -- cata_xcs sera utilisée par l'algo de dichotomie pour les quartets
   set cata_xcs [lsort -real -increasing -index 0 $catas]
   set xcmini [lindex [lindex $cata_xcs   0] 0]
   set xcmaxi [lindex [lindex $cata_xcs end] 0]
   set acc_xc0   [expr $xcmini-$delta]
   set acc_xcend [expr $xcmaxi+$delta]
   set acc_nc [expr int(ceil(($acc_xcend-$acc_xc0)/(1.*$delta)))]
   set k1 0
   set acc_xcs ""
   set acc_kcs ""
   set n [llength $cata_xcs]
   for {set ka 0} {$ka<[expr $acc_nc-1]} {incr ka} {
      #::console::affiche_resultat "============================\n"
      #::console::affiche_resultat "[lrange $cata_xcs 0 end]\n"
      #::console::affiche_resultat "----------------------------\n"
      set kadeb $ka
      set kafin [expr $ka+3]
      set xcdeb [expr $acc_xc0+1.*$kadeb*$delta]
      set xcfin [expr $acc_xc0+1.*$kafin*$delta]
      lappend acc_xcs [list $xcdeb $xcfin]
      set kcs ""
      for {set kc $k1} {$kc<$n} {incr kc} {
         set xxcc [lindex [lindex $cata_xcs $kc] 0]
         #::console::affiche_resultat "ka=$ka kc=$kc  xxcc = $xxcc\n"
         if {$xxcc<$xcdeb} {
            set k1 $kc
         } elseif {$xxcc<$xcfin} {
            lappend kcs $kc
            #::console::affiche_resultat "  $xcdeb <= $xxcc < $xcfin\n"
         } else {
            break
         }
      }
      lappend acc_kcs $kcs
      #::console::affiche_resultat "  ka=$ka kcs = $kcs\n"
      #if {$ka>4} {
      #   break
      #}
   }
   #::console::affiche_resultat "  acc_xcs = $acc_xcs\n"
   #::console::affiche_resultat "  acc_kcs = $acc_kcs\n"

   # -- valeur limite du nombre de quartets minimaux pour voter
   if {$nstars<$ncatas} {
      set nmini $nstars
   } else {
      set nmini $ncatas
   }
   if {$nmini<=3} {
      # --- cas de trois stars ou trois catas (il ne peut pas y avoir de quartet)
      set nquartet_lim -1
   } elseif {$nmini<=5} {
      set nquartet_lim 1
   } else {
      # --- limite empirique du nombre de quartets trouves pour avoir le droit de voter
      set nquartet_lim [expr int(ceil(sqrt($nmini)))]
      if {$nquartet_lim>10} {
         set nquartet_lim 10
      }
   }
   #set nquartet_lim 1

   # --- on complete les triplets pour les calculs de votes
   # on ajoute $bs $cs $bamins $bamaxs $camins $camaxs
   set res ""
   for {set kts 0} {$kts<$ntriplet_stars} {incr kts} {
      set triplet_star [lindex $triplet_stars $kts]
      lassign $triplet_star ks1 ks2 ks3 bas cas ws as
      set bs [expr $as*$bas]
      set bamins [expr 1.*($bs-$delta)/($as+$delta)]
      set bamaxs [expr 1.*($bs+$delta)/($as-$delta)]
      set cs [expr $as*$cas]
      set camins [expr 1.*($cs-$delta)/($as+$delta)]
      set camaxs [expr 1.*($cs+$delta)/($as-$delta)]
      set f1 [lindex [lindex $stars $ks1] 2]
      set f2 [lindex [lindex $stars $ks2] 2]
      set f3 [lindex [lindex $stars $ks3] 2]
      if {($f2>$f3)} {
         if {$f1>$f2} {
            set f 123
         } elseif {$f1>$f3} {
            set f 213
         } else {
            set f 231
         }
      } else {
         # --- f2<f3
         if {$f1<$f2} {
            set f 321
         } elseif {$f1<$f3} {
            set f 312
         } else {
            set f 132
         }
      }
      set fs $f
      lappend res [list $ks1 $ks2 $ks3 $bas $cas $ws $as $bs $cs $bamins $bamaxs $camins $camaxs $fs]
   }
   set triplet_stars $res
   set triplet_stars [lsort -real -increasing -index 10 $triplet_stars]
   set res ""
   for {set ktc 0} {$ktc<$ntriplet_catas} {incr ktc} {
      set triplet_cata [lindex $triplet_catas $ktc]
      lassign $triplet_cata kc1 kc2 kc3 bac cac wc ac
      set bc [expr $ac*$bac]
      set baminc [expr 1.*($bc-$delta)/($ac+$delta)]
      set bamaxc [expr 1.*($bc+$delta)/($ac-$delta)]
      set cc [expr $ac*$cac]
      set caminc [expr 1.*($cc-$delta)/($ac+$delta)]
      set camaxc [expr 1.*($cc+$delta)/($ac-$delta)]
      set f1 [lindex [lindex $catas $kc1] 2]
      set f2 [lindex [lindex $catas $kc2] 2]
      set f3 [lindex [lindex $catas $kc3] 2]
      if {($f2>$f3)} {
         if {$f1>$f2} {
            set f 123
         } elseif {$f1>$f3} {
            set f 213
         } else {
            set f 231
         }
      } else {
         # --- f2<f3
         if {$f1<$f2} {
            set f 321
         } elseif {$f1<$f3} {
            set f 312
         } else {
            set f 132
         }
      }
      set fc $f
      lappend res [list $kc1 $kc2 $kc3 $bac $cac $wc $ac $bc $cc $baminc $bamaxc $caminc $camaxc $fc]
   }
   set triplet_catas $res
   set triplet_catas [lsort -real -increasing -index 3 $triplet_catas]

   # =========================================================================
   # Calcule la matrice de votes
   # =========================================================================

   # --- on remplit la matrice des votes avec les etapes suivantes:
   # 1) Compatibilité (b/a) entre triplet star et cata
   # 2) Compatibilité d'ordre en flux pour les trois objets entre star et cata (optionnel avec flux_criterion=1)
   # 3) Compatibilité (c/a) entre triplet star et cata
   # 4) On calcule la transformation geometrique la plus probable
   # 5) On ajoute une quatrieme etoile au triplet star et on compte s'il y a une occurence dans cata en utilisant la transofmration geometrique.
   #    On scanne tous les objets de star pour tester ce critere de quatrieme etoile
   #    A la fin du scan on connait nquartet le nombre de quatriemes etoiles compatibles avec la transformation geométrique.
   # 6) On ne vote que si nquartet > limite statistique
   catch {unset votes}
   set sqrt2 [expr sqrt(2.)]
   set kappa $sqrt2
   set delta2 [expr $kappa*$kappa*$delta*$delta]
   set ktc1 0
   set ktc2 $ntriplet_catas
   set scalings ""
   set super_scalings ""
   set xs ""
   set kxs 1
   set transxs ""
   set transys ""
   for {set kts 0} {$kts<$ntriplet_stars} {incr kts} {
      #set kts 25
      set triplet_star [lindex $triplet_stars $kts]
      lassign $triplet_star ks1 ks2 ks3 bas cas ws as bs cs bamins bamaxs camins camaxs fs
      lassign [lindex $stars $ks1] xs1 ys1 fs1
      lassign [lindex $stars $ks2] xs2 ys2 fs2
      lassign [lindex $stars $ks3] xs3 ys3 fs3
      ### console::affiche_resultat "=== kts=$kts ktc1=$ktc1 ktc2=$ktc2\n"
      for {set ktc $ktc1} {$ktc<$ktc2} {incr ktc} {
         #set ktc 622
         set triplet_cata [lindex $triplet_catas $ktc]
         lassign $triplet_cata kc1 kc2 kc3 bac cac wc ac bc cc baminc bamaxc caminc camaxc fc
         if {$verbose>0} {
            ::console::affiche_resultat "  --------------------------- \n"
            ::console::affiche_resultat "  Triangle indexes : kts=$kts ktc=$ktc\n"
            ::console::affiche_resultat "   Object indexes : star =($ks1,$ks2,$ks3) cata=($kc1,$kc2,$kc3)\n"
            ::console::affiche_resultat "   Object star : $triplet_star\n"
            ::console::affiche_resultat "   Star coords : ($xs1,$ys2) ($xs2,$ys2) ($xs3,$ys3)\n"
            ::console::affiche_resultat "   Star flux : $fs1 $fs2 $fs3\n"
            ::console::affiche_resultat "   Star bas=$bas  cas=$cas as=$as\n"
            ::console::affiche_resultat "   Object cata : $triplet_cata\n"
            lassign [lindex $catas $kc1] xc1 yc1 fc1
            lassign [lindex $catas $kc2] xc2 yc2 fc2
            lassign [lindex $catas $kc3] xc3 yc3 fc3
            ::console::affiche_resultat "   Cata coords : ($xc1,$yc2) ($xc2,$yc2) ($xc3,$yc3)\n"
            ::console::affiche_resultat "   Cata flux : $fc1 $fc2 $fc3\n"
            ::console::affiche_resultat "   Cata bac=$bac  cac=$cac ac=$ac\n"
         }
         if {($bac<$bamins)} {
            set ktc1 $ktc
         } elseif {($bac<$bamaxs)} {
            # --- b/a sont compatibles
            lassign [lindex $catas $kc1] xc1 yc1 fc1
            lassign [lindex $catas $kc2] xc2 yc2 fc2
            lassign [lindex $catas $kc3] xc3 yc3 fc3
            # --- On exclut si l'ordre des flux des points n'est pas le bon
            if {($fs!=$fc)&&($flux_criterion==1)} {
               continue
            }
            if {($cac>=$camins)&&($cac<=$camaxs)} {
               # --- c/a sont compatibles
               #
               # --- on calcule la transformation geometrique entre les deux triplets
               # cata = scaling * star
               set x11 [lindex [lindex $stars $ks1] 0]
               set y11 [lindex [lindex $stars $ks1] 1]
               set x12 [lindex [lindex $stars $ks2] 0]
               set y12 [lindex [lindex $stars $ks2] 1]
               set x13 [lindex [lindex $stars $ks3] 0]
               set y13 [lindex [lindex $stars $ks3] 1]
               set x21 [lindex [lindex $catas $kc1] 0]
               set y21 [lindex [lindex $catas $kc1] 1]
               set x22 [lindex [lindex $catas $kc2] 0]
               set y22 [lindex [lindex $catas $kc2] 1]
               set x23 [lindex [lindex $catas $kc3] 0]
               set y23 [lindex [lindex $catas $kc3] 1]
               if {$dimension==1} {
                  set xy1s [list $x12 $x13 ]
                  set xy2s [list $x22 $x23 ]
                  set det_ab [focas_tools_linear_transform_2points $xy1s $xy2s]
                  lassign $det_ab det ab
                  lassign $ab a b
                  set scaling $a
                  set transx $b
                  set transy 0
               } else {
                  set xy1s [list [list $x11 $y11] [list $x12 $y12] [list $x13 $y13] ]
                  set xy2s [list [list $x21 $y21] [list $x22 $y22] [list $x23 $y23] ]
                  set det_abc_def [focas_tools_linear_transform_3points $xy1s $xy2s]
                  lassign $det_abc_def det abc def
                  lassign $abc a b c
                  lassign $def d e f
                  set scaling [expr sqrt(abs($a*$e-$b*$d))]
                  set transx $c
                  set transy $f
                  # --- Il ne semble pas necessaire d'exclure les transformations non orthogonales
                  # set norm_v1 [expr sqrt($a*$a+$b*$b)]
                  # set norm_v2 [expr sqrt($d*$d+$e*$e)]
                  # set prod_scal [expr $a*$d+$b*$e]
                  # set cosv12 [expr abs($prod_scal/($norm_v1*$norm_v2))]
               }
               # --- On ajoute une quatrieme etoile au triplet de stars
               # Il y a donc (nstars-3) etoiles (xxs,yys)
               # que l'on projete vers l'espace de catas (xxc,yyc).
               #
               set nquartet 0
               for {set kks 0} {$kks<$nstars} {incr kks} {
                  # --- on extrait (x,y)s d'une etoile hors triplet
                  if {($kks==$ks1)||($kks==$ks2)||($kks==$ks3)} {
                     continue
                  }
                  set star [lindex $stars $kks]
                  lassign $star xxs yys flux fwhm coords id flag
                  if {$dimension==1} {
                     set xxc [expr $a*$xxs+$b]
                     set yyc 1
                  } else {
                     set xxc [expr $a*$xxs+$b*$yys+$c]
                     set yyc [expr $d*$xxs+$e*$yys+$f]
                  }
                  # --- on scanne les objets de catas par l'accelerateur pour gagner du temps
                  set kkc [expr int((($xxc-$acc_xc0)/(1.*$delta)))]
                  set kkccs [lindex $acc_kcs $kkc]
                  #console::affiche_resultat "=== kks=$kks xxc=$xxc yyc=$yyc / kkccs=$kkccs\n"
                  foreach kkcc $kkccs {
                     set xxcc [lindex [lindex $cata_xcs $kkcc] 0]
                     set yycc [lindex [lindex $cata_xcs $kkcc] 1]
                     set dx [expr $xxc-$xxcc]
                     set dy [expr $yyc-$yycc]
                     set dr2 [expr $dx*$dx+$dy*$dy]
                     #console::affiche_resultat " kkcc=$kkcc ($xxcc,$yycc). dx=$dx dy=$dy dr2=$dr2\n"
                     if {$dr2<=$delta2} {
                        incr nquartet
                        break
                     }
                  }
                  #console::affiche_resultat " Algo-acc nquartet=$nquartet\n"
               }
               #if {$nquartet>0} {
               #   console::affiche_resultat "** kts=$kts TOTAL nquartet=$nquartet (nquartet_lim=$nquartet_lim)\n"
               #}
               #focas_tools_plot_points $stars $catas
               #focas_tools_plot_points_triangles $stars $catas $triplet_star $triplet_cata
               # focas_tools_plot_triplets $triplet_stars $triplet_catas
               # focas_tools_plot_triplets_triangles $triplet_star $triplet_cata
               #tk_messageBox -message "kts=$kts ktc=$ktc cac=$cas \nkc1=$kc1 kc2=$kc2 kc3=$kc3\nscaling=$scaling tx=$transx ty=$transy\nws=$ws nquartet=$nquartet"
               # --- On vote avec l'apariement des triplets $kts et $ktc
               if {$nquartet>=$nquartet_lim} {
                  # focas_tools_plot_points $stars $catas
                  # focas_tools_plot_points_triangles $stars $catas $triplet_star $triplet_cata
                  # focas_tools_plot_triplets $triplet_stars $triplet_catas
                  # focas_tools_plot_triplets_triangles $triplet_star $triplet_cata
                  # tk_messageBox -message "cac=$cas \nkc1=$kc1 kc2=$kc2 kc3=$kc3\nscaling=$scaling tx=$transx ty=$transy\nw=$w"
                  incr kxs
                  lappend xs $bas
                  lappend scalings $scaling
                  lappend super_scalings [list $scaling $nquartet]
                  lappend transxs $transx
                  lappend transys $transy
                  set w [format %.3f $ws]
                  lappend votes($ks1) [list $kc1 $w 0 $nquartet $scaling $transx $transy ]
                  lappend votes($ks2) [list $kc2 $w 0 $nquartet $scaling $transx $transy ]
                  lappend votes($ks3) [list $kc3 $w 0 $nquartet $scaling $transx $transy ]
               }
            }
         } else {
            #::console::affiche_resultat "   kts=$kts  ktc=$ktc (break)\n"
            break
         }
      }
   }
   set n [llength $scalings]
   #::console::affiche_resultat "($n) [lsort -index 1 -integer $super_scalings]\n"
   # plotxy::plot $xs $scalings
   set scalings [lsort -real $scalings]
   set scaling_median [lindex $scalings [expr $n/2]]
   set transxs [lsort -real $transxs]
   set transx_median [lindex $transxs [expr $n/2]]
   set transys [lsort -real $transys]
   set transy_median [lindex $transys [expr $n/2]]
   #::console::affiche_resultat "GEO median $scaling_median $transx_median $transy_median ($n)\n"
   # Ici on pourrait eliminer les triangles hors scaling_median et trans_median
   # dans le cas de champs denses (style voie lactee)
   # --- on compte les votes de chaque etoile en les pondérant avec le poids
   set names [lsort -integer -increasing [array names votes]]
   foreach name [lrange $names 0 end] {
      #::console::affiche_resultat "AVANT votes($name) = [lsort -real -decreasing -index 0 $votes($name)]\n"
      set wwtot 0
      set nntot 0
      foreach vote $votes($name) {
         lassign $vote kt w
         set wwtot [expr $wwtot+$w]
         incr nntot
      }
      if {$wwtot==0} { set wwtot 1. }
      set kt0 -1
      catch {unset ww}
      catch {unset nn}
      catch {unset nnquartet}
      foreach vote [lsort -integer -increasing -index 0 $votes($name)] {
         lassign $vote kt w nvote nquartet scaling transx transy
         #set w [expr $w/$wwtot]
         if {$kt!=$kt0} {
            set ww($kt) $w
            set nn($kt) 1
            set nnquartet($kt) 0
            set kt0 $kt
         } else {
            set ww($kt) [expr $ww($kt)+$w]
            incr nn($kt)
            incr nnquartet($kt) $nquartet
         }
      }
      catch {unset v}
      set wwnames [array names ww]
      set tot_quartet 0
      foreach wwname $wwnames {
         lappend v [list $wwname [format %.3f $ww($wwname)] $nn($wwname) $nnquartet($wwname) $scaling $transx $transy]
         set tot_quartet [expr $tot_quartet + $nnquartet($wwname)]
      }
      if {$tot_quartet>0} {
         set votes($name) [lsort -real -decreasing -index 1 $v]
         #::console::affiche_resultat "APRES votes($name) = $votes($name)\n"
      } else {
         unset votes($name)
      }
   }

   # =========================================================================
   # Calcule les appariements
   # =========================================================================
   set names [array names votes]
   set rlims [list 2. 1.5 1.]
   foreach rlim $rlims {
      set couples ""
      foreach name $names {
         lassign $votes($name) obj0 obj1
         lassign $obj0 obj0_k obj0_w obj0_n obj0_q
         lassign $obj1 obj1_k obj1_w obj1_n obj1_q
         if {$obj1_w==""} {
            set obj1_w 1e-10
         }
         if {$obj1_w==0} {
            set obj1_w 1e-10
         }
         set r [expr $obj0_w/$obj1_w]
         if {$r>$rlim} {
            #::console::affiche_resultat "couple ($name) = $obj0\n"
            lappend couples [list $name $obj0_k $obj0_w $obj0_n $obj0_q]
         }
      }
      if {[llength $couples]>=3} {
         break
      }
   }

   # --- enleve les doublons sur le cata
   #::console::affiche_resultat "couples = $couples\n"
   set couples [lsort -integer -decreasing -index 3 $couples]
   set dejapris ""
   set ls ""
   foreach couple $couples {
      set kcata [lindex $couple 1]
      set k [lsearch -integer $dejapris $kcata]
      if {$k==-1} {
         lappend dejapris $kcata
         lappend ls $couple
      }
   }
   set couples $ls
   set couplefulls ""
   #::console::affiche_resultat "==== [llength $couples] objets appariés:\n"
   set couplefull_header [list xs ys coordc idc xc yc fluxs fluxc ks kc totweight ntotvotes ntotquartet]
   foreach couple $couples {
      lassign $couple ks kc w totvote totquartet scaling transx transy]
      set star [lindex $stars $ks]
      lassign $star xs ys fluxs
      set cata [lindex $catas $kc]
      lassign $cata xc yc fluxc fwhm coordc idc flag
      set couplefull [list $xs $ys $coordc $idc $xc $yc $fluxs $fluxc $ks $kc $w $totvote $totquartet]
      lappend couplefulls $couplefull
   }
   # --- on trie selon nquartet descendant
   set couplefulls [lsort -real -decreasing -index 12 $couplefulls]
   foreach couplefull $couplefulls {
      #::console::affiche_resultat "Couple : $couplefull\n"
   }
   # -- calcule la meilleure transformation entre les trois meilleurs couples
   set best_transform ""
   # --- on calcule la transformation geometrique entre les deux triplets
   # cata = scaling * star
   if {(([llength $couplefulls]>=2)&&($dimension==1)) || (([llength $couplefulls]>=3)&&($dimension==2))} {
      set x11 [lindex [lindex $couplefulls 0] 0]
      set y11 [lindex [lindex $couplefulls 0] 1]
      set x12 [lindex [lindex $couplefulls 1] 0]
      set y12 [lindex [lindex $couplefulls 1] 1]
      set x13 [lindex [lindex $couplefulls 2] 0]
      set y13 [lindex [lindex $couplefulls 2] 1]
      set x21 [lindex [lindex $couplefulls 0] 4]
      set y21 [lindex [lindex $couplefulls 0] 5]
      set x22 [lindex [lindex $couplefulls 1] 4]
      set y22 [lindex [lindex $couplefulls 1] 5]
      set x23 [lindex [lindex $couplefulls 2] 4]
      set y23 [lindex [lindex $couplefulls 2] 5]
      if {$dimension==1} {
         set xy1s [list $x11 $x12 ]
         set xy2s [list $x21 $x22 ]
         set det_ab [focas_tools_linear_transform_2points $xy1s $xy2s]
         lassign $det_ab det ab
         set best_transform $ab
      } else {
         set xy1s [list [list $x11 $y11] [list $x12 $y12] [list $x13 $y13] ]
         set xy2s [list [list $x21 $y21] [list $x22 $y22] [list $x23 $y23] ]
         set det_abc_def [focas_tools_linear_transform_3points $xy1s $xy2s]
         lassign $det_abc_def det abc def
         lassign $abc a b c
         lassign $def d e f
         set best_transform [list $abc $def]
      }
   } else {
      if {$dimension==1} {
         set best_transform {1 0}
      } else {
         set best_transform {{1 0 0} {0 1 0}}
      }
   }
   # --
   return [list $couplefull_header $couplefulls $best_transform]

}

proc focas_imagedb2pairs { filename catatype catapath {delta 1.} {nmax 20} } {
   set star0s [focas_image2stars $filename $catatype]
   set cata0s [focas_db2catas $catatype $catapath]
   set couples [focas_catastars2pairs $star0s $cata0s $catatype $delta $nmax]
}

# relation coord_cata = poly ( coord_star )
proc focas_pairs2poly { pairs polydeg } {
   set xs ""
   set ys ""
   set coord1s ""
   set coord2s ""
   set couples [lsort -index 0 -real [lindex $pairs 1]]
   set nc [llength $couples]
   set dof [expr $nc-$polydeg-1]
   if {$dof<0} {
      set polydeg [expr $nc-1]
   }
   foreach couple $couples {
      lappend xs [lindex $couple 0]
      lappend ys [lindex $couple 1]
      lappend coord1s [lindex [lindex $couple 2] 0]
      lappend coord2s [lindex [lindex $couple 2] 1]
   }
   if {[lindex $coord2s 0]=={}} {
      set pixpics $xs
      set lambdapics $coord1s
      set polys [focas_tools_polyfit $pixpics $lambdapics $polydeg]
      set np [llength $polys]
      # === Calcul o-c de la calibration
      set dlambdapics ""
      set chi2 0.
      for {set k 0} {$k<[llength $lambdapics]} {incr k} {
         set pix [lindex $pixpics $k]
         set lambda [focas_tools_polyval $polys $pix]
         set dlambdapic [expr [lindex $lambdapics $k]-$lambda]
         lappend dlambdapics $dlambdapic
         set chi2 [expr $chi2+$dlambdapic*$dlambdapic]
      }
      set sigma [expr sqrt($chi2/([llength $lambdapics]-1))]
      set res [list $polydeg $polys $sigma $dlambdapics]
      #plotxy::plot $lambdapics $dlambdapics ob
      #plotxy::xlabel "Lambda (Angstroms)"
      #plotxy::ylabel "Lambda o-c (Angstroms)"
      #plotxy::title "sigma = [format %.2f $sigma] Angstroms"
   } else {
      set polys [lindex $pairs 2]
      set polydeg 1
      set sigma 0
      set dcoords { {0 0} {0 0} {0 0} }
      set res [list $polydeg $polys $sigma $dcoords]
      # --- fit 2D TODO
   }
   return $res
}


#
## @file photcal.tcl
#  @brief Utilitaire pour faire de la photométrie calibrée à partir de deux images filtrées
#  @pre Les images doivent etre calibrées en WCS
#  @author Alain KLOTZ
#  $Id: photcal.tcl 13599 2016-04-04 10:24:37Z rzachantke $
#  @todo traiter pour Doxygen
#

#  source $audace(rep_install)/gui/audace/photcal.tcl
#

# ----------------------------------------------------------------------------------------------
# MODE CALIBRATION AUTOMATIQUE
# On recherche les coefficients de transformation en analysant le flux des etoiles
# qui sont dans le catalogue Loneos.
# ----------------------------------------------------------------------------------------------
#
# Placer les images de la nuit dans un répertoire dédié (=répertoire par
# défaut de la configuration de AudeLA).
#
# photcal_selectfiles : pour selectionner les fichiers compatible avec l'analyse photometrique.
#
# photcal_matchfiles V R : Pour créer le fichier commun des etoiles présentes dans le catalogue Loneos.
#
# photcal_plotcom comVR : Pour visualiser les mesures extraites.
#
# photcal_fit comVR : Pour ajuster les parametres photometriques
#
# photcal_calibrate comVR 1
#
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_selectfiles *.fits.gz
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_matchfiles V R Loneos-*.fit
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_fit comVR
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_plotcom comVR
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_calibrate comVR
#
# # -> rep_images in C:/d/boninsegna
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_selectfiles *.fits.gz
#
# # -> analysis of the calibration fields observed over the night
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_matchfiles B V N3*.fit 0.5 loneos C:/d/boninsegna/loneos_nsv.phot
# photcal_plotcom comBV B
# photcal_plotcom comBV Z 1 3 10 15
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_fit comBV 10 15 0 0
# photcal_plotcom comBV Z 1 3 10 15
# # -> a file comBV.coefs contains photometric coefs
#
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_matchfiles B V nsv*.fit 0.5 none
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_calibrate comBV 1 10 15
#
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_generate comBV 1 loneos C:/d/boninsegna/loneos_BV.phot 10 15
#
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_merge C:/d/boninsegna/loneos_BV.phot C:/d/boninsegna/loneos_VR.phot

# ----------------------------------------------------------------------------------------------
# MODE CALIBRATION SEMI AUTOMATIQUE
# On recherche les coefficients de transformation en analysant le flux des etoiles
# qui sont dans le catalogue Loneos.
# ----------------------------------------------------------------------------------------------
#
# On utilise d'abord la fonction photcal_extract pour extraire un fichier d'etoiles
# communes aux deux images et puis on utilise photcal_match pour identifier
# les etoiles du catalogue Loneos. La fonction photcal_airmass permet de
# calculer les elevations de chaque etoile et photcal_coefs calcule les
# coefficients de la photometrie. Le fichier des etoiles observé est
# alors calibrée par photcal_calibration. On peut ensuite fabriquer
# un catalogue personnel au format Loneos avec photcal_generate.
#
# exemple sur le champ Loneos NSV5000:
# photcal_extract nsv5000-v1 nsv5000-r1 V R common1
# photcal_extract nsv5000-v2 nsv5000-r2 V R common2
# photcal_match loneos c:/d/grb110205a/dauban/loneos_nsv5000.phot common 1
# photcal_airmass common 1 {gps 6 E 43 670} calibration
# photcal_coefs calibration coefs
# photcal_calibration common 1 {gps 6 E 43 670} coefs
# photcal_generate common 1 loneos c:/d/grb110205a/dauban/loneos_grb.phot 11 16
#
#
# ----------------------------------------------------------------------------------------------
# MODE GENERATION DE SCENES D'OBSERVATION DE CHAMPS LONEOS
# .
# ----------------------------------------------------------------------------------------------
# photcal_scenes loneos c:/d/grb110205a/dauban/loneos.phot
#
# ----------------------------------------------------------------------------------------------
# MODE DIAGRAMME H-R
# .
# ----------------------------------------------------------------------------------------------
#
# On part de deux images faites deux couleurs d'un amas d'étoiles.
#
# photcal_extract imageV imageR V R comVR : Pour extraire un fichier d'etoiles communes.
#
# photcal_plot comVR : pour dessiner un diagramme couleur/magnitude et superposer un isochrone.
#
# ----------------------------------------------------------------------------------------------
# BIBLIOGRAPHY
# ----------------------------------------------------------------------------------------------
# Sextractor (Bertin, E. & Arnouts, S. 1996, Astronomy & Astrophysics
# Supplement 317, 393) is used to extract fluxes
# of stars. Using a R filter, sextractor gives flux_R
# (flux_V for a V filter). The conversion between
# fluxes and the magnitudes is given by the
# following equations:
#
# R = ZMAGR - 2.5 log(flux_R) + COEFR*(V-R) - KR*Airmass_R
# V = ZMAGV - 2.5 log(flux_V) + COEFV*(V-R) - KV*Airmass_V
#
# ZMAGR, ZMAGV, COEFR, COEFV, KR and KV are calculated
# with stars of known V and R magnitudes. To
# determine these coefficients, we used the Loneos catalogue
# published as "UBVRI photometry of faint field stars" (Skiff, 2007,
# Skiff, B.A, 2007 yCat.2277....0S, VizieR On-line
# Data Catalog: II/277). Loneos is based on
# Johnson-Cousins UBVRI photometry. As a consequence,
# The R I colors are calculated on the Cousins system.
# -----------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_nearest 12h 50d now
proc photcal_nearest { ra0 dec0 date {sepangle_max 5} {home ""} {catalog_format ""} {file_loneos ""} } {
   global audace
   if {$catalog_format==""} {
      set catalog_format loneos
   }
   if {$file_loneos==""} {
      set file_loneos $audace(rep_catalogues)/cataphotom/loneos.phot
   }
   if {$home==""} {
      set home $audace(posobs,observateur,gps)
   }
   set ra0  [mc_angle2deg $ra0]
   set dec0 [mc_angle2deg $dec0]
   set res [mc_radec2altaz $ra0 $dec0 $home $date]
   set az0 [lindex $res 0]
   set el0 [lindex $res 1]
   ::console::affiche_resultat "Elevation = [format %+5.2f $el0] deg\n"
   if {$catalog_format=="loneos"} {
      set fic "$file_loneos"
      set f [open $fic r]
      set lignes [split [read $f] \n]
      close $f
      set loneoss ""
      set nl [llength $lignes]
      for {set kl 0} {$kl<$nl} {incr kl} {
         set ligne [lindex $lignes $kl]
         set n [llength $ligne]
         if {$n<8} { continue }
         set ra  "[string range $ligne 19 28] h"
         set dec "[string range $ligne 31 39]"
         set ra [mc_angle2deg $ra]
         set dec [mc_angle2deg $dec]
         if {($ra==0)&&($dec==0)} {
            continue
         }
         set magv [expr [string range $ligne 56 60]]
         set magbv [string trim [string range $ligne 62 67]]
         set magub [string trim [string range $ligne 69 73]]
         set magvr [string trim [string range $ligne 76 81]]
         set magvi [string trim [string range $ligne 83 88]]
         if {[expr abs($dec-$dec0)]>$sepangle_max} {
            continue
         }
         set res [mc_radec2altaz $ra $dec $home $date]
         set az [lindex $res 0]
         set el [lindex $res 1]
         set sepangle [lindex [mc_sepangle $az0 $el0 $az $el] 0]
         if {$sepangle>$sepangle_max} {
            continue
         }
         lappend loneoss [list $sepangle $ligne]
      }
      set loneoss [lsort -index 0 -real $loneoss]
   }
   set fic "tmp.txt"
   set f [open $fic w]
   set k 0
   foreach loneos $loneoss {
      set sepangle [lindex $loneos 0]
      set ligne [lindex $loneos 1]
      puts $f $ligne
      ::console::affiche_resultat "$ligne\n"
      if {$sepangle>$sepangle_max} {
         break
      }
   }
   close $f

}

# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_calibrate comVR
proc photcal_calibrate { file_calibration nb_file_common {mag_inf ""} {mag_sup ""} } {
   global audace
   if {$mag_inf==""} {
      set mag_inf -99
   }
   if {$mag_sup==""} {
      set mag_sup 99
   }
   set home $audace(posobs,observateur,gps)
   set pathim $audace(rep_images)
   set generic_file_common $file_calibration
   set fic "$pathim/${file_calibration}.coefs"
   if {[file exists $fic]==0} {
      error "File $fic not found."
   }
   set f [open $fic r]
   set lignes [split [read $f] \n]
   close $f
   set k 0
   foreach ligne $lignes {
      set car [string range $ligne 0 0]
      if {$car=="#"} {
         continue
      }
      incr k
      set coef_col$k [lindex $ligne 0]
      set C$k        [lindex $ligne 1]
      set alpha$k    [lindex $ligne 3]
      set K$k        [lindex $ligne 5]
      set havefit 1
   }
   for {set kcom 1} {$kcom<=$nb_file_common} {incr kcom} {
      set ficc "$pathim/${generic_file_common}${kcom}.txt"
      if {[file exists $ficc]==0} {
         error "File $ficc not found."
      }
      set f [open $ficc r]
      set lignes [split [read $f] \n]
      close $f
      set nl [llength $lignes]
      set ligne [lindex $lignes 0]
      # --- B=66 V=86 R=82 I=73
      set col1 [lindex $ligne 6]
      set color1 [format %c [expr int($col1)]]
      set col2 [lindex $ligne 15]
      set color2 [format %c [expr int($col2)]]
      ::console::affiche_resultat "color1=$color1 color2=$color2\n"
      # ---
      set textes ""
      foreach ligne $lignes {
         if {[llength $ligne]<5} {
            continue
         }
         set magcat1 [lindex $ligne 9]
         set magcat2 [lindex $ligne 18]
         #::console::affiche_resultat "magcat1=$magcat1 magcat2=$magcat2 ($ligne)\n"
         set ra [lindex $ligne 0]
         set dec [lindex $ligne 1]
         set jd1 [lindex $ligne 2]
         set exposure1 [lindex $ligne 3]
         set res [mc_radec2altaz $ra $dec $home $jd1]
         set elev1 [lindex $res 1]
         set airmass1 [expr 1/sin(3.1416/180*$elev1)]
         set flux1 [lindex $ligne 7]
         set jd2 [lindex $ligne 11]
         set exposure2 [lindex $ligne 12]
         set res [mc_radec2altaz $ra $dec $home $jd2]
         set elev2 [lindex $res 1]
         set airmass2 [expr 1/sin(3.1416/180*$elev2)]
         set flux2 [lindex $ligne 16]
         #
         if {$flux1<=0} {
            continue
         }
         set A1 [expr $C1-2.5*log10($flux1)-$K1*$airmass1]
         if {$flux2<=0} {
            continue
         }
         set A2 [expr $C2-2.5*log10($flux2)-$K2*$airmass2]
         set deno [expr (1.-$alpha1)*(1.+$alpha2)+$alpha1*$alpha2]
         set mag1 [expr ($A1*(1.+$alpha2)-$A2*$alpha1) / $deno ]
         set mag2 [expr ($A1*$alpha2+$A2*(1.-$alpha1)) / $deno ]
         set mag12 [expr $mag1-$mag2]
         if {($mag1<$mag_inf)||($mag1>$mag_sup)} { set mag1 -99 }
         if {($mag2<$mag_inf)||($mag2>$mag_sup)} { set mag2 -99 }
         if {$mag12<-0.5} { set mag1 -99 ; set mag2 -99 }
         if {$mag12>3}    { set mag1 -99 ; set mag2 -99 }
         set texte ""
         append texte "[format %9.5f $ra] [format %+9.5f $dec]    "
         set star [lrange $ligne 2 9]
         append texte "$star [format %5.2f $mag1]     "
         set star [lrange $ligne 11 18]
         append texte "$star [format %5.2f $mag2]"
         append textes "$texte\n"
         incr nstar
      }
      # --- fichier resultat
      ::console::affiche_resultat "Update the file $ficc\n"
      set f [open ${ficc} w]
      puts -nonewline $f $textes
      close $f
   }
   return ""

}

# -------------------------------------------------------------------------------------------------
#
# Entrees :
# File created by photcal_matchfiles.
#
# Sorties:
# Graphical plot and coefficents
#
# Examples:
#
#
# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_fit comVR
proc photcal_fit { file_calibration {mag_inf ""} {mag_sup ""} {K1 ""} {K2 ""} } {
   global audace
   set pathim $audace(rep_images)
   set fic "$pathim/${file_calibration}.txt"
   set f [open $fic r]
   set lignes [split [read $f] \n]
   close $f
   if {$mag_inf==""} {
      set mag_inf -99
   }
   if {$mag_sup==""} {
      set mag_sup 99
   }
   set k 0
   foreach ligne $lignes {
      if {[llength $ligne]<5} {
         continue
      }
      set magcat1 [lindex $ligne 5]
      if {($magcat1<=$mag_inf)||($magcat1>=$mag_sup)} {
         continue
      }
      set airmass1 [lindex $ligne 1]
      set col1 [lindex $ligne 2]
      set flux1 [lindex $ligne 3]
      set dflux1 [lindex $ligne 4]
      set magcat1 [lindex $ligne 5]
      set airmass2 [lindex $ligne 7]
      set col2 [lindex $ligne 8]
      set flux2 [lindex $ligne 9]
      set dflux2 [lindex $ligne 10]
      set magcat2 [lindex $ligne 11]
      lappend airmass1s $airmass1
      lappend col1s $col1
      lappend flux1s $flux1
      lappend dflux1s $dflux1
      lappend magcat1s $magcat1
      lappend airmass2s $airmass2
      lappend col2s $col2
      lappend flux2s $flux2
      lappend dflux2s $dflux2
      lappend magcat2s $magcat2
      set color1 [format %c [expr int($col1)]]
      set color2 [format %c [expr int($col2)]]
      set cols "$col1 $col2"
      set colorindex "${color1}-${color2}"
      #
      incr k
   }
   set y1 ""
   set y2 ""
   set n $k
   if {$n<1} {
      error "Pas assez d'etoiles pour l'ajustement ($n etoiles)"
   }
   for {set k 0} {$k<$n} {incr k} {
      set airmass1 [lindex $airmass1s $k]
      set airmass2 [lindex $airmass2s $k]
      set magcat1 [lindex $magcat1s $k]
      set dmagcat1 0.05
      set magcat2 [lindex $magcat2s $k]
      set dmagcat2 0.05
      set flux1 [lindex $flux1s $k]
      set flux2 [lindex $flux2s $k]
      set y1k [expr $magcat1 + 2.5*log10( $flux1 )]
      if {($K1!="")&&($K2!="")} {
         set y1k [expr $y1k + $K1*($magcat1-$magcat2)]
         set x1k [list [expr $magcat1-$magcat2] 1]
      } else {
         set x1k [list [expr $magcat1-$magcat2] [expr -1*$airmass1] 1]
      }
      set w1k [expr 1./$dmagcat1/$dmagcat1]
      set y2k [expr $magcat2 + 2.5*log10( $flux2 )]
      if {($K1!="")&&($K2!="")} {
         set y2k [expr $y2k + $K2*($magcat1-$magcat2)]
         set x2k [list [expr $magcat1-$magcat2] 1]
      } else {
         set x2k [list [expr $magcat1-$magcat2] [expr -1*$airmass2] 1]
      }
      set w2k [expr 1./$dmagcat2/$dmagcat2]
      lappend y1 $y1k
      lappend X1 $x1k
      lappend w1 $w1k
      lappend y2 $y2k
      lappend X2 $x2k
      lappend w2 $w2k
   }
   # - calcul de l'ajustement
   set textes ""
   append textes "# ${color1} = ZMAG${color1} - 2.5 log(flux_${color1}) + COEF${color1}*(${color1}-${color2}) - K${color1}*Airmass_${color1}\n"
   append textes "# ${color2} = ZMAG${color2} - 2.5 log(flux_${color2}) + COEF${color2}*(${color1}-${color2}) - K${color2}*Airmass_${color2}\n"
   append textes "# Filter C d_C alpha d_alpha K d_K\n"
   append textes "# ----------------------------------------------\n"
   set k 0
   set fcolors [list [list 1 $color1] [list 2 $color2]]
   foreach fcolor $fcolors {
      set findex [lindex $fcolor 0]
      set color [lindex $fcolor 1]
      if {$findex==1} {
         set filter $color1
         set X $X1
         set y $y1
         set w $w1
      } else {
         set filter $color2
         set X $X2
         set y $y2
         set w $w2
      }
      set X [gsl_mtranspose [gsl_mtranspose $X]]
      set nl [lindex [gsl_mlength $X] 0]
      set nc [lindex [gsl_mlength $X] 1]
      set result [gsl_mfitmultilin $y $X $w]
      #::console::affiche_resultat "result=$result \n"
      set c     [lindex $result 0]
      set chi2  [lindex $result 1]
      set covar [lindex $result 2]
      # - extrait le resultat
      set alpha   [lindex $c 0]
      set d_alpha [expr sqrt([gsl_mindex $covar 1 1])]
      if {($K1!="")&&($K2!="")} {
         if {$k==0} {
            set K    $K1
         } else {
            set K    $K2
         }
         set d_K     0.0
         set C       [lindex $c 1]
         set d_C     [expr sqrt([gsl_mindex $covar 2 2])]
      } else {
         set K       [lindex $c 1]
         set d_K     [expr sqrt([gsl_mindex $covar 2 2])]
         set C       [lindex $c 2]
         set d_C     [expr sqrt([gsl_mindex $covar 3 3])]
      }
      set err [catch {format %.3f $C} msg]
      if {$err==1} { set C -99 }
      set err [catch {format %+.3f $alpha} msg]
      if {$err==1} { set alpha 0 }
      set err [catch {format %+.3f $K} msg]
      if {$err==1} { set K 0 }
      set msg [string first inf $C]
      if {$msg!=-1} { set C -99 }
      set msg [string first inf $alpha]
      if {$msg!=-1} { set alpha 0 }
      set msg [string first inf $K]
      if {$msg!=-1} { set K 0 }
      ::console::affiche_resultat "\n"
      #::console::affiche_resultat "<[lindex $cols $k]> $C $d_C $alpha $d_alpha $K $d_K\n"
      ::console::affiche_resultat "===== mag$filter = C$filter - 2.5*log10(flux${filter}/t${filter}) + alpha$filter *(${color1}-${color2}) - K$filter * Airmass\n"
      ::console::affiche_resultat "alpha$filter = [format %+.3f $alpha] +/- [format %.3f $d_alpha] \n"
      ::console::affiche_resultat "K$filter     = [format %.3f $K     ] +/- [format %.3f $d_K] \n"
      ::console::affiche_resultat "C$filter     = [format %.3f $C     ] +/- [format %.3f $d_C] \n"
      append textes "[lindex $cols $k] $C $d_C $alpha $d_alpha $K $d_K\n"
      incr k
   }
   ::console::affiche_resultat "\n"
   ::console::affiche_resultat "===== Results stored in file $pathim/${file_calibration}.coefs\n"
   set fic "$pathim/${file_calibration}.coefs"
   set f [open $fic w]
   puts -nonewline $f $textes
   close $f

}

# -------------------------------------------------------------------------------------------------
# proc photcal_plotcom plots the photometric measurements calculated by
# photcal_matchfiles. This allows to check the global tendency of
# parameters:
#
# X = Color index
# Y = catalogue magnitude + 2.5 *log10 ( integrated flux divided by exptime )
# Z = Airmass
#
# There are three plot categories :
#
# 1a) photcal_plotcom comBV B
# Plot x=X y=Z and dot size is proportional to Y(B).
#
# 1b) photcal_plotcom comBV V
# Plot x=X y=Z and dot size is proportional to Y(V).
#
# 2) photcal_plotcom comBV X 0 1
# Plot x=Z y=Y(B) and Y(V) only for data in the range 0<X<1
#
# 3) photcal_plotcom comBV Z 1 3
# Plot x=X y=Y(B) and Y(V) only for data in the range 1<Z<3
#
# Entrees :
# File created by photcal_matchfiles.
#
# Sorties:
# Graphical plot.
#
# Examples:
# photcal_plotcom comBV B
# photcal_plotcom comBV V
# photcal_plotcom comBV X 0 1
# photcal_plotcom comBV Z 1 3
# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_plotcom comVR Z 1 4 12 14
proc photcal_plotcom { file_calibration {axis_lim ""} {lim_inf ""} {lim_sup ""} {mag_inf ""} {mag_sup ""} } {
   global audace
   set pathim $audace(rep_images)
   set fic "$pathim/${file_calibration}.txt"
   #::console::affiche_resultat "Read the file $fic\n"
   if {[file size $fic]==0} {
      return ""
   }
   set f [open $fic r]
   set lignes [split [read $f] \n]
   close $f
   if {$mag_inf==""} {
      set mag_inf -99
   }
   if {$mag_sup==""} {
      set mag_sup 99
   }
   set k 0
   set y1min 1e15
   set y1max -1e15
   set y2min 1e15
   set y2max -1e15
   foreach ligne $lignes {
      if {[llength $ligne]<5} {
         continue
      }
      lappend airmass1s [lindex $ligne 1]
      lappend col1s [lindex $ligne 2]
      lappend flux1s [lindex $ligne 3]
      lappend dflux1s [lindex $ligne 4]
      lappend magcat1s [lindex $ligne 5]
      lappend airmass2s [lindex $ligne 7]
      lappend col2s [lindex $ligne 8]
      lappend flux2s [lindex $ligne 9]
      lappend dflux2s [lindex $ligne 10]
      lappend magcat2s [lindex $ligne 11]
      set color1 [format %c [expr int([lindex $ligne 2])]]
      set color2 [format %c [expr int([lindex $ligne 8])]]
      set colorindex "${color1}-${color2}"
      #
      lappend xs [expr [lindex $ligne 5]-[lindex $ligne 11]]
      set y1 [expr [lindex $magcat1s $k]+2.5*log10([lindex $flux1s $k])]
      lappend y1s $y1
      set y2 [expr [lindex $magcat2s $k]+2.5*log10([lindex $flux2s $k])]
      lappend y2s $y2
      lappend z1s [lindex $airmass1s $k]
      lappend z2s [lindex $airmass2s $k]
      lappend zs [expr ([lindex $airmass1s $k]+[lindex $airmass2s $k])/2.]
      incr k
   }
   set n $k
   if {$n>0} {
      if {$color1=="B"} { set c1 b }
      if {$color1=="V"} { set c1 g }
      if {$color1=="R"} { set c1 r }
      if {$color1=="I"} { set c1 m }
      if {$color2=="B"} { set c2 b }
      if {$color2=="V"} { set c2 g }
      if {$color2=="R"} { set c2 r }
      if {$color2=="I"} { set c2 m }
   } else {
      error "No data in the file $fic"
   }
   set fic "$pathim/${file_calibration}.coefs"
   set havefit 0
   set k 0
   if {[file exists $fic]==1} {
      set f [open $fic r]
      set lignes [split [read $f] \n]
      close $f
      foreach ligne $lignes {
         set car [string range $ligne 0 0]
         if {$car=="#"} {
            continue
         }
         incr k
         set coef_col$k [lindex $ligne 0]
         set C$k        [lindex $ligne 1]
         set alpha$k    [lindex $ligne 3]
         set K$k        [lindex $ligne 5]
         set havefit 1
      }
   }
   if {[info commands tk_*]==""} {
      return "No Tk"
   }
   if {$lim_inf==""} {
      catch {::plotxy::clf}
      set y [lsort -real $y1s]
      set y1min [lindex $y 1]
      set y1max [lindex $y end]
      set y [lsort -real $y2s]
      set y2min [lindex $y 1]
      set y2max [lindex $y end]
      #::console::affiche_resultat "y1min=$y1min y1max=$y1max\n"
      for {set k 0} {$k<$n} {incr k} {
         if {($axis_lim=="2")||($axis_lim==$color2)} {
            set y2 [lindex $y2s $k]
            set size [expr 2.+10.*($y2-$y2min)/($y2max-$y2min)]
            if {$size<1} { set size 2 }
            if {$size>12} { set size 12 }
            ::plotxy::plot [lindex $xs $k] [lindex $z2s $k] '.o${c2}' $size
            ::plotxy::hold on
            ::plotxy::title "All Y ( m + 2.5 * log10(flux) for filter $color2)"
         } else {
            set y1 [lindex $y1s $k]
            set size [expr 2.+10.*($y1-$y1min)/($y1max-$y1min)]
            if {$size<1} { set size 2 }
            if {$size>12} { set size 12 }
            #::console::affiche_resultat "y1=$y1 size=$size\n"
            ::plotxy::plot [lindex $xs $k] [lindex $z1s $k] '.o${c1}' $size
            ::plotxy::hold on
            ::plotxy::title "All Y ( m + 2.5 * log10(flux) for filter $color1)"
         }
      }
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::bgcolor #FFFFFF
      ::plotxy::xlabel "X ( Color index $colorindex )"
      ::plotxy::ylabel "Z ( Airmass )"
      ::plotxy::position {40 40 400 500}
      set res [::plotxy::axis]
      set res [lreplace $res 2 2 1.0]
      ::plotxy::axis $res
      if {$havefit==1} {
         set coef_col$k [lindex $ligne 0]
         set C$k        [lindex $ligne 1]
         set alpha$k    [lindex $ligne 3]
         set K$k        [lindex $ligne 5]
      }
   } elseif {$axis_lim=="Z"} {
      set kk 0
      for {set k 0} {$k<$n} {incr k} {
         set z1 [lindex $z1s $k]
         set z2 [lindex $z2s $k]
         #::console::affiche_resultat "z1=$z1 z2=$z2\n"
         if {($z1>=$lim_inf)&&($z1<=$lim_sup)} {
            set magcat1 [lindex $magcat1s $k]
            if {($magcat1<=$mag_inf)||($magcat1>=$mag_sup)} {
               continue
            }
            lappend xxs [lindex $xs $k]
            lappend yy1s [lindex $y1s $k]
            lappend yy2s [lindex $y2s $k]
            incr kk
         }
      }
      set nn $kk
      if {$nn>0} {
         catch {::plotxy::clf}
         ::plotxy::plot $xxs $yy1s '.o${c1}'
         ::plotxy::hold on
         ::plotxy::plot $xxs $yy2s '.o${c2}'
         ::plotxy::plotbackground #FFFFFF
         ::plotxy::bgcolor #FFFFFF
         ::plotxy::xlabel "X ( Color index $colorindex)"
         ::plotxy::ylabel "Y ( m + 2.5 * log10(flux) )"
         ::plotxy::title "Airmass range: $lim_inf - $lim_sup"
         ::plotxy::position {40 40 400 500}
         if {$havefit==1} {
            set axis [::plotxy::axis]
            set xmin [lindex $axis 0]
            set xmax [lindex $axis 1]
            set zmin $lim_inf
            set zmax $lim_sup
            set dz [expr ($zmax-$zmin)/1.]
            set dx [expr ($xmax-$xmin)/1.]
            for {set z $zmin} {$z<=$zmax} {set z [expr $z+$dz]} {
               set xfit ""
               set yfit ""
               for {set x $xmin} {$x<=$xmax} {set x [expr $x+$dx]} {
                  lappend xfit $x
                  lappend yfit [expr $C1+$alpha1*$x-$K1*$z]
               }
               ::plotxy::plot $xfit $yfit ":${c1}" 0
               set xfit ""
               set yfit ""
               for {set x $xmin} {$x<=$xmax} {set x [expr $x+$dx]} {
                  lappend xfit $x
                  lappend yfit [expr $C2+$alpha2*$x-$K2*$z]
               }
               ::plotxy::plot $xfit $yfit ":${c2}" 0
            }
         }
      }
   } elseif {$axis_lim=="X"} {
      set kk 0
      for {set k 0} {$k<$n} {incr k} {
         set magcat1 [lindex $magcat1s $k]
         if {($magcat1<=$mag_inf)||($magcat1>=$mag_sup)} {
            continue
         }
         set x [lindex $xs $k]
         if {($x>=$lim_inf)&&($x<=$lim_sup)} {
            set z1 [lindex $z1s $k]
            set z2 [lindex $z2s $k]
            lappend zz1s [lindex $z1s $k]
            lappend zz2s [lindex $z2s $k]
            lappend xxs [lindex $xs $k]
            lappend yy1s [lindex $y1s $k]
            lappend yy2s [lindex $y2s $k]
            incr kk
         }
      }
      set nn $kk
      if {$nn>0} {
         catch {::plotxy::clf}
         ::plotxy::plot $zz1s $yy1s '.o${c1}'
         ::plotxy::hold on
         ::plotxy::plot $zz2s $yy2s '.o${c2}'
         ::plotxy::plotbackground #FFFFFF
         ::plotxy::bgcolor #FFFFFF
         ::plotxy::xlabel "Z ( Airmass )"
         ::plotxy::ylabel "Y ( m + 2.5 * log10(flux) )"
         ::plotxy::title "Color index ($colorindex) range: $lim_inf to $lim_sup"
         ::plotxy::position {40 40 400 500}
         set res [::plotxy::axis]
         set res [lreplace $res 0 0 1.0]
         ::plotxy::axis $res
         if {$havefit==1} {
            set axis [::plotxy::axis]
            set zmin [lindex $axis 0]
            set zmax [lindex $axis 1]
            set xmin $lim_inf
            set xmax $lim_sup
            set dz [expr ($zmax-$zmin)/1.]
            set dx [expr ($xmax-$xmin)/1.]
            for {set x $xmin} {$x<=$xmax} {set x [expr $x+$dx]} {
               set zfit ""
               set yfit ""
               for {set z $zmin} {$z<=$zmax} {set z [expr $z+$dz]} {
                  lappend zfit $z
                  lappend yfit [expr $C1+$alpha1*$x-$K1*$z]
               }
               ::plotxy::plot $zfit $yfit ":${c1}" 0
               set zfit ""
               set yfit ""
               for {set z $zmin} {$z<=$zmax} {set z [expr $z+$dz]} {
                  lappend zfit $z
                  lappend yfit [expr $C2+$alpha2*$x-$K2*$z]
               }
               ::plotxy::plot $zfit $yfit ":${c2}" 0
            }
         }
      }
   }
   return ""
}

# -------------------------------------------------------------------------------------------------
# proc photcal_matchfiles performs the matching between files previously
# selected using photcal_selectfiles. Only two color filters will be
# processed. The two color filters must specified as parameters of the proc.
# First, stars are extracted using sextractor and a common file is created
# (a*.txt). When all common files are created, they are merged to form
# only one file which has the name com followed by the letters of the
# two filters (e.g. comBV.txt). This file can be visually analyzed using
# photcal_plotcom.
#
# Entrees :
# vignetting : Fraction of the usable image diagonal for photometry (1=all the image)
# Files created by photcal_selectfiles.
# Home location that is taken from the AudeLA configuration.
#
# Sorties:
# File com??.txt (where ?? are the two filter symbols).
#
# Examples:
# photcal_matchfiles V R
# photcal_matchfiles V R "" "" c:/d/grb110205a/dauban/loneos_nsv5000.phot
# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_matchfiles V R Loneos-*.fit
proc photcal_matchfiles { color1 color2 {dirfilter ""} {vignetting 0.5} {catalog_format ""} {file_loneos ""} } {
   global audace
   set bufno $audace(bufNo)
   set pathim $audace(rep_images)
   if {$dirfilter==""} {
      set dirfilter "photcal-*[buf$audace(bufNo) extension]"
   }
   set fichiers [lsort [glob -nocomplain "${pathim}/${dirfilter}"]]
   set nf [llength $fichiers]
   if {$nf==0} {
      error "No files of type ${pathim}/${dirfilter}"
   }
   if {$catalog_format==""} {
      set catalog_format loneos
   }
   if {$file_loneos==""} {
      set file_loneos $audace(rep_catalogues)/cataphotom/loneos.phot
   }
   ::console::affiche_resultat "$nf fichiers a analyser\n"
   set kk 0
   for {set kf1 0} {$kf1<$nf} {incr kf1} {
      set fichier1 [lindex $fichiers $kf1]
      set fic1 [file rootname [file tail $fichier1]]
      set k [string last - $fic1]
      set field1 [string range $fic1 0 [expr $k-1]]
      set filter1 [string range $fic1 [expr $k+1] end]
      set f1 ""
      if {$filter1==$color1} {
         set f1 1
      } elseif {$filter1==$color2} {
         set f1 2
      } else { continue }
      for {set kf2 [expr $kf1+1]} {$kf2<$nf} {incr kf2} {
         set fichier2 [lindex $fichiers $kf2]
         #::console::affiche_resultat "fichier2=$fichier2\n"
         set fic2 [file rootname [file tail $fichier2]]
         set k [string last - $fic2]
         set field2 [string range $fic2 0 [expr $k-1]]
         set filter2 [string range $fic2 [expr $k+1] end]
         if {$field2!=$field1} { break }
         if {$filter2==$color1} {
            set f2 1
         } elseif { $filter2==$color2} {
            set f2 2
         } else { continue }
         incr kk
         loadima $fichier1
         saveima com${color1}${color2}${kk}-${filter1}
         loadima $fichier2
         saveima com${color1}${color2}${kk}-${filter2}
         ::console::affiche_resultat "$field1 : com${color1}${color2}${kk}\n"
      }
   }
   set nn $kk
   for {set kk 1} {$kk<=$nn} {incr kk} {
      ::console::affiche_resultat "========================= com${color1}${color2}${kk}\n"
      photcal_extract com${color1}${color2}${kk}-${color1} com${color1}${color2}${kk}-${color2} ${color1} ${color2} com${color1}${color2}${kk} $vignetting
   }
   ::console::affiche_resultat "=========================\n"
   if {$catalog_format=="none"} {
      catch {photcal_match $catalog_format $file_loneos com${color1}${color2} $nn}
      return ""
   }
   photcal_match $catalog_format $file_loneos com${color1}${color2} $nn
   photcal_airmass com${color1}${color2} $nn $audace(posobs,observateur,gps) com${color1}${color2}
   photcal_plotcom com${color1}${color2}

}

# -------------------------------------------------------------------------------------------------
# proc photcal_selectfiles selects image files that contain photometric informations to
# determine photometric coefficients. This pros must be followed by photcal_matchfiles.
# That means the following FITS keywords are presents: DATE-OBS EXPOSURE
# Moreover, either the FITS keyword FILTER exists, either the filename
# contains a letter characteristic of one of a BVgRrIi filter.
#
# Entrees :
# dirfilter : directory filter for image files if not the default of AudeLA
#
# Sorties :
# Files copied with their name changed.
#
# Examples:
# photcal_selectfiles *.fits.gz
# photcal_selectfiles
# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_selectfiles *.fits.gz
proc photcal_selectfiles { {dirfilter ""} {vignetting 1} } {
   global audace
   set bufno $audace(bufNo)
   set pathim $audace(rep_images)
   if {$dirfilter==""} {
      set dirfilter "*[buf$audace(bufNo) extension]"
   }
   set fichiers [lsort [glob -nocomplain "${pathim}/${dirfilter}"]]
   set n [llength $fichiers]
   ::console::affiche_resultat "$n fichiers a analyser\n"
   set kb 0
   set kv 0
   set kr 0
   set ki 0
   foreach fichier $fichiers {
      loadima $fichier
      set fic [file rootname [file tail $fichier]]
      set filter [string trim [lindex [buf$bufno getkwd FILTER] 1]]
      if {$filter==""} {
         set ffic [string toupper $fic]
         set nfic [string length $ffic]
         set filter C
         for {set k [expr $nfic-1]} {$k>=0} {incr k -1} {
            set lettre [string index $ffic $k]
            if {$lettre=="B"} { set filter B ; break }
            if {$lettre=="V"} { set filter V ; break }
            if {$lettre=="G"} { set filter V ; break }
            if {$lettre=="R"} { set filter R ; break }
            if {$lettre=="I"} { set filter I ; break }
         }
         #::console::affiche_resultat "[string range $fic 0 [expr $k-1]]\n"
         set fic [string range $fic 0 [expr $k-1]]
         buf$bufno setkwd [list FILTER $filter string "" ""]
      }
      set exposure [lindex [buf$bufno getkwd EXPOSURE] 1]
      set dateobs [lindex [buf$bufno getkwd DATE-OBS] 1]
      set name [string trim [lindex [buf$bufno getkwd NAME] 1]]
      if {$name==""} { set name photcal-$fic }
      set azimut [lindex [buf$bufno getkwd GREN_AZ] 1]
      if {$azimut==""} { set azimut 0 }
      ::console::affiche_resultat "$fic $dateobs $exposure $filter\n"
      if {$filter=="B"} {
         set filter B
         incr kb
         set k $kb
      } elseif {($filter=="g")||($filter=="V")} {
         set filter V
         incr kv
         set k $kv
      } elseif {($filter=="r")||($filter=="R")} {
         set filter R
         incr kr
         set k $kr
      } elseif {($filter=="i")||($filter=="I")||($filter=="I2")} {
         set filter I
         incr ki
         set k $ki
      } else {
         continue
      }
      # --- Special Zadko
      #if {($azimut<174)||($azimut>187)} {
      #   continue
      #}
      set res [buf$bufno getkwd FILTER]
      set res [lreplace $res 1 1 $filter]
      buf$bufno setkwd $res
      set sname ${name}-${filter}
      saveima $sname
      ::console::affiche_resultat "=> $fic COPIED INTO $sname\n"
   }
}


# -------------------------------------------------------------------------------------------------
# proc photcal_calibration pour calculer les magnitudes dans un fichier texte d'etoiles en commun entre deux images
#
# Entrees :
# * file_calibration : Fichier texte des etoiles en commun (format COMMON)
# * file_coefs : Fichier texte des etoiles en commun (format COEF)
# -------------------------------------------------------------------------------------------------
proc photcal_calibration { generic_file_common nb_file_common home file_coefs} {
   global audace
   set pathim $audace(rep_images)
   # --- Lit le fichier des coefs
   set ficc "$pathim/${file_coefs}.txt"
   set f [open $ficc r]
   set lignecs [split [read $f] \n]
   close $f
   set nl [llength $lignecs]
   set ligne [lindex $lignecs 1]
   # --- B=66 V=86 R=82 I=73
   set col1 [lindex $ligne 0]
   set color1 [format %c [expr int($col1)]]
   set a1 [lindex $ligne 1]
   set cmag1 [lindex $ligne 2]
   set ligne [lindex $lignecs 2]
   set col2 [lindex $ligne 0]
   set color2 [format %c [expr int($col2)]]
   set a2 [lindex $ligne 1]
   set cmag2 [lindex $ligne 2]
   #::console::affiche_resultat "color1=$color1 color2=$color2\n"
   # --- Lit le fichier file_common
   set textes ""
   for {set kcom 1} {$kcom<=$nb_file_common} {incr kcom} {
      set ficc "$pathim/${generic_file_common}${kcom}.txt"
      set f [open $ficc r]
      set lignes [split [read $f] \n]
      close $f
      set nl [llength $lignes]
      set ligne [lindex $lignes 0]
      # --- B=66 V=86 R=82 I=73
      set col1 [lindex $ligne 6]
      set color1 [format %c [expr int($col1)]]
      set col2 [lindex $ligne 15]
      set color2 [format %c [expr int($col2)]]
      ::console::affiche_resultat "Image $kcom : color1=$color1 color2=$color2\n"
      # ---
      set textes ""
      foreach ligne $lignes {
         if {[llength $ligne]<5} {
            continue
         }
         set magcat1 [lindex $ligne 9]
         set magcat2 [lindex $ligne 18]
         #::console::affiche_resultat "magcat1=$magcat1 magcat2=$magcat2 ($ligne)\n"
         set ra [lindex $ligne 0]
         set dec [lindex $ligne 1]
         set jd1 [lindex $ligne 2]
         set exposure1 [lindex $ligne 3]
         set res [mc_radec2altaz $ra $dec $home $jd1]
         set elev1 [lindex $res 1]
         set airmass1 [expr 1/sin(3.1416/180*$elev1)]
         set flux1 [lindex $ligne 7]
         set mag01 [expr $cmag1-2.5*log10($flux1)]
         set jd2 [lindex $ligne 11]
         set exposure2 [lindex $ligne 12]
         set res [mc_radec2altaz $ra $dec $home $jd2]
         set elev2 [lindex $res 1]
         set airmass2 [expr 1/sin(3.1416/180*$elev2)]
         set flux2 [lindex $ligne 16]
         set mag02 [expr $cmag2-2.5*log10(abs($flux2))]
         #
         set mag1 $mag01
         set mag2 $mag02
         set mag12 [expr $mag1-$mag2]
         set texte "mag1=$mag1 mag2=$mag2 mag12=$mag12"
         #::console::affiche_resultat "$texte\n"
         #
         for {set kk 0} {$kk<5} {incr kk} {
            set mag12 [expr $mag1-$mag2]
            set mag1 [expr $mag01+$a1*$mag12]
            set mag2 [expr $mag02+$a2*$mag12]
            set texte "mag1=$mag1 mag2=$mag2 mag12=$mag12"
            #::console::affiche_resultat "$texte\n"
         }
         #::console::affiche_resultat "$texte ($ligne)\n"
         set texte ""
         append texte "[format %9.5f $ra] [format %+9.5f $dec]    "
         set star [lrange $ligne 2 9]
         append texte "$star [format %5.2f $mag1]     "
         set star [lrange $ligne 11 18]
         append texte "$star [format %5.2f $mag2]"
         append textes "$texte\n"
         incr nstar
      }
      # --- fichier resultat
      set ficc "$pathim/${generic_file_common}${kcom}.txt"
      ::console::affiche_resultat "Update the file $ficc\n"
      set f [open $ficc w]
      puts -nonewline $f $textes
      close $f
   }
}

# -------------------------------------------------------------------------------------------------
# proc photcal_coefs pour analyser les magnitudes Loneos dans un fichier texte d'etoiles en commun entre deux images
#
# Entrees :
# * file_calibration : Fichier texte des etoiles en commun (format CALIBRATION)
# * file_coefs : Fichier texte des etoiles en commun (format COEF)
# -------------------------------------------------------------------------------------------------
proc photcal_coefs { file_calibration file_coefs} {
   global audace
   set pathim $audace(rep_images)
   set fic "$pathim/${file_calibration}.txt"
   ::console::affiche_resultat "Read the file $fic\n"
   set f [open $fic r]
   set lignes [split [read $f] \n]
   close $f
   set k 0
   foreach ligne $lignes {
      if {[llength $ligne]<5} {
         continue
      }
      lappend airmass1s [lindex $ligne 1]
      lappend col1s [lindex $ligne 2]
      lappend flux1s [lindex $ligne 3]
      lappend dflux1s [lindex $ligne 4]
      lappend magcat1s [lindex $ligne 5]
      lappend airmass2s [lindex $ligne 7]
      lappend col2s [lindex $ligne 8]
      lappend flux2s [lindex $ligne 9]
      lappend dflux2s [lindex $ligne 10]
      lappend magcat2s [lindex $ligne 11]
      #
      lappend xs [expr [lindex $ligne 5]-[lindex $ligne 11]]
      lappend y1s [expr [lindex $magcat1s $k]+2.5*log10([lindex $flux1s $k])]
      lappend y2s [expr [lindex $magcat2s $k]+2.5*log10([lindex $flux2s $k])]
      incr k
   }
   set sx 0
   set sy1 0
   set sy2 0
   set sxy1 0
   set sxy2 0
   set sxx 0
   set n [llength $xs]
   for {set k 0} {$k<$n} {incr k} {
      set x [lindex $xs $k]
      set y1 [lindex $y1s $k]
      set y2 [lindex $y2s $k]
      set sx [expr $sx+$x]
      set sy1 [expr $sy1+$y1]
      set sy2 [expr $sy2+$y2]
      set sxx [expr $sxx+$x*$x]
      set sxy1 [expr $sxy1+$x*$y1]
      set sxy2 [expr $sxy2+$x*$y2]
   }
   set col1 [lindex $col1s 0]
   set a1 [expr ($n*$sxy1 - $sx*$sy1) / ($n*$sxx - $sx*$sx)]
   set cmag1 [expr ($sy1*$sxx - $sxy1*$sx) / ($n*$sxx - $sx*$sx)]
   set col2 [lindex $col2s 0]
   set a2 [expr ($n*$sxy2 - $sx*$sy2) / ($n*$sxx - $sx*$sx)]
   set cmag2 [expr ($sy2*$sxx - $sxy2*$sx) / ($n*$sxx - $sx*$sx)]
   ::console::affiche_resultat "col1=$col1 a1=$a1 cmag1=$cmag1\n"
   ::console::affiche_resultat "col2=$col2 a2=$a2 cmag2=$cmag2\n"
   set fic "$pathim/${file_coefs}.txt"
   set f [open $fic w]
   puts $f "# col a1 cmag"
   puts $f "$col1 $a1 $cmag1"
   puts $f "$col2 $a2 $cmag2"
   close $f
}

# -------------------------------------------------------------------------------------------------
# proc photcal_airmass pour analyser les magnitudes Loneos dans un fichier texte d'etoiles en commun entre deux images
#
# Entrees :
# * file_common : Fichier texte des etoiles en commun (format COMMON)
# * file_calibration : Fichier texte des etoiles en commun (format CALIBRATION)
# -------------------------------------------------------------------------------------------------
proc photcal_airmass { generic_file_common nb_file_common home file_calibration} {
   global audace
   # --- Lit le fichier file_common
   set pathim $audace(rep_images)
   set textes ""
   set xs ""
   set ys ""
   for {set kcom 1} {$kcom<=$nb_file_common} {incr kcom} {
      set ficc "$pathim/${generic_file_common}${kcom}.txt"
      set f [open $ficc r]
      set lignes [split [read $f] \n]
      close $f
      set nl [llength $lignes]
      set ligne [lindex $lignes 0]
      if {$ligne==""} {
         continue
      }
      # --- B=66 V=86 R=82 I=73
      set col1 [lindex $ligne 6]
      set color1 [format %c [expr int($col1)]]
      set col2 [lindex $ligne 15]
      set color2 [format %c [expr int($col2)]]
      ::console::affiche_resultat "color1=$color1 color2=$color2\n"
      # ---
      foreach ligne $lignes {
         if {[llength $ligne]<5} {
            continue
         }
         set magcat1 [lindex $ligne 9]
         set magcat2 [lindex $ligne 18]
         #::console::affiche_resultat "magcat1=$magcat1 magcat2=$magcat2 ($ligne)\n"
         if {($magcat1==-99)||($magcat2==-99)} {
            continue
         }
         set ra [lindex $ligne 0]
         set dec [lindex $ligne 1]
         set jd1 [lindex $ligne 2]
         set exposure1 [lindex $ligne 3]
         set res [mc_radec2altaz $ra $dec $home $jd1]
         set elev1 [lindex $res 1]
         set airmass1 [expr 1/sin(3.1416/180*$elev1)]
         set flux1 [lindex $ligne 7]
         set dflux1 [lindex $ligne 8]
         set jd2 [lindex $ligne 11]
         set exposure2 [lindex $ligne 12]
         set res [mc_radec2altaz $ra $dec $home $jd2]
         set elev2 [lindex $res 1]
         set airmass2 [expr 1/sin(3.1416/180*$elev2)]
         set flux2 [lindex $ligne 16]
         set dflux2 [lindex $ligne 17]
         set texte ""
         append texte "$jd1 $airmass1 $col1 $flux1 $dflux1 $magcat1 "
         append texte "$jd2 $airmass2 $col2 $flux2 $dflux2 $magcat2 "
         append textes "$texte\n"
         #::console::affiche_resultat "$texte\n"
         lappend xs [expr $magcat1-$magcat2]
         lappend ys $airmass1
      }
   }
   # --- fichier resultat
   set fic "$pathim/${file_calibration}.txt"
   ::console::affiche_resultat "Creates the file $fic\n"
   set f [open $fic w]
   puts -nonewline $f $textes
   close $f
}

# -------------------------------------------------------------------------------------------------
# proc photcal_scenes pour generer des scenes a partir du fichier catalogue Loneos
#
# Entree :
# * file_loneos : Fichier texte au format Loneos
# -------------------------------------------------------------------------------------------------
# source $audace(rep_install)/gui/audace/photcal.tcl ; photcal_scenes "" "" com
proc photcal_scenes { {catalog_format ""} {file_loneos ""} {simulation ""} } {
   global audace
   global ros
   set pathim $audace(rep_images)
   set pi [expr 4*atan(1)]
   if {$catalog_format==""} {
      set catalog_format loneos
   }
   if {$file_loneos==""} {
      set file_loneos $audace(rep_catalogues)/cataphotom/loneos.phot
   }
   if {[info commands ::audace::date_sys2ut]==""} {
      set have_audace 0
   } else {
      set have_audace 1
   }
   # --- Skylight computation
   if {$have_audace==1} {
      set date [::audace::date_sys2ut]
      set home $audace(posobs,observateur,gps)
   } else {
      set date now
      set home $ros(common,home)
   }
   set jd [mc_date2jd $date]
   set elev_sun_set 0
   set elev_sun_twilight -9
   set res [mc_nextnight $date $home $elev_sun_set $elev_sun_twilight]
   set mer2mer [lindex $res 0]
   set rise2rise [lindex $res 1]
   set prev_sun_rise [lindex $rise2rise 0]
   set mer [lindex $rise2rise 1]
   set sun_set [lindex $rise2rise 2]
   set dusk [lindex $rise2rise 3]
   set dawn [lindex $rise2rise 4]
   set next_sun_rise [lindex $rise2rise 5]
   if {$jd<$sun_set} {
      set skylight Day
   } elseif {$jd<$dusk} {
      set skylight Dusk
   } elseif {$jd<$dawn} {
      set skylight Night
   } else {
      set skylight Dawn
   }
   set sunelev [format %.4f [lindex [mc_ephem sun [list $jd] {ALTITUDE} -topo $home] 0]]
   if {$have_audace==1} {
      ::console::affiche_resultat "dusk=[mc_date2iso8601 $dusk] dawn=[mc_date2iso8601 $dawn]\n"
      ::console::affiche_resultat "skylight=$skylight sunelev=$sunelev\n"
   }
   set lst_dusk [mc_date2lst $dusk $home -format deg]
   set night_duration [expr ($dawn - $dusk)*24] ; # hours
   # -------------------------------------
   set latitude [lindex $home 3]
   set color1 V
   set color2 R
   if {$have_audace==1} {
      ::console::affiche_resultat "color1=$color1 color2=$color2\n"
   }
   if {$catalog_format=="loneos"} {
      set fic "$file_loneos"
      set f [open $fic r]
      set lignes [split [read $f] \n]
      close $f
      set loneoss ""
      set nl [llength $lignes]
      for {set kl 0} {$kl<$nl} {incr kl} {
         set ligne [lindex $lignes $kl]
         set n [llength $ligne]
         if {$n<8} { continue }
         set ra  "[string range $ligne 19 28] h"
         set dec "[string range $ligne 31 39]"
         set ra [mc_angle2deg $ra]
         set dec [mc_angle2deg $dec]
         if {($ra==0)&&($dec==0)} {
            continue
         }
         set magv [expr [string range $ligne 56 60]]
         set magbv [string trim [string range $ligne 62 67]]
         set magub [string trim [string range $ligne 69 73]]
         set magvr [string trim [string range $ligne 76 81]]
         set magvi [string trim [string range $ligne 83 88]]
         if {(($color1=="U")||($color2=="U"))} {
            if {($magub=="")||($magbv=="")} {
               continue
            } else {
               set magu [expr $magv+$magbv+$magub]
            }
         }
         if {(($color1=="B")||($color2=="B"))} {
            if {($magbv=="")} {
               continue
            } else {
               set magb [expr $magv+$magbv]
            }
         }
         if {(($color1=="R")||($color2=="R"))} {
            if {($magvr=="")} {
               continue
            } else {
               set magr [expr $magv-$magvr]
            }
         }
         if {(($color1=="I")||($color2=="I"))} {
            if {($magvi=="")} {
               continue
            } else {
               set err [catch {expr $magvi} msg]
               if {$err==1} {
                  continue
               }
               set magi [expr $magv-$magvi]
            }
         }
         # --- format : ra dec mag1 mag2
         set dec [expr $dec]
         # - limit for meridian
         if {$latitude<0} {
            set elevation 20
            set declim [expr 90.+$latitude-$elevation]
            if {$dec>$declim} { continue }
            if {$dec<$latitude} { continue }
         } else {
            set elevation 20
            set declim [expr -90.+$latitude+$elevation]
            if {$dec<$declim} { continue }
            if {$dec>$latitude} { continue }
         }
         set loneos "$ra $dec "
         if {$color1=="U"} { append loneos "$magu " }
         if {$color1=="B"} { append loneos "$magb " }
         if {$color1=="V"} { append loneos "$magv " }
         if {$color1=="R"} { append loneos "$magr " }
         if {$color1=="I"} { append loneos "$magi " }
         if {$color2=="U"} { append loneos "$magu " }
         if {$color2=="B"} { append loneos "$magb " }
         if {$color2=="V"} { append loneos "$magv " }
         if {$color2=="R"} { append loneos "$magr " }
         if {$color2=="I"} { append loneos "$magi " }
         # --- Special Zadko
         if {$latitude<0} {
            if {[lindex $loneos 2]<12} { continue }
            if {[lindex $loneos 3]<12} { continue }
         }
         # ---
         set colindex [expr [lindex $loneos 2]-[lindex $loneos 3]]
         append loneos "[format %+05.2f $colindex] "
         set ha_dusk [expr fmod( 720 + $lst_dusk - $ra , 360 )]
         set meridian [expr (360. - $ha_dusk)/15.] ; # meridian pass expressed in hours after the dusk date
         if {$meridian>$night_duration} {
            continue
         }
         set meridian [expr $meridian/24 + $dusk] ; # meridian pass expressed in UTC
         if {$latitude<0} {
            set elevation [expr 90.+$latitude-$dec] ; # northern meridian
         } else {
            set elevation [expr 90.-$latitude+$dec] ; # southern meridian
         }
         if {$elevation>90} {
            continue
         }
         set airmass [expr 1./sin($elevation*$pi/180)]
         append loneos "$meridian $airmass "
         #::console::affiche_resultat "loneos=$loneos\n"
         lappend loneoss $loneos
      }
   }
   set res [lsort -real -index 5 $loneoss]
   set loneoss ""
   foreach re $res {
      lappend loneoss $re
      #::console::affiche_resultat "loneos=$re\n"
   }
   # --- selectionne les etoiles en fonction de l'airmass et des indices de couleur
   set lim_airmasses {1 1.5 2 2.5 3}
   set dh 2.
   set na [expr [llength $lim_airmasses]-1]
   set kh 0
   set dra 0.00418098
   set ddec 0
   if {$have_audace==1} {
      set lieu ""
   } else {
      set lieu $ros(common,telescope_name)
   }
   set t 60
   # filter Zadko g=13 r=14 i=15 I=5 C=1
   set ksimu 0
   set sceness ""
   for {set h 0} {$h<$night_duration} {set h [expr $h+$dh]} {
      set h1 $h
      set h2 [expr $h+$dh]
      if {$have_audace==1} {
         ::console::affiche_resultat "==================== $h1<H<$h2 =============== \n"
      }
      set scenes ""
      for {set ka 0} {$ka<$na} {incr ka} {
         set a1 [lindex $lim_airmasses $ka]
         set a2 [lindex $lim_airmasses [expr $ka+1]]
         if {$have_audace==1} {
            ::console::affiche_resultat "--- $h1<H<$h2 $a1<Z<$a2 --- \n"
         }
         set subloneoss ""
         foreach lo $loneoss {
            set ra  [lindex $lo 0]
            set dec [lindex $lo 1]
            set mag1 [lindex $lo 2]
            set mag2 [lindex $lo 3]
            set mag12 [lindex $lo 4]
            set meridian [lindex $lo 5]
            set airmass [lindex $lo 6]
            set hh [expr ($meridian-$dusk)*24]
            if {($airmass>=$a1)&&($airmass<$a2)} {
               if {($hh>=$h1)&&($hh<$h2)} {
                  if {($mag1>12)&&($mag2>12)&&($mag1<16)&&($mag2<16)} {
                     if {($mag12>-1)&&($mag12<2)} {
                       lappend subloneoss $lo
                       #::console::affiche_resultat "lo=$lo\n"
                     }
                  }
               }
            }
         }
         set res [lsort -real -index 4 $subloneoss]
         set subloneoss ""
         foreach re $res {
            lappend subloneoss $re
            #::console::affiche_resultat "loneos=$re\n"
         }
         set n [llength $subloneoss]
         if {$n>=3} {
            set n1 1
            set n3 [expr $n-1]
            set n2 [expr ($n1+$n3)/2]
            set subloneos_blue [lindex $subloneoss $n1]
            set subloneos_green [lindex $subloneoss $n2]
            set subloneos_red [lindex $subloneoss $n3]
            if {$have_audace==1} {
               ::console::affiche_resultat "BLUE  : $subloneos_blue\n"
               ::console::affiche_resultat "GREEN : $subloneos_green\n"
               ::console::affiche_resultat "RED   : $subloneos_red\n"
            }
            #
            set sublos [list [list $subloneos_blue b] [list $subloneos_green g] [list $subloneos_red r]]
            foreach sublo $sublos {
               set lo [lindex $sublo 0]
               set ra  [lindex $lo 0]
               set dec [lindex $lo 1]
               set date0 [lindex $lo 5]
               set airmass [lindex $lo 6]
               set name Loneos-${kh}-${ka}-[lindex $sublo 1]
               set scene "\"$name\" $ra $dec $date0 $dra $ddec $t 13 $t 14 $t 15 0 0 0 0 0 0 0 $lieu"
               if {$simulation!=""} {
                  set ra1  [mc_angle2deg $ra]
                  set dec1 [mc_angle2deg $dec 90]
                  set exposure1 $t
                  set exposure2 $t
                  set dateobsjd1 [mc_date2jd $date0]
                  set dateobsjd2 [expr $dateobsjd1+$t/86400.]
                  #set elev1 [lindex [mc_radec2altaz $ra1 $dec1 $home $dateobsjd1] 1]
                  #set airmass1 [expr 1/sin(3.1416/180*$elev1)]
                  set airmass1 $airmass
                  set airmass2 $airmass1
                  set x1 1024
                  set y1 1024
                  set col1 86
                  set x2 1024
                  set y2 1024
                  set col2 82
                  set mag1 [lindex $lo 2]
                  set mag2 [lindex $lo 3]
                  set magcat $mag1
                  # === mag1 = cste1 - 2.5 * log10(flux1) + alpha1 * (mag1-mag2) - k1 * airmass1
                  # --- 2.5 * log10(flux1) = cste1 - mag1 + alpha1 * (mag1-mag2) - k1 * airmass1
                  # --- flux1 = pow( 10 , 0.4 * (cste1 - mag1 + alpha1 * (mag1-mag2) - k1 * airmass1) )
                  set cste1 21
                  set alpha1 0.2
                  set k1 0.6
                  set randn 0 ; for {set kp 0} {$kp<20} {incr kp} { set randn [expr $randn+rand()-0.5] }
                  #set randn 0
                  set flux1 [expr pow( 10 , 0.4 * ($cste1 - $mag1 + 0.03*$randn + $alpha1 * ($mag1-$mag2) - $k1 * $airmass1) )]
                  set fluxerr1 [expr sqrt($flux1*2.5)/2.5]
                  set cste2 22
                  set alpha2 0.3
                  set k2 0.2
                  set randn 0 ; for {set kp 0} {$kp<20} {incr kp} { set randn [expr $randn+rand()-0.5] }
                  #set randn 0
                  set flux2 [expr pow( 10 , 0.4 * ($cste2 - $mag2 + 0.03*$randn + $alpha2 * ($mag1-$mag2) - $k2 * $airmass2) )]
                  set fluxerr2 [expr sqrt($flux2*2.5)/2.5]
                  set texte ""
                  append texte "[format %9.5f $ra1] [format %+9.5f $dec1]"
                  append texte "   "
                  append texte "[format %15.6f $dateobsjd1] [format %e $exposure1] [format %7.2f $x1] [format %7.2f $y1] [format %2.0f $col1] [format %e $flux1] [format %e $fluxerr1] [format %5.2f $mag1] -99.00"
                  append texte "   "
                  append texte "[format %15.6f $dateobsjd2] [format %e $exposure2] [format %7.2f $x2] [format %7.2f $y2] [format %2.0f $col2] [format %e $flux2] [format %e $fluxerr2] [format %5.2f $mag2] -99.00"
                  incr ksimu
                  set f [open ${pathim}/${simulation}${color1}${color2}${ksimu}.txt w]
                  puts $f $texte
                  close $f
               }
               lappend scenes $scene
               lappend sceness $scene
            }
         }
      }
      if {$have_audace==1} {
         ::console::affiche_resultat "$scenes\n"
      }
      incr kh
   }
   if {$simulation!=""} {
      ::console::affiche_resultat "============ SIMULATION ===============\n"
      set nsimu $ksimu
      photcal_airmass com${color1}${color2} $nsimu $audace(posobs,observateur,gps) com${color1}${color2}
      for {set ksimu 1} {$ksimu<=$nsimu} {incr ksimu} {
         file delete ${pathim}/${simulation}${color1}${color2}${ksimu}.txt
      }
      photcal_plotcom com${color1}${color2}
   }
   if {$have_audace==1} {
      return ""
   } else {
      return $sceness
   }
}

# -------------------------------------------------------------------------------------------------
# proc photcal_match pour ajouter les magnitudes Loneos dans un fichier texte d'etoiles en commun entre deux images
#
# Entrees :
# * file_common : Fichier texte des etoiles en commun (format COMMON)
# * file_loneos : Fichier texte au format Loneos
# Name                  RA  (J2000)  Dec     s    GSC       V     B-V    U-B    V-R    V-I    bibcode              remarks
# NSV 5000           10 54 42.1  +63 02 40   h 4148-0380  12.83   0.70          0.36   0.78
#  123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
#           1         2         3         4         5         6         7         8         9
# -------------------------------------------------------------------------------------------------
proc photcal_match { catalog_format file_loneos generic_file_common nb_file_common } {
   global audace
   set bufno $audace(bufNo)
   # --- Lit le fichier file_common
   set pathim $audace(rep_images)
   for {set kcom 1} {$kcom<=$nb_file_common} {incr kcom} {
      set ficc "$pathim/${generic_file_common}${kcom}.txt"
      set f [open $ficc r]
      set lignecs [split [read $f] \n]
      close $f
      set nl [llength $lignecs]
      set ligne [lindex $lignecs 0]
      if {$ligne==""} {
         continue
      }
      # --- B=66 V=86 R=82 I=73
      set col1 [lindex $ligne 6]
      set color1 [format %c [expr int($col1)]]
      set col2 [lindex $ligne 15]
      set color2 [format %c [expr int($col2)]]
      ::console::affiche_resultat "color1=$color1 color2=$color2\n"
      # --- Lit le fichier file_loneos la premiere fois
      if {$kcom==1} {
         if {$catalog_format=="loneos"} {
            set fic "$file_loneos"
            set f [open $fic r]
            set lignes [split [read $f] \n]
            close $f
            set loneoss ""
            set nl [llength $lignes]
            for {set kl 0} {$kl<$nl} {incr kl} {
               set ligne [lindex $lignes $kl]
               set n [llength $ligne]
               if {$n<8} { continue }
               set ra  "[string range $ligne 19 28] h"
               set dec "[string range $ligne 31 39]"
               set ra [mc_angle2deg $ra]
               set dec [mc_angle2deg $dec]
               if {($ra==0)&&($dec==0)} {
                  continue
               }
               #::console::affiche_resultat "ra=$ra dec=$dec color1=$color1 color2=$color2\n"
               #::console::affiche_resultat "<[string range $ligne 56 60]>\n"
               set magv [expr [string range $ligne 56 60]]
               set magbv [string trim [string range $ligne 62 67]]
               set magub [string trim [string range $ligne 69 73]]
               set magvr [string trim [string range $ligne 76 81]]
               set magvi [string trim [string range $ligne 83 88]]
               if {(($color1=="U")||($color2=="U"))} {
                  if {($magub=="")||($magbv=="")} {
                     continue
                  } else {
                     set magu [expr $magv+$magbv+$magub]
                  }
               }
               if {(($color1=="B")||($color2=="B"))} {
                  if {($magbv=="")} {
                     continue
                  } else {
                     set magb [expr $magv+$magbv]
                  }
               }
               if {(($color1=="R")||($color2=="R"))} {
                  if {($magvr=="")} {
                     continue
                  } else {
                     set magr [expr $magv-$magvr]
                  }
               }
               if {(($color1=="I")||($color2=="I"))} {
                  if {($magvi=="")} {
                     continue
                  } else {
                     set err [catch {expr $magvi} msg]
                     if {$err==1} {
                        continue
                     }
                     set magi [expr $magv-$magvi]
                  }
               }
               # --- format : ra dec mag1 mag2
               set loneos "$ra $dec "
               if {$color1=="U"} { append loneos "$magu " }
               if {$color1=="B"} { append loneos "$magb " }
               if {$color1=="V"} { append loneos "$magv " }
               if {$color1=="R"} { append loneos "$magr " }
               if {$color1=="I"} { append loneos "$magi " }
               if {$color2=="U"} { append loneos "$magu " }
               if {$color2=="B"} { append loneos "$magb " }
               if {$color2=="V"} { append loneos "$magv " }
               if {$color2=="R"} { append loneos "$magr " }
               if {$color2=="I"} { append loneos "$magi " }
               #::console::affiche_resultat "loneos=$loneos\n"
               lappend loneoss [list [format %+08.5f $dec] $loneos]
            }
         }
         set res [lsort -real -index 0 $loneoss]
         set loneoss ""
         foreach re $res {
            lappend loneoss [lindex $re 1]
            #::console::affiche_resultat "loneos=[lindex $re 1]\n"
         }
      }
      # --- appariement avec le catalogue Loneos
      ::console::affiche_resultat "match stars with Loneos in $ficc\n"
      # --- Special Zadko
      set res [lindex [buf$bufno getkwd CDELT1] 1]
      set radius_over 1.5; # 1.5 pixel
      if {$res!=""} {
         set sepmax [expr 1.*abs($res*3600)*$radius_over] ; # conversion pixel en arcsec
      } else {
         set sepmax [expr 1.*$radius_over] ; # pixel direct
      }
      set stars ""
      set nstar 0
      set star2s $loneoss
      foreach star1 $lignecs {
         if {[llength $star1]<5} {
            continue
         }
         set ra1 [lindex $star1 0]
         set dec1 [lindex $star1 1]
         #::console::affiche_resultat "======\ra1=$ra1 dec1=$dec1\n"
         set kmatch -1
         set n [llength $star2s]
         for {set k 0} {$k<$n} {incr k} {
            set star2 [lindex $star2s $k]
            if {$star2==""} { continue }
            set ra2 [lindex $star2 0]
            set dec2 [lindex $star2 1]
            set ddec [expr ($dec2-$dec1)*3600.]
            if {$ddec<-$sepmax} {
               continue
            }
            if {$ddec>$sepmax} {
               break
            }
            #::console::affiche_resultat " ra2=$ra2 dec2=$dec2 ddec=$ddec\n"
            set dra [expr abs($ra2-$ra1)]
            if {$dra>180} {
               set dra [expr 360.-$dra]
            }
            set dra [expr $dra*3600.]
            if {$dra>$sepmax} {
               continue
            }
            set mag1 [lindex $star2 2]
            set mag2 [lindex $star2 3]
            set texte ""
            append texte "[format %9.5f $ra1] [format %+9.5f $dec1]    "
            set star [lrange $star1 2 8]
            append texte "$star $mag1 -99     "
            set star [lrange $star1 11 17]
            append texte "$star $mag2 -99"
            append stars "$texte\n"
            incr nstar
            #::console::affiche_resultat "[format %5d $nstar] ($dra $ddec): $texte\n"
            set kmatch $k
            break
         }
         if {$kmatch>=0} {
            set star2s [lreplace $star2s $kmatch $kmatch ""]
         } else {
            append stars "$star1\n"
         }
      }
      ::console::affiche_resultat "$nstar stars matched between Loneos and the star list\n"
      # --- update le fichier resultat
      set fic "$pathim/${generic_file_common}${kcom}.txt"
      ::console::affiche_resultat "Update the file $fic\n"
      set f [open $fic w]
      puts -nonewline $f $stars
      close $f
   }
}

# -------------------------------------------------------------------------------------------------
# proc photcal_extract pour extraire un fichier texte d'etoiles en commun entre deux images
#
# Entrees :
# * file_image_1 : Fichier FITS de l'image numero 1
# * file_image_2 : Fichier FITS de l'image numero 2
# * color1 : Symbole du filtre de l'image 1.
# * color2 : Symbole du filtre de l'image 2.
# * file_common : Fichier texte des etoiles en commun
#
# Sorties (file_common, format COMMON) :
# col0 : RA (deg)
# col1 : DEC (deg)
# col2 : DATE-OBS image 1 (JD)
# col3 : EXPOSURE image 1 (s)
# col4 : ASCII-FILTER image 1 (R=82, etc)
# col5 : FLUX image 1 (ADU/s)
# col6 : FLUXERR image 1 (ADU/s)
# col7 : MAGCAT image 1 (mag)
# col8 : MAGCAL image 1 (mag)
# col9 : DATE-OBS image 2 (JD)
# col10 : EXPOSURE image 2 (s)
# col11 : ASCII-FILTER image 2 (R=82, etc)
# col12 : FLUX image 2 (ADU/s)
# col13 : FLUXERR image 2 (ADU/s)
# col14 : MAGCAT image 2 (mag)
# col15 : MAGCAL image 2 (mag)
# -------------------------------------------------------------------------------------------------
proc photcal_extract { file_image_1 file_image_2 color1 color2 file_common {vignetting 1} } {
   global audace

   set radius_over 5.
   set bufno $audace(bufNo)
   # --- Verif images
   set pathim $audace(rep_images)
   set fic1 "$pathim/${file_image_1}.fit"
   loadima $fic1
   set exposure1 [lindex [buf$bufno getkwd EXPOSURE] 1]
   set dateobsjd1 [mc_date2jd [lindex [buf$bufno getkwd DATE-OBS] 1]]
   set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufno getkwd NAXIS2] 1]
   set filter $color1
   for {set k 0} {$k<256} {incr k} {
      set car [format %c $k]
      if {$car==$filter} {
         set col1 $k
      }
   }
   set fic2 "$pathim/${file_image_2}.fit"
   loadima $fic2
   set exposure2 [lindex [buf$bufno getkwd EXPOSURE] 1]
   set dateobsjd2 [mc_date2jd [lindex [buf$bufno getkwd DATE-OBS] 1]]
   set filter $color2
   for {set k 0} {$k<256} {incr k} {
      set car [format %c $k]
      if {$car==$filter} {
         set col2 $k
      }
   }
   # --- Sextractor
   set pathsex [pwd]
   ::console::affiche_resultat "sextractor $fic1\n"
   sextractor $fic1
   file copy -force -- "$pathsex/catalog.cat" "$pathsex/catalog1.txt"
   ::console::affiche_resultat "sextractor $fic2\n"
   sextractor $fic2
   file copy -force -- "$pathsex/catalog.cat" "$pathsex/catalog2.txt"
   # --- params
   ::console::affiche_resultat "analyze $pathsex/config.param\n"
   set f [open "$pathsex/config.param" r]
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
   ::console::affiche_resultat "indexes x=$kx y=$ky flux=$kflux fluxerr=$kfluxerr\n"
   # ---
   ::console::affiche_resultat "vignetting=$vignetting\n"
   ::console::affiche_resultat "analyze star list 1\n"
   loadima $fic1
   set err [catch {set radec [buf$bufno xy2radec [list 1 1]]} msg ]
   if {$err==0} {
      set wcs 1
      ::console::affiche_resultat "wcs keywords found\n"
   } else {
      set wcs 0
      error "wcs keywords not found"
   }
   set f [open "$pathsex/catalog1.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set t ""
   set stars ""
   set exposure $exposure1
   set vignetting2 [expr $vignetting*$vignetting]
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
      set radec [buf$bufno xy2radec [list $x $y]]
      set ra [lindex $radec 0]
      set dec [lindex $radec 1]
      set flux [expr [lindex $ligne $kflux]/$exposure]
      set fluxerr [expr [lindex $ligne $kfluxerr]/$exposure]
      lappend stars [list $x $y $ra $dec $flux $fluxerr]
   }
   set star1s [lsort -increasing -real -index 3 $stars]
   ::console::affiche_resultat "[llength $star1s] stars found in the list 1\n"
   # ---
   ::console::affiche_resultat "analyze star list 2\n"
   loadima $fic2
   set naxis1 [lindex [buf$bufno getkwd NAXIS1] 1]
   set naxis2 [lindex [buf$bufno getkwd NAXIS2] 1]
   set f [open "$pathsex/catalog2.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set t ""
   set stars ""
   set exposure $exposure2
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
      set radec [buf$bufno xy2radec [list $x $y]]
      set ra [lindex $radec 0]
      set dec [lindex $radec 1]
      set flux [expr [lindex $ligne $kflux]/$exposure]
      set fluxerr [expr [lindex $ligne $kfluxerr]/$exposure]
      lappend stars [list $x $y $ra $dec $flux $fluxerr]
   }
   set star2s [lsort -increasing -real -index 3 $stars]
   ::console::affiche_resultat "[llength $star2s] stars found in the list 2\n"
   # --- appariement
   ::console::affiche_resultat "match stars in the two lists\n"
   if {$wcs==1} {
      set res [lindex [buf$bufno getkwd CDELT1] 1]
      set sepmax [expr abs($res*3600)*$radius_over] ; # 1 pixel en arcsec
   } else {
      set sepmax [expr 1.*$radius_over] ; # 1 pixel
   }
   set stars ""
   set nstar 0
   set k1 0
   foreach star1 $star1s {
      set x1 [lindex $star1 0]
      set y1 [lindex $star1 1]
      set ra1 [lindex $star1 2]
      set dec1 [lindex $star1 3]
      set flux1 [lindex $star1 4]
      set fluxerr1 [lindex $star1 5]
      set kmatch -1
      #::console::affiche_resultat ">>>>>>>>> k1=$k1 flux1 = $flux1\n"
      set n [llength $star2s]
      for {set k 0} {$k<$n} {incr k} {
         set star2 [lindex $star2s $k]
         if {$star2==""} {
            continue
         }
         set x2 [lindex $star2 0]
         set y2 [lindex $star2 1]
         set ra2 [lindex $star2 2]
         set dec2 [lindex $star2 3]
         set flux2 [lindex $star2 4]
         set fluxerr2 [lindex $star2 5]
         set ddec [expr ($dec2-$dec1)*3600.]
         if {$ddec<-$sepmax} {
            #::console::affiche_resultat "k=$k ddec = $ddec<-$sepmax\n"
            continue
         }
         if {$ddec>$sepmax} {
            #::console::affiche_resultat "star2 = $star2\n"
            #::console::affiche_resultat "x1=$x1 y1=$y1 ra1=$ra1 dec1=$dec1\n"
            #::console::affiche_resultat "x2=$x2 y2=$y2 ra2=$ra2 dec2=$dec2\n"
            #::console::affiche_resultat "ddec = ($dec2-$dec1) = $ddec\n"
            #::console::affiche_resultat "sepmax=$sepmax\n"
            #::console::affiche_resultat "PAS DE MATCH pour k1=$k1 ddec = $ddec>$sepmax\n"
            break
         }
         set dra [expr abs($ra2-$ra1)]
         if {$dra>180} {
            set dra [expr 360.-$dra]
         }
         set dra [expr $dra*3600.]
         if {$dra>$sepmax} {
            continue
         }
         set flux1 [lindex $star1 4]
         set flux2 [lindex $star2 4]
         set texte ""
         append texte "[format %9.5f $ra1] [format %+9.5f $dec1]"
         append texte "   "
         append texte "[format %15.6f $dateobsjd1] [format %e $exposure1] [format %7.2f $x1] [format %7.2f $y1] [format %2.0f $col1] [format %e $flux1] [format %e $fluxerr1] -99.00 -99.00"
         append texte "   "
         append texte "[format %15.6f $dateobsjd2] [format %e $exposure2] [format %7.2f $x2] [format %7.2f $y2] [format %2.0f $col2] [format %e $flux2] [format %e $fluxerr2] -99.00 -99.00"
         append stars "$texte\n"
         incr nstar
         #::console::affiche_resultat "[format %5d $nstar] : [lrange $texte 0 1]\n"
         #::console::affiche_resultat "=== [format %5d $nstar] : $x1 $y1   $x2 $y2\n"
         set kmatch $k
         break
      }
      if {$kmatch>=0} {
         set star2s [lreplace $star2s $kmatch $kmatch ""]
      }
      incr k1
   }
   ::console::affiche_resultat "$nstar stars matched in the two lists\n"
   # --- sauve le fichier resultat
   set fic "$pathim/${file_common}.txt"
   ::console::affiche_resultat "save common star list in file $fic\n"
   set f [open $fic w]
   puts -nonewline $f $stars
   close $f
}


# -------------------------------------------------------------------------------------------------
# proc photcal_plot pour dessiner un diagramme couleur/magnitude et superposer un isochrone.
#
# Entrees :
# * fic_hr : nom du fichier ([pwd]/hr.txt par defaut) genere prealablement par la fonction photcal_extract
# col1 : RA (deg)
# col2 : DEC (deg)
# col3 : mag1
# col4 : mag2
# col5 : mag1-mag2
# * offmag1 : offset en magnitude pour effectuer une correction photometrique supplementaire
# * offmag2 : offset en magnitude pour effectuer une correction photometrique supplementaire
# * xaxis : fraction de points delimitant les bornes de visualisation sur l'axe des abscisses (0.95 par defaut).
# * color1 : Symbole du filtre de l'image 1 si l'on souhaite superposer un isochrone.
# * color2 : Symbole du filtre de l'image 1 si l'on souhaite effectuer une calibration photometrique par NOMAD1.
# * age : Age (annees) pour superposer l'isochrone correspondant ("" = pas d'isochrone superpose = par defaut).
# * dist_modulus : Module de distance (magnitudes) pour superposer un isochrone
# * v_extinction : Extinction dans la bande V pour superposer un isochrone
# * fic_isochrones : fichier qui contient les isochrones.
# -------------------------------------------------------------------------------------------------
proc photcal_plot { {fic_hr ""} {offmag1 0} {offmag2 0} {xaxis 0.95} {color1 V} {color2 R} {age ""} {dist_modulus 7} {v_extinction 0} {fic_isochrones ""} } {
   global audace

   set filters {B V R J H K}
   set pathim $audace(rep_images)
   if {$fic_hr==""} {
      set fic "$pathim/hr.txt"
   } else {
      set fic $fic_hr
   }
   ::console::affiche_resultat "load star list in file $fic\n"
   set f [open $fic r]
   set lignes [split [read $f] \n]
   close $f
   for {set ki 0} {$ki<=1} {incr ki} {
      set mag1s ""
      set mag2s ""
      set mag12s ""
      set n 0
      set nn 0
      set cmag1s ""
      set cmag2s ""
      set cmag 0
      if {[catch {expr $offmag1}]==1} { set offmag10 0 ; set cmag 1} else { set offmag10 $offmag1 }
      if {[catch {expr $offmag2}]==1} { set offmag20 0 ; set cmag 1} else { set offmag20 $offmag2 }
      set m [expr int(floor([llength $lignes]/20.))]
      foreach ligne $lignes {
         if {[lindex $ligne 0]==""} {
            continue
         }
         set ra   [lindex $ligne 0]
         set dec  [lindex $ligne 1]
         set mag1 [expr [lindex $ligne 2]+$offmag10]
         set mag2 [expr [lindex $ligne 3]+$offmag20]
         set mag12 [expr $mag1-$mag2]
         lappend mag1s $mag1
         lappend mag2s $mag2
         lappend mag12s $mag12
         incr n
         if {($nn>$m)&&($cmag==1)} {
            set star [vo_neareststar $ra $dec]
            set catara  [lindex $star 1]
            set catadec [lindex $star 2]
            set sepangle [expr 3600.*[lindex [mc_sepangle $ra $dec $catara $catadec] 0]]
            #::console::affiche_resultat "sepangle=$sepangle : $star\n"
            if {$sepangle>4.} {
               continue
            }
            set k [lsearch -regexp $filters $offmag1]
            if {$k<0} { continue }
            set catamag1 [lindex $star [expr 3+$k]]
            if {$catamag1=={}} { continue }
            set k [lsearch -regexp $filters $offmag2]
            if {$k<0} { continue }
            set catamag2 [lindex $star [expr 3+$k]]
            if {$catamag2=={}} { continue }
            set cmag1 [expr $catamag1-$mag1]
            lappend cmag1s $cmag1
            set cmag2 [expr $catamag2-$mag2]
            lappend cmag2s $cmag2
            set nn 0
            #::console::affiche_resultat "$cmag1 $cmag2 : $star\n"
         }
         incr nn
      }
      if {$cmag==1} {
         set nn [expr int(floor([llength $cmag1s]/2))]
         set cmag1s [lsort -real $cmag1s]
         set cmag2s [lsort -real $cmag2s]
         set offmag1 [lindex $cmag1s $nn]
         set offmag2 [lindex $cmag2s $nn]
         set cmag 0
         ::console::affiche_resultat "Zero mags : offmag1=$offmag1 offmag2=$offmag2\n"
      } else {
         break
      }
   }
   if {$n>10} {
      set n1 [expr int(floor((1.-$xaxis)*$n))]
      set n2 [expr int(floor($xaxis*$n))]
   } else {
      set n1 0
      set n2 $n
   }
   set res [lsort -real $mag12s]
   set x1 [lindex $res $n1]
   set x2 [lindex $res $n2]
   catch {::plotxy::clf}
   ::plotxy::plotbackground #FFFFFF
   ::plotxy::bgcolor #FFFFFF
   ::plotxy::plot $mag12s $mag1s r.
   ::plotxy::ydir reverse
   ::plotxy::xlabel "${color1}-${color2}"
   ::plotxy::ylabel "${color1}"
   set res [::plotxy::axis]
   set y1 [lindex $res 2]
   set y2 [lindex $res 3]
   ::plotxy::axis [list $x1 $x2 $y1 $y2]
   ::console::affiche_resultat "$n stars plotted\n"
   # ---- isochrones
   if {$age==""} {
      return ""
   }
   set logage [expr log10($age)]
   if {$fic_isochrones==""} {
      set fic_isochrones "$audace(rep_install)/gui/audace/catalogues/isochrones1.dat"
   }
   if {[file exists $fic_isochrones]==0} {
      ::console::affiche_resultat "File $fic_isochrones not found !!!\n"
      return ""
   }
   set f [open $fic_isochrones r]
   set lignes [split [read $f] \n]
   close $f
   # --- ages
   set ages ""
   set a0 ""
   foreach ligne $lignes {
      set car [string index $ligne 0]
      if {$car=="#"} {
         continue
      }
      set a [lindex $ligne 0]
      if {($a!=$a0)&&($a!="")} {
         lappend ages $a
      }
      set a0 $a
   }
   set ages [lsort -real $ages]
   set valmin 1e15
   foreach a $ages {
      set val [expr abs($logage-$a)]
      if {$val<$valmin} {
         set logage0 $a
         set valmin $val
      }
   }
   ::console::affiche_resultat "Log age selected is $logage0\n"
   # ----
   # Rieke & Lebosky 1985
   set extcoefs {1.531   1.324   1.0     0.748   0.482   0.282   0.175   0.112}
   set filters  {U       B       V       R       I       J       H       K}
   set k1 [lsearch -regexp $filters $color1]
   set k2 [lsearch -regexp $filters $color2]
   if {($k1<0)||($k2<0)} {
      return "No filter available !!!\n"
   }
   set iso1s ""
   set iso2s ""
   set iso12s ""
   foreach ligne $lignes {
      set car [string index $ligne 0]
      if {$car=="#"} {
         continue
      }
      set a [lindex $ligne 0]
      if {$a==$logage0} {
         set ext1 [lindex $extcoefs $k1]
         set ext2 [lindex $extcoefs $k2]
         set iso1 [expr [lindex $ligne [expr 6+$k1]]+$dist_modulus+$ext1*$v_extinction]
         set iso2 [expr [lindex $ligne [expr 6+$k2]]+$dist_modulus+$ext1*$v_extinction]
         set iso12 [expr $iso1-$iso2]
         lappend iso1s $iso1
         lappend iso2s $iso2
         lappend iso12s $iso12
      }
   }
   ::plotxy::hold on
   ::plotxy::plot $iso12s $iso1s b
   ::plotxy::plotbackground #FFFFFF
   ::plotxy::bgcolor #FFFFFF
   return ""
}

# -------------------------------------------------------------------------------------------------
# proc photcal_generate pour generer un catalog au format Loneos a partir d'un fichier texte d'etoiles calibrées en commun entre deux images
#
# Entrees :
# * file_common : Fichier texte des etoiles en commun (format COMMON)
# * file_loneos : Fichier texte au format Loneos
# Name                  RA  (J2000)  Dec     s    GSC       V     B-V    U-B    V-R    V-I    bibcode              remarks
# NSV 5000           10 54 42.1  +63 02 40   h 4148-0380  12.83   0.70          0.36   0.78
#  123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
#           1         2         3         4         5         6         7         8         9
# -------------------------------------------------------------------------------------------------
proc photcal_generate { generic_file_common nb_file_common catalog_format file_loneos {magvmin -10} {magvmax 50} } {
   global audace
   # --- Lit le fichier file_common
   set pathim $audace(rep_images)
   for {set kcom 1} {$kcom<=$nb_file_common} {incr kcom} {
      set ficc "$pathim/${generic_file_common}${kcom}.txt"
      set f [open $ficc r]
      set lignes [split [read $f] \n]
      close $f
      set nl [llength $lignes]
      set textes ""
      set kstar 0
      foreach ligne $lignes {
         if {[llength $ligne]<5} {
            continue
         }
         set ra [lindex $ligne 0]
         set dec [lindex $ligne 1]
         set magcat1 [lindex $ligne 9]
         set mag1 [lindex $ligne 10]
         set magcat2 [lindex $ligne 18]
         set mag2 [lindex $ligne 19]
         set col1 [lindex $ligne 6]
         set color1 [format %c [expr int($col1)]]
         set col2 [lindex $ligne 15]
         set color2 [format %c [expr int($col2)]]
         set mag12 [expr abs($mag1-$mag2)]
         if {$mag12>5} {
            continue
         }
         # --- B=66 V=86 R=82 I=73
         #::console::affiche_resultat "Image $kcom : color1=$color1 color2=$color2\n"
         set magu ""
         set magb ""
         set magv ""
         set magr ""
         set magi ""
         if {$col1==85} { set magu $mag1 }
         if {$col1==66} { set magb $mag1 }
         if {$col1==86} { set magv $mag1 }
         if {$col1==82} { set magr $mag1 }
         if {$col1==73} { set magi $mag1 }
         if {$col2==85} { set magu $mag2 }
         if {$col2==66} { set magb $mag2 }
         if {$col2==86} { set magv $mag2 }
         if {$col2==82} { set magr $mag2 }
         if {$col2==73} { set magi $mag2 }
         set magbv ""
         set magub ""
         set magvr ""
         set magvi ""
         if {($magb!="")&&($magv!="")} { set magbv [expr $magb-$magv] }
         if {($magu!="")&&($magb!="")} { set magub [expr $magu-$magb] }
         if {($magv!="")&&($magr!="")} { set magvr [expr $magv-$magr] }
         if {($magv!="")&&($magi!="")} { set magvi [expr $magv-$magi] }
         # ---
         #::console::affiche_resultat "magv=$magv catalog_format=$catalog_format\n"
         #::console::affiche_resultat "ligne=$ligne\n"
         if {$catalog_format=="loneos"} {
            if {$magv==""} {
               continue
            }
            if {$magv<$magvmin} {
               continue
            }
            if {$magv>$magvmax} {
               continue
            }
            set texte ""
            incr kstar
            set idstar "[string range ${generic_file_common} 0 10]-${kcom}-${kstar}                               "
            set idstar [string range $idstar 0 17]
            append texte "$idstar "
            set rahms [mc_angle2hms $ra]
            set rah [lindex $rahms 0]
            set ram [lindex $rahms 1]
            set ras [lindex $rahms 2]
            set rahms "[format %02d $rah] [format %02d $ram] [format %04.1f $ras]"
            append texte "$rahms  "
            set decdms [mc_angle2dms $dec 90]
            set decd [lindex $decdms 0]
            set decm [lindex $decdms 1]
            set decs [lindex $decdms 2]
            set decdms "[format %+03d $decd] [format %02d $decm] [format %02.0f $decs]"
            append texte "$decdms "
            append texte "              "
            append texte "[format %6.2f $magv] "
            if {$magbv==""} {
               append texte "       "
            } else {
               append texte "[format %6.2f $magbv] "
            }
            if {$magub==""} {
               append texte "       "
            } else {
               append texte "[format %6.2f $magub] "
            }
            if {$magvr==""} {
               append texte "       "
            } else {
               append texte "[format %6.2f $magvr] "
            }
            if {$magvi==""} {
               append texte "       "
            } else {
               append texte "[format %6.2f $magvi] "
            }
            append textes "${texte}\n"
         }
      }
      set ficc "$file_loneos"
      set f [open $ficc w]
      puts -nonewline $f $textes
      close $f
   }
}

# -------------------------------------------------------------------------------------------------
# proc photcal_merge pour fondre deux catalogues au format Loneos
#
# Entrees :
# * file_loneos1  : Fichier texte au format Loneos (en entree)
# * file_loneos2  : Fichier texte au format Loneos (en entree)
# * file_loneos12 : Fichier texte au format Loneos (en sortie)
# Name                  RA  (J2000)  Dec     s    GSC       V     B-V    U-B    V-R    V-I    bibcode              remarks
# NSV 5000           10 54 42.1  +63 02 40   h 4148-0380  12.83   0.70          0.36   0.78
#  123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
#           1         2         3         4         5         6         7         8         9
# -------------------------------------------------------------------------------------------------
proc photcal_merge { file_loneos1 file_loneos2 file_loneos12 } {
   global audace
   # --- Lit le fichier loneos1
   set f [open $file_loneos1 r]
   set ligne1s [split [read $f] \n]
   close $f
   # --- Lit le fichier loneos2
   set f [open $file_loneos2 r]
   set ligne2s [split [read $f] \n]
   close $f
   # ---
   foreach ligne1 $ligne1s {
      set texte ""
      set ligne $ligne1
      if {[llength $ligne1]<8} {
         continue
      }
      set id1 "[string range $ligne  0 17]"
      set ra  "[string range $ligne 19 28] h"
      set dec "[string range $ligne 31 39]"
      set ra1 [mc_angle2deg $ra]
      set dec1 [mc_angle2deg $dec]
      if {($ra1==0)&&($dec1==0)} {
         continue
      }
      set magv1 [expr [string range $ligne 56 60]]
      set magbv1 [string trim [string range $ligne 62 67]]
      set magub1 [string trim [string range $ligne 69 73]]
      set magvr1 [string trim [string range $ligne 76 81]]
      set magvi1 [string trim [string range $ligne 83 88]]
      foreach ligne2 $ligne2s {
         set ligne $ligne2
         if {[llength $ligne]<8} {
            continue
         }
         set ra  "[string range $ligne 19 28] h"
         set dec "[string range $ligne 31 39]"
         set ra2 [mc_angle2deg $ra]
         set dec2 [mc_angle2deg $dec]
         if {($ra2==0)&&($dec2==0)} {
            continue
         }
         set magv2 [expr [string range $ligne 56 60]]
         set magbv2 [string trim [string range $ligne 62 67]]
         set magub2 [string trim [string range $ligne 69 73]]
         set magvr2 [string trim [string range $ligne 76 81]]
         set magvi2 [string trim [string range $ligne 83 88]]
         set sepangle [lindex [mc_sepangle $ra1 $dec1 $ra2 $dec2] 0]
         set sepsec [expr $sepangle*3600]
         if {$sepsec<2} {
            # --- etoile en commun
            incr kstar
            set idstar "$id1"
            set idstar [string range $idstar 0 17]
            append texte "$idstar "
            set rahms [mc_angle2hms $ra1]
            set rah [lindex $rahms 0]
            set ram [lindex $rahms 1]
            set ras [lindex $rahms 2]
            set rahms "[format %02d $rah] [format %02d $ram] [format %04.1f $ras]"
            append texte "$rahms  "
            set decdms [mc_angle2dms $dec1 90]
            set decd [lindex $decdms 0]
            set decm [lindex $decdms 1]
            set decs [lindex $decdms 2]
            set decdms "[format %+03d $decd] [format %02d $decm] [format %02.0f $decs]"
            append texte "$decdms "
            append texte "              "
            set magv [expr ($magv1+$magv2)/2.]
            append texte "[format %6.2f $magv] "
            if {$magbv1!=""} {
               append texte "[format %6.2f $magbv1] "
            } elseif {$magbv2!=""} {
               append texte "[format %6.2f $magbv2] "
            } else {
               append texte "       "
            }
            if {$magub1!=""} {
               append texte "[format %6.2f $magub1] "
            } elseif {$magub2!=""} {
               append texte "[format %6.2f $magub2] "
            } else {
               append texte "       "
            }
            if {$magvr1!=""} {
               append texte "[format %6.2f $magvr1] "
            } elseif {$magvr2!=""} {
               append texte "[format %6.2f $magvr2] "
            } else {
               append texte "       "
            }
            if {$magvi1!=""} {
               append texte "[format %6.2f $magvi1] "
            } elseif {$magvi2!=""} {
               append texte "[format %6.2f $magvi2] "
            } else {
               append texte "       "
            }
            append textes "${texte}\n"
         }
      }
   }
   set f [open $file_loneos12 w]
   puts -nonewline $f $textes
   close $f
}

# Name                  RA  (J2000)  Dec     s    GSC       V     B-V    U-B    V-R    V-I    bibcode              remarks
# NSV 5000           10 54 42.1  +63 02 40   h 4148-0380  12.83   0.70          0.36   0.78
#  123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789
#           1         2         3         4         5         6         7         8         9

# source $audace(rep_install)/gui/audace/photcal.tcl ; abell_insert
proc abell_insert { {dirfilter ""} } {
   global audace
   set bufno $audace(bufNo)
   set pathim $audace(rep_images)
   if {$dirfilter==""} {
      set dirfilter "*.fits.gz"
   }
   ::console::affiche_resultat "Exploration de ${pathim}/${dirfilter}\n"
   set fichiers [lsort [glob -nocomplain "${pathim}/${dirfilter}"]]
   set n [llength $fichiers]
   ::console::affiche_resultat "$n fichiers a explorer\n"
   set numeros ""
   set date0 2005-03-21T00:00:00
   if {$n>0} {
      set fichier [lindex $fichiers 0]
      loadima $fichier
      set obslong [lindex [buf$bufno getkwd OBS-LONG] 1]
      if {$obslong<0} {
         set sens W
         set obslong [expr -$obslong]
      } else {
         set sens E
      }
      set obslat [lindex [buf$bufno getkwd OBS-LAT] 1]
      set obselev [lindex [buf$bufno getkwd OBS-ELEV] 1]
      set home [list GPS $obslong $sens $obslat $obselev]
      ::console::affiche_resultat "home=$home\n"
      set res [mc_nextnight $date0 $home]
      set jd0 [lindex [lindex $res 0] 0]
      foreach fichier $fichiers {
         buf$bufno load $fichier
         set fic [file rootname [file rootname [file tail $fichier]]]
         set jd [mc_date2jd [lindex [buf$bufno getkwd DATE-OBS] 1]]
         set djd [mc_date2iso8601 [expr floor($jd0)+0.5+int(floor($jd-$jd0))]]
         set djd [string range $djd 0 3][string range $djd 5 6][string range $djd 8 9]
         set catastar [lindex [buf$bufno getkwd CATASTAR] 1]
         set name [lindex [buf$bufno getkwd NAME] 1]
         set idname [string range $name 0 5]
         ::console::affiche_resultat "$fic => $name\n"
         if {$idname=="Abell_"} {
            set k [string first _ $name]
            set numero [string range $name [expr $k+1] end]
            file mkdir "${pathim}/../../${numero}"
            set ficout "${pathim}/../../${numero}/${fic}.fit"
            if {[file exists $ficout]==1} {
               file delete -force -- $fichier
               ::console::affiche_resultat "=> $fic EVER MOVED IN ${numero}\n"
               continue
            }
            if {[lsearch -exact $numeros $numero]==-1} {
               lappend numeros $numero
            }
            saveima $ficout
            file delete -force -- $fichier
            ::console::affiche_resultat "=> $fic MOVED INTO ${numero}\n"
            set f [open "${pathim}/../../${numero}/jds.txt" a]
            puts $f "$jd $djd $catastar $fic"
            close $f
         }
      }
   }
   if {$numeros==""} {
      set fichiers [lsort [glob -nocomplain "${pathim}/../../*"]]
      #set fichiers [lsort [glob -nocomplain "${pathim}/../../1080"]]
   } else {
      set fichiers ""
      foreach numero $numeros {
         lappend fichiers "${pathim}/../../$numero"
      }
   }
   foreach fichier $fichiers {
      if {[file isdirectory $fichier]==0} {
         continue
      }
      set numero [file tail $fichier]
      set err [catch {expr $numero} msg]
      if {$err==1} { continue }
      ::console::affiche_resultat "Exploration de Abell $numero\n"
      set f [open "${pathim}/../../${numero}/jds.txt" r]
      set lignes [split [read $f] \n]
      close $f
      set lignes [lrange $lignes 0 end-1]
      set lignes [lsort -index 2 -real $lignes]
      set n [llength $lignes]
      set n2 [expr $n/2]
      set med [lindex [lindex $lignes $n2] 2]
      #::console::affiche_resultat "med=$med\n"
      set catastarlim [expr $med*0.7]
      set ls ""
      foreach ligne $lignes {
         set catastar [lindex $ligne 2]
         if {$catastar<$catastarlim} {
            continue
         }
         lappend ls $ligne
      }
      set lignes $ls
      set n [llength $lignes]
      set lignes [lsort -index 1 -real $lignes]
      set dates ""
      foreach ligne $lignes {
         set date [lindex $ligne 1]
         lappend dates $date
      }
      set n [llength $dates]
      set d0 [lindex $dates 0]
      set ds $d0
      for {set k 1} {$k<$n} {incr k} {
         set d [lindex $dates $k]
         if {$d!=$d0} {
            lappend ds $d
            set d0 $d
         }
      }
      set dates $ds
      ::console::affiche_resultat "dates=$dates\n"
      foreach date $dates {
         set ficout "${pathim}/../../${numero}/abell${numero}-${date}.fit"
         if {[file exists $ficout]==1} {
            ::console::affiche_resultat "abell${numero}-${date}.fit ever exists.\n"
            continue
         }
         set ligs ""
         foreach ligne $lignes {
            set d [lindex $ligne 1]
            if {$d==$date} {
               lappend ligs $ligne
            }
         }
         set k 0
         foreach lig $ligs {
            incr k
            set fic [lindex $lig 3]
            set ficout "${pathim}/../../${numero}/${fic}.fit"
            set ficin "${pathim}/i${k}.fit"
            #::console::affiche_resultat "A ficout=$ficout\n"
            file copy -force -- $ficout $ficin
         }
         set n $k
         ::console::affiche_resultat "registerwcs i i $n 1\n"
         registerwcs i i $n 1 nullpixel=1
         smean i abell${numero}-${date} $n 1 "nullpixel=1 bitpix=-32"
         set ficin "${pathim}/abell${numero}-${date}.fit"
         set ficout "${pathim}/../../${numero}/abell${numero}-${date}.fit"
         ::console::affiche_resultat "abell${numero}-${date}.fit is created.\n"
         file rename -force -- $ficin $ficout
         for {set k 1} {$k<=$n} {incr k} {
            file delete "${pathim}/i${k}.fit"
         }
      }
   }

}

# source $audace(rep_install)/gui/audace/photcal.tcl ; abell_selectfiles
proc abell_selectfiles { {numero ""} {dateref ""} {datenight ""} } {
   global audace
   set bufno $audace(bufNo)
   set pathim $audace(rep_images)
   set err [catch {expr $numero} msg]
   if {$numero==""} {
      set fichiers [lsort [glob -nocomplain "${pathim}/../../*"]]
      set ls ""
      foreach fichier $fichiers {
         if {[file isdirectory $fichier]==0} {
            continue
         }
         set numero [file tail $fichier]
         set err [catch {expr $numero} msg]
         if {$err==1} { continue }
         append ls "$numero "
      }
      ::console::affiche_resultat "$ls\n"
   } else {
      if {$err==0} {
         set fichiers "${pathim}/../../${numero}"
      } else {
         set fichiers [lsort [glob -nocomplain "${pathim}/../../*"]]
      }
      foreach fichier $fichiers {
         if {[file isdirectory $fichier]==0} {
            continue
         }
         set numero [file tail $fichier]
         set err [catch {expr $numero} msg]
         if {$err==1} { continue }
         ::console::affiche_resultat "Exploration de Abell $numero\n"
         set fics [lsort [glob -nocomplain "${pathim}/../../${numero}/abell${numero}*.fit"]]
         foreach fic $fics {
            ::console::affiche_resultat "$fic\n"
         }
         if {$datenight==""} {
            set ficnight [lindex $fics end]
         } else {
            set ficnight "${pathim}/../../${numero}/abell${numero}-${datenight}.fit"
            if {[file exists $ficnight]==0} {
               error "Error, file $ficnight does not exists"
            }
         }
         file copy -force -- $ficnight ${pathim}/i2.fit
         ::console::affiche_resultat "ficnight=$ficnight\n"
         if {$dateref==""} {
            set ficref "${pathim}/../../${numero}/ref.txt"
            if {[file exists $ficref]==1} {
               set f [open $ficref r]
               set ficref "${pathim}/../../${numero}/[lindex [read $f] 0]"
               close $f
            } else {
               set ficref [lindex $fics 0]
            }
         } else {
            set ficref "${pathim}/../../${numero}/abell${numero}-${dateref}.fit"
            if {[file exists $ficref]==0} {
               error "Error, file $ficref does not exists"
            }
         }
         file copy -force -- $ficref ${pathim}/i1.fit
         ::console::affiche_resultat "ficref=$ficref\n"
         ::console::affiche_resultat "registerwcs i i 2 1 nullpixel=1\n"
         registerwcs i i 2 1 nullpixel=1
         # --- box
         buf$bufno load ${pathim}/i2.fit
         set naxis1 [buf$bufno getpixelswidth]
         set naxis2 [buf$bufno getpixelsheight]
         set xc [expr $naxis1/2]
         set yc [expr $naxis2/2]
         set x1 1
         set x2 $naxis1
         set x 1
         set val0 [lindex [buf$bufno getpix [list $x $yc]] 1]
         for {set x 2} {$x<=$naxis1} {incr x} {
            set val [lindex [buf$bufno getpix [list $x $yc]] 1]
            #::console::affiche_resultat "x=$x   val0=$val0   val=$val  ($x1,$x2)\n"
            if {($val!=1)&&($val0==1)} {
               set x1 $x
            }
            if {($val==1)&&($val0!=1)} {
               set x2 [expr $x-1]
               break
            }
            set val0 $val
         }
         set y1 1
         set y2 $naxis2
         set y 1
         set val0 [lindex [buf$bufno getpix [list $xc $y]] 1]
         for {set y 2} {$y<=$naxis2} {incr y} {
            set val [lindex [buf$bufno getpix [list $xc $y]] 1]
            #::console::affiche_resultat "y=$y   val0=$val0   val=$val  ($y1,$y2)\n"
            if {($val!=1)&&($val0==1)} {
               set y1 $y
            }
            if {($val==1)&&($val0!=1)} {
               set y2 [expr $y-1]
               break
            }
            set val0 $val
         }
         set box [list $x1 $y1 $x2 $y2]
         ::console::affiche_resultat "Box = $box\n"
         buf$bufno window $box
         buf$bufno save ${pathim}/i2.fit
         buf$bufno load ${pathim}/i1.fit
         buf$bufno window $box
         buf$bufno save ${pathim}/i1.fit
         ::console::affiche_resultat "Finished\n"
      }
   }
}


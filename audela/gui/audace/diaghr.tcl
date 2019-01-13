#
## @file diaghr.tcl
#  @brief Utilitaire pour mesurer des diagrammes HR à partir de deux images filtrées
#  @pre Les images doivent être calibrées en WCS
#  @author Alain KLOTZ
#  $Id: diaghr.tcl 13469 2016-03-22 10:50:30Z rzachantke $
#
# @note
# On utilise d'abord la fonction diaghr_extract pour extraire un fichier d'étoiles
# communes aux deux images puis on utilise diaghr_plot pour visualiser le
# diagramme couleur/magnitude avec une courbe d'isochrones superposée éventuellement
# @code
# exemple sur Messier 35:
# source $audace(rep_install)/gui/audace/diaghr.tcl
# diaghr_extract m35v2 m35r2 6h9m9s +24d20m 15. V R
# source $audace(rep_install)/gui/audace/diaghr.tcl
# diaghr_plot "" 0 0 0.95 V R 7e8 8 1
#
# exemple sur Messier 67:
# source $audace(rep_install)/gui/audace/diaghr.tcl
# diaghr_extract m67v2 m67r2 8h51m23s +11d49m22s 10. V R
# source $audace(rep_install)/gui/audace/diaghr.tcl
# diaghr_plot "" 0 0 0.95 V R 2.5e9 9.97 0
# @endcode

# -------------------------------------------------------------------------------------------------
## @brief extrait un fichier texte d'étoiles en commun entre deux images
#  @param file_image_1  fichier FITS de l'image numero 1
#  @param file_image_2  fichier FITS de l'image numero 2
#  @param ra_center     coordonnée RA du centre de la région à mesurer (Angle)
#  @param dec_center    coordonnée DEC du centre de la région à mesurer (Angle)
#  @param radius_arcmin rayon de calcul pour isoler les étoiles de l'amas du reste de l'image
#  @param color1        symbole du filtre de l'image 1 si l'on souhaite effectuer une calibration photométrique par NOMAD1
#  @param color2        symbole du filtre de l'image 1 si l'on souhaite effectuer une calibration photométrique par NOMAD1
#  @note : en sortie, le fichier [pwd]/hr.txt qui contient :
#   - col1 : RA (deg)
#   - col2 : DEC (deg)
#   - col3 : mag1
#   - col4 : mag2
#   - col5 : mag1-mag2
#
proc diaghr_extract { file_image_1 file_image_2 ra_center dec_center radius_arcmin {color1 ""} {color2 ""} } {
   global audace

   set radius_over 0.5
   set bufno $audace(bufNo)
   set rac [mc_angle2deg $ra_center]
   set decc [mc_angle2deg $dec_center 90]
   # --- Verif images
   set pathim $audace(rep_images)
   set ext [buf$audace(bufNo) extension]
   if {1==1} {
      set fic1 "$pathim/${file_image_1}$ext"
      set fic1 [lindex [glob -nocomplain $fic1] 0]
      if {$fic1==""} {
         ::console::affiche_resultat "Fichier $fic1 non trouve\n"
         return
      }
      set fic2 "$pathim/${file_image_2}$ext"
      set fic2 [lindex [glob -nocomplain $fic2] 0]
      if {$fic2==""} {
         ::console::affiche_resultat "Fichier $fic2 non trouve\n"
         return
      }
   } else {
      set fic1 "$file_image_1*"
      set fic1 [lindex [glob -nocomplain $fic1] 0]
      if {$fic1==""} {
         set fic1 "$pathim/$file_image_1*"
         set fic1 [lindex [glob -nocomplain $fic1] 0]
         if {$fic1==""} {
            ::console::affiche_resultat "Fichier $fic1 non trouve\n"
            return
         }
      }
      set fic2 "$file_image_2*"
      set fic2 [lindex [glob -nocomplain $fic2] 0]
      if {$fic2==""} {
         set fic2 "$pathim/$file_image_2*"
         set fic2 [lindex [glob -nocomplain $fic2] 0]
         if {$fic2==""} {
            ::console::affiche_resultat "Fichier $fic2 non trouve\n"
            return
         }
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
   set k [lsearch $params MAG_BEST]
   set kmag $k
   set k [lsearch $params MAGERR_BEST]
   set kmagerr $k
   ::console::affiche_resultat "indexes x=$kx y=$ky mag=$kmag magerr=$kmagerr\n"
   # ---
   ::console::affiche_resultat "analyze star list 1\n"
   loadima $fic1
   set err [catch {set radec [buf$bufno xy2radec [list 1 1]]} msg ]
   if {$err==0} {
      set wcs 1
      ::console::affiche_resultat "wcs keywords found\n"
   } else {
      set wcs 0
      ::console::affiche_resultat "wcs keywords not found. Calculations in pixel units.\n"
   }
   set f [open "$pathsex/catalog1.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set star1s ""
   foreach ligne $lignes {
      if {[lindex $ligne 0]==""} {
         continue
      }
      set x [lindex $ligne $kx]
      set y [lindex $ligne $ky]
      if {$wcs==1} {
         set radec [buf$bufno xy2radec [list $x $y]]
         set ra [lindex $radec 0]
         set dec [lindex $radec 1]
         set sepangle [expr [lindex [mc_sepangle $ra $dec $rac $decc] 0]*60.]
         if {$sepangle>=$radius_arcmin} {
            continue
         }
      } else {
         set ra $x
         set dec $y
         set dra [expr abs($ra-$rac)]
         set ddec [expr abs($dec-$decc)]
         set sepangle [expr sqrt($dra*$dra+$ddec*$ddec)]
      }
      if {$sepangle>=$radius_arcmin} {
         continue
      }
      set mag [lindex $ligne $kmag]
      set magerr [lindex $ligne $kmagerr]
      lappend star1s [list $x $y $ra $dec $mag $magerr]
   }
   ::console::affiche_resultat "[llength $star1s] stars found in the list 1\n"
   # ---
   ::console::affiche_resultat "analyze star list 2\n"
   loadima $fic2
   set f [open "$pathsex/catalog2.txt" r]
   set lignes [split [read $f] \n]
   close $f
   set star2s ""
   foreach ligne $lignes {
      if {[lindex $ligne 0]==""} {
         continue
      }
      set x [lindex $ligne $kx]
      set y [lindex $ligne $ky]
      if {$wcs==1} {
         set radec [buf$bufno xy2radec [list $x $y]]
         set ra [lindex $radec 0]
         set dec [lindex $radec 1]
         set sepangle [expr [lindex [mc_sepangle $ra $dec $rac $decc] 0]*60.]
         if {$sepangle>=$radius_arcmin} {
            continue
         }
      } else {
         set ra $x
         set dec $y
         set dra [expr abs($ra-$rac)]
         set ddec [expr abs($dec-$decc)]
         set sepangle [expr sqrt($dra*$dra+$ddec*$ddec)]
      }
      if {$sepangle>=$radius_arcmin} {
         continue
      }
      set mag [lindex $ligne $kmag]
      set magerr [lindex $ligne $kmagerr]
      lappend star2s [list $x $y $ra $dec $mag $magerr]
   }
   ::console::affiche_resultat "[llength $star2s] stars found in the list 2\n"
   # --- appariement
   ::console::affiche_resultat "match stars in the two lists\n"
   if {[info exists audace(diaghr_extract,pix_radius)]==0} {
      set audace(diaghr_extract,pix_radius) 2
   }
   if {$wcs==1} {
      set res [lindex [buf$bufno getkwd CDELT1] 1]
      set sepmax [expr abs($audace(diaghr_extract,pix_radius)*$res*3600)*$radius_over] ; # 2 pixels en arcsec
   } else {
      set sepmax [expr $audace(diaghr_extract,pix_radius)*$radius_over] ; # 2 pixels
   }
   set stars ""
   set nstar 0
   foreach star1 $star1s {
      set x1 [lindex $star1 0]
      set y1 [lindex $star1 1]
      set ra1 [lindex $star1 2]
      set dec1 [lindex $star1 3]
      set n [llength $star2s]
      set kmatch -1
      for {set k 0} {$k<$n} {incr k} {
         set star2 [lindex $star2s $k]
         set x2 [lindex $star2 0]
         set y2 [lindex $star2 1]
         set ra2 [lindex $star2 2]
         set dec2 [lindex $star2 3]
         if {$wcs==1} {
            set dra [expr abs($ra2-$ra1)*3600.]
            if {$dra>180} {
               set dra [expr 360.-$dra]
            }
            if {$dra>$sepmax} {
               continue
            }
            set ddec [expr abs($dec2-$dec1)*3600.]
            if {$ddec>$sepmax} {
               continue
            }
         } else {
            set dra [expr abs($ra2-$ra1)]
            if {$dra>$sepmax} {
               continue
            }
            set ddec [expr abs($dec2-$dec1)]
            if {$ddec>$sepmax} {
               continue
            }
         }
         set mag1 [lindex $star1 4]
         set mag2 [lindex $star2 4]
         set mag12 [expr $mag1-$mag2]
         if {$wcs==1} {
            set texte "[format %9.5f $ra1] [format %+9.5f $dec1] [format %6.3f $mag1] [format %6.3f $mag2] [format %+6.3f $mag12]\n"
         } else {
            set texte "[format %8.2f $ra1] [format %8.2f $dec1] [format %6.3f $mag1] [format %6.3f $mag2] [format %+6.3f $mag12]\n"
         }
         append stars $texte
         incr nstar
         ::console::affiche_resultat "[format %5d $nstar] : $texte"
         set kmatch $k
         break
      }
      if {$kmatch>=0} {
         set star2s [lreplace $star2s $kmatch $kmatch]
      }
   }
   ::console::affiche_resultat "$nstar stars matched in the two lists\n"
   # --- sauve le fichier resultat
   set fic "$pathim/hr.txt"
   ::console::affiche_resultat "save common star list in file $fic\n"
   set f [open $fic w]
   puts -nonewline $f $stars
   close $f
   # --- correction photometrique avec le NOMAD1
   if {($color1!="")&&($color2!="")} {
      set offmag1 $color1
      set offmag2 $color2
      set filters {B V R J H K}
      ::console::affiche_resultat "load star list in file $fic\n"
      set f [open $fic r]
      set lignes [split [read $f] \n]
      close $f
      for {set ki 0} {$ki<=1} {incr ki} {
         set stars ""
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
            #
            if {$wcs==1} {
               set texte "[format %9.5f $ra] [format %+9.5f $dec] [format %6.3f $mag1] [format %6.3f $mag2] [format %+6.3f $mag12]\n"
            } else {
               set texte "[format %8.2f $ra] [format %8.2f $dec] [format %6.3f $mag1] [format %6.3f $mag2] [format %+6.3f $mag12]\n"
            }
            append stars $texte
            #
            incr n
            if {($nn>$m)&&($cmag==1)} {
               set star [lindex [vo_neareststar $ra $dec] 0]
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
      # --- sauve le fichier resultat
      set fic "$pathim/hr.txt"
      ::console::affiche_resultat "save final common star list in file $fic\n"
      set f [open $fic w]
      puts -nonewline $f $stars
      close $f
   }
}

# -------------------------------------------------------------------------------------------------
## @brief dessine un diagramme couleur/magnitude et superpose un isochrone.
#  @pre  extraire d'abord les étoiles en commun avec @ref diaghr_extract
#  @param fic_hr        nom du fichier ($audace(rep_images)/hr.txt par défaut) généré préalablement par la fonction diaghr_extract ;
#  pour mémoire, ce fichier contient :
#  - col1 : RA (deg)
#  - col2 : DEC (deg)
#  - col3 : mag1
#  - col4 : mag2
#  - col5 : mag1-mag2
#  @param offmag1        offset en magnitude pour effectuer une correction photométrique supplementaire
#  @param offmag2        offset en magnitude pour effectuer une correction photométrique supplementaire
#  @param xaxis          fraction de points délimitant les bornes de visualisation sur l'axe des abscisses (0.95 par defaut)
#  @param color1         symbole du filtre de l'image 1 si l'on souhaite superposer un isochrone
#  @param color2         symbole du filtre de l'image 1 si l'on souhaite effectuer une calibration photométrique par NOMAD1
#  @param age            âge (années) pour superposer l'isochrone correspondant ("" = pas d'isochrone superpose = par defaut)
#  @param dist_modulus   module de distance (magnitudes) pour superposer un isochrone
#  @param v_extinction   extinction dans la bande V pour superposer un isochrone
#  @param fic_isochrones fichier qui contient les isochrones
#
proc diaghr_plot { {fic_hr ""} {offmag1 0} {offmag2 0} {xaxis 0.95} {color1 V} {color2 R} {age ""} {dist_modulus 7} {v_extinction 0} {fic_isochrones ""} } {
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
            set star [lindex [vo_neareststar $ra $dec] 0]
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
   ::plotxy::plot $mag12s $mag1s r.
   ::plotxy::ydir reverse
   ::plotxy::xlabel "${color1}-${color2}"
   ::plotxy::ylabel "${color1}"
   ::plotxy::plotbackground #FFFFFF
   ::plotxy::bgcolor #FFFFFF
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


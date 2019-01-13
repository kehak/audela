#
## @file photrel.tcl
#  @brief Relative photometry from a series of images. Automatic extraction of variable stars.
#  @author Alain KLOTZ
#  $Id: photrel.tcl 13766 2016-04-28 19:30:47Z rzachantke $
#
#  @defgroup photrel Relative photometry from a series of images. Automatic extraction of variable stars.
#  This script is based on the thesis work of <B>Yassine Damerdji</B>
#
# - @ref photrel_wcs2cat : Creates a binary catalog of sources from an image series
# - @ref photrel_cat2mes : Extract a light curve from a (ra,dec) and a binary catalog of sources
# - @ref photrel_cat2var : Find automatically variable sources from a binary catalog of sources
# - @ref photrel_wcs2var : Find automatically variable sources from an image series
# - @ref photrel_cat2per : Compute the best period from a (ra,dec) and a binary catalog of sources
#
# Work that remains to do :
# -# Photometric calibration from a binary catalog and a photometric catalog
#   - @ref photrel_cat2con : Extract the center coordinates and the radius of a binary catalog of sources
#   - @ref photrel_nom2cal : Download a list of Nomad1 stars in an ascii catalogue as calibrated magnitudes
#   - @ref photrel_cal2cat : Add calibrated magnitudes in a binary catalog of sources
#   - @ref photrel_mes2mes : Calibration of a binary catalog of sources
# -# photrel_cat2mov  : to find automatically moving objects
#
#---------------------------------------------------------------------------------------------
#
# On part avec une série d'images. Exemple: ic1.fit a ic10.fit
#
# Les images doivent prealablement etre calibrées WCS (sinon utiliser @ref calibwcs2)
# On fabrique une série de trois fichiers binaires appelés "catalogues" (@ref photrel_wcs2cat)
# Les trois fichiers sont MES, REF et ZMG :
# - MES = fichier des mesures. Chaque entrée correspond à une étoile pour une date.
# - REF = fichier des références. Chaque entrée definit les coordonnées et la magnitude moyenne d'une seule étoile dans divers filtres éventuellement.
# - ZMG = fichier des corrections de magnitudes pour chaque date.
# Idéalement, les fichiers d'un catalogue couvrent une petite zone sur le ciel.
#
# A la fin de @ref photrel_wcs2cat, les fichiers binaires sont recopiés en ASCII pour être lisibles facilement.
# A partir des fichers catalogue, on peut extraire la courbe de lumière de n'importe quelle étoile (@ref photrel_cat2mes).
# Néanmoins, ce sont les fichiers binaires qui seront utilisés pour les analyses ultérieures.
# A partir des fichers catalogue, on peut demander à trouver automatiquement les étoiles variables (@ref photrel_cat2var).
# Il y a deux algorithmes utilisés. Par défaut c'est l'algo de Stetson.
# A la fin de l'extraction, un fichier HTML et les courbes de lumières des candidates sont générés.
# A partir des fichers catalogue, on peut calculer la période la plus probable de n'importe quelle étoile (photrel_cat2per).
# Les étapes :
# - On calcule les catalogues binaires à partir de la serie d'images Utilisation de Sextractor).
#   @code
#   source "$audace(rep_install)/gui/audace/photrel.tcl"
#   photrel_wcs2cat ic 10 new
#   @endcode
#
# - On extrait les étoiles variables à partir des catalogues binaires :
#   @code
#   source "$audace(rep_install)/gui/audace/photrel.tcl"
#   photrel_cat2var ic -html c:/srv/www/htdocs/vars/ -var_method std -param_method 5
#   photrel_cat2var N321200310
#   @endcode
#
# - On extrait les étoiles variables à partir de la série d'images
#   @code
#   source "$audace(rep_install)/gui/audace/photrel.tcl"
#   photrel_wcs2var ic 10 new 1 -html c:/srv/www/htdocs/vars/ -var_method std -param_method 5
#   @endcode
#
# - On extrait une courbe de lumière à partir de RA,DEC et des catalogues binaires
#   @code
#   source "$audace(rep_install)/gui/audace/photrel.tcl"
#   photrel_cat2mes ic mystar 164.630162 67.525332 C
#   @endcode
#
# - On calcule la période la plus probable à partir des catalogues binaires
#   @code
#   source "$audace(rep_install)/gui/audace/photrel.tcl"
#   photrel_cat2per N321200310 mystar 23.033801 1.341922 C 2
#   @endcode
#
# - @ref photrel_demo est une proc de démonstration à l'aide de @ref simulimage2
#

#========================================================================

## @brief génère des éphémérides pour un astre
#  @code
#  photrel_elem2ephem {2454506.376 0.514043} now 20 $audace(posobs,observateur,gps) [list  01h17m13.5s +74d51m20s J2000]
#  @endcode
#
proc photrel_elem2ephem { List_elems_JDE_period Date_start nb_days {home ""} {List_coords ""}} {

   set elems $List_elems_JDE_period
   set jde0 [lindex $elems 0]
   set p [lindex $elems 1]
   set p2 [lindex $elems 2]
   if {$p2==""} {
      set p2 0
   }
   set jd1 [mc_date2jd $Date_start]
   set jd2 [expr $jd1+$nb_days]
   # JDmax = jde0 + p*E + p2*E*E
   # recherche le E1 pour la date jd1
   set a $p2
   set b $p
   set c [expr $jde0-$jd1]
   if {$a!=0} {
      set d [expr $b*$b-4*$a*$c]
      set e1 [expr (-$b-sqrt($d))/(2.*$a)]
   } else {
      set e1 [expr -1.*$c/$b]
   }
   set c [expr $jde0-$jd2]
   if {$a!=0} {
      set d [expr $b*$b-4*$a*$c]
      set e2 [expr (-$b-sqrt($d))/(2.*$a)]
   } else {
      set e2 [expr -1.*$c/$b]
   }
   set e1 [expr int(floor($e1))]
   set e2 [expr int(ceil($e2))]
   if {$home==""} {
      set home $::audace(posobs,observateur,gps)
   }
   if {$List_coords!=""} {
      lassign $List_coords Angle_Ra Angle_Dec Equinox
      if {$Equinox==""} {
         set Equinox J2000
      }
   }
   for {set e $e1} {$e<=$e2} {incr e} {
      set jdmax [expr $jde0 + $p*$e + $p2*$e*$e]
      set elev_sun [lindex [mc_ephem {sun} [list $jdmax] [list ALTITUDE] -topo $home] 0]
      if {$elev_sun>-20} {
         continue
      }
      set elev 0
      if {$List_coords!=""} {
         set jd [mc_tt2bary $jdmax $Angle_Ra $Angle_Dec $Equinox $home]
         set djd [expr $jd-$jdmax]
         set jdmax [expr $jdmax-$djd]
         set res [mc_radec2altaz $Angle_Ra $Angle_Dec $home $jdmax]
         lassign $res az elev ha paral
         if {$elev<20} {
            continue
         }
      }
      console::affiche_resultat "[string range [mc_date2iso8601 $jdmax] 0 end-4] [format %3d $e] [format %4.1f $elev] [format %4.1f $elev_sun]\n"
   }
}

## @brief extract the center coordinates and the radius of a binary catalog of sources.
#  @param args file_cat
#
proc photrel_cat2con { args } {

   set n [llength $args]
   if {$n>=1} {
      set in "[lindex $args 0]"
      set path $::audace(rep_images)/
      set res [yd_ref2field ${path} ${in}]
      return $res
   } else {
      error "Usage: photrel_cat2con file_cat"
   }
}

## @brief download a list of Nomad1 stars in an ascii catalogue as calibrated magnitudes.
#  @param args ra dec radius_deg file_nomad
#
proc photrel_nom2cal { args } {

   set n [llength $args]
   if {$n>=1} {
      set ra "[lindex $args 0]"
      set dec "[lindex $args 1]"
      set radius "[lindex $args 2]"
      set out "[lindex $args 3]"
      set path $::audace(rep_images)/
      set stars [vo_neareststar $ra $dec [expr $radius*60]]
      set texte ""
      foreach star $stars {
         set ra [lindex $star 1]
         set dec [lindex $star 2]
         append texte "$ra $dec"
         for {set k 0} {$k<6} {incr k} {
            set mag [lindex $star [expr 3+$k]]
            if {$mag=={}} {
               set mag -99.9
            }
            append texte " [format %7.3f $mag]"
         }
         append texte "\n"
      }
      set f [open ${path}/${out}_cal.txt w]
      puts -nonewline $f $texte
      close $f
      return $texte
   } else {
      error "Usage: photrel_nom2cal ra dec radius_deg file_nomad"
   }
}

## @brief add calibrated magnitudes in a binary catalog of sources.
#  @param args file_cat
#
proc photrel_cal2cat { args } {

   set n [llength $args]
   if {$n>=1} {
      set in "[lindex $args 0]"
      set path $::audace(rep_images)/
      yd_cal2ref ${path} ${in}
      yd_refzmgmes2ascii ${path} ${in}
      return ""
   } else {
      error "Usage: photrel_cal2cat file_cat"
   }
}

## @brief calibration of a binary catalog of sources.
#  @param args file_cat
#
proc photrel_mes2mes { args } {

   set n [llength $args]
   if {$n>=1} {
      set in "[lindex $args 0]"
      set path $::audace(rep_images)/
      yd_mes2mes ${path} ${in}
      #yd_refzmgmes2ascii ${path} ${in}
      return ""
   } else {
      error "Usage: photrel_mes2mes file_cat"
   }
}

## @brief extract a light curve from a (ra,dec) and a binary catalog of sources.
# @param args file_cat file_mes ra dec filter ?codecam?
#
proc photrel_cat2mes { args } {

   set n [llength $args]
   if {$n>=5} {
      set in "[lindex $args 0]"
      set out "[lindex $args 1]"
      set ra_deg [mc_angle2deg [lindex $args 2]]
      set dec_deg [mc_angle2deg [lindex $args 3] 90]
      set filter [lindex $args 4]
      set codefiltre 67
      for {set kfil 0} {$kfil<256} {incr kfil} {
         set car [format %c $kfil]
         if {$car==$filter} {
            set codefiltre $kfil
            break
         }
      }
      set codecam 0
      if {$n>=6} {
         set codecam [lindex $args 5]
      }
      set path $::audace(rep_images)/
      #::console::affiche_resultat "yd_radecinrefzmgmes ${path}${in} ${path}${out}.txt $ra_deg $dec_deg $codefiltre $codecam\n"
      yd_radecinrefzmgmes ${path}${in} ${path}${out}.txt $ra_deg $dec_deg $codefiltre $codecam
   } else {
      error "Usage: photrel_cat2mes file_cat file_mes ra dec filter ?codecam?"
   }
}

## @brief creates a binary catalog of sources from an image series.
#  @param args in number attribut(new|append) ?first_index?
#
proc photrel_wcs2cat { args } {

   set n [llength $args]
   if {$n>=2} {
      set in "[lindex $args 0]"
      set number [lindex $args 1]
      set attribut [lindex $args 2]
      set first 1
      if {$n>=4} {
         set first "[lindex $args 3]"
      }
      set ni [expr $number+$first-1]
      set path $::audace(rep_images)/
      set htm_name $in
      if {$attribut=="new"} {
         catch {file delete ${path}${htm_name}_ref.bin}
         catch {file delete ${path}${htm_name}_mes.bin}
         catch {file delete ${path}${htm_name}_zmg.bin}
      }
      for {set ki $first} {$ki<=$ni} {incr ki} {
         # --- Lecture du fichier image et passage dans sextractor
         loadima ${in}${ki}
         set ext $::conf(extension,defaut)
         #--- Remplacement de "$::audace(rep_images)" par "." dans "mypath" - Cela permet a
         #--- Sextractor de ne pas etre sensible aux noms de repertoire contenant des
         #--- espaces et ayant une longueur superieure a 70 caracteres
         set mypath "."
         set sky0 dummy0
         set sky dummy
         buf$::audace(bufNo) save [ file join ${mypath} ${sky0}$ext ]
         createFileConfigSextractor
         sextractor [ file join $mypath $sky0$ext ] -c "[ file join $mypath config.sex ]"
         # --- Lecture du fichier catalog.cat de sextractor
         set f [open catalog.cat r]
         set lignes [split [read $f] \n]
         close $f
         catch {file delete [file join ${mypath} ${sky0}$ext ]}
         set nl [expr [llength $lignes]-1]
         # --- On transforme le fichier catalog.cat de sextractor en fichier ASCII
         # airmass du centre du champ
         set filter [string trim [lindex [buf$::audace(bufNo) getkwd FILTER] 1]]
         if {$filter==""} {
            set filter C
         }
         set codefiltre 67
         for {set kfil 0} {$kfil<256} {incr kfil} {
            set car [format %c $kfil]
            if {$car==$filter} {
               set codefiltre $kfil
               break
            }
         }
         #::console::affiche_resultat "Filter=$filter codefiltre=$codefiltre\n"
         set naxis1 [lindex [buf$::audace(bufNo) getkwd NAXIS1] 1]
         set naxis2 [lindex [buf$::audace(bufNo) getkwd NAXIS2] 1]
         set radec [buf$::audace(bufNo) xy2radec [list [expr $naxis1/2.] [expr $naxis2/2.]]]
         set ra [lindex $radec 0]
         set dec [lindex $radec 1]
         set airmass 1 ; # TBC
         set cdelt1 [expr abs([lindex [buf$::audace(bufNo) getkwd CDELT1] 1])]
         set cdelt2 [expr abs([lindex [buf$::audace(bufNo) getkwd CDELT2] 1])]
         set cdelt $cdelt1
         if {$cdelt2>$cdelt1} { set cdelt $cdelt2 }
         set angle [expr 3600.*$cdelt] ; # rayon d'association en arcsec
         # ra dec jd codecam codefiltre maginst exposure airmass (ASCII)
         set textes ""
         for {set kl 0} {$kl<$nl} {incr kl} {
            set ligne [lindex $lignes $kl]
            if {([lindex $ligne 0]=="")||([string index [string trim $ligne] 0]=="#")} {
               continue
            }
            set x [lindex $ligne 6]
            set y [lindex $ligne 7]
            set radec [buf$::audace(bufNo) xy2radec [list $x $y]]
            set ra [lindex $radec 0]
            set dec [lindex $radec 1]
            set date_obs [lindex [buf$::audace(bufNo) getkwd DATE-OBS] 1]
            set exposure [lindex [buf$::audace(bufNo) getkwd EXPOSURE] 1]
            set jd [mc_datescomp $date_obs + [expr $exposure/2./86400.]]
            set codecam 0
            set maginst [lindex $ligne 3]
            set dmag [lindex $ligne 4]
            set sexflag [lindex $ligne 15]
            set texte "$ra $dec $jd $codecam $codefiltre $maginst $exposure $airmass $dmag $sexflag"
            append textes "${texte}\n"
         }
         set asciifile_in $::audace(rep_images)/catalog.txt
         set f [open $asciifile_in w]
         puts -nonewline $f $textes
         close $f
         ::console::affiche_resultat "Image ${in}${ki} : $nl stars filter=$filter\n"
         if {$nl<=0} { continue }
         # --- On transforme le fichier ASCII en fichier binaire
         catch {file delete ${path}${htm_name}_.bin}
         #::console::affiche_resultat "yd_file2htm $asciifile_in $path $htm_name -1\n"
         yd_file2htm $asciifile_in $path $htm_name -1
         # --- On eclate le fichier binaire en trois fichiers catalogues binaires
         set filename_in ${path}${htm_name}_.bin
         set generic_filename_out $htm_name
         #::console::affiche_resultat "yd_filehtm2refzmgmes $filename_in $path $generic_filename_out $angle\n"
         yd_filehtm2refzmgmes $filename_in $path $generic_filename_out $angle
         catch {file delete ${path}${htm_name}_.bin}
      }
      set name ${path}${htm_name}
      if {[file exists "${name}_ref.bin"]==0} {
         return ""
      }
      set nref [expr ([file size "${name}_ref.bin"]/48)]
      set nzmg [expr ([file size "${name}_zmg.bin"]/24)]
      set nmes [expr ([file size "${name}_mes.bin"]/32)]
      ::console::affiche_resultat "Balance: $nref stars, $nzmg dates, $nmes measures.\n"
      # --- point zero et superstar
      yd_updatezmg "$path" $htm_name
      yd_refzmgmes2ascii "$path" $htm_name
   } else {
      error "Usage: photrel_wcs2cat in number attribut(new|append) ?first_index?"
   }
}

## @brief find automatically variable sources from a binary catalog of sources
#  @param args in ?-html htm_folder? ?-var_method stetson|std? ?-param_method value?
#
proc photrel_cat2var { args } {

   set n [llength $args]
   if {$n>=1} {
      set in "[lindex $args 0]"
      set html_folder $::audace(rep_images)/
      set var_method stetson
      set param_method 1
      set var_method_modified 0
      set param_method_modified 0
      if {$n>=3} {
         for {set k 1} {$k<$n} {incr k} {
            set key [lindex $args $k]
            set val [lindex $args [expr $k+1]]
            if {$key=="-html"} { set html_folder $val }
            if {$key=="-var_method"} { set var_method $val ; set var_method_modified 1}
            if {$key=="-param_method"} { set param_method $val ; set param_method_modified 1}
         }
      }
      if {($var_method_modified==1)&&($param_method_modified==0)} {
         if {$var_method=="stetson"} {
            set param_method 1 ; # 0= peu d'etoiles 1= si > 10 etoiles
         } else {
            set param_method 5 ; # nb etoiles mini pour faire le zero mag
         }
      }
      ::console::affiche_resultat "Parameters: html_folder=$html_folder var_method=$var_method param_method=$param_method\n"
      set path $::audace(rep_images)/
      set htm_name $in
      set name ${path}${htm_name}
      set nref [expr ([file size "${name}_ref.bin"]/48)]
      set nzmg [expr ([file size "${name}_zmg.bin"]/24)]
      set nmes [expr ([file size "${name}_mes.bin"]/32)]
      ::console::affiche_resultat "Balance: $nref stars, $nzmg dates, $nmes measures.\n"
      # --- point zero et superstar
      yd_updatezmg "$path" $htm_name
      yd_refzmgmes2ascii "$path" $htm_name
      # --- extraction des etoiles variables
      set config $param_method
      set obs_symbol STAR
      set starmin $param_method
      set list_header [list {PROC photrel_cat2var}]
      ::console::affiche_resultat "Extract variables using method: $var_method (params $param_method).\n"
      if {$var_method=="stetson"} {
         set res [yd_refzmgmes2vars_stetson "$path" $htm_name $config $obs_symbol $list_header]
      } else {
         set res [yd_refzmgmes2vars "$path" $htm_name $starmin $obs_symbol $list_header]
      }
      ::console::affiche_resultat "res=$res\n"
      set fics [glob -nocomplain "${path}${obs_symbol}-${in}-*.txt"]
      set nf [llength $fics]
      ::console::affiche_resultat "$nf stars found to be potentially variable:\n"
      for {set kf 0} {$kf<$nf} {incr kf} {
         set fic [lindex $fics $kf]
         ::console::affiche_resultat " See file $fic\n"
      }
      # --- pages html pour les variables trouvees
      if {$nf>0} {
         set texte ""
         append texte "<HEAD><TITLE>Variable star candidates</TITLE><HEAD>\n"
         append texte "<BODY><HTML>\n"
         append texte "<CENTER><H2>PHOTOMETRY FROM FILES ${in}</H2></CENTER>"
         append texte "<I>These measurements are automatically produced by AudeLA software. First column is julian day of the middle exposure. The second column is the magnitude. The third column contains an integer which identify the camera used.</I><BR>\n"
         append texte "<BR>\n"
      }
      set texte0s ""
      for {set kf 0} {$kf<$nf} {incr kf} {
         set fic [lindex $fics $kf]
         ::console::affiche_resultat " See file $fic\n"
         # --- on copy le fichier ASCII de la variable dans le dossier HTTP
         set ficascii "[file tail [file rootname $fic]].txt"
         set fichier "${html_folder}/$ficascii"
         catch {file copy -force -- $fic $fichier}
         # --- on genere le GIF de la variable dans le dossier HTTP
         source "$::audace(rep_install)/gui/audace/fly.tcl"
         set ng [fly_var2gif "$fichier"]
         if {$ng>=1} {
            set ficgif0 "[file tail [file rootname $fic]].gif"
            set fic [file tail $fichier]
            set size [file size $fichier]
            set mtime [file mtime $fichier]
            set datename [clock format [file mtime $fichier] -format %Y-%m-%dT%H:%M:%S ]
            set texte00s ""
            lappend texte0s "$mtime <A HREF=$ficascii>$ficascii</A> $ng measurements ([format %.1f [expr ${size}/1024.]] Ko) <I>updated on ${datename}</I><BR><IMG SRC=$ficgif0 alt=file_not_found width=600 height=300>"
         }
      }
      set texte0s [lsort -decreasing "$texte0s"]
      foreach texte0 $texte0s {
         append texte "[lrange "$texte0" 1 end]\n"
         append texte "<BR>"
      }
      append texte "</HTML></BODY>\n"
      set f [open "${html_folder}/${in}.html" w]
      puts $f "$texte"
      close $f
      ::console::affiche_resultat "HTML file generated in ${html_folder}/${in}.html\n"
   } else {
      error "Usage: photrel_cat2var in ?-html htm_folder? ?-var_method stetson|std? ?-param_method value?"
   }
}

## @brief find automatically variable sources from an image series
#  @param args in number attribut(new|append) ?first_index? ?-html htm_folder? ?-var_method stetson|std? ?-param_method value?
#
proc photrel_wcs2var {args} {

   set n [llength $args]
   if {$n>=2} {
      set in "[lindex $args 0]"
      set number [lindex $args 1]
      set attribut [lindex $args 2]
      set first 1
      if {$n>=4} {
         set first "[lindex $args 3]"
      }
      set html_folder $::audace(rep_images)/
      set var_method stetson
      set param_method 1
      set var_method_modified 0
      set param_method_modified 0
      if {$n>=5} {
         for {set k 4} {$k<$n} {incr k} {
            set key [lindex $args $k]
            set val [lindex $args [expr $k+1]]
            if {$key=="-html"} { set html_folder $val }
            if {$key=="-var_method"} { set var_method $val ; set var_method_modified 1}
            if {$key=="-param_method"} { set param_method $val ; set param_method_modified 1}
         }
      }
      if {($var_method_modified==1)&&($param_method_modified==0)} {
         if {$var_method=="stetson"} {
            set param_method 1 ; # 0= peu d'etoiles 1= si > 10 etoiles
         } else {
            set param_method 5 ; # nb etoiles mini pour faire le zero mag
         }
      }
      set ni [expr $number+$first-1]
      photrel_wcs2cat $in $number $attribut $first
      photrel_cat2var $in -html $html_folder -var_method $var_method -param_method $param_method
   } else {
      error "Usage: photrel_wcs2var in number attribut(new|append) ?first_index? ?-html htm_folder? ?-var_method stetson|std? ?-param_method value?"
   }
}

## @brief détermine une période à partir d'un fichier de mesures
#  @code
#  source "$audace(rep_install)/gui/audace/photrel.tcl"
#  photrel_cat2per ic mystar 164.630162 67.525332 C
#  @endcode
#
proc photrel_cat2per { args } {

   set n [llength $args]
    if {$n>=2} {
      set in "[lindex $args 0]"
      set out "[lindex $args 1]"
      set ra_deg [string trim [mc_angle2deg [lindex $args 2]]]
      set dec_deg [string trim [mc_angle2deg [lindex $args 3] 90]]
      set filter [lindex $args 4]
      set codefiltre 67
      for {set kfil 0} {$kfil<256} {incr kfil} {
         set car [format %c $kfil]
         if {$car==$filter} {
            set codefiltre $kfil
            break
         }
      }
      set codecam 0
      if {$n>=6} {
         set codecam [lindex $args 5]
      }
      set path $::audace(rep_images)/
      set pathhtm $path
      #
      # ==============================================================
      # Mes file
      # ==============================================================
      #
      #::console::affiche_resultat "photrel_cat2mes $args\n"
      set toeval "photrel_cat2mes $args"
      eval $toeval
      #
      # ==============================================================
      # Parameters
      # ==============================================================
      #
      set nbin1 8     ; # nombre de cases pour l'analyse en entropie (courtes periodes)
      set nbin2 16    ; # nombre de cases pour l'analyse en entropie (longues periodes)
      set nper1 100   ; # nombre de frequences a garder apres la premiere analyse
      set nper2 10    ; # nombre de frequences a garder pour l'analyse en harmoniques
      set nhar 5
      set amode 4
      #
      # ==============================================================
      # Init the phase vector to plot the light curve
      # ==============================================================
      #
      set phaseps ""
      set nphasep 100
      for {set kk 0} {$kk<=$nphasep} {incr kk} {
         set phase [expr 1.5*$kk/100.]
         lappend phaseps $phase
      }
      #
      # ==============================================================
      # Read the ASCII file of that variable
      # ==============================================================
      #
      set html_folder $::audace(rep_images)
      set file_mes $out
      set fichier $html_folder/$file_mes.txt
      set fichier0 $fichier
      set f [open $fichier r]
      set data [split [read $f] \n]
      catch {set data [lrange $data 0 end-1]}
      close $f
      set name $in
      #
      set header ""
      lappend header "NAME      = $file_mes"
      lappend header "RA        = $ra_deg"
      lappend header "DEC       = $dec_deg"
      lappend header "EQUINOX   = J2000.0"
      lappend header "FILTER    = $filter"
      lappend header "CAMERANO  = $codecam"
      lappend header "PROC      = photrel_cat2mes"
      if {$data==""} {
         error "No data at this position"
      }
      set ra $ra_deg
      set dec $dec_deg
      # --- verify that new measurements were done since the last computation
      set jdlastmes [lindex [lindex $data end] 0]
      set fictxt [file tail $fichier0]
      set ficname [file rootname $fictxt]
      # ---
      set x [gsl_mtranspose $data]
      set x [lrange $x 0 3]
      # --- extracts the (jds,mags,bars) from observed lists
      set jds [lindex $x 0]
      set nobs [llength $jds]
      if {$nobs<30} {
         return "Period searching impossible because there is less than 30 observations"
      }
      # --- correction of time : JD UT-terrestrial -> barycentrical of the solar system
      set jds [mc_dates_ut2bary $jds $ra $dec J2000.0]
      # --- compute the sigma and the amplitude of the observed magnitudes
      set mags [lindex $x 1]
      set res [lsort -real $mags]
      set amplitudeobs [expr [lindex $res end]-[lindex $res 0]]
      set bars [lindex $x 2]
      set poids_temp ""
      set poids_temp0 [expr 1./$nobs]
      for {set kk 0} {$kk<$nobs} {incr kk} {
         lappend poids_temp $poids_temp0
      }
      set flags [lindex $x 3]
      # on calcule ici les poids normalises a 1 (pour les flag =+1=neighbor, +2=linked on double la barre d'erreur)
      set poids [yd_poids $bars $flags]
      set res [yd_meansigma $mags $poids]
      set sigma [lindex $res 1]
      set moyenne [lindex $res 0]
      set res [yd_meansigma $mags $poids_temp]
      set sigma_temp [lindex $res 1]
      if {$amplitudeobs<$sigma} {
         error "Amplitude < sigma ($amplitudeobs < $sigma)"
      }
      #ce test permet de calculer la portion de points dont 1*bars coupe la moyenne
      set res [yd_moy_bars_comp $mags $bars $moyenne $sigma]
      if {$res} {
         error "Star non variable"
      }
      unset x
      #
      # ==============================================================
      #                    Searching for period
      # ==============================================================
      #
      # ==============================================================
      # Select the period range according to the sampling theorem
      # ==============================================================
      set per_range_minmin 0.04
      set res [yd_per_range $jds $per_range_minmin]
      set per_range_min [lindex $res 0]
      set per_range_max [lindex $res 1]
      if {$per_range_max<=$per_range_min} {
         error "Per_range_max <= per_range_min"
      }
      if {$per_range_max<0.06} {
         error "Per_range_max <= 0.06jours=1.5h"
      }
      # ==============================================================
      # Je regarde si ma vaiable est une longue ou courte periode
      # ==============================================================
      set res [yd_shortorlong $jds $mags $poids_temp $poids $amplitudeobs $sigma_temp $sigma $per_range_min $per_range_max $nper1 $nbin2]
      set longvar [lindex $res 0]
      set pasfreq [lindex $res 1]
      set pasfreqlong [lindex $res 2]
      set predisp [lindex $res 3]
      set periods [lindex $res 4]
      set PDM [lindex $res 5]
      set Entropie [lindex $res 6]
      if {$longvar} {
         # c est une longue periode : j ai calcule PDM et Entropie dans ce cas
         set shortvar 0
         set poids $poids_temp
      } else {
         set shortvar 1
         set periods_long $periods
         set PDM_long $PDM
         set Entropie_long $Entropie
      }
      #
      # ===============================================================
      # Compute the nper1 best probable periods
      # ===============================================================

      if {$shortvar} {
         set res [yd_entropie_pdm $jds $mags $poids $per_range_min $per_range_max $pasfreq $nper1 $nbin1]
         set periods [lindex $res 0]
         set PDM [lindex $res 1]
         set Entropie [lindex $res 2]
         set pasfreqshort [lindex $res 3]
         unset res
      }
      #
      # ===============================================================
      # Compute the Minlong of the selected periods
      # ===============================================================
      set nper3 [llength $periods]
      set minlong [lindex [yd_minlong $jds $mags $poids $periods] 0]
      #
      # ==============================================================================
      # Compute the periodograms of the selected periods only if we seek a long period
      # ==============================================================================
      #set periodog [yd_periodog $jds $mags $poids $periods $moyenne $sigma]
      set periodog ""
      for {set kper 0} {$kper<[llength $PDM]} {incr kper} { lappend periodog "0" }
      #
      # ===============================================================
      # Compute a criterium to select the 10 best periods
      # ===============================================================
      set best_periods [yd_classification $periods $minlong $periodog $PDM $Entropie $nobs $longvar $nper2]
      unset minlong periodog PDM Entropie
      #
      # ===============================================================
      # Compute the Fourier series development for the best period
      # ===============================================================
      set jdphase0 [lindex $jds 0]
      set res [yd_ajustement $jds $jdphase0 $mags $poids $best_periods $nhar]
      set periodetris [lindex $res 0]
      set periode [lindex $periodetris 0]

      # et si c etait une longue var
      if {$predisp} {
         set minlong_long [lindex [yd_minlong $jds $mags $poids_temp $periods_long] 0]
         set periodog_long ""
         for {set kper 0} {$kper<[llength $PDM_long]} {incr kper} { lappend periodog_long "0" }
         set best_periods_long [yd_classification $periods_long $minlong_long $periodog_long $PDM_long $Entropie_long $nobs 1 $nper2]
         unset minlong_long PDM_long Entropie_long periodog_long
         set res [yd_ajustement $jds $jdphase0 $mags $poids $best_periods_long $nhar]
         set periodetris_long [lindex $res 0]
         set periode_long [lindex $periodetris_long 0]
         set periods_shortlong "$periode $periode_long"
         set res [yd_ajustement_spec $jds $jdphase0 $mags $poids $periods_shortlong $nhar]
         set periode  [lindex $res 0]
      }
      if {$periode==0} {
         error "Frequency null"
      }
      if {($periode<2.)&&($nobs<60)} {
         error "Periode < 2j et nobs<60"
      }

      #
      set n_arm [lindex $res 1] ; # number of harmonics in the final analysis
      set coefs [lindex $res 2] ; # list of the harmonic coefficients
      set phases [lindex $res 3] ; # the observed phase vector
      unset res
      # --- compute the best period
      set duree [format %.2f [expr ([lindex $jds end]-[lindex $jds 0])/$periode]]

      # =====================================================================
      # Verify that o-c magnitude values are compatible for the best period
      # =====================================================================
      #
      # --- The first criterium is that the standard deviation (stdmodel) between
      #     observed and calculated magnitudes must be lower to a fraction
      #     of the standard deviation of the observed magnitudes (sigma).
      #     In other terms, the observed magnitudes must be attached to the
      #     calculated light curve.
      set res [yd_cour_final $phases $mags $bars $coefs $sigma]
      set magpobss [lindex $res 0]
      set stdmodel [lindex $res 1]
      set temoin [lindex $res 2]
      if {$temoin==0} {
         set ind_jdgoods [lindex $res 3]
         set ind_jdbads [lindex $res 4]
      }
      if {$temoin==1} {
         set ind_jdgoods ""
         set ind_jdbads [lindex $res 3]
      }
      if {$temoin==-1} {
         set ind_jdgoods [lindex $res 3]
         set ind_jdbads ""
      }
      #
      # --- compute the good phase/mag vectors
      set phasegoods_sans_flag ""
      set jdgoods_sans_flag ""
      set maggoods_sans_flag ""
      set bargoods_sans_flag ""
      set phasegoods_avec_flag ""
      set jdgoods_avec_flag ""
      set maggoods_avec_flag ""
      set bargoods_avec_flag ""
      set maggoods ""

      set ngood [llength $ind_jdgoods]
      for {set kk 0} {$kk<$ngood} {incr kk} {
            set indice [lindex $ind_jdgoods $kk]
            set indice [expr round($indice)]
            set flag [lindex $flags $indice]
            if {$flag==0} {
               lappend jdgoods_sans_flag [expr [lindex $jds $indice]-$jdphase0]
               lappend maggoods_sans_flag [lindex $mags $indice]
               lappend bargoods_sans_flag [expr [lindex $bars $indice]*2]
               lappend phasegoods_sans_flag [lindex $phases $indice]
               lappend maggoods [lindex $mags $indice]
            } else {
               lappend jdgoods_avec_flag [expr [lindex $jds $indice]-$jdphase0]
               lappend maggoods_avec_flag [lindex $mags $indice]
               lappend bargoods_avec_flag [expr [lindex $bars $indice]*2]
               lappend phasegoods_avec_flag [lindex $phases $indice]
               lappend maggoods [lindex $mags $indice]
            }
      }

      # --- compute the bad phase/mag vectors
      set phasebads_sans_flag ""
      set jdbads_sans_flag ""
      set magbads_sans_flag ""
      set barbads_sans_flag ""
      set phasebads_avec_flag ""
      set jdbads_avec_flag ""
      set magbads_avec_flag ""
      set barbads_avec_flag ""
      set nbad [llength $ind_jdbads]
      for {set kk 0} {$kk<$nbad} {incr kk} {
          set indice [lindex $ind_jdbads $kk]
          set indice [expr round($indice)]
          set flag [lindex $flags $indice]
          if {$flag==0} {
              lappend jdbads_sans_flag [expr [lindex $jds $indice]-$jdphase0]
              lappend magbads_sans_flag [lindex $mags $indice]
              lappend barbads_sans_flag [expr [lindex $bars $indice]*2]
              lappend phasebads_sans_flag [lindex $phases $indice]
          } else {
              lappend jdbads_avec_flag [expr [lindex $jds $indice]-$jdphase0]
              lappend magbads_avec_flag [lindex $mags $indice]
              lappend barbads_avec_flag [expr [lindex $bars $indice]*2]
              lappend phasebads_avec_flag [lindex $phases $indice]
          }
      }
      #
      # --- another constraint is the ratio nbad/(ngood+nbad) that should be <= 0.4
      set bad_factor [expr $nbad./($ngood+$nbad)]
      set bad_factor_limit 0.4
      if {$nobs>200} {
         set bad_factor_limit 0.7
      }
      if {$bad_factor>$bad_factor_limit} {
         error "Bad_factor = $bad_factor > $bad_factor_limit"
      }
      # --- The second criterium is that the amplitude (amplitude) of the
      #     calculated magnitudes corresponding the observed phases must be
      #     higher than the standard deviation of the observed magnitudes (sigma).
      #     In other terms, the observed magnitudes must be attached to the
      #     calculated light curve.

      set res [lsort -real $maggoods]
      set amplitude [expr [lindex $res end]-[lindex $res 0]]
      set res [yd_meansigma $maggoods]
      set sigmagood [lindex $res 1]
      # --- if the theoretical amplitude for observed phases is less than magnitude uncertainties, then it is not a good candidate
      if {$amplitude<$sigmagood} {
         error "Amplitude=$amplitude < sigma=$sigma"
      }
      set naverage [expr $ngood/$duree]
      #
      # =====================================================================
      # Verify that amplitude of the theoretical light curve is large enough
      # =====================================================================
      #
      set bars2 ""
      for {set kk 0} {$kk<=$nphasep} {incr kk} {
          lappend bars2 0.1
          #les barres d'erreur sont toutes egales (pas de problemes)
      }
      # --- for all measurements
      set res [yd_cour_final $phaseps $phaseps $bars2 $coefs $sigma]
      set magps [lindex $res 0]
      set res [lsort -real $magps]
      # on prend comme amplitude celle de la courbe ajustee
      #set amplitude_theo [expr [lindex $res end]-[lindex $res 0]]
      set amplitude [expr [lindex $res end]-[lindex $res 0]]
      if {$amplitude<0.1} {
         error "Amplitude_theo=$amplitude < 0.1"
      }
      # ---
      set nmagp [llength $magps]
      set magp1s ""
      set magp2s ""
      for {set kk 0} {$kk<$nmagp} {incr kk} {
         lappend magp1s [expr [lindex $magps $kk]-$sigma/2.]
         lappend magp2s [expr [lindex $magps $kk]+$sigma/2.]
      }
      # l'incertitude sur la periode
      if {$periode>20.} {
         set pasfreq $pasfreqlong
      } else {
         set pasfreq $pasfreqshort
      }
      set accu_per [expr $periode*$periode*$pasfreq]
      # pour que ca soit une fct plus generale
      set res [yd_reduit_nombre_digit $periode $accu_per]
      set periode [lindex $res 0]
      set accu_per [lindex $res 1]
      # Pour les coefs, JD_phase0 et l'amplitude
      set jdphase0 [format %.6f $jdphase0]
      set amplitude [format %.3f $amplitude]
      set stdmodel [format %.3f $stdmodel]
      set ncoef [llength $coefs]
      for {set k 0} {$k<$ncoef} {incr k} { lset coefs $k [format %.3f [lindex $coefs $k]] }
      #
      # ==============================================================
      # Test if it can be a nova
      # ==============================================================
      #
      # --- A nova has an incomplete phase range and a period > 8 days
      set isnova no
      set fadingrate 0.
      if {($duree<1.)&&($periode>8.)} {
         set nmagp [llength $magps]
         # --- search the first maximum of brightness
         set mag0 [lindex $magps 0]
         for {set kk 1} {$kk<$nmagp} {incr kk} {
            set mag1 [lindex $magps $kk]
            if {[expr $mag1-$mag0]>=0} {
               break
            }
            set mag0 $mag1
         }
         set kmax [expr $kk-1]
         set phase00 [lindex $phaseps $kmax]
         set mag00 [lindex $magps $kmax]
         # --- the nova must decrease early
         if {$phase00<0.25} {
            # --- search the following minimum of brightness
            set mag0 [lindex $magps [expr $kmax+1]]
            for {set kk [expr $kmax+2]} {$kk<$nmagp} {incr kk} {
               set mag1 [lindex $magps $kk]
               if {[expr $mag1-$mag0]<=0} {
                  break
               }
               set mag0 $mag1
            }
            set kmax [expr $kk-1]
            set phase11 [lindex $phaseps $kmax]
            set mag11 [lindex $magps $kmax]
            if {[expr $duree-0.15]<$phase11} {
               set isnova yes
               set fadingrate [expr ($mag11-$mag00)/($phase11-$phase00)/$periode]
            }
         }
      }
      #
      set nom_fich [file rootname [file tail $fichier]]
      #
      # ==============================================================
      # Create the ASCII file of that variable for WEB
      # ==============================================================
      #
      # --- Add the Fourier series developpement coefficients in the header
      set headerplus ""
      lappend headerplus [list PERIOD $periode]
      lappend headerplus [list PERIODMI $per_range_min]
      lappend headerplus [list PERIODMA $per_range_max]
      lappend headerplus [list PERIODOT $accu_per]
      lappend headerplus [list JDPHASE $jdphase0]
      lappend headerplus [list C1 [lindex $coefs end]]
      for {set l 1} {$l<=$n_arm} {incr l} {
         lappend headerplus [list A$l [lindex $coefs [expr 2*($l-1)  ] ] ]
         lappend headerplus [list B$l [lindex $coefs [expr 2*($l-1)+1] ] ]
      }
      lappend headerplus [list STDMODEL $stdmodel]
      photrel_tool_writevartxt "$pathhtm/$nom_fich.txt" $header $headerplus $data

      #
      # ==============================================================
      # Create a gif file for a graphical display for WEB
      # ==============================================================
      #
      set phasegood2s_sans_flag ""
      foreach phasegood  $phasegoods_sans_flag {
         lappend phasegood2s_sans_flag [expr 1.+$phasegood]
      }

      set phasegood2s_avec_flag ""
      foreach phasegood  $phasegoods_avec_flag {
         lappend phasegood2s_avec_flag [expr 1.+$phasegood]
      }

      set phasebad2s_sans_flag ""
      foreach phasebad  $phasebads_sans_flag {
         lappend phasebad2s_sans_flag [expr 1.+$phasebad]
      }

      set phasebad2s_avec_flag ""
      foreach phasebad  $phasebads_avec_flag {
         lappend phasebad2s_avec_flag [expr 1.+$phasebad]
      }

      # --- Graphic with BLT library
      plotxy::clf
      plotxy::figure 1
      #plotxy::setgcf 1 {{hide 1}}
      plotxy::plot $phasegoods_sans_flag $maggoods_sans_flag ro. 1.5 [list -ybars $bargoods_sans_flag]
      plotxy::setgcf 1 {{hold on}}
      if {$duree>1.} {
         plotxy::plot $phasegood2s_sans_flag $maggoods_sans_flag ro. 1.5 [list -ybars $bargoods_sans_flag]
      }
      plotxy::plot $phasegoods_avec_flag $maggoods_avec_flag k+. 1.5 [list -ybars $bargoods_avec_flag]
      plotxy::setgcf 1 {{hold on}}
      if {$duree>1.} {
         plotxy::plot $phasegood2s_avec_flag $maggoods_avec_flag k+. 1.5 [list -ybars $bargoods_avec_flag]
      }
      plotxy::bgcolor #FFFFFF
      plotxy::plotbackground #FFFFFF
      plotxy::xlabel "Phase"
      plotxy::ylabel "$filter magnitude"
      set per $periode
      #set perpm $periodepm
      set unit day
      if {$per<1.} {
         set per [expr 24.*$per]
         #set perpm [expr 24.*$perpm]
         set unit hour
         if {$per<1.} {
            set per [expr 60.*$per]
            #set perpm [expr 60.*$perpm]
            set unit min.
         }
      }
      set nom_fich [file rootname [file tail $fichier]]
      plotxy::title "$nom_fich P=[format %.4f $per] $unit"
      plotxy::ydir reverse
      plotxy::position {10 10 600 600}
      if {$nbad>0} {
         plotxy::plot $phasebads_sans_flag $magbads_sans_flag go. 1.5 [list -ybars $barbads_sans_flag]
         if {$duree>1.} {
            plotxy::plot $phasebad2s_sans_flag $magbads_sans_flag go. 1.5 [list -ybars $barbads_sans_flag]
         }
         plotxy::plot $phasebads_avec_flag $magbads_avec_flag k+. 1.5 [list -ybars $barbads_avec_flag]
         if {$duree>1.} {
            plotxy::plot $phasebad2s_avec_flag $magbads_avec_flag k+. 1.5 [list -ybars $barbads_avec_flag]
         }
      }
      plotxy::plot $phaseps $magps b- 0
      plotxy::plot $phaseps $magp1s b: 0
      plotxy::plot $phaseps $magp2s b: 0
      set axis [plotxy::axis]
      lset axis 0 0.0
      lset axis 1 1.5
      plotxy::axis $axis
      #plotxy::writegif "$pathhtm/$nom_fich.gif"

      # ---
      return $periode
   } else {
      error "Usage: photrel_cat2per file_cat file_mes ra dec filter ?codecam?"
   }
}

## @brief write a text files for the variable detection algorithm
#  @private
#
proc photrel_tool_writevartxt { filename header headeradds data } {

   set f [open "$filename" w]
   foreach ligne $header {
      set kwd [string range [lindex $ligne 0] 0 7]
      set passe no
      foreach headeradd $headeradds {
         set keyword [string range [lindex $headeradd 0] 0 7]
         if {$keyword==$kwd} {
            set passe yes
            break
         }
      }
      for {set k 1} {$k<9} {incr k} {
         set keyword "A$k"
         set kwd0 [string trim $kwd]
         if {$keyword==$kwd} {
            set passe yes
            break
         }
         set keyword "B$k"
         set kwd0 [string trim $kwd]
         if {$keyword==$kwd} {
            set passe yes
            break
         }
      }
      if {$passe=="no"} {
         puts $f $ligne
      }
   }
   foreach headeradd $headeradds {
      set keyword [string range [lindex $headeradd 0] 0 7]
      set ns [expr 9-[string length $keyword]]
      set blank [string range "          " 0 $ns]
      set value [lindex $headeradd 1]
      puts $f "${keyword}${blank}= $value "
   }
   puts $f "END "
   foreach ligne $data {
      puts $f $ligne
   }
   close $f
}

## @brief démonstration de simuliage2 et de quelques fonctions de @ref photrel.tcl
#  pour une étoile variable
#  @pre la catalogue MICROCAT doit être installé et configuré dans les catalogues
#
proc photrel_demo { } {

   set catalog MICROCAT
   set catalogPath $::conf(rep_userCatalogMicrocat)

   simulimage2 test [mc_date2listdates 2011-11-11T00:00:00 0.021 100] {FOURIER 164.630566 67.529504 2011-11-08T00:00:00 0.28 12.5 -0.86 -0.53 -0.45 0.32 0.039 0.021} 200 200 164.589733 67.515479 13.5 13.5 0.84587 $catalog $catalogPath 90 2.5 0.25 R 20.0 0.07 1.8 8.5  1 1000 0.5 0.6 0.85 1 0
   photrel_wcs2cat test 100 new
   photrel_cat2var test
   photrel_cat2per test test 164.630637 67.529499 C 0

}
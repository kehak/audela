
# Procedures des traitements géométriques
# Lancement en console : source $audace(rep_scripts)/spcaudace/spc_geom.tcl

# Mise a jour $Id: spc_geom.tcl 14525 2018-11-09 18:22:10Z bmauclaire $



####################################################################
# Procédure de découpe puis raboutage de 2 lampes de calibration pour calibration BR
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20120122
# Date modification : 20120202
####################################################################

proc spc_lampmerge { args } {
   global conf
   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs == 2 } {
      set sp_long [ lindex $args 0 ]
      set sp_short [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_lampmerge spectre_lamp_long_exposed spectre_lamp_short_exposed\n"
      return ""
   }

   #--- Get infos :
   buf$audace(bufNo) load "$audace(rep_images)/$sp_long"
   set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
   set xcrop [ expr int($naxis1/2) ]
   set xrestant [ expr $naxis1-$xcrop ]
   buf$audace(bufNo) noffset 0

   #--- Mise a zero des pixels de la partie rouge du spectre longue pose :
   #for { set i [ expr $xcrop+1 ] } { $i<=$naxis1 } { incr i } {
   #   for { set j 1 } { $j<=$naxis2} { incr j } {
   #      buf$audace(bufNo) setpix [ list $i $j ] 0
   #   }
   #}
   buf$audace(bufNo) imaseries "TRANS trans_x=$xrestant trans_y=0"
   buf$audace(bufNo) imaseries "TRANS trans_x=-$xrestant trans_y=0"

   #--- Addition du spectre courte pose :
   buf$audace(bufNo) add "$sp_short" 0
   buf$audace(bufNo) save "$audace(rep_images)/lamp_merged"

   #--- Fin de script :
   file delete -force "$audace(rep_images)/${sp_short}_gain$conf(extension,defaut)"
   loadima lamp_merged
   return "lamp_merged$conf(extension,defaut)"

   #--- Suite : tracer le profil de raies
   # spc_profily lamp_merged [ expr int($naxis1/2) ] 160
}
#**********************************************************************************#



####################################################################
# Procédure de determination des bords de la base d'une raie.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-02-2011
# Date modification : 07-02-2011, 30-12-2015
# Arguments : spectre 2D fits de lampe
####################################################################

proc spc_linewidth { args } {
   global audace conf spcaudace
   #set intervalle_centre 200.0
   set intervalle_centre $spcaudace(largeur_lcentrale)

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set filename [ file rootname [ lindex $args 0 ] ]
      set methfindline "fitting"
   } elseif { $nbargs==2 } {
      set filename [ file rootname [ lindex $args 0 ] ]
      set methfindline [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_linewidth spectre_2D_lampe_fits ?methode_recherche_raies(fitting/corr)?\n"
      return ""
   }

   #--- Efface les mots clef CDELT1 et CRVAL1 :
   set filenamespc [ spc_delcal "$filename" ]
   
   #--- Binning de toute l'image :
   buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
   set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
   set xmid [ expr round($naxis1/2.) ]
   set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
   buf$audace(bufNo) imaseries "biny y1=1 y2=$naxis2 height=1"
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_spc"
   set icont [ lindex [ buf$audace(bufNo) stat ] 4 ]
   buf$audace(bufNo) bitpix short


   #--- Détermiantion du centre de la raie la plus centrale :
   if { $methfindline=="corr" } {
      set liste_raies [ spc_findbiglineslamp ${filenamespc}_spc ]
   } else {
      set liste_raies [ spc_findbiglines ${filenamespc}_spc e ]
      #-- Comportement par defaut ;
   }
   
   set liste_ecart [ list ]
   foreach raie $liste_raies {
      set xraie [ lindex $raie 0 ]
      lappend liste_ecart [ list $xraie [ expr abs($xraie-$xmid) ] [ lindex $raie 1 ] ]
   }
   set liste_ecart [ lsort -increasing -index 1 $liste_ecart ]
   #-- Selectionne la plus lumineuse parmi les 2 raies plus proches du centre :
   set liste_select [ list [ lindex $liste_ecart 0 ] [ lindex $liste_ecart 1 ] ]
   #- Tri les raies par ordre d'intensite decroissante :
   set liste_select [ lsort -decreasing -index 2 $liste_select ]
   #::console::affiche_resultat "LE=$liste_ecart\n"
   #-- Extrait l'absisse de la raie centrale :
   set xraie_centre [ expr round([ lindex [ lindex $liste_select 0 ] 0 ]) ]
   # ::console::affiche_resultat "LE=$liste_ecart\n raiec=$xraie_centre\n"
   #-- Memorise l'abscisse de la raie centrale dans SPC_XCLM :
   # buf$audace(bufNo) load "$audace(rep_images)/$filename"

   if { 1==0 } {
      set xdeb [ expr round($naxis1/2.0-$intervalle_centre*$naxis1) ]
      set xfin [ expr round($naxis1/2.0+$intervalle_centre*$naxis1) ]
      set x_raiecentrale [ spc_centergauss "${filenamespc}_spc" $xdeb $xfin e ]
   }
    
   #--- Determination de la largeur de base de la raie centrale :
   #-- Detection du bord lorsque i>=5% du continuum
   #set imin [ expr 1.05*$icont ]
   set spcdata [ spc_fits2data "${filenamespc}_spc" ]
   set abscisses [ lindex $spcdata 0 ]
   set ordonnees [ lindex $spcdata 1 ]
   set xraiec_index [ lsearch $abscisses $xraie_centre ]
   
   #-- Recherche du bord droit :
   set intensite [ lindex $ordonnees $xraiec_index ]
   #- Permet augmenter le bord droit pour un meilleur calcul du bord haut apres ;
   set icontm [ expr $icont*0.99 ]
   set k 0
   while { $intensite>$icont } {
      set intensite [ lindex $ordonnees [ expr $xraiec_index+$k ] ]
      incr k
   }
   set x_bord_droit [ expr $xraiec_index+2*$k+1+int(0.005*$naxis1) ]
   
   #-- Recherche du bord gauche :
   set intensite [ lindex $ordonnees $xraiec_index ]
   set k 0
   while { $intensite>$icont } {
      set intensite [ lindex $ordonnees [ expr $xraiec_index-$k ] ]
      incr k
   }
   set x_bord_gauche [ expr $xraiec_index-2*$k+1 ]

   #--- Gestion du cas ou x_bord_gauche=x_bord_droit :
   if { $x_bord_gauche==$x_bord_droit } {
      ::console::affiche_resultat "Détermination par intercorrelation...\n"
      file delete -force "$audace(rep_images)/${filenamespc}_spc$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${filenamespc}$conf(extension,defaut)"
      set resultat2 [ spc_linewidth "$filename" "corr" ]
      set x_bord_gauche [ lindex $resultat2 0 ]
      set x_bord_droit [ lindex $resultat2 1 ]
   }

   #--- Gestion de la valeur max de x_bord_droit :
   if { $x_bord_droit>$naxis1 } { set x_bord_droit [ expr $naxis1-5 ] }

   #--- Memorise la position des sbords dans des mots clef :
   #buf$audace(bufNo) load "$audace(rep_images)/$filename"
   #buf$audace(bufNo) setkwd [ list "SPC_XCLE" $x_bord_gauche int "Left edge of most central line" "pixel" ]
   #buf$audace(bufNo) setkwd [ list "SPC_XCRI" $x_bord_droit int "Right edge of most central line" "pixel" ]
   #buf$audace(bufNo) save "$audace(rep_images)/$filename"

   
   #--- Fin du script :
   set results [ list $x_bord_gauche $x_bord_droit ]
   ::console::affiche_resultat "Bord gauche=$x_bord_gauche ; Bord droit=$x_bord_droit\n"
   file delete -force "$audace(rep_images)/${filenamespc}_spc$conf(extension,defaut)"
   file delete -force "$audace(rep_images)/${filenamespc}$conf(extension,defaut)"
   return $results
}
#****************************************************************************



####################################################################
# Procédure de determination des bords de la base d'une raie.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-11-2015
# Date modification : 08-11-2015
# Arguments : spectre 2D fits de lampe
####################################################################

proc spc_lineheigh { args } {
   global audace conf
   set intervalle_centre 200.0

   if { [ llength $args ]==3 } {
      set filenamespc [ file rootname [ lindex $args 0 ] ]
      set x_bord_gauche [ lindex $args 1 ]
      set x_bord_droit [ lindex $args 2 ]

      #--- Determination de la hauteur de la raie a encadrer :
      #-- Binning horizontal :
      buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
      set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
      set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
      #- Genere des problemes de detections par la suite bien que cela protege des cosmics :
      # buf$audace(bufNo) imaseries "medianx x1=$x_bord_gauche x2=$x_bord_droit width=1"
      #- Retour au binx : 
      buf$audace(bufNo) imaseries "binx x1=$x_bord_gauche x2=$x_bord_droit width=20"
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_spc"
      set icont [ lindex [ buf$audace(bufNo) stat ] 4 ]
      buf$audace(bufNo) bitpix short

      #--- Détermine le centroide vertical de la raie et son intensite :
      set xmid [ buf$audace(bufNo) centro [ list 1 [ expr round(0.05*$naxis2) ] 1 [ expr round(.95*$naxis2) ] ] ] 
      set icont [ lindex [ buf$audace(bufNo) stat ] 2 ]
      buf$audace(bufNo) bitpix short
      #::console::affiche_prompt "icont=$icont ; xmid=$xmid\n"

      #--- Extrait les intensites :
      #- 1,1 : en bas a gauche
      buf$audace(bufNo) load "$audace(rep_images)/${filenamespc}_spc"
      set intensites [ list ]
      for { set k 1 } { $k<=$naxis2 } { incr k } {
         lappend intensites [ lindex [ buf$audace(bufNo) getpix [ list 1 $k ] ] 1 ]
      }

      #--- Détemination des limites verticales de la raie en partant du centroide :
      set icontm [ expr 0.7*$icont ]
      set xcentro [ expr round([ lindex $xmid 1 ]) ]
      set y_bas 0
      #-- Limite basse : le profil est une porte au centree du capteur
      #- Cas fente courte :
      for { set k $xcentro } { $k>=0 } { incr k -1 } {
         set intensite [ lindex $intensites $k ]
         if { $intensite<$icontm } {
            set y_bas [ expr round($k+$naxis2*0.02) ]
            break
         }
      }
      #- Cas fente longue : le profil est une cloche sur toute la hauteur
      if { $y_bas==0 } {
         set y_bas [ expr round($naxis2*0.05) ]
      }
      #::console::affiche_prompt "Y_bas=$y_bas\n"

      #-- Limite haute :
      #- Cas fente courte : le profil est une porte au centree du capteur
      set y_haut 0
      for { set k $xcentro } { $k<$naxis2 } { incr k } {
         #set intensite [ lindex [ buf$audace(bufNo) getpix [ list 1 $k ] ] 1 ]
         set intensite [ lindex $intensites $k ]
         if { $intensite<$icontm } {
            set y_haut [ expr round($k-$naxis2*0.02) ]
            break
         }
      }
      #- Cas fente longue : le profil est une cloche sur toute la hauteur
      if { $y_haut==0 } {
         set y_haut [ expr round($naxis2*0.95) ]
      }
      #::console::affiche_prompt "Y_haut=$y_haut\n"

      #-- Fin :
      ::console::affiche_resultat "Bord inférieur=$y_bas ; Bord supérieur=$y_haut\n"
      file delete -force "$audace(rep_images)/${filenamespc}_spc$conf(extension,defaut)"

      #--- Fin du script :
      set results [ list $y_bas $y_haut ]
      return $results
   } else {
      ::console::affiche_erreur "Usage: spc_lineheigh spectre_2D_lampe_fits x_bord_gauche x_bord_droit\n"
   }
}
#****************************************************************************


####################################################################
# Procedure de rotation de 180° d'un profil de raies ou d'une image
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits du profil de raie spatial
####################################################################

proc spc_rot180 { args } {

    global audace caption
    global conf

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filenamespc [ lindex $args 0 ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filenamespc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n"
	    return 0
	}

	#-- Traitement :
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	buf$audace(bufNo) mirrorx
	#visu
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_flip$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_flip$conf(extension,defaut).\n"
	return ${filespc}_flip
    } else {
	::console::affiche_erreur "Usage: spc_rot180 fichier_fits\n"
    }
}
#****************************************************************************


####################################################################
# Procedure de rotation de 180° d'un profil de raies ou d'une image
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 20-09-2006
# Arguments : fichier fits du profil de raie spatial
####################################################################

proc spc_flip { args } {

    global audace
    global conf

    if {[llength $args] == 1} {
	set filenamespc [ lindex $args 0 ]
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	buf$audace(bufNo) mirrorx
	set filespc [ file rootname $filenamespc ]
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_flip$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_flip$conf(extension,defaut).\n"
	return ${filespc}_flip
    } else {
	::console::affiche_erreur "Usage: spc_flip fichier_fits\n\n"
    }
}
#****************************************************************************



####################################################################
# Procedure de rotation d'un angle alpha d'un spectre spatial 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 18-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits de l'image, coordonnées de 2 points pris sur l'axe incliné à redresser horizontalement
# A faire : determiner le photocentre autour des points M1 et M2 choisis.
####################################################################

proc spc_tilt { args } {
#proc spc_tilt { { filenamespc ""} { x1 ""} { y1 ""} { x2 ""} { y2 ""} }

  global audace
  global conf
  set pi [expr acos(-1.0)]
  #--- Les angles pour les oprations trigonometriques sont en degres.

  if {[llength $args] == 5} {
    set filenamespc [ lindex $args 0 ]
    set x1 [ lindex $args 1 ]
    set y1 [ lindex $args 2 ]
    set x2 [ lindex $args 3 ]
    set y2 [ lindex $args 4 ]

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
    set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]

    if { $x1 < $x2 } {
    #--- Point M1 à gauche de M2
	#set xinf $x1
	set yinf $y1
	set angle [expr 180/$pi*atan(1.0*($y1-$y2)/($x2-$x1))]
    } else {
    #--- Point M1 à droite de M2
	#set xinf $x2
	set yinf $y2
	set angle [expr 180/$pi*atan(1.0*($y2-$y1)/($x1-$x2))]
    }

    #--- Angles>0 vers le haut de l'image
    set xinf 1
    #set newnaxis2 [expr $naxis2+int($naxis1*abs(tan($angle*$pi/180)))+1]
    #buf$audace(bufNo) setkwd [list "NAXIS2" "$newnaxis2" int "" ""]
    buf$audace(bufNo) rot $xinf $yinf $angle
    ::console::affiche_resultat "Rotation d'angle ${angle}° autour de ($xinf,$yinf).\n"

    #--- Visualisation du resultat
    #visu
    set listeseuils [buf$audace(bufNo) autocuts]
    set seuilb [expr 0.5*[lindex $listeseuils 0]]
    set seuilh [lindex $listeseuils 0]
    set seuils [list $seuilh $seuilb]
    #visu1 cut $seuils

    #--- Modification du nom du fichier de sortie
    set filespc [ file rootname $filenamespc ]
    buf$audace(bufNo) setkwd [ list "SPC_TILT" $angle float "Tilt angle" "degres" ]
    buf$audace(bufNo) setkwd [ list "SPC_TILX" $xinf int "Tilt X center" "pixel" ]
    buf$audace(bufNo) setkwd [ list "SPC_TILY" $yinf int "Tilt Y center" "pixel" ]
    buf$audace(bufNo) save "$audace(rep_images)/${filespc}_tilt$conf(extension,defaut)"
    #loadima ${filespc}_tilt$conf(extension,defaut)
    ::console::affiche_resultat "Image sauvée sous ${filespc}_tilt$conf(extension,defaut).\n"
  } else {
     ::console::affiche_erreur "Usage: spc_tilt fichier_fits x1 y1 x2 y2 (pris sur le spectre)\n\n"
  }
}
#****************************************************************************



####################################################################
# Correction géométrique du "spc_smile" d'un spectre spatial 2D
#  (déformation en courbure)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 21-02-2005
# Date modification : 27-12-2005
# Arguments : fichier fits de l'image, coordonnées de 3 points pris sur l'axe curvé à redresser horizontalement
# A faire : determiner le photocentre autour des points M1, M2 et M3 choisis.
####################################################################

proc spc_smile { args } {
  global audace
  global conf

  if {[llength $args] == 7} {
    set filenamespc [ lindex $args 0 ]
    set x1 [ lindex $args 1 ]
    set y1 [ lindex $args 2 ]
    set x2 [ lindex $args 3 ]
    set y2 [ lindex $args 4 ]
    set x3 [ lindex $args 5 ]
    set y3 [ lindex $args 6 ]

    set listecoefs [ pil2 $x1 $y1 $x2 $y2 $x3 $y3 ]
    set a [ lindex $listecoefs 0 ]
    set b [ lindex $listecoefs 1 ]
    set c [ lindex $listecoefs 2 ]

    # Calcul des coordonnées du point extremum de la parabole
    set xextrem [ expr -1.0*$b/(2*$a) ]
    set yextrem [ expr ($b^2*($a-2)+4*$a*$c)/(4*$a) ]

    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
    set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]

    # A TERMINER
  } else {
    ::console::affiche_erreur "Usage: spc_smile fichier_fits x1 y1 x2 y2 x3 y3 (pris sur le spectre)\n\n"
  }
}
#****************************************************************************



####################################################################
#  Procedure de registration de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 27-12-2005/06-10-09
# Arguments : nom générique des fichiers .fit dont la forme est nom-n°.fit
####################################################################

proc spc_register { args } {
   global audace
   global conf

   if { [llength $args] == 1 } {
       set filename [ lindex $args 0 ]
       #- Détection fragile : * doit etre un nombre de 0 a n. glob -nocomplain ?
       #- Améliorée le 14-08-2006
       set fileliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${filename}\[0-9\]$conf(extension,defaut) ${filename}\[0-9\]\[0-9\]$conf(extension,defaut) ${filename}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
       # Les fichiers de fileliste contiennent aussi le nom du repertoire
       set nb_file [ llength $fileliste ]
       set fichier1 [file tail [ lindex $fileliste 0 ]]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       #set windowcoords [ list 1 1 3 $naxis2 ]
       #-- Gestion des bordures lumineuses dues au prétraitement :
       set y1 [ expr int(0.05*$naxis2) ]
       set y2 [ expr int(0.95*$naxis2) ]
       set windowcoords [ list 1 $y1 1 $y2 ]

       #-- Initialisation de variables :
       set ycoords ""
       set k 0
       set kk 1

       #::console::affiche_resultat "Liste : $fileliste\n"
       #--- Effectue le binning des colonnes et détermine le centroïde en Y du spectre 2D
       set fichier ""
       foreach rfichier $fileliste {
	   set fichier [file tail $rfichier]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   #-- Méthode du 27-12-2005 :
	   # buf$audace(bufNo) binx 1 $naxis1 3
	   # set ycentre [lindex [buf$audace(bufNo) centro $windowcoords] 1]
	   #-- Méthode du 06-10-09 :
	   buf$audace(bufNo) imaseries "BINX x1=1 x2=$naxis1 height=1"
	   set ycentre [ lindex [ buf$audace(bufNo) fitgauss $windowcoords ] 5 ]
	   lappend ycoords $ycentre
       }

       # Recale chaque spectre 2D verticalement par rapport au premier
       ::console::affiche_resultat "Recalage de $nb_file images...\n"
       set k 0
       set kk 1
       set ycentre [ lindex $ycoords 0 ]
       set fichier ""
       set rfichier ""
       foreach rfichier $fileliste {
	   set fichier [ file rootname [file tail $rfichier] ]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   set yi [ lindex $ycoords $k ]
	   set dy [ expr $ycentre-$yi ]
	   buf$audace(bufNo) imaseries "TRANS trans_x=0 trans_y=$dy"
	   #-- EXpreqssion reguliere pouvant etre fragile !
	   #regexp {(.+)\-?[0-9]+} $fichier match nomfichier
	   #buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_r-$kk$conf(extension,defaut)"
	   buf$audace(bufNo) save "$audace(rep_images)/${filename}-r-$kk$conf(extension,defaut)"
	   ::console::affiche_resultat "Spectre redressé sauvé sous ${filename}-r-$kk\n"
	   incr k
	   incr kk
       }
       #::console::affiche_resultat "Images sauvées sous ${nomfichier}-r-x$conf(extension,defaut)\n"
       #return ${nomfichier}_r-
       ::console::affiche_resultat "Images sauvées sous ${filename}-r-\n"
       return ${filename}-r-
   } else {
       ::console::affiche_erreur "Usage: spc_register nom_générique_fichiers\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de registration horizontale de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-03-16
# Date modification : 2017-04-10
# Arguments : nom_spectre_lampe nom_générique_spectres_objet
####################################################################

proc spc_registerh { args } {
   global audace conf spcaudace
   set largeur_recherche $spcaudace(largeur_recherche_raie)
   
   set nbargs [ llength $args ]
   if { $nbargs <= 3 } {
      if { $nbargs == 2 } {
         set nom_lampes [ lindex $args 0 ]
         set nomg_objet [ lindex $args 1 ]
      } elseif { $nbargs == 3 } {
         set nom_lampes [ lindex $args 0 ]
         set nomg_objet [ lindex $args 1 ]
         set wincoords [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_registerh nom_spectre_lampe ?nom_générique_spectres? ?coordonnees_zone_du_spectre?\n\n"
         return ""
      }

      #-- Argument supplementaire : position raie utilisee en calib ?
      
      #--- Crée la liste des spectres de la lampe et de l'objet (pretraite, smilex et tilt) :
      #-- Détermine le nom générique des spectres de la lampe :
      #set nom_lampe_noext [ file rootname "$nom_lampes" ]
      #- La regle du nommage des lampes de calib : finissent par un chiffre
      #regexp {(.+\-?)[0-9]+} "$nom_lampe_noext" match nomg_lampe
      #set nb_lampes 0
      
      buf$audace(bufNo) load "$audace(rep_images)/$nom_lampes"
      if { [ lindex [ buf$audace(bufNo) getkwd "SPC_LNM" ] 1 ] != "" } {
         set nom_lampe_orig [ lindex [ buf$audace(bufNo) getkwd "SPC_LNM" ] 1 ]
         regexp {(.+)\-?[0-9]+} "$nom_lampe_orig" match nomg_lampe
         set nb_lampes 0
      } else {
         if { [ catch { regexp {(.+)\-?[0-9]+} "$nom_lampes" match nomg_lampe } ]==0 } {
            set nomg_lampe "$nom_lampes"
         } else {
            regexp {(.+)\-?[0-9]+} "$nom_lampes" match nomg_lampe
         }
         set nb_lampes 1
      }
      ::console::affiche_resultat "Nom générique des spectres de lampe : $nomg_lampe\n" 

      
      #-- Liste des spectres :
      if { $nb_lampes==0 } {
         set lampesliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nomg_lampe}\[0-9\]$conf(extension,defaut) ${nomg_lampe}\[0-9\]\[0-9\]$conf(extension,defaut) ${nomg_lampe}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_lampes [ llength $lampesliste ]
      } else {
         set lampesliste [ list "$nomg_lampe" ]
      }
      set spectresliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nomg_objet}\[0-9\]$conf(extension,defaut) ${nomg_objet}\[0-9\]\[0-9\]$conf(extension,defaut) ${nomg_objet}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
      set nb_spobjet [ llength $spectresliste ]


      #set spobj1 [ lindex $spectresliste 0 ]
      #regexp {(.+)\-?[0-9]+} "$spobj1" match nomg_objet

      #--- Corrections géométriques des spectres de la lampe :
      #-- Récupère les coéfficients de déformation depuis le premier spectre d'objet :
      ::console::affiche_resultat "\n\n**** Corrections géométriques du spectre de la lampe de calibration ****\n"
      set spc_obj [ file tail [ lindex $spectresliste 0 ] ]
      buf$audace(bufNo) load "$audace(rep_images)/$spc_obj"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_TILT" ] !=-1 } {
         set angle [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
         set pente [ expr tan($angle*acos(-1.0)/180.) ]
         set flag_tilt 1
      } else {
         set flag_tilt 0
      }

      #-- Smilex :
      if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
         set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
         set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
         ::console::affiche_resultat "\n** Correction de la courbure des raies (smile selon l'axe x)... **\n"
         set lampesmilex [ spc_smileximgs $nomg_lampe $spc_ycenter $spc_cdeg2 ]
         set flag_smilex 1
      } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
         set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
         ::console::affiche_resultat "\n** Correction de l'inclinaison des raies (slant)... **\n"
         set lampesmilex [ spc_slant2imgs $nomg_lampe $pente ]
         set flag_smilex 1
      } else {
         ::console::affiche_resultat "\n** Aucune correction géométrique nécessaire. **\n"
         set lampesmilex "$nomg_lampe"
         set flag_smilex 0
      }

      #-- Tilt :
      if { $flag_tilt==1 } {
         for { set i 1 } { $i<=$nb_lampes } { incr i } {
            set fsortie [ spc_tilt3 [ lindex $lampesliste [ expr $i-1 ] ] $pente ]
            file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${nomg_lampe}-tilt-$i$conf(extension,defaut)"
         }
      } else {
         set i 1
         foreach lampe $lampesliste {
            file copy -force "$lampe" "$audace(rep_images)/${nomg_lampe}-tilt-$i$conf(extension,defaut)"
            incr i
         }
      }

      #--- Crée un profil de raies des spectres de la lampe :
      #-- W : travaille pour l'instant qu'avec 2 spectres de lampe
      #-- Extrait le profil de raies :
      #- Lampe 1 :
      set somme_spobj [ bm_smean $nomg_objet ]
      if { $nbargs==2 } {
         set profil_lampe1 [ spc_profillampe $somme_spobj ${nomg_lampe}-tilt-1 "o" ]
      } elseif { $nbargs==3 } {
         set profil_lampe1 [ spc_profillampezone ${nomg_lampe}-tilt-1 $wincoords ]
      }
      #- Last lampe :
      if { $nbargs==2 } {
         set profil_lampe2 [ spc_profillampe $somme_spobj ${nomg_lampe}-tilt-$nb_lampes "o" ]
      } elseif { $nbargs==3 } {
         set profil_lampe2 [ spc_profillampezone ${nomg_lampe}-tilt-$nb_lampes $wincoords ]
      }
      #::console::affiche_resultat "Lampes (nb=$nb_lampes) : $profil_lampe1 ; $profil_lampe2\n"
      
      #-- Détermination du centre de la premiere raie utilisée pour la calibration : FRAGILE
      if { $spcaudace(onlyslant)==1 } {
         set nomg_objet_sans_tiret [ string trimright "$nomg_objet" "--t--tilt--slt" ] ; # pas -slt
      } elseif { $spcaudace(onlyslant)==0 } {
         set nomg_objet_sans_tiret [ string trimright "$nomg_objet" "--t--tilt-slx" ]
      }
      set nom_lampe_calibree "lampe_redressee_calibree-${nomg_objet_sans_tiret}"
      ::console::affiche_resultat "Nom du spectre 1D de la lampe calibrée : $nom_lampe_calibree\n"

      #-- Lecture de la liste des raies utilisées pour la calibration :
      buf$audace(bufNo) load "$audace(rep_images)/$nom_lampe_calibree$conf(extension,defaut)"
      set listemotsclefcal [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclefcal "SPC_LCA1" ] !=-1 } {
         set lcal1 [ lindex [ buf$audace(bufNo) getkwd "SPC_LCA1" ] 1 ]
      } elseif { [ lsearch $listemotsclefcal "SPC_LCAL" ] !=-1 } {
         set lcal1 [ lindex [ buf$audace(bufNo) getkwd "SPC_LCAL" ] 1 ]
      } else {
         ::console::affiche_erreur "Aucun mot cléf SPC_LCA1 ou SPC_LCAL présent dans $nom_lampe_calibree\n"
         return ""         
      }

      
      #if { [ catch { regexp {([0-9]+)\.[0-9]+\s.+} "$lcal1" match lambda_raie_prevue } ]==0 } {
      #   ::console::affiche_erreur "Aucune raie trouvée dans SPC_LCA1 : $lcal1 \n"
      #   return ""
      #} else {
         regexp {([0-9]+)\.[0-9]+\s.+} "$lcal1" match lambda_raie_prevue
         ::console::affiche_resultat "Recherche de la raie autour du pixel $lambda_raie_prevue\n"
      #}
      
      #- Mesure de l'abscisse de cette raie dans la 1iere lampe :
      buf$audace(bufNo) load "$audace(rep_images)/$profil_lampe1"
      set abscisselinemax1 [ lindex [ buf$audace(bufNo) fitgauss [ list [ expr $lambda_raie_prevue-$largeur_recherche ] 1 [ expr $lambda_raie_prevue+$largeur_recherche ] 1 ] ] 1 ]
      
      #- Mesure de l'abscisse de cette raie dans la 2ieme lampe :
      buf$audace(bufNo) load "$audace(rep_images)/$profil_lampe2"
      set abscisselinemax2 [ lindex [ buf$audace(bufNo) fitgauss [ list [ expr $lambda_raie_prevue-$largeur_recherche ] 1 [ expr $lambda_raie_prevue+$largeur_recherche ] 1 ] ] 1 ]
      ::console::affiche_resultat "Abscisses de la raie dans les 2 lampes extrémales : $abscisselinemax1 ; $abscisselinemax2\n"
      
      if { 1==0 } {
         #-- Détection des raies les plus brillantes :
      #- Liste des coupes (x,I) et sélectionne la plus brillante de la 1iere lampe :
      set listeraies [ spc_findbiglines $profil_lampe1 e ]
      #- Selection des raies dont I>=0.1*Imax et trie selon les abscisses :
      set listeraies [ lsort -decreasing -real -index 1 [ spc_selectstronglines $listeraies ] ]
      set abscisselinemax1 [ lindex [ lindex $listeraies 0 ] 0 ]
      ::console::affiche_resultat "Raies de calibration sélectionnées : $listeraies dont la plus intense est $abscisselinemax1\n"
      #- Liste des coupes (x,I) et sélectionne la plus brillante de la 2ieme lampe :
      set listeraies [ spc_findbiglines $profil_lampe2 e ]
      #- Selection des raies dont I>=0.1*Imax et trie selon les abscisses :
      set listeraies [ lsort -decreasing -real -index 1 [ spc_selectstronglines $listeraies ] ]
      set abscisselinemax2 [ lindex [ lindex $listeraies 0 ] 0 ]
      ::console::affiche_resultat "Raies de calibration sélectionnées : $listeraies dont la plus intense est $abscisselinemax2\n"
      }

      
      #--- Détermine l'équation linéaire de la loi du décalage horizontal en pixel au cours du temps :
      #-- Calcul l'écart en pixel la raie la plus braillante entre ces 2 spectres :
      #set ecartx [ expr $abscisselinemax2-$abscisselinemax1 ]
      #-- Extrait la date du premier et dernier spectre de lampe :
      buf$audace(bufNo) load "$audace(rep_images)/$profil_lampe1"
      set date1 [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
      buf$audace(bufNo) load "$audace(rep_images)/$profil_lampe2"
      set date2 [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]

      #-- Détermine l'équation de la loi de décalage : decalage=a+b*temps
      set coefs [ lindex [ spc_ajustdeg1 [ list $date1 $date2 ] [ list $abscisselinemax1 $abscisselinemax2 ] .1 ] 0 ]
      set a [ lindex $coefs 0 ]
      set b [ lindex $coefs 1 ]
      ::console::affiche_resultat "Equation du recalage horizontal : $a+$b*Temps\n"

      #--- Calcul de décalage horizontal des spectres et le corrige :
      ::console::affiche_resultat "\nRecalage horizontal de $nb_spobjet sepctres...\n"
      for { set i 1 } { $i<=$nb_spobjet } { incr i } {
         set nomspobj [ lindex $spectresliste [ expr $i-1 ] ]
         buf$audace(bufNo) load "$nomspobj"
         set date [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
         set deltax [ expr -1.*($a+$date*$b-$abscisselinemax1) ]
         set b_format [ format "%9.6f" $b ]
         buf$audace(bufNo) imaseries "TRANS trans_x=$deltax trans_y=0"
         buf$audace(bufNo) setkwd [ list "SPC_REGH" "Yes" string "Horizontal reg: $a+$b_format*T" ""]
         buf$audace(bufNo) save "$audace(rep_images)/${nomg_objet}-regh-$i"
      }

      #--- Nettoyage des fichiers temporaires :
      delete2 "${nomg_lampe}-tilt-" $nb_lampes
      if { $flag_smilex==1 } {
         delete2 "$lampesmilex" $nb_lampes
      }
      file delete -force "$audace(rep_images)/$somme_spobj$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${nomg_lampe}-tilt-1_spc$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${nomg_lampe}-tilt-${nb_lampes}_spc$conf(extension,defaut)"

      #--- Affichage du résultat :
      ::console::affiche_resultat "Fichiers recalés horizontalement sauvés sous ${nomg_objet}-regh-\n"
      return "${nomg_objet}-regh-"
   } else {
       ::console::affiche_erreur "Usage: spc_registerh nom_spectre_lampe nom_générique_spectres\n\n"
   }
}
####################################################################




####################################################################
#  Procedure de rotation automatique de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 29-10-2005/27-12-2005/15-08-2006/13-02-07
# Arguments : fichier .fit
# Heuristique : si l'angle est supérieur a 6°, l'angle calculé ne correspond pas à la réalité de l'inclinaison du spectre.
####################################################################

proc spc_tiltauto { args } {
   global audace caption spcaudace
   global conf

   set pi [expr acos(-1.0)]

   if {[llength $args] <= 1} {
       if {[llength $args] == 1} {
	   set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set filename $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
	   return 0
       }

      set results [ spc_findtilt "$filename" ]
      set fileout [ spc_tilt2 "$filename" [ lindex $results 0 ] [ lindex $results 1 ] [ lindex $results 2 ] ]
      ::console::affiche_resultat "Spectre pivoté de [ lindex $results 0 ]° sauvé sous $fileout\n"
      return "$fileout"
   } else {
       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
   }
}
####################################################################


####################################################################
#  Procedure de rotation automatique de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 29-10-2005/27-12-2005/15-08-2006/13-02-07
# Arguments : fichier .fit
# Heuristique : si l'angle est supérieur a 6°, l'angle calculé ne correspond pas à la réalité de l'inclinaison du spectre.
####################################################################

proc spc_tiltauto_old { args } {
   global audace caption spcaudace
   global conf

   set pi [expr acos(-1.0)]

   if {[llength $args] <= 1} {
       if {[llength $args] == 1} {
	   set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set filename $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
	   return 0
       }

       #--- Traitement :
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]

       #--- Algo de detection : binx aux bords droit et gauche sur une largeur de 1/100 de celle de l'image.
       set largeur [ expr $naxis1/100 ]
       set windowcoords [ list 1 1 3 $naxis2 ]

       #--- Algo : determine le centre des taches du bord gauche et droit et calcul l'angle.
       #- Methode un peu fragile : trouve parfois un angle important (4 ou 15°) alors que ce n'est pas le cas.
       #-- Binning des colonnes à l'extrême gauche de l'image
       # buf$audace(bufNo) binx [expr $largeur+1] [expr 2*$largeur] 3
       buf$audace(bufNo) imaseries "medianx x1=[expr $largeur+1] x2=[expr 2*$largeur] width=3"
       set x1 [ expr int(1.5*$largeur) ]
       set y1 [lindex [buf$audace(bufNo) centro $windowcoords] 1]

       #-- Binning des colonnes à l'extrême droite de l'image
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       buf$audace(bufNo) binx [expr $naxis1-2*$largeur] [expr $naxis1-$largeur] 3
       set x2 [ expr int($naxis1-1.5*$largeur) ]
       set y2 [ lindex [buf$audace(bufNo) centro $windowcoords ] 1]

       #-- Effectue la rotation d'angle "angle" et de centre=centre moyen de l'epaisseur du spectre :
       #- Angles>0 vers le haut de l'image
       # set pente [ expr -($y2-$y1)/($x2-$x1) ]
       # Le 2012-04-15 : - -> +
       set pente [ expr ($y2-$y1)/($x2-$x1) ]
       set angle [ expr 180/$pi*atan($pente) ]
       ## Si l'angle est supérieur a 6°, l'angle calculé ne correspond pas à la réalité de l'inclinaison du spectre
       if { [ expr abs($angle) ] < $spcaudace(tilt_limit) } {
	   set yinf [ expr int(0.5*($y1+$y2)) ]
	   set xinf [ expr int($naxis1/2) ]
	   buf$audace(bufNo) load "$audace(rep_images)/$filename"
	   #set newnaxis2 [expr $naxis2+int($naxis1*abs(tan($angle*$pi/180)))+1]
	   #buf$audace(bufNo) setkwd [list "NAXIS2" "$newnaxis2" int "" ""]
	   # buf$audace(bufNo) rot $xinf $yinf $angle
           #- imaseries TILT se charge de compenser le sens de la pente : nul besoin d'inverser son signe :
	   buf$audace(bufNo) imaseries "TILT trans_x=0 trans_y=$pente"
           buf$audace(bufNo) setkwd [ list "SPC_TILT" $angle float "Tilt angle" "degres" ]
           buf$audace(bufNo) setkwd [ list "SPC_TILX" $xinf int "Tilt X center" "pixel" ]
           buf$audace(bufNo) setkwd [ list "SPC_TILY" $yinf int "Tilt Y center" "pixel" ]
	   ::console::affiche_resultat "Rotation d'angle ${angle}° autour de ($xinf,$yinf).\n"
	   buf$audace(bufNo) save "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
	   ::console::affiche_resultat "Image sauvée sous ${filename}_tilt$conf(extension,defaut).\n"
	   return ${filename}_tilt
       } else {
	   ::console::affiche_resultat "Rotation d'angle 0° car angle=$angle est érroné.\n"
	   file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_tilt0$conf(extension,defaut)"
	   ::console::affiche_resultat "Image sauvée sous ${filename}_tilt0$conf(extension,defaut).\n"
	   return ${filename}_tilt0
       }
   } else {
       ::console::affiche_erreur "Usage: spc_tiltauto fichier\n\n"
   }
}
####################################################################




####################################################################
#  Procedure de decoupage d'une tranche horizontale pour une série d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-08-2005
# Date modification : 27-12-2005
# Arguments : nom y_inf
# Algorithme : cree une selction de l'image pour y>y_inf
####################################################################


proc spc_hcrop { args } {
   global audace
   global conf
   set kk 1

   if {[llength $args] == 2} {
       set filename [ lindex $args 0 ]
       set ybas [ lindex $args 1 ]
       set fileliste [ lsort -dictionary [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ] ]
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [ lindex $fileliste 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list 1 $ybas $naxis1 $naxis2 ]

       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   set nomfichierlg [ file rootname $fichier ]
	   regexp {(.+)\-?[0-9]+} $nomfichierlg match nomfichier
	   buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_hcrop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${nomfichier}_hcrop-x$conf(extension,defaut)\n"
       return ${nomfichier}_hcrop-
   } else {
       ::console::affiche_erreur "Usage: spc_hcrop nom_gégérique_fichiers y_bas\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de decoupage d'une tranche verticale pour une série d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-11-2005
# Date modification : 27-12-2005
# Arguments : nom x_inf
# Algorithme : cree une selction de l'image pour x>x_gauche
####################################################################


proc spc_vcrop { args } {
   global audace
   global conf
   set kk 1

   if {[llength $args] == 2} {
       set filename [ lindex $args 0 ]
       set ybas [ lindex $args 1 ]
       set fileliste [ lsort -dictionary [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ] ]
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [ lindex $fileliste 0 ]
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list $xgauche 1 $naxis1 $naxis2 ]

       set fichier ""
       foreach fichier $fileliste {
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   set nomfichierlg [ file rootname $fichier ]
	   regexp {(.+)\-[0-9]+} $nomfichierlg match nomfichier
	   buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_vcrop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${nomfichier}_vcrop-x$conf(extension,defaut)\n"
       return ${nomfichier}_vcrop-
   } else {
       ::console::affiche_erreur "Usage: spc_vcrop nom_gégérique_fichiers x_gauche\n\n"
   }
}
####################################################################



####################################################################
#  Procedure de decoupage d'une zone supérieure droite pour une série d'images 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-11-2005
# Date modification : 22-12-2005/27-12-05
# Arguments : nom_générique x_gauche y_bas
# Algorithme : cree une selction de l'image pour x>x_gauche et y>y_bas
####################################################################


proc spc_crop { args } {
   global audace
   global conf
   set kk 1

   if {[llength $args] == 3} {
       set filename [ lindex $args 0 ]
       set xgauche [ lindex $args 1 ]
       set ybas [ lindex $args 2 ]
       set fileliste [ lsort -dictionary [ glob -dir "$audace(rep_images)" "${filename}*$conf(extension,defaut)" ] ]
       # Les fichiers de fileliste contiennent aussi le nom du repertoire !
       set nbimg [ llength $fileliste ]
       ::console::affiche_resultat "$nbimg images à traiter...\n"

       set fichier1 [file tail [ lindex $fileliste 0 ]]
       ::console::affiche_resultat "$fichier1\n"
       buf$audace(bufNo) load "$audace(rep_images)/$fichier1"
       set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set naxis2 [lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1]
       set windowcoords [ list $xgauche $ybas $naxis1 $naxis2 ]

       set fichier ""
       foreach rfichier $fileliste {
	   set fichier [file tail $rfichier]
	   buf$audace(bufNo) load "$audace(rep_images)/$fichier"
	   buf$audace(bufNo) window $windowcoords
	   # 060223 : nom de fichier sortie incorrect -> impose
	   # set nomfichierlg [ file rootname $fichier ]
	   # set nomfichier [regexp {(.+)\-[0-9]+} $nomfichierlg match]
	   # buf$audace(bufNo) save "$audace(rep_images)/${nomfichier}_crop-$kk$conf(extension,defaut)"
	   buf$audace(bufNo) save "$audace(rep_images)/${filename}crop-$kk$conf(extension,defaut)"
	   #::console::affiche_resultat "Image $kk traitée\n"
	   incr kk
       }
       ::console::affiche_resultat "Images sauvées sous $audace(rep_images)/${filename}crop-x$conf(extension,defaut)\n"
       #-- 060223 : nomfichier -> filename
       # return ${nomfichier}_crop-
       return ${filename}crop-
   } else {
       ::console::affiche_erreur "Usage: spc_crop nom_gégérique_fichiers x_gauche y_bas\n\n"
   }
}
####################################################################



####################################################################
# Procédure de correction de raies courbées (lampe de calibration) par rapport à l'axe vertical : smile selon l'axe x.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-05-2006
# Date modification : 06-06-2006, 061220, 20151108, 20151223
# Arguments : fichier fits 2D d'une lampe de calibration
# ATTENTION : 2 parametres sont ici fixes en dur : la largeur des raies et la demi-largeur de la fenetre de decoupage autour de la raie choisie.
####################################################################

proc spc_smilex { args } {

    global audace spcaudace
    global conf caption
    global flag_ok
    set pourcentimg 0.01

    if {[llength $args] <= 2} {
	if {[llength $args] == 1} {
	    set filenamespc [ file rootname [ file tail [ lindex $args 0 ] ] ]
	    set flagmanuel "n"
	} elseif {[llength $args] == 2} {
	    set filenamespc [ file rootname [ file tail [ lindex $args 0 ] ] ]
	    set flagmanuel [ lindex $args 1 ]
	} elseif { [llength $args] == 0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [ list [ list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension ] [ buf$audace(bufNo) extension].gz" ] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filenamespc "$spctrouve"
		set flagmanuel "n"
	    } else {
		::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration ?sélection_manuelle (o/n)?\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration ?sélection_manuelle (o/n)?\n\n"
	    return 0
	}
        ## file copy -force "$audace(rep_images)/${filenamespc}$conf(extension,defaut)" "$audace(rep_images)/_${filenamespc}$conf(extension,defaut)"

	#set xdeb [ lindex $args 1 ]
	#set ydeb [ lindex $args 2 ]
	#set xfin [ lindex $args 3 ]
	#set yfin [ lindex $args 4 ]

	#--- Initialisation de variables liées aux dimensions du spectre de la lampe de calibration :
	# loadima "$audace(rep_images)/$filenamespc"
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
        visu1 cut [ lrange [ buf$audace(bufNo) stat ] 0 1 ] ; visu1 disp
	# ::confVisu::autovisu 1

	set naxis2i [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	# set pas [ expr $naxis2i/200 ]
	set pas [ expr round($pourcentimg*$naxis2i) ]
       if { $pas==1 } { set pas 2 }

	#----- Si hauteur>hmax : on tient compte du smilex :
       if { $naxis2i > $spcaudace(hmax) } {
       # if { $naxis2i > $spcaudace(hmax) || ( $naxis2i<$spcaudace(hmax) && $flagmanuel == "o" ) }
	    #------------------------------------------------------------------------#
	    #--- Selection d'une raie à la sourie
	    if { $flagmanuel == "o" } {
		::console::affiche_resultat "Sélectionnez un cadre autour d'une raie...\n"
		set flag_ok 0
		# Création de la fenêtre
		if { [ winfo exists .benji ] } {
		    destroy .benji
		}
		toplevel .benji
		wm geometry .benji
		wm title .benji "Get zone"
		wm transient .benji .audace
		#-- Textes d'avertissement
		label .benji.lab -text "Sélectionnez un cadre autour d'une raie..."
		pack .benji.lab -expand true -expand true -fill both
		#-- Sous-trame pour boutons
		frame .benji.but
		pack .benji.but -expand true -fill both
		#-- Bouton "Ok"
		button .benji.but.1  -command {set flag_ok 1} -text "OK"
		pack .benji.but.1 -side left -expand true -fill both
		#-- Bouton "Annuler"
		button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
		pack .benji.but.2 -side right -expand true -fill both
		#-- Attend que la variable $flag_ok change
		vwait flag_ok
		if { $flag_ok==1 } {
		    set wincoords [::confVisu::getBox 1]
		    ::console::affiche_resultat "Zone : $wincoords\n"
		    set flag_ok 2
		    destroy .benji
		} elseif { $flag_ok==2 } {
		    set flag_ok 2
		    destroy .benji
		    return 0
		}
		#-- Découpage de la zone
		if { [::confVisu::getBox 1] != "" } {
		    #--- Détermination du rayon et du centre de courbure du raie verticale
		    ##  -----------B
		    ##  |          |
		    ##  A-----------
		    ##set wincoords [ list $xdeb 1 $xfin $naxis2 ]
		    #set wincoords [ list $xdeb $ydeb $xfin $yfin ]
		    buf$audace(bufNo) window $wincoords
                    #buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_zonegeom$conf(extension,defaut)"
                    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
                    set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
		    #-- Suppression de la zone selectionnee avec la souris
		    ::confVisu::deleteBox 1
		} else {
		    ::console::affiche_erreur "Usage: Select zone with mouse\n\n"
		}
	    } elseif { $flagmanuel=="n" } {
               #------------------------------------------------------------------------#
               #-- Détermination de la largeur pour l'encadrement de la raie centrale :
               #- Ajoute le mot clef SPC_XCLM ;
               set linemesure [ spc_linewidth "$filenamespc" ]
               set x_bord_gauche [ lindex $linemesure 0 ]
               set x_bord_droit [ lindex $linemesure 1 ]

               #-- Détermination de la hauteur pour l'encadrement de la raie centrale :
               set linemesure [ spc_lineheigh "$filenamespc" $x_bord_gauche $x_bord_droit ]
               set y_bas [ lindex $linemesure 0 ]
               set y_haut [ lindex $linemesure 1 ]

               #-- Determination de la pente de slant :
               #loadima "$filenamespc"
               buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
               set wincoords [ list $x_bord_gauche $y_bas $x_bord_droit $y_haut ]
               ::console::affiche_resultat "Zone : $wincoords\n"
               buf$audace(bufNo) window $wincoords
               set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
               set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
                set pas [ expr round($pourcentimg*$naxis2) ]
               #set pas [ expr round($pourcentimg*($y_haut-$y_bas) ]
               if { $pas==1 } { set pas 2 }
               if { $pas==0 } {
                  set pas 2
                  ::console::affiche_erreur "Le pas vaut zéro : $pas. Il est mis à 2\n"
               }
               # buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_zone"
            }
            #::console::affiche_resultat "ICI1 ; pas=$pas ; naxis2=$naxis2 ; naxis1=$naxis1\n"

            
            #--- Calcul de points présents sur la raie penchée par centrage gaussien sur une ligne :
            ::console::affiche_resultat "Traitement de [expr $naxis2/$pas] lignes.\n"
            set yline 1
            while {$yline<=$naxis2} {
               set listcoords [ list 1 $yline $naxis1 $yline ]
               lappend ycoords $yline
               lappend xcoords [ lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1 ]
               set yline [ expr $yline+$pas-1 ]
            }

            #-- Calcul du polynome d'ajustement de degré 2 sur la raie courbee cx^2+bx+a :
            set coefssmilex [ lindex [ spc_ajustdeg2 $ycoords $xcoords 1 ] 0 ]
            set c [ expr $spcaudace(smilex_inv)*[ lindex $coefssmilex 2 ] ]
            set b [ lindex $coefssmilex 1 ]


	    #--- Correction du smile selon l'axe horizontal X ou du slant :
	    if { $c == 0.0 } {
		::console::affiche_resultat "Le spectre n'est pas affecté par un smile selon l'axe X.\n"
		if { $b != 0.0 } {
		    set pente $b
		    ::console::affiche_resultat "Correction du slant de pente $pente...\n"
		    buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
		    buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
		    #-- Sauvegarde du spectre corrigé du slant :
		    # buf$audace(bufNo) setkwd [list "SPC_SLX1" 0 float "ycenter smilex" ""]
		    # buf$audace(bufNo) setkwd [list "SPC_SLX2" 0 float "adeg2 smilex" ""]
		    buf$audace(bufNo) setkwd [ list "SPC_SLA" $pente float "pente slant" "real" ]
		    buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_slt$conf(extension,defaut)"
		    loadima "$audace(rep_images)/${filenamespc}_slt$conf(extension,defaut)"
		    ::console::affiche_resultat "Image sauvée sous ${filenamespc}_slt$conf(extension,defaut). Coéfficents du slant : $pente, $c.\n Il faudra peut-être aussi corriger l'inclinaison du spectre.\n"
		    set results [ list ${filenamespc}_slt $c $b [ lindex $coefssmilex 0 ] $pente ]
		    return $results
		} else {
		    ::console::affiche_resultat "Pas de correction du slant nécessaire non plus.\n"
		    return [ list $filenamespc ]
		}
	    } else {
		set deltay [ expr 0.5*($naxis2i-$naxis2) ]
		set ycenter [ expr -$spcaudace(smilex_inv)*$b/(2*$c)+$deltay ]
                ::console::affiche_resultat "Correction du smilex (ycenter=$ycenter, deg2=$c)...\n"
		buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
		buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$c"
		#--- Sauvegarde
		buf$audace(bufNo) setkwd [list "SPC_SLX1" $ycenter float "ycenter smilex" "pixel"]
		buf$audace(bufNo) setkwd [list "SPC_SLX2" $c float "coef deg2 smilex" "real"]
		buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_slx$conf(extension,defaut)"
		loadima "$audace(rep_images)/${filenamespc}_slx$conf(extension,defaut)"
		::console::affiche_resultat "Image sauvée sous ${filenamespc}_slx$conf(extension,defaut). Coéfficents du smilex : $ycenter, $c.\n Il faudra peut-être aussi corriger l'inclinaison du spectre.\n"
		set results [ list ${filenamespc}_slx $c $b [lindex $coefssmilex 0] $ycenter  ]
		return $results
	    }
	} else {
	    ::console::affiche_resultat "La seule déformation horizontale est du slant...\n"
           if { $flagmanuel=="o" } {
              #set results [ spc_autoslant "${filenamespc}_zonegeom" ]
              #set results [ spc_slant2img "${filenamespc}_zonegeom" "$filenamespc" ]
              set results [ spc_slant "$filenamespc" e ]
           } else {
              set results [ spc_autoslant "$filenamespc" ]
           }
	    return $results
	}
       #file delete -force "$audace(rep_images)/${filenamespc}_zonegeom$conf(extension,defaut)"
    } else {
	# ::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration xdeb ydeb xfin yfin\n\n"
	::console::affiche_erreur "Usage: spc_smilex spectre_lampe_calibration ?sélection_manuelle (o/n)?\n\n"
    }
}
#****************************************************************************


####################################################################
# Procédure de correction des spectres courbés (stellaire) par rapport à l'axe horizontal : smile selon l'axe y.
#
# Procédure de correction de raies courbées (lampe de calibration) par rapport à l'axe vertical : smile selon l'axe x d'une série d'images connaissant les coefficients.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 21-09-2006
# Date modification : 21-09-2006
# Arguments : nom_générique_spectres_2D_fits ycenter a
####################################################################

proc spc_smileximgs { args } {

    global conf audace spcaudace
    set pourcentimg 0.01

    if { [llength $args] == 3 } {
       set filename [ file rootname [ lindex $args 0 ] ]
       set ycenter [ lindex $args 1 ]
       set a [ lindex $args 2 ]

	::console::affiche_resultat "Coéfficients du smilex : ycenter=$ycenter, a=$a\n"
	#--- Applique le smile au(x) spectre(s) incriminé(s)
	if { [ file exists "$audace(rep_images)/$filename$conf(extension,defaut)" ] } {
           set nbsp 1
           set liste_images [ list $filename ]
	} else {
	    set liste_images [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${filename}\[0-9\]$conf(extension,defaut) ${filename}\[0-9\]\[0-9\]$conf(extension,defaut) ${filename}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
	    set nbsp [ llength $liste_images ]
	}

	if { $nbsp ==  1 } {
	    buf$audace(bufNo) load "$audace(rep_images)/[ lindex $liste_images 0 ]"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
	    buf$audace(bufNo) save "$audace(rep_images)/${filename}-slx$conf(extension,defaut)"
	    ::console::affiche_resultat "Spectre corrigé du smile en x sauvé sous ${filename}-slx$conf(extension,defaut)\n"
	    return ${filename}-slx
	} else {
	    set i 1
	    ::console::affiche_resultat "Correction du smilex de $nbsp spectres...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file tail $lefichier ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
		#--- Sauvegarde
		buf$audace(bufNo) setkwd [list "SPC_SLX1" $ycenter float "ycenter smilex" "pixel"]
		buf$audace(bufNo) setkwd [list "SPC_SLX2" $a float "coef deg2 smilex" "real"]
		buf$audace(bufNo) save "$audace(rep_images)/${filename}slx-$i$conf(extension,defaut)"
		incr i
	    }
	    #--- Messages d'information
	    ::console::affiche_resultat "Spectres corrigés du smile en x sauvés sous ${filename}slx-\*$conf(extension,defaut).\n"
	    return ${filename}slx-
	}
    } else {
	::console::affiche_erreur "Usage: spc_smileximgs nom_générique_spectres_2D_fits ycenter a\n\n"
    }
}
#********************************************************************************#




####################################################################
# Procédure de correction du raies courbées (lampe de calibration) : smile selon l'axe x et l'applique au spectre 2D à traiter avec ces paramètres.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-05-2006
# Date modification : 28-05-2006
# Arguments : spectre_lampe_calibration, spectre_a_traiter
####################################################################

proc spc_smilex2img { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set spectre [ file rootname [ lindex $args 1 ] ]

	#--- Détermine les coéfficients du smilex
	set results [ spc_smilex $spectrelampe ]
	#-- results : ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter
	set ycenter [ lindex $results 4 ]
	set a [ lindex $results 1 ]

	#--- Applique le smile au spectre incriminé
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"

	#--- Sauvegarde
	set filespc [ file rootname $spectre ]
        buf$audace(bufNo) setkwd [list "SPC_SLX1" $ycenter float "ycenter smilex" "pixel"]
        buf$audace(bufNo) setkwd [list "SPC_SLX2" $a float "coef deg2 smilex" "real"]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_slx$conf(extension,defaut)"
	::console::affiche_resultat "Spectre corrigé du smile en x sauvé sous ${spectre}_slx$conf(extension,defaut).\n"
	return ${spectre}_slx
    } else {
	::console::affiche_erreur "Usage: spc_smilex2img spectre_lampe_calibration spectre_2D_a_corriger\n\n"
    }
}
#********************************************************************************#



####################################################################
# Procédure de correction du raies courbées (lampe de calibration) : smile selon l'axe x et l'applique au spectre 2D à traiter avec ces paramètres.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 13-06-2006
# Date modification : 14-06-2006
# Arguments : spectre_lampe_calibration, spectre_a_traiter ou nom générique des pectres à traiter
####################################################################

proc spc_smilex2imgs { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set filename [ file rootname [ lindex $args 1 ] ]

	#--- Détermine les coéfficients du smilex
	set results [ spc_smilex $spectrelampe ]
	#-- results : ${filespc}_slx $a $b [lindex $coefssmilex 0] $ycenter
	set ycenter [ lindex $results 4 ]
	set a [ lindex $results 1 ]

	#--- Applique le smile au(x) spectre(s) incriminé(s)
	if { [ file exists "$audace(rep_images)/$filename$conf(extension,defaut)" ] } {
           set nbsp 1
           set liste_images [ list $filename ]
	} else {
           set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" "${filename}\[0-9\]*$conf(extension,defaut)" ] ]
           set nbsp [ llength $liste_images ]
        }
	if { $nbsp ==  1 } {
           buf$audace(bufNo) load "$audace(rep_images)/[ lindex $liste_images 0 ]"
	    buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
	    buf$audace(bufNo) save "$audace(rep_images)/${filename}-slx$conf(extension,defaut)"
	    ::console::affiche_resultat "Spectre corrigé du smile en x sauvé sous ${filename}-slx$conf(extension,defaut)\n"
	    return ${filename}-slx
	} else {
	    set i 1
	    ::console::affiche_resultat "Correction du smilex de $nbsp spectres...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file tail $lefichier ]
		buf$audace(bufNo) load "$audace(rep_images)/$fichier"
		buf$audace(bufNo) imaseries "SMILEX ycenter=$ycenter coef_smile2=$a"
		#--- Sauvegarde
		buf$audace(bufNo) setkwd [list "SPC_SLX1" $ycenter float "ycenter smilex" "pixel"]
		buf$audace(bufNo) setkwd [list "SPC_SLX2" $a float "coef deg2 smilex" "real"]
		buf$audace(bufNo) save "$audace(rep_images)/${filename}slx-$i$conf(extension,defaut)"
		incr i
	    }
	    #--- Messages d'information
	    ::console::affiche_resultat "Spectres corrigés du smile en x sauvés sous ${filename}slx-\*$conf(extension,defaut).\n"
	    return ${filename}slx-
	}
    } else {
	::console::affiche_erreur "Usage: spc_smilex2imgs spectre_2D_a_corriger spectre_lampe_calibration\n\n"
    }
}
#********************************************************************************#




####################################################################
# Procédure de correction des spectres courbés (stellaire) par rapport à l'axe horizontal : smile selon l'axe y.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 06-06-2006
# Date modification : 06-06-2006
# Arguments : spectre 2D fits
####################################################################

proc spc_smiley { args } {

    global audace caption
    global conf
    set pourcentimg 0.01

    if {[llength $args] <= 1} {
	if {[llength $args] == 1} {
	    set filenamespc [ lindex $args 0 ]
	} elseif { [llength $args]==0 } {
	    set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	    if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
		set filenamespc $spctrouve
	    } else {
		::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
		return 0
	    }
	} else {
	    ::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
	    return 0
	}


	#--- Initialisation de varaibles relatives aux dimentions de l'image
	buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
	set naxis1 [lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	set naxis2 [lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	set pas [ expr int($pourcentimg*$naxis1) ]

	#--- Détermination des paramètres de courbure du spectre
	::console::affiche_resultat "Traitement de [expr $naxis1/$pas] colonnes.\n"
	set xline 1
	while {$xline<=$naxis1} {
	    ##  -----------B
	    ##  |          |
	    ##  A-----------
	    set listcoords [list $xline 1 $xline $naxis2 ]
	    lappend xcoords $xline
	    lappend ycoords [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 5]
	    set xline [ expr $xline+$pas-1 ]
	}

	#-- Calcul du polynome d'ajustement de degré 2 sur la raie courbee
	set coefssmiley [ lindex [ spc_ajustdeg2 $xcoords $ycoords 1 ] 0 ]
	set a [ lindex $coefssmiley 2 ]
	set b [ lindex $coefssmiley 1 ]
	#set deltay [ expr 0.5*($naxis2i-$naxis2) ]
	#set xcenter [ expr -$b/(2*$a)+$deltay ]
	set xcenter [ expr -$b/(2*$a) ]

	#--- Correction du smile selon l'axe vertical Y
	if { $a == 0 } {
	    ::console::affiche_resultat "Le spectre n'est pas affecté par un smile selon l'axe Y.\n"
	    return 0
	} else {
	    buf$audace(bufNo) imaseries "SMILEY xcenter=$xcenter coef_smile2=$a"
	}

	#--- Sauvegarde
	set filespc [ file rootname $filenamespc ]
        buf$audace(bufNo) setkwd [list "SPC_SLY1" $xcenter float "xcenter smiley" "pixel"]
        buf$audace(bufNo) setkwd [list "SPC_SLY2" $a float "coef deg2 smiley" "real"]	
	buf$audace(bufNo) save "$audace(rep_images)/${filespc}_sly$conf(extension,defaut)"
	loadima "$audace(rep_images)/${filespc}_sly$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_sly$conf(extension,defaut).\n"
	set results [ list ${filespc}_sly $a $b [lindex $coefssmiley 0] $xcenter ]
	return $results
    } else {
	::console::affiche_erreur "Usage: spc_smiley spectre_2D_fits\n\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction du raies inclinées dans le spectre : translations de lignes.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-06-2006
# Date modification : 08-06-2008/061220/07-02-2011
# Arguments 060806 : spectre 2D fits
####################################################################

proc spc_autoslant { args } {

    global audace spcaudace
    global conf
    #global flag_ok
    set pourcentimg 0.01

    if {[llength $args]==1} {
       set filenamespc [ file rootname [ lindex $args 0 ] ]

       #--- Détermination de la largeur pour l'encadrement de la raie centrale :
       set linemesure [ spc_linewidth $filenamespc ]
       set x_bord_gauche [ lindex $linemesure 0 ]
       set x_bord_droit [ lindex $linemesure 1 ]

       #--- Determination de la pente de slant :
       loadima "$filenamespc"
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       buf$audace(bufNo) window [ list $x_bord_gauche 1 $x_bord_droit $naxis2 ]
       set pas [ expr round($pourcentimg*$naxis2) ]
       if { $pas==1 } { set pas 2 }
       # buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_zone"
       #-- Calcul de points présents sur la raie penchée par centrage gaussien sur une ligne :
       ::console::affiche_resultat "Traitement de [expr $naxis2/$pas] lignes.\n"
       set yline 1
       while {$yline<=$naxis2} {
          set listcoords [ list 1 $yline $naxis1 $yline ]
          lappend ycoords $yline
          lappend xcoords [ lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1 ]
          set yline [ expr $yline+$pas-1 ]
       }
       #-- Calcul du polynome d'ajustement de degré 2 sur la raie courbee b*x+a :
       set coefsajust [ lindex [ spc_ajustdeg1 $ycoords $xcoords 1 ] 0 ]
       set b [ expr $spcaudace(smilex_inv)*[ lindex $coefsajust 1 ] ]
       set a [ lindex $coefsajust 0 ]

       #--- Correction du slant :
       set pente $b
       buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
       ::console::affiche_resultat "Pente d'inclinaison de la raie : $pente pixels y/pixels x.\n"
       buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
       buf$audace(bufNo) setkwd [list "SPC_SLA" $pente float "Slant slope" "real"]

       #--- Sauvegarde
       #if { [string compare $type "a"] == 0 } {
       #   buf$audace(bufNo) mult -1.0
       #}
       buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_slant$conf(extension,defaut)"
       ::console::affiche_resultat "Image sauvée sous ${filenamespc}_slant$conf(extension,defaut).\n"
       loadima "$audace(rep_images)/${filenamespc}_slant$conf(extension,defaut)"
       set results [ list ${filenamespc}_slant $pente ]
       return $results
    } else {
       ::console::affiche_erreur "Usage: spc_autoslant spectre_2D_fits\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction du raies inclinées dans le spectre : translations de lignes.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-06-2006
# Date modification : 08-06-2008/061220
# Arguments 061220 (a faire ?)  : spectre 2D fits
# Arguments 060806 : spectre 2D fits, type de raies a/e (absorption/émission)
# Remarque : cette commande pourrait s'appeler aussi "spc_tiltx"
####################################################################

proc spc_slant { args } {

    global audace
    global conf
    global flag_ok

    if {[llength $args] == 2} {
	set filenamespc [ lindex $args 0 ]
	set type [ lindex $args 1 ]

	#--- Chargement du spectre et inversion si nécessaire
        #loadima "$filenamespc"
        #set naxis2 [ lindex [ buf1 getkwd "NAXIS2" ] 1 ]
        buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
        visu$audace(bufNo) cut [ lrange [ buf$audace(bufNo) stat ] 0 1 ]
        visu$audace(bufNo) disp
        set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
	if { [string compare $type "a"] == 0 } {
	    buf$audace(bufNo) mult -1.0
	}

	#--- Repérage de la partie supérieure de la raie  ----
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Faites un cadre sur la partie supérieure d'une raie brillante (boîte petite)"
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "OK"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set coords_zone [::confVisu::getBox 1]
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Determine le photocentre de la zone sélectionée
	# set stats [ buf$audace(bufNo) stat ]
	##set point_depart [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ]
       # set point_depart [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
       set param_depart [ buf$audace(bufNo) fitgauss $coords_zone ]
       set point_depart [ list [ lindex $param_depart 1 ] [ lindex $param_depart 5 ] ]
       	::console::affiche_resultat "Point supérieur de la raie : $point_depart\n"

	#---------------------------------------------------------#
	#--- Repérage de la partie inférieure de la raie  ----
	set flag_ok 0
	#-- Création de la fenêtre
	if { [ winfo exists .benji ] } {
	    destroy .benji
	}
	toplevel .benji
	wm geometry .benji
	wm title .benji "Get zone"
	wm transient .benji .audace
	#-- Textes d'avertissement
	label .benji.lab -text "Faites un cadre sur la partie inférieure de cette même raie (boîte petite)"
	pack .benji.lab -expand true -expand true -fill both
	#-- Sous-trame pour boutons
	frame .benji.but
	pack .benji.but -expand true -fill both
	#-- Bouton "Ok"
	button .benji.but.1  -command {set flag_ok 1} -text "OK"
	pack .benji.but.1 -side left -expand true -fill both
	#-- Bouton "Annuler"
	button .benji.but.2 -command {set flag_ok 2} -text "Annuler"
	pack .benji.but.2 -side right -expand true -fill both
	#-- Attend que la variable $flag_ok change
	vwait flag_ok
	if { $flag_ok == "1" } {
	    set coords_zone [::confVisu::getBox 1]
	    set flag_ok 2
	    destroy .benji
	} elseif { $flag_ok == "2" } {
	    set flag_ok 2
	    destroy .benji
            return 0
	}
	#-- Determine le photocentre de la zone sélectionée
	# set stats [ buf$audace(bufNo) stat ]
        # set point_final [ lrange [ buf$audace(bufNo) centro $coords_zone [lindex $stats 6] ] 0 1]
       set param_final [ buf$audace(bufNo) fitgauss $coords_zone ]
       set point_final [ list [ lindex $param_final 1 ] [ lindex $param_final 5 ] ]
	::console::affiche_resultat "Point inférieur de la raie : $point_final\n"
       
        #--- Si DeltaY>20%naxis1, recommencer :
        set deltay [ expr [ lindex $point_depart 1 ]-[ lindex $point_final 1 ] ]
        set deltaymin [ expr 0.17*$naxis2 ]
        if { $deltay<$deltaymin } {
           ::console::affiche_erreur "Distance verticale entre les points trop petite (<$deltaymin). Recommencer...\n"
           spc_slant "$filenamespc" $type
        } else {   
           #--- Affichage des coordonnees :
           #::console::affiche_resultat "Msup=([ lindex $point_depart 0 ], [ lindex $point_depart 1 ]) ; Minf=([ lindex $point_final 0 ], [ lindex $point_final 1 ])\n"
       
           #--- Correction du slant
           set erra [ lindex $point_depart 2 ]
           #set erra 0.1
           if { $erra >=0.3 } {
              set x_depart [expr [lindex $point_depart 0]+$erra ]
              set y_depart [expr [lindex $point_depart 1]+$erra ]
           } else {
              set x_depart [ lindex $point_depart 0 ]
              set y_depart [ lindex $point_depart 1 ]
           }
           set errb [ lindex $point_final 2 ]
           if { $erra >=0.3 } {
              set x_final [expr [lindex $point_final 0]+$errb ]
              set y_final [expr [lindex $point_final 1]+$errb ]
           } else {
              set x_final [ lindex $point_final 0 ]
              set y_final [ lindex $point_final 1 ]
           }
           #::console::affiche_resultat "Msup=($x_depart, $y_depart) ; Minf=($x_final, $y_final)\n"
           set deltax [expr $x_final-$x_depart ]
           set deltay [expr $y_final-$y_depart ]
           #set deltax [ expr [ lindex $point_final 0 ]-[ lindex $point_depart 0 ] ]
           #set deltay [ expr [ lindex $point_final 1 ]-[ lindex $point_depart 1 ] ]
           ## set cd [ expr $deltay/$deltax ]
           set pente [ expr $deltax/$deltay ]
           #set pente [ expr -1.0*$deltax/$deltay ]
           ::console::affiche_resultat "Pente d'inclinaison de la raie : $pente pixels x/pixels y.\n"
           buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
           buf$audace(bufNo) setkwd [list "SPC_SLA" $pente float "Slant slope" "real"]

           #--- Sauvegarde
           if { [string compare $type "a"] == 0 } {
              buf$audace(bufNo) mult -1.0
           }
           set filespc [ file rootname $filenamespc ]
           buf$audace(bufNo) save "$audace(rep_images)/${filespc}_slant$conf(extension,defaut)"
           ::console::affiche_resultat "Image sauvée sous ${filespc}_slant$conf(extension,defaut).\n"
           loadima "$audace(rep_images)/${filespc}_slant$conf(extension,defaut)"
           set results [ list ${filespc}_slant $pente ]
           return $results
        }
    } else {
	::console::affiche_erreur "Usage: spc_slant spectre_2D_fits type_raie (a/e)\n\n"
    }
}
#****************************************************************************



####################################################################
# Procédure de correction du raies inclinées dans le spectre : translations de lignes et l'applique au spectre déformé. (inutile car applique la correction qu'à une image).
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-06-2006
# Date modification : 08-06-2008
# Arguments : spectre 2D fits
# Remarque : cette commande pourrait s'appeler aussi "spc_tiltx"
####################################################################

proc spc_slant2img { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
	set spectrelampe [ lindex $args 0 ]
	set spectre [ lindex $args 1 ]

	#--- Détermine les coéfficients du slant
	set cd [ lindex [ spc_slant $spectrelamp ] 1 ]

	#--- Applique le smile au spectre incriminé
	buf$audace(bufNo) load "$audace(rep_images)/$spectre"
	buf$audace(bufNo) imaseries "TILT trans_x=$cd trans_y=0"

	#--- Sauvegarde
	set filespc [ file rootname $spectre ]
	buf$audace(bufNo) setkwd [list "SPC_SLA" $cd float "Slant slope" "real"]
	buf$audace(bufNo) save "$audace(rep_images)/${spectre}_slant$conf(extension,defaut)"
	::console::affiche_resultat "Image sauvée sous ${filespc}_slant$conf(extension,defaut).\n"
	return ${spectre}_slant
    } else {
	::console::affiche_erreur "Usage: spc_slant2img spectre_lampe_calibration spectre_2D_a_corriger\n\n"
    }
}
#****************************************************************************


####################################################################
# Procédure de correction du raies inclinées dans le spectre : translations de lignes et l'applique à une série d'images déformées.
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 28-12-2006
# Date modification : 28-12-2006
# Arguments : nom générique des fichiers à corriger, pente du slant
####################################################################

proc spc_slant2imgs { args } {

    global audace
    global conf

    if {[llength $args] == 2} {
       set nom_spectres [ file rootname [ lindex $args 0 ] ]
       set pente [ lindex $args 1 ]
       
       #--- Cas d'un seul fichier :
       if { [ file exists "$audace(rep_images)/$nom_spectres$conf(extension,defaut)" ] } {
          buf$audace(bufNo) load "$audace(rep_images)/$nom_spectres"
          buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
          buf$audace(bufNo) setkwd [list "SPC_SLA" $pente float "Slant slope" "real"]
          buf$audace(bufNo) save "$audace(rep_images)/${nom_spectres}-slt$conf(extension,defaut)"
          ::console::affiche_resultat "Image corrigée sauvée sous ${nom_spectres}-slt$conf(extension,defaut).\n"
       } else {
          #--- Construit la liste des images à traiter :
          set liste_sp [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_spectres}\[0-9\]$conf(extension,defaut) ${nom_spectres}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_spectres}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
          
          #--- Applique le smile aux spectres incriminés :
          set i 1
          foreach spectre $liste_sp {
             set lespectre [ file tail $spectre ]
             buf$audace(bufNo) load "$audace(rep_images)/$lespectre"
             buf$audace(bufNo) imaseries "TILT trans_x=$pente trans_y=0"
             buf$audace(bufNo) setkwd [list "SPC_SLA" $pente float "Slant slope" "real"]
             buf$audace(bufNo) save "$audace(rep_images)/${nom_spectres}-slt-$i$conf(extension,defaut)"
             ::console::affiche_resultat "Image corrigée sauvée sous ${nom_spectres}-slt-$i$conf(extension,defaut).\n"
             incr i
          }
       }
       return ${nom_spectres}-slt-
    } else {
       ::console::affiche_erreur "Usage: spc_slant2imgs nom_générique_spectre2D_a_corriger pente_slant\n\n"
    }
}
#****************************************************************************


####################################################################
# Détermine l'angle et les corrdonnées d'inclinaison d'un spectre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-03-2007
# Date modification : 31-10-2012
# Arguments : fichier .fit
####################################################################

proc spc_findtilt { args } {
   global audace caption spcaudace
   global conf

   set pi [ expr acos(-1.0) ]
   #-- Angles>0 penchés vers le haut à droite de l'image

   if {[llength $args] <= 1} {
       if {[llength $args] == 1} {
	   set spectre_name [ file tail [ file rootname [ lindex $args 0 ] ] ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set spectre_name $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
	   return 0
       }

       #--- Elimination des bords gauche et droit :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre_name"
       set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]

       set x1 [ expr round($spcaudace(pourcent_bordt)*$naxis1) ]
       set x2 [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ]
       # set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] 1 [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] $naxis2 ]
       # set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] $ydeb [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] $yfin ]
      set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] [ expr round($naxis2*(1-$spcaudace(pourcent_bordt))) ] [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] [ expr round($spcaudace(pourcent_bordt)*$naxis2) ]  ]
       buf$audace(bufNo) window $windowcoords
       buf$audace(bufNo) save "$audace(rep_images)/${spectre_name}_vcrop"

       #--- Extraction des mots clef :
       #-- Il faut caonnaitre la valeur actuelle de NAXIS1 !
       set naxis1_crop [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set naxis2_crop [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       # ::console::affiche_resultat "$naxis1_crop ; $naxis2_crop\n"

       #--- Calcul de l'angle avec les 2 méthodes et les compare :
       if { $spcaudace(tilt_normal)=="o" } {
          #-- Methode un peu fragile : trouve parfois un angle important (4 ou 15°) alors que ce n'est pas le cas.
          #-- Binning des colonnes à l'extrême gauche de l'image
          #buf$audace(bufNo) imaseries "binx x1=[expr $largeur+1] x2=[expr 2*$largeur] width=3"
          buf$audace(bufNo) imaseries "medianx x1=1 x2=[ expr round($naxis1_crop*$spcaudace(largeur_tilt)) ] width=3"
           set y1 [ lindex [buf$audace(bufNo) centro [ list 1 1 3 $naxis2_crop ] ] 1 ]
          #set y1 [ lindex [buf$audace(bufNo) fitgauss [ list 1 1 3 $naxis2_crop ] ] 5 ]
          
          #-- Binning des colonnes à l'extrême droite de l'image
          buf$audace(bufNo) load "$audace(rep_images)/${spectre_name}_vcrop"
          #buf$audace(bufNo) imaseries "binx x1=[expr $naxis1-2*$largeur] x2=[expr $naxis1-$largeur] width=3"
          buf$audace(bufNo) imaseries "medianx x1=[expr int($naxis1_crop*(1-$spcaudace(largeur_tilt))) ] x2=$naxis1_crop width=3"
          #set x2 [ expr int($naxis1-1.5*$largeur) ]
          set y2 [ lindex [buf$audace(bufNo) centro [ list 1 1 3 $naxis2_crop ] ] 1]
          #set y2 [ lindex [buf$audace(bufNo) fitgauss [ list 1 1 3 $naxis2_crop ] ] 5 ]
          
          #-- Angles>0 penchés vers le haut à droite de l'image
          set facteur_correctif_du_au_crop $spcaudace(tilt_fcorrectif)
          set pente [ expr 1.0*($y2-$y1)/($x2-$x1) ]
          set angle [ expr $facteur_correctif_du_au_crop*180./$pi*atan($pente) ]
          #- Mise a 0 car methode peu précise : 2008-02-24
          #set angle 0.0
       } else {
          #-- Oblige l'usage de la methode 2 : orientation necessaire pour spectres de snr intermediaire (mv5.5)
          set angle $spcaudace(tilt_limit)
       }
      set xinf [ expr round($naxis1/2) ]
      set yinf [ expr round($naxis2/2) ]
      #::console::affiche_resultat "Angle=$angle ; Xc=$xinf ; Yc=$yinf\n"


       #--- Traitement du résultat :
       file delete -force "$audace(rep_images)/${spectre_name}_vcrop$conf(extension,defaut)"
       set results [ list $angle $xinf $yinf $pente ]
       ::console::affiche_resultat "Angle de rotation trouvé : ${angle}° autour de ($xinf,$yinf) de pente $pente.\n"
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
   }
}
#***************************************************************************#


####################################################################
# Détermine l'angle et les corrdonnées d'inclinaison d'un spectre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-10-2012
# Date modification : 20-10-2012
# Arguments : fichier .fit
####################################################################

proc spc_findgeomimgs { args } {
   global audace caption spcaudace
   global conf
   set pi [ expr acos(-1.0) ]
   #-- Angles>0 penchés vers le haut à droite de l'image

   if {[llength $args] == 1} {
      set nom_generique [ lindex $args 0 ]

      set listefichiers [ glob -dir $audace(rep_images) -tails ${nom_generique}\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_generique}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ]
      foreach fichier $listefichiers {
         #--- Determination des parametres de tilt :
         set results [ spc_findtilt "$fichier" ]
         set angle [ lindex $results 0 ]
         set xrot [ lindex $results 1 ]
         set yrot [ lindex $results 2 ]

         #--- Determination des parametres de de binning (h, e) :
         set results [ spc_detectasym "$fichier" ]
         set ybin [ expr round([ lindex $results 0 ]) ]
         # set epaisseur [ lindex $results 1 ]

         #--- Ecrit les parametres dans le header :
         buf$audace(bufNo) load "$audace(rep_images)/$fichier"
         buf$audace(bufNo) setkwd [ list "SPC_YBIN" $ybin int "Y heigh for binning" "pixel" ]
         buf$audace(bufNo) setkwd [ list "SPC_TILT" $angle float "Tilt angle" "degres" ]
         buf$audace(bufNo) setkwd [ list "SPC_TILX" $xrot int "Tilt X center" "pixel" ]
         buf$audace(bufNo) setkwd [ list "SPC_TILY" $yrot int "Tilt Y center" "pixel" ]
         buf$audace(bufNo) setkwd [ list "SPC_XROT" $xrot int "Tilt X center" "pixel" ]
         buf$audace(bufNo) setkwd [ list "SPC_YROT" $yrot int "Tilt Y center" "pixel" ]
         buf$audace(bufNo) bitpix short
         buf$audace(bufNo) save "$audace(rep_images)/$fichier"
      }
   } else {
       ::console::affiche_erreur "Usage: spc_findgeomimgs nom_generique_fichier\n\n"
   }
}
#***************************************************************************#



####################################################################
# Détermine l'angle et les corrdonnées d'inclinaison d'un spectre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-03-2007
# Date modification : 20-10-2012
# Arguments : fichier .fit
####################################################################

proc spc_findtilt_old2 { args } {
   global audace caption spcaudace
   global conf
   set pi [ expr acos(-1.0) ]
   #-- Angles>0 penchés vers le haut à droite de l'image

   if {[llength $args] <= 1} {
       if {[llength $args] == 1} {
	   set spectre_name [ file tail [ file rootname [ lindex $args 0 ] ] ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set spectre_name $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
	   return 0
       }

       #--- Elimination des bords gauche et droit :
       buf$audace(bufNo) load "$audace(rep_images)/$spectre_name"
       set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]

       set x1 [ expr round($spcaudace(pourcent_bordt)*$naxis1) ]
       set x2 [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ]
       # set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] 1 [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] $naxis2 ]
       # set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] $ydeb [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] $yfin ]
      set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] [ expr round($naxis2*(1-$spcaudace(pourcent_bordt))) ] [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] [ expr round($spcaudace(pourcent_bordt)*$naxis2) ]  ]
       buf$audace(bufNo) window $windowcoords
       buf$audace(bufNo) save "$audace(rep_images)/${spectre_name}_vcrop"

       #--- Extraction des mots clef :
       #-- Il faut caonnaitre la valeur actuelle de NAXIS1 !
       set naxis1_crop [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set naxis2_crop [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       # ::console::affiche_resultat "$naxis1_crop ; $naxis2_crop\n"

       #--- Calcul de l'angle avec les 2 méthodes et les compare :
       if { $spcaudace(tilt_normal)=="o" } {
          #-- Methode un peu fragile : trouve parfois un angle important (4 ou 15°) alors que ce n'est pas le cas.
          #-- Binning des colonnes à l'extrême gauche de l'image
          #buf$audace(bufNo) imaseries "binx x1=[expr $largeur+1] x2=[expr 2*$largeur] width=3"
          buf$audace(bufNo) imaseries "medianx x1=1 x2=[ expr round($naxis1_crop*0.05) ] width=3"
           set y1 [ lindex [buf$audace(bufNo) centro [ list 1 1 3 $naxis2_crop ] ] 1 ]
          #set y1 [ lindex [buf$audace(bufNo) fitgauss [ list 1 1 3 $naxis2_crop ] ] 5 ]
          
          #-- Binning des colonnes à l'extrême droite de l'image
          buf$audace(bufNo) load "$audace(rep_images)/${spectre_name}_vcrop"
          #buf$audace(bufNo) imaseries "binx x1=[expr $naxis1-2*$largeur] x2=[expr $naxis1-$largeur] width=3"
          buf$audace(bufNo) imaseries "medianx x1=[expr int($naxis1_crop*.95) ] x2=$naxis1_crop width=3"
          #set x2 [ expr int($naxis1-1.5*$largeur) ]
          set y2 [ lindex [buf$audace(bufNo) centro [ list 1 1 3 $naxis2_crop ] ] 1]
          #set y2 [ lindex [buf$audace(bufNo) fitgauss [ list 1 1 3 $naxis2_crop ] ] 5 ]
          
          #-- Angles>0 penchés vers le haut à droite de l'image
          set facteur_correctif_du_au_crop 0.95
          set pente [ expr 1.0*($y2-$y1)/($x2-$x1) ]
          set angle [ expr $facteur_correctif_du_au_crop*180./$pi*atan($pente) ]
          #- Mise a 0 car methode peu précise : 2008-02-24
          #set angle 0.0
       } else {
          #-- Oblige l'usage de la methode 2 : orientation necessaire pour spectres de snr intermediaire (mv5.5)
          set angle $spcaudace(tilt_limit)
       }
      set xinf [ expr round($naxis1/2) ]
      set yinf [ expr round($naxis2/2) ]
      #::console::affiche_resultat "Angle=$angle ; Xc=$xinf ; Yc=$yinf\n"


       #--- Traitement du résultat :
       file delete -force "$audace(rep_images)/${spectre_name}_vcrop$conf(extension,defaut)"
       set results [ list $angle $xinf $yinf $pente ]
       ::console::affiche_resultat "\nAngle de rotation trouvé : ${angle}° autour de ($xinf,$yinf) de pente $pente.\n"
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
   }
}
#***************************************************************************#



####################################################################
# Détermine l'angle et les corrdonnées d'inclinaison d'un spectre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-03-2007
# Date modification : 20-03-2007
# Arguments : fichier .fit
####################################################################

proc spc_findtilt_old1 { args } {
   global audace caption spcaudace
   global conf
   set pi [ expr acos(-1.0) ]
   #-- Angles>0 penchés vers le haut à droite de l'image

   if {[llength $args] <= 1} {
       if {[llength $args] == 1} {
	   set spectre_name [ file tail [ file rootname [ lindex $args 0 ] ] ]
       } elseif { [llength $args]==0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile  -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set spectre_name $spctrouve
	   } else {
	       ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
	       return 0
	   }
       } else {
	   ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
	   return 0
       }

       #--- Elimination des bords gauche et droit :
      set results_y [ spc_detect "$spectre_name" ]
      set ycentre [ lindex $results_y 0 ]
      set largeur_y [ expr 2*[ lindex $results_y 1 ] ]
      set ydeb [ expr round($ycentre-$largeur_y) ]
      set yfin [ expr round($ycentre+$largeur_y) ]
       buf$audace(bufNo) load "$audace(rep_images)/$spectre_name"
       set naxis2 [ lindex [buf$audace(bufNo) getkwd "NAXIS2"] 1 ]
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       
       # set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] 1 [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] $naxis2 ]
       set windowcoords [ list [ expr round($spcaudace(pourcent_bordt)*$naxis1) ] $ydeb [ expr round($naxis1*(1-$spcaudace(pourcent_bordt))) ] $yfin ]
       buf$audace(bufNo) window $windowcoords
       buf$audace(bufNo) save "$audace(rep_images)/${spectre_name}_vcrop"
       set filename "${spectre_name}_vcrop"

       #--- Extraction des mots clef :
       #-- Il faut caonnaitre la valeur actuelle de NAXIS1 !
       set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
       set x_fin [ expr (1-$spcaudace(epaisseur_detect))*$naxis1 ]


       #--- Calcul de l'angle avec les 2 méthodes et les compare :
       if { $spcaudace(tilt_normal)=="o" } {
          #-- Methode un peu fragile : trouve parfois un angle important (4 ou 15°) alors que ce n'est pas le cas.
          #-- Binning des colonnes à l'extrême gauche de l'image
          set largeur [ expr $naxis1/100 ]
          set windowcoords [ list 1 1 3 $naxis2 ]
          #buf$audace(bufNo) imaseries "binx x1=[expr $largeur+1] x2=[expr 2*$largeur] width=3"
          buf$audace(bufNo) imaseries "medianx x1=[expr $largeur+1] x2=[expr 2*$largeur] width=3"
          set x1 [ expr int(1.5*$largeur) ]
          set y1 [lindex [buf$audace(bufNo) centro $windowcoords] 1]
          
          #-- Binning des colonnes à l'extrême droite de l'image
          buf$audace(bufNo) load "$audace(rep_images)/$filename"
          #buf$audace(bufNo) imaseries "binx x1=[expr $naxis1-2*$largeur] x2=[expr $naxis1-$largeur] width=3"
          buf$audace(bufNo) imaseries "medianx x1=[expr $naxis1-2*$largeur] x2=[expr $naxis1-$largeur] width=3"
          set x2 [ expr int($naxis1-1.5*$largeur) ]
          set y2 [ lindex [buf$audace(bufNo) centro $windowcoords ] 1]
          
          #-- Angles>0 penchés vers le haut à droite de l'image
          set pente [ expr 1.0*($y2-$y1)/($x2-$x1) ]
          set angle [ expr 180./$pi*atan($pente) ]
          #- Mise a 0 car methode peu précise : 2008-02-24
          #set angle 0.0
       } else {
          #-- Oblige l'usage de la methode 2 : orientation necessaire pour spectres de snr intermediaire (mv5.5)
          set angle $spcaudace(tilt_limit)
       }

       #--- Test la valeur de l'angle :
       if { [expr abs($angle) ] < $spcaudace(tilt_limit) && abs($angle) != 0.0 } { 
	   #-- Rotation d'angle "angle" et de centre=centre moyen de l'épaisseur du spectre :
	   set yinf [ expr round(0.5*($y1+$y2)) ]
           set xinf [ expr round($naxis1/2) ]
       } else {
	   #-- Détermination du centre lumineux des profils de plusieurs colonnes :
           ::console::affiche_resultat "Angle ($angle °) trouvé par la méthode 1 trop grand : méthode 2...\n"
	   set xpas [ expr int($naxis1/$spcaudace(nb_coupes)) ]
	   ::console::affiche_resultat "Pas entre chaque point de détection : $xpas\n"
	   set liste_x [ list ]
	   set liste_y [ list ]
	   for {set k $xpas} {$k <= $x_fin} {incr k} {
	       # set fsortie [ file rootname [ spc_profilx "$filename" $k $spcaudace(largeur_binning) ] ]
               buf$audace(bufNo) load "$audace(rep_images)/$filename"
               set xdeb [ expr $k-$spcaudace(largeur_binning) ]
               if { $xdeb<1 } { set xdeb 1 }
               set xfin [ expr $k+$spcaudace(largeur_binning) ]
               if { $xfin>$naxis1 } { set xfin $naxis1 }
               buf$audace(bufNo) imaseries "BINX x1=$xdeb x2=$xfin width=1"
	       lappend liste_x $k
	       set y1 [ expr int($spcaudace(epaisseur_detect)*$naxis2) ]
	       set y2 [ expr int((1-$spcaudace(epaisseur_detect))*$naxis2) ]
	       set windowcoords [ list 1 $y1 1 $y2 ]
	       # buf$audace(bufNo) load "$audace(rep_images)/$fsortie"
               #- 2010-02-08 :
	       lappend liste_y [ lindex [ buf$audace(bufNo) fitgauss $windowcoords ] 5 ]
               #- 091214 :
               #lappend liste_y [ lindex [ buf$audace(bufNo) centro $windowcoords ] 1 ]
	       # file delete -force "$audace(rep_images)/$fsortie$conf(extension,defaut)"
	       set k [ expr $k+$xpas-1 ]
	   }

	   #-- Equation de la doite a+b*x passant par le profil incliné :
	   set coefs [ spc_ajustdeg1 $liste_x $liste_y 1. ]
	   set a [ lindex [ lindex $coefs 0 ] 0 ]
	   set b [ lindex [ lindex $coefs 0 ] 1 ]

	   #-- Calcule l'angle d'inclinaison de la droite :
	   set angle [ expr 180./$pi*atan(1.0*$b) ]
	   #set angle [ expr 180./$pi*atan(1.0*$b) ]
	   set pente $b
	   set xinf [ expr round($naxis1/2) ]
	   set yinf [ expr round($a+$b*$xinf) ]
       }

       #--- Traitement du résultat :
       file delete -force "$audace(rep_images)/$filename$conf(extension,defaut)"
       set results [ list $angle $xinf $yinf $pente ]
       ::console::affiche_resultat "\n\nAngle de rotation trouvé : ${angle}° autour de ($xinf,$yinf) de pente $pente.\n"
       return $results
   } else {
       ::console::affiche_erreur "Usage: spc_findtilt fichier\n\n"
   }
}
#***************************************************************************#




####################################################################
# Rotation d'un spectre avec l'angle te les corrdonnées du centre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-03-2007
# Date modification : 20-03-2007
# Arguments : fichier_fit angle xrot yrot
####################################################################

proc spc_tilt2 { args } {
   global audace
   global conf

   if { [llength $args]==4 } {
       set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set angle [ lindex $args 1 ]
       set xrot [ expr round([ lindex $args 2 ]) ]
       set yrot [ expr round([ lindex $args 3 ]) ]

       #--- Recalcule la pente :
       #-- Nul besoin d'inverser le signe de la pente car imaseries TILT se charge de compenser :
       set pente [ expr tan($angle*acos(-1.0)/180.) ]

       #--- Rotation de l'image :
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       buf$audace(bufNo) imaseries "TILT trans_x=0 trans_y=$pente"
       buf$audace(bufNo) setkwd [ list "SPC_TILT" $angle float "Tilt angle" "degres" ]
       buf$audace(bufNo) setkwd [ list "SPC_TILX" $xrot int "Tilt X center" "pixel" ]
       buf$audace(bufNo) setkwd [ list "SPC_TILY" $yrot int "Tilt Y center" "pixel" ]
       buf$audace(bufNo) save "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
       ::console::affiche_resultat "Rotation d'angle ${angle}° autour de ($xrot,$yrot) sauvé sous ${filename}_tilt$conf(extension,defaut).\n"
       return ${filename}_tilt
   } else {
       ::console::affiche_erreur "Usage: spc_tilt2 fichier_fits angle(°) xrot yrot\n\n"
   }
}
#***************************************************************************#



####################################################################
# Rotation d'un spectre avec l'angle te les corrdonnées du centre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 30-09-2007
# Date modification : 30-09-2007
# Arguments : fichier_fit pente
####################################################################

proc spc_tilt3 { args } {
   global audace
   global conf

   if { [llength $args]==2 } {
       set filename [ file tail [ file rootname [ lindex $args 0 ] ] ]
       #-- Nul besoin d'inverser le signe de la pente car imaseries TILT se charge de compenser :
       set pente [ lindex $args 1 ]
       set angle [ expr atan($pente)*180./acos(-1.0) ]

       #--- Rotation de l'image :
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       # set xrot [ expr round(0.5*[ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]) ]
       set xrot 1
       set yrot [ expr round(0.5*[ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]) ]
       buf$audace(bufNo) imaseries "TILT trans_x=0 trans_y=$pente"
       buf$audace(bufNo) setkwd [ list "SPC_TILT" $angle float "Tilt angle" "degres" ]
       buf$audace(bufNo) setkwd [ list "SPC_TILX" $xrot int "Tilt X center" "pixel" ]
       buf$audace(bufNo) setkwd [ list "SPC_TILY" $yrot int "Tilt Y center" "pixel" ]
       buf$audace(bufNo) save "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
       ::console::affiche_resultat "Rotation sauvé sous ${filename}_tilt$conf(extension,defaut).\n"
       return ${filename}_tilt
   } else {
       ::console::affiche_erreur "Usage: spc_tilt3 fichier_fits pente\n\n"
   }
}
#***************************************************************************#



####################################################################
# Procédure de correction de l'inclinaison du spectre pour une série d'images
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-03-2007
# Date modification : 31-10-2012
# Arguments : nom générique des spectres à traiter
# Algo : fait la somme des spectres inclines, detecte l'angle, applique la rotation trouvée aux fichiers
####################################################################

proc spc_tiltautoimgs { args } {

    global audace spcaudace
    global conf

    if { [llength $args] <= 2 } {
	if { [llength $args] == 1 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject "o"
	} elseif { [llength $args] == 2 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D ?flag_reject (o/n)?\n\n"
	    return 0
	}

	#--- Applique le tilt au(x) spectre(s) incriminé(s)
	#-- Cas d'un seul fichier :
	if { [ file exists "$filename$conf(extension,defaut)" ] } {
           buf$audace(bufNo) load "$audace(rep_images)/$filename"
           set listemotsclef [ buf$audace(bufNo) getkwds ]
           if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 && [ lsearch $listemotsclef "SPC_XROT" ]!=-1 && [ lsearch $listemotsclef "SPC_YROT" ]!=-1 } {
              set angle [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
              set xrot [ lindex [ buf$audace(bufNo) getkwd "SPC_XROT" ] 1 ]
              set yrot [ lindex [ buf$audace(bufNo) getkwd "SPC_YROT" ] 1 ]
           } else {
              set results [ spc_findtilt "$filename" ]
              set angle [ lindex $results 0 ]
              set xrot [ lindex $results 1 ]
              set yrot [ lindex $results 2 ]
           }
           if { [ expr abs($angle) ]>$spcaudace(tilt_limit) } {
		::console::affiche_erreur "Attention : angle limite de tilt $spcaudace(tilt_limit) dépassé : mise à 0°\n"
		file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
		set spectre_tilte "${filename}_tilt"
		return "$spectre_tilte"
	    } else {
		#set yrot [ lindex [ spc_detect $filename ] 0 ]
		set spectre_tilte [ spc_tilt2 $filename $angle $xrot $yrot ]
                # set spectre_tilte [ spc_tiltauto $filename ]
		::console::affiche_resultat "Spectre corrigé sauvé sous $spectre_tilte\n"
		return "$spectre_tilte"
	    }
	} else {
	    #-- Cas de plusieurs fichiers :
	    set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" -tails "${filename}\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut)" ] ]
	    set nbsp [ llength $liste_images ]
	    #--- Détermination de l'angle de tilt :
	    ::console::affiche_resultat "Régistration verticale prélimiaire et somme de $nbsp spectres...\n"
	    #set freg [ spc_register "$filename" ]
	    #- 070908 : sadd -> smean :
            #- 091214 : smean -> sadd :
            #- 120930 : sadd -> ssk :
	    #set fsomme [ spc_ssk "$freg" ]
	    #delete2 $freg $nbsp
            set fsomme [ spc_ssk "$filename" ]
	    set results [ spc_findtilt "$fsomme" ]
	    file delete -force "$audace(rep_images)/$fsomme$conf(extension,defaut)"
	    set anglec [ lindex $results 0 ]
	    set xrotc [ lindex $results 1 ]
            set yrotc [ lindex $results 2 ]

	    #--- Tilt de la série d'images :
	    set i 1
	    ::console::affiche_resultat "$nbsp spectres à pivoter...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file rootname $lefichier ]
               buf$audace(bufNo) load "$audace(rep_images)/$fichier"
               set listemotsclef [ buf$audace(bufNo) getkwds ]
               if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 && [ lsearch $listemotsclef "SPC_XROT" ]!=-1 && [ lsearch $listemotsclef "SPC_YROT" ]!=-1 } {
                  set angle [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
                  set xrot [ lindex [ buf$audace(bufNo) getkwd "SPC_XROT" ] 1 ]
                  set yrot [ lindex [ buf$audace(bufNo) getkwd "SPC_YROT" ] 1 ]
               } else {
                  set angle $anglec 
                  set xrot $xrotc
                  set yrot $yrotc
               }
                if { [ expr abs($angle) ]>$spcaudace(tilt_limit) } {
                   ::console::affiche_erreur "Attention : angle limite de tilt $spcaudace(tilt_limit) dépassé : mise à 0°\n"
                   file copy -force "$audace(rep_images)/$fichier$conf(extension,defaut)" "$audace(rep_images)/${filename}-tilt-$i$conf(extension,defaut)"
                } else {
                   # set spectre_tilte [ spc_tiltauto $fichier ]
                   set spectre_tilte [ spc_tilt2 $fichier $angle $xrot $yrot ]
                   file rename -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}-tilt-$i$conf(extension,defaut)"
                   ::console::affiche_resultat "Spectre corrigé sauvé sous ${filename}-tilt-$i$conf(extension,defaut).\n\n"
                }
		incr i
	    }

	    #--- Messages d'information
	    #::console::affiche_resultat "Spectre corrigés sauvés sous ${filename}tilt-\*$conf(extension,defaut).\n"
	    return ${filename}-tilt-
	}
    } else {
	::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D ?flag_reject (o/n)?\n\n"
    }
}
#********************************************************************************#





####################################################################
# Procédure de correction de l'inclinaison du spectre pour une série d'images
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 20-03-2007
# Date modification : 21-03-2007
# Arguments : nom générique des spectres à traiter
# Algo : fait la somme des spectres inclines, detecte l'angle, applique la rotation trouvée aux fichiers
####################################################################

proc spc_tiltautoimgs_old1 { args } {

    global audace spcaudace
    global conf

    if { [llength $args] <= 2 } {
	if { [llength $args] == 1 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject "o"
	} elseif { [llength $args] == 2 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D ?flag_reject (o/n)?\n\n"
	    return 0
	}

	#--- Applique le tilt au(x) spectre(s) incriminé(s)
	#-- Cas d'un seul fichier :
	if { [ file exists "$filename$conf(extension,defaut)" ] } {
	    set results [ spc_findtilt "$filename" ]
	    set angle [ lindex $results 0 ]
	    set xrot [ lindex $results 1 ]
	    if { abs($angle)>$spcaudace(tilt_limit) } {
		::console::affiche_erreur "Attention : angle limite de tilt $spcaudace(tilt_limit) dépassé : mise à 0°\n"
		file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
		set spectre_tilte "${filename}_tilt"
		return "$spectre_tilte"
	    } else {
		#set yrot [ lindex [ spc_detect $filename ] 0 ]
		#set spectre_tilte [ spc_tilt2 $filename $angle $xrot $yrot ]
                set spectre_tilte [ spc_tiltauto $filename ]
		::console::affiche_resultat "Spectre corrigé sauvé sous $spectre_tilte\n"
		return "$spectre_tilte"
	    }
	} else {
	    #-- Cas de plusieurs fichiers :
	    set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" -tails "${filename}\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut)" ] ]
	    set nbsp [ llength $liste_images ]
	    #--- Détermination de l'angle de tilt :
	    ::console::affiche_resultat "Régistration verticale prélimiaire et somme de $nbsp spectres...\n"
	    set freg [ spc_register "$filename" ]
	    #- 070908 : sadd -> smean :
            #- 091214 : smean -> sadd :
            #- 120930 : sadd -> ssk :
	    set fsomme [ spc_ssk "$freg" ]
	    delete2 $freg $nbsp
	    set results [ spc_findtilt "$fsomme" ]
	    file delete -force "$audace(rep_images)/$fsomme$conf(extension,defaut)"
	    set angle [ lindex $results 0 ]
	    set xrot [ lindex $results 1 ]
	    set pente [ lindex $results 3 ]

	    #-- Test la valeur de l'angle :
	    if { abs($angle)>$spcaudace(tilt_limit) } {
		set angle 0.0
		set pente 0.0
		::console::affiche_erreur "Attention : angle limite de tilt $spcaudace(tilt_limit) dépassé : mise à 0°\n"
	    }

	    #--- Tilt de la série d'images :
	    set i 1
	    ::console::affiche_resultat "$nbsp spectres à pivoter...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file rootname $lefichier ]
		## set yrot [ lindex [ spc_detect $fichier ] 0 ]
		## set spectre_tilte [ spc_tilt2 $fichier $angle $xrot $yrot ]
		# set spectre_tilte [ spc_tilt3 $fichier $pente ]
                set spectre_tilte [ spc_tiltauto $filename ]
		file rename -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
		::console::affiche_resultat "Spectre corrigé sauvé sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		incr i
	    }

	    #--- Messages d'information
	    #::console::affiche_resultat "Spectre corrigés sauvés sous ${filename}tilt-\*$conf(extension,defaut).\n"
	    return ${filename}tilt-
	}
    } else {
	::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D ?flag_reject (o/n)?\n\n"
    }
}
#********************************************************************************#



####################################################################
# Procédure de correction de l'inclinaison du spectre pour une série d'images
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-07-2010
# Date modification : 03-07-2010
# Arguments : nom générique des spectres à traiter
# Algo : applique la rotation aux fichiers
####################################################################

proc spc_tilt2imgs { args } {

    global audace spcaudace
    global conf

    if { [llength $args] <= 4 } {
       set filename [ file rootname [ lindex $args 0 ] ]
       set angle [ lindex $args 1 ]
       set xrot [ lindex $args 2 ]
       set yrot [ lindex $args 3 ]

       #--- Applique le tilt au(x) spectre(s) incriminé(s)
       #-- Cas d'un seul fichier :
       if { [ file exists "$filename$conf(extension,defaut)" ] } {
          if { abs($angle)>$spcaudace(tilt_limit) } {
             ::console::affiche_erreur "Attention : angle limite de tilt $spcaudace(tilt_limit) dépassé : mise à 0°\n"
             file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_tilt$conf(extension,defaut)"
             set spectre_tilte "${filename}_tilt"
             return "$spectre_tilte"
          } else {
             set spectre_tilte [ spc_tilt2 $filename $angle $xrot $yrot ]
             ::console::affiche_resultat "Spectre corrigé sauvé sous $spectre_tilte\n"
             return "$spectre_tilte"
          }
	} else {
           #-- Cas de plusieurs fichiers :
           set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" -tails "${filename}\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut)" ] ]
           set nbsp [ llength $liste_images ]
           #--- Détermination de l'angle de tilt :
           # set pente [ expr tan($angle*acos(-1.0)/180) ]

           #-- Test la valeur de l'angle :
           if { abs($angle)>$spcaudace(tilt_limit) } {
              set angle 0.0
              set pente 0.0
              ::console::affiche_erreur "Attention : angle limite de tilt $spcaudace(tilt_limit) dépassé : mise à 0°\n"
           }

           #--- Tilt de la série d'images :
           set i 1
           ::console::affiche_resultat "$nbsp spectres à pivoter...\n\n"
           foreach lefichier $liste_images {
              set fichier [ file rootname $lefichier ]
              # set yrot [ lindex [ spc_detect $fichier ] 0 ]
              set spectre_tilte [ spc_tilt2 $fichier $angle $xrot $yrot ]
              # set spectre_tilte [ spc_tilt3 $fichier $pente ]
              file rename -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
              ::console::affiche_resultat "Spectre corrigé sauvé sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
              incr i
           }

           #--- Messages d'information
           #::console::affiche_resultat "Spectre corrigés sauvés sous ${filename}tilt-\*$conf(extension,defaut).\n"
           return "${filename}tilt-"
	}
    } else {
       ::console::affiche_erreur "Usage: spc_tilt2imgs nom_générique_spectre_2D angle(°) x_centre y_centre\n\n"
    }
}
#********************************************************************************#






####################################################################
# Procédure d'élimination des spectres bruts inexploitables : passage nuageux...
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 15-08-2006
# Date modification : 15-08-2006
# Arguments : nom générique des spectres à traiter
# Heuristique : si l'épaisseur du spectre est trop faible, l'image est considérée comme altérée.
####################################################################

proc spc_reject { args } {

    global audace
    global conf
    set hauteur_min 6.0

    if { [ llength $args ] == 1} {
	set nomgeneric [ lindex $args 0 ]
	set listeimg [ lsort -dictionary [ glob -dir $audace(rep_images) ${nomgeneric}\[0-9\]*$conf(extension,defaut) ] ]
	set nbimg [ llength $listeimg ]

	#--- Heuristique : si l'épaisseur du spectre est trop faible, l'image est considérée comme altérée.
	set i 0
	::console::affiche_resultat "Vérification de $nbimg spectres...\n"
	foreach spectre $listeimg {
	    set fichier [ file tail [ file rootname $spectre ] ]
	    set sp_hauteur [ lindex [ spc_detect $fichier ] 1 ]
	    if { $sp_hauteur < $hauteur_min } {
		incr i
		file rename $audace(rep_images)/$fichier$conf(extension,defaut) $audace(rep_images)/bad_$fichier$conf(extension,defaut)
		::console::affiche_resultat "Le spectre $fichier est altéré et est donc renomé en bad_$fichier\n"
	    }
	}

	#--- Renumerote les images dans le cas ou il y a au moins un rejet :
	if { $i >= 1 } {
	    renumerote $nomgeneric
	}
	::console::affiche_resultat "$i spectre(s) retiré(s) de la série\n"
    } else {
	::console::affiche_erreur "Usage: spc_reject nom_générique_spectre_2D\n\n"
    }
}
#********************************************************************************#






















#================================================================================#
#            Ancinennes implémentations                                          #
#================================================================================#



####################################################################
# Procédure de correction de l'inclinaison du spectre pour une série d'images
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-06-2006
# Date modification : 15-08-2006/24-08-06
# Arguments : nom générique des spectres à traiter
####################################################################

proc spc_tiltautoimgs_24082006 { args } {

    global audace
    global conf


    if { [llength $args] <= 2 } {
	if { [llength $args] == 1 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject "o"
	} elseif { [llength $args] == 2 } {
	    set filename [ file rootname [ lindex $args 0 ] ]
	    set reject [ lindex $args 1 ]
	} else {
	    ::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D ?flag_reject (o/n)?\n\n"
	    return 0
	}

	#--- Applique le smile au(x) spectre(s) incriminé(s)
	set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" "${filename}\[0-9\]*$conf(extension,defaut)" ] ]
	set nbsp [ llength $liste_images ]
	if { $nbsp==1 } {
	    set spectre_tilt [ spc_tiltauto $filename ]
	    ::console::affiche_resultat "Spectre corrigé sauvé sous $spectre_tilt$conf(extension,defaut)\n"
	    return $spectre_tilt
	} else {
	    set i 1
	    set nbspbad 0
	    ::console::affiche_resultat "$nbsp spectres à traiter...\n\n"
	    foreach lefichier $liste_images {
		set fichier [ file rootname [ file tail $lefichier ] ]
		set spectre_tilte [ spc_tiltauto $fichier ]
		#-- Cas des spectres dont la rotation excede une valeur seuil :
		if { [ regexp {(.+)tilt0+} $spectre_tilte match spectrem ] } {
		    if { $reject == "o" } {
			file delete -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)"
			file copy -force "$audace(rep_images)/$fichier$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt0-$i$conf(extension,defaut)"
			::console::affiche_resultat "Spectre non corrigé sauvé sous ${filename}tilt0-$i$conf(extension,defaut).\n\n"
		    } elseif { $reject == "n" } {
			file delete -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)"
			file copy -force "$audace(rep_images)/$fichier$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
			::console::affiche_resultat "Spectre non corrigé sauvé sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		    } else {
			::console::affiche_resultat "Mauvaise option de rejet de spectre.\n"
			return 0
		    }
		    incr nbspbad
		} else {
		    file rename -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
		    ::console::affiche_resultat "Spectre corrigé sauvé sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		}
		incr i
	    }

	    #--- Renumerote si des spectres ont ete ecrates de la serie :
	    if { $nbspbad >= 1 } {
		renumerote ${filename}tilt-
	    }

	    #--- Messages d'information
	    #::console::affiche_resultat "Spectre corrigés sauvés sous ${filename}tilt-\*$conf(extension,defaut).\n"
	    return ${filename}tilt-
	}
    } else {
	::console::affiche_erreur "Usage: spc_tiltautoimgs nom_générique_spectre_2D ?flag_reject (o/n)?\n\n"
    }
}
#********************************************************************************#

####################################################################
#  Procedure de registration horizontale de spectres 2D
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2008-03-16
# Date modification : 2008-03-16
# Arguments : nom_spectre_lampe nom_générique_spectres_objet
####################################################################

proc spc_registerh_v1 { args } {
   global audace
   global conf
   
   set nbargs [ llength $args ]
   if { $nbargs <= 3 } {
      if { $nbargs == 2 } {
         set nom_lampes [ lindex $args 0 ]
         set nomg_objet [ lindex $args 1 ]
      } elseif { $nbargs == 3 } {
         set nom_lampes [ lindex $args 0 ]
         set nomg_objet [ lindex $args 1 ]
         set wincoords [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_registerh nom_spectre_lampe ?nom_générique_spectres? ?coordonnees_zone_du_spectre?\n\n"
         return ""
      }

      #--- Crée la liste des spectres de la lampe et de l'objet (pretraite, smilex et tilt) :
      #-- Détermine le nom générique des spectres de la lampe :
      buf$audace(bufNo) load "$audace(rep_images)/$nom_lampes"
      if { [ lindex [ buf$audace(bufNo) getkwd "SPC_LNM" ] 1 ] != "" } {
         set nom_lampe_orig [ lindex [ buf$audace(bufNo) getkwd "SPC_LNM" ] 1 ]
         regexp {(.+)\-?[0-9]+} "$nom_lampe_orig" match nomg_lampe
         set nb_lampes 0
      } else {
         if { [ catch { regexp {(.+)\-?[0-9]+} "$nom_lampes" match nomg_lampe } ]==0 } {
            set nomg_lampe "$nom_lampes"
         } else {
            regexp {(.+)\-?[0-9]+} "$nom_lampes" match nomg_lampe
         }
         set nb_lampes 1
      }
      ::console::affiche_resultat "Nom générique des spectres de lampe : $nomg_lampe\n"

      #-- Liste des spectres :
      if { $nb_lampes==0 } {
         set lampesliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nomg_lampe}\[0-9\]$conf(extension,defaut) ${nomg_lampe}\[0-9\]\[0-9\]$conf(extension,defaut) ${nomg_lampe}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
         set nb_lampes [ llength $lampesliste ]
      } else {
         set lampesliste [ list "$nomg_lampe" ]
      }
      set spectresliste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nomg_objet}\[0-9\]$conf(extension,defaut) ${nomg_objet}\[0-9\]\[0-9\]$conf(extension,defaut) ${nomg_objet}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
      set nb_spobjet [ llength $spectresliste ]

      #set spobj1 [ lindex $spectresliste 0 ]
      #regexp {(.+)\-?[0-9]+} "$spobj1" match nomg_objet

      #--- Corrections géométriques des spectres de la lampe :
      #-- Récupère les coéfficients de déformation depuis le premier spectre d'objet :
      ::console::affiche_resultat "\n\n**** Corrections géométriques du spectre de la lampe de calibration ****\n"
      set spc_obj [ file tail [ lindex $spectresliste 0 ] ]
      buf$audace(bufNo) load "$audace(rep_images)/$spc_obj"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_TILT" ] !=-1 } {
         set angle [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
         set pente [ expr tan($angle*acos(-1.0)/180.) ]
         set flag_tilt 1
      } else {
         set flag_tilt 0
      }

      #-- Smilex :
      if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
         set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
         set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
         ::console::affiche_resultat "\n** Correction de la courbure des raies (smile selon l'axe x)... **\n"
         set lampesmilex [ spc_smileximgs $nomg_lampe $spc_ycenter $spc_cdeg2 ]
      } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
         set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
         ::console::affiche_resultat "\n** Correction de l'inclinaison des raies (slant)... **\n"
         set lampesmilex [ spc_slant2imgs $nomg_lampe $pente ]
      } else {
         ::console::affiche_resultat "\n** Aucune correction géométrique nécessaire. **\n"
         set lampesmilex "$nomg_lampe"
      }

      #-- Tilt :
      if { $flag_tilt==1 } {
         for { set i 1 } { $i<=$nb_lampes } { incr i } {
            set fsortie [ spc_tilt3 [ lindex $lampesliste [ expr $i-1 ] ] $pente ]
            file rename -force "$audace(rep_images)/$fsortie$conf(extension,defaut)" "$audace(rep_images)/${nomg_lampe}-tilt-$i$conf(extension,defaut)"
         }
      } else {
         set i 1
         foreach lampe $lampesliste {
            file copy -force "$lampe" "$audace(rep_images)/${nomg_lampe}-tilt-$i$conf(extension,defaut)"
            incr i
         }
      }

      #--- Crée un profil de raies des spectres de la lampe :
      #-- W : travaille pour l'instant qu'avec 2 spectres de lampe
      #-- Extrait le profil de raies :
      #- Lampe 1 :
      set somme_spobj [ bm_smean $nomg_objet ]
      if { $nbargs==2 } {
         set profil_lampe1 [ spc_profillampe $somme_spobj ${nomg_lampe}-tilt-1 "o" ]
      } elseif { $nbargs==3 } {
         set profil_lampe1 [ spc_profillampezone ${nomg_lampe}-tilt-1 $wincoords ]
      }
      #- Last lampe :
      if { $nbargs==2 } {
         set profil_lampe2 [ spc_profillampe $somme_spobj ${nomg_lampe}-tilt-$nb_lampes "o" ]
      } elseif { $nbargs==3 } {
         set profil_lampe2 [ spc_profillampezone ${nomg_lampe}-tilt-$nb_lampes $wincoords ]
      }

      #-- Détection des raies les plus brillantes :
      #- Liste des coupes (x,I) et sélectionne la plus brillante de la 1iere lampe :
      set listeraies [ spc_findbiglines $profil_lampe1 e ]
      #- Selection des raies dont I>=0.1*Imax et trie selon les abscisses :
      set listeraies [ lsort -decreasing -real -index 1 [ spc_selectstronglines $listeraies ] ]
      set abscisselinemax1 [ lindex [ lindex $listeraies 0 ] 0 ]
      ::console::affiche_resultat "Raies de calibration sélectionnées : $listeraies dont la plus intense est $abscisselinemax1\n"
      #- Liste des coupes (x,I) et sélectionne la plus brillante de la 2ieme lampe :
      set listeraies [ spc_findbiglines $profil_lampe2 e ]
      #- Selection des raies dont I>=0.1*Imax et trie selon les abscisses :
      set listeraies [ lsort -decreasing -real -index 1 [ spc_selectstronglines $listeraies ] ]
      set abscisselinemax2 [ lindex [ lindex $listeraies 0 ] 0 ]
      ::console::affiche_resultat "Raies de calibration sélectionnées : $listeraies dont la plus intense est $abscisselinemax2\n"

      #--- Détermine l'équation linéaire de la loi du décalage horizontal en pixel au cours du temps :
      #-- Calcul l'écart en pixel la raie la plus braillante entre ces 2 spectres :
      #set ecartx [ expr $abscisselinemax2-$abscisselinemax1 ]
      #-- Extrait la date du premier et dernier spectre de lampe :
      buf$audace(bufNo) load "$audace(rep_images)/$profil_lampe1"
      set date1 [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
      buf$audace(bufNo) load "$audace(rep_images)/$profil_lampe2"
      set date2 [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]

      #-- Détermine l'équation de la loi de décalage : decalage=a+b*temps
      set coefs [ lindex [ spc_ajustdeg1 [ list $date1 $date2 ] [ list $abscisselinemax1 $abscisselinemax2 ] .1 ] 0 ]
      set a [ lindex $coefs 0 ]
      set b [ lindex $coefs 1 ]
      ::console::affiche_resultat "Equation du recalage horizontal : $a+$b*Temps\n"

      #--- Calcul de décalage horizontal des spectres et le corrige :
      ::console::affiche_resultat "\nRecalage horizontal de $nb_spobjet sepctres...\n"
      for { set i 1 } { $i<=$nb_spobjet } { incr i } {
         set nomspobj [ lindex $spectresliste [ expr $i-1 ] ]
         buf$audace(bufNo) load "$nomspobj"
         set date [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
         set deltax [ expr -1.*($a+$date*$b-$abscisselinemax1) ]
         buf$audace(bufNo) imaseries "TRANS trans_x=$deltax trans_y=0"
         buf$audace(bufNo) save "$audace(rep_images)/${nomg_objet}-regh-$i"
      }

      #--- Nettoyage des fichiers temporaires :
      delete2 "${nomg_lampe}-tilt-" $nb_lampes
      delete2 "$lampesmilex" $nb_lampes
      file delete -force "$audace(rep_images)/$somme_spobj$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${nomg_lampe}-tilt-1_spc$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${nomg_lampe}-tilt-${nb_lampes}_spc$conf(extension,defaut)"

      #--- Affichage du résultat :
      ::console::affiche_resultat "Fichiers recalés horizontalement sauvés sous ${nomg_objet}-regh-\n"
      return "${nomg_objet}-regh-"
   } else {
       ::console::affiche_erreur "Usage: spc_registerh nom_spectre_lampe nom_générique_spectres\n\n"
   }
}
####################################################################

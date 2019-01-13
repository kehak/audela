####################################################################################
#
# Routines de manipulation de spectres échelle.
# Auteur : 
# Date de creation : 28-08-2005
# Date de mise a jour : 07-05-2016
# Chargement en script : source $spcaudace(rep_spc)/spc_echelle.tcl
#
#####################################################################################

# Mise a jour $Id: spc_echelle.tcl 14525 2018-11-09 18:22:10Z bmauclaire $


#***************************************************************************#
#*** Hypotheses de traitement :
#
# - Les ordres sont peu courbes, pas commes sur un eShell.
#     * Ainsi une decoupe des ordres par bandes horizontale est possible.
#     * On approxime le smiley a du tilt qui est plus rubuste.
# Il serait alors necessaire de realiser une découpe courbée en repérant 3 points le
# long d'un ordre lumineux (2 extremes et milieu du CCD). Puis déterminer le rayon
# de courbure et l'equation de la courbe délimitant les ordres.
#
# - Le slant des raies dans un ordre n'est pas corrigé car pas de solution actuelle.
# En effet, l'inclinaison des raies la même le long d'un même ordre.
#
#***************************************************************************#


#***************************************************************************#
#*** Succession des commandes :

#--- Pretraitement :
# spc_pretraitech Arcturus_ noir_arcturus_ plu_arcturus_ noirPLU_arcturus_
#-- -> Arcturus_-t--s5

#--- Corrections géométriques et création des profils :
# spc_geom2spcech arcturus Arcturus_-t--s5 plu_arcturus_-obtained-smd5.fit cal_arcturus_2.fit
#-- -> arcturus_profil_ordre-1... lampe_arcturus_profil_ordre-1...

#--- Calibration de la lampe :
#-- Recherche des raies dans la lampe par ordre :
# lsort -index 0 -increasing -real [ spc_findbiglineslamp lampe_arcturus_profil_1a_ordre-2 ]
# -> {5.17490842491 8154.59075092} {116.539261479 44436.4481978} {205.365175719 13729.684377} {530.860995851 6983.88132781} {639.445652174 6597.60869565} {796.518283063 44817.5203527} {975.715692712 18198.9420224} {1011.55754277 7437.16290825}

#-- Pour chaque ordre, asscocier les raies aux longueurs d'onde et calibrer :
# Meth1 : manuelle mais sure
# spc_calibren lampe_arcturus_profil_1a_ordre-2 116.539261479 6402.246 205.365175719 6416.307 796.518283063 6506.528 975.715692712 6532.882
#-- -> Loi de calibration : 6383.73403847+0.161341420413*(x-1)+-9.84051519604e-06*(x-1)^2+1.3337657167e-09*(x-1)^3 avec RMS=0.0000e+00
#-- -> llampe_arcturus_profil_1a_ordre-2

# Meth2 : automatique apres avoir cree les fichier calib_ordre-1.txt etc, mais necessite verif
# Description methode : http://wsdiscovery.free.fr/spcaudace/news/403/#calib
# Reduire la tolerence a 10 pixels :
# set spcaudace(largeur_recherche_raie) 10
# Usage: spc_calibrefile nom_profil_lampe_relco_redressee fichier_texte_xmoy_lambda ?largeur_recherche?

#--- Application de la calibration de la lampe au spectre d'objet pour chaque ordre :
#-- Calibration :
# spc_calibreloifile llampe_arcturus_profil_1a_ordre-2 arcturus_profil_ordre-2
#-- -> larcturus_profil_ordre-2

#-- Linearisation de la loi de calibration :
# spc_linearcal larcturus_profil_ordre-2
#-- -> larcturus_profil_ordre-2_linear

#--- FIN !

#***************************************************************************#



####################################################################
# Procédure de detections de la position des ordres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Exemple : spc_detectorders plu_arcturus_-obtained-smd5.fit
# Sortie : liste des positions des ordres
####################################################################

proc spc_geom2spcech { args } {
   global audace conf spcaudace
   #set flip "n"
   #set flag_norma "o"

   set nbargs [ llength $args ]
   if { $nbargs==4 } {
      set nom_objet [ lindex $args 0 ]
      set stellaire_traite [ file rootname [ lindex $args 1 ] ]
      set plu_traite [ file rootname [ lindex $args 2 ] ]
      set lampe [ file rootname [ lindex $args 3 ] ]
      set flag_norma "n"
      set flip "n"
   } elseif { $nbargs==5 } {
      set nom_objet [ lindex $args 0 ]
      set stellaire_traite [ file rootname [ lindex $args 1 ] ]
      set plu_traite [ file rootname [ lindex $args 2 ] ]
      set lampe [ file rootname [ lindex $args 3 ] ]
      set flag_norma [ lindex $args 4 ]
      set flip "n"
   } elseif { $nbargs==6 } {
      set nom_objet [ lindex $args 0 ]
      set stellaire_traite [ file rootname [ lindex $args 1 ] ]
      set plu_traite [ file rootname [ lindex $args 2 ] ]
      set lampe [ file rootname [ lindex $args 3 ] ]
      set flag_norma [ lindex $args 4 ]
      set flip [ lindex $args 5 ]
   } else {
      ::console::affiche_erreur "Usage: spc_geom2spcech nom_objet_sans_espaces spectre_stellaire_traite spectre_2d_plu_traitee spectre_lampe ?normalisation (o/n)? ?flip_gauche_droite(o/n)?\n"
      return ""
   }

   ::console::affiche_prompt "\n****** DÉBUT geom2spc ******\n"
   #--- Extraction des ordres :
   ::console::affiche_prompt "\n\n****** Extraction des ordres... *******\n"
   set plu_binnee [ spc_binpluech "$plu_traite" ]
   set liste_pos [ spc_detectorders "$plu_binnee" ]
   set ordres_plu [ spc_cropordres "plu_$nom_objet" "$plu_traite" $liste_pos ]
   set ordres_stellaire [ spc_cropordres "$nom_objet" "$stellaire_traite" $liste_pos ]
   set ordres_lampe [ spc_cropordres "lampe_$nom_objet" "$lampe" $liste_pos ]

   #--- Correction du smiley :
   ::console::affiche_prompt "\n\n****** Correction géométriques... *******\n"
   set ordres_plu_sly [ spc_smileyech "$ordres_plu" ]
   set ordres_stellaire_sly [ spc_smiley2imgech "$nom_objet" "$ordres_stellaire" "$ordres_plu_sly" ]
   set ordres_lampe_sly [ spc_smiley2imgech "lampe_$nom_objet" "$ordres_lampe" "$ordres_plu_sly" ]

   #--- Inversion gauche-droite pour avoir le bleu sur la gauche des profils :
   if { "$flip"=="o" } {
      ::console::affiche_prompt "\n\n****** Inversion gauche-droite... *******\n"
      set ordres_stellaire_final [ spc_flipech "$nom_objet" "$ordres_stellaire_sly" ]
      set ordres_lampe_final [ spc_flipech "lampe_$nom_objet" "$ordres_lampe_sly" ]
      set ordres_plu_final [ spc_flipech "plu_$nom_objet" "$ordres_plu_sly" ]
   } else {
      set ordres_stellaire_final "$ordres_stellaire_sly"
      set ordres_lampe_final "$ordres_lampe_sly"
      set ordres_plu_final "$ordres_plu_sly"
   }

   #--- Extraction des profils de raies :
   ::console::affiche_prompt "\n\n****** Création des profils de raies... *******\n"
   set profil_ordres_stellaire_last [ spc_profilech "$nom_objet" "$ordres_stellaire_final" ]
   set profil_ordres_lampe [ spc_profilech "lampe_$nom_objet" "$ordres_lampe_final" ]
   set profil_ordres_plu [ spc_profilech "plu_$nom_objet" "$ordres_plu_final" ]

   #--- Normalisation des profils stellaires à défaut de division par la ri :
   if { "$flag_norma"=="o" } {
      ::console::affiche_prompt "\n\n****** Normalisation des profils de raies... *******\n"
      set profil_ordres_stellaire [ spc_normaech "$nom_objet" "$profil_ordres_stellaire_last" ]
   } else {
      set profil_ordres_stellaire ""
   }
   

   #--- Menage :
   #-- Déplacement des ordres 2D traites dans le sous-rep ordres_2d_traites :
   ::console::affiche_prompt "\n\n****** Déplacement des ordres 2D dans rep_stockage_2d... *******\n"
   set rep_stockage_2d "${nom_objet}_ordres_2d_traites"
   set rep_stockage_1d "${nom_objet}_ordres_1d_traites"
   set rep_stockage_1d_nonorma "non_norma"
   file mkdir "$audace(rep_images)/$rep_stockage_1d"
   file mkdir "$audace(rep_images)/$rep_stockage_2d"
   file mkdir "$audace(rep_images)/$rep_stockage_1d/$rep_stockage_1d_nonorma"
   set liste_profil_stell_nonorma [ glob -dir $audace(rep_images) -tails ${profil_ordres_stellaire_last}\[0-9\]$conf(extension,defaut) ${profil_ordres_stellaire_last}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   if { "$flag_norma"=="o" } {
      set liste_profil_stell [ glob -dir $audace(rep_images) -tails ${profil_ordres_stellaire}\[0-9\]$conf(extension,defaut) ${profil_ordres_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   } else {
      set liste_profil_stell [ list ]
   }
   set liste_profil_lampe [ glob -dir $audace(rep_images) -tails ${profil_ordres_lampe}\[0-9\]$conf(extension,defaut) ${profil_ordres_lampe}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   set liste_profil_plu [ glob -dir $audace(rep_images) -tails ${profil_ordres_plu}\[0-9\]$conf(extension,defaut) ${profil_ordres_plu}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   set liste_stell [ glob -dir $audace(rep_images) -tails ${ordres_stellaire_final}\[0-9\]$conf(extension,defaut) ${ordres_stellaire_final}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   set liste_lampe [ glob -dir $audace(rep_images) -tails ${ordres_lampe_final}\[0-9\]$conf(extension,defaut) ${ordres_lampe_final}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   set liste_plu [ glob -dir $audace(rep_images) -tails ${ordres_plu_final}\[0-9\]$conf(extension,defaut) ${ordres_plu_final}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   set nb_ordres 0
   foreach profil_stella $liste_profil_stell profil_stella_nonorma $liste_profil_stell_nonorma profil_lampe $liste_profil_lampe profil_plu $liste_profil_plu  stella $liste_stell lampa $liste_lampe plu $liste_plu {
      if { "$flag_norma"=="o" } {
         file rename -force "$audace(rep_images)/$profil_stella" "$audace(rep_images)/$rep_stockage_1d/$profil_stella"
      }
      file rename -force "$audace(rep_images)/$profil_stella_nonorma" "$audace(rep_images)/$rep_stockage_1d/$rep_stockage_1d_nonorma/$profil_stella_nonorma"
      file rename -force "$audace(rep_images)/$profil_lampe" "$audace(rep_images)/$rep_stockage_1d/$profil_lampe"
      file rename -force "$audace(rep_images)/$profil_plu" "$audace(rep_images)/$rep_stockage_1d/$profil_plu"
      file rename -force "$audace(rep_images)/$stella" "$audace(rep_images)/$rep_stockage_2d/$stella"
      file rename -force "$audace(rep_images)/$lampa" "$audace(rep_images)/$rep_stockage_2d/$lampa"
      file rename -force "$audace(rep_images)/$plu" "$audace(rep_images)/$rep_stockage_2d/$plu"
      incr nb_ordres
   }

   
   #-- Reste du menage :
   ##set liste_ordres [ glob -dir $audace(rep_images) -tails ${ordres_plu_sly}\[0-9\]$conf(extension,defaut) ${ordres_plu_sly}\[0-9\]\[0-9\]$conf(extension,defaut) ]
   ##set nb_ordres [ llength $liste_ordres ]

   file delete -force "$audace(rep_images)/$plu_binnee"
   delete2 $ordres_plu $nb_ordres ; #- Decommenter pour debug
   delete2 $ordres_stellaire $nb_ordres
   delete2 $ordres_lampe $nb_ordres
   delete2 $ordres_plu_sly $nb_ordres
   delete2 $ordres_stellaire_sly $nb_ordres
   delete2 $ordres_lampe_sly $nb_ordres
   ##delete2 $profil_ordres_stellaire_last $nb_ordres
   
   #--- Traitement des resultats :
   set liste_profils_finaux "$profil_ordres_stellaire_last"
   #set liste_profils_finaux "$profil_ordres_stellaire"
   set results [ list "$liste_profils_finaux" "$profil_ordres_lampe" ]
   ::console::affiche_prompt "\n****** FIN geom2spc ******\n"
   ::console::affiche_prompt "Profils des ordres stellaires et de lampe sauvés sous : $results\n\n"
   return $results
}
#***************************************************************************#


####################################################################
# Procédure de detections de la position des ordres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Exemple : spc_detectorders plu_arcturus_-obtained-smd5.fit
# Sortie : liste des positions des ordres
####################################################################

proc spc_binpluech { args } {
   global audace conf spcaudace
   set coef_largeur_bin 0.3
   
   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set plufile [ file rootname [ lindex $args 0 ] ]
   } else {
      ::console::affiche_erreur "Usage: spc_binpluech spectre_2d_plu_traitee\n"
      return ""
   }

   #--- Creation du profil des ordres de la PLU :
   buf$audace(bufNo) load "$audace(rep_images)/$plufile"
   #-- Binning sur toute la largeur : BAD
   if { 1==0 } {
      buf$audace(bufNo) imaseries "INVERT XY"
      buf$audace(bufNo) mirrorx
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      #-- Specificite Sardine : peu courbés et courbés vers le haut
      set xmax [ expr int($naxis1*0.5) ]
      buf$audace(bufNo) imaseries "mediany y1=1 y2=$xmax height=1"
   }
   
   #-- Binning sur la zone centrale de largeur 30% du CCD :
   set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
   set xmid [ expr int($naxis2*0.5) ]
   set xmin [ expr round($xmid-0.5*$coef_largeur_bin*$naxis2) ]
   set xmax [ expr round($xmid+0.5*$coef_largeur_bin*$naxis2) ]
   buf$audace(bufNo) imaseries "medianx x1=$xmin x2=$xmax width=1"
   buf$audace(bufNo) imaseries "INVERT XY"
   buf$audace(bufNo) mirrorx
   #set naxis1 $naxis2

   #--- Sauvegarde du profil et detection :
   buf$audace(bufNo) save1d "$audace(rep_images)/detect_orders$conf(extension,defaut)"

   #--- Fin de script :
   return "detect_orders$conf(extension,defaut)"
}
#***************************************************************************#



####################################################################
# Recherche de la position des ordres en determinant les 0 dans les decroissances de la derivee
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 11-07-2017
# Date modification : 11-07-2017
# Arguments : nom_profil_raies_plu_binnee
# Exemple : spc_detectorders plu_arcturus_-obtained-smd5.fit
# Sortie : liste des positions des ordres
# Amelioration robustess : filtrer fichier de la derivee
####################################################################

proc spc_detectorders { args } {
    global conf
    global audace

    if { [llength $args] == 1 } {
       set plu_binned [ file tail [ file rootname [ lindex $args 0 ] ] ]

       #--- Filtrage doux pour eliminer des petits maxima dus au bruit du continuum :
       set sp_smoothed [ spc_smooth "$plu_binned" 1 ]
       
       #--- Derivation :
       set listevals [ spc_fits2data "$sp_smoothed" ]
       set listevalsdervie [ spc_derivation $listevals ]
       set ordonnees [ lindex $listevalsdervie 0 ]
       set intensites [ lindex $listevalsdervie 1 ]
       set nbvals [ llength $intensites ]

       #--- Export optionnel en .dat de la derivee :
       if { 1==0 } {
          set fileout "derivee.dat"
          set file_id [open "$audace(rep_images)/$fileout" w+]
          for { set k 1 } { $k<=$nbvals } { incr k } {
             set pixel $k
             set intensite [ lindex $intensites [ expr $k-1 ] ]
             puts $file_id "$pixel\t$intensite"
          }
          close $file_id
       }

       #--- Recherche des valeurs nulles :
       set liste_maxima [ list ]
       set indice_max [ expr $nbvals-3 ]
       for { set k 1 } { $k<=$indice_max } { incr k } {
          set intensite_k [ lindex $intensites $k ]
          if { $intensite_k<0 } {
             continue
          } else {
             set intensite_k1 [ lindex $intensites [ expr $k+1 ] ]
             set intensite_k2 [ lindex $intensites [ expr $k+2 ] ]
             if { $intensite_k1<0 && $intensite_k2<0 } {
                lappend liste_maxima [ lindex $ordonnees [ expr $k+1 ] ]
             } else {
                continue
             }
          }
       }

       #--- Calcul la valeur complementaire des positions car il y un mirrorx necessaire pour le bon focntionnement de findbiglines :
       set liste_pos_finale [ list ]
       set naxis1 $nbvals
       foreach position $liste_maxima {
          lappend liste_pos_finale [ expr $naxis1-$position ]
       }
       

       #--- Fin de script :
       file delete -force "$audace(rep_images)/$sp_smoothed$conf(extension,defaut)"
       set nbmax [ llength $liste_maxima ]
       ::console::affiche_resultat "$nbmax maxima trouvés\n"
       #return $liste_maxima
       return $liste_pos_finale
    } else {
       ::console::affiche_erreur "Usage: spc_detectorders nom_profil_raies\n"
    }
}
#***************************************************************************



####################################################################
# Procédure de detections de la position des ordres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Exemple : spc_detectorders plu_arcturus_-obtained-smd5.fit
# Sortie : liste des positions des ordres
####################################################################

proc spc_detectorders0 { args } {
   global audace conf spcaudace
   #-- Largeur ordre sous forme de raie :
   set demi_largeur_ordre 9

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set plufile [ file rootname [ lindex $args 0 ] ]
   } else {
      ::console::affiche_erreur "Usage: spc_detectorders spectre_2d_plu_traitee\n"
      return ""
   }

   #--- Detection des ordres les plus brillants :
   buf$audace(bufNo) load "$audace(rep_images)/$plufile"
   if { 1==0 } {
   buf$audace(bufNo) imaseries "INVERT XY"
   buf$audace(bufNo) mirrorx
   set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   #-- Specificite Sardine : peu courbés et courbés vers le haut
   set xmax [ expr int($naxis1*0.5) ]
   buf$audace(bufNo) imaseries "mediany y1=1 y2=$xmax height=1"
   }
   set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
   set xmax $naxis2
   buf$audace(bufNo) imaseries "medianx x1=1 x2=$xmax width=1"
   buf$audace(bufNo) imaseries "INVERT XY"
   buf$audace(bufNo) mirrorx
   set naxis1 $naxis2
   #-- Sauvegarde du profil et detection :
   buf$audace(bufNo) save1d "$audace(rep_images)/detect_orders$conf(extension,defaut)"

   #--- Recherche de la position des ordres :
   ## spc_findbiglines detect_orders e
   set liste_pos_int [ spc_findbiglineslamp detect_orders.fit ]
   set nb_ordres_mes [ llength $liste_pos_int ]
   ::console::affiche_resultat "Nombre préliminaire d'ordres : $nb_ordres_mes\n"
   
   #--- Rassemblement de seulement les positions :
   set liste_pos [ list ]
   foreach element $liste_pos_int {
      #lappend liste_pos [ expr int([ lindex $element 0 ]) ]
      lappend liste_pos [ lindex $element 0 ]
   }

   
   
   #--- Detection des autres ordres :
   ::console::affiche_resultat "Recherche des ordres de faible intensité...\n"
   # manque 4 ordres faibles dont 3 exploitables (separes de 47 pixels, coupÃ©s tous les xcentre-23;xcentre+23
   #-> faire les decoupes a l'aveugle jusqu'a NAXIS1
   set last_index [ expr [ llength $liste_pos ]-1 ]
   set position_n [ lindex $liste_pos $last_index ]
   set position_n_1 [ lindex $liste_pos [ expr $last_index-1 ] ]
   set ecart_ordres [ expr $position_n-$position_n_1 ]
   set position_np1 [ expr $position_n+$ecart_ordres ]
   if { $position_np1<$naxis1 } {
      buf$audace(bufNo) load "$audace(rep_images)/detect_orders$conf(extension,defaut)"
      set i $position_np1
      while { $i<=$naxis1 } {
         set pos_mesuree [ lindex [ buf$audace(bufNo) fitgauss [ list [ expr round($i-$demi_largeur_ordre) ] 1 [ expr round($i+$demi_largeur_ordre) ] 1 ] ] 1 ]
         lappend liste_pos $pos_mesuree
         set i [ expr $pos_mesuree+$ecart_ordres ]
      }
   }

   #--- Tri par ordre decroissant :
   #set liste_pos [ lsort -decreasing -real $liste_pos ]
   #--- Calcul la valeur complementaire des positions car il y un mirrorx necessaire pour le bon focntionnement de findbiglines :
   set liste_pos_finale [ list ]
   foreach position $liste_pos {
      lappend liste_pos_finale [ expr $naxis1-$position ]
   }
   
   #--- Traitement du resultat :
   file delete -force "$audace(rep_images)/detect_orders$conf(extension,defaut)"
   set nb_ordres [ llength $liste_pos_finale ]
   ::console::affiche_resultat "Nombre d'ordres exploitables trouvés : $nb_ordres\n"
   return $liste_pos_finale
}
#***************************************************************************#



####################################################################
# Procédure de decoupe des ordres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D, liste des position des ordres
# Sortie : nom generique de la serie de spectres 2D
# Exemple : spc_cropordres arcturus- plu_arcturus_-obtained-smd5.fit { 983.160714286 897.342105263 816.710526316 740.703703704 669.068627451 601.388888889 537.31 476.587349398 418.857142857 363.977272727 311.674418605 261.880597015 214.242857143 168.774926 125.231334 83.413035 42.919889 }
# Exemple 2 : Arcturus_-t--s5.fit
####################################################################

proc spc_cropordres { args } {
   global audace conf spcaudace
   #-- Largeur ordre sous forme de raie :
   set demi_largeur_ordre 9
   set coeff_hauteur_ordre 0.70 ; # avant 20170711 : 0.75
   #-- Nom de l'objet :
   #set nom_ordre "ordre-"

   set nbargs [ llength $args ]
   if { $nbargs==3 } {
      set nom_sortie [ lindex $args 0 ]
      set spectre2d [ file rootname [ lindex $args 1 ] ]
      set liste_pos [ lindex $args 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_cropordres nom_generique_de_sortie(arcturus) spectre_2d liste_positions_ordres\n"
      return ""
   }
   set nom_ordre "${nom_sortie}_ordre-"

   #--- Informations sur le spectre :
   #-- Dimension du spectre :
   buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
   set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]

   
   #--- Decoupe des ordres :
   #-- On commence en haut (car la lite des pos est decroissante)
   #-- Hytpothese : ordre lumineux dans la partie superieure de l'image
   set index_pos_max [ expr [ llength $liste_pos ]-1 ]
   set index_pos 0
   set no_ordre 1
   foreach position_ordre $liste_pos {
      set index_pos_np1 [ expr $index_pos+1 ]
      if { $index_pos_np1<=$index_pos_max } {
         set position_ordre_np1 [ lindex $liste_pos $index_pos_np1 ]
         if { $index_pos==0 } {
            #-- Premier ordre, en haut d'image, contre y=naxis2 : 
            set dsepa_ordre [ expr ($position_ordre_np1-$position_ordre)*$coeff_hauteur_ordre ]
            set yinf [ expr round($position_ordre-$dsepa_ordre) ]
            set ysup [ expr round($position_ordre+$dsepa_ordre) ]
            if { $ysup>$naxis2 } { set ysup $naxis2 }
            buf$audace(bufNo) window [ list 1 $yinf $naxis1 $ysup ]
            buf$audace(bufNo) save "$audace(rep_images)/$nom_ordre$no_ordre"
         } else {
            #-- Ordres entre 2 et n-1 inclus :
            set dsepa_ordre [ expr ($position_ordre_np1-$position_ordre)*$coeff_hauteur_ordre ]
            set yinf [ expr round($position_ordre-$dsepa_ordre) ]
            set ysup [ expr round($position_ordre+$dsepa_ordre) ]
            buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
            buf$audace(bufNo) window [ list 1 $yinf $naxis1 $ysup ]
            buf$audace(bufNo) save "$audace(rep_images)/$nom_ordre$no_ordre"
         }
      } else {
         #-- Dernier crop en bas, contre y=1 :
         set index_pos_nm1 [ expr $index_pos-1 ]
         set position_ordre_nm1 [ lindex $liste_pos $index_pos_nm1 ]
         set dsepa_ordre [ expr ($position_ordre-$position_ordre_nm1)*$coeff_hauteur_ordre ]
         set yinf [ expr round($position_ordre-$dsepa_ordre) ]
         set ysup [ expr round($position_ordre+$dsepa_ordre) ]
         if { $yinf<1 } { set yinf 1 }
         buf$audace(bufNo) load "$audace(rep_images)/$spectre2d"
         buf$audace(bufNo) window [ list 1 $yinf $naxis1 $ysup ]
         buf$audace(bufNo) save "$audace(rep_images)/$nom_ordre$no_ordre"
      }
      incr index_pos
      incr no_ordre
   }
   set nb_ordres $no_ordre

   #--- Traitement du resultat :
   ::console::affiche_resultat "Nombre d'ordre distincts sauvés sous $nom_ordre : $nb_ordres\n"
   return "$nom_ordre"
}
#***************************************************************************#


####################################################################
# Procédure de mesure et de correction du smiley sur les plu
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Sortie : liste des positions des ordres
####################################################################

proc spc_smileyech { args } {
   global audace conf spcaudace
   set out_final "plu_sly_ordre-"

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set plu_name [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_smileyech nom_generic_ordres_plu\n"
      return ""
   }

   #--- Liste des fichiers :
   set liste_files [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${plu_name}\[0-9\]$conf(extension,defaut) ${plu_name}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

   #--- Mesure et correction du smiley :
   set i 1
   foreach fichier $liste_files {
      #- set outfile [ lindex [ spc_smiley "$fichier" ] 0 ]
      set outfile [ spc_tiltauto "$fichier" ] ; #- 20170711 : tilt plutot que smiley
      file rename -force "$audace(rep_images)/$outfile$conf(extension,defaut)" "$audace(rep_images)/$out_final$i$conf(extension,defaut)"
      incr i
   }

   #--- Resultat :
   ::console::affiche_resultat "$plu_name : $i ordres corrigés du smiley\n"
   return "$out_final"
}
#***************************************************************************#


####################################################################
# Procédure de correction du smiley d'une serie de spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Sortie : liste des positions des ordres
####################################################################

proc spc_smiley2imgech { args } {
   global audace conf spcaudace
   set flag_smiley "n"
   
   set nbargs [ llength $args ]
   if { $nbargs==3 } {
      set nom_objet [ lindex $args 0 ]
      set nom_ordres_stellaire [ lindex $args 1 ]
      set nom_ordres_plu [ lindex $args 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_smiley2imgech nom_objet nom_ordres_stellaire nom_ordres_plu\n"
      return ""
   }

   #--- Liste des fichiers :
   set out_final "${nom_objet}_sly_ordre-"
   set liste_stellaire [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_ordres_stellaire}\[0-9\]$conf(extension,defaut) ${nom_ordres_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
   set liste_plu [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_ordres_plu}\[0-9\]$conf(extension,defaut) ${nom_ordres_plu}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

   #--- Mesure et correction du smiley :
   set i 1
   foreach stellaire $liste_stellaire plu $liste_plu {
      buf$audace(bufNo) load "$audace(rep_images)/$plu"
      if { "$flag_smiley"=="o" } {
         set sly1 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLY1" ] 1 ]
         set sly2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLY2" ] 1 ]
         buf$audace(bufNo) load "$audace(rep_images)/$stellaire"
         buf$audace(bufNo) imaseries "SMILEY xcenter=$sly1 coef_smile2=$sly2"
      } else {
         set xrot [ lindex [ buf$audace(bufNo) getkwd "SPC_TILX" ] 1 ]
         set yrot [ lindex [ buf$audace(bufNo) getkwd "SPC_TILY" ] 1 ]
         set angle [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
         set pente [ expr tan(($angle*acos(-1.0))/180.) ]
         buf$audace(bufNo) load "$audace(rep_images)/$stellaire"
         buf$audace(bufNo) imaseries "TILT trans_x=0 trans_y=$pente"
         buf$audace(bufNo) setkwd [ list "SPC_TILT" $angle float "Tilt angle" "degres" ]
         buf$audace(bufNo) setkwd [ list "SPC_TILX" $xrot int "Tilt X center" "pixel" ]
         buf$audace(bufNo) setkwd [ list "SPC_TILY" $yrot int "Tilt Y center" "pixel" ]
      }
      buf$audace(bufNo) save "$audace(rep_images)/$out_final$i"
      incr i
   }
   
   #--- Resultat :
   ::console::affiche_resultat "$nom_objet : $i ordres corrigés du smiley\n"
   return "$out_final"
}
#***************************************************************************#


####################################################################
# Procédure 
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Sortie : liste des positions des ordres
####################################################################

proc spc_flipech { args } {
   global audace conf spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set nom_objet [ lindex $args 0 ]
      set nom_spectre [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_flipech nom_objet nom_generic_spectres\n"
      return ""
   }

   #--- Liste des fichiers :
   set out_final "${nom_objet}_sly_flip_ordre-"
   set liste_files [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_spectre}\[0-9\]$conf(extension,defaut) ${nom_spectre}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

   #--- Inversion gauche-droite :
   set i 1
   foreach fichier $liste_files {
      buf$audace(bufNo) load "$audace(rep_images)/$fichier"
      buf$audace(bufNo) mirrorx
      buf$audace(bufNo) save "$audace(rep_images)/$out_final$i"
      incr i
   }

   #--- Resultat :
   ::console::affiche_resultat "$i ordres inversés gauche-droite\n"
   return "$out_final"
}
#***************************************************************************#


####################################################################
# Procédure 
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Sortie : liste des positions des ordres
####################################################################

proc spc_profilech { args } {
   global audace conf spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set nom_objet [ lindex $args 0 ]
      set nom_spectre [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_profilech nom_objet nom_generic_spectres_2d\n"
      return ""
   }

   #--- Liste des fichiers :
   set out_final "${nom_objet}_profil_1a_ordre-"
   set liste_files [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_spectre}\[0-9\]$conf(extension,defaut) ${nom_spectre}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

   #--- Hauteur de binning :
   set option "large"
   
   #--- Creation du profil de raies :
   set i 1
   foreach fichier $liste_files {
      set outfile [ spc_profil "$fichier" none $option ]
      file rename -force "$audace(rep_images)/$outfile$conf(extension,defaut)" "$audace(rep_images)/$out_final$i$conf(extension,defaut)"
      incr i
   }

   #--- Resultat :
   ::console::affiche_resultat "$i profils de raies créés\n"
   return "$out_final"
}
#***************************************************************************#


####################################################################
# Procédure 
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 07-05-2016
# Date modification : 07-05-2016
# Arguments : spectre 2D plu traite
# Sortie : liste des positions des ordres
####################################################################

proc spc_normaech { args } {
   global audace conf spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set nom_objet [ lindex $args 0 ]
      set nom_spectre [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_normaech nom_objet nom_generic_profils\n"
      return ""
   }

   #--- Liste des fichiers :
   set out_final "${nom_objet}_profil_ordre-"
   set liste_files [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_spectre}\[0-9\]$conf(extension,defaut) ${nom_spectre}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

   #--- Creation du profil de raies :
   set i 1
   foreach fichier $liste_files {
      set outfile [ spc_autonorma "$fichier" ]
      file rename -force "$audace(rep_images)/$outfile$conf(extension,defaut)" "$audace(rep_images)/$out_final$i$conf(extension,defaut)"
      incr i
   }

   #--- Resultat :
   ::console::affiche_resultat "$i profils de raies normalisés\n"
   return "$out_final"
}
#***************************************************************************#

















###############################################################################
# Description : effectue le prétraitement d'une série d'images brutes
#
# Auteur : Benjamin MAUCLAIRE
# Date création : 27-08-2005
# Date de mise à jour : 21-12-2005/2007-01-03/2007-07-10/2007-08-01
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu effacement des masters (O/n) ?liste_coordonnées_fenêtre_étude?
# Méthode : par soustraction du noir et sans offset.
# Bug : Il faut travailler dans le rep parametre d'Audela, donc revoir toutes les operations !!
###############################################################################

proc spc_pretraitech { args } {

   global conf audace spcaudace
   set spcaudace(exposure) 0.

   set nbargs [ llength $args ]
   if {$nbargs <= 7} {
       if { $nbargs== 4} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset "none"
           set flag_rmmaster "o"
           set flag_nonstellaire 0
       } elseif {$nbargs == 5} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
           set flag_rmmaster "o"
           set flag_nonstellaire 0
       } elseif {$nbargs == 6} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
           set flag_rmmaster [ lindex $args 5 ]
           set flag_nonstellaire 0
       } elseif {$nbargs == 7} {
           #--- On se place dans le répertoire d'images configuré dans Audace
           set repdflt [ spc_goodrep ]
           set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
           set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
           set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
           set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
           set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
           set flag_rmmaster [ lindex $args 5 ]
           set spc_windowcoords [ lindex $args 6 ]
           set flag_nonstellaire 1
       } else {
           ::console::affiche_erreur "Usage: spc_pretrait nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?nom_offset (none)? ?effacement des masters (o/n)? ?liste_coordonnées_fenêtre_étude?\n\n"
           return ""
       }


       #--- Compte les images :
       ## Renumerote chaque série de fichier
       #renumerote $nom_stellaire
       #renumerote $nom_dark
       #renumerote $nom_flat
       #renumerote $nom_darkflat

       ## Détermine les listes de fichiers de chasue série
       #set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_dark}\[0-9\]*$conf(extension,defaut) ] ]
       #set nb_dark [ llength $dark_liste ]
       #set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_flat}\[0-9\]*$conf(extension,defaut) ] ]
       #set nb_flat [ llength $flat_liste ]
       #set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]*$conf(extension,defaut) ] ]
       #set nb_darkflat [ llength $darkflat_liste ]
       #---------------------------------------------------------------------------------#
       if { 1==0 } {
       set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut)  ] ]
       set nb_stellaire [ llength $stellaire_liste ]
       #-- Gestion du cas des masters au lieu d'une série de fichier :
       if { [ catch { glob -dir $audace(rep_images) ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
           set dark_list [ list $nom_dark ]
           set nb_dark 1
       } else {
           set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_dark [ llength $dark_liste ]
       }
       if { [ catch { glob -dir $audace(rep_images) ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
           set flat_list [ list $nom_flat ]
           set nb_flat 1
       } else {
           set flat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_flat [ llength $flat_liste ]
       }
       if { [ catch { glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) } ] } {
           set darkflat_list [ list $nom_darkflat ]
           set nb_darkflat 1
       } else {
           set darkflat_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_darkflat [ llength $darkflat_liste ]
       }
       }
       #---------------------------------------------------------------------------------#

       #--- Compte les images :
       if { [ file exists "$audace(rep_images)/$nom_stellaire$conf(extension,defaut)" ] } {
           set stellaire_liste [ list $nom_stellaire ]
           set nb_stellaire 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
          set prestel_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
          if { [ llength $prestel_list ]==1 } {
             set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
             set nb_stellaire 1
          } else {
             renumerote $nom_stellaire
             set stellaire_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
             set nb_stellaire [ llength $stellaire_liste ]
          }
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_stellaire n'existe(nt) pas.\n"
           return ""
       }
       if { [ file exists "$audace(rep_images)/$nom_dark$conf(extension,defaut)" ] } {
           set dark_liste [ list $nom_dark ]
           set nb_dark 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_dark
           set dark_liste [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_dark}\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_dark}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_dark [ llength $dark_liste ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_dark n'existe(nt) pas.\n"
           return ""
       }
       if { [ file exists "$audace(rep_images)/$nom_flat$conf(extension,defaut)" ] } {
           set flat_list [ list $nom_flat ]
           set nb_flat 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_flat
           set flat_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_flat}\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_flat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_flat [ llength $flat_list ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_flat n'existe(nt) pas.\n"
           return ""
       }
       if { [ file exists "$audace(rep_images)/$nom_darkflat$conf(extension,defaut)" ] } {
           set darkflat_list [ list $nom_darkflat ]
           set nb_darkflat 1
       } elseif { [ catch { glob -dir $audace(rep_images) ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
           renumerote $nom_darkflat
           set darkflat_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_darkflat}\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_darkflat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
           set nb_darkflat [ llength $darkflat_list ]
       } else {
           ::console::affiche_erreur "Le(s) fichier(s) $nom_darkflat n'existe(nt) pas.\n"
           return ""
       }
       if { $nom_offset!="none" } {
           if { [ file exists "$audace(rep_images)/$nom_offset$conf(extension,defaut)" ] } {
               set offset_list [ list $nom_offset ]
               set nb_offset 1
           } elseif { [ catch { glob -dir $audace(rep_images) ${nom_offset}\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
               renumerote $nom_offset
               set offset_list [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_offset}\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_offset}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
               set nb_offset [ llength $offset_list ]
           } else {
               ::console::affiche_erreur "Le(s) fichier(s) $nom_offset n'existe(nt) pas.\n"
               return ""
           }
       }


       #--- Isole le préfixe des noms de fichiers dans le cas ou ils possedent un "-" avant le n° :
       set pref_stellaire ""
       set pref_dark ""
       set pref_flat ""
       set pref_darkflat ""
       set pref_offset ""
       regexp {(.+)\-?[0-9]+} $nom_stellaire match pref_stellaire
       regexp {(.+)\-?[0-9]+} $nom_dark match pref_dark
       regexp {(.+)\-?[0-9]+} $nom_flat match pref_flat
       regexp {(.+)\-?[0-9]+} $nom_darkflat match pref_darkflat
       regexp {(.+)\-?[0-9]+} $nom_offset match pref_offset
       #-- En attendant de gerer le cas des fichiers avec des - au milieu du nom de fichier : remis le 31082010
       set pref_stellaire $nom_stellaire
       set pref_dark $nom_dark
       set pref_flat $nom_flat
       set pref_darkflat $nom_darkflat
       set pref_offset $nom_offset

       #-- La regexp ne fonctionne pas bien pavec des noms contenant des "_"
       if {$pref_stellaire == ""} {
           set pref_stellaire $nom_stellaire
       }
       if {$pref_dark == ""} {
           set pref_dark $nom_dark
       }
       if {$pref_flat == ""} {
           set pref_flat $nom_flat
       }
       if {$pref_darkflat == ""} {
           set pref_darkflat $nom_darkflat
       }
       if {$pref_offset == ""} {
           set pref_offset $nom_offset
       }
       # ::console::affiche_resultat "Corr : b=$pref_stellaire, d=$pref_dark, f=$pref_flat, df=$pref_darkflat\n"
       ::console::affiche_resultat "brut=$pref_stellaire, dark=$pref_dark, flat=$pref_flat, df=$pref_darkflat, offset=$pref_offset\n"

       #--- Gestion d'un laxisme de libtt qui peut utiliser exptime au lieu exposure :
       spc_correxposure "${pref_stellaire}"
       #--- Prétraitement des flats :
       #-- Somme médiane des dark, dark_flat et offset :
       if { $nb_dark == 1 } {
           ::console::affiche_resultat "L'image de dark est $nom_dark$conf(extension,defaut)\n"
           set pref_dark $nom_dark
           file copy -force "$audace(rep_images)/$nom_dark$conf(extension,defaut)" "$audace(rep_images)/${pref_dark}-smd$nb_dark$conf(extension,defaut)"
       } else {
           ::console::affiche_resultat "Somme médiane de $nb_dark dark(s)...\n"
           smedian "$nom_dark" "${pref_dark}-smd$nb_dark" $nb_dark
       }
       if { $nb_darkflat == 1 } {
           ::console::affiche_resultat "L'image de dark de flat est $nom_darkflat$conf(extension,defaut)\n"
           set pref_darkflat "$nom_darkflat"
           file copy -force "$audace(rep_images)/$nom_darkflat$conf(extension,defaut)" "$audace(rep_images)/${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
       } else {
           ::console::affiche_resultat "Somme médiane de $nb_darkflat dark(s) associé(s) aux flat(s)...\n"
           smedian "$nom_darkflat" "${pref_darkflat}-smd$nb_darkflat" $nb_darkflat
       }
       if { $nom_offset!="none" } {
           if { $nb_offset == 1 } {
               ::console::affiche_resultat "L'image de offset est $nom_offset$conf(extension,defaut)\n"
               set pref_offset $nom_offset
               file copy -force "$audace(rep_images)/$nom_offset$conf(extension,defaut)" "$audace(rep_images)/${pref_offset}-smd$nb_offset$conf(extension,defaut)"
           } else {
               ::console::affiche_resultat "Somme médiane de $nb_offset offset(s)...\n"
               smedian "$nom_offset" "${pref_offset}-smd$nb_offset" $nb_offset
           }
       }

       #-- Soustraction du master_dark aux images de flat :
       if { $nom_offset=="none" } {
           ::console::affiche_resultat "Soustraction des noirs associés aux plus...\n"
           if { $nb_flat == 1 } {
               set pref_flat $nom_flat
               buf$audace(bufNo) load "$audace(rep_images)/$nom_flat"
               buf$audace(bufNo) sub "$audace(rep_images)/${pref_darkflat}-smd$nb_darkflat" 0
               buf$audace(bufNo) save "$audace(rep_images)/${pref_flat}-smd$nb_flat"
           } else {
               sub2 "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_flat}_moinsnoir-" 0 $nb_flat
               set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
               #set flat_traite_1 [ lindex [ glob ${pref_flat}_moinsnoir-*$conf(extension,defaut) ] 0 ]
           }
       } else {
           ::console::affiche_resultat "Optimisation des noirs associés aux plus...\n"
           if { $nb_flat == 1 } {
               set pref_flat $nom_flat
               # buf$audace(bufNo) load "$audace(rep_images)/$nom_flat"
               # buf$audace(bufNo) opt "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset"
               # buf$audace(bufNo) save "$audace(rep_images)/${pref_flat}-smd$nb_flat"
              set fileoutdark [ spc_darkgeneric "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset" ]
              buf$audace(bufNo) load "$audace(rep_images)/$nom_flat"
              buf$audace(bufNo) sub "$fileoutdark" 0
              buf$audace(bufNo) save "$audace(rep_images)/${pref_flat}-smd$nb_flat"
              file delete -force "$audace(rep_images)/$fileoutdark$conf(extension,defaut)"
           } else {
               # opt2 "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset" "${pref_flat}_moinsnoir-" $nb_flat
               # set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
              set fileoutdark [ spc_darkgeneric "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset" ]
              sub2 "$nom_flat" "$fileoutdark" "${pref_flat}_moinsnoir-" 0 $nb_flat
              set flat_moinsnoir_1 [ lindex [ lsort -dictionary [ glob ${pref_flat}_moinsnoir-\[0-9\]*$conf(extension,defaut) ] ] 0 ]
              file delete -force "$audace(rep_images)/$fileoutdark$conf(extension,defaut)"
           }
       }

       #-- Harmonisation des flats et somme médiane :
       if { $nb_flat == 1 } {
           # Calcul du niveau moyen de la première image
           #buf$audace(bufNo) load "${pref_flat}_moinsnoir-1"
           #set intensite_moyenne [lindex [stat] 4]
           ## Mise au même niveau de toutes les images de PLU
           #::console::affiche_resultat "Mise au même niveau de l'image de PLU...\n"
           #ngain $intensite_moyenne
           #buf$audace(bufNo) save "${pref_flat}-smd$nb_flat"
           #file copy ${pref_flat}_moinsnoir-$nb_flat$conf(extension,defaut) ${pref_flat}-smd$nb_flat$conf(extension,defaut)
           ::console::affiche_resultat "Le flat prétraité est ${pref_flat}-smd$nb_flat\n"
       } else {
           # Calcul du niveau moyen de la première image
           buf$audace(bufNo) load "$audace(rep_images)/$flat_moinsnoir_1"
           set intensite_moyenne [ lindex [stat] 4 ]
           # Mise au même niveau de toutes les images de PLU
           ::console::affiche_resultat "Mise au même niveau de toutes les images de PLU...\n"
           ngain2 "${pref_flat}_moinsnoir-" "${pref_flat}_auniveau-" $intensite_moyenne $nb_flat
           ::console::affiche_resultat "Somme médiane des flat prétraités...\n"
           smedian "${pref_flat}_auniveau-" "${pref_flat}-smd$nb_flat" $nb_flat
           #file delete [ file join [ file rootname ${pref_flat}_auniveau-]$conf(extension,defaut) ]
           delete2 "${pref_flat}_auniveau-" $nb_flat
           delete2 "${pref_flat}_moinsnoir-" $nb_flat
       }

       #-- Normalisation et binning des flats pour les spectres sur la bande horizontale (naxis1) d'étude :
       if { $spcaudace(binned_flat) == "o" } {
          if { $flag_nonstellaire==1 } {
             #- Ne pas faire de superflat normalisé ? A tester.
             set hauteur [ expr [ lindex $spc_windowcoords 3 ] - [ lindex $spc_windowcoords 1 ] ]
             set ycenter [ expr round(0.5*$hauteur)+[ lindex $spc_windowcoords 1 ] ]
             set flatnorma [ spc_normaflat "${pref_flat}-smd$nb_flat" $ycenter $hauteur ]
             file rename -force "$audace(rep_images)/$flatnorma$conf(extension,defaut)" "$audace(rep_images)/${pref_flat}-smd$nb_flat$conf(extension,defaut)"
          } else {
             if { $nb_stellaire==1 } {
                set fmean $nom_stellaire
             } else {
                set fmean [ bm_smean $nom_stellaire ]
             }
             set spc_params [ spc_detect $fmean ]
             set ycenter [ lindex $spc_params 0 ]
             set hauteur [ lindex $spc_params 1 ]
             if { $hauteur <= $spcaudace(largeur_binning) } {
                # set fpretraitbis [ bm_pretrait "$nom_stellaire" "${pref_dark}-smd$nb_dark" "$nom_flat" "${pref_darkflat}-smd$nb_darkflat" ]
                # set fsmean [ bm_smean "$fpretraitbis" ]
                # set hauteur [ lindex [ spc_detect "$fsmean" ] 1 ]
                # delete2 "fpretraitbis" $nb_stellaire
                # file delete -force "$audace(rep_images)/$fsmean$conf(extension,defaut)"
                #-- Met a 21 pixels la hauteur de binning du flat :
                set hauteur [ expr 3*$spcaudace(largeur_binning) ]
             }
             if { $nb_stellaire!=1 } {
                file delete -force "$audace(rep_images)/$fmean$conf(extension,defaut)"
             }
             set flatnorma [ spc_normaflat "${pref_flat}-smd$nb_flat" $ycenter $hauteur ]
             file rename -force "$audace(rep_images)/$flatnorma$conf(extension,defaut)" "$audace(rep_images)/${pref_flat}-smd$nb_flat$conf(extension,defaut)"
          }
       } elseif { $spcaudace(binned_flat) == "n" } {
          buf$audace(bufNo) load "$audace(rep_images)/${pref_flat}-smd$nb_flat"
          # set intensite_moy [ lindex [ buf$audace(bufNo) stat ] 4 ]
          # buf$audace(bufNo) mult [ expr 1./$intensite_moy ]
          #-- 20170709 :
          set intensite_max [ lindex [ buf$audace(bufNo) stat ] 2 ]
          buf$audace(bufNo) mult [ expr 1./$intensite_max ]
          #-- Special spectres echelle :
          buf$audace(bufNo) offset 1
          #-- Fin spectres echelle
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/${pref_flat}-smd$nb_flat"
          buf$audace(bufNo) bitpix short
       }

       #--- Prétraitement des images stellaires :
       #-- Soustraction du noir des images stellaires :
       ::console::affiche_resultat "Soustraction du noir des images stellaires...\n"
       if { $nom_offset=="none" } {
           ::console::affiche_resultat "Soustraction des noirs associés aux images stellaires...\n"
           if { $nb_stellaire==1 } {
               # set pref_stellaire "$nom_stellaire"
               buf$audace(bufNo) load "$audace(rep_images)/[ lindex $stellaire_liste 0 ]"
               buf$audace(bufNo) sub "$audace(rep_images)/${pref_dark}-smd$nb_dark" 0
               buf$audace(bufNo) save "$audace(rep_images)/${pref_stellaire}_moinsnoir"
           } else {
               sub2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire
               # sub2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire "COSMIC_THRESHOLD=300"
               # Lent :
               # ttscript2 "IMA/SERIES \"$::audace(rep_images)\" \"$nom_stellaire\" 1 $nb_stellaire \"$::conf(extension,defaut)\" \"$::audace(rep_images)\" \"${pref_stellaire}_moinsnoir-\" 1 \"$::conf(extension,defaut)\" SUB \"file=$::audace(rep_images)/${pref_dark}-smd$nb_dark\" offset=0 \"COSMIC_THRESHOLD=300\" "
           }
       } else {
           ::console::affiche_resultat "Optimisation des noirs associés aux images stellaires...\n"
           if { $nb_stellaire==1 } {
               ## set pref_stellaire "$nom_stellaire"
               # buf$audace(bufNo) load "$audace(rep_images)/[ lindex $stellaire_liste 0 ]"
               # buf$audace(bufNo) opt "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset"
               # buf$audace(bufNo) save "$audace(rep_images)/${pref_stellaire}_moinsnoir"
              set nom_stellaire_file [ lindex $stellaire_liste 0 ]
              set fileoutdark [ spc_darkgeneric "$nom_stellaire_file" "${pref_darkflat}-smd$nb_darkflat" "${pref_offset}-smd$nb_offset" ]
              buf$audace(bufNo) load "$audace(rep_images)/$nom_stellaire_file"
              buf$audace(bufNo) sub "$fileoutdark" 0
              buf$audace(bufNo) save "$audace(rep_images)/${pref_stellaire}_moinsnoir"           
              file delete -force "$audace(rep_images)/$fileoutdark$conf(extension,defaut)"
           } else {
               # opt2 "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset" "${pref_stellaire}_moinsnoir-" $nb_stellaire
              set fileoutdark [ spc_darkgeneric "$nom_stellaire" "${pref_dark}-smd$nb_dark" "${pref_offset}-smd$nb_offset" ]
              sub2 "$nom_stellaire" "$fileoutdark" "${pref_stellaire}_moinsnoir-" 0 $nb_stellaire           
              file delete -force "$audace(rep_images)/$fileoutdark$conf(extension,defaut)"
           }
       }

       #-- Calcul du niveau moyen de la PLU traitée :
       buf$audace(bufNo) load "${pref_flat}-smd$nb_flat"
       set intensite_moyenne [ lindex [stat] 4 ]

       #-- Division des images stellaires par la PLU :
       ::console::affiche_resultat "Division des images stellaires par la PLU normalisée...\n"
      if { $nb_stellaire==1 } {
         # set pref_stellaire "$nom_stellaire"
         buf$audace(bufNo) load "$audace(rep_images)/${pref_stellaire}_moinsnoir"
         buf$audace(bufNo) div "$audace(rep_images)/${pref_flat}-smd$nb_flat" 1
         buf$audace(bufNo) setkwd [ list "EXPOSURE" $spcaudace(exposure) float "Image exposure time" "second" ]
         buf$audace(bufNo) save "$audace(rep_images)/${pref_stellaire}-t-1"
         set image_traite_1 "${pref_stellaire}-t-1"
      } else {
         div2 "${pref_stellaire}_moinsnoir-" "${pref_flat}-smd$nb_flat" "${pref_stellaire}-t-" $intensite_moyenne $nb_stellaire
         #- Compensation d'un bug de libtt qui met EXPOSURE a 0 :
         set liste_traites [ lsort -dictionary [ glob ${pref_stellaire}-t-\[0-9\]*$conf(extension,defaut) ] ]
         foreach fichier $liste_traites {
            buf$audace(bufNo) load "$audace(rep_images)/$fichier"
            buf$audace(bufNo) setkwd [ list "EXPOSURE" $spcaudace(exposure) float "Image exposure time" "second" ]
            buf$audace(bufNo) save "$audace(rep_images)/$fichier"
         }
         set image_traite_1 [ lindex $liste_traites 0 ]
      }

       #--- Compensation d'un bug de libtt qui met EXPOSURE a 0 :
       #spc_correxposure "${pref_stellaire}" "${pref_stellaire}-t-"


       #--- Affichage et netoyage :
       loadima "$image_traite_1"
       ::console::affiche_resultat "Affichage de la première image prétraitée\n"
      if { $nb_stellaire==1 } {
         file delete -force "$audace(rep_images)/${pref_stellaire}_moinsnoir$conf(extension,defaut)"
      } else {
         delete2 "${pref_stellaire}_moinsnoir-" $nb_stellaire
      }
       # if { $flag_rmmaster == "o" } {
           #-- Le 06/02/19 :
           # file delete -force "${pref_dark}-smd$nb_dark$conf(extension,defaut)"
           # file delete -force "${pref_flat}-smd$nb_flat$conf(extension,defaut)"
           file rename -force "$audace(rep_images)/${pref_flat}-smd$nb_flat$conf(extension,defaut)" "$audace(rep_images)/${pref_flat}-obtained-smd$nb_flat$conf(extension,defaut)"
           # file delete -force "${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
       # }

       #-- Effacement des fichiers copie des masters dark, flat et dflat dus a la copie automatique de pretrait :
       if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_dark}-smd$nb_dark match resul ] } {
           file delete -force "${pref_dark}-smd$nb_dark$conf(extension,defaut)"
       }
       if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_flat}-smd$nb_flat match resul ] } {
           file delete -force "${pref_flat}-smd$nb_flat$conf(extension,defaut)"
       }
       if { [ regexp {.+-smd[0-9]+-smd[0-9]+} ${pref_darkflat}-smd$nb_darkflat match resul ] } {
           file delete -force "${pref_darkflat}-smd$nb_darkflat$conf(extension,defaut)"
       }


      #--- Somme simple des spectrs pretraites :
      set fileout [ spc_somme "${pref_stellaire}-t-" addi ]
      delete2 "${pref_stellaire}-t-" [ llength [ glob -dir $audace(rep_images) -tails ${pref_stellaire}-t-*$conf(extension,defaut) ] ]

      #--- Retour dans le répertoire de départ avant le script
      #return ${pref_stellaire}-t-
      return "$fileout"
   } else {
       ::console::affiche_erreur "Usage: spc_pretraitech nom_generique_images_objet (sans extension fit) nom_dark nom_plu nom_dark_plu ?nom_offset (none)? ?effacement des masters (o/n)? ?liste_coordonnées_fenêtre_étude?\n\n"
   }
}
#****************************************************************************#

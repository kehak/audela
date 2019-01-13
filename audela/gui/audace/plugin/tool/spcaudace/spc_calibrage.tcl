
# source $audace(rep_scripts)/spcaudace/spc_calibrage.tcl
# spc_fits2dat lmachholz_centre.fit
# buf1 load lmachholz_centre.fit

# Mise a jour $Id: spc_calibrage.tcl 14525 2018-11-09 18:22:10Z bmauclaire $

####################################################################
# Verifie la calibration sur dle spectre d'une etoile ayant les raies de Balmer
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2015-10-27
# Date modification : 2015-10-27
# Arguments : nom_profil_calibre_etoile_balmer
####################################################################

proc spc_rmsbalmer { args } {
   global audace conf spcaudace
   set raies_balmer [ list 3889.064 3970.075 4101.748 4340.475 4861.342 6562.819 ]
   #-- +-5 A
   #set intervalle_balmer 5
   set intervalle_balmer 3

   #--- Gestion des arguments :
   set nbargs [ llength $args ] 
   if { $nbargs==1 } {
      set spectre [ file rootname [ lindex $args 0 ] ]
      set intervalle_balmer 5
   } elseif { $nbargs==2 } {
      set spectre [ file rootname [ lindex $args 0 ] ]
      set intervalle_balmer [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_rmsbalmer nom_profil_etoile_calibree ?intervalle_balmer(5 A)?\n"
      return ""
   }

   #--- Linearise la calibration :
   set spectre_linear [ spc_linearcal "$spectre" ]

   #--- Lecture de la dispersion :
   buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
      set cdelt1 [ format "%2.4f" [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ] ]
   }

   #--- Mesure du centroide des raies de Balmer et calcul des residus :
   set rms 0
   set lambda_mesurees [ list ]
   set residus_mesures [ list ]
   foreach raie $raies_balmer {
      set ldeb [ expr $raie-$intervalle_balmer ]
      set lfin [ expr $raie+$intervalle_balmer ]
      set lcentre [ spc_centergaussl "$spectre_linear" $ldeb $lfin a ]
      lappend lambda_mesurees $lcentre
      set residu [ expr $raie-$lcentre ]
      lappend residus_mesures $residu
      set rms [ expr $rms+$residu*$residu ]
   }
   set nblines [ llength $raies_balmer ]
   set rms [ format "%2.4f" [ expr sqrt($rms/$nblines) ] ]
   file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"

   #-- Affichage des resultats :
   ::console::affiche_resultat "\nLambda (A) : Résidu (A)\n"
   foreach raie $raies_balmer residu $residus_mesures {
      ::console::affiche_resultat "$raie : $residu\n"
   }
   ::console::affiche_resultat "RMS des résidus : $rms A\n"
   ::console::affiche_resultat "Disperion : $cdelt1 A/pix\n"
}
#**************************************************************#



####################################################################
# Calibration automatique à partir d'un fichier lambdas, position_moyennes
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2016-02-24
# Date modification : 2016-02-24
# Algo :
# Recherche des raies par fitting gaussien large autour de la position moyenne donnee par le fichier.
# Approprié plustot à la haute résolution.
#
# Arguments : nom_profil_lampe_redressee fichier_texte_xmoy_lambda
####################################################################

proc spc_calibrefile { args } {
   global audace conf spcaudace

   #--- Parametres de recherche en pixels : 30
   #set intervalle_lampe $spcaudace(largeur_recherche_raie)

   #--- Gestion des arguments :
   set nbargs [ llength $args ] 
   if { $nbargs==2 } {
      set fichier_lampe [ file rootname [ lindex $args 0 ] ]
      set fichier_raies [ lindex $args 1 ]
      set largeur_recherche $spcaudace(largeur_recherche_raie)
   } elseif { $nbargs==3 } {
      set fichier_lampe [ file rootname [ lindex $args 0 ] ]
      set fichier_raies [ lindex $args 1 ]
      set largeur_recherche [ lindex $args 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_calibrefile nom_profil_lampe_calibration fichier_texte_xmoy_lambda ?largeur_recherche?\n"
      return ""
   }

   #--- Création de la liste de raies à partir du fichier :
   if { [ file exist "$audace(rep_images)/$fichier_raies" ] } {
      ::console::affiche_prompt "Raies cherchées à partir du fichier : $fichier_raies\n"
      #-- Lecture du fichier de donnees du profil de raie :
      set file_id [ open "$audace(rep_images)/$fichier_raies" r ]
      fconfigure $file_id -translation crlf
      set contents [ split [ read $file_id ] \n ]
      close $file_id

      #-- Creation de la liste des couples {position lambda} :
      set liste_raies [ list ]
      foreach ligne $contents {
         if { $ligne=="" } {
            break
         } else {
            set position [ lindex $ligne 0 ]
            if { $position!="" } {
               set lambda [ lindex $ligne 1 ]
               lappend liste_raies [ list $position $lambda ]
            }
         }
      }
      ::console::affiche_resultat "Liste couples lus : $liste_raies\n"
   } else {
      ::console::affiche_erreur "Le fichier de $fichier_raies n'exsiste pas dans le répertoire de travail. Veuillez le créer.\n"
      return ""
   }


   #--- Recherche du centre de toutes les autres raies de liste :
   set chaine_couples ""
   foreach raie $liste_raies {
      set position_approx [ lindex $raie 0 ]
      set lambda [ lindex $raie 1 ]
      set xdeb [ expr round($position_approx-$largeur_recherche) ]
      set xfin [ expr round($position_approx+$largeur_recherche) ]
      set position_mes [ spc_centergauss "$fichier_lampe" $xdeb $xfin e ]
      append chaine_couples "$position_mes $lambda "
   }
   # ::console::affiche_prompt "Liste des couples=$chaine_couples\n"


   #--- Calibration finale à l'aide de toutes les raies bien mesurées :
   #set lampe_calibree [ spc_calibren "$lampe_relco" $chaine_couples ]
   set chaine_commande "spc_calibren $fichier_lampe $chaine_couples"
   set lampe_calibree [ eval [ format $chaine_commande ] ]

   #--- Fin de script :
   return $lampe_calibree
}
#***********************************************************************


####################################################################
# Calibration automatique de la lampe Relco Ne-Ar basse résolution
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2015-10-26
# Date modification : 2015-11-03, 2016-02-19
# Algo :
#  1. Recherche la raie la plus brillante (traditionnellement 7509, deux fois plus intense que 5852),
#  puis la plus au centre (5852).
#  2.a. Si la raie la plus brillante détectée est proche du centre, c'est 5852, donc la 2ieme plus
#  brillante est 6965. 7509 absente.
#  2.b. Si la raie la plus brillante est avant .92*naxis1, c'est 6965, donc la 2ieme plus
#  brillante est 5852 (cas Aply+Atik414). 7509 absente.
#  3. Réalise ensuite une calibration intermédiaire de degré 1 pour rechercher la raie 4197 et
#  recalcule une loi de degré 2.
#  4. Recherche toutes les autres raies et calcule une loi de calibration finalisée de degré 4.
#
# Arguments : nom_profil_lampe_relco_redressee
####################################################################

proc spc_calibrerelco { args } {
   global audace conf spcaudace

   #--- Parametres de recherche :
   set epaisseur_raie 10
   #set intervalle_5852 300.0
   set intervalle_5852 $spcaudace(largeur_lcentrale) ; #- 0.21
   set intervalle_4197 50.0
   #-- 7509 se trouve au dela de 0.92*naxis1 :
   set pourcent_lim_7509 0.92
   #-- v1=20 v2=10 v3=5.0
   set intervalle_relco $spcaudace(largeur_relco)
   #-- Nom par defaut du fichier de raies Relco personnalisable par l'utisateur :
   set name_relco_file "relco_lines.txt"
   #-- 6 efficienxy lines :
   #set raies_relco6 { 4197.246 4510.733 5187.746 5852.488 6965.431 7509.261 }
   #- 4545.052 mieux detectee changee en 4510 bien que moins brillante : abandonné
   #set raies_relco6 { 4197.246 4545.052 5187.746 5852.488 6965.431 7509.261 }
   set raies_relco6 { 4197.246 4428.095 5187.746 5852.488 6965.431 7509.261 }
   #-- 8 lines :
   #set raies_relco8 { 4197.246 4510.733 4764.865 5187.746 5852.488 6409.277 6965.431 7509.261 }
   #set raies_relco8 { 4197.246 4545.052 4764.865 5187.746 5852.488 6409.277 6965.431 7509.261 }
   set raies_relco8 { 4197.246 4428.095 4764.865 5187.746 5852.488 6409.277 6965.431 7509.261 }
   #-- PL selection :
   set raies_relco12 { 4158.59 4510.733 4657.90 4764.86 5400.56 5852.49 6266.49 6506.53 6717.04 7067.22 7272.94 7383.98 }

   #--- Gestion des arguments :
   set nbargs [ llength $args ] 
   if { $nbargs==1 } {
      set lampe_relco [ file rootname [ lindex $args 0 ] ]
      set nblines $spcaudace(nblines_relco)
   } elseif { $nbargs==2 } {
      set lampe_relco [ file rootname [ lindex $args 0 ] ]
      set nblines [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_calibrerelco nom_profil_lampe_relco_redressee ?nb_raies_liste(6/8/\[12\]/f)?\n f : utilise un fichier texte monocolonne de raies mémorisé dans le répertoire de travail sous relco_lines.txt\n"
      return ""
   }

   #--- Gestion de la liste de raies :
   switch $nblines {
      6 { set raies_relco $raies_relco6 }
      8 { set raies_relco $raies_relco8 }
      12 { set raies_relco $raies_relco12 }
      f {
         if { [ file exist "$audace(rep_images)/$name_relco_file" ] } {
            set file_id [ open "$audace(rep_images)/$name_relco_file" r ]
            fconfigure $file_id -translation crlf
            set contents [ split [ read $file_id ] \n ]
            #set raies_relco [ list ]
            foreach ligne $contents {
               if { $ligne=="" } {
                  break
               } else {
                  #lappend raies_relco $ligne
                  append raies_relco "$ligne "
               }
            }
            close $file_id
            ::console::affiche_prompt "Raies Relco du fichier : $raies_relco\n"
         } else {
            ::console::affiche_erreur "Le fichier de $name_relco_file n'exsiste pas dans le répertoire de travail. Veuillez le créer.\n"
            return ""
         }
      }
      default {
         ::console::affiche_erreur "Les listes disponibles contiennent 6, 8, ou 12 raies.\n"
         return ""
      }
   }

   #--- Recherche de 7509, la plus brillante :
   set x_7509 [ lindex [ lindex [ spc_findbiglines "$lampe_relco" e $epaisseur_raie ] 0 ] 0 ]
   ::console::affiche_prompt "x_7509=$x_7509\n"

   #--- Gerer le cas ou 7509 est absente :
   #if { $x_7509<$xlim7509 }
   #- Voir cas $x_7509<=$xlim7509 && $x_7509>$xfin && 1==1 ; avec un flag

   #--- Recherche de 5852, la plus au centre :
   buf$audace(bufNo) load "$audace(rep_images)/$lampe_relco"
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "NAXIS1" ] !=-1 } {
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
   }
   set xdeb [ expr round($naxis1/2.0-$intervalle_5852*$naxis1) ]
   set xfin [ expr round($naxis1/2.0+$intervalle_5852*$naxis1) ]
   set xlim7509 [ expr $pourcent_lim_7509*$naxis1 ]

   #--- Raisonnement sur les raies brillantes, notamment la présence ou non de 7509 :
   if { $x_7509<$xlim7509 && 1==0 } {
      set flag_no7509 1
      #-- Gere le cas ou 7509 est absente et :
      ::console::affiche_erreur "La raie 7509 A n'est pas présente sur le spectre. C'est 6965 qui domine.\n"
      set x_6965 $x_7509
      ::console::affiche_prompt "x_6965=$x_6965\n"
      set x_5852 [ spc_centergauss "$lampe_relco" $xdeb $xfin e ]
      ::console::affiche_prompt "x_5852=$x_5852\n"
      #-- Précalibation à 2 raies :
      set lampe_precal1 [ spc_calibren "$lampe_relco" $x_5852 5852.488 $x_6965 6965.431 ]
      
   } elseif { $x_7509>$xdeb && $x_7509<$xfin } {
      set flag_no7509 1
      #-- Cas ou la raie la plus brillante mesurée et présente est 5852 :
      ::console::affiche_erreur "La raie 7509 A n'est pas présente sur le spectre. Veuillez modifier le réglage de votre spectroscope.\n La calibration sera probablement moins précise.\n"
      #return ""
      #- La raie 7509 mesuree est en fait 5852, qui est alors la plus brillante :
      set x_5852 $x_7509

      ::console::affiche_prompt "x_5852=$x_5852\n"
      #-- La seconde raie la plus brilllante dans ce cas est 6965.431 :
      set x_6965 [ lindex [ lindex [ spc_findbiglines "$lampe_relco" e $epaisseur_raie ] 1 ] 0 ]
      ::console::affiche_prompt "x_6965=$x_6965\n"
      #-- Précalibation à 2 raies :
      set lampe_precal1 [ spc_calibren "$lampe_relco" $x_5852 5852.488 $x_6965 6965.431 ]
      
   } elseif { $x_7509<=$xlim7509 && $x_7509>$xfin && "$spcaudace(relco_noline7509)"=="o" } {
      set flag_no7509 1
      #-- Cas d'une lampe Relco viellie, car montée à l'envers
      #-- RENFORCER DETECTION DU CAS, CAR LA CALCIB DES LAMPES DE TEST DE DEPART EST MAUVAISE
      #- Anomalie de lampe : 6965 est plus intense que 5852 et 7509 absente
      #- Penser a d'aborder chercher la position de la raie "centre" 5852, puis gerer les cas des brillantes a droite.
      ::console::affiche_erreur "La raie 7509 A n'est pas présente sur le spectre. C'est 6965 qui domine.\n"
      set x_6965 $x_7509
      ::console::affiche_prompt "x_6965=$x_6965\n"
      set x_5852 [ spc_centergauss "$lampe_relco" $xdeb $xfin e ]
      ::console::affiche_prompt "x_5852=$x_5852\n"
      #-- Précalibation à 2 raies :
      set lampe_precal1 [ spc_calibren "$lampe_relco" $x_5852 5852.488 $x_6965 6965.431 ]
      
   } elseif { $x_7509<$xdeb } {
      ::console::affiche_erreur "Des raies dans le bleu sont anormalement intenses.\n"
      return ""
      
   } else {
      set flag_no7509 0
      #-- La raie 7509 est présente :
      ::console::affiche_prompt "La raie 7509 est présente\n"
      set x_5852 [ spc_centergauss "$lampe_relco" $xdeb $xfin e ]
      ::console::affiche_prompt "x_5852=$x_5852\n"
      #-- Précalibation à 2 raies :
      set lampe_precal1 [ spc_calibren "$lampe_relco" $x_5852 5852.488 $x_7509 7509.261 ]
   }


   #--- Recherche de 4197 :
   buf$audace(bufNo) load "$audace(rep_images)/$lampe_precal1"
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
   }
   if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
   }
   set x_4197 [ expr (4197.246-$crval1)/$cdelt1+1 ]
   set xdeb [ expr round($x_4197-$intervalle_4197) ]
   set xfin [ expr round($x_4197+$intervalle_4197) ]
   set x_4197 [ spc_centergauss "$lampe_relco" $xdeb $xfin e ]
   ::console::affiche_prompt "x_4197=$x_4197\n"
   # file copy -force "$audace(rep_images)/$lampe_precal1$conf(extension,defaut)" "$audace(rep_images)/precal1$conf(extension,defaut)"
   file delete -force "$audace(rep_images)/$lampe_precal1$conf(extension,defaut)"

   #--- Recalibrage à 3 raies bien réparties :
   if { $flag_no7509==0 } {
      set lampe_precal2 [ spc_calibren "$lampe_relco" $x_4197 4197.246 $x_5852 5852.488 $x_7509 7509.261 ]
   } elseif { $flag_no7509==1 } {
      set lampe_precal2 [ spc_calibren "$lampe_relco" $x_4197 4197.246 $x_5852 5852.488 $x_6965 6965.431 ]
   }


   #--- Recherche du centre de toutes les autres raies de liste Relco8 :
   #-- Mots clef de la calibration :
   buf$audace(bufNo) load "$audace(rep_images)/$lampe_precal2"
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
      set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
      set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
      set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
   }
   if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
      set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
   }

   #-- Pour chaque raie de la liste :
   set chaine_couples ""
   #::console::affiche_prompt "delta=$delta ; $spc_a ; $spc_b; $spc_c\n"
   foreach raie $raies_relco {
      # ::console::affiche_prompt "RAIE : $raie\n"
      if { $raie==4197.246 } {
         set position_mes $x_4197
         ::console::affiche_resultat "Le centre de la raie est : $position_mes (pixels)\n"
      } elseif { $raie==5852.488 } {
         set position_mes $x_5852
         ::console::affiche_resultat "Le centre de la raie est : $position_mes (pixels)\n"
      } elseif { $raie==6965.431 && $flag_no7509==1 } {
         set position_mes $x_6965
         ::console::affiche_resultat "Le centre de la raie est : $position_mes (pixels)\n"
      } elseif { $raie==7509.261 } {
         if { $flag_no7509==0 } {
            set position_mes $x_7509
            ::console::affiche_resultat "Le centre de la raie est : $position_mes (pixels)\n"
         } elseif { $flag_no7509==1 } {
            continue
         }
      } else {
         set delta [ expr $spc_b*$spc_b-4*$spc_c*($spc_a-$raie) ]
         # ::console::affiche_prompt "delta=$delta\n"
         if { $delta>0 } {
            set position_approx [ expr (-1.0*$spc_b+sqrt($delta))/(2*$spc_c) ]
         } elseif { $delta==0 } {
            set position_approx [ expr -1.0*$spc_b/(2*$spc_c) ]
         } else {
            ::console::affiche_erreur "Pas de solution à la loi de calibration. Fin de calibration.\n"
            return ""
         }
         # ::console::affiche_prompt "x_approx=$position_approx\n"
         set xdeb [ expr round($position_approx-$intervalle_relco) ]
         set xfin [ expr round($position_approx+$intervalle_relco) ]
         set position_mes [ spc_centergauss "$lampe_relco" $xdeb $xfin e ]
      }
      append chaine_couples "$position_mes $raie "
   }
   ::console::affiche_prompt "Liste des couples=$chaine_couples\n"
   #file copy -force "$audace(rep_images)/$lampe_precal1$conf(extension,defaut)" "$audace(rep_images)/precal2$conf(extension,defaut)"
   file delete -force "$audace(rep_images)/$lampe_precal2$conf(extension,defaut)"


   #--- Calibration finale à l'aide de toutes les raies bien mesurées :
   #set lampe_calibree [ spc_calibren "$lampe_relco" $chaine_couples ]
   set chaine_commande "spc_calibren $lampe_relco $chaine_couples"
   set lampe_calibree [ eval [ format $chaine_commande ] ]

   #--- Fin de script :
   return $lampe_calibree
}
#***********************************************************************



####################################################################
# Cree un profil de calibration a partir d'un spectre brut d'etoile chaude (raies de Balmer) :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2014-11-30
# Date modification : 2014-11-30
# Argument : nom d'un spectre brute 2D
#
####################################################################

proc spc_brcreacal { args } {
   global audace conf

   if { [ llength $args ]==1 } {
      set spectre2D [ file rootname [ lindex $args 0 ] ]

      #--- Cree le profil de raie :
      set spec_profil_1a [ spc_profil "$spectre2D" med large rober ]

      #--- Calibration le longueur d'onde avec GUI :
      spc_loadneon balmer 2
      set spec_profil_1b [ spc_calibre "$spec_profil_1a" a ]
      ::confVisu::close 2

      #--- Fin du scirpt :
      set spec_calibration "calibration_$spectre2D"
      file delete -force "$audace(rep_images)/$spec_profil_1a$conf(extension,defaut)"
      file rename -force "$audace(rep_images)/$spec_profil_1b$conf(extension,defaut)" "$audace(rep_images)/$spec_calibration$conf(extension,defaut)"
      spc_load "$spec_calibration"
      return $spec_calibration
   } else {
      ::console::affiche_erreur "Usage: spc_brcreacal spectre_2D_brut_etoile_chaude\n"
   }
}
#******************************************************************#


###################################################################
# Procedure de test de calibration BR d'un spectre cible via le spectre calibre mesure d'une etoile de reference et les neons des 2 astres
#
# Auteur : Patrick LAILLY
# Date creation : 14-09-12
# Date modification : 14-09-12
# Arguments : profil-1a cible, profil calibre (approx) neon cible, profil mesure calibre etoile reference, profil calibre (approx) neon etoile de reference
# exemple : spc_exportcalibbr prof1acible profneoncible prof1bref profneonref
####################################################################

proc spc_exportcalibbr { args } {
   global audace conf
   if { [ llength $args ] == 4 } {
      set prof1acible [ lindex $args 0 ]
      set neoncible [ lindex $args 1 ]
      set neonref [ lindex $args 3]
      set prof1bref [ lindex $args 2 ]
      if { [ spc_testlincalib $neoncible ] != 1 } {
	 set neoncible [ spc_linearcal $neoncible ]
      }
      set profil1acible [ file rootname $prof1acible ]
      buf$audace(bufNo) load "$audace(rep_images)/$neoncible"
      set crvalneonc [ lindex [ buf$audace(bufNo) getkwd CRVAL1 ] 1 ]
      set cdeltneonc [ lindex [ buf$audace(bufNo) getkwd CDELT1 ] 1 ]
      set naxisneonc [ lindex [ buf$audace(bufNo) getkwd NAXIS1 ] 1 ]
      if { [ spc_testlincalib $neonref ] != 1 } {
	 set neonref [ spc_linearcal $neonref ]
      }
      buf$audace(bufNo) load "$audace(rep_images)/$neonref"
      set crvalneonr [ lindex [ buf$audace(bufNo) getkwd CRVAL1 ] 1 ]
      set cdeltneonr [ lindex [ buf$audace(bufNo) getkwd CDELT1 ] 1 ]
      # analyse des lois de calibration neon
      set dcdelt [ expr abs ($cdeltneonc - $cdeltneonr) ]
      set incertit [ expr $dcdelt * $naxisneonc ]
      ::console::affiche_prompt "WARNING : la procedure spc_exportcalibbr suppose que la calibration des 2 profils neon a aboutit a la meme dispersion ce qui ne semble pas etre le cas. La difference de dispersion conduit a des intervalles de longueurs d'ondes de longueurs differentes en l'occurence de $incertit Angstroems  \n"
      # calcul du numero d'echantillon de le raie a 585 nm. sur chacun des deux profils du neon
      set nech585r [ expr ( 5852.48 - $crvalneonr ) / $cdeltneonr ]
      set nech585c [ expr ( 5852.48 - $crvalneonc ) / $cdeltneonc ]
      set decalech [ expr $nech585r - $nech585c ]
      set decallambda [ expr $decalech * $cdeltneonr ]
      ::console::affiche_resultat "les profils neon $neoncible et $neonref apparaissent decales de $decalech echantillons soit $decallambda Angstroems suivant la loi de dispersion du neon de l'etoile de reference \n"

      #calibration de spectre de la cible suivant la loi de dispersion du neon de l'etoile de reference
      set suff _exportbr
      set newfile [ spc_calibreloifile $prof1bref $prof1acible ]
      #prise en compte du decalage des neons
      set newfile [ spc_calibredecal $newfile $decallambda ]
      file rename -force "$audace(rep_images)/$newfile$conf(extension,defaut)" "$audace(rep_images)/$prof1acible$suff$conf(extension,defaut)"
      ::console::affiche_resultat " le profil $prof1acible a ete calibre et sauvegarde sous $prof1acible$suff \n"
      return "$prof1acible$suff"
   } else {
      ::console::affiche_erreur "Usage: spc_exporttcalibbr spectre_1a_cible spectre_neon_cible spectre_1b_etoile_reference spctre_neon_etoile_reference\n\n"
   }
}
#********************************************************************


###################################################################
# Procedure de test de calibration lineaire d'un profil fits
#
# Auteur : Patrick LAILLY
# Date creation : 25-11-09
# Date modification : 25-11-09
# Argument : nom fichier fits
# exemple : spc_testlincalib nom_fich
####################################################################

proc spc_testlincalib { args } {
   global audace conf
   if { [ llength $args ] == 1 } {
      set nom_fich [ lindex $args 0 ]
      buf$audace(bufNo) load "$audace(rep_images)/$nom_fich"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	 return -1
      } else {
	 return 1
      }
   } else {
      ::console::affiche_erreur "Usage: spc_testlincalib nom_fich_fits\n\n"
   }
}
#********************************************************************

####################################################################
# Procedure de calcul d'une réponse instrumentale intrinseque c'est a dire en eliminant l'effet de la transmission
# atmospherique
#
# Auteur : Patrick LAILLY
# Date creation : 2009-10-10
# Date modification : 2011-04-24 ; 2018-05-22
# Arguments : fichier .fit du profil 1b mesure (calibré linéairement), type spectral (doit etre dans bibliotheque
# spectrale)  correspondant ? liste donnant les parametres requis pour le calcul de la transmission atmospherique ?
# Cette liste comprend : altitude observatoire (en km), hauteur (en °) de l'astre, le temps
# qu'il fait a choiisr entre sec ou normal ou lourd ou orageux ou valeur numerique qui sera
# la valeur de AOD specifiee par l'utilisateur, en option : desert ?
# Sortie : la procedure cree le fichier ri_intris avec le meme echantillonage que le profil mesure.
# Exemples d'utilisation : spc_calriintrins altair.fit a7v liste_atmosph
# Exemple de liste_atmosph { 0.8 45.0 lourd }
# Exemple de liste_atmosph { 3842. 45.0 normal desert }
# Exemple de liste_atmosph { 0.8 45.0 0.15 }
####################################################################

proc spc_calriintrins { args } {
   global audace spcaudace
   #set spcaudace(imax_tolerence) 1.2
   if { [ llength $args ] == 3 } {
      set fich_profile [ lindex $args 0 ]
      set type_spectral [ lindex $args 1 ]
      
      set suff .fit
      set fich_profile_ref "$spcaudace(rep_spcbib)/$type_spectral$suff"
      set liste_atmosph [ lindex $args 2 ]
      if { [ llength $liste_atmosph ] > 4 } {
	 ::console::affiche_erreur "Usage : spc_calriintrins la liste $liste_atmosph decrivant les parametres pour la correction atmospherique est trop longue \n\n"
	 return 0
      } else {
	 set altitude [ lindex $liste_atmosph 0 ]
	 set haut [ lindex $liste_atmosph 1 ]
	 set weather [ lindex $liste_atmosph 2 ]
	 if { [ llength $liste_atmosph ] ==4 } {
	    set location [ lindex $liste_atmosph 3 ]
	 }
	 if { [ spc_testlincalib  $fich_profile ] == -1 } {
	    ::console::affiche_resultat "le profil entre n'est pas calibre lineairement => on linearise la loi de calibration \n"
	    set fich_profile [ spc_linearcal $fich_profile ]
	 }
	 #set profile [ spc_fits2data $fich_profile ]
	 buf$audace(bufNo) load "$audace(rep_images)/$fich_profile"
	 #--- Renseigne sur les parametres de l'image :
	 set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	 set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	 set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	 set caract_lambda [ list ]
	 ::console::affiche_resultat "caractéristiques profil mesure $fich_profile cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
	 lappend caract_lambda $naxis1
	 lappend caract_lambda $crval1
	 lappend caract_lambda $cdelt1
	 #::console::affiche_resultat "caractéristiques profil mesure $fich_profile cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
	 set ecart_lambda [ expr ($naxis1 -1) * $cdelt1 ]
	 #--- test si plage longueurs d'ondes assez large
	 if { $ecart_lambda < 500. } {
	    ::console::affiche_resultat "spc_calriintrins : avertissement : la plage de longueurs d'ondes explorees ($ecart_lambda) est petite : le calcul peut etre non significatif mais sera quand meme effectue \n"
	 }

	 #--- calcul de la transmission atmospherique
	 if { [ llength $liste_atmosph ] ==4 } {
	    set transm_atmosph [ spc_atmosph $haut $altitude $caract_lambda $weather $location ]
	 } else {
	    set transm_atmosph [ spc_atmosph $haut $altitude $caract_lambda $weather ]
	 }
	 #--- division profil mesure par transmission atmospherique
	 set fich_profile_corr_transm [ spc_divri $fich_profile $transm_atmosph ]

	 #--- calcul de la reponse instrumentale intrinseque
	 file copy -force $fich_profile_ref "$audace(rep_images)/$type_spectral$suff"
	 # sauvegarde d'une eventuelle reponse instrumentale calculee anterieurement
	 set repinstr reponse_instrumentale-br.fit
	 set repinstrprev reponse_prev.fit
	 #set prev -prev
	 #set br -br
	 if { [ file exists "$audace(rep_images)/$repinstr" ]==1 } {
	    #::console::affiche_resultat "spc_calriintrins : $audace(rep_images)/$repinstr$br$suff \n"
	    file copy -force "$audace(rep_images)/$repinstr" "$audace(rep_images)/$repinstrprev"
	    ::console::affiche_resultat "spc_calriintrins : sauvegarde provisoire du fichier $audace(rep_images)/$repinstrprev\n"
	 }
	 set output_rinstrum [ spc_rinstrum $fich_profile_corr_transm "$type_spectral$suff" ]
	 #sauvegarde de la reponse instrumentale intrinseque sous son vrai nom
	 set ri_intrins "ri_intrinseque$suff"
	 file copy -force "$audace(rep_images)/$repinstr" "$audace(rep_images)/$ri_intrins"
	 ::console::affiche_resultat "spc_calriintrins : en fait la reponse instrumentale s'appelle ri_intrinseque et est sauvegardee sous $audace(rep_images)/$ri_intrins\n"
	 #restitution de l'eventuelle reponse instrumentale calculee anterieurement
	 if { [ file exists "$audace(rep_images)/$repinstrprev" ]==1 } {
	    file copy -force "$audace(rep_images)/$repinstrprev" "$audace(rep_images)/$repinstr"
	    ::console::affiche_resultat "spc_calriintrins : restitution du fichier $audace(rep_images)/$repinstr\n"
	    file delete -force "$audace(rep_images)/$repinstrprev"
	    ::console::affiche_resultat "spc_calriintrins : effacement de la sauvegarde provisoire $audace(rep_images)/$repinstrprev\n"
	 }

	 #::console::affiche_resultat " sortie rinstrum : $output_rinstrum   $output_rinstrum$ad_hoc$suff \n"
	 #file copy -force "$audace(rep_images)/$output_rinstrum$ad_hoc$suff" "$audace(rep_images)/$ri_intrins"
	 # faut il coder en dur le nom riinstr ou bien le faire passer en argument ?
	 ::console::affiche_resultat " la reponse instrumentale intrinseque a ete calculee\n"
	 # nettoyage des fichiers temporaires
	 file delete -force "$audace(rep_images)/$output_rinstrum$suff"
	 file delete -force "$audace(rep_images)/$fich_profile_corr_transm$suff"
	 file delete -force "$audace(rep_images)/$transm_atmosph"
	 file delete -force "$audace(rep_images)/$type_spectral$suff"
      }
      return $ri_intrins
   }  else  {
      ::console::affiche_erreur "Usage : spc_calriintrins profil mesure ? type spectral ? caract_lambda ? liste atmosph \n\n"
   }
}
#********************************************************************

####################################################################
# Procedure de corrrection d'un profil par la réponse instrumentale intrinseque c'est a dire en prenant en compte
# l'effet de la transmission atmospherique
#
# Auteur : Patrick LAILLY
# Date creation : 2009-10-10
# Date modification : 2012-09-01
# Arguments : fichier .fit du profil 1b mesure (calibré linéairement), fichier .fit donnant la ri intrinseque, liste
# donnant les parametres requis pour le calcul de la transmission atmospherique ?
# Cette liste comprend : altitude observatoire (en km), hauteur (en °) de l'astre, le temps
# qu'il fait a choiisr entre sec ou normal ou lourd ou orageux ou valeur numerique qui sera
# la valeur de AOD specifiee par l'utilisateur, en option : desert ?
# Sortie : la procedure cree le fichier 1c associe au profil mesure : ce fichier contient le meme nombre d'echantillons
# que le fichier 1b
# Exemples d'utilisation : spc_corrriintrins zeta_tau.fit reponse_instrumentale-br.fit liste_atmosph
# Exemple de liste_atmosph { 0.8 45.0 lourd }
# Exemple de liste_atmosph { 3.842 45.0 normal desert }
# Exemple de liste_atmosph { 0.8 45.0 0.15 }
####################################################################

proc spc_corrriintrins { args } {
   global audace spcaudace
   #set spcaudace(imax_tolerence) 1.2
   #--- lecture arguments
   if { [ llength $args ] == 3 } {
      set fich_profile [ lindex $args 0 ]
      set ri_intrins [ lindex $args 1 ]
      set liste_atmosph [ lindex $args 2 ]
      #--- calcul de la transmission atmospherique
      if { [ llength $liste_atmosph ] > 4 } {
	 ::console::affiche_erreur "Usage : spc_calriintrins la liste $liste_atmosph decrivant les parametres pour la correction atmospherique est trop longue \n\n"
	 return 0
      } else {
	 set altitude [ lindex $liste_atmosph 0 ]
	 set haut [ lindex $liste_atmosph 1 ]
	 set weather [ lindex $liste_atmosph 2 ]
	 if { [ llength $liste_atmosph ] ==4 } {
	    set location [ lindex $liste_atmosph 3 ]
	 }
	 if { [ spc_testlincalib  $fich_profile ] == -1 } {
	    ::console::affiche_resultat "le profil entre n'est pas calibre lineairement => on linearise la loi de calibration \n"
	    set fich_profile [ spc_linearcal $fich_profile ]
	 }
	 #set profile [ spc_fits2data $fich_profile ]
	 buf$audace(bufNo) load "$audace(rep_images)/$fich_profile"
	 #--- Renseigne sur les parametres de l'image fich_profile:
	 set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	 set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	 set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	 ::console::affiche_resultat "caractéristiques prfil mesure $fich_profile cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
	 set caract_lambda [ list ]
	 lappend caract_lambda $naxis1
	 lappend caract_lambda $crval1
	 lappend caract_lambda $cdelt1
	 #::console::affiche_resultat "caractéristiques prfil mesure cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
	 set ecart_lambda [ expr ($naxis1 -1) * $cdelt1 ]
	 #--- test si plage longueurs d'ondes assez large
	 if { $ecart_lambda < 500. } {
	    ::console::affiche_resultat " spc_corrriintrins : avertissement : la plage de longueurs d'ondes explorees ($ecart_lambda) est petite : le calcul peut etre non significatif mais sera quand meme effectue \n"
	 }

	 #--- calcul de la transmission atmospherique
	 if { [ llength $liste_atmosph ] ==4 } {
	    set transm_atmosph [ spc_atmosph $haut $altitude $caract_lambda $weather $location ]
	 } else {
	    set transm_atmosph [ spc_atmosph $haut $altitude $caract_lambda $weather ]
	 }
	 #--- division profil mesure par transmission atmospherique
	 set fich_profile_corr_transm [ spc_divri $fich_profile $transm_atmosph ]


	 #--- division de ce resultat par la riintrins et sauvegarde du resultat (profil 1c)
	 set nom_fich [ spc_divri $fich_profile_corr_transm $ri_intrins ]
	 set nom_fich [ file rootname $nom_fich ]
	 set suff1 -1c
	 set suff .fit
	 # la gestion des noms de fichiers sera a revoir !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	 set fich_profile [ file rootname $fich_profile ]
	 file rename -force "$audace(rep_images)/$nom_fich$suff" "$audace(rep_images)/$fich_profile$suff1$suff"
	 ::console::affiche_resultat " le profil corrige de la reponse instrumentale intrinseque a ete sauvegarde sous le nom $fich_profile$suff1$suff \n"
	 #--- nettoyage des fichiers temporaires
	 file delete -force "$audace(rep_images)/$fich_profile_corr_transm$suff"
	 file delete -force "$audace(rep_images)/$transm_atmosph$suff"
	 file delete -force "$audace(rep_images)/$nom_fich$suff"
      }
      set nom_fich "$fich_profile$suff1"
      return $nom_fich
   }  else  {
      ::console::affiche_erreur "Usage : spc_corrriintrins profil mesure ? ri intrinseque ? liste atmosph \n\n"
   }
}
#************************************************************************



####################################################################
# Procedure de corrrection d'un profil par la réponse instrumentale intrinseque c'est a dire en prenant en compte
# l'effet de la transmission atmospherique
#
# Auteur : Patrick LAILLY
# Date creation : 2009-10-10
# Date modification : 2011-04-24
# Arguments : fichier .fit du profil 1b mesure (calibré linéairement), fichier .fit donnant la ri intrinseque, liste
# donnant les parametres requis pour le calcul de la transmission atmospherique ?
# Cette liste comprend : altitude observatoire (en km), hauteur (en °) de l'astre, le temps
# qu'il fait a choiisr entre sec ou normal ou lourd ou orageux ou valeur numerique qui sera
# la valeur de AOD specifiee par l'utilisateur, en option : desert ?
# Sortie : la procedure cree le fichier 1c associe au profil mesure : ce fichier contient le meme nombre d'echantillons
# que le fichier 1b
# Exemples d'utilisation : spc_corrriintrins zeta_tau.fit reponse_instrumentale-br.fit liste_atmosph
# Exemple de liste_atmosph { 0.8 45.0 lourd }
# Exemple de liste_atmosph { 3.842 45.0 normal desert }
# Exemple de liste_atmosph { 0.8 45.0 0.15 }
####################################################################

proc spc_corrriintrins_old { args } {
   global audace spcaudace
   #set spcaudace(imax_tolerence) 1.2
   #--- lecture arguments
   if { [ llength $args ] == 3 } {
      set fich_profile [ lindex $args 0 ]
      set ri_intrins [ lindex $args 1 ]
      set liste_atmosph [ lindex $args 2 ]
      #--- calcul de la transmission atmospherique
      if { [ llength $liste_atmosph ] > 4 } {
	 ::console::affiche_erreur "Usage : spc_calriintrins la liste $liste_atmosph decrivant les parametres pour la correction atmospherique est trop longue \n\n"
	 return 0
      } else {
	 set altitude [ lindex $liste_atmosph 0 ]
	 set haut [ lindex $liste_atmosph 1 ]
	 set weather [ lindex $liste_atmosph 2 ]
	 if { [ llength $liste_atmosph ] ==4 } {
	    set location [ lindex $liste_atmosph 3 ]
	 }
	 if { [ spc_testlincalib  $fich_profile ] == -1 } {
	    ::console::affiche_resultat "le profil entre n'est pas calibre lineairement => on linearise la loi de calibration \n"
	    set fich_profile [ spc_linearcal $fich_profile ]
	 }
	 #set profile [ spc_fits2data $fich_profile ]
	 buf$audace(bufNo) load "$audace(rep_images)/$fich_profile"
	 #--- Renseigne sur les parametres de l'image fich_profile:
	 set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	 set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	 set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	 ::console::affiche_resultat "caractéristiques prfil mesure $fich_profile cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
	 set caract_lambda [ list ]
	 lappend caract_lambda $naxis1
	 lappend caract_lambda $crval1
	 lappend caract_lambda $cdelt1
	 #::console::affiche_resultat "caractéristiques prfil mesure cdelt1= $cdelt1 naxis1= $naxis1 crval1= $crval1 \n"
	 set ecart_lambda [ expr ($naxis1 -1) * $cdelt1 ]
	 #--- test si plage longueurs d'ondes assez large
	 if { $ecart_lambda < 500. } {
	    ::console::affiche_resultat " spc_corrriintrins : avertissement : la plage de longueurs d'ondes explorees ($ecart_lambda) est petite : le calcul peut etre non significatif mais sera quand meme effectue \n"
	 }

	 #--- calcul de la transmission atmospherique
	 if { [ llength $liste_atmosph ] ==4 } {
	    set transm_atmosph [ spc_atmosph $haut $altitude $caract_lambda $weather $location ]
	 } else {
	    set transm_atmosph [ spc_atmosph $haut $altitude $caract_lambda $weather ]
	 }
	 #--- division profil mesure par transmission atmospherique
	 set fich_profile_corr_transm [ spc_divri $fich_profile $transm_atmosph ]
	 # mise en conformite des profils ri_intrins et fich_profile_corr_transm
	 buf$audace(bufNo) load "$audace(rep_images)/$ri_intrins"
	 #--- Renseigne sur les parametres de l'image ri_intrins:
	 #set naxis1b [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	 set crval1b [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
	 #set cdelt1b [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	 set crval1m [ expr max ( $crval1, $crval1b ) ]
	 set ri_intrins_newsamp [ spc_echantdelt $ri_intrins $cdelt1 $crval1m ]
	 #egalisation du nb d'echantillons des deux profils
	 #--- Renseigne sur les parametres de l'image ri_intrins_newsamp:
	 buf$audace(bufNo) load "$audace(rep_images)/$ri_intrins_newsamp"
	 set naxis1b [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
	 #egalisation du nb d'echantillons des deux profils
	 if { $naxis1 < $naxis1b } {
	    set ri_intrins_newsamp [ spc_selectpixels $ri_intrins_newsamp 1 $naxis1 ]
	 } elseif { $naxis1 > $naxis1b } {
	    set ri_intrins_newsamp [ spc_zeropad $ri_intrins_newsamp $naxis1 ]
	 }
	 ::console::affiche_resultat " spc_corrriintrins : riintrins $ri_intrins_newsamp reechantillone avec $naxis1b echantillons \n"
	 #--- division de ce resultat par la riintrins et sauvegarde du resultat (profil 1c)
	 set nom_fich [ spc_divri $fich_profile_corr_transm $ri_intrins_newsamp ]
	 set nom_fich [ file rootname $nom_fich ]
	 set suff1 -1c
	 set suff .fit
	 # la gestion des noms de fichiers sera a revoir !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	 set fich_profile [ file rootname $fich_profile ]
	 file rename -force "$audace(rep_images)/$nom_fich$suff" "$audace(rep_images)/$fich_profile$suff1$suff"
	 ::console::affiche_resultat " le profil corrige de la reponse instrumentale intrinseque a ete sauvegarde sous le nom $fich_profile$suff1$suff \n"
	 #--- nettoyage des fichiers temporaires
	 file delete -force "$audace(rep_images)/$fich_profile_corr_transm$suff"
	 file delete -force "$audace(rep_images)/$transm_atmosph$suff"
	 file delete -force "$audace(rep_images)/$nom_fich$suff"
      }
      set nom_fich "$fich_profile$suff1"
      return $nom_fich
   }  else  {
      ::console::affiche_erreur "Usage : spc_corrriintrins profil mesure ? ri intrinseque ? liste atmosph \n\n"
   }
}
#************************************************************************



####################################################################
# Procedure pour calculer la transmission atmospherique (attenuation) pour un astre de hauteur
# zenithale donnee (spectro basse resolution)
# Auteur : Patrick Lailly (ref. doc Ch. Buil))
# Date creation : 2009-09-25
# Date modification : 2009-09-25
# Attention dans cette version l'argument est la hauteur de l'astre (avant c'etait la hauteur zenithale)
# Arguments :  hauteur de l'astre (en °), altitude observatoire (en km), liste
# donnant les caracteristiques (naxis1, crval1, cdelt1) de la liste des lambdas, le temps
# qu'il fait a choiisr entre sec ou normal ou lourd ou orageux ou valeur numerique qui sera
# la valeur de AOD specifiee par l'utilisateur, en option : desert
# Sortie : fichier fits (transm_atmosph.fit) donnant liste des valeurs de la transmission
# atmopherique pour les longueurs d'ondes considerees
# Exemple : spc_atmosph 35 .9 caract_lambda lourd
# Exemple : spc_atmosph 35 .9 caract_lambda .05
# Exemple : spc_atmosph 35 .9 caract_lambda sec desert
####################################################################

proc spc_atmosph { args } {
   global audace spcaudace
   if { [ llength $args ] == 4 || [ llength $args ] == 5 } {
      set haut [ lindex $args 0 ]
      set haut_zen [ expr 90. - $haut ]
      set alt_obs [ lindex $args 1 ]
      set caract_lambda [ lindex $args 2 ]
      set weather [ lindex $args 3 ]
      set location 0
      if { [ llength $args ] == 5 } {
	 set location [ lindex $args 4 ]
      }
      set test  0
      switch $weather {
	 sec {
	    set AOD .07 ; set test 1
	    ::console::affiche_resultat "acquisition par temps sec specifie par l'utilisateur\n"
	 }
	 normal {
	    set AOD .14 ; set test 1
	    ::console::affiche_resultat "acquisition par temps normal specifie par l'utilisateur\n"
	 }
	 lourd {
	    set AOD .25 ; set test 1
	    ::console::affiche_resultat "acquisition par temps lourd specifie par l'utilisateur\n"
	 }
	 orageux {
	    set AOD .45 ; set test 1
	    ::console::affiche_resultat "acquisition par temps orageux specifie par l'utilisateur\n"
	 }
      }
      if { $location == {desert} } {
	 set AOD [ expr $AOD * .5 ]
	 ::console::affiche_resultat "acquisition en zone desertique specifiee explicitement par l'utilisateur\n"

      }
      if { $test == 0 } {
	 set AOD [ lindex $args 3 ]
	 ::console::affiche_resultat "AOD specifie explicitement par l'utilisateur a la valeur de $AOD\n"
      }
      set z [ mc_angle2rad $haut_zen ]
      #--- calcul de la masse d'air
      set X [ expr cos ( $z ) + .025 * exp ( -11. * cos ( $z ) ) ]
      set X [ expr 1. / $X ]
      if { [ llength $caract_lambda ] != 3 } {
	 ::console::affiche_erreur " spc_atmosph la liste donnant les caracteristiques des longueurs d'ondes considerees n'a pas la bonne longueur \n\n"
	 return 0
      }
      set naxis1 [ lindex $caract_lambda 0 ]
      set crval1 [ lindex $caract_lambda 1 ]
      set cdelt1 [ lindex $caract_lambda 2 ]
      ::console::affiche_resultat " longueurs d'ondes considerees definies par naxis1 = $naxis1 crval1 = $crval1 cdelt1 = $cdelt1 \n "
      set list_lambda [ list ]
      for { set i 0 } { $i < $naxis1 } { incr i } {
	 set lambda [ expr $crval1 + $cdelt1 * $i ]
	 lappend list_lambda $lambda
      }

      #--- calcul diffusion de Rayleigh + absorption ozone
      set A1R .0094977
      set A2R [ expr exp (-$alt_obs/7.996) ]
      set listR [ list ]
      for { set i 0 } { $i < $naxis1 } { incr i } {
	 set lambda [ expr [ lindex $list_lambda $i ] *.0001 ]
	 #--Rayleigh
	 set invlambda2 [ expr 1. / ( $lambda * $lambda ) ]
	 set A1 .23465
	 set A1 [ expr $A1 + 107.6 / ( 146. - $invlambda2 ) ]
	 set A1 [ expr $A1 + .93161 / ( 41. - $invlambda2 ) ]
	 set A1 [ expr $A1 * $A1 ]
	 set A2 [ expr $A1R * $A2R * $A1 * $invlambda2 * $invlambda2 ]
	 #-- ozone
	 set Tz [ expr exp (-.0168 * exp ( -15. * abs ( $lambda - .59 ) ) ) ]
	 #-- logarithme decimal
	 set Ao [ expr -2.5 * log10 ( $Tz ) ]
	 #--effet de aerosols
	 set Aa [ expr $lambda / .55 ]
	 set Aa [ expr pow ($Aa, -1.3) ]
	 set Aa [ expr 2.5 * log10 ( exp ( $AOD * $Aa ) ) ]
	 # +2.5 d'apres Buil
	 lappend listR [ expr $A2 + $Ao +$Aa]
      }

      ::console::affiche_resultat " AOD utilise = $AOD \n"

      set transm [ list ]
      for { set i 0 } { $i < $naxis1 } { incr i } {
	 set XX [ expr -.4 *  [ lindex $listR $i ] * $X ]
	 set XX [ expr pow (10, $XX) ]
	 lappend transm $XX
      }

      #--- visualisation du resultat
      ::plotxy::clf
      ::plotxy::figure 1
      ::plotxy::plot $list_lambda $transm r 1
      #::plotxy::plot $abscissesorig $riliss1 g 1
      ::plotxy::hold on
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::xlabel "lambda"
      ::plotxy::ylabel "transm. atmosph."
      ::plotxy::hold on
      ::plotxy::title "AOD= $AOD"
      #-- creation fichier fits transm_atmosph
      #-- creation du nouveau fichier
      set nbunit "float"
      set nbunit1 "double"
      buf$audace(bufNo) setpixels CLASS_GRAY $naxis1 1 FORMAT_FLOAT COMPRESS_NONE 0
      buf$audace(bufNo) setkwd [ list "NAXIS" 1 int "" "" ]
      buf$audace(bufNo) setkwd [list "NAXIS1" $naxis1 int "" ""]
      buf$audace(bufNo) setkwd [list "NAXIS2" 1 int "" ""]
      #-- Valeur minimale de l'abscisse (xdepart) : =0 si profil non étalonné
      #set xdepart [ expr 1.0*[lindex $lambda 0]]
      buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 $nbunit1 "" "angstrom"]
      #-- Dispersion
      buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1 $nbunit1 "" "angstrom/pixel"]
      buf$audace(bufNo) setkwd [list "CRPIX1" 1 double "" ""]
      #-- Rempli la matrice 1D du fichier fits avec les valeurs du profil de raie ---
      # Une liste commence à 0 ; Un vecteur fits commence à 1
      #set intensite [ list ]
      for {set k 0} { $k < $naxis1 } {incr k} {
	 #append intensite [lindex $profileref $k]
	 #::console::affiche_resultat "$intensite\n"
	 #if { [regexp {([0-9]+\.*[0-9]*)} $intensite match mintensite] } {}
	 buf$audace(bufNo) setpix [list [expr $k+1] 1] [lindex $transm $k ]
         #set intensite 0
      }
      #--- Sauvegarde du fichier fits ainsi créé
      buf$audace(bufNo) bitpix float
      set nom_fich_output "transm_atmosph"
      buf$audace(bufNo) save "$audace(rep_images)/$nom_fich_output"
      ::console::affiche_resultat " nom fichier sortie $nom_fich_output \n"
      buf$audace(bufNo) bitpix short
      return $nom_fich_output

   } else {
      ::console::affiche_erreur "Usage : spc_atmosph hauteur_astre(degre) altitude_observatoire_(km) {naxis1 crval1 cdelt1} ?weather(sec/normal/orageux/lourd)/AOD? ?desert?\n\n"
   }
}
#*********************************************************************




####################################################################
# Efface la calibration d'un profil de raies :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2009-12-23
# Date modification : 2009-12-23
# Argument : nom du porofil de raies
#
####################################################################

proc spc_delcal { args } {
   global audace conf

   if { [llength $args] == 1 } {
      set filespc [ file rootname [ lindex $args 0 ] ]

      #--- Efface les mots clef :
      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         buf$audace(bufNo) delkwd "CDELT1"
         buf$audace(bufNo) delkwd "CRVAL1"
         if { [ lsearch $listemotsclef "CUNIT1" ] !=-1 } {
            buf$audace(bufNo) delkwd "CUNIT1"
         }
         if { [ lsearch $listemotsclef "CTYPE1" ] !=-1 } {
            buf$audace(bufNo) delkwd "CTYPE1"
         }
         if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
            buf$audace(bufNo) delkwd "SPC_RMS"
         }
      }
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         buf$audace(bufNo) delkwd "SPC_A"
         buf$audace(bufNo) delkwd "SPC_B"
         buf$audace(bufNo) delkwd "SPC_C"
         if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
            buf$audace(bufNo) delkwd "SPC_D"
         }
         if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
            buf$audace(bufNo) delkwd "SPC_E"
         }
      }

      #--- Traitement du resultat :
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filespc}_nc"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "Profil savé sous ${filespc}_nc\n"
      return ${filespc}_nc
   } else {
      ::console::affiche_erreur "Usage : spc_delcal profil_de_raies_calibre\n"
   }
}
#*****************************************************************#



####################################################################
# Calcul le RMS d'une loi de calibration a l'aide des raies utilisees
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2009-10-06
# Date modification : 2009-10-06
# Exemples :
# spc_calibrms 1. 6237.76305396 0.341479004614 -1.89664276254e-06 0 {84.08237 483.213003  790.44639 1063.872 1414.723756 } {6266.49 6402.25 6506.53 6598.95 6717.04}
# Decalage moyen=2.14000285844e-07 ; RMS=0.0202809056204.
# 0.0202809056204
#
# spc_calibrms  1. 6237.85625521 0.3405440622 -2.89514072546e-07 -7.11963452803e-10 {84.08237 483.213003  790.44639 1063.872 1414.723756 } {6266.49 6402.25 6506.53 6598.95 6717.04}
# Decalage moyen=5.60003066502e-08 ; RMS=0.0065581466617.
# 0.0065581466617
####################################################################

proc spc_calibrms { args } {
   global audace conf

   set nbargs [ llength $args ]
   if { $nbargs==7 } {
      set crpix1 [ lindex $args 0 ]
      set a [ lindex $args 1 ]
      set b [ lindex $args 2 ]
      set c [ lindex $args 3 ]
      set d [ lindex $args 4 ]
      set pixels [ lindex $args 5 ]
      set lambdas [ lindex $args 6 ]
   } elseif { $nbargs==8 } {
      set crpix1 [ lindex $args 0 ]
      set a [ lindex $args 1 ]
      set b [ lindex $args 2 ]
      set c [ lindex $args 3 ]
      set d [ lindex $args 4 ]
      set e [ lindex $args 5 ]
      set pixels [ lindex $args 6 ]
      set lambdas [ lindex $args 7 ]
   } else {
      ::console::affiche_erreur "Usage : spc_calibrms crpix1 a b c d ?e? \{positions en pixels\} \{longueurs d'onde\}\n\n"
      return ""
   }

   #--- Calcul la différence entre les O-C des lambdas ayant servi a la calibration :
   set diff 0.0
   set diff2 0.0
   set nblines [ llength $pixels ]
   if { $nbargs==7} {
      foreach x $pixels lambda $lambdas {
         set lambda_cal [ spc_calpoly $x $crpix1 $a $b $c $d ]
         set diff [ expr $diff+($lambda_cal-$lambda) ]
         set diff2 [ expr $diff2+($lambda_cal-$lambda)*($lambda_cal-$lambda) ]
      }
   } elseif { $nbargs==8 } {
      foreach x $pixels lambda $lambdas {
         set lambda_cal [ spc_calpoly $x $crpix1 $a $b $c $d $e ]
         set diff [ expr $diff+($lambda_cal-$lambda) ]
         set diff2 [ expr $diff2+($lambda_cal-$lambda)*($lambda_cal-$lambda) ]
      }
   }

   #--- Calculs de la dispersion :
   set meanshift [ expr $diff/$nblines ]
   set rms [ expr sqrt($diff2/$nblines) ]
   if { $rms<=0.000001 } {
      ::console::affiche_resultat "Gestion d'un RMS<10^-6.\n"
      set rms [ format "%1.4e" $rms ]
   }

   ::console::affiche_resultat "Decalage moyen=$meanshift ; RMS=$rms.\n"
   return $rms
}
#*****************************************************************#



####################################################################
#  Procedure de calcul de dispersion moyenne
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2005
# Date modification : 27-02-2005
# Arguments : liste des lambdas, naxis1
####################################################################

proc spc_dispersion_moy { { lambdas ""} } {
    # Dispersion du spectre :
    set naxis1 [llength $lambdas]
    set l1 [lindex $lambdas 1]
    set l2 [lindex $lambdas [expr int($naxis1/10)]]
    set l3 [lindex $lambdas [expr int(2*$naxis1/10)]]
    set l4 [lindex $lambdas [expr int(3*$naxis1/10)]]
    set dl1 [expr ($l2-$l1)/(int($naxis1/10)-1)]
    set dl2 [expr ($l4-$l3)/(int($naxis1/10)-1)]
    set xincr [expr 0.5*($dl2+$dl1)]
    return $xincr
}
#****************************************************************#



####################################################################
#  Procedure de calibration en longueur d'onde par une loi lineaire a+b*x
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-05 / 09-12-05 / 26-12-05 / 11-11-09
# Arguments : fichier .fit du profil de raie spatial pixel1 lambda1 pixel2 lambda2
####################################################################

proc spc_calibre2 { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 5} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set pixel2 [ lindex $args 3 ]
    set lambda2 [ lindex $args 4 ]

     #--- Tri des raies par ordre coissant des abscisses :
     set coords [ list $pixel1 $lambda1 $pixel2 $lambda2 ]
     set couples [ list  ]
     set len 4
     for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ] } {
        lappend couples [ list [ lindex $coords $i ] [ lindex $coords [ expr $i+1 ] ] ]
     }
     set couples [ lsort -index 0 -increasing -real $couples ]

     #--- Réaffecte les couples pixels,lambda :
     set i 1
     foreach element $couples {
        set pixel$i [ lindex $element 0 ]
        set lambda$i [ lindex $element 1 ]
        incr i
     }


    #--- Récupère la liste "spectre" contenant 2 listes : pixels et intensites
    #set spectre [ openspcncal "$filespc" ]
    #-- Modif faite le 26/12/2005
    #set spectre [ spc_fits2data "$filespc" ]
    #set intensites [lindex $spectre 0]
    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set listemotsclef [ buf$audace(bufNo) getkwds ]
    set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
    #set binning [ lindex [ buf$audace(bufNo) getkwd "BIN1" ] 1 ]
    if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
       set pixelRef [  lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
    } else {
       set pixelRef 1
    }

    #--- Calcul des parametres spectraux
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion angstroms/pixel\n"
    set lambdaRef [expr 1.0*($lambda1-$dispersion*($pixel1-$pixelRef))]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    if { [ lsearch $listemotsclef "CRPIX1" ]==-1 } {
       buf$audace(bufNo) setkwd [ list "CRPIX1" $pixelRef double "Reference pixel" "pixel" ]
    }
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdaRef double "Wavelength at reference pixel" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Wavelength dispersion" "angstrom/pixel" ]
    buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" "" ]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "Axis 1 data type" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    buf$audace(bufNo) bitpix short
    ::console::affiche_resultat "\nLoi de calibration : $lambdaRef+$dispersion*x\n"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2 fichier_fits_du_profil x1 lambda1 x2 lambda2\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure de conversion d'étalonnage en longueur d'onde d'ordre 2
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-05/09-12-05/26-12-05/26-03-06
# Arguments : fichier .fit du profil de raie x1a x2a lambda_a type_raie (a/e) x1b x2b lambda_b type_raie (a/e)
####################################################################

proc spc_calibre2sauto { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 9} {
    set filespc [ lindex $args 0 ]
    set pixel1a [ expr int([ lindex $args 1 ]) ]
    set pixel1b [ expr int([ lindex $args 2 ]) ]
    set lambda1 [ lindex $args 3 ]
    set linetype1 [ lindex $args 4 ]
    set pixel2a [ expr int([ lindex $args 5 ]) ]
    set pixel2b [ expr int([ lindex $args 6 ]) ]
    set lambda2 [ lindex $args 7 ]
    set linetype2 [ lindex $args 8 ]

    #--- Récupère la liste "spectre" contenant 2 listes : pixels et intensites
    #set spectre [ openspcncal "$filespc" ]
    #-- Modif faite le 26/12/2005
    #set spectre [ spc_fits2data "$filespc" ]
    #set intensites [lindex $spectre 0]
    ##set naxis1 [lindex $spectre 1]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]
    set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]


    #--- Détermine le centre gaussien de la raie 1 et 2
    #-- Raie 1
    if { $linetype1 == "a" } {
          buf$audace(bufNo) mult -1
    }
    set listcoords [list $pixel1a 1 $pixel1b 1]
    set pixel1 [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1]
    #-- Redresse le spectre a l'endroit s'il avait ete inversé précédement
    if { $linetype1 == "a" } {
          buf$audace(bufNo) mult -1
    }
    #-- Raie 2
    if { $linetype2 == "a" } {
          buf$audace(bufNo) mult -1
    }
    set listcoords [list $pixel2a 1 $pixel2b 1]
    set pixel2 [lindex [ buf$audace(bufNo) fitgauss $listcoords ] 1]
    #-- Redresse le spectre a l'endroit s'il avait ete inversé précédement
    if { $linetype2 == "a" } {
          buf$audace(bufNo) mult -1
    }
    ::console::affiche_resultat "Centre des raies 1 : $pixel1 et raie 2 : $pixel2\n"

    #--- Calcul des parametres spectraux
    #-- Dispersion :
    set deltax [expr 1.0*($pixel2-$pixel1)]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion vaut : $dispersion angstroms/pixel\n"
    #-- Longueur d'onde de départ :
    set lambda0 [ expr 1.0*($lambda1-$dispersion*($pixel1-$crpix1)) ]
    # set lambda0 [expr 1.0*($lambda1-$dispersion*$pixel1/$binning)] # FAUX

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "Wavelength at reference pixel" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "Wavelength dispersion" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "Axis 1 data type" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save $audace(rep_images)/l${filespc}
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2sauto fichier_fits_du_profil x1a x2a lambda_a type_raie (a/e) x1b x2b lambda_b type_raie (a/e)\n\n"
  }
}
#****************************************************************#



####################################################################
#  Procedure d'étalonnage en longueur d'onde à partir de la dispersion et d'une raie
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 16-08-2005
# Date modification : 16-08-2005
# Arguments : profil de raie.fit, pixel, lambda, dispersion
####################################################################

proc spc_calibre2rd { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 4} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set dispersion [ lindex $args 3 ]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
    set crpix1 [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
    ::console::affiche_resultat "$naxis1\n"

    #--- Calcul des parametres spectraux
    set lambda0 [expr 1.0*($lambda1-$dispersion*($pixel1-$crpix1))]

    #--- Initialisation des mots clefs du fichier fits de sortie
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "Wavelength at reference pixel" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "Wavelength dispersion" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "Axis 1 data type" ""]

    #--- Sauvegarde du profil calibré
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2rd fichier_fits_du_profil x1 lambda1 dispersion\n\n"
  }
}
#****************************************************************#


####################################################################
# Procedure d'étalonnage en longueur d'onde à partir de la loi de dispersion
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-04-2006
# Date modification : 17-04-2006
# Arguments : profil de raie.fit, lambda_debut, dispersion
####################################################################

proc spc_calibre2loi { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 3} {
    set filespc [ lindex $args 0 ]
    set lambda0 [ lindex $args 1 ]
    set dispersion [ lindex $args 2 ]

    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    #--- Initialisation des mots clefs du fichier fits de sortie
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "Wavelength at reference pixel" "angstrom"]
    #-- Dispersion
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "Wavelength dispersion" "angstrom/pixel"]
    buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
    #-- Corrdonnée représentée sur l'axe 1 (ie X)
    buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "Axis 1 data type" ""]

    #--- Sauvegarde du profil calibré
    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre2loi fichier_fits_du_profil lambda_debut dispersion\n\n"
  }
}
#****************************************************************#


####################################################################
# Procedure d'étalonnage en longueur d'onde à partir de la loi de dispersion
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 17-04-2006
# Date modification : 20-09-2006/04-01-07/07-04-2008
# Arguments : profil_de_reference_fits profil_a_etalonner_fits
####################################################################

proc spc_calibreloifile { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 2} {
      set fileref [ lindex $args 0 ]
      set filespc [ lindex $args 1 ]

      buf$audace(bufNo) load "$audace(rep_images)/$fileref"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
          set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix1 1
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
          set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      }
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
          set dispersion [ lindex [buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
          set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
          set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
          set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
          set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
      } else {
          set spc_d 0.0
      }
      if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
          set spc_e [ lindex [ buf$audace(bufNo) getkwd "SPC_E" ] 1 ]
      } else {
          set spc_e 0.0
      }
      if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
          set spc_rms [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 1 ]
      }
      if { [ lsearch $listemotsclef "SPC_RESP" ] !=-1 } {
         set spc_res [ lindex [ buf$audace(bufNo) getkwd "SPC_RESP" ] 1 ]
      } else {
         set spc_res 0.
      }
      if { [ lsearch $listemotsclef "SPC_RESL" ] !=-1 } {
         set spc_resl [ lindex [ buf$audace(bufNo) getkwd "SPC_RESL" ] 1 ]
      } else {
         set spc_resl 0.
      }

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      #--- Initialisation des mots clefs du fichier fits de sortie
      # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
      #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
      #if { [ lsearch $listemotsclef "CRPIX1" ]==-1 } 
      buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]

      #-- Longueur d'onde de départ
      #if { [ lsearch $listemotsclef "CRVAL1" ]!=-1 } {
      #    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "Wavelength at reference pixel" "Angstrom"]
      #}
      buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "Wavelength at reference pixel" "angstrom"]

      #-- Dispersion
      #if { [ lsearch $listemotsclef "CDELT1" ]!=-1 } {
      #   buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Wavelength dispersion" "angstrom/pixel" ]
      #   buf$audace(bufNo) setkwd [ list "CUNIT1" "Angstrom" string "Wavelength unit" "" ]
      #}
      buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel" ]
      buf$audace(bufNo) setkwd [ list "CUNIT1" "angstrom" string "Wavelength unit" "" ]

      #-- Coordonnée représentée sur l'axe 1 (ie X)
     buf$audace(bufNo) setkwd [ list "CTYPE1" "Wavelength" string "Axis 1 data type" "" ]
     buf$audace(bufNo) setkwd [ list "SPC_RESP" $spc_res double "Power of resolution at wavelength SPC_RESL" "" ]
     buf$audace(bufNo) setkwd [ list "SPC_RESL" $spc_resl double "Wavelength for resolution measurement" "angstrom" ]
     if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
        buf$audace(bufNo) setkwd [ list "SPC_RMS" $spc_rms double "Wavelength calibration RMS" "angstrom" ]
     }

      #--- Mots clefs de la calibration non-linéaire :
      #-- A+B.x+C.x.x+D.x.x.x
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
          #-- Ancienne formulation < 04012007 :
          # buf$audace(bufNo) setkwd [list "SPC_DESC" "A.x.x+B.x+C" string "" ""]
          #-- Nouvelle formulation :
          buf$audace(bufNo) setkwd [ list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" "" ]
          buf$audace(bufNo) setkwd [ list "SPC_A" $spc_a double "Wavelength at reference pixel" "angstrom" ]
          if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
              buf$audace(bufNo) setkwd [ list "SPC_B" $spc_b double "" "angstrom/pixel" ]
          }
          if { [ lsearch $listemotsclef "SPC_C" ] !=-1 } {
              buf$audace(bufNo) setkwd [ list "SPC_C" $spc_c double "" "angstrom*angstrom/pixel*pixel" ]
          }
          buf$audace(bufNo) setkwd [ list "SPC_D" $spc_d double "" "angstrom*angstrom*angstrom/pixel*pixel*pixel" ]
          if { $spc_e!=0 } {
              buf$audace(bufNo) setkwd [ list "SPC_E" $spc_e double "" "A*A*A*A/pixel*pixel*pixel*pixel" ]
          }
          if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
              buf$audace(bufNo) setkwd [ list "SPC_RMS" $spc_rms double "Wavelength calibration RMS" "angstrom" ]
          }

      }

      #--- Sauvegarde du profil calibré
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
      return l${filespc}
  } else {
      ::console::affiche_erreur "Usage: spc_calibreloifile profil_de_reference_fits profil_a_etalonner_fits\n\n"
  }
}
#****************************************************************#



####################################################################
# Procedure de décalage de la longureur d'onde de départ
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-01-2007
# Date modification : 04-01-2007
# Arguments : profil_a_decaler_fits decalage
####################################################################

proc spc_calibredecal { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 2} {
      set filespc [file rootname [ lindex $args 0 ] ]
      set decalage [ lindex $args 1 ]

      buf$audace(bufNo) load "$audace(rep_images)/$filespc"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
          if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
              set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
              set lambda_modifie [ expr $lambda0+$decalage ]
              buf$audace(bufNo) setkwd [list "CRVAL1" $lambda_modifie double "Wavelength at reference pixel" "angstrom"]
          }
          set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
          set spc_a_modifie [ expr $spc_a+$decalage ]
          buf$audace(bufNo) setkwd [list "SPC_A" $spc_a_modifie double "Wavelength at reference pixel" "angstrom"]
      } elseif { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
         set lambda_modifie [ expr $lambda0+$decalage ]
         buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda_modifie double "Wavelength at reference pixel" "angstrom" ]
         buf$audace(bufNo) setkwd [ list "SPC_DEC" $decalage double "Wavelength shift applied" "angstrom" ]
      }

      #--- Sauvegarde du profil calibré
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filespc}_dec"
      ::console::affiche_resultat "spc_calibredecal Spectre décalé $decalage CRVAL1=$lambda_modifie, sauvé sous ${filespc}_dec\n"
      return "${filespc}_dec"
  } else {
      ::console::affiche_erreur "Usage: spc_calibredecal profil_a_decaler_fits decalage\n\n"
  }
}
#****************************************************************#



####################################################################
# Procédure de calibration par un polynôme de degré 2 (au moins 3 raies nécessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
# Exemple : spc_calibren ne-2 84.08237 6266.49 483.213003 6402.25 790.44639 6506.53 1063.89 6598.95 1414.723756 6717.04
# Coefficients B : 6238.19448683+0.340573342632*x+-3.51778832039e-07*x^2+-6.83665149147e-10*x^3
# Decalage moyen=-1.65999709219e-07 ; RMS=0.00717259190759.
# RMS=0.00717259190759 angstrom
# La droite de régression est : 6238.49652963+0.338582593128*x
####################################################################

proc spc_calibren { args } {
   global conf
   global audace spcaudace
   set erreur 0.01

   set len [expr [ llength $args ]-1 ]
   if { [ expr $len+1 ] >= 2 } {
      set filename [ lindex $args 0 ]
      set coords [ lrange $args 1 $len ]

      #--- Tri des raies par ordre coissant des abscisses :
      for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ]} {
         lappend couples [ list [ lindex $coords $i ] [ lindex $coords [ expr $i+1 ] ] ]
      }
      set couples [ lsort -index 0 -increasing -real $couples ]
      set lencouples [ llength $couples ]

      #--- Préparation des listes de données :
      for {set i 0} {$i<$lencouples} {incr i} {
         lappend xvals [ lindex [ lindex $couples $i ] 0 ]
         lappend lambdas [ lindex [ lindex $couples $i ] 1 ]
         lappend errors $erreur
      }
      set nbraies [ llength $lambdas ]

      #--- Obtention de mots clef :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      #set binning [ lindex [ buf$audace(bufNo) getkwd "BIN1" ] 1 ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix1  1.0
      }

      #--- Calcul des coéfficients du polynome de calibration :
      if { $nbraies == 2 } {
         #-- Calcul du polynôme de calibration a+bx :
         set sortie [ spc_ajustdeg1cal $crpix1 $xvals $lambdas ]
         set a [ lindex $sortie 0 ]
         set b [ lindex $sortie 1 ]
         set c 0.0
         set d 0.0
         buf$audace(bufNo) setkwd [list "CDELT1" $b double "" "angstrom/pixel"]
      } elseif { $nbraies == 3 } {
         #-- Calcul du polynôme de calibration a+bx+cx^2 :
         set sortie [ spc_ajustdeg2 $xvals $lambdas $errors $crpix1 ]
         set coeffs [ lindex $sortie 0 ]
         set chi2 [ lindex $sortie 1 ]
         set d 0.0
         set c [ lindex $coeffs 2 ]
         set b [ lindex $coeffs 1 ]
         set a [ lindex $coeffs 0 ]
      } elseif { $nbraies == 4 } {
         #-- Calcul du polynôme de calibration a+b*x+c*x^2+d*x^3 :
         set sortie [ spc_ajustdeg3 $xvals $lambdas $errors $crpix1 ]
         set coeffs [ lindex $sortie 0 ]
         set chi2 [ lindex $sortie 1 ]
         set d [ lindex $coeffs 3 ]
         set c [ lindex $coeffs 2 ]
         set b [ lindex $coeffs 1 ]
         set a [ lindex $coeffs 0 ]
      } elseif { $nbraies > 4 && $spcaudace(degmax_cal)<=4 } {
         #-- Calcul du polynôme de calibration a+b*x+c*x^2+d*x^3 :
         set sortie [ spc_ajustdegn $xvals $lambdas $erreur $spcaudace(degmax_cal) $crpix1 ]
         set coeffs [ lindex $sortie 0 ]
         set chi2 [ lindex $sortie 1 ]
         set e [ lindex $coeffs 4 ]
         set d [ lindex $coeffs 3 ]
         set c [ lindex $coeffs 2 ]
         set b [ lindex $coeffs 1 ]
         set a [ lindex $coeffs 0 ]
         switch $spcaudace(degmax_cal) {
            4 {
               set e [ lindex $coeffs 4 ]
               set d [ lindex $coeffs 3 ]
               set c [ lindex $coeffs 2 ]
               set b [ lindex $coeffs 1 ]
               set a [ lindex $coeffs 0 ]
            }
            3 {
               set e 0.0
               set d [ lindex $coeffs 3 ]
               set c [ lindex $coeffs 2 ]
               set b [ lindex $coeffs 1 ]
               set a [ lindex $coeffs 0 ]
            }
            2 {
               set e 0.0
               set d 0.0
               set c [ lindex $coeffs 2 ]
               set b [ lindex $coeffs 1 ]
               set a [ lindex $coeffs 0 ]
            }
            1 {
               set e 0.0
               set d 0.0
               set c 0.0
               set b [ lindex $coeffs 1 ]
               set a [ lindex $coeffs 0 ]
            }
            0 {
               ::console::affiche_erreur "Le degré du polinôme de calibration doit être supérieur à 0.\n"
               return ""
            }
         }
      } else {
         ::console::affiche_erreur "Il faut au moins deux raies pour calibrer.\n"
         return ""
      }

      #--- Calcul de la longueur au pixel de reference :
      if { $nbraies <= 4 } {
         set lambdaRef [ spc_calpoly $crpix1 $crpix1 $a $b $c $d ]
      } else {
         set lambdaRef [ spc_calpoly $crpix1 $crpix1 $a $b $c $d $e ]
      }

      #--- Calcul du RMS :
      #- set rms [ expr $lambda0deg3*sqrt($chi2/$nbraies) ]
      #- set sigma 1.0
      #- set rms [ expr $sigma*sqrt($chi2/$nbraies) ]
      if { $nbraies <= 4 } {
         set rms [ spc_calibrms $crpix1 $a $b $c $d $xvals $lambdas ]
      } else {
         set rms [ spc_calibrms $crpix1 $a $b $c $d $e $xvals $lambdas ]
      }
      ::console::affiche_resultat "RMS=$rms angstrom\n"

      #--- Calcul des coéfficients de linéarisation provisoire de la calibration a1+b1*x (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
      if { $nbraies<=4 } {
         #-- Calcul d'une série de longueurs d'ondes passant par le polynome pour la linéarisation qui suit :
         #- for { set x 20 } { $x<=[ expr $naxis1-10 ] } { set x [ expr $x+20 ]} {
         #-    lappend xpos $x
         #-    lappend lambdaspoly [ spc_calpoly $x $crpix1 $a $b $c $d ]
         #- }
         #-- Obtention de la dispersion approximative cdelt1 :
         ## set coeffsdeg1 [ spc_reglin $xpos $lambdaspoly $crpix1 ]
         ## set b1 [ lindex $coeffsdeg1 0 ]
         #- set coeffsdeg1 [ spc_ajustdeg1hp $xpos $lambdaspoly 1. $crpix1 ]
         #- set b1 [ lindex [ lindex $coeffsdeg1 0 ] 1 ]
         set lambdafin [ spc_calpoly $naxis1 $crpix1 $a $b $c $d ]
         set dispersion [ expr 1.0*($lambdafin-$lambdaRef)/($naxis1-1) ]
         ::console::affiche_prompt "Loi linéarisée : $lambdaRef+$dispersion*(x-$crpix1)\n"
      } elseif { $nbraies>=5 } {
         set lambdafin [ spc_calpoly $naxis1 $crpix1 $a $b $c $d $e ]
         set dispersion [ expr 1.0*($lambdafin-$lambdaRef)/($naxis1-1) ]
         ::console::affiche_prompt "Loi linéarisée : $lambdaRef+$dispersion*(x-$crpix1)\n"
      } else {
         set dispersion $b
      }

      #--- Mise à jour des mots clefs :
      if { [ lsearch $listemotsclef "CRPIX1" ] ==-1 } {
         buf$audace(bufNo) setkwd [list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]
      }
      #-- Longueur d'onde de départ :
      buf$audace(bufNo) setkwd [ list "CRVAL1" $lambdaRef double "Coordinate at reference pixel" "angstrom" ]
      buf$audace(bufNo) setkwd [ list "CREATOR" "SpcAudACE $spcaudace(version)" string "Software that create this FITS file" "" ]
      #-- Dispersion moyenne :
      #- Si le mot clé n'existe pas :
      if { [ lsearch $listemotsclef "CDELT1" ] ==-1 } {
         buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel"]
         buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
      } else {
         set cdelt1_unit [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 3 ]
         if { $cdelt1_unit != "\[Angstrom/pixel\]" || $cdelt1_unit != "\[angstrom/pixel\]" } {
            #- Si l'unité du mot clé montre qu'il n'a pas de valeur liée a une calibration en longueur d'onde :
            buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "Wavelength increment" "angstrom/pixel"]
            buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
         }
      }
      #-- Coordonnée représentée sur l'axe 1 (ie X) :
      #buf$audace(bufNo) delkwd "CTYPE1"
      buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "Axis 1 data type" ""]
      #-- Mots clefs du polynôme :
      if { $nbraies<=4 } {
         buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
         buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
         buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
         buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
         buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
      } elseif { $nbraies>=5 } {
         buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x+E.x.x.x.x" string "" ""]
         buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
         buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
         buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
         buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
         buf$audace(bufNo) setkwd [list "SPC_E" $e double "" "A.A.A.A/pixel.pixel.pixel.pixel"]
      }
      buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms double "RMS measured from calibration lamp" "angstrom" ]

      #- Ecrit les mots clef contenant les longueurs d'ondes utilisees pour la calibration :
      set coords_length [ string length $coords ]
      buf$audace(bufNo) setkwd [ list "SPC_LCAD" "SPC_LCAL definition" string "Lines used for wavelength calibration" "" ]
      if { $coords_length<=70 } {
         buf$audace(bufNo) setkwd [ list "SPC_LCAL" "$coords" string "" "" ]
      } else {
         set k 1
         for { set i 70 } { [ expr $i-69 ]<=$coords_length } { incr i 70 } {
            if { [ expr $coords_length-($i-69) ]<=70 } {
               set coordsi [ string range $coords [ expr $i-69-$k ] end  ]
               buf$audace(bufNo) setkwd [ list "SPC_LCA$k" "$coordsi" string "" "" ]
            } else {
               set coordsi [ string range $coords [ expr $i-69-$k ] $i  ]
               buf$audace(bufNo) setkwd [ list "SPC_LCA$k" "$coordsi" string "" "" ]
               incr k
            }
         }
      }
      #- fin
      if { 1==0} {
      if { $coords_length<=70 } {
         buf$audace(bufNo) setkwd [ list "SPC_LCAL" "$coords" string "" "" ]
      } elseif { $coords_length>70 && $coords_length<=141 } {
         set coords1 [ string range $coords 1 70 ]
         set coords2 [ string range $coords 71 end ]
         buf$audace(bufNo) setkwd [ list "SPC_LCA1" "$coords1" string "" "" ]
         buf$audace(bufNo) setkwd [ list "SPC_LCA2" "$coords2" string "" "" ]
      } else {
         set coords1 [ string range $coords 1 70 ]
         set coords2 [ string range $coords 71 141 ]
         set coords3 [ string range $coords 142 end ]
         buf$audace(bufNo) setkwd [ list "SPC_LCA1" "$coords1" string "" "" ]
         buf$audace(bufNo) setkwd [ list "SPC_LCA2" "$coords2" string "" "" ]
         buf$audace(bufNo) setkwd [ list "SPC_LCA3" "$coords3" string "" "" ]
      }
      }
         

      #--- Fin du script :
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
      buf$audace(bufNo) bitpix short
      if { $nbraies<=4 } {
         ::console::affiche_prompt "\nLoi de calibration : $a+$b*(x-$crpix1)+$c*(x-$crpix1)^2+$d*(x-$crpix1)^3 avec RMS=$rms\n"
      } elseif { $nbraies>=5 } {
         ::console::affiche_prompt "\nLoi de calibration : $a+$b*(x-$crpix1)+$c*(x-$crpix1)^2+$d*(x-$crpix1)^3+$e*(x-$crpix1)^4 avec RMS=$rms\n"
      }
      ::console::affiche_resultat "Spectre étalonné sauvé sous l${filename}\n"
      return l${filename}
   } else {
      ::console::affiche_erreur "Usage: spc_calibren nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
   }
}
#***************************************************************************#





####################################################################
# Procédure de calibration par un polynôme de degré 2 (au moins 3 raies nécessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3
####################################################################

proc spc_autocalibren { args } {
    global conf
    global audace

    ::console::affiche_resultat "Pas encore implémentée\n"
}
#***************************************************************************#



####################################################################
# Procédure de rééchantillonnage linéaire d'un profil de raies a calibration non-linéaire
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 25-04-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_linearcal { args } {
   global conf
   global audace

   if { [llength $args] == 1 } {
      set filename [ file rootname [ lindex $args 0 ] ]

      #--- Recupere les coéfficients du polynôme de calibration :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         set spc_a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
         set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
         set spc_c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
         if { [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ] != "" } {
            set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
         } else {
            set spc_d 0.0
         }
         if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
            set spc_e [ lindex [ buf$audace(bufNo) getkwd "SPC_E" ] 1 ]
         } else {
            set spc_e 0.0
         }
         set flag_spccal 1
         #-- Calcul l'incertitude sur une lecture de longueur d'onde :
         set mes_incertitude [ expr 1.0/($spc_a*$spc_b) ]
      } else {
         set flag_spccal 0
      }
      set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
      } else {
         set crpix1 1
      }
      #::console::affiche_resultat "crval1=$crval1\n"

      #--- Initialise les vecteurs et mots clefs à sauvegarder :
      set listevals [ spc_fits2data $filename ]
      set xvals [ lindex $listevals 0 ]
      set yvals [ lindex $listevals 1 ]
      set len [ llength $xvals ]

      #--- Initialise un vecteur des indices des pixels :
      for {set i 1} {$i<=$len} {incr i} {
         lappend indices $i
      }
      set valeurs [ list $indices $xvals ]

      #--- Calcul les longueurs éspacées d'un pas constant :
      if { $flag_spccal } {
         #-- Calcul le pas del calibration linéaire :
         #set lambda_deb [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
         #set lambda_fin [ expr $spc_a+$spc_b*$len+$spc_c*$len*$len+$spc_d*$len*$len*$len ]
         #- le 21-11-2009 :
         #set lambda_deb $spc_a
         #set lambda_deb [ spc_calpoly 1. $crpix1 $spc_a $spc_b $spc_c $spc_d ]
         set lambda_deb $crval1
         set lambda_fin [ spc_calpoly $len $crpix1 $spc_a $spc_b $spc_c $spc_d $spc_e ]

         #- modif michel
         # set pas [ expr ($lambda_fin-$lambda_deb)/$len ]
         set pas [ expr ($lambda_fin-$lambda_deb)/($len-1 ) ]

         #-- Calcul les longueurs d'onde (linéaires) associées a chaque pixel :
         # set xlin [ list ]
         # set errors [ list ]
         set lambdas [ list ]
         for {set i 1} {$i<=$len} {incr i} {
            #-- 21-11-2009 : a verifier si trop lent
            #lappend lambdas [ expr $pas*($i-$crpix1)+$lambda_deb ]
            lappend lambdas [ spc_calpoly $i $crpix1 $lambda_deb $pas 0 0 ]
         }
         #-- Rééchantillonne par spline les intensités sur la nouvelle échelle en longueur d'onde :
         #- Verifier les valeurs des lambdas pour eviter un "monoticaly error de BLT".
         set new_intensities [ lindex  [ spc_spline $xvals $yvals $lambdas n ] 1 ]
         #set new_intensities [ lindex [ spc_resample $xvals $yvals $pas $lambda_deb ] 1 ]
         #-- 21-11-2009 :
         #set crval1 [ spc_cal $lambda_deb $crpix1 $lambda_deb $pas 0 0 ]
         #-- 11-04-2011 : crval1 pris dans le spectre de depart : ca ne change pas.
         #set crval1 $lambda_deb

         #-- Enregistrement au format fits :
         buf$audace(bufNo) load "$audace(rep_images)/$filename"
         for {set k 0} {$k<$len} {incr k} {
            set intensite [ lindex $new_intensities $k ]
            buf$audace(bufNo) setpix [ list [ expr $k+1 ] 1 ] $intensite
         }
         #- Coordinate at reference pixel :
         #buf$audace(bufNo) delkwd "CRVAL1"
         buf$audace(bufNo) setkwd [ list "CRVAL1" $crval1 double "Wavelength at reference pixel" "angstrom" ]
         #- "Coordinate increment" "angstrom/pixel" :
         #buf$audace(bufNo) delkwd "CDELT1"
         buf$audace(bufNo) setkwd [ list "CDELT1" $pas double "Wavelength increment" "angstrom/pixel" ]
         if { [ lsearch $listemotsclef "CRPIX1" ]==-1 } {
            buf$audace(bufNo) setkwd [ list "CRPIX1" $crpix1 double "Reference pixel" "pixel" ]
         }
         buf$audace(bufNo) delkwd "SPC_A"
         buf$audace(bufNo) delkwd "SPC_B"
         buf$audace(bufNo) delkwd "SPC_C"
         if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
            buf$audace(bufNo) delkwd "SPC_D"
         }
         if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
            buf$audace(bufNo) delkwd "SPC_E"
         }
         if { [ lsearch $listemotsclef "SPC_DESC" ] !=-1 } {
            buf$audace(bufNo) delkwd "SPC_DESC"
         }
         buf$audace(bufNo) bitpix float
         buf$audace(bufNo) save "$audace(rep_images)/${filename}_linear"
         buf$audace(bufNo) bitpix short
         ::console::affiche_prompt "\nLoi de calibration linéaisée : $crval1+$pas*(x-$crpix1)\n"
         ::console::affiche_resultat "Le profil rééchantillonné linéairement sauvé sous ${filename}_linear\n"
         return "${filename}_linear"
      } else {
         ::console::affiche_resultat "Profil déjà linéarisé mais sauvé sous ${filename}_linear\n"
         #-- Bug : fichier original parfois efface dans les pipeline et spc_calibretelluric :
         file copy -force "$audace(rep_images)/$filename$conf(extension,defaut)" "$audace(rep_images)/${filename}_linear$conf(extension,defaut)"
         return "${filename}_linear"
      }
   } else {
      ::console::affiche_erreur "Usage: spc_linearcal nom_profil_raies\n"
   }
}
#***************************************************************************#



####################################################################
# Procédure de calibration a partir d'un spectre etalon
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 3-09-2006
# Date modification : 3-09-2006
# Arguments : profil_de_raies profil_de_raies_a_calibrer
####################################################################

proc spc_calibrelampe { args } {
    global conf
    global audace

    if { [llength $args] == 2 } {
        set spetalon [ lindex $args 0 ]
        set spacalibrer [ lindex $args 1 ]

        #--- Calcul du profil de raies du spectre étalon :
        set linecoords [ spc_detect $spcacalibrer ]
        set ysup [ expr int([ lindex $linecoords 0 ]+[ lindex $linecoords 1 ]) ]
        set yinf [ expr int([ lindex $linecoords 0 ]-[ lindex $linecoords 1 ]) ]
        buf$audace(bufNo) load "$audace(rep_images)/$spetalon"
        set intensite_fond [ lindex [ buf$audace(bufNo) stat ] 6 ]
        buf$audace(bufNo) imaseries "BINY y1=$yinf y2=$ysup height=1"
        buf$audace(bufNo) delkwd "NAXIS2"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${spetalon}_spc"
        buf$audace(bufNo) bitpix short

        #--- Détemination du centre de chaque raies détectées dans le spectre étalon :
        set listemax [ spc_findlines ${spetalon}_spc 20 ]
        #-- Algo : fait avancer de 10 pixels un fitgauss {x1 1 x2 1}, recupere le Xmax et centreX, puis tri selon Xmax et garde les 6 plus importants
        set nbraies [ llength $listemax ]

        #--- Calibration du spectre etalon ;
        #-- Algo : fait une premiere calibrae avec 2 raies, puis se sert de la loi pour associer une lambda aux autres raies (>=3) et fait une calibrtion polynomile si d'autres raies existent

        #--- Calibration du spectre à calibrer :
        if { $nbraies== 1 } {
            ::console::affiche_resultat "Pas assez de raies calibrer en longueur d'onde\n"
        } else {
            set fileout [ spc_calibreloifile $l{spetalon}_spc $spacalibrer ]
        }

        #--- Affichage des résultats :
        ::console::affiche_resultat "Le spectre calibré est sauvé sous $fileout\n"
        return $fileout
    } else {
       ::console::affiche_erreur "Usage: spc_calibrelampe profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#***************************************************************************#


##########################################################
# Affiche l'image du profil du néon de la bibliothèque
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 09-10-2007
# Date de mise à jour : 09-10-2007
# Arguments : aucun
##########################################################

proc spc_loadneon { args } {

   global spcaudace
   global conf

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set type_resolution [ lindex $args 0 ]
      set num_visu 1
   } elseif { $nbargs==2 } {
      set type_resolution [ lindex $args 0 ]
      set num_visu [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_loadneon type_resolution(hr/br/relco/sa/balmer) numero_visu(1,2)\n"
      return ""
   }

   #--- Creation d'une fenetre d'affichage si num_visu != 1 :
   if { $nbargs==2 && $num_visu!=1 } {
      set num_visu [ ::confVisu::create ]
   }

   #--- Affichage de l'image du neon de la bibliothèque de calibration :
   if { $type_resolution=="hr" } {
      #-- Haute resolution :
      # buf$num_visu load $spcaudace(rep_spccal)/Neon.jpg
      loadima $spcaudace(rep_spccal)/Neon.jpg $num_visu
      visu$num_visu zoom 1
      #::confVisu::setZoom 1 1
      ::confVisu::autovisu $num_visu
      visu$num_visu disp {251 -15}
   } elseif { $type_resolution=="br" } {
      #-- Affichage spécifique à la basse résolution :
      # set num_newvisu [ ::confVisu::create ]
      # buf$num_visu load $spcaudace(rep_spccal)/neon_br.png
      loadima $spcaudace(rep_spccal)/neon_br.png $num_visu
      visu$num_visu zoom 1
      ::confVisu::autovisu $num_visu
      visu$num_visu disp {251 -15}
   } elseif { $type_resolution=="relco" } {
      #-- Affichage spécifique à la basse résolution lampe Relco NeAr :
      # set num_newvisu [ ::confVisu::create ]
      # buf$num_visu load $spcaudace(rep_spccal)/neon_br.png
      loadima $spcaudace(rep_spccal)/near_relco.png $num_visu
      visu$num_visu zoom 1
      ::confVisu::autovisu $num_visu
      visu$num_visu disp {251 -15}
   } elseif { $type_resolution=="sa" } {
      #-- Star Analyser :
      ## buf$num_visu load $spcaudace(rep_spccal)/a2v_br_chimie.png
      # buf$num_visu load $spcaudace(rep_spccal)/regulus_sa.png
      loadima $spcaudace(rep_spccal)/regulus_sa.png $num_visu
      visu$num_visu zoom 1
      ::confVisu::autovisu $num_visu
      visu$num_visu disp {251 -15}
   } elseif { $type_resolution=="balmer" } {
      #-- Star Analyser :
      ## buf$num_visu load $spcaudace(rep_spccal)/a2v_br_chimie.png
      # buf$num_visu load $spcaudace(rep_spccal)/regulus_sa.png
      loadima $spcaudace(rep_spccal)/a2v_br_chimie.png $num_visu
      visu$num_visu zoom 1
      ::confVisu::autovisu $num_visu
      visu$num_visu disp {251 -15}
   }
}



##########################################################
# Effectue la calibration en longueur d'onde d'un spectre avec n raies et interface graphique
# Attention : GUI présente !
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 17-09-2006
# Date de mise à jour : 20-09-2006, 20160225
# Arguments : profil_lampe_calibration
# Retour : nom_du_fichier_calibre (sans extension)
##########################################################

proc spc_calibre { args } {

   global audace conf caption spcaudace
   #-- Variable globale spcalibre : nom de la variable retournee par la gui param_spc_audace_calibreprofil qui contient le nom du fichier de la lampe calibree
   global spcalibre

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set profiletalon [ file rootname [ lindex $args 0 ] ]
      set typeraie "e"
   } elseif { $nbargs==2 } {
      set profiletalon [ file rootname [ lindex $args 0 ] ]
      set typeraie [ lindex $args 1 ]
   } elseif { $nbargs==0 } {
      set typeraie "e"
      set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
      if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
         set profiletalon [ file rootname "$spctrouve" ]
      } else {
         ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer ?type_raie(a/e)?\n\n"
         return ""
      }
   } else {
      ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer ?type_raie(a/e)?\n\n"
      return ""
   }


   #--- Gestion des types de calibration (Relco, manu, lines_file...) :
   if { [ file exists "$audace(rep_images)/$spcaudace(fichier_raies)" ] } {
      set spcalibre [ spc_calibrefile "$profiletalon" "$spcaudace(fichier_raies)" $spcaudace(largeur_recherche_raie) ]
      return "$spcalibre"
   } else {      
      if { $spcaudace(flag_relcobr)=="o" } {
         set spcalibre [ spc_calibrerelco "$profiletalon" ]
         return "$spcalibre"
      } elseif { $spcaudace(flag_relcobr)=="n" } {
         #--- Affichage du profil de raies du spectre à calibrer :
         spc_gdeleteall
         spc_loadfit "$profiletalon"

         #--- Détection des raies dans le profil de raies de la lampe :
         #set raies [ spc_findbiglines "$profiletalon" $typeraie ]
         set raies [ spc_findbiglineslamp "$profiletalon" ]
         #foreach raie $raies {
         #   lappend listeabscisses [ lindex $raie 0 ]
         #}
         set listeabscisses_i $raies

         #--- Elaboration des listes de longueurs d'onde :
         set listelambdaschem [ spc_readchemfiles ]
         #::console::affiche_resultat "Chim : $listelambdaschem\n"
         set listeargs [ list $profiletalon $listeabscisses_i $listelambdaschem ]

         #--- Affichage du spectre modèle pour une aide à la calibration :
         #-- Basse résolution :
         if { $spcaudace(br) } {
            spc_loadneon "br" 2
            spc_loadneon "relco" 3
         } else {
            #-- Haute résolution :
            spc_loadneon "hr" 1
         }

         #--- Boîte de dialogue pour saisir les paramètres de calibration :
         set err [ catch {
            ::param_spc_audace_calibreprofil::run $listeargs
            tkwait window .param_spc_audace_calibreprofil
         } msg ]
         if {$err==1} {
            ::console::affiche_erreur "$msg\n"
         }


         #--- Effectue la calibration de la lampe spectrale :
         # set etaloncalibre [ spc_calibren $profiletalon $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]
         # NON : file delete "$audace(rep_images)/$profiletalon$conf(extension,defaut)"
         visu1 zoom 0.5
         #::confVisu::setZoom 0.5 0.5
         ::confVisu::autovisu 1

         if { $spcalibre != "" } {
            #-- Teste si la calibration est viable : pas de dispersion negative !
            buf$audace(bufNo) load "$audace(rep_images)/$spcalibre"
            set listemotsclef [ buf$audace(bufNo) getkwds ]
            if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
               set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
            } else {
               ::console::affiche_erreur "Le spectre n'est pas calibré\n"
               return ""
            }
            if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
               set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
            } else {
               ::console::affiche_erreur "Le spectre n'est pas calibré\n"
               return ""
            }
            if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
               set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
            } else {
               set spc_b 0.0
            }
            set spc_rms [ lindex [buf$audace(bufNo) getkwd "SPC_RMS"] 1 ]

            if { $cdelt1>0 && $crval1>=0 && $spc_b>=0.0 && $spc_rms<$spcaudace(rms_lim) } {
               set retour2 [ catch { ::confVisu::close 2 } ]
               set retour3 [ catch { ::confVisu::close 3 } ]
               loadima "$spcalibre"
               return "$spcalibre"
            } else {
               ::console::affiche_erreur "\nVous avez effectué une mauvaise calibration.\n"
               ##-- Boîte de dialogue pour REsaisir les paramètres de calibration :
               set fileout [ spc_calibre $profiletalon ]
            }
         } else {
            ::console::affiche_erreur "La calibration a échouée.\n"
            return ""
         }
      }
   }
}
#****************************************************************#


##########################################################
# CAlcul la resolution d'un spectre (prérablement sur un spectre de lampe de calibration)
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 07-04-2008
# Date de mise à jour : 07-04-2008, 27-12-2015
# Arguments : profil_lampe_calibration lambda_raie
##########################################################

proc spc_resolution { args } {

   global audace spcaudace
   global conf caption
   #set ecart [ expr 0.5*$spcaudace(largeur_raie_detect) ]

   if { [ llength $args ] == 2 } {
      set sp_name [ lindex $args 0 ]
      set lambda_raie [ lindex $args 1 ]

      #--- Linearise la calibration :
      set spcfile_linear [ spc_linearcal "$sp_name" ]

      #--- Teste si c'est haute ou basse resolution :
      set flag_br [ spc_testbr "$spcfile_linear" ]
      if { $flag_br } {
         set ecart [ expr 1*$spcaudace(largeur_raie_detect) ]
      } else {
         set ecart [ expr 3*$spcaudace(largeur_raie_detect) ]
      }
      
      #--- Récupère les informaitons du sptectre :
      buf$audace(bufNo) load "$audace(rep_images)/$spcfile_linear"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "SPC_XCLE" ] !=-1 } {
         set spc_xcle [ lindex [ buf$audace(bufNo) getkwd "SPC_XCLE" ] 1 ]
         set spc_xcri [ lindex [ buf$audace(bufNo) getkwd "SPC_XCRI" ] 1 ]
      } else {
         set spc_xcle 0
         set spc_xcri 0
      }
      set spc_xcle 0
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      } else {
         set cdelt1 1.
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      } else {
         set crval1 1.
      }
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
      } else {
         set crpix1 1
      }

      #--- Détermine les valeurs encadrants la raie :
      set lecart [ expr $ecart*$cdelt1 ]
      if { $spc_xcle==0 } {
         set x1 [ expr round(($lambda_raie-$lecart-$crval1)/$cdelt1 +$crpix1) ]
         set x2 [ expr round(($lambda_raie+$lecart-$crval1)/$cdelt1 +$crpix1) ]
      } else {
         set x1 $spc_xcle
         set x2 $spc_xcri
      }
      file delete -force "$audace(rep_images)/$spcfile_linear$conf(extension,defaut)"

      
      #--- Mesure la FWHM et le centre gaussien de la raie :
      set line_infos [ buf$audace(bufNo) fitgauss [ list $x1 1 $x2 1 ] ]
      set fwhm [ lindex $line_infos 2 ]
      #- set xcenter [ expr [ lindex $line_infos 1 ] -1 ]
      set xcenter [ lindex $line_infos 1 ]
      ::console::affiche_resultat "X1=$x1 ; x2=$x2 ; FWHM=$fwhm\n"
      
      #--- Calcul de la resolution :
      set frac_lambda [ expr $lambda_raie-int($lambda_raie) ]
      if { $frac_lambda==0 } {
         set lcenter [ spc_calpoly $xcenter $crpix1 $crval1 $cdelt1 0 0 ]
         set spc_res [ expr round($lcenter/($cdelt1*$fwhm)) ]
      } else {
         set lcenter $lambda_raie
         set spc_res [ expr round($lcenter/($cdelt1*$fwhm)) ]
      }

      #--- Traitement des résultats :
      buf$audace(bufNo) load "$audace(rep_images)/$sp_name"
      buf$audace(bufNo) setkwd [ list "SPC_RESP" $spc_res float "Power of resolution at wavelength SPC_RESL" "" ]
      buf$audace(bufNo) setkwd [ list "SPC_RESL" $lcenter double "Wavelength where power of resolution was measured" "angstrom" ]
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/$sp_name"
      buf$audace(bufNo) bitpix short
      ::console::affiche_resultat "\nLa résolution pour la raie $lcenter vaut : $spc_res\n"
      return $spc_res
   } else {
       ::console::affiche_erreur "Usage: spc_resolution profil_de_raies_calibre longueur_d_onde_raie\n\n"
   }
}
#****************************************************************#



##########################################################
# CAlcul la resolution d'un spectre de lampe de calibration en trouvant la raie la plus proche du centre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 22-10-200
# Date de mise à jour : 22-10-2009, 27-12-2015
# Arguments : profil_lampe_calibration
##########################################################

proc spc_bestresolution { args } {

   global audace spcaudace
   global conf caption

   if { [ llength $args ] == 1 } {
      set lampecalibree [ lindex $args 0 ]

      #--- Calcul la resolution du spectre à partir de la raie la plus brillante trouvée et proche du centre du capteur :
      ::console::affiche_resultat "\nCalcul la résolution du spectre...\n"
      # set lambda_raiemax [ lindex [ lindex [ spc_findbiglines $lampecalibree e ] 0 ] 0 ]
      set liste_raies [ spc_findbiglines $lampecalibree e ]
      #-- Selection les trois premiere raies les plus brillantes de la liste :
      set nbraies [ llength $liste_raies ]
      if { $nbraies >= 3 } {
         set liste_raies [ lrange $liste_raies 0 2 ]
      }

      #-- Recherhe de la raie la plus proche du centre, sinon prend la plus brillante :
      #- Reucpere les parametres du spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
      set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      } else {
         set cdelt1 1.
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      } else {
         set crval1 1.
      }

      #--- Determine la reslution pour chaque raies de calibration :
      set listeresol [ list ]
      foreach raie $liste_raies {
         set lambdaraie [ lindex $raie 0 ]
         if { $lambdaraie<=$crval1 } {
            continue
         } else {
            lappend listeresol [ list $lambdaraie [ spc_resolution $lampecalibree $lambdaraie ] ]
         }
      }

      #--- Determine la resolution maximale accessible :
      set bestresol [ lindex [ lsort -real -decreasing -index 1 $listeresol ] 0 ]
      set lambdabestres [ lindex $bestresol 0 ]

      #-- Calcul de la resolution et l'ecrit dans le header :
      set resolution [ spc_resolution $lampecalibree [ lindex $bestresol 0 ] ]
      ::console::affiche_resultat "\nLa meilleure résolution accessible vaut : $resolution à $lambdabestres A\n"
      return "$lampecalibree"
   } else {
       ::console::affiche_erreur "Usage: spc_bestresolution profil_lampe_calibree\n"
   }
}
#****************************************************************#



##########################################################
# CAlcul la resolution d'un spectre de lampe de calibration en trouvant la raie la plus proche du centre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 22-10-200
# Date de mise à jour : 22-10-2009, 27-12-2015
# Arguments : profil_lampe_calibration
##########################################################

proc spc_autoresolution { args } {

   global audace spcaudace
   global conf caption
   set lambdacal_min 3900

   if { [ llength $args ] == 1 } {
      set lampecalibree [ lindex $args 0 ]

      #--- Teste si basse resolution (recherche par spc_findcline) :
      set flag_br [ spc_testbr "$lampecalibree" ]
      
      #--- Calcul la resolution du spectre à partir de la raie la plus brillante trouvée et proche du centre du capteur :
      ::console::affiche_resultat "\nCalcul la résolution du spectre...\n"
      
      if { $flag_br==1 && 1==0 } {
         set lambda_raiemax [ spc_findcline "$lampecalibree" ]
      } else {
         #--- Reucpere les parametres du spectre :
         buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
         set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
            set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
         } else {
            set cdelt1 1.
         }
         if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
            set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
         } else {
            set crval1 1.
         }
         set lambda_max [ expr $crval1+$naxis1*$cdelt1 ]
         set lambda_cent [ expr ($lambda_max+$crval1)/2. ]

         #--- Recupere les raies utilises pour la calibration :
         if { [ lsearch $listemotsclef "SPC_LCAL" ] !=-1 } {
            #-- Haute resolution :
            set calibration_used [ lindex [ buf$audace(bufNo) getkwd "SPC_LCAL" ] 1 ]
            #set lines_used [ list ]
            #set i 0
            #foreach cused $calibration_used {
            #   if { [ expr {($i % 2) == 0} ] && $i!=0 } {
            #      lappend lines_used $cused
            #   }
            #   incr i
            #}
            #::console::affiche_resultat "Liste Used : $lines_used\n"
         } elseif { [ lsearch $listemotsclef "SPC_LCA1" ] !=-1 } {
            #-- Basse resolution :
            set lambda_cent [ expr ($lambda_max+$lambdacal_min)/2. ]
            set calibration_used [ list ]
            append calibration_used [ lindex [ buf$audace(bufNo) getkwd "SPC_LCA1" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_LCA2" ] !=-1 } {
               append calibration_used " [ lindex [buf$audace(bufNo) getkwd "SPC_LCA2"] 1 ]"
            }
            if { [ lsearch $listemotsclef "SPC_LCA3" ] !=-1 } {
               append calibration_used " [ lindex [buf$audace(bufNo) getkwd "SPC_LCA3"] 1 ]"
            }
            if { [ lsearch $listemotsclef "SPC_LCA4" ] !=-1 } {
               append calibration_used " [ lindex [buf$audace(bufNo) getkwd "SPC_LCA4"] 1 ]"
            }
            if { [ lsearch $listemotsclef "SPC_LCA5" ] !=-1 } {
               append calibration_used " [ lindex [buf$audace(bufNo) getkwd "SPC_LCA5"] 1 ]"
            }
         }
         # ::console::affiche_resultat "Calibration Used : $calibration_used\n"
         if { [ lsearch $listemotsclef "SPC_LCAD" ] !=-1 } {
            set lines_used [ list ]
            foreach cused $calibration_used {
               if { $cused>$lambdacal_min && $cused<$lambda_max } {
                  lappend lines_used $cused
               }
            }
            ::console::affiche_resultat "Liste Used : $lines_used\n"
         } else {
            set lines_used [ list ]
         }

         
         if { [ llength $lines_used ] !=0 } {
            #--- Recherche dans les raies utilisees pour la calibration :
            ::console::affiche_resultat "Utilisation des raies de calibration...\n"
            set liste_comp [ list ]
            set i 0
            foreach raie $lines_used {
               lappend liste_comp [ list [ expr abs($lambda_cent-[ lindex $raie 0 ]) ] $i ]
               incr i
            }
            set liste_comp [ lsort -real -increasing -index 0 $liste_comp ]
            set index_lproche [ lindex [ lindex $liste_comp 0 ] 1 ]
            set lambda_raiemax [ lindex [ lindex $lines_used $index_lproche ] 0 ]
         } else {
            #--- JAMAIS UTILISE SI CALIBRATION FAITE SOUS SPCAUDACE
            #--- Recherche de la raie la plus proche du centre sinon prend la plus brillante :
            # set lambda_raiemax [ lindex [ lindex [ spc_findbiglines $lampecalibree e ] 0 ] 0 ]
            set liste_raies [ spc_findbiglines $lampecalibree e ]
            #- Selection des raies dont I>=0.1*Imax et trie selon les abscisses :
            set liste_raies [ spc_selectstronglines $liste_raies ]

            set liste_comp [ list ]
            set i 0
            foreach raie $liste_raies {
               lappend liste_comp [ list [ expr abs($lambda_cent-[ lindex $raie 0 ]) ] $i ]
               incr i
            }
            ##::console::affiche_resultat "Avant tri: $liste_comp\n"
            ##::console::affiche_resultat "crval1=$crval1 ; cdelt1=$cdelt1 ; Lmax=$lambda_max ; Lc=$lambda_cent\n"
            set liste_comp [ lsort -real -increasing -index 0 $liste_comp ]
            set index_lproche [ lindex [ lindex $liste_comp 0 ] 1 ]
            ##::console::affiche_resultat "Index : $index_lproche ; Apres tri: $liste_comp\n"
            #- Prend la longueur d'onde de la raie la plus proche du centre, sinon la plus brillante :
            if { $index_lproche >= 4 } {
               #- Compare les intensites des deux raies les plus proches du centre et choisis la plus brillante :
               if { [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 1 ] >  [ lindex [ lindex $liste_raies $index_lproche ] 1 ] } {
                  set lambda_raiemax [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 0 ]
               } else {
                  set lambda_raiemax [ lindex [ lindex $liste_raies 0 ] 0 ]
               }
            } else {
               set lambda_raiemax [ lindex [ lindex $liste_raies $index_lproche ] 0 ]
            }

            #-- Verifie que la raie choisie n'est pas dans les 20% de chaque bords :
            set lblueedge [ expr $crval1*1.2 ]
            set lrededge [ expr $lambda_max*0.8 ]
            if { $lambda_raiemax<$lblueedge || $lambda_raiemax>$lrededge } {
               ::console::affiche_resultat "Nouvelle recherche plus loin des bords...\n"
               set lambda_raiemax [ lindex [ lindex $liste_raies [ expr $index_lproche+1 ] ] 0 ]
            }
         }
      }
      ::console::affiche_resultat "Longueur d'onde la plus proche du centre du CCD est : $lambda_raiemax A\n"
      
      #-- Calcul de la resolution et l'ecrit dans le header :
      set resolution [ spc_resolution $lampecalibree $lambda_raiemax ]
      ::console::affiche_resultat "\nLa résolution vaut $resolution à $lambda_raiemax A\n"
      return "$lampecalibree"
   } else {
       ::console::affiche_erreur "Usage: spc_autoresolution profil_lampe_calibreen\n"
   }
}
#****************************************************************#



##########################################################
# CAlcul la resolution d'un spectre de lampe de calibration en trouvant la raie la plus proche du centre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 14-09-2008
# Date de mise à jour : 14-09-2008
# Arguments : profil_lampe_calibration
##########################################################

proc spc_autoresolutionmid { args } {

   global audace spcaudace
   global conf caption

   if { [ llength $args ] == 1 } {
      set lampecalibree [ lindex $args 0 ]

      #--- Calcul la resolution du spectre à partir de la raie la plus brillante trouvée et proche du centre du capteur :
      ::console::affiche_resultat "\nCalcul la résolution du spectre...\n"
      # set lambda_raiemax [ lindex [ lindex [ spc_findbiglines $lampecalibree e ] 0 ] 0 ]
      set liste_raies [ spc_findbiglines $lampecalibree e ]

      #-- Recherhe de la raie la plus proche du centre, sinon prend la plus brillante :
      #- Reucpere les parametres du spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
      set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
         set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
      } else {
         set cdelt1 1.
      }
      if { [ lsearch $listemotsclef "CRVAL1" ] !=-1 } {
         set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
      } else {
         set crval1 1.
      }
      set lambda_max [ expr $crval1+$naxis1*$cdelt1 ]
      set lambda_cent [ expr ($lambda_max+$crval1)/2. ]
      #- Recherche de la raie la plus proche du centre :
      set liste_comp [ list ]
      set i 0
      foreach raie $liste_raies {
         lappend liste_comp [ list [ expr abs($lambda_cent-[ lindex $raie 0 ]) ] $i ]
         incr i
      }
      ##::console::affiche_resultat "Avant tri: $liste_comp\n"
      ##::console::affiche_resultat "crval1=$crval1 ; cdelt1=$cdelt1 ; Lmax=$lambda_max ; Lc=$lambda_cent\n"
      set liste_comp [ lsort -real -increasing -index 0 $liste_comp ]
      set index_lproche [ lindex [ lindex $liste_comp 0 ] 1 ]
      #::console::affiche_resultat "Index : $index_lproche ; Apres tri: $liste_comp\n"
      #- Prend la longueur d'onde de la raie la plus proche du centre, sinon la plus brillante :
      if { $index_lproche >= 4 } {
         #- Compare les intensites des deux raies les plus proches du centre et choisis la plus brillante :
         if { [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 1 ] >  [ lindex [ lindex $liste_raies $index_lproche ] 1 ] } {
            set lambda_raiemax [ lindex [ lindex $liste_raies [ lindex [ lindex $liste_comp 1 ] 1 ] ] 0 ]
         } else {
            set lambda_raiemax [ lindex [ lindex $liste_raies 0 ] 0 ]
         }
      } else {
         set lambda_raiemax [ lindex [ lindex $liste_raies $index_lproche ] 0 ]
      }
      ::console::affiche_resultat "Longueur d'onde la plus proche du centre du CCD est : $lambda_raiemax\n"

      #-- Calcul de la resolution et l'ecrit dans le header :
      set resolution [ spc_resolution $lampecalibree $lambda_raiemax ]
      return "$lampecalibree"
   } else {
       ::console::affiche_erreur "Usage: spc_autoresolutionmid profil_de_raies_lampe\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction de calcul du RMS d'un calibration
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-09-2007
# Date modification : 12-09-2007
# Arguments : nom_profil_raies ?largeur_raie? ?liste_raies_ayant_serivies_a_la_calibration?
####################################################################

proc spc_caloverif { args } {
    global conf
    global audace spcaudace
    #-- Marge a partir du bord ou sont prises en compte les raies :
    set marge_bord 2.5
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.5
    # GOOD : set ecart 1.0
    #set ecart 1.2
    #set erreur 0.01

    set nbargs [ llength $args ]
    if { $nbargs <= 3 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur_raie [expr 2.0*$spcaudace(dlargeur_eau) ]
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur_raie [ lindex $args 1 ]
        } elseif { $nbargs == 3 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur_raie [ lindex $args 1 ]
            set listeraieseau [ lindex $args 2 ]
        } else {
            ::console::affiche_erreur "Usage: spc_caloverif nom_profil_de_raies ?largeur_raie (A)? ?liste_raies_référence?\n"
            return ""
        }
        set ecart [ expr $largeur_raie/2. ]

        #--- Gestion des profils selon loi de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
           set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
        } else {
           set crpix1 1
        }
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
            if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
                set spc_e [ lindex [ buf$audace(bufNo) getkwd "SPC_E" ] 1 ]
            } else {
                set spc_e 0.
            }
            set lmin_spectre [ spc_calpoly 1.0 $crpix1 $spc_a $spc_b $spc_c $spc_d $spc_e ]
            set lmax_spectre [ spc_calpoly $naxis1 $crpix1 $spc_a $spc_b $spc_c $spc_d $spc_e ]
        } else {
            set flag_spccal 0
            #- set lmin_spectre $crval1
            set lmin_spectre [ spc_calpoly 1.0 $crpix1 $crval1 $cdelt1 0 0 ]
            set lmax_spectre [ spc_calpoly $naxis1 $crpix1 $crval1 $cdelt1 0 0 ]
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


        #--- Charge la liste des raies de l'eau :
        if { $nbargs <= 2 } {
            set listeraieseau [ list ]
            set file_id [ open "$spcaudace(filetelluric)" r ]
            set contents [ split [ read $file_id ] \n ]
            close $file_id
            set nbraiesbib 0
            foreach ligne $contents {
                lappend listeraieseau [ lindex $ligne 1 ]
                incr nbraiesbib
            }
            set nbraiesbib [ expr $nbraiesbib-2 ]
            set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
            set lmin_bib [ lindex $listeraieseau 0 ]
            set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        } else {
            set nbraiesbib [ llength $listeraieseau ]
            set lmin_bib [ lindex $listeraieseau 0 ]
            set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        }
        # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
        # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


        #--- Creée la liste de travail des raies de l'eau pour le spectre :
        if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
            #-- Recherche la longueur minimum des raies raies telluriques utilisables (2.5 A) :
            set index_min 0
            foreach raieo $listeraieseau {
                if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
                    break
                } else {
                    incr index_min
                }
            }
            # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
            #-- Recherche la longueur maximum des raies raies telluriques utilisables (2.5 A) :
            set index_max $nbraiesbib
            for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
                if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
                    break
                }
            }
            # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
            #-- Liste des raies telluriques utilisables :
            #- Enleve une raie sur chaque bords : 070910
            # set index_min [ expr $index_min+1 ]
            # set index_max [ expr $index_max-1 ]
            set listeraies [ lrange $listeraieseau $index_min $index_max ]
            ::console::affiche_resultat "Liste raies de référence : $listeraies\n"
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }

        #--- Calculs les paramètres de la qualité de la calibration par rapport aux raies de la liste :
        #set cal_infos [ spc_rms "${filename}_conti" $listeraies $largeur_raie ]
        set cal_infos [ spc_rms "$filename" $listeraies $largeur_raie ]
        set chi2 [ lindex $cal_infos 0 ]
        set rms  [ lindex $cal_infos 1 ]
        set mean_shift [ lindex $cal_infos 2 ]

        #--- Traitement des résultats :
        ::console::affiche_resultat "\n\nQualité de la calibration :\nChi2=$chi2\nRMS=$rms A\nEcart moyen=$mean_shift A\n"
       #-- Maj du mot clef SPC_RMSO :
       buf$audace(bufNo) load "$audace(rep_images)/$filename"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_RMSO" ] !=-1 } {
          set spcrmso [ lindex [ buf$audace(bufNo) getkwd "SPC_RMSO" ] 1 ]
          if { $rms<$spcrmso } {
             buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms double "RMS measured from telluric lines" "angstrom" ]
             buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift double "Mean shift from tellruic lines" "angstrom" ]
             buf$audace(bufNo) bitpix float
             buf$audace(bufNo) save "$audace(rep_images)/$filename"
             buf$audace(bufNo) bitpix short
             ::console::affiche_resultat "\nRMSO de $filename mis à jour.\n"
          } else {
             ::console::affiche_resultat "\nRMSO de $filename inchangé.\n"
          }
       } else {
          buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms double "RMS measured from telluric lines" "angstrom" ]
          buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift double "Mean shift from tellruic lines" "angstrom" ]
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/$filename"
          buf$audace(bufNo) bitpix short
          ::console::affiche_resultat "\nRMSO de $filename mis à jour.\n"
       }
       return $cal_infos
   } else {
       ::console::affiche_erreur "Usage: spc_caloverif profil_de_raies_a_calibrer ?largeur_raie (A)? ?liste_raies_référence?\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction de calcul du RMS d'un calibration
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 9-09-2007
# Date modification : 9-09-2007
# Arguments : nom_profil_raies liste_raies_ayant_serivies_a_la_calibration largeur_raie
# Exemple : spc_rms spectre_1200t { 6532.359 6543.907 6552.629 6572.072 6574.847 6580.786 6594.361 6599.325 6612.540 }
#
####################################################################

proc spc_rms { args } {
   global conf
   global audace spcaudace
   # set pas 10
   #-- Demi-largeur de recherche des raies telluriques (Angstroms)
   #set ecart 4.0
   #set ecart 1.5
   ### modif michel
   set ecart spcaudace(dlargeur_eau)
   # GOOD : set ecart 1.0
   #set ecart 1.2
   #set erreur 0.01
   #-- Largeur du filtre SaveGol : 28
   set largeur $spcaudace(largeur_savgol)

   set nbargs [ llength $args ]
   if { $nbargs <= 3 } {
      if { $nbargs == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set listeraies [ lindex $args 1 ]
         set largeur_raie [ expr 2.0*$spcaudace(dlargeur_eau) ]
      } elseif { $nbargs == 3 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set listeraies [ lindex $args 1 ]
         set largeur_raie [ lindex $args 2 ]
      } else {
         ::console::affiche_erreur "Usage: spc_rms nom_profil_de_raies liste_raies_référence ?largeur_raie (A)?\n"
         return ""
      }
      set ecart [ expr $largeur_raie/2. ]

      #--- Extrait les mots clef utiles :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      #- Cas non-lineaire :
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix1 1
      }
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         set flag_spccal 1
         set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
         set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
         set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
         if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
            set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
         } else {
            set spc_d 0.
         }
         if { [ lsearch $listemotsclef "SPC_E" ] !=-1 } {
            set spc_e [ lindex [ buf$audace(bufNo) getkwd "SPC_E" ] 1 ]
         } else {
            set spc_e 0.
         }
      } else {
         #- Cas linéaire :
         set flag_spccal 0
      }


      #--- Filtrage pour isoler le continuum :
      #-- Retire les petites raies qui seraient des pixels chauds ou autre :
      #- buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
      set ffiltered [ spc_smoothsg "$filename" $largeur ]
      set fcont1 [ spc_div "$filename" "$ffiltered" ]
      #-- Inversion et mise a 0 du niveau moyen :
      buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
      set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
      buf$audace(bufNo) mult -1.0
      buf$audace(bufNo) offset $icontinuum
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
      buf$audace(bufNo) bitpix short


      #--- Détermine la longueur d'onde centrale des raies ayant servies à la calibration :
      #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
      ### modif michel
      ### set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]

      set listelmesurees [ list ]
      #set liste_ecart [ list ]
      #- Différence moyenne :
      set sum_diff 0.
      #- Différence moyenne au carré :
      set sum_diffsq 0.
      #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
      #buf$audace(bufNo) load "$audace(rep_images)/$filename"
      foreach lambda_cat $listeraies {
         if { $flag_spccal } {
            set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lambda_cat-$ecart))*$spc_c))/(2*$spc_c)+$crpix1) ]
            set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($lambda_cat+$ecart))*$spc_c))/(2*$spc_c)+$crpix1) ]
            set coords [ list $x1 1 $x2 1 ]
            #-- Meth 1 : centre de gravité
            ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #-- Meth 2 : centre gaussien
            set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
            #-- Meth 3 : centre moyen de gravité
            #set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #buf$audace(bufNo) mult -1.0
            #set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #buf$audace(bufNo) mult -1.0
            #set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
            #::console::affiche_resultat "$xc1, $xc2, $xcenter\n"
            set lambda_mes [ spc_calpoly $xcenter $crpix1 $spc_a $spc_b $spc_c $spc_d $spc_e ]
            set ldiff    [ expr $lambda_mes-$lambda_cat ]
            set sum_diff [ expr $sum_diff+$ldiff ]
            set sum_diffsq [ expr $sum_diffsq+pow($ldiff,2) ]
            lappend listelmesurees $lambda_mes
            lappend liste_ecart $ldiff
         } else {
            ### modif michel
            ### set x1 [ expr round(($lambda_cat-$ecart-$crval1)/$cdelt1) ]
            set x1 [ expr round(($lambda_cat-$ecart-$crval1)/$cdelt1+$crpix1) ]
            set x2 [ expr round(($lambda_cat+$ecart-$crval1)/$cdelt1+$crpix1) ]
            set coords [ list $x1 1 $x2 1 ]
            #-- Meth 1 : centre de gravité
            #set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #-- Meth 2 : centre gaussien
            set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
            #-- Meth 3 : centre moyen de gravité
            #set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #buf$audace(bufNo) mult -1.0
            #set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #buf$audace(bufNo) mult -1.0
            #set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
            #::console::affiche_resultat "$xc1, $xc2, $xcenter\n"
            set lambda_mes [ spc_calpoly $xcenter $crpix1 $crval1 $cdelt1 0 0 ]
            set ldiff    [ expr $lambda_mes-$lambda_cat ]
            set sum_diff [ expr $sum_diff+$ldiff ]
            set sum_diffsq [ expr $sum_diffsq+pow($ldiff,2) ]
            lappend listelmesurees $lambda_mes
            lappend liste_ecart $ldiff
         }
         ### modif michel
         # lappend errors $mes_incertitude
      }
      #::console::affiche_resultat "Liste des raies de référence :\n$listeraies\n"
      ::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
      ::console::affiche_resultat "Liste des écarts :\n$liste_ecart\n"

      #--- Calcul du RMS et ecart-type :
      set nbraies [ llength $listeraies ]
      set chi2 [ expr $sum_diffsq/($nbraies*pow($cdelt1,2)) ]
      #-- Multiplication de la valeur du RMS par CRDELT pour donner artificiellement une valeur qui est comparable à celle affichée par les autres logiciels amateurs, mais reste proportionnelle au RMS. Le RMS reste un indicateur, qui permet de comparer des spectres avec spc_rms.
      set rms1 [ expr sqrt($sum_diffsq/$nbraies) ]
      #- set rms [ expr $cdelt1*sqrt($sum_diffsq/$nbraies) ]
      set rms [ expr sqrt($sum_diffsq/$nbraies) ]
      set mean_shift [ expr $sum_diff/$nbraies ]
      set rmse [ expr sqrt(($sum_diffsq/$nbraies-pow($mean_shift,2))/$nbraies) ]

      #--- Traitement des résultats :
      #-- Effacement des fichiers temporaires :
      file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"
      ::console::affiche_resultat "Chi2=$chi2 ; RMS=$rms ; Ecart moyen=$mean_shift ; RMSE=$rmse ; RMS1=$rms1\n"
      set cal_infos [ list $chi2 $rms $mean_shift ]
      return $cal_infos
   } else {
      ::console::affiche_erreur "Usage: spc_rms profil_de_raies_a_calibrer liste_raies_référence  ?largeur_raie (A)?\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction d'étalonnage à partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-09-2007
# Date modification : 12-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_calibretelluric { args } {
   global conf
   global audace spcaudace
   # set pas 10
   #-- Demi-largeur de recherche des raies telluriques (Angstroms)
   #set ecart 4.0
   #set ecart 1.2
   #set ecart 1.5
   # set ecart 1.0
   set ecart $spcaudace(dlargeur_eau)
   set marge_bord 2.5
   #set erreur 0.01

   #--- Rappels des raies pour resneignements :
   #-- Liste C.Buil :
   ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
   ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
   # GOOD : set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
   #-- Liste ESO-Pollman :
   ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
   #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
   ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

   set nbargs [ llength $args ]
   if { $nbargs <= 2 } {
      if { $nbargs == 1 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set largeur $spcaudace(largeur_savgol)
      } elseif { $nbargs == 2 } {
         set filename [ file rootname [ lindex $args 0 ] ]
         set largeur [ lindex $args 1 ]
      } else {
         ::console::affiche_erreur "Usage: spc_calibretelluric profil_de_raies_a_calibrer ?largeur_raie_pixels (28)?\n"
         return ""
      }

      #--- Gestion des profils selon la loi de calibration :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      #-- Renseigne sur les parametres de l'image :
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
         set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
      } else {
         set crpix1 1
      }
      #- Cas non-lineaire :
      if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
         set flag_spccal 1
         set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
         set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
         set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
         if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
            set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
         } else {
            set spc_d 0.
         }
         set lmin_spectre [ spc_calpoly 1.0 $crpix1 $spc_a $spc_b $spc_c $spc_d ]
         set lmax_spectre [ spc_calpoly $naxis1 $crpix1 $spc_a $spc_b $spc_c $spc_d ]
      } else {
         set flag_spccal 0
         #- set lmin_spectre $crval1
         set lmin_spectre [ spc_calpoly 1.0 $crpix1 $crval1 $cdelt1 0 0 ]
         set lmax_spectre [ spc_calpoly $naxis1 $crpix1 $crval1 $cdelt1 0 0 ]
      }
      #-- Memorise le RMS de calibration avec la lampe dans SPC_RMSL :
      if { [ lsearch $listemotsclef "SPC_RMS" ] != -1 } {
         set rms_ini [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 1 ]
         set rms_orig [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 3 ]
         if { [ lsearch $listemotsclef "SPC_RMSL" ] == -1 } {
            buf$audace(bufNo) setkwd [ list "SPC_RMSL" $rms_ini double "RMS measured from calibration lamp" "angstrom" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/$filename"
            #buf$audace(bufNo) bitpix short
         }
      }
      
      
      #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :

      ### modif michel (mes_incertitude avait une valeur beaucoup trop elevee)
      set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


      #--- Charge la liste des raies de l'eau :
      set file_id [ open "$spcaudace(filetelluric)" r ]
      set contents [ split [ read $file_id ] \n ]
      close $file_id
      set nbraiesbib 0
      foreach ligne $contents {
         lappend listeraieseau [ lindex $ligne 1 ]
         incr nbraiesbib
      }
      set nbraiesbib [ expr $nbraiesbib-2 ]
      set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
      set lmin_bib [ lindex $listeraieseau 0 ]
      set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
      # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
      # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


      #--- Creée la liste de travail des raies de l'eau pour le spectre :
      if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
         #-- Recherche la longueur minimum des raies raies telluriques utilisables (2 A) :
         set index_min 0
         foreach raieo $listeraieseau {
            if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
               break
            } else {
               incr index_min
            }
         }
         # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
         #-- Recherche la longueur maximum des raies raies telluriques utilisables (2 A) :
         set index_max $nbraiesbib
         for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
            if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
               break
            }
         }
         # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
         #-- Liste des raies telluriques utilisables :
         #- Enleve une raie sur chaque bords : 070910
         # set index_min [ expr $index_min+1 ]
         # set index_max [ expr $index_max-1 ]
         set listeraies [ lrange $listeraieseau $index_min $index_max ]
         # ::console::affiche_resultat "$listeraies\n"
      } else {
         ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
         return "$filename"
      }


      #--- Filtrage pour isoler le continuum :
      #-- Retire les petites raies qui seraient des pixels chauds ou autre :
      #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
      set ffiltered [ spc_smoothsg $filename $largeur ]
      set fcont1 [ spc_div $filename $ffiltered ]

      #--- Inversion et mise a 0 du niveau moyen :
      buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
      set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
      buf$audace(bufNo) mult -1.0
      buf$audace(bufNo) offset $icontinuum
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
      buf$audace(bufNo) bitpix short

      #--- Recherche des raies telluriques en absorption :
      ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
      #set pas [ expr int($largeur/2) ]
      #buf$audace(bufNo) scale {1 3} 1
      #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
      #buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set nbraies [ llength $listeraies ]
      set listexraies [list ]
      set listexmesures [list ]
      set listelmesurees [list ]
      set listeldiff [list ]

      if { $flag_spccal } {
         foreach raie $listeraies {
            set x  [ expr (-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie))*$spc_c))/(2*$spc_c)+$crpix1 ]
            set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)+$crpix1) ]
            set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)+$crpix1) ]
            set coords [ list $x1 1 $x2 1 ]
            #-- Meth 1 : centre de gravité
            ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #-- Meth 2 : centre gaussien
            set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
            #-- Meth 3 : centre moyen de gravité
            # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            # buf$audace(bufNo) mult -1.0
            # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            # buf$audace(bufNo) mult -1.0
            # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
            #-- set lambda_mes [ expr ($xcenter -1)*$cdelt1+$crval1 ]
            set lambda_mes [ spc_calpoly $xcenter $crpix1 $spc_a $spc_b $spc_c $spc_d ]
            set ldiff [ expr $lambda_mes-$raie ]
            lappend listexraies $x
            lappend listexmesures $xcenter
            lappend listelmesurees $lambda_mes
            lappend listeldiff $ldiff
            lappend errors $mes_incertitude
         }
      } else {
         foreach raie $listeraies {
            set x  [ expr ($raie-$crval1)/$cdelt1+$crpix1 ]
            set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1+$crpix1) ]
            set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1+$crpix1) ]
            set coords [ list $x1 1 $x2 1 ]
            #-- Meth 1 : centre de gravité
            ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            #-- Meth 2 : centre gaussien
            set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
            #-- Meth 3 : centre moyen de gravité
            # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            # buf$audace(bufNo) mult -1.0
            # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
            # buf$audace(bufNo) mult -1.0
            # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
            set lambda_mes [ spc_calpoly $xcenter $crpix1 $crval1 $cdelt1 0 0 ]
            set ldiff [ expr $lambda_mes-$raie ]
            lappend listexraies    $x
            lappend listexmesures  $xcenter
            lappend listelmesurees $lambda_mes
            lappend listeldiff     $ldiff
            lappend errors $mes_incertitude
         }
      }


      ::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
      ::console::affiche_resultat "Liste des x mesures :\n$listexmesures\n"
      ::console::affiche_resultat "Liste des raies du catalogue :\n$listeraies\n"
      ::console::affiche_resultat "Liste des x du catalogue :\n$listexraies\n"

      #--- Effacement des fichiers temporaires :
      file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
      file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"


      #--- Ajout de la methode 4 pour les KAF400+Lhires3 2400 g/mm :
      buf$audace(bufNo) load "$audace(rep_images)/$filename"
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set lambda_fin [ spc_calpoly $naxis1 $crpix1 $crval1 $cdelt1 0 0 ]
      set bande [ expr $lambda_fin-$crval1 ]
      if { $bande<=100. && $cdelt1<=.2 } {
         set flag_kaf400 1
         set nbmeths [ llength $spcaudace(calo_meths) ]
         set spcaudace(calo_meths) [ linsert $spcaudace(calo_meths) $nbmeths 4 ]
      } else {
         set flag_kaf400 0
      }


      #--- Methode 1 : spectre initial linéaire :
      ::console::affiche_resultat "============ 1) spectre initial linéaire ================\n"
      set spectre_linear [ spc_linearcal "$filename" ]
      set infos_cal [ spc_rms "$spectre_linear" $listeraies ]
      set rms_initial [ lindex $infos_cal 1 ]
      set mean_shift_initial [ lindex $infos_cal 2 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set cdelt1_initial $cdelt1
      set crval1_initial $crval1
      ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


       #--- Methode 2 : origine decalee du decalage moyen
       if { [ lsearch $spcaudace(calo_meths) 2 ] != -1 } {
          ::console::affiche_resultat "============ 2) Décalage du SHIFT du spectre inital linéarisé ================\n"
          set spectre_lindec [ spc_calibredecal "$spectre_linear" [ expr -1.0*$mean_shift_initial ] ]
          #- set spectre_lindec [ spc_calibredecal "$spectre_linear" [ expr -1.*$mean_shift_initial ] ]
          set infos_cal [ spc_rms "$spectre_lindec" $listeraies ]
          set rms_lindec [ lindex $infos_cal 1 ]
          set mean_shift_lindec [ lindex $infos_cal 2 ]
          file rename -force "$audace(rep_images)/$spectre_lindec$conf(extension,defaut)" "$audace(rep_images)/${filename}_mshiftdec$conf(extension,defaut)"
          set spectre_lindec "${filename}_mshiftdec"
       }


       #--- Methode 5 : Décalage du spectre inital linéarisé de la valeur du RMS :
       if { [ lsearch $spcaudace(calo_meths) 5 ] != -1 } {
          ::console::affiche_resultat "============ 5) Décalage de RMS du spectre inital linéarisé ================\n"
          #set rms_decalage [ expr $rms_initial/$cdelt1_initial/2. ]
          set rms_decalage [ expr $rms_initial/$cdelt1_initial ]
          if { $mean_shift_initial > 0. } {
             set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" [ expr -1.0*$rms_decalage ] ]
          } else {
             set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" $rms_decalage ]
          }
          set infos_cal [ spc_rms "$spectre_lindec_rms" $listeraies ]
          set rms_lindec_rms [ lindex $infos_cal 1 ]
          set mean_shift_lindec_rms [ lindex $infos_cal 2 ]
          file rename -force "$audace(rep_images)/$spectre_lindec_rms$conf(extension,defaut)" "$audace(rep_images)/${filename}_rmsdec$conf(extension,defaut)"
          set spectre_lindec_rms "${filename}_rmsdec"
       }


       #--- Methode 6 : Décalage du spectre inital linéarisé de la valeur du RMS :
       if { [ lsearch $spcaudace(calo_meths) 6 ] != -1 } {
          ::console::affiche_resultat "============ 7) Décalage de 0.5RMS du spectre inital linéarisé ================\n"
          set rms_decalage [ expr $rms_initial/$cdelt1_initial/2. ]
          if { $mean_shift_initial > 0. } {
             set spectre_lindec_drms [ spc_calibredecal "$spectre_linear" [ expr -1.0*$rms_decalage ] ]
          } else {
             set spectre_lindec_drms [ spc_calibredecal "$spectre_linear" $rms_decalage ]
          }
          set infos_cal [ spc_rms "$spectre_lindec_drms" $listeraies ]
          set drms_dec [ lindex $infos_cal 1 ]
          set mean_shift_drms [ lindex $infos_cal 2 ]
          file rename -force "$audace(rep_images)/$spectre_lindec_drms$conf(extension,defaut)" "$audace(rep_images)/${filename}_drmsdec$conf(extension,defaut)"
          set spectre_lindec_drms "${filename}_drmsdec"
       }


       #--- Methode 3 : callibration avec les raies telluriques :
       #- PAS BON : les intensites ne sont pas reinterpollees avec la nouvelle calibration deg3.
       if { [ lsearch $spcaudace(calo_meths) 3 ] != -1 } {
          ::console::affiche_resultat "============ 3) calibration sur l'eau ================\n"
          #-- Ajustement polynomial de degre 3 :
          set sortie [ spc_ajustdeg3 $listexmesures $listeraies $errors $crpix1 ]
          set coeffs [ lindex $sortie 0 ]
          set d [ lindex $coeffs 3 ]
          set c [ lindex $coeffs 2 ]
          set b [ lindex $coeffs 1 ]
          set a [ lindex $coeffs 0 ]
          set chi2 [ lindex $sortie 1 ]
          set covar [ lindex $sortie 2 ]
          set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
          #-- Sauvegarde le spectre calibré non-linéairement :
          buf$audace(bufNo) load "$audace(rep_images)/$filename"
          buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
          buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
          buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
          buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
          buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
          buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "Wavelength RMS updated" "angstrom"]
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocalnl"
          buf$audace(bufNo) bitpix short
          #-- Recalage de la calibration grace aux raies telluriques :
          #- Rééchantillonnage pour obtenir une loi de calibration linéaire :
          set spectre_ocallin [ spc_linearcal "${filename}-ocalnl" ]
          #- Calcul de décalage moyen+rms :
          set mean_shift [ lindex [ spc_rms "$spectre_ocallin" $listeraies ] 2 ]
          #- Réalise le décalage sur la loi linéaire :
          set spectre_ocalshifted [ spc_calibredecal "$spectre_ocallin" [ expr -1.*$mean_shift ] ]
          #- Calcul le décalage moyen+rms du spectre final :
          # set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies 1.5 ]
          set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies ]
          set rms_calo [ lindex $infos_cal 1 ]
          set mean_shift_calo [ lindex $infos_cal 2 ]
          #- Effacement des fichiers temporaires :
          file rename -force "$audace(rep_images)/$spectre_ocalshifted$conf(extension,defaut)" "$audace(rep_images)/${filename}_caloshift$conf(extension,defaut)"
          set spectre_ocalshifted "${filename}_caloshift"
          if { $spectre_ocallin != "${filename}-ocalnl" } {
             file delete -force "$audace(rep_images)/${filename}-ocalnl$conf(extension,defaut)"
          }
          file delete -force "$audace(rep_images)/$spectre_ocallin$conf(extension,defaut)"
       }


       #--- Methode 4 : callibration 2 avec les raies telluriques
       if { [ lsearch $spcaudace(calo_meths) 4 ] != -1 } {
          ::console::affiche_resultat "============ 4) calibration sur l'eau bis ================\n"
          #-- Calcul du polynôme de calibration xlin = a+bx+cx^2+dx^3
          ### spc_calibretelluric 94-bet-leo--profil-traite-final.fit
          set sortie [ spc_ajustdeg2 $listexmesures $listexraies $errors $crpix1 ]
          # set sortie [ spc_ajustdeg3 $listexmesures $listexraies $errors ]
          set coeffs [ lindex $sortie 0 ]
          # set d [ lindex $coeffs 3 ]
          set d 0.0
          set c [ lindex $coeffs 2 ]
          set b [ lindex $coeffs 1 ]
          set a [ lindex $coeffs 0 ]
          set chi2 [ lindex $sortie 1 ]
          set covar [ lindex $sortie 2 ]
          set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]

          #-- je charge l'image calibree avec le neon :
          buf$audace(bufNo) load "$audace(rep_images)/$filename"
          set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
          set crpix1 [lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1]
          #-- je calcule les x linearises
          set listexlin [list]
          foreach x $listexmesures {
             lappend listexlin [ spc_calpoly $x $crpix1 $a $b $c $d ]
          }

          #-- Rééchantillonnage pour obtenir une loi de calibration linéaire :
          set xorigin [list ]
          set xlinear [list ]
          set intensites [list ]
          for {set x 1 } {$x<=$naxis1} {incr x} {
             lappend xorigin $x
             lappend xlinear [ spc_calpoly $x $crpix1 $a $b $c $d ]
             lappend intensities [lindex [ buf$audace(bufNo) getpix [list $x 1] ] 1]
          }
          set newIntensities [ lindex [ spc_spline $xlinear $intensities $xorigin n ] 1 ]
          for {set x 0 } {$x<$naxis1} {incr x} {
             buf$audace(bufNo) setpix [ list [expr $x +1] 1 ] [lindex $newIntensities $x]
          }
          #-- je calcule les coefficients de la droite moyenne lambda=f(xlin) :
          #set sortie [ spc_ajustdeg1hp $listexlin $listeraies $errors ]
          set sortie [ spc_ajustdeg1hp $listexlin $listeraies $errors $crpix1 ]
          #- lambda0 : lambda pour x=0
          set lambda0 [lindex [ lindex $sortie 0 ] 0]
          set cdelt1 [lindex [ lindex $sortie 0 ] 1]
          #- crval1 : lambda pour x=crpix1
          #-set crval1 [expr $lambda0 + $cdelt1]
          set crval1 [ spc_calpoly $crpix1 $crpix1 $lambda0 $cdelt1 0 0 ]
          #-- Sauve les mots clef :
          buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 double "" "angstrom" ]
          buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1 double "" "angstrom/pixel" ]
          set listemotsclef [ buf$audace(bufNo) getkwds ]
          if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
             buf$audace(bufNo) delkwd "SPC_A"
             buf$audace(bufNo) delkwd "SPC_B"
             buf$audace(bufNo) delkwd "SPC_C"
             if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
		buf$audace(bufNo) delkwd "SPC_D"
             }
          }
          #-- j'enregistre l'image :
          set spectre_ocallinbis "${filename}_caloshift2"
          buf$audace(bufNo) bitpix float
          buf$audace(bufNo) save "$audace(rep_images)/$spectre_ocallinbis"
          buf$audace(bufNo) bitpix short
          #-- Calcul le décalage moyen+rms du spectre final :
          set infos_cal   [ spc_rms $spectre_ocallinbis $listeraies ]
          set rms_calobis [ lindex $infos_cal 1 ]
          set mean_shift_calobis [ lindex $infos_cal 2 ]
          ::console::affiche_resultat "Loi de calibration lineaire calobis : $crval1+$cdelt1*x\n"
       }


       #--- Methode 8 : calibration avec les raies telluriques derivee de 4
       if { [ lsearch $spcaudace(calo_meths) 8 ] != -1 } {
          ::console::affiche_resultat "============ 8) calibration sur l'eau 100% ================\n"
          #-- Construction liste pour la calibrtion sur raies tellu catalogue :
          set liste_couples ""
          foreach xmes $listexmesures lcat $listeraies {
             append liste_couples "$xmes $lcat "
          }

          #-- Caliberation avec raies catalogue et positions mesurees :
          set profil_noncal [ spc_delcal "$filename" ]
          #set profil_calibre [ spc_calibren $liste_couples ]
          set chaine_commande "spc_calibren $profil_noncal $liste_couples"
          set profil_calibre [ eval [ format $chaine_commande ] ]
          set profil_modele [ spc_linearcal "$profil_calibre" ]

          #--- Reechantillonnage des intensites :
          #set profil_reech [ spc_echant "$filename" "$profil_modele" ]
          ##set new_intensities [ lindex  [ spc_spline $xvals $yvals $lambdas n ] 1 ]
          ##set new_intensities [ lindex [ spc_resample $xvals $yvals $pas $lambda_deb ] 1 ]


          #-- j'enregistre l'image :
          file delete -force "$audace(rep_images)/$profil_calibre$conf(extension,defaut)"
          file delete -force "$audace(rep_images)/$profil_noncal$conf(extension,defaut)"
          file rename -force "$audace(rep_images)/$profil_modele$conf(extension,defaut)" "$audace(rep_images)/${filename}_calopure$conf(extension,defaut)"
          #-- Calcul le décalage moyen+rms du spectre final :
          set infos_cal [ spc_rms "${filename}_calopure" $listeraies ]
          set rms_calopure [ lindex $infos_cal 1 ]
          set mean_shift_calopure [ lindex $infos_cal 2 ]
          ::console::affiche_resultat "Qualité de calibration calopure : RMS=$rms_calopure ; MEAN_DEC=$mean_shift_calopure\n"
       }
      

       #--- Methode 7 : callibration avec les raies telluriques :
       if { [ lsearch $spcaudace(calo_meths) 7 ] != -1 } {
          ::console::affiche_resultat "====== 7) Recalage progressif par iterations ====\n"
          set nb_iteration 0
          set dl 0.01
          set rms_dec1 [ expr $rms_initial+$dl ]
          set tdl $dl
          set tdl_max [ expr 2.*abs($mean_shift_initial) ]
          if { $mean_shift_initial > 0 } { set signe "-" } else { set signe "" }
          set spectre_decini [ spc_calibredecal "$spectre_linear" "$signe$mean_shift_initial" ]
          set rms_dec2 [ lindex [ spc_rms "$spectre_decini" $listeraies ] 1 ]
          while { $tdl < $tdl_max } {
             #if { $rms_dec2 > $rms_dec1 &&  [ expr abs($rms_dec2-$rms_dec1) ] >= 0.01 }
             if { $rms_dec2 > $rms_dec1 } {
                set spectre_dec [ spc_calibredecal "$spectre_decini" [ expr $signe$tdl-$dl ] ]
                set infos_cal [ spc_rms "$spectre_dec" $listeraies ]
                set rms_dec [ lindex $infos_cal 1 ]
                set mean_shift_dec [ lindex $infos_cal 2 ]
                file rename -force "$audace(rep_images)/$spectre_dec$conf(extension,defaut)" "$audace(rep_images)/${filename}_iterdec$conf(extension,defaut)"
                set spectre_dec "${filename}_iterdec"
                file delete -force "$audace(rep_images)/$spectre_decini$conf(extension,defaut)"
                ::console::affiche_resultat "\nNb iterations : $nb_iteration, dec=$tdl ; RMS2=$rms_dec2 ; RMS1=$rms_dec1\n"
                break
             } else {
                set rms_dec1 $rms_dec2
                set tdl [ expr $tdl+$dl ]
                incr nb_iteration
                set spectre_dec [ spc_calibredecal "$spectre_decini" "$signe$tdl" ]
                set rms_dec2 [ lindex [ spc_rms "$spectre_dec" $listeraies ] 1 ]
             }
          }
          set infos_cal [ spc_rms "$spectre_dec" $listeraies ]
          set rms_dec [ lindex $infos_cal 1 ]
          set mean_shift_recu [ lindex $infos_cal 2 ]
       }



        #--- Détermine la meilleure calibration :
        ::console::affiche_resultat "============ Détermine la meilleure calibration ================\n"
        #-- Sauvera le spectre final recalibré (linéarirement) :
        # set liste_rms [ list [ list "calobis" $rms_calobis ] [ list "calo" $rms_calo ] [ list "lindec" $rms_lindec ] [ list "initial" $rms_initial ] ]
        #-- Gestion des méthodes sélectionnées (car calo n°3 mauvaise selon la taille du capteur) :
        set liste_rms [ list ]
        if { [ lsearch $spcaudace(calo_meths) 1 ] != -1 } {
           lappend liste_rms [ list "initial" $rms_initial ]
        }
        if { [ lsearch $spcaudace(calo_meths) 2 ] != -1 } {
           lappend liste_rms [ list "lindec" $rms_lindec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 3 ] != -1 } {
           lappend liste_rms [ list "calo" $rms_calo ]
        }
        if { [ lsearch $spcaudace(calo_meths) 4 ] != -1 } {
           lappend liste_rms [ list "calobis" $rms_calobis ]
        }
        if { [ lsearch $spcaudace(calo_meths) 5 ] != -1 } {
           lappend liste_rms [ list "lindec_rms" $rms_lindec_rms ]
        }
        if { [ lsearch $spcaudace(calo_meths) 6 ] != -1 } {
           lappend liste_rms [ list "lindec_drms" $drms_dec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 7 ] != -1 } {
           lappend liste_rms [ list "iterdec" $rms_dec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 8 ] != -1 } {
           lappend liste_rms [ list "calopure" $rms_calopure ]
        }

        #-- Tri par RMS croissant :
        set liste_rms [ lsort -index 1 -increasing -real $liste_rms ]
        set best_rms_name [ lindex [ lindex $liste_rms 0 ] 0 ]
        set best_rms_val [ lindex [ lindex $liste_rms 0 ] 1 ]

	#-- Compare et choisis la meilleure calibration a l'aide du RMS :
        if { $best_rms_name == "calobis" } {
            #-- Le spectre recalibré avec l'eau (4) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocallinbis"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_calobis double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_calobis double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 4)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre recalibré avec (4) les raies telluriques de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration linéarisée : $crval1+$cdelt1*(x-$crpix1)\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_calobis A\nEcart moyen=$mean_shift_calobis A\n\n"
         } elseif { $best_rms_name == "calopure" } {
            #-- Le spectre recalibré avec l'eau (8) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/${filename}_calopure"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_calopure double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_calopure double "Mean measured shift from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 8)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            file delete -force "$audace(rep_images)/${filename}_calopure$conf(extension,defaut)"
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre recalibré avec (8) les raies telluriques de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration linéarisée : $crval1+$cdelt1*(x-$crpix1)\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_calopure A\nEcart moyen=$mean_shift_calopure A\n\n"
        } elseif { $best_rms_name == "calo" } {
            #-- Le spectre recalibré avec l'eau (3) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocalshifted"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_calo double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 3)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre recalibré avec (3) les raies telluriques de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Loi de calibration tellutique trouvée : $a+$b*x+$c*x^2\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_calo A\nEcart moyen=$mean_shift_calo A\n\n"
        } elseif { $best_rms_name == "lindec" } {
            #-- Le spectre linéarisé juste décalé avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_lindec double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_lindec double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 2)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_prompt "\nSpectre de calibration avec (2) de meilleure qualité (dec de Meanshift).\n"
            ::console::affiche_prompt "Loi de calibration finale linéarisée : $crval1+$cdelt1*(x-$crpix1)\n"
            ::console::affiche_prompt "Qualité de la calibration :\nRMS=$rms_lindec A\nEcart moyen=$mean_shift_lindec A\n\n"
        } elseif { $best_rms_name == "lindec_rms" } {
            #-- Le spectre linéarisé juste décalé avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec_rms"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_lindec_rms double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_lindec_rms double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 5)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (5) de meilleure qualité (dec de RMS).\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_lindec_rms A\nEcart moyen=$mean_shift_lindec_rms A\n\n"
        } elseif { $best_rms_name == "lindec_drms" } {
            #-- Le spectre linéarisé juste décalé avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec_drms"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $drms_dec double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_drms double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 6)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (6) de meilleure qualité (dec de 0.5RMS).\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$drms_dec A\nEcart moyen=$mean_shift_drms A\n\n"
        } elseif { $best_rms_name == "iterdec" } {
            #-- Le spectre linéarisé juste décalé avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_dec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_dec double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_recu double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 7)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (7) de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_dec A\nEcart moyen=$mean_shift_dec A\n\n"
        } elseif { $best_rms_name == "initial" } {
            #-- La calibration du spectre inital est meilleure :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMSO" $rms_initial double "RMS measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_MDEC" $mean_shift_initial double "Mean shift measured from telluric lines" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "no (method 1)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_prompt "\nSpectre de calibration (1) initiale de meilleure qualité.\n"
            ::console::affiche_prompt "Loi de calibration finale linéarisée : $crval1+$cdelt1*(x-$crpix1)\n"
            ::console::affiche_prompt "Qualité de la calibration :\nRMS=$rms_initial A\nEcart moyen=$mean_shift_initial A\n\n"
        }

        #--- Maj de SPC_RMS s'il est nul :
        buf$audace(bufNo) load "$audace(rep_images)/${filename}-ocal"
        set spc_rmsdflt [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 1 ]
        set spc_rmso [ lindex [ buf$audace(bufNo) getkwd "SPC_RMSO" ] 1 ]
        if { $spc_rmsdflt==0.0 } {
           buf$audace(bufNo) setkwd [ list "SPC_RMS" $spc_rmso double "Wavelength calibration RMS" "angstrom" ]
        } elseif { $best_rms_name != "initial" && $spc_rmso < $spc_rmsdflt } {
           buf$audace(bufNo) setkwd [ list "SPC_RMS" $spc_rmso double "Wavelength calibration RMS" "angstrom" ]
           #- RMS updated from telluric lines RMS
        }
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
        buf$audace(bufNo) bitpix short

      
        #--- Effacement des fichiers resultats des 4 methodes :
        if { $spectre_linear != $filename } {
           file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"
        }
        if { $spcaudace(flag_rmcalo) == "o" } {
           file delete -force "$audace(rep_images)/${filename}_caloshift2$conf(extension,defaut)"
           #file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_caloshift$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_mshiftdec$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_rmsdec$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_drmsdec$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/${filename}_iterdec$conf(extension,defaut)"
        }

        #--- Dans le cas d'un KAF400+Lhires3 2400, remet la liste des methodes comme avant :
        if { $flag_kaf400 } {
           set spcaudace(calo_meths) [ lrange $spcaudace(calo_meths) 0 [ expr $nbmeths-1 ] ]
        }
        return "${filename}-ocal"
   } else {
       ::console::affiche_erreur "Usage: spc_calibretelluric profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#



####################################################################
# Fonction d'étalonnage à partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 12-09-2007
# Date modification : 12-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_calibretelluric1 { args } {
    global conf
    global audace spcaudace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.2
    #set ecart 1.5
    # set ecart 1.0
    set ecart $spcaudace(dlargeur_eau)
    set marge_bord 2.5
    #set erreur 0.01

    #--- Rappels des raies pour resneignements :
    #-- Liste C.Buil :
    ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    # GOOD : set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_calibretelluric profil_de_raies_a_calibrer ?largeur_raie_pixels (28)?\n"
            return ""
        }

        #--- Gestion des profils selon la loi de calibration :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        #- Cas non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set flag_spccal 1
            set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
            set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
            set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
            if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
                set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
            } else {
                set spc_d 0.
            }
            set lmin_spectre [ expr $spc_a+$spc_b+$spc_c+$spc_d ]
            set lmax_spectre [ expr $spc_a+$spc_b*$naxis1+$spc_c*pow($naxis1,2)+$spc_d*pow($naxis1,3) ]
        } else {
            set flag_spccal 0
            set lmin_spectre $crval1
            set lmax_spectre [ expr $crval1+$cdelt1*($naxis1 -1) ]
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :

        ### modif michel (mes_incertitude avait une valeur beaucoup trop elevee)
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]


        #--- Charge la liste des raies de l'eau :
        set file_id [ open "$spcaudace(filetelluric)" r ]
        set contents [ split [ read $file_id ] \n ]
        close $file_id
        set nbraiesbib 0
        foreach ligne $contents {
            lappend listeraieseau [ lindex $ligne 1 ]
            incr nbraiesbib
        }
        set nbraiesbib [ expr $nbraiesbib-2 ]
        set listeraieseau [ lrange $listeraieseau 0 $nbraiesbib ]
        set lmin_bib [ lindex $listeraieseau 0 ]
        set lmax_bib [ lindex $listeraieseau $nbraiesbib ]
        # ::console::affiche_resultat "$nbraiesbib ; Lminbib=$lmin_bib ; Lmaxbib=$lmax_bib\n"
        # ::console::affiche_resultat "Lminsp=$lmin_spectre ; Lmaxsp=$lmax_spectre\n"


        #--- Creée la liste de travail des raies de l'eau pour le spectre :
        if { [ expr $lmin_bib+$marge_bord ]<$lmin_spectre || [ expr $lmax_bib-$marge_bord ]<$lmax_spectre } {
            #-- Recherche la longueur minimum des raies raies telluriques utilisables (2 A) :
            set index_min 0
            foreach raieo $listeraieseau {
                if { [ expr $lmin_spectre-$raieo ]<=-$marge_bord } {
                    break
                } else {
                    incr index_min
                }
            }
            # ::console::affiche_resultat "$index_min ; [ lindex $listeraieseau $index_min ]\n"
            #-- Recherche la longueur maximum des raies raies telluriques utilisables (2 A) :
            set index_max $nbraiesbib
            for { set index_max $nbraiesbib } { $index_max>=0 } { incr index_max -1 } {
                if { [ expr [ lindex $listeraieseau $index_max ]-$lmax_spectre ]<=-$marge_bord } {
                    break
                }
            }
            # ::console::affiche_resultat "$index_max ; [ lindex $listeraieseau $index_max ]\n"
            #-- Liste des raies telluriques utilisables :
            #- Enleve une raie sur chaque bords : 070910
            # set index_min [ expr $index_min+1 ]
            # set index_max [ expr $index_max-1 ]
            set listeraies [ lrange $listeraieseau $index_min $index_max ]
            # ::console::affiche_resultat "$listeraies\n"
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }


        #--- Filtrage pour isoler le continuum :
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
        set ffiltered [ spc_smoothsg $filename $largeur ]
        set fcont1 [ spc_div $filename $ffiltered ]

        #--- Inversion et mise a 0 du niveau moyen :
        buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
        set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
        buf$audace(bufNo) mult -1.0
        buf$audace(bufNo) offset $icontinuum
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
        buf$audace(bufNo) bitpix short

        #--- Recherche des raies telluriques en absorption :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        #set pas [ expr int($largeur/2) ]
        #buf$audace(bufNo) scale {1 3} 1
        #buf$audace(bufNo) load "$audace(rep_images)/${filename}_conti"
        #buf$audace(bufNo) load "$audace(rep_images)/$filename"
        set nbraies [ llength $listeraies ]
        set listexraies [list ]
        set listexmesures [list ]
        set listelmesurees [list ]
        set listeldiff [list ]
        foreach raie $listeraies {
            if { $flag_spccal } {
                set x  [ expr (-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie))*$spc_c))/(2*$spc_c) ]
                set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)) ]
                set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravité
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravité
                # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                set lambda_mes [ expr ($xcenter -1)*$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies $x
                lappend listexmesures $xcenter
                lappend listelmesurees $lambda_mes
                lappend listeldiff $ldiff
            } else {
                set x  [ expr ($raie-$crval1)/$cdelt1 + 1 ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 +1 ) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 +1 ) ]
                set coords [ list $x1 1 $x2 1 ]
                #-- Meth 1 : centre de gravité
                ###set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #-- Meth 2 : centre gaussien
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #-- Meth 3 : centre moyen de gravité
                # set xc1 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xc2 [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                # buf$audace(bufNo) mult -1.0
                # set xcenter [ expr [ lindex [ lsort -real -increasing [ list $xc1 $xc2 ]  ] 0 ]+0.5*abs($xc2-$xc1) ]
                set lambda_mes [ expr  ($xcenter -1) *$cdelt1+$crval1 ]
                set ldiff [ expr $lambda_mes-$raie ]
                lappend listexraies    $x
                lappend listexmesures  $xcenter
                lappend listelmesurees $lambda_mes
                lappend listeldiff     $ldiff

            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
        ::console::affiche_resultat "Liste des x mesures :\n$listexmesures\n"
        ::console::affiche_resultat "Liste des raies du catalogue :\n$listeraies\n"
        ::console::affiche_resultat "Liste des x du catalogue :\n$listexraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

        #--- Methode 1 : spectre initial linéaire :
        ::console::affiche_resultat "============ 1) spectre initial linéaire ================\n"
        set spectre_linear [ spc_linearcal "$filename" ]
        set infos_cal [ spc_rms "$spectre_linear" $listeraies ]
        set rms_initial [ lindex $infos_cal 1 ]
        set mean_shift_initial [ lindex $infos_cal 2 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        set cdelt1_initial $cdelt1
        set crval1_initial $crval1
        ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


        #--- Methode 2 : Décalage du spectre inital linéarisé à l'aide des raies telluriques :
        ::console::affiche_resultat "============ 2) Décalage du SHIFT du spectre inital linéarisé ================\n"
        set spectre_lindec [ spc_calibredecal "$spectre_linear" [ expr -1.0*$mean_shift_initial ] ]
        set infos_cal [ spc_rms "$spectre_lindec" $listeraies ]
        set rms_lindec [ lindex $infos_cal 1 ]
        set mean_shift_lindec [ lindex $infos_cal 2 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


        #--- Methode 5 : Décalage du spectre inital linéarisé de la valeur du RMS :
        ::console::affiche_resultat "============ 5) Décalage de RMS du spectre inital linéarisé ================\n"
        #set rms_decalage [ expr $rms_initial/$cdelt1_initial/2. ]
        set rms_decalage [ expr $rms_initial/$cdelt1_initial ]
        if { $mean_shift_initial > 0. } {
           set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" [ expr -1.0*$rms_decalage ] ]
        } else {
           set spectre_lindec_rms [ spc_calibredecal "$spectre_linear" $rms_decalage ]
        }
        set infos_cal [ spc_rms "$spectre_lindec" $listeraies ]
        set rms_lindec_rms [ lindex $infos_cal 1 ]
        set mean_shift_lindec_rms [ lindex $infos_cal 2 ]
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        ::console::affiche_resultat "Loi de calibration lineaire : $crval1+$cdelt1*x\n"


        #--- Methode 6 : callibration avec les raies telluriques :
        ::console::affiche_resultat "====== 6) Recalage sur la valeur de PDeg3 au pixel 1 ====\n"
        #-- Ajustement polynomial de degre 3 :
        set sortie [ spc_ajustdeg3 $listexmesures $listeraies $errors ]
        set coeffs [ lindex $sortie 0 ]
        set d [ lindex $coeffs 3 ]
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        #set crval1_deg3 [ expr $a+$b+$c+$d ]
        #-- Lineratistation de la loi polynomiale :
        for { set i 1 } { $i<=$naxis1 } { incr i 10 } {
          lappend abscisses $i
          lappend ordonnees [ expr $a+$b*$i+$c*pow($i,2)+$d*pow($i,3) ]
          lappend erreurs 1.
        }
        set sortie [ spc_ajustdeg1hp $abscisses $ordonnees $erreurs ]
	#- lambda0 : lambda pour x=0
        set lambda0 [ lindex [ lindex $sortie 0 ] 0 ]
        set cdelt1 [ lindex [ lindex $sortie 0 ] 1 ]
	#- crval1 : lambda pour x=1
        set crval1_deg3 [ expr $lambda0 + $cdelt1 ]
        buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
        buf$audace(bufNo) setkwd [list "CRVAL1" $crval1_deg3 double "" "angstrom" ]
        set spectre_deg3dec "${spectre_linear}_deg2dec"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$spectre_deg3dec"
        buf$audace(bufNo) bitpix short
        set infos_cal [ spc_rms "$spectre_deg3dec" $listeraies ]
        set rms_deg3dec [ lindex $infos_cal 1 ]
        set mean_shift_deg3dec [ lindex $infos_cal 2 ]


        #--- Methode 3 : callibration avec les raies telluriques :
        ::console::affiche_resultat "============ 3) calibration sur l'eau ================\n"
        #-- Ajustement polynomial de degre 3 :
        set sortie [ spc_ajustdeg3 $listexmesures $listeraies $errors ]
        set coeffs [ lindex $sortie 0 ]
        set d [ lindex $coeffs 3 ]
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        set chi2 [ lindex $sortie 1 ]
        set covar [ lindex $sortie 2 ]
        set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]

        #-- Sauvegarde le spectre calibré non-linéairement :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocalnl"
        buf$audace(bufNo) bitpix short

        #-- Recalage de la calibration grace aux raies telluriques :
        #- Rééchantillonnage pour obtenir une loi de calibration linéaire :
        set spectre_ocallin [ spc_linearcal "${filename}-ocalnl" ]

        #- Calcul de décalage moyen+rms :
        set mean_shift [ lindex [ spc_rms "$spectre_ocallin" $listeraies ] 2 ]
        #- Réalise le décalage sur la loi linéaire :
        set spectre_ocalshifted [ spc_calibredecal "$spectre_ocallin" [ expr -1.*$mean_shift ] ]
        #- Calcul le décalage moyen+rms du spectre final :
        # set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies 1.5 ]
        set infos_cal [ spc_rms "$spectre_ocalshifted" $listeraies ]
        set rms_calo [ lindex $infos_cal 1 ]
        set mean_shift_calo [ lindex $infos_cal 2 ]
        #- Effacement des fichiers temporaires :
        if { $spectre_ocallin != "${filename}-ocalnl" } {
            file delete -force "$audace(rep_images)/${filename}-ocalnl$conf(extension,defaut)"
        }
        file delete -force "$audace(rep_images)/$spectre_ocallin$conf(extension,defaut)"
        #- Enregistre les éléments de la calibration :
        set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]


        #--- Methode 4 : callibration 2 avec les raies telluriques
        ::console::affiche_resultat "============ 4) calibration sur l'eau bis ================\n"
        #-- Calcul du polynôme de calibration xlin = a+bx+cx^2+cx^3
        ### spc_calibretelluric 94-bet-leo--profil-traite-final.fit
        set sortie [ spc_ajustdeg2 $listexmesures $listexraies $errors ]
        # set sortie [ spc_ajustdeg3 $listexmesures $listexraies $errors ]
        set coeffs [ lindex $sortie 0 ]
        # set d [ lindex $coeffs 3 ]
        set d 0.0
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        set chi2 [ lindex $sortie 1 ]
        set covar [ lindex $sortie 2 ]
        set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]

        #-- je calcule les x linearises
        set listexlin [list]
        foreach x $listexmesures {
            lappend listexlin [ expr $a + $b*$x + $c*$x*$x + $d*$x*$x*$x ]
        }

        #-- je charge l'image calibree avec le neon
        buf$audace(bufNo) load "$audace(rep_images)/$filename"

        #-- Rééchantillonnage pour obtenir une loi de calibration linéaire :
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        set xorigin [list ]
        set xlinear [list ]
        set intensites [list ]
        for {set x 0 } {$x<$naxis1} {incr x} {
            lappend xorigin $x
            lappend xlinear [ expr $a + $b*$x + $c*$x*$x + $d*$x*$x*$x ]
            lappend intensities [lindex [ buf$audace(bufNo) getpix [list [expr $x +1] 1] ] 1]
        }
        set newIntensities [ lindex [ spc_spline $xlinear $intensities $xorigin n ] 1 ]
        for {set x 0 } {$x<$naxis1} {incr x} {
            buf$audace(bufNo) setpix [ list [expr $x +1] 1 ] [lindex $newIntensities $x]
        }

        #-- je calcule les coefficients de la droite moyenne lambda=f(xlin)
        set sortie [ spc_ajustdeg1hp $listexlin $listeraies $errors ]
	#- lambda0 : lambda pour x=0
        set lambda0 [lindex [ lindex $sortie 0 ] 0]
        set cdelt1 [lindex [ lindex $sortie 0 ] 1]
	#- crval1 : lambda pour x=1
        set crval1 [expr $lambda0 + $cdelt1]
        buf$audace(bufNo) setkwd [list "CRVAL1" $crval1 double "" "angstrom" ]
        buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1 double "" "angstrom/pixel" ]
	set listemotsclef [ buf$audace(bufNo) getkwds ]
	if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
	    buf$audace(bufNo) delkwd "SPC_A"
	    buf$audace(bufNo) delkwd "SPC_B"
	    buf$audace(bufNo) delkwd "SPC_C"
	    if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
		buf$audace(bufNo) delkwd "SPC_D"
	    }
	}

        #-- j'enregistre l'image
        set spectre_ocallinbis "${filename}-ocalnlbis"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$spectre_ocallinbis"
        buf$audace(bufNo) bitpix short

        #-- Calcul le décalage moyen+rms du spectre final :
        set infos_cal   [ spc_rms $spectre_ocallinbis $listeraies ]
        set rms_calobis [ lindex $infos_cal 1 ]
        set mean_shift_calobis [ lindex $infos_cal 2 ]
        ::console::affiche_resultat "Loi de calibration lineaire calobis : $crval1+$cdelt1*x\n"


        #--- Détermine la meilleure calibration :
        ::console::affiche_resultat "============ Détermine la meilleure calibration ================\n"
        #-- Sauvera le spectre final recalibré (linéarirement) :
        # set liste_rms [ list [ list "calobis" $rms_calobis ] [ list "calo" $rms_calo ] [ list "lindec" $rms_lindec ] [ list "initial" $rms_initial ] ]
        #-- Gestion des méthodes sélectionnées (car calo n°3 mauvaise selon la taille du capteur) :
        set liste_rms [ list ]
        if { [ lsearch $spcaudace(calo_meths) 1 ] != -1 } {
           lappend liste_rms [ list "initial" $rms_initial ]
        }
        if { [ lsearch $spcaudace(calo_meths) 2 ] != -1 } {
           lappend liste_rms [ list "lindec" $rms_lindec ]
        }
        if { [ lsearch $spcaudace(calo_meths) 3 ] != -1 } {
           lappend liste_rms [ list "calo" $rms_calo ]
        }
        if { [ lsearch $spcaudace(calo_meths) 4 ] != -1 } {
           lappend liste_rms [ list "calobis" $rms_calobis ]
        }
        if { [ lsearch $spcaudace(calo_meths) 5 ] != -1 } {
           lappend liste_rms [ list "lindec_rms" $rms_lindec_rms ]
        }
        if { [ lsearch $spcaudace(calo_meths) 6 ] != -1 } {
           lappend liste_rms [ list "deg3dec" $rms_deg3dec ]
        }

        #-- Tri par RMS croissant :
        set liste_rms [ lsort -index 1 -increasing -real $liste_rms ]
        set best_rms_name [ lindex [ lindex $liste_rms 0 ] 0 ]
        set best_rms_val [ lindex [ lindex $liste_rms 0 ] 1 ]

	#-- Compare et choisis la meilleure calibration a l'aide du RMS :
        if { $best_rms_name == "calobis" } {
            #-- Le spectre recalibré avec l'eau (4) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocallinbis"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_calobis double "Wavelength calibration RMS" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 4)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre recalibré avec (4) les raies telluriques de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_calobis A\nEcart moyen=$mean_shift_calobis A\n\n"
        } elseif { $best_rms_name == "calo" } {
            #-- Le spectre recalibré avec l'eau (3) est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_ocalshifted"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_calo double "Wavelength calibration RMS" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 3)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre recalibré avec (3) les raies telluriques de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Loi de calibration tellutique trouvée : $a+$b*x+$c*x^2\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_calo A\nEcart moyen=$mean_shift_calo A\n\n"
        } elseif { $best_rms_name == "lindec" } {
            #-- Le spectre linéarisé juste décalé avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_lindec double "Wavelength calibration RMS" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 2)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (2) décalage de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_lindec A\nEcart moyen=$mean_shift_lindec A\n\n"
        } elseif { $best_rms_name == "lindec_rms" } {
            #-- Le spectre linéarisé juste décalé avec l'eau est meilleur :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_lindec_rms"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_lindec_rms double "Wavelength calibration RMS" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 5)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (5) décalage de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_lindec_rms A\nEcart moyen=$mean_shift_lindec_rms A\n\n"
        } elseif { $best_rms_name == "deg3dec" } {
            #-- La calibration du spectre inital est meilleure :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_deg3dec"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_deg3dec double "Wavelength calibration RMS" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 6)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration avec (6) de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_initial A\nEcart moyen=$mean_shift_initial A\n\n"
        } elseif { $best_rms_name == "initial" } {
            #-- La calibration du spectre inital est meilleure :
            buf$audace(bufNo) load "$audace(rep_images)/$spectre_linear"
            set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
            set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
            buf$audace(bufNo) setkwd [ list "SPC_RMS" $rms_initial double "Wavelength calibration RMS" "angstrom" ]
            buf$audace(bufNo) setkwd [ list "SPC_CALO" "yes (method 1)" string "Yes if spectrum has been calibrated with telluric lines" "" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save "$audace(rep_images)/${filename}-ocal"
            buf$audace(bufNo) bitpix short
            #-- Exploitatoin des résultats :
            ::console::affiche_resultat "\nSpectre de calibration (1) initiale de meilleure qualité.\n"
            ::console::affiche_resultat "Loi de calibration finale linéarisée : $crval1+$cdelt1*x\n"
            ::console::affiche_resultat "Qualité de la calibration :\nRMS=$rms_initial A\nEcart moyen=$mean_shift_initial A\n\n"
        }

        #--- Effacement des fichiers resultats des 4 methodes
        file delete -force "$audace(rep_images)/$spectre_ocallinbis$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_ocalshifted$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_lindec$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_lindec_rms$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$spectre_deg3dec$conf(extension,defaut)"
        if { $spectre_linear != $filename } {
           file delete -force "$audace(rep_images)/$spectre_linear$conf(extension,defaut)"
        }
        return "${filename}-ocal"
   } else {
       ::console::affiche_erreur "Usage: spc_calibretelluric1 profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#




####################################################################
# Réalise un diagnostique de la calibration par prapport aux raies de l'eau :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-09-2007
# Date modification : 23-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_calobilan { args } {
    global conf
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_calobilan nom_profil_de_raies_fits ?largeur_raie (pixel)?\n"
            return ""
        }

        #--- Met le spectre de l'eau au niveau du continuum du spectre étidié :
        #-- Détermine la valeur du continuum :
        set icontinuum [ spc_icontinuum "$filename" ]
        #-- Applique au spectre de l'eau :
        buf$audace(bufNo) load "$spcaudace(reptelluric)/$spcaudace(sp_eau)"
        buf$audace(bufNo) mult $icontinuum
        buf$audace(bufNo) save "$audace(rep_images)/eau_conti"

        #--- Affichage des renseignements :
        spc_gdeleteall
        spc_load "$filename"
        spc_loadmore "eau_conti" "green"
        set spcaudace(gcolor) [ expr $spcaudace(gcolor) + 1 ]
        spc_caloverif "$filename"
        file delete -force "$audace(rep_images)/eau_conti$conf(extension,defaut)"
   } else {
       ::console::affiche_erreur "Usage: spc_calobilan profil_de_raies_fits ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#


####################################################################
# Superpose le profil de raies de l'eau sur un spectre choisi :
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-09-2007
# Date modification : 23-09-2007
# Arguments : nom_profil_raies
####################################################################

proc spc_loadmh2o { args } {
    global conf caption
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur $spcaudace(largeur_savgol)
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } elseif { $nbargs == 0 } {
	   set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
	   if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
	       set filename $spctrouve
	   } else {
              ::console::affiche_erreur "Le profil de raies doit se trouver dans le répertoire de travail.\nUsage: spc_loadmh2o nom_profil_de_raies_fits ?largeur_raie (pixel)?\n"
              return ""
	   }
        }

        #--- Met le spectre de l'eau au niveau du continuum du spectre étidié :
        #-- Détermine la valeur du continuum :
        set icontinuum [ spc_icontinuum "$filename" ]
        #-- Applique au spectre de l'eau :
        #- Corrige pb du repertoire d'install d'Audela avec des espaces... :
        # buf$audace(bufNo) load "$spcaudace(reptelluric)/$spcaudace(sp_eau)"
        file copy -force "$spcaudace(reptelluric)/$spcaudace(sp_eau)" "$audace(rep_images)/$spcaudace(sp_eau)"
        buf$audace(bufNo) load "$audace(rep_images)/$spcaudace(sp_eau)"
        #- Suite normale :
        buf$audace(bufNo) mult $icontinuum
        buf$audace(bufNo) save "$audace(rep_images)/eau_conti"
        file delete -force "$audace(rep_images)/$spcaudace(sp_eau)"

        #--- Affichage des renseignements :
        spc_gdeleteall
        if { [ llength $spcaudace(gloaded) ] == 0 } {
           spc_load "$filename"
        }
        spc_loadmore "eau_conti" "green"
        set spcaudace(gcolor) [ expr $spcaudace(gcolor) + 1 ]
        file delete -force "$audace(rep_images)/eau_conti$conf(extension,defaut)"
   } else {
       ::console::affiche_erreur "Usage: spc_loadmh2o profil_de_raies_fits ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#




####################################################################
# Visualise un spectre de l'au de la bibliothèque
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-09-2007
# Date modification : 23-09-2007
# Arguments : ?nom_profil_raies_eau_bibliothèque?
####################################################################

proc spc_loadh2o { args } {
    global conf
    global audace spcaudace

    set nbargs [ llength $args ]
    if { $nbargs <= 1 } {
        if { $nbargs == 1 } {
            set fileselect [ file rootname [ lindex $args 0 ] ]
            set filename "${fileselect}.fit"
        } elseif { $nbargs == 0 } {
            set filename $spcaudace(sp_eau)
        } else {
            ::console::affiche_erreur "Usage: spc_loadh2o ?nom_profil_de_raies_telluric_bibliotheque?\n\n"
            return ""
        }

        #--- Cherche le spectre de l'eau :
        file copy -force "$spcaudace(reptelluric)/$filename" "$audace(rep_images)/$filename"
        #--- Affiche :
        if { [ llength $spcaudace(gloaded) ] == 0 } {
            spc_load "$filename"
        } else {
            spc_loadmore "$filename"
        }

        #--- Nettoie le répetoire de travail :
        file delete -force "$audace(rep_images)/$filename"

    } else {
        ::console::affiche_erreur "Usage: spc_loadh2o ?nom_profil_de_raies_telluric_bibliotheque?\n\n"
    }
}
#****************************************************************#



####################################################################
# Procédure de recalage en longueur d'onde a partir d'une raie tellurique de l'eau
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 25-03-2007
# Date modification : 25-03-2007
# Arguments : profil_de_raies_étoile_référence profil_de_raies_a_calibrer lambda_eau_mesurée_6532
####################################################################

proc spc_calibrehaeau { args } {
    global conf
    global audace

    #-- Liste C.Buil :
    ## set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    #set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]

    if { [llength $args]==3 } {
        set spreference [ lindex $args 0 ]
        set spacalibrer [ lindex $args 1 ]
        set leau [ lindex $args 2 ]


        #--- Affichage des résultats :
        ::console::affiche_resultat "Le spectre calibré est sauvé sous $fileout\n"
        return ""
    } else {
       ::console::affiche_erreur "Usage: spc_calibrehaeau profil_de_raies_étoile_référence profil_de_raies_a_calibrer lambda_eau_mesurée_6532\n\n"
   }
}
#***************************************************************************#




####################################################################
# Fonction d'étalonnage à partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 30-09-2006
# Date modification : 03-10-2006
# Arguments : nom_profil_raies
####################################################################

proc spc_autocalibrehaeau1 { args } {
    global conf
    global audace
    # set pas 10
    #set ecart 4.0
    set ecart 1.5
    #set erreur 0.01
    set ldeb 6528.0
    set lfin 6580.0
    #-- Liste C.Buil :
    ## set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    #set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    #-- Liste ESO-Pollman :
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ lindex $args 0 ]
            set largeur 0
        } elseif { $nbargs == 2 } {
            set filename [ lindex $args 0 ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_autocalibrehaeau nom_profil_de_raies ?largeur_raie (pixel)?\n"
            return 0
        }
        #set pas [ expr int($largeur/2) ]

        #--- Gestion des profils calibrés en longueur d'onde :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
        set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
        set crpix1 [ lindex [buf$audace(bufNo) getkwd "CRPIX1"] 1 ]
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]

        #--- Calcul des xdeb et xfin bornant les 6 raies de l'eau :
        if { $ldeb>$crval1+2. && $lfin<[ expr $naxis1*$cdelt1+$crval1-2. ] } {
### modif michel
###            set xdeb [ expr int(($lfin????-$crval1)/$cdelt1) ]
###            set xfin [ expr int(($lfin-$crval1)/$cdelt1) ]
            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) -1 ]
            set xfin [ expr round(($lfin-$crval1)/$cdelt1) -1 ]
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }

        #--- Recherche des raies d'émission :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        buf$audace(bufNo) mult -1.0
        set nbraies [ llength $listeraies ]
        foreach raie $listeraies {
### modif michel
###            set x1 [ expr int(($raie-$ecart-$crval1)/$cdelt1) ]
###            set x2 [ expr int(($raie+$ecart-$crval1)/$cdelt1) ]
            set x1 [ expr int(($raie-$ecart-$crval1)/$cdelt1 -1) ]
            set x2 [ expr int(($raie+$ecart-$crval1)/$cdelt1 -1) ]
            set coords [ list $x1 1 $x2 1 ]
            if { $largeur == 0 } {
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1*$cdelt1+$crval1 ]
            } else {
                set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1)*$cdelt1+$crval1 ]
            }
            lappend errors $mes_incertitude
        }
        ::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
        # ::console::affiche_resultat "Liste des raies trouvées : $listemesures\n"
        ::console::affiche_resultat "Liste des raies de référence :\n$listeraies\n"

        #------------------------------------------------------------#
        set flag 0
        if { $flag==1} {
        #--- Constitution de la chaine x_n lambda_n :
        #foreach mes $listemesures eau $listeraies {
            # append listecoords "$mes $eau "
        #    append listecoords $mes
        #    append listecoords $eau
        #}
        #::console::affiche_resultat "Coords : $listecoords\n"
        set i 1
        foreach mes $listemesures eau $listeraies {
            set x$i $mes
            set l$i $eau
            incr i
        }

        #--- Calibration en longueur d'onde :
        ::console::affiche_resultat "Calibration du profil avec les raies de l'eau...\n"
        #set calibreargs [ list $filename $listecoords ]
        #set len [ llength $calibreargs ]
        #::console::affiche_resultat "$len args : $calibreargs\n"
        #set sortie [ spc_calibren $calibreargs ]
        set sortie [ spc_calibren $filename $x1 $l1 $x2 $l2 $x3 $l3 $x4 $l4 $x5 $l5 $x6 $l6 ]
        return $sortie
        }
        #------------------------------------------------------------#

        #--- Calcul du polynôme de calibration a+bx+cx^2 :
        set sortie [ spc_ajustdeg2 $listemesures $listeraies $errors ]
         set coeffs [ lindex $sortie 0 ]
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        set chi2 [ lindex $sortie 1 ]
        set covar [ lindex $sortie 2 ]
        ::console::affiche_resultat "Chi2=$chi2\n"
        set lambda0deg2 [ expr $a+$b+$c ]
        set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
        ::console::affiche_resultat "RMS=$rms angstrom\n"

        #--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
            lappend xpos $x
            lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
            lappend errorsd1 $mes_incertitude
        }
        #set sortie1 [ spc_ajustdeg1 $xpos $lambdaspoly $errorsd1 ]
        set coeffsdeg1 [ spc_reglin $xpos $lambdaspoly $crpix1 ]
        set a1 [ lindex $coeffsdeg1 0 ]
        set b1 [ lindex $coeffsdeg1 1 ]
        set lambda0deg1 $b1


        #--- Nouvelle valeur de Lambda0 :
        #set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
        #-- Reglages :
        #- 40 -10 l0deg1 : AB
        #- 40 -40 l0deg1 : AB+
        #- 20 -10 l0deg2 : AB++
        set lambda0 $lambda0deg2


        #--- Redonne le lambda du centre des raies apres réétalonnage :
        set ecart2 0.6
        foreach raie $listeraies {
### modif michel
###            set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1) ]
###            set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1) ]
            set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1 -1) ]
            set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1 -1) ]
            set coords [ list $x1 1 $x2 1 ]
            if { $largeur == 0 } {
                set x [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                #lappend listemesures $xcenter
                # lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
                lappend listelmesurees2 [ expr $lambda0+$cdelt1*$x ]
            } else {
                set x [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
                #lappend listemesures $xcenter
                lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
            }
        }
        #::console::affiche_resultat "Liste des raies après réétalonnage :\n$listelmesurees2\nÀ comparer avec :\n$listeraies\n"


        #--- Mise à jour des mots clefs :
        buf$audace(bufNo) setkwd [list "CRPIX1" 1 double "" ""]
        #-- Longueur d'onde de départ :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
        #-- Dispersion moyenne :
        #buf$audace(bufNo) setkwd [list "CDELT1" $a1 double "" "angstrom/pixel"]
        #buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
        #-- Corrdonnée représentée sur l'axe 1 (ie X) :
        #buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
        #-- Mots clefs du polynôme :
        buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        #buf$audace(bufNo) setkwd [list "SPC_B" $b float "" "angstrom/pixel"]
        #buf$audace(bufNo) setkwd [list "SPC_C" $c float "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]

        #--- Sauvegarde :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
        buf$audace(bufNo) bitpix short

        #--- Fin du script :
        ::console::affiche_resultat "Spectre étalonné sauvé sous l${filename}\n"
        return l${filename}

   } else {
       ::console::affiche_erreur "Usage: spc_autocalibrehaeau profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#




##########################################################
# Procedure de correction  de la vitesse héliocentrique
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 27-12-2011
# Date de mise à jour : 20-10-2017
# Arguments : profil_raies_étalonné lambda_raie_approché lambda_réf ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
# Explication : la correciton héliocentrique possède déjà le bon signe tandis que la vitesse héliocentrique non.
#  La mesure de vitesse radiale nécessite d'être corrigée de la vitesse héliocentrique même si la calibration a été faite sur les raies telluriques car le centre du référentiel n'est pas la Terre mais le barycentre du Système Solaire.
##########################################################

proc spc_vheliocorr { args } {

   global audace conf spcaudace

   if { [llength $args] == 1 || [llength $args] == 7 || [llength $args] == 10 } {
       if { [llength $args] == 1 } {
          set spectre [ file rootname [ lindex $args 0 ] ]
       } elseif { [llength $args] == 7 } {
          set spectre [ file rootname [ lindex $args 0 ] ]
	   set ra_h [ lindex $args 1 ]
	   set ra_m [ lindex $args 2 ]
	   set ra_s [ lindex $args 3 ]
	   set dec_d [ lindex $args 4 ]
	   set dec_m [ lindex $args 5 ]
	   set dec_s [ lindex $args 6 ]
       } elseif { [llength $args] == 10 } {
          set spectre [ file rootname [ lindex $args 0 ] ]
	   set ra_h [ lindex $args 1 ]
	   set ra_m [ lindex $args 2 ]
	   set ra_s [ lindex $args 3 ]
	   set dec_d [ lindex $args 4 ]
	   set dec_m [ lindex $args 5 ]
	   set dec_s [ lindex $args 6 ]
	   set jj [ lindex $args 7 ]
	   set mm [ lindex $args 8 ]
	   set aaaa [ lindex $args 9 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_vheliocorr profil_raies_étalonné ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
	   return 0
       }

      #--- Charge les mots clefs :
      buf$audace(bufNo) load "$audace(rep_images)/$spectre"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set lambda_ref [ expr 0.5*($naxis1-1)*$cdelt1+$crval1 ]

      #--- Détermine les paramètres de date et de coordonnées si nécessaire :
      # mc_baryvel {2006 7 22} {19h24m58.00s} {11d57m00.0s} J2000.0
      if { [llength $args] == 1 } {
         # OBJCTRA = '00 16 42.089'
         if { [ lsearch $listemotsclef "OBJCTRA" ] !=-1 } {
            set ra [ lindex [buf$audace(bufNo) getkwd "OBJCTRA" ] 1 ]
            set ra_h [ lindex $ra 0 ]
            set ra_m [ lindex $ra 0 ]
            set ra_s [ lindex $ra 0 ]
            set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
         } elseif { [ lsearch $listemotsclef "RA" ] !=-1 } {
            set raf [ lindex [buf$audace(bufNo) getkwd "RA" ] 1 ]
            if { [ regexp {\s+} $raf match resul ] } {
               ::console::affiche_erreur "Aucune coordonnée trouvée.\n"
               return ""
            }
         } else {
            ::console::affiche_erreur "Aucune coordonnée trouvée.\n"
            return ""
         }
         # OBJCTDEC= '-05 23 52.444'
         if { [ lsearch $listemotsclef "OBJCTDEC" ] !=-1 } {
            set dec [ lindex [buf$audace(bufNo) getkwd "OBJCTDEC" ] 1 ]
            set dec_d [ lindex $dec 0 ]
            set dec_m [ lindex $dec 0 ]
            set dec_s [ lindex $dec 0 ]
            set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
         } elseif { [ lsearch $listemotsclef "DEC" ] !=-1 } {
            set decf [ lindex [buf$audace(bufNo) getkwd "DEC" ] 1 ]
         }
         # DATE-OBS : 2005-11-26T20:47:04
         if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
            set ladate [ lindex [buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
            set ldate [ mc_date2ymdhms $ladate ]
            set y [ lindex $ldate 0 ]
            set mo [ lindex $ldate 1 ]
            set d [ lindex $ldate 2 ]
            set datef [ list $y $mo $d ]
         }
      } elseif { [llength $args] == 7 } {
         # DATE-OBS : 2005-11-26T20:47:04
         if { [ lsearch $listemotsclef "DATE-OBS" ] !=-1 } {
            set ladate [ lindex [buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
            set ldate [ mc_date2ymdhms $ladate ]
            set y [ lindex $ldate 0 ]
            set mo [ lindex $ldate 1 ]
            set d [ lindex $ldate 2 ]
            set datef [ list $y $mo $d ]
         }
         set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
         set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
      } elseif { [llength $args] == 10 } {
         set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
         set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
         set datef [ list $aaaa $mm $jj ]
      }

      #--- Calcul de la vitesse héliocentrique :
      ::console::affiche_resultat "Correction de la vitesse héliocentrique du spectre...\n"
      set raf [ list "${ra_h}h${ra_m}m${ra_s}s" ]
      set decf [ list "${dec_d}d${dec_m}m${dec_s}s" ]
      #set vhelio [ lindex [ mc_baryvel $ladate $raf $decf J2000.0 ] 0 ]
      #-- Retourne les corrections héliocentriques et barycentriques à apporter à la mesure de la vitesse radiale d'un astre aux coordonnées Angle_Ra Angle_Decà l'équinoxe Equinox. Donc : Vrh=Vrg+Vhelio
      set vhelio [ lindex [ mc_baryvel $ladate $raf $decf $ladate ] 0 ]
      set delta_lambda [ format "%4.4f" [ expr $lambda_ref*$vhelio/$spcaudace(vlum) ] ]
      
      #--- Recalage en longueur d'onde du spectre :
      #-- Dans le triangle Terre, Soleil et Etoile on a : SE=ST+TE
      #-- Donc Vrefhelio=Vrefgeo+Vhelio (chgt de ref) et on a : dL_refhelio=dL_refgeo+dL_du_a_vhelio
      #-- On aura : Lambda_refhelio=L_refgeo+dL_decalagehelio(appliqué à L_refgeo)=Lrefgeo+Lrefgeo.Vh/c
      buf$audace(bufNo) load "$audace(rep_images)/$spectre"
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set crval1m [ expr $crval1*(1+$vhelio/$spcaudace(vlum)) ]
      set cdelt1m [ expr $cdelt1*(1+$vhelio/$spcaudace(vlum)) ]

      #--- Traitement du résultat :
      set lambda_refp [ format "%4.2f" $lambda_ref ]
      buf$audace(bufNo) setkwd [ list BSS_VHEL $vhelio float "Helio velocity for date obs at $lambda_refp" "km/s" ]
      buf$audace(bufNo) setkwd [ list SPC_VHEL $vhelio float "Helio velocity for date obs at $lambda_refp" "km/s" ]
      buf$audace(bufNo) setkwd [list "CRVAL1" $crval1m double "Wavelength at reference pixel" "angstrom"]
      buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1m double "Wavelength dispersion" "angstrom/pixel"]
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${spectre}_vhel"
      buf$audace(bufNo) bitpix short


      #--- Formatage du résultat :
      set vheliof [ format "%4.5f" $vhelio ]
      ::console::affiche_resultat "Spectre corrigé de $vheliof km/s (ex. pour $lambda_ref A : delta=$delta_lambda A) sauvé sous ${spectre}_vhel\n"
      return "${spectre}_vhel"
   } else {
      ::console::affiche_erreur "Usage: spc_vheliocorr profil_raies_étalonné ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?\n\n"
   }
}
#*******************************************************************************#






##########################################################
# Procedure de correction de la vitesse héliocentrique de la calibration en longueur d'onde
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 05-03-2007
   # Date de mise à jour : 05-03-2007 ; 22-03-2016
# Arguments : profil_raies_étalonné lambda_calage ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA?
##########################################################

proc spc_corrvhelio { args } {

   global audace spcaudace
   global conf

   if { [llength $args] == 2 || [llength $args] == 8 || [llength $args] == 11 } {
       if { [llength $args] == 2 } {
           set spectre [ file rootname [ lindex $args 0 ] ]
           set lambda_cal [ lindex $args 1 ]
           set vhelio [ spc_vhelio $spectre ]
       } elseif { [llength $args] == 8 } {
           set spectre [ file rootname [ lindex $args 0 ] ]
           set lambda_cal [ lindex $args 1 ]
           set ra_h [ lindex $args 2 ]
           set ra_m [ lindex $args 3 ]
           set ra_s [ lindex $args 4 ]
           set dec_d [ lindex $args 5 ]
           set dec_m [ lindex $args 6 ]
           set dec_s [ lindex $args 7 ]
           set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s ]
       } elseif { [llength $args] == 11 } {
           set spectre [ file rootname [ lindex $args 0 ] ]
           set lambda_cal [ lindex $args 1 ]
           set ra_h [ lindex $args 2 ]
           set ra_m [ lindex $args 3 ]
           set ra_s [ lindex $args 4 ]
           set dec_d [ lindex $args 5 ]
           set dec_m [ lindex $args 6 ]
           set dec_s [ lindex $args 7 ]
           set jj [ lindex $args 8 ]
           set mm [ lindex $args 9 ]
           set aaaa [ lindex $args 10 ]
           set vhelio [ spc_vhelio $spectre $ra_h $ra_m $ra_s $dec_d $dec_m $dec_s $jj $mm $aaaa ]
       } else {
           #::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ?[[?RA_d RA_m RA_s DEC_h DEC_m DEC_s?] ?JJ MM AAAA?]?\n\n"
           ::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ?RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA??\n"
           return ""
       }

      #--- Calcul du décalage en longueur d'onde pour lambda_ref :
      set delta_lambda [ format "%4.4f" [ expr $lambda_cal*$vhelio/$spcaudace(vlum) ] ]

      #--- Recalage en longueur d'onde du spectre :
      buf$audace(bufNo) load "$audace(rep_images)/$spectre"
      set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
      set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set crval1m [ expr $crval1*(1+$vhelio/$spcaudace(vlum)) ]
      set cdelt1m [ expr $cdelt1*(1+$vhelio/$spcaudace(vlum)) ]

      #--- Traitement du résultat :
      buf$audace(bufNo) setkwd [ list BSS_VHEL $vhelio float "Heliocentric velocity at data date" "km/s" ]
      buf$audace(bufNo) setkwd [list "CRVAL1" $crval1m double "Wavelength at reference pixel" "angstrom"]
      buf$audace(bufNo) setkwd [list "CDELT1" $cdelt1m double "Wavelength dispersion" "angstrom/pixel"]
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/${spectre}_vhel"
      buf$audace(bufNo) bitpix short

      #--- Fin :
      #::console::affiche_resultat "Spectre décalé de $delta_lambda A à $lambda_cal sauvé sous ${spectre}_vhel\n"
      set vheliof [ format "%4.5f" $vhelio ]      
      ::console::affiche_resultat "Spectre corrigé de $vheliof km/s (ex. pour $lambda_cal A : delta=$delta_lambda A) sauvé sous ${spectre}_vhel\n"
      return "${spectre}_vhel"
   } else {
       ::console::affiche_erreur "Usage: spc_corrvhelio profil_raies_étalonné lambda_calage ??RA_d RA_m RA_s DEC_h DEC_m DEC_s? ?JJ MM AAAA??\n"
       return ""
   }
}
#****************************************************************#


##########################################################
# Procedure de decalage d'un spectre d'un vitesse donnee
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 2016-08-03
# Date de mise à jour : 2016-08-03
# Arguments : profil_raies_étalonné v_shifting
##########################################################

proc spc_vdecal { args } {
   global conf audace spcaudace

   if { [ llength $args ] == 2 } {
      set spectre [ file rootname [ lindex $args 0 ] ]
      set vdecal [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_vdecal profil_raies_étalonné vitesse_de_décalage(km/s)\n"
      return ""
   }

   #--- Recalage en longueur d'onde du spectre :
   buf$audace(bufNo) load "$audace(rep_images)/$spectre"
   set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
   set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
   set crval1m [ expr $crval1*(1+$vdecal/$spcaudace(vlum)) ]
   set cdelt1m [ expr $cdelt1*(1+$vdecal/$spcaudace(vlum)) ]

   #--- Traitement du résultat :
   buf$audace(bufNo) setkwd [ list "SPC_VDEC" $vdecal float "Velocity shift" "km/s" ]
   buf$audace(bufNo) setkwd [ list "CRVAL1" $crval1m double "Wavelength at reference pixel" "angstrom" ]
   buf$audace(bufNo) setkwd [ list "CDELT1" $cdelt1m double "Wavelength dispersion" "angstrom/pixel" ]
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save "$audace(rep_images)/${spectre}_vdec"
   buf$audace(bufNo) bitpix short
   
   #--- Fin :
   ::console::affiche_resultat "Spectre décalé de $vdecal km/s sauvé sous ${spectre}_vdec\n"
   return "${spectre}_vdec"
}
#****************************************************************#


##########################################################
# Procedure de passage de la calibration dans le referentiel de l'etoile avec vrad
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 2016-08-03
# Date de mise à jour : 2016-08-03
# Arguments : profil_raies_étalonné vradiale
##########################################################

proc spc_calrestframe { args } {
   global conf audace spcaudace

   if { [ llength $args ] == 2 } {
      set spectre [ file rootname [ lindex $args 0 ] ]
      set vradiale [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_calrestframe profil_raies_étalonné vitesse_radiale(km/s)\n"
      return ""
   }

   #--- Calcul de la vitesse de correction :
   set vdecal [ expr -1.0*$vradiale ]

   #--- Correction du spectre :
   set file_result [ spc_vdecal "$spectre" $vdecal ]
   
   #--- Fin :
   ::console::affiche_resultat "Spectre décalé de $vdecal km/s sauvé sous $file_result\n"
   return "$file_result"
}
#****************************************************************#





##########################################################
# Procedure de test si un spectre est un PROFIL qui est CALIBRE
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 03-08-2007
# Date de mise à jour : 03-08-2007
# Arguments : spectre
# Sortie : retourne 1 si c'est un profil de raies calibré, sinon 0, si spectre 2D -1
##########################################################

proc spc_testcalibre { args } {

   global audace
   global conf

   if { [llength $args] == 1 } {
      set lampe [ lindex $args 0 ]
      set flag_calibration 0

      buf$audace(bufNo) load "$audace(rep_images)/$lampe"
      set listemotsclef [ buf$audace(bufNo) getkwds ]
      #--- NAXIS2 n'existe pas :
      if { [ lsearch $listemotsclef "NAXIS2" ] ==-1 } {
          if { [ lsearch $listemotsclef "CUNIT1" ] != -1 } {
              set cunit1 [ lindex [ buf$audace(bufNo) getkwd "CUNIT1" ] 1 ]
              if { $cunit1=="angstrom" || $cunit1=="Angstrom" || $cunit1=="angstroms" || $cunit1=="Angstroms" } {
                  set flag_calibration 1
              } else {
                  ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier.\n"
                  tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier."
                  set flag_calibration -1
              }
          } else {
          #-- CUNIT1 n'existe pas, donc test sur CRVAL1 :
              if { [ lsearch $listemotsclef "CRVAL1" ] != -1 } {
                  set crval1 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
                  if { $crval1 != 1. } {
                      set flag_calibration 1
                  } else {
                      ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier.\n"
                      tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier."
                      set flag_calibration -1
                  }
              } else {
                  ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier.\n"
                  tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier."
                  set flag_calibration -1
              }
          }
      } else {
      #--- NAXIS2 existe :
          set naxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
          #-- NAXIS2 est égale à 1 :
          if { $naxis2==1 } {
              if { [ lsearch $listemotsclef "CUNIT1" ] != -1 } {
                  set cunit1 [ lindex [ buf$audace(bufNo) getkwd "CUNIT1" ] 1 ]
                  if { $cunit1=="angstrom" || $cunit1=="Angstrom" || $cunit1=="angstroms" || $cunit1=="Angstroms" } {
                      set flag_calibration 1
                  } else {
                      ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier.\n"
                      tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier."
                      set flag_calibration -1
                  }
              } else {
                      ::console::affiche_resultat "\n Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier.\n"
                      tk_messageBox -title "Erreur de saisie" -icon error -message "Le fichier de la lampe de calibration n'est pas un spectre 2D ou 1D calibré.\nVeuillez choisir le bon fichier."
                      set flag_calibration -1
              }
          } else {
          #-- NAXIS2 est différent de 1 : ce spectre est à traiter.
              set flag_calibration 0
          }
      }

      return $flag_calibration
   } else {
      ::console::affiche_erreur "Usage: spc_testcalibre spectre_fits_à_tester\n\n"
   }
}














#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#            Correction de la réponse instrumentale                          #
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#


##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Nouvelle version : 25-08-12 (Patrick LAILLY)
# Date de mise à jour : 20-03-06/26-08-06/23-07-2007/24-04-2011
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division
##########################################################

proc spc_rinstrum { args } {

   global audace spcaudace
   global conf
   set precision 0.0001
   #-- basse résolution si bande spectrale couverte >800A

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]


       #--- Test si c'est un cas de basse réolution () :
       #-- Meth 1 :
       # buf$audace(bufNo) load "$audace(rep_images)/$result_division"
       # set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       #if { $dispersion>=$spcaudace(dmax) } {
       #    set flag_br 1
       #} else {
       #    set flag_br 0
       #}
       #-- Meth 2 : (071009) gère le cas où CDELT1 n'est pas cohérent avec SPC_B (spectre initalialement non-linéaires issus de spc_calibren $a1)
       buf$audace(bufNo) load "$audace(rep_images)/$fichier_mes"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
           set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
           set bp [ expr $dispersion*$naxis1 ]
           if { $bp >= $spcaudace(bp_br) } {
               set flag_br 1
           } else {
               set flag_br 0
           }
       } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
           set bp [ expr $dispersion*$naxis1 ]
           if { $bp >= $spcaudace(bp_br) } {
               set flag_br 1
           } else {
               set flag_br 0
           }
       }


       #--- Rééchanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nRééchantillonnage du spectre de référence...\n"
       if { $flag_br==1 } {
          #::console::affiche_erreur "BR echant\n"
          set fref_echant [ spc_echantmodel $fichier_mes $fichier_ref ]
          set fmes_lin [ spc_linearcal $fichier_mes ]
          set fref_sortie [ spc_echant $fref_echant $fmes_lin ]
          file delete -force "$audace(rep_images)/$fref_echant$conf(extension,defaut)"
       } else {
          set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]
       }

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]
       if { $flag_br==1 } {
          set result_division_nl [ spc_divbrut $fmes_lin $fref_sortie ]
          file delete -force "$audace(rep_images)/$fmes_lin$conf(extension,defaut)"
       } else {
          set result_division_nl [ spc_divbrut $fmes_sortie $fref_sortie ]
       }

       set result_division [ spc_linearcal $result_division_nl ]
       file delete -force "$audace(rep_images)/$result_division_nl$conf(extension,defaut)"

       #--- Ajout du nom du spectre de bibliotheque dans l'entete :
       buf$audace(bufNo) load "$audace(rep_images)/$result_division"
       buf$audace(bufNo) setkwd [ list "SPC_REFL" "$fichier_ref" string "Reference spectrum used from library" "" ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/$result_division"
       buf$audace(bufNo) bitpix short
      
       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la réponse instrumentale...\n"
       #-- Meth 1 :
       #set rinstrum1 [ spc_smooth2 $rinstrum0 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 ]
       #set rinstrum [ spc_passebas $rinstrum3 ]

       #-- Meth2 pour 2400 t/mm : 3 passebas (110, 35, 10) + spc_smooth2.
       #set rinstrum1 [ spc_passebas $rinstrum0 110 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 35 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 10 ]
       #set rinstrum [ spc_smooth2 $rinstrum3 ]

       #-- Meth 6 : filtrage linéaire par morçeaux -> RI 0 spéciale basse résulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"


       #--- Lissage du résultat de la division :
       if { $flag_br==0 } {
           #-- Meth 3 : interpolation polynomiale de degré 1 -> RI 1 (INUTILE CE JOUR 20160201)
           # set rinstrum [ spc_ajustrid1 $result_division "o" ]
           # file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-1$conf(extension,defaut)"
          
           #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
           ##set rinstrum [ spc_ajustripbas $result_division ]
           ##file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"

           #-- Meth 6 : filtrage passe bas fort -> RI 2
           set rinstrum [ spc_ajustripbasfort $result_division "o" ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-2$conf(extension,defaut)"
           
           #-- Meth 4 : interpolation polynomiale de 4 -> RI 3
           #- set rinstrum [ spc_polynomefilter $result_division 3 150 o ]
           set rinstrum [ spc_polynomefilter $result_division 3 150 "o" ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"

           #-- Evite les valeurs trop petites de la RI :
           if { 1==0 } {
           set rinstrum_off [ spc_offset "$rinstrum" 0.5 ]
           file delete -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)"
           file rename -force "$audace(rep_images)/$rinstrum_off$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"
           }
       } elseif { $flag_br==1 } {
           if { $dispersion<=1. && $dispersion>0.2 } {
               #-- Lhires3+résos 600 t/mm et 1200 t/mm-kaf1600 :
               ::console::affiche_resultat "\n~~~ Calcul de la RI pour un spectre au 600 t/mm... ~~~\n"
               ## set rinstrum [ spc_pwlfilter $result_division 280 o 51 201 10 2 50 ]
               # set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.3 10000 { 1.0 2.0 } "o" 18 ]
	      # La version lissee du resultat division etant, dans un premier temps, representee par une fonction lineaire par morceaux, la valeur 50 apparaissant ci-dessous est la largeur des morceaux exprimee en nombre d'echantillons
               set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.0 6. { 1.0 1.0 10000000. 1. } "o" 50 ]
           } elseif { $dispersion<=0.2 } {
           #-- Spectres eShell :
              ::console::affiche_resultat "\n~~~ Calcul de la RI pour un spectre eShell... ~~~\n"
              # set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_eshell.dat" 1. 8. { 1.0 1.0 } "o" 200 ]
              set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_eshell.dat" 1. 9. { 1.0 1.0 } "o" 800 ]
           } else {
           #-- Lhires3+résos 300 et 150 t/mm :
              ::console::affiche_resultat "\n~~~ Calcul de la RI pour un spectre basse résolution... ~~~\n"
              ## set rinstrum [ spc_pwlfilter $result_division 50 o 11 51 70 50 100 ]
              # set rinstrum [ spc_pwlfilter $result_division 24 o 3 3 50 50 50 ]
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 10 { 1.0 2.0 } "o" 18 ]
              #- avant 20120309 :
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 1.7 { 1. 5. 1500. } "o" 18 ]
              #- a partir de 20120309 :
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 3. { 1. 10. 100. 500. 500. } "o" 18 ]
              #- a partir de 20140622 : spc_ commente dans piecewise
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 3. { 1. 10. 100. 500. 500. } "o" 3 ]
              #- 20140929 :
              ## set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 3. { 1. 10. 100. 500. 500. } "o" 20 ]
              ## set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 4. { 1. 10. 100. 500. 500. } "o" 7 ]
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 3. { 1. 10. 100. 500. 500. } "o" 7 ]
              #- set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 6. { 100. 10. 100. 500. 500. } "o" 7 ]
              #set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 3.5 { 10. 10. 100. 500. 500. } "o" 7 ]
              set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_sa.dat" 1.1 3.7 { 10. 10. 100. 500. 500. } "o" 7 ]
           }
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)"
          
          #-- Evite une mauvaise correction dans le bleu (trop intense) avec des valeurs trop faibles de la RI :
          if { 1==0 } {
             set rinstrum_norma [ spc_rescalecont "$rinstrum" 6300 ]
             file delete -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)"
             #set rinstrum_off [ spc_offset "$rinstrum_norma" 0.001 ]
             #file delete -force "$audace(rep_images)/$rinstrum_norma$conf(extension,defaut)"
             buf$audace(bufNo) load "$audace(rep_images)/$rinstrum_norma"
             buf$audace(bufNo) mult 1.0
             buf$audace(bufNo) offset 0.1 ; # 0.01
             buf$audace(bufNo) save "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)"
             file delete -force "$audace(rep_images)/$rinstrum_norma$conf(extension,defaut)"
             #file rename -force "$audace(rep_images)/$rinstrum_off$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)"
          }
       }


       #--- Nettoyage des fichiers temporaires :
       file rename -force "$audace(rep_images)/$result_division$conf(extension,defaut)" "$audace(rep_images)/resultat_division$conf(extension,defaut)"
       #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"

       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       if { $fref_sortie != $fichier_ref } {
           #- A decommenter :
           file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       }
       if { $rinstrum == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
          if { $flag_br == 1 } {
             ::console::affiche_erreur "Réponse instrumentale sauvée sous reponse_instrumentale-br$conf(extension,defaut)\n"
             #return reponse_instrumentale-br
             return reponse_instrumentale-
          } else {
             #-- Résultat de la division :
             ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
             ::console::affiche_erreur "Réponse instrumentale sauvée sous reponse_instrumentale-3$conf(extension,defaut)\n"
             #-- Le postfix sera soit 1, 2, 3 :
             return reponse_instrumentale-
          }
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#

##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06/23-07-2007/24-04-2011
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division
##########################################################

proc spc_rinstrum_old { args } {

   global audace spcaudace
   global conf
   set precision 0.0001
   #-- basse résolution si bande spectrale couverte >800A

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]


       #--- Rééchanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nRééchantillonnage du spectre de référence...\n"
       set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       # set result_division_tot [ spc_divbrut $fmes_sortie $fref_sortie ]

       #--- Mise à 0 des bords par sécurité et propreté, en attendant une gestion des effets de bords :
       # set result_division [ spc_bordsnuls $result_division_tot ]
       # file delete -force "$audace(rep_images)/$result_division_tot"

       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la réponse instrumentale...\n"
       #-- Meth 1 :
       #set rinstrum1 [ spc_smooth2 $rinstrum0 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 ]
       #set rinstrum [ spc_passebas $rinstrum3 ]

       #-- Meth2 pour 2400 t/mm : 3 passebas (110, 35, 10) + spc_smooth2.
       #set rinstrum1 [ spc_passebas $rinstrum0 110 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 35 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 10 ]
       #set rinstrum [ spc_smooth2 $rinstrum3 ]

       #-- Meth 6 : filtrage linéaire par morçeaux -> RI 0 spéciale basse résulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"

       #--- Test si c'est un cas de basse réolution () :
       #-- Meth 1 :
       # buf$audace(bufNo) load "$audace(rep_images)/$result_division"
       # set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       #if { $dispersion>=$spcaudace(dmax) } {
       #    set flag_br 1
       #} else {
       #    set flag_br 0
       #}
       #-- Meth 2 : (071009) gère le cas où CDELT1 n'est pas cohérent avec SPC_B (spectre initalialement non-linéaires issus de spc_calibren $a1)
       buf$audace(bufNo) load "$audace(rep_images)/$result_division"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
           set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
           set bp [ expr $dispersion*$naxis1 ]
           if { $bp >= $spcaudace(bp_br) } {
               set flag_br 1
           } else {
               set flag_br 0
           }
       } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
           set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
           set bp [ expr $dispersion*$naxis1 ]
           if { $bp >= $spcaudace(bp_br) } {
               set flag_br 1
           } else {
               set flag_br 0
           }
       }


       #--- Lissage du résultat de la division :
       if { $flag_br==0 } {
           #-- Meth 3 : interpolation polynomiale de degré 1 -> RI 1
           set rinstrum [ spc_ajustrid1 $result_division "o" ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-1$conf(extension,defaut)"
           #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
           #set rinstrum [ spc_ajustripbas $result_division ]
           #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"
           #-- Meth 6 : filtrage passe bas fort -> RI 2
           set rinstrum [ spc_ajustripbasfort $result_division "o" ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-2$conf(extension,defaut)"
           #-- Meth 4 : interpolation polynomiale de 4 -> RI 3
           #- set rinstrum [ spc_polynomefilter $result_division 3 150 o ]
           set rinstrum [ spc_polynomefilter $result_division 3 150 "o" ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)"
       } elseif { $flag_br==1 } {
           if { $dispersion<=1. && $dispersion>0.2 } {
               #-- Lhires3+résos 600 t/mm et 1200 t/mm-kaf1600 :
               ## set rinstrum [ spc_pwlfilter $result_division 280 o 51 201 10 2 50 ]
               # set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.3 10000 { 1.0 2.0 } "o" 18 ]
	      # La version lissee du resultat division etant, dans un premier temps, representee par une fonction lineaire par morceaux, la valeur 50 apparaissant ci-dessous est la largeur des morceaux exprimee en nombre d'echantillons
               set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.0 6. { 1.0 1.0 10000000. 1. } "o" 50 ]
           } elseif { $dispersion<=0.2 } {
           #-- Spectres eShell :
              ::console::affiche_resultat "\n~~~ Calcul de la RI pour un spectre eShell... ~~~\n"
              # set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_eshell.dat" 1. 8. { 1.0 1.0 } "o" 200 ]
              set rinstrum [  spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda_eshell.dat" 1. 9. { 1.0 1.0 } "o" 800 ]
           } else {
           #-- Lhires3+résos 300 et 150 t/mm :
              ## set rinstrum [ spc_pwlfilter $result_division 50 o 11 51 70 50 100 ]
              # set rinstrum [ spc_pwlfilter $result_division 24 o 3 3 50 50 50 ]
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 10 { 1.0 2.0 } "o" 18 ]
              # avant 20120309 :
              # set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 1.7 { 1. 5. 1500. } "o" 18 ]
              # a partir de 20120309 :
              set rinstrum [ spc_lowresfilterfile $result_division "$spcaudace(reptelluric)/forgetlambda.dat" 1.1 3. { 1. 10. 100. 500. 500. } "o" 18 ]
           }
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)"
       }


       #--- Nettoyage des fichiers temporaires :
       file rename -force "$audace(rep_images)/$result_division$conf(extension,defaut)" "$audace(rep_images)/resultat_division$conf(extension,defaut)"
       #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"

       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       if { $fref_sortie != $fichier_ref } {
           #- A decommenter :
           #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       }
       if { $rinstrum == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
          if { $flag_br == 1 } {
             ::console::affiche_erreur "Réponse instrumentale sauvée sous reponse_instrumentale-br$conf(extension,defaut)\n"
             #return reponse_instrumentale-br
             return reponse_instrumentale-
          } else {
             #-- Résultat de la division :
             ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
             ::console::affiche_erreur "Réponse instrumentale sauvée sous reponse_instrumentale-3$conf(extension,defaut)\n"
             #-- Le postfix sera soit 1, 2, 3 :
             return reponse_instrumentale-
          }
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#



##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06/23-07-2007
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division
##########################################################

proc spc_rinstrum2 { args } {

   global audace
   global conf
   set precision 0.0001

   set nbargs [ llength $args ]
   if { $nbargs<=3 } {
       if { $nbargs==2 } {
           set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
           set fichier_ref [ file rootname [ lindex $args 1 ] ]
           set ribr "n"
       } elseif { $nbargs==3 } {
           set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
           set fichier_ref [ file rootname [ lindex $args 1 ] ]
           set ribr [ lindex $args 2 ]
       } else {
           ::console::affiche_erreur "Usage: spc_rinstrum2 profil_de_raies_mesuré profil_de_raies_de_référence ?option basse résolution >800A (o/n)?\n\n"
           return 0
       }


       #--- Rééchanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nRééchantillonnage du spectre de référence...\n"
       set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]


       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la réponse instrumentale...\n"
       #-- Meth 1 :
       #set rinstrum1 [ spc_smooth2 $rinstrum0 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 ]
       #set rinstrum [ spc_passebas $rinstrum3 ]

       #-- Meth2 pour 2400 t/mm : 3 passebas (110, 35, 10) + spc_smooth2.
       #set rinstrum1 [ spc_passebas $rinstrum0 110 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 35 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 10 ]
       #set rinstrum [ spc_smooth2 $rinstrum3 ]

       #-- Meth 6 : filtrage linéaire par morçeaux -> RI 0 spéciale basse résulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"

       if { $ribr=="n" } {
           #-- Meth 3 : interpolation polynomiale de degré 1 -> RI 1
           set rinstrum [ spc_ajustrid1 $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale1$conf(extension,defaut)"
           #-- Meth 4 : interpolation polynomiale de 2 -> RI 2
           set rinstrum [ spc_ajustrid2 $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale2$conf(extension,defaut)"

           #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
           set rinstrum [ spc_ajustripbas $result_division ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale3$conf(extension,defaut)"
       } elseif { $ribr=="o" } {
           set rinstrum [ spc_pwlfilter $result_division 50 o 11 51 70 50 100 ]
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"
       }


       #--- Nettoyage des fichiers temporaires :
       file rename -force "$audace(rep_images)/$result_division$conf(extension,defaut)" "$audace(rep_images)/resultat_division$conf(extension,defaut)"
       #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"

       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       if { $fref_sortie != $fichier_ref } {
           #- A decommenter :
           #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       }
       if { $rinstrum == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           #-- Résultat de la division :
           ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
           ::console::affiche_resultat "Réponse instrumentale sauvée sous reponse_instrumentale3$conf(extension,defaut)\n"
           return reponse_instrumentale3
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum2 profil_de_raies_mesuré profil_de_raies_de_référence ?option basse résolution >800A (o/n)?\n\n"
   }
}
#****************************************************************#



##########################################################
# Effectue la correction de la réponse intrumentale à l'aide du profil_a_corriger, profil_étoile_référence et profil_étoile_catalogue
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 14-07-2006
# Date de mise à jour : 14-07-2006
# Arguments : profil_a_corriger profil_étoile_référence profil_étoile_catalogue
##########################################################

proc spc_rinstrumcorr { args } {

   global audace
   global conf
   if { [llength $args] == 3 } {
       set spectre_acorr [ file rootname [ lindex $args 0 ] ]
       set etoile_ref [ file rootname [ lindex $args 1 ] ]
       set etoile_cat [ file rootname [ lindex $args 2 ] ]

       set rinstrum [ spc_rinstrum $etoile_ref $etoile_cat ]
       #set rinstrum_ech [ spc_echant $rinstrum $spectre_acorr ]
       #set spectre_corr [ spc_div $spectre_acorr $rinstrum_ech ]
       #file delete "$audace(rep_images)/$rinstrum_ech$conf(extension,defaut)"
       set spectre_corr [ spc_divri $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
           ::console::affiche_resultat "\nLe profil corrigé de la réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_ricorr$conf(extension,defaut)"
           ::console::affiche_resultat "\nProfil corrigé de la réponse intrumentale sauvé sous ${spectre_acorr}_ricorr.\n\n"
           return ${spectre_acorr}_ricorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumcorr profil_a_corriger profil_étoile_référence profil_étoile_catalogue\n\n"
   }
}
#****************************************************************#




##########################################################
# Calcul la réponse intrumentale avec les raies telluriques de l'eau
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division
##########################################################

proc spc_rinstrumeau { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
           #-- Détermine le spectre de dispersion la plus précise
           set carac1 [ spc_info $fichier_mes ]
           set carac2 [ spc_info $fichier_ref ]
           set disp1 [ lindex $carac1 5 ]
           set ldeb1 [ lindex $carac1 3 ]
           set lfin1 [ lindex $carac1 4 ]
           set disp2 [ lindex $carac2 5 ]
           set ldeb2 [ lindex $carac2 3 ]
           set lfin2 [ lindex $carac2 4 ]
           if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Rééchantillonnage et crop du spectre de référence fichier_ref
               ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
               #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
               set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               set fref_sel_ech [ spc_echant $fref_sel $fichier_mes ]
               set fref_sortie $fref_sel_ech
               set fmes_sortie $fichier_mes

               #- Dans cet ordre, permet d'obtenir le vertiable continuum :
               #set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               #set fref_ech_sel [ spc_select $fref_ech $ldeb1 $lfin1 ]
               #set fref_sortie $fref_ech_sel
               #set fmes_sortie $fichier_mes
           } elseif { $disp2<$disp1 && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
               ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_sortie $fref_ech
               set fmes_sortie $fmes_sel
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
               set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               set fref_sortie $fref_sel
               set fmes_sortie $fichier_mes
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_sortie $fichier_ref
               set fmes_sortie $fmes_sel
           } else {
               #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
               ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
           }
       } else {
           #-- Aucun rééchantillonnage ni redécoupage nécessaire
           ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
           set fref_sortie $fichier_ref
           set fmes_sortie $fichier_mes
       }

       #--- Linéarisation des deux profils de raies
       ::console::affiche_resultat "Linéarisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth $fref_sortie ]
       set fmes_ready [ spc_bigsmooth $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]
       #-- Rééchantillonne le continuum avec l'eau pour obtenir la même dispersion que celle du spectre de mesures :
       #set rinstrumeau [ spc_echant $rinstrum $fichier_mes ]
       set rinstrumeau $rinstrum

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrumeau == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           file rename -force "$audace(rep_images)/$rinstrumeau$conf(extension,defaut)" "$audace(rep_images)/${fichier_mes}_rinstrumeau$conf(extension,defaut)"
           ::console::affiche_resultat "Réponse instrumentale sauvée sous ${fichier_mes}_rinstrumeau$conf(extension,defaut)\n"
           return ${fichier_mes}_rinstrumeau
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumeau profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#


##########################################################
# Effectue la correction de la réponse intrumentale à l'aide du profil_a_corriger, profil_étoile_référence et profil_étoile_catalogue *** tout en retirant les raies telluriques ***
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 25-08-2006
# Date de mise à jour : 25-08-2006
# Arguments : profil_a_corriger profil_étoile_référence profil_étoile_catalogue
##########################################################

proc spc_rinstrumeaucorr { args } {

   global audace
   global conf
   if { [llength $args] == 3 } {
       set spectre_acorr [ file rootname [ lindex $args 0 ] ]
       set etoile_ref [ file rootname [ lindex $args 1 ] ]
       set etoile_cat [ file rootname [ lindex $args 2 ] ]

       set rinstrum [ spc_rinstrumeau $etoile_ref $etoile_cat ]
       #set rinstrum_ech [ spc_echant $rinstrum $spectre_acorr ]
       #set spectre_corr [ spc_div $spectre_acorr $rinstrum_ech ]
       #file delete "$audace(rep_images)/$rinstrum_ech$conf(extension,defaut)"
       set spectre_corr [ spc_divri $spectre_acorr $rinstrum ]

       if { $spectre_corr == 0 } {
           ::console::affiche_resultat "\nLe profil corrigé de la réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           file rename -force "$audace(rep_images)/$spectre_corr$conf(extension,defaut)" "$audace(rep_images)/${spectre_acorr}_riocorr$conf(extension,defaut)"
           ::console::affiche_resultat "\nProfil corrigé de la réponse intrumentale et des raies tellurtiques sauvé sous ${spectre_acorr}_riocorr.\n\n"
           return ${spectre_acorr}_riocorr
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrumeaucorr profil_a_corriger profil_étoile_référence profil_étoile_catalogue\n\n"
   }
}
#****************************************************************#




####################################################################
# Procedure d'ajustement d'un nuage de points de réponse instrumentale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 27-02-2007
# Date modification : 27-02-2007
# Arguments : fichier .fit de la réponse instrumentale
# Algo : ajustement par un polynome de degré 1 avec abaissement global basé sur la moyenne de la difference des valeurs y_deb et y_fin de l'intervalle.
####################################################################

proc spc_ajustrid1 { args } {
    global conf
    global audace

   if { [llength $args] == 1} {
      set filenamespc [ lindex $args 0 ]
      set gflag "n"
   } elseif { [llength $args] == 2} {
      set filenamespc [ lindex $args 0 ]
      set gflag [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ajustrid1 fichier_profil.fit ?affichage graph (o/N)?\n\n"
      return ""
   }


        #--- Initialisation des paramètres et des données :
        set erreur 1.
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set len [ llength $ordonnees ]
        set limits [ spc_findnnul $ordonnees ]
        set i_inf [ lindex $limits 0 ]
        set i_sup [ lindex $limits 1 ]

        #--- Calcul des coefficients du polynôme d'ajustement :
        # - calcul de la matrice X
        set ordonnees_cut [ list ]
        set X ""
        for {set i $i_inf} {$i<$i_sup} {incr i} {
            set xi [ lindex $abscisses $i ]
            set ligne_i 1
            lappend ordonnees_cut [ lindex $ordonnees $i ]
            lappend erreurs $erreur
            lappend ligne_i $xi
            lappend X $ligne_i
        }
        #-- calcul de l'ajustement
        set result [ gsl_mfitmultilin $ordonnees_cut $X $erreurs ]
        #-- extrait le resultat
        set coeffs [lindex $result 0]
        set chi2 [lindex $result 1]
        set covar [lindex $result 2]

        set a [lindex $coeffs 0]
        set b [lindex $coeffs 1]
        ::console::affiche_resultat "Coefficients de la droite d'interpolation : $a+$b*x\n"


        #--- Met a jour les nouvelles intensités :
        buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        for {set k 1} {$k<=$naxis1} {incr k} {
            set x [ lindex $abscisses [ expr $k-1 ] ]
            set y [ lindex $ordonnees [ expr $k-1 ] ]
            if { $y==0 } {
                set yadj 0.
            } else {
                set yadj [ expr $a+$b*$x ]
            }
            lappend yadjs $yadj
            buf$audace(bufNo) setpix [list $k 1] $yadj
        }


        #--- Affichage du graphe
       if { $gflag=="o" } {
        ::plotxy::figure 1
        #::plotxy::clf
        ::plotxy::plot $abscisses $yadjs g 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ::plotxy::title "bleu : Résultat division - rouge : RI interpolée deg 1"
        ::plotxy::hold off
       }

        #--- Sauvegarde du résultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points de réponse instrumentale
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-02-2007
# Date modification : 26-02-2007
# Arguments : fichier .fit de la réponse instrumentale
# Algo : ajustement par un polynome de degré 2 avec abaissement global basé sur la moyenne de la difference des valeurs y_deb et y_fin de l'intervalle.
####################################################################

proc spc_ajustrid2 { args } {
    global conf
    global audace spcaudace

    if {[llength $args] == 1} {
        set filenamespc [ lindex $args 0 ]

        #--- Initialisation des paramètres et des données :
        set erreur 1.
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [lindex $contenu 0]
        set ordonnees [lindex $contenu 1]
        set len [llength $ordonnees]
        set limits [ spc_findnnul $ordonnees ]
        set i_inf [ lindex $limits 0 ]
        set i_sup [ lindex $limits 1 ]

        #--- Calcul des coefficients du polynôme d'ajustement :
        # - calcul de la matrice X
        set n [llength $abscisses]
        set ordonnees_cut [ list ]
        set X ""
        for {set i $i_inf} {$i<$i_sup} {incr i} {
            set xi [lindex $abscisses $i]
            set ligne_i 1
            lappend ordonnees_cut [ lindex $ordonnees $i ]
            lappend erreurs $erreur
            lappend ligne_i $xi
            lappend ligne_i [expr $xi*$xi]
            lappend X $ligne_i
        }
        #-- calcul de l'ajustement
        set result [ gsl_mfitmultilin $ordonnees_cut $X $erreurs ]
        #-- extrait le resultat
        set coeffs [lindex $result 0]
        set chi2 [lindex $result 1]
        set covar [lindex $result 2]

        set a [lindex $coeffs 0]
        set b [lindex $coeffs 1]
        set c [lindex $coeffs 2]
        ::console::affiche_resultat "Coefficients du polynôme : $a+$b*x+$c*x^2\n"

        #--- Calcul la valeur a retrancher : basée sur la difference moyenne y_deb et y_fin calculee par rapport aux mesures :
        set ecart [ expr round($len*$spcaudace(bordsnuls)) ]
        set xdeb [ lindex $abscisses $ecart ]
        set xfin [ lindex $abscisses [ expr $len-$ecart-1 ] ]
        set ycalc_deb [ expr $a+$b*$xdeb+$c*$xdeb*$xdeb ]
        set ycalc_fin [ expr $a+$b*$xfin+$c*$xfin*$xfin ]
        set ymes_deb [ lindex $ordonnees $ecart ]
        set ymes_fin [ lindex $ordonnees [ expr $len-$ecart-1 ] ]
        #::console::affiche_resultat "$ycalc_deb ; $ycalc_fin ; $ymes_deb ; $ymes_fin\n"
        ## set dy_moy [ expr 0.5*(abs($ycalc_deb-$ymes_deb)+abs($ycalc_fin-$ymes_fin)) ]
        set dy_moy [ expr 0.5*($ycalc_deb-$ymes_deb+$ycalc_fin-$ymes_fin) ]
        # Pujol 070930 : set dy_moy [ expr 0.29*($ycalc_deb-$ymes_deb+$ycalc_fin-$ymes_fin) ]
        #::console::affiche_resultat "Offset à retrancher : $dy_moy\n"
        set aadj [ expr $a-$dy_moy ]
        #set aadj $a

        #--- Met a jour les nouvelles intensités :
        buf$audace(bufNo) load "$audace(rep_images)/$filenamespc"
        set naxis1 [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
        for {set k 1} {$k<=$naxis1} {incr k} {
            set x [ lindex $abscisses [ expr $k-1 ] ]
            set y [ lindex $ordonnees [ expr $k-1 ] ]
            if { $y==0 } {
                set yadj 0.
            } else {
                # set yadj [ expr $a+$b*$x+$c*$x*$x ]
                set yadj [ expr $aadj+$b*$x+$c*$x*$x ]
            }
            lappend yadjs $yadj
            buf$audace(bufNo) setpix [list $k 1] $yadj
        }


        #--- Affichage du graphe
        #::plotxy::clf
        ::plotxy::figure 2
        ::plotxy::plot $abscisses $yadjs r 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ::plotxy::title "bleu : Résultat division - rouge : RI interpolée deg 2"
        ::plotxy::hold off


        #--- Sauvegarde du résultat :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        buf$audace(bufNo) bitpix short
        ::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajustrid2 fichier_profil.fit\n\n"
    }
}
#****************************************************************#



####################################################################
# Procedure d'ajustement d'un nuage de points
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 03-03-2007
# Date modification : 03-03-2007
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajustripbas { args } {
    global conf
    global audace

    if { [ llength $args ]==1 } {
        set filenamespc [ lindex $args 0 ]

        #--- Filtrages passe-bas :
        set rinstrum1 [ spc_passebas $filenamespc ]
        set rinstrum2 [ spc_passebas $rinstrum1 ]
        set rinstrum [ spc_smooth2 $rinstrum2 ]

        #--- Effacement des fichiers intermédiaires :
        file delete -force "$audace(rep_images)/$rinstrum1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$rinstrum2$conf(extension,defaut)"

        #--- Extraction des données :
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set yadjs [ lindex [ spc_fits2data $rinstrum ] 1 ]

        #--- Affichage du graphe
        #::plotxy::clf
        ::plotxy::figure 2
        ::plotxy::plot $abscisses $yadjs r 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ::plotxy::title "bleu : Résultat division - rouge : RI filtrée passe bas"
        ::plotxy::hold off

        #--- Retour du résultat :
        file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        ::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
    } else {
        ::console::affiche_erreur "Usage: spc_ajustripbas fichier_profil.fit\n\n"
    }
}
#****************************************************************#


####################################################################
# Procedure d'ajustement d'un nuage de points avec fort lissage
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 13-02-2008
# Date modification : 13-02-2008
# Arguments : fichier .fit du profil de raie
####################################################################

proc spc_ajustripbasfort { args } {
    global conf
    global audace

    if { [ llength $args ]==1 } {
       set filenamespc [ lindex $args 0 ]
       set gflag "n"
    } elseif { [ llength $args ]==2 } {
       set filenamespc [ lindex $args 0 ]
       set gflag [ lindex $args 1 ]
    } else {
       ::console::affiche_erreur "Usage: spc_ajustripbasfort fichier_profil.fit ?trace graphique (o/N)?\n\n"
       return ""
    }

        #--- Filtrages passe-bas :
        set rinstrum1 [ spc_passebas $filenamespc 200 ]
        set rinstrum2 [ spc_smooth2 $rinstrum1 ]
        set rinstrum3 [ spc_passebas $rinstrum2 100 ]
        set rinstrum [ spc_passebas $rinstrum3 25 ]

        #--- Effacement des fichiers intermédiaires :
        file delete -force "$audace(rep_images)/$rinstrum1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$rinstrum2$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$rinstrum3$conf(extension,defaut)"

        #--- Extraction des données :
        set contenu [ spc_fits2data $filenamespc ]
        set abscisses [ lindex $contenu 0 ]
        set ordonnees [ lindex $contenu 1 ]
        set yadjs [ lindex [ spc_fits2data $rinstrum ] 1 ]

        #--- Affichage du graphe
   if { $gflag=="o" } {
        #::plotxy::clf
        ::plotxy::figure 2
        ::plotxy::plot $abscisses $yadjs r 1
        ::plotxy::hold on
        ::plotxy::plot $abscisses $ordonnees ob 0
        ::plotxy::plotbackground #FFFFFF
        ::plotxy::title "bleu : Résultat division - rouge : filtrage passe bas fort"
        ::plotxy::hold off
     }
        #--- Retour du résultat :
        file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${filenamespc}_lin$conf(extension,defaut)"
        ::console::affiche_resultat "Fichier fits sauvé sous ${filenamespc}_lin$conf(extension,defaut)\n"
        return ${filenamespc}_lin
}
#****************************************************************#























#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



####################################################################################
# Ancienne version des fonctions
####################################################################################



if {1==0} {


##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division
##########################################################

proc spc_rinstrum_23-07-2007 { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

     #===================================================================#
     if { 1==0 } {
       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
           #-- Détermine le spectre de dispersion la plus précise
           set carac1 [ spc_info $fichier_mes ]
           set carac2 [ spc_info $fichier_ref ]
           set disp1 [ lindex $carac1 5 ]
           set ldeb1 [ lindex $carac1 3 ]
           set lfin1 [ lindex $carac1 4 ]
           set disp2 [ lindex $carac2 5 ]
           set ldeb2 [ lindex $carac2 3 ]
           set lfin2 [ lindex $carac2 4 ]
           if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Rééchantillonnage et crop du spectre de référence fichier_ref
               ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
               #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
               #set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               #set fref_sel_ech [ spc_echant $fref_sel $fichier_mes ]
               #set fref_sortie $fref_sel_ech
               #set fmes_sortie $fichier_mes

               #- Dans cet ordre, permet d'obtenir le vertiable continuum :
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_ech_sel [ spc_select $fref_ech $ldeb1 $lfin1 ]
               set fref_sortie $fref_ech_sel
               set fmes_sortie $fichier_mes
           } elseif { $disp2<$disp1 && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
               ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_sortie $fref_ech
               set fmes_sortie $fmes_sel
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
               set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               set fref_sortie $fref_sel
               set fmes_sortie $fichier_mes
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_sortie $fichier_ref
               set fmes_sortie $fmes_sel
           } else {
               #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
               ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
           }
       } else {
           #-- Aucun rééchantillonnage ni redécoupage nécessaire
           ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
           set fref_sortie $fichier_ref
           set fmes_sortie $fichier_mes
       }
    }
    #======================================================================#

       #--- Rééchanetillonnage du profil du catalogue :
       #set fref_sortie $fichier_ref
       set fmes_sortie $fichier_mes
       ::console::affiche_resultat "\nRééchantillonnage du spectre de référence...\n"
       set fref_sortie [ spc_echant $fichier_ref $fichier_mes ]

    if {1==0} {
       #--- Recalage du profil de catalogue sur le pixel central du capteur :
       buf$audace(bufNo) load "$audace(rep_images)/$fichier_mes"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       set naxis1m [ expr int(0.5*[ lindex [buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]) ]
       set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set lambdam_mes [ expr $lambda0+$cdelt1*$naxis1m ]
       if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
           set spc_a [ lindex [ buf$audace(bufNo) getkwd "SPC_A" ] 1 ]
           set spc_b [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
           set spc_c [ lindex [ buf$audace(bufNo) getkwd "SPC_C" ] 1 ]
           if { [ lsearch $listemotsclef "SPC_D" ] !=-1 } {
               set spc_d [ lindex [ buf$audace(bufNo) getkwd "SPC_D" ] 1 ]
           } else {
               set spc_d 0.0
           }
           set lambdam_mes [ expr $spc_a+$spc_b*$naxis1m+$spc_c*pow($naxis1m,2)+$spc_d*pow($naxis1m,3) ]
       } else {
           set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
           set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
           set lambdam_mes [ expr $lambda0+$cdelt1*$naxis1m ]
       }
       buf$audace(bufNo) load "$audace(rep_images)/$fref_sortie"
       set naxis1m [ expr int(0.5*[ lindex [buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]) ]
       set lambda0 [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ]
       set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set lambdam_ref [ expr $lambda0+$cdelt1*$naxis1m ]
       set deltal [ expr $lambdam_mes-$lambdam_ref ]
       if { $deltal>[ expr $cdelt1/10.] } {
           ::console::affiche_resultat "Décalage de $deltal angstroms entre les 2 profils, recalage du profil de l'étoile du catalogue...\n"
           buf$audace(bufNo) load "$audace(rep_images)/$fmes_sortie"
           set listemotsclef [ buf$audace(bufNo) getkwds ]
           set lambda0dec [ expr $lambda0+$deltal ]
           buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda0dec double "" "angstrom" ]
           if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
                buf$audace(bufNo) setkwd [list "SPC_A" $lambda0dec double "" "angstrom"]
           }
           buf$audace(bufNo) bitpix float
           buf$audace(bufNo) save "$audace(rep_images)/${fmes_sortie}_dec"
           buf$audace(bufNo) bitpix short
           set fref_sortie [ spc_echant ${fmes_sortie}_dec $fichier_ref ]
           #file delete -force "$audace(rep_images)/${fmes_sortie}_dec"
       }
   }

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "\nDivison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       #set rinstrum0 [ spc_div $fmes_sortie $fref_sortie ]
       #set result_division [ spc_div $fmes_sortie $fref_sortie ]
       set result_division [ spc_divbrut $fmes_sortie $fref_sortie ]
       #set result_division [ spc_divri $fmes_sortie $fref_sortie ]


       #--- Lissage de la reponse instrumentale :
       ::console::affiche_resultat "\nLissage de la réponse instrumentale...\n"
       #-- Meth 1 :
       #set rinstrum1 [ spc_smooth2 $rinstrum0 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 ]
       #set rinstrum [ spc_passebas $rinstrum3 ]

       #-- Meth2 pour 2400 t/mm : 3 passebas (110, 35, 10) + spc_smooth2.
       #set rinstrum1 [ spc_passebas $rinstrum0 110 ]
       #set rinstrum2 [ spc_passebas $rinstrum1 35 ]
       #set rinstrum3 [ spc_passebas $rinstrum2 10 ]
       #set rinstrum [ spc_smooth2 $rinstrum3 ]

       #-- Meth 6 : filtrage linéaire par morçeaux -> RI 0 spéciale basse résulution
       #set rinstrum0 [ spc_ajust_piecewiselinear $result_division 60 30 ]
       #set rinstrum [ spc_passebas $rinstrum0 31 ]
       # file delete "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
       #file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale_br$conf(extension,defaut)"


       #-- Meth 3 : interpolation polynomiale de degré 1 -> RI 1
       set rinstrum [ spc_ajustrid1 $result_division ]
       file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale1$conf(extension,defaut)"
       #-- Meth 4 : interpolation polynomiale de 2 -> RI 2
       set rinstrum [ spc_ajustrid2 $result_division ]
       file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale2$conf(extension,defaut)"

       #-- Meth 5 : filtrage passe bas (largeur de 25 pixls par defaut) -> RI 3
       set rinstrum [ spc_ajustripbas $result_division ]
       file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale3$conf(extension,defaut)"


       #--- Nettoyage des fichiers temporaires :
       file rename -force "$audace(rep_images)/$result_division$conf(extension,defaut)" "$audace(rep_images)/resultat_division$conf(extension,defaut)"
       #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"

       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       if { $fref_sortie != $fichier_ref } {
           #- A decommenter :
           #file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       }
       if { $rinstrum == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           #-- Résultat de la division :
           ##file delete -force "$audace(rep_images)/$rinstrum0$conf(extension,defaut)"
           ::console::affiche_resultat "Réponse instrumentale sauvée sous reponse_instrumentale3$conf(extension,defaut)\n"
           return reponse_instrumentale3
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#



####################################################################
# Procédure de calibration par un polynôme de degré 2 (au moins 3 raies nécessaires)
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2-09-2006
# Date modification : 2-09-2006
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################

proc spc_rinstrum_020905 { args } {

   global audace
   global conf

   if {[llength $args] == 2} {
       set infichier_mes [ lindex $args 0 ]
       set infichier_ref [ lindex $args 1 ]
       set fichier_mes [ file rootname $infichier_mes ]
       set fichier_ref [ file rootname $infichier_ref ]

       # Récupère les caractéristiques des 2 spectres
       buf$audace(bufNo) load $fichier_mes
       set naxis1a [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set xdeb1 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set disper1 [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin1 [ expr $xdeb1+$naxis1a*$disper1*1.0 ]
       buf$audace(bufNo) load $fichier_ref
       set naxis1b [lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1]
       set xdeb2 [lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1]
       set disper2 [lindex [buf$audace(bufNo) getkwd "CDELT1"] 1]
       set xfin2 [ expr $xdeb2+$naxis1b*$disper2*1.0 ]

       # Sélection de la bande de longueur d'onde du spectre de référence
       ## Le spectre de référence est supposé avoir une plus large bande de lambda
       set ${fichier_ref}_sel [ spc_select $fichier_ref $xdeb1 $xfin1 ]
       # Rééchantillonnage du spectre de référence : c'est un choix.
       ## Que disp1 < disp2 ou disp2 < disp1, la dispersion finale sera disp1
       set ${fichier_ref}_sel_rech [ spc_echant ${fichier_ref}_sel $disp1 ]
       file delete ${fichier_ref}_sel$conf(extension,defaut)
       # Calcul la réponse intrumentale : RP=spectre_mesure/spectre_ref
       buf$audace(bufNo) load $fichier_mes
       buf$audace(bufNo) div ${fichier_ref}_sel_rech 1.0
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save reponse_intrumentale
       ::console::affiche_resultat "Sélection sauvée sous ${fichier}_sel$conf(extension,defaut)\n"
       return ${fichier}_sel$conf(extension,defaut)
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum fichier .fit du profil de raie, profil de raie de référence\n\n"
   }
}
#****************************************************************#


##########################################################
# Calcul la réponse intrumentale et l'enregistre
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 02-09-2005
# Date de mise à jour : 20-03-06/26-08-06
# Arguments : fichier .fit du profil de raie, profil de raie de référence
# Remarque : effectue le découpage, rééchantillonnage puis la division
##########################################################

proc spc_rinstrum_060826 { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
           #-- Détermine le spectre de dispersion la plus précise
           set carac1 [ spc_info $fichier_mes ]
           set carac2 [ spc_info $fichier_ref ]
           set disp1 [ lindex $carac1 5 ]
           set ldeb1 [ lindex $carac1 3 ]
           set lfin1 [ lindex $carac1 4 ]
           set disp2 [ lindex $carac2 5 ]
           set ldeb2 [ lindex $carac2 3 ]
           set lfin2 [ lindex $carac2 4 ]
           if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Rééchantillonnage et crop du spectre de référence fichier_ref
               ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
               #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
               #set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               #set fref_sel_ech [ spc_echant $fref_sel $fichier_mes ]
               #set fref_sortie $fref_sel_ech
               #set fmes_sortie $fichier_mes

               #- Dans cet ordre, permet d'obtenir le vertiable continuum :
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_ech_sel [ spc_select $fref_ech $ldeb1 $lfin1 ]
               set fref_sortie $fref_ech_sel
               set fmes_sortie $fichier_mes
           } elseif { $disp2<$disp1 && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
               ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_sortie $fref_ech
               set fmes_sortie $fmes_sel
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
               set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               set fref_sortie $fref_sel
               set fmes_sortie $fichier_mes
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_sortie $fichier_ref
               set fmes_sortie $fmes_sel
           } else {
               #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
               ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
           }
       } else {
           #-- Aucun rééchantillonnage ni redécoupage nécessaire
           ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
           set fref_sortie $fichier_ref
           set fmes_sortie $fichier_mes
       }

       #--- Linéarisation des deux profils de raies
       ::console::affiche_resultat "Linéarisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth $fref_sortie ]
       set fmes_ready [ spc_bigsmooth $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       #set fref_ready "$fref_sortie"
       #set fmes_ready "$fmes_sortie"

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrum == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/${fichier_mes}_rinstrum$conf(extension,defaut)"
           ::console::affiche_resultat "Réponse instrumentale sauvée sous ${fichier_mes}_rinstrum$conf(extension,defaut)\n"
           return ${fichier_mes}_rinstrum
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#



proc spc_rinstrum_260806 { args } {

   global audace
   global conf
   set precision 0.0001

   if { [llength $args] == 2 } {
       set fichier_mes [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set fichier_ref [ file rootname [ lindex $args 1 ] ]

       #--- Vérifie s'il faut rééchantilonner ou non
       if { [ spc_compare $fichier_mes $fichier_ref ] == 0 } {
           #-- Détermine le spectre de dispersion la plus précise
           set carac1 [ spc_info $fichier_mes ]
           set carac2 [ spc_info $fichier_ref ]
           set disp1 [ lindex $carac1 5 ]
           set ldeb1 [ lindex $carac1 3 ]
           set lfin1 [ lindex $carac1 4 ]
           set disp2 [ lindex $carac2 5 ]
           set ldeb2 [ lindex $carac2 3 ]
           set lfin2 [ lindex $carac2 4 ]
           if { $disp1!=$disp2 && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Rééchantillonnage et crop du spectre de référence fichier_ref
               ::console::affiche_resultat "\nRééchantillonnage et crop du spectre de référence...\n\n"
               #- Dans cet ordre, permet d'obtenir un continuum avec les raies de l'eau et oscillations d'interférence, mais le continuum possède la dispersion du sepctre de référence :
               #set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               #set fref_sel_ech [ spc_echant $fref_sel $fichier_mes ]
               #set fref_sortie $fref_sel_ech
               #set fmes_sortie $fichier_mes

               #- Dans cet ordre, permet d'obtenir le vertiable continuum :
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_ech_sel [ spc_select $fref_ech $ldeb1 $lfin1 ]
               set fref_sortie $fref_ech_sel
               set fmes_sortie $fichier_mes
           } elseif { $disp2<$disp1 && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Rééchantillonnage du spectre de référence fichier_ref et crop du spectre de mesure
               ::console::affiche_resultat "\nRééchantillonnage du spectre mesuré fichier_mes et crop du spectre de référence...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_ech [ spc_echant $fichier_ref $fichier_mes ]
               set fref_sortie $fref_ech
               set fmes_sortie $fmes_sel
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2<=$ldeb1 && $lfin1<=$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de référence...\n\n"
               set fref_sel [ spc_select $fichier_ref $ldeb1 $lfin1 ]
               set fref_sortie $fref_sel
               set fmes_sortie $fichier_mes
           } elseif { [expr abs($disp2-$disp1)]<=$precision && $ldeb2>$ldeb1 && $lfin1>$lfin2 } {
               #-- Aucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures
               ::console::affiche_resultat "\nAucun rééchantillonnage nécessaire mais un redécoupage (crop) nécessaire du spectre de mesures...\n\n"
               set fmes_sel [ spc_select $fichier_mes $ldeb2 $lfin2 ]
               set fref_sortie $fichier_ref
               set fmes_sortie $fmes_sel
           } else {
               #-- Le spectre de référence ne recouvre pas les longueurs d'onde du spectre mesuré
               ::console::affiche_resultat "\nLe spectre de référence ne recouvre aucune plage de longueurs d'onde du spectre mesuré.\n\n"
           }
       } else {
           #-- Aucun rééchantillonnage ni redécoupage nécessaire
           ::console::affiche_resultat "\nAucun rééchantillonnage ni redécoupage nécessaire.\n\n"
           set fref_sortie $fichier_ref
           set fmes_sortie $fichier_mes
       }

       #--- Linéarisation des deux profils de raies
       ::console::affiche_resultat "Linéarisation des deux profils de raies...\n"
       set fref_ready [ spc_bigsmooth2 $fref_sortie ]
       set fmes_ready [ spc_bigsmooth2 $fmes_sortie ]
       file delete -force "$audace(rep_images)/${fref_sortie}$conf(extension,defaut)"
       if { $fmes_sortie != $fichier_mes } {
           file delete -force "$audace(rep_images)/${fmes_sortie}$conf(extension,defaut)"
       }
       #set fref_ready "$fref_sortie"
       #set fmes_ready "$fmes_sortie"

       #--- Divison des deux profils de raies pour obtention de la réponse intrumentale :
       ::console::affiche_resultat "Divison des deux profils de raies pour obtention de la réponse intrumentale...\n"
       set rinstrum [ spc_div $fmes_ready $fref_ready ]

       #--- Nettoyage des fichiers temporaires :
       file delete -force "$audace(rep_images)/${fref_ready}$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${fmes_ready}$conf(extension,defaut)"
       if { $rinstrum == 0 } {
           ::console::affiche_resultat "\nLa réponse intrumentale ne peut être calculée.\n"
           return 0
       } else {
           file rename -force "$audace(rep_images)/$rinstrum$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale$conf(extension,defaut)"
           ::console::affiche_resultat "Réponse instrumentale sauvée sous reponse_instrumentale$conf(extension,defaut)\n"
           return reponse_instrumentale
       }
   } else {
       ::console::affiche_erreur "Usage: spc_rinstrum profil_de_raies_mesuré profil_de_raies_de_référence\n\n"
   }
}
#****************************************************************#


####################################################################
#  Procédure d'évaluation de la non-linéarité de la dispersion d'un spectre
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 23-08-2006
# Date modification : 8-05-2007
# Arguments : nom_fichier_profil_de_raies ?liste_de_liste_intervalles_encadrant_raies?
####################################################################

proc spc_caloverif_08052007 { args } {
    global conf
    global audace

    if { [llength $args]<= 2 } {
        if { [llength $args]== 2 } {
            set spectre [ lindex $args 0 ]
            set raylist [ lindex $args 1 ]
        } elseif { [llength $args]==1 } {
            set spectre [ lindex $args 0 ]
            set raylist {{6531.781 6532.869 6532.359} {6543.4 6544.5 6543.907} {6548.1 6549.4 6548.622} {6552.1 6553.2 6552.629} {6571.7 6572.8 6572.072} {6574.3 6575.6 6574.847}}
        } else {
            ::console::affiche_erreur "Usage: spc_caloverif nom_fichier_profil_de_raies ?liste_de_liste_intervalles_encadrant_raies?\n\n"
            return ""
        }


        #--- Détermine le centre des raies mesurées et calcul la difference avec celles duc atalogue :
        set chi2 0.
        set ecart_type 0.
        foreach ray $raylist {
            set xdeb [ lindex $ray 0 ]
            set xfin [ lindex $ray 1 ]
            set lambda_cat [ lindex $ray 2 ]
            #set lambda_mes [ spc_centergaussl $spectre $xdeb $xfin e ]
            set lambda_mes [ spc_centergravl $spectre $xdeb $xfin ]
            set ldiff [ expr $lambda_mes-$lambda_cat ]
            lappend results " [ list $lambda_cat $lambda_mes $ldiff ] \n"
            #set chi2 [ expr $chi2+pow($ldiff,2)/$lambda_cat ]
            set ecart_type [ expr $ecart_type+pow($ldiff,2) ]
        }


        #--- Calcul du RMS et ecart-type :
        set nbraies [ llength $raylist ]
        buf$audace(bufNo) load "$audace(rep_images)/$spectre"
        set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
        set chi2 [ expr $ecart_type/($nbraies*pow($cdelt1,2)) ]
        set rms [ expr $cdelt1*sqrt($chi2) ]
        set ecart_type [ expr sqrt($ecart_type)/$nbraies ]


        #--- Affichage des résultats :
        ::console::affiche_resultat "Liste résultats (Lambda_cat Lambda_mes Diff) :\n $results\n"
        ::console::affiche_resultat "Sigma=$ecart_type A\nChi2=$chi2\nRMS=$rms A\n"
    } else {
        ::console::affiche_erreur "Usage: spc_caloverif nom_fichier_profil_de_raies ?liste_de_liste_intervalles_encadrant_raies?\n\n"
    }
}
#****************************************************************#


####################################################################
#  Procedure de conversion d'étalonnage en longueur d'onde d'ordre 2 : OBSOLETE
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-01-2005
# Date modification : 29-01-2005 / 09-12-2005
# Arguments : fichier .fit du profil de raie spatial
####################################################################

proc spc_calibre3pil { args } {

  global conf
  global audace
  global profilspc
  global caption

  if {[llength $args] == 7} {
    set filespc [ lindex $args 0 ]
    set pixel1 [ lindex $args 1 ]
    set lambda1 [ lindex $args 2 ]
    set pixel2 [ lindex $args 3 ]
    set lambda2 [ lindex $args 4 ]
    set pixel3 [ lindex $args 5 ]
    set lambda3 [ lindex $args 6 ]

    #--- Récupère la liste "spectre" contenant 2 listes : pixels et intensites
    #-- Modif faite le 26/12/2005
    set spectre [ spc_fits2data "$filespc" ]
    set intensites [lindex $spectre 0]
    buf$audace(bufNo) load "$audace(rep_images)/$filespc"
    set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
    set binning [ lindex [buf$audace(bufNo) getkwd "BIN1"] 1 ]

    #--- Calcul des parametres spectraux
    set deltax [expr $x2-$x1]
    #set dispersion [expr 1.0*$binning*($lambda2-$lambda1)/$deltax]
    set dispersion [expr 1.0*($lambda2-$lambda1)/$deltax]
    ::console::affiche_resultat "La dispersion linéaire vaut : $dispersion angstroms/Pixel.\n"
    set lambda_0 [expr $lambda1-$dispersion*$x1]

    #--- Calcul les coefficients du polynôme interpolateur de Lagrange : lambda=a*x^2+b*x+c
    set a [expr $lambda1/(($x1-$x2)*($x1-$x2))+$lambda2/(($x2-$x1)*($x2-$x3))+$lambda3/(($x3-$x1)*($x3-$x2))]
    set b [expr -$lambda1*($x3+$x2)/(($x1-$x2)*($x1-$x2))-$lambda2*($x3+$x1)/(($x2-$x1)*($x2-$x3))-$lambda3*($x1+$x2)/(($x3-$x1)*($x3-$x2))]
    set c [expr $lambda1*$x3*$x2/(($x1-$x2)*($x1-$x2))+$lambda2*$x3*$x1/(($x2-$x1)*($x2-$x3))+$lambda3*$x1*$x2/(($x3-$x1)*($x3-$x2))]
    ::console::affiche_resultat "$a, $b et $c\n"

    # set dispersionm [expr (sqrt(abs($b^2-4*$a*$c)))/$a]
    #set dispersionm [expr abs([ dispersion_moy $intensites $naxis1 ]) ]
    #--- Calcul les valeurs des longueurs d'ondes associees a chaque pixel
    set len [expr $naxis1-2]
    for {set x 1} {$x<=$len} {incr x} {
        lappend lambdas [expr $a*$x*$x+$b*$x+$c]
    }

    #--- Affichage du polynome :
    set file_id [open "$audace(rep_images)/polynome.txt" w+]
    for {set x 1} {$x<=$len} {incr x} {
        set lamb [lindex $lambdas [expr $x-1]]
        puts $file_id "$x $lamb"
    }
    close $file_id

     #--- Calcul la disersion moyenne en faisant la moyenne des ecarts entre les lambdas : GOOD !
    set dispersionm 0
    for {set k 0} {$k<[expr $len-1]} {incr k} {
        set l1 [lindex $lambdas $k]
        set l2 [lindex $lambdas [expr $k+1]]
        set dispersionm [expr 0.5*($dispersionm+0.5*($l2-$l1))]
    }
    ::console::affiche_resultat "La dispersion non linéaire vaut : $dispersionm angstroms/Pixel.\n"

    set lambda0 [expr $a+$b+$c]
    set lcentre [expr int($lambda0+0.5*($dispersionm*$naxis1)-1)]

    #--- Initialisation des mots clefs du fichier fits de sortie
    # setkwd [list "mot-clef" "valeur" [string, int, float] "commentaire" "unite"]
    #buf$audace(bufNo) setkwd [list "NAXIS1" "$naxis1" int "" ""]
    #-- Longueur d'onde de départ
    buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
    #-- Dispersion
    #buf$audace(bufNo) setkwd [list "CDELT1" "$dispersionm" double "" "Angtrom/pixel"]
    buf$audace(bufNo) setkwd [list "CDELT1" $dispersion double "" "Angtrom/pixel"]
    #-- Longueur d'onde centrale
    #buf$audace(bufNo) setkwd [list "CRPIX1" "$lcentre" double "" "angstrom"]
    #-- Type de dispersion : LINEAR...
    #buf$audace(bufNo) setkwd [list "CTYPE1" "NONLINEAR" string "" ""]

    buf$audace(bufNo) bitpix float
    buf$audace(bufNo) save "$audace(rep_images)/l${filespc}"
    ::console::affiche_resultat "Spectre étalonné sauvé sous l${filespc}\n"
    return l${filespc}
  } else {
    ::console::affiche_erreur "Usage: spc_calibre3pil fichier_fits_du_profil x1 lambda1 x2 lambda2 x3 lambda3\n\n"
  }
}
#****************************************************************************


####################################################################
# Procédure de calibration par un polynôme de degré 2 ou 3 selon le nombre de raies : OBSOLETE
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 04-01-2007
# Date modification : 04-01-2007
# Arguments : nom_profil_raies x1 lambda1 x2 lamda2 x3 lambda3 ... x_n lambda_n
####################################################################

proc spc_calibren_deg3 { args } {
    global conf
    global audace
    set erreur 0.01

    set len [expr [ llength $args ]-1 ]
    if { [ expr $len+1 ] >= 1 } {
        set filename [ lindex $args 0 ]
        set coords [ lrange $args 1 $len ]
        #::console::affiche_resultat "$len Coords : $coords\n"

        #--- Préparation des listes de données :
        for {set i 0} {$i<[expr $len-1]} { set i [ expr $i+2 ]} {
            lappend xvals [ lindex $coords $i ]
            lappend lambdas [ lindex $coords [ expr $i+1 ] ]
            lappend errors $erreur
        }
        set nbraies [ llength $lambdas ]

        #--- Calcul des coéfficients du polynome de calibration :
        if { $nbraies <=2 } {
            #-- Calcul du polynôme de calibration a+bx+cx^2 :
            set sortie [ spc_ajustdeg2 $xvals $lambdas $errors ]
            set coeffs [ lindex $sortie 0 ]
            set chi2 [ lindex $sortie 1 ]
            set d 0.0
            set c [ lindex $coeffs 2 ]
            set b [ lindex $coeffs 1 ]
            set a [ lindex $coeffs 0 ]
            set lambda0deg2 [ expr $a+$b+$c ]
            #-- Calcul du RMS :
            set rms [ expr $lambda0deg2*sqrt($chi2/$nbraies) ]
            ::console::affiche_resultat "RMS=$rms angstrom\n"
            #-- Calcul d'une série de longueurs d'ondes passant par le polynome pour la linéarisation :
            buf$audace(bufNo) load "$audace(rep_images)/$filename"
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
            for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
                lappend xpos $x
                lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
            }
        } else {
            #-- Calcul du polynôme de calibration a+bx+cx^2+dx^3 :
            set sortie [ spc_ajustdeg3 $xvals $lambdas $errors ]
            set coeffs [ lindex $sortie 0 ]
            set chi2 [ lindex $sortie 1 ]
            set d [ lindex $coeffs 3 ]
            set c [ lindex $coeffs 2 ]
            set b [ lindex $coeffs 1 ]
            set a [ lindex $coeffs 0 ]
            set lambda0deg3 [ expr $a+$b+$c+$d ]
            #--- Calcul du RMS :
            set sigma 1.0
            #set rms [ expr $lambda0deg3*sqrt($chi2/$nbraies) ]
            set rms [ expr $sigma*sqrt($chi2/$nbraies) ]
            ::console::affiche_resultat "RMS deg3=$rms angstrom\n"
            #-- Calcul d'une série de longueurs d'ondes passant par le polynome pour la linéarisation qui suit :
            buf$audace(bufNo) load "$audace(rep_images)/$filename"
            set naxis1 [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
            for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
                lappend xpos $x
                lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x+$d*$x*$x*$x ]
            }
        }

        #--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
        set coeffsdeg1 [ spc_reglin $xpos $lambdaspoly ]
        set a1 [ lindex $coeffsdeg1 0 ]
        set b1 [ lindex $coeffsdeg1 1 ]
        set lambda0deg1 [ expr $a1+$b1 ]
        #set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
        #-- Reglages :
        #- 40 -10 l0deg1 : AB
        #- 40 -40 l0deg1 : AB+
        #- 20 -10 l0deg2 : AB++
        if { $nbraies <=2 } {
            set lambda0 $lambda0deg2
        } else {
            set lambda0 $lambda0deg3
        }

        #--- Mise à jour des mots clefs :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        buf$audace(bufNo) setkwd [list "CRPIX1" 1 double "Reference pixel" ""]
        #-- Longueur d'onde de départ :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0 double "" "angstrom"]
        #-- Dispersion moyenne :
        buf$audace(bufNo) setkwd [list "CDELT1" $a1 double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
        #-- Corrdonnée représentée sur l'axe 1 (ie X) :
        buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "Axis 1 data type" ""]
        #-- Mots clefs du polynôme :
        buf$audace(bufNo) setkwd [list "SPC_DESC" "A+B.x+C.x.x+D.x.x.x" string "" ""]
        buf$audace(bufNo) setkwd [list "SPC_A" $a double "" "angstrom"]
        buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
        buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_D" $d double "" "angstrom.angstrom.angstrom/pixel.pixel.pixel"]
        buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]

        #--- Fin du script :
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/l${filename}"
        ::console::affiche_resultat "Spectre étalonné sauvé sous l${filename}\n"
        return l${filename}
    } else {
        ::console::affiche_erreur "Usage: spc_calibren_deg3 nom_profil_raies x1 lambda1 x2 lambda2 x3 lambda3 ... x_n lambda_n\n"
    }
}
#***************************************************************************#


####################################################################
# Fonction d'étalonnage à partir de raies de l'eau autour de Ha
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 08-04-2007
# Date modification : 21-04-2007/27-04-2007(int->round)
# Arguments : nom_profil_raies
####################################################################

proc spc_autocalibrehaeau { args } {
    global conf
    global audace
    # set pas 10
    #-- Demi-largeur de recherche des raies telluriques (Angstroms)
    #set ecart 4.0
    #set ecart 1.5
    set ecart 1.0
    #set ecart 1.2
    #set erreur 0.01
    set ldeb 6528.0
    set lfin 6580.0
    #-- Liste C.Buil :
    ### set listeraies [ list 6532.359 6542.313 6548.622 6552.629 6574.852 6586.597 ]
    ##set listeraies [ list 6532.359 6543.912 6548.622 6552.629 6574.852 6586.597 ]
    set listeraies [ list 6532.359 6543.907 6548.622 6552.629 6572.072 6574.847 ]
    #-- Liste ESO-Pollman :
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6574.880 6586.730 ]
    #set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 6574.880 ]
    ##set listeraies [ list 6532.351 6543.912 6548.651 6552.646 6572.079 ]

    set nbargs [ llength $args ]
    if { $nbargs <= 2 } {
        if { $nbargs == 1 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur 28
        } elseif { $nbargs == 2 } {
            set filename [ file rootname [ lindex $args 0 ] ]
            set largeur [ lindex $args 1 ]
        } else {
            ::console::affiche_erreur "Usage: spc_autocalibrehaeau nom_profil_de_raies ?largeur_raie (pixel)?\n"
            return 0
        }
        #set pas [ expr int($largeur/2) ]

        #--- Gestion des profils calibrés en longueur d'onde :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        #-- Retire les petites raies qui seraient des pixels chauds ou autre :
        #buf$audace(bufNo) imaseries "CONV kernel_type=gaussian sigma=0.9"
        #-- Renseigne sur les parametres de l'image :
        set naxis1 [ lindex [buf$audace(bufNo) getkwd "NAXIS1"] 1 ]
        set crval1 [ lindex [buf$audace(bufNo) getkwd "CRVAL1"] 1 ]
        set cdelt1 [ lindex [buf$audace(bufNo) getkwd "CDELT1"] 1 ]
        #- CAs non-lineaire :
        set listemotsclef [ buf$audace(bufNo) getkwds ]
        if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
            set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
            set flag_spccal 1
            set spc_a [ lindex [buf$audace(bufNo) getkwd "SPC_A"] 1 ]
            set spc_b [ lindex [buf$audace(bufNo) getkwd "SPC_B"] 1 ]
            set spc_c [ lindex [buf$audace(bufNo) getkwd "SPC_C"] 1 ]
            if { [ lsearch $listemotsclef "SPC_A" ] !=-1 } {
                set spc_d [ lindex [buf$audace(bufNo) getkwd "SPC_D"] 1 ]
            } else {
                set spc_d 0.
            }
        } else {
            set flag_spccal 0
        }
        #-- Incertitude sur mesure=1/nbpix*disp, nbpix_incertitude=1 :
        set mes_incertitude [ expr 1.0/($cdelt1*$cdelt1) ]

        #--- Calcul des xdeb et xfin bornant les 6 raies de l'eau :
        if { $ldeb>$crval1+2. && $lfin<[ expr $naxis1*$cdelt1+$crval1-2. ] } {
### modif michel
###            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) ]
###            set xfin [ expr round(($lfin-$crval1)/$cdelt1) ]
            set xdeb [ expr round(($ldeb-$crval1)/$cdelt1) -1 ]
            set xfin [ expr round(($lfin-$crval1)/$cdelt1) -1 ]
        } else {
            ::console::affiche_erreur "Plage de longueurs d'onde incompatibles avec la calibration tellurique\n"
            return "$filename"
        }

        #--- Filtrage pour isoler le continuum :
        set ffiltered [ spc_smoothsg $filename $largeur ]
        set fcont1 [ spc_div $filename $ffiltered ]

        #--- Inversion et mise a 0 du niveau moyen :
        buf$audace(bufNo) load "$audace(rep_images)/$fcont1"
        set icontinuum [ expr 2*[ lindex [ buf$audace(bufNo) stat ] 4 ] ]
        buf$audace(bufNo) mult -1.0
        buf$audace(bufNo) offset $icontinuum
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/${filename}_conti"
        buf$audace(bufNo) bitpix short

        #--- Recherche des raies d'émission :
        ::console::affiche_resultat "Recherche des raies d'absorption de l'eau...\n"
        #buf$audace(bufNo) scale {1 3} 1
        set nbraies [ llength $listeraies ]
        foreach raie $listeraies {
            if { $flag_spccal } {
                set x1 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie-$ecart))*$spc_c))/(2*$spc_c)) ]
                set x2 [ expr round((-$spc_b+sqrt($spc_b*$spc_b-4*($spc_a-($raie+$ecart))*$spc_c))/(2*$spc_c)) ]
                set coords [ list $x1 1 $x2 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                ##set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr $spc_a+$xcenter*$spc_b+$xcenter*$xcenter*$spc_c+pow($xcenter,3)*$spc_d ]
            } else {
### modif michel
###                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1) ]
###                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1) ]
                set x1 [ expr round(($raie-$ecart-$crval1)/$cdelt1 -1) ]
                set x2 [ expr round(($raie+$ecart-$crval1)/$cdelt1 -1) ]
                set coords [ list $x1 1 $x2 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 0 ]
                #set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1)*$cdelt1+$crval1 ]
            }
            lappend errors $mes_incertitude


          if { 1==0 } {
            if { $largeur == 0 } {
                # set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1*$cdelt1+$crval1 ]
            } else {
                #set xcenter [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
                set xcenter [ lindex [ buf$audace(bufNo) centro $coords $largeur ] 1 ]
                lappend listemesures $xcenter
                lappend listelmesurees [ expr ($xcenter -1*$cdelt1+$crval1 ]
            }
          }


        }
        ::console::affiche_resultat "Liste des raies trouvées :\n$listelmesurees\n"
        # ::console::affiche_resultat "Liste des raies trouvées : $listemesures\n"
        ::console::affiche_resultat "Liste des raies de référence :\n$listeraies\n"

        #--- Effacement des fichiers temporaires :
        file delete -force "$audace(rep_images)/$ffiltered$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/$fcont1$conf(extension,defaut)"
        file delete -force "$audace(rep_images)/${filename}_conti$conf(extension,defaut)"

      if { 1==1} {
        #-------------------- Non utilisé ----------------------------#
        if { 0==1} {
        #--- Constitution de la chaine x_n lambda_n :
        #foreach mes $listemesures eau $listeraies {
            # append listecoords "$mes $eau "
        #    append listecoords $mes
        #    append listecoords $eau
        #}
        #::console::affiche_resultat "Coords : $listecoords\n"
        set i 1
        foreach mes $listemesures eau $listeraies {
            set x$i $mes
            set l$i $eau
            incr i
        }

        #--- Calibration en longueur d'onde :
        ::console::affiche_resultat "Calibration du profil avec les raies de l'eau...\n"
        #set calibreargs [ list $filename $listecoords ]
        #set len [ llength $calibreargs ]
        #::console::affiche_resultat "$len args : $calibreargs\n"
        #set sortie [ spc_calibren $calibreargs ]
        set sortie [ spc_calibren $filename $x1 $l1 $x2 $l2 $x3 $l3 $x4 $l4 $x5 $l5 $x6 $l6 ]
        return $sortie
        }
        #------------------------------------------------------------#

        #--- Calcul du polynôme de calibration a+bx+cx^2 :
        set sortie [ spc_ajustdeg2 $listemesures $listeraies $errors ]
         set coeffs [ lindex $sortie 0 ]
        set c [ lindex $coeffs 2 ]
        set b [ lindex $coeffs 1 ]
        set a [ lindex $coeffs 0 ]
        set chi2 [ lindex $sortie 1 ]
        set covar [ lindex $sortie 2 ]
        ::console::affiche_resultat "Chi2=$chi2\n"
        if { $flag_spccal } {
            set lambda0deg2 [ expr $a+$b+$c ]
            set lambda0deg2 [ expr $a+$spc_b+$spc_c ]
        } else {
            set lambda0deg2 [ expr $a+$b+$c ]
        }
        set rms [ expr $cdelt1*sqrt($chi2/$nbraies) ]
        ::console::affiche_resultat "RMS=$rms angstrom\n"

        #--- Calcul des coéfficients de linéarisation de la calibration a1x+b1 (régression linéaire sur les abscisses choisies et leur lambda issues du polynome) :
        buf$audace(bufNo) load "$audace(rep_images)/$filename"
        for {set x 20} {$x<=[ expr $naxis1-10 ]} { set x [ expr $x+20 ]} {
            lappend xpos $x
            #lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
            lappend lambdaspoly [ expr $a+$b*$x+$c*$x*$x ]
            lappend errorsd1 $mes_incertitude
        }
        #set sortie1 [ spc_ajustdeg1 $xpos $lambdaspoly $errorsd1 ]
        set coeffsdeg1 [ spc_reglin $xpos $lambdaspoly ]
        set a1 [ lindex $coeffsdeg1 0 ]
        set b1 [ lindex $coeffsdeg1 1 ]
        #-- Valeur théorique :
        set lambda0deg1 [ expr $a1+$b1 ]
### modif michel
###        #-- Correction empirique :
###        set lambda0deg1 [ expr 1.*$b1 ]


        #--- Nouvelle valeur de Lambda0 :
        #set lambda0 [ expr 0.5*abs($lambda0deg1-$lambda0deg2)+$lambda0deg2 ]
        #-- Reglages :
        #- 40 -10 l0deg1 : AB
        #- 40 -40 l0deg1 : AB+
        #- 20 -10 l0deg2 : AB++

        #-- Valeur théorique :
        # set lambda0 $lambda0deg2
        #-- Correction empirique :
        set lambda0 [ expr $lambda0deg2-2.*$cdelt1 ]
        #set lambda0 $a


###        if { 1==0 } {
###        #--- Redonne le lambda du centre des raies apres réétalonnage :
###        set ecart2 0.6
###        foreach raie $listeraies {
###            set x1 [ expr int(($raie-$ecart2-$lambda0)/$cdelt1) ]
###            set x2 [ expr int(($raie+$ecart2-$lambda0)/$cdelt1) ]
###            set coords [ list $x1 1 $x2 1 ]
###            if { $largeur == 0 } {
###                set x [ lindex [ buf$audace(bufNo) fitgauss $coords ] 1 ]
###                #lappend listemesures $xcenter
###                # lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
###                lappend listelmesurees2 [ expr $lambda0+$cdelt1*$x ]
###            } else {
###                set x [ lindex [ buf$audace(bufNo) fitgauss $coords -fwhmx $largeur ] 1 ]
###                #lappend listemesures $xcenter
###                lappend listelmesurees2 [ expr $a+$b*$x+$c*$x*$x ]
###            }
###        }
###        #::console::affiche_resultat "Liste des raies après réétalonnage :\n$listelmesurees2\nÀ comparer avec :\n$listeraies\n"
###        }


        #--- Mise à jour des mots clefs :
        buf$audace(bufNo) setkwd [list "CRPIX1" 1 double "" ""]
        #-- Longueur d'onde de départ :
        buf$audace(bufNo) setkwd [list "CRVAL1" $lambda0deg1 double "" "angstrom"]
        #-- Dispersion moyenne :
        #buf$audace(bufNo) setkwd [list "CDELT1" $a1 double "" "angstrom/pixel"]
        #buf$audace(bufNo) setkwd [list "CUNIT1" "angstrom" string "Wavelength unit" ""]
        #-- Corrdonnée représentée sur l'axe 1 (ie X) :
        #buf$audace(bufNo) setkwd [list "CTYPE1" "Wavelength" string "" ""]
        #-- Mots clefs du polynôme :
        if { $flag_spccal } {
            buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
            #buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_A" $lambda0 double "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
        } else {
            buf$audace(bufNo) setkwd [list "SPC_DESC" "D.x.x.x+C.x.x+B.x+A" string "" ""]
            #buf$audace(bufNo) setkwd [list "SPC_A" $a float "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_A" $lambda0deg2 double "" "angstrom"]
            buf$audace(bufNo) setkwd [list "SPC_B" $b double "" "angstrom/pixel"]
            buf$audace(bufNo) setkwd [list "SPC_C" $c double "" "angstrom.angstrom/pixel.pixel"]
            buf$audace(bufNo) setkwd [list "SPC_RMS" $rms double "" "angstrom"]
        }

        #--- Sauvegarde :
        set fileout "${filename}-ocal"
        buf$audace(bufNo) bitpix float
        buf$audace(bufNo) save "$audace(rep_images)/$fileout"
        buf$audace(bufNo) bitpix short

        #--- Fin du script :
        ::console::affiche_resultat "Spectre étalonné sauvé sous $fileout\n"
        return "$fileout"
     }
   } else {
       ::console::affiche_erreur "Usage: spc_autocalibrehaeau profil_de_raies_a_calibrer ?largeur_raie (pixels)?\n\n"
   }
}
#****************************************************************#



}

#
# Fonctions à injecter dans les fichiers tcl d'Spcaudace
#



####################################################################
# Mesure le SNR moyen de tous les spectres du repertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 31-05-2018
# Date modification : 31-05-2018
# Arguments : ri_br spectre_astre-2b offset(0.5) coeff_multiplication_ri(1.0)
####################################################################

proc spc_ribrcorr { args } {
   global audace conf

   #--- Gestion arguments :
   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set ri_br [ file rootname [ lindex $args 0 ] ]
      set sp_astre [ file rootname [ lindex $args 1 ] ]
      set offset_cal 0.5
      set mult_val 1.0
   } elseif { $nbargs==3 } {
      set ri_br [ file rootname [ lindex $args 0 ] ]
      set sp_astre [ file rootname [ lindex $args 1 ] ]
      set offset_cal [ lindex $args 2 ]
      set mult_val 1.0
   } elseif { $nbargs==4 } {
      set ri_br [ file rootname [ lindex $args 0 ] ]
      set sp_astre [ file rootname [ lindex $args 1 ] ]
      set offset_cal [ lindex $args 2 ]
      set mult_val [ lindex $args 3 ]
   } else {
      ::console::affiche_erreur "Usage: spc_ribrcorr ri_br spectre_astre-2b ?offset(0.5)? ?coeff_multiplication_ri(1.0)?\n"
      return ""
   }

   #--- Mise a l'echelle du continuum de la ri :
   set ri_norm [ spc_rescalecont "$ri_br" 6300 ]
   
   #--- Modifications de la ri :
   buf$audace(bufNo) load "$audace(rep_images)/$ri_norm"
   buf$audace(bufNo) mult $mult_val
   buf$audace(bufNo) offset $offset_cal
   buf$audace(bufNo) save "$audace(rep_images)/${ri_br}_corr"

   #--- Division du spectre par la ri :
   file delete -force "$audace(rep_images)/$ri_norm$conf(extension,defaut)"
   set sp_astre_corrri [ spc_divri "$sp_astre" "${ri_br}_corr" ]

   #--- Affichage :
   spc_gdeleteall
   spc_load "$sp_astre_corrri"

   #--- Fin :
   ::console::affiche_resultat "Spectre corrige de la ri modifiée sauvé sous $sp_astre_corrri\n"
   return $sp_astre_corrri
}
#**************************************************************#


####################################################################
# Mesure le SNR moyen de tous les spectres du repertoire de travail
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 26-11-2017
# Date modification : 29-11-2017
# Arguments : lambda zone mesure
####################################################################

proc spc_snrserie { args } {
   global audace conf

   #--- Gestion arguments :
   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set lambda_snr [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_snrserie lambda_mesure_snr\n"
      return ""
   }

   #--- Prepa variables :
   set listefichiers [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]

   #--- Mesure du snr de chaque spectre :
   set snr_moy 0
   foreach fichier $listefichiers {
      set snr_i [ spc_snr "$fichier" $lambda_snr ]
      set snr_moy [ expr $snr_moy+$snr_i ]
   }
   set nb_spectres [ llength $listefichiers ]
   set snr_moy [ expr round($snr_moy/$nb_spectres) ]

   #--- Fin :
   ::console::affiche_resultat "SNR moyen de $nb_spectres spectres : $snr_moy\n"
   return $snr_moy
}
#**************************************************************#


####################################################################
# Compare par affichage deux spectres avec rescale du continuum a 6000 A par defaut
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-05-2018
# Date modification : 29-05-2018
# Arguments : spectre1 spectre2 ?lambda_rescale?
####################################################################

proc spc_compareduo { args } {
   global audace conf

   #--- Gestion arguments :
   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set spectre1 [ file rootname [ lindex $args 0 ] ]
      set spectre2 [ file rootname [ lindex $args 1 ] ]
      set lambda_rescale 6000
   } elseif { $nbargs==3 } {
      set spectre1 [ lindex $args 0 ]
      set spectre2 [ lindex $args 1 ]
      set lambda_rescale [ lindex $args 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_compareduo spectre1 spectre2 ?lambda_rescale(6000)?\n"
      return ""
   }

   #--- Mise a l'echelle des continuum :
   set sprescale1 [ spc_rescalecont "$spectre1" $lambda_rescale ]
   set sprescale2 [ spc_rescalecont "$spectre2" $lambda_rescale ]

   #--- Affichage des 2 spectres :
   spc_gdeleteall
   spc_load "$sprescale1"
   spc_loadmore "$sprescale2" green

   #--- Menage des spectres :
   if { "$sprescale1" != "$spectre1" } { file delete -force "$audace(rep_images)/$sprescale1$conf(extension,defaut)" }
   if { "$sprescale2" != "$spectre2" } { file delete -force "$audace(rep_images)/$sprescale2$conf(extension,defaut)"}

   #--- Fin :
   if { "$sprescale1" == "$spectre1" || "$sprescale2" == "$spectre2" } {
      ::console::affiche_erreur "Aucune mise à l'échelle réalisée. Veuillez préciser une longueur d'onde dans la plage couverte.\n"
   } else {
      ::console::affiche_resultat "Spectres comparés mis à l'échelle affichés dans SpcAudace.\n"
   }
}
#**************************************************************#



####################################################################
# Procédure de lecture d'une fichier dat de 2 colonnes et ressort une liste {{xi} {yi}}
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 29-11-2016
# Date modification : 29-11-2016
# Arguments : nom_de_fichier
####################################################################

proc spc_dat2data { args } {
   global conf audace
   
   if { [ llength $args ]==1 } {
      set datafile [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_dat2data fichier_de_données\n"
      return ""
   }

   #--- Lecture du fichier de donnees :
   set input [ open "$audace(rep_images)/$datafile" r ]
   set contents [ split [read $input] \n ]
   close $input

   #--- Extraction des abscisses et des ordonnees :
   set abscisses [ list ]
   set ordonnees [ list ]
   foreach ligne $contents {
      set abscisse [ lindex $ligne 0 ]
      if { "$abscisse"!="" } {
         lappend abscisses $abscisse
         lappend ordonnees [ lindex $ligne 1 ]
      }
   }

   #--- Fin du script :
   set datas [ list $abscisses $ordonnees ]
   return $datas
}
#**************************************************************#



####################################################################
# Procédure d'enregistrement dans un fichier dat 2 colonnes d'un ensemble de valeurs {{xi}{y}}
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 1-09-2006
# Date modification : 1-09-2006
# Arguments : {{liste xi} {liste yi}}
####################################################################

proc spc_data2dat { args } {
   global conf
   global audace
   set fileout "data.dat"
   
    if { [llength $args] == 1 } {
       set listevals [ lindex $args 0 ]
       set valsx [ lindex $listevals 0 ]
       set valsy [ lindex $listevals 1 ]
       set len [ llength $valsx ]

       #--- Enregistre le derivee dans un fichier texte de 2 colonnes :
       set file_id [open "$audace(rep_images)/$fileout" w+]
       #-- independamment du systeme LINUX ou WINDOWS
       fconfigure $file_id -translation crlf
       for {set k 0} {$k<$len} {incr k} {
          set valx [ lindex $valsx $k ]
          set valy [ lindex $valsy $k ]
          puts $file_id "$valx\t$valy"
       }
       close $file_id

       #--- Fin :
       return "$fileout"
    } else {
	::console::affiche_erreur "Usage: spc_data2dat {{liste xi} {liste yi}}\n"
    }
}
#***************************************************************************#



#**************************************************************#
# Effectue la difference entre une serie de spectre et un spectre de "reference"
# 2016-08-03
#**************************************************************#
proc spc_spdiff { args } {
   global audace conf

   if { [ llength $args ]==1 } {
      set spectre_ref [ file rootname [ lindex $args 0 ] ]
   } else {
      ::console::affiche_erreur "Usage: spc_spdiff spectre_reference\n"
      return ""
   }

   #--- Cree repertoier de sortie :
   set rep_sortie "spdiff"
   if { ![ file exists "$audace(rep_images)/$rep_sortie" ] } {
      file mkdir "$audace(rep_images)/$rep_sortie"
   }

   #--- Boucle sur les spectres :
   set nb_files 0
   set listefichiers [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]
   foreach spectre $listefichiers {
      set spectre_nom [ file rootname "$spectre" ]
      if { "$spectre_nom"!="$spectre_ref" } {
         buf$audace(bufNo) load "$audace(rep_images)/$spectre"
         buf$audace(bufNo) sub "$spectre_ref"
         buf$audace(bufNo) bitpix float
         buf$audace(bufNo) save "$audace(rep_images)/$rep_sortie/${spectre_nom}_diff$conf(extension,defaut)"
         incr nb_files
      }
   }

   #--- Fin :
   ::console::affiche_resultat "$nb_files traitées sauvées dans le répertoire $rep_sortie\n"
}
#********************************************************#


#**************************************************************#
# Effectue la difference entre une serie de spectre et un spectre de "reference"
# 2016-08-05
#**************************************************************#
proc spc_spdiffdec { args } {
   global audace conf

   set val_continuum 1.0
   set ldeb_dflt 6561.6
   set lfin_dflt 6563.2

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set spectre_ref [ file rootname [ lindex $args 0 ] ]
      set ldeb $ldeb_dflt
      set lfin $lfin_dflt
   } elseif { $nbargs==3 } {
      set spectre_ref [ file rootname [ lindex $args 0 ] ]
      set ldeb [ lindex $args 1 ]
      set lfin [ lindex $args 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_spdiffdec spectre_reference ?lambde_deb lambda_fin?\n"
      return ""
   }

   #--- Cree repertoier de sortie :
   set rep_sortie "spdiff"
   if { ![ file exists "$audace(rep_images)/$rep_sortie" ] } {
      file mkdir "$audace(rep_images)/$rep_sortie"
   }

   #--- Mesure lambda centre spectre ref :
   set lcentre_ref [ spc_centergaussl "$spectre_ref" $ldeb $lfin a ]
   
   #--- Boucle sur les spectres :
   set nb_files 0
   set listefichiers [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]
   foreach spectre $listefichiers {
      set spectre_nom [ file rootname "$spectre" ]
      if { "$spectre_nom"!="$spectre_ref" } {
         set lcentre [ spc_centergaussl "$spectre" $ldeb $lfin a ]
         set diff [ expr -1.*($lcentre-$lcentre_ref) ]
         set spectre_ref_dec [ spc_calibredecal "$spectre_ref" $diff ]
         buf$audace(bufNo) load "$audace(rep_images)/$spectre"
         buf$audace(bufNo) sub "$spectre_ref_dec"
         buf$audace(bufNo) offset $val_continuum
         buf$audace(bufNo) bitpix float
         buf$audace(bufNo) save "$audace(rep_images)/$rep_sortie/${spectre_nom}_diff$conf(extension,defaut)"
         file delete -force "$audace(rep_images)/$spectre_ref_dec$conf(extension,defaut)"
         incr nb_files
      }
   }

   #--- Fin :
   ::console::affiche_resultat "$nb_files traitées sauvées dans le répertoire $rep_sortie\n"
}
#********************************************************#



#**************************************************************#
# Assemble les spectres par paquet de P spectres (smean)
#**************************************************************#
proc spc_smeanp { args } {
   global audace conf
   set flag_datem 1

   if { [ llength $args ]==1 } {
      set p_uplet [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_smeanp nb_spectres_par_stack\n"
      return ""
   }

   set rep_sortie "stack${p_uplet}"
   file mkdir "$audace(rep_images)/$rep_sortie"
   
   set listefichiersdep [ lsort -dictionary [ glob -dir $audace(rep_images) -tails *$conf(extension,defaut) ] ]
   set listefichiers [ rr_rrlphasesort $listefichiersdep ]
   set nbspectres [ llength $listefichiers ]
   set index_max [ expr $nbspectres-1 ]
   set nb_puplet 0
   set sous_liste [ list ]
   set nb_sp_byuplet [ list ]
   for { set i 0 } { $i<=$index_max } { incr i $p_uplet } {
      #--- Selection des spectres pour faire la sous-liste :
      set nb_spectres_restant [ expr $nbspectres-$i ]
      if { $nb_spectres_restant<$p_uplet } {
         set index_packp [ expr $i+$nb_spectres_restant ]
      } else {
         set index_packp [ expr $i+$p_uplet-1 ]
      }
      set sous_liste [ lrange $listefichiers $i $index_packp ]
      
      #--- Moyenne des spectres sélectionnés :
      set k 0
      set tot_exptime 0
      set chaine_sous_liste ""
      foreach spectre $sous_liste {
         set nom [ file rootname "$spectre" ]
         append chaine_sous_liste "$nom "
         incr k
         if { $k==1 } {
            buf$audace(bufNo) load "$audace(rep_images)/$spectre"
            set tot_exptime [ expr $tot_exptime+[ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]/(3600*24.0) ]
            set jd_mid [ mc_date2jd [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ] ]
         } else {
            buf$audace(bufNo) load "$audace(rep_images)/$spectre"
            set tot_exptime [ expr $tot_exptime+[ lindex [ buf$audace(bufNo) getkwd "EXPTIME" ] 1 ]/(3600*24.0) ]
         }
      }
      #-- Calcul du JD de milieu de pose du multiplet : jd_mid [ expr 0.5*($jd_begin+(n-1)*$exptime) ]
      #::console::affiche_resultat "Jmid avant moy : $jd_mid\n"
      set jd_mid [ expr $jd_mid+$tot_exptime/$k ]
      #::console::affiche_resultat "Jmid apres moy : $jd_mid\n"
      #-- Les spectres etant triés par phase, la date du spectre de sortie est celle du 1er spectre du multiplet+0.5*(n-1)*exptime pour ne pas etre perturbe par la date des autres spectres entrant dans la moyenne.
      set date_mid [ mc_date2iso8601 $jd_mid ]
      #::console::affiche_resultat "Dmid moy : $date_mid\n"
      set nom_spectre_out [ file rootname [ lindex $sous_liste 0 ] ]
      #-- Calcul de la moyenne :
      #::console::affiche_resultat "$nom_spectre_out : $sous_liste\n"
      ttscript2 "IMA/STACK . \"$chaine_sous_liste\" * * $conf(extension,defaut) \"./$rep_sortie\" \"$nom_spectre_out\" . $conf(extension,defaut) MEAN bitpix=-32"
      incr nb_puplet
      #::console::affiche_prompt "Contenu du $nb_puplet multiplet : $chaine_sous_liste\n"

      #--- Met a jour la date du fichier de sortie :
      buf$audace(bufNo) load "$audace(rep_images)/$rep_sortie/$nom_spectre_out"
      buf$audace(bufNo) setkwd [ list "DATE-OBS" "$date_mid" string "Start of exposure UT" "ISO 8601" ]
      #set i 1
      #foreach spectre $sous_liste {
      #   buf$audace(bufNo) setkwd [ list "STACK-$i" "$spectre" string "Stacked file $i" "" ]
      #   incr i
      #}
      #buf$audace(bufNo) setkwd [ list "STACK" "$chaine_sous_liste" string "" "" ]
      buf$audace(bufNo) bitpix float
      buf$audace(bufNo) save "$audace(rep_images)/$rep_sortie/$nom_spectre_out"
      #::console::affiche_resultat "$nom_spectre_out : $sous_liste\n"
   }
   ::console::affiche_resultat "$nb_puplet groupes de spectres moyennés par $p_uplet\n"
   #return $nb_sp_byuplet
}
#**************************************************************#



####################################################################
# Conversion date iso en JD
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2012-08-02
# Date modification : 2012-08-2
# Arguments : date_iso (2011-10-05T23:26:52)
####################################################################

proc spc_date2jd { args } {
   global audace conf

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set ladate [ lindex $args 0 ]
      set jdate [ mc_date2jd $ladate ]
      ::console::affiche_resultat "Date $ladate en jours juliens : $jdate\n"
      return $jdate
   } else {
      ::console::affiche_erreur "Usage: spc_date2jd date_iso (2011-10-05T23:26:52)\n"
   }
}      
#***********************************************************************#


####################################################################
# Conversion date iso en JD
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2012-08-02
# Date modification : 2012-08-2
# Arguments : date_iso (2011-10-05T23:26:52)
####################################################################

proc spc_jd2date { args } {
   global audace conf

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set jdate [ lindex $args 0 ]
      set date_iso [ mc_date2iso8601 $jdate ]
      ::console::affiche_resultat "Date $jdate au format ISO (fits) : $date_iso\n"
      return $date_iso
   } else {
      ::console::affiche_erreur "Usage: spc_jd2date date_jours_juliens\n"
   }
}      
#***********************************************************************#



####################################################################
# Mesure de la vitesse d'une raie avec options étendues
####################################################################

proc spc_vmes { args } {
   global audace conf spcaudace

   #-- Type de raie :
   set type_raie_dflt "a"
   #-- Methode de dmesure : gaussien/gravite :
   set meth_mes_dflt "ga"
   #-- Lambda ref :
   #set lambda_ref 5895.924
   set lambda_ref_dft 6562.819
   #-- Precision de la mesure d'une longueur d'onde a +- 1/4 -> 1/2 de pixel :
   set precision_dflt 0.25
   
   #--- Gestion arguments :
   set nbargs [ llength $args ]
   if { $nbargs==3 } {
      set fichier [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set type_raie $type_raie_dflt
      set lambda_ref $lambda_ref_dft
      set meth_mes $meth_mes_dflt
      set precision $precision_dflt
   } elseif { $nbargs==4 } {
      set fichier [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set type_raie [ lindex $args 3 ]
      set lambda_ref $lambda_ref_dft
      set meth_mes $meth_mes_dflt
      set precision $precision_dflt
   } elseif { $nbargs==5 } {
      set fichier [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set type_raie [ lindex $args 3 ]
      set lambda_ref [ lindex $args 4 ]
      set meth_mes $meth_mes_dflt
      set precision $precision_dflt
   } elseif { $nbargs==6 } {
      set fichier [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set type_raie [ lindex $args 3 ]
      set lambda_ref [ lindex $args 4 ]
      set meth_mes [ lindex $args 5 ]
      set precision $precision_dflt
   } elseif { $nbargs==7 } {
      set fichier [ lindex $args 0 ]
      set lambda_deb [ lindex $args 1 ]
      set lambda_fin [ lindex $args 2 ]
      set type_raie [ lindex $args 3 ]
      set lambda_ref [ lindex $args 4 ]
      set meth_mes [ lindex $args 5 ]
      set precision [ lindex $args 6 ]
   } else {
      ::console::affiche_erreur "Usage: spc_vmes spectre lambda_deb lambda_fin ?type_sp (e/a)? ?lambda_ref(6562.819)? ?methode_mes(ga/gr)? ?precision_position_raie(pixels)?\n"
      return ""
   }


   #--- Pour chaque spectre :
   buf$audace(bufNo) load "$audace(rep_images)/$fichier"

   #-- Determine la date et la phase de pulsation :
   set dateobs [ lindex [ buf$audace(bufNo) getkwd "DATE-OBS" ] 1 ]
   set cdelt1 [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
   #set phasep [ format "%1.3f" [ bm_rrlyrd2p "$dateobs" ] ]
   #set dateiso_list [ mc_date2ymdhms $dateobs ]
   #regexp {([0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9])T.} $dateobs match dateiso

   #-- Mesure du decalage Doppler :
   if { "$meth_mes"=="ga" } {
      set lambda_mes [ spc_centergaussl "$fichier" $lambda_deb $lambda_fin "$type_raie" ]
   } elseif { "$meth_mes"=="gr" } {
      set lambda_mes [ lindex [ spc_centergravl "$fichier" $lambda_deb $lambda_fin "$type_raie" ] 0 ]
   } else {
      ::console::affiche_erreur "Le méthode de mesure doit être soit 'ga' (gaussienne) ou 'gr' (centre de gravité).\n"
      return ""
   }

   #-- Calcul de la vitesse :
   set v_mes [ expr $spcaudace(vlum)*($lambda_mes-$lambda_ref)/$lambda_ref ]
   set delta_vrad [ format "%1.1f" [ expr $spcaudace(vlum)*$precision*$cdelt1/$lambda_ref ] ]

   #--- Affichage des resultats :
   set lambda_mes [ format "%4.4f" $lambda_mes ]
   set v_mes [ format "%3.1f" $v_mes ]
   #::console::affiche_resultat "\n"
   ::console::affiche_resultat "Lmes=$lambda_mes A ; Vmes=$v_mes +/- $delta_vrad km/s\n"
   set results [ list $v_mes $delta_vrad ]
   return $results
}
#**************************************************************#





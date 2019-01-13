
# Procédures liées à 'linterface graphique et au tracé des profils de raies.

# Mise a jour $Id: spc_sa.tcl 11027 2014-10-02 17:24:59Z bmauclaire $

# 2014-03-22



####################################################################
# Traite les spectres issu d'un Star analyser
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2014-01-31
# Date modification : 2014-01-31
# Hypotheses : spectre horizontale (pas de deformation geometriques), loi de calibration donne par la spectre 1b de l'etoile de reference
####################################################################

proc spc_sari { args } {
   global audace conf spcaudace

   # set ldeb 3900
   # set ldeb 3750
   set ldeb 3500
   set lfin 9500
   set coef_gaussienne 1.3
   set lambda_hbeta 4861.342
   #set reponse_instrumentale "reponse_instrumentale-br.fit"

   set nbargs [ llength $args ]
   if { $nbargs==6 } {
      set nom_stellaire [ file rootname [ file tail [ lindex $args 0 ] ] ]
      set nom_dark [ file rootname [ file tail [ lindex $args 1 ] ] ]
      set nom_flat [ file rootname [ file tail [ lindex $args 2 ] ] ]
      set nom_darkflat [ file rootname [ file tail [ lindex $args 3 ] ] ]
      set nom_offset [ file rootname [ file tail [ lindex $args 4 ] ] ]
      # set dispersion [ lindex $args 4 ]
      set type_etoile_ref [ lindex $args 5 ]
   } else {
      # ::console::affiche_erreur "Usage: spc_sari nom_generique_spectre nom_generique_noirs/somme_noirs nom_generique_plu nom_generique_noirs_plu/somme_noirs_plu dispersion_approximative_du_spectro type_etoile_ref\(a0v, a2v, a5v, b2iv, b5ii, b8v\)\n"
      ::console::affiche_erreur "Usage: spc_sari nom_generique_spectre nom_generique_noirs/somme_noirs nom_generique_plu nom_generique_noirs_plu/somme_noirs_plu nom_generique_offsets/somme_offsets/none type_etoile_ref\(a0v, a2v, a5v, b2iv, b5ii, b8v\)\n"
      return ""
   }


   #--- Premier spectre de la serie :   
   set liste_spectres [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
   set nb_stellaire [ llength $liste_spectres ]
   set spectre_one [ lindex $liste_spectres 0 ]

   #--- Zone de l'ordre zero pour la registration :
   set zone_ordre0 [ spc_sazone "$spectre_one" "Sélectionnez un cadre autour des taches de l'ordre 0" ]

   #--- Zone de l'extremite du spectre visible pour la correction du tilt :
   set zone_fin_spectre [ spc_sazone "$spectre_one" "Sélectionnez un cadre autour de l'extrémité rouge du spectre de l'étoile" ]

   #--- Pretraitement :
   set pretraitfilename [ spc_pretrait $nom_stellaire $nom_dark $nom_flat $nom_darkflat $nom_offset ]

   #--- Corrections géometriques :
   #-- Appariement veritcal et horizontal :
   register "$pretraitfilename" "${pretraitfilename}_r-" $nb_stellaire -box $zone_ordre0
   delete2 "$pretraitfilename" $nb_stellaire
   #-- Correction du tilt :
   #- Choisir un 2eme point sur une raie emission ou un morceau lumineux du contninuum, avec la box au debut :
   set spectre_tilted [ spc_sarot "${pretraitfilename}_r-" $zone_ordre0 $zone_fin_spectre ]
   delete2 "${pretraitfilename}_r-" $nb_stellaire

   #--- Somme mediane :
   set sumfile [ bm_smed "$spectre_tilted" ]
   delete2 "$spectre_tilted" $nb_stellaire

   #--- Extraction du profil de raies :
   set fileprofile [ spc_profil "$sumfile" ]
   file rename -force "$audace(rep_images)/$sumfile$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-spectre-2D$conf(extension,defaut)"

   #--- Calibration :
   #-- Methode avec Hbeta a trouver et disp donnee :
   #- Mesure de x de l'ordre zero :
   if  { 1==0 } {
   set x_0 [ lindex [ lindex [ spc_findbiglines "$fileprofile" e 15 ] 0 ] 0 ]
   #set x_hbeta [ lindex [ lindex [ spc_findbiglines sheratan_tr_sme5_zone_fc_spc a 15 ] 0 ]
   #- Determination de x_hbeta :
   # Hypo : disp connue, recherche x_hbeta a +-10 pixels
   set x_hbeta_0 [ expr 4861.342/$dispersion+$x_0 ]
   set x_hbeta [ spc_centergauss "$fileprofile" [ expr $x_hbeta_0-10. ] [ expr $x_hbeta_0+10. ] a ]
   #- Calibration du profil :
   set file_calibrated [ spc_calibren "$fileprofile" $x_0 0. $x_hbeta $lambda_hbeta ]
   file rename -force "$audace(rep_images)/$fileprofile$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1a$conf(extension,defaut)"
   }

   #-- Methode avec boite de dialogue :
   #- Determination de la largeur typique des raies a l'aide de l'ordre 0 :
   #"set x_0 [ lindex [ lindex [ spc_findbiglines "$fileprofile" e 15 ] 0 ] 0 ]
   # set fwhm [ spc_fwhm "$fileprofile" [ expr $x_0-10 ] [ expr $x_0+10 ] e ]
   # set largeur_raie [ expr $fwhm*$coef_gaussienne ]
   ##set largeur_raie [ expr $fwhm*2. ]
   # ::console::affiche_prompt "fwhm=$fwhm ; largeur=$largeur_raie\n"
   #- Affiche un fichier 2D car pas possible de charger le spectre modele avec buf1 load si un profil a ete visualise :
   #loadima "$sumfile"
   #--- Determination du centroide de l'ordre 0 :
   buf$audace(bufNo) load "$audace(rep_images)/${nom_stellaire}-spectre-2D"
   set x_ordre0 [ lindex [ buf$audace(bufNo) centro $zone_ordre0 ] 0 ]

   #- Calibration du profil :
   set file_calibrated0 [ spc_sacalibre "$fileprofile" $x_ordre0 ]
   set file_calibrated [ spc_linearcal "$file_calibrated0" ]
   file delete -force "$audace(rep_images)/$file_calibrated0$conf(extension,defaut)"
   file rename -force "$audace(rep_images)/$fileprofile$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1a$conf(extension,defaut)"


   #--- Decoupage :
   set profil_select [ spc_select "$file_calibrated" $ldeb $lfin ]
   file rename -force "$audace(rep_images)/$file_calibrated$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1b$conf(extension,defaut)"
   set file_calibrated "${nom_stellaire}-profil-1b"

   #--- Determination de la RI :
   #- a0v, a2v, a5v, b2iv, b5ii, b8v
   switch $type_etoile_ref {
      a0v {
         set profil_reference "a0v.fit"
         file copy -force "$spcaudace(rep_spcbib)/$profil_reference" "$audace(rep_images)/$profil_reference"
      }
      a2v {
         set profil_reference "a2v.fit"
         file copy -force "$spcaudace(rep_spcbib)/$profil_reference" "$audace(rep_images)/$profil_reference"
      }
      a5v {
         set profil_reference "a5v.fit"
         file copy -force "$spcaudace(rep_spcbib)/$profil_reference" "$audace(rep_images)/$profil_reference"
      }
      b2iv {
         set profil_reference "2b2iv.fit"
         file copy -force "$spcaudace(rep_spcbib)/$profil_reference" "$audace(rep_images)/$profil_reference"
      }
      b5ii {
         set profil_reference "2b5ii.fit"
         file copy -force "$spcaudace(rep_spcbib)/$profil_reference" "$audace(rep_images)/$profil_reference"
      }
      b8v {
         set profil_reference "2b8v.fit"
         file copy -force "$spcaudace(rep_spcbib)/$profil_reference" "$audace(rep_images)/$profil_reference"
      }
   }
   set reponse_instrumentale [ spc_rinstrum "$profil_select" "$profil_reference" ]
   file delete -force "$audace(rep_images)/$profil_reference"
   set profil_reference_noext [ file rootname "$profil_reference" ]
   file delete -force "$audace(rep_images)/${profil_reference_noext}_ech$conf(extension,defaut)"

   #--- Correction par la ri :
   if { [ file exists "$audace(rep_images)/reponse_instrumentale-br.fit" ] } {
      set profil_ricorr [ spc_divri "$profil_select" "reponse_instrumentale-br" ]
      file rename -force "$audace(rep_images)/$profil_select$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1b-decoupe$conf(extension,defaut)"
      set profil_select "${nom_stellaire}-profil-1b-decoupe"
      file rename -force "$audace(rep_images)/$profil_ricorr$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1c$conf(extension,defaut)"
      set profil_ricorr "${nom_stellaire}-profil-1c"
   } else {
      ::console::affiche_resultat "Pas de RI disponible\n"
      file rename -force "$audace(rep_images)/$profil_select$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1b-decoupe$conf(extension,defaut)"
      set profil_select "${nom_stellaire}-profil-1b-decoupe"
      set profil_ricorr "$profil_select"
   }

   #--- Rescale cont a 6400 A :
   set profil_rescaled [ spc_rescalecont "$profil_ricorr" 6400 ]
   file rename -force "$audace(rep_images)/$profil_rescaled$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-2a$conf(extension,defaut)"
   set profil_2a "${nom_stellaire}-profil-2a"

   #--- Fin du script :
   ::console::affiche_prompt "****** Fin du traitement ****\n"
   #::console::affiche_prompt "Verifier la position des raies de Balmer sur le profil affiché. Si trop différentes, appliquer par essais succesifs une dfispersion proche de $dispersion avec :\n spc_sadisperse nom_profil_de_raies nouvelle_dispersion\n"
   loadima "${nom_stellaire}-spectre-2D"
   spc_load $profil_2a
   return $profil_2a
}
#***********************************************************************



####################################################################
# Traite les spectres issu d'un Star analyser
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2014-01-31
# Date modification : 2014-03-22
# Hypotheses : spectre horizontale (pas d'inclinaison), loi de calibration donne par la spectre 1b de l'etoile de reference, fichier ri porte le nom "reponse_instrumentale-br.fit"
####################################################################

proc spc_satraite { args } {
   global audace conf spcaudace
   set ldeb 3750
   set lfin 9500
   set reponse_instrumentale "reponse_instrumentale-br.fit"

   set nbargs [ llength $args ]
   if { $nbargs==6 } {
      set spectre_1b_reference [ file rootname [ file tail [ lindex $args 0 ] ] ]
      set nom_stellaire [ file rootname [ file tail [ lindex $args 1 ] ] ]
      set nom_dark [ file rootname [ file tail [ lindex $args 2 ] ] ]
      set nom_flat [ file rootname [ file tail [ lindex $args 3 ] ] ]
      set nom_darkflat [ file rootname [ file tail [ lindex $args 4 ] ] ]
      set nom_offset [ file rootname [ file tail [ lindex $args 5 ] ] ]
      set flag_nebular "n"
   } elseif { $nbargs==7 } {
      set spectre_1b_reference [ file rootname [ file tail [ lindex $args 0 ] ] ]
      set nom_stellaire [ file rootname [ file tail [ lindex $args 1 ] ] ]
      set nom_dark [ file rootname [ file tail [ lindex $args 2 ] ] ]
      set nom_flat [ file rootname [ file tail [ lindex $args 3 ] ] ]
      set nom_darkflat [ file rootname [ file tail [ lindex $args 4 ] ] ]
      set nom_offset [ file rootname [ file tail [ lindex $args 5 ] ] ]
      set methodefc [ lindex $args 6 ]
      set flag_nebular "o"
      # set yinf [ lindex $args 5 ]
      # set ysup [ lindex $args 6 ]
   } else {
      # ::console::affiche_erreur "Usage: spc_satraite spectre_1b_reference nom_generique_spectre nom_generique_noirs/somme_noirs nom_generique_plu nom_generique_noirs_plu/somme_noirs_plu ?yinf ysup (zone de binning)?\n
      ::console::affiche_erreur "Usage: spc_satraite spectre_1b_reference nom_generique_spectre nom_generique_noirs/somme_noirs nom_generique_plu nom_generique_noirs_plu/somme_noirs_plu nom_generique_offsets/somme_offsets/none ?méthode_soustraction_fond_de_ciel_pour_nébuleuses (\[med\], moy, moy2, sup, inf, none, back)? \n
Hypothèses : loi de calibration donnée par la spectre 1b de l'étoile de référence, fichier ri porte le nom reponse_instrumentale-br.fit\n"
      return ""
   }


   #--- Zone de l'ordre zero pour la registration :
   set spmoyen [ bm_smean "$nom_stellaire" ]
   set zone_ordre0 [ spc_sazone "$spmoyen" "Sélectionnez un cadre autour des taches de l'ordre 0" ]
   file delete -force "$audace(rep_images)/$spmoyen$conf(extension,defaut)"

   #--- Pretraitement :
   set nb_stellaire [ llength [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${nom_stellaire}\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]$conf(extension,defaut) ${nom_stellaire}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] ]
   set pretraitfilename [ spc_pretrait $nom_stellaire $nom_dark $nom_flat $nom_darkflat $nom_offset ]

   #--- Corrections géometriques :
   #-- Appariement veritcal et horizontal :
   register "$pretraitfilename" "${pretraitfilename}_r-" $nb_stellaire -box $zone_ordre0
   delete2 "$pretraitfilename" $nb_stellaire

   #-- Correction du tilt :
   #- Calcul centroide de l'ordre 0 :
   set sumfile_temp [ bm_smean "${pretraitfilename}_r-" ]
   buf$audace(bufNo) load "$audace(rep_images)/$sumfile_temp"
   set coords_o0 [ buf$audace(bufNo) centro $zone_ordre0 ]
   set x0 [ lindex $coords_o0 0 ]
   set y0 [ lindex $coords_o0 1 ]
   file delete -force "$audace(rep_images)/$sumfile_temp$conf(extension,defaut)"

   #- Recupere les parametres du tilt dans le spectre 1b donné :
   buf$audace(bufNo) load "$audace(rep_images)/$spectre_1b_reference"
   set angle_tilt [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
   #- Rotation des spectres :
   set ftilt [ spc_tilt2imgs "${pretraitfilename}_r-" $angle_tilt $x0 $y0 ]
   delete2 "${pretraitfilename}_r-" $nb_stellaire

   #--- Somme mediane :
   set sumfile [ bm_smed "$ftilt" ]
   delete2 "$ftilt" $nb_stellaire

   #--- Recupere les coordonnees de la zone a binner en cas de spectre nebulaire :
   if { "$flag_nebular"=="o" } {
      set zone_binning [ spc_sazone "$sumfile" "Sélectionnez un cadre autour de la zone à binner pour la détermination de yinf et ysup" ]
   }


   #--- Extraction du profil de raies :
   if { "$flag_nebular"=="n" } {
      set fileprofile [ spc_profil "$sumfile" ]
   } elseif { "$flag_nebular"=="o" } {
      buf$audace(bufNo) load "$audace(rep_images)/$sumfile"
      set x2b [ lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set x1b 1
      set y1b [ lindex $zone_binning 1 ]
      set y2b [ lindex $zone_binning 3 ]
      #-- -6 : car binning Roberval ne prend pas les 3 lignes dessus et dessous.
      set hauteur [ expr round($y2b-$y1b)+1-6 ]
      set ycenter [ expr round(0.5*$hauteur)+$y1b ]
      set sumfile_moins_fc [ spc_subsky $sumfile $ycenter $hauteur $methodefc ]
      buf$audace(bufNo) load "$audace(rep_images)/$sumfile_moins_fc"
      set yepaisseur [ expr [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]-3 ]
      if { $yepaisseur<=4. } {
         ::console::affiche_erreur "Zone de binning trop mince. Extension de 20 pixels verticaux.\n"
         set y1b [ expr [ lindex $zone_binning 1 ]-10 ]
         set y2b [ expr [ lindex $zone_binning 3 ]+10 ]
         set yepaisseur [ expr round($y2b-$y1b)+1 ]
         #-- -6 : car binning Roberval ne prend pas les 3 lignes dessus et dessous.
         set hauteur [ expr $ypepaisseur-6 ]
         set ycenter [ expr round(0.5*$hauteur)+$y1b ]
         set sumfile_moins_fc [ spc_subsky $sumfile $ycenter $hauteur $methodefc ]
         buf$audace(bufNo) load "$audace(rep_images)/$sumfile_moins_fc"
      }
      #-- J. G. Robertson, PASP 98, 1220-1231, November 1986, Version simplifliee sans rejection des pixels aberrants.
      buf$audace(bufNo) imaseries "LOPT y1=3 y2=$yepaisseur height=1"
      buf$audace(bufNo) save "$audace(rep_images)/${sumfile}-profil"
      set fileprofile "${sumfile}-profil"
      file delete -force "$audace(rep_images)/$sumfile_moins_fc$conf(extension,defaut)"
   }
   file rename -force "$audace(rep_images)/$sumfile$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-spectre-2D$conf(extension,defaut)"

   #--- Calibration :
   set file_calibrated0 [ spc_calibreloifile "$spectre_1b_reference" "$fileprofile" ]
   #-- Recalage a l'aide de l'ordre 0 :
   set lambda_0 [ lindex [ lindex [ spc_findbiglines "$file_calibrated0" e 15 ] 0 ] 0 ]
   set delta_lambda [ expr -1.*$lambda_0 ]
   set file_calibrated1 [ spc_calibredecal "$file_calibrated0" $delta_lambda ]
   file delete -force "$audace(rep_images)/$file_calibrated0$conf(extension,defaut)"
   #-- Ajustement avec 7605 :
   set dispersion [ lindex [ spc_info "$file_calibrated1" ] 5 ]
   set lambda_o2 [ spc_centergaussl "$file_calibrated1" 7500 7700 a ]
   set delta_lambda [ expr 7605.0-$lambda_o2+$dispersion*1.0 ]
   set file_calibrated [ spc_calibredecal "$file_calibrated1" $delta_lambda ]
   file delete -force "$audace(rep_images)/$file_calibrated1$conf(extension,defaut)"


   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
   if { 1==0 } {
   #-- Mesure de x de l'ordre zero :
   set x_0 [ lindex [ lindex [ spc_findbiglines "$fileprofile" e 15 ] 0 ] 0 ]
   set ref_uncal [ spc_delcal "$spectre_1b_reference" ]
   set x_0_ref [ lindex [ lindex [ spc_findbiglines "$ref_uncal" e 15 ] 0 ] 0 ]
   file delete -force "$audace(rep_images)/$ref_uncal$conf(extension,defaut)"
   set delta_x0 [ expr $x_0-$x_0_ref ]
   #-- Calibration :
   set ref_linearcal [ spc_linearcal "$spectre_1b_reference" ]
   set ref_infos [ spc_info "$ref_linearcal" ]
   file delete -force "$audace(rep_images)/$ref_linearcal$conf(extension,defaut)"
   set lambda0_ref [ lindex $ref_infos 3 ]
   set dispersion [ lindex $ref_infos 5 ]       
   set delta_lambda [ expr $delta_x0*$dispersion ]
   set lambda_0 [ expr $lambda0_ref+$delta_lambda ] 
   }
   if { 1==0 } {
   set file_calibrated "l${fileprofile}"
   buf$audace(bufNo) load "$audace(rep_images)/$fileprofile"
   buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda_0 double "" "angstrom" ]
   buf$audace(bufNo) setkwd [ list "CDELT1" $dispersion double "Dispersion" "angstrom/pixel" ]
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save1d "$audace(rep_images)/$file_calibrated"
   buf$audace(bufNo) bitpix short
   }
   if { 1==0 } {
   set file_calibrated [ spc_calibreloifile "$spectre_1b_reference" "$fileprofile" ]
   buf$audace(bufNo) load "$audace(rep_images)/$file_calibrated"
   buf$audace(bufNo) setkwd [ list "CRVAL1" $lambda_0 double "" "angstrom" ]
   buf$audace(bufNo) setkwd [ list "SPC_A" $lambda_0 double "" "angstrom" ]
   buf$audace(bufNo) bitpix float
   buf$audace(bufNo) save1d "$audace(rep_images)/$file_calibrated"
   buf$audace(bufNo) bitpix short
   }
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
   file rename -force "$audace(rep_images)/$fileprofile$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1a$conf(extension,defaut)"
   

   #--- Decoupage :
   set profil_select [ spc_select "$file_calibrated" $ldeb $lfin ]
   file rename -force "$audace(rep_images)/$file_calibrated$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1b$conf(extension,defaut)"
   set file_calibrated "${nom_stellaire}-profil-1b"

   #--- Correction par la ri :
   if { [ file exists "$audace(rep_images)/reponse_instrumentale-br.fit" ] } {
      ::console::affiche_prompt "\nCorrection de la réponse instrementale :\n"
      set profil_ricorr [ spc_divri "$profil_select" "$reponse_instrumentale" ]
      file rename -force "$audace(rep_images)/$profil_select$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1b-decoupe$conf(extension,defaut)"
      set profil_select "${nom_stellaire}-profil-1b-decoupe"
      file rename -force "$audace(rep_images)/$profil_ricorr$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1c$conf(extension,defaut)"
      set profil_ricorr "${nom_stellaire}-profil-1c"
   } else {
      ::console::affiche_prompt "Pas de RI disponible.\n"
      file rename -force "$audace(rep_images)/$profil_select$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-1b-decoupe$conf(extension,defaut)"
      set profil_select "${nom_stellaire}-profil-1b-decoupe"
      set profil_ricorr "$profil_select"
   }

   #--- Rescale cont a 6400 A :
   set profil_rescaled [ spc_rescalecont "$profil_ricorr" 6400 ]
   file rename -force "$audace(rep_images)/$profil_rescaled$conf(extension,defaut)" "$audace(rep_images)/${nom_stellaire}-profil-2a$conf(extension,defaut)"
   set profil_2a "${nom_stellaire}-profil-2a"

   #--- Fin du script :
   ::console::affiche_prompt "****** Fin du traitement ****\n"
   loadima "${nom_stellaire}-spectre-2D"
   spc_load $profil_2a
   return $profil_2a
}
#***********************************************************************



##########################################################
# Effectue la calibration en longueur d'onde d'un spectre avec n raies et interface graphique
# Attention : GUI présente !
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 17-09-2006
# Date de mise à jour : 14-02-2014
# Arguments : profil_lampe_calibration
##########################################################

proc spc_sacalibre { args } {
   global audace
   global conf caption spcaudace
   #- spcalibre : nom de la variable retournee par la gui param_spc_audace_calibreprofil qui contient le nom du fichier de la lampe calibree
   global spcalibre

   if { [llength $args] <= 2 } {
       if { [llength $args] == 2 } {
          set profiletalon [ file rootname [ lindex $args 0 ] ]
	  set x_ordre0 [ lindex $args 1 ]
       } elseif { [llength $args]==0 } {
           set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
           if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
              set profiletalon [ file rootname "$spctrouve" ]
           } else {
               ::console::affiche_erreur "Usage: spc_sacalibre profil_de_raies_a_calibrer x_ordre0\n"
               return 0
           }
       } else {
	  ::console::affiche_erreur "Usage: spc_sacalibre profil_de_raies_a_calibrer x_ordre0\n"
           return 0
       }

      #--- Determination du centroide de l'ordre 0 :
      #set xdeb [ lindex $winzone 0 ]
      #set xfin [ lindex $winzone 3 ]
      #buf$audace(bufNo) load "$audace(rep_images)/$profiletalon"
      #set x_ordre0 [ lindex [ buf$audace(bufNo) centro [ list $xdeb 1 $xfin 1 ] ] 0 ]

      #--- Affichage du profil de raies du spectre à calibrer :
      spc_gdeleteall
      spc_loadfit "$profiletalon"

       #--- Détection des raies dans le profil de raies de la lampe :
      #-- Ne converge pas toujours avec stectres sans fente du Staranlyser :
      # set raies [ spc_findbiglines "$profiletalon" a $largeur ]

       #set raies [ spc_findbiglines "$profiletalon" a 15 ]
       # set raies [ spc_findbiglineslamp $profiletalon ]
       #foreach raie $raies {
        #   lappend listeabscisses [ lindex $raie 0 ]
       #}
       #set listeabscisses_i $raies
      # set listeabscisses_i [ linsert $raies 0 [ list $x_ordre0 1 ] ]
      set listeabscisses_i [ list [ list $x_ordre0 1 ] ]

       #--- Elaboration des listes de longueurs d'onde :
       set listelambdaschem [ spc_readchemfiles ]
       #::console::affiche_resultat "Chim : $listelambdaschem\n"
       set listeargs [ list $profiletalon $listeabscisses_i $listelambdaschem ]

      #--- Affichage du spectre modèle pour une aide à la calibration :
      #-- Haute résolution :
      #spc_loadneon "hr" 1
      #-- Basse résolution :
      #if { $spcaudace(br) } {
      #   spc_loadneon "br" 2
      #}

      spc_loadneon "sa" 1

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

          if { $cdelt1>0 && $spc_b>=0.0 && $spc_rms<$spcaudace(rms_lim) } {
             loadima $spcalibre
             return $spcalibre
          } else {
             ::console::affiche_erreur "\nVous avez effectué une mauvaise calibration.\n"
             ##-- Boîte de dialogue pour REsaisir les paramètres de calibration :
             set fileout [ spc_sacalibre $profiletalon $x_ordre0 ]
          }
       } else {
          ::console::affiche_erreur "La calibration a échouée.\n"
          return ""
       }
   } else {
       ::console::affiche_erreur "Usage: spc_sacalibre profil_de_raies_a_calibrer largeur_raie(pixels)\n"
   }
}
#****************************************************************#


####################################################################
# Boite graphique de selection de la zone de l'ordre 0 d'un Star analyser
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2014-01-31
# Date modification : 2014-02-14
# Argument : nom generique des brutes
####################################################################

proc spc_sazone { args } {
   global audace spcaudace conf
   global flag_ok

   if { [llength $args]==2 } {
      set nom_stellaire [ file rootname [ lindex $args 0 ] ]
      set message_text [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_sazone nom_spectre_2D \"texte du message\"\n"
      return ""
   }

 
   # set spmoyen [ bm_smean "$nom_stellaire" ]
   # loadima "$spmoyen"
   loadima "$nom_stellaire"
   #buf$audace(bufNo) load "$audace(rep_images)/$spmoyen"
   #visu1 cut [ lrange [ buf$audace(bufNo) stat ] 0 1 ] ; visu1 disp
   ::console::affiche_resultat "$message_text\n"
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
   label .benji.lab -text "$message_text"
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
      set zone_selected [::confVisu::getBox 1]
      ::console::affiche_resultat "Zone : $zone_selected\n"
      ::confVisu::deleteBox 1
      set flag_ok 2
      destroy .benji
   } elseif { $flag_ok==2 } {
      set flag_ok 2
      ::confVisu::deleteBox 1
      destroy .benji
      return 0
   }
   # file delete -force "$audace(rep_images)/$spmoyen$conf(extension,defaut)"
   return $zone_selected
}
#****************************************************************#




####################################################################
# Determine la pente et angle de tilt, puis pivote les spectres
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2014-03-12
# Date modification : 2014-03-12
# Argument : nom generique des brutes
####################################################################

proc spc_sarot { args } {
   global audace spcaudace conf
   set pi [ expr acos(-1.0) ]

   if { [llength $args]==3 } {
      set nom_generique [ lindex $args 0 ]
      set zone_ordre0 [ lindex $args 1 ]
      set zone_rouge [ lindex $args 2 ]
   } else {
      ::console::affiche_erreur "Usage: spc_sarot nom_gegenrique_spectres_2D coordonnees_zone_ordre0 coordonnees_zone_rouge\n"
      return ""
   }

   #--- Gestion de l'angle limite :
   set angle_max_dflt $spcaudace(tilt_limit)
   set spcaudace(tilt_limit) 60

   #--- Moyenne des spectres (recales horizontalement) :
   set spmoyen [ bm_smean "$nom_generique" ]
   buf$audace(bufNo) load "$audace(rep_images)/$spmoyen"

   #--- Determinationn des coordonnees du centre de l'ordre 0 :
   set coords_ordre0 [ buf$audace(bufNo) centro $zone_ordre0 ]
   #--- Determinationn des coordonnees du centre de la partie rouge du spectre :
   set coords_rouge [ buf$audace(bufNo) centro $zone_rouge ]
   file delete -force "$audace(rep_images)/$spmoyen$conf(extension,defaut)"

   #--- Calcul de la pente :
   set x0 [ lindex $coords_ordre0 0 ]
   set y0 [ lindex $coords_ordre0 1 ]
   set xr [ lindex $coords_rouge 0 ]
   set yr [ lindex $coords_rouge 1 ]
   set pente [ expr 1.0*($yr-$y0)/($xr-$x0) ]
   set angle_tilt [ expr 180./$pi*atan($pente) ]

   #--- Rotation des spectres :
   set ftilt [ spc_tilt2imgs "$nom_generique" $angle_tilt $x0 $y0 ]

   #--- Fin de script :
   set spcaudace(tilt_limit) $angle_max_dflt
   return "$ftilt"
}
#****************************************************************#




####################################################################
# Modifie la dispersion d'un spectre du Star analyser
#
# Auteur : Benjamin MAUCLAIRE
# Date creation : 2014-01-31
# Date modification : 2014-01-31
# Arguments : profil de raies calibre, nouvelle dispersion
####################################################################

proc spc_sadisperse { args } {
   global audace conf

   set nbargs [ llength $args ]
   if { $nbargs==2 } {
      set linesprofile [ file rootname [ lindex $args 0 ] ]
      set new_disp [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_sadisperse nom_profil_de_raies nouvelle_dispersion\n"
      return ""
   }

   if { [ file exists "$audace(rep_images)/reponse_instrumentale-br.fit" ] } {
      set file_newdisp [ spc_echantdelt "reponse_instrumentale-br" $new_disp ]
      file rename -force "$audace(rep_images)/$file_newdisp$conf(extension,defaut)" "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)"
   }

   set file_newdisp [ spc_echantdelt "$linesprofile" $new_disp ]
   set newname "${linesprofile}-redisp"
   file rename -force "$audace(rep_images)/$linesprofile$conf(extension,defaut)" "$audace(rep_images)/$newname$conf(extension,defaut)"
   ::console::affiche_prompt "Profil avec la nouvelle dispersion sauve sous $newname. La RI a été aussi corrigée.\n"
   return "$newname"
}
#****************************************************************#

##########################################################
# Effectue la calibration en longueur d'onde d'un spectre avec n raies et interface graphique
# Attention : GUI présente !
#
# Auteur : Benjamin MAUCLAIRE
# Date de création : 17-09-2006
# Date de mise à jour : 14-02-2014
# Arguments : profil_lampe_calibration
##########################################################

proc spc_sacalibre0 { args } {
   global audace
   global conf caption spcaudace
   #- spcalibre : nom de la variable retournee par la gui param_spc_audace_calibreprofil qui contient le nom du fichier de la lampe calibree
   global spcalibre

   if { [llength $args] <= 3 } {
       if { [llength $args] == 3 } {
          set profiletalon [ file rootname [ lindex $args 0 ] ]
	  set largeur [ lindex $args 1 ]
	  set winzone [ lindex $args 2 ]
       } elseif { [llength $args]==0 } {
           set spctrouve [ file rootname [ file tail [ tk_getOpenFile -filetypes [list [list "$caption(tkutil,image_fits)" "[buf$audace(bufNo) extension] [buf$audace(bufNo) extension].gz"] ] -initialdir $audace(rep_images) ] ] ]
           if { [ file exists "$audace(rep_images)/$spctrouve$conf(extension,defaut)" ] == 1 } {
              set profiletalon [ file rootname "$spctrouve" ]
           } else {
               ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer largeur_raie(pixels)\n"
               return 0
           }
       } else {
	  ::console::affiche_erreur "Usage: spc_calibre profil_de_raies_a_calibrer largeur_raie(pixels) zone_ordre0\{x1 y1 x2 y2\}\n"
           return 0
       }

      #--- Determination du centroide de l'ordre 0 :
      set xdeb [ lindex $winzone 0 ]
      set xfin [ lindex $winzone 3 ]
      buf$audace(bufNo) load "$audace(rep_images)/$profiletalon"
      set x_ordre0 [ lindex [ buf$audace(bufNo) centro [ list $xdeb 1 $xfin 1 ] ] 0 ]

      #--- Affichage du profil de raies du spectre à calibrer :
      spc_gdeleteall
      spc_loadfit "$profiletalon"

       #--- Détection des raies dans le profil de raies de la lampe :
      #-- Ne converge pas toujours avec stectres sans fente du Staranlyser :
      # set raies [ spc_findbiglines "$profiletalon" a $largeur ]

       #set raies [ spc_findbiglines "$profiletalon" a 15 ]
       # set raies [ spc_findbiglineslamp $profiletalon ]
       #foreach raie $raies {
        #   lappend listeabscisses [ lindex $raie 0 ]
       #}
       #set listeabscisses_i $raies
      # set listeabscisses_i [ linsert $raies 0 [ list $x_ordre0 1 ] ]
      set listeabscisses_i [ list [ list $x_ordre0 1 ] ]

       #--- Elaboration des listes de longueurs d'onde :
       set listelambdaschem [ spc_readchemfiles ]
       #::console::affiche_resultat "Chim : $listelambdaschem\n"
       set listeargs [ list $profiletalon $listeabscisses_i $listelambdaschem ]

      #--- Affichage du spectre modèle pour une aide à la calibration :
      #-- Haute résolution :
      #spc_loadneon "hr" 1
      #-- Basse résolution :
      #if { $spcaudace(br) } {
      #   spc_loadneon "br" 2
      #}

      spc_loadneon "sa" 1

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

          if { $cdelt1>0 && $spc_b>=0.0 && $spc_rms<$spcaudace(rms_lim) } {
             loadima $spcalibre
             return $spcalibre
          } else {
             ::console::affiche_erreur "\nVous avez effectué une mauvaise calibration.\n"
             ##-- Boîte de dialogue pour REsaisir les paramètres de calibration :
             set fileout [ spc_sacalibre $profiletalon $largeur $winzone ]
          }
       } else {
          ::console::affiche_erreur "La calibration a échouée.\n"
          return ""
       }
   } else {
       ::console::affiche_erreur "Usage: spc_sacalibre profil_de_raies_a_calibrer largeur_raie(pixels)\n"
   }
}
#****************************************************************#

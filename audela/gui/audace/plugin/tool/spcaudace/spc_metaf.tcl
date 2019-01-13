# Chargement en script :
# A130 : source $audace(rep_scripts)/spcaudace/spc_metaf.tcl
# A140 : source [ file join $audace(rep_plugin) tool spcaudace spc_metaf.tcl ]

# Mise a jour $Id: spc_metaf.tcl 14525 2018-11-09 18:22:10Z bmauclaire $



###############################################################################
# Procédure de test d'ihm
# Auteur : Benjamin MAUCLAIRE
###############################################################################

proc spc_testihm {} {
    global caption
    global audace
    global conf

    #source [ file join $audace(rep_scripts) spcaudace spc_gui_boxes.tcl ]
    set err [ catch {
	::param_spc_audace_calibre2::run
	tkwait window .param_spc_audace_calibre2
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    set audace(param_spc_audace,calibre2,config,xa1)
    set audace(param_spc_audace,calibre2,config,xa2)
    set audace(param_spc_audace,calibre2,config,xb1)
    set audace(param_spc_audace,calibre2,config,xb2)
    set audace(param_spc_audace,calibre2,config,type1)
    set audace(param_spc_audace,calibre2,config,type2)
    set audace(param_spc_audace,calibre2,config,lambda1)
    set audace(param_spc_audace,calibre2,config,lambda2)
    #::console::affiche_resultat "Paramètres : $audace(param_spc_audace,calibre2,config,xa1)\n"

    set xa1 $audace(param_spc_audace,calibre2,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2,config,xb2)
    set type1 $audace(param_spc_audace,calibre2,config,type1)
    set type2 $audace(param_spc_audace,calibre2,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
    ::console::affiche_resultat "Paramètres : $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2\n"
}
#****************************************************************************#


###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, vcrop, régistration, sadd, tilt, spc_profil. Pas de calibration en longueur d'onde ni en flux.
# Auteur : Benjamin MAUCLAIRE
# Date création :  27-08-2005
# Date de mise à jour : 28-10-2005/03-12-2005/21-12-2005
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu [yinf_crop]
###############################################################################

proc spc_traitea { args } {

   global audace
   global conf

   ## Découpage de la zone à étudier et prétraitement puis profil :
   if { [llength $args] == 6 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set nbimg [ llength [ glob -dir $audace(rep_images) ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Prétraitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Découpage de la zone de travail des images ****\n"
       set nom_generique_crop [ spc_crop $nom_generique_pretrait [lindex $args 4] [lindex $args 5] ]
       delete2 $nom_generique_pretrait $nbimg
       ::console::affiche_resultat "\n**** Appariement des images ****\n"
       set nom_generique_reg [ spc_register $nom_generique_crop ]
       delete2 $nom_generique_crop $nbimg
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ spc_somme $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy $fichier_final1$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
       set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       file copy $fichier_final2$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
       set fichier_final3 [ spc_profil $fichier_final2 auto ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       # file copy $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   ## Prétraitement des images seulement puis profil :
   } elseif { [llength $args] == 4 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set nbimg [ llength [ glob ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Prétraitement des images ****\n"
       set nom_generique_pretrait [ bm_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Appariement des images ****\n"
       #set nom_generique_reg [ spc_register $nom_generique_pretrait ]
       set nom_generique_reg [ bm_register $nom_generique_pretrait ]
       delete2 $nom_generique_pretrait $nbimg
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ spc_somme $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy $fichier_final1$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
       set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       file copy $fichier_final2$conf(extension,defaut) traitees
       ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
       set fichier_final3 [ spc_profil $fichier_final2 auto ]
       spc_loadfit $fichier_final3
       set fichier_final [ file rootname $fichier_final3 ]
       file copy $fichier_final$conf(extension,defaut) traitees
       # file copy $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   } else {
       ::console::affiche_erreur "Usage: spc_traitea nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu ?xinf_crop yinf_crop?\n\n"
   }
}
###############################################################################


###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, vcrop, régistration, sadd, tilt, spc_profil. Pas de calibration en longueur d'onde ni en flux.
# Auteur : Benjamin MAUCLAIRE
# Date création :  27-08-2005
# Date de mise à jour : 28-10-2005/03-12-2005/21-12-2005
# Méthode : utilise bm_pretrait pour le prétraitement
# Arguments : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu [yinf_crop]
###############################################################################

proc spc_traiteaopt { args } {

   global audace
   global conf

   ## Découpage de la zone à étudier et prétraitement puis profil :
   if { [llength $args] == 10 } {
       set repdflt [spc_goodrep]
       set f1 [ lindex $args 0 ]
       set f2 [ lindex $args 1 ]
       set f3 [ lindex $args 2 ]
       set f4 [ lindex $args 3 ]
       set meth_fc [ lindex $args 6 ]
       set meth_reg [ lindex $args 7 ]
       set meth_tilt [ lindex $args 8 ]
       set meth_prof [ lindex $args 9 ]

       set nbimg [ llength [ glob -dir $audace(rep_images) ${f1}*$conf(extension,defaut) ] ]
       ::console::affiche_resultat "\n**** Prétraitement des images ****\n"
       set nom_generique_pretrait [ spc_pretrait $f1 $f2 $f3 $f4 ]
       ::console::affiche_resultat "\n**** Découpage de la zone de travail des images ****\n"
       set nom_generique_crop [ spc_crop $nom_generique_pretrait [lindex $args 4] [lindex $args 5] ]
       delete2 $nom_generique_pretrait $nbimg

       #--- Soustraction du fond de ciel
       if { $meth_fc == "auto" } {
	   ::console::affiche_resultat "\n**** Soustraction du fond de ciel des images ****\n"
	   set nom_generique_fc [ spc_subskies $nom_generique_crop ]
	   delete2 $nom_generique_crop $nbimg
       } elseif { $meth_fc == "no" } {
	   ::console::affiche_resultat "\n**** Pas de soustraction du fond de ciel ****\n"
	   set nom_generique_fc $nom_generique_crop
       }

       #--- Appariement des images
       if { $meth_reg == "reg" } {
	   ::console::affiche_resultat "\n**** Appariement des images ****\n"
	   set nom_generique_reg [ bm_register $nom_generique_fc ]
	   delete2 $nom_generique_fc $nbimg
       } elseif { $meth_reg == "spc" } {
	   ::console::affiche_resultat "\n**** Appariement des images ****\n"
	   set nom_generique_reg [ spc_register $nom_generique_fc ]
	   delete2 $nom_generique_fc $nbimg
       } elseif { $meth_reg == "no" } {
	   ::console::affiche_resultat "\n**** Pas d'appariement des images ****\n"
	   set nom_generique_reg $nom_generique_fc
       }

       #--- Addition des images
       ::console::affiche_resultat "\n**** Addition des images ****\n"
       set fichier_final1 [ spc_somme $nom_generique_reg ]
       delete2 $nom_generique_reg $nbimg
       file mkdir "traitees"
       file copy -force $fichier_final1$conf(extension,defaut) traitees

       #--- Redressement (rot) de l'image finale
       if { $meth_tilt == "auto" } {
	   ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
	   set fichier_final2 [ spc_tiltauto $fichier_final1 ]
       } elseif { $meth_tilt == "man" } {
	   ::console::affiche_resultat "\n**** Redressement (rot) de l'image finale ****\n"
	   set fichier_final2 [ spc_tiltman $fichier_final1 ]
       } elseif { $meth_tilt == "no" } {
	   ::console::affiche_resultat "\n**** Pas de redressement (rot) de l'image ****\n"
	   set fichier_final2 $fichier_final1
       }
       file copy -force $fichier_final2$conf(extension,defaut) traitees

       #--- Création du profil de raies
       if { $meth_prof == "auto" } {
	   #-- Avec correction du fond de ciel par le BLACK
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 auto ]
       } elseif { $meth_prof == "none" } {
	   #-- Sans correction du fond de ciel
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 none ]
       } elseif { $meth_prof == "all" } {
	   #-- Avec correction du fond de ciel par les zones sup et inf au spectre
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 all ]
       } elseif { $meth_prof == "sup" } {
	   #-- Avec correction du fond de ciel par la zones sup au spectre
	   ::console::affiche_resultat "\n**** Création du profil de raies ****\n"
	   set fichier_final3 [ spc_profil $fichier_final2 sup ]
       }
       spc_loadfit $fichier_final3

       #--- Rangement des fichiers
       set fichier_final [ file rootname $fichier_final3 ]
       file copy -force $fichier_final$conf(extension,defaut) traitees
       # file copy -force $fichier_final.dat traitees
       file delete $fichier_final$conf(extension,defaut) $fichier_final.dat $fichier_final1$conf(extension,defaut) $fichier_final2$conf(extension,defaut)
       cd $repdflt
   } else {
       ::console::affiche_erreur "Usage: spc_traiteaopt nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu xinf_crop yinf_crop méthode_fond_de_ciel (no, auto) méthode régistration (reg, spc, no) méthode_tilt (no, auto, man) méthode_profil (none, auto, all, sup, inf, back, moy, moy2)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, smooth.
# Auteur : Benjamin MAUCLAIRE
# Date création :  13-07-2006
# Date de mise à jour : 13-07-2006
# Arguments : nom_generique_spectres_pretraites spectre_2D_lampe methode_reg (reg, spc) uncosmic (o/n) methode_détection_spectre (large, serre) methode_sub_sky (moy, moy2, med, inf, sup, ack, none) mirrorx (o/n) methode_binning (add, opt1, opt2) smooth (o/n)
###############################################################################

proc spc_geom2calibre { args } {

   global audace spcaudace
   global conf

   if { [llength $args] == 9 } {
       set spectres [ lindex $args 0 ]
       set lampe [ file rootname [ lindex $args 1 ] ]
       set methreg [ lindex $args 2 ]
       set methcos [ lindex $args 3 ]
       set methsel [ lindex $args 4 ]
       set methsky [ lindex $args 5 ]
       set methinv [ lindex $args 6 ]
       set methbin [ lindex $args 7 ]
       set methsmo [ lindex $args 8 ]

       #--- Eliminatoin des mauvaise images :
       ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
       spc_reject $spectres
       set nbimg [ llength [ glob -dir $audace(rep_images) ${spectres}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       set fsmilex [ spc_smilex2imgs $lampe $spectres ]

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       set ftilt [ spc_tiltautoimgs $fsmilex ]
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       ::console::affiche_resultat "Sortie : $ftilt\n"
       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       ::console::affiche_resultat "Sortie : $freg\n"
       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ spc_somme $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       ::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   #-- Mirrorx du spectre prétraité :
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
	   #-- Mirrorx du spectre de la lampe de calibration :
	   buf$audace(bufNo) load "$audace(rep_images)/${lampe}_slx"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}_slx"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fsadd $methsky $methsel $methbin ]

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       spc_loadfit ${lampe}_slx
       loadima ${lampe}_slx
       #-- Boîte de dialogue pour saisir les paramètres de calibration :
       # tk.message "Selectionnez les corrdonnées x de cahque bords de 2 raies"
       # tk.boite1 xa1 xa2 xb1 xb2
       # tk.message "Donner la longueur d'onde et le type (a/e) des 2 raies"
       # tk.boite2 type1 lammbda1 type2 lambda2
       set err [ catch {
	   ::param_spc_audace_calibre2::run
	   tkwait window .param_spc_audace_calibre2
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       set audace(param_spc_audace,calibre2,config,xa1)
       set audace(param_spc_audace,calibre2,config,xa2)
       set audace(param_spc_audace,calibre2,config,xb1)
       set audace(param_spc_audace,calibre2,config,xb2)
       set audace(param_spc_audace,calibre2,config,type1)
       set audace(param_spc_audace,calibre2,config,type2)
       set audace(param_spc_audace,calibre2,config,lambda1)
       set audace(param_spc_audace,calibre2,config,lambda2)

       set xa1 $audace(param_spc_audace,calibre2,config,xa1)
       set xa2 $audace(param_spc_audace,calibre2,config,xa2)
       set xb1 $audace(param_spc_audace,calibre2,config,xb1)
       set xb2 $audace(param_spc_audace,calibre2,config,xb2)
       set type1 $audace(param_spc_audace,calibre2,config,type1)
       set type2 $audace(param_spc_audace,calibre2,config,type2)
       set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
       set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
       #-- Effectue la calibration du spectre 2D de la lampe spectrale :
       set lampecalibree [ spc_calibre2sauto ${lampe}_slx $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $spectres ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fcal ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fcal"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_geom2calibre nom_generique_spectres_pretraites spectre_2D_lampe methode_reg (reg, spc) uncosmic (o/n) methode_détection_spectre (large, serre) methode_sub_sky (moy, moy2, med, inf, sup, ack, none) mirrorx (o/n) methode_binning (add, opt1, opt2) smooth (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  14-07-2006
# Date de mise à jour : 14-07-2006
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_générique_spectres_prétraités (sans extension) spectre_2D_lampe méthode_reg (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre)  méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_bining (add, rober, horne) adoucissment (o/n) normalisation (o/n)
###############################################################################

proc spc_geom2rinstrum { args } {

   global audace spcaudace
   global conf

   if { [llength $args] == 12 } {
       #set repdflt [spc_goodrep]
       set spectres [ lindex $args 0 ]
       set lampe [ file tail [ file rootname [ lindex $args 1 ] ] ]
       set etoile_ref [ file tail [ file rootname [ lindex $args 2 ] ] ]
       set etoile_cat [ lindex $args 3 ]
       set methreg [ lindex $args 4 ]
       set methcos [ lindex $args 5 ]
       set methsel [ lindex $args 6 ]
       set methsky [ lindex $args 7 ]
       set methinv [ lindex $args 8 ]
       set methbin [ lindex $args 9 ]
       set methnorma [ lindex $args 10 ]
       set methsmo [ lindex $args 11 ]

       #--- Eliminatoin des mauvaise images :
       ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
       spc_reject $spectres
       set nbimg [ llength [ glob -dir $audace(rep_images) ${spectres}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ spc_pretrait $img $dark $flat $dflat ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       set fsmilex [ spc_smilex2imgs $lampe $fpretrait ]
       delete2 $fpretrait $nbimg

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       set ftilt [ spc_tiltautoimgs $fsmilex ]
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ spc_somme $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
	   #-- Mirrorx du spectre de la lampe de calibration :
	   buf$audace(bufNo) load "$audace(rep_images)/${lampe}_slx"
	   buf$audace(bufNo) mirrorx
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}_slx"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fsadd $methsky $methsel $methbin ]

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       spc_loadfit ${lampe}_slx
       loadima ${lampe}_slx
       #-- Boîte de dialogue pour saisir les paramètres de calibration :
       # tk.message "Selectionnez les corrdonnées x de cahque bords de 2 raies"
       # tk.boite1 xa1 xa2 xb1 xb2
       # tk.message "Donner la longueur d'onde et le type (a/e) des 2 raies"
       # tk.boite2 type1 lammbda1 type2 lambda2
       set err [ catch {
	   ::param_spc_audace_calibre2::run
	   tkwait window .param_spc_audace_calibre2
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       set audace(param_spc_audace,calibre2,config,xa1)
       set audace(param_spc_audace,calibre2,config,xa2)
       set audace(param_spc_audace,calibre2,config,xb1)
       set audace(param_spc_audace,calibre2,config,xb2)
       set audace(param_spc_audace,calibre2,config,type1)
       set audace(param_spc_audace,calibre2,config,type2)
       set audace(param_spc_audace,calibre2,config,lambda1)
       set audace(param_spc_audace,calibre2,config,lambda2)

       set xa1 $audace(param_spc_audace,calibre2,config,xa1)
       set xa2 $audace(param_spc_audace,calibre2,config,xa2)
       set xb1 $audace(param_spc_audace,calibre2,config,xb1)
       set xb2 $audace(param_spc_audace,calibre2,config,xb2)
       set type1 $audace(param_spc_audace,calibre2,config,type1)
       set type2 $audace(param_spc_audace,calibre2,config,type2)
       set lambda1 $audace(param_spc_audace,calibre2,config,lambda1)
       set lambda2 $audace(param_spc_audace,calibre2,config,lambda2)
       #-- Effectue la calibration du spectre 2D de la lampe spectrale :
       set lampecalibree [ spc_calibre2sauto ${lampe}_slx $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $spectres ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]

       #--- Correction de la réponse instrumentale :
       ::console::affiche_resultat "\n\n**** Correction de la réponse intrumentale ****\n\n"
       # file copy $audace(rep_scripts)/spcaudace/data/bibliotheque_spectrale/$etoile_cat$conf(extension,defaut) $audace(rep_images)
       file copy $etoile_cat $audace(rep_images)
       set fricorr [ spc_rinstrumcorr $fcal $etoile_ref $etoile_cat ]
       file rename -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${fcal}_ricorr$conf(extension,defaut)"
       set fricorr "${fcal}_ricorr"


       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_normaraie $fricorr e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_normaraie $fricorr a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fsnorma]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fsnorma"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_geom2rinstrum nom_générique_spectres_prétraités (sans extension) spectre_2D_lampe méthode_reg (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre)  méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_bining (add, rober, horne) normalisation (o/n) adoucissement (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-08-2006
# Date de mise à jour : 28-08-2006
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n)
###############################################################################

proc spc_traite2scalibre { args } {

   global audace spcaudace
   global conf

   if { [llength $args] == 16 } {
       set img [ lindex $args 0 ]
       set dark [ lindex $args 1 ]
       set flat [ lindex $args 2 ]
       set dflat [ lindex $args 3 ]
       set offset [ lindex $args 4 ]
       set lampecalibree [ file tail [ file rootname [ lindex $args 5 ] ] ]
       set methreg [ lindex $args 6 ]
       set methcos [ lindex $args 7 ]
       set methsel [ lindex $args 8 ]
       set methsky [ lindex $args 9 ]
       set methinv [ lindex $args 10 ]
       set methbin [ lindex $args 11 ]
       set methnorma [ lindex $args 12 ]
       set methsmo [ lindex $args 13 ]
       set methejbad [ lindex $args 14 ]
       set methejtilt [ lindex $args 15 ]

       #--- Eliminatoin des mauvaise images :
       if { $methejbad == "o" } {
	   ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Prétraitement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ spc_pretrait $img $dark $flat $dflat ]

       #--- Correction de la courbure des raies (smile selon l'axe x) :
       ::console::affiche_resultat "\n\n**** Correction de la courbure des raies (smile selon l'axe x) ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set a [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   set fsmilex [ spc_smileximgs $fpretrait $ycenter $a ]
       } else {
	   ::console::affiche_resultat "\nAucune correction de la courbure (smilex) des raies possible.\n"
	   set fsmilex "$fpretrait"
       }
       delete2 $fpretrait $nbimg

       #--- Correction du l'inclinaison (tilt)
       ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejtilt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fsmilex o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fsmilex n ]
       }
       delete2 $fsmilex $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]*$conf(extension,defaut) ] ]

       #--- Appariement de $nbimg images :
       ::console::affiche_resultat "\n\n**** Appariement de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "no"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }

       #--- Addition de $nbimg images :
       ::console::affiche_resultat "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ spc_somme $freg ]
       delete2 $ftilt $nbimg
       delete2 $freg $nbimg

       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
       }

       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }

       #--- Soustraction du fond de ciel et binning
       ::console::affiche_resultat "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]

       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_resultat "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]
       set fricorr "$fcal"

       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr e ]
       } elseif { $methnorma == "a" } {
	   ::console::affiche_resultat "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fricorr a ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorr"
       }

       #--- Adoucissement du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_resultat "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Message de fin du script :
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous $fsmooth\n\n"
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       spc_loadfit $fsmooth
       return $fsmooth
   } else {
       ::console::affiche_erreur "Usage: spc_traite2scalibre nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_1D_lampe_calibrée  méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde.
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-02-2007
# Date de mise à jour : 28-02-2007
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne), sélection manuelle d'une raie pour la géométrie (o/n), effacer masters de prétraitement (o/n)
###############################################################################

proc spc_lampe2calibre { args } {

   global audace spcaudace
   global conf
   global lampe2calibre_fileout

   set nbargs [ llength $args ]
   if { $nbargs <= 9 } {
       if { $nbargs == 8 } {
	   set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
	   set img [ file tail [ file rootname [ lindex $args 1 ] ] ]
	   set dark [ file tail [ file rootname [ lindex $args 2 ] ] ]
	   set methcos [ lindex $args 3 ]
	   set methsel [ lindex $args 4 ]
	   set methinv [ lindex $args 5 ]
	   set methbin [ lindex $args 6 ]
	   set methraie [ lindex $args 7 ]
       } elseif { $nbargs == 9 } {
	   set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
	   set img [ file tail [ file rootname [ lindex $args 1 ] ] ]
	   set dark [ file tail [ file rootname [ lindex $args 2 ] ] ]
	   set methcos [ lindex $args 3 ]
	   set methsel [ lindex $args 4 ]
	   set methinv [ lindex $args 5 ]
	   set methbin [ lindex $args 6 ]
	   set methraie [ lindex $args 7 ]
	   set wincoords [ lindex $args 8 ]
       } else {
	   ::console::affiche_erreur "Usage: spc_lampe2calibre spectre_2D_lampe nom_générique_images_objet_(sans extension) nom_dark uncosmic (o/n) méthode_détection_spectre (large, serre) mirrorx (o/n) méthode_binning (add, rober, horne) sélection_manuelle_raie_géométrie (o/n) ?liste_corrdonnées_zone?\n\n"
          return ""
       }

       #--- Prend la première image et le premier dark ou le masterdark :
       # set img1 [ file rootname [ lindex [ glob -dir $audace(rep_images) -tails ${img}\[0-9\]*$conf(extension,defaut) ] 0 ] ]
       #set dark1 [ file rootname [ lindex [ glob -dir $audace(rep_images) -tails ${dark}\[0-9\]*$conf(extension,defaut) ${dark}*$conf(extension,defaut) ] 0 ] ]
       if { [ file exists "$audace(rep_images)/$img$conf(extension,defaut)" ] } {
	   set img1 $img
       } elseif { [ catch { glob -dir $audace(rep_images) ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set img1 [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   ::console::affiche_erreur "Le(s) fichier(s) $img n'existe(nt) pas.\n"
	   return ""
       }
       if { [ file exists "$audace(rep_images)/$dark$conf(extension,defaut)" ] } {
	   set darkmaster $dark
       } elseif { [ catch { glob -dir $audace(rep_images) ${dark}\[0-9\]$conf(extension,defaut) ${dark}\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   renumerote $dark
	   set darkmaster [ bm_smed $dark ]
       } else {
	   ::console::affiche_erreur "Le(s) fichier(s) $dark n'existe(nt) pas.\n"
	   return ""
       }



       #--- Prétraitement du 1ier spectre de l'objet donné pour repérer l'ordonnée du spectre :
       ::console::affiche_resultat "\n\n**** Prétraitement du premier spectre donné pour repérage du spectre ****\n\n"
       #buf$audace(bufNo) load "$audace(rep_images)/$plu1"
       #buf$audace(bufNo) sub "$audace(rep_images)/$dplu1" 0
       #set intensite_moyenne [ lindex [ buf$audace(bufNo) stat ] 4 ]
       #buf$audace(bufNo) ngain $intensite_moyenne
       #buf$audace(bufNo) save "$audace(rep_images)/${plu1}-t"
       buf$audace(bufNo) load "$audace(rep_images)/$img1"
       buf$audace(bufNo) sub "$audace(rep_images)/$darkmaster" 0
       #buf$audace(bufNo) div "$audace(rep_images)/${plu1}-t" $intensite_moyenne
       buf$audace(bufNo) save "$audace(rep_images)/${img}-t"
       #file delete -force "$audace(rep_images)/${plu1}-t$conf(extension,defaut)"
       loadima ${img}-t


       #--- Correction du l'inclinaison (tilt) :
       #
       # ::console::affiche_resultat "\n\n**** Correction du l'inclinaison (tilt) du 1ier spectre ****\n\n"
       # set ftilt [ spc_tiltautoimgs ${img}-t n ]
       # file delete -force "$audace(rep_images)/${img}-t"
       set ftilt ${img}-t

        if { 1==0 } {
	    #-- Cas de plusieurs fichiers :
	    set liste_images [ lsort -dictionary [ glob -dir "$audace(rep_images)" -tails "${filename}\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]$conf(extension,defaut)" "${filename}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut)" ] ]
	    set nbsp [ llength $liste_images ]
	    #--- Détermination de l'angle de tilt :
	    ::console::affiche_resultat "Régistration verticale prélimiaire et somme de $nbsp spectres...\n"
	    set freg [ spc_register "$filename" ]
	    #- 070908 : sadd -> smean :
            #- 091214 : smean -> sadd :
	    set fsomme [ bm_sadd "$freg" ]
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
		# set yrot [ lindex [ spc_detect $fichier ] 0 ]
		# set spectre_tilte [ spc_tilt2 $fichier $angle $xrot $yrot ]
		set spectre_tilte [ spc_tilt3 $fichier $pente ]
		file rename -force "$audace(rep_images)/$spectre_tilte$conf(extension,defaut)" "$audace(rep_images)/${filename}tilt-$i$conf(extension,defaut)"
		::console::affiche_resultat "Spectre corrigé sauvé sous ${filename}tilt-$i$conf(extension,defaut).\n\n"
		incr i
	    }
         }



       #--- Retrait des cosmics :
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$ftilt"
	   uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) save "$audace(rep_images)/$ftilt"
       }


       #--- Traitement du spectre de la lampe de calibration :
       ::console::affiche_resultat "\n\n**** Traitement du spectre de lampe de calibration ****\n\n"
      #-- Retrait du dark : engendre des problemes de détection des raies !
      #----------------------------------------#
       if { 0==1 } {
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       set exposurel [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
       buf$audace(bufNo) load "$audace(rep_images)/$darkmaster"
       set exposured [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
       buf$audace(bufNo) mult [ expr $exposurel/$exposured*1. ]
       buf$audace(bufNo) bitpix short
       buf$audace(bufNo) save "$audace(rep_images)/${darkmaster}t"
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       buf$audace(bufNo) sub "$audace(rep_images)/${darkmaster}t" 0
       buf$audace(bufNo) bitpix short
       buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
       set lampet "${lampe}-t"
       file delete "$audace(rep_images)/${darkmaster}t$conf(extension,defaut)"
       }
      #----------------------------------------#

      buf$audace(bufNo) load "$audace(rep_images)/$lampe"
      if { $spcaudace(lampe_mdark)=="o" } {
         buf$audace(bufNo) sub "$audace(rep_images)/$darkmaster" 0
         #-- Realiser a l'avenir une soustraction au prorata du temps de pose de la lampe
      }
      buf$audace(bufNo) setkwd [ list "SPC_LNM" "$lampe" string "Initial name of calibration lampe file" "" ]
      buf$audace(bufNo) bitpix short
      ##buf$audace(bufNo) save "$audace(rep_images)/$lampe"
      ##file copy -force "$audace(rep_images)/$lampe$conf(extension,defaut)" "$audace(rep_images)/${lampe}-t$conf(extension,defaut)"
      buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
      set lampet "${lampe}-t"

       #-- Correction du smilex du spectre de lampe de calibration :
       set smilexcoefs [ spc_smilex $lampet $methraie ]
       set lampegeom [ lindex $smilexcoefs 0 ]
       #set ycenter [ lindex $smilexcoefs 1 ]
       #set adeg2 [ lindex $smilexcoefs 4 ]

       #-- Inversion gauche-droite :
       if { $methinv == "o" } {
	   set lampeflip [ spc_flip $lampegeom ]
	   file delete -force "$audace(rep_images)/$lampegeom$conf(extension,defaut)"
       } else {
	   set lampeflip "$lampegeom"
       }

       #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
       ::console::affiche_resultat "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
       #-- Création du profil de raie de la lampe :
       if { $nbargs==8 } {
	   set profillampe [ spc_profillampe $ftilt $lampeflip $methraie ]
       } elseif { $nbargs==9 } {
	   set profillampe [ spc_profillampezone $lampeflip $wincoords ]
       }
       #-- Calibration de la lampe avec gestion des types de calibrations (Relco, manu, fichier...) :
       set lampecalibree [ spc_calibre "$profillampe" ]
       #-- Menage :
       file delete -force "$audace(rep_images)/$profillampe$conf(extension,defaut)"
       #set lampecalibree "lampe_redressee_calibree"
       file delete -force "$audace(rep_images)/${img}-t$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$lampet$conf(extension,defaut)"

    #-------------------------------------------------------#
    if { 1==0 } {
      #--- Calcul la resolution du spectre à partir de la raie la plus brillante trouvée et proche du centre du capteur :
      ::console::affiche_resultat "\nCalcul la résolution du spectre...\n"
      # set lambda_raiemax [ lindex [ lindex [ spc_findbiglines $lampecalibree e ] 0 ] 0 ]
      set liste_raies [ spc_findbiglines $lampecalibree e ]
      #- Selection des raies dont I>=0.1*Imax et trie selon les abscisses :
      set liste_raies [ spc_selectstronglines $liste_raies ]

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
   }
   #-------------------------------------------------------#

      #-- Calcul de la resolution et l'ecrit dans le header :
      set resolution [ spc_autoresolution $lampecalibree ]


       #--- Message de fin du script :
       set nomimg [ string trim $img "-" ]
       file rename -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)" "$audace(rep_images)/lampe_spectre2D_redresse-$nomimg$conf(extension,defaut)"
       file rename -force "$audace(rep_images)/$lampecalibree$conf(extension,defaut)" "$audace(rep_images)/lampe_redressee_calibree-${nomimg}$conf(extension,defaut)"
       ::console::affiche_resultat "\n\nSpectre de lampe de calibration corrigé et calibré sauvé sous lampe_redressee_calibree-${nomimg}$conf(extension,defaut)\n\n"
       spc_loadfit lampe_redressee_calibree-${nomimg}
       set lampe2calibre_fileout "lampe_redressee_calibree-${nomimg}"
       return lampe_redressee_calibree-${nomimg}
   } else {
      ::console::affiche_erreur "Usage: spc_lampe2calibre spectre_2D_lampe nom_générique_images_objet_(sans extension) nom_dark uncosmic (o/n) méthode_détection_spectre (large, serre) mirrorx (o/n) méthode_binning (add, rober, horne) sélection_manuelle_raie_géométrie (o/n) ?liste_corrdonnées_zone?\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  14-07-2006
# Date de mise à jour : 14-07-2006/061230
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_étoile_référence profil_étoile_catalogue méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n), sélection manuelle d'une raie pour la géométrie (o/n), effacer masters de prétraitement (o/n)
###############################################################################

proc spc_traite2rinstrum { args } {

   global audace spcaudace
   global conf

   if { [llength $args] == 21 } {
       set img [ lindex $args 0 ]
       set dark [ file rootname [ lindex $args 1 ] ]
       set flat [ lindex $args 2 ]
       set dflat [ file rootname [ lindex $args 3 ] ]
       set offset [ file rootname [ lindex $args 4 ] ]
       set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
       set etoile_cat [ lindex $args 6 ]
       # etoile_cat contient le chemin et le nom du fichier
       set methreg [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methsel [ lindex $args 9 ]
       set methsky [ lindex $args 10 ]
       set methinv [ lindex $args 11 ]
       set methbin [ lindex $args 12 ]
       set methnorma [ lindex $args 13 ]
       set methsmo [ lindex $args 14 ]
       set methejb [ lindex $args 15 ]
       set methejt [ lindex $args 16 ]
       set methraie [ lindex $args 17 ]
       #set methmasters [ lindex $args 18 ]
       set rmfpretrait [ lindex $args 18 ]
       set flag_calibration [ lindex $args 19 ]
       set methcalo [ lindex $args 20 ]

       #--- Debut du pipeline de calcul de la RI :
       ::console::affiche_prompt "\n\n**** PIPELINE DE CALCUL DE LA REPONSE INSTRUMENTALE ****\n\n"


       #--- Elimination des mauvaise images :
       if { $methejb == "o" } {
	   ::console::affiche_resultat "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       renumerote $img

       #[ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

       #--- Comptage des images :
       set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]

       #--- Renumérotation et détection des darks :
       if { [ file exists "$audace(rep_images)/$dark$conf(extension,defaut)" ] } {
	   set darkmaster $dark
       } elseif { [ catch { glob -dir $audace(rep_images) ${dark}\[0-9\]$conf(extension,defaut) ${dark}\[0-9\]\[0-9\]$conf(extension,defaut) ${dark}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   renumerote $dark
	   set darkmaster [ bm_smed $dark ]
       } else {
	   ::console::affiche_resultat "Le(s) fichier(s) $dark n'existe(nt) pas.\n"
	   return ""
       }


       #--- Renumérotation et détection des darks_flat : 070323
       if { [ file exists "$audace(rep_images)/$dflat$conf(extension,defaut)" ] } {
	   set darkflatmaster $dflat
       } elseif { [ catch { glob -dir $audace(rep_images) ${dflat}\[0-9\]$conf(extension,defaut) ${dflat}\[0-9\]\[0-9\]$conf(extension,defaut) ${dflat}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   renumerote $dflat
	   set darkflatmaster [ bm_smed $dflat ]
       } else {
	   ::console::affiche_resultat "Le(s) fichier(s) $dflat n'existe(nt) pas.\n"
	   return ""
       }



       #--- Traitement du spectre de la lampe de calibration :
       #- spc_traite2rinstrum n'utilise pas spc_lampe2calibre
      if { $flag_calibration == 0 } {
           ### set lampecalibree [ spc_lampe2calibre "$lampe" "$img" "$dark" $methcos $methsel $methinv $methbin $methraie ]
	   ::console::affiche_prompt "\n\n**** Traitement du spectre de lampe de calibration ****\n\n"
	   #-- Retrait du dark :
           buf$audace(bufNo) load "$audace(rep_images)/$lampe"
           #- Le retrait du dark perturbe le smilex ;
	   #buf$audace(bufNo) sub "$audace(rep_images)/$darkmaster" 0
	   buf$audace(bufNo) save "$audace(rep_images)/${lampe}-t"
	   set lampet "${lampe}-t"

	   #-- Correction du smilex du spectre de lampe de calibration :
	   set smilexcoefs [ spc_smilex "$lampet" $methraie ]
	   file delete -force "$audace(rep_images)/$lampet$conf(extension,defaut)"
	   set lampegeom [ lindex $smilexcoefs 0 ]
	   #set ycenter [ lindex $smilexcoefs 1 ]
	   #set adeg2 [ lindex $smilexcoefs 4 ]

	   #-- Inversion gauche-droite :
	   if { $methinv == "o" } {
	       set lampeflip [ spc_flip "$lampegeom" ]
	       file delete -force "$audace(rep_images)/$lampegeom$conf(extension,defaut)"
	   } else {
	       set lampeflip "$lampegeom"
	   }

	   #--- Etalonnage en longueur d'onde du spectre de lampe de calibration :
	   ::console::affiche_prompt "\n\n**** Etalonnage en longueur d'onde du spectre de lampe de calibration ****\n\n"
	   #-- Création du profil de raie de la lampe :
	   set profillampe [ spc_profillampe ${img}1 "$lampeflip" ]
          #file delete -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)"
           #-- Calibration de la lampe avec gestion des types de calibrations (Relco, manu, fichier...) :
           set lampecalibree [ spc_calibre "$profillampe" ]
          

           #-- Calcul la resolution du spectre de la lampe :
           set lampecalibree [ spc_autoresolution "$lampecalibree" ]
           #-- Fin du traitement lampe :
	   set nomimg [ string trim $img "-" ]
	   file copy -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)" "$audace(rep_images)/lampe_spectre2D-traite-$nomimg$conf(extension,defaut)"
	   file delete -force "$audace(rep_images)/$lampeflip$conf(extension,defaut)"
	   file delete -force "$audace(rep_images)/$profillampe$conf(extension,defaut)"
	   #- 04012007 :
	   file rename -force "$audace(rep_images)/$lampecalibree$conf(extension,defaut)" "$audace(rep_images)/lampe_redressee_calibree-$nomimg$conf(extension,defaut)"
	   set lampecalibree "lampe_redressee_calibree-$nomimg"
           spc_loadfit "$lampecalibree"
       } elseif { $flag_calibration == 1 } {
	   set lampecalibree "$lampe"
       }


       #--- Prétraitement de $nbimg images :
       ::console::affiche_prompt "\n\n**** Prétraitement de $nbimg images ****\n\n"
       set fpretrait [ spc_pretrait $img $dark $flat $dflat $offset $rmfpretrait ]

      #--- Detection du tilt sur les bruts :
      #spc_findgeomimgs "$img"


       #--- Corrections géométriques des raies (smile selon l'axe x ou slant) :
       ::console::affiche_prompt "\n\n**** Corrections géométriques du spectre 2D ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   ::console::affiche_prompt "\n** Correction de la courbure des raies (smile selon l'axe x)... **\n"
	   set fgeom [ spc_smileximgs $fpretrait $spc_ycenter $spc_cdeg2 ]
       } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
	   set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
	   ::console::affiche_prompt "\n** Correction de l'inclinaison des raies (slant)... **\n"
	   set fgeom [ spc_slant2imgs $fpretrait $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction géométrique nécessaire. **\n"
	   set fgeom "$fpretrait"
       }


       #--- Correction du l'inclinaison (tilt) :
       ::console::affiche_prompt "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
       if { $methejt == "o" } {
	   set ftilt [ spc_tiltautoimgs $fgeom o ]
       } else {
	   set ftilt [ spc_tiltautoimgs $fgeom n ]
       }


       #--- Effacement des images prétraitées : NON UTILISE
       #if { $rmfpretrait=="o" && [ file exists $audace(rep_images)/${fpretrait}-1$conf(extension,defaut) ] }
       delete2 $fpretrait $nbimg
       delete2 $fgeom $nbimg
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]


       #::console::affiche_resultat "Sortie : $ftilt\n"
       #--- Appariement de $nbimg images :
       ::console::affiche_prompt "\n\n**** Appariement vertical de $nbimg images ****\n\n"
       if { $methreg == "spc" } {
	   set freg [ spc_register $ftilt ]
       } elseif { $methreg == "reg" } {
	   set freg [ bm_register $ftilt ]
       } elseif { $methreg == "n"} {
	   set freg "$ftilt"
       } else {
	   ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
       }


       #::console::affiche_resultat "Sortie : $freg\n"
       #--- Addition de $nbimg images :
       ::console::affiche_prompt "\n\n**** Addition de $nbimg images ****\n\n"
       set fsadd [ spc_somme $freg ]


       #--- Effacement des images prétraitées :
       if { $rmfpretrait=="o" } {
	   delete2 $ftilt $nbimg
       }
       if { $rmfpretrait=="o" } {
	   delete2 $freg $nbimg
       }


       #::console::affiche_resultat "Sortie : $fsadd\n"
       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
           buf$audace(bufNo) bitpix ulong
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
           buf$audace(bufNo) bitpix short
       }

       #--- Inversion gauche-droite du spectre 2D prétraité (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
       } else {
	   set fflip "$fsadd"
       }
       #--- Renammage du spectre 2D : avant spc_profil qui save en 16 bits le spectre 2D !
       file copy -force "$audace(rep_images)/$fflip$conf(extension,defaut)" "$audace(rep_images)/${img}-spectre2D-traite$conf(extension,defaut)"


       #--- Soustraction du fond de ciel et binning
       ::console::affiche_prompt "\n\n**** Extraction du profil de raies ****\n\n"
       set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]
       file delete -force "$audace(rep_images)/$fflip$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fsadd$conf(extension,defaut)"
      
      
       #--- Ajout du nom du spectre de bibliotheque dans l'entete :
       buf$audace(bufNo) load "$audace(rep_images)/$fprofil"
       buf$audace(bufNo) setkwd [ list "SPC_REFL" "$etoile_cat" string "Reference spectrum used from library" "" ]
       buf$audace(bufNo) bitpix float
       buf$audace(bufNo) save "$audace(rep_images)/$fprofil"
       buf$audace(bufNo) bitpix short


       #--- Calibration en longueur d'onde du spectre de l'objet :
       ::console::affiche_prompt "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       set fcal [ spc_calibreloifile $lampecalibree $fprofil ]
       file copy -force "$audace(rep_images)/$fprofil$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1a$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fprofil$conf(extension,defaut)"


       #--- Calibration avec les raies telluriques :
       if { $methcalo == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fcal"
	   set listemotsclef [ buf$audace(bufNo) getkwds ]
	   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_prompt "\n\n**** Calibration préparatoire avec les raies telluriques ****\n\n"
		   set fcalo [ spc_calibretelluric "$fcal" ]
	       } else {
		   ::console::affiche_erreur "\n\n**** Calibration  préparatoire avec les raies telluriques non réalisée car dispersion insuffisante ****\n\n"
		   set fcalo "$fcal"
	       }
	   } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_prompt "\n\n**** Calibration préparatoire avec les raies telluriques ****\n\n"
		   set fcalo [ spc_calibretelluric "$fcal" ]
	       } else {
		   ::console::affiche_erreur "\n\n**** Calibration préparatoire avec les raies telluriques non réalisée car dispersion lineaire insuffisante ****\n\n"
		   set fcalo "$fcal"
	       }
	   }
       } else {
	   set fcalo "$fcal"
       }
       file copy -force "$audace(rep_images)/$fcalo$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1b$conf(extension,defaut)"



       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie $fcalo e ]
       } elseif { $methnorma == "r" } {
	   ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
	   # set fnorma [ spc_autonormaraie $fcalo a ]
	   set fnorma [ spc_rescalecont "$fcalo" ]
       } elseif { $methsmo == "n" } {
	   set fnorma "$fcalo"
       }

       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
	   ::console::affiche_prompt "\n\n**** Adoucissement du profil de raies ****\n\n"
	   set fsmooth [ spc_smooth $fnorma ]
       } elseif { $methsmo == "n" } {
	   set fsmooth "$fnorma"
       }

       #--- Calcul de la réponse intrumentale :
       ::console::affiche_prompt "\n\n**** Calcul de la réponse intrumentale ****\n\n"
       file copy -force "$spcaudace(rep_spcbib)/$etoile_cat" "$audace(rep_images)"
       # set fricorr [ spc_rinstrumcorr $fcal $etoile_ref $etoile_cat ]
       set rep_instrum [ spc_rinstrum "$fcalo" "$etoile_cat" ]
       ::console::affiche_resultat "\nRéponse instrumentale sauvée sous $rep_instrum\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampecalibree"
       set naxis1 [  lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
       set cdelt1 [  lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
       set largeur_spectrale [ expr $cdelt1*$naxis1 ]

       #--- Correction de l'étoile de référence par la réponse instrumentale :
       ::console::affiche_prompt "\n\n**** Division par la réponse intrumentale ****\n\n"
       if { [ file exists "$audace(rep_images)/${rep_instrum}3$conf(extension,defaut)" ] } {
	   set fricorr1 [ spc_divri "$fcalo" ${rep_instrum}3 ]
           set fricorr [ spc_linearcal $fricorr1 ]
           file delete -force "$audace(rep_images)/$fricorr1$conf(extension,defaut)"
           file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c$conf(extension,defaut)"
       } elseif { [ file exists "$audace(rep_images)/${rep_instrum}br$conf(extension,defaut)" ] } {
	   #- set fricorr1 [ spc_divri "$fcalo" ${rep_instrum}br ]
           set fricorr2 [ spc_divbrut "$fcalo" ${rep_instrum}br ]
           set fricorr1 [ spc_rmextrema "$fricorr2" ]
           set fricorr [ spc_linearcal $fricorr1 ]
           file delete -force "$audace(rep_images)/$fricorr1$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/$fricorr2$conf(extension,defaut)"
           file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c$conf(extension,defaut)"
       } else {
	   set fricorr "$fcalo"
       }



       #--- Calibration finale avec les raies telluriques :
       if { $methcalo == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fricorr"
	   set listemotsclef [ buf$audace(bufNo) getkwds ]
	   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_prompt "\n\n**** Calibration finale avec les raies telluriques ****\n\n"
		   set ffinal [ spc_calibretelluric "$fricorr" ]
	       } else {
		   ::console::affiche_erreur "\n\n**** Calibration finale avec les raies telluriques non réalisée car dispersion insuffisante ****\n\n"
		   set ffinal "$fricorr"
	       }
	   } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_prompt "\n\n**** Calibration finale avec les raies telluriques ****\n\n"
		   set ffinal [ spc_calibretelluric "$fricorr" ]
	       } else {
		   ::console::affiche_erreur "\n\n**** Calibration finale avec les raies telluriques non réalisée car dispersion linéaire insuffisante ****\n\n"
		   set ffinal "$fricorr"
	       }
	   }
       } else {
	   set ffinal "$fricorr"
       }

      
       #--- Nettoyage des fichiers :
       #file copy -force "$audace(rep_images)/$fcalo$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1b$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fcalo$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
       if { $methcalo == "o" } {
          #file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c$conf(extension,defaut)"
          #file copy -force "$audace(rep_images)/$ffinal$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c-ocal$conf(extension,defaut)"
       } else {
          #file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c$conf(extension,defaut)"
       }
       file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$ffinal$conf(extension,defaut)"
       set etoile_cat [ file rootname $etoile_cat ]
       file delete -force "$audace(rep_images)/$etoile_cat$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/${etoile_cat}_ech$conf(extension,defaut)"

       #--- Message de fin du script :
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       if { [ file exist ${img}-profil-1c-ocal$conf(extension,defaut) ] } {
         set profil_final_termine "${img}-profil-1c-ocal"
       } else {
         set profil_final_termine "${img}-profil-1c"

       }
       spc_gdeleteall
       spc_loadfit "$profil_final_termine"
       spc_pipeabstract "$profil_final_termine" "${img}-profil-"
       loadima "$audace(rep_images)/${img}-spectre2D-traite"
       return "${img}-profil-1c"
   } else {
       ::console::affiche_erreur "Usage: spc_traite2rinstrum nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe profil_étoile_catalogue méthode_appariement (reg, spc, n) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_bad_spectres (o/n) rejet_rotation_importante (o/n) sélection_manuelle_raie_géométrie (o/n) effacer_masters (o/n)\n\n"
   }
}
#**********************************************************************************#





###############################################################################
# Procédure de traitement de spectres 2D : prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-08-2006
# Date de mise à jour : 28-08-2006
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traite2srinstrum { args } {

   global audace spcaudace
   global conf

   set nbargs [ llength $args ]
   if { $nbargs<=21 } {
       if { $nbargs == 20 } {
          set img [ lindex $args 0 ]
          set dark [ file rootname [ lindex $args 1 ] ]
          set flat [ lindex $args 2 ]
          set dflat [ file rootname [ lindex $args 3 ] ]
          set offset [ file rootname [ lindex $args 4 ] ]
          set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
          set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
          set methreg [ lindex $args 7 ]
          set methcos [ lindex $args 8 ]
          set methsel [ lindex $args 9 ]
          set methsky [ lindex $args 10 ]
          set methinv [ lindex $args 11 ]
          set methbin [ lindex $args 12 ]
          set methnorma [ lindex $args 13 ]
          set methsmo [ lindex $args 14 ]
          set methejbad [ lindex $args 15 ]
          set methejtilt [ lindex $args 16 ]
          set rmfpretrait [ lindex $args 17 ]
          set export_png [ lindex $args 18 ]
          set flag_2lamps [ lindex $args 19 ]
          set flag_nonstellaire 0
       } elseif { $nbargs==21 } {
          set img [ lindex $args 0 ]
          set dark [ lindex $args 1 ]
          set flat [ lindex $args 2 ]
          set dflat [ lindex $args 3 ]
          set offset [ lindex $args 4 ]
          set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
          set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
          set methreg [ lindex $args 7 ]
          set methcos [ lindex $args 8 ]
          set methsel [ lindex $args 9 ]
          set methsky [ lindex $args 10 ]
          set methinv [ lindex $args 11 ]
          set methbin [ lindex $args 12 ]
          set methnorma [ lindex $args 13 ]
          set methsmo [ lindex $args 14 ]
          set methejbad [ lindex $args 15 ]
          set methejtilt [ lindex $args 16 ]
          set rmfpretrait [ lindex $args 17 ]
          set export_png [ lindex $args 18 ]
          set flag_2lamps [ lindex $args 19 ]
          set windowcoords [ lindex $args 20 ]
          set flag_nonstellaire 1
       } else {
          ::console::affiche_erreur "Usage: spc_traite2srinstrum nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc, n) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) effacer_masters (o/n) export_PNG (o/n) ?2 spectres de calibration (o/n)? ?fenêtre_binning {x1 y1 x2 y2}?\n\n"
	   return ""
       }

      #--- Traitement et calibration de la lampe :
      #- Effectuee par spc_lampe2calibre
      #- Est execute avant spc_traite2srinstrum dans les fonctions spc_traitestellaire et spc_traitenebula
      #- spc_traite2rinstrum n'utilise pas spc_lampe2calibre


       #--- Elimination des mauvaises images :
       if { $methejbad == "o" } {
	   ::console::affiche_prompt "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $img
       }
       if { [ file exists "$audace(rep_images)/$img$conf(extension,defaut)" ] } {
          set nbimg 1
          set nbimg_ini 1
       } else {
          set nbimg [ llength [ glob -dir $audace(rep_images) ${img}\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]$conf(extension,defaut) ${img}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
          set nbimg_ini $nbimg
       }

      #--- Detection du tilt sur les bruts :
      if { $flag_nonstellaire==0 } {
          spc_findgeomimgs "$img"
      }


       #--- Prétraitement de $nbimg images :
       ::console::affiche_prompt "\n\n**** Prétraitement de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 } {
	   set fpretrait [ spc_pretrait $img $dark $flat $dflat $offset $rmfpretrait $windowcoords ]
       } else {
	   set fpretrait [ spc_pretrait $img $dark $flat $dflat $offset $rmfpretrait ]
       }



       #--- Correction du l'inclinaison (tilt) :
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       #-- Memorise le nom initial du spectre de la lampe de calibration :
       if { [ lsearch $listemotsclef "SPC_LNM" ]!=-1 } {
          set lampe_name [ lindex [ buf$audace(bufNo) getkwd "SPC_LNM" ] 1 ]
       } else {
          set lampe_name "$lampe"
          set flag_2lamps "n"
       }

       #-- Effectue la correction de tilt :
       if { $flag_nonstellaire==1 } {
          #-- Temporaire : si le spectre de lampe donné est deja corrige geometriquement, utilise ses parametres :
          ::console::affiche_prompt "\n\n**** Correction de l'inclinaison (tilt) des spectres ****\n\n"
          buf$audace(bufNo) load "$audace(rep_images)/$lampe"
          set listemotsclef [ buf$audace(bufNo) getkwds ]
          if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 && [ lsearch $listemotsclef "SPC_TILX" ]!=-1 } {
             set spc_angletilt [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
             set spc_tiltx [ lindex [ buf$audace(bufNo) getkwd "SPC_TILX" ] 1 ]
             set spc_tilty [ lindex [ buf$audace(bufNo) getkwd "SPC_TILY" ] 1 ]
             set ftilt [ spc_tilt2imgs $fpretrait $spc_angletilt $spc_tiltx $spc_tilty ]
          } else {
             buf$audace(bufNo) load "$audace(rep_images)/$rinstrum"
             set listemotsclef [ buf$audace(bufNo) getkwds ]
             if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 && [ lsearch $listemotsclef "SPC_TILX" ]!=-1 } {
                ::console::affiche_resultat "** Correction TILT avec parametres de reponse_instrumentale. **\n"
                set spc_angletilt [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
                set spc_tiltx [ lindex [ buf$audace(bufNo) getkwd "SPC_TILX" ] 1 ]
                set spc_tilty [ lindex [ buf$audace(bufNo) getkwd "SPC_TILY" ] 1 ]
                set ftilt [ spc_tilt2imgs $fpretrait $spc_angletilt $spc_tiltx $spc_tilty ]
             } else {
                #-- Pas de correction de l'inclinaison pour les spectres non stellaires :
                ::console::affiche_erreur "\n\nPAS DE CORRECTION DE L'INCLINAISON POUR LES SPECTRES NON STELLAIRES\n\n"
                set ftilt "$fpretrait"
             }
          }
       } else {
          ::console::affiche_prompt "\n\n**** Correction de l'inclinaison (tilt) des spectres ****\n\n"
          ::console::affiche_resultat "** Correction directe du TILT sur les spectres. **\n"
          if { $methejtilt == "o" } {
             set ftilt [ spc_tiltautoimgs $fpretrait o ]
          } else {
             set ftilt [ spc_tiltautoimgs $fpretrait n ]
          }
          #-- Si l'angle de tilt est > spcaudace(tilt_limit), alors utilise l'angle present dans la reponse instrumentale si elle con,tient SPC_TILT :
          buf$audace(bufNo) load "$audace(rep_images)/${ftilt}1"
          set spc_tiltri [ expr abs([ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]) ]
          if { $spc_tiltri>=$spcaudace(tilt_limit) } {
             buf$audace(bufNo) load "$audace(rep_images)/$rinstrum"
             set listemotsclef [ buf$audace(bufNo) getkwds ]
             if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 && [ lsearch $listemotsclef "SPC_TILX" ]!=-1 } {
                ::console::affiche_resultat "\n** Correction du TILT avec parametres de reponse_instrumentale. **\n"
                set spc_angletilt [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
                set spc_tiltx [ lindex [ buf$audace(bufNo) getkwd "SPC_TILX" ] 1 ]
                set spc_tilty [ lindex [ buf$audace(bufNo) getkwd "SPC_TILY" ] 1 ]
                set ftilt [ spc_tilt2imgs $fpretrait $spc_angletilt $spc_tiltx $spc_tilty ]
             }
          }
       }

       #--- Corrections géométriques des raies (smile selon l'axe x ou slant) que lorsque l'on a un spectre 2D de lampe :
       ::console::affiche_prompt "\n\n**** Corrections géométriques du spectre 2D ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampe"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   ::console::affiche_prompt "\n*** Correction de la courbure des raies (smile selon l'axe x)... ***\n\n"
	   set fgeom [ spc_smileximgs $ftilt $spc_ycenter $spc_cdeg2 ]
       } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
	   set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
	   ::console::affiche_prompt "\n** Correction de l'inclinaison des raies (slant)... **\n"
	   set fgeom [ spc_slant2imgs $ftilt $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction géométrique de slant réalisée. **\n"
	   set fgeom "$ftilt"
       }



       #if { $rmfpretrait=="o" && [ file exists $audace(rep_images)/${fgeom}-1$conf(extension,defaut) ] }
       #--- Appariement horizontal :
       if { $flag_2lamps == "o" } {
          set result_grep [ regexp {(.+\-?)[0-9]+} "$lampe_name" match prefixe_lampe ]
          if { $result_grep==0 } {
             set fhreg "$fgeom"
          } elseif { [ file exists "$audace(rep_images)/${prefixe_lampe}2$conf(extension,defaut)" ]==1 } {
             ::console::affiche_prompt "\n\n******* Appariement horizontal de $nbimg images *******\n\n"
             set fhreg [ spc_registerh "$lampe" "$fgeom" ]
          } else {
             set fhreg "$fgeom"
          }
       } else {
          set fhreg "$fgeom"
       }


       #--- Effacement des images prétraitées :
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
       if { $rmfpretrait=="o" } {
	   delete2 $fpretrait $nbimg
       }


       #--- Appariement vertical de $nbimg images :
       ::console::affiche_prompt "\n\n**** Appariement vertical de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 || $nbimg_ini==1 } {
	   ::console::affiche_resultat "\n Pas d'appariement vertical pour les spectres non stellaires ou solitaires\n"
	   set freg "$fhreg"
       } else {
	   if { $methreg == "spc" } {
	       set freg [ spc_register "$fhreg" ]
	   } elseif { $methreg == "reg" } {
	       set freg [ bm_register "$fhreg" ]
	   } elseif { $methreg == "n"} {
	       set freg "$fhreg"
	   } else {
	       ::console::affiche_resultat "\nOption d'appariement incorrecte\n"
	   }
       }


       #--- Addition de $nbimg images :
       ::console::affiche_prompt "\n\n**** Addition de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 } {
          #-- Somme des images pour les spectres non-stellaires car faibles :
          set fsadd [ spc_somme "$freg" addi ]
       } elseif { $nbimg_ini==1 } {
          file copy -force "$audace(rep_images)/$freg$conf(extension,defaut)" "$audace(rep_images)/${freg}-s$conf(extension,defaut)"
          set fsadd "${freg}-s"
       } else {
          #-- Somme moyenne des images pour les spectres stellaires car brillants :
          #- set fsadd [ spc_somme "$freg" moy ] par defaut
          set fsadd [ spc_somme "$freg" ]
       }

       if { $rmfpretrait=="o" } {
          if { $nbimg_ini==1 } {
             file delete -force "$audace(rep_images)/$fgeom$conf(extension,defaut)"
          } else {
             delete2 "$fgeom" $nbimg
          }
       }


       #--- Effacement des images prétraitées :
       if { $rmfpretrait=="o" } {
	   delete2 "$ftilt" $nbimg
       }
       if { $rmfpretrait=="o" } {
	   delete2 "$fhreg" $nbimg
       }
       if { $rmfpretrait=="o" } {
	   delete2 "$freg" $nbimg
       }


       #--- Retrait des cosmics
       if { $methcos == "o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   uncosmic $spcaudace(uncosmic)
	   #uncosmic $spcaudace(uncosmic)
	   buf$audace(bufNo) setkwd [ list SPC_COSM "removed, weighted median filter" string "Method used for erasing cosmics" "" ]
           buf$audace(bufNo) bitpix ulong
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
           buf$audace(bufNo) bitpix short
       } else {
	   buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
	   buf$audace(bufNo) setkwd [ list SPC_COSM "none" string "Method used for erasing cosmics" "" ]
           buf$audace(bufNo) bitpix ulong
	   buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
           buf$audace(bufNo) bitpix short
       }


       #--- Inversion gauche-droite du spectre 2D (mirrorx)
       if { $methinv == "o" } {
	   set fflip [ spc_flip $fsadd ]
	   file delete -force "$audace(rep_images)/$fsadd$conf(extension,defaut)"
       } else {
	   set fflip "$fsadd"
       }
       file copy -force "$audace(rep_images)/$fflip$conf(extension,defaut)" "$audace(rep_images)/${img}-spectre2D-traite$conf(extension,defaut)"


       #--- Soustraction du fond de ciel et binning :
       ::console::affiche_prompt "\n\n**** Extraction du profil de raies ****\n\n"
       if { $flag_nonstellaire==1 } {
	   set fprofil [ spc_profilzone $fflip $windowcoords $methsky $methbin ]
       } else {
	   set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]
       }
       file delete -force "$audace(rep_images)/$fflip$conf(extension,defaut)"


       #--- Calibration en longueur d'onde du spectre de l'objet (niveau 1b) :
       ::console::affiche_prompt "\n\n**** Calibration en longueur d'onde du spectre de l'objet $img ****\n\n"
       #- Pour les spectre d'objets non-stellaire, la calibration est faite a partir de la zone decoupée de lampe.
       set fcal [ spc_calibreloifile "$lampe" "$fprofil" ]
       file copy -force "$audace(rep_images)/$fprofil$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1a$conf(extension,defaut)"
       file delete -force "$audace(rep_images)/$fprofil$conf(extension,defaut)"
       file copy -force "$audace(rep_images)/$fcal$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1b$conf(extension,defaut)"


       #--- Correction de la réponse intrumentale :
      buf$audace(bufNo) load "$audace(rep_images)/${img}-profil-1b"
      set naxis1 [  lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
      set cdelt1 [  lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
      set largeur_spectrale [ expr $cdelt1*$naxis1 ]
      if { $largeur_spectrale >= $spcaudace(bande_br) } {
         set spcaudace(rm_edges) "n"
      }
       if { $rinstrum=="none" } {
          set fricorr "$fcal"
          #-- Linearisation de la calibration a partir du niveau 1b_lin :
          set fricorrlin1 [ spc_linearcal "$fricorr" ]             
          #-- Elimination des bords "nuls" :
          if { $spcaudace(rm_edges)=="o" } {
             set fricorrlin [ spc_rmedges "$fricorrlin1" ]
             file delete -force "$audace(rep_images)/$fricorrlin1$conf(extension,defaut)"
          } else {
             set fricorrlin "$fricorrlin1"
          }
          file copy -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1b$conf(extension,defaut)"
          file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1b_nonlin$conf(extension,defaut)"
          file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
       } else {
          ::console::affiche_prompt "\n\n**** Correction de la réponse intrumentale ****\n\n"
          if { $largeur_spectrale >= $spcaudace(bande_br) } {
             set imaxtol $spcaudace(imax_tolerence)
             set spcaudace(imax_tolerence) 1.10
          }
	   #-- Messge d'erreur en cas d'une sélection de plage de longueur d'onde :
	   if { $flag_nonstellaire==1 } {
	       set xdeb [ lindex $windowcoords 0 ]
	       set xfin [ lindex $windowcoords 2 ]
	       if { $xdeb>1 || $xfin<$naxis1 } {
		   ::console::affiche_erreur "\nPAS DE CORRECTION DE LA RÉPONSE INSTRUMENTALE LORS D'UNE SÉLECTION DE LARGEUR SPÉCIFIQUE DU SPECTRE.\n"
		   set fricorr "$fcal"
	       } else {
                  set fricorr [ spc_divri "$fcal" "$rinstrum" ]
	       }
	   } else {
              if { $largeur_spectrale >= $spcaudace(bande_br) } {
                 # set fricorr [ spc_divbrut "$fcal" "$rinstrum" ]
                 set fricorr [ spc_divri "$fcal" "$rinstrum" ]
              } else {
                 set fricorr [ spc_divri "$fcal" "$rinstrum" ]
              }
	   }
          if { $largeur_spectrale >= $spcaudace(bande_br) } {
             set spcaudace(imax_tolerence) $imaxtol
          }


	   #-- Division du profil par la RI :
	   ## set rinstrum_ech [ spc_echant $rinstrum $fcal ]
	   ## set fricorr [ spc_div $fcal $rinstrum_ech ]
	   #- Beaucoup de mise a 0 si methode avec reechant avant. Methode courante est calibreloifile :
	   # set fricorr [ spc_divri $fcal $rinstrum ]
	   #- 040107 :
	   ## set fricorr [ spc_div $fcal $rinstrum ]

	   #-- Message d'erreur en cas d'échec de la division et linéarisation de la calibration :
	   if { $fricorr == 0 } {
	       ::console::affiche_erreur "\nLa division par la réponse intrumentale n'a pas pu peut être calculée.\n"
	       return 0
	   } else {
              #-- Linearisation de la calibration a partir du niveau 1c :
              set fricorrlin1 [ spc_linearcal "$fricorr" ]             
              #-- Elimination des bords "nuls" :
              if { $spcaudace(rm_edges)=="o" } {
                 set fricorrlin [ spc_rmedges "$fricorrlin1" ]
                 file delete -force "$audace(rep_images)/$fricorrlin1$conf(extension,defaut)"
              } else {
                 set fricorrlin "$fricorrlin1"
              }
              file copy -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c$conf(extension,defaut)"
              file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-1c_nonlin$conf(extension,defaut)"
              file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
	   }
       }
       set spcaudace(rm_edges) "o"


       #--- Normalisation du profil de raies :
       if { $methnorma == "e" } {
	   ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie "$fricorrlin" e ]
	   file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-2b$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
           set fnorma "${img}-profil-2b"
       } elseif { $methnorma == "a" } {
	   ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonormaraie "$fricorrlin" a ]
	   file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-2b$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
           set fnorma "${img}-profil-2b"
       } elseif { $methnorma == "r" } {
	   ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_rescalecont "$fricorrlin" ]
	   file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-2b$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
           set fnorma "${img}-profil-2b"
       } elseif { $methnorma == "o" } {
	   ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
	   set fnorma [ spc_autonorma "$fricorrlin" ]
	   file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
	   file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-2b$conf(extension,defaut)"
           file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
           set fnorma "${img}-profil-2b"
       } elseif { $methsmo == "n" } {
	   set fnorma "$fricorrlin"
       }



       #--- Doucissage du profil de raies :
       if { $methsmo == "o" } {
          ::console::affiche_prompt "\n\n**** Adoucissement du profil de raies ****\n\n"
          set fsmooth [ spc_smooth "$fnorma" ]
          if { $methnorma != "n" } {
             file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"  
          }
       } elseif { $methsmo == "n" } {
          set fsmooth "$fnorma"
       }


       #--- Linéarisation de la calibration en longueur d'onde :
       if { $spcaudace(linear_cal)=="o" } {
	   set flinearcal [ spc_linearcal "$fsmooth" ]
       } else {
	   set flinearcal "$fsmooth"
       }


       #--- Export au format PNG :
       if { $export_png=="o" } {
	   set fichier_png [ spc_export2png "$flinearcal" ]
       }


       #--- Message de fin du script :
       file copy -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)" "$audace(rep_images)/${img}-profil-final$conf(extension,defaut)"
       # file delete -force "$audace(rep_images)/$fsmooth$conf(extension,defaut)"
       ::console::affiche_resultat "\n\nSpectre traité, corrigé et calibré sauvé sous ${img}-profil-final\n\n"
       file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
       if { "$flinearcal" != "${img}-profil-final" } {
	   file delete -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)"
       }
       if { "$fsmooth" != "${img}-profil-final" && $methsmo != "n" } {
	   file delete -force "$audace(rep_images)/$fsmooth$conf(extension,defaut)"
       }
       if { $methsmo == "n" } {
         file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
       }
       #if { "$fnorma" != "${img}-profil-final" } {
       #   file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
       #}
       # tk.message "Affichage du spectre traité, corrigé et calibré $fsmooth"
       #spc_loadfit $fsmooth
       #return $fsmooth

       #--- Traitement du résultat :
       spc_gdeleteall
       spc_loadfit "${img}-profil-final"
       loadima "$audace(rep_images)/${img}-spectre2D-traite"
       ::console::affiche_prompt "\n\n**** Spectre traité, corrigé et calibré sauvé sous ****\n${img}-profil-final\n\n"
       return "${img}-profil-final"
   } else {
       ::console::affiche_erreur "Usage: spc_traite2srinstrum nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc, n) uncosmic (o/n) méthode_détection_spectre (large, serre, moy) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) effacer_masters (o/n)  export_PNG (o/n) 2_lampes_calibration (o/n) ?fenêtre_binning {x1 y1 x2 y2}?\n\n"
   }
}
#**********************************************************************************#





###############################################################################
# Procédure de traitement de spectres 2D stellaire : calibration, prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création : 16-06-2007
# Date de mise à jour : 16-06-2007
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_lampe nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_réponse_instrumentale méthode_sélection_raies méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traitestellaire { args } {

   global audace spcaudace
   global conf


   if { [llength $args] == 24 } {
       set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set brut [ lindex $args 1 ]
       set noir [ file rootname [ lindex $args 2 ] ]
       set plu [ lindex $args 3 ]
       set noirplu [ file rootname [ lindex $args 4 ] ]
       set offset [ file rootname [ lindex $args 5 ] ]
       set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set methraie [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methinv [ lindex $args 9 ]
       set methnorma [ lindex $args 10 ]
       set cal_eau [ lindex $args 11 ]
       set export_png [ lindex $args 12 ]
       set export_bess [ lindex $args 13 ]
       #--- Paramètres prédéfinis :
       set methreg [ lindex $args 14 ]
       set methsel [ lindex $args 15 ]
       set methsky [ lindex $args 16 ]
       set methbin [ lindex $args 17 ]
       set methsmo [ lindex $args 18 ]
       set ejbad [ lindex $args 19 ]
       set ejtilt [ lindex $args 20 ]
       set rmfpretrait [ lindex $args 21 ]
       set flag_2lamps [ lindex $args 22 ]
       set flag_calibration [ lindex $args 23 ]


       #-- Rappel des options prédéfinies par l'interface graphique :
       #set methreg "spc"
       #set methsky "med"
       #set methbin "rober"
       #set methsmo "n"
       #set ejbad "n"
       #set ejtilt "n"
       #set rmfpretrait "o"

       #--- Debut du pipeline stellaire :
       ::console::affiche_prompt "\n\n**** PIPELINE DE TRAITEMENT DE SPECTRES STELLAIRES ****\n\n"


       #--- Profil et calibration du spectre de la lampe et calibration :
       if { $flag_calibration==1 } {
          set lampe_traitee "$lampe"
       } else {
          set lampe_traitee [ spc_lampe2calibre "$lampe" "$brut" "$noir" $methcos $methsel $methinv $methbin $methraie ]
       }

       #--- Recherche des masters dark, flat et darkflat :
       #-- Noirs :
       if { [ file exists "$audace(rep_images)/$noir$conf(extension,defaut)" ] } {
	   set noir_master "$noir"
       } elseif { [ catch { glob -dir $audace(rep_images) $noir*-smd\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noir_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $noir*-smd\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noir_master "$noir"
       }

       #-- Noirs_plu :
       if { [ file exists "$audace(rep_images)/$noirplu$conf(extension,defaut)" ] } {
	   set noirplu_master "$noirplu"
       } elseif { [ catch { glob -dir $audace(rep_images) $noirplu*-smd\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noirplu_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $noirplu*-smd\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noirplu_master "$noirplu"
       }


       #--- Application aux spectre de l'étoile :
       #-- Export PNG plus tard dans ce pipe, donc option "n" passee en argument.
       set spectre_traite [ spc_traite2srinstrum "$brut" "$noir_master" "$plu" "$noirplu_master" "$offset" "$lampe_traitee" "$rinstrum" $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $rmfpretrait "n" $flag_2lamps ]
       #- L'export au format PNG est ici réalisé en dehors de spc_traite2srinstrum


       #--- Calibration avec les raies telluriques :
       if { $cal_eau=="o" } {
	   buf$audace(bufNo) load "$audace(rep_images)/$spectre_traite"
	   set listemotsclef [ buf$audace(bufNo) getkwds ]
	   if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
                  ::console::affiche_prompt "\n\n**** Calibration avec les raies telluriques ****\n\n"
                  #if { $spcaudace(rm_edges)=="o" } 
                  #   set spectre_calo1 [ spc_calibretelluric "$spectre_traite" ]
                  #   set spectre_calo [ spc_rmedges "$spectre_calo1" ]
                  #   file delete -force "$audace(rep_images)/$spectre_calo1$conf(extension,defaut)"
                  set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
	       } else {
		   ::console::affiche_erreur "\n\n**** Calibration avec les raies telluriques non réalisée car dispersion insuffisante ****\n\n"
		   set spectre_calo "$spectre_traite"
	       }
	   } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
		   ::console::affiche_prompt "\n\n**** Calibration avec les raies telluriques ****\n\n"
                   #if { $spcaudace(rm_edges)=="o" } 
                   #   set spectre_calo1 [ spc_calibretelluric "$spectre_traite" ]
                   #   set spectre_calo [ spc_rmedges "$spectre_calo1" ]
                   #   file delete -force "$audace(rep_images)/$spectre_calo1$conf(extension,defaut)"
                      set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
	       } else {
		   ::console::affiche_erreur "\n\n**** Calibration avec les raies telluriques non réalisée car dispersion insuffisante ****\n\n"
		   set spectre_calo "$spectre_traite"
	       }
	   }
	   ## set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
       } else {
	   set spectre_calo "$spectre_traite"
       }


       #--- Export au format PNG :
       if { $export_png=="o" } {
	   set spectre_png [ spc_export2png "$spectre_calo" ]
       } else {
	   set spectre_png "$spectre_calo"
       }


       #--- Export au format Bess :
       if { $export_bess=="o" } {
          source [ file join $spcaudace(rep_spc) plugins bess_module bess_module.tcl ]
          set spectre_bess [ ::bess::Principal  "$spectre_calo" ]
          #-- Ouverture du site Internet BeSS :
          #spc_bess
       } else {
          set spectre_bess "$spectre_calo"
       }

      #--- Traitements des résultats :
      #-- file rename -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-final$conf(extension,defaut)"
      if { $cal_eau == "o" && $methnorma == "n" } {
         file rename -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-1c-calo$conf(extension,defaut)"
         set profil_final "${brut}-profil-1c-calo"
      } elseif { $cal_eau == "o" && $methnorma != "n" } {
         file rename -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-2b-calo$conf(extension,defaut)"
         set profil_final "${brut}-profil-2b-calo"
      } elseif { $cal_eau == "n" && $methnorma == "n" } {
         file rename -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-1c$conf(extension,defaut)"
         set profil_final "${brut}-profil-1c"
      } elseif { $cal_eau == "n" && $methnorma != "n" } {
         set profil_final "${brut}-profil-2b"
      }

       if { [ file exists "$audace(rep_images)/$spectre_traite$conf(extension,defaut)" ] } {
          file delete -force "$audace(rep_images)/$spectre_traite$conf(extension,defaut)"
       }
       if { $cal_eau=="o" } {
          ::console::affiche_prompt "\n\n**** Qualité de la calibration en longueur d'onde ****\n\n"
          spc_caloverif "$profil_final"
       }
       file delete -force "$audace(rep_images)/${brut}-profil-final$conf(extension,defaut)"

      #-- Renomage du fichier final :
      set datefile [ spc_datefile $profil_final ]
      file copy -force "$audace(rep_images)/$profil_final$conf(extension,defaut)" "$audace(rep_images)/_${brut}-${datefile}$conf(extension,defaut)"
      #file delete -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)"
      set profil_final_termine "_${brut}-${datefile}$conf(extension,defaut)"

      #-- Affichage du resultat :
      spc_load "$profil_final_termine"
      spc_pipeabstract "$profil_final_termine" "${brut}-profil-"
      return "$profil_final_termine"
   } else {
      ::console::affiche_erreur "Usage: spc_traitestellaire nom_lampe nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_réponse_instrumentale sélection_manuelle_raies uncosmic (o/n) mirrorx (o/n) normalisation (o/n) calibration_raies_telluriques (o/n) export_png (o/n) export_bess (o/n) méthode_appariement (reg, spc, n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none)méthode_binning (add, rober, horne) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) efface_pretraitement (o/n) 2_lampes_calibration (o/n) lampe_calibrée (1/0)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D non stellaires : calibration, prétraitement, correction géométriques, régistration, sadd, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création : 16-06-2007
# Date de mise à jour : 16-06-2007
# Méthode : utilise spc_pretrait pour le prétraitement
# Attention : usage d'une GUI pour le choix de la zone d'étude
# Arguments : nom_lampe nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_réponse_instrumentale méthode_sélection_raies méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traitenebula { args } {

   global audace spcaudace
   global conf
   global spc_windowcoords

#$lampe $brut $noir $plu $noirplu $offset $rinstrum $methraie $methcos $methinv $methnorma $export_png $methreg $methsky $methbin $methsmo $rmfpretrait

   if { [llength $args] == 19 } {
       set lampe [ file tail [ file rootname [ lindex $args 0 ] ] ]
       set brut [ lindex $args 1 ]
       set noir [ file rootname [ lindex $args 2 ] ]
       set plu [ lindex $args 3 ]
       set noirplu [ file rootname [ lindex $args 4 ] ]
       set offset [ file rootname [ lindex $args 5 ] ]
       set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
       set methraie [ lindex $args 7 ]
       set methcos [ lindex $args 8 ]
       set methinv [ lindex $args 9 ]
       set methnorma [ lindex $args 10 ]
       set export_png [ lindex $args 11 ]
       #--- Paramètres prédéfinis :
       set methreg [ lindex $args 12 ]
       set methsky [ lindex $args 13 ]
       set methbin [ lindex $args 14 ]
       set methsmo [ lindex $args 15 ]
       set rmfpretrait [ lindex $args 16 ]
       set flag_2lamps [ lindex $args 17 ]
       set flag_calibration [ lindex $args 18 ]
       set ejbad "n"
       set ejtilt "n"
       set methsel "serre"


       #-- Rappel des options prédéfinies par l'interface graphique :
       #set methreg "spc"
       #set methsky "med"
       #set methbin "rober"
       #set methsmo "n"
       #set rmfpretrait "o"
       set flag_geom_interne 0


       #--- Debut du pipeline nebulaire :
       ::console::affiche_prompt "\n\n**** PIPELINE DE TRAITEMENT DE SPECTRES NON STELLAIRES ****\n\n"

       #--- Recherche des masters dark, flat et darkflat :
       #-- Noirs :
       if { [ file exists "$audace(rep_images)/$noir$conf(extension,defaut)" ] } {
	   set noir_master "$noir"
       } elseif { [ catch { glob -dir $audace(rep_images) ${noir}\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noir_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${noir}\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]$conf(extension,defaut) ${noir}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noir_master "$noir"
       }

       #-- Noirs_plu :
       if { [ file exists "$audace(rep_images)/$noirplu$conf(extension,defaut)" ] } {
	   set noirplu_master "$noirplu"
       } elseif { [ catch { glob -dir $audace(rep_images) ${noirplu}\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noirplu_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${noirplu}\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]$conf(extension,defaut) ${noirplu}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noirplu_master "$noirplu"
       }


       #--- Sélection de la zone d'intérêt du spectre :
       renumerote "$brut"
       set fsmea [ bm_smean "$brut" ]
       buf$audace(bufNo) load "$audace(rep_images)/$fsmea"
       buf$audace(bufNo) sub "$audace(rep_images)/$noir_master" 0
       set spc_nebnaxis2 [ lindex [ buf$audace(bufNo) getkwd "NAXIS2" ] 1 ]
       buf$audace(bufNo) save "$audace(rep_images)/${fsmea}-t"

      #-- Tilt du spectre pour une selection de zone optimale si le spectre donné comme lampe contient SPC_TILT :
      if { $flag_calibration==1 } {
         buf$audace(bufNo) load "$audace(rep_images)/$lampe"
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 } {
            set spc_ycenter [ expr round(0.5*$spc_nebnaxis2) ]
            set spc_xcenter 1
            buf$audace(bufNo) load "$audace(rep_images)/$lampe"
            set spc_angletilt [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
            set fsmea_tilt [ spc_tilt2 "${fsmea}-t" $spc_angletilt $spc_xcenter $spc_ycenter ]
            set flag_geom_interne 1
         }
      }

       set err [ catch {
          if { $flag_geom_interne==1 } {
             ::param_spc_audace_selectzone::run "$fsmea_tilt"
          } else {
             ::param_spc_audace_selectzone::run "${fsmea}-t"
          }
          tkwait window .param_spc_audace_selectzone
       } msg ]
       if {$err==1} {
	   ::console::affiche_erreur "$msg\n"
       }
       file delete "$audace(rep_images)/$fsmea$conf(extension,defaut)"
       file delete "$audace(rep_images)/${fsmea}-t$conf(extension,defaut)"
       if { $flag_geom_interne==1 } {
          file delete "$audace(rep_images)/$fsmea_tilt$conf(extension,defaut)"
       }


       #--- Profil du spectre de la lampe et calibration :
       if { $flag_calibration==1 } {
          buf$audace(bufNo) load "$audace(rep_images)/$lampe"
          set listemotsclef [ buf$audace(bufNo) getkwds ]
          if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 } {
             set spc_xcenter 1
             # set spc_xcenter [ expr round(0.5*([ lindex $spc_windowcoords 2 ]+[ lindex $spc_windowcoords 2 ])) ]
             set spc_y1 [ lindex $spc_windowcoords 1 ]
             set spc_y2 [ lindex $spc_windowcoords 3 ]
             set spc_ycenter [ expr round(0.5*($spc_y2+$spc_y1)) ]
             buf$audace(bufNo) setkwd [ list "SPC_TILX" $spc_xcenter int "Tilt X center" "" ]
             buf$audace(bufNo) setkwd [ list "SPC_TILY" $spc_ycenter int "Tilt Y center" "" ]
             buf$audace(bufNo) save "$audace(rep_images)/$lampe"
             set lampe_traitee "$lampe"
          } else {
             set lampe_traitee "$lampe"
          }
       } else {
	   set lampe_traitee [ spc_lampe2calibre "$lampe" "$brut" "$noir" $methcos $methsel $methinv $methbin $methraie $spc_windowcoords ]
       }

       #--- Application aux spectres de l'objet :
       #-- L'export au format PNG est ici réalisé en dehors de spc_traite2srinstrum : donc "n".
       #-- Le flat est binné sur la hauteur définie puis élargie en une image 2D.
       #-- Pas de gestion de deux spectres de lampes de calibration : donc "n".
       set flag_binned_dflt $spcaudace(binned_flat)
       set spcaudace(binned_flat) "o"
       set spectre_traite [ spc_traite2srinstrum "$brut" "$noir_master" "$plu" "$noirplu_master" "$offset" "$lampe_traitee" "$rinstrum" $methreg $methcos $methsel $methsky $methinv $methbin $methnorma $methsmo $ejbad $ejtilt $rmfpretrait "n" $flag_2lamps $spc_windowcoords ]
       set spcaudace(binned_flat) $flag_binned_dflt

       #--- Export au format PNG :
       if { $export_png=="o" } {
	   set spectre_png [ spc_export2png "$spectre_traite" ]
       } else {
	   set spectre_png "$spectre_traite"
       }


       #--- Résultat des traitements :
       # file copy -force "$audace(rep_images)/$spectre_traite$conf(extension,defaut)" "$audace(rep_images)/${brut}-profil-traite-final$conf(extension,defaut)"
       # file delete -force "$audace(rep_images)/$spectre_traite$conf(extension,defaut)"
       spc_load "${brut}-profil-final"
       spc_pipeabstract "${brut}-profil-final" "${brut}-profil-"
       return "${brut}-profil-final"
   } else {
       ::console::affiche_erreur "Usage: spc_traitenebula nom_lampe nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_réponse_instrumentale sélection_manuelle_raies uncosmic (o/n) mirrorx (o/n) normalisation (o/n) calibration_raies_telluriques (o/n) export_png (o/n) export_bess (o/n) méthode_appariement (reg, spc, n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none)méthode_binning (add, rober, horne) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) efface_pretraitements (o/n) 2_lampes_calibration (o/n) lampe_calibrée (1/0)\n\n"
   }
}
#**********************************************************************************#




###############################################################################
# Procédure de traitement de spectres 2D pour des series (1 spectre=1 profil) : prétraitement, correction géométriques, régistration, spc_profil, calibration en longeur d'onde, correction réponse instrumentale, normalisation.
# Auteur : Benjamin MAUCLAIRE
# Date création :  28-08-2006
# Date de mise à jour : 16-09-2012
# Méthode : utilise spc_pretrait pour le prétraitement
# Arguments : nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) efface_pretraitement (o/n) export_png (o/n)
###############################################################################

proc spc_traiteseries { args } {

   global audace spcaudace
   global conf

   set nbargs [ llength $args ]
   if { $nbargs<=22 } {
       if { $nbargs == 21 } {
          set brut [ lindex $args 0 ]
          set noir [ file rootname [ lindex $args 1 ] ]
          set flat [ lindex $args 2 ]
          set noirplu [ file rootname [ lindex $args 3 ] ]
          set offset [ file rootname [ lindex $args 4 ] ]
          set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
          set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
          set methreg [ lindex $args 7 ]
          set methcos [ lindex $args 8 ]
          set methsel [ lindex $args 9 ]
          set methsky [ lindex $args 10 ]
          set methinv [ lindex $args 11 ]
          set methbin [ lindex $args 12 ]
          set methnorma [ lindex $args 13 ]
          set methsmo [ lindex $args 14 ]
          set methejbad [ lindex $args 15 ]
          set methejtilt [ lindex $args 16 ]
          set rmfpretrait [ lindex $args 17 ]
          set export_png [ lindex $args 18 ]
          set flag_2lamps [ lindex $args 19 ]
          set cal_eau [ lindex $args 20 ]
          set flag_nonstellaire 0
       } elseif { $nbargs==22 } {
          set brut [ lindex $args 0 ]
          set noir [ lindex $args 1 ]
          set flat [ lindex $args 2 ]
          set noirplu [ lindex $args 3 ]
          set offset [ lindex $args 4 ]
          set lampe [ file tail [ file rootname [ lindex $args 5 ] ] ]
          set rinstrum [ file tail [ file rootname [ lindex $args 6 ] ] ]
          set methreg [ lindex $args 7 ]
          set methcos [ lindex $args 8 ]
          set methsel [ lindex $args 9 ]
          set methsky [ lindex $args 10 ]
          set methinv [ lindex $args 11 ]
          set methbin [ lindex $args 12 ]
          set methnorma [ lindex $args 13 ]
          set methsmo [ lindex $args 14 ]
          set methejbad [ lindex $args 15 ]
          set methejtilt [ lindex $args 16 ]
          set rmfpretrait [ lindex $args 17 ]
          set export_png [ lindex $args 18 ]
          set flag_2lamps [ lindex $args 19 ]
          set cal_eau [ lindex $args 20 ]
          set windowcoords [ lindex $args 21 ]
          set flag_nonstellaire 1
       } else {
          ::console::affiche_erreur "Usage: spc_traiteseries nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc, n) uncosmic (o/n) méthode_détection_spectre (large, serre) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) effacer_masters (o/n) export_PNG (o/n) 2 spectres de calibration (o/n) cal_eau (o/n) ?fenêtre_binning {x1 y1 x2 y2}?\n\n"
	   return ""
       }

       #-- Rappel des options prédéfinies par l'interface graphique :
       #set methreg "spc"
       #set methsky "med"
       #set methbin "rober"
       #set methsmo "n"
       #set ejbad "n"
       #set ejtilt "n"
       #set rmfpretrait "o"

       #-- Pas de rmedges car les cosmics sont genants sur les poses unitaires :
       set spcaudace(rm_edges) "n"
       #-- Pas de calibration tellurique par defaut (cf dans spc_var) :
       # set spcaudace(caloserie) "n"

       #--- Debut du pipeline stellaire :
       ::console::affiche_prompt "\n\n**** PIPELINE DE TRAITEMENT DE SÉRIE DE SPECTRES ****\n\n"


       #--- Profil et calibration du spectre de la lampe et calibration :
       #if { $flag_calibration==1 } {
       #   set lampe_traitee "$lampe"
       #} else {
          set lampe_traitee [ spc_lampe2calibre "$lampe" "$brut" "$noir" $methcos $methsel $methinv $methbin $methreg ]
       #}

       #--- Recherche des masters dark, flat et darkflat :
       #-- Noirs :
       if { [ file exists "$audace(rep_images)/$noir$conf(extension,defaut)" ] } {
	   set noir_master "$noir"
       } elseif { [ catch { glob -dir $audace(rep_images) $noir*-smd\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noir_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $noir*-smd\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noir*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noir_master "$noir"
       }

       #-- Noirs_plu :
       if { [ file exists "$audace(rep_images)/$noirplu$conf(extension,defaut)" ] } {
	   set noirplu_master "$noirplu"
       } elseif { [ catch { glob -dir $audace(rep_images) $noirplu*-smd\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) } ]==0 } {
	   set noirplu_master [ lindex [ lsort -dictionary [ glob -dir $audace(rep_images) -tails $noirplu*-smd\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]$conf(extension,defaut) $noirplu*-smd\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ] 0 ]
       } else {
	   set noirplu_master "$noirplu"
       }


       #--- Elimination des mauvaises images :
       if { $methejbad == "o" } {
	   ::console::affiche_prompt "\n**** Éliminations des mauvaises images ****\n\n"
	   spc_reject $brut
       }
       if { [ file exists "$audace(rep_images)/$brut$conf(extension,defaut)" ] } {
          set nbimg 1
          set nbimg_ini 1
       } else {
          set nbimg [ llength [ glob -dir $audace(rep_images) ${brut}\[0-9\]$conf(extension,defaut) ${brut}\[0-9\]\[0-9\]$conf(extension,defaut) ${brut}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
          set nbimg_ini $nbimg
       }


      #--- Detection du tilt sur les bruts :
      if { $flag_nonstellaire==0 } {
          spc_findgeomimgs "$brut"
      }

       #--- Prétraitement de $nbimg images :
       ::console::affiche_prompt "\n\n**** Prétraitement de $nbimg images ****\n\n"
       if { $flag_nonstellaire==1 } {
	   set fpretrait [ spc_pretrait "$brut" "$noir_master" "$flat" "$noirplu_master" "$offset" $rmfpretrait $windowcoords ]
       } else {
	   set fpretrait [ spc_pretrait "$brut" "$noir_master" "$flat" "$noirplu_master" "$offset" $rmfpretrait ]
       }


       #--- Correction du l'inclinaison (tilt) :
       buf$audace(bufNo) load "$audace(rep_images)/$lampe_traitee"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       #-- Memorise le nom initial du spectre de la lampe de calibration :
       if { [ lsearch $listemotsclef "SPC_LNM" ]!=-1 } {
          set lampe_name [ lindex [ buf$audace(bufNo) getkwd "SPC_LNM" ] 1 ]
       } else {
          set lampe_name "$lampe_traitee"
          set flag_2lamps "n"
       }

       #-- Effectue la correction de tilt :
       if { $flag_nonstellaire==1 } {
          #-- Temporaire : si le spectre de lampe donné est deja corrige geometriquement, utilise ses parametres :
          ::console::affiche_prompt "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
          buf$audace(bufNo) load "$audace(rep_images)/$lampe_traitee"
          set listemotsclef [ buf$audace(bufNo) getkwds ]
          if { [ lsearch $listemotsclef "SPC_TILT" ]!=-1 && [ lsearch $listemotsclef "SPC_TILX" ]!=-1 } {
             set spc_angletilt [ lindex [ buf$audace(bufNo) getkwd "SPC_TILT" ] 1 ]
             set spc_tiltx [ lindex [ buf$audace(bufNo) getkwd "SPC_TILX" ] 1 ]
             set spc_tilty [ lindex [ buf$audace(bufNo) getkwd "SPC_TILY" ] 1 ]
             set ftilt [ spc_tilt2imgs $fpretrait $spc_angletilt $spc_tiltx $spc_tilty ]
          } else {
             #-- Pas de correction de l'inclinaison pour les spectres non stellaires :
             ::console::affiche_erreur "\n\nPAS DE CORRECTION DE L'INCLINAISON POUR LES SPECTRES NON STELLAIRES\n\n"
             set ftilt "$fpretrait"
          }
       } else {
          ::console::affiche_prompt "\n\n**** Correction du l'inclinaison (tilt) ****\n\n"
          if { $methejtilt == "o" } {
             set ftilt [ spc_tiltautoimgs $fpretrait o ]
          } else {
             set ftilt [ spc_tiltautoimgs $fpretrait n ]
          }
       }

       #--- Corrections géométriques des raies (smile selon l'axe x ou slant) :
       ::console::affiche_prompt "\n\n**** Corrections géométriques du spectre 2D ****\n\n"
       buf$audace(bufNo) load "$audace(rep_images)/$lampe_traitee"
       set listemotsclef [ buf$audace(bufNo) getkwds ]
       if { [ lsearch $listemotsclef "SPC_SLX1" ] !=-1 } {
	   set spc_ycenter [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX1" ] 1 ]
	   set spc_cdeg2 [ lindex [ buf$audace(bufNo) getkwd "SPC_SLX2" ] 1 ]
	   ::console::affiche_prompt "\n*** Correction de la courbure des raies (smile selon l'axe x)... ***\n\n"
	   set fgeom [ spc_smileximgs $ftilt $spc_ycenter $spc_cdeg2 ]
       } elseif { [ lsearch $listemotsclef "SPC_SLA" ] !=-1 } {
	   set pente [ lindex [ buf$audace(bufNo) getkwd "SPC_SLA" ] 1 ]
	   ::console::affiche_prompt "\n** Correction de l'inclinaison des raies (slant)... **\n"
	   set fgeom [ spc_slant2imgs $ftilt $pente ]
       } else {
	   ::console::affiche_resultat "\n** Aucune correction géométrique nécessaire. **\n"
	   set fgeom "$ftilt"
       }



       #if { $rmfpretrait=="o" && [ file exists $audace(rep_images)/${fgeom}-1$conf(extension,defaut) ] }
       #--- Appariement horizontal :
       if { $flag_2lamps == "o" } {
          set result_grep [ regexp {(.+\-?)[0-9]+} "$lampe_name" match prefixe_lampe ]
          if { $result_grep==0 } {
             set fhreg "$fgeom"
          } elseif { [ file exists "$audace(rep_images)/${prefixe_lampe}2$conf(extension,defaut)" ]==1 } {
             ::console::affiche_prompt "\n\n******* Appariement horizontal de $nbimg images *******\n\n"
             set fhreg [ spc_registerh "$lampe_traitee" "$fgeom" ]
          } else {
             set fhreg "$fgeom"
          }
       } else {
          set fhreg "$fgeom"
       }

       #--- Effacement des images prétraitées :
       set nbimg [ llength [ glob -dir $audace(rep_images) ${ftilt}\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]$conf(extension,defaut) ${ftilt}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
       if { $rmfpretrait=="o" } {
	   delete2 $fpretrait $nbimg
       }

      #=========================================================================================#
      #---- Pour chaque spectre unitaire, extraction du profil de raies de chaque spectre :
      set listefichiers [ lsort -dictionary [ glob -dir $audace(rep_images) -tails ${fhreg}\[0-9\]$conf(extension,defaut) ${fhreg}\[0-9\]\[0-9\]$conf(extension,defaut) ${fhreg}\[0-9\]\[0-9\]\[0-9\]$conf(extension,defaut) ] ]
      set nbspectres [ llength $listefichiers ]
      set num_spectre 1

      foreach spectre $listefichiers {
         ::console::affiche_prompt "\n---------- RÉDUCTION DU SPECTRE n°$num_spectre/$nbspectres -------\n"
         set spectre [ file rootname $spectre ]
         #--- Inversion gauche-droite du spectre 2D (mirrorx) :
         if { $methinv == "o" } {
            set fflip [ spc_flip $spectre ]
            file delete -force "$audace(rep_images)/$spectre$conf(extension,defaut)"
         } else {
            set fflip "$spectre"
         }

         #--- Soustraction du fond de ciel et binning :
         ::console::affiche_prompt "\n\n**** Extraction du profil de raies ****\n\n"
         if { $flag_nonstellaire==1 } {
            set fprofil [ spc_profilzone $fflip $windowcoords $methsky $methbin ]
         } else {
            set fprofil [ spc_profil $fflip $methsky $methsel $methbin ]
         }
         # file delete -force "$audace(rep_images)/$fflip$conf(extension,defaut)"
         file rename -force "$audace(rep_images)/$fflip$conf(extension,defaut)" "$audace(rep_images)/${brut}-spectre2D-traite-${num_spectre}$conf(extension,defaut)"

         #--- Calibration en longueur d'onde du spectre de l'objet (niveau 1b) :
         ::console::affiche_prompt "\n\n**** Calibration en longueur d'onde du spectre de l'objet $spectre ****\n\n"
         #- Pour les spectre d'objets non-stellaire, la calibration est faite a partir de la zone decoupée de lampe.
         set fcal [ spc_calibreloifile "$lampe_traitee" "$fprofil" ]
         # file copy -force "$audace(rep_images)/$fprofil$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-1a$conf(extension,defaut)"
         file delete -force "$audace(rep_images)/$fprofil$conf(extension,defaut)"
         # file copy -force "$audace(rep_images)/$fcal$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-1b$conf(extension,defaut)"

         #--- Correction de la réponse intrumentale :
         buf$audace(bufNo) load "$audace(rep_images)/$fcal"
         #-- Ajoute le mot clef EXPTIME (pour BeSS) s'il n'existe pas :
         set listemotsclef [ buf$audace(bufNo) getkwds ]
         if { [ lsearch $listemotsclef "EXPOSURE" ]!=-1 && [ lsearch $listemotsclef "EXPTIME" ]==-1 } {
            set exptime [ lindex [ buf$audace(bufNo) getkwd "EXPOSURE" ] 1 ]
            buf$audace(bufNo) setkwd [ list "EXPTIME" "$exptime" float "Total observation duration" "s" ]
            buf$audace(bufNo) bitpix float
            buf$audace(bufNo) save1d "$audace(rep_images)/$fcal"
            buf$audace(bufNo) bitpix short
         }

         #-- Calcule la largeur spectral :
         set naxis1 [  lindex [ buf$audace(bufNo) getkwd "NAXIS1" ] 1 ]
         set cdelt1 [  lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
         set largeur_spectrale [ expr $cdelt1*$naxis1 ]
         if { $largeur_spectrale >= $spcaudace(bande_br) } {
            set spcaudace(rm_edges) "n"
         }
         if { $rinstrum=="none" } {
            set fricorr "$fcal"
            #-- Linearisation de la calibration a partir du niveau 1b_lin :
            set fricorrlin1 [ spc_linearcal "$fricorr" ]             
            #-- Elimination des bords "nuls" :
            if { $spcaudace(rm_edges)=="o" } {
               set fricorrlin [ spc_rmedges "$fricorrlin1" ]
               file delete -force "$audace(rep_images)/$fricorrlin1$conf(extension,defaut)"
            } else {
               set fricorrlin "$fricorrlin1"
            }
            #file copy -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-1b$conf(extension,defaut)"
            #file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-1b_nonlin$conf(extension,defaut)"
            file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
            file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
         } else {
            ::console::affiche_prompt "\n\n**** Correction de la réponse intrumentale ****\n\n"
            if { $largeur_spectrale >= $spcaudace(bande_br) } {
               set imaxtol $spcaudace(imax_tolerence)
               set spcaudace(imax_tolerence) 1.10
            }
            #-- Messge d'erreur en cas d'une sélection de plage de longueur d'onde :
            if { $flag_nonstellaire==1 } {
	       set xdeb [ lindex $windowcoords 0 ]
	       set xfin [ lindex $windowcoords 2 ]
	       if { $xdeb>1 || $xfin<$naxis1 } {
                  ::console::affiche_erreur "\nPAS DE CORRECTION DE LA RÉPONSE INSTRUMENTALE LORS D'UNE SÉLECTION DE LARGEUR SPÉCIFIQUE DU SPECTRE.\n"
                  set fricorr "$fcal"
	       } else {
                  set fricorr [ spc_divri "$fcal" "$rinstrum" ]
                  file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
	       }
            } else {
               if { $largeur_spectrale >= $spcaudace(bande_br) } {
                  # set fricorr [ spc_divbrut "$fcal" "$rinstrum" ]
                  set fricorr [ spc_divri "$fcal" "$rinstrum" ]
               } else {
                  set fricorr [ spc_divri "$fcal" "$rinstrum" ]
               }
               file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
            }
            if { $largeur_spectrale >= $spcaudace(bande_br) } {
               set spcaudace(imax_tolerence) $imaxtol
            }

            #-- Division du profil par la RI :
            ## set rinstrum_ech [ spc_echant $rinstrum $fcal ]
            ## set fricorr [ spc_div $fcal $rinstrum_ech ]
            #- Beaucoup de mise a 0 si methode avec reechant avant. Methode courante est calibreloifile :
            # set fricorr [ spc_divri $fcal $rinstrum ]
            #- 040107 :
            ## set fricorr [ spc_div $fcal $rinstrum ]

            #-- Message d'erreur en cas d'échec de la division et linéarisation de la calibration :
            if { $fricorr == 0 } {
	       ::console::affiche_erreur "\nLa division par la réponse intrumentale n'a pas pu peut être calculée.\n"
	       return 0
            } else {
               #-- Linearisation de la calibration a partir du niveau 1c :
               set fricorrlin1 [ spc_linearcal "$fricorr" ]    
               #-- Elimination des bords "nuls" :
               if { $spcaudace(rm_edges)=="o" } {
                  set fricorrlin [ spc_rmedges "$fricorrlin1" ]
                  file delete -force "$audace(rep_images)/$fricorrlin1$conf(extension,defaut)"
               } else {
                  set fricorrlin "$fricorrlin1"
               }
               #file copy -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-1c$conf(extension,defaut)"
               #file copy -force "$audace(rep_images)/$fricorr$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-1c_nonlin$conf(extension,defaut)"
               file delete -force "$audace(rep_images)/$fricorr$conf(extension,defaut)"
               file delete -force "$audace(rep_images)/$fcal$conf(extension,defaut)"
            }
         }


         #--- Normalisation du profil de raies :
         if { $methnorma == "e" } {
            ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
            set fnorma [ spc_autonormaraie "$fricorrlin" e ]
            file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
            # file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-2b$conf(extension,defaut)"
            # file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
            # set fnorma "${brut}-${num_spectre}-profil-2b"
         } elseif { $methnorma == "a" } {
            ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
            set fnorma [ spc_autonormaraie "$fricorrlin" a ]
            file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
            # file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-2b$conf(extension,defaut)"
            # file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
            # set fnorma "${brut}-${num_spectre}-profil-2b"
         } elseif { $methnorma == "r" } {
            ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
            set fnorma [ spc_rescalecont "$fricorrlin" ]
            file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
            # file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-2b$conf(extension,defaut)"
            # file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
            # set fnorma "${brut}-${num_spectre}-profil-2b"
         } elseif { $methnorma == "o" } {
            ::console::affiche_prompt "\n\n**** Normalisation du profil de raies ****\n\n"
            set fnorma [ spc_autonorma "$fricorrlin" ]
            file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
            # file copy -force "$audace(rep_images)/$fnorma$conf(extension,defaut)" "$audace(rep_images)/${brut}-${num_spectre}-profil-2b$conf(extension,defaut)"
            # file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
            # set fnorma "${brut}-${num_spectre}-profil-2b"
         } elseif { $methsmo == "n" } {
            set fnorma "$fricorrlin"
         }

         #--- Doucissage du profil de raies :
         if { $methsmo == "o" } {
            ::console::affiche_prompt "\n\n**** Adoucissement du profil de raies ****\n\n"
            set fsmooth [ spc_smooth "$fnorma" ]
            if { $methnorma != "n" } {
               file delete -force "$audace(rep_images)/$fnorma$conf(extension,defaut)"
               file delete -force "$audace(rep_images)/$fricorrlin$conf(extension,defaut)"
            }
         } elseif { $methsmo == "n" } {
            set fsmooth "$fnorma"
         }

         #--- Linéarisation de la calibration en longueur d'onde :
         if { $spcaudace(linear_cal)=="o" } {
            set flinearcal [ spc_linearcal "$fsmooth" ]
            file delete -force "$audace(rep_images)/$fsmooth$conf(extension,defaut)"
         } else {
            set flinearcal "$fsmooth"
         }

         #--- Calibration avec les raies telluriques :
         if { $cal_eau=="o" && $spcaudace(calo_serie)=="o" } {
            buf$audace(bufNo) load "$audace(rep_images)/$flinearcal"
            set listemotsclef [ buf$audace(bufNo) getkwds ]
            if { [ lsearch $listemotsclef "SPC_B" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "SPC_B" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
                  ::console::affiche_prompt "\n\n**** Calibration avec les raies telluriques ****\n\n"
                  #if { $spcaudace(rm_edges)=="o" } 
                  #   set spectre_calo1 [ spc_calibretelluric "$spectre_traite" ]
                  #   set spectre_calo [ spc_rmedges "$spectre_calo1" ]
                  #   file delete -force "$audace(rep_images)/$spectre_calo1$conf(extension,defaut)"
                  set spectre_calo [ spc_calibretelluric "$flinearcal" ]
                  file delete -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)"
	       } else {
                  ::console::affiche_erreur "\n\n**** Calibration avec les raies telluriques non réalisée car dispersion insuffisante ****\n\n"
                  set spectre_calo "$flinearcal"
	       }
            } elseif { [ lsearch $listemotsclef "CDELT1" ] !=-1 } {
	       set dispersion [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ]
	       if { $dispersion <= $spcaudace(dmax) } {
                  ::console::affiche_prompt "\n\n**** Calibration avec les raies telluriques ****\n\n"
                  #if { $spcaudace(rm_edges)=="o" } 
                  #   set spectre_calo1 [ spc_calibretelluric "$spectre_traite" ]
                  #   set spectre_calo [ spc_rmedges "$spectre_calo1" ]
                  #   file delete -force "$audace(rep_images)/$spectre_calo1$conf(extension,defaut)"
                  set spectre_calo [ spc_calibretelluric "$flinearcal" ]
                  file delete -force "$audace(rep_images)/$flinearcal$conf(extension,defaut)"
	       } else {
                  ::console::affiche_erreur "\n\n**** Calibration avec les raies telluriques non réalisée car dispersion insuffisante ****\n\n"
                  set spectre_calo "$flinearcal"
	       }
            }
            ## set spectre_calo [ spc_calibretelluric "$spectre_traite" ]
         } else {
            set spectre_calo "$flinearcal"
         }

         #--- Sauve le profil en 1D :
         buf$audace(bufNo) load "$audace(rep_images)/$spectre_calo"
         buf$audace(bufNo) bitpix float
         buf$audace(bufNo) setkwd [ list "SPC_NBF" 1 int "Number of single shots" "" ]
         buf$audace(bufNo) save1d "$audace(rep_images)/$spectre_calo"
         buf$audace(bufNo) bitpix short


         if { 1==0 } {
            #--- Retrait des cosmics
            if { $methcos == "o" } {
               buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
               uncosmic $spcaudace(uncosmic)
               #uncosmic $spcaudace(uncosmic)
               buf$audace(bufNo) setkwd [ list SPC_COSM "removed, weighted median filter" string "Method used for erasing cosmics" "" ]
               buf$audace(bufNo) bitpix ulong
               buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
               buf$audace(bufNo) bitpix short
            } else {
               buf$audace(bufNo) load "$audace(rep_images)/$fsadd"
               buf$audace(bufNo) setkwd [ list SPC_COSM "none" string "Method used for erasing cosmics" "" ]
               buf$audace(bufNo) bitpix ulong
               buf$audace(bufNo) save "$audace(rep_images)/$fsadd"
               buf$audace(bufNo) bitpix short
            }
         }

         #--- Export en PNG :
         #if { $export_png=="o" } {
         #   set fichier_png [ spc_export2png "$flinearcal" ]
         #}

         #--- Renomage du fichier final :
         set datefile [ spc_datefile $spectre_calo ]
         file copy -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)" "$audace(rep_images)/_${brut}-${datefile}$conf(extension,defaut)"
         file delete -force "$audace(rep_images)/$spectre_calo$conf(extension,defaut)"

         #--- Increment du numero de spectre de la serie :
         incr num_spectre
      }
      #======================== Fin du traitement time serie ======================================#
      

      #--- Effacement des images prétraitées :
      set spcaudace(rm_edges) "o"
      delete2 "$fpretrait" $nbspectres
      delete2 "$ftilt" $nbspectres
      delete2 "$fgeom" $nbspectres

      #--- Affichage des resultats :
      spc_loadfit "_${brut}-${datefile}$conf(extension,defaut)"
      #::console::affiche_prompt "\n\n**** Spectres traités, corrigés et calibrés sauvés sous ****\n_${brut}-DATE$conf(extension,defaut)\n\n"
      # spc_pipeabstract "_${brut}-DATE$conf(extension,defaut)" "_${brut}-${datefile}"
      spc_pipeabstract "_${brut}-${datefile}" "_${brut}-DATE$conf(extension,defaut)"
      return "_${brut}-DATE$conf(extension,defaut)"
   } else {
      ::console::affiche_erreur "Usage: spc_traiteseries nom_générique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_offset spectre_2D_lampe spectre_réponse_instrumentale méthode_appariement (reg, spc, n) uncosmic (o/n) méthode_détection_spectre (large, serre, moy) méthode_sub_sky (moy, moy2, med, inf, sup, back, none) mirrorx (o/n) méthode_binning (add, rober, horne) normalisation (o/n) adoucissement (o/n) rejet_mauvais_spectres (o/n) rejet_rotation_importante (o/n) effacer_masters (o/n)  export_PNG (o/n) 2_lampes_calibration (o/n) cal_eau (o/n) ?fenêtre_binning {x1 y1 x2 y2}?\n\n"
   }
}
#**********************************************************************************#


###############################################################################
# Procédure d'affichage d'une synthèse des traitements
# Auteur : Benjamin MAUCLAIRE
# Date création :  29-12-2015
# Date de mise à jour : 29-12-2015
# Méthode : utilise les mots clef
# Arguments : 
###############################################################################

proc spc_pipeabstract { args } {

   global conf audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs<=2 } {
      set nom_profil_final [ lindex $args 0 ]
      set nom_generic_profils [ lindex $args 1 ]
   } else {
      ::console::affiche_erreur "Usage: spc_pipeabstract nom_profil_final nom_generic_profils\n"
      return ""
   }

   #--- Lecture des mots clef importants : CRAVL1, CDELT1, SPC_RMS, SPC_RMSO, SPC_RESP, SPC_RESL
   if { [ file exists "$audace(rep_images)/$nom_profil_final$conf(extension,defaut)" ]==1 } {
      buf$audace(bufNo) load "$audace(rep_images)/$nom_profil_final"
   } elseif { [ file exists "$audace(rep_images)/${nom_generic_profils}2b-calo$conf(extension,defaut)" ]==1 } {
      buf$audace(bufNo) load "$audace(rep_images)/${nom_generic_profils}2b-calo"
   } elseif { [ file exists "$audace(rep_images)/${nom_generic_profils}1c$conf(extension,defaut)" ]==1 } {
      buf$audace(bufNo) load "$audace(rep_images)/${nom_generic_profils}1c"
   } else {
      ::console::affiche_erreur "Aucun des fichiers finaux donnés n'est présent.\n"
      return ""
   }
   set listemotsclef [ buf$audace(bufNo) getkwds ]
   set crval1 [ format "%4.4f" [ lindex [ buf$audace(bufNo) getkwd "CRVAL1" ] 1 ] ]
   set cdelt1 [ format "%2.4f" [ lindex [ buf$audace(bufNo) getkwd "CDELT1" ] 1 ] ]
   if { [ lsearch $listemotsclef "CRPIX1" ] !=-1 } {
      set crpix1 [ lindex [ buf$audace(bufNo) getkwd "CRPIX1" ] 1 ]
   } else {
      set crpix1
   }
   if { [ lsearch $listemotsclef "SPC_RMS" ] !=-1 } {
      set rms [ lindex [ buf$audace(bufNo) getkwd "SPC_RMS" ] 1 ]
      if { $rms<1e-5 } {
         set rms [ format "%1.3e" $rms ]
      } else {
         set rms [ format "%1.6f" $rms ]
      }
   } else {
      set rms 0.
   }
   set rmsaccur [ format "%2.0f" [ expr 100.*(1-$rms/$cdelt1) ] ]
   
   if { [ lsearch $listemotsclef "SPC_RMSO" ] !=-1 } {
      set rmso [ format "%1.6f" [ lindex [ buf$audace(bufNo) getkwd "SPC_RMSO" ] 1 ] ]
      set rmsoaccur [ format "%2.0f" [ expr 100.*(1-$rmso/$cdelt1) ] ]
   } else {
      set rmso 0.
   }
   if { [ lsearch $listemotsclef "SPC_MDEC" ] !=-1 } {
      set mdec [ format "%1.6f" [ lindex [ buf$audace(bufNo) getkwd "SPC_MDEC" ] 1 ] ]
   } else {
      set mdec 0.
   }
   if { [ lsearch $listemotsclef "SPC_RESP" ] !=-1 } {
      set resolution [ lindex [ buf$audace(bufNo) getkwd "SPC_RESP" ] 1 ]
   } else {
      set resolution 0.
   }
   if { [ lsearch $listemotsclef "SPC_RESL" ] !=-1 } {
      set resolution_l [ format "%4.3f" [ lindex [ buf$audace(bufNo) getkwd "SPC_RESL" ] 1 ] ]
   } else {
      set resolution_l 0.
   }

   #--- Affichage final du pipeline :
   # ::console::affiche_prompt "\n\n     ****** FIN DU TRAITEMENT ******\n"
   ::console::affiche_prompt "\n\n=============== FIN DU TRAITEMENT ===============\n"
   ::console::affiche_prompt "\n**** Spectre final traité, corrigé et calibré sauvé sous : ****\n"
   ::console::affiche_prompt "Profil final *: $nom_profil_final\n"

   #-- Fichiers intermédaires :
   ::console::affiche_prompt "\n*** Fichiers intermédaires sauvés : ***\n"
   if { [ file exists "$audace(rep_images)/${nom_generic_profils}1a$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Profil non calibré *: ${nom_generic_profils}1a$conf(extension,defaut)\n"
   }
   if { [ file exists "$audace(rep_images)/${nom_generic_profils}1b$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Profil calibré *: ${nom_generic_profils}1b$conf(extension,defaut) \n"
   }
   if { [ file exists "$audace(rep_images)/${nom_generic_profils}1c$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Profil calibré et corrigé de la RI *: ${nom_generic_profils}1c$conf(extension,defaut) \n"
   }
   #- Les 2b, pas toujours presents :
   if { [ file exists "$audace(rep_images)/${nom_generic_profils}2b$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Profil 1c normalisé/mis à l'échelle *: ${nom_generic_profils}2b$conf(extension,defaut) \n"
   }
   if { [ file exists "$audace(rep_images)/${nom_generic_profils}2b-calo$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Profil 2b calibré avec raies télluriques *: ${nom_generic_profils}2b-calo$conf(extension,defaut)\n"
   }

   #- La RI :
   ::console::affiche_prompt "\n"
   if { [ file exists "$audace(rep_images)/reponse_instrumentale-3$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Réponse instrumentale *: reponse_instrumentale-3$conf(extension,defaut)\n"
   } elseif { [ file exists "$audace(rep_images)/reponse_instrumentale-br$conf(extension,defaut)" ]==1 } {
      ::console::affiche_prompt "Réponse instrumentale *: reponse_instrumentale-br$conf(extension,defaut)\n"
   }

   #-- Fichiers de la lampe de calibration :
   set objet_name ""
   #- Cas traitement de spectres additionnes :
   regexp {(.+)\-profil\-} "$nom_generic_profils" match objet_name
   if { "$objet_name"!="" } {
      ::console::affiche_prompt "Spectre 2D traité et redressé de l'objet *: ${objet_name}-spectre2D-traite$conf(extension,defaut)\n"
      ::console::affiche_prompt "Spectre 2D redressé de la lampe *: lampe_spectre2D_redresse-${objet_name}$conf(extension,defaut)\n"
      ::console::affiche_prompt "Profil corrigé et calibré de la lampe *: lampe_redressee_calibree-${objet_name}$conf(extension,defaut)\n"
   } else {
      #- Cas des times series :
      regexp {_(.+)\-[0-9]+} "$nom_profil_final" match objet_name
      if { "$objet_name"!="" } {
         ::console::affiche_prompt "Spectre 2D traité et redressé de l'objet *: ${objet_name}--spectre2D-traite$conf(extension,defaut)\n"
         ::console::affiche_prompt "Spectre 2D redressé de la lampe *: lampe_spectre2D_redresse-${objet_name}$conf(extension,defaut)\n"
         ::console::affiche_prompt "Profil corrigé et calibré de la lampe *: lampe_redressee_calibree-${objet_name}$conf(extension,defaut)\n"
      }
   }

   #-- Qualité de la calibration et résolution :
   ::console::affiche_prompt "\n*** Qualité de la calibration et résolution : ***\n"
   ::console::affiche_prompt "Loi de calibration : Lambda=$crval1+$cdelt1*(x-$crpix1)\n"
   ::console::affiche_prompt "RMS=$rms A  ---  Taux de précision=$rmsaccur%\n"
   if { $rmso!=0. } {
      ::console::affiche_prompt "RMS avec calibration téllurique=$rmso A  ---  Précision=$rmsoaccur%\n"
      ::console::affiche_prompt "Décalage moyen par rapport aux raies télluriques=$mdec A\n"
   }
   ::console::affiche_prompt "Pouvoir de résolution : R=$resolution sur la raie $resolution_l A\n"
   ::console::affiche_prompt "\n* Tous les résultats des opérations sont mémorisés dans l'entête FITS des fichiers. *\n"
   ::console::affiche_prompt "\n"
}

#**********************************************************************************#


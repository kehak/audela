#*****************************************************************************#
#                                                                             #
# Boîtes graphiques TK de saisie des paramètres pour les fonctions Spcaudace  #
#                                                                             #
#*****************************************************************************#
# Chargement : source $audace(rep_scripts)/spcaudace/spc_gui_runs.tcl

# Mise a jour $Id: spc_gui_runs.tcl 14525 2018-11-09 18:22:10Z bmauclaire $




########################################################################
# Activation calibration automatique avec lampe Relco
#
# Auteurs : Benjamin Mauclaire
# Date de création : 03-11-2015
# Date de modification : 03-11-2015
########################################################################

proc spc_relcono7509 { args } {

   global audace spcaudace

   set optioncalib [ lindex $args 0 ]
   set spcaudace(relco_noline7509) $optioncalib
   if { $optioncalib=="o" } {
      ::console::affiche_prompt "Absence de la raie 7509 de lampe Relco activée.\n"
   } elseif { $optioncalib=="n" } {
      ::console::affiche_prompt "Absence de la raie 7509 de lampe Relco désactivée.\n"
   }
}
#**********************************************************************#



########################################################################
# Maj du l'angle limite du tilt
#
# Auteurs : Benjamin Mauclaire
# Date de création : 25-02-2016
# Date de modification : 25-02-2016
########################################################################

proc spc_tiltonoff { args } {

   global audace spcaudace
   #-- Delfault value : set spcaudace(tilt_limit) 4.

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set max_tilt_angle [ lindex $args 0 ]
      set spcaudace(tilt_limit) $max_tilt_angle
      if { $max_tilt_angle==0. } {
         ::console::affiche_prompt "No tilt correction will be done.\n"
      } else {
         ::console::affiche_prompt "Tilt correction will be done.\n"
      }
   } else {
      ::console::affiche_erreur "Usage: spc_tiltonoff maximum_tilt_angle(4.0)\n"
      return ""
   }
}
#**********************************************************************#


########################################################################
# Activation de la correction uniquement du slant ou smilex
#
# Auteurs : Benjamin Mauclaire
# Date de création : 25-02-2016
# Date de modification : 25-02-2016
########################################################################

proc spc_smileonoff { args } {

   global audace spcaudace
   # Onlyslant : set spcaudace(hmax) 10000

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set ccd_height [ lindex $args 0 ]
      set spcaudace(hmax) $ccd_height
      if { $ccd_height==10000. } {
         set spcaudace(onlyslant) 1
         ::console::affiche_prompt "Only slant correction will be done.\n"
      } elseif { $ccd_height==4.2 } {
         set spcaudace(onlyslant) 0
         ::console::affiche_prompt "Smilex correction will be done.\n"
      }
   } else {
      ::console::affiche_erreur "Usage: spc_smileonoff maximum_ccd_height(4.2)\n"
      return ""
   }
}
#**********************************************************************#


########################################################################
# Personnalisation de la largeur de recherche des raies Relco
#
# Auteurs : Benjamin Mauclaire
# Date de création : 25-02-2016
# Date de modification : 25-02-2016
########################################################################

proc spc_calibrefile_setfile { args } {

   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set lines_file [ lindex $args 0 ]
      set spcaudace(fichier_raies) "$lines_file"
   } else {
      ::console::affiche_erreur "Usage: spc_calibrefile_setfile position_lambda_file_name.txt(Default: lines_file.txt)\n"
      return ""
   }
}
#**********************************************************************#



########################################################################
# Activation calibration automatique avec lampe Relco
#
# Auteurs : Benjamin Mauclaire
# Date de création : 03-11-2015
# Date de modification : 03-11-2015
########################################################################

proc spc_relcobr { args } {

   global audace spcaudace

   set optioncalib [ lindex $args 0 ]
   set spcaudace(flag_relcobr) $optioncalib
   if { $optioncalib=="o" } {
      ::console::affiche_prompt "Calibration automatique avec lampe Relco activée.\n"
   } elseif { $optioncalib=="n" } {
      ::console::affiche_prompt "Calibration manuelle classique activée.\n"
   }
}
#**********************************************************************#


########################################################################
# Personnalisation de la largeur de recherche des raies Relco
#
# Auteurs : Benjamin Mauclaire
# Date de création : 03-11-2015
# Date de modification : 03-11-2015
########################################################################

proc spc_relcowide { args } {

   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set relcowide [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_relcowide largeur_recherche_raies_relco (default : 3 A)\n"
      return ""
   }

   set spcaudace(largeur_relco) $relcowide
   ::console::affiche_prompt "Largeur de recherche des raies Relco réglée sur $relcowide A\n"
}
#**********************************************************************#

########################################################################
# Gestion de fente courte
#
# Auteurs : Benjamin Mauclaire
# Date de création : 03-11-2015
# Date de modification : 03-11-2015
########################################################################

proc spc_relcolineslist { args } {

   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set relcoliste [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_relcolineslist 6/8/(12)/f\n f : utilise un fichier texte monocolonne de raies mémorisé dans le répertoire de travail sous relco_lines.txt\n"
      return ""
   }

   set spcaudace(nblines_relco) $relcoliste
   ::console::affiche_prompt "Choix de la liste de raies Relco réglée sur $relcoliste\n"
}
#**********************************************************************#


########################################################################
# Gestion de fente courte
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-06-2015
# Date de modification : 09-06-2015
########################################################################

proc spc_shortslit_w { args } {

   global audace spcaudace

   set nbargs [ llength $args ]
   if { $nbargs==1 } {
      set choix [ lindex $args 0 ]
   } else {
      ::console::affiche_erreur "Usage: spc_shortslit_w o/n\n"
      return ""
   }

   if { $choix=="o" } {
      set spcaudace(binned_flat) "o"
      ::console::affiche_prompt "Gestion de fente courte activée.\n"
   } elseif { $choix=="n" } {
      set spcaudace(binned_flat) "n"
      ::console::affiche_prompt "Gestion de fente longue activée.\n"
   }
}
#**********************************************************************#


########################################################################
# Desactiver la decoupe des bords nuls
#
# Auteurs : Benjamin Mauclaire
# Date de création : 01-09-2013
# Date de modification : 01-09-2013
########################################################################

proc spc_rmedgesa_w {} {

   global audace spcaudace

   set spcaudace(rm_edges) "n"
   ::console::affiche_prompt "Découpe des bords nuls désactivée.\nPour la réactiver durant votre session, tapper : set spcaudace(rm_edges) \"o\"\n\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction buildhtml
#
# Auteurs : Benjamin Mauclaire
# Date de création : 07-08-2012
# Date de modification : 07-08-2012
########################################################################

proc spc_buildhtml_w {} {

   global audace

   spc_buildhtml
}
#**********************************************************************#


########################################################################
# PAsser en basse resolution
#
# Auteurs : Benjamin Mauclaire
# Date de création : 20-04-2010
# Date de modification : 20-04-2010
########################################################################

proc spc_br_w {} {

   global audace spcaudace

   set spcaudace(br) 1
   ::console::affiche_prompt "Mode basse résolution activé.\n\n"
}
#**********************************************************************#

########################################################################
# PAsser en haute resolution
#
# Auteurs : Benjamin Mauclaire
# Date de création : 20-04-2010
# Date de modification : 20-04-2010
########################################################################

proc spc_hr_w {} {

   global audace spcaudace

   set spcaudace(br) 0
   ::console::affiche_prompt "Mode haute résolution activé.\n\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_anim
#
# Auteurs : Benjamin Mauclaire
# Date de création : 20-04-2010
# Date de modification : 20-04-2010
########################################################################

proc spc_anim_w {} {

   global audace

   spc_anim
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_rmcosmics
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_rmcosmics_w {} {

   global audace

   spc_rmcosmics
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_scar
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_scar_w {} {

   global audace

   spc_scar
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_ajustplanck
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_ajustplanck_w {} {

   global audace

   spc_ajustplanck
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_offset
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_offset_w {} {

   global audace

   spc_offset
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommeadd_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_sommeadd_w {} {

   global audace spcaudace

   set spcaudace(meth_somme) "addi"
   ::console::affiche_prompt "Addition des spectres par une somme simple activée.\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommekappa_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_sommekappa_w {} {

   global audace spcaudace

   set spcaudace(meth_somme) "sigmakappa"
   ::console::affiche_prompt "Addition des spectres par une somme kappa-sigma activée.\n"
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommekappa_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_hbinning_w { args } {
   global audace spcaudace

   if { [ llength $args ]==1 } {
      set hbin [ lindex $args 0 ]
      set spcaudace(hauteur_binning) $hbin
      ::console::affiche_prompt "Hauteur de binning fixée à $hbin.\n"
   } else {
      set spcaudace(hauteur_binning) 0
      ::console::affiche_prompt "Hauteur de binning remise à la valeur 0.\n"
      ::console::affiche_erreur "Usage: spc_hbinning_w hauteur_binning_en_pixels. Mettre 0 pour une gestion automatique (comportement par défaut).\n"
   }
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_sommekappa_w
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_cafwhmbinning_w { args } {
   global audace spcaudace

   if { [ llength $args ]==1 } {
      set cabin [ lindex $args 0 ]
      set spcaudace(cafwhm_binning) $cabin
      ::console::affiche_prompt "Coéfficient multiplicateur de la FWHM de binning fixé à $cabin.\n"
   } else {
      set spcaudace(cafwhm_binning) 1.9
      ::console::affiche_prompt "Coéfficient multiplicateur de la FWHM de binning remis à 1.9.\n"
      ::console::affiche_erreur "Usage: spc_cafwhmbinning_w coefficient_multiplicateur_fwhm_de_binning. 1.9 est la valeur par défaut.\n"
   }
}
#**********************************************************************#


########################################################################
# Interface pour l'appel de la fonction spc_multc
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_multc_w {} {

   global audace

   spc_multc
}
#**********************************************************************#



########################################################################
# Interface pour l'appel de la fonction spc_ajustpoints
#
# Auteurs : Benjamin Mauclaire
# Date de création : 23-03-2010
# Date de modification : 23-03-2010
########################################################################

proc spc_ajustpoints_w {} {

   global audace

   spc_ajustpoints
}
#**********************************************************************#


########################################################################
# Interface pour l'appel du panneau de prétraitement de Francois Cochard
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
########################################################################

proc spc_pretraitementfc_w {} {

   global audace

   ::confVisu::selectTool $audace(visuNo) ::pretrfc
}
#**********************************************************************#



########################################################################
# Interface pour la réduction des spectres du Lhires III
#
# Auteurs : Benjamin Mauclaire
# Date de création : 19-08-2006
# Date de modification : 19-08-2006
########################################################################

proc spc_specLhIII_w {} {

    global conf
    global audace

    # source $audace(rep_scripts)/../plugin/tool/pretrfc/pretrfc.ini
    ::spbmfc::Demarragespbmfc
}


########################################################################
# Interface pour la calibration en longueur d'onde a partir de 2 raies
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traitecalibre (meta)
# Args :
########################################################################

proc spc_calibre2file_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_calibre2file::run
	tkwait window .param_spc_audace_calibre2file
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,calibre2file,config,spectre)
    set audace(param_spc_audace,calibre2file,config,xa1)
    set audace(param_spc_audace,calibre2file,config,xa2)
    set audace(param_spc_audace,calibre2file,config,xb1)
    set audace(param_spc_audace,calibre2file,config,xb2)
    set audace(param_spc_audace,calibre2file,config,type1)
    set audace(param_spc_audace,calibre2file,config,type2)
    set audace(param_spc_audace,calibre2file,config,lambda1)
    set audace(param_spc_audace,calibre2file,config,lambda2)

    set spectre $audace(param_spc_audace,calibre2file,config,spectre)
    set xa1 $audace(param_spc_audace,calibre2file,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2file,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2file,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2file,config,xb2)
    set type1 $audace(param_spc_audace,calibre2file,config,type1)
    set type2 $audace(param_spc_audace,calibre2file,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2file,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2file,config,lambda2)

    #--- Effectue la calibration du spectre 2D de la lampe spectrale :
    set fileout [ spc_calibre2sauto $spectre $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]
    return $fileout
}
#**************************************************************************#



########################################################################
# Interface pour la calibration en longueur d'onde a partir de 2 raies
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traitecalibre (meta)
# Args :
########################################################################

proc spc_calibre2loifile_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_calibre2loifile::run
	tkwait window .param_spc_audace_calibre2loifile
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,calibre2loifile,config,spectre)
    set audace(param_spc_audace,calibre2loifile,config,lampe)
    set audace(param_spc_audace,calibre2loifile,config,xa1)
    set audace(param_spc_audace,calibre2loifile,config,xa2)
    set audace(param_spc_audace,calibre2loifile,config,xb1)
    set audace(param_spc_audace,calibre2loifile,config,xb2)
    set audace(param_spc_audace,calibre2loifile,config,type1)
    set audace(param_spc_audace,calibre2loifile,config,type2)
    set audace(param_spc_audace,calibre2loifile,config,lambda1)
    set audace(param_spc_audace,calibre2loifile,config,lambda2)

    set spectre $audace(param_spc_audace,calibre2loifile,config,spectre)
    set lampe $audace(param_spc_audace,calibre2loifile,config,lampe)
    set xa1 $audace(param_spc_audace,calibre2loifile,config,xa1)
    set xa2 $audace(param_spc_audace,calibre2loifile,config,xa2)
    set xb1 $audace(param_spc_audace,calibre2loifile,config,xb1)
    set xb2 $audace(param_spc_audace,calibre2loifile,config,xb2)
    set type1 $audace(param_spc_audace,calibre2loifile,config,type1)
    set type2 $audace(param_spc_audace,calibre2loifile,config,type2)
    set lambda1 $audace(param_spc_audace,calibre2loifile,config,lambda1)
    set lambda2 $audace(param_spc_audace,calibre2loifile,config,lambda2)

    #--- Effectue la calibration du spectre 2D de la lampe spectrale :
    set lampecalibree [ spc_calibre2sauto $spectre $xa1 $xa2 $lambda1 $type1 $xb1 $xb2 $lambda2 $type2 ]
    ::console::affiche_resultat "\n**** Calibration en longueur d'onde du spectre de l'objet $spectre ****\n\n"
    set fcalibre [ spc_calibreloifile $lampecalibree $spectre ]
    return $fcalibre
}
#**************************************************************************#


########################################################################
# Interface pour le traitement des spectre : géométrie, calibration, correction réponse intrumentale, adoucissement
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_geom2calibre
# Args : nom_generique_spectres_pretraites (sans extension) nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) normalisation (o/n)
########################################################################

proc spc_geom2calibre_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_geom2calibre::run
	tkwait window .param_spc_audace_geom2calibre
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set flag 1
    if { $flag == 0 } {
    set audace(param_spc_audace,geom2calibre,config,spectres)
    set audace(param_spc_audace,geom2calibre,config,lampe)
    set audace(param_spc_audace,geom2calibre,config,etoile_ref)
    set audace(param_spc_audace,geom2calibre,config,etoile_cat)
    set audace(param_spc_audace,geom2calibre,config,methreg)
    set audace(param_spc_audace,geom2calibre,config,methsel)
    set audace(param_spc_audace,geom2calibre,config,methsky)
    set audace(param_spc_audace,geom2calibre,config,methbin)
    set audace(param_spc_audace,geom2calibre,config,smooth)
    }
    set spectres $audace(param_spc_audace,geom2calibre,config,spectres)
    set lampe $audace(param_spc_audace,geom2calibre,config,lampe)
    set etoile_ref $audace(param_spc_audace,geom2calibre,config,etoile_ref)
    set etoile_cat $audace(param_spc_audace,geom2calibre,config,etoile_cat)
    set methreg $audace(param_spc_audace,geom2calibre,config,methreg)
    set methsel $audace(param_spc_audace,geom2calibre,config,methsel)
    set methsky $audace(param_spc_audace,geom2calibre,config,methsky)
    set methbin $audace(param_spc_audace,geom2calibre,config,methbin)
    set smooth $audace(param_spc_audace,geom2calibre,config,smooth)

    #--- Lancement de la fonction spcaudace :
    # set fileout [ spc_geom2calibre $spectres $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $smooth ]
    ::console::affiche_resultat "$spectres, $lampe, $etoile_ref\n"
    return $fileout
}
#**************************************************************************#



########################################################################
# Interface pour le traitement des spectre : géométrie, calibration, correction réponse intrumentale, normalisation
#
# Auteurs : Benjamin Mauclaire
# Date de création : 14-07-2006
# Date de modification : 14-07-2006
# Utilisée par : spc_geom2rinstrum
# Args : nom_generique_spectres_pretraites (sans extension) nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) normalisation (o/n)
########################################################################

proc spc_geom2rinstrum_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_geom2rinstrum::run
	tkwait window .param_spc_audace_geom2rinstrum
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,geom2rinstrum,config,spectres)
    set audace(param_spc_audace,geom2rinstrum,config,lampe)
    set audace(param_spc_audace,geom2rinstrum,config,etoile_ref)
    set audace(param_spc_audace,geom2rinstrum,config,etoile_cat)
    set audace(param_spc_audace,geom2rinstrum,config,methreg)
    set audace(param_spc_audace,geom2rinstrum,config,methsel)
    set audace(param_spc_audace,geom2rinstrum,config,methsky)
    set audace(param_spc_audace,geom2rinstrum,config,methbin)
    set audace(param_spc_audace,geom2rinstrum,config,norma)

    set brut $audace(param_spc_audace,geom2rinstrum,config,spectres)
    set lampe $audace(param_spc_audace,geom2rinstrum,config,lampe)
    set etoile_ref $audace(param_spc_audace,geom2rinstrum,config,etoile_ref)
    set etoile_cat $audace(param_spc_audace,geom2rinstrum,config,etoile_cat)
    set methreg $audace(param_spc_audace,geom2rinstrum,config,methreg)
    set methsel $audace(param_spc_audace,geom2rinstrum,config,methsel)
    set methsky $audace(param_spc_audace,geom2rinstrum,config,methsky)
    set methbin $audace(param_spc_audace,geom2rinstrum,config,methbin)
    set smooth $audace(param_spc_audace,geom2rinstrum,config,norma)

    #--- Lancement de la fonction spcaudace :
    set fileout [ spc_geom2rinstrum $spectres $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $norma ]
    return $fileout
}
#**************************************************************************#



########################################################################
# Interface pour le traitement des spectre : prétraiement, géométrie, calibration
#
# Auteurs : Benjamin Mauclaire
# Date de création : 09-07-2006
# Date de modification : 09-07-2006
# Utilisée par : spc_traite2calibre (meta)
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) smooth (o/n)
########################################################################

proc spc_traite2calibre_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_traite2calibre::run
	tkwait window .param_spc_audace_traite2calibre
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,traite2calibre,config,brut)
    set audace(param_spc_audace,traite2calibre,config,noir)
    set audace(param_spc_audace,traite2calibre,config,plu)
    set audace(param_spc_audace,traite2calibre,config,noirplu)
    set audace(param_spc_audace,traite2calibre,config,lampe)
    set audace(param_spc_audace,traite2calibre,config,methreg)
    set audace(param_spc_audace,traite2calibre,config,methsel)
    set audace(param_spc_audace,traite2calibre,config,methsky)
    set audace(param_spc_audace,traite2calibre,config,methbin)
    set audace(param_spc_audace,traite2calibre,config,smooth)

    set brut $audace(param_spc_audace,traite2calibre,config,brut)
    set noir $audace(param_spc_audace,traite2calibre,config,noir)
    set plu $audace(param_spc_audace,traite2calibre,config,plu)
    set noirplu $audace(param_spc_audace,traite2calibre,config,noirplu)
    set lampe $audace(param_spc_audace,traite2calibre,config,lampe)
    set methreg $audace(param_spc_audace,traite2calibre,config,methreg)
    set methsel $audace(param_spc_audace,traite2calibre,config,methsel)
    set methsky $audace(param_spc_audace,traite2calibre,config,methsky)
    set methbin $audace(param_spc_audace,traite2calibre,config,methbin)
    set smooth $audace(param_spc_audace,traite2calibre,config,smooth)

    #--- Lancement de la fonction spcaudace :
    set fileout [ spc_traite2calibre $brut $noir $plu $noirplu $lampe $methreg $methsel $methsky $methbin $smooth ]
    return $fileout
}
#**************************************************************************#


########################################################################
# Interface pour le traitement des spectre : prétraiement, géométrie, calibration, correction réponse intrumentale, normalisation
#
# Auteurs : Benjamin Mauclaire
# Date de création : 13-07-2006
# Date de modification : 13-07-2006
# Utilisée par : spc_traite2rinstrum (meta)
# Args : nom_generique_images_objet (sans extension) nom_dark nom_plu nom_dark_plu nom_spectre_lampe etoile_ref etoile_cat methode_reg (reg, spc) methode_détection_spectre (large, serre)  methode_sub_sky (moy, moy2, med, inf, sup, ack, none) methode_binning (add, rober, horne) normalisation (o/n)
########################################################################

proc spc_traite2rinstrum_w {} {

    global conf
    global audace

    set err [ catch {
	::param_spc_audace_traite2rinstrum::run
	tkwait window .param_spc_audace_traite2rinstrum
    } msg ]
    if {$err==1} {
	::console::affiche_erreur "$msg\n"
    }

    #--- Récupératoin des paramètres saisis dans l'interface graphique
    set audace(param_spc_audace,traite2rinstrum,config,brut)
    set audace(param_spc_audace,traite2rinstrum,config,noir)
    set audace(param_spc_audace,traite2rinstrum,config,plu)
    set audace(param_spc_audace,traite2rinstrum,config,noirplu)
    set audace(param_spc_audace,traite2rinstrum,config,lampe)
    set audace(param_spc_audace,traite2rinstrum,config,etoile_ref)
    set audace(param_spc_audace,traite2rinstrum,config,etoile_cat)
    set audace(param_spc_audace,traite2rinstrum,config,methreg)
    set audace(param_spc_audace,traite2rinstrum,config,methsel)
    set audace(param_spc_audace,traite2rinstrum,config,methsky)
    set audace(param_spc_audace,traite2rinstrum,config,methbin)
    set audace(param_spc_audace,traite2rinstrum,config,norma)

    set brut $audace(param_spc_audace,traite2rinstrum,config,brut)
    set noir $audace(param_spc_audace,traite2rinstrum,config,noir)
    set plu $audace(param_spc_audace,traite2rinstrum,config,plu)
    set noirplu $audace(param_spc_audace,traite2rinstrum,config,noirplu)
    set lampe $audace(param_spc_audace,traite2rinstrum,config,lampe)
    set etoile_ref $audace(param_spc_audace,traite2rinstrum,config,etoile_ref)
    set etoile_cat $audace(param_spc_audace,traite2rinstrum,config,etoile_cat)
    set methreg $audace(param_spc_audace,traite2rinstrum,config,methreg)
    set methsel $audace(param_spc_audace,traite2rinstrum,config,methsel)
    set methsky $audace(param_spc_audace,traite2rinstrum,config,methsky)
    set methbin $audace(param_spc_audace,traite2rinstrum,config,methbin)
    set smooth $audace(param_spc_audace,traite2rinstrum,config,norma)

    #--- Lancement de la fonction spcaudace :
    set fileout [ spc_traite2rinstrum $brut $noir $plu $noirplu $lampe $etoile_ref $etoile_cat $methreg $methsel $methsky $methbin $norma ]
    return $fileout
}
#**************************************************************************#




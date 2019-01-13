## @file bddimages_go.tcl
#  @brief     Demarrage du plugin bddimages
#  @author    Frederic Vachier and Jerome Berthier
#  @version   1.0
#  @date      2013
#  @copyright GNU Public License.
#  @par Ressource
#  @code  source [file join $audace(rep_install) gui audace plugin tool bddimages bddimages_go.tcl]
#  @endcode

# $Id: bddimages_go.tcl 14537 2018-11-19 17:10:02Z fredvachier $

##
# @namespace bddimages
# @brief Cr&eacute;ation et initialisation du plugin bddimages.
# @pre Requiert le fichier d'internationalisation \c bddimages_go.cap .
# @warning Outil en d&eacute;veloppement
#
namespace eval ::bddimages {

   package provide bddimages 1.0

   global audace
   variable This
   variable log_level
   variable gui_exist

   #--- Chargement des captions
   source [ file join [file dirname [info script]] bddimages_go.cap ]

}

#------------------------------------------------------------
## Retourne le titre du plugin dans la langue de l'utilisateur
#  @return  Titre du plugin
#  @sa      getPluginType
#
proc ::bddimages::getPluginTitle { } {
   global caption

   return "$caption(bddimages_go,titre)"
}

#------------------------------------------------------------
## Retourne le nom du fichier d'aide principal
#  @return le nom du fichier d'aide principal
#
proc ::bddimages::getPluginHelp { } {
   return "bddimages.htm"
}

#------------------------------------------------------------
## Retourne le type de plugin
#  @return type de plugin
#
proc ::bddimages::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
## Retourne le repertoire du plugin
#  @return repertoire du plugin
#
proc ::bddimages::getPluginDirectory { } {
   return "bddimages"
}

#------------------------------------------------------------
## Retourne le ou les OS de fonctionnement du plugin
#  @return le ou les OS de fonctionnement du plugin
#
proc ::bddimages::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## Recupere la valeur d'une propriete du plugin
#  @param propertyName Nom de la propriete
#  @return valeur de la propriete ou "" si la propriete n'existe pas
#
proc ::bddimages::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "display" }
      display      { return "panel" }
   }
}

#------------------------------------------------------------
## Creation d'une instance du plugin
# @param base base tk
# @param visuNo numéro de la visu
# @return void
#
proc ::bddimages::createPluginInstance { base { visuNo 1 } } {

   global audace
   global bddconf

   #--- Chargement des packages
   package require tablelist
   package require math::statistics

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_config.tcl ]\""

   set bddconf(current_db) "?"

   set bddconf(font,courier_8)  "Courier  8 normal"
   set bddconf(font,courier_10) "Courier 10 normal"
   set bddconf(font,arial_10)   "{Arial} 10 normal"
   set bddconf(font,arial_10_b) "{Arial} 10 bold"
   set bddconf(font,arial_12)   "{Arial} 12 normal"
   set bddconf(font,arial_12_b) "{Arial} 12 bold"
   set bddconf(font,arial_14_b) "{Arial} 14 bold"

   set bddconf(bufno)    $audace(bufNo)
   set bddconf(visuno)   $audace(visuNo)
   set bddconf(rep_plug) [file join $audace(rep_plugin) tool bddimages]
   set bddconf(astroid)  [file join $audace(rep_plugin) tool bddimages utils astroid]

   set bddconf(extension_bdd) ".fits.gz"
   set bddconf(extension_tmp) ".fit"

   set ::bddimages::log_level "Info"

   #--- Chargement des procedures
   ::bddimages::ressource
   ::Samp::destroy

   ::bddimages_sql::mysql_init

   #--- Mise en place de l'interface graphique
   ::bddimages::createPanel $base.bddimages

   #---
   return $base.bddimages
}

#------------------------------------------------------------
## Re-source l'ensemble des sources Tcl du plugin
# @return void
#
proc ::bddimages::ressource {  } {

   global audace

   set ::bddimages::log_level "Info"

   load [file join $audace(rep_install) bin libcatalog_tcl[info sharedlibextension]]
#   load [file join $audace(rep_install) bin libcatalog[info sharedlibextension]]

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool bddimages bddimages_go.cap ]

   #--- Chargement des fichiers externes
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools vo_tools_go.tcl ]\""

   #--- Chargement des fichiers prioritaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""

   #--- Chargement des fichiers tools
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_appariement.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_calendar.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_image.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_jpl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_mpc.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_priam.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_sources.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_verifcata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_psf.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astrometry.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_cata_user.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_reports.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_synchro.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_synchro.server.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_synchro.client.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astroid_tank.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_verif.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_reports_v0_v1.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_headers.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_define.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_binast.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_famous.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_planetes.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_orbfit.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_thread.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages tools_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages tools_cdl.tcl ]\""

   #--- Chargement des fichiers gui
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_astrometry.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_creation.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_delete.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_gestion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cdl.famous.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cdl_withwcs.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cdl_basic.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_gestion_source.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_psf.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_set_ref_science.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_verifcata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_synchro.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_famous.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_voir.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_export.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_manage.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_mpc.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_mail.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_astrometry_analyse.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_analysis.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_analysis_data.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_analysis_graph.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_analysis_interpol.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_define.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast_ihm.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast_io.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast_mesure.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast_ephem.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_analysis_y_manual_move.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_analysis_planif.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.visu.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.skybot.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.reports.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.traitement.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.dev.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.mesure.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.starref.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_planetes.newaster.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_astrophotom.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_newaster.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_newaster.planif.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_orbfit.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_orbfit.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_reports_newaster.voir.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]\""

   # Anciennes facon de nommage des routines
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sql.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_header.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages test.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.cap ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages utils astroid libastroid.tcl ]\""

   source [ file join $::audace(rep_install) gui audace surchaud.tcl ]
}

#------------------------------------------------------------
## Re-source l'ensemble des sources Tcl du plugin
# @return void
#
proc ::bddimages::ressource_tools {  } {

   global audace

   set ::bddimages::log_level "Info"

   load [file join $audace(rep_install) bin libcatalog_tcl[info sharedlibextension]]
#   load [file join $audace(rep_install) bin libcatalog[info sharedlibextension]]

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool bddimages bddimages_go.cap ]

   #--- Chargement des fichiers externes
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools samp.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools sampTools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votable.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools votableUtil.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool vo_tools vo_tools_go.tcl ]\""

   #--- Chargement des fichiers prioritaires
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_xml.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_admin.tcl ]\""

   #--- Chargement des fichiers tools
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_appariement.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_calendar.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_config.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_image.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_jpl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_mpc.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_priam.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_sources.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_status.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_verifcata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_psf.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astrometry.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_cata_user.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_reports.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_synchro.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_synchro.server.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_synchro.client.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_astroid_tank.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_verif.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_reports_v0_v1.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_headers.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_binast.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_famous.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_planetes.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_orbfit.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_tools_thread.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages tools_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages tools_cdl.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_binast_ihm.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cata_gestion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bdi_gui_cdl_withwcs.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_go.tcl ]\""

   # Anciennes facon de nommage des routines
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sql.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_identification.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_entete_preminforecon.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_fichier.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_header.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste_gui.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_astroid.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_cdl.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages test.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_sub_insertion.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion_applet.tcl ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.tcl ]\""

   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_insertion.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_recherche.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_liste.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_define.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_imgcorrection.cap ]\""
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages bddimages_infocam.cap ]\""


   uplevel #0 "source \"[ file join $audace(rep_plugin) tool bddimages utils astroid libastroid.tcl ]\""

}

#------------------------------------------------------------
## Detruit d'instance du plugin
# @param visuNo Numero de la Visu
# @return void
#
proc ::bddimages::deletePluginInstance { visuNo } {

}

#------------------------------------------------------------
## Initialisation de la creation du panneau bddimages
# @param this string pathName racine du panneau
# @return void
#
proc ::bddimages::createPanel { this } {

   variable This
   global caption panneau bddconf

   #--- Initialisation du nom de la fenetre
   set This $this

   #--- Chargement des noms des config disponibles de bddimages
   ::bdi_tools_config::load_config_names

   #--- Construction de l'interface
   ::bddimages::bddimagesBuildIF $This

}

#------------------------------------------------------------
## Configuration des boutons et autres widgets du panneau
# @return void
#
proc ::bddimages::handleBddState { } {

   variable This
   global audace bddconf

   set visuNo $::audace(visuNo)

   if {$::bdi_tools_xml::is_config_loaded && $::bdi_tools_config::ok_mysql_connect} {
      set colorBtn "#00CC00"
      #--- Active les boutons
      $This.fra3.but1 configure -state active
      $This.fra4.but1 configure -state active
      $This.fra5.but1 configure -state active
   } else {
      set colorBtn "#DD0000"
      #--- De-Active les boutons
      $This.fra3.but1 configure -state disabled
      $This.fra4.but1 configure -state disabled
      $This.fra5.but1 configure -state disabled
   }

   # Configure menubutton du choix des bdd
   $This.fra1.menu configure -bg $colorBtn

}

#------------------------------------------------------------
## Chargement de la config selectionnee a partir du menu-bouton config.
# @return void
#
proc ::bddimages::load_config_frombutton { } {

   variable This
   global audace bddconf

   if {[string compare $bddconf(current_config) "?"] == 0} {
      ::bdi_gui_config::configuration $audace(base).bdi_gui_config
   } else {
      ::bdi_tools_config::load_config $bddconf(current_config)
      ::bddimages::handleBddState
   }

   #--- Initialisation des parametres des cata
   ::bdi_gui_cata_creation::inittoconf
   ::bdi_gui_astrometry::inittoconf

}

#------------------------------------------------------------
## Creation du panneau de bddimages
# @param This string pathName de la racine du panneau
# @return void
#
proc ::bddimages::bddimagesBuildIF { This } {

   global audace caption bddconf

   #--- Frame
   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra0 -borderwidth 2 -relief groove
      pack $This.fra0 -side top -fill x

         #--- Bouton du titre
         button $This.fra0.but -borderwidth 1 \
            -text "$caption(bddimages_go,help_titre1)\n$caption(bddimages_go,bddimages)" \
            -command "::audace::showHelpPlugin tool bddimages bddimages.htm"
         pack $This.fra0.but -in $This.fra0 -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra0.but -text $caption(bddimages_go,help_titre)

      #--- Frame des services
      frame $This.fra1 -borderwidth 1 -relief groove
      pack $This.fra1 -side top -fill x

         #--- Cree un menu bouton pour choisir la bdd
         menubutton $This.fra1.menu -relief raised -borderwidth 2 -textvariable bddconf(current_config) -menu $This.fra1.menu.list
         pack $This.fra1.menu -in $This.fra1 -side top -padx 3 -pady 5 -ipadx 5 -ipady 2
         set menuconfig [menu $This.fra1.menu.list -tearoff 1]
         foreach myconf $bddconf(list_config) {
            $menuconfig add radiobutton -label [lindex "$myconf" 1] -value [lindex "$myconf" 1] \
               -variable bddconf(current_config) \
               -command "::bddimages::load_config_frombutton"
         }

      #--- Frame des services
      frame $This.fra2 -borderwidth 1 -relief groove
      pack $This.fra2 -side top -fill x

         #--- Bouton d'ouverture de la config
         button $This.fra2.but1 -borderwidth 2 -text $caption(bddimages_go,configuration) \
            -command "::bdi_gui_config::configuration $audace(base).bdi_gui_config"
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.fra3 -borderwidth 1 -relief groove
      pack $This.fra3 -side top -fill x

         #--- Bouton d'ouverture de l'outil de statut
         button $This.fra3.but1 -borderwidth 2 -text $caption(bddimages_go,status) \
            -command "::bdi_gui_status::run $audace(base).status"
         pack $This.fra3.but1 -in $This.fra3 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.fra4 -borderwidth 1 -relief groove
      pack $This.fra4 -side top -fill x

         #--- Bouton d'ouverture de l'outil d'insertion des images
         button $This.fra4.but1 -borderwidth 2 -text $caption(bddimages_go,insertion) \
            -command "::bddimages_insertion::run $audace(base).bddimages_insertion"
         pack $This.fra4.but1 -in $This.fra4 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.fra5 -borderwidth 1 -relief groove
      pack $This.fra5 -side top -fill x

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.fra5.but1 -borderwidth 2 -text $caption(bddimages_go,recherche) \
            -command "::bddimages_recherche::run $audace(base).bddimages_recherche"
         pack $This.fra5.but1 -in $This.fra5 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.synchro -borderwidth 1 -relief groove
      pack $This.synchro -side top -fill x

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.synchro.but1 -borderwidth 2 -text "Synchro" \
            -command "::bdi_gui_synchro::run"
         pack $This.synchro.but1 -in $This.synchro -anchor center -fill both -pady 5 -ipadx 5 -ipady 3

     #--- Frame des services
     frame $This.fra_reports -borderwidth 1 -relief groove
     pack $This.fra_reports -side top -fill x

        #--- Bouton d'ouverture de l'outil de recherche d images
        button $This.fra_reports.but1 -borderwidth 2 -text $caption(bddimages_go,reports) \
           -command "::bdi_gui_reports::run" -state active
        pack $This.fra_reports.but1 -in $This.fra_reports -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

     #--- Frame des services
     frame $This.fra6 -borderwidth 1 -relief groove
     pack $This.fra6 -side top -fill x

        #--- Bouton d'ouverture de l'outil de recherche d images
        button $This.fra6.but1 -borderwidth 2 -text $caption(bddimages_go,test) \
           -command "::testprocedure::run" -state disabled
        pack $This.fra6.but1 -in $This.fra6 -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame des services
      frame $This.ressource -borderwidth 1 -relief groove
      pack $This.ressource -side top -fill x

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.ressource.but1 -borderwidth 2 -text $caption(bddimages_go,ressource) \
            -command {::bddimages::ressource}
         pack $This.ressource.but1 -in $This.ressource -anchor center -fill none -pady 5 -ipadx 5 -ipady 3

      #--- Frame du bouton log
      frame $This.log -borderwidth 1 -relief groove
      pack $This.log -side top -fill x

         #--- Bouton de choix du niveau de log
         label $This.log.lab -text "Log:"
         menubutton $This.log.b -menu $This.log.b.m -textvar ::bddimages::log_level -width 10 -relief groove
         menu $This.log.b.m -tearoff 0
         $This.log.b.m add command -label "No"    -command {set ::bddimages::log_level "No"}
         $This.log.b.m add command -label "Info"  -command {set ::bddimages::log_level "Info"}
         $This.log.b.m add command -label "Debug" -command {set ::bddimages::log_level "Debug"}
         grid $This.log.lab $This.log.b -pady 5 -ipadx 3 -ipady 3

      #--- Frame des services
      frame $This.clean -borderwidth 1 -relief groove
      pack $This.clean -side top -fill x

         #--- Bouton d'ouverture de l'outil de recherche d images
         button $This.clean.but1 -borderwidth 2 -text $caption(bddimages_go,cleanconsole) \
            -command { console::clear}
         pack $This.clean.but1 -in $This.clean -anchor center -fill none -pady 5 -ipadx 5 -ipady 3


      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
      #--- Coloration du menubouton du choix de la bdd
      $This.fra1.menu configure -bg "#DD0000"
      #--- Desactive les boutons, qui seront actives apres chargement de la config
      $This.fra3.but1 configure -state disabled
      $This.fra4.but1 configure -state disabled
      $This.fra5.but1 configure -state disabled

}

#------------------------------------------------------------
## Impression d'un message dans la console
# @return void
#
proc gren_msg { msg } {
   ::console::affiche_resultat "$msg"
}


#------------------------------------------------------------
## Impression d'un message d'info dans la console si la variable log_level vaut Info ou Debug
# @return void
#
proc gren_info { msg } {

   if {[info exists ::bddimages::nogui]} {
      if {$::bddimages::nogui} {
         if { [string index $msg end] == "\n" } {
            set msg [string range $msg 0 end-1]
         }
      }
   }

   if {$::bddimages::log_level == "Info" || $::bddimages::log_level == "Debug"} {
      ::console::affiche_resultat "$msg"
   }
}


#------------------------------------------------------------
## Impression d'un message de debug dans la console si la variable log_level vaut Debug
# @return void
#
proc gren_debug { msg } {
   global audace
   if {$::bddimages::log_level == "Debug"} {
      $audace(Console).txt1 tag configure style_debug -foreground blue
      $audace(Console).txt1 insert end "# Debug > " style_debug
      $audace(Console).txt1 insert end "$msg"
   }
}


#------------------------------------------------------------
## Impression d'un message d'erreur dans la console
# @return void
#
proc gren_erreur { msg } {

   if {[info exists ::bddimages::nogui]} {
      if {$::bddimages::nogui} {
         if { [string index $msg end] == "\n" } {
            set msg [string range $msg 0 end-1]
         }
      }
   }
   ::console::affiche_erreur "$msg"

}


proc gren_date { } {
   # --- Retourne la date de l'instant actuel
   set date [mc_date2ymdhms now]
   set date "[format "%04d-%02d-%02dT%02d:%02d:%02.0f" [lindex $date 0] [lindex $date 1] [lindex $date 2] [lindex $date 3] [lindex $date 4] [lindex $date 5]]"
   return $date
}


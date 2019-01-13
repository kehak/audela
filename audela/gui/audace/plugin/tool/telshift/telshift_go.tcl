#
## @file telshift_go.tcl
#  @brief Outil pour l'acquisition avec deplacement du telescope entre les poses
#  @author Christian JASINSKI
#  $Id: telshift_go.tcl 13343 2016-03-10 15:19:04Z rzachantke $
#

#============================================================
# Declaration du namespace telshift
#    initialise le namespace
#============================================================

## namespace telshift
#  @brief Outil pour l'acquisition avec deplacement du telescope entre les poses

namespace eval ::telshift {
   package provide telshift 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] telshift_go.cap ]
}

#------------------------------------------------------------
# brief      retourne le titre du plugin dans la langue de l'utilisateur
# return     titre du plugin
#
proc ::telshift::getPluginTitle { } {
   global caption

   return "$caption(telshift_go,telshift)"
}

#------------------------------------------------------------
# brief      retourne le nom du fichier d'aide principal
# return     nom du fichier d'aide principal
#
proc ::telshift::getPluginHelp { } {
   return "telshift.htm"
}

#------------------------------------------------------------
# brief      retourne le type de plugin
# return     type de plugin
#
proc ::telshift::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief      retourne le nom du répertoire du plugin
# return     nom du répertoire du plugin : "telshift"
#
proc ::telshift::getPluginDirectory { } {
   return "telshift"
}

#------------------------------------------------------------
## @brief     retourne le ou les OS de fonctionnement du plugin
#  @return    liste des OS : "Windows Linux Darwin"
#
proc ::telshift::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::telshift::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "aiming" }
      display      { return "window" }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin de la fenêtre
#
proc ::telshift::createPluginInstance { base { visuNo 1 } } {
   global audace

   #--- Charge le source de la fenetre Imager & deplacer
   uplevel #0 "source \"[ file join $audace(rep_plugin) tool telshift telshift.tcl ]\""

   #---
   set This $base.telima

   #--- J'ouvre la fenetre
   ::telshift::createPanel $This

   #---
   return $This
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin
#  @param   visuNo numéro de la visu
#
proc ::telshift::deletePluginInstance { visuNo } {
   variable This

   if { [ winfo exists $This ] } {
      #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
      ::telshift::cmdClose
   }
}


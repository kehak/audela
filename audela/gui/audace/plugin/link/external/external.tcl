#
# Fichier : external.tcl
# Description : Interface de liaison manuelle
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: external.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::external {
   package provide external 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] external.cap ]
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::external::configurePlugin { } {
   global audace

   #--- Affiche la liaison
  ### external::run "$audace(base).external"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::external::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::external::createPluginInstance { linkLabel deviceId usage comment args } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::external::deletePluginInstance { linkLabel deviceId usage } {
   #--- pour l'instant, la liaison est arretee par le pilote de la camera
   return
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::external::getPluginProperty { propertyName } {
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::external::getPluginTitle { } {
   global caption

   return "$caption(external,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::external::getPluginHelp { } {
   return "external.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::external::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::external::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::external::fillConfigPage { frm } {
   variable widget

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
# ::confLink::getLinkLabels
#    retourne la seule instance ethernaude
#
#------------------------------------------------------------
proc ::external::getLinkLabels { } {
   variable private

   return "$private(genericName)1"
}

#------------------------------------------------------------
# getSelectedLinkLabel
#    retourne le link choisi
#
#------------------------------------------------------------
proc ::external::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "external1"   retourne 1
#     exemple :  isValidLabel "XXX1"        retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::external::isValidLabel { linkLabel } {
   variable private

   if { [string first $private(genericName) $linkLabel ] == 0 } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#------------------------------------------------------------
proc ::external::initPlugin { } {
   variable private

   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "external"

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::external::initConf { } {
   global conf

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::external::isReady { } {
   return 0
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::external::selectConfigLink { linkLabel } {
   #--- rien a faire
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::external::widgetToConf { } {
   variable widget
   global conf

}


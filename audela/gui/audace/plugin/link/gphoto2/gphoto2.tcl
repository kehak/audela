#
# Fichier : gphoto2.tcl
# Description : Interface de liaison GPhoto2
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: gphoto2.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::gphoto2 {
   package provide gphoto2 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] gphoto2.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::gphoto2::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libgphoto2.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::gphoto2::getPluginType]] "gphoto2" "libgphoto2.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_canon.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::gphoto2::getPluginType]] "gphoto2" "libgphoto2_canon.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_port.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::gphoto2::getPluginType]] "gphoto2" "libgphoto2_port.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- je deplace libgphoto2_port_usb.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::gphoto2::getPluginType]] "gphoto2" "libgphoto2_port_usb.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(gphoto2,installNewVersion) $sourceFileName [package version gphoto2] ]
   }
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
proc ::gphoto2::configurePlugin { } {
   global audace

   #--- Affiche la liaison
  ### gphoto2::run "$audace(base).gphoto2"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::gphoto2::confToWidget { } {
   variable widget
   global conf

   set widget(gphoto2,debug) $conf(gphoto2,debug)
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::createPluginInstance { linkLabel deviceId usage comment args } {
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::deletePluginInstance { linkLabel deviceId usage } {
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
proc ::gphoto2::getPluginProperty { propertyName } {
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::gphoto2::getPluginTitle { } {
   global caption

   return "$caption(gphoto2,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::gphoto2::getPluginHelp { } {
   return "gphoto2.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::gphoto2::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::gphoto2::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::fillConfigPage { frm } {
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Mode debug
   checkbutton $frm.debug -text "$caption(gphoto2,debug) (gphoto2.log)" -highlightthickness 0 \
      -variable ::gphoto2::widget(gphoto2,debug)
   pack $frm.debug -in $frm -anchor center -side left -padx 10 -pady 2

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
# getLinkLabels
#    retourne le label du seul link
#
#------------------------------------------------------------
proc ::gphoto2::getLinkLabels { } {
   variable private

   return "$private(genericName)1"
}

#------------------------------------------------------------
# getSelectedLinkLabel
#    retourne le link choisi
#
#------------------------------------------------------------
proc ::gphoto2::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "gphoto21"   retourne 1
#     exemple :  isValidLabel "XXX1"        retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::gphoto2::isValidLabel { linkLabel } {
   variable private

   if { [string first $private(genericName) $linkLabel ] == 0 } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#------------------------------------------------------------
proc ::gphoto2::initPlugin { } {
   variable private

   #--- je fixe le nom generique de la liaison  identique au namespace
   set private(genericName) "gphoto2"

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
proc ::gphoto2::initConf { } {
   global conf

   if { ! [ info exists conf(gphoto2,debug) ] } { set conf(gphoto2,debug) "0" }
   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready) , 1 (not ready)
#------------------------------------------------------------
proc ::gphoto2::isReady { } {
   return 0
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::gphoto2::selectConfigLink { linkLabel } {
   variable private

   #--- rien a faire car il n'y qu'un seul link de ce type
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::gphoto2::widgetToConf { } {
   variable widget
   global conf

   set conf(gphoto2,debug) $widget(gphoto2,debug)
}


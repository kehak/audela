#
# Fichier : oscadine.tcl
# Description : Interface de liaison Oscadine
# Auteurs : OSCADI
# Mise à jour $Id: oscadine.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::oscadine {
   package provide oscadine 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] oscadine.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::oscadine::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace liboscadine.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::oscadine::getPluginType]] "oscadine" "liboscadine.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(oscadine,installNewVersion) $sourceFileName [package version oscadine] ]
   }
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  getPluginProperty
#     Retourne la valeur de la propriete
#
#  Parametres :
#     propertyName : Nom de la propriete
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::getPluginProperty { propertyName } {
   switch $propertyName {
      bitList {
         return [list 0 1 2 3 4 5 6 7]
      }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     Retourne le titre du plugin dans la langue de l'utilisateur
#
#  Parametres :
#     Aucun
#  Return :
#     caption(nom_plugin,titre)
#------------------------------------------------------------
proc ::oscadine::getPluginTitle { } {
   global caption

   return "$caption(oscadine,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     Retourne la documentation du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     nom_plugin.htm
#------------------------------------------------------------
proc ::oscadine::getPluginHelp { } {
   return "oscadine.htm"
}

#------------------------------------------------------------
#  getPluginType
#     Retourne le type du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     link
#------------------------------------------------------------
proc ::oscadine::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     Retourne le ou les OS de fonctionnement du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     La liste des OS supportes par le plugin
#------------------------------------------------------------
proc ::oscadine::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initPlugin
#     Initialise le plugin
#     initPlugin est lance automatiquement au chargement de ce fichier tcl
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::initPlugin { } {
   variable private
   set private(genericName) "oscadine"

   #--- Cree les variables dans conf(...) si elles n'existent pas
   initConf

   confToWidget
}

#------------------------------------------------------------
#  configurePlugin
#     Configure le plugin
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::configurePlugin { } {
   global audace

   #--- Affiche la liaison

   return
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::oscadine::initConf { } {
   global conf

   if { ! [ info exists conf(oscadine,ledsettings) ] }      { set conf(oscadine,ledsettings)      "0" }
   if { ! [ info exists conf(oscadine,overscansettings) ] } { set conf(oscadine,overscansettings) "0" }

   return
}

#------------------------------------------------------------
#  confToWidget
#     Copie les parametres du tableau conf() dans les variables des widgets
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::confToWidget { } {
   variable widget
   global conf

   set widget(oscadine,ledsettings)      $conf(oscadine,ledsettings)
   set widget(oscadine,overscansettings) $conf(oscadine,overscansettings)
}

#------------------------------------------------------------
#  createPluginInstance
#
#     Cree une liaison et retourne le numero du link
#    Le numero du link est attribue automatiquement
#    Si ce link est deja cree, on retourne le numero du link existant
#
#  Parametres :
#     linkLabel : Par exemple "LPT1:"
#     deviceId  : Par exemple "cam1"
#     usage     : Type d'utilisation
#     comment   : Commentaire
#  Return :
#     Numero du link
#
#------------------------------------------------------------
proc ::oscadine::createPluginInstance { linkLabel deviceId usage comment args } {
   variable private

   #--- je cree le lien
   set linkno [::link::create oscadine $linkLabel]
   #--- j'ajoute l'utilisation
   link$linkno use add $deviceId $usage $comment

   return $linkno
}

#------------------------------------------------------------
#  deletePluginInstance
#     Supprime une utilisation d'une liaison
#     et supprime la liaison si elle n'est plus utilises par aucun autre peripherique
#     Ne fait rien si la liaison n'est pas ouverte
#
#  Parametres :
#     linkLabel : Par exemple "LPT1:"
#     deviceId  : Par exemple "cam1"
#     usage     : Type d'utilisation
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::deletePluginInstance { linkLabel deviceId usage } {
   set linkno [::confLink::getLinkNo $linkLabel]
   if { $linkno != "" } {
      link$linkno use remove $deviceId $usage
      if { [link$linkno use get] == "" } {
         #--- je supprime la liaison si elle n'est plus utilisee par aucun peripherique
         ::link::delete $linkno
      }
      #--- je rafraichis la liste
      refreshAvailableList
   }
}

#------------------------------------------------------------
#  fillConfigPage
#     Fenetre de configuration du plugin
#
#  Parametres :
#     frm : Widget de l'onglet
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::fillConfigPage { frm } {
   variable widget
   global audace caption color

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- J'affiche l'interface de test
   frame $frm.port -borderwidth 0 -relief ridge

      #--- Frame test materiel
      TitleFrame $frm.port.settings -borderwidth 2 -relief ridge \
         -text "$caption(oscadine,settingsTitle)"

         checkbutton $frm.port.settings.ledsettings -text "$caption(oscadine,shutdownLed)" -highlightthickness 0 \
            -variable ::oscadine::widget(oscadine,ledsettings)

         pack $frm.port.settings.ledsettings -in [$frm.port.settings getframe] -side top -fill none -anchor w

         checkbutton $frm.port.settings.overscansettings -text "$caption(oscadine,hideOverscan)" -highlightthickness 0 \
            -variable ::oscadine::widget(oscadine,overscansettings)

         pack $frm.port.settings.overscansettings -in [$frm.port.settings getframe] -side top -fill none -anchor w

      pack $frm.port.settings -side top -anchor w -fill none -pady 10 -padx 15 -ipady 5 -ipadx 20

      #--- Site web officiel de l'Oscadine
      label $frm.port.websitelabel -text "$caption(oscadine,websiteLabel)"
      pack $frm.port.websitelabel -in $frm.port -side top -fill x -pady 2

      label $frm.port.labURL -text "$caption(oscadine,websiteURL)" -fg $color(blue)
      pack $frm.port.labURL -in $frm.port -side top -fill x -pady 2

   pack $frm.port -side top -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $frm.port.labURL <ButtonPress-1> {
      set filename "$caption(oscadine,websiteURL)"
      ::audace::Lance_Site_htm $filename
   }
   bind $frm.port.labURL <Enter> {
      $::oscadine::widget(frm).port.labURL configure -fg $color(purple)
   }
   bind $frm.port.labURL <Leave> {
      $::oscadine::widget(frm).port.labURL configure -fg $color(blue)
   }
}

#------------------------------------------------------------
#  getLinkLabels
#     Retourne les libelles des ports paralleles disponibles
#
#  Parametres :
#     Aucun
#  Return :
#     linkLabels : Par exemple { "LPT1:" "LPT2:" "LPT3:" }
#------------------------------------------------------------
proc ::oscadine::getLinkLabels { } {
   variable private

   #--- Je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     Retourne le link choisi
#
#  Parametres :
#     Aucun
#  Return :
#     linkLabel : Par exemple "LPT1:"
#------------------------------------------------------------
proc ::oscadine::getSelectedLinkLabel { } {
   variable private

   #--- Je retourne le label du seul link
   return "$private(genericName)1"
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "oscadine1"   retourne 1
#     exemple :  isValidLabel "XXX1"        retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::oscadine::isValidLabel { linkLabel } {
   variable private

   if { [string first $private(genericName) $linkLabel ] == 0 } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return nothing
#------------------------------------------------------------
proc ::oscadine::selectConfigLink { linkLabel } {
   variable private

   #--- Rien a faire car il n'y qu'un seul link de ce type
}

#------------------------------------------------------------
#  isReady
#     Informe de l'etat de fonctionnement du plugin
#
#  Parametres :
#     Aucun
#  Return :
#     0 (ready) ou 1 (not ready)
#------------------------------------------------------------
proc ::oscadine::isReady { } {
   return 0
}

#------------------------------------------------------------
#  widgetToConf
#     Copie les variables des widgets dans le tableau conf()
#
#  Parametres :
#     Aucun
#  Return :
#     Rien
#------------------------------------------------------------
proc ::oscadine::widgetToConf { } {
      variable widget
      global conf

   set conf(oscadine,ledsettings)      $widget(oscadine,ledsettings)
   set conf(oscadine,overscansettings) $widget(oscadine,overscansettings)
}


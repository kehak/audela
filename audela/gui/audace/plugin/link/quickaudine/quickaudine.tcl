#
# Fichier : quickaudine.tcl
# Description : Interface de liaison QuickAudine
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: quickaudine.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::quickaudine {
   package provide quickaudine 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] quickaudine.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::quickaudine::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libquicka.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::quickaudine::getPluginType]] "quickaudine" "libquicka.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(quickaudine,installNewVersion) $sourceFileName [package version quickaudine] ]
   }
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::configurePlugin { } {
   global audace

   #--- Affiche la liaison
  ### quickaudine::run "$audace(base).quickaudine"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::confToWidget { } {
   variable widget
   global conf

   set widget(quickaudine,delayshutter) $conf(quickaudine,delayshutter)
   set widget(quickaudine,canspeed)     $conf(quickaudine,canspeed)
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::createPluginInstance { linkLabel deviceId usage comment args } {
   global audace

   #--- je rafraichis la liste
   ::quickaudine::refreshAvailableList
   #--- je selectionne le link
   ::quickaudine::selectConfigLink $linkLabel
   #--- pour l'instant, la liaison est demarree par le pilote de la camera
   return
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::deletePluginInstance { linkLabel deviceId usage } {
   global audace

   #--- je rafraichis la liste
   ::quickaudine::refreshAvailableList
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
proc ::quickaudine::getPluginProperty { propertyName } {

}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::quickaudine::getPluginTitle { } {
   global caption

   return "$caption(quickaudine,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::quickaudine::getPluginHelp { } {
   return "quickaudine.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::quickaudine::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::quickaudine::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- j'affiche la liste des links et le bouton pour rafraichir cette liste
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(quickaudine,available)

      listbox $frm.available.list -height 3
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true

      Button $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(quickaudine,refresh)" -command { ::quickaudine::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left

   pack $frm.available -side top -fill both -expand true

   #--- j'affiche les labels et l'entry pour le delai avant la lecture du CCD
   frame $frm.delayshutter -borderwidth 0 -relief raised

      label $frm.delayshutter.lab1 -text "$caption(quickaudine,delayshutter)"
      pack $frm.delayshutter.lab1 -in $frm.delayshutter -anchor center -side left -padx 10 -pady 10

      entry $frm.delayshutter.entry -width 5 -textvariable ::quickaudine::widget(quickaudine,delayshutter) \
         -justify center
      pack $frm.delayshutter.entry -in $frm.delayshutter -anchor center -side left -pady 10

      label $frm.delayshutter.lab2 -text "$caption(quickaudine,unite)"
      pack $frm.delayshutter.lab2 -in $frm.delayshutter -anchor center -side left -padx 2 -pady 10

   pack $frm.delayshutter -side top -fill x

   #--- j'affiche les labels et le scale pour la vitesse de lecture de chaque pixel
   frame $frm.speed -borderwidth 0 -relief raised

      label $frm.speed.lab3 -text "$caption(quickaudine,lecture_pixel)"
      pack $frm.speed.lab3 -in $frm.speed -anchor center -side left -padx 10 -pady 2

      scale $frm.speed.lecture_pixel_variant -from "1.0" -to "15.0" -length 300 \
         -orient horizontal -showvalue true -tickinterval 1 -resolution 1 \
         -borderwidth 2 -relief groove -variable ::quickaudine::widget(quickaudine,canspeed) -width 10
      pack $frm.speed.lecture_pixel_variant -in $frm.speed -anchor center -side left -pady 0

      label $frm.speed.lab4 -text "$caption(quickaudine,micro_sec)"
      pack $frm.speed.lab4 -in $frm.speed -anchor center -side left -padx 2 -pady 2

   pack $frm.speed -side top -fill x

   #--- j'affiche l'eventuel message d'erreur
   frame $frm.statusMessage -borderwidth 2 -relief ridge

      label $frm.statusMessage.statusMessage_lab -text "$caption(quickaudine,error)"
      pack $frm.statusMessage.statusMessage_lab -in $frm.statusMessage -side top -anchor nw -padx 5 -pady 2

      Label $frm.statusMessage.status -textvariable ::quickaudine::private(statusMessage) -height 8 \
         -wraplength 500 -justify left
      pack $frm.statusMessage.status -in $frm.statusMessage -side top -anchor nw -padx 20

   pack $frm.statusMessage -side top -fill both

   #--- je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des quickaudine disponibles
#
#   exemple :
#   getLinkLabels
#     { "quickaudine0" "quickaudine1" }
#------------------------------------------------------------
proc ::quickaudine::getLinkLabels { } {
   variable private

   #--- j'initialise une liste vide
   set labels [list]
   catch {
      foreach instance [link::available quickremote ] {
         lappend labels "$private(genericName)[lindex $instance 0]"
      }
   } catchError
   if { $catchError != "" } {
      set private(statusMessage) "$catchError\n\n$::caption(quickaudine,msg)"
   }

   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "quickaudine0"
#------------------------------------------------------------
proc ::quickaudine::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne )
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "quickaudine1"   retourne 1
#     exemple :  isValidLabel "XXX1"        retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::quickaudine::isValidLabel { linkLabel } {
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
proc ::quickaudine::initPlugin { } {
   variable private

   #--- Initialisation
   set private(frm) ""

   #--- je fixe le nom generique de la liaison
   set private(genericName)   "quickaudine"
   set private(statusMessage) ""

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
proc ::quickaudine::initConf { } {
   global conf

   if { ! [ info exists conf(quickaudine,delayshutter) ] } { set conf(quickaudine,delayshutter) "0" }
   if { ! [ info exists conf(quickaudine,canspeed) ] }     { set conf(quickaudine,canspeed)     "2" }

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::quickaudine::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::refreshAvailableList { } {
   variable private

   #--- je verifie que la liste existe
   if { [ winfo exists $private(frm).available.list ] == "0" } {
      return
   }

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   set selectedLinkLabel [getSelectedLinkLabel]

   #--- j'efface le contenu de la liste
   $private(frm).available.list delete 0 [ $private(frm).available.list size]

   #--- je recupere les linkNo ouverts
   set linkNoList [link::list]

   #--- je remplis la liste
   foreach linkLabel [getLinkLabels] {
      set linkText ""
      #--- je recherche si ce link est ouvert
      foreach linkNo $linkNoList {
         if { $linkLabel == [link$linkNo name] } {
            #--- si le link est ouvert, j'affiche son label, linkNo et les utilisations
            set linkText "$linkLabel link$linkNo [link$linkNo use get]"
         }
      }
      #--- si le link est ferme, j'affiche son label seulement
      if { $linkText == "" } {
         set linkText "$linkLabel"
      }
      $private(frm).available.list insert end $linkText
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::selectConfigLink { linkLabel } {
   variable private

   #--- je verifie que la liste existe
   if { [ winfo exists $private(frm).available.list ] == "0" } {
      return
   }

   $private(frm).available.list selection clear 0 end

   #--- je recherche linkLabel dans la listbox  (linkLabel est le premier element de chaque ligne)
   for {set i 0} {$i<[$private(frm).available.list size]} {incr i} {
      if { [lindex [$private(frm).available.list get $i] 0] == $linkLabel } {
         $private(frm).available.list selection set $i
         return
      }
   }
   if { [$private(frm).available.list size] > 0 } {
      #--- sinon je selectionne le premier linkLabel
      $private(frm).available.list selection set 0
   }
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::quickaudine::widgetToConf { } {
   variable widget
   global conf

   set conf(quickaudine,delayshutter) $widget(quickaudine,delayshutter)
   set conf(quickaudine,canspeed)     $widget(quickaudine,canspeed)
}


#
# Fichier : quickremote.tcl
# Description : Interface de liaison QuickRemote
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: quickremote.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::quickremote {
   package provide quickremote 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] quickremote.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::quickremote::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libquickremote.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::quickremote::getPluginType]] "quickremote" "libquickremote.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(quickremote,installNewVersion) $sourceFileName [package version quickremote] ]
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
proc ::quickremote::configurePlugin { } {
   global audace

   #--- rien a faire
   #--- car la liaison est configuree par le peripherique qui l'utilise

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::confToWidget { } {
   variable widget
   global conf

}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#     retourne le numero du link
#       le numero du link est attribue automatiquement
#       si ce link est deja cree, on retourne le numero du link existant
#
#   exemple :
#   ::quickremote::create "quickremote1" "cam1" "acquisition" "bit 1"
#     1
#   ::quickremote::create "quickremote2" "cam1" "longuepose" "bit 1"
#     2
#   ::quickremote::create "quickremote2" "cam2" "longuepose" "bit 2"
#     2
#------------------------------------------------------------
proc ::quickremote::createPluginInstance { linkLabel deviceId usage comment args } {
   global audace

   #--- je cree le lien
   set linkno [::link::create quickremote $linkLabel]
   #--- j'ajoute l'utilisation
   link$linkno use add $deviceId $usage $comment
   #--- je rafraichis la liste
   ::quickremote::refreshAvailableList
   #--- je selectionne le link
   ::quickremote::selectConfigLink $linkLabel
   #---
   return $linkno
}

#------------------------------------------------------------
#  deletePluginInstance
#     Supprime une utilisation d'une liaison
#     et supprime la liaison si elle n'est plus utilises par aucun autre peripherique
#     Ne fait rien si la liaison n'est pas ouverte
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::deletePluginInstance { linkLabel deviceId usage } {
   global audace

   set linkno [::confLink::getLinkNo $linkLabel]
   if { $linkno != "" } {
      link$linkno use remove $deviceId $usage
      if { [link$linkno use get] == "" } {
         #--- je supprime la liaison si elle n'est plus utilisee par aucun peripherique
         ::link::delete $linkno
      }
      #--- je rafraichis la liste
      ::quickremote::refreshAvailableList
   }
}

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::quickremote::getPluginProperty { propertyName } {
   switch $propertyName {
      bitList {
         return [list 0 1 2 3 4 5 6 7]
      }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::quickremote::getPluginTitle { } {
   global caption

   return "$caption(quickremote,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::quickremote::getPluginHelp { } {
   return "quickremote.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::quickremote::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::quickremote::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::fillConfigPage { frm } {
   variable private
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- j'affiche la liste des links et le bouton pour rafraichir cette liste
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(quickremote,available)

      listbox $frm.available.list -height 3
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true

      Button $frm.available.refresh -highlightthickness 0 -padx 3 -pady 3 -state normal \
         -text "$caption(quickremote,refresh)" -command { ::quickremote::refreshAvailableList }
      pack $frm.available.refresh -in [$frm.available getframe] -side left

   pack $frm.available -side top -fill both -expand true

   #--- j'affiche l'eventuel message d'erreur
   frame $frm.statusMessage -borderwidth 2 -relief ridge

      label $frm.statusMessage.statusMessage_lab -text "$caption(quickremote,error)"
      pack $frm.statusMessage.statusMessage_lab -in $frm.statusMessage -side top -anchor nw -padx 5 -pady 2

      Label $frm.statusMessage.status -textvariable ::quickremote::private(statusMessage) -height 8 \
         -wraplength 500 -justify left
      pack $frm.statusMessage.status -in $frm.statusMessage -side top -anchor nw -padx 20

   pack $frm.statusMessage -side top -fill x

   #--- je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des quickremote disponibles
#
#   exemple :
#   getLinkLabels
#     { "quickremote0" "quickremote1" }
#------------------------------------------------------------
proc ::quickremote::getLinkLabels { } {
   variable private

   #--- j'initialise une liste vide
   set labels [list]
   catch {
      foreach instance [link::available quickremote ] {
         lappend labels "$private(genericName)[lindex $instance 0]"
      }
   } catchError
   if { $catchError != "" } {
      set private(statusMessage) "$catchError\n\n$::caption(quickremote,msg)"
   }

   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "quickremote0"
#------------------------------------------------------------
proc ::quickremote::getSelectedLinkLabel { } {
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
#     exemple :  isValidLabel "quickremote1"   retourne 1
#     exemple :  isValidLabel "XXX1"        retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::quickremote::isValidLabel { linkLabel } {
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
proc ::quickremote::initPlugin { } {
   variable private

   #--- Initialisation
   set private(frm) ""

   #--- je fixe le nom generique de la liaison
   set private(genericName)   "quickremote"
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
proc ::quickremote::initConf { } {
   global conf

   return
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 0 (ready), 1 (not ready)
#------------------------------------------------------------
proc ::quickremote::isReady { } {
   return 0
}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::quickremote::refreshAvailableList { } {
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
proc ::quickremote::selectConfigLink { linkLabel } {
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
proc ::quickremote::widgetToConf { } {
   variable widget
   global conf

}


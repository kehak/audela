#
# Fichier : serialport.tcl
# Description : Interface de liaison Port Serie
# Auteurs : Robert DELMAS et Michel PUJOL
# Mise à jour $Id: serialport.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::serialport {
   package provide serialport 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] serialport.cap ]
}

#------------------------------------------------------------
#  install (utilisé par le plugin UpdatAudela)
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::serialport::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace libserialport.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::serialport::getPluginType]] "serialport" "libserialport.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(serialport,installNewVersion) $sourceFileName [package version serialport] ]
   }
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::serialport::getPluginProperty { propertyName } {
   switch $propertyName {
      bitList {
         return [list DTR RTS]
      }
   }
}

#------------------------------------------------------------
#  getPluginTitle
#     retourne le label du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::serialport::getPluginTitle { } {
   global caption

   return "$caption(serialport,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::serialport::getPluginHelp { } {
   return "serialport.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::serialport::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::serialport::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initPlugin  (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#
#  return namespace
#------------------------------------------------------------
proc ::serialport::initPlugin { } {
   variable private

   #--- Je charge les variables d'environnement
   initConf

   #--- Initialisation
   set private(frm) ""

   #--- je fixe le nom generique de la liaison
   if {  $::tcl_platform(os) == "Linux" } {
      set private(genericNameList) "/dev/tty /dev/ttyS /dev/ttyUSB /dev/ttyAMA"
   } else {
      set private(genericNameList) "//./COM"
   }

   #--- J'initialise les variables widget(..)
   confToWidget
}

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return rien
#------------------------------------------------------------
proc ::serialport::configurePlugin { } {
   global audace

   #--- Affiche la liaison
  ### serialport::run "$audace(base).serialport"

   return
}

#------------------------------------------------------------
#  confToWidget
#     copie les parametres du tableau conf() dans les variables des widgets
#
#  return rien
#------------------------------------------------------------
proc ::serialport::confToWidget { } {
   variable widget
   global conf

   set widget(serial,port_exclus) "$conf(serial,port_exclus)"
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return rien
#------------------------------------------------------------
proc ::serialport::createPluginInstance { linkLabel deviceId usage comment args } {
   variable private

   #--- je cree le lien
   set linkNo [::link::create serialport $linkLabel $args ]
   #--- j'ajoute l'utilisation
   link$linkNo use add $deviceId $usage $comment
   #--- je rafraichis la liste
   ::serialport::refreshAvailableList
   #--- je selectionne le link
   ::serialport::selectConfigLink $linkLabel
   #---
   return $linkNo
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::serialport::deletePluginInstance { linkLabel deviceId usage } {
   variable private

   #--- pour l'instant, la liaison est arretee par le pilote du peripherique
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
   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return rien
#------------------------------------------------------------
proc ::serialport::fillConfigPage { frm } {
   variable private
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- J'affiche la liste des links exclus
   frame $frm.port_exclus -borderwidth 0 -relief ridge

      label $frm.port_exclus_lab -text "$caption(serialport,port_exclus)"
      pack $frm.port_exclus_lab -in $frm.port_exclus -side left -padx 5 -pady 5

      entry $frm.port_exclus_ent -textvariable serialport::widget(serial,port_exclus) -width 25
      pack $frm.port_exclus_ent -in $frm.port_exclus -side left

   pack $frm.port_exclus -side top -fill x

   #--- J'affiche la liste des links disponibles et utilises
   TitleFrame $frm.available -borderwidth 2 -relief ridge -text $caption(serialport,available)

      listbox $frm.available.list
      pack $frm.available.list -in [$frm.available getframe] -side left -fill both -expand true

   pack $frm.available -side left -fill both -expand true

   #--- J'affiche le bouton de rafraichissement de la liste des links
   Button $frm.refresh -highlightthickness 0 -padx 10 -pady 3 -state normal \
      -text "$caption(serialport,refresh)" -command { ::serialport::refreshAvailableList }
   pack $frm.refresh -side left

   #--- Je mets a jour la liste
   refreshAvailableList

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  initConf
#     initialise les parametres dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::serialport::initConf { } {
   global conf

   if { ! [ info exists conf(serial,port_exclus) ] } { set conf(serial,port_exclus) "" }

   return
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des ports series disponibles
#
#   exemple :
#   getLinkLabels
#     { "COM1" "COM2" }
#------------------------------------------------------------
proc ::serialport::getLinkLabels { } {
   variable private

   set labels [list]

   if { $::tcl_platform(os) == "Linux" } {
      #--- je recherche les ports disponibles
      foreach port [ ::serialport::getPorts ] {
         lappend labels "$port"
      }
   } else {
      foreach port [ ::serialport::getPorts ] {
         lappend labels "$port"
      }
   }
   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "COM1"
#------------------------------------------------------------
proc ::serialport::getSelectedLinkLabel { } {
   variable private

   #--- je memorise le linkLabel selectionne
   set i [$private(frm).available.list curselection]
   if { $i == "" } {
      set i 0
   }
   #--- je retourne le label du link (premier mot de la ligne)
   return [lindex [$private(frm).available.list get $i] 0]
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "COM1:"   retourne 1
#     exemple :  isValidLabel "XXX1:"   retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::serialport::isValidLabel { linkLabel } {
   variable private

   #--- je cherche si linkLabel commence par l'un des noms generiques
   foreach genericName $private(genericNameList) {
      if { [string first $genericName $linkLabel ] == 0 } {
         #--- linkLabel commence par
         return 1
      }
   }
   #---
   return 0

}

#------------------------------------------------------------
#  refreshAvailableList
#     rafraichit la liste des link disponibles
#
#  return rien
#------------------------------------------------------------
proc ::serialport::refreshAvailableList { } {
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

   #--- j'efface le contenu de la liste des ports disponibles
   $private(frm).available.list delete 0 [ $private(frm).available.list size]
   widgetToConf

   set linkList [list ]
   set linkLabelList [list ]
   #--- j'affiche les ports series deja ouverts
   foreach { linkNo } [ ::link::list ] {
      if { [ link$linkNo drivername ] == "serialport" } {
         set linklabel [link$linkNo name]
         set usage     [ link$linkNo use get ]
         set linkText  "$linklabel $usage"
         #--- je renseigne la liste les ports deja utilises
         lappend linkList $linkText
         lappend linkLabelList $linklabel
      }
   }

   #--- je recherche les ports disponibles non utilises
   searchPorts
   #--- j'ajoute les ports disponibles non utilises
   foreach linkLabel [::serialport::getLinkLabels] {
      if { [lsearch $linkLabelList $linkLabel] == -1 } {
         lappend linkList $linkLabel
      }
   }

   #--- j'affiche la liste triee
   foreach linkLabel [lsort $linkList] {
      $private(frm).available.list insert end $linkLabel
   }

   #--- je selectionne le linkLabel comme avant le rafraichissement
   selectConfigLink $selectedLinkLabel

   return
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::serialport::selectConfigLink { linkLabel } {
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
proc ::serialport::widgetToConf { } {
   variable widget
   global conf

   set conf(serial,port_exclus) $widget(serial,port_exclus)
}

#------------------------------------------------------------
#  searchPorts
#     recherche les ports com disponible sur le PC
#
#  return rien
#------------------------------------------------------------
proc ::serialport::searchPorts { } {
   variable private
   global conf

   #--- Recherche le ou les ports COM exclus
   set kd ""
   set port_exclus $conf(serial,port_exclus)
   set nbr_port_exclus [ llength $port_exclus ]
   if { $nbr_port_exclus == "1" } {
      set kd [string index $port_exclus [expr [string length $port_exclus]-1]]
   } else {
      for { set i 0 } { $i < $nbr_port_exclus } { incr i } {
         set a [ lindex $port_exclus $i ]
         set kdd [string index $a [expr [string length $a]-1]]
         lappend kd $kdd
         set kd [ lsort $kd ]
      }
   }

   #--- Suivant l'OS
   if { $::tcl_platform(os) == "Linux" } {
      set port_com     "/dev/ttyS"
      set port_com_usb "/dev/ttyUSB"
      set port_com_ama "/dev/ttyAMA"
      set kk  "0"
      set kkt "20"
   } else {
      set port_com "//./COM"
      set kk  "1"
      set kkt "20"
   }

   #--- Recherche des ports com
   set comlist            ""
   set comlist_usb        ""
   set comlist_ama        ""
   set private(portsList) ""

   set i "0"
   for { set k $kk } { $k < $kkt } { incr k } {
      if { $k != "[ lindex $kd $i]" } {
         set errnum [ catch { open $port_com$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist $k
            close $msg
         }
      } else {
         incr i
      }
   }
   set long_com [ llength $comlist ]

   for { set k 0 } { $k < $long_com } { incr k } {
      lappend private(portsList) "$port_com[ lindex $comlist $k ]"
   }

   if { $::tcl_platform(os) == "Linux" } {

      for { set k $kk } { $k < 20 } { incr k } {
         set errnum [ catch { open $port_com_usb$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist_usb $k
            close $msg
         }
      }
      set long_com_usb [ llength $comlist_usb ]
      for { set k 0 } { $k < $long_com_usb } { incr k } {
         lappend private(portsList) "$port_com_usb[ lindex $comlist_usb $k ]"
      }

      for { set k $kk } { $k < 5 } { incr k } {
         set errnum [ catch { open $port_com_ama$k r+ } msg ]
         if { $errnum == "0" } {
            lappend comlist_ama $k
            close $msg
         }
      }
      set long_com_ama [ llength $comlist_ama ]
      for { set k 0 } { $k < $long_com_ama } { incr k } {
         lappend private(portsList) "$port_com_ama[ lindex $comlist_ama $k ]"
      }

   }
}

#------------------------------------------------------------
#  searchPortsThread
#     recherche les ports com disponibles sur le PC, executee
#     dans un thread different du thread principal
#
#  return rien
#------------------------------------------------------------
proc ::serialport::searchPortsThread { } {
   variable private

   set catchResult [ catch {
      #--- Creation d'un thread
      set threadNo [thread::create]
      #--- Preparation du nom du fichier a charger dans le thread
      set sourceFileName [file join $::audace(rep_gui) [file join $::audace(rep_plugin) link serialport searchport.tcl]]
      #--- Chargement du code TCL du fichier dans le thread
      ::thread::send $threadNo [list uplevel #0 source \"$sourceFileName\"]
      #--- Lancement de l'execution du code TCL en differe
      ::thread::send -async $threadNo "::searchPorts [thread::id] $::conf(serial,port_exclus)"
   } ]

   if { $catchResult == 1 } {
      bell
      ::tkutil::displayErrorInfo $::caption(serialport,titre)
      return
   }
}

#------------------------------------------------------------
#  getPorts
#     retourne la liste des ports COM disponibles
#
#  return rien
#------------------------------------------------------------
proc ::serialport::getPorts { } {
   variable private

   if { [ info exists private(portsList) ] == "0" } {
      ::serialport::searchPorts
   }

   return $private(portsList)
}


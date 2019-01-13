#
## @file joystick.tcl
#  @brief Interface pour joystick
#  @author Fred Vachier
#  @namespace joystick
#  @brief Interface pour joystick

#  $Id: joystick.tcl 13980 2016-06-11 07:25:34Z rzachantke $
#

namespace eval ::joystick {
   package provide joystick 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] joystick.cap ]

   #TODO
   # il faut surement remonter le source plus haut dans Audela
   #source "$::audace(rep_install)/gui/audace/joystick_tools.tcl"

}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  brief   retourne le titre du plugin dans la langue de l'utilisateur
#  return  titre du plugin
#
proc ::joystick::getPluginTitle { } {
   global caption

   return "$caption(joystick,titre)"
}

#------------------------------------------------------------
## @brief retourne l'indicateur de lancement au démarrage de Audela
#  @return
#  - 1 (lancé au démarrage)
#  - 0 (pas lancé)
#
proc ::joystick::getStartFlag { } {
   return $::conf(joystick,start)
}

#------------------------------------------------------------
#  brief    retourne le nom du fichier d'aide principal
#  return  nom du fichier d'aide principal
#
proc ::joystick::getPluginHelp { } {
   return "joystick.htm"
}

#------------------------------------------------------------
#  brief    retourne le type de plugin
#  return   type de plugin
#
proc ::joystick::getPluginType { } {
   return "equipment"
}

#------------------------------------------------------------
#  brief    retourne le nom du répertoire du plugin
#  return   nom du répertoire du plugin : "joystick"
#
proc ::joystick::getPluginDirectory { } {
   return "joystick"
}

#------------------------------------------------------------
## @brief   retourne le ou les OS de fonctionnement du plugin
#  @return  liste des OS : "Windows Linux"
#
proc ::joystick::getPluginOS { } {
   return [ list Linux]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#  @details  cet outil s'ouvre dans un onglet du menu Equipements
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::joystick::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
      bitList  { return [list 0 1 2 3 4 5 6 7] }
      defaultr { return "" }
   }
}

#------------------------------------------------------------
## @brief initialise le plugin  (
#  @details est lancé automatiquement au chargement de ce fichier tcl
#
proc ::joystick::initPlugin { } {
   variable private

   #--- Je charge les variables d'environnement
   if { ! [ info exists ::conf(joystick,serialPort) ] }  { set ::conf(joystick,serialPort)  COM1 }
   if { ! [ info exists ::conf(joystick,cardAddress) ] } { set ::conf(joystick,cardAddress) 1 }
   if { ! [ info exists ::conf(joystick,start) ] }       { set ::conf(joystick,start)       0 }

   #--- j'initialise les variables privees
   set private(frm) ""
   for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
      set private(bit,$bitNo) "OFF"
   }
   set private(portHandle)     ""
   set private(linkNo)         0
   set private(genericName)    "joystick"
   set private(newCardAddress) $::conf(joystick,cardAddress)
}

#------------------------------------------------------------
## @brief   informe de l'état de fonctionnement du plugin
#  @return
#  - 1 (ready)
#  - 0 (not ready)
#
proc ::joystick::isReady { } {
   variable private

   if { $private(linkNo) == 0 } {
      return 0
   } else {
      return 1
   }
}

#------------------------------------------------------------
#  brief configure le plugin
#
proc ::joystick::configurePlugin { } {
   variable private

   if { [isReady] == 1 } {
      #--- je supprime la liaison si elle existe deja
      ::joystick::stopPlugin
   }
   set linkLabel "$private(genericName)-$::conf(joystick,serialPort)"
   #--- je cree la liaison
   ::confLink::create $linkLabel "link" $private(genericName) ""
}

#------------------------------------------------------------
# brief arrête la liaison du plugin
#
proc ::joystick::stopPlugin { } {
   variable private

   set linkLabel "$private(genericName)-$::conf(joystick,serialPort)"
   ::confLink::delete $linkLabel "link" $private(genericName)
}

#------------------------------------------------------------
#  createPlugin
#     demarre la liaison
#
#  return
#     numero du link
#------------------------------------------------------------
proc ::joystick::createPlugin { linkLabel deviceId usage comment args } {
   variable private

   #---
   set linkNo 0

   #-- j'ouvre le port serie
   set catchResult [catch {
      set private(portHandle) [open $::conf(joystick,serialPort) r+]
      #-- je configure la vitesse
      fconfigure $private(portHandle) -mode "2400,n,8,1" -buffering none -blocking 0 -translation binary
      #--- j'ajoute l'utilisation du port serie ( avec l'option -noopen car le port est déjà ouvert par la commande TCl precedente
      ::serialport::createPluginInstance $::conf(joystick,serialPort) $linkLabel "command" "" "-noopen"

      #--- je cree le lien ::link$linkno  (simule la presence de la librairie dynamique)
      set linkNo [::joystick::simulLibraryCreateLink joystick $linkLabel ]
      #--- je rafraichis la liste
      ###::joystick::refreshAvailableList

   } ]

   #--- je traite l'erreur
   if { $catchResult != 0 } {
      ::console::affiche_erreur "::joystick::createPlugin \n $::errorInfo\n"
      if { $linkNo != 0 } {
         catch { ::joystick::deletePlugin $linkLabel $deviceId $usage }
         set linkNo 0
      }
      if { $private(portHandle) != "" } {
         #--- je referme le port
         close $private(portHandle)
         set private(portHandle) ""
      }
   }
   set private(linkNo) $linkNo

   #--- Je configure les boutons de test
   configureConfigPage

   return $linkNo
}

#------------------------------------------------------------
## @brief arête la liaison et libère les ressources occupées
#
proc ::joystick::deletePlugin { linkLabel deviceId usage } {
   variable private

   #--- je ferme le port serie
   if { $private(portHandle) != "" } {
      close $private(portHandle)
      set private(portHandle) ""
   }

   #--- je supprime l'utilisation du port serie
   ::serialport::deletePluginInstance $::conf(joystick,serialPort) $linkLabel "command"

   #--- je supprime le lien ::link$linkno  (simule la presence de la librairie dynamique)
   if { $private(linkNo) != 0 } {
      ::link$private(linkNo) close
   }
   set private(linkNo) 0

   #--- je supprime le commentaire d'utilisation de joystick
   if { [info exists private(serialLink,$linkLabel,$deviceId,$usage)] } {
      unset private(serialLink,$linkLabel,$deviceId,$usage)
   }

   #--- Je configure les boutons de test
   configureConfigPage
}

#------------------------------------------------------------
# TODO
# en attendant les ameliorations on ecrit la liste en dur
proc ::joystick::getPorts {  } {
   return { "/dev/input/js0" }
}

#------------------------------------------------------------
#  brief créé l'interface graphique
#  param frm chemin Tk de la fenêtre
#
#
proc ::joystick::fillConfigPage { frm } {
   variable private
   variable widget
   global caption conf

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   set widget(serialPort) $::conf(joystick,serialPort)

   #--- je recupere la liste des ports disponibles

#TODO
#   set linkList [::confLink::getLinkLabels { "serialport" } ]
   set linkList [::joystick::getPorts]

   #--- Je verifie le contenu de la liste
   if { [ llength $linkList ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [ lsearch -exact $linkList $widget(serialPort) ] == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(serialPort) [ lindex $linkList 0 ]
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }

   set linkLabel [::joystick::getSelectedLinkLabel]

   #--- J'affiche la liste des links exclus
   frame $frm.port -borderwidth 0 -relief ridge
   pack $frm.port -side top -fill x

      label $frm.port.lab1 -text "$caption(joystick,Port)"
      pack $frm.port.lab1  -side left -padx 5 -pady 5

      #--- Choix du port ou de la liaison
      ComboBox $frm.port.list \
         -height [ llength $linkList ] \
         -relief sunken    \
         -width 14 \
         -borderwidth 1    \
         -textvariable ::joystick::widget(serialPort) \
         -editable 0       \
         -values $linkList
      pack $frm.port.list  -anchor c -side left -padx 10 -pady 10

      #--- Bouton de configuration des ports et liaisons
      button $frm.port.refresh -text $::caption(joystick,refresh) -relief raised \
         -command "::joystick::refreshSerialPortList"
      pack $frm.port.refresh -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      label $frm.port.lab2 -text "$caption(joystick,connexion)"
      pack $frm.port.lab2  -side left -padx 5 -pady 5

      #--- Bouton de configuration des ports et liaisons
      button $frm.port.open -text $::caption(joystick,open) -relief raised \
         -command "::joystick::open"
      pack $frm.port.open -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Bouton de configuration des ports et liaisons
      button $frm.port.event -text $::caption(joystick,close) -relief raised \
         -command "::joystick::close"
      pack $frm.port.event -anchor n -side left -pady 10 -ipadx 10 -ipady 1 -expand 0

   frame $frm.img -borderwidth 0 -cursor arrow -relief groove
   pack $frm.img -in $frm -anchor s -side top -expand yes -fill both  -padx 10 -pady 5
   image create photo .pad -format png -file [ file join $::audace(rep_plugin) equipment joystick joystick.png]

      set width 500
      set height 310

      set ::joystick::canva [canvas $frm.img.chart -width $width -height $height -bd 0 -relief groove]
      pack $::joystick::canva -side top -anchor c
      $::joystick::canva create image [expr $width/2] [expr $height/2] -image .pad


   #--- Frame du bouton Arreter et du checkbutton creer au demarrage
   frame $frm.start -borderwidth 0 -relief flat

      #--- Bouton Arreter
     button $frm.start.stop -text "$caption(joystick,arreter)" -relief raised \
         -command "::joystick::deletePlugin $linkLabel $deviceId $usage"
      pack $frm.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

      #--- Checkbutton demarrage automatique
      checkbutton $frm.start.chk -text "$caption(joystick,creer_au_demarrage)" \
         -highlightthickness 0 -variable ::conf(joystick,start)
      pack $frm.start.chk -side top -padx 3 -pady 3 -fill x

   pack $frm.start -side bottom -fill x


      # Pratique pour determiner la position des points rouges
      # bind $::joystick::canva <ButtonPress-1> {::joystick::bPress1 %W %x %y}

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   configureConfigPage
}

proc ::joystick::bPress1 {w x y} {
   ::console::affiche "set x $x ; set y $y\n"
 }

proc ::joystick::open { } {
   variable widget

   :console::affiche "Port : $widget(serialPort)\n"
   joystick_open $widget(serialPort)
   ::joystick::eventloop
}

proc ::joystick::close { } {
   joystick_close
}

 proc ::joystick::eventloop { } {
   global x
   global audace

   fileevent $audace(joystick,channel) readable [list ::joystick::event $audace(joystick,channel)]
   vwait x; joystick_close
}

proc ::joystick::event { s } {
   global x
   global audace

   set l [gets $s]

   if {[eof $s]} {
      close $s
      set x done
   } else {
      #::console::affiche_resultat "press : [joystick_getall]\n"
      ::joystick::view_all [joystick_getall]
   }
}

proc ::joystick::view_all { lst } {
   $::joystick::canva  delete -tag "press"
   foreach but $lst {
      set type [lindex $but 0]
      set num  [lindex $but 1]
      set action  [lindex $but 2]
      if {$action !=0 } {
         ::joystick::view $type $num $action
      }
   }
}

proc ::joystick::view { type but action } {
   set x 0 ; set y 0

   switch $type {
      "button" {
         switch $but {
            "0"   { set x 398 ; set y  79 }
            "1"   { set x 435 ; set y 114 }
            "2"   { set x 398 ; set y 152 }
            "3"   { set x 361 ; set y 114 }
            "5"   { set x 397 ; set y  21 }
            "4"   { set x 100 ; set y  21 }
            "7"   { set x 432 ; set y  21 }
            "6"   { set x  67 ; set y  21 }
         }
      }
      "axis" {
         if {$but=="0"} {
            if {$action < 0} {
               set x 140 ; set y 192 ; # 4
            }
            if {$action > 0} {
               set x 212 ; set y 192 ; # 2
            }
         }
         if {$but=="1"} {
            if {$action < 0} {
               set x 176 ; set y 156 ; # 1
            }
            if {$action > 0} {
               set x 176 ; set y 228 ; # 3
            }
         }
         if {$but=="3"} {
            if {$action < 0} {
               set x 285 ; set y 190 ; # 4
            }
            if {$action > 0} {
               set x 357 ; set y 190 ; # 2
            }
         }
         if {$but=="4"} {
            if {$action < 0} {
               set x 322 ; set y 155 ; # 1
            }
            if {$action > 0} {
               set x 322 ; set y 227 ; # 3
            }
         }
         if {$but=="5"} {
            if {$action < 0} {
               set x 74 ; set y 113 ; # 4
            }
            if {$action > 0} {
               set x 127 ; set y 113 ; # 2
            }
         }
         if {$but=="6"} {
            if {$action < 0} {
               set x 101 ; set y 87 ; # 1
            }
            if {$action > 0} {
               set x 101 ; set y 141 ; # 3
            }
         }
      }
   }

   if {$x==0||$y==0} {return}
   set r 10
   $::joystick::canva create oval [expr int($x-$r)] [expr int($y-$r)] \
                 [expr int($x+$r)] [expr int($y+$r)] -fill red -tag "press" -width 1

   update
}

#------------------------------------------------------------
#  brief autorise/interdit les boutons de test
#
proc ::joystick::configureConfigPage { } {
   variable private

   if { $private(frm) != "" && [winfo exists $private(frm)] } {
      if {  [ ::joystick::isReady ] == 1 } {
         #--- j'active les boutons de test
         #$private(frm).port.stop configure -state normal
         #$private(frm).card.changeCardAddress configure -state normal
         #$private(frm).card.newAddress configure -state normal
      } else {
         #$private(frm).port.stop configure -state disabled
         #$private(frm).card.changeCardAddress configure -state disabled
         #$private(frm).card.newAddress configure -state disabled
      }
   }
}

#------------------------------------------------------------
#  brief rafraîchit la liste des port série
#
proc ::joystick::refreshSerialPortList { } {
   variable private
   variable widget

   #--- on force le rafraississement des ports series
   ::serialport::searchPorts

   #--- je recupere la liste des ports serie disponibles

#TODO
   set linkList [ ::serialport::getPorts ]
   #set linkList [ ::joystick::getPorts ]

   #--- je copie la liste dans la combobox
   $private(frm).port.list configure -values $linkList -height [llength $linkList]
   #--- Je verifie le contenu de la liste
   if { [ llength $linkList ] > 0 } {
      #--- Si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      set index [ lsearch -exact $linkList $widget(serialPort) ]
      if { $index == -1 } {
         #--- Si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(serialPort) [ lindex $linkList 0 ]
      } else {
         #--- je selectionne la valeur
         $private(frm).port.list setvalue  "@$index"
      }
   } else {
      #--- Si la liste est vide, on continue quand meme
   }
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#------------------------------------------------------------
proc ::joystick::getSelectedLinkLabel { } {
   variable private

   #--- je retourne le label du link
   return "$private(genericName)-$::conf(joystick,serialPort)"
}

#------------------------------------------------------------
## @brief indique si linkLabel est un nom de link valide
#  @code exemples :
#  isValidLabel "K8056-COM1"   retourne 1
#  isValidLabel "XXX1"         retourne 0
#  @endcode
#  @param     linkLabel nom du link
#  @return
#  - 1 (valid)
#  - 0 (not valid)
#
proc ::joystick::isValidLabel { linkLabel } {
   variable private

   if { [string first $private(genericName) $linkLabel ] == 0 } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  brief copie les variables des widgets dans le tableau conf()
#
proc ::joystick::widgetToConf { } {
   variable widget
   variable private

   if { [isReady] == 1 } {
      #--- je supprime la liaison si elle existe deja
      ::joystick::stopPlugin
   }
   set ::conf(joystick,serialPort) $widget(serialPort)

   for { set bitNo 1 } { $bitNo <= 8 } {incr bitNo } {
      set private(bit,$bitNo) $widget(bit,$bitNo)
   }
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::joystick::selectConfigLink { linkLabel } {
   variable private

   #-- rien a faire car pour l'instant
}

#------------------------------------------------------------
#  simulCreateLink
#     cree une liaison purement TCL (sans libriairie dynamique)
#     cette procedure simule la librairie dynamique.
#  return rien
#------------------------------------------------------------
proc ::joystick::simulLibraryCreateLink { libraryName linkLabel } {
   #--- je recherche le premier linkNo disponible
   set linkNo 1
   while { [info command ::link$linkNo ] == "::link$linkNo"  } {
      incr linkNo
   }

   set dollar "$"
   set command ""
   append command "proc ::link$linkNo { arg0 { arg1 \"\" } { arg2 \"\" } { arg3 \"\" }} {\n"
   append command "   switch ${dollar}arg0 {\n"
   append command "   drivername { return $libraryName }\n"
   append command "   close { rename ::link$linkNo \"\" \n" }
   append command "   name { return $linkLabel } \n"
   append command "   use  { ::confLink::simulLibraryUseLink $libraryName $linkNo ${dollar}arg1 ${dollar}arg2 ${dollar}arg3 } \n"
   append command "   char { ::${libraryName}::setChar ${dollar}arg1  } \n"
   append command "   bit  { ::${libraryName}::setBit  ${dollar}arg1 ${dollar}arg2  } \n"
   append command "   default  { error \"link$linkNo choose sub-command among  drivername close use char bit \" } \n"
   append command "   }\n"
   append command "}\n"

   eval $command
   return $linkNo
}

#------------------------------------------------------------
#  simulUseLink
#     ajoute, retourne ou supprime l'usage d'une liaison purement TCL (sans librairie dynamique)
#
#  return
#------------------------------------------------------------
proc ::joystick::simulLibraryUseLink { libraryName linkNo args } {
   variable private

   switch $command1 {
      add {
         set deviceId [lindex $args 0]
         set usage    [lindex $args 1]
         set comment  [lindex $args 2]
         set private($libraryName,$linkNo,use) $args
      }
      get {
         if { [info exists private($libraryName,$linkNo,use)] } {
            return $private($libraryName,$linkNo,use)
         } else {
            return ""
         }
      }
      remove {
         if { [info exists private($libraryName,$linkNo,use)] } {
            unset private($libraryName,$linkNo,use)
         }
      }
      default {
         error "# Usage: link$linkNo use add|get|remove ?options?"
      }
   }
}


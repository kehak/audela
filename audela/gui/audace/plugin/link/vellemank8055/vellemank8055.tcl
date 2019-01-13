#
# Fichier : vellemank8055.tcl
# Description : Interface pour la carte Velleman K8055
# Auteurs : Michel PUJOL et Robert DELMAS
# Mise à jour $Id: vellemank8055.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::vellemank8055 {
   package provide vellemank8055 2.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] vellemank8055.cap ]
}

#------------------------------------------------------------
#  install
#     installe le plugin et la dll
#------------------------------------------------------------
proc ::vellemank8055::install { } {
   if { $::tcl_platform(platform) == "windows" } {
      #--- je deplace K8055D.dll dans le repertoire audela/bin
      set sourceFileName [file join $::audace(rep_plugin) [::audace::getPluginTypeDirectory [::vellemank8055::getPluginType]] "vellemank8055" "K8055D.dll"]
      if { [ file exists $sourceFileName ] } {
         ::audace::appendUpdateCommand "file rename -force {$sourceFileName} {$::audela_start_dir} \n"
      }
      #--- j'affiche le message de fin de mise a jour du plugin
      ::audace::appendUpdateMessage [ format $::caption(vellemank8055,installNewVersion) $sourceFileName [package version vellemank8055] ]
   }
}

#==============================================================
# Procedures generiques de configuration des plugins
#==============================================================

#------------------------------------------------------------
#  getPluginProperty
#     retourne la valeur de la propriete
#
# Parametre :
#    propertyName : Nom de la propriete
# Return : Valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::vellemank8055::getPluginProperty { propertyName } {
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
proc ::vellemank8055::getPluginTitle { } {
   global caption

   return "$caption(vellemank8055,titre)"
}

#------------------------------------------------------------
#  getPluginHelp
#     retourne la documentation du plugin
#
#  return "nom_plugin.htm"
#------------------------------------------------------------
proc ::vellemank8055::getPluginHelp { } {
   return "vellemank8055.htm"
}

#------------------------------------------------------------
#  getPluginType
#     retourne le type de plugin
#------------------------------------------------------------
proc ::vellemank8055::getPluginType { } {
   return "link"
}

#------------------------------------------------------------
#  getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::vellemank8055::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#
#  return namespace
#------------------------------------------------------------
proc ::vellemank8055::initPlugin { } {
   variable private
   global conf

   #--- J'initialise les variables privees
   set private(frm) ""
   for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
      set private(bitOutput,$bitNoOutput) "OFF"
   }
   set private(bitOutput,tous) "OFF"
   for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
      set private(bitInput,$bitNoInput) "0"
   }
   if { ! [ info exists conf(vellemank8055,SK5) ] } { set conf(vellemank8055,SK5) "1" }
   if { ! [ info exists conf(vellemank8055,SK6) ] } { set conf(vellemank8055,SK6) "1" }
   set private(portHandle)  ""
   set private(linkNo)      "0"
   set private(genericName) "K8055"
}

#------------------------------------------------------------
#  isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::vellemank8055::isReady { } {
   variable private

   if { $private(linkNo) == 0 } {
      return 0
   } else {
      return 1
   }
}

#------------------------------------------------------------
#  configurePlugin
#     configure le plugin
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::configurePlugin { } {
   variable private

   if { [isReady] == 1 } {
      #--- Je supprime la liaison si elle existe deja
      ::vellemank8055::stopPlugin
   }
   set linkLabel "$private(genericName)-USB"
   #--- Je cree la liaison K8055
   ::confLink::create $linkLabel "link" $private(genericName) ""

   return
}

#------------------------------------------------------------
#  stopPlugin
#     arrete le plugin
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::stopPlugin { } {
   variable private

   #--- J'initialise tous les boutons sur OFF et les bits de sortie a 0
   ::vellemank8055::initialiseBitsSortieOFF
   #--- J'arrete la liaison K8055
   set linkLabel "$private(genericName)-USB"
   ::confLink::delete $linkLabel "link" $private(genericName)
   #--- Je referme la connexion USB avec la carte
   ros_velleman close $private(numeroCarte)

   return
}

#------------------------------------------------------------
#  createPluginInstance
#     demarre la liaison
#
#  return
#     numero du link
#------------------------------------------------------------
proc ::vellemank8055::createPluginInstance { linkLabel deviceId usage comment args } {
   variable private
   global caption

   #--- Chargement de la librairie libros
   catch { load libros.dll }

   #--- J'initialise le numero de link
   set linkNo 0

   #-- J'ouvre la connexion USB avec la carte
   set catchResult [catch {
      ros_velleman open $private(numeroCarte)
      set private(portHandle) "USB"
      #--- Je cree le lien ::link$linkno (je simule la presence de la librairie dynamique)
      set linkNo [::vellemank8055::simulLibraryCreateLink vellemank8055 $linkLabel ]
   } ]

   #--- Je traite l'erreur
   if { $catchResult != 0 } {
      ::console::affiche_erreur "::vellemank8055::createPluginInstance \n $::errorInfo\n\n"
      tk_messageBox -title "$caption(vellemank8055,attention)" -icon error \
         -message "$caption(vellemank8055,cannotcreatelink)\n$caption(vellemank8055,seeconsole)"
      if { $linkNo != 0 } {
         ::vellemank8055::deletePluginInstance $linkLabel $deviceId $usage
         set linkNo 0
      }
      if { $private(portHandle) != "" } {
         #--- j'initialise tous les boutons sur OFF et les bits de sortie a 0
         ::vellemank8055::initialiseBitsSortieOFF
         #--- je referme la connexion USB avec la carte
         ros_velleman close $private(numeroCarte)
         set private(portHandle) ""
      }
   }
   set private(linkNo) $linkNo

   #--- Je configure les boutons de l'interface
   configureConfigPage

   return $linkNo
}

#------------------------------------------------------------
#  deletePluginInstance
#     arrete la liaison et libere les ressources occupees
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::deletePluginInstance { linkLabel deviceId usage } {
   variable private

   #--- Je ferme la connexion USB avec la carte
   if { $private(portHandle) != "" } {
      #--- J'initialise tous les boutons sur OFF et les bits de sortie a 0
      ::vellemank8055::initialiseBitsSortieOFF
      #--- Je ferme la connexion USB avec la carte
      ros_velleman close $private(numeroCarte)
      set private(portHandle) ""
   }

   #--- Je supprime le lien ::link$linkno (je simule la presence de la librairie dynamique)
   if { $private(linkNo) != 0 } {
      ::link$private(linkNo) close
   }
   set private(linkNo) 0

   #--- Je configure les boutons de l'interface
   configureConfigPage

   return
}

#------------------------------------------------------------
#  fillConfigPage
#     fenetre de configuration du plugin
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::fillConfigPage { frm } {
   variable private
   variable widget
   global caption conf

   #--- Je memorise la reference de la frame
   set private(frm) $frm

   #--- J'execute un changement de variable
   set widget(SK5) $conf(vellemank8055,SK5)
   set widget(SK6) $conf(vellemank8055,SK6)

   #--- Configuration du numero de la carte
   ::vellemank8055::numeroCarte

   for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
      set widget(bitOutput,$bitNoOutput) $private(bitOutput,$bitNoOutput)
   }
   set widget(bitOutput,tous) $private(bitOutput,tous)

   for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
      set widget(bitInput,$bitNoInput) $private(bitInput,$bitNoInput)
   }

   #--- J'affiche l'interface de test
   frame $frm.port -borderwidth 0 -relief ridge

      #--- Bouton arreter
      button $frm.port.stop -text "$caption(vellemank8055,stop)" -relief raised \
         -command "::vellemank8055::stopPlugin"
      pack $frm.port.stop -side right -pady 10 -ipadx 10 -ipady 1 -expand 0

      #--- Label du port
      label $frm.port.lab1 -text "$caption(vellemank8055,USBPort)"
      pack $frm.port.lab1 -side right -padx 5 -pady 5

      #--- Frame  de selection de la carte
      TitleFrame $frm.port.adresse -borderwidth 2 -relief ridge \
         -text "$caption(vellemank8055,selectAdresse)"

         checkbutton $frm.port.adresse.adresse1 -text "$caption(vellemank8055,SK5)" \
            -variable ::vellemank8055::widget(SK5) \
            -command "::vellemank8055::numeroCarte"
         grid $frm.port.adresse.adresse1 -in [$frm.port.adresse getframe] -row 0 -column 0

         checkbutton $frm.port.adresse.adresse2 -text "$caption(vellemank8055,SK6)" \
            -variable ::vellemank8055::widget(SK6) \
            -command "::vellemank8055::numeroCarte"
         grid $frm.port.adresse.adresse2 -in [$frm.port.adresse getframe] -row 0 -column 1

         label $frm.port.adresse.lab2 -text "      $caption(vellemank8055,adresse)"
         grid $frm.port.adresse.lab2 -in [$frm.port.adresse getframe] -row 0 -column 2

         label $frm.port.adresse.lab3 -textvariable ::vellemank8055::widget(numeroCarte)
         grid $frm.port.adresse.lab3 -in [$frm.port.adresse getframe] -row 0 -column 3

      pack $frm.port.adresse -side top -anchor w -fill none -pady 5

   pack $frm.port -side top -fill x

   #--- J'affiche les boutons de test des 8 bits de sortie
   TitleFrame $frm.test -borderwidth 2 -relief ridge -text "$caption(vellemank8055,test8sorties)"

      #--- J'affiche les boutons des 8 bits de sortie
      for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
         label $frm.test.lab$bitNoOutput -text $bitNoOutput
         grid $frm.test.lab$bitNoOutput -in [$frm.test getframe] -row 0 -column $bitNoOutput
         checkbutton $frm.test.bit$bitNoOutput -text $widget(bitOutput,$bitNoOutput) -indicatoron false \
            -offvalue "OFF" -onvalue "ON" \
            -variable ::vellemank8055::widget(bitOutput,$bitNoOutput) \
            -command "::vellemank8055::setOutput $bitNoOutput"
         grid $frm.test.bit$bitNoOutput -in [$frm.test getframe] -row 1 -column $bitNoOutput
         grid columnconfigure [$frm.test getframe] $bitNoOutput -minsize 40 -weight 0
      }

      #--- J'affiche le bouton general (les 8 boutons ensemble)
      label $frm.test.labtous -text "$caption(vellemank8055,tous)"
      grid $frm.test.labtous -in [$frm.test getframe] -row 0 -column 9
      checkbutton $frm.test.tousOutput -text $widget(bitOutput,tous) -indicatoron false \
         -offvalue "OFF" -onvalue "ON" \
         -variable ::vellemank8055::widget(bitOutput,tous) \
         -command "::vellemank8055::initialiseBitsSortieON"
      grid $frm.test.tousOutput -in [$frm.test getframe] -row 1 -column 9
      grid columnconfigure [$frm.test getframe] 9 -minsize 40 -weight 0

      #--- J'affiche le bouton du chenillard
      button $frm.test.chenillard -text "$caption(vellemank8055,chenillard)" -relief raised \
         -command "::vellemank8055::chenillard"
      grid $frm.test.chenillard -in [$frm.test getframe] -row 1 -column 10 -padx 6 -ipadx 5

      #--- J'affiche le bouton de remise a zero des 8 bits de sortie
      button $frm.test.raz -text "$caption(vellemank8055,raz)" -relief raised \
         -command "::vellemank8055::initialiseBitsSortieOFF"
      grid $frm.test.raz -in [$frm.test getframe] -row 1 -column 11 -padx 6 -ipadx 5

   pack $frm.test -side top -anchor w -fill none -pady 5

   #--- J'affiche les voyants et le bouton de lecture des 5 bits d'entree
   TitleFrame $frm.test1 -borderwidth 2 -relief ridge -text "$caption(vellemank8055,test5entrees)"

      #--- J'affiche les voyants des 5 bits d'entree
      for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
         label $frm.test1.lab$bitNoInput -text $bitNoInput
         grid $frm.test1.lab$bitNoInput -in [$frm.test1 getframe] -row 0 -column $bitNoInput
         checkbutton $frm.test1.bit$bitNoInput -state disabled \
            -variable ::vellemank8055::widget(bitInput,$bitNoInput)
         grid $frm.test1.bit$bitNoInput -in [$frm.test1 getframe] -row 1 -column $bitNoInput
         grid columnconfigure [$frm.test1 getframe] $bitNoInput -minsize 40 -weight 0
      }

      #--- J'affiche le bouton de lecture des entrees
      button $frm.test1.read -text "$caption(vellemank8055,lire)" -relief raised \
         -command "::vellemank8055::readInputs"
      grid $frm.test1.read -in [$frm.test1 getframe] -row 1 -column 9 -ipadx 5

   pack $frm.test1 -side top -anchor w -fill none -pady 5

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm

   #--- Configuration des boutons de test
   ::vellemank8055::configureConfigPage
}

#------------------------------------------------------------
# configureConfigPage
#   autorise/interdit les boutons de test
#
# Parameters:
#
# Return:
#  rien
#------------------------------------------------------------
proc ::vellemank8055::configureConfigPage { } {
   variable private

   if { $private(frm) != "" && [winfo exists $private(frm)] } {
      if { [ ::vellemank8055::isReady ] == 1 } {
         #--- J'active les boutons de l'interface
         for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
            $private(frm).test.lab$bitNoOutput configure -state normal
            $private(frm).test.bit$bitNoOutput configure -state normal
         }
         $private(frm).test.labtous configure -state normal
         $private(frm).test.tousOutput configure -state normal
         $private(frm).test.chenillard configure -state normal
         $private(frm).test.raz configure -state normal
         for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
            $private(frm).test1.lab$bitNoInput configure -state normal
         }
         $private(frm).test1.read configure -state normal
         $private(frm).port.stop configure -state normal
      } else {
         #--- Je desactive les boutons de l'interface
         for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
            $private(frm).test.lab$bitNoOutput configure -state disabled
            $private(frm).test.bit$bitNoOutput configure -state disabled
         }
         $private(frm).test.labtous configure -state disabled
         $private(frm).test.tousOutput configure -state disabled
         $private(frm).test.chenillard configure -state disabled
         $private(frm).test.raz configure -state disabled
         for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
            $private(frm).test1.lab$bitNoInput configure -state disabled
         }
         $private(frm).test1.read configure -state disabled
         $private(frm).port.stop configure -state disabled
      }
   }
}

#------------------------------------------------------------
#  setOutput
#     change un bit de sortie
#
#------------------------------------------------------------
proc ::vellemank8055::setOutput { bitNoOutput { bitValue "" } } {
   variable private
   variable widget

   if { [lsearch -exact "1 2 3 4 5 6 7 8" $bitNoOutput ] == -1 } {
      error "Error bitNoOutput=$bitNoOutput Must be between 1 and 8 "
   }
   if { $bitValue == "" } {
      if { $widget(bitOutput,$bitNoOutput) == "ON" } {
         set bitValue 1
      } else {
         set bitValue 0
      }
   }

   sendCommandK8055 $bitNoOutput $bitValue

   if { [winfo exists $private(frm).test.bit$bitNoOutput] } {
      if { $bitValue == 1 } {
         set widget(bitOutput,$bitNoOutput) "ON"
      } else {
         set widget(bitOutput,$bitNoOutput) "OFF"
      }
      #--- Je refraichis l'affichage du bouton de test du bit de sortie
      $private(frm).test.bit$bitNoOutput configure -text $widget(bitOutput,$bitNoOutput)
   }
}

#------------------------------------------------------------
# sendCommandK8055
#    envoie une commande au module K8055
#
# Parameters :
#  bitNoOutput : numero du bit
#  bitValue    : valeur du label du bouton (1 = ON, 0 = OFF)
#
# Return :
#    rien
#------------------------------------------------------------
proc ::vellemank8055::sendCommandK8055 { { bitNoOutput " " } { bitValue " " } } {
   variable private

   if { $bitValue == "1" } {
      ros_velleman function SetDigitalChannel $bitNoOutput
   } elseif { $bitValue == "0" } {
      ros_velleman function ClearDigitalChannel $bitNoOutput
  }
}

#------------------------------------------------------------
# initialiseBitsSortieOFF
#    initialise les interrupteurs de sortie qui sont ON a OFF
#
# Parameters:
#    aucun
#
# Return:
#    rien
#------------------------------------------------------------
proc ::vellemank8055::initialiseBitsSortieOFF { } {
   variable private
   variable widget

   for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
      #--- Je mets a 0 les 8 bits de sortie
      ros_velleman function ClearDigitalChannel $bitNoOutput
      #--- Je refraichis l'affichage du bouton de test
      if { $widget(bitOutput,$bitNoOutput) == "ON" } {
         set widget(bitOutput,$bitNoOutput) "OFF"
         $private(frm).test.bit$bitNoOutput configure -text $widget(bitOutput,$bitNoOutput) \
            -variable ::vellemank8055::widget(bitOutput,$bitNoOutput)
      }
   }

   #--- Je refraichis l'affichage du bouton de test de l'ensemble des 8 bits de sortie
   if { $widget(bitOutput,tous) == "ON" } {
      set widget(bitOutput,tous) "OFF"
      $private(frm).test.tousOutput configure -text $widget(bitOutput,tous) \
         -variable ::vellemank8055::widget(bitOutput,tous)
   }
}

#------------------------------------------------------------
# initialiseBitsSortieON
#    initialise les interrupteurs de sortie a ON
#
# Parameters:
#    aucun
#
# Return:
#    rien
#------------------------------------------------------------
proc ::vellemank8055::initialiseBitsSortieON { } {
   variable private
   variable widget

   if { $widget(bitOutput,tous) == "ON" } {
      #--- Je mets tous les boutons des bits de sortie a ON
      for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
         #--- Je mets a 1 tous les bits de sortie
         ros_velleman function SetDigitalChannel $bitNoOutput
      }
   } elseif { $widget(bitOutput,tous) == "OFF" } {
      ::vellemank8055::initialiseBitsSortieOFF
   }
   #--- Je refraichis l'affichage du bouton de test de l'ensemble des 8 bits de sortie
   $private(frm).test.tousOutput configure -text $widget(bitOutput,tous)
}

#------------------------------------------------------------
# chenillard
#    realise un chenillard avec les 8 bits de sortie
#
# Parameters:
#    aucun
#
# Return:
#    rien
#------------------------------------------------------------
proc ::vellemank8055::chenillard { } {
   variable private
   variable widget

   ::vellemank8055::initialiseBitsSortieOFF
   for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
      ros_velleman function SetDigitalChannel $bitNoOutput
      after 200
      ros_velleman function ClearDigitalChannel $bitNoOutput
   }
}

#------------------------------------------------------------
# readInputs
#    lit les 5 bits d'entree
#
# Parameters:
#    aucun
#
# Return:
#    rien
#------------------------------------------------------------
proc ::vellemank8055::readInputs { } {
   variable private
   variable widget

   set res [ ros_velleman function ReadAllDigital ]
   set ligne "binary scan \\x[format %02x $res] b8 bitsInput"
   eval $ligne
   set bitsInput
   for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
      set nn [ expr $bitNoInput - 1 ]
      set bitInput [ string range $bitsInput $nn $nn ]
      set widget(bitInput,$bitNoInput) [ string range $bitsInput $nn $nn ]
   }
}

#------------------------------------------------------------
# numeroCarte
#    definit le numero de la carte
#
# Parameters:
#    aucun
#
# Return:
#    rien
#------------------------------------------------------------
proc ::vellemank8055::numeroCarte { } {
   variable private
   variable widget

   if { $widget(SK5) == "1" && $widget(SK6) == "1" } {
      set private(numeroCarte) "0"
   } elseif { $widget(SK5) == "0" && $widget(SK6) == "1" } {
      set private(numeroCarte) "1"
   } elseif { $widget(SK5) == "1" && $widget(SK6) == "0" } {
      set private(numeroCarte) "2"
   } elseif { $widget(SK5) == "0" && $widget(SK6) == "0" } {
      set private(numeroCarte) "3"
   }
   set widget(numeroCarte) $private(numeroCarte)
}

#------------------------------------------------------------
#  getLinkLabels
#     retourne les libelles des cartes vellemank8055 disponibles
#
#   exemple :
#   getLinkLabels
#   retourne   "K8055-USB"
#------------------------------------------------------------
proc ::vellemank8055::getLinkLabels { } {
   variable private

   set labels [list ]

   lappend labels "K8055-USB"

   return $labels
}

#------------------------------------------------------------
#  getSelectedLinkLabel
#     retourne le link choisi
#
#   exemple :
#   getSelectedLinkLabel
#     "K8055-COM1"
#------------------------------------------------------------
proc ::vellemank8055::getSelectedLinkLabel { } {
   variable private

   #--- Je retourne le label du link
   return "$private(genericName)-USB"
}

#------------------------------------------------------------
#  isValidLabel
#     indique si linkLabel ets un nom de link valide
#     exemple :  isValidLabel "K8055-USB"   retourne 1
#     exemple :  isValidLabel "XXX1"        retourne 0
#  @param     linkLabel   nom du link
#  @return    1 (valid) ou 0 (not valid)
#------------------------------------------------------------
proc ::vellemank8055::isValidLabel { linkLabel } {
   variable private

   if { [string first $private(genericName) $linkLabel ] == 0 } {
      return 1
   } else {
      return 0
   }
}

#------------------------------------------------------------
#  widgetToConf
#     copie les variables des widgets dans le tableau conf()
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::widgetToConf { } {
   variable private
   variable widget
   global conf

   if { [isReady] == 1 } {
      #--- Je supprime la liaison si elle existe deja
      ::vellemank8055::stopPlugin
   }

   set conf(vellemank8055,SK5) $widget(SK5)
   set conf(vellemank8055,SK6) $widget(SK6)

   for { set bitNoOutput 1 } { $bitNoOutput <= 8 } {incr bitNoOutput } {
      set private(bitOutput,$bitNoOutput) $widget(bitOutput,$bitNoOutput)
   }

   for { set bitNoInput 1 } { $bitNoInput <= 5 } {incr bitNoInput } {
      set private(bitInput,$bitNoInput) $widget(bitInput,$bitNoInput)
   }
}

#------------------------------------------------------------
#  selectConfigLink
#     selectionne un link dans la fenetre de configuration
#
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::selectConfigLink { linkLabel } {
   variable private

   #-- Rien a faire car pour l'instant il n'y a qu'une seule carte Velleman

}

#------------------------------------------------------------
#  simulCreateLink
#     cree une liaison purement TCL (sans libriairie dynamique)
#     cette procedure simule la librairie dynamique.
#  return rien
#------------------------------------------------------------
proc ::vellemank8055::simulLibraryCreateLink { libraryName linkLabel } {

   #--- Je recherche le premier linkNo disponible
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
   append command "   bit  { ::${libraryName}::setOutput  ${dollar}arg1 ${dollar}arg2  } \n"
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
proc ::vellemank8055::simulLibraryUseLink { libraryName linkNo  args } {
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


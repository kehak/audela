#
## @file confeqt.tcl
#  @brief Affiche la fenêtre de configuration des plugins du type 'equipment'
#  @authors Robert DELMAS et Michel PUJOL
#  @namespace confEqt
#  @brief Affiche la fenêtre de configuration des plugins du type 'equipment'
#  $Id: confeqt.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::confEqt {
}

#------------------------------------------------------------
## @brief initialise les variable conf(..) et caption(..)
#  @warning cette procédure est lancée automatiquement au chargement de ce fichier tcl
#  @details démarre le plugin sélectionné par défaut
#
proc ::confEqt::init { } {
   variable private
   global audace

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" confeqt.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   ::confEqt::initConf

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(notebookLabelList)   ""
   set private(notebookNameList)    ""
   set private(frm)                 "$audace(base).confeqt"
   set private(variablePluginName)  ""
   set private(selectedFocuser)     $::caption(confeqt,pas_focuser)

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" equipment]
   #--- je charge la liste des plugins
   findPlugin
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Equipement :"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(confEqt,geometry) définit la position de la fenêtre
#
proc ::confEqt::initConf { } {
   global conf

   if { ! [ info exists conf(confEqt,geometry) ] } { set conf(confEqt,geometry) "475x570+15+15" }
}

#------------------------------------------------------------
#  brief retourne le titre de la fenêtre dans la langue de l'utilisateur
#
proc ::confEqt::getLabel { } {
   global caption

   return "$caption(confeqt,config)"
}

#------------------------------------------------------------
#  brief affiche la fenêtre de choix et de configuration
#
proc ::confEqt::run { { variablePluginName "" } { authorizedPluginType "" } { configurationTitle "" } } {
   variable private
   global caption

   #--- je memorise le nom de la variable contenant le nom du plugin selectionne
   #--- la procedure appliquer copira le nom du plugin selectionne dans cette variable
   set private(variablePluginName) $variablePluginName

   set private(notebookLabelList) [list ]
   set private(notebookNameList)  [list ]

   #--- Si authorizedPluginType est vide tous les onglets sont affiches
   if { $authorizedPluginType == "" } {
      #--- les plugins de tous les types sont autorises
      set private(notebookNameList) $private(pluginNamespaceList)
      foreach pluginName $private(notebookNameList) {
         lappend private(notebookLabelList) [::$pluginName\::getPluginTitle]
      }
   } else {
      #--- je cree la liste des plugins dont le type est autorise
      foreach pluginName $private(pluginNamespaceList) {
         if { [lsearch -exact $authorizedPluginType [::$pluginName\::getPluginType]] != -1 } {
            lappend private(notebookNameList)  $pluginName
            lappend private(notebookLabelList) [::$pluginName\::getPluginTitle]
         }
      }
   }

   #--- je verifie si le plugin existe dans la liste des onglets
   if { [ llength $private(notebookNameList) ] > 0 } {
      ::confEqt::createDialog
      if { $::confEqt::private(variablePluginName) != "" } {
         set selectedPluginName [ set $::confEqt::private(variablePluginName) ]
      } else {
         set selectedPluginName ""
      }
      if { $selectedPluginName != "" } {
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [ lsearch -exact $private(notebookNameList) $selectedPluginName ] == -1 } {
            #--- si la valeur n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set selectedPluginName [ lindex $private(notebookNameList) 0 ]
         }
      } else {
         set selectedPluginName [ lindex $private(notebookNameList) 0 ]
      }
      selectNotebook $selectedPluginName
   } else {
      tk_messageBox -title "$caption(confeqt,config)" -message "$caption(confeqt,pas_equipement)" -icon error
   }
}

#------------------------------------------------------------
#  brief commande du bouton "Ok"
#  details mémorise et applique la configuration
#  et ferme la fenêtre de réglage
#
proc ::confEqt::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
## @brief commande du bouton "Appliquer"
#  @details mémorise et applique la configuration
#
proc ::confEqt::appliquer { } {
   variable private
   global audace

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le nom du plugin selectionne
   set selectedPluginName [ $private(frm).usr.onglet raise ]

   #--- je mets a jour la combobox du nom du focuser
   if { [::$selectedPluginName\::getPluginType] == "focuser" } {
      set private(selectedFocuser) $selectedPluginName
   }

   #--- Affichage d'un message d'alerte si necessaire
   ::confEqt::connectEquipement

   #--- je configure le plugin
   ::confEqt::configurePlugin $selectedPluginName

   #--- je cree le plugin selectionne
   ::confEqt::createPlugin $selectedPluginName

   #--- je copie le nom dans la variable de sortie
   if { $private(variablePluginName) != "" } {
      set $private(variablePluginName) $selectedPluginName
   }

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal

   #--- Effacement du message d'alerte s'il existe
   if [ winfo exists $audace(base).connectEquipement ] {
      destroy $audace(base).connectEquipement
   }
}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#
proc ::confEqt::afficheAide { } {
   variable private

   #--- j'affiche la documentation
   set selectedPluginName   [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory  [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp           [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#
proc ::confEqt::fermer { } {
   variable private

   ::confEqt::recupPosDim
   destroy $private(frm)

   #--- j'efface le nom de la variable de sortie
   set private(variablePluginName) ""
}

#------------------------------------------------------------
#  brief récupère et de sauvegarde la position et la
#  dimension de la fenêtre de configuration
#
proc ::confEqt::recupPosDim { } {
   variable private
   global conf

   set private(confEqt,geometry) [ wm geometry $private(frm) ]
   set conf(confEqt,geometry)    $private(confEqt,geometry)
}

#------------------------------------------------------------
#  brief créé un widget "label" avec une URL du site WEB
#  param tkparent chemin de la frame parente
#  param title texte affiché
#  param url url cible
#
proc ::confEqt::createUrlLabel { tkparent title url } {
   global color

   label  $tkparent.labURL -text "$title" -fg $color(blue)
   bind   $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   bind   $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind   $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

#------------------------------------------------------------
## @brief configure le plugin
#  @param pluginLabel nom du plugin
#
proc ::confEqt::configurePlugin { pluginLabel } {
   if { $pluginLabel != "" } {
      ::$pluginLabel\::configurePlugin
   }
}

#------------------------------------------------------------
#  brief affiche la fenêtre à onglets
#  return 0 = OK, 1 = error (no plugin found)
#
proc ::confEqt::createDialog { } {
   variable private
   global caption conf

   #---
   if { [ winfo exists $private(frm) ] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      focus $private(frm)
      return 0
   }

   #---
   set private(confEqt,geometry) $conf(confEqt,geometry)

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(confEqt,geometry)
   wm minsize $private(frm) 460 465
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confeqt,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confEqt::fermer"

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(confeqt,ok)" -relief raised -state normal -width 7 \
         -command "::confEqt::ok"
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(confeqt,appliquer)" -relief raised -state normal -width 8 \
         -command "::confEqt::appliquer"
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(confeqt,fermer)" -relief raised -state normal -width 7 \
         -command "::confEqt::fermer"
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(confeqt,aide)" -relief raised -state normal -width 8 \
         -command "::confEqt::afficheAide"
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $private(notebookNameList) {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title    " ]
         ::$namespace\::fillConfigPage $frm
      }
      pack $notebook -fill both -expand 1 -padx 4 -pady 4

   pack $private(frm).usr -side top -fill both -expand 1

   #--- La fenetre est active
   focus $private(frm)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private(frm) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private(frm)

   return 0
}

#------------------------------------------------------------
#  brief sélectionne un onglet
#  details si le label est omis ou inconnu, le premier onglet est sélectionné
#
proc ::confEqt::selectNotebook { { equipment "" } } {
   variable private

   if { $equipment != "" } {
      set frm [ $private(frm).usr.onglet getframe $equipment ]
      $private(frm).usr.onglet raise $equipment
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#------------------------------------------------------------
## @brief créé le plugin
#  @param pluginLabel nom du plugin
#
proc ::confEqt::createPlugin { pluginLabel } {
   if { $pluginLabel != "" } {
      #--- je demarrer le plugin
      ::$pluginLabel\::createPlugin
   }
}

#------------------------------------------------------------
## @brief supprime le plugin
#  @param pluginLabel nom du plugin
#
proc ::confEqt::deletePlugin { pluginLabel } {
   if { "$pluginLabel" != "" } {
      ::$pluginLabel\::deletePlugin
   }
}

#------------------------------------------------------------
## @brief recherche les plugins de type "equipment"
#  @pre le plugin doit avoir une procedure getPluginType qui retourne
#   "equipment" ou "focuser" ou "spectroscope" ou "weather_station"
#  @pre le plugin doit avoir une procedure getPluginTitle
#  @remarks si le plugin remplit les conditions, son label est ajouté dans la liste namespaceList,
#  sinon le fichier tcl est ignoré car ce n'est pas un plugin
#  @return 0 = OK, 1 = error (no plugin found)
#
proc ::confEqt::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers equipment/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" equipment * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "equipment" || $pluginInfo(type) == "focuser" || $pluginInfo(type) == "spectroscope"\
               || $pluginInfo(type) == "weather_station" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(confeqt,equipement) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading equipment $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confEqt::findPlugin $::errorInfo\n"
      }
   }

   #--- je trie les plugins par ordre alphabetique des libelles
   set pluginList ""
   for { set i 0} {$i< [llength $private(pluginLabelList)] } {incr i } {
      lappend pluginList [list [lindex $private(pluginLabelList) $i] [lindex $private(pluginNamespaceList) $i] ]
   }
   set pluginList [lsort -dictionary -index 0 $pluginList]
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   foreach plugin $pluginList {
      lappend private(pluginLabelList)     [lindex $plugin 0]
      lappend private(pluginNamespaceList) [lindex $plugin 1]
   }

   ::console::affiche_prompt "\n"

   if { [llength $private(pluginNamespaceList)] < 1 } {
      #--- aucun plugin correct
      return 1
   } else {
      #--- tout est ok
      return 0
   }
}

#------------------------------------------------------------
#  brief affiche un message d'alerte pendant la connexion d'un équipement au démarrage
#
proc ::confEqt::connectEquipement { } {
   variable private
   global audace caption color

   if [ winfo exists $audace(base).connectEquipement ] {
      destroy $audace(base).connectEquipement
   }

   toplevel $audace(base).connectEquipement
   wm resizable $audace(base).connectEquipement 0 0
   wm title $audace(base).connectEquipement "$caption(confeqt,attention)"
   if { [ winfo exists $audace(base).confeqt ] } {
      set posx_connectEquipement [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
      set posy_connectEquipement [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
      wm geometry $audace(base).connectEquipement +[ expr $posx_connectEquipement + 50 ]+[ expr $posy_connectEquipement + 100 ]
      wm transient $audace(base).connectEquipement $private(frm)
   } else {
      wm geometry $audace(base).connectEquipement +200+100
      wm transient $audace(base).connectEquipement $audace(base)
   }

   #--- Cree l'affichage du message
   label $audace(base).connectEquipement.labURL_1 -text "$caption(confeqt,connexion_texte1)" -fg $color(red)
   pack $audace(base).connectEquipement.labURL_1 -padx 10 -pady 2
   label $audace(base).connectEquipement.labURL_2 -text "$caption(confeqt,connexion_texte2)" -fg $color(red)
   pack $audace(base).connectEquipement.labURL_2 -padx 10 -pady 2
   update

   #--- La nouvelle fenetre est active
   focus $audace(base).connectEquipement

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectEquipement
}

#--------------------------  tous les plugins ------------------------------

#------------------------------------------------------------
## @brief lance tous les plugins
#
proc ::confEqt::startPlugin { } {
   variable private
   global audace

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(pluginNamespaceList) {
      if { [::$pluginLabel\::getStartFlag] == 1 } {
         #--- Affichage d'un message d'alerte si necessaire
         ::confEqt::connectEquipement
         #--- Lance les plugins equipements au demarrage
         set catchError [ catch { ::$pluginLabel\::createPlugin } catchMessage ]
         if { $catchError == 1 } {
            #--- j'affiche un message d'erreur
            ::console::affiche_erreur "Error start equipment $pluginLabel: $catchMessage\n\n"
         }
         #--- Effacement du message d'alerte s'il existe
         if [ winfo exists $audace(base).connectEquipement ] {
            destroy $audace(base).connectEquipement
         }
      }
   }
}

#------------------------------------------------------------
## @brief arrête tous les plugins qui sont en service
#
proc ::confEqt::stopPlugin { } {
   variable private

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach pluginLabel $private(pluginNamespaceList) {
      if { [::$pluginLabel\::isReady] == 1 } {
         ::$pluginLabel\::deletePlugin
      }
   }
}


#-------------------------- specifique aux focusers ------------------------------

#------------------------------------------------------------
#  brief créé une frame pour sélectionner le focuser
#  code Exemple ::confEqt::createFrameFocuser $frm.focuserList ::panneau(foc,focuser)
#  endcode
#  remarks cette frame est destinée à être insérée dans une fenêtre
#  param frm chemin TK de la frame à creer
#  param variablePluginName contient le nom de la variable dans laquelle sera
#  copié le nom du focuser sélectionné
#  param specificFocuser si un seul focuser est utilisable (option)
#
proc ::confEqt::createFrameFocuser { frm variablePluginName { specificFocuser "" } } {
   variable private
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   #--- je cree la liste des plugins de type "focuser"
   set pluginList [list $::caption(confeqt,pas_focuser) ]
   if { $specificFocuser != "focuserlx200" } {
      foreach pluginName $private(pluginNamespaceList) {
         if { [::$pluginName\::getPluginType] == "focuser" } {
            lappend pluginList $pluginName
         }
      }
   } else {
      lappend pluginList focuserlx200
   }

   #--- je mets la liste des plugins dans une variable consultable de l'exterieur
   set private(pluginListFocuser) $pluginList

   #--- combobox
   ComboBox $frm.list \
      -width [ ::tkutil::lgEntryComboBox $pluginList ] \
      -height [llength $pluginList] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable ::confEqt::private(selectedFocuser) \
      -editable 0     \
      -values $pluginList \
      -modifycmd "::confEqt::activeFocuser $frm.configure $variablePluginName"
   pack $frm.list -in $frm -anchor center -side left -padx 0 -pady 10

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confeqt,configurer) ..." \
      -command "::confEqt::run $variablePluginName focuser"
   pack $frm.configure -in $frm -anchor center -side top -padx 10 -pady 10 -ipadx 10 -ipady 5 -expand true

   #--- j'adapte l'affichage du bouton de configuration
   ::confEqt::activeFocuser $frm.configure $variablePluginName
}

#------------------------------------------------------------
#  brief configure la combobox créée avec ::confEqt::createFrameFocuser
#  param frm chemin TK de la frame à configurer
#  param plugin plugin à afficher dans la combobox
#
proc ::confEqt::setValueFrameFocuser { frm plugin } {
   variable private

   set rank [ lsearch -exact $private(pluginListFocuser) $plugin ]
   $frm.list setvalue @$rank
}

#------------------------------------------------------------
# createFrameFocuserTool
#  brief créé une frame pour selectionner le focuser pour un outil
#  code Exemple : ::confEqt::createFrameFocuserTool $frm.focuserList ::panneau(foc,focuser)
#  endcode
#  details cette frame est destinée à être insérée dans une fenêtre
#  param frm chemin TK de la frame à créer
#  param variablePluginName contient le nom de la variable dans laquelle sera
#  copié le nom du focuser sélectionné
#
proc ::confEqt::createFrameFocuserTool { frm variablePluginName } {
   variable private
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   #--- je cree la liste des plugins de type "focuser"
   set pluginList [list $::caption(confeqt,pas_focuser) ]
   foreach pluginName $private(pluginNamespaceList) {
      if { [::$pluginName\::getPluginType] == "focuser" } {
         lappend pluginList $pluginName
      }
   }

   #--- j'intialise la variable qui contient la valeur selectionnee
   if { [set $variablePluginName] == "" } {
      set private(selectedFocuser) $::caption(confeqt,pas_focuser)
   } else {
      set private(selectedFocuser) [set $variablePluginName]
   }

   #--- je mets la liste des plugins dans une variable consultable de l'exterieur
   set private(pluginListFocuserTool) $pluginList

   #--- combobox
   ComboBox $frm.list \
      -width [ ::tkutil::lgEntryComboBox $pluginList ] \
      -height [llength $pluginList] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable ::confEqt::private(selectedFocuser) \
      -editable 0     \
      -values $pluginList \
      -modifycmd "::confEqt::activeFocuser $frm.configure $variablePluginName"
   pack $frm.list -in $frm -anchor center -side top -padx 0 -pady 2

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confeqt,configurer) ..." \
      -command "::confEqt::run $variablePluginName focuser"
  pack $frm.configure -in $frm -anchor center -side top -padx 0 -pady 2 -ipadx 10 -ipady 5 -expand true
}

#------------------------------------------------------------
#  brief configure la combobox créée avec ::confEqt::createFrameFocuserTool
#  param frm chemin TK de la frame à configurer
#  param plugin plugin à afficher dans la combobox
#
proc ::confEqt::setValueFrameFocuserTool { frm plugin } {
   variable private

   set rank [ lsearch -exact $private(pluginListFocuserTool) $plugin ]
   $frm.list setvalue @$rank
}

#------------------------------------------------------------
#   brief active le bouton de configuration du focuser
#   ou désactive le bouton si le nom du focuser est vide
#   param configureButton chemin TK de la frame à creer
#   param focuserName nom du focuser
#
proc ::confEqt::activeFocuser { configureButton variablePluginName } {
   variable private

   if { $private(selectedFocuser) == $::caption(confeqt,pas_focuser) } {
       set $variablePluginName ""
   } else {
      set $variablePluginName $private(selectedFocuser)
   }

   if { [set $variablePluginName] == "" } {
      $configureButton configure -state disabled
   } else {
      $configureButton configure -state normal
   }
}

#--- initialisation de la liste des plugins
::confEqt::init


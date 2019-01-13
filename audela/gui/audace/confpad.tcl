#
## @file confpad.tcl
#  @brief Affiche la fenêtre de configuration des plugins du type 'pad'
#  @author Michel PUJOL
#  @namespace confPad
#  @brief Affiche la fenêtre de configuration des plugins du type 'pad'
#  $Id: confpad.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::confPad {
}

#------------------------------------------------------------
## @brief initialise les variable conf(..) et caption(..)
#  @warning cette procédure est lancée automatiquement au chargement de ce fichier tcl
#  @details démarre le plugin sélectionné par défaut
#
proc ::confPad::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" confpad.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   ::confPad::initConf

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confPad"
   set private(variablePluginName)  ""

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" pad]
   #--- je recherche les plugin presents
   ::confPad::findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(confPad)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(confPad) ""
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Raquette :"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(confPad,geometry) définit la position de la fenêtre
#  - conf(confPad) nom du pad (ex superpad)
#
proc ::confPad::initConf { } {
   global conf

   if { ! [ info exists conf(confPad,geometry) ] } { set conf(confPad,geometry) "440x240+15+15" }
   if { ! [ info exists conf(confPad) ] }          { set conf(confPad)          "superpad" }
}

#------------------------------------------------------------
#  brief retourne le titre de la fenêtre dans la langue de l'utilisateur
#
proc ::confPad::getLabel { } {
   global caption

   return "$caption(confpad,config)"
}

#------------------------------------------------------------
## @brief retourne le nom de la raquette courante
#
proc ::confPad::getCurrentPad { } {
   global conf

   return $conf(confPad)
}

#------------------------------------------------------------
## @brief commande du bouton "Configurer"
#  @param variablePluginName contient le nom de la variable dans laquelle
#  sera copié le nom du plugin sélectionné
#
proc ::confPad::run { { variablePluginName "" } } {
   variable private
   global caption conf

   set private(variablePluginName) $variablePluginName

   #--- je verifie si le plugin existe dans la liste des onglets
   if { [ llength $private(pluginNamespaceList) ] > 0 } {
      ::confPad::createDialog
      if { $::confPad::private(variablePluginName) != "" } {
         set selectedPluginName [ set $::confPad::private(variablePluginName) ]
      } else {
         set selectedPluginName "$conf(confPad)"
      }
      if { $selectedPluginName != "" } {
         #--- je verifie que la valeur par defaut existe dans la liste
         if { [ lsearch -exact $private(pluginNamespaceList) $selectedPluginName ] == -1 } {
            #--- si la valeur n'existe pas dans la liste,
            #--- je la remplace par le premier item de la liste
            set selectedPluginName [ lindex $private(pluginNamespaceList) 0 ]
         }
      } else {
         set selectedPluginName [ lindex $private(pluginNamespaceList) 0 ]
      }
      selectNotebook $selectedPluginName
   } else {
      tk_messageBox -title "$caption(confpad,config)" -message "$caption(confpad,pas_raquette)" -icon error
   }
}

#------------------------------------------------------------
#  brief commande du bouton "Ok"
#  details mémorise et applique la configuration
#  et ferme la fenêtre de réglage
#
proc ::confPad::ok { } {
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
proc ::confPad::appliquer { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- je recupere le nom du plugin selectionne
   set selectedPluginName [ $private(frm).usr.onglet raise ]

   #--- je demande a chaque plugin de sauver sa config dans le tableau conf(..)
   foreach name $private(pluginNamespaceList) {
      $name\::widgetToConf
   }

   #--- je copie le nom dans la variable de sortie
   if { $private(variablePluginName) != "" } {
      set $private(variablePluginName) $selectedPluginName
   }

   #--- je demarre le plugin selectionne
   configurePlugin $selectedPluginName

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#
proc ::confPad::afficheAide { } {
   variable private

   #--- j'affiche la documentation
   set selectedPluginName  [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp          [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#
proc ::confPad::fermer { } {
   variable private

   ::confPad::recupPosDim
   destroy $private(frm)
}

#------------------------------------------------------------
#  brief récupère et sauvegarde la position et la
#  dimension de la fenêtre de configuration de la raquette
#
proc ::confPad::recupPosDim { } {
   variable private
   global conf

   set private(confPad,geometry) [ wm geometry $private(frm) ]
   set conf(confPad,geometry) $private(confPad,geometry)
}

#------------------------------------------------------------
#  brief affiche la fenêtre à onglets
#  return 0 = OK, 1 = error (no plugin found)
#
proc ::confPad::createDialog { } {
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
   set private(confPad,geometry) $conf(confPad,geometry)

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(confPad,geometry)
   wm minsize $private(frm) 440 240
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confpad,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confPad::fermer"

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(confpad,ok)" -relief raised -state normal -width 7 \
         -command "::confPad::ok"
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(confpad,appliquer)" -relief raised -state normal -width 8 \
         -command "::confPad::appliquer"
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(confpad,fermer)" -relief raised -state normal -width 7 \
         -command "::confPad::fermer"
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(confpad,aide)" -relief raised -state normal -width 8 \
         -command "::confPad::afficheAide"
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $private(pluginNamespaceList) {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title " ]
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
#  brief créé une frame pour sélectionner le plugin dans une combobox
#  details cette frame est destinée à être insérée dans une fenêtre.
#  code Exemple ::confPad::createFramePad $frm.padList ::confTel::private(nomRaquette)
#  endcode
#  param frm chemin TK de la frame à créer
#  param variablePluginName nom de la variable dans laquelle sera copié le nom du plugin sélectionné
#
proc ::confPad::createFramePad { frm variablePluginName} {
   variable private
   global caption

   set private(frame) $frm
   #--- je cree la frame si elle n'existe pas deja
   if { [winfo exists $frm ] == 0 } {
      frame $private(frame) -borderwidth 0 -relief raised
   }

   ComboBox $frm.list \
      -width [ ::tkutil::lgEntryComboBox $private(pluginNamespaceList) ] \
      -height [llength $private(pluginNamespaceList)] \
      -relief sunken  \
      -borderwidth 1  \
      -textvariable $variablePluginName \
      -editable 0     \
      -values $private(pluginNamespaceList)
   pack $frm.list -in $frm -anchor center -side left -padx 0 -pady 10

   #--- bouton de configuration de l'equipement
   button $frm.configure -text "$caption(confpad,configurer) ..." \
      -command "::confPad::run $variablePluginName"
   pack $frm.configure -in $frm -anchor center -side top -padx 10 -pady 10 -ipadx 10 -ipady 5 -expand true
}

#------------------------------------------------------------
#  brief sélectionne un onglet
#  details si le label est omis ou inconnu, le premier onglet est sélectionné
#  param pad nom de la raquette
#
proc ::confPad::selectNotebook { { pad "" } } {
   variable private

   if { $pad != "" } {
      set frm [ $private(frm).usr.onglet getframe $pad ]
      $private(frm).usr.onglet raise $pad
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#------------------------------------------------------------
## @brief configure le plugin dont le label est dans $conf(confPad)
#  @param pluginName
#
proc ::confPad::configurePlugin { pluginName } {
   global conf

   #--- j'arrete le plugin precedent
   if { $conf(confPad) != "" } {
      ::$conf(confPad)::deletePluginInstance
   }

   set conf(confPad) $pluginName

   #--- je cree le plugin
   if { $pluginName != "" } {
      ::$pluginName\::createPluginInstance
   }
}

#------------------------------------------------------------
## @brief lance le plugin sélectionné
#
proc ::confPad::startPlugin { } {
   global conf

   ::confPad::configurePlugin $conf(confPad)
}

#------------------------------------------------------------
## @brief arrête le plugin sélectionné
#
proc ::confPad::stopPlugin { } {
   global conf

   if { "$conf(confPad)" != "" } {
      catch {
         $conf(confPad)::deletePluginInstance
      }
   }
}

#------------------------------------------------------------
## @brief recherche les plugins de type "pad"
#  @pre le plugin doit avoir une procedure getPluginType qui retourne "pad"
#  @pre le plugin doit avoir une procedure getPluginTitle
#  @remarks si le plugin remplit les conditions, son label est ajouté dans la liste pluginTitleList
#  et son namespace est ajouté dans pluginNamespaceList
#  sinon le fichier tcl est ignoré car ce n'est pas un plugin
#  @return 0 = OK, 1 = error (no plugin found)
#
proc ::confPad::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers pad/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" pad * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "pad" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(confpad,raquette) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading pad $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confPad::findPlugin $::errorInfo\n"
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

#--- connexion au demarrage du plugin selectionne par defaut
::confPad::init


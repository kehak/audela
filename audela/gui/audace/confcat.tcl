#
## @file confcat.tcl
#  @brief Affiche la fenêtre de configuration des plugins du type 'chart'
#  @author Michel PUJOL
#  @namespace confCat
#  @brief Affiche la fenêtre de configuration des plugins du type 'chart'
#  $Id: confcat.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::confCat {
}

#------------------------------------------------------------
## @brief initialise les variable conf(..) et caption(..)
#  @warning cette procédure est lancée automatiquement au chargement de ce fichier tcl
#  @details démarre le plugin sélectionné par défaut
#
proc ::confCat::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" confcat.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   ::confCat::initConf

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confcat"

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" chart]
   #--- je recherche les plugin presents
   findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(confCat)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(confCat) ""
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Carte :"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(confCat,geometry) définit la position de la fenêtre
#  - conf(confCat,start) indicateur de lancement au démarrage
#  - conf(confCat) nom de la carte
#
proc ::confCat::initConf { } {
   global conf

   if { ! [ info exists conf(confCat,geometry) ] } { set conf(confCat,geometry) "500x350+15+15" }
   if { ! [ info exists conf(confCat,start) ] }    { set conf(confCat,start)    "0" }
   if { ! [ info exists conf(confCat) ] }          { set conf(confCat)          "" }
}

#------------------------------------------------------------
#  brief retourne le titre de la fenêtre dans la langue de l'utilisateur
#
proc ::confCat::getLabel { } {
   global caption

   return "$caption(confcat,config)"
}

#------------------------------------------------------------
## @brief affiche la fenêtre de choix et de configuration
#  @param pluginName nom du plugin
#
proc ::confCat::run { { pluginName "" } } {
   variable private
   global caption conf

   #--- je verifie si le plugin existe dans la liste des onglets
   if { [ llength $private(pluginNamespaceList) ] > 0 } {
      ::confCat::createDialog
      if { $pluginName == "" } {
         set selectedPluginName $conf(confCat)
      } else {
         set selectedPluginName $pluginName
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
      tk_messageBox -title "$caption(confcat,config)" -message "$caption(confcat,pas_carte)" -icon error
   }
}

#------------------------------------------------------------
#  brief commande du bouton "Ok"
#  details mémorise et applique la configuration
#  et ferme la fen@tre de réglage
#
proc ::confCat::ok { } {
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
proc ::confCat::appliquer { } {
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

   #--- je demarre le plugin selectionne
   configurePlugin $selectedPluginName

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#
proc ::confCat::afficheAide { } {
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
proc ::confCat::fermer { } {
   variable private

   ::confCat::recupPosDim
   destroy $private(frm)
}

#------------------------------------------------------------
#  brief récupère et sauvegarde la position et la
#  dimension de la fenêtre de configuration de la raquette
#
proc ::confCat::recupPosDim { } {
   variable private
   global conf

   set private(confCat,geometry) [ wm geometry $private(frm) ]
   set conf(confCat,geometry) $private(confCat,geometry)
}

#------------------------------------------------------------
#  brief affiche la fenêtre à onglets
#  return 0 = OK, 1 = error (no plugin found)
#
proc ::confCat::createDialog { } {
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
   set private(confCat,geometry) $conf(confCat,geometry)

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(confCat,geometry)
   wm minsize $private(frm) 500 350
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(confcat,config)"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confCat::fermer"

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(confcat,ok)" -relief raised -state normal -width 7 \
         -command "::confCat::ok"
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(confcat,appliquer)" -relief raised -state normal -width 8 \
         -command "::confCat::appliquer"
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(confcat,fermer)" -relief raised -state normal -width 7 \
         -command "::confCat::fermer"
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(confcat,aide)" -relief raised -state normal -width 8 \
         -command "::confCat::afficheAide"
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      checkbutton $private(frm).start.chk -text "$caption(confcat,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(confCat,start)
      pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x

   pack $private(frm).start -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $private(pluginNamespaceList) {
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
#  param chart nom de la carte
#
proc ::confCat::selectNotebook { { chart "" } } {
   variable private

   if { $chart != "" } {
      set frm [ $private(frm).usr.onglet getframe $chart ]
      $private(frm).usr.onglet raise $chart
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#------------------------------------------------------------
## @brief configure le plugin dont le label est dans $conf(confCat)
#  @param pluginName nom du plugin
#
proc ::confCat::configurePlugin { pluginName } {
   global conf

   #--- j'arrete le plugin precedent
   if { $conf(confCat) != "" } {
      ::$conf(confCat)::deletePluginInstance
   }

   set conf(confCat) $pluginName

   #--- je cree le plugin
   if { $pluginName != "" } {
      ::$pluginName\::createPluginInstance
   }
}

#------------------------------------------------------------
#  brief créé un widget "label" avec une URL du site WEB
#  param tkparent chemin de la frame parente
#  param title texte affiché
#  param url url cible
#
proc ::confCat::createUrlLabel { tkparent title url } {
   global color

   label  $tkparent.labURL -text "$title" -fg $color(blue)
   bind   $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   bind   $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind   $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

#------------------------------------------------------------
## @brief lance le plugin sélectionné
#
proc ::confCat::startPlugin { } {
   global conf

   if { $conf(confCat,start) == "1" } {
      ::confCat::configurePlugin $conf(confCat)
   }
}

#------------------------------------------------------------
## @brief arrête le plugin sélectionné
#
proc ::confCat::stopPlugin { } {
   global conf

   if { "$conf(confCat)" != "" } {
      catch {
         $conf(confCat)::deletePluginInstance
      }
   }
}

#------------------------------------------------------------
## @brief recherche les plugins de type "chart"
#  @pre le plugin doit avoir une procedure getPluginType qui retourne "pad"
#  @pre le plugin doit avoir une procedure getPluginTitle
#  @remarks si le plugin remplit les conditions, son label est ajouté dans la liste pluginTitleList
#  et son namespace est ajouté dans pluginNamespaceList
#  sinon le fichier tcl est ignoré car ce n'est pas un plugin
#  @return 0 = OK, 1 = error (no plugin found)
#
proc ::confCat::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers chart/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" chart * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "chart" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(confcat,carte) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading cat $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confCat::findPlugin $::errorInfo\n"
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
::confCat::init


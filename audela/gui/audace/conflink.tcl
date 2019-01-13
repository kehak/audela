#
## @file confLink.tcl
#  @brief Gère des objets 'liaison' pour la communication
#  @authors Robert DELMAS et Michel PUJOL
## namespace confLink
#  @brief Gère des objets 'liaison' pour la communication
#  $Id: conflink.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::confLink {
}

#------------------------------------------------------------
## @brief initialise les variable conf(..) et caption(..)
#  @warning cette procédure est lancée automatiquement au chargement de ce fichier tcl
#  @details démarre le plugin sélectionné par défaut
#
proc ::confLink::init { } {
   variable private
   global audace conf

   #--- charge le fichier caption
   source [ file join "$audace(rep_caption)" conflink.cap ]

   #--- cree les variables dans conf(..) si elles n'existent pas
   ::confLink::initConf

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confLink"

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" link]
   #--- je recherche les plugin presents
   findPlugin

   #--- configure le plugin selectionne par defaut
   #if { $conf(confLink,start) == "1" } {
   #   configurePlugin
   #}
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Liaison :"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(confLink,position) définit la position de la fenêtre
#  - conf(confLink,start) indicateur de lancement au démarrage
#
proc ::confLink::initConf { } {
   global conf

   if { ! [ info exists conf(confLink,position) ] } { set conf(confLink,position) "+15+15" }
   if { ! [ info exists conf(confLink,start) ] }    { set conf(confLink,start)    "0" }
}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#
proc ::confLink::afficheAide { } {
   variable private

   #--- j'affiche la documentation
   set selectedPluginName  [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp          [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

#------------------------------------------------------------
## @brief commande du bouton "Appliquer"
#  @details mémorise et applique la configuration
#
proc ::confLink::appliquer { } {
   variable private
   global audace

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   set catchResult [ catch {
      #--- je recupere le nom du plugin selectionne
      set linkNamespace [ $private(frm).usr.onglet raise ]

      #--- je demande a chaque plugin de sauver sa config dans le tableau
      # conf(..)
      foreach name $private(authorizedPresentNamespaces) {
         $name\:\:widgetToConf
      }

      #--- je recupere le link choisi (pour la procedure ::confLink::run)
      set private(linkLabel) [$linkNamespace\:\:getSelectedLinkLabel]
      set $private(variableLinkLabel) $private(linkLabel)

      #--- je demarre le plugin selectionne
      configurePlugin

   }]

   if { $catchResult !=0 } {
      ::tkutil::displayErrorInfo $::caption(conflink,config)
      return
   }

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal

}

#------------------------------------------------------------
#  brief retourne le titre de la fenêtre dans la langue de l'utilisateur
#
proc ::confLink::getLabel { } {
   global caption

   return "$caption(conflink,config)"
}

#------------------------------------------------------------
#  brief commande du bouton "Ok"
#  details mémorise et applique la configuration
#  et ferme la fenêtre de réglage
#
proc ::confLink::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   appliquer
   fermer
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#
proc ::confLink::fermer { } {
   variable private

   ::confLink::recup_position
   destroy $private(frm)
}

#------------------------------------------------------------
#  brief récupère et sauvegarde la position et la
#  dimension de la fenêtre de configuration
#
proc ::confLink::recup_position { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set deb [ expr 1 + [ string first + $private(geometry) ] ]
   set fin [ string length $private(geometry) ]
   set private(position) "+[ string range $private(geometry) $deb $fin ]"
   #---
   set conf(confLink,position) $private(position)
}

#------------------------------------------------------------
## @brief affiche la fenêtre à onglets
#  @param authorizedNamespaces liste des onglets à afficher
#  si la chaîne est vide tous les onglets sont affichés
#  @param configurationTitle titre complémentaire de la fenêtre de dialogue
#  @return 0 = OK , 1 = error (no plugin found)
#
proc ::confLink::createDialog { authorizedNamespaces configurationTitle } {
   variable private
   global caption conf

   if { [winfo exists $private(frm)] } {
      destroy $private(frm)
   }

   #--- Je verifie qu'il y a des liaisons
   if { [llength $authorizedNamespaces] <1 } {
      tk_messageBox -title "$caption(conflink,config) $configurationTitle" \
         -message "$caption(conflink,pas_liaison)" -icon error
      return 1
   }

   #---
   set private(position) $conf(confLink,position)

   #---
   if { [ info exists private(geometry) ] } {
      set deb [ expr 1 + [ string first + $private(geometry) ] ]
      set fin [ string length $private(geometry) ]
      set private(position) "+[ string range $private(geometry) $deb $fin ]"
   }

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) 580x450$private(position)
   wm minsize $private(frm) 580 450
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) "$caption(conflink,config) $configurationTitle"
   wm protocol $private(frm) WM_DELETE_WINDOW "::confLink::fermer"

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(conflink,ok)" -relief raised -state normal -width 7 \
         -command " ::confLink::ok "
      if { $conf(ok+appliquer)=="1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(conflink,appliquer)" -relief raised -state normal -width 8 \
         -command " ::confLink::appliquer "
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(conflink,fermer)" -relief raised -state normal -width 7 \
         -command " ::confLink::fermer "
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(conflink,aide)" -relief raised -state normal -width 8 \
         -command " ::confLink::afficheAide "
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      checkbutton $private(frm).start.chk -text "$caption(conflink,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(confLink,start)
      pack $private(frm).start.chk -side top -padx 3 -pady 3 -fill x

   pack $private(frm).start -side bottom -fill x

   #--- Frame de la fenetre de configuration
   frame $private(frm).usr -borderwidth 0 -relief raised

      #--- Creation de la fenetre a onglets
      set notebook [ NoteBook $private(frm).usr.onglet ]
      foreach namespace $authorizedNamespaces {
         set title [ ::$namespace\::getPluginTitle ]
         set frm   [ $notebook insert end $namespace -text "$title    "  ]
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
# ::confLink::create
## @brief créé une liaison en indiquant quel péripherique utilise la liaison
#    et en précisant la partie utilisée de liaison (cas d'une liaison
#    utilisée par plusieur periphériques)
#  @param linkLabel  identifiant de la liaison
#  @param deviceId   commande du peripherique qui utilise la liaison
#  @param usage      type d'utilisation     (commentaire libre)
#  @param comment    commentaire facultatif (commentaire libre)
#  @param args       arguments optionnels   (commentaire libre)
#  @return linkno    numéro du link ou une chaine vide si le type du lien n'existe pas
#  @remarks le numéro du link est attribué automatiquement ; si ce link est deja créé,
#  on retourne le numero du link existant
#  @details Exemples :
#  - la liaison quickaudine0 est utilisée par cam1
#  - la liaison quickremote1 est utilisée par cam1 et par cam2
#  @code
#    ::confLink::create "quickaudine0" "cam1" "acquisition" "bit 1"
#    1
#    ::confLink::create "quickremote1" "cam1" "longuepose" "bit 1"
#    2
#    ::confLink::create "quickremote1" "cam2" "longuepose" "bit 2"
#    2
#  @endcode
#
proc ::confLink::create { linkLabel deviceId usage comment args } {
   set linkNamespace [getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      set linkno [$linkNamespace\::createPluginInstance $linkLabel $deviceId $usage $comment $args ]
   } else {
      set linkno ""
   }
   return $linkno
}

#------------------------------------------------------------
## @brief supprime une utilisation d'une liaison et supprime la
#  liaison si elle n'est plus utilisée par aucun autre péripherique
#  @code Exemple : ::confLink::delete "quickremote0" "cam1" "longuepose"
#  @endcode
#  @param linkLabel nom du link
#  @param deviceId  nom du périphérique
#  @param usage     nom de l'usage
#
proc ::confLink::delete { linkLabel deviceId usage } {
   set linkNamespace [getLinkNamespace $linkLabel]
   if { $linkNamespace != "" } {
      $linkNamespace\:\:deletePluginInstance $linkLabel $deviceId $usage
   }
}

#------------------------------------------------------------
#  brief sélectionne un onglet
#  details si le label est omis ou inconnu, le premier onglet est sélectionné
#  param linkNamespace
#
proc ::confLink::selectNotebook { { linkNamespace "" } } {
   variable private

   if { $linkNamespace != "" } {
      set frm [ $private(frm).usr.onglet getframe $linkNamespace ]
      $private(frm).usr.onglet raise $linkNamespace
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#------------------------------------------------------------
#  brief configure le plugin dont le label est dans private(linkLabel)
#
proc ::confLink::configurePlugin { } {
   variable private

   if { $private(linkLabel) == "" } {
      #--- pas de plugin selectionne par defaut
      return
   }

   set linkNamespace [getLinkNamespace $private(linkLabel)]

   if { $linkNamespace != "" } {
      #--- je configure le plugin
      [getLinkNamespace $private(linkLabel)]\::configurePlugin
   } else {
      error "link namspace not found for \"$private(linkLabel)\" in ::confLink::configurePlugin "
   }
}

#------------------------------------------------------------
## @brief arrête un ou tous les link
#  @param linkLabel nom du link
#  -  arrête le link, si le nom d'un link est donné en paramètre
#  -  arrête tous les link si aucun nom n'est passé en paramètre
#
proc ::confLink::stopPlugin { { linkLabel "" } } {
   if { $linkLabel != "" } {
      [getLinkNamespace $linkLabel]\:\:stopPlugin
   } else {
      #--- j'arrete tous les links
      ##### A FAIRE
   }
}

#------------------------------------------------------------
## @brief recherche les plugins de type "link"
#  @pre le plugin doit avoir une procédure getPluginType qui retourne ""link"
#  @pre le plugin doit avoir une procédure getPluginTitle
#  @remarks si le plugin remplit les conditions, son label est ajouté dans la liste pluginTitleList
#  et son namespace est ajouté dans pluginNamespaceList
#  sinon le fichier tcl est ignoré car ce n'est pas un plugin
#  @return 0 = OK, 1 = error (no plugin found)
#
proc ::confLink::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers link/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" link * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {
      set catchResult [catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "link" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(conflink,liaison) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading link $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage]
      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         console::affiche_erreur "::confLink::findPlugin $::errorInfo\n"
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
## @brief retourne les libellés des link disponibles
#  @param namespaces nom
#  @return retourne une liste vide s'il n'existe aucun namespace
#  @code getLinkLabels { quickremote parallelport }
#  { "quickremote0" "quickremote1" "LPT1:" "LPT2:" }
#  @endcode
#
proc ::confLink::getLinkLabels { namespaces } {
   variable private

   set labels [list]

   foreach namespaceName $namespaces {
      #--- je verifie que le namespace existe
      if { [lsearch -exact $private(pluginNamespaceList) $namespaceName] != -1 } {
         foreach linkLabel [$namespaceName\:\:getLinkLabels] {
            lappend labels $linkLabel
         }
      }
   }
   return $labels
}

#------------------------------------------------------------
## @brief retourne le libellé du namespace
#  @param namespace nom du namespace
#  @return libellé du namespace ou une chaine vide si namespace n'existe pas
#  @code getNamespaceLabel "parallelport"
#  { "Port parallele" }
#  @endcode
#
proc ::confLink::getNamespaceLabel { namespace } {
   variable private

   #--- je verifie que le namespace existe
   if { [lsearch -exact $private(pluginNamespaceList) $namespace] != -1 } {
      return [$namespace\:\:getPluginTitle]
   } else {
      #--- je retourne une chaine vide
      return ""
   }
}

#------------------------------------------------------------
## @brief retourne le namespace du link
#  @param linkLabel nom du link
#  @return retourne le namespace du link ou une chaine vide si le link n'existe pas
#  @code getLinkNamespace "LPT1:"
#  parallelport
#  @endcode
#
proc ::confLink::getLinkNamespace { linkLabel } {
   variable private

   foreach namespaceName $private(pluginNamespaceList) {
      #--- je verifie si on peut recuperer l'index
      if { [::$namespaceName\::isValidLabel $linkLabel] == 1 } {
         return $namespaceName
      }
   }
   #--- je retourne une chaine vide
   return ""
}

#------------------------------------------------------------
## @brief retourne le numéro de la liaison
#  @param linkLabel nom du link
#  @return numéro de la liaison ou une chaine vide si la liaison est fermée
#  @code Exemple : getLinkNo "quickremote0"
#  1
#  @endcode
#
proc ::confLink::getLinkNo { linkLabel } {
   variable private

   #--- je recupere les linkNo ouverts avec une librairie dynamique
   ##set linkNoList [link::list]
   #--- je recherche les commandes de la forme link$linkno
   set linkList [info command {link*[0-9]} ]

   foreach link $linkList {
      if { [$link name] == $linkLabel } {
         return  [scan $link "link%d" ]
      }
   }

   #--- je retourne une chaine vide si la liaison n'a pas de numero
   return ""
}

#------------------------------------------------------------
## @brief retourne la valeur d'une propriété d'une liaison
#  @param linkLabel nom de la liaison (exemple: LPT1 ou QUICKREMOTE1 )
#  @param propertyName nom de la propriété
#  @return retourne la valeur de la propriété
#
proc ::confLink::getPluginProperty { linkLabel propertyName } {
   variable private

   #--- je recherche la valeur par defaut de la propriete
   #--- si la valeur par defaut de la propriete n'existe pas , je retourne une chaine vide
   switch $propertyName {
      bitList          { set result [ list "" ] }
      default          { set result "" }
   }

   set linkNamespace [::confLink::getLinkNamespace $linkLabel]

   #--- si une camera est selectionnee, je recherche la valeur propre a la camera
   if { $linkNamespace != "" } {
      set result [ ::$linkNamespace\::getPluginProperty $propertyName ]
   }
   return $result
}

#------------------------------------------------------------
## @brief affiche la fenêtre de choix et de configuration
#  @param variableLinkLabel nom de la variable qui contient le link pré-selectionné
#  @param authorizedNamespaces namespaces autorises (optionel)
#  @param configurationTitle titre de la fenêtre de configuration (optionel)
#
proc ::confLink::run { { variableLinkLabel "" } { authorizedNamespaces "" } { configurationTitle "" } } {
   variable private
   global conf

   if { $variableLinkLabel == "" } {
      set private(linkLabel)         ""
      set private(variableLinkLabel) ""
   } else {
      set private(linkLabel)         [set $variableLinkLabel]
      set private(variableLinkLabel) $variableLinkLabel
   }

   if { $authorizedNamespaces == "" } {
      set authorizedPresentNamespaces $private(pluginNamespaceList)
   } else {
      #--- je liste les packages qui sont presents parmi ceux qui sont autorises
      set authorizedPresentNamespaces [list ]
      foreach name $authorizedNamespaces {
          if { [lsearch $private(pluginNamespaceList) $name ] != -1 } {
            lappend authorizedPresentNamespaces $name
          }
      }
   }

   #--- je memorise la liste des onglets qui vont etre affiches
   set private(authorizedPresentNamespaces) $authorizedPresentNamespaces

   if { [createDialog $authorizedPresentNamespaces $configurationTitle ]==0 } {
      set linkNamespace [getLinkNamespace $private(linkLabel) ]
      if { $linkNamespace != "" } {
         #--- je selectionne l'onglet correspondant au linkNamespace
         selectNotebook $linkNamespace
         #--- je selectionne le link dans l'onglet
         $linkNamespace\::selectConfigLink $private(linkLabel)
      } else {
         #--- si  linkNamespace demande n'existe pas je selectionne le premier onglet
         selectNotebook [ lindex $authorizedPresentNamespaces 0 ]
      }
      #--- j'attends la fermeture de la fenetre
      tkwait window $private(frm)
      #--- je retourne le link choisi
      return $private(linkLabel)
   }
}

#--- Connexion au demarrage du plugin selectionne par defaut
::confLink::init


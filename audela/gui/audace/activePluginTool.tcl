#
## @file activePluginTool.tcl
#  @brief Choix des plugins de type tool à afficher dans les menus déroulants
#  @author Robert DELMAS
#  @namespace confChoixOutil
#  @brief  Choix des plugins de type tool à afficher dans les menus déroulants
#  $Id: activePluginTool.tcl 14152 2016-12-12 16:54:56Z rzachantke $
#

namespace eval ::confChoixOutil {
}

#------------------------------------------------------------
#  brief charge les variables de configuration dans des variables locales
#
proc ::confChoixOutil::confToWidget { } {
   variable widget
   global conf

   set widget(confChoixOutil,geometry) $conf(choixOutil,geometry)
}

#------------------------------------------------------------
#  brief charge les variables locales dans des variables de configuration
#
proc ::confChoixOutil::widgetToConf { } {
   variable widget
   global conf

   set conf(choixOutil,geometry) $widget(confChoixOutil,geometry)
}

#------------------------------------------------------------
#  brief récupère la géométrie (dimensions et position) de la fenêtre "Sélection des outils"
#
proc ::confChoixOutil::recupPosition { } {
   variable This
   variable widget

   set widget(confChoixOutil,geometry) [ wm geometry $This ]
   #---
   ::confChoixOutil::widgetToConf
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Sélection des outils"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(choixOutil,geometry)   définit les dimensions et la position de la fenêtre
#  - conf(choixOutil,utilisable) définit la liste des outils utilisables dans les menus déroulants
#  - conf(choixOutil,initAudace) définit les outils pour lesquels les ressources doivent être lancées au démarrage d'Aud'ACE
#
proc ::confChoixOutil::initConf { } {
   global conf

   if { ! [ info exists conf(choixOutil,geometry) ] }   { set conf(choixOutil,geometry)   "625x364+180+100" }
   if { ! [ info exists conf(choixOutil,utilisable) ] } { set conf(choixOutil,utilisable) "" }
   if { ! [ info exists conf(choixOutil,initAudace) ] } { set conf(choixOutil,initAudace) "" }
}

#------------------------------------------------------------
#  brief crée la fenêtre de configuration du choix des outils à afficher dans les menus déroulants
#  param this   chemin de la fenêtre
#  param visuNo numéro de la visu
#
proc ::confChoixOutil::run { this visuNo } {
   variable This
   global conf

   #--- Initialisation des variables conf(   )
   ::confChoixOutil::initConf
   #--- Chargement dans la variable locale
   ::confChoixOutil::confToWidget
   #--- Creation de l'interface graphique
   set This $this
   ::confChoixOutil::createDialog $visuNo
}

#------------------------------------------------------------
#  brief commande du bouton 'OK' pour mémoriser et appliquer la configuration
#  sur toutes les visu et fermer la fenetre du choix des outils à afficher
#  dans les menus déroulants
#  param visuNo numéro de la visu
#
proc ::confChoixOutil::ok { visuNo } {
   ::confChoixOutil::appliquer $visuNo
   ::confChoixOutil::fermer
}

#------------------------------------------------------------
## @brief commande du bouton "Appliquer" pour mémoriser
#  et appliquer la configuration sur toutes les visu
#  @param visuNo numéro de la visu
#
proc ::confChoixOutil::appliquer { visuNo } {
   variable private
   global conf panneau

   #--- Je recupere la geometrie de la fenetre
   ::confChoixOutil::recupPosition

   #--- Je construis la variable de configuration
   set private(pluginUtilisable) ""
   foreach menuDeroulantPluginNamespace $private(listeParMenu) {
      set menuDeroulant [ lindex $menuDeroulantPluginNamespace 0 ]
      set namespace     [ lindex $menuDeroulantPluginNamespace 2 ]
      #--- Je sauvegarde la configuration et mets en forme les variables conf
      if { $private($menuDeroulant,display,$namespace) == "1" } {
         #--- Outils actifs
         lappend private(pluginUtilisable) $namespace [ list 1 $private($menuDeroulant,raccourci,$namespace) ]
      } else {
         #--- Outils inactifs
         lappend private(pluginUtilisable) $namespace [ list 0 $private($menuDeroulant,raccourci,$namespace) ]
      }
   }

   #--- Je sauvegarde la configuration et mets en forme les variables conf
   set conf(choixOutil,utilisable) $private(pluginUtilisable)

   #--- Je rechercher le plugin ayant une procedure initAudace
   set private(pluginInitAudace) ""
   foreach pluginInitAudace $private(listeParMenu) {
      set namespace [ lindex $pluginInitAudace 2 ]
      if { [info commands "::$namespace\::initAudace" ] == "::$namespace\::initAudace" } {
         set menuDeroulant [ lindex $pluginInitAudace 0 ]
         set plugin        [ lindex $pluginInitAudace 1 ]
         lappend private(pluginInitAudace) [ list $menuDeroulant $plugin $namespace $private($menuDeroulant,load,$namespace) ]
      }
   }

   #--- Je sauvegarde la configuration et mets en forme les variables conf
   set conf(choixOutil,initAudace) $private(pluginInitAudace)

   #--- Rafraichissement des menus contenant des outils
   ::confVisu::refreshMenu $visuNo
}

#------------------------------------------------------------
#  brief commande du bouton "Aide"
#
proc ::confChoixOutil::afficheAide { } {
   global help

   ::audace::showHelpItem "$help(dir,config+)" "1010choix_outil.htm"
}

#------------------------------------------------------------
## @brief commande du bouton "Fermer"
#
proc ::confChoixOutil::fermer { } {
   variable This

   #--- Je recupere la geometrie de la fenetre
   ::confChoixOutil::recupPosition
   #--- Je ferme la fenetre
   destroy $This
}

#------------------------------------------------------------
#  brief tri dans l'ordre d'affichage des menus déroulants
#  param m contient 'menu_name,nom du namespace'
#
proc ::confChoixOutil::ordreMenuDeroulant { m } {
   set menuDeroulant [ ::[ string trimleft [ string trimleft $m "menu_name" ] "," ]\::getPluginProperty function ]
   if { $menuDeroulant == "file" } {
      set rangMenu 1
   } elseif { $menuDeroulant == "display" } {
      set rangMenu 2
   } elseif { $menuDeroulant == "images" } {
      set rangMenu 3
   } elseif { $menuDeroulant == "analysis" } {
      set rangMenu 4
   } elseif { $menuDeroulant == "acquisition" } {
      set rangMenu 5
   } elseif { $menuDeroulant == "aiming" } {
      set rangMenu 6
   } elseif { $menuDeroulant == "setup" } {
      set rangMenu 7
   }
   return $rangMenu
}

#------------------------------------------------------------
#  brief crée l'interface graphique de la fenêtre
#  param visuNo numéro de la visu
#
proc ::confChoixOutil::createDialog { visuNo } {
   variable This
   variable private
   variable widget
   global caption color conf panneau

   #--- Initialisation de variables
   set private(listePlugins)     ""
   set private(listeParMenu)     ""
   set private(pluginInitAudace) $conf(choixOutil,initAudace)
   set private(pluginUtilisable) $conf(choixOutil,utilisable)

   #--- Liste des raccourcis
   set private(listCombobox) [ list $caption(touche,pas_de_raccourci) \
      $caption(touche,F2) $caption(touche,F3) $caption(touche,F4) $caption(touche,F5) \
      $caption(touche,F6) $caption(touche,F7) $caption(touche,F8) $caption(touche,F9) \
      $caption(touche,F10) $caption(touche,F11) \
      $caption(touche,controle,A) $caption(touche,controle,B) $caption(touche,controle,C) \
      $caption(touche,controle,D) $caption(touche,controle,E) $caption(touche,controle,F) \
      $caption(touche,controle,G) $caption(touche,controle,H) $caption(touche,controle,I) \
      $caption(touche,controle,J) $caption(touche,controle,K) $caption(touche,controle,L) \
      $caption(touche,controle,M) $caption(touche,controle,N) $caption(touche,controle,P) \
      $caption(touche,controle,R) $caption(touche,controle,T) $caption(touche,controle,U) \
      $caption(touche,controle,V) $caption(touche,controle,W) $caption(touche,controle,X) \
      $caption(touche,controle,Y) $caption(touche,controle,Z) ]

   #--- Liste des menus deroulants
   set private(listeMenuDeroulant) [ list file display images analysis acquisition aiming setup ]

   #--- Liste des plugins de chaque menu
   foreach m [array names panneau menu_name,*] {
      lappend private(listePlugins) [ list [ ::confChoixOutil::ordreMenuDeroulant $m ] "$panneau($m) " $m ]
   }

   #--- Je copie la liste dans un tableau affiche(namespace)
   array set affiche $conf(choixOutil,utilisable)

   #--- Construction de la liste
   foreach m [lsort -dictionary $private(listePlugins)] {
      set namespace [lindex [lindex [ split $m "," ] 1] 0]
      if { [ info exist affiche($namespace) ] } {
         set private(affiche,$namespace)   [ lindex $affiche($namespace) 0 ]
         set private(raccourci,$namespace) [ lindex $affiche($namespace) 1 ]
      } else {
         set private(affiche,$namespace)   1
         set private(raccourci,$namespace) ""
      }
      set menuDeroulant [ ::$namespace\::getPluginProperty function ]
      set private($menuDeroulant,affiche,$namespace)   $private(affiche,$namespace)
      set private($menuDeroulant,raccourci,$namespace) $private(raccourci,$namespace)
      set plugin "$panneau(menu_name,$namespace)"
      lappend private(listeParMenu) [ list $menuDeroulant $plugin $namespace ]
   }

   #---
   if { [winfo exists $This] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm geometry $This $widget(confChoixOutil,geometry)
   wm minsize $This 596 364
   wm resizable $This 1 1
   wm title $This $caption(confgene,choix_outils)
   wm protocol $This WM_DELETE_WINDOW ::confChoixOutil::fermer

   #--- Creation des differents frames
   frame $This.frame0 -borderwidth 1 -relief raised
   pack $This.frame0 -side top -fill both -expand 1

   frame $This.frame1 -borderwidth 0 -relief raised
   pack $This.frame1 -in $This.frame0 -side top -fill both -expand 0

   frame $This.frame2 -borderwidth 0 -relief raised
   pack $This.frame2 -in $This.frame0 -side top -fill both -expand 1

   frame $This.frame3 -borderwidth 1 -relief raised
   pack $This.frame3 -side top -fill both -expand 0

   frame $This.frame4 -borderwidth 1 -relief raised
   pack $This.frame4 -side top -fill x

   #--- Cree le frame pour les commentaires
   label $This.lab1 -text "$caption(confgene,choix_outils_1)"
   pack $This.lab1 -in $This.frame1 -side top -fill both -expand 1 -padx 5 -pady 8

   #--- Ouvre le choix a l'affichage ou non des plugins dans les menus

   #--- Creation de la fenetre a onglets
   set notebook [ NoteBook $This.frame2.onglet ]

   fillConfigFile        file        [ $notebook insert end fillConfigFile        -text "$caption(confgene,file)  " \
                         -raisecmd "" ]
   fillConfigDisplay     display     [ $notebook insert end fillConfigDisplay     -text "$caption(confgene,display)  " \
                         -raisecmd "" ]
   fillConfigImages      images      [ $notebook insert end fillConfigImages      -text "$caption(confgene,images)  " \
                         -raisecmd "" ]
   fillConfigAnalysis    analysis    [ $notebook insert end fillConfigAnalysis    -text "$caption(confgene,analysis)  " \
                         -raisecmd "" ]
   fillConfigAcquisition acquisition [ $notebook insert end fillConfigAcquisition -text "$caption(confgene,acquisition)  " \
                         -raisecmd "" ]
   fillConfigAiming      aiming      [ $notebook insert end fillConfigAiming      -text "$caption(confgene,aiming)  " \
                         -raisecmd "" ]
   fillConfigSetup       setup       [ $notebook insert end fillConfigSetup       -text "$caption(confgene,setup)  " \
                         -raisecmd "" ]

   pack $notebook -fill both -expand 1 -padx 4 -pady 4

   $notebook raise [ $notebook page 0 ]

   #--- Cree le frame pour les commentaires
   label $This.labURL3 -text "$caption(confgene,choix_outils_2)" -fg $color(red)
   pack $This.labURL3 -in $This.frame3 -side bottom -fill both -expand 1 -padx 5 -pady 2

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
      -command "::confChoixOutil::ok $visuNo"
   if { $conf(ok+appliquer) == "1" } {
      pack $This.but_ok -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5
   }

   #--- Cree le bouton 'Appliquer'
   button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
      -command "::confChoixOutil::appliquer $visuNo"
   pack $This.but_appliquer -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Fermer'
   button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
      -command ::confChoixOutil::fermer
   pack $This.but_fermer -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Aide'
   button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
      -command ::confChoixOutil::afficheAide
   pack $This.but_aide -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> ::console::GiveFocus

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   #--- Je donne le temps au TK pour creer les checkbutton dans la tablelist
   update

   #--- Je mets a jour les checkbuttons qui sont coches ou decoches
   ::confChoixOutil::setCheckButtonValue1 $visuNo

   #--- Je mets a jour la valeur des checkbuttons des outils ayant une procedure initAudace
   ::confChoixOutil::setCheckButtonValue2 $visuNo
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Fichier
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigFile { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Fichier
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(file,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(file,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(file,table) xview" -orient horizontal
      ::tablelist::tablelist $private(file,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(file,table) columnconfigure 0 -name displayfile
      $private(file,table) columnconfigure 1 -name designationfile
      $private(file,table) columnconfigure 2 -name raccourcifile
      $private(file,table) columnconfigure 3 -name chargefile

      #--- Je place la table et les scrollbars dans la frame
      grid $private(file,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Affichage
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigDisplay { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 1 ] == "display" } {
         set plugin [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
      }
   }

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Affichage
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(display,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(display,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(display,table) xview" -orient horizontal
      ::tablelist::tablelist $private(display,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(display,table) columnconfigure 0 -name displaydisplay
      $private(display,table) columnconfigure 1 -name designationdisplay
      $private(display,table) columnconfigure 2 -name raccourcidisplay
      $private(display,table) columnconfigure 3 -name chargedisplay

      #--- Je place la table et les scrollbars dans la frame
      grid $private(display,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Images
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigImages { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "images" } {
         set plugin [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
      }
   }

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Images
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(images,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(images,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(images,table) xview" -orient horizontal
      ::tablelist::tablelist $private(images,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(images,table) columnconfigure 0 -name displayimages
      $private(images,table) columnconfigure 1 -name designationimages
      $private(images,table) columnconfigure 2 -name raccourciimages
      $private(images,table) columnconfigure 3 -name chargeimages

      #--- Je place la table et les scrollbars dans la frame
      grid $private(images,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Analyse
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigAnalysis { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "analysis" } {
         set plugin [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
      }
   }

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Analyse
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(analysis,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(analysis,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(analysis,table) xview" -orient horizontal
      ::tablelist::tablelist $private(analysis,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(analysis,table) columnconfigure 0 -name displayanalysis
      $private(analysis,table) columnconfigure 1 -name designationanalysis
      $private(analysis,table) columnconfigure 2 -name raccourcianalysis
      $private(analysis,table) columnconfigure 3 -name chargeanalysis

      #--- Je place la table et les scrollbars dans la frame
      grid $private(analysis,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Caméra
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigAcquisition { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "acquisition" } {
         set plugin [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
      }
   }

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Camera
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(acquisition,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(acquisition,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(acquisition,table) xview" -orient horizontal
      ::tablelist::tablelist $private(acquisition,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(acquisition,table) columnconfigure 0 -name displayacquisition
      $private(acquisition,table) columnconfigure 1 -name designationacquisition
      $private(acquisition,table) columnconfigure 2 -name raccourciacquisition
      $private(acquisition,table) columnconfigure 3 -name chargeacquisition

      #--- Je place la table et les scrollbars dans la frame
      grid $private(acquisition,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Télescope
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigAiming { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "aiming" } {
         set plugin [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
      }
   }

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Telescope
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(aiming,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(aiming,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(aiming,table) xview" -orient horizontal
      ::tablelist::tablelist $private(aiming,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(aiming,table) columnconfigure 0 -name displayaiming
      $private(aiming,table) columnconfigure 1 -name designationaiming
      $private(aiming,table) columnconfigure 2 -name raccourciaiming
      $private(aiming,table) columnconfigure 3 -name chargeaiming

      #--- Je place la table et les scrollbars dans la frame
      grid $private(aiming,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
#  brief crée l'onglet de configuration des outils du menu Configuration
#  param menuDeroulant nom du menu déroulant
#  param frm           chemin de l'onglet
#
proc ::confChoixOutil::fillConfigSetup { menuDeroulant frm } {
   variable private
   variable widget
   global caption

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "setup" } {
         set plugin [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
      }
   }

   #--- Je memorise la reference de la frame
   set widget(frm) $frm

   #--- Frame des outils du menu Configuration
   frame $widget(frm).frame1 -borderwidth 0 -relief raised

      set private(setup,table) $widget(frm).frame1.table
      scrollbar $widget(frm).frame1.ysb -command "$private(setup,table) yview"
      scrollbar $widget(frm).frame1.xsb -command "$private(setup,table) xview" -orient horizontal
      ::tablelist::tablelist $private(setup,table) \
         -columns [ list \
            11 $caption(confgene,affiche)     center \
            40 $caption(confgene,designation) left \
            20 $caption(confgene,raccourci)   center \
            16 $caption(confgene,charge)      center \
            ] \
         -xscrollcommand [list $widget(frm).frame1.xsb set] -yscrollcommand [list $widget(frm).frame1.ysb set] \
         -exportselection 0 \
         -setfocus 1 \
         -activestyle none

      #--- Je donne un nom a chaque colonne
      $private(setup,table) columnconfigure 0 -name displaysetup
      $private(setup,table) columnconfigure 1 -name designationsetup
      $private(setup,table) columnconfigure 2 -name raccourcisetup
      $private(setup,table) columnconfigure 3 -name chargesetup

      #--- Je place la table et les scrollbars dans la frame
      grid $private(setup,table) -row 0 -column 0 -sticky ewns
      grid $widget(frm).frame1.ysb -row 0 -column 1 -sticky nsew
      grid $widget(frm).frame1.xsb -row 1 -column 0 -sticky ew
      grid rowconfig    $widget(frm).frame1 0 -weight 1
      grid columnconfig $widget(frm).frame1 0 -weight 1

   pack $widget(frm).frame1 -side top -fill both -expand 1

   #--- Longueur de la liste
   set longList [ llength $private(listeParMenu) ]

   #--- Nom du plugin
   for { set k 0 } { $k <= $longList } { incr k } {
      if { [ lindex [ lindex $private(listeParMenu) $k ] 0 ] == "$menuDeroulant" } {
         set plugin    [ lindex [ lindex $private(listeParMenu) $k ] 1 ]
         set namespace [ lindex [ lindex $private(listeParMenu) $k ] 2 ]
         ajouteLigne $menuDeroulant $plugin $private(listCombobox) ::confChoixOutil::private($menuDeroulant,raccourci,$namespace) $namespace
      }
   }
}

#------------------------------------------------------------
## @brief crée le checkbutton de la 1ère colonne dans la table
#  @param menuDeroulant nom du menu déroulant
#  @param namespace     namespace de l'outil
#  @param tbl           nom Tk de la table
#  @param row           numéro de la ligne
#  @param col           numéro de la colonne
#  @param w             nom Tk du bouton
#
proc ::confChoixOutil::createCheckbutton1 { menuDeroulant namespace tbl row col w } {
   variable private

   checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::confChoixOutil::private($menuDeroulant,display,$namespace) -state normal

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------
## @brief crée le checkbutton de la 4ième colonne dans la table
#  @param menuDeroulant nom du menu déroulant
#  @param namespace     namespace de l'outil
#  @param tbl           nom Tk de la table
#  @param row           numéro de la ligne
#  @param col           numéro de la colonne
#  @param w             nom Tk du bouton
#
proc ::confChoixOutil::createCheckbutton2 { menuDeroulant namespace tbl row col w } {
   variable private

   checkbutton $w -highlightthickness 0 -takefocus 0 -variable ::confChoixOutil::private($menuDeroulant,load,$namespace) -state normal

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------
## @brief crée la combobox de la 3ième colonne dans la table
#  @param listCombobox    liste des valeurs possibles de la combobox
#  @param textvarComboBox nom de la variable contenant la valeur affichée
#  @param menuDeroulant   nom du menu déroulant
#  @param namespace       namespace de l'outil
#  @param tbl             nom Tk de la table
#  @param row             numéro de la ligne
#  @param col             numéro de la colonne
#  @param w               nom Tk du bouton
#
proc ::confChoixOutil::createComboBox { listCombobox textvarComboBox menuDeroulant namespace tbl row col w } {
   variable private
   global caption

   #--- ComboBox
   ComboBox $w \
      -width [ ::tkutil::lgEntryComboBox $listCombobox ] \
      -height 5 \
      -relief sunken      \
      -borderwidth 1      \
      -textvariable $textvarComboBox \
      -editable 0 \
      -values $private(listCombobox)

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $w
}

#------------------------------------------------------------
## @brief ajoute une ligne dans la table
#  @param menuDeroulant   nom du menu déroulant
#  @param plugin          nom de l'outil
#  @param listCombobox    liste des valeurs possibles de la combobox
#  @param textvarComboBox nom de la variable contenant la valeur affichée
#  @param namespace       namespace de l'outil
#
proc ::confChoixOutil::ajouteLigne { menuDeroulant plugin listCombobox textvarComboBox namespace } {
   variable private
   global caption

   #--- je cree la ligne
   if { [info commands "::$namespace\::initAudace" ] == "::$namespace\::initAudace" } {
      $private($menuDeroulant,table) insert end [ list "" $plugin "" "" ]
   } else {
      $private($menuDeroulant,table) insert end [ list "" $plugin "" $caption(confgene,nonApplicable) ]
   }
   #--- je nomme la ligne
   $private($menuDeroulant,table) rowconfigure end -name $namespace
   #--- je cree le checkbutton pour l'affichage de l'outil (coche par defaut)
   set private($menuDeroulant,display,$namespace) 1
   $private($menuDeroulant,table) cellconfigure end,display$menuDeroulant -window [ list ::confChoixOutil::createCheckbutton1 $menuDeroulant $namespace ]
   #--- je cree la combobox
   set private($menuDeroulant,raccourci,$namespace) ""
   $private($menuDeroulant,table) cellconfigure end,raccourci$menuDeroulant -window [ list ::confChoixOutil::createComboBox $listCombobox $textvarComboBox $menuDeroulant $namespace ]
   #--- je cree le checkbutton pour le chargement au démarrage de l'outil (decoche par defaut)
   set private($menuDeroulant,load,$namespace) 0
   if { [info commands "::$namespace\::initAudace" ] == "::$namespace\::initAudace" } {
      $private($menuDeroulant,table) cellconfigure end,charge$menuDeroulant -window [ list ::confChoixOutil::createCheckbutton2 $menuDeroulant $namespace ]
   }
}

#------------------------------------------------------------
## @brief met à jour les checkbuttons qui sont cochés ou décochés en
#  fonction de leurs états définis dans la variable private(pluginUtilisable)
#  @param visuNo numéro de la visu
#
proc ::confChoixOutil::setCheckButtonValue1 { visuNo } {
   variable private
   global conf panneau

   #--- Initialisation de variables
   set private(listeParMenu) ""

   #--- Je copie la liste dans un tableau affiche(namespace)
   array set affiche $conf(choixOutil,utilisable)

   #--- Construction de la liste
   foreach m [lsort -dictionary $private(listePlugins)] {
      set namespace [lindex [lindex [ split $m "," ] 1] 0]
      if { [ info exist affiche($namespace) ] } {
         set private(affiche,$namespace)   [ lindex $affiche($namespace) 0 ]
         set private(raccourci,$namespace) [ lindex $affiche($namespace) 1 ]
      } else {
         set private(affiche,$namespace)   1
         set private(raccourci,$namespace) ""
      }
      set menuDeroulant [ ::$namespace\::getPluginProperty function ]
      set private($menuDeroulant,affiche,$namespace)   $private(affiche,$namespace)
      set private($menuDeroulant,raccourci,$namespace) $private(raccourci,$namespace)
      set plugin "$panneau(menu_name,$namespace)"
      lappend private(listeParMenu) [ list $menuDeroulant $plugin $namespace ]
   }

   #--- je scanne chaque menu deroulant
   foreach menuDeroulant $private(listeMenuDeroulant) {
      #--- je scanne chaque ligne dans chaque menu deroulant
      for {set i 0 } { $i < [$private($menuDeroulant,table) size] } { incr i } {
         set namespace [$private($menuDeroulant,table) rowcget $i -name ]
         #--- je recupere le nomTK du checkbutton
         set w [$::confChoixOutil::private($menuDeroulant,table) windowpath $i,display$menuDeroulant ]
            #--- je recupere la valeur pour configurer le checkbutton
            foreach { namespace1 affiche_raccourci } $private(pluginUtilisable) {
               if { $namespace1 == $namespace } {
                  set private($menuDeroulant,display,$namespace) [ lindex $affiche_raccourci 0 ]
                  $w configure -variable ::confChoixOutil::private($menuDeroulant,display,$namespace)
               }
            }
      }
   }
}

#------------------------------------------------------------
## @brief met a jour la valeur des checkbuttons des outils ayant une procedure
#  initAudace si leurs noms est dans la variable private(pluginInitAudace)
#  ils sont cochés ou décochés en fonction de leurs états définis dans cette variable
#  @param visuNo numéro de la visu
#
proc ::confChoixOutil::setCheckButtonValue2 { visuNo } {
   variable private

   #--- je scanne chaque menu deroulant
   foreach menuDeroulant $private(listeMenuDeroulant) {
      #--- je scanne chaque ligne dans chaque menu deroulant
     for {set i 0 } { $i < [$private($menuDeroulant,table) size] } { incr i } {
         set namespace [$private($menuDeroulant,table) rowcget $i -name ]
         #--- je recupere le nomTK du checkbutton
         set w [$::confChoixOutil::private($menuDeroulant,table) windowpath $i,charge$menuDeroulant ]
         #--- je recupere la valeur pour configurer le checkbutton
         if { $w != "" } {
            foreach pluginInitAudace $private(pluginInitAudace) {
               if { $namespace == [ lindex $pluginInitAudace 2 ] } {
                  set private($menuDeroulant,load,$namespace) [ lindex $pluginInitAudace 3 ]
                  $w configure -variable ::confChoixOutil::private($menuDeroulant,load,$namespace)
               }
            }
         }
      }
   }
}

#------------------------------------------------------------
## @brief indique si le chargement de l'outil est autorisé
#  indique si la procédure initAudace doit être exécutée au démarrage d'Aud'ACE
#  @param toolNamespace nom du namespace de l'outil
#  @return 1 si le chargement est autorisé, sinon retourne 0
#
proc ::confChoixOutil::isInitAudaceEnabled { toolNamespace } {
   #--- Le parametre '-inline' permet de recuperer le 'tuple' au lieu de l'index
   set tuple [ lsearch -index 2 -inline $::conf(choixOutil,initAudace) $toolNamespace ]
   if { $tuple != "" } {
      set valeur [ lindex $tuple 3 ]
   } else {
      set valeur 0
   }
   return $valeur
}

#------------------------------------------------------------
## @brief ajoute un outil
#  cette procédure doit être exécutée que si la variable conf(choixOutil,utilisable) n'est pas vide
#  @param toolNamespace nom du namespace de l'outil
#  @param state         1 outil présent dans le menu déroulant, 0 outil absent
#  @param shortcut      touche raccourci de l'outil
#
proc ::confChoixOutil::addTool { toolNamespace state shortcut } {
   lappend ::conf(choixOutil,utilisable) [ string trimleft $toolNamespace "::" ] [ list $state $shortcut ]
}

#------------------------------------------------------------
## @brief ajoute un outil
#  cette procédure doit être exécutée que si la variable conf(choixOutil,utilisable) est vide
#  @param toolNamespace nom du namespace de l'outil
#  @param state         1 outil présent dans le menu déroulant, 0 outil absent
#  @param shortcut      touche raccourci de l'outil
#
proc ::confChoixOutil::addTool1 { toolNamespace state shortcut } {
   if { $::conf(choixOutil,utilisable) == "" } {
      lappend ::conf(choixOutil,utilisable) [ string trimleft $toolNamespace "::" ] [ list $state $shortcut ]
   }
}

#------------------------------------------------------------
## @brief supprime un outil
#  on supprime l'outil dans les 2 variables conf(choixOutil,utilisable) et conf(choixOutil,initAudace)
# @param toolNamespace nom du namespace de l'outil
#
proc ::confChoixOutil::removeTool { toolNamespace } {
   set toolNamespace [string trim $toolNamespace "::"]
   set index [ lsearch $::conf(choixOutil,utilisable) $toolNamespace ]
   if {$index != -1 } {
      set ::conf(choixOutil,utilisable) [ lreplace $::conf(choixOutil,utilisable) $index $index ]
      set ::conf(choixOutil,utilisable) [ lreplace $::conf(choixOutil,utilisable) $index $index ]
   }

   set index [ lsearch -index 2 $::conf(choixOutil,initAudace) $toolNamespace ]
   if {$index != -1 } {
      set ::conf(choixOutil,initAudace) [ lreplace $::conf(choixOutil,initAudace) $index $index ]
   }
}

#------------------------------------------------------------
## @brief affiche/masque l'interface graphique de l'outil affiché dans la visu
#  @param visuNo numéro de la visu
#
proc ::confChoixOutil::pasOutil { visuNo } {
   variable private
   global audace

   if { $::confVisu::private($visuNo,currentTool) != "" } {
      set private(currentTool) $::confVisu::private($visuNo,currentTool)
      ::confVisu::hidePanelTool $visuNo
   } elseif {[info exists private(currentTool)] eq "1" } {
      #--- Je relance automatiquement l'outil currentTool
      ::confVisu::selectTool $visuNo $private(currentTool)
   }
}

#------------------------------------------------------------
## @brief affiche automatiquement au démarrage d'Aud'ACE l'outil ayant F2 pour touche raccourci
#
proc ::confChoixOutil::afficheOutilF2 { } {
   global audace conf

   foreach { namespace affiche_raccourci } $conf(choixOutil,utilisable) {
      set raccourci [ lindex $affiche_raccourci 1 ]
      if { $raccourci == "F2" } {
         #--- Lancement automatique de l'outil ayant le raccourci F2
         ::confVisu::selectTool $audace(visuNo) ::$namespace
      }
   }
}

#--- Initialisation des variables conf(...)
::confChoixOutil::initConf


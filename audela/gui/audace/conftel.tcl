#
## @file conftel.tcl
#  @brief Gère les objets 'monture' (ex-objets 'telescope')
#  $Id: conftel.tcl 13696 2016-04-13 20:28:43Z michelpujol $
#

## 
#  @brief Gère les objets 'monture' (ex-objets 'telescope')
namespace eval ::confTel {
}

# @brief affiche la fenêtre de choix et de configuration des montures
#
proc ::confTel::run { } {
   variable private
   variable widget
   global conf

   set private(nomRaquette)   [::confPad::getCurrentPad]
   set widget(model,enabled)  $conf(telescope,model,enabled)
   set widget(model,fileName) $conf(telescope,model,fileName)
   set widget(model,name)     ""
   set widget(model,date)     ""

   set loadModelError [catch {
      if { $widget(model,fileName) != "" } {
         set result [loadModel  $conf(telescope,model,fileName)]
         set widget(model,name) [lindex $result 0]
         set widget(model,date) [lindex $result 1]
      }
   }]

   ::confTel::createDialog
   ::confTel::selectNotebook $conf(telescope)

   if { $loadModelError != 0 } {
      #--- je desactive le modele de pointage
      set widget(model,enabled) 0
      #--- je signale que le modèle n'est pas chargé
      ::tkutil::displayErrorInfo $::caption(conftel,config)
   }
}



## @brief initialise les variable conf(..) et caption(..)
#  @warning cette procédure est lancée automatiquement au chargement de ce fichier tcl
#  @details démarre le plugin sélectionné par défaut
#  @private
#
proc ::confTel::init { } {
   variable private
   global audace conf

   #--- Charge le fichier caption
   source [ file join $audace(rep_caption) conftel.cap ]

   #--- Initialise les variables de configuration
   ::confTel::initConf

   #--- Initalise le numero de la monture a nul
   set audace(telNo) "0"

   #--- Initialisation de variables
   set private(geometry)  $conf(telescope,geometry)
   set private(telNo)     "0"
   set private(mountName) ""

   #--- Initalise les listes de montures
   set private(nomRaquette) $conf(confPad)

   #--- j'ajoute le repertoire pouvant contenir des plugins
   lappend ::auto_path [file join "$::audace(rep_plugin)" mount]

   #--- Initialise les variables locales
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""
   set private(frm)                 "$audace(base).confTel"

   #--- je recherche les plugins presents
   ::confTel::findPlugin

   #--- je verifie que le plugin par defaut existe dans la liste
   if { [lsearch $private(pluginNamespaceList) $conf(telescope)] == -1 } {
      #--- s'il n'existe pas, je vide le nom du plugin par defaut
      set conf(telescope) ""
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Configuration de la monture"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(raquette)                 affichage de la raquette actif ou non
#  - conf(telescope)                nom de la monture
#  - conf(telescope,start)          indicateur de lancement au démarrage
#  - conf(telescope,geometry)       définit la position de la fenêtre
#  - conf(telescope,model,fileName) nom du modèle de pointage
#  - conf(telescope,model,enabled)  modèle de pointage actif ou non
#
#  @private
proc ::confTel::initConf { } {
   global conf

   if { ! [ info exists conf(raquette) ] }                 { set conf(raquette)                 "1" }
   if { ! [ info exists conf(telescope) ] }                { set conf(telescope)                "lx200" }
   if { ! [ info exists conf(telescope,start) ] }          { set conf(telescope,start)          "0" }
   if { ! [ info exists conf(telescope,geometry) ] }       { set conf(telescope,geometry)       "630x565+15+0" }
   if { ! [ info exists conf(telescope,model,fileName) ] } { set conf(telescope,model,fileName) "" }
   if { ! [ info exists conf(telescope,model,enabled) ] }  { set conf(telescope,model,enabled)  "" }
}

#------------------------------------------------------------
#  @brief commande du bouton "Ok"
#  @details mémorise et applique la configuration
#  et ferme la fenêtre de réglage
#  @private
proc ::confTel::ok { } {
   variable private

   $private(frm).cmd.ok configure -relief groove -state disabled
   $private(frm).cmd.appliquer configure -state disabled
   $private(frm).cmd.fermer configure -state disabled
   ::confTel::appliquer
   ::confTel::fermer
}

## @brief commande du bouton "Appliquer"
#  @details mémorise et applique la configuration
#  @private
proc ::confTel::appliquer { } {
   variable private

   $private(frm).cmd.ok configure -state disabled
   $private(frm).cmd.appliquer configure -relief groove -state disabled
   $private(frm).cmd.fermer configure -state disabled

   #--- J'arrete la monture
   ::confTel::stopPlugin
   #--- Je copie les parametres de la nouvelle monture dans conf()
   widgetToConf
   #--- Je configure la monture
   ::confTel::configureMonture

   $private(frm).cmd.ok configure -state normal
   $private(frm).cmd.appliquer configure -relief raised -state normal
   $private(frm).cmd.fermer configure -state normal
}

#  @brief commande du bouton "Aide"
#  @private
proc ::confTel::afficherAide { } {
   variable private

   #--- J'affiche la documentation
   set selectedPluginName [ $private(frm).usr.onglet raise ]
   set pluginTypeDirectory [ ::audace::getPluginTypeDirectory [ $selectedPluginName\::getPluginType ] ]
   set pluginHelp [ $selectedPluginName\::getPluginHelp ]
   ::audace::showHelpPlugin "$pluginTypeDirectory" "$selectedPluginName" "$pluginHelp"
}

## @brief commande du bouton "Fermer"
#  @private
proc ::confTel::fermer { } {
   variable private

   ::confTel::recupPosDim
   destroy $private(frm)
}

# @brief récupère et sauvegarde la position de la fenêtre de configuration de la caméra
# @private
proc ::confTel::recupPosDim { } {
   variable private
   global conf

   set private(geometry) [ wm geometry $private(frm) ]
   set conf(telescope,geometry) $private(geometry)
}

# @brief créé l'interface graphique
# @private
proc ::confTel::createDialog { } {
   variable private
   global caption conf

   if { [ winfo exists $private(frm) ] } {
      wm withdraw $private(frm)
      wm deiconify $private(frm)
      selectNotebook $conf(telescope)
      focus $private(frm)
      return
   }

   #--- Creation de la fenetre toplevel
   toplevel $private(frm)
   wm geometry $private(frm) $private(geometry)
   wm minsize $private(frm) 540 500
   wm resizable $private(frm) 1 1
   wm deiconify $private(frm)
   wm title $private(frm) $caption(conftel,config)
   wm protocol $private(frm) WM_DELETE_WINDOW ::confTel::fermer

   #--- Frame des boutons OK, Appliquer, Aide et Fermer
   frame $private(frm).cmd -borderwidth 1 -relief raised

      button $private(frm).cmd.ok -text "$caption(conftel,ok)" -relief raised -state normal -width 7 \
         -command { ::confTel::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $private(frm).cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
      }

      button $private(frm).cmd.appliquer -text "$caption(conftel,appliquer)" -relief raised -state normal -width 8 \
         -command { ::confTel::appliquer }
      pack $private(frm).cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.fermer -text "$caption(conftel,fermer)" -relief raised -state normal -width 7 \
         -command { ::confTel::fermer }
      pack $private(frm).cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

      button $private(frm).cmd.aide -text "$caption(conftel,aide)" -relief raised -state normal -width 7 \
         -command { ::confTel::afficherAide }
      pack $private(frm).cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x

   pack $private(frm).cmd -side bottom -fill x

   #--- Frame du bouton Arreter et du checkbutton creer au demarrage
   frame $private(frm).start -borderwidth 1 -relief raised

      button $private(frm).start.stop -text "$caption(conftel,arreter)" -width 7 \
         -command { ::confTel::stopPlugin }
      pack $private(frm).start.stop -side left -padx 3 -pady 3 -expand true

      checkbutton $private(frm).start.chk -text "$caption(conftel,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(telescope,start)
      pack $private(frm).start.chk -side left -padx 3 -pady 3 -expand true

   pack $private(frm).start -side bottom -fill x

   #--- Frame du modele de pointage
   frame $private(frm).model -borderwidth 1 -relief raised
      label $private(frm).model.title -text  $caption(conftel,model,title)
      pack $private(frm).model.title -side left -padx 3 -pady 3 -expand 0

      checkbutton $private(frm).model.enabled -text $caption(conftel,model,enabled) \
         -highlightthickness 0 -variable ::confTel::widget(model,enabled)
      pack $private(frm).model.enabled -side left -padx 3 -pady 3 -expand 0

      entry $private(frm).model.name -textvariable ::confTel::widget(model,name) \
         -state readonly
      pack $private(frm).model.name -side left -padx 3 -pady 3 -fill x -expand true

      entry $private(frm).model.date -textvariable ::confTel::widget(model,date) \
         -state readonly -width 19
      pack $private(frm).model.date -side left -padx 3 -pady 3 -expand false

      button $private(frm).model.configure -text $caption(conftel,configurer) \
         -command { ::confTel::selectModel }
      pack $private(frm).model.configure -side left -padx 3 -pady 3 -expand 0

   pack $private(frm).model -side bottom -fill x

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
}

## @brief créé un widget "label" avec une URL du site WEB
#
#  @param tkparent base Tk du widget
#  @param title titre
#  @param url url associée
#  @return chemin du widget
#  @private
proc ::confTel::createUrlLabel { tkparent title url } {
   global color

   label $tkparent.labURL -text "$title" -fg $color(blue)
   if { $url != "" } {
      bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   }
   bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

## @brief créé un widget "label" pour un document pdf
#  @param tkparent base Tk du widget
#  @param title titre
#  @param pdf nom court du pdf
#  @return chemin du widget
#  @private
proc ::confTel::createPdfLabel { tkparent title pdf } {
   global audace color

   set filename [ file join $audace(rep_plugin) mount audecom french $pdf ]
   label $tkparent.labURL -text "$title" -fg $color(blue)
   if { $pdf != "" } {
      bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Notice_pdf \"$filename\""
   }
   bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return  $tkparent.labURL
}

#------------------------------------------------------------
## @brief affiche un message d'alerte pendant la connexion de la caméra au démarrage
#
proc ::confTel::connectMonture { } {
   variable private
   global audace caption color

   if [ winfo exists $audace(base).connectMonture ] {
      destroy $audace(base).connectMonture
   }

   toplevel $audace(base).connectMonture
   wm resizable $audace(base).connectMonture 0 0
   wm title $audace(base).connectMonture "$caption(conftel,attention)"
   if { [ info exists private(frm) ] } {
      if { [ winfo exists $private(frm) ] } {
         set posx_connectMonture [ lindex [ split [ wm geometry $private(frm) ] "+" ] 1 ]
         set posy_connectMonture [ lindex [ split [ wm geometry $private(frm) ] "+" ] 2 ]
         wm geometry $audace(base).connectMonture +[ expr $posx_connectMonture + 50 ]+[ expr $posy_connectMonture + 100 ]
         wm transient $audace(base).connectMonture $private(frm)
      }
   } else {
      wm geometry $audace(base).connectMonture +200+100
      wm transient $audace(base).connectMonture $audace(base)
   }

   #--- Cree l'affichage du message
   label $audace(base).connectMonture.labURL_1 -text "$caption(conftel,connexion_texte1)" -fg $color(red)
   pack $audace(base).connectMonture.labURL_1 -padx 10 -pady 2
   label $audace(base).connectMonture.labURL_2 -text "$caption(conftel,connexion_texte2)" -fg $color(red)
   pack $audace(base).connectMonture.labURL_2 -padx 10 -pady 2

   #--- La nouvelle fenetre est active
   focus $audace(base).connectMonture

  #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $audace(base).connectMonture
}

#  @brief sélectionne un onglet
#  @param mountName nom de la monture
#  @private
proc ::confTel::selectNotebook { mountName } {
   variable private
   global conf

   #--- je recupere l'item courant
   if { $mountName == "" } {
      set mountName $conf(telescope)
   }

   if { $mountName != "" } {
      set frm [ $private(frm).usr.onglet getframe $mountName ]
      $private(frm).usr.onglet raise $mountName
   } elseif { [ llength $private(pluginNamespaceList) ] > 0 } {
      $private(frm).usr.onglet raise [ lindex $private(pluginNamespaceList) 0 ]
   }
}

#  @brief ouvre la monture dont le nom est dans la varialble globale \::conf(telescope)
#
proc ::confTel::startPlugin { } {
   variable private
   global conf

   if { $conf(telescope,start) == "1" } {
      set private(mountName) $conf(telescope)
      if { $private(mountName) != "" } {
         ::confTel::configureMonture
      }
   }
}

#  @brief ferme la monture ouverte
#
proc ::confTel::stopPlugin { } {
   variable private
   global audace

   #--- Je ferme la liaison
   if { $private(telNo) != "0" } {
      #--- Je ferme les ressources specifiques de la monture
      ::$private(mountName)::stop
      #--- Raz du numero de monture
      set private(telNo) "0"
      set audace(telNo)  $private(telNo)
      #--- Je supprime le label des visus
      foreach visuNo [ ::visu::list ] {
         ::confVisu::setMount $visuNo
      }
      #--- Je supprime l'association avec les cameras
      foreach camItem { A B C } {
         ::confCam::setMount $camItem $audace(telNo)
      }
   }
   set private(mountName) ""
}

## @brief configure la monture en fonction des données contenues dans le tableau conf(..)
#  @private
proc ::confTel::configureMonture { } {
   variable private
   global audace caption conf

   #--- Affichage d'un message d'alerte si necessaire
   ::confTel::connectMonture

   set catchResult [ catch {

      #--- Je configure la monture
      ::$private(mountName)::configureMonture

      #--- Je recupere telNo
      set private(telNo) [ ::$private(mountName)::getTelNo ]

      #--- Je configure le modèle de pointage
      set loadModelError [catch {
         if { $conf(telescope,model,enabled) == 1} {
            #--- je charge le modele
            setModelFileName $conf(telescope,model,fileName)
            #--- j'active le modele de pointage
            setModelEnabled $conf(telescope,model,enabled)

         } else {
            #--- je desactive le modele de pointage
            setModelEnabled $conf(telescope,model,enabled)
         }
      }]

       if { $loadModelError != 0 } {
          #--- je signale que le modèle n'est pas chargé
          ::tkutil::displayErrorInfo $::caption(conftel,config)
          #--- je continue sans le modele
          tel$private(telNo) radec model -enabled 0
       }

      #--- Mise a jour de la variable audace
      set audace(telNo) $private(telNo)

      #--- J'associe la monture avec les visus
      foreach visuNo [ ::visu::list ] {
         ::confVisu::setMount $visuNo
      }

      #--- J'associe la monture avec les cameras
      foreach camItem { A B C } {
         ::confCam::setMount $camItem $audace(telNo)
      }

      #--- Raffraichissement de la vitesse dans les raquettes et les outils, et de l'affichage des coordonnees
      if { $conf(raquette) == "1" } {
         #--- je cree la nouvelle raquette
         ::confPad::configurePlugin $private(nomRaquette)
      } else {
         ::confPad::stopPlugin
      }

   } errorMessage ]

   #--- Il n'y a pas d'erreur detectee par le catch
   if { $catchResult == "0" } {

      ::telescope::setSpeed "$audace(telescope,speed)"
      ::telescope::afficheCoord

   }

   #--- Il y a des erreurs detectees par le catch
   if { $catchResult != "0" } {

      #--- J'affiche le message d'erreur
      ::console::affiche_erreur "$::errorInfo\n\n"
      tk_messageBox -title "$caption(conftel,attention)" -icon error \
         -message "$errorMessage\n$caption(conftel,cannotcreatecam)\n$caption(conftel,seeconsole)"

      #--- Je desactive le demarrage automatique
      set conf(telescope,start) "0"

      #--- En cas de probleme, monture par defaut
      set private(mountName) ""
      set private(telNo)     "0"

   }

   #--- Effacement du message d'alerte s'il existe
   if [ winfo exists $audace(base).connectMonture ] {
      destroy $audace(base).connectMonture
   }
}

## @brief active/désactive le modèle de pointage du télescope
#  @param modelEnabled   0=désctive le modèle 1=active le modèle
#  @public cette procédure peut etre appelée depuis l'extérieur du namespace
#
proc ::confTel::setModelEnabled { modelEnabled } {
   variable private
   variable widget

   #--- j'active le modele de pointage
   if { $private(telNo) != 0 } {

      tel$private(telNo) radec model -enabled $modelEnabled \
   }

   set ::conf(telescope,model,enabled) $modelEnabled

   #--- j'affiche l'activation du modele si la fenetre de
   #--- configuration de la monture est ouverte
   if { [ winfo exists $private(frm) ] } {
      set widget(model,enabled) $modelEnabled
   }
}

## @brief configure le modele de pointage du telescope
#  @param modelFileName
#  @public  cette procédure peut etre appelée depuis l'extérieur du namespace
#
proc ::confTel::setModelFileName { modelFileName } {
   variable private
   variable widget

   set loadModelError [catch {
      tel$private(telNo) home $::audace(posobs,observateur,gps)
      tel$private(telNo) home name $::conf(posobs,nom_observatoire)

      #--- je charge le modele
      set result             [loadModel  $modelFileName ]
      set modelName          [lindex $result 0]
      set modelDate          [lindex $result 1]
      set modelSymbols       [lindex $result 4]
      set modelCoeffficients [lindex $result 5]
      set modelPressure      $::audace(meteo,obs,pressure)
      set modelTemperature   [ expr $::audace(meteo,obs,temperature) + 273.15 ]
      if { $private(telNo) != 0 } {
         #--- j'active le modele de pointage
         #--- j'active le modele de pointage
         tel$private(telNo) radec model \
            -name $modelName -date $modelDate \
            -pressure $modelPressure -temperature $modelTemperature \
            -symbols $modelSymbols -coefficients $modelCoeffficients ]
      }

      set ::conf(telescope,model,fileName) $modelFileName
      #--- j'affiche le nom et la date du modele dans les widgets si la fenetre de
      #--- configuration de la monture est ouverte
      if { [ winfo exists $private(frm) ] } {
         set widget(model,fileName) $modelFileName
         set widget(model,name)     $modelName
         set widget(model,date)     $modelDate
      }

   }]

    if { $loadModelError != 0 } {
       #--- je signale que le modèle n'est pas chargé
       ::tkutil::displayErrorInfo $::caption(conftel,config)
       if { $private(telNo) != 0 } {
          #--- je continue sans le modele
          tel$private(telNo) radec model -enabled 0
       }
    }
}

## @brief configure le modèle de pointage du télescope
#
#  @param modelEnabled  1= active le modèle de pointage , 0 = désactive le modèle de pointage 
#  @param modelName     nom du module de pointage (libellé libre)
#  @param modelDate     date de dernière modification du modèle de pointage (format ISO AAAA-MM-DDThh:mm:ss)
#  @param modelSymbols  liste des symboles utilisés dans le modèle de pointage (voir le menu: Modèle de pointage V2)
#  @param modelCoeffficients  liste des coefficients correspondant aux symboles 
#  @public  cette procédure peut être appelée depuis l'extérieur du namespace
#
proc ::confTel::configureModel { modelEnabled modelName modelDate modelSymbols modelCoeffficients } {
   variable private

   tel$private(telNo) home $::audace(posobs,observateur,gps)
   tel$private(telNo) home name $::conf(posobs,nom_observatoire)

   set modelPressure    $::audace(meteo,obs,pressure)
   set modelTemperature [ expr $::audace(meteo,obs,temperature) + 273.15 ]

   if { $modelEnabled == 1 } {
      #--- j'active le modele de pointage
      tel$private(telNo) radec model -enabled $modelEnabled \
         -name $modelName -date $modelDate \
         -pressure $modelPressure -temperature $modelTemperature \
         -symbols $modelSymbols -coefficients $modelCoeffficients ]

      set conf(telescope,model,enabled)  $modelEnabled
      set conf(telescope,model,fileName)  $modelEnabled

      #--- j'affiche le nom et la date du modele dans les widgets si la fenetre de
      #--- configuration de la monture est ouverte
      if { [ winfo exists $private(frm) ] } {
         set widget(model,enabled)  $modelEnabled
         set widget(model,fileName) ""
         set widget(model,name)     $modelName
         set widget(model,date)     $modelDate
      }

   } else {
      #--- je desactive le modele
      tel$private(telNo) radec model -enabled $modelEnabled
      set conf(telescope,model,enabled) $modelEnabled
      if { [ winfo exists $private(frm) ] } {
         set widget(model,enabled)      $modelEnabled
      }
   }
}

#  @brief récupère et sauvegarde les paramètres de configuration
#
#  @private
proc ::confTel::widgetToConf { } {
   variable private
   variable widget
   global conf

   #--- Memorise la configuration de la monture
   set mountName                      [ $private(frm).usr.onglet raise ]
   set private(mountName)             $mountName
   set conf(telescope)                $mountName
   set conf(telescope,model,fileName) $widget(model,fileName)
   if { $conf(telescope,model,fileName) == "" } {
      #--- je desactive le modele de pointage si aucun fichier n'est selectionne
      set widget(model,enabled)       0
   }
   set conf(telescope,model,enabled)  $widget(model,enabled)

   ::$private(mountName)::widgetToConf
}

## @brief retourne la valeur d'une propriété de la monture
#  @param propertyName : property name
#  @return valeur de la propriété
#
proc ::confTel::getPluginProperty { propertyName } {
   variable private

   # alignmentMode           Retourne le mode de fonctionnement de la monture (ALTAZ ou EQUATORIAL)
   # backlash                Retourne la possibilite de faire un rattrapage des jeux
   # guidingSpeed            Retourne les vitesses de guidage en arcseconde de degre par seconde de temps
   # hasCoordinates          Retourne la possibilite d'afficher les coordonnees
   # hasControlSuivi         Retourne la possibilite d'arreter le suivi sideral
   # hasRefractionCorrection Retourne la possibilite de calculer les corrections de refraction
   # hasGoto                 Retourne la possibilite de faire un Goto
   # hasManualMotion         Retourne la possibilite de faire des deplacement Nord, Sud, Est ou Ouest
   # hasMatch                Retourne la possibilite de faire un Match
   # hasModel                Retourne la possibilite d'avoir plusieurs modeles pour le meme product
   # hasMotionWhile          Retourne la possibilite d'avoir des deplacements cardinaux pendant une duree
   # hasPark                 Retourne la possibilite de parquer la monture
   # hasUnpark               Retourne la possibilite de de-parquer la monture
   # hasUpdateDate           Retourne la possibilite de mettre a jour la date et le lieu
   # multiMount              Retourne la possibilite de se connecter avec Ouranos (1 : Oui, 0 : Non)
   # name                    Retourne le modele de la monture
   # product                 Retourne le nom du produit

   #--- je recherche la valeur par defaut de la propriete
   #--- si la valeur par defaut de la propriete n'existe pas, je retourne une chaine vide
   switch $propertyName {
      alignmentMode           { set defaultResult EQUATORIAL }
      backlash                { set defaultResult 0 }
      guidingSpeed            { set defaultResult [list 1.0 1.0] }
      hasCoordinates          { set defaultResult 1 }
      hasControlSuivi         { set defaultResult 0 }
      hasGoto                 { set defaultResult 1 }
      hasManualMotion         { set defaultResult 1 }
      hasMatch                { set defaultResult 1 }
      hasModel                { set defaultResult 0 }
      hasMotionWhile          { set defaultResult 0 }
      hasPark                 { set defaultResult 0 }
      hasUnpark               { set defaultResult 0 }
      hasUpdateDate           { set defaultResult 0 }
      multiMount              { set defaultResult 0 }
      name                    { set defaultResult "" }
      product                 { set defaultResult "" }
      default                 { set defaultResult 0 }
   }

   #--- si aucune monture n'est selectionnee, je retourne la valeur par defaut
   if { $private(mountName) == "" } {
      return $defaultResult
   }

   #--- si une monture est selectionnee, je recherche la valeur propre a la monture
   switch $propertyName {
      alignmentMode           {
         return [ tel$private(telNo) alignmentmode ]
      }
      hasRefractionCorrection {
         return [ tel$private(telNo) refraction ]
      }
      default                 {
         set result [ ::$private(mountName)::getPluginProperty $propertyName ]
         if { $result != "" } {
            return $result
         } else {
            return $defaultResult
         }
      }
   }
}

## @brief indique si la monture est démarrée
#  @return Retourne "1" si la camera est démarree, sinon retourne "0"
#
proc ::confTel::isReady { } {
   variable private

   #--- Je verifie que la monture est prete
   if { $private(mountName) == "" } {
      set result "0"
   } else {
      set result [ ::$private(mountName)::isReady ]
   }
   return $result
}

## @brief recherche les plugins de type "mount"
#  @pre le plugin doit avoir une procedure getPluginType qui retourne "mount"
#  @pre le plugin doit avoir une procedure getPluginTitle
#  @remarks si le plugin remplit les conditions, son label est ajouté dans la liste pluginTitleList
#  et son namespace est ajouté dans pluginNamespaceList
#  sinon le fichier tcl est ignoré car ce n'est pas un plugin
#  @return 0 = OK, 1 = error (no plugin found)  . Le resultat est dans la variable privée private(pluginNamespaceList)
#
proc ::confTel::findPlugin { } {
   variable private
   global audace caption

   #--- j'initialise les listes vides
   set private(pluginNamespaceList) ""
   set private(pluginLabelList)     ""

   #--- je recherche les fichiers mount/*/pkgIndex.tcl
   set filelist [glob -nocomplain -type f -join "$audace(rep_plugin)" mount * pkgIndex.tcl ]
   foreach pkgIndexFileName $filelist {

      set catchResult [ catch {
         #--- je recupere le nom du package
         if { [ ::audace::getPluginInfo "$pkgIndexFileName" pluginInfo] == 0 } {
            if { $pluginInfo(type) == "mount" } {
               if { [ lsearch $pluginInfo(os) [ lindex $::tcl_platform(os) 0 ] ] != "-1" } {
                  #--- je charge le package
                  package require $pluginInfo(name)
                  #--- j'initalise le plugin
                  $pluginInfo(namespace)::initPlugin
                  set pluginlabel "[$pluginInfo(namespace)::getPluginTitle]"
                  #--- je l'ajoute dans la liste des plugins
                  lappend private(pluginNamespaceList) [ string trimleft $pluginInfo(namespace) "::" ]
                  lappend private(pluginLabelList) $pluginlabel
                  ::console::affiche_prompt "#$caption(conftel,mount) $pluginlabel v$pluginInfo(version)\n"
               }
            }
         } else {
            ::console::affiche_erreur "Error loading mount $pkgIndexFileName \n$::errorInfo\n\n"
         }
      } catchMessage ]

      #--- j'affiche le message d'erreur et je continue la recherche des plugins
      if { $catchResult !=0 } {
         ::console::affiche_erreur "::confTel::findPlugin $::errorInfo\n"
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

################################################################
#
# Modeles de pointage
#
################################################################

##------------------------------------------------------------
## @brief affiche une fenêtre pour sélectionner le modèle
#  @public
#
proc ::confTel::selectModel { } {
   variable private
   variable widget

   #--- j'ouvre la fenetre de selection du modele de pointage
   set initialdir [file join $::audace(rep_home) modpoi]
   if { ! [ file exist $initialdir ] } {
      #--- Si le repertoire modpoi n'existe pas, le creer
      file mkdir $initialdir
   }

   set fileName [ ::tkutil::box_load [winfo toplevel $private(frm)] $initialdir $::audace(bufNo) "10" ]
   if { $fileName != "" } {
      #--- je charge les donnees du modele de pointage
      set loadModelError [catch {
          if { $fileName != "" } {
             set result [loadModel  $fileName ]
             set widget(model,fileName) $fileName
             set widget(model,name) [lindex $result 0]
             set widget(model,date) [lindex $result 1]
          }
       }]

      if { $loadModelError != 0 } {
         #--- je desactive le modele de pointage
         set widget(model,enabled)  0
         set widget(model,fileName) ""
         set widget(model,name)     ""
         set widget(model,date)     ""
         #--- je signale que le modèle n'est pas chargé
         ::tkutil::displayErrorInfo $::caption(conftel,config)
      }
   }
}

##------------------------------------------------------------
## @brief charge un modèle à partir d'un fichier
#  @code Exemple ::confTel::loadModel  $::audace(rep_home)/modpoi/model_modpoi/test-juin-2009_synthese_17etoiles.txt
#  @endcode
#  @param fileName nom du fichier
#  @return liste contenant les informations du modele
#    * result[0] name
#    * result[1] date
#    * result[2] comment
#    * result[3] starList
#    * result[4] symbols
#    * result[5] coefficents
#    * result[6] chisquare
#    * result[7] covars
#    * result[8] refraction
#
proc ::confTel::loadModel { fileName } {

   package require dom

   #--- je charge les donnees du modele de pointage
   set modelName    ""
   set modelDate    ""
   set modelComment ""
   set starList     ""
   set symbols      ""
   set coefficients ""
   set covars       ""
   set chisquare    ""
   set refraction   0

   #--- je charge le fichier existant
   set hfile [open $fileName r]
   set data [read $hfile]
   close $hfile
   #--- je parse les données lues
   set catchError [ catch {
      set modelDom     [::dom::tcl::parse $data]
      set modelElement [::dom::tcl::document cget $modelDom -documentElement]
      #--- je recupere les attributs du modele
      set modelName    [file tail [file rootname $fileName]]
      set modelVersion [::dom::element getAttribute $modelElement "VERSION" ]
      set modelDate    [::dom::element getAttribute $modelElement "UT_DATE" ]
      set modelComment [::dom::element getAttribute $modelElement "COMMENT" ]

      #--- je recupere la liste des etoiles
      set starsNode [lindex [set [::dom::element getElementsByTagName $modelElement "STARS" ]] 0]
       if { $starsNode != "" } {
         foreach starNode [set [::dom::element getElementsByTagName $starsNode STAR ]] {
            set star ""
            lappend star [::dom::element getAttribute $starNode "AMER_AZ"]
            lappend star [::dom::element getAttribute $starNode "AMER_EL"]
            lappend star [::dom::element getAttribute $starNode "NAME"]
            lappend star [::dom::element getAttribute $starNode "CAT_RA"]
            lappend star [::dom::element getAttribute $starNode "CAT_DE"]
            lappend star [::dom::element getAttribute $starNode "CAT_EQUINOX"]
            lappend star [::dom::element getAttribute $starNode "OBS_DATE"]
            lappend star [::dom::element getAttribute $starNode "OBS_RA"]
            lappend star [::dom::element getAttribute $starNode "OBS_DE"]
            lappend star [::dom::element getAttribute $starNode "PRESSURE"]
            lappend star [::dom::element getAttribute $starNode "TEMPERATURE"]
            #--- j'ajoute l'etoile dans la liste des etoiles
            lappend starList $star
         }
      }

      set coeffsNode [lindex [set [::dom::element getElementsByTagName $modelElement "COEFFICIENTS" ]] 0]
      if { $coeffsNode != "" } {
         foreach coeffNode [set [::dom::element getElementsByTagName $coeffsNode COEFFICIENT ]] {
            lappend symbols [::dom::element getAttribute $coeffNode "SYMBOL"]
            lappend coefficients [::dom::element getAttribute $coeffNode "VALUE"]
            lappend covars [::dom::element getAttribute $coeffNode "COVAR"]
         }
         set chisquare [::dom::element getAttribute $coeffsNode "CHISQUARE"]
         set refraction [::dom::element getAttribute $coeffsNode "REFRACTION"]
      } else {
         ### TODO : calculer le modèle
      }
      ::dom::tcl::destroy $modelDom
   } catchMessage ]

   if { $catchError != 0 } {
      if { [string compare -length 14 $catchMessage "unexpectedtext"] == 0 } {
         #--- je charge le modele ancien format

         set catchResult [catch {
            set hFile [ open $fileName r ]
            set data [read $hFile]
            close $hFile
            set dataLen [llength $data ]
            if { $dataLen == 3 } {
               #--- j'ajoute l'indicateur de réfraction
               lappend $data "0"
            } elseif  { $dataLen == 4 } {
               #--- rien a faire

            } else {
               error "::confTel::loadModel error data length=$dataLen . Must be 3 or 4"
            }
            set modelName    [file tail $fileName]
            set modelDate    [clock format [file mtime $fileName] -format "%d-%m-%Y %H:%M:%S" -timezone :localtime ]
            set modelComment ""
            set symbols      {IH ID NP CH ME MA FO HF DAF TF}
            set coefficients [lindex $data 0]
            set chisquare    [lindex $data 1]
            set covars       [lindex $data 2]
            set refraction   [lindex $data 3]
         }]
         if { $catchResult == 1 } {
            #--- je transmet l'erreur
            error $::errorInfo
         }

         #--- je charge la liste des etoiles ancien format
         set catchResult [catch {
            set starFileName "[file rootname $fileName]_inp.txt"
            set input [ open [ file join $::audace(rep_plugin) tool modpoi model_modpoi $starFileName ] r ]
            set inputData [split [read $input] \n]
            close $input
            set starList ""
            set k 1
            foreach line $inputData {
               if { [llength $line] == 4 } {
                  set amerAz   "0"
                 set amerEl   "0"
                  set name     "star$k"
                  set date     ""
                  set ra_cal   ""
                  set dec_cal  [mc_angle2deg [lindex $line 1] 90]
                  set ra_delta [format "%8.3f" [lindex $line 2]]
                  set de_delta [format "%8.3f" [lindex $line 3]]
                  set ha_cal   [mc_angle2deg [lindex $line 0] 360]
                  lappend starList [list $amerAz $amerEl $name $date $ra_cal $dec_cal $ra_delta $de_delta $ha_cal]
                  incr k
               }
            }
         }]
         if { $catchResult == 1 } {
            #--- je ne transmets pas l'erreur car la liste des etoiles n'est pas indispensable
            set starList ""
         }
      } else {
         #--- je transmet l'erreur
         error $::errorInfo
      }
   }

   return [list $modelName $modelDate $modelComment $starList $symbols $coefficients $chisquare $covars $refraction]
}

## @brief ajoute une procédure à appeler si on change de monture
#  @param cmd : commande TCL à lancer quand la monture change
#
proc ::confTel::addMountListener { cmd } {
   trace add variable "::audace(telNo)" write $cmd
}

## @brief supprime une procédure à appeler si on change de monture
#  @param cmd : commande TCL à lancer quand la monture change
#
proc ::confTel::removeMountListener { cmd } {
   trace remove variable "::audace(telNo)" write $cmd
}


#--- Connexion au demarrage de la monture selectionnee par defaut
::confTel::init


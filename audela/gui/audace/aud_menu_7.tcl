#
## @file aud_menu_7.tcl
#  @brief Scripts regroupant les fonctionnalités du menu Configuration
#  $Id: aud_menu_7.tcl 14521 2018-10-24 14:29:29Z rzachantke $
#

## namespace cwdWindow
#  @brief configure les répertoires

namespace eval ::cwdWindow {

   #
   ## @brief Lance la fenêtre de dialogue pour la configuration des répertoires
   #  @param this chemin de la fenêtre
   #
   proc run { this } {
      variable This
      global audace conf caption cwdWindow

      #---
      set This $this
      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
      } else {

         initConf

         set cwdWindow(rep_geometry) $conf(rep_geometry)

         set cwdWindow(dir_images)                 [file nativename $::conf(rep_images)]
         set cwdWindow(rep_images,mode)            $::conf(rep_images,mode)
         set cwdWindow(rep_images,refModeAuto)     $::conf(rep_images,refModeAuto)
         set cwdWindow(rep_images,subdir)          $::conf(rep_images,subdir)
         set cwdWindow(dir_travail)                [file nativename $::audace(rep_travail)]
         set cwdWindow(travail_images)             $::conf(rep_travail,travail_images)

         ::cwdWindow::createWidgetVars

         #--   Identifie la longueur maximale des chemins
         set cwdWindow(long)    [string length $cwdWindow(dir_images)]
         if {[string length $cwdWindow(dir_scripts)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_scripts)]
         }
         if {[string length $cwdWindow(dir_travail)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_travail)]
         }
         if {[string length $cwdWindow(dir_archives)] > $cwdWindow(long)} {
            set cwdWindow(long) [string length $cwdWindow(dir_archives)]
         }

         #--- je calcule la date du jour (a partir de l'heure TU)
         if { $cwdWindow(rep_images,refModeAuto) == "0" } {
            set heure_nouveau_repertoire "0"
         } else {
            set heure_nouveau_repertoire "12"
         }
         set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
         if { $heure_courante < $heure_nouveau_repertoire } {
            #--- Si on est avant l'heure de changement, je prends la date de la veille
            set cwdWindow(sous_repertoire_date) [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y%m%d" ]
         } else {
            #--- Sinon, je prends la date du jour
            set cwdWindow(sous_repertoire_date) [ clock format [ clock seconds ] -format "%Y%m%d" ]
         }

         createDialog
      }
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de l'outil "Répertoires"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(rep_geometry) définit la position de la fenêtre
   #
   proc initConf { } {
      global conf

      if {[info exists conf(rep_geometry)] ==0} { set conf(rep_geometry) "500x500+450+210" }
   }

   #
   ## @brief créé les variables locales à partir de conf(rep_userCatalogList)
   #
   proc createWidgetVars { } {
      global cwdWindow

      #--   Construit la liste de la combobox
      set cwdWindow(catalogues) [list Base Catalogues]
      #--   Le nom des catalogues affiche dans la combobox est toujours en majuscules
      foreach catalog $::conf(rep_userCatalogList) {
         lappend cwdWindow(catalogues) [string toupper $catalog]
      }
	  
      #--   Liste les repertoires a verifier autres que images et travail
      #--   Alternance du suffixe du catalogue dans cwdWindow(dir_xxxx) et de celui dans audace(rep_yyyy)
      set cwdWindow(suffixes) [list scripts scripts archives archives catalogues userCatalog]
      foreach catalog $::conf(rep_userCatalogList) {
         #--   Le nom des variables cwdWindow(dir_cata_xxx) est entierement en minuscules
         #--   Le nom des variables conf(rep_userCatalogxxx) et audace(rep_userCatalogxxx)
         #     comporte une terminaison (celle de conf(rep_userCatalogList) commencant par une majuscule
         lappend cwdWindow(suffixes) "cata_[string tolower $catalog]" "userCatalog$catalog"
      }

      foreach {suffixe_dir suffixe_audace} $cwdWindow(suffixes) {
         if {[info exists ::audace(rep_$suffixe_audace)] eq "1"} {
            set cwdWindow(dir_$suffixe_dir) [file nativename $::audace(rep_$suffixe_audace)]
         }
      }
   }

   #
   #  brief créé l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption cwdWindow

      #--- Nom du sous-repertoire
      set date [clock format [clock seconds] -format "%y%m%d"]
      set cwdWindow(sous_repertoire) $date

      #---
      toplevel $This
      wm geometry $This $cwdWindow(rep_geometry)
      wm resizable $This 1 1
      wm title $This "$caption(cwdWindow,repertoire)"
      wm protocol $This WM_DELETE_WINDOW ::cwdWindow::cmdClose

      #--- Initialisation des variables de changement
      set cwdWindow(rep_images)      "0"
      set cwdWindow(rep_travail)     "0"
      set cwdWindow(rep_scripts)     "0"
      set cwdWindow(rep_userCatalog) "0"
      set cwdWindow(rep_archives)    "0"

      #--- Frame pour les repertoires
      frame $This.usr -borderwidth 0 -relief raised

         #--- Frame du repertoire images
         frame $This.usr.1 -borderwidth 1 -relief raised
            frame $This.usr.1.a -borderwidth 0 -relief raised
               label $This.usr.1.a.lab1 -text "$caption(cwdWindow,repertoire_images)"
               pack $This.usr.1.a.lab1 -side left -padx 5 -pady 3
               button $This.usr.1.a.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRep images $This.usr.1.a.ent1"
               pack $This.usr.1.a.explore -side right -padx 5 -pady 3 -ipadx 1
               entry $This.usr.1.a.ent1 -textvariable cwdWindow(dir_images) -width $cwdWindow(long)
               pack $This.usr.1.a.ent1 -side right -padx 4 -pady 3
            pack $This.usr.1.a -side top -fill both -expand 1
            #---
            frame $This.usr.1.subdir -borderwidth 0 -relief groove
               #--- pas de sous repertoire
               radiobutton $This.usr.1.subdir.noneButton -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,label_sous_rep,aucun)" \
                  -value "none" \
                  -variable cwdWindow(rep_images,mode) \
                  -command ::cwdWindow::changeState
               grid $This.usr.1.subdir.noneButton -row 0 -column 0 -sticky wn
               #--- sous repertoire manuel
               radiobutton $This.usr.1.subdir.manualButton -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,label_sous_rep,fixe)" \
                  -value "manual" \
                  -variable cwdWindow(rep_images,mode) \
                  -command ::cwdWindow::changeState
               grid $This.usr.1.subdir.manualButton -row 1 -column 0 -sticky wn
               #--- Entry nouveau sous-repertoire
               entry $This.usr.1.subdir.manualEntry -textvariable cwdWindow(sous_repertoire) -width 30
               grid $This.usr.1.subdir.manualEntry -row 1 -column 3 -sticky wn
               #--- sous repertoire automatique (date du jour)
               radiobutton $This.usr.1.subdir.dateButton -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,label_sous_rep,date)" \
                  -value "date" \
                  -variable cwdWindow(rep_images,mode) \
                  -command ::cwdWindow::changeState
               grid $This.usr.1.subdir.dateButton -row 2 -column 0 -sticky wn
               radiobutton $This.usr.1.subdir.changeDateButton0h -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,changement_0h)" \
                  -value "0" \
                  -variable cwdWindow(rep_images,refModeAuto) \
                  -command ::cwdWindow::changeDateJour
               grid $This.usr.1.subdir.changeDateButton0h -row 2 -column 1 -sticky wn
               radiobutton $This.usr.1.subdir.changeDateButton12h -highlightthickness 0 -state normal \
                  -text "$::caption(cwdWindow,changement_12h)" \
                  -value "12" \
                  -variable cwdWindow(rep_images,refModeAuto) \
                  -command ::cwdWindow::changeDateJour
               grid $This.usr.1.subdir.changeDateButton12h -row 2 -column 2 -sticky wn
               #--- Entry date sous-repertoire
               entry $This.usr.1.subdir.dateEntry -textvariable cwdWindow(sous_repertoire_date) -width 12 \
                  -state readonly
               grid $This.usr.1.subdir.dateEntry -row 2 -column 3 -sticky wn
            pack $This.usr.1.subdir -side top -fill x -padx 12
         pack $This.usr.1 -side top -fill both -expand 1

         #--- Frame du repertoire de travail
         frame $This.usr.1a -borderwidth 1 -relief raised
            frame $This.usr.1a.a -borderwidth 0 -relief raised
               label $This.usr.1a.a.lab1a -text "$caption(cwdWindow,repertoire_travail)"
               pack $This.usr.1a.a.lab1a -side left -padx 5 -pady 3
               button $This.usr.1a.a.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
                  -command "::cwdWindow::changeRep travail $This.usr.1a.a.ent1a"
               pack $This.usr.1a.a.explore -side right -padx 5 -pady 3 -ipadx 1
               entry $This.usr.1a.a.ent1a -textvariable cwdWindow(dir_travail) -width $cwdWindow(long)
               pack $This.usr.1a.a.ent1a -side right -padx 4 -pady 3
            pack $This.usr.1a.a -side top -fill both -expand 1
            frame $This.usr.1a.b -borderwidth 0 -relief raised
               checkbutton $This.usr.1a.b.check1 -text "$caption(cwdWindow,travail_images)" \
                  -highlightthickness 0 -variable cwdWindow(travail_images) \
                  -command ::cwdWindow::changeState
               pack $This.usr.1a.b.check1 -anchor w -side left -padx 20 -pady 5
            pack $This.usr.1a.b -side top -fill both -expand 1
         pack $This.usr.1a -side top -fill both -expand 1
         #--- Configuration des widgets du repertoire de travail
         ::cwdWindow::changeState

         #--- Frame du repertoire des scripts
         frame $This.usr.2 -borderwidth 1 -relief raised
            label $This.usr.2.lab2 -text "$caption(cwdWindow,repertoire_scripts)"
            pack $This.usr.2.lab2 -side left -padx 5 -pady 3
            button $This.usr.2.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command "::cwdWindow::changeRep scripts $This.usr.2.ent2"
            pack $This.usr.2.explore -side right -padx 5 -pady 3 -ipadx 1
            entry $This.usr.2.ent2 -textvariable cwdWindow(dir_scripts) -width $cwdWindow(long)
            pack $This.usr.2.ent2 -side right -padx 4 -pady 3
         pack $This.usr.2 -side top -fill both -expand 1

         #--- Frame du repertoire des archives
         frame $This.usr.3 -borderwidth 1 -relief raised
            label $This.usr.3.lab4 -text "$caption(cwdWindow,repertoire_archives)"
            pack $This.usr.3.lab4 -side left -padx 5 -pady 3
            button $This.usr.3.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command "::cwdWindow::changeRep archives $This.usr.3.ent4"
            pack $This.usr.3.explore -side right -padx 5 -pady 3 -ipadx 1
            entry $This.usr.3.ent4 -textvariable cwdWindow(dir_archives) -width $cwdWindow(long)
            pack $This.usr.3.ent4 -side right -padx 4 -pady 3
         pack $This.usr.3 -side top -fill both -expand 1

         #--- Frame commun
         frame $This.usr.4 -borderwidth 1 -relief raised
            label $This.usr.4.lab -text "$caption(cwdWindow,repertoire_catalogues)"
            pack $This.usr.4.lab -side left -padx 5 -pady 3
            ttk::combobox $This.usr.4.cat \
               -height [llength $cwdWindow(catalogues)] \
               -width [::tkutil::lgEntryComboBox $cwdWindow(catalogues)] \
               -justify center -state normal \
               -textvariable ::cwdWindow::cwdWindow(selected) \
               -values $cwdWindow(catalogues) \
               -validate focus -validatecommand "::cwdWindow::validCommand %P $This.usr.4"
            pack $This.usr.4.cat -side left -padx 5 -pady 3 -ipadx 1
            button $This.usr.4.explore -text "$caption(aud_menu_7,parcourir)" -width 1
            pack $This.usr.4.explore -side right -padx 5 -pady 3 -ipadx 1
            entry $This.usr.4.ent -textvariable cwdWindow(dir_selected) -width $cwdWindow(long)
            pack $This.usr.4.ent -side right -padx 4 -pady 3
            #--   Affiche le premier de la liste et actionne la commande
            $This.usr.4.cat set [lindex $cwdWindow(catalogues) 0]
            ::cwdWindow::displayRep $::cwdWindow::cwdWindow(selected) $This.usr.4

         pack $This.usr.4 -side top -fill both -expand 1

      pack $This.usr -side top -fill both -expand 1

      #--- Frame pour les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         button $This.cmd.ok -text "$caption(aud_menu_7,ok)" -width 7 \
            -command ::cwdWindow::cmdOk
         if { $::conf(ok+appliquer)=="1" } {
           pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         }
         button $This.cmd.appliquer -text "$caption(aud_menu_7,appliquer)" -width 8 \
            -command ::cwdWindow::cmdApply
         pack $This.cmd.appliquer -side left -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.fermer -text "$caption(aud_menu_7,fermer)" -width 7 \
            -command ::cwdWindow::cmdClose
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         button $This.cmd.aide -text "$caption(aud_menu_7,aide)" -width 7 \
            -command ::cwdWindow::afficheAide
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--   Affiche la fin du chemin
      foreach w [list $This.usr.1.a.ent1 $This.usr.2.ent2 $This.usr.1a.a.ent1a $This.usr.3.ent4] {
         $w xview moveto 1
      }

      #---
      bind $This <Key-Return> {::cwdWindow::cmdOk}
      bind $This <Key-Escape> {::cwdWindow::cmdClose}

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   ## @brief commande associée à la combobox "Répertoire des catalogues :"
   #  @param selected nom du catalogue sélectionné (Base, BOWELL, etc.)
   #  @param w chemin de la fenêtre (.audace.cwdWindow.usr.4)
   #
   proc validCommand { selected w } {
      global audace conf caption cwdWindow

      set change 1
      set erreur 0
      #--   Par defaut
      if {[info exists cwdWindow(previous_selected)] eq "0"} {
         set cwdWindow(previous_selected) "Base"
      }
      set selectAnterieur $cwdWindow(previous_selected)

      #--   Selectionne et formate le nom du catalogue dans les variables conf et audace (ex Loneos)
      if {$selected ne ""} {
         #--   Passe le nom en majuscules
         if {$selected ni [list Base Catalogues]} {
            set selected [string toupper $selected]
         }
         set v $selected
      } else {
         set v $selectAnterieur
      }
      set name [string toupper [string index $v 0]]
      append name [string tolower [string range $v 1 end]]

      if {$selected ne ""} {
         #--   Memorise le nom
         set cwdWindow(previous_selected) $selected
         if {$selected in $cwdWindow(catalogues)} {
            set change 0
         } else {
            #--   Cas de l'addition
            if {[regexp -all {[^a-zA-Z0-9_]} $selected] eq "0"} {
               #--   Complete la liste des catalogues
               lappend conf(rep_userCatalogList) $name
               #--   Initialise la variable une valeur non vide
               set conf(rep_userCatalog$name) $conf(rep_userCatalog)
            } else {
               set erreur 1
               #--   Message d'erreur si le nom comporte un caractere interdit
               tk_messageBox -message $caption(cwdWindow,mal_forme) \
                  -title "$caption(cwdWindow,boite_erreur)" -icon error
            }
         }

      } else {

         #--   Cas d'une suppression
         if {$selectAnterieur ni [list Base Catalogues 2MASS GAIA1 GAIA2 MICROCAT NOMAD1 PPMX PPMXL \
            USNOA2 USNOSA2 TYCHO2_FAST UCAC2 UCAC3 UCAC4 URAT1 BMK LONEOS TLE]} {

            #--   Supprime la variable conf
            if {[info exists conf(rep_userCatalog$name)] eq "1"} {
               unset conf(rep_userCatalog$name)
            }
            #--   Rafraichit la liste conf
            set i [lsearch -exact $conf(rep_userCatalogList) $name]
            set conf(rep_userCatalogList) [lreplace $conf(rep_userCatalogList) $i $i]
            set index [lsearch -exact $cwdWindow(catalogues) $selectAnterieur]
            set selected [lindex $cwdWindow(catalogues) [incr index -1]]
         } else {
            set erreur 1
            #--   Message d'erreur si suppression interdite
            tk_messageBox -message "$caption(cwdWindow,interdit)" \
               -title "$caption(cwdWindow,boite_erreur)" -icon error
         }
      }

      #--   Definit le nom a afficher dans la combobox
      if {$erreur eq "1"} {
         #--   Retablit la selection anterieure en cas d'erreur
         set value $selectAnterieur
      } else {
         set value $selected
      }
      #--   Debug
      #::console::disp "\nconf(rep_userCatalogList) $conf(rep_userCatalogList)\nname $name value $value\n"

      if {$change eq "1"} {
         #--   Rafraichit les variables audaces et cwdWindow
         ::cwdWindow::createWidgetVars
         #--   Reconfigure et actualise la combobox
         $w.cat configure -values $cwdWindow(catalogues) -height [llength $cwdWindow(catalogues)]
         $w.cat set $value
         update
      }

      ::cwdWindow::displayRep $value $w

      return 1
   }

   #
   ## @brief affiche le chemin du catalogue sélectionné par la combobox
   #  @param selected nom du catalogue sélectionné (Base, BOWELL, etc.)
   #  @param w        chemin TK
   #
   proc displayRep { selected { w .audace.cwdWindow.usr.4 } } {
      global cwdWindow

      #--   Identifie la variable ex dir_cata_ucac4
      if {$selected ne "Catalogues"} {
         set v cata_[string tolower $selected]
      } else {
         set v [string tolower $selected]
      }

      if {[info exists cwdWindow(dir_$v)] eq "1"} {
         #--   Affiche le chemin si la variable existe
         set cwdWindow(dir_selected) $cwdWindow(dir_$v)
         $w.ent xview moveto 1
      } else {
         set cwdWindow(dir_selected) ""
      }
      update

      #--   Modifie la commande du bouton [...]
      $w.explore configure -command "::cwdWindow::changeRep $v $w.ent"
   }

   #
   #  brief commande des radiobuttons de changement de date
   #  details initialise la date de changement de jour
   #
   proc changeDateJour { } {

      #--- je calcule la date du jour (a partir de l'heure TU)
      if { $::cwdWindow(rep_images,refModeAuto) == "0" } {
         set heure_nouveau_repertoire "0"
      } else {
         set heure_nouveau_repertoire "12"
      }
      set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
      if { $heure_courante < $heure_nouveau_repertoire } {
         #--- Si on est avant l'heure de changement, je prends la date de la veille
         set ::cwdWindow(sous_repertoire_date) [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y%m%d" ]
      } else {
         #--- Sinon, je prends la date du jour
         set ::cwdWindow(sous_repertoire_date) [ clock format [ clock seconds ] -format "%Y%m%d" ]
      }
   }

   #
   ## @brief commande des boutons "..." qui ouvre le navigateur pour choisir le répertoire
   #  @param nomRep suffixe de dir_ (images, travail, scripts, archives, cata_ucac4)
   #  @param w nom complet du widget contenant le chemin du répertoire
   #
   proc changeRep { nomRep w } {
      variable This
      global audace caption cwdWindow

      #--- Recupere la police par defaut des entry
      set cwdWindow(rep_font) $audace(font,Entry)
      #--- Transformation de la police en italique
      set cwdWindow(rep_font_italic) [ lreplace $cwdWindow(rep_font) 2 2 italic ]

      #---
      if {$nomRep in [list images travail scripts archives]} {
         set cwdWindow(rep_$nomRep) "1"
      } else {
         set cwdWindow(rep_userCatalog) "1"
      }

      #--   Met le chemin en italic et modifie l'apparence de la boite
      $w configure -font $cwdWindow(rep_font_italic) -relief solid

      #--   Definit le titre de la fenetre
      if {$nomRep in [list images travail scripts archives cata_base catalogues]} {
         set title $caption(cwdWindow,repertoire_$nomRep)
      } else {
         set name $::cwdWindow::cwdWindow(selected)
         set title [format $caption(cwdWindow,repertoire_cata) $name]
      }

      #--   Definit le repertoire pointe
      if {[info exists cwdWindow(dir_$nomRep)] eq "1"} {
         set initialdir [file normalize $cwdWindow(dir_$nomRep)]
      } else {
         set initialdir [file normalize $audace(rep_home)]
      }

      #--   Recupere le chemin
      set dir [file nativename [ ::cwdWindow::tkplus_chooseDir $initialdir $title $This ]]

      #--   Affecte le(s) chemin(s) si commande OK
      if {$dir ne "[file nativename $initialdir]"} {
         if {$nomRep in [list images travail scripts archives]} {
            set cwdWindow(dir_$nomRep) $dir
         } elseif {$nomRep eq "cata_base"} {
            set cwdWindow(dir_selected) $dir
            #--   Commande particuliere pour Base
            ::cwdWindow::getDirs
         } else {
            set cwdWindow(dir_$nomRep) $dir
            set cwdWindow(dir_selected) $dir
         }
         if {$cwdWindow(rep_images) eq "1" && $cwdWindow(travail_images) eq "1"} {
            set cwdWindow(dir_travail) $cwdWindow(dir_images)
         }
      }

      #--   Met le chemin en mode normal et modifie l'apparence de la boite
      $w configure -font $cwdWindow(rep_font) -relief sunken
      $w xview moveto 1
      focus $w
   }

   #
   #  brief recherche les répertoires de catalogues présents dans le répertoire de base
   #
   proc getDirs { } {
      global caption cwdWindow

      package require struct::set

      set baseDir $cwdWindow(dir_selected)
      if {$baseDir ne ""} {
         #--   Liste les repertoires dans le repertoire selectionne
         set repFound [glob -nocomplain -tails -dir $baseDir -type d *]

         #--   Liste les repertoires effectivement trouves
         set cataFound [::struct::set intersect $cwdWindow(catalogues) [string toupper $repFound]]

         foreach rep $cataFound {
            set pattern ($rep)
            regexp -nocase $pattern $repFound all name
            set dir [file join $baseDir $name]
            if {[glob -nocomplain -tails -dir $dir *] ne ""} {
               #--   Traite les repertoires non vides
               set cwdWindow(dir_cata_[string tolower $rep]) [file nativename $dir]
               #--   Debug
               ::console::disp "cwdWindow(dir_cata_[string tolower $rep]) $cwdWindow(dir_cata_[string tolower $rep])\n"
            } else {
               #--   Message d'erreur pour un repertoire vide
               ::console::affiche_erreur "[format $caption(cwdWindow,rep_vide) $dir]\n"
            }
         }
      }
   }

   #
   #  brief change l'état du widget : Disabled - Normal
   #
   proc changeState { } {
      variable This
      global cwdWindow

      if { $cwdWindow(travail_images) == "0" } {
         $This.usr.1a.a.ent1a configure -state normal
         $This.usr.1a.a.explore configure -state normal
         set cwdWindow(dir_travail) [ file nativename $::audace(rep_travail) ]
      } elseif { $cwdWindow(travail_images) == "1" } {
         $This.usr.1a.a.ent1a configure -state disabled
         $This.usr.1a.a.explore configure -state disabled
         switch $cwdWindow(rep_images,mode) {
            "none" {
               set dirName $cwdWindow(dir_images)
            }
            "manual" {
               set dirName [ file join $cwdWindow(dir_images) $cwdWindow(sous_repertoire) ]
            }
            "date" {
               set dirName [ file join $cwdWindow(dir_images) $cwdWindow(sous_repertoire_date) ]
            }
         }
         set cwdWindow(dir_travail) [ file nativename $dirName ]
      }
   }

   #
   #  brief navigateur pour le choix des répertoires
   #
   proc tkplus_chooseDir { inidir title parent } {
      global cwdWindow

      if {$inidir=="."} {
         set inidir [pwd]
      }
      if { $cwdWindow(rep_images) == "1" } {
         set cwdWindow(rep_images) "0"
      } elseif { $cwdWindow(rep_travail) == "1" } {
         set cwdWindow(rep_travail) "0"
      } elseif { $cwdWindow(rep_scripts) == "1" } {
         set cwdWindow(rep_scripts) "0"
      } elseif { $cwdWindow(rep_userCatalog) == "1" } {
         set cwdWindow(rep_userCatalog) "0"
      } elseif { $cwdWindow(rep_archives) == "1" } {
         set cwdWindow(rep_archives) "0"
      }
      set res [ tk_chooseDirectory -title "$title" -initialdir "$inidir" -parent "$parent" ]
      if {$res==""} {
         return "$inidir"
      } else {
         return "$res"
      }
   }

   #
   #  brief commande du bouton "OK"
   #
   proc cmdOk { } {
      if {[cmdApply] == 0} {
         cmdClose
      }
   }

   #
   ## @brief commade du bouton "Appliquer"
   #  @return
   #  - 0=OK
   #  - 1=erreur
   #
   proc cmdApply { } {
      global audace caption conf cwdWindow

      set nofault 0

      #--- Substituer les \ par des /
      set normalized_dir_images             [file normalize $cwdWindow(dir_images)]
      set normalized_dir_travail            [file normalize $cwdWindow(dir_travail)]

      #--   Par defaut, les repertoires sont identiques
      set conf(rep_travail,travail_images) $cwdWindow(travail_images)

      if {[::cwdWindow::verifFolder images] eq "0"} {
         return -1
      } else {
         switch $cwdWindow(rep_images,mode) {
            "none"   {  #--- rien a faire
                        set dirName $normalized_dir_images
                     }
            "manual" {  set dirName [file join $normalized_dir_images $cwdWindow(sous_repertoire) ]
                        if { ![file exists $dirName] } {
                           #--- je cree le repertoire
                           set catchError [catch {
                              file mkdir $dirName
                              set conf(rep_images,subdir) $cwdWindow(sous_repertoire)
                           }]
                           if { $catchError != 0 } {
                              ::tkutil::displayErrorInfo "$::caption(cwdWindow,label_sous_rep)"
                              return -1
                           }
                        }
                     }
            "date"   {  set dirName [file join $normalized_dir_images $cwdWindow(sous_repertoire_date) ]
                        if { ![file exists $dirName] } {
                           #--- je cree le repertoire
                           set catchError [catch { file mkdir $dirName  }]
                           if { $catchError != 0 } {
                              ::tkutil::displayErrorInfo "$::caption(cwdWindow,label_sous_rep)"
                              return -1
                           }
                        }
                     }
         }

         set conf(rep_images)             $normalized_dir_images
         set conf(rep_images,mode)        $cwdWindow(rep_images,mode)
         set conf(rep_images,refModeAuto) $cwdWindow(rep_images,refModeAuto)
         set audace(rep_images)           $dirName

         if { $conf(rep_travail,travail_images) == "1" } {
            set conf(rep_travail)         $audace(rep_images)
            set audace(rep_travail)       $audace(rep_images)
            set cwdWindow(dir_travail)    $audace(rep_images)
            #--- On se place dans le nouveau repertoire de travail
            cd $audace(rep_travail)
         } else {
            if {[::cwdWindow::verifFolder travail] eq "1"} {
               set audace(rep_travail) $normalized_dir_travail
               #--- On se place dans le nouveau repertoire de travail
               cd $audace(rep_travail)
            } else {
               return -1
            }
         }
      }

      #--   Verifie les repertoires autres que images et travail
      foreach {suffixe_dir suffixe_audace} $cwdWindow(suffixes) {
         #--- Substituer les \ par des /
         set normalized_dir [file normalize $cwdWindow(dir_$suffixe_dir)]
         #--- Verifie que le repertoire existe
         if {[::cwdWindow::verifFolder $suffixe_dir ] eq "1"} {
            set conf(rep_$suffixe_audace) $normalized_dir
            set audace(rep_$suffixe_audace) $normalized_dir
         } else {
            set nofault -1
            #--   Arrete a la premiere erreur
            break
         }
      }

      return $nofault
   }

   #
   #  brief vérifie l'existance du répertoire
   #  param suffixe_dir
   #  return
   #  - 1=OK
   #  - 0=erreur
   #
   proc verifFolder { suffixe_dir } {
      global caption cwdWindow

      set err 1
      set normalized_dir [file normalize $cwdWindow(dir_$suffixe_dir)]
      if {![file exists $normalized_dir] || ![file isdirectory $normalized_dir]} {
         tk_messageBox -message "[format $caption(cwdWindow,pas_repertoire) $cwdWindow(dir_$suffixe_dir)]"\
            -title "$caption(cwdWindow,boite_erreur)" -icon error
         set err 0
      }

      return $err
   }

   #
   #  brief commande du bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1020repertoire.htm"
   }

   #
   ## @brief commande du bouton "Fermer"
   #
   proc cmdClose { } {
      variable This
      global conf

      set conf(rep_geometry) [wm geometry $This]
      destroy $This
      unset This
   }

   #
   #  brief teste l'existence d'un répertoire avec création du répertoire s'il n'existe pas
   #
   proc updateImageDirectory { } {
      if { $::conf(rep_images,mode) == "date" } {
         #--- Je calcule la date du jour (a partir de l'heure TU)
         if { $::conf(rep_images,refModeAuto) == "0" } {
            set heure_nouveau_repertoire "0"
         } else {
            set heure_nouveau_repertoire "12"
         }
         set heure_courante [ lindex [ split $::audace(tu,format,hmsint) h ] 0 ]
         if { $heure_courante < $heure_nouveau_repertoire } {
            #--- Si on est avant l'heure de changement, je prends la date de la veille
            set ::cwdWindow(sous_repertoire_date) [ clock format [ expr { [ clock seconds ] - 86400 } ] -format "%Y%m%d" ]
         } else {
            #--- Sinon, je prends la date du jour
            set ::cwdWindow(sous_repertoire_date) [ clock format [ clock seconds ] -format "%Y%m%d" ]
         }

         #--- Substituer les \ par des /
         set normalized_dir_images [ file normalize $::conf(rep_images) ]

         #--- Creation du sous-repertoire du jour s'il n'existe pas
         set dirName [ file join $normalized_dir_images $::cwdWindow(sous_repertoire_date) ]
         if { ![ file exists $dirName ] } {
            #--- je cree le repertoire
            set catchError [catch {
               file mkdir $dirName
            }]
            if { $catchError != 0 } {
               ::tkutil::displayErrorInfo "$::caption(cwdWindow,label_sous_rep)"
               return
            }
         }
         set ::audace(rep_images) $dirName
      }
   }
}

########################### Fin du namespace cwdWindow ############################

## namespace confEditScript
#  @brief configure l'éditeur de scripts, le lecteur de fichiers pdf, de pages html et d'images

namespace eval ::confEditScript {

   #
   ## @brief créé la fenêtre de configuration de l'éditeur de scripts, de fichiers pdf, de pages html et d'images
   #  @param this chemin de la fenetre
   #
   proc run { this } {
      variable This
      global confgene

      set This $this

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      updateData
      createDialog
      focus $This

      if { [ info exists confgene(EditScript,geometry) ] } {
         wm geometry $This $confgene(EditScript,geometry)
      }

      tkwait visibility $This
      tkwait variable confgene(EditScript,ok)
      catch { destroy $This }

      return $confgene(EditScript,ok)
   }

   #
   ## @brief initialisation de variables dans aud.tcl \::audace::loadSetup pour le lancement d'Aud'ACE
   #
   proc initConf { } {
      global conf

      #--- Initialisation
      if { ! [ info exists conf(editsite_htm,selectHelp) ] } { set conf(editsite_htm,selectHelp) "0" }
   }

   #
   #  brief créé l'interface graphique
   #
   proc createDialog { } {
      variable This
      global audace caption conf confgene

      #--- Recuperation de la police par defaut des entry
      set confgene(EditScript,edit_font)        "$audace(font,Entry)"
      #--- Transformation de la police en italique
      set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
      #--- Changement de variable
      set confgene(EditScript,selectHelp)       "$conf(editsite_htm,selectHelp)"

      if { [ winfo exists $This ] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }
      toplevel $This
      wm resizable $This 0 0
      wm deiconify $This
      wm title $This "$caption(confeditscript,logiciels_externes)"
      wm geometry $This +180+50
      wm protocol $This WM_DELETE_WINDOW ::confEditScript::cmdClose

      #--- Ecriture du chemin d'un repertoire et du nom d'un lecteur
      if { $::tcl_platform(os) == "Linux" } {
         set confgene(EditScript,path) [ file join / usr bin ]
      } else {
         set defaultpath [ file join C: "Program Files" ]
         catch {
            set testpath "$::env(ProgramFiles)"
            set kend [expr [string length $testpath]-1]
            for {set k 0} {$k<=$kend} {incr k} {
               set car [string index "$testpath" $k]
               if {$car=="\\"} {
                  set testpath [string replace "$testpath" $k $k /]
               }
            }
            set defaultpath "$testpath"
            }
         set confgene(EditScript,path)  "$defaultpath"
         set confgene(EditScript,drive) [ lindex [ file split "$confgene(EditScript,path)" ] 0 ]
      }

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Editeur de scripts
      frame $This.usr1 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_script) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr1.lab1 -text "$caption(confeditscript,edit_script)"
         pack $This.usr1.lab1 -side left -padx 5 -pady 5
         button $This.usr1.explore1 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr1.ent1 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_script) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "6" ]
               if { $confgene(EditScript,edit_script) == "" } {
                  set confgene(EditScript,edit_script) $conf(editscript)
               }
               focus $::confEditScript::This.usr1
               $::confEditScript::This.usr1.ent1 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr1.explore1 -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr1.ent1 -textvariable confgene(EditScript,edit_script) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr1.ent1 -side right -padx 5 -pady 5
      pack $This.usr1 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Editeur de documents pdf
      frame $This.usr2 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_pdf) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr2.lab2 -text "$caption(confeditscript,notice_pdf)"
         pack $This.usr2.lab2 -side left -padx 5 -pady 5
         button $This.usr2.explore2 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr2.ent2 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_pdf) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "7" ]
               if { $confgene(EditScript,edit_pdf) == "" } {
                  set confgene(EditScript,edit_pdf) $conf(editnotice_pdf)
               }
               focus $::confEditScript::This.usr2
               $::confEditScript::This.usr2.ent2 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr2.explore2 -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr2.ent2 -textvariable confgene(EditScript,edit_pdf) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr2.ent2 -side right -padx 5 -pady 5
      pack $This.usr2 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Navigateur de pages htm
      frame $This.usr3 -borderwidth 1 -relief raised
         frame $This.usr3.top -borderwidth 0 -relief raised
            #--- Positionne le bouton ... et la zone a renseigner
            if { $confgene(EditScript,error_htm) == "1" } {
               set font $confgene(EditScript,edit_font)
               set relief "sunken"
            } else {
               set font $confgene(EditScript,edit_font_italic)
               set relief "solid"
            }
            label $This.usr3.top.lab3 -text "$caption(confeditscript,navigateur_htm)"
            pack $This.usr3.top.lab3 -side left -padx 5 -pady 5
            button $This.usr3.top.explore3 -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command {
                  #--- Recuperation de la police par defaut des entry
                  set confgene(EditScript,edit_font)        "$audace(font,Entry)"
                  #--- Transformation de la police en italique
                  set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
                  #---
                  $::confEditScript::This.usr3.top.ent3 configure -font $confgene(EditScript,edit_font_italic) -relief solid
                  set fenetre "$::confEditScript::This"
                  set confgene(EditScript,edit_htm) \
                     [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "8" ]
                  if { $confgene(EditScript,edit_htm) == "" } {
                     set confgene(EditScript,edit_htm) $conf(editsite_htm)
                  }
                  focus $::confEditScript::This.usr3
                  $::confEditScript::This.usr3.top.ent3 configure -font $confgene(EditScript,edit_font) -relief sunken
               }
            pack $This.usr3.top.explore3 -side right -padx 5 -pady 5 -ipady 5
            entry $This.usr3.top.ent3 -textvariable confgene(EditScript,edit_htm) -width $confgene(EditScript,long) \
               -font $font -relief $relief
            pack $This.usr3.top.ent3 -side right -padx 5 -pady 5
         pack $This.usr3.top -side top -fill x -expand 1
         frame $This.usr3.bottom -borderwidth 0 -relief raised
            checkbutton $This.usr3.bottom.selectHelp -text "$caption(confeditscript,selectHelp)" \
               -highlightthickness 0 -variable confgene(EditScript,selectHelp)
            pack $This.usr3.bottom.selectHelp -anchor w -side bottom -padx 20 -pady 5
         pack $This.usr3.bottom -side top -fill x -expand 1
      pack $This.usr3 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Visualiseur d'images
      frame $This.usr4 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_viewer) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr4.lab4 -text "$caption(confeditscript,viewer)"
         pack $This.usr4.lab4 -side left -padx 5 -pady 5
         button $This.usr4.explore4 -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr4.ent4 configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,edit_viewer) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "9" ]
               if { $confgene(EditScript,edit_viewer) == "" } {
                  set confgene(EditScript,edit_viewer) $conf(edit_viewer)
               }
               focus $::confEditScript::This.usr4
               $::confEditScript::This.usr4.ent4 configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr4.explore4 -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr4.ent4 -textvariable confgene(EditScript,edit_viewer) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr4.ent4 -side right -padx 5 -pady 5
      pack $This.usr4 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Java
      frame $This.usr5 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_java) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr5.lab -text "$caption(confeditscript,exec_java)"
         pack $This.usr5.lab -side left -padx 5 -pady 5
         button $This.usr5.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr5.ent configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,exec_java) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "12" ]
               if { $confgene(EditScript,exec_java) == "" } {
                  set confgene(EditScript,exec_java) $conf(exec_java)
               }
               focus $::confEditScript::This.usr5
               $::confEditScript::This.usr5.ent configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr5.explore -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr5.ent -textvariable confgene(EditScript,exec_java) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr5.ent -side right -padx 5 -pady 5
      pack $This.usr5 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Aladin
      frame $This.usr6 -borderwidth 1 -relief raised
         #--- Positionne le bouton ... et la zone a renseigner
         if { $confgene(EditScript,error_aladin) == "1" } {
            set font $confgene(EditScript,edit_font)
            set relief "sunken"
         } else {
            set font $confgene(EditScript,edit_font_italic)
            set relief "solid"
         }
         label $This.usr6.lab -text "$caption(confeditscript,exec_aladin)"
         pack $This.usr6.lab -side left -padx 5 -pady 5
         button $This.usr6.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
            -command {
               #--- Recuperation de la police par defaut des entry
               set confgene(EditScript,edit_font)        "$audace(font,Entry)"
               #--- Transformation de la police en italique
               set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
               #---
               $::confEditScript::This.usr6.ent configure -font $confgene(EditScript,edit_font_italic) -relief solid
               set fenetre "$::confEditScript::This"
               set confgene(EditScript,exec_aladin) \
                  [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "13" ]
               if { $confgene(EditScript,exec_aladin) == "" } {
                  set confgene(EditScript,exec_aladin) $conf(exec_aladin)
               }
               focus $::confEditScript::This.usr6
               $::confEditScript::This.usr6.ent configure -font $confgene(EditScript,edit_font) -relief sunken
            }
         pack $This.usr6.explore -side right -padx 5 -pady 5 -ipady 5
         entry $This.usr6.ent -textvariable confgene(EditScript,exec_aladin) -width $confgene(EditScript,long) \
            -font $font -relief $relief
         pack $This.usr6.ent -side right -padx 5 -pady 5
      pack $This.usr6 -side top -fill both -expand 1

      #--- Cree un frame pour y mettre le bouton ... et la zone a renseigner - Iris (pour Windows uniquement)
      if { $::tcl_platform(os) == "Windows NT" } {
         frame $This.usr7 -borderwidth 1 -relief raised
            #--- Positionne le bouton ... et la zone a renseigner
            if { $confgene(EditScript,error_iris) == "1" } {
               set font $confgene(EditScript,edit_font)
               set relief "sunken"
            } else {
               set font $confgene(EditScript,edit_font_italic)
               set relief "solid"
            }
            label $This.usr7.lab -text "$caption(confeditscript,exec_iris)"
            pack $This.usr7.lab -side left -padx 5 -pady 5
            button $This.usr7.explore -text "$caption(aud_menu_7,parcourir)" -width 1 \
               -command {
                  #--- Recuperation de la police par defaut des entry
                  set confgene(EditScript,edit_font)        "$audace(font,Entry)"
                  #--- Transformation de la police en italique
                  set confgene(EditScript,edit_font_italic) [ lreplace $confgene(EditScript,edit_font) 2 2 italic ]
                  #---
                  $::confEditScript::This.usr7.ent configure -font $confgene(EditScript,edit_font_italic) -relief solid
                  set fenetre "$::confEditScript::This"
                  set confgene(EditScript,exec_iris) \
                     [ ::tkutil::box_load $fenetre ${confgene(EditScript,path)} $audace(bufNo) "12" ]
                  if { $confgene(EditScript,exec_iris) == "" } {
                     set confgene(EditScript,exec_iris $conf(exec_iris)
                  }
                  focus $::confEditScript::This.usr7
                  $::confEditScript::This.usr7.ent configure -font $confgene(EditScript,edit_font) -relief sunken
               }
            pack $This.usr7.explore -side right -padx 5 -pady 5 -ipady 5
            entry $This.usr7.ent -textvariable confgene(EditScript,exec_iris) -width $confgene(EditScript,long) \
               -font $font -relief $relief
            pack $This.usr7.ent -side right -padx 5 -pady 5
         pack $This.usr7 -side top -fill both -expand 1
      }

      #--- Cree un frame pour y mettre les boutons
      frame $This.cmd -borderwidth 1 -relief raised
         #--- Cree le bouton 'OK'
         button $This.cmd.ok -text "$caption(aud_menu_7,ok)" -width 7 -command ::confEditScript::cmdOk
         pack $This.cmd.ok -side left -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Fermer'
         button $This.cmd.fermer -text "$caption(aud_menu_7,fermer)" -width 7 -command ::confEditScript::cmdClose
         pack $This.cmd.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x
         #--- Cree le bouton 'Aide'
         button $This.cmd.aide -text "$caption(aud_menu_7,aide)" -width 7 -command ::confEditScript::afficheAide
         pack $This.cmd.aide -side right -padx 3 -pady 3 -ipady 5 -fill x
      pack $This.cmd -side top -fill x

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   #  brief mise à jour automatique de la longueur des entry
   #
   proc updateData { } {
      global conf confgene

      catch {
         set confgene(EditScript,edit_script) $conf(editscript)
         set confgene(EditScript,long)        [ string length $confgene(EditScript,edit_script) ]
      }
      if { ! [ info exists confgene(EditScript,edit_script) ] } { set confgene(EditScript,long) "30" }
      catch {
         set confgene(EditScript,edit_pdf) $conf(editnotice_pdf)
         set confgene(EditScript,long_pdf) [ string length $confgene(EditScript,edit_pdf) ]
      }
      if { ! [ info exists confgene(EditScript,edit_pdf) ] } { set confgene(EditScript,long_pdf) "30" }
      catch {
         set confgene(EditScript,edit_htm) $conf(editsite_htm)
         set confgene(EditScript,long_htm) [ string length $confgene(EditScript,edit_htm) ]
      }
      if { ! [ info exists confgene(EditScript,edit_htm) ] } { set confgene(EditScript,long_htm) "30" }
      catch {
         set confgene(EditScript,edit_viewer) $conf(edit_viewer)
         set confgene(EditScript,long_viewer) [ string length $confgene(EditScript,edit_viewer) ]
      }
      if { ! [ info exists confgene(EditScript,edit_viewer) ] } { set confgene(EditScript,long_viewer) "30" }
      catch {
         set confgene(EditScript,exec_java) $conf(exec_java)
         set confgene(EditScript,long_java) [ string length $confgene(EditScript,exec_java) ]
      }
      if { ! [ info exists confgene(EditScript,exec_java) ] } { set confgene(EditScript,long_java) "30" }
      catch {
         set confgene(EditScript,exec_aladin) $conf(exec_aladin)
         set confgene(EditScript,long_aladin) [ string length $confgene(EditScript,exec_aladin) ]
      }
      if { ! [ info exists confgene(EditScript,exec_aladin) ] } { set confgene(EditScript,long_aladin) "30" }
      if { $::tcl_platform(os) == "Windows NT" } {
         catch {
            set confgene(EditScript,exec_iris) $conf(exec_iris)
            set confgene(EditScript,long_iris) [ string length $confgene(EditScript,exec_iris) ]
         }
         if { ! [ info exists confgene(EditScript,exec_iris) ] } { set confgene(EditScript,long_iris) "30" }
      }

      if { $confgene(EditScript,long_pdf) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_pdf)
      }
      if { $confgene(EditScript,long_htm) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_htm)
      }
      if { $confgene(EditScript,long_viewer) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_viewer)
      }
      if { $confgene(EditScript,long_java) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_java)
      }
      if { $confgene(EditScript,long_aladin) > $confgene(EditScript,long) } {
         set confgene(EditScript,long) $confgene(EditScript,long_aladin)
      }
      if { $::tcl_platform(os) == "Windows NT" } {
         if { $confgene(EditScript,long_iris) > $confgene(EditScript,long) } {
            set confgene(EditScript,long) $confgene(EditScript,long_iris)
         }
      }
      set confgene(EditScript,long) [expr $confgene(EditScript,long) + 3]
   }

   #
   #  brief procédure correspondant à la fermeture de la fenêtre
   #
   proc destroyDialog { } {
      variable This
      global confgene

      set confgene(EditScript,geometry) [ wm geometry $This ]
      destroy $This
      unset This
   }

   #
   ## @brief commande du bouton "OK"
   #
   proc cmdOk { } {
      global conf confgene

      #---
      set conf(editscript)                  "$confgene(EditScript,edit_script)"
      set conf(editnotice_pdf)              "$confgene(EditScript,edit_pdf)"
      set conf(editsite_htm)                "$confgene(EditScript,edit_htm)"
      set conf(editsite_htm,selectHelp)     "$confgene(EditScript,selectHelp)"
      set conf(edit_viewer)                 "$confgene(EditScript,edit_viewer)"
      set conf(exec_java)                   "$confgene(EditScript,exec_java)"
      set conf(exec_aladin)                 "$confgene(EditScript,exec_aladin)"
      if { $::tcl_platform(os) == "Windows NT" } {
         set conf(exec_iris)                "$confgene(EditScript,exec_iris)"
      }
      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      set confgene(EditScript,error_iris)   "1"
      #---
      set confgene(EditScript,ok)           "1"
      ::confEditScript::destroyDialog
   }

   #
   #  brief commande du bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1030logiciels_externes.htm"
   }

   #
   ## @brief commande du bouton "Fermer"
   #
   proc cmdClose { } {
      global confgene

      #---
      set confgene(EditScript,error_script) "1"
      set confgene(EditScript,error_pdf)    "1"
      set confgene(EditScript,error_htm)    "1"
      set confgene(EditScript,error_viewer) "1"
      set confgene(EditScript,error_java)   "1"
      set confgene(EditScript,error_aladin) "1"
      set confgene(EditScript,error_iris)   "1"
      #---
      set confgene(EditScript,ok)           "0"
      ::confEditScript::destroyDialog
   }

}

######################### Fin du namespace confEditScript #########################

## namespace audace

namespace eval ::audace {

   #
   ## @brief demande la confirmation pour enregistrer la configuration
   #
   proc enregistrerConfiguration { } {
      variable private
      global audace caption conf

      #---
      menustate disabled
      #--- Positions et tailles des fenetres
      #--- Je recupere les visuNo des visu ouvertes
      set list_visuNo [list ]
      foreach visuNo [::visu::list] {
         lappend list_visuNo "$visuNo"
      }
      foreach visuNo $list_visuNo {
         if { $visuNo == 1 } {
           set conf(audace,visu$visuNo,wmgeometry) [ wm geometry $audace(base) ]
         } else {
            set conf(audace,visu$visuNo,wmgeometry) [ wm geometry $::confVisu::private($visuNo,This) ]
         }
      }
      set conf(console,wmgeometry) [ wm geometry $audace(Console) ]

      #---
      set filename [ file join $::audace(rep_home) audace.ini ]
      set filebak  [ file join $::audace(rep_home) audace.bak ]
      set filename2 $filename
      catch {
         file copy -force $filename $filebak
      }
      array set file_conf [ini_getArrayFromFile $filename]

      if {[ini_fileNeedWritten file_conf conf]} {
         set choice [ tk_messageBox -message "$caption(audace,enregistrer_config3)" \
            -title "$caption(audace,enregistrer_config1)" -icon question -type yesno ]
         if { $choice == "yes" } {
            #--- Enregistrer la configuration
            ini_writeIniFile $filename2 conf
         } elseif {$choice=="no"} {
            #--- Pas d'enregistrement
            ::console::affiche_resultat "$caption(audace,enregistrer_config2)\n\n"
         }
      } else {
         #--- Pas d'enregistrement
         ::console::affiche_resultat "$caption(audace,enregistrer_config2)\n\n"
      }
      #---
      menustate normal
      #---
      focus $audace(base)
   }

}

############################# Fin du namespace audace #############################


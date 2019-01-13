#
## @file viseur_polaire_eq6.tcl
#  @brief Positionne l'étoile polaire dans un viseur polaire de type EQ6 ou à constellations
#  @author Robert DELMAS
#  $Id: viseur_polaire_eq6.tcl 13587 2016-04-03 05:43:48Z robertdelmas $
#

#------------------------------------------------------------
## @brief Crée la fenêtre du viseur polaire EQ6
#  @param this Chemin de la fenêtre
#
proc ::viseur_polaire::runEQ6 { this } {
   variable widget

   #--- Cree les variables dans conf(...) si elles n'existent pas
   ::viseur_polaire::initConfEQ6
   #--- Recupere les variables dans conf(...) si elles existent
   ::viseur_polaire::confToWidgetEQ6
   #---
   set widget(viseur_polaire_eq6,This) $this
   if { [ winfo exists $widget(viseur_polaire_eq6,This) ] } {
      wm withdraw $widget(viseur_polaire_eq6,This)
      wm deiconify $widget(viseur_polaire_eq6,This)
      focus $widget(viseur_polaire_eq6,This).but_fermer
   } else {
      if { [ info exists widget(viseur_polaire_eq6,geometry) ] } {
         set deb [ expr 1 + [ string first + $widget(viseur_polaire_eq6,geometry) ] ]
         set fin [ string length $widget(viseur_polaire_eq6,geometry) ]
         set widget(viseur_polaire_eq6,position) "+[ string range $widget(viseur_polaire_eq6,geometry) $deb $fin ]"
      }
      ::viseur_polaire::createDialogEQ6
      tkwait visibility $widget(viseur_polaire_eq6,This)
   }
}

#------------------------------------------------------------
## @brief Commande du bouton "OK"
#
proc ::viseur_polaire::okEQ6 { } {
   ::viseur_polaire::recup_positionEQ6
   ::viseur_polaire::widgetToConfEQ6
   ::viseur_polaire::fermerEQ6
}

#------------------------------------------------------------
## @brief Commande du bouton "Appliquer"
#
proc ::viseur_polaire::appliquerEQ6 { } {
   ::viseur_polaire::okEQ6
   ::viseur_polaire::runEQ6 $::viseur_polaire::This.viseurPolaireEQ6
}

#------------------------------------------------------------
## @brief Commande du bouton "Annuler"
#
proc ::viseur_polaire::fermerEQ6 { } {
   variable widget

   ::viseur_polaire::recup_positionEQ6
   destroy $widget(viseur_polaire_eq6,This)
   unset widget(viseur_polaire_eq6,This)
}

#------------------------------------------------------------
## @brief Initialise les variables du viseur polaire EQ6 dans le tableau \::conf(...)
#  @details Les variables \::conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - \::conf(viseur_eq6,position)         définit la position de la fenêtre
#  - \::conf(viseur_eq6,taille)           définit la taille de la fenêtre
#  - \::conf(viseur_eq6,couleur_fond)     définit la couleur du fond du ciel
#  - \::conf(viseur_eq6,couleur_reticule) définit la couleur des réticules
#  - \::conf(viseur_eq6,couleur_etoile)   définit la couleur des étoiles et des constellations
#
proc ::viseur_polaire::initConfEQ6 { } {
   if { ! [ info exists ::conf(viseur_eq6,position) ] }         { set ::conf(viseur_eq6,position)         "+110+20" }
   if { ! [ info exists ::conf(viseur_eq6,taille) ] }           { set ::conf(viseur_eq6,taille)           "0.5" }
   if { ! [ info exists ::conf(viseur_eq6,couleur_fond) ] }     { set ::conf(viseur_eq6,couleur_fond)     "#000000" }
   if { ! [ info exists ::conf(viseur_eq6,couleur_reticule) ] } { set ::conf(viseur_eq6,couleur_reticule) "#FFFFFF" }
   if { ! [ info exists ::conf(viseur_eq6,couleur_etoile) ] }   { set ::conf(viseur_eq6,couleur_etoile)   "#FFFF00" }

   return
}

#------------------------------------------------------------
## @brief Copie les paramètres du tableau conf(   ) dans les variables des widgets
#
proc ::viseur_polaire::confToWidgetEQ6 { } {
   variable widget

   set widget(viseur_polaire_eq6,position)         $::conf(viseur_eq6,position)
   set widget(viseur_polaire_eq6,taille)           $::conf(viseur_eq6,taille)
   set widget(viseur_polaire_eq6,couleur_fond)     $::conf(viseur_eq6,couleur_fond)
   set widget(viseur_polaire_eq6,couleur_reticule) $::conf(viseur_eq6,couleur_reticule)
   set widget(viseur_polaire_eq6,couleur_etoile)   $::conf(viseur_eq6,couleur_etoile)
}

#------------------------------------------------------------
## @brief Copie les variables des widgets dans le tableau conf(   )
#
proc ::viseur_polaire::widgetToConfEQ6 { } {
   variable widget

   set ::conf(viseur_eq6,position)         $widget(viseur_polaire_eq6,position)
   set ::conf(viseur_eq6,taille)           $widget(viseur_polaire_eq6,taille)
   set ::conf(viseur_eq6,couleur_fond)     $widget(viseur_polaire_eq6,couleur_fond)
   set ::conf(viseur_eq6,couleur_reticule) $widget(viseur_polaire_eq6,couleur_reticule)
   set ::conf(viseur_eq6,couleur_etoile)   $widget(viseur_polaire_eq6,couleur_etoile)
}

#------------------------------------------------------------
## @brief Recupère la position de la fenêtre
#
proc ::viseur_polaire::recup_positionEQ6 { } {
   variable widget

   set widget(viseur_polaire_eq6,geometry) [ wm geometry $widget(viseur_polaire_eq6,This) ]
   set deb [ expr 1 + [ string first + $widget(viseur_polaire_eq6,geometry) ] ]
   set fin [ string length $widget(viseur_polaire_eq6,geometry) ]
   set widget(viseur_polaire_eq6,position) "+[ string range $widget(viseur_polaire_eq6,geometry) $deb $fin ]"
   #---
   ::viseur_polaire::widgetToConfEQ6
}

#------------------------------------------------------------
## @brief Crée l'interface graphique
#
proc ::viseur_polaire::createDialogEQ6 { } {
   variable widget

   #--- Cree la fenetre $widget(viseur_polaire_eq6,This) de niveau le plus haut
   toplevel $widget(viseur_polaire_eq6,This) -class Toplevel
   wm title $widget(viseur_polaire_eq6,This) $::caption(viseur_polaire,titre_eq6)
   wm geometry $widget(viseur_polaire_eq6,This) $widget(viseur_polaire_eq6,position)
   wm resizable $widget(viseur_polaire_eq6,This) 0 0
   wm protocol $widget(viseur_polaire_eq6,This) WM_DELETE_WINDOW ::viseur_polaire::fermerEQ6

   #--- Creation des differents frames
   frame $widget(viseur_polaire_eq6,This).frame1 -borderwidth 1 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_eq6,This).frame2 -borderwidth 1 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame2 -side top -fill x

   frame $widget(viseur_polaire_eq6,This).frame3 -borderwidth 1 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame3 -side top -fill x

   frame $widget(viseur_polaire_eq6,This).frame4 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame4 -in $widget(viseur_polaire_eq6,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_eq6,This).frame5 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame5 -in $widget(viseur_polaire_eq6,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_eq6,This).frame6 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame6 -in $widget(viseur_polaire_eq6,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_eq6,This).frame7 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame7 -in $widget(viseur_polaire_eq6,This).frame2 -side top -fill both -expand 1

   frame $widget(viseur_polaire_eq6,This).frame8 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_eq6,This).frame8 -in $widget(viseur_polaire_eq6,This).frame2 -side top -fill both -expand 1

   #--- Texte et donnees
   label $widget(viseur_polaire_eq6,This).lab1 -text $::caption(viseur_polaire,texte_eq6)
   pack $widget(viseur_polaire_eq6,This).lab1 -in $widget(viseur_polaire_eq6,This).frame4 -anchor center -side left \
      -padx 5 -pady 2

   set widget(viseur_polaire_eq6,longitude) "$::conf(posobs,estouest) $::conf(posobs,long)"
   label $widget(viseur_polaire_eq6,This).labURL3 -textvariable viseur_polaire::widget(viseur_polaire_eq6,longitude) \
      -fg $::color(blue)
   pack $widget(viseur_polaire_eq6,This).labURL3 -in $widget(viseur_polaire_eq6,This).frame4 -anchor center -side right \
      -padx 5 -pady 2

   label $widget(viseur_polaire_eq6,This).lab2 -text $::caption(viseur_polaire,long)
   pack $widget(viseur_polaire_eq6,This).lab2 -in $widget(viseur_polaire_eq6,This).frame4 -anchor center -side right \
      -padx 0 -pady 2

   label $widget(viseur_polaire_eq6,This).lab4 -text $::caption(viseur_polaire,ah_polaire)
   pack $widget(viseur_polaire_eq6,This).lab4 -in $widget(viseur_polaire_eq6,This).frame5 -anchor center -side left \
      -padx 5 -pady 2

   label $widget(viseur_polaire_eq6,This).lab5 -anchor w
   pack $widget(viseur_polaire_eq6,This).lab5 -in $widget(viseur_polaire_eq6,This).frame5 -anchor center -side left \
      -padx 0 -pady 2

   #--- Creation d'un canvas pour l'affichage du viseur polaire
   canvas $widget(viseur_polaire_eq6,This).image1_color_invariant -width [ expr $widget(viseur_polaire_eq6,taille)*500 ] \
      -height [ expr $widget(viseur_polaire_eq6,taille)*500 ] -bg $widget(viseur_polaire_eq6,couleur_fond)
   pack $widget(viseur_polaire_eq6,This).image1_color_invariant -in $widget(viseur_polaire_eq6,This).frame6 -side top \
      -anchor center -padx 0 -pady 0
   set widget(viseur_polaire_eq6,image1) $widget(viseur_polaire_eq6,This).image1_color_invariant

   #--- Calcul de l'angle horaire de la Polaire et dessin du viseur polaire
   ::viseur_polaire::HA_PolaireEQ6

   #--- Taille du viseur polaire
   label $widget(viseur_polaire_eq6,This).lab10 -text $::caption(viseur_polaire,taille)
   pack $widget(viseur_polaire_eq6,This).lab10 -in $widget(viseur_polaire_eq6,This).frame7 -anchor center -side left \
      -padx 5 -pady 5

   #--- Definition de la taille de la raquette
   set list_combobox [ list 0.5 0.6 0.7 0.8 0.9 1.0 ]
   ComboBox $widget(viseur_polaire_eq6,This).taille \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [llength $list_combobox ] \
      -relief sunken     \
      -borderwidth 1     \
      -editable 0        \
      -textvariable viseur_polaire::widget(viseur_polaire_eq6,taille) \
      -values $list_combobox
   pack $widget(viseur_polaire_eq6,This).taille -in $widget(viseur_polaire_eq6,This).frame7 -anchor center -side left \
      -padx 5 -pady 5

   #--- Choix de la couleur du fond
   button $widget(viseur_polaire_eq6,This).but_couleur_fond_color_invariant -relief raised -width 6 \
      -bg $widget(viseur_polaire_eq6,couleur_fond) -activebackground $widget(viseur_polaire_eq6,couleur_fond) \
      -command ::viseur_polaire::colorFondEQ6
   pack $widget(viseur_polaire_eq6,This).but_couleur_fond_color_invariant -in $widget(viseur_polaire_eq6,This).frame7 \
      -anchor center -side right -padx 5 -pady 5

   #--- Couleur du fond
   label $widget(viseur_polaire_eq6,This).lab_couleur_fond -text $::caption(viseur_polaire,couleur_fond)
   pack $widget(viseur_polaire_eq6,This).lab_couleur_fond -in $widget(viseur_polaire_eq6,This).frame7 -anchor center \
      -side right -padx 5 -pady 5

   #--- Couleur du reticule
   label $widget(viseur_polaire_eq6,This).lab_couleur_reticule -text $::caption(viseur_polaire,couleur_reticule)
   pack $widget(viseur_polaire_eq6,This).lab_couleur_reticule -in $widget(viseur_polaire_eq6,This).frame8 -anchor center \
      -side left -padx 5 -pady 5

   #--- Choix de la couleur du reticule
   button $widget(viseur_polaire_eq6,This).but_couleur_reticule_color_invariant -relief raised -width 6 \
      -bg $widget(viseur_polaire_eq6,couleur_reticule) -activebackground $widget(viseur_polaire_eq6,couleur_reticule) \
      -command ::viseur_polaire::colorReticuleEQ6
   pack $widget(viseur_polaire_eq6,This).but_couleur_reticule_color_invariant -in $widget(viseur_polaire_eq6,This).frame8 \
      -anchor center -side left -padx 5 -pady 5

   #--- Choix de la couleur de la Polaire
   button $widget(viseur_polaire_eq6,This).but_couleur_etoile_color_invariant -relief raised -width 6 \
      -bg $widget(viseur_polaire_eq6,couleur_etoile) -activebackground $widget(viseur_polaire_eq6,couleur_etoile) \
      -command ::viseur_polaire::colorEtoilesEQ6
   pack $widget(viseur_polaire_eq6,This).but_couleur_etoile_color_invariant -in $widget(viseur_polaire_eq6,This).frame8 \
      -anchor center -side right -padx 5 -pady 5

   #--- Couleur de la Polaire
   label $widget(viseur_polaire_eq6,This).lab_couleur_etoile -text $::caption(viseur_polaire,couleur_etoile)
   pack $widget(viseur_polaire_eq6,This).lab_couleur_etoile -in $widget(viseur_polaire_eq6,This).frame8 -anchor center \
      -side right -padx 5 -pady 5

   #--- Cree le bouton 'OK'
   button $widget(viseur_polaire_eq6,This).but_ok -text $::caption(viseur_polaire,ok) -width 7 -borderwidth 2 \
      -command ::viseur_polaire::okEQ6
   if { $::conf(ok+appliquer)=="1" } {
      pack $widget(viseur_polaire_eq6,This).but_ok -in $widget(viseur_polaire_eq6,This).frame3 -side left -anchor w \
         -padx 3 -pady 3 -ipady 5
   }

   #--- Cree le bouton 'Appliquer'
   button $widget(viseur_polaire_eq6,This).but_appliquer -text $::caption(viseur_polaire,appliquer) -width 8 -borderwidth 2 \
      -command ::viseur_polaire::appliquerEQ6
   pack $widget(viseur_polaire_eq6,This).but_appliquer -in $widget(viseur_polaire_eq6,This).frame3 -side left -anchor w \
      -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Fermer'
   button $widget(viseur_polaire_eq6,This).but_fermer -text $::caption(viseur_polaire,fermer) -width 7 -borderwidth 2 \
      -command ::viseur_polaire::fermerEQ6
   pack $widget(viseur_polaire_eq6,This).but_fermer -in $widget(viseur_polaire_eq6,This).frame3 -side right -anchor w \
      -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Aide'
   button $widget(viseur_polaire_eq6,This).but_aide -text $::caption(viseur_polaire,aide) -width 7 -borderwidth 2 \
      -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::viseur_polaire::getPluginType ] ] \
             [ ::viseur_polaire::getPluginDirectory ] [ ::viseur_polaire::getPluginHelp ]"
   pack $widget(viseur_polaire_eq6,This).but_aide -in $widget(viseur_polaire_eq6,This).frame3 -side right -anchor w \
      -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $widget(viseur_polaire_eq6,This)

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $widget(viseur_polaire_eq6,This)

   #--- Bind sur la longitude
   bind $widget(viseur_polaire_eq6,This).labURL3 <ButtonPress-1> ::viseur_polaire::longitudeEQ6
}

#------------------------------------------------------------
## @brief Gère la mise à jour de la longitude de l'observateur
#
proc ::viseur_polaire::longitudeEQ6 { } {
   variable widget

   ::confPosObs::run $::audace(base).confPosObs
   tkwait window $::audace(base).confPosObs
   set widget(viseur_polaire_eq6,longitude) "$::conf(posobs,estouest) $::conf(posobs,long)"
   catch {
      #--- Redessine le viseur EQ6
      ::viseur_polaire::HA_PolaireEQ6
      #--- Redessine le viseur Takahashi s'ils sont affiches tous les 2
      set widget(viseur_polaire_taka,longitude) $widget(viseur_polaire_eq6,longitude)
      ::viseurPolaireTaka::HA_PolaireEQ6
   }
}

#------------------------------------------------------------
## @brief Calcule l'angle horaire de la Polaire et dessine le viseur polaire
#
proc ::viseur_polaire::HA_PolaireEQ6 { } {
   variable widget

   #--- Coordonnees de la Polaire J2000.0
   set ad_LP  "2h31m52.741"
   set dec_LP "89d15m50.60"

   #--- Calcul des coordonnees vraies de la Polaire
   set pressure        $::audace(meteo,obs,pressure)
   set temperature     [ expr $::audace(meteo,obs,temperature) + 273.15 ]
   set now             [ ::audace::date_sys2ut now ]
   set hipRecord       [ list 1 0.0 [ mc_angle2deg $ad_LP ] [ mc_angle2deg $dec_LP ] J2000.0 now 0 0 0 ]
   set ad_dec_v        [ mc_hip2tel $hipRecord $now $::audace(posobs,observateur,gps) $pressure $temperature ]
   set ad_LP_vrai      [ lindex $ad_dec_v 0 ]
   set dec_LP_vrai     [ lindex $ad_dec_v 1 ]
   set anglehoraire_LP [ lindex $ad_dec_v 2 ]

   #--- Angle horaire
   set anglehoraire_LP     [ mc_angle2hms $anglehoraire_LP 360 ]
   set anglehoraire_LP_sec [ lindex $anglehoraire_LP 2 ]
   set anglehoraire        [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_LP 0 ] [ lindex $anglehoraire_LP 1 ] \
      [ expr int($anglehoraire_LP_sec) ]]

   #--- Angle horaire en degre
   set anglehoraire_deg [ mc_angle2deg $anglehoraire ]

   #--- Affichage de l'angle horaire
   $widget(viseur_polaire_eq6,This).lab5 configure -text "$anglehoraire"

   #--- Effacement des cercles, du reticule et de La Polaire
   $widget(viseur_polaire_eq6,image1) delete cadres

   #--- Dessin des 2 cercles
   $widget(viseur_polaire_eq6,image1) create oval [ expr $widget(viseur_polaire_eq6,taille) * 12 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 12 ] [ expr $widget(viseur_polaire_eq6,taille) * 487 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 487 ] -outline $widget(viseur_polaire_eq6,couleur_reticule) \
      -tags cadres -width 2.0
   $widget(viseur_polaire_eq6,image1) create oval [ expr $widget(viseur_polaire_eq6,taille) * 212 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 212 ] [ expr $widget(viseur_polaire_eq6,taille) * 287 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 287 ] -outline $widget(viseur_polaire_eq6,couleur_reticule) \
      -tags cadres -width 1.0

   #--- Dessin de la Polaire
   set anglehoraire_rad [ mc_angle2rad $anglehoraire_deg ]
   set PLx [ expr $widget(viseur_polaire_eq6,taille) * ( 249.5 + 35.0 * sin($anglehoraire_rad) ) ]
   set PLy [ expr $widget(viseur_polaire_eq6,taille) * ( 249.5 + 35.0 * cos($anglehoraire_rad) ) ]
   set PLx1 [ expr ( $PLx + 2 ) ]
   set PLy1 [ expr ( $PLy + 2 ) ]
   set PLx2 [ expr ( $PLx - 2 ) ]
   set PLy2 [ expr ( $PLy - 2 ) ]
   $widget(viseur_polaire_eq6,image1) create oval $PLx1 $PLy1 $PLx2 $PLy2 -outline $widget(viseur_polaire_eq6,couleur_etoile) \
      -tags cadres -width [ expr $widget(viseur_polaire_eq6,taille) * 4.0 ]

   #--- Dessin du reticule
   $widget(viseur_polaire_eq6,image1) create line [ expr $widget(viseur_polaire_eq6,taille) * 248.5 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 232 ] [ expr $widget(viseur_polaire_eq6,taille) * 248.5 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 267 ] -fill $widget(viseur_polaire_eq6,couleur_reticule) \
      -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $widget(viseur_polaire_eq6,taille) * 232 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 250 ] [ expr $widget(viseur_polaire_eq6,taille) * 267 ] \
      [ expr $widget(viseur_polaire_eq6,taille) * 250 ] -fill $widget(viseur_polaire_eq6,couleur_reticule) \
      -tags cadres -width 1.0

   #--- Dessin des constellations de Cassiopee et de la Grande Ourse
   ::viseur_polaire::Affich_constEQ6
}

#------------------------------------------------------------
## @brief Calcule l'angle horaire des étoiles de la constellation de Cassiopée
#
proc ::viseur_polaire::HA_CasEQ6 { } {
   #--- Constellation Cassiopee J2000.0
   #--- Epsilon Cas
   set ad_cas(1)  "1h54m23.803"
   set dec_cas(1) "63d40m12.06"
   #--- Delta Cas
   set ad_cas(2)  "1h25m49.593"
   set dec_cas(2) "60d14m6.24"
   #--- Gamma Cas
   set ad_cas(3)  "0h56m42.586"
   set dec_cas(3) "60d43m00.20"
   #--- Alpha Cas
   set ad_cas(4)  "0h40m30.540"
   set dec_cas(4) "56d32m13.88"
   #--- Beta Cas
   set ad_cas(5)  "0h9m11.780"
   set dec_cas(5) "59d8m56.32"

   for {set i 1} {$i <= 5} {incr i} {
      #--- Calcul des coordonnees vraies des etoiles de Cassiopee
      set pressure             $::audace(meteo,obs,pressure)
      set temperature          [ expr $::audace(meteo,obs,temperature) + 273.15 ]
      set now                  [ ::audace::date_sys2ut now ]
      set hipRecord($i)        [ list 1 0.0 [ mc_angle2deg $ad_cas($i) ] [ mc_angle2deg $dec_cas($i) ] J2000.0 now 0 0 0 ]
      set ad_dec_v($i)         [ mc_hip2tel $hipRecord($i) $now $::audace(posobs,observateur,gps) $pressure $temperature ]
      set ad_cas_vrai($i)      [ lindex $ad_dec_v($i) 0 ]
      set dec_cas_vrai($i)     [ lindex $ad_dec_v($i) 1 ]
      set anglehoraire_cas($i) [ lindex $ad_dec_v($i) 2 ]

      #--- Angle horaire
      set anglehoraire_cas($i)     [ mc_angle2hms $anglehoraire_cas($i) 360 ]
      set anglehoraire_cas_sec($i) [ lindex $anglehoraire_cas($i) 2 ]
      set anglehoraire_cas($i)     [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_cas($i) 0 ] \
         [ lindex $anglehoraire_cas($i) 1 ] [ expr int($anglehoraire_cas_sec($i)) ] ]

      #--- Angle horaire en degre
      set anglehoraire_cas_deg($i) [ mc_angle2deg $anglehoraire_cas($i) ]
      set anglehoraire_cas_deg($i) [ expr $anglehoraire_cas_deg($i) + 180.0 ]
      if { $anglehoraire_cas_deg($i) >= "360.0" } {
         set anglehoraire_cas_deg($i) [ expr $anglehoraire_cas_deg($i) - 360.0 ]
      }
   }

   return [ list $anglehoraire_cas_deg(1) $dec_cas(1) $anglehoraire_cas_deg(2) $dec_cas(2) $anglehoraire_cas_deg(3) \
      $dec_cas(3) $anglehoraire_cas_deg(4) $dec_cas(4) $anglehoraire_cas_deg(5) $dec_cas(5) ]
}

#------------------------------------------------------------
## @brief Calcule l'angle horaire des étoiles de la constellation de la Grande Ourse
#
proc ::viseur_polaire::HA_UMaEQ6 { } {
   #--- Constellation Grande Ourse J2000.0
   #--- Eta UMa
   set ad_uma(1)  "13h47m32.239"
   set dec_uma(1) "49d18m47.52"
   #--- Dzeta UMa
   set ad_uma(2)  "13h23m55.768"
   set dec_uma(2) "54d55m30.95"
   #--- Epsilon UMa
   set ad_uma(3)  "12h54m1.964"
   set dec_uma(3) "55d57m35.24"
   #--- Delta UMa
   set ad_uma(4)  "12h15m25.765"
   set dec_uma(4) "57d1m57.53"
   #--- Gamma UMa
   set ad_uma(5)  "11h53m50.029"
   set dec_uma(5) "53d41m41.29"
   #--- Beta UMa
   set ad_uma(6)  "11h1m50.633"
   set dec_uma(6) "56d22m57.26"
   #--- Alpha UMa
   set ad_uma(7)  "11h3m43.368"
   set dec_uma(7) "61d45m3.16"

   for {set i 1} {$i <= 7} {incr i} {
      #--- Calcul des coordonnees vraies des etoiles de la Grande Ourse
      set pressure             $::audace(meteo,obs,pressure)
      set temperature          [ expr $::audace(meteo,obs,temperature) + 273.15 ]
      set now                  [ ::audace::date_sys2ut now ]
      set hipRecord($i)        [ list 1 0.0 [ mc_angle2deg $ad_uma($i) ] [ mc_angle2deg $dec_uma($i) ] J2000.0 now 0 0 0 ]
      set ad_dec_v($i)         [ mc_hip2tel $hipRecord($i) $now $::audace(posobs,observateur,gps) $pressure $temperature ]
      set ad_uma_vrai($i)      [ lindex $ad_dec_v($i) 0 ]
      set dec_uma_vrai($i)     [ lindex $ad_dec_v($i) 1 ]
      set anglehoraire_uma($i) [ lindex $ad_dec_v($i) 2 ]

      #--- Angle horaire
      set anglehoraire_uma($i)     [ mc_angle2hms $anglehoraire_uma($i) 360 ]
      set anglehoraire_uma_sec($i) [ lindex $anglehoraire_uma($i) 2 ]
      set anglehoraire_uma($i)     [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_uma($i) 0 ] \
         [ lindex $anglehoraire_uma($i) 1 ] [ expr int($anglehoraire_uma_sec($i)) ] ]

      #--- Angle horaire en degre
      set anglehoraire_uma_deg($i) [ mc_angle2deg $anglehoraire_uma($i) ]
      set anglehoraire_uma_deg($i) [ expr $anglehoraire_uma_deg($i) + 180.0 ]
      if { $anglehoraire_uma_deg($i) >= "360.0" } {
         set anglehoraire_uma_deg($i) [ expr $anglehoraire_uma_deg($i) - 360.0 ]
      }
   }

   return [ list $anglehoraire_uma_deg(1) $dec_uma(1) $anglehoraire_uma_deg(2) $dec_uma(2) $anglehoraire_uma_deg(3) \
      $dec_uma(3) $anglehoraire_uma_deg(4) $dec_uma(4) $anglehoraire_uma_deg(5) $dec_uma(5) $anglehoraire_uma_deg(6) \
      $dec_uma(6) $anglehoraire_uma_deg(7) $dec_uma(7) ]
}

#------------------------------------------------------------
## @brief Dessine les constellations de Cassiopée et de la Grande Ourse
#
proc ::viseur_polaire::Affich_constEQ6 { } {
   variable widget

   #--- Calcul de l'angle horaire des etoiles de Cassiopee et de leurs rayons sur le reticule
   set donnee_cas [ ::viseur_polaire::HA_CasEQ6 ]
   for {set j 0} {$j <= 4} {incr j} {
      set index_ah [ expr 2 * $j ]
      set index_r [ expr 2 * $j + 1 ]
      set i [ expr $j + 1 ]
      set anglehoraire_cas_deg($i) [ lindex $donnee_cas $index_ah ]
      set dec_cas($i) [ lindex $donnee_cas $index_r ]
   }

   #--- Dessin des etoiles de Cassiopee
   for {set i 1} {$i <= 5} {incr i} {
      set dec_cas_rad($i) [ mc_angle2rad $dec_cas($i) ]
      set r_cas($i) [ expr 237.5 * cos($dec_cas_rad($i)) ]
      set anglehoraire_cas_rad($i) [ mc_angle2rad $anglehoraire_cas_deg($i) ]
      set PLx_cas($i) [ expr $widget(viseur_polaire_eq6,taille) * \
         ( 249.5 + $r_cas($i) * sin($anglehoraire_cas_rad($i)) ) ]
      set PLy_cas($i) [ expr $widget(viseur_polaire_eq6,taille) * \
         ( 249.5 + $r_cas($i) * cos($anglehoraire_cas_rad($i)) ) ]
      set PLx_cas_1 [ expr ( $PLx_cas($i) + 2 ) ]
      set PLy_cas_1 [ expr ( $PLy_cas($i) + 2 ) ]
      set PLx_cas_2 [ expr ( $PLx_cas($i) - 2 ) ]
      set PLy_cas_2 [ expr ( $PLy_cas($i) - 2 ) ]
      $widget(viseur_polaire_eq6,image1) create oval $PLx_cas_1 $PLy_cas_1 $PLx_cas_2 $PLy_cas_2 \
        -outline $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres \
        -width [ expr $widget(viseur_polaire_eq6,taille) * 4.0 ]
   }

   #--- Dessin de la constellation de Cassiopee
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_cas(1) ] [ expr $PLy_cas(1) ] [ expr $PLx_cas(2) ] \
      [ expr $PLy_cas(2) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_cas(2) ] [ expr $PLy_cas(2) ] [ expr $PLx_cas(3) ] \
      [ expr $PLy_cas(3) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_cas(3) ] [ expr $PLy_cas(3) ] [ expr $PLx_cas(4) ] \
      [ expr $PLy_cas(4) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_cas(4) ] [ expr $PLy_cas(4) ] [ expr $PLx_cas(5) ] \
      [ expr $PLy_cas(5) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0

   #--- Calcul de l'angle horaire des etoiles de la Grande Ourse et de leurs rayons sur le reticule
   set donnee_uma [ ::viseur_polaire::HA_UMaEQ6 ]
   for {set j 0} {$j <= 6} {incr j} {
      set index_ah [ expr 2 * $j ]
      set index_r [ expr 2 * $j + 1 ]
      set i [ expr $j + 1 ]
      set anglehoraire_uma_deg($i) [ lindex $donnee_uma $index_ah ]
      set dec_uma($i) [ lindex $donnee_uma $index_r ]
   }

   #--- Dessin des etoiles de la Grande Ourse
   for {set i 1} {$i <= 7} {incr i} {
      set dec_uma_rad($i) [ mc_angle2rad $dec_uma($i) ]
      set r_uma($i) [ expr 237.5 * cos($dec_uma_rad($i)) ]
      set anglehoraire_uma_rad($i) [ mc_angle2rad $anglehoraire_uma_deg($i) ]
      set PLx_uma($i) [ expr $widget(viseur_polaire_eq6,taille) * \
         ( 249.5 + $r_uma($i) * sin($anglehoraire_uma_rad($i)) ) ]
      set PLy_uma($i) [ expr $widget(viseur_polaire_eq6,taille) * \
         ( 249.5 + $r_uma($i) * cos($anglehoraire_uma_rad($i)) ) ]
      set PLx_uma_1 [ expr ( $PLx_uma($i) + 2 ) ]
      set PLy_uma_1 [ expr ( $PLy_uma($i) + 2 ) ]
      set PLx_uma_2 [ expr ( $PLx_uma($i) - 2 ) ]
      set PLy_uma_2 [ expr ( $PLy_uma($i) - 2 ) ]
      $widget(viseur_polaire_eq6,image1) create oval $PLx_uma_1 $PLy_uma_1 $PLx_uma_2 $PLy_uma_2 \
        -outline $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres \
        -width [ expr $widget(viseur_polaire_eq6,taille) * 4.0 ]
   }

   #--- Dessin de la constellation de la Grande Ourse
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_uma(1) ] [ expr $PLy_uma(1) ] [ expr $PLx_uma(2) ] \
      [ expr $PLy_uma(2) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_uma(2) ] [ expr $PLy_uma(2) ] [ expr $PLx_uma(3) ] \
      [ expr $PLy_uma(3) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_uma(3) ] [ expr $PLy_uma(3) ] [ expr $PLx_uma(4) ] \
      [ expr $PLy_uma(4) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_uma(4) ] [ expr $PLy_uma(4) ] [ expr $PLx_uma(5) ] \
      [ expr $PLy_uma(5) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_uma(5) ] [ expr $PLy_uma(5) ] [ expr $PLx_uma(6) ] \
      [ expr $PLy_uma(6) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
   $widget(viseur_polaire_eq6,image1) create line [ expr $PLx_uma(6) ] [ expr $PLy_uma(6) ] [ expr $PLx_uma(7) ] \
      [ expr $PLy_uma(7) ] -fill $widget(viseur_polaire_eq6,couleur_reticule) -tags cadres -width 1.0
}

#------------------------------------------------------------
## @brief Change la couleur du fond du ciel
#
proc ::viseur_polaire::colorFondEQ6 { } {
   variable widget

   set temp [ tk_chooseColor -initialcolor $widget(viseur_polaire_eq6,couleur_fond) \
      -parent $widget(viseur_polaire_eq6,This) -title $::caption(viseur_polaire,couleur_fond) ]
   if  { $temp != "" } {
      set widget(viseur_polaire_eq6,couleur_fond) $temp
      $widget(viseur_polaire_eq6,This).but_couleur_fond_color_invariant configure \
         -bg $widget(viseur_polaire_eq6,couleur_fond)
   }
}

#------------------------------------------------------------
## @brief Change la couleur du réticule
#
proc ::viseur_polaire::colorReticuleEQ6 { } {
   variable widget

   set temp [ tk_chooseColor -initialcolor $widget(viseur_polaire_eq6,couleur_reticule) \
      -parent $widget(viseur_polaire_eq6,This) -title $::caption(viseur_polaire,couleur_reticule) ]
   if  { $temp != "" } {
      set widget(viseur_polaire_eq6,couleur_reticule) $temp
      $widget(viseur_polaire_eq6,This).but_couleur_reticule_color_invariant configure \
         -bg $widget(viseur_polaire_eq6,couleur_reticule)
   }
}

#------------------------------------------------------------
## @brief Change la couleur de l'étoile Polaire
#
proc ::viseur_polaire::colorEtoilesEQ6 { } {
   variable widget

   set temp [ tk_chooseColor -initialcolor $widget(viseur_polaire_eq6,couleur_etoile) \
      -parent $widget(viseur_polaire_eq6,This) -title $::caption(viseur_polaire,couleur_etoile) ]
   if  { $temp != "" } {
      set widget(viseur_polaire_eq6,couleur_etoile) $temp
      $widget(viseur_polaire_eq6,This).but_couleur_etoile_color_invariant configure \
         -bg $widget(viseur_polaire_eq6,couleur_etoile)
   }
}


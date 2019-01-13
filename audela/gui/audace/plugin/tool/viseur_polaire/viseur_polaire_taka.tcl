#
## @file viseur_polaire_taka.tcl
#  @brief Positionne l'étoile polaire dans un viseur polaire de type Takahashi ou à niveau
#  @author Robert DELMAS
#  $Id: viseur_polaire_taka.tcl 13587 2016-04-03 05:43:48Z robertdelmas $
#

#------------------------------------------------------------
## @brief Crée la fenêtre du viseur polaire Takahashi
#  @param this Chemin de la fenêtre
#
proc ::viseur_polaire::runTaka { this } {
   variable widget

   #--- Cree les variables dans conf(...) si elles n'existent pas
   ::viseur_polaire::initConfTaka
   #--- Recupere les variables dans conf(...) si elles existent
   ::viseur_polaire::confToWidgetTaka
   #---
   set widget(viseur_polaire_taka,This) $this
   if { [ winfo exists $widget(viseur_polaire_taka,This) ] } {
      wm withdraw $widget(viseur_polaire_taka,This)
      wm deiconify $widget(viseur_polaire_taka,This)
      focus $widget(viseur_polaire_taka,This).but_fermer
   } else {
      if { [ info exists widget(viseur_polaire_taka,geometry) ] } {
         set deb [ expr 1 + [ string first + $widget(viseur_polaire_taka,geometry) ] ]
         set fin [ string length $widget(viseur_polaire_taka,geometry) ]
         set widget(viseur_polaire_taka,position) "+[ string range $widget(viseur_polaire_taka,geometry) $deb $fin ]"
      }
      ::viseur_polaire::createDialogTaka
      tkwait visibility $widget(viseur_polaire_taka,This)
   }
}

#------------------------------------------------------------
## @brief Commande du bouton "OK"
#
proc ::viseur_polaire::okTaka { } {
   ::viseur_polaire::recup_positionTaka
   ::viseur_polaire::widgetToConfTaka
   ::viseur_polaire::fermerTaka
}

#------------------------------------------------------------
## @brief Commande du bouton "Appliquer"
#
proc ::viseur_polaire::appliquerTaka { } {
   ::viseur_polaire::okTaka
   ::viseur_polaire::runTaka $::viseur_polaire::This.viseurPolaireTaka
}

#------------------------------------------------------------
## @brief Commande du bouton "Annuler"
#
proc ::viseur_polaire::fermerTaka { } {
   variable widget

   ::viseur_polaire::recup_positionTaka
   destroy $widget(viseur_polaire_taka,This)
   unset widget(viseur_polaire_taka,This)
}

#------------------------------------------------------------
## @brief Initialise les variables du viseur polaire Takahashi dans le tableau \::conf(...)
#  @details Les variables \::conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - \::conf(viseur_taka,position)         définit la position de la fenêtre
#  - \::conf(viseur_taka,taille)           définit la taille de la fenêtre
#  - \::conf(viseur_taka,couleur_fond)     définit la couleur du fond du ciel
#  - \::conf(viseur_taka,couleur_reticule) définit la couleur des réticules
#  - \::conf(viseur_taka,couleur_etoile)   définit la couleur de l'étoile Polaire
#
proc ::viseur_polaire::initConfTaka { } {
   if { ! [ info exists ::conf(viseur_taka,position) ] }         { set ::conf(viseur_taka,position)         "+110+20" }
   if { ! [ info exists ::conf(viseur_taka,taille) ] }           { set ::conf(viseur_taka,taille)           "0.5" }
   if { ! [ info exists ::conf(viseur_taka,couleur_fond) ] }     { set ::conf(viseur_taka,couleur_fond)     "#000000" }
   if { ! [ info exists ::conf(viseur_taka,couleur_reticule) ] } { set ::conf(viseur_taka,couleur_reticule) "#FFFFFF" }
   if { ! [ info exists ::conf(viseur_taka,couleur_etoile) ] }   { set ::conf(viseur_taka,couleur_etoile)   "#FFFF00" }

   return
}

#------------------------------------------------------------
## @brief Copie les paramètres du tableau conf(   ) dans les variables des widgets
#
proc ::viseur_polaire::confToWidgetTaka { } {
   variable widget

   set widget(viseur_polaire_taka,position)         $::conf(viseur_taka,position)
   set widget(viseur_polaire_taka,taille)           $::conf(viseur_taka,taille)
   set widget(viseur_polaire_taka,couleur_fond)     $::conf(viseur_taka,couleur_fond)
   set widget(viseur_polaire_taka,couleur_reticule) $::conf(viseur_taka,couleur_reticule)
   set widget(viseur_polaire_taka,couleur_etoile)   $::conf(viseur_taka,couleur_etoile)
}

#------------------------------------------------------------
## @brief Copie les variables des widgets dans le tableau conf(   )
#
proc ::viseur_polaire::widgetToConfTaka { } {
   variable widget

   set ::conf(viseur_taka,position)         $widget(viseur_polaire_taka,position)
   set ::conf(viseur_taka,taille)           $widget(viseur_polaire_taka,taille)
   set ::conf(viseur_taka,couleur_fond)     $widget(viseur_polaire_taka,couleur_fond)
   set ::conf(viseur_taka,couleur_reticule) $widget(viseur_polaire_taka,couleur_reticule)
   set ::conf(viseur_taka,couleur_etoile)   $widget(viseur_polaire_taka,couleur_etoile)
}

#------------------------------------------------------------
## @brief Recupère la position de la fenêtre
#
proc ::viseur_polaire::recup_positionTaka { } {
   variable widget

   set widget(viseur_polaire_taka,geometry) [ wm geometry $widget(viseur_polaire_taka,This) ]
   set deb [ expr 1 + [ string first + $widget(viseur_polaire_taka,geometry) ] ]
   set fin [ string length $widget(viseur_polaire_taka,geometry) ]
   set widget(viseur_polaire_taka,position) "+[ string range $widget(viseur_polaire_taka,geometry) $deb $fin ]"
   #---
   ::viseur_polaire::widgetToConfTaka
}

#------------------------------------------------------------
## @brief Crée l'interface graphique
#
proc ::viseur_polaire::createDialogTaka { } {
   variable widget

   #--- Cree la fenetre $widget(viseur_polaire_taka,This) de niveau le plus haut
   toplevel $widget(viseur_polaire_taka,This) -class Toplevel
   wm title $widget(viseur_polaire_taka,This) $::caption(viseur_polaire,titre_taka)
   wm geometry $widget(viseur_polaire_taka,This) $widget(viseur_polaire_taka,position)
   wm resizable $widget(viseur_polaire_taka,This) 0 0
   wm protocol $widget(viseur_polaire_taka,This) WM_DELETE_WINDOW ::viseur_polaire::fermerTaka

   #--- Creation des differents frames
   frame $widget(viseur_polaire_taka,This).frame1 -borderwidth 1 -relief raised
   pack $widget(viseur_polaire_taka,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_taka,This).frame2 -borderwidth 1 -relief raised
   pack $widget(viseur_polaire_taka,This).frame2 -side top -fill x

   frame $widget(viseur_polaire_taka,This).frame3 -borderwidth 1 -relief raised
   pack $widget(viseur_polaire_taka,This).frame3 -side top -fill x

   frame $widget(viseur_polaire_taka,This).frame4 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_taka,This).frame4 -in $widget(viseur_polaire_taka,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_taka,This).frame5 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_taka,This).frame5 -in $widget(viseur_polaire_taka,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_taka,This).frame6 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_taka,This).frame6 -in $widget(viseur_polaire_taka,This).frame1 -side top -fill both -expand 1

   frame $widget(viseur_polaire_taka,This).frame7 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_taka,This).frame7 -in $widget(viseur_polaire_taka,This).frame2 -side top -fill both -expand 1

   frame $widget(viseur_polaire_taka,This).frame8 -borderwidth 0 -relief raised
   pack $widget(viseur_polaire_taka,This).frame8 -in $widget(viseur_polaire_taka,This).frame2 -side top -fill both -expand 1

   #--- Texte et donnees
   label $widget(viseur_polaire_taka,This).lab1 -text $::caption(viseur_polaire,texte_taka)
   pack $widget(viseur_polaire_taka,This).lab1 -in $widget(viseur_polaire_taka,This).frame4 -anchor center -side left \
      -padx 5 -pady 2

   set widget(viseur_polaire_taka,longitude) "$::conf(posobs,estouest) $::conf(posobs,long)"
   label $widget(viseur_polaire_taka,This).labURL3 -textvariable viseur_polaire::widget(viseur_polaire_taka,longitude) \
      -fg $::color(blue)
   pack $widget(viseur_polaire_taka,This).labURL3 -in $widget(viseur_polaire_taka,This).frame4 -anchor center -side right \
      -padx 5 -pady 2

   label $widget(viseur_polaire_taka,This).lab2 -text $::caption(viseur_polaire,long)
   pack $widget(viseur_polaire_taka,This).lab2 -in $widget(viseur_polaire_taka,This).frame4 -anchor center -side right \
      -padx 0 -pady 2

   label $widget(viseur_polaire_taka,This).lab4 -text $::caption(viseur_polaire,ah_polaire)
   pack $widget(viseur_polaire_taka,This).lab4 -in $widget(viseur_polaire_taka,This).frame5 -anchor center -side left \
      -padx 5 -pady 2

   label $widget(viseur_polaire_taka,This).lab5 -anchor w
   pack $widget(viseur_polaire_taka,This).lab5 -in $widget(viseur_polaire_taka,This).frame5 -anchor center -side left \
      -padx 0 -pady 2

   #--- Creation d'un canvas pour l'affichage du viseur polaire
   canvas $widget(viseur_polaire_taka,This).image1_color_invariant -width [ expr $widget(viseur_polaire_taka,taille)*500 ] \
      -height [ expr $widget(viseur_polaire_taka,taille)*500 ] -bg $widget(viseur_polaire_taka,couleur_fond)
   pack $widget(viseur_polaire_taka,This).image1_color_invariant -in $widget(viseur_polaire_taka,This).frame6 -side top \
      -anchor center -padx 0 -pady 0
   set widget(viseur_polaire_taka,image1) $widget(viseur_polaire_taka,This).image1_color_invariant

   #--- Calcul de l'angle horaire de la Polaire et dessin du viseur polaire
   ::viseur_polaire::HA_PolaireTaka

   #--- Taille du viseur polaire
   label $widget(viseur_polaire_taka,This).lab10 -text $::caption(viseur_polaire,taille)
   pack $widget(viseur_polaire_taka,This).lab10 -in $widget(viseur_polaire_taka,This).frame7 -anchor center -side left \
      -padx 5 -pady 5

   #--- Definition de la taille de la raquette
   set list_combobox [ list 0.5 0.6 0.7 0.8 0.9 1.0 ]
   ComboBox $widget(viseur_polaire_taka,This).taille \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [llength $list_combobox ] \
      -relief sunken     \
      -borderwidth 1     \
      -textvariable viseur_polaire::widget(viseur_polaire_taka,taille) \
      -editable 0        \
      -values $list_combobox
   pack $widget(viseur_polaire_taka,This).taille -in $widget(viseur_polaire_taka,This).frame7 -anchor center -side left \
      -padx 5 -pady 5

   #--- Choix de la couleur du fond
   button $widget(viseur_polaire_taka,This).but_couleur_fond_color_invariant -relief raised -width 6 \
      -bg $widget(viseur_polaire_taka,couleur_fond) -activebackground $widget(viseur_polaire_taka,couleur_fond) \
      -command ::viseur_polaire::colorFondTaka
   pack $widget(viseur_polaire_taka,This).but_couleur_fond_color_invariant -in $widget(viseur_polaire_taka,This).frame7 \
      -anchor center -side right -padx 5 -pady 5

   #--- Couleur du fond
   label $widget(viseur_polaire_taka,This).lab_couleur_fond -text $::caption(viseur_polaire,couleur_fond)
   pack $widget(viseur_polaire_taka,This).lab_couleur_fond -in $widget(viseur_polaire_taka,This).frame7 -anchor center \
      -side right -padx 5 -pady 5

   #--- Couleur du reticule
   label $widget(viseur_polaire_taka,This).lab_couleur_reticule -text $::caption(viseur_polaire,couleur_reticule)
   pack $widget(viseur_polaire_taka,This).lab_couleur_reticule -in $widget(viseur_polaire_taka,This).frame8 -anchor center \
      -side left -padx 5 -pady 5

   #--- Choix de la couleur du reticule
   button $widget(viseur_polaire_taka,This).but_couleur_reticule_color_invariant -relief raised -width 6 \
      -bg $widget(viseur_polaire_taka,couleur_reticule) \
      -activebackground $widget(viseur_polaire_taka,couleur_reticule) \
      -command ::viseur_polaire::colorReticuleTaka
   pack $widget(viseur_polaire_taka,This).but_couleur_reticule_color_invariant -in $widget(viseur_polaire_taka,This).frame8 \
      -anchor center -side left -padx 5 -pady 5

   #--- Choix de la couleur de la Polaire
   button $widget(viseur_polaire_taka,This).but_couleur_etoile_color_invariant -relief raised -width 6 \
      -bg $widget(viseur_polaire_taka,couleur_etoile) -activebackground $widget(viseur_polaire_taka,couleur_etoile) \
      -command ::viseur_polaire::colorPolaireTaka
   pack $widget(viseur_polaire_taka,This).but_couleur_etoile_color_invariant -in $widget(viseur_polaire_taka,This).frame8 \
      -anchor center -side right -padx 5 -pady 5

   #--- Couleur de la Polaire
   label $widget(viseur_polaire_taka,This).lab_couleur_etoile -text $::caption(viseur_polaire,couleur_etoile)
   pack $widget(viseur_polaire_taka,This).lab_couleur_etoile -in $widget(viseur_polaire_taka,This).frame8 -anchor center \
      -side right -padx 5 -pady 5

   #--- Cree le bouton 'OK'
   button $widget(viseur_polaire_taka,This).but_ok -text $::caption(viseur_polaire,ok) -width 7 -borderwidth 2 \
      -command ::viseur_polaire::okTaka
   if { $::conf(ok+appliquer)=="1" } {
      pack $widget(viseur_polaire_taka,This).but_ok -in $widget(viseur_polaire_taka,This).frame3 -side left -anchor w \
         -padx 3 -pady 3 -ipady 5
   }

   #--- Cree le bouton 'Appliquer'
   button $widget(viseur_polaire_taka,This).but_appliquer -text $::caption(viseur_polaire,appliquer) -width 8 -borderwidth 2 \
      -command ::viseur_polaire::appliquerTaka
   pack $widget(viseur_polaire_taka,This).but_appliquer -in $widget(viseur_polaire_taka,This).frame3 -side left -anchor w \
      -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Fermer'
   button $widget(viseur_polaire_taka,This).but_fermer -text $::caption(viseur_polaire,fermer) -width 7 -borderwidth 2 \
      -command ::viseur_polaire::fermerTaka
   pack $widget(viseur_polaire_taka,This).but_fermer -in $widget(viseur_polaire_taka,This).frame3 -side right -anchor w \
      -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Aide'
   button $widget(viseur_polaire_taka,This).but_aide -text $::caption(viseur_polaire,aide) -width 7 -borderwidth 2 \
      -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::viseur_polaire::getPluginType ] ] \
            [ ::viseur_polaire::getPluginDirectory ] [ ::viseur_polaire::getPluginHelp ]"
   pack $widget(viseur_polaire_taka,This).but_aide -in $widget(viseur_polaire_taka,This).frame3 -side right -anchor w \
      -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $widget(viseur_polaire_taka,This)

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $widget(viseur_polaire_taka,This)

   #--- Bind sur la longitude
   bind $widget(viseur_polaire_taka,This).labURL3 <ButtonPress-1> ::viseur_polaire::longitudeTaka
}

#------------------------------------------------------------
## @brief Gère la mise à jour de la longitude de l'observateur
#
proc ::viseur_polaire::longitudeTaka { } {
   variable widget

   ::confPosObs::run $::audace(base).confPosObs
   tkwait window $::audace(base).confPosObs
   set widget(viseur_polaire_taka,longitude) "$::conf(posobs,estouest) $::conf(posobs,long)"
   catch {
      #--- Redessine le viseur Takahashi
      ::viseur_polaire::HA_PolaireTaka
      #--- Redessine le viseur EQ6 s'ils sont affiches tous les 2
      set widget(viseur_polaire_eq6,longitude) $widget(viseur_polaire_taka,longitude)
      ::viseurPolaireEQ6::HA_PolaireTaka
   }
}

#------------------------------------------------------------
## @brief Calcule l'angle horaire de la Polaire et dessine le viseur polaire
#
proc ::viseur_polaire::HA_PolaireTaka { } {
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
   set anglehoraire        [ format "%02dh%02dm%02ds" [ lindex $anglehoraire_LP 0 ] \
      [ lindex $anglehoraire_LP 1 ] [ expr int($anglehoraire_LP_sec) ] ]

   #--- Angle horaire en degre
   set anglehoraire_deg [ mc_angle2deg $anglehoraire ]

   #--- Affichage de l'angle horaire
   $widget(viseur_polaire_taka,This).lab5 configure -text "$anglehoraire"

   #--- Effacement des cercles, du reticule, des graduations et de La Polaire
   $widget(viseur_polaire_taka,image1) delete cadres

   #--- Dessin des 3 cercles
   $widget(viseur_polaire_taka,image1) create oval [ expr $widget(viseur_polaire_taka,taille) * 12 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 12 ] [ expr $widget(viseur_polaire_taka,taille) * 487 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 487 ] -outline $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 2.0
   $widget(viseur_polaire_taka,image1) create oval [ expr $widget(viseur_polaire_taka,taille) * 32 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 32 ] [ expr $widget(viseur_polaire_taka,taille) * 467 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 467 ] -outline $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 1.0
   $widget(viseur_polaire_taka,image1) create oval [ expr $widget(viseur_polaire_taka,taille) * 52 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 52 ] [ expr $widget(viseur_polaire_taka,taille) * 447 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 447 ] -outline $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 1.0

   #--- Dessin du reticule
   $widget(viseur_polaire_taka,image1) create line [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 12 ] [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 245 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 1.0
   $widget(viseur_polaire_taka,image1) create line [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 255 ] [ expr $widget(viseur_polaire_taka,taille) * 248.5 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 487 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 1.0
   $widget(viseur_polaire_taka,image1) create line [ expr $widget(viseur_polaire_taka,taille) * 12 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 250 ] [ expr $widget(viseur_polaire_taka,taille) * 245 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 250 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 1.0
   $widget(viseur_polaire_taka,image1) create line [ expr $widget(viseur_polaire_taka,taille) * 255 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 250 ] [ expr $widget(viseur_polaire_taka,taille) * 487 ] \
      [ expr $widget(viseur_polaire_taka,taille) * 250 ] -fill $widget(viseur_polaire_taka,couleur_reticule) \
      -tags cadres -width 1.0

   #--- Coordonnees polaires et dessin des graduations longues
   for {set angle_deg 0} {$angle_deg <= 360} {incr angle_deg 15} {
      set angle_rad [ mc_angle2rad $angle_deg ]
      set x1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 237.5 * sin($angle_rad) ) ]
      set y1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 237.5 * cos($angle_rad) ) ]
      set x2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * sin($angle_rad) ) ]
      set y2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * cos($angle_rad) ) ]
      $widget(viseur_polaire_taka,image1) create line $x1 $y1 $x2 $y2 -fill $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0
   }

   #--- Coordonnees polaires et dessin des graduations courtes
   for {set angle_deg 0} {$angle_deg <= 360} {incr angle_deg 5} {
      set angle_rad [ mc_angle2rad $angle_deg ]
      set x1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * sin($angle_rad) ) ]
      set y1 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * cos($angle_rad) ) ]
      set x2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * sin($angle_rad) ) ]
      set y2 [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 207.5 * cos($angle_rad) ) ]
      $widget(viseur_polaire_taka,image1) create line $x1 $y1 $x2 $y2 -fill $widget(viseur_polaire_taka,couleur_reticule) \
         -tags cadres -width 1.0
   }

   #--- Dessin de la position de la Polaire
   set anglehoraire_rad [ mc_angle2rad $anglehoraire_deg ]
   set PLx [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * sin($anglehoraire_rad) ) ]
   set PLy [ expr $widget(viseur_polaire_taka,taille) * ( 249.5 + 217.5 * cos($anglehoraire_rad) ) ]
   set PLx1 [ expr ( $PLx + 4 ) ]
   set PLy1 [ expr ( $PLy + 4 ) ]
   set PLx2 [ expr ( $PLx - 4 ) ]
   set PLy2 [ expr ( $PLy - 4 ) ]
   $widget(viseur_polaire_taka,image1) create oval $PLx1 $PLy1 $PLx2 $PLy2 -outline $widget(viseur_polaire_taka,couleur_etoile) \
      -tags cadres -width [ expr $widget(viseur_polaire_taka,taille) * 6.0 ]
}

#------------------------------------------------------------
## @brief Change la couleur du fond du ciel
#
proc ::viseur_polaire::colorFondTaka { } {
   variable widget

   set temp [ tk_chooseColor -initialcolor $widget(viseur_polaire_taka,couleur_fond) \
      -parent $widget(viseur_polaire_taka,This) -title $::caption(viseur_polaire,couleur_fond) ]
   if  { $temp != "" } {
      set widget(viseur_polaire_taka,couleur_fond) $temp
      $widget(viseur_polaire_taka,This).but_couleur_fond_color_invariant configure \
         -bg $widget(viseur_polaire_taka,couleur_fond)
   }
}

#------------------------------------------------------------
## @brief Change la couleur du réticule
#
proc ::viseur_polaire::colorReticuleTaka { } {
   variable widget

   set temp [ tk_chooseColor -initialcolor $widget(viseur_polaire_taka,couleur_reticule) \
      -parent $widget(viseur_polaire_taka,This) -title $::caption(viseur_polaire,couleur_reticule) ]
   if  { $temp != "" } {
      set widget(viseur_polaire_taka,couleur_reticule) $temp
      $widget(viseur_polaire_taka,This).but_couleur_reticule_color_invariant configure \
         -bg $widget(viseur_polaire_taka,couleur_reticule)
   }
}

#------------------------------------------------------------
## @brief Change la couleur de l'étoile Polaire
#
proc ::viseur_polaire::colorPolaireTaka { } {
   variable widget

   set temp [ tk_chooseColor -initialcolor $widget(viseur_polaire_taka,couleur_etoile) \
      -parent $widget(viseur_polaire_taka,This) -title $::caption(viseur_polaire,couleur_etoile) ]
   if  { $temp != "" } {
      set widget(viseur_polaire_taka,couleur_etoile) $temp
      $widget(viseur_polaire_taka,This).but_couleur_etoile_color_invariant configure \
         -bg $widget(viseur_polaire_taka,couleur_etoile)
   }
}


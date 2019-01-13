#
## @file catagoto.tcl
#  @brief Gère les catalogues pour l'outil Télescope
#  @author Robert DELMAS
#  @namespace cataGoto
#  @brief Assure la gestion des catalogues pour l'outil Télescope
#  $Id: catagoto.tcl 13695 2016-04-13 19:23:32Z rzachantke $
#

namespace eval ::cataGoto {

   #------------------------------------------------------------
   #  brief charge les captions et initialise des variables locales
   #  param visuNo numéro de la visu (optionnel, par défaut c'est la visu 1)
   #
   proc init { { visuNo 1 } } {
      global audace caption cataGoto catalogue conf

      #--- Charge le fichier caption
      source [ file join $audace(rep_caption) catagoto.cap ]

      #--- Initialisation de variables
      set cataGoto(carte,validation)   "0"
      set cataGoto(carte,avant_plan)   "0"
      set catalogue($visuNo,nom_objet) ""
      set catalogue($visuNo,equinoxe)  ""
      set catalogue($visuNo,magnitude) ""
      set catalogue(liste_cata)        "$caption(catagoto,coord) $caption(catagoto,planete) $caption(catagoto,asteroide) \
         $caption(catagoto,etoile) $caption(catagoto,messier) $caption(catagoto,ngc) $caption(catagoto,ic) \
         $caption(catagoto,utilisateur) $caption(catagoto,zenith)"

      #--- initConf
      initConf
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres des fenêtres associées au sélecteur (combobox) d'objets dans la fenêtre de l'outil "Télescope"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(cata,haut_inf)                 définit la hauteur limite inférieure de l'objet sélectionné pour autoriser un Goto
   #  - conf(cata,haut_sup)                 définit la hauteur limite supérieure de l'objet sélectionné pour autoriser un Goto
   #  - conf(cata,toujoursVisible)          définit l'affichage des boutons "OK" et "Appliquer" indépendamment des hauteurs limites
   #  - conf(gotoPlanete,position)          définit la position de la fenêtre "Planètes"
   #  - conf(cataAsteroide,position)        définit la position de la fenêtre "Astéroïdes"
   #  - conf(cataObjet,position)            définit la position des fenêtres "Messier", "NGC" et "IC"
   #  - conf(cataEtoile,position)           définit la position de la fenêtre "Etoiles"
   #  - conf(cataObjetUtilisateur,position) définit la position de la fenêtre "Utilisateur"
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(cata,haut_inf) ] }                 { set conf(cata,haut_inf)                 "10" }
      if { ! [ info exists conf(cata,haut_sup) ] }                 { set conf(cata,haut_sup)                 "90" }
      if { ! [ info exists conf(cata,toujoursVisible) ] }          { set conf(cata,toujoursVisible)          "0" }
      if { ! [ info exists conf(gotoPlanete,position) ] }          { set conf(gotoPlanete,position)          "+140+40" }
      if { ! [ info exists conf(cataAsteroide,position) ] }        { set conf(cataAsteroide,position)        "+140+40" }
      if { ! [ info exists conf(cataObjet,position) ] }            { set conf(cataObjet,position)            "+140+40" }
      if { ! [ info exists conf(cataEtoile,position) ] }           { set conf(cataEtoile,position)           "+140+40" }
      if { ! [ info exists conf(cataObjetUtilisateur,position) ] } { set conf(cataObjetUtilisateur,position) "+140+40" }
   }

   #------------------------------------------------------------
   #  brief efface les fenêtres des catalogues si elles existent
   #
   proc nettoyage { } {
      global audace

      #---
      if [ winfo exists $audace(base).gotoPlanete ] {
         destroy $audace(base).gotoPlanete
      } elseif [ winfo exists $audace(base).cataAsteroide ] {
         destroy $audace(base).cataAsteroide
      } elseif [ winfo exists $audace(base).cataObjet ] {
         destroy $audace(base).cataObjet
      } elseif [ winfo exists $audace(base).cataEtoile ] {
         destroy $audace(base).cataEtoile
      } elseif [ winfo exists $audace(base).cataObjetUtilisateur ] {
         destroy $audace(base).cataObjetUtilisateur
      }
   }

   #------------------------------------------------------------
   #  brief récupère la position des fenêtres dédiées à chaque catalogue
   #
   proc recupPosition { } {
      variable This
      global audace cataGoto conf

      if [ winfo exists $audace(base).gotoPlanete ] {
         set cataGoto(gotoPlanete,geometry) [ wm geometry $audace(base).gotoPlanete ]
         set deb [ expr 1 + [ string first + $cataGoto(gotoPlanete,geometry) ] ]
         set fin [ string length $cataGoto(gotoPlanete,geometry) ]
         set cataGoto(gotoPlanete,position) "+[ string range $cataGoto(gotoPlanete,geometry) $deb $fin ]"
         #---
         set conf(gotoPlanete,position) $cataGoto(gotoPlanete,position)
      } elseif [ winfo exists $audace(base).cataAsteroide ] {
         set cataGoto(cataAsteroide,geometry) [ wm geometry $audace(base).cataAsteroide ]
         set deb [ expr 1 + [ string first + $cataGoto(cataAsteroide,geometry) ] ]
         set fin [ string length $cataGoto(cataAsteroide,geometry) ]
         set cataGoto(cataAsteroide,position) "+[ string range $cataGoto(cataAsteroide,geometry) $deb $fin ]"
         #---
         set conf(cataAsteroide,position) $cataGoto(cataAsteroide,position)
      } elseif [ winfo exists $audace(base).cataObjet ] {
         set cataGoto(cataObjet,geometry) [ wm geometry $audace(base).cataObjet ]
         set deb [ expr 1 + [ string first + $cataGoto(cataObjet,geometry) ] ]
         set fin [ string length $cataGoto(cataObjet,geometry) ]
         set cataGoto(cataObjet,position) "+[ string range $cataGoto(cataObjet,geometry) $deb $fin ]"
         #---
         set conf(cataObjet,position) $cataGoto(cataObjet,position)
      } elseif [ winfo exists $audace(base).cataEtoile ] {
         set cataGoto(cataEtoile,geometry) [ wm geometry $audace(base).cataEtoile ]
         set deb [ expr 1 + [ string first + $cataGoto(cataEtoile,geometry) ] ]
         set fin [ string length $cataGoto(cataEtoile,geometry) ]
         set cataGoto(cataEtoile,position) "+[ string range $cataGoto(cataEtoile,geometry) $deb $fin ]"
         #---
         set conf(cataEtoile,position) $cataGoto(cataEtoile,position)
      } elseif [ winfo exists $audace(base).cataObjetUtilisateur ] {
         set cataGoto(cataObjetUtilisateur,geometry) [ wm geometry $audace(base).cataObjetUtilisateur ]
         set deb [ expr 1 + [ string first + $cataGoto(cataObjetUtilisateur,geometry) ] ]
         set fin [ string length $cataGoto(cataObjetUtilisateur,geometry) ]
         set cataGoto(cataObjetUtilisateur,position) "+[ string range $cataGoto(cataObjetUtilisateur,geometry) $deb $fin ]"
         #---
         set conf(cataObjetUtilisateur,position) $cataGoto(cataObjetUtilisateur,position)
      }
   }

   #------------------------------------------------------------
   ## @brief crée une frame pour sélectionner un catalogue d'objets
   #  @details cette frame est destinée à être insérée dans une fenêtre
   #  @param frm                   chemin TK de la frame à creer
   #  @param variablePositionObjet position AD et Déc. d'un objet
   #  @param visuNo                numéro de la visu
   #  @param nameSpaceCaller       namespace de l'outil utilisant cette procédure
   #
   proc createFrameCatalogue { frm variablePositionObjet visuNo nameSpaceCaller } {
      global caption catalogue

      #--- Initialisation du catalogue choisi
      set catalogue(choisi,$visuNo) "$caption(catagoto,coord)"

      #--- Initialisation des coordonnees pour le premier affichage
      set catalogue($visuNo,list_radec) $variablePositionObjet

      #--- Initialisation du nom du namespace appelant
      set catalogue($visuNo,nameSpaceCaller) $nameSpaceCaller

      #--- je cree la frame si elle n'existe pas deja
      if { [ winfo exists $frm ] == 0 } {
         frame $frm -borderwidth 0 -relief raised
      }

      ComboBox $frm.list \
         -width [ ::tkutil::lgEntryComboBox $catalogue(liste_cata) ] \
         -height [ llength $catalogue(liste_cata) ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable catalogue(choisi,$visuNo) \
         -modifycmd "::cataGoto::gestionCata $visuNo" \
         -values $catalogue(liste_cata)
      pack $frm.list -in $frm -anchor center -padx 2 -pady 2

      #--- Bind (clic droit) pour ouvrir la fenetre sans avoir a selectionner dans la listbox
      bind $frm.list.e <ButtonPress-3> "::cataGoto::gestionCata $visuNo"
   }

   #------------------------------------------------------------
   ## @brief gère les différents catalogues
   #  @param visuNo      numéro de la visu
   #  @param type_objets
   #  - type de catalogue utilisé ou
   #  - "" par défaut, ce qui a pour effet de faire RAZ de certaines variables
   #
   proc gestionCata { visuNo { type_objets "" } } {
      global audace caption catalogue

      #--- Force le type d'objets
      if { $type_objets != "" } {
         set catalogue(choisi,$visuNo) "$type_objets"
      }

      #--- Gestion des catalogues
      if { $catalogue(choisi,$visuNo) == "$caption(catagoto,coord)" } {
         ::cataGoto::nettoyage
         set catalogue($visuNo,list_radec) [ list "" "" ]
         set catalogue($visuNo,nom_objet)  ""
         set catalogue($visuNo,equinoxe)   "J2000.0"
         set catalogue($visuNo,magnitude)  ""
         #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
         $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,planete)" } {
         ::cataGoto::gotoPlanete $visuNo
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,asteroide)" } {
         ::cataGoto::cataAsteroide $visuNo
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,etoile)" } {
         ::cataGoto::cataEtoiles $visuNo
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,messier)" } {
         ::cataGoto::cataObjet $visuNo $catalogue(choisi,$visuNo)
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,ngc)" } {
         ::cataGoto::cataObjet $visuNo $catalogue(choisi,$visuNo)
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,ic)" } {
         ::cataGoto::cataObjet $visuNo $catalogue(choisi,$visuNo)
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,utilisateur)" } {
         ::cataGoto::cataObjetUtilisateurChoix $visuNo
      } elseif { $catalogue(choisi,$visuNo) == "$caption(catagoto,zenith)" } {
         ::cataGoto::nettoyage
         set lat_zenith [ mc_angle2dms [ lindex $audace(posobs,observateur,gps) 3 ] 90 nozero 0 auto string ]
         set catalogue($visuNo,list_radec) "$audace(tsl,format,zenith)s $lat_zenith"
         set catalogue($visuNo,nom_objet)  "$caption(catagoto,zenith)"
         set catalogue($visuNo,equinoxe)   "J2000.0"
         set catalogue($visuNo,magnitude)  ""
         #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
         $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
      } else {
         #---Raz des variables de sortie si aucun catalogue n'est selectionne
         set catalogue($visuNo,list_radec) [list "-" "-" ]
         set catalogue($visuNo,nom_objet)  "-"
         set catalogue($visuNo,equinoxe)   "-"
         set catalogue($visuNo,magnitude)  "-"
      }
   }

############## Gestion des corps du Systeme Solaire (Soleil, Lune et Planetes) ##############

   #------------------------------------------------------------
   #  brief initialise des variables locales
   #
   proc initPlanete { } {
      global catalogue

      #---
      set catalogue(planete_numero)        "10"
      set catalogue(planete_choisie)       "-"
      set catalogue(planete_mag)           "-"
      set catalogue(planete_diam_apparent) "-"
      set catalogue(planete_phase)         "-"
      set catalogue(planete_elongation)    "-"
      set catalogue(planete_ad)            "-"
      set catalogue(planete_dec)           "-"
      set catalogue(planete_hauteur_°)     "-"
      set catalogue(planete_azimut_°)      "-"
      set catalogue(planete_anglehoraire)  "-"
   }

   #------------------------------------------------------------
   #  brief affiche la fenêtre de configuration pour les Goto vers les planètes, le Soleil et la Lune
   #  param visuNo numéro de la visu
   #
   proc gotoPlanete { visuNo } {
      global audace caption cataGoto catalogue conf

      #---
      ::cataGoto::initPlanete
      #---
      ::cataGoto::nettoyage
      #---
      set cataGoto(gotoPlanete,position) $conf(gotoPlanete,position)
      #---
      if { [ info exists cataGoto(gotoPlanete,geometry) ] } {
         set deb [ expr 1 + [ string first + $cataGoto(gotoPlanete,geometry) ] ]
         set fin [ string length $cataGoto(gotoPlanete,geometry) ]
         set cataGoto(gotoPlanete,position) "+[ string range $cataGoto(gotoPlanete,geometry) $deb $fin ]"
      }
      #---
      toplevel $audace(base).gotoPlanete -class Toplevel
      wm resizable $audace(base).gotoPlanete 0 0
      wm title $audace(base).gotoPlanete "$caption(catagoto,planete)"
      wm geometry $audace(base).gotoPlanete $cataGoto(gotoPlanete,position)
      wm protocol $audace(base).gotoPlanete WM_DELETE_WINDOW "::cataGoto::gotoPlaneteFermer"

      #--- La nouvelle fenetre est active
      focus $audace(base).gotoPlanete

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).gotoPlanete <Key-F1> { ::console::GiveFocus }

      #--- Cree l'affichage de la fenetre de selection et des boutons
      frame $audace(base).gotoPlanete.frame1 -borderwidth 1 -relief raised
         frame $audace(base).gotoPlanete.frame1.frame1a -borderwidth 0 -relief raised
            #--- Radio-bouton Soleil
            radiobutton $audace(base).gotoPlanete.frame1.frame1a.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,soleil)" -value 0 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1a.rad1 -side left -padx 5 -pady 2
            #--- Radio-bouton Lune
            radiobutton $audace(base).gotoPlanete.frame1.frame1a.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,lune)" -value 1 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1a.rad2 -side right -padx 5 -pady 2
         pack $audace(base).gotoPlanete.frame1.frame1a -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame1.frame1b -borderwidth 0 -relief raised
            #--- Radio-bouton Mercure
            radiobutton $audace(base).gotoPlanete.frame1.frame1b.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,mercure)" -value 2 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1b.rad3 -side left -padx 5 -pady 2
            #--- Radio-bouton Venus
            radiobutton $audace(base).gotoPlanete.frame1.frame1b.rad4 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,venus)" -value 3 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1b.rad4 -side left -padx 5 -pady 2
            #--- Radio-bouton Mars
            radiobutton $audace(base).gotoPlanete.frame1.frame1b.rad5 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,mars)" -value 4 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1b.rad5 -side left -padx 5 -pady 2
            #--- Radio-bouton Jupiter
            radiobutton $audace(base).gotoPlanete.frame1.frame1b.rad6 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,jupiter)" -value 5 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1b.rad6 -side left -padx 5 -pady 2
         pack $audace(base).gotoPlanete.frame1.frame1b -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame1.frame1c -borderwidth 0 -relief raised
            #--- Radio-bouton Saturne
            radiobutton $audace(base).gotoPlanete.frame1.frame1c.rad7 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,saturne)" -value 6 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1c.rad7 -side left -padx 5 -pady 2
            #--- Radio-bouton Uranus
            radiobutton $audace(base).gotoPlanete.frame1.frame1c.rad8 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,uranus)" -value 7 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1c.rad8 -side left -padx 5 -pady 2
            #--- Radio-bouton Neptune
            radiobutton $audace(base).gotoPlanete.frame1.frame1c.rad9 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,neptune)" -value 8 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1c.rad9 -side left -padx 5 -pady 2
            #--- Radio-bouton Pluton
            radiobutton $audace(base).gotoPlanete.frame1.frame1c.rad10 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
               -text "$caption(catagoto,pluton)" -value 9 -variable catalogue(planete_numero) \
               -width 10 -command { ::cataGoto::ephemeridePlanete }
            pack $audace(base).gotoPlanete.frame1.frame1c.rad10 -side left -padx 5 -pady 2
         pack $audace(base).gotoPlanete.frame1.frame1c -side top -fill both -expand 1
      pack $audace(base).gotoPlanete.frame1 -side top -fill both -expand 1

      #--- Cree l'affichage de la selection
      frame $audace(base).gotoPlanete.frame2 -borderwidth 1 -relief raised
         frame $audace(base).gotoPlanete.frame2.frame3 -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame3.lab2 -text "$caption(catagoto,planete_choisie)"
            pack $audace(base).gotoPlanete.frame2.frame3.lab2 -side top -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3.lab3 -text "$caption(catagoto,nom)"
            pack $audace(base).gotoPlanete.frame2.frame3.lab3 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3.lab3a -textvariable "catalogue(planete_choisie)"
            pack $audace(base).gotoPlanete.frame2.frame3.lab3a -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3.lab4 -text "$caption(catagoto,magnitude)"
            pack $audace(base).gotoPlanete.frame2.frame3.lab4 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3.lab4a -textvariable "catalogue(planete_mag)"
            pack $audace(base).gotoPlanete.frame2.frame3.lab4a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame3 -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame2.frame3a -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame3a.lab41 -text "$caption(catagoto,diametre_ap)"
            pack $audace(base).gotoPlanete.frame2.frame3a.lab41 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3a.lab41a -textvariable "catalogue(planete_diam_apparent)"
            pack $audace(base).gotoPlanete.frame2.frame3a.lab41a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame3a -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame2.frame3b -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame3b.lab42 -text "$caption(catagoto,phase)"
            pack $audace(base).gotoPlanete.frame2.frame3b.lab42 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3b.lab42a -textvariable "catalogue(planete_phase)"
            pack $audace(base).gotoPlanete.frame2.frame3b.lab42a -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3b.lab43 -text "$caption(catagoto,elongation)"
            pack $audace(base).gotoPlanete.frame2.frame3b.lab43 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame3b.lab43a -textvariable "catalogue(planete_elongation)"
            pack $audace(base).gotoPlanete.frame2.frame3b.lab43a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame3b -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame2.frame4 -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame4.lab5 \
               -text "$caption(catagoto,RA) $caption(catagoto,2points)"
            pack $audace(base).gotoPlanete.frame2.frame4.lab5 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame4.lab5a -textvariable "catalogue(planete_ad)"
            pack $audace(base).gotoPlanete.frame2.frame4.lab5a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame4 -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame2.frame5 -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame5.lab6 \
               -text "$caption(catagoto,DEC) $caption(catagoto,2points)"
            pack $audace(base).gotoPlanete.frame2.frame5.lab6 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame5.lab6a -textvariable "catalogue(planete_dec)"
            pack $audace(base).gotoPlanete.frame2.frame5.lab6a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame5 -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame2.frame6 -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame6.lab7 -text "$caption(catagoto,hauteur)"
            pack $audace(base).gotoPlanete.frame2.frame6.lab7 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame6.labURLRed7a -textvariable "catalogue(planete_hauteur_°)"
            pack $audace(base).gotoPlanete.frame2.frame6.labURLRed7a -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame6.lab8 -text "$caption(catagoto,azimut)"
            pack $audace(base).gotoPlanete.frame2.frame6.lab8 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame6.lab8a -textvariable "catalogue(planete_azimut_°)"
            pack $audace(base).gotoPlanete.frame2.frame6.lab8a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame6 -side top -fill both -expand 1
         frame $audace(base).gotoPlanete.frame2.frame7 -borderwidth 0 -relief raised
            label $audace(base).gotoPlanete.frame2.frame7.lab9 -text "$caption(catagoto,angle_horaire)"
            pack $audace(base).gotoPlanete.frame2.frame7.lab9 -side left -padx 5 -pady 5
            label $audace(base).gotoPlanete.frame2.frame7.lab9a -textvariable "catalogue(planete_anglehoraire)"
            pack $audace(base).gotoPlanete.frame2.frame7.lab9a -side left -padx 5 -pady 5
         pack $audace(base).gotoPlanete.frame2.frame7 -side top -fill both -expand 1
      pack $audace(base).gotoPlanete.frame2 -side top -fill both -expand 1

      #--- Cree l'affichage des limites en hauteur
      frame $audace(base).gotoPlanete.frame8 -borderwidth 1 -relief raised
         label $audace(base).gotoPlanete.frame8.lab10 -text "$caption(catagoto,haut_inf)"
         pack $audace(base).gotoPlanete.frame8.lab10 -side left -padx 10 -pady 5
         entry $audace(base).gotoPlanete.frame8.haut_inf -textvariable "conf(cata,haut_inf)" -justify center -width 4
         pack $audace(base).gotoPlanete.frame8.haut_inf -side left -padx 10 -pady 5
         label $audace(base).gotoPlanete.frame8.lab11 -text "$caption(catagoto,haut_sup)"
         pack $audace(base).gotoPlanete.frame8.lab11 -side left -padx 10 -pady 5
         entry $audace(base).gotoPlanete.frame8.haut_sup -textvariable "conf(cata,haut_sup)" -justify center -width 4
         pack $audace(base).gotoPlanete.frame8.haut_sup -side left -padx 10 -pady 5
      pack $audace(base).gotoPlanete.frame8 -side top -fill both -expand 1

      #--- Cree l'affichage d'un checkbutton
      frame $audace(base).gotoPlanete.frame9 -borderwidth 1 -relief raised
         checkbutton $audace(base).gotoPlanete.frame9.carte -text "$caption(catagoto,ok_toujours_visible)" \
            -highlightthickness 0 -variable conf(cata,toujoursVisible)
         pack $audace(base).gotoPlanete.frame9.carte -side left -padx 10 -pady 5
      pack $audace(base).gotoPlanete.frame9 -side top -fill both -expand 1

      #--- Cree l'affichage des boutons
      frame $audace(base).gotoPlanete.frame10 -borderwidth 1 -relief raised
         button $audace(base).gotoPlanete.frame10.ok -text "$caption(catagoto,ok)" -width 7 \
            -state normal -command "::cataGoto::gotoPlaneteOK $visuNo"
         if { $conf(ok+appliquer) == "1" } {
            pack $audace(base).gotoPlanete.frame10.ok -side left -padx 10 -pady 5 -ipady 5 -fill x
         }
         button $audace(base).gotoPlanete.frame10.appliquer -text "$caption(catagoto,appliquer)" -width 8 \
            -state normal -command "::cataGoto::gotoPlaneteAppliquer $visuNo"
         pack $audace(base).gotoPlanete.frame10.appliquer -side left -padx 10 -pady 5 -ipady 5 -fill x
         if { $conf(cata,toujoursVisible) == "1" } {
            $audace(base).gotoPlanete.frame10.ok configure -state normal
            $audace(base).gotoPlanete.frame10.appliquer configure -state normal
         } else {
            $audace(base).gotoPlanete.frame10.ok configure -state disabled
            $audace(base).gotoPlanete.frame10.appliquer configure -state disabled
         }
         button $audace(base).gotoPlanete.frame10.fermer -text "$caption(catagoto,fermer)" -width 7 \
            -command "::cataGoto::gotoPlaneteFermer"
         pack $audace(base).gotoPlanete.frame10.fermer -side right -padx 10 -pady 5 -ipady 5
      pack $audace(base).gotoPlanete.frame10 -side top -fill both -expand 1

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).gotoPlanete
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" de la fenêtre "Planètes"
   #  param visuNo numéro de la visu
   #
   proc gotoPlaneteOK { visuNo } {
      global audace

      ::cataGoto::gotoPlaneteAppliquer $visuNo
      destroy $audace(base).gotoPlanete
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" de la fenêtre "Planètes"
   #  @param visuNo numéro de la visu
   #
   proc gotoPlaneteAppliquer { visuNo } {
      global catalogue

      ::cataGoto::recupPosition
      #--- Recopie les donnees
      set catalogue($visuNo,list_radec) "$catalogue(planete_ad) $catalogue(planete_dec)"
      set catalogue($visuNo,nom_objet)  "$catalogue(planete_choisie)"
      set catalogue($visuNo,equinoxe)   "J2000.0"
      set catalogue($visuNo,magnitude)  ""
      #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
      $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer" de la fenêtre "Planètes"
   #
   proc gotoPlaneteFermer { } {
      global audace cataGoto

      ::cataGoto::recupPosition
      set cataGoto(carte,validation) "0"
      set cataGoto(carte,avant_plan) "0"
      destroy $audace(base).gotoPlanete
   }

   #------------------------------------------------------------
   ## @brief éphémérides de l'objet choisi (planète, Soleil ou Lune)
   #
   proc ephemeridePlanete { } {
      global audace caption cataGoto catalogue color conf

      #--- Preparation de l'heure TU
      set now [ ::audace::date_sys2ut now ]

      #--- Preparation des affichages nom, magnitude, AD et Dec.
      switch -exact -- $catalogue(planete_numero) {
         0 { set catalogue(planete_choisie) "$caption(catagoto,soleil)"
             set planete_choisie [mc_ephem {Sun} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
         1 { set catalogue(planete_choisie) "$caption(catagoto,lune)"
             set planete_choisie [mc_ephem {Moon} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM PHASE} -topo $audace(posobs,observateur,gps)]
         }
         2 { set catalogue(planete_choisie) "$caption(catagoto,mercure)"
             set planete_choisie [mc_ephem {Mercury} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM PHASE ELONG} -topo $audace(posobs,observateur,gps)]
         }
         3 { set catalogue(planete_choisie) "$caption(catagoto,venus)"
             set planete_choisie [mc_ephem {Venus} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM PHASE ELONG} -topo $audace(posobs,observateur,gps)]
         }
         4 { set catalogue(planete_choisie) "$caption(catagoto,mars)"
             set planete_choisie [mc_ephem {Mars} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
         5 { set catalogue(planete_choisie) "$caption(catagoto,jupiter)"
             set planete_choisie [mc_ephem {Jupiter} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
         6 { set catalogue(planete_choisie) "$caption(catagoto,saturne)"
             set planete_choisie [mc_ephem {Saturn} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
         7 { set catalogue(planete_choisie) "$caption(catagoto,uranus)"
             set planete_choisie [mc_ephem {Uranus} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
         8 { set catalogue(planete_choisie) "$caption(catagoto,neptune)"
             set planete_choisie [mc_ephem {Neptune} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
         9 { set catalogue(planete_choisie) "$caption(catagoto,pluton)"
             set planete_choisie [mc_ephem {Pluto} [list [mc_date2tt $now]] \
                {OBJENAME RAH RAM RAS.S DECD DECM DECS.S MAG APPDIAM} -topo $audace(posobs,observateur,gps)]
         }
      }

      #--- Extraction du nom pour l'affichage de la carte de champ
      set cataGoto(carte,nom_objet) "[lindex [lindex $planete_choisie 0] 0]"
      if { $cataGoto(carte,nom_objet) == "Sun" } {
         set cataGoto(carte,zoom_objet) "7"
      } elseif { $cataGoto(carte,nom_objet) == "Moon" } {
         set cataGoto(carte,zoom_objet) "7"
      } elseif { $cataGoto(carte,nom_objet) == "Mercury" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Venus" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Mars" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Jupiter" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Saturn" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Uranus" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Neptune" } {
         set cataGoto(carte,zoom_objet) "10"
      } elseif { $cataGoto(carte,nom_objet) == "Pluto" } {
         set cataGoto(carte,zoom_objet) "10"
      }

      #--- Preparation et affichage diametre apparent
      set diam_ap [lindex [lindex $planete_choisie 0] 8]
      set diam_ap [expr $diam_ap*60.*60.]
      if { $diam_ap >= "60" } {
         set diam_ap [expr $diam_ap/60.]
         set diam_ap "[format "%04.2f" $diam_ap]"
         set catalogue(planete_diam_apparent) "$diam_ap$caption(catagoto,minute_arc)"
      } else {
         set diam_ap "[format "%04.2f" $diam_ap]"
         set catalogue(planete_diam_apparent) "$diam_ap$caption(catagoto,seconde_arc)"
      }

      #--- Affichage phase et elongation
      if { ([lindex [lindex $planete_choisie 0] 0] == "Moon") || ([lindex [lindex $planete_choisie 0] 0] == "Mercury") || ([lindex [lindex $planete_choisie 0] 0] == "Venus") } {
         set phase [lindex [lindex $planete_choisie 0] 9]
         set phase [mc_angle2rad $phase]
         set phase [expr (1+cos($phase))/2]
         set catalogue(planete_phase) "[format "%04.2f" $phase]"
      } else {
         set catalogue(planete_phase) "-"
      }
      if { ([lindex [lindex $planete_choisie 0] 0] == "Mercury") || ([lindex [lindex $planete_choisie 0] 0] == "Venus") } {
         set catalogue(planete_elongation) "[format "%-03.1f" [lindex [lindex $planete_choisie 0] 10] ]"
         set catalogue(planete_elongation) "$catalogue(planete_elongation)$caption(catagoto,degre)"
      } else {
         set catalogue(planete_elongation) "-"
      }

      #--- Affichage magnitude, ascension droite et declinaison
      set catalogue(planete_mag) "[format "%-03.1f" [lindex [lindex $planete_choisie 0] 7] ]"
      set catalogue(planete_ad)  "[format "%02dh%02dm%03.1fs" [lindex [lindex $planete_choisie 0] 1] [lindex [lindex $planete_choisie 0] 2] [lindex [lindex $planete_choisie 0] 3] ]"
      set catalogue(planete_dec) "[format "%02dd%02dm%03.1fs" [lindex [lindex $planete_choisie 0] 4] [lindex [lindex $planete_choisie 0] 5] [lindex [lindex $planete_choisie 0] 6] ]"

      #--- Preparation et affichage hauteur et azimut
      set catalogue(planete_altaz) [ mc_radec2altaz $catalogue(planete_ad) $catalogue(planete_dec) $audace(posobs,observateur,gps) $now ]
      #--- Hauteur
      set catalogue(planete_hauteur) "[format "%05.2f" [lindex $catalogue(planete_altaz) 1]]"
      if { $conf(cata,toujoursVisible) == "0" } {
         if { $catalogue(planete_hauteur) < $conf(cata,haut_inf) } {
            set fg $color(red)
            $audace(base).gotoPlanete.frame10.ok configure -state disabled
            $audace(base).gotoPlanete.frame10.appliquer configure -state disabled
         } elseif { $catalogue(planete_hauteur) > $conf(cata,haut_sup) } {
            set fg $color(red)
            $audace(base).gotoPlanete.frame10.ok configure -state disabled
            $audace(base).gotoPlanete.frame10.appliquer configure -state disabled
         } else {
            set fg $audace(color,textColor)
            $audace(base).gotoPlanete.frame10.ok configure -state normal
            $audace(base).gotoPlanete.frame10.appliquer configure -state normal
         }
      } else {
         if { $catalogue(planete_hauteur) < $conf(cata,haut_inf) } {
            set fg $color(red)
         } elseif { $catalogue(planete_hauteur) > $conf(cata,haut_sup) } {
            set fg $color(red)
         } else {
            set fg $audace(color,textColor)
         }
         $audace(base).gotoPlanete.frame10.ok configure -state normal
         $audace(base).gotoPlanete.frame10.appliquer configure -state normal
      }
      set catalogue(planete_hauteur_°) "$catalogue(planete_hauteur)$caption(catagoto,degre)"
      $audace(base).gotoPlanete.frame2.frame6.labURLRed7a configure -fg $fg
      #--- Azimut
      set catalogue(planete_azimut)   [format "%05.2f" [lindex $catalogue(planete_altaz) 0]]
      set catalogue(planete_azimut_°) "$catalogue(planete_azimut)$caption(catagoto,degre)"
      #--- Angle horaire
      set catalogue(planete_anglehoraire)     [lindex $catalogue(planete_altaz) 2]
      set catalogue(planete_anglehoraire)     [mc_angle2hms $catalogue(planete_anglehoraire) 360]
      set catalogue(planete_anglehoraire_sec) [lindex $catalogue(planete_anglehoraire) 2]
      set catalogue(planete_anglehoraire)     [format "%02dh%02dm%02ds" [lindex $catalogue(planete_anglehoraire) 0] [lindex $catalogue(planete_anglehoraire) 1] [expr int($catalogue(planete_anglehoraire_sec))]]
   }

##################### Gestion des corps du Systeme Solaire (Asteroides) #####################

   #------------------------------------------------------------
   #  brief initialise les variables locales
   #
   proc initCataAsteroide { } {
      global catalogue

      #---
      set catalogue(asteroide_choisi)       ""
      set catalogue(asteroide_choisie)      "-"
      set catalogue(asteroide_mag)          "-"
      set catalogue(asteroide_ad)           "-"
      set catalogue(asteroide_dec)          "-"
      set catalogue(asteroide_hauteur_°)    "-"
      set catalogue(asteroide_azimut_°)     "-"
      set catalogue(asteroide_anglehoraire) "-"
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique pour les Goto vers des astéroïdes
   #  param visuNo numéro de la visu
   #
   proc cataAsteroide { visuNo } {
      global audace caption cataGoto catalogue color conf panneau

      #---
      ::cataGoto::initCataAsteroide
      #---
      ::cataGoto::nettoyage
      #---
      set cataGoto(cataAsteroide,position) $conf(cataAsteroide,position)
      #---
      if { [ info exists cataGoto(cataAsteroide,geometry) ] } {
         set deb [ expr 1 + [ string first + $cataGoto(cataAsteroide,geometry) ] ]
         set fin [ string length $cataGoto(cataAsteroide,geometry) ]
         set cataGoto(cataAsteroide,position) "+[ string range $cataGoto(cataAsteroide,geometry) $deb $fin ]"
      }
      #---
      toplevel $audace(base).cataAsteroide
      wm resizable $audace(base).cataAsteroide 0 0
      wm title $audace(base).cataAsteroide "$caption(catagoto,asteroide)"
      wm geometry $audace(base).cataAsteroide $cataGoto(cataAsteroide,position)
      wm protocol $audace(base).cataAsteroide WM_DELETE_WINDOW "::cataGoto::cataAsteroideFermer"

      #--- La nouvelle fenetre est active
      focus $audace(base).cataAsteroide

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).cataAsteroide <Key-F1> { ::console::GiveFocus }

      #--- Cree l'affichage de la fenetre de selection et des boutons
      frame $audace(base).cataAsteroide.frame1 -borderwidth 1 -relief raised
         label $audace(base).cataAsteroide.frame1.labURL -text "$caption(catagoto,besoin_internet)" \
            -fg $color(red)
         pack $audace(base).cataAsteroide.frame1.labURL -side top -padx 5 -pady 5
         label $audace(base).cataAsteroide.frame1.lab1 -text "$caption(catagoto,objet_choisi)"
         pack $audace(base).cataAsteroide.frame1.lab1 -side left -padx 5 -pady 5
         entry $audace(base).cataAsteroide.frame1.obj_choisi_ref -textvariable "catalogue(asteroide_choisi)" \
            -justify left -width 16
         pack $audace(base).cataAsteroide.frame1.obj_choisi_ref -side left -padx 5 -pady 5
         button $audace(base).cataAsteroide.frame1.rechercher -text "$caption(catagoto,rechercher)" -width 12 \
            -command { ::cataGoto::rechercheAsteroide }
         pack $audace(base).cataAsteroide.frame1.rechercher -side right -padx 10 -pady 5 -ipady 5
      pack $audace(base).cataAsteroide.frame1 -side top -fill both -expand 1

      #--- Cree l'affichage de la selection
      frame $audace(base).cataAsteroide.frame2 -borderwidth 1 -relief raised
         frame $audace(base).cataAsteroide.frame2.frame3 -borderwidth 0 -relief raised
            label $audace(base).cataAsteroide.frame2.frame3.lab2 -text "$caption(catagoto,objet_choisi)"
            pack $audace(base).cataAsteroide.frame2.frame3.lab2 -side top -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame3.lab3 -text "$caption(catagoto,nom)"
            pack $audace(base).cataAsteroide.frame2.frame3.lab3 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame3.lab3a -textvariable "catalogue(asteroide_choisie)"
            pack $audace(base).cataAsteroide.frame2.frame3.lab3a -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame3.lab4 -text "$caption(catagoto,magnitude)"
            pack $audace(base).cataAsteroide.frame2.frame3.lab4 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame3.lab4a -textvariable "catalogue(asteroide_mag)"
            pack $audace(base).cataAsteroide.frame2.frame3.lab4a -side left -padx 5 -pady 5
         pack $audace(base).cataAsteroide.frame2.frame3 -side top -fill both -expand 1
         frame $audace(base).cataAsteroide.frame2.frame4 -borderwidth 0 -relief raised
            label $audace(base).cataAsteroide.frame2.frame4.lab5 \
               -text "$caption(catagoto,RA) $caption(catagoto,2points)"
            pack $audace(base).cataAsteroide.frame2.frame4.lab5 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame4.lab5a -textvariable "catalogue(asteroide_ad)"
            pack $audace(base).cataAsteroide.frame2.frame4.lab5a -side left -padx 5 -pady 5
         pack $audace(base).cataAsteroide.frame2.frame4 -side top -fill both -expand 1
         frame $audace(base).cataAsteroide.frame2.frame5 -borderwidth 0 -relief raised
            label $audace(base).cataAsteroide.frame2.frame5.lab6 \
               -text "$caption(catagoto,DEC) $caption(catagoto,2points)"
            pack $audace(base).cataAsteroide.frame2.frame5.lab6 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame5.lab6a -textvariable "catalogue(asteroide_dec)"
            pack $audace(base).cataAsteroide.frame2.frame5.lab6a -side left -padx 5 -pady 5
         pack $audace(base).cataAsteroide.frame2.frame5 -side top -fill both -expand 1
         frame $audace(base).cataAsteroide.frame2.frame6 -borderwidth 0 -relief raised
            label $audace(base).cataAsteroide.frame2.frame6.lab7 -text "$caption(catagoto,hauteur)"
            pack $audace(base).cataAsteroide.frame2.frame6.lab7 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame6.labURLRed7a -textvariable "catalogue(asteroide_hauteur_°)"
            pack $audace(base).cataAsteroide.frame2.frame6.labURLRed7a -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame6.lab8 -text "$caption(catagoto,azimut)"
            pack $audace(base).cataAsteroide.frame2.frame6.lab8 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame6.lab8a -textvariable "catalogue(asteroide_azimut_°)"
            pack $audace(base).cataAsteroide.frame2.frame6.lab8a -side left -padx 5 -pady 5
         pack $audace(base).cataAsteroide.frame2.frame6 -side top -fill both -expand 1
         frame $audace(base).cataAsteroide.frame2.frame7 -borderwidth 0 -relief raised
            label $audace(base).cataAsteroide.frame2.frame7.lab9 -text "$caption(catagoto,angle_horaire)"
            pack $audace(base).cataAsteroide.frame2.frame7.lab9 -side left -padx 5 -pady 5
            label $audace(base).cataAsteroide.frame2.frame7.lab9a -textvariable "catalogue(asteroide_anglehoraire)"
            pack $audace(base).cataAsteroide.frame2.frame7.lab9a -side left -padx 5 -pady 5
         pack $audace(base).cataAsteroide.frame2.frame7 -side top -fill both -expand 1
      pack $audace(base).cataAsteroide.frame2 -side top -fill both -expand 1

      #--- Cree l'affichage des limites en hauteur
      frame $audace(base).cataAsteroide.frame8 -borderwidth 1 -relief raised
         label $audace(base).cataAsteroide.frame8.lab10 -text "$caption(catagoto,haut_inf)"
         pack $audace(base).cataAsteroide.frame8.lab10 -side left -padx 10 -pady 5
         entry $audace(base).cataAsteroide.frame8.haut_inf -textvariable "conf(cata,haut_inf)" -justify center -width 4
         pack $audace(base).cataAsteroide.frame8.haut_inf -side left -padx 10 -pady 5
         label $audace(base).cataAsteroide.frame8.lab11 -text "$caption(catagoto,haut_sup)"
         pack $audace(base).cataAsteroide.frame8.lab11 -side left -padx 10 -pady 5
         entry $audace(base).cataAsteroide.frame8.haut_sup -textvariable "conf(cata,haut_sup)" -justify center -width 4
         pack $audace(base).cataAsteroide.frame8.haut_sup -side left -padx 10 -pady 5
      pack $audace(base).cataAsteroide.frame8 -side top -fill both -expand 1

      #--- Gere l'option de creation d'une carte de champ
      frame $audace(base).cataAsteroide.frame9 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataAsteroide.frame9.carte -text "$caption(catagoto,carte_champ)" \
            -highlightthickness 0 -variable cataGoto(carte,validation)
         pack $audace(base).cataAsteroide.frame9.carte -side top -fill both -expand 1
         checkbutton $audace(base).cataAsteroide.frame9.cartea -text "$caption(catagoto,carte_champ_devant)" \
            -highlightthickness 0 -variable cataGoto(carte,avant_plan)
         pack $audace(base).cataAsteroide.frame9.cartea -side top -fill both -expand 1
      pack $audace(base).cataAsteroide.frame9 -side top -fill both -expand 1

      #--- Cree l'affichage d'un checkbutton
      frame $audace(base).cataAsteroide.frame10 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataAsteroide.frame10.carte -text "$caption(catagoto,ok_toujours_visible)" \
            -highlightthickness 0 -variable conf(cata,toujoursVisible)
         pack $audace(base).cataAsteroide.frame10.carte -side left -padx 10 -pady 5
      pack $audace(base).cataAsteroide.frame10 -side top -fill both -expand 1

      #--- Cree l'affichage des boutons
      frame $audace(base).cataAsteroide.frame11 -borderwidth 1 -relief raised
         button $audace(base).cataAsteroide.frame11.ok -text "$caption(catagoto,ok)" -width 7 \
            -state normal -command "::cataGoto::cataAsteroideOK $visuNo"
         if { $conf(ok+appliquer) == "1" } {
            pack $audace(base).cataAsteroide.frame11.ok -side left -padx 10 -pady 5 -ipady 5 -fill x
         }
         button $audace(base).cataAsteroide.frame11.appliquer -text "$caption(catagoto,appliquer)" -width 8 \
            -state normal -command "::cataGoto::cataAsteroideAppliquer $visuNo"
         pack $audace(base).cataAsteroide.frame11.appliquer -side left -padx 10 -pady 5 -ipady 5 -fill x
         if { $conf(cata,toujoursVisible) == "1" } {
            $audace(base).cataAsteroide.frame11.ok configure -state normal
            $audace(base).cataAsteroide.frame11.appliquer configure -state normal
         } else {
            $audace(base).cataAsteroide.frame11.ok configure -state disabled
            $audace(base).cataAsteroide.frame11.appliquer configure -state disabled
         }
         button $audace(base).cataAsteroide.frame11.fermer -text "$caption(catagoto,fermer)" -width 7 \
            -command "::cataGoto::cataAsteroideFermer"
         pack $audace(base).cataAsteroide.frame11.fermer -side right -padx 10 -pady 5 -ipady 5
      pack $audace(base).cataAsteroide.frame11 -side top -fill both -expand 1

      #--- On donne le focus a l'entry de l'objet
      focus $audace(base).cataAsteroide.frame1.obj_choisi_ref

      #--- Binding sur le bouton Rechercher
      bind $audace(base).cataAsteroide <Key-Return> "::cataGoto::rechercheAsteroide"

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).cataAsteroide
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" de la fenêtre "Astéroïdes"
   #  param visuNo numéro de la visu
   #
   proc cataAsteroideOK { visuNo } {
      global audace

      ::cataGoto::cataAsteroideAppliquer $visuNo
      destroy $audace(base).cataAsteroide
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" de la fenêtre "Astéroïdes"
   #  @param visuNo numéro de la visu
   #
   proc cataAsteroideAppliquer { visuNo } {
      global catalogue

      ::cataGoto::recupPosition
      #--- Recopie les donnees
      set catalogue($visuNo,list_radec) "$catalogue(asteroide_ad) $catalogue(asteroide_dec)"
      set catalogue($visuNo,nom_objet)  [ string trimleft [ lindex [ split $catalogue(asteroide_choisie) ")" ] 1 ] " " ]
      set catalogue($visuNo,equinoxe)   "J2000.0"
      set catalogue($visuNo,magnitude)  ""
      #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
      $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer" de la fenêtre "Astéroïdes"
   #
   proc cataAsteroideFermer { } {
      global audace cataGoto

      ::cataGoto::recupPosition
      set cataGoto(carte,validation) "0"
      set cataGoto(carte,avant_plan) "0"
      destroy $audace(base).cataAsteroide
   }

   #------------------------------------------------------------
   ## brief recherche de l'objet choisi dans la nomenclature des astéroïdes via une connexion Internet
   #
   proc rechercheAsteroide { } {
      global audace caption cataGoto catalogue color conf voconf

      set cataGoto(carte,nom_objet) ""
      set cataGoto(carte,ad) ""
      set cataGoto(carte,dec) ""

      #--- Envoi d'une requete a SkyBoT si necessaire
      if { $catalogue(asteroide_choisi) != "" } {
         #--- Gestion du bouton
         $audace(base).cataAsteroide.frame1.rechercher configure -relief groove -state disabled
         #--- Traitement du nom de l'asteroide
         set catalogue(asteroide_choisi) [ suppr_accents $catalogue(asteroide_choisi) ]
         #--- Demande et extraction des ephemerides
         set liste [ vo_skybotresolver [ mc_date2jd now ] $catalogue(asteroide_choisi) text basic 500 ]
         if { $liste == "failed" } {
            tk_messageBox -title "$caption(catagoto,asteroide)" -icon error -message "$caption(catagoto,besoin_internet)"
         }
         if { [ string first "SKYBOTResolver" $liste ] == -1 } {
            set liste_titres [ lindex [ lrange [ split $liste ";" ] 0 end ] 0 ]
            #--- Traitement d'une erreur particuliere, la requete repond 'item'
            if { $liste_titres == "item" } {
               set catalogue(asteroide_choisi) ""
               set catalogue(asteroide_mag)    "-"
            } else {
               set liste_objet [ split [ lindex [ lrange [ split $liste ";" ] 0 end ] 1 ] "|" ]
               if { $liste_objet != "" } {
                  set catalogue(asteroide_choisi) [ lindex $liste_objet 1 ]
                  set catalogue(asteroide_choisi) [ string trimleft $catalogue(asteroide_choisi) " " ]
                  set catalogue(asteroide_choisi) [ string trimright $catalogue(asteroide_choisi) " " ]
                  set catalogue(aster_ad) [ mc_angle2deg [ lindex $liste_objet 2 ] ]
                  set catalogue(asteroide_ad_d) [ expr 15.0 * $catalogue(aster_ad) ]
                  set catalogue(asteroide_ad_) [ mc_angle2hms $catalogue(asteroide_ad_d) 360 zero 2 auto string ]
                  set catalogue(aster_dec) [ mc_angle2deg [ lindex $liste_objet 3 ] ]
                  set catalogue(asteroide_dec_) [ string trimleft [ mc_angle2dms $catalogue(aster_dec) 90 zero 2 + string ] + ]
                  set catalogue(asteroide_mag_) [ lindex $liste_objet 5 ]
               } else {
                  set catalogue(asteroide_choisi) ""
                  set catalogue(asteroide_mag)    "-"
               }
            }
         } else {
            set catalogue(asteroide_choisi) ""
            set catalogue(asteroide_mag)    "-"
         }
         #--- Gestion du bouton
         $audace(base).cataAsteroide.frame1.rechercher configure -relief raised -state normal
      }

      #--- Extraction du nom pour l'affichage de la carte de champ
      set cataGoto(carte,nom_objet)  "$catalogue(asteroide_choisi)"
      set cataGoto(carte,zoom_objet) "8"

      #--- Preparation et affichage nom, magnitude, AD et Dec.
      if { "$catalogue(asteroide_choisi)" == "" } {
         set catalogue(asteroide_choisie) "-"
         set catalogue(asteroide_mag)     "-"
         set catalogue(asteroide_ad)      "-"
         set catalogue(asteroide_dec)     "-"
      } else {
         if { $liste_objet != "" } {
            set catalogue(asteroide_choisie) [ concat "([ string trimright [ lindex $liste_objet 0 ] " " ]) $catalogue(asteroide_choisi)" ]
            set catalogue(asteroide_mag)     $catalogue(asteroide_mag_)
            set catalogue(asteroide_ad)      $catalogue(asteroide_ad_)
            set catalogue(asteroide_dec)     $catalogue(asteroide_dec_)
         }
      }

      #--- Preparation et affichage hauteur et azimut
      if { "$catalogue(asteroide_choisi)" != "" } {
         if { $liste_objet != "" } {
            set catalogue(asteroide_altaz) [ mc_radec2altaz $catalogue(asteroide_ad) $catalogue(asteroide_dec) $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
            #--- Hauteur
            set catalogue(asteroide_hauteur) "[format "%05.2f" [lindex $catalogue(asteroide_altaz) 1]]"
            if { $conf(cata,toujoursVisible) == "0" } {
               if { ( $catalogue(asteroide_hauteur) < $conf(cata,haut_inf) ) || ( "$catalogue(asteroide_choisi)" == "" ) } {
                  set fg $color(red)
                  $audace(base).cataAsteroide.frame11.ok configure -state disabled
                  $audace(base).cataAsteroide.frame11.appliquer configure -state disabled
               } elseif { ( $catalogue(asteroide_hauteur) > $conf(cata,haut_sup) ) || ( "$catalogue(asteroide_choisi)" == "" ) } {
                  set fg $color(red)
                  $audace(base).cataAsteroide.frame11.ok configure -state disabled
                  $audace(base).cataAsteroide.frame11.appliquer configure -state disabled
               } else {
                  set fg $audace(color,textColor)
                  $audace(base).cataAsteroide.frame11.ok configure -state normal
                  $audace(base).cataAsteroide.frame11.appliquer configure -state normal
               }
            } else {
               if { ( $catalogue(asteroide_hauteur) < $conf(cata,haut_inf) ) || ( "$catalogue(asteroide_choisi)" == "" ) } {
                  set fg $color(red)
               } elseif { ( $catalogue(asteroide_hauteur) > $conf(cata,haut_sup) ) || ( "$catalogue(asteroide_choisi)" == "" ) } {
                  set fg $color(red)
               } else {
                  set fg $audace(color,textColor)
               }
               $audace(base).cataAsteroide.frame11.ok configure -state normal
               $audace(base).cataAsteroide.frame11.appliquer configure -state normal
            }
            set catalogue(asteroide_hauteur_°) "$catalogue(asteroide_hauteur)$caption(catagoto,degre)"
            $audace(base).cataAsteroide.frame2.frame6.labURLRed7a configure -fg $fg
            #--- Azimut
            set catalogue(asteroide_azimut) "[format "%05.2f" [lindex $catalogue(asteroide_altaz) 0]]"
            set catalogue(asteroide_azimut_°) "$catalogue(asteroide_azimut)$caption(catagoto,degre)"
            #--- Angle horaire
            set catalogue(asteroide_anglehoraire) [lindex $catalogue(asteroide_altaz) 2]
            set catalogue(asteroide_anglehoraire) [mc_angle2hms $catalogue(asteroide_anglehoraire) 360]
            set catalogue(asteroide_anglehoraire_sec) [lindex $catalogue(asteroide_anglehoraire) 2]
            set catalogue(asteroide_anglehoraire) [format "%02dh%02dm%02ds" [lindex $catalogue(asteroide_anglehoraire) 0] [lindex $catalogue(asteroide_anglehoraire) 1] [expr int($catalogue(asteroide_anglehoraire_sec))]]
         }
      } else {
         #--- Hauteur
         set catalogue(asteroide_hauteur_°)    "-"
         #--- Azimut
         set catalogue(asteroide_azimut_°)     "-"
         #--- Angle horaire
         set catalogue(asteroide_anglehoraire) "-"
      }
   }

######################### Gestion des catalogues Messier, NGC ou IC #########################

   #------------------------------------------------------------
   #  brief initialise les variables locales
   #
   proc initCataObjet { } {
      global catalogue

      #---
      set catalogue(M-NGC-IC_choisie)      "-"
      set catalogue(M-NGC-IC_mag)          "-"
      set catalogue(M-NGC-IC_ad)           "-"
      set catalogue(objet_ad)              "$catalogue(M-NGC-IC_ad)"
      set catalogue(M-NGC-IC_dec)          "-"
      set catalogue(objet_dec)             "$catalogue(M-NGC-IC_dec)"
      set catalogue(M-NGC-IC_hauteur_°)    "-"
      set catalogue(M-NGC-IC_azimut_°)     "-"
      set catalogue(M-NGC-IC_anglehoraire) "-"
   }

   #------------------------------------------------------------
   #  brief affiche la fenêtre de configuration des catalogues Messier, NGC ou IC
   #  param visuNo     numéro de la visu
   #  param menuChoisi catalogue choisi (Messier, NGC ou IC)
   #
   proc cataObjet { visuNo menuChoisi } {
      variable private
      global audace caption cataGoto catalogue conf panneau

      #---
      ::cataGoto::initCataObjet
      #---
      ::cataGoto::nettoyage
      #---
      set cataGoto(cataObjet,position) $conf(cataObjet,position)
      #---
      if { [ info exists cataGoto(cataObjet,geometry) ] } {
         set deb [ expr 1 + [ string first + $cataGoto(cataObjet,geometry) ] ]
         set fin [ string length $cataGoto(cataObjet,geometry) ]
         set cataGoto(cataObjet,position) "+[ string range $cataGoto(cataObjet,geometry) $deb $fin ]"
      }
      #---
      set catalogue(M-NGC-IC) $menuChoisi
      #---
      toplevel $audace(base).cataObjet
      wm resizable $audace(base).cataObjet 0 0
      if { "$menuChoisi" == "$caption(catagoto,messier)" } {
         wm title $audace(base).cataObjet "$caption(catagoto,messier)"
         set catalogue(obj_choisi_ref) $caption(catagoto,M)
         set catalogue(objet) "cat_messier.txt"
      } elseif { $menuChoisi == "$caption(catagoto,ngc)" } {
         wm title $audace(base).cataObjet "$caption(catagoto,ngc)"
         set catalogue(obj_choisi_ref) $caption(catagoto,ngc)
         set catalogue(objet) "cat_ngc.txt"
      } elseif { $menuChoisi == "$caption(catagoto,ic)" } {
         wm title $audace(base).cataObjet "$caption(catagoto,ic)"
         set catalogue(obj_choisi_ref) $caption(catagoto,ic)
         set catalogue(objet) "cat_ic.txt"
      }
      wm geometry $audace(base).cataObjet $cataGoto(cataObjet,position)
      wm protocol $audace(base).cataObjet WM_DELETE_WINDOW "::cataGoto::cataObjetFermer"

      #--- La nouvelle fenetre est active
      focus $audace(base).cataObjet

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).cataObjet <Key-F1> { ::console::GiveFocus }

      #--- Cree l'affichage de la fenetre de selection et des boutons
      frame $audace(base).cataObjet.frame1 -borderwidth 1 -relief raised
         label $audace(base).cataObjet.frame1.lab1 -text "$caption(catagoto,objet_choisi)"
         pack $audace(base).cataObjet.frame1.lab1 -side left -padx 5 -pady 5
         entry $audace(base).cataObjet.frame1.obj_choisi_ref -textvariable "catalogue(obj_choisi_ref)" \
            -justify left -width 10
         pack $audace(base).cataObjet.frame1.obj_choisi_ref -side left -padx 5 -pady 5
         button $audace(base).cataObjet.frame1.rechercher -text "$caption(catagoto,rechercher)" -width 12 \
            -command { ::cataGoto::rechercheObjet }
         pack $audace(base).cataObjet.frame1.rechercher -side right -padx 10 -pady 5 -ipady 5
      pack $audace(base).cataObjet.frame1 -side top -fill both -expand 1

      #--- Cree l'affichage de la selection
      frame $audace(base).cataObjet.frame2 -borderwidth 1 -relief raised
         frame $audace(base).cataObjet.frame2.frame3 -borderwidth 0 -relief raised
            label $audace(base).cataObjet.frame2.frame3.lab2 -text "$caption(catagoto,objet_choisi)"
            pack $audace(base).cataObjet.frame2.frame3.lab2 -side top -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame3.lab3 -text "$caption(catagoto,nom)"
            pack $audace(base).cataObjet.frame2.frame3.lab3 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame3.lab3a -textvariable "catalogue(M-NGC-IC_choisie)"
            pack $audace(base).cataObjet.frame2.frame3.lab3a -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame3.lab4 -text "$caption(catagoto,magnitude)"
            pack $audace(base).cataObjet.frame2.frame3.lab4 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame3.lab4a -textvariable "catalogue(M-NGC-IC_mag)"
            pack $audace(base).cataObjet.frame2.frame3.lab4a -side left -padx 5 -pady 5
         pack $audace(base).cataObjet.frame2.frame3 -side top -fill both -expand 1
         frame $audace(base).cataObjet.frame2.frame4 -borderwidth 0 -relief raised
            label $audace(base).cataObjet.frame2.frame4.lab5 \
               -text "$caption(catagoto,RA) $caption(catagoto,J2000) $caption(catagoto,2points)"
            pack $audace(base).cataObjet.frame2.frame4.lab5 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame4.lab5a -textvariable "catalogue(M-NGC-IC_ad)"
            pack $audace(base).cataObjet.frame2.frame4.lab5a -side left -padx 5 -pady 5
         pack $audace(base).cataObjet.frame2.frame4 -side top -fill both -expand 1
         frame $audace(base).cataObjet.frame2.frame5 -borderwidth 0 -relief raised
            label $audace(base).cataObjet.frame2.frame5.lab6 \
               -text "$caption(catagoto,DEC) $caption(catagoto,J2000) $caption(catagoto,2points)"
            pack $audace(base).cataObjet.frame2.frame5.lab6 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame5.lab6a -textvariable "catalogue(M-NGC-IC_dec)"
            pack $audace(base).cataObjet.frame2.frame5.lab6a -side left -padx 5 -pady 5
         pack $audace(base).cataObjet.frame2.frame5 -side top -fill both -expand 1
         frame $audace(base).cataObjet.frame2.frame6 -borderwidth 0 -relief raised
            label $audace(base).cataObjet.frame2.frame6.lab7 -text "$caption(catagoto,hauteur)"
            pack $audace(base).cataObjet.frame2.frame6.lab7 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame6.labURLRed7a -textvariable "catalogue(M-NGC-IC_hauteur_°)"
            pack $audace(base).cataObjet.frame2.frame6.labURLRed7a -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame6.lab8 -text "$caption(catagoto,azimut)"
            pack $audace(base).cataObjet.frame2.frame6.lab8 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame6.lab8a -textvariable "catalogue(M-NGC-IC_azimut_°)"
            pack $audace(base).cataObjet.frame2.frame6.lab8a -side left -padx 5 -pady 5
         pack $audace(base).cataObjet.frame2.frame6 -side top -fill both -expand 1
         frame $audace(base).cataObjet.frame2.frame7 -borderwidth 0 -relief raised
            label $audace(base).cataObjet.frame2.frame7.lab9 -text "$caption(catagoto,angle_horaire)"
            pack $audace(base).cataObjet.frame2.frame7.lab9 -side left -padx 5 -pady 5
            label $audace(base).cataObjet.frame2.frame7.lab9a -textvariable "catalogue(M-NGC-IC_anglehoraire)"
            pack $audace(base).cataObjet.frame2.frame7.lab9a -side left -padx 5 -pady 5
         pack $audace(base).cataObjet.frame2.frame7 -side top -fill both -expand 1
      pack $audace(base).cataObjet.frame2 -side top -fill both -expand 1

      #--- Cree l'affichage des limites en hauteur
      frame $audace(base).cataObjet.frame8 -borderwidth 1 -relief raised
         label $audace(base).cataObjet.frame8.lab10 -text "$caption(catagoto,haut_inf)"
         pack $audace(base).cataObjet.frame8.lab10 -side left -padx 10 -pady 5
         entry $audace(base).cataObjet.frame8.haut_inf -textvariable "conf(cata,haut_inf)" -justify center -width 4
         pack $audace(base).cataObjet.frame8.haut_inf -side left -padx 10 -pady 5
         label $audace(base).cataObjet.frame8.lab11 -text "$caption(catagoto,haut_sup)"
         pack $audace(base).cataObjet.frame8.lab11 -side left -padx 10 -pady 5
         entry $audace(base).cataObjet.frame8.haut_sup -textvariable "conf(cata,haut_sup)" -justify center -width 4
         pack $audace(base).cataObjet.frame8.haut_sup -side left -padx 10 -pady 5
      pack $audace(base).cataObjet.frame8 -side top -fill both -expand 1

      #--- Gere l'option de creation d'une carte de champ
      frame $audace(base).cataObjet.frame9 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataObjet.frame9.carte -text "$caption(catagoto,carte_champ)" \
            -highlightthickness 0 -variable cataGoto(carte,validation)
         pack $audace(base).cataObjet.frame9.carte -side top -fill both -expand 1
         checkbutton $audace(base).cataObjet.frame9.cartea -text "$caption(catagoto,carte_champ_devant)" \
            -highlightthickness 0 -variable cataGoto(carte,avant_plan)
         pack $audace(base).cataObjet.frame9.cartea -side top -fill both -expand 1
      pack $audace(base).cataObjet.frame9 -side top -fill both -expand 1

      #--- Cree l'affichage d'un checkbutton
      frame $audace(base).cataObjet.frame10 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataObjet.frame10.carte -text "$caption(catagoto,ok_toujours_visible)" \
            -highlightthickness 0 -variable conf(cata,toujoursVisible)
         pack $audace(base).cataObjet.frame10.carte -side left -padx 10 -pady 5
      pack $audace(base).cataObjet.frame10 -side top -fill both -expand 1

      #--- Cree l'affichage des boutons
      frame $audace(base).cataObjet.frame11 -borderwidth 1 -relief raised
         button $audace(base).cataObjet.frame11.ok -text "$caption(catagoto,ok)" -width 7 \
            -state normal -command "::cataGoto::cataObjetOK $visuNo"
         if { $conf(ok+appliquer) == "1" } {
            pack $audace(base).cataObjet.frame11.ok -side left -padx 10 -pady 5 -ipady 5 -fill x
         }
         button $audace(base).cataObjet.frame11.appliquer -text "$caption(catagoto,appliquer)" -width 8 \
            -state normal -command "::cataGoto::cataObjetAppliquer $visuNo"
         pack $audace(base).cataObjet.frame11.appliquer -side left -padx 10 -pady 5 -ipady 5 -fill x
         if { $conf(cata,toujoursVisible) == "1" } {
            $audace(base).cataObjet.frame11.ok configure -state normal
            $audace(base).cataObjet.frame11.appliquer configure -state normal
         } else {
            $audace(base).cataObjet.frame11.ok configure -state disabled
            $audace(base).cataObjet.frame11.appliquer configure -state disabled
         }
         button $audace(base).cataObjet.frame11.fermer -text "$caption(catagoto,fermer)" -width 7 \
            -command "::cataGoto::cataObjetFermer"
         pack $audace(base).cataObjet.frame11.fermer -side right -padx 10 -pady 5 -ipady 5
      pack $audace(base).cataObjet.frame11 -side top -fill both -expand 1

      #--- On positionne le curseur a droite du dernier caractere
      $audace(base).cataObjet.frame1.obj_choisi_ref icursor end

      #--- On donne le focus a l'entry de l'objet
      focus $audace(base).cataObjet.frame1.obj_choisi_ref

      #--- Binding sur le bouton Rechercher
      bind $audace(base).cataObjet <Key-Return> "::cataGoto::rechercheObjet"

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).cataObjet
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" des fenêtres "Messier", "NGC" ou "IC"
   #  param visuNo numéro de la visu
   #
   proc cataObjetOK { visuNo } {
      global audace

      ::cataGoto::cataObjetAppliquer $visuNo
      destroy $audace(base).cataObjet
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" des fenêtres "Messier", "NGC" ou "IC"
   #  @param visuNo numéro de la visu
   #
   proc cataObjetAppliquer { visuNo } {
      global catalogue

      ::cataGoto::recupPosition
      #--- Recopie les donnees
      set catalogue($visuNo,list_radec) "$catalogue(objet_ad) $catalogue(objet_dec)"
      set catalogue($visuNo,nom_objet)  "$catalogue(M-NGC-IC_choisie)"
      set catalogue($visuNo,equinoxe)   "J2000.0"
      set catalogue($visuNo,magnitude)  ""
      #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
      $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer" des fenêtres "Messier", "NGC" ou "IC"
   #
   proc cataObjetFermer { } {
      global audace cataGoto

      ::cataGoto::recupPosition
      set cataGoto(carte,validation) "0"
      set cataGoto(carte,avant_plan) "0"
      destroy $audace(base).cataObjet
   }

   #------------------------------------------------------------
   ## brief recherche de l'objet choisi dans les catalogues Messier, NGC ou IC
   #
   proc rechercheObjet { } {
      global audace caption cataGoto catalogue color conf

      set cataGoto(carte,nom_objet) ""
      set cataGoto(carte,ad) ""
      set cataGoto(carte,dec) ""

      #--- Ouverture du catalogue des objets choisis
      set f [open [file join $audace(rep_gui) audace catalogues catagoto $catalogue(objet)] r]
      #--- Creation d'une liste des objets
      set objet [split [read $f] "\n"]
      #--- Determine le nombre d'elements de la liste
      set long [llength $objet]
      #--- Recherche l'objet demande
      for {set j 0} {$j <= $long} {incr j} {
         set objet_choisi [lindex $objet $j]
         if { [string compare [lindex $objet_choisi 0] "$catalogue(obj_choisi_ref)"]=="0"} {
            break
         }
      }
      #--- Ferme le fichier des objets
      close $f

      #--- Extraction du nom pour l'affichage de la carte de champ
      set cataGoto(carte,nom_objet) "[lindex $objet_choisi 0]"
      set cataGoto(carte,zoom_objet) "8"

      #--- Preparation et affichage nom, magnitude, AD et Dec.
      if { [lindex $objet_choisi 0] == "" } {
         set catalogue(M-NGC-IC_choisie) "-"
         set catalogue(M-NGC-IC_mag)     "-"
         set catalogue(M-NGC-IC_ad)      "-"
         set catalogue(objet_ad)         "0"
         set catalogue(M-NGC-IC_dec)     "-"
         set catalogue(objet_dec)        "0"
      } else {
         set catalogue(M-NGC-IC_choisie) "[lindex $objet_choisi 0]"
         set catalogue(M-NGC-IC_mag)     "[lindex $objet_choisi 5]"
         set catalogue(M-NGC-IC_ad)      "[lindex $objet_choisi 1]h[string range [lindex $objet_choisi 2] 0 1]m[expr ([string range [lindex $objet_choisi 2] 3 3])*60/10]s"
         set catalogue(objet_ad)         "$catalogue(M-NGC-IC_ad)"
         set catalogue(M-NGC-IC_dec)     "[lindex $objet_choisi 3]d[lindex $objet_choisi 4]m00s"
         set catalogue(objet_dec)        "$catalogue(M-NGC-IC_dec)"
      }

      #--- Preparation et affichage hauteur, azimut et angle horaire
      if { [lindex $objet_choisi 0] != "" } {
         set catalogue(objet_altaz) [ mc_radec2altaz $catalogue(M-NGC-IC_ad) $catalogue(M-NGC-IC_dec) $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
         #--- Hauteur
         set catalogue(objet_hauteur) "[format "%05.2f" [lindex $catalogue(objet_altaz) 1]]"
         if { $conf(cata,toujoursVisible) == "0" } {
            if { ( $catalogue(objet_hauteur) < $conf(cata,haut_inf) ) || ( [ lindex $objet_choisi 0 ] == "" ) } {
               set fg $color(red)
               $audace(base).cataObjet.frame11.ok configure -state disabled
               $audace(base).cataObjet.frame11.appliquer configure -state disabled
            } elseif { ( $catalogue(objet_hauteur) > $conf(cata,haut_sup) ) || ( [ lindex $objet_choisi 0 ] == "" ) } {
               set fg $color(red)
               $audace(base).cataObjet.frame11.ok configure -state disabled
               $audace(base).cataObjet.frame11.appliquer configure -state disabled
            } else {
               set fg $audace(color,textColor)
               $audace(base).cataObjet.frame11.ok configure -state normal
               $audace(base).cataObjet.frame11.appliquer configure -state normal
            }
         } else {
            if { ( $catalogue(objet_hauteur) < $conf(cata,haut_inf) ) || ( [ lindex $objet_choisi 0 ] == "" ) } {
               set fg $color(red)
            } elseif { ( $catalogue(objet_hauteur) > $conf(cata,haut_sup) ) || ( [ lindex $objet_choisi 0 ] == "" ) } {
               set fg $color(red)
            } else {
               set fg $audace(color,textColor)
            }
            $audace(base).cataObjet.frame11.ok configure -state normal
            $audace(base).cataObjet.frame11.appliquer configure -state normal
         }
         set catalogue(M-NGC-IC_hauteur_°) "$catalogue(objet_hauteur)$caption(catagoto,degre)"
         $audace(base).cataObjet.frame2.frame6.labURLRed7a configure -fg $fg
         #--- Azimut
         set catalogue(objet_azimut) "[format "%05.2f" [lindex $catalogue(objet_altaz) 0]]"
         set catalogue(M-NGC-IC_azimut_°) "$catalogue(objet_azimut)$caption(catagoto,degre)"
         #--- Angle horaire
         set catalogue(objet_anglehoraire) [lindex $catalogue(objet_altaz) 2]
         set catalogue(objet_anglehoraire) [mc_angle2hms $catalogue(objet_anglehoraire) 360]
         set catalogue(objet_anglehoraire_sec) [lindex $catalogue(objet_anglehoraire) 2]
         set catalogue(objet_anglehoraire) [format "%02dh%02dm%02ds" [lindex $catalogue(objet_anglehoraire) 0] [lindex $catalogue(objet_anglehoraire) 1] [expr int($catalogue(objet_anglehoraire_sec))]]
         set catalogue(M-NGC-IC_anglehoraire) "$catalogue(objet_anglehoraire)"
      } else {
         #--- Hauteur
         set catalogue(M-NGC-IC_hauteur_°) "-"
         #--- Azimut
         set catalogue(M-NGC-IC_azimut_°) "-"
         #--- Angle horaire
         set catalogue(M-NGC-IC_anglehoraire) "-"
      }
   }

############################# Gestion d'un catalogue d'etoiles ##############################

   #------------------------------------------------------------
   #  brief initialise les variables locales
   #
   proc initCataEtoiles { } {
      global catalogue

      #---
      set catalogue(etoile_choisie)      "-"
      set catalogue(etoile_nom_courant)  "-"
      set catalogue(etoile_mag)          "-"
      set catalogue(etoile_ad)           "-"
      set catalogue(etoile_dec)          "-"
      set catalogue(etoile_hauteur_°)    "-"
      set catalogue(etoile_azimut_°)     "-"
      set catalogue(etoile_anglehoraire) "-"
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de configuration du catalogue des étoiles
   #  param visuNo numéro de la visu
   #
   proc cataEtoiles { visuNo } {
      variable private
      global audace caption cataGoto catalogue color conf zone

      #---
      ::cataGoto::initCataEtoiles
      #---
      ::cataGoto::nettoyage
      #---
      set cataGoto(cataEtoile,position) $conf(cataEtoile,position)
      #---
      if { [ info exists cataGoto(cataEtoile,geometry) ] } {
         set deb [ expr 1 + [ string first + $cataGoto(cataEtoile,geometry) ] ]
         set fin [ string length $cataGoto(cataEtoile,geometry) ]
         set cataGoto(cataEtoile,position) "+[ string range $cataGoto(cataEtoile,geometry) $deb $fin ]"
      }
      #---
      toplevel $audace(base).cataEtoile
      wm resizable $audace(base).cataEtoile 0 0
      wm title $audace(base).cataEtoile "$caption(catagoto,etoile)"
      wm geometry $audace(base).cataEtoile $cataGoto(cataEtoile,position)
      wm protocol $audace(base).cataEtoile WM_DELETE_WINDOW "::cataGoto::cataEtoilesFermer"

      #--- La nouvelle fenetre est active
      focus $audace(base).cataEtoile

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).cataEtoile <Key-F1> { ::console::GiveFocus }

      #--- Cree l'affichage du catalogue dans une fenetre a defilement
      frame $audace(base).cataEtoile.frame1 -borderwidth 1 -relief raised
         listbox $audace(base).cataEtoile.frame1.lb1 -width 75 -height 9 -borderwidth 2 -relief sunken \
            -yscrollcommand [list $audace(base).cataEtoile.frame1.scrollbar set]
         pack $audace(base).cataEtoile.frame1.lb1 -side left -anchor nw
         scrollbar $audace(base).cataEtoile.frame1.scrollbar -orient vertical \
            -command [list $audace(base).cataEtoile.frame1.lb1 yview] -takefocus 1 -borderwidth 1
         pack $audace(base).cataEtoile.frame1.scrollbar -side left -fill y
         set zone(list_etoile) $audace(base).cataEtoile.frame1.lb1
      pack $audace(base).cataEtoile.frame1 -side top -fill both -expand 1

      #--- Cree l'affichage des boutons
      frame $audace(base).cataEtoile.frame10 -borderwidth 1 -relief raised
         button $audace(base).cataEtoile.frame10.ok -text "$caption(catagoto,ok)" -width 7 \
            -state normal -command "::cataGoto::cataEtoilesOK $visuNo"
         if { $conf(ok+appliquer) == "1" } {
            pack $audace(base).cataEtoile.frame10.ok -side left -padx 10 -pady 5 -ipady 5 -fill x
         }
         button $audace(base).cataEtoile.frame10.appliquer -text "$caption(catagoto,appliquer)" -width 8 \
            -state normal -command "::cataGoto::cataEtoilesAppliquer $visuNo"
         pack $audace(base).cataEtoile.frame10.appliquer -side left -padx 10 -pady 5 -ipady 5 -fill x
         if { $conf(cata,toujoursVisible) == "1" } {
            $audace(base).cataEtoile.frame10.ok configure -state normal
            $audace(base).cataEtoile.frame10.appliquer configure -state normal
         } else {
            $audace(base).cataEtoile.frame10.ok configure -state disabled
            $audace(base).cataEtoile.frame10.appliquer configure -state disabled
         }
         button $audace(base).cataEtoile.frame10.fermer -text "$caption(catagoto,fermer)" -width 7 \
            -command "::cataGoto::cataEtoilesFermer"
         pack $audace(base).cataEtoile.frame10.fermer -side right -padx 10 -pady 5 -ipady 5 -fill x
      pack $audace(base).cataEtoile.frame10 -side bottom -fill both -expand 1

      #--- Cree l'affichage d'un checkbutton
      frame $audace(base).cataEtoile.frame9 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataEtoile.frame9.carte -text "$caption(catagoto,ok_toujours_visible)" \
            -highlightthickness 0 -variable conf(cata,toujoursVisible)
         pack $audace(base).cataEtoile.frame9.carte -side left -padx 10 -pady 5
      pack $audace(base).cataEtoile.frame9 -side bottom -fill both -expand 1

      #--- Gere l'option de creation d'une carte de champ
      frame $audace(base).cataEtoile.frame8 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataEtoile.frame8.carte -text "$caption(catagoto,carte_champ)" \
            -highlightthickness 0 -variable cataGoto(carte,validation)
         pack $audace(base).cataEtoile.frame8.carte -side top -fill both -expand 1
         checkbutton $audace(base).cataEtoile.frame8.cartea -text "$caption(catagoto,carte_champ_devant)" \
            -highlightthickness 0 -variable cataGoto(carte,avant_plan)
         pack $audace(base).cataEtoile.frame8.cartea -side top -fill both -expand 1
      pack $audace(base).cataEtoile.frame8 -side bottom -fill both -expand 1

      #--- Cree l'affichage des limites en hauteur
      frame $audace(base).cataEtoile.frame7 -borderwidth 1 -relief raised
         label $audace(base).cataEtoile.frame7.lab10 -text "$caption(catagoto,haut_inf)"
         pack $audace(base).cataEtoile.frame7.lab10 -side left -padx 10 -pady 5
         entry $audace(base).cataEtoile.frame7.haut_inf -textvariable "conf(cata,haut_inf)" -justify center -width 4
         pack $audace(base).cataEtoile.frame7.haut_inf -side left -padx 10 -pady 5
         label $audace(base).cataEtoile.frame7.lab11 -text "$caption(catagoto,haut_sup)"
         pack $audace(base).cataEtoile.frame7.lab11 -side left -padx 10 -pady 5
         entry $audace(base).cataEtoile.frame7.haut_sup -textvariable "conf(cata,haut_sup)" -justify center -width 4
         pack $audace(base).cataEtoile.frame7.haut_sup -side left -padx 10 -pady 5
      pack $audace(base).cataEtoile.frame7 -side bottom -fill both -expand 1

      #--- Cree l'affichage de la selection
      frame $audace(base).cataEtoile.frame2 -borderwidth 1 -relief raised
         frame $audace(base).cataEtoile.frame2.frame3 -borderwidth 0 -relief raised
            label $audace(base).cataEtoile.frame2.frame3.lab1 -text "$caption(catagoto,etoile_choisie)"
            pack $audace(base).cataEtoile.frame2.frame3.lab1 -side top -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame3.lab2 -text "$caption(catagoto,nom_courant)"
            pack $audace(base).cataEtoile.frame2.frame3.lab2 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame3.lab2a -textvariable "catalogue(etoile_nom_courant)"
            pack $audace(base).cataEtoile.frame2.frame3.lab2a -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame3.lab3 -text "$caption(catagoto,nom)"
            pack $audace(base).cataEtoile.frame2.frame3.lab3 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame3.lab3a -textvariable "catalogue(etoile_choisie)"
            pack $audace(base).cataEtoile.frame2.frame3.lab3a -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame3.lab4 -text "$caption(catagoto,magnitude)"
            pack $audace(base).cataEtoile.frame2.frame3.lab4 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame3.lab4a -textvariable "catalogue(etoile_mag)"
            pack $audace(base).cataEtoile.frame2.frame3.lab4a -side left -padx 5 -pady 5
         pack $audace(base).cataEtoile.frame2.frame3 -side top -fill both -expand 1
         frame $audace(base).cataEtoile.frame2.frame4 -borderwidth 0 -relief raised
            label $audace(base).cataEtoile.frame2.frame4.lab5 \
               -text "$caption(catagoto,RA) $caption(catagoto,J2000) $caption(catagoto,2points)"
            pack $audace(base).cataEtoile.frame2.frame4.lab5 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame4.lab5a -textvariable "catalogue(etoile_ad)"
            pack $audace(base).cataEtoile.frame2.frame4.lab5a -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame4.lab6 \
               -text "$caption(catagoto,DEC) $caption(catagoto,J2000) $caption(catagoto,2points)"
            pack $audace(base).cataEtoile.frame2.frame4.lab6 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame4.lab6a -textvariable "catalogue(etoile_dec)"
            pack $audace(base).cataEtoile.frame2.frame4.lab6a -side left -padx 5 -pady 5
         pack $audace(base).cataEtoile.frame2.frame4 -side top -fill both -expand 1
         frame $audace(base).cataEtoile.frame2.frame5 -borderwidth 0 -relief raised
            label $audace(base).cataEtoile.frame2.frame5.lab7 -text "$caption(catagoto,hauteur)"
            pack $audace(base).cataEtoile.frame2.frame5.lab7 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame5.labURLRed7a -textvariable "catalogue(etoile_hauteur_°)"
            pack $audace(base).cataEtoile.frame2.frame5.labURLRed7a -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame5.lab8 -text "$caption(catagoto,azimut)"
            pack $audace(base).cataEtoile.frame2.frame5.lab8 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame5.lab8a -textvariable "catalogue(etoile_azimut_°)"
            pack $audace(base).cataEtoile.frame2.frame5.lab8a -side left -padx 5 -pady 5
         pack $audace(base).cataEtoile.frame2.frame5 -side top -fill both -expand 1
         frame $audace(base).cataEtoile.frame2.frame6 -borderwidth 0 -relief raised
            label $audace(base).cataEtoile.frame2.frame6.lab9 -text "$caption(catagoto,angle_horaire)"
            pack $audace(base).cataEtoile.frame2.frame6.lab9 -side left -padx 5 -pady 5
            label $audace(base).cataEtoile.frame2.frame6.lab9a -textvariable "catalogue(etoile_anglehoraire)"
            pack $audace(base).cataEtoile.frame2.frame6.lab9a -side left -padx 5 -pady 5
         pack $audace(base).cataEtoile.frame2.frame6 -side top -fill both -expand 1
      pack $audace(base).cataEtoile.frame2 -side bottom -fill both -expand 1

      #--- Lit le catalogue des etoiles
      ::cataGoto::litCataEtoile

      #--- Positionne la liste d'etoiles sur la plus proche du meridien
      ::cataGoto::positionneEtoileMeridien

      #--- Definition du bind de selection de l'etoile choisie
      bind $zone(list_etoile) <Double-ButtonRelease-1> { }
      bind $zone(list_etoile) <ButtonRelease-1> {
         set thisstar [lindex $etbrillante [%W curselection]]
         #--- Preparation des affichages nom, nom courant, magnitude, AD et Dec.
         set catalogue(etoile_nom_courant) "[lindex $thisstar 0]"
         set catalogue(etoile_choisie)     "[lindex $thisstar 1] [lindex $thisstar 2]"
         set catalogue(etoile_mag)         "[lindex $thisstar 9]"
         set catalogue(etoile_ad)          "[lindex $thisstar 3]h[lindex $thisstar 4]m[lindex $thisstar 5]s"
         set catalogue(etoile_dec)         "[lindex $thisstar 6]d[lindex $thisstar 7]m[lindex $thisstar 8]s"
         #--- Extraction des coordonnees pour l'affichage de la carte de champ
         set cataGoto(carte,nom_objet)  "#etoile#"
         set cataGoto(carte,ad)         "[lindex $thisstar 3]h[lindex $thisstar 4]m[lindex $thisstar 5]s"
         set cataGoto(carte,dec)        "[lindex $thisstar 6]d[lindex $thisstar 7]'[lindex $thisstar 8]"
         set cataGoto(carte,dec)        "$cataGoto(carte,dec)"
         set cataGoto(carte,zoom_objet) "6"
         #--- Preparation des affichages hauteur et azimut
         set catalogue(etoile_altaz) [ mc_radec2altaz $catalogue(etoile_ad) $catalogue(etoile_dec) $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
         #--- Hauteur
         set catalogue(etoile_hauteur) "[format "%%05.2f" [lindex $catalogue(etoile_altaz) 1]]"
         if { $conf(cata,toujoursVisible) == "0" } {
            if { $catalogue(etoile_hauteur) < $conf(cata,haut_inf) } {
               set fg $color(red)
               $audace(base).cataEtoile.frame10.ok configure -state disabled
               $audace(base).cataEtoile.frame10.appliquer configure -state disabled
            } elseif { $catalogue(etoile_hauteur) > $conf(cata,haut_sup) } {
               set fg $color(red)
               $audace(base).cataEtoile.frame10.ok configure -state disabled
               $audace(base).cataEtoile.frame10.appliquer configure -state disabled
            } else {
               set fg $audace(color,textColor)
               $audace(base).cataEtoile.frame10.ok configure -state normal
               $audace(base).cataEtoile.frame10.appliquer configure -state normal
            }
         } else {
            if { $catalogue(etoile_hauteur) < $conf(cata,haut_inf) } {
               set fg $color(red)
            } elseif { $catalogue(etoile_hauteur) > $conf(cata,haut_sup) } {
               set fg $color(red)
            } else {
               set fg $audace(color,textColor)
            }
            $audace(base).cataEtoile.frame10.ok configure -state normal
            $audace(base).cataEtoile.frame10.appliquer configure -state normal
         }
         set catalogue(etoile_hauteur_°) "$catalogue(etoile_hauteur)$caption(catagoto,degre)"
         $audace(base).cataEtoile.frame2.frame5.labURLRed7a configure -fg $fg
         #--- Azimut
         set catalogue(etoile_azimut)   "[format "%%05.2f" [lindex $catalogue(etoile_altaz) 0]]"
         set catalogue(etoile_azimut_°) "$catalogue(etoile_azimut)$caption(catagoto,degre)"
         #--- Angle horaire
         set catalogue(etoile_anglehoraire)     [lindex $catalogue(etoile_altaz) 2]
         set catalogue(etoile_anglehoraire)     [mc_angle2hms $catalogue(etoile_anglehoraire) 360]
         set catalogue(etoile_anglehoraire_sec) [lindex $catalogue(etoile_anglehoraire) 2]
         set catalogue(etoile_anglehoraire)     [format "%%02dh%%02dm%%02ds" [lindex $catalogue(etoile_anglehoraire) 0] [lindex $catalogue(etoile_anglehoraire) 1] [expr int($catalogue(etoile_anglehoraire_sec))]]
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).cataEtoile
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" de le fenêtre "Etoiles"
   #  param visuNo numéro de la visu
   #
   proc cataEtoilesOK { visuNo } {
      global audace

      ::cataGoto::cataEtoilesAppliquer $visuNo
      destroy $audace(base).cataEtoile
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" de le fenêtre "Etoiles"
   #  @param visuNo numéro de la visu
   #
   proc cataEtoilesAppliquer { visuNo } {
      global catalogue

      ::cataGoto::recupPosition
      #--- Recopie les donnees
      set catalogue($visuNo,list_radec) "$catalogue(etoile_ad) $catalogue(etoile_dec)"
      set catalogue($visuNo,nom_objet)  "$catalogue(etoile_choisie)"
      set catalogue($visuNo,equinoxe)   "J2000.0"
      set catalogue($visuNo,magnitude)  ""
      #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
      $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer" de le fenêtre "Etoiles"
   #
   proc cataEtoilesFermer { } {
      global audace cataGoto

      ::cataGoto::recupPosition
      set cataGoto(carte,validation) "0"
      set cataGoto(carte,avant_plan) "0"
      destroy $audace(base).cataEtoile
   }

   #------------------------------------------------------------
   ## @brief lit le catalogue des étoiles brillantes
   #
   proc litCataEtoile { } {
      global audace etbrillante tableEtBrillante zone

      #--- Ouverture du catalogue des etoiles
      set f [open [file join $audace(rep_gui) audace catalogues catagoto etoiles_brillantes.txt] r]
      #--- Creation d'une liste des etoiles
      set etbrillante [split [read $f] "\n"]
      #--- Determine le nombre d'elements de la liste
      set long [llength $etbrillante]
      set long [expr $long-2]
      set tableEtBrillante(long) [expr $long + 1]
      #--- Met chaque ligne du catalogue dans une variable et acceleration de l'affichage
      pack forget $audace(base).cataEtoile.frame1.lb1
      pack forget $audace(base).cataEtoile.frame1.scrollbar
      pack forget $audace(base).cataEtoile.frame1
      for {set i 0} {$i <= $long} {incr i} {
         $zone(list_etoile) insert end "[lindex $etbrillante $i]"
         set j                                 [expr $i + 1]
         set tableEtBrillante($j)              [lindex $etbrillante $i]
         set tableEtBrillante(ad_$j)           "[lindex $tableEtBrillante($j) 3]h[lindex $tableEtBrillante($j) 4]m[lindex $tableEtBrillante($j) 5]"
         set tableEtBrillante(dec_$j)          "[lindex $tableEtBrillante($j) 6]d[lindex $tableEtBrillante($j) 7]m[lindex $tableEtBrillante($j) 8]"
         set tableEtBrillante(altaz_$j)        [ mc_radec2altaz $tableEtBrillante(ad_$j) $tableEtBrillante(dec_$j) $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
         set tableEtBrillante(anglehoraire_$j) [lindex $tableEtBrillante(altaz_$j) 2]
      }
      pack $audace(base).cataEtoile.frame1.lb1 -side left -anchor nw
      pack $audace(base).cataEtoile.frame1.scrollbar -side left -fill y
      pack $audace(base).cataEtoile.frame1 -side top -fill both -expand 1
      #--- Ferme le fichier des etoiles
      close $f
   }

   #------------------------------------------------------------
   ## @brief prépositionne la liste des étoiles sur l'étoile la plus proche du méridien
   #
   proc positionneEtoileMeridien { } {
      global audace tableEtBrillante

      set Ecart_meridien_mini "10.0"
      for {set j 1} {$j <= $tableEtBrillante(long)} {incr j} {
         if { $tableEtBrillante(anglehoraire_$j) > 180.0 } {
            set tableEtBrillante(anglehoraire_$j) [expr 360.0 - $tableEtBrillante(anglehoraire_$j)]
         }
         if { $tableEtBrillante(anglehoraire_$j) < $Ecart_meridien_mini } {
            set Ecart_meridien_mini $tableEtBrillante(anglehoraire_$j)
            set tableEtBrillante(indice) $j
         }
      }
      set index [expr ($tableEtBrillante(indice) - 5.0) / $tableEtBrillante(long)]
      if { $index <= "0" } {
         set index "0"
      }
      $audace(base).cataEtoile.frame1.lb1 yview moveto $index
   }

############################# Gestion de catalogues utilsateurs #############################

   #------------------------------------------------------------
   #  brief initialise les variables locales
   #
   proc initCataObjetUtilisateur { } {
      global catalogue

      #---
      set catalogue(utilisateur_choisie)      "-"
      set catalogue(utilisateur_mag)          "-"
      set catalogue(utilisateur_ad)           "-"
      set catalogue(objet_utilisateur_ad)     "$catalogue(utilisateur_ad)"
      set catalogue(utilisateur_dec)          "-"
      set catalogue(objet_utilisateur_dec)    "$catalogue(utilisateur_dec)"
      set catalogue(utilisateur_hauteur_°)    "-"
      set catalogue(utilisateur_azimut_°)     "-"
      set catalogue(utilisateur_anglehoraire) "-"
   }

   #------------------------------------------------------------
   #  brief affiche la fenêtre de configuration pour le choix des catalogues propres à l'utilisateur
   #  param visuNo numéro de la visu
   #
   proc cataObjetUtilisateurChoix { visuNo } {
      global audace catalogue

      #---
      ::cataGoto::nettoyage

      #--- Fenetre parent
      set fenetre "$audace(base)"

      #--- Ouvre la fenetre de configuration du choix du catalogue utilisateur
      set catalogue(utilisateur) [ ::tkutil::box_load $fenetre $audace(rep_userCatalog) $audace(bufNo) "5" ]

      #--- Ouverture de la fenetre de choix des objets
      if { $catalogue(utilisateur) != "" } {
         ::cataGoto::cataObjetUtilisateur $visuNo
      }
   }

   #------------------------------------------------------------
   #  brief affiche la fenêtre de configuration des catalogues propres à l'utilisateur
   #  param visuNo numéro de la visu
   #
   proc cataObjetUtilisateur { visuNo } {
      global audace caption cataGoto catalogue color conf objetUtilisateur zone

      #---
      ::cataGoto::initCataObjetUtilisateur

      #---
      ::cataGoto::nettoyage

      #---
      set cataGoto(cataObjetUtilisateur,position) $conf(cataObjetUtilisateur,position)

      #---
      if { [ info exists cataGoto(cataObjetUtilisateur,geometry) ] } {
         set deb [ expr 1 + [ string first + $cataGoto(cataObjetUtilisateur,geometry) ] ]
         set fin [ string length $cataGoto(cataObjetUtilisateur,geometry) ]
         set cataGoto(cataObjetUtilisateur,position) "+[ string range $cataGoto(cataObjetUtilisateur,geometry) $deb $fin ]"
      }

      #---
      toplevel $audace(base).cataObjetUtilisateur
      wm resizable $audace(base).cataObjetUtilisateur 0 0
      wm title $audace(base).cataObjetUtilisateur "$caption(catagoto,utilisateur)"
      wm geometry $audace(base).cataObjetUtilisateur $cataGoto(cataObjetUtilisateur,position)
      wm protocol $audace(base).cataObjetUtilisateur WM_DELETE_WINDOW "::cataGoto::cataObjetUtilisateurFermer"

      #--- La nouvelle fenetre est active
      focus $audace(base).cataObjetUtilisateur

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $audace(base).cataObjetUtilisateur <Key-F1> { ::console::GiveFocus }

      #--- Cree l'affichage du catalogue dans une fenetre a defilement
      frame $audace(base).cataObjetUtilisateur.frame1 -borderwidth 1 -relief raised
         listbox $audace(base).cataObjetUtilisateur.frame1.lb1 -width 59 -height 9 -borderwidth 2 -relief sunken \
            -yscrollcommand [list $audace(base).cataObjetUtilisateur.frame1.scrollbar set]
         pack $audace(base).cataObjetUtilisateur.frame1.lb1 -side left -anchor nw
         scrollbar $audace(base).cataObjetUtilisateur.frame1.scrollbar -orient vertical \
            -command [list $audace(base).cataObjetUtilisateur.frame1.lb1 yview] -takefocus 1 -borderwidth 1
         pack $audace(base).cataObjetUtilisateur.frame1.scrollbar -side left -fill y
         set zone(list_objet_utilisateur) $audace(base).cataObjetUtilisateur.frame1.lb1
      pack $audace(base).cataObjetUtilisateur.frame1 -side top -fill both -expand 1

      #--- Cree l'affichage des boutons
      frame $audace(base).cataObjetUtilisateur.frame8 -borderwidth 1 -relief raised
         button $audace(base).cataObjetUtilisateur.frame8.ok -text "$caption(catagoto,ok)" -width 7 \
            -state normal -command "::cataGoto::cataObjetUtilisateurOK $visuNo"
         if { $conf(ok+appliquer) == "1" } {
            pack $audace(base).cataObjetUtilisateur.frame8.ok -side left -padx 10 -pady 5 -ipady 5 -fill x
         }
         button $audace(base).cataObjetUtilisateur.frame8.appliquer -text "$caption(catagoto,appliquer)" -width 8 \
            -state normal -command "::cataGoto::cataObjetUtilisateurAppliquer $visuNo"
         pack $audace(base).cataObjetUtilisateur.frame8.appliquer -side left -padx 10 -pady 5 -ipady 5 -fill x
         if { $conf(cata,toujoursVisible) == "1" } {
            $audace(base).cataObjetUtilisateur.frame8.ok configure -state normal
            $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state normal
         } else {
            $audace(base).cataObjetUtilisateur.frame8.ok configure -state disabled
            $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state disabled
         }
         button $audace(base).cataObjetUtilisateur.frame8.fermer -text "$caption(catagoto,fermer)" \
            -width 7 -command "::cataGoto::cataObjetUtilisateurFermer"
         pack $audace(base).cataObjetUtilisateur.frame8.fermer -side right -padx 10 -pady 5 -ipady 5 -fill x
      pack $audace(base).cataObjetUtilisateur.frame8 -side bottom -fill both -expand 1

      #--- Cree l'affichage d'un checkbutton
      frame $audace(base).cataObjetUtilisateur.frame7 -borderwidth 1 -relief raised
         checkbutton $audace(base).cataObjetUtilisateur.frame7.carte -text "$caption(catagoto,ok_toujours_visible)" \
            -highlightthickness 0 -variable conf(cata,toujoursVisible)
         pack $audace(base).cataObjetUtilisateur.frame7.carte -side left -padx 10 -pady 5
      pack $audace(base).cataObjetUtilisateur.frame7 -side bottom -fill both -expand 1

      #--- Cree l'affichage des limites en hauteur
      frame $audace(base).cataObjetUtilisateur.frame6 -borderwidth 1 -relief raised
         label $audace(base).cataObjetUtilisateur.frame6.lab8 -text "$caption(catagoto,haut_inf)"
         pack $audace(base).cataObjetUtilisateur.frame6.lab8 -side left -padx 10 -pady 5
         entry $audace(base).cataObjetUtilisateur.frame6.haut_inf -textvariable "conf(cata,haut_inf)" \
            -justify center -width 4
         pack $audace(base).cataObjetUtilisateur.frame6.haut_inf -side left -padx 10 -pady 5
         label $audace(base).cataObjetUtilisateur.frame6.lab9 -text "$caption(catagoto,haut_sup)"
         pack $audace(base).cataObjetUtilisateur.frame6.lab9 -side left -padx 10 -pady 5
         entry $audace(base).cataObjetUtilisateur.frame6.haut_sup -textvariable "conf(cata,haut_sup)" \
            -justify center -width 4
         pack $audace(base).cataObjetUtilisateur.frame6.haut_sup -side left -padx 10 -pady 5
      pack $audace(base).cataObjetUtilisateur.frame6 -side bottom -fill both -expand 1

      #--- Cree l'affichage de la selection
      frame $audace(base).cataObjetUtilisateur.frame2 -borderwidth 1 -relief raised
         frame $audace(base).cataObjetUtilisateur.frame2.frame3 -borderwidth 0 -relief raised
            label $audace(base).cataObjetUtilisateur.frame2.frame3.lab1 -text "$caption(catagoto,objet_choisi)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame3.lab1 -side top -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame3.lab2 -text "$caption(catagoto,nom)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame3.lab2 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame3.lab2a -textvariable "catalogue(utilisateur_choisie)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame3.lab2a -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame3.lab3 -text "$caption(catagoto,magnitude)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame3.lab3 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame3.lab3a -textvariable "catalogue(utilisateur_mag)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame3.lab3a -side left -padx 5 -pady 5
         pack $audace(base).cataObjetUtilisateur.frame2.frame3 -side top -fill both -expand 1
         frame $audace(base).cataObjetUtilisateur.frame2.frame4 -borderwidth 0 -relief raised
            label $audace(base).cataObjetUtilisateur.frame2.frame4.lab4 \
               -text "$caption(catagoto,RA) $caption(catagoto,J2000) $caption(catagoto,2points)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame4.lab4 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame4.lab4a -textvariable "catalogue(utilisateur_ad)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame4.lab4a -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame4.lab5 \
               -text "$caption(catagoto,DEC) $caption(catagoto,J2000) $caption(catagoto,2points)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame4.lab5 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame4.lab5a -textvariable "catalogue(utilisateur_dec)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame4.lab5a -side left -padx 5 -pady 5
         pack $audace(base).cataObjetUtilisateur.frame2.frame4 -side top -fill both -expand 1
         frame $audace(base).cataObjetUtilisateur.frame2.frame5 -borderwidth 0 -relief raised
            label $audace(base).cataObjetUtilisateur.frame2.frame5.lab6 -text "$caption(catagoto,hauteur)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame5.lab6 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame5.labURLRed6a -textvariable "catalogue(utilisateur_hauteur_°)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame5.labURLRed6a -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame5.lab7 -text "$caption(catagoto,azimut)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame5.lab7 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame5.lab7a -textvariable "catalogue(utilisateur_azimut_°)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame5.lab7a -side left -padx 5 -pady 5
         pack $audace(base).cataObjetUtilisateur.frame2.frame5 -side top -fill both -expand 1
         frame $audace(base).cataObjetUtilisateur.frame2.frame6 -borderwidth 0 -relief raised
            label $audace(base).cataObjetUtilisateur.frame2.frame6.lab8 -text "$caption(catagoto,angle_horaire)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame6.lab8 -side left -padx 5 -pady 5
            label $audace(base).cataObjetUtilisateur.frame2.frame6.lab8a -textvariable "catalogue(utilisateur_anglehoraire)"
            pack $audace(base).cataObjetUtilisateur.frame2.frame6.lab8a -side left -padx 5 -pady 5
         pack $audace(base).cataObjetUtilisateur.frame2.frame6 -side top -fill both -expand 1
      pack $audace(base).cataObjetUtilisateur.frame2 -side bottom -fill both -expand 1

      #--- Lit le catalogue des objets utilisateur
      ::cataGoto::litCataUtilisateur

      #--- Definition du bind de selection de l'objet utilisateur choisie
      bind $zone(list_objet_utilisateur) <Double-ButtonRelease-1> { }
      bind $zone(list_objet_utilisateur) <ButtonRelease-1> {
         set thisuser [lindex $objetUtilisateur [%W curselection]]
         #--- Preparation des affichages nom, magnitude, AD et Dec.
         if { [string first "\t" $thisuser  ] != -1 } {
            #--- si la ligne contient au moins une tabulation, alors le separateur est la tabulation
            set thisuser [split $thisuser "\t"]
            #--- je recupere les valeurs
            set catalogue(utilisateur_choisie)   [lindex $thisuser 0]
            set catalogue(objet_utilisateur_ad)  [lindex $thisuser 1]
            set catalogue(utilisateur_ad)        $catalogue(objet_utilisateur_ad)
            set catalogue(objet_utilisateur_dec) [lindex $thisuser 2]
            set catalogue(utilisateur_dec)       $catalogue(objet_utilisateur_dec)
            set catalogue(utilisateur_mag)       [lindex $thisuser 3]
         } else {
            #--- sinon le separateur est un espace ou une serie d'espaces
            set catalogue(utilisateur_choisie)   "[lindex $thisuser 0]"
            set catalogue(utilisateur_mag)       "[lindex $thisuser 7]"
            set catalogue(objet_utilisateur_ad)  "[lindex $thisuser 1]h[lindex $thisuser 2]m[lindex $thisuser 3]s"
            set catalogue(utilisateur_ad)        $catalogue(objet_utilisateur_ad)
            set catalogue(objet_utilisateur_dec) "[lindex $thisuser 4]d[lindex $thisuser 5]m[lindex $thisuser 6]s"
            set catalogue(utilisateur_dec)       $catalogue(objet_utilisateur_dec)
         }
         if { ($catalogue(objet_utilisateur_ad) == "hm") || ($catalogue(objet_utilisateur_dec) == "dm") } {
            set catalogue(utilisateur_hauteur_°)    "-"
            set catalogue(utilisateur_azimut_°)     "-"
            set catalogue(utilisateur_anglehoraire) "-"
            $audace(base).cataObjetUtilisateur.frame8.ok configure -state disabled
            $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state disabled
         } else {
            #--- Preparation des affichages hauteur et azimut
            set catalogue(objet_utilisateur_altaz) [ mc_radec2altaz $catalogue(objet_utilisateur_ad) $catalogue(objet_utilisateur_dec) $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
            #--- Hauteur
            set catalogue(objet_utilisateur_hauteur) "[format "%%05.2f" [lindex $catalogue(objet_utilisateur_altaz) 1]]"
            if { $conf(cata,toujoursVisible) == "0" } {
               if { $catalogue(objet_utilisateur_hauteur) < $conf(cata,haut_inf) } {
                  set fg $color(red)
                  $audace(base).cataObjetUtilisateur.frame8.ok configure -state disabled
                  $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state disabled
               } elseif { $catalogue(objet_utilisateur_hauteur) > $conf(cata,haut_sup) } {
                  set fg $color(red)
                  $audace(base).cataObjetUtilisateur.frame8.ok configure -state disabled
                  $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state disabled
               } else {
                  set fg $audace(color,textColor)
                  $audace(base).cataObjetUtilisateur.frame8.ok configure -state normal
                  $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state normal
               }
            } else {
               if { $catalogue(objet_utilisateur_hauteur) < $conf(cata,haut_inf) } {
                  set fg $color(red)
               } elseif { $catalogue(objet_utilisateur_hauteur) > $conf(cata,haut_sup) } {
                  set fg $color(red)
               } else {
                  set fg $audace(color,textColor)
               }
               $audace(base).cataObjetUtilisateur.frame8.ok configure -state normal
               $audace(base).cataObjetUtilisateur.frame8.appliquer configure -state normal
            }
            set catalogue(utilisateur_hauteur_°) "$catalogue(objet_utilisateur_hauteur)$caption(catagoto,degre)"
            $audace(base).cataObjetUtilisateur.frame2.frame5.labURLRed6a configure -fg $fg
            #--- Azimut
            set catalogue(objet_utilisateur_azimut) "[format "%%05.2f" [lindex $catalogue(objet_utilisateur_altaz) 0]]"
            set catalogue(utilisateur_azimut_°)     "$catalogue(objet_utilisateur_azimut)$caption(catagoto,degre)"
            #--- Angle horaire
            set catalogue(objet_utilisateur_anglehoraire)     [lindex $catalogue(objet_utilisateur_altaz) 2]
            set catalogue(objet_utilisateur_anglehoraire)     [mc_angle2hms $catalogue(objet_utilisateur_anglehoraire) 360]
            set catalogue(objet_utilisateur_anglehoraire_sec) [lindex $catalogue(objet_utilisateur_anglehoraire) 2]
            set catalogue(objet_utilisateur_anglehoraire)     [format "%%02dh%%02dm%%02ds" [lindex $catalogue(objet_utilisateur_anglehoraire) 0] [lindex $catalogue(objet_utilisateur_anglehoraire) 1] [expr int($catalogue(objet_utilisateur_anglehoraire_sec))]]
            set catalogue(utilisateur_anglehoraire)           $catalogue(objet_utilisateur_anglehoraire)
         }
      }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).cataObjetUtilisateur
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" de la fenêtre "Utilisateur"
   #  param visuNo numéro de la visu
   #
   proc cataObjetUtilisateurOK { visuNo } {
      global audace

      ::cataGoto::cataObjetUtilisateurAppliquer $visuNo
      destroy $audace(base).cataObjetUtilisateur
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" de la fenêtre "Utilisateur"
   #  @param visuNo numéro de la visu
   #
   proc cataObjetUtilisateurAppliquer { visuNo } {
      global catalogue

      ::cataGoto::recupPosition
      #--- Recopie les donnees
      set catalogue($visuNo,list_radec) "$catalogue(objet_utilisateur_ad) $catalogue(objet_utilisateur_dec)"
      set catalogue($visuNo,nom_objet)  "$catalogue(utilisateur_choisie)"
      set catalogue($visuNo,equinoxe)   "J2000.0"
      set catalogue($visuNo,magnitude)  "$catalogue(utilisateur_mag)"
      #--- Mise a jour des coordonnees pour les outils Telescope et Controle a distance
      $catalogue($visuNo,nameSpaceCaller)::setRaDec $visuNo $catalogue($visuNo,list_radec) $catalogue($visuNo,nom_objet) $catalogue($visuNo,equinoxe) $catalogue($visuNo,magnitude)
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer" de la fenêtre "Utilisateur"
   #
   proc cataObjetUtilisateurFermer { } {
      global audace cataGoto

      ::cataGoto::recupPosition
      set cataGoto(carte,validation) "0"
      set cataGoto(carte,avant_plan) "0"
      destroy $audace(base).cataObjetUtilisateur
   }

   #------------------------------------------------------------
   ## @brief recherche l'objet choisi dans les catalogues propres à l'utilisateur
   #
   proc litCataUtilisateur { } {
     global audace catalogue objetUtilisateur zone

      #--- Ouverture du catalogue des objets utilisateur
      set f [open [file join $audace(rep_userCatalog) $catalogue(utilisateur)] r]
      #--- Creation d'une liste des objets utilisateur
      set objetUtilisateur [split [read $f] "\n"]
      #--- Determine le nombre d'elements de la liste
      set long [llength $objetUtilisateur]
      #--- Recherche le numero de la ligne avec les '---'
      set ligne_en_trop "0"
      for {set j 0} {$j <= $long} {incr j} {
         set ligne [lindex $objetUtilisateur $j]
         if { [string compare [lindex $ligne 0] "---"]=="0"} {
            set ligne_en_trop "1"
            break
         }
      }
      if { $ligne_en_trop == "1" } {
         #--- Supprime les 'j' lignes de commentaires
         set objetUtilisateur [lreplace $objetUtilisateur 0 $j]
      }
      #--- Determine le nombre d'elements de la nouvelle liste
      set long_new [llength $objetUtilisateur]
      set long_new [expr $long_new-1]
      #--- Met chaque ligne du catalogue dans une variable et acceleration de l'affichage
      pack forget $audace(base).cataObjetUtilisateur.frame1.lb1
      pack forget $audace(base).cataObjetUtilisateur.frame1.scrollbar
      pack forget $audace(base).cataObjetUtilisateur.frame1
      for {set i 0} {$i <= $long_new} {incr i} {
         $zone(list_objet_utilisateur) insert end "[lindex $objetUtilisateur $i]"
      }
      pack $audace(base).cataObjetUtilisateur.frame1.lb1 -side left -anchor nw
      pack $audace(base).cataObjetUtilisateur.frame1.scrollbar -side left -fill y
      pack $audace(base).cataObjetUtilisateur.frame1 -side top -fill both -expand 1
      #--- Ferme le fichier des objets utilisateur
      close $f
   }

}

#--- Initialisation
::cataGoto::init


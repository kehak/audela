#
# Fichier : eventaude_gps.tcl
# Description : Permet de controler l'alimentation AlAudine NT avec port I2C
# Auteur : Robert DELMAS
# Mise à jour $Id: eventaude_gps.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::eventAudeGPS {
}

#
# run
# Cree la fenetre de tests
# this = chemin de la fenetre
#
proc ::eventAudeGPS::run { this } {
   variable This

   set This $this
   createDialog
}

#
# ok
# Fonction appellee lors de l'appui sur le bouton 'OK'
#
proc ::eventAudeGPS::ok { } {
   variable This

   ::eventAudeGPS::appliquer
   ::eventAudeGPS::recupPosition
   destroy $This
}

#
# appliquer
# Fonction appellee lors de l'appui sur le bouton 'Appliquer'
#
proc ::eventAudeGPS::appliquer { } {
   ::eventAudeGPS::widgetToConf
}

#
# afficherAide
# Fonction appellee lors de l'appui sur le bouton 'Aide'
#
proc ::eventAudeGPS::afficherAide { } {
   ::audace::showHelpPlugin link ethernaude "eventaude.htm"
}

#
# fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::eventAudeGPS::fermer { } {
   variable This

   ::eventAudeGPS::recupPosition
   destroy $This
}

#
# recupPosition
# Permet de recuperer et de sauvegarder la position de la fenetre de configuration de l'alimentation
#
proc ::eventAudeGPS::recupPosition { } {
   variable This
   variable private
   global conf

   set private(geometry) [ wm geometry $This ]
   set deb [ expr 1 + [ string first + $private(geometry) ] ]
   set fin [ string length $private(geometry) ]
   set private(position) "+[ string range $private(geometry) $deb $fin ]"
   #---
   set conf(eventaude_gps,position) $private(position)
}

#
# createDialog
# Creation de l'interface graphique
#
proc ::eventAudeGPS::createDialog { } {
   variable This
   variable private
   global audace caption color conf

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) link ethernaude eventaude_gps.cap ]

   #--- Initialisation de la variable de configuration
   if { ! [ info exists conf(eventaude_gps,position) ] } { set conf(eventaude_gps,position) "+600+490" }

   #--- Initialisation de variables locales
   if { ! [ info exists private(coord_GPS_Observateur) ] } { set private(coord_GPS_Observateur) "" }
   if { ! [ info exists private(longi_GPS_Observateur) ] } { set private(longi_GPS_Observateur) "" }
   if { ! [ info exists private(lati_GPS_Observateur) ] }  { set private(lati_GPS_Observateur)  "" }
   if { ! [ info exists private(alti_GPS_Observateur) ] }  { set private(alti_GPS_Observateur)  "" }

   #--- Recupere le camNo de la camera
   set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]

   #--- Verifie si l'EventAude existe et si elle est sous tension
   if { [ cam$camNo hasEventaude ] != "1" } {
      tk_messageBox -title "$caption(eventaude_gps,attention)" -icon error \
         -message "$caption(eventaude_gps,message_1)\n$caption(eventaude_gps,message_2)"
      return
   }

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      ::eventAudeGPS::coordGPS
      return
   }

   #---
   set private(position) $conf(eventaude_gps,position)
   #---
   if { [ info exists private(geometry) ] } {
      set deb [ expr 1 + [ string first + $private(geometry) ] ]
      set fin [ string length $private(geometry) ]
      set private(position) "+[ string range $private(geometry) $deb $fin ]"
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(eventaude_gps,titre)
   wm geometry $This $private(position)
   wm resizable $This 0 0
   wm protocol $This WM_DELETE_WINDOW ::eventAudeGPS::fermer

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side top -fill x

   frame $This.frame3 -borderwidth 0 -relief raised
   pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame4 -borderwidth 0 -relief raised
   pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame5 -borderwidth 0 -relief raised
   pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame6 -borderwidth 0 -relief raised
   pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame7 -borderwidth 0 -relief raised
   pack $This.frame7 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame1 -side top -fill both -expand 1

   #--- Rafraichissement des coordonnes GPS
   button $This.rafraichir -text "$caption(eventaude_gps,rafraichir)" \
      -command "::eventAudeGPS::coordGPS"
   pack $This.rafraichir -in $This.frame3 -side top -padx 3 -pady 3 -ipadx 5 -ipady 5

   #--- Coordonnees du lieu au format GPS
   label $This.lab1 -text "$caption(eventaude_gps,position_gps)"
   pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 5 -pady 5
   label $This.lab2 -textvariable "::eventAudeGPS::private(coord_GPS_Observateur)"
   pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

   #--- Longitude
   label $This.lab3 -text "$caption(eventaude_gps,longitude)"
   pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5
   label $This.lab4 -textvariable "::eventAudeGPS::private(longi_GPS_Observateur)"
   pack $This.lab4 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Latitude
   label $This.lab5 -text "$caption(eventaude_gps,latitude)"
   pack $This.lab5 -in $This.frame5 -anchor center -side left -padx 5 -pady 5
   label $This.lab6 -textvariable "::eventAudeGPS::private(lati_GPS_Observateur)"
   pack $This.lab6 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

   #--- Altitude
   label $This.lab7 -text "$caption(eventaude_gps,altitude)"
   pack $This.lab7 -in $This.frame6 -anchor center -side left -padx 5 -pady 5
   label $This.lab8 -textvariable "::eventAudeGPS::private(alti_GPS_Observateur)"
   pack $This.lab8 -in $This.frame6 -anchor center -side left -padx 5 -pady 5

   #--- Mise a jour de la longitude et de la latitude
   button $This.maj_long_lat -text "$caption(eventaude_gps,maj_long+lat)" \
      -command "::eventAudeGPS::confirmSaveLongLat"
   pack $This.maj_long_lat -in $This.frame7 -side top -padx 3 -pady 3 -ipadx 5 -ipady 5

   #--- Mise a jour de l'altitude
   button $This.maj_alt -text "$caption(eventaude_gps,maj_alt)" \
      -command "::eventAudeGPS::confirmSaveAlt"
   pack $This.maj_alt -in $This.frame7 -side top -padx 3 -pady 3 -ipadx 5 -ipady 5

   #--- Site web officiel de l'EventAude
   label $This.lab103 -text "$caption(eventaude_gps,site_web_ref)"
   pack $This.lab103 -in $This.frame8 -side top -fill x -pady 2

   label $This.labURL -text "$caption(eventaude_gps,site_eventaude)" -fg $color(blue)
   pack $This.labURL -in $This.frame8 -side top -fill x -pady 2

   #--- Creation du lien avec le navigateur web et changement de sa couleur
   bind $This.labURL <ButtonPress-1> {
      set filename "$caption(eventaude_gps,site_eventaude)"
      ::audace::Lance_Site_htm $filename
   }
   bind $This.labURL <Enter> {
      $::eventAudeGPS::This.labURL configure -fg $color(purple)
   }
   bind $This.labURL <Leave> {
      $::eventAudeGPS::This.labURL configure -fg $color(blue)
   }

   #--- Cree le bouton 'OK'
   button $This.frame2.ok -text "$caption(eventaude_gps,ok)" -width 7 \
      -command "::eventAudeGPS::ok"
   if { $conf(ok+appliquer) == "1" } {
      pack $This.frame2.ok -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x
   }

   #--- Cree le bouton 'Appliquer'
   button $This.frame2.appliquer -text "$caption(eventaude_gps,appliquer)" -width 8 \
      -command "::eventAudeGPS::appliquer"
   pack $This.frame2.appliquer -in $This.frame2 -side left -padx 3 -pady 3 -ipady 5 -fill x

   #--- Cree le bouton 'Fermer'
   button $This.frame2.fermer -text "$caption(eventaude_gps,fermer)" -width 7 \
      -command "::eventAudeGPS::fermer"
   pack $This.frame2.fermer -side right -padx 3 -pady 3 -ipady 5 -fill x

   #--- Cree le bouton 'Aide'
   button $This.frame2.aide -text "$caption(eventaude_gps,aide)" -width 7 \
      -command "::eventAudeGPS::afficherAide"
   pack $This.frame2.aide -in $This.frame2 -side right -padx 3 -pady 3 -ipady 5 -fill x

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This

   #--- Recuperation des coordonnees GPS par l'EventAude
   ::eventAudeGPS::coordGPS
}

#
# widgetToConf
# Acquisition de la configuration, c'est a dire isolation des
# differentes variables dans le tableau conf(...)
#
proc ::eventAudeGPS::widgetToConf { } {
   variable private
   global conf

   #--- Memorise
}

#
# coordGPS
# Permet d'obtenir les coordonnees GPS de l'observateur
#
proc ::eventAudeGPS::coordGPS { } {
   variable private
   global caption

   #--- Remarque : La commande [set $xxx] permet de recuperer le contenu d'une variable
   set camNo [ ::confCam::getCamNo [ ::confCam::getCurrentCamItem ] ]
   if { $camNo != "0" } {
      if { [ catch { set private(coord_GPS_Observateur) [ cam$camNo gps ] } ] == "0" } {
         #--- Verifie que le GPS est connecte et synchronise
         set coord_GPS $private(coord_GPS_Observateur)
         if { ( [ lindex $coord_GPS 1 ] == "572900.5" ) || ( [ lindex $coord_GPS 3 ] == "572900.5" ) || ( [ lindex $coord_GPS 4 ] == "9999.0" ) } {
            ::eventAudeGPS::fermer
            tk_messageBox -title "$caption(eventaude_gps,attention)" -icon error \
               -message "$caption(eventaude_gps,message_3)"
            return
         }
         #--- Recupere les coordonnees geographiques
         set private(long_GPS_Observateur) [ mc_angle2dms [ lindex $private(coord_GPS_Observateur) 1 ] 180 ]
         set longi_est_ouest [ lindex $private(coord_GPS_Observateur) 2 ]
         if { $longi_est_ouest == "W" } {
            set longi_est_ouest "$caption(eventaude_gps,ouest)"
         } elseif { $longi_est_ouest == "E" } {
            set longi_est_ouest "$caption(eventaude_gps,est)"
         }
         set private(longi_GPS_Observateur) "$longi_est_ouest [ format "%2d° %2d' %4.2f''" [ lindex $private(long_GPS_Observateur) 0 ] [ lindex $private(long_GPS_Observateur) 1 ] [ lindex $private(long_GPS_Observateur) 2 ] ]"
         set private(lat_GPS_Observateur) [ mc_angle2dms [ lindex $private(coord_GPS_Observateur) 3 ] 90 ]
         set private(lati_GPS_Observateur) [ format "%2d° %2d' %4.2f''" [ lindex $private(lat_GPS_Observateur) 0 ] [ lindex $private(lat_GPS_Observateur) 1 ] [ lindex $private(lat_GPS_Observateur) 2 ] ]
         set private(alt_GPS_Observateur) [ lindex $private(coord_GPS_Observateur) 4 ]
         set private(alti_GPS_Observateur) [ format "%5.0f m" $private(alt_GPS_Observateur) ]
      }
   }
}

#
# confirmSaveLongLat
# Confirme la sauvegarde des coordonnees GPS en longitude et en latitude
#
proc ::eventAudeGPS::confirmSaveLongLat { } {
   variable private
   global audace caption confgene

   set choix [ tk_messageBox -type yesno -icon warning -title "$caption(eventaude_gps,maj_long+lat-)" \
      -message "$caption(eventaude_gps,confirm)" ]
   if { $choix == "yes" } {
      #--- Mise en forme et sauvegarde de la longitude
      set confgene(posobs,long) [lindex $private(coord_GPS_Observateur) 1]
      set confgene(posobs,long) [mc_angle2dms $confgene(posobs,long) 180 nozero 1 auto string]
      set confgene(posobs,estouest) [lindex $private(coord_GPS_Observateur) 2]
      if { $confgene(posobs,estouest) == "W" } {
         set confgene(posobs,estouest) "$caption(eventaude_gps,ouest)"
      } elseif { $confgene(posobs,estouest) == "E" } {
         set confgene(posobs,estouest) $caption(eventaude_gps,est)
      }

      #--- Mise en forme et sauvegarde de la latitude
      set confgene(posobs,lat) [lindex $private(coord_GPS_Observateur) 3]
      if { $confgene(posobs,lat) < 0 } {
         set confgene(posobs,nordsud) "$caption(eventaude_gps,sud)"
         set confgene(posobs,lat)     "[expr abs($confgene(posobs,lat))]"
      } else {
         set confgene(posobs,nordsud) "$caption(eventaude_gps,nord)"
         set confgene(posobs,lat)     "$confgene(posobs,lat)"
      }
      set confgene(posobs,lat) [mc_angle2dms $confgene(posobs,lat) 90 nozero 1 auto string]

      #--- Mise a jour de champs de la boite Position de l'observateur
      set confgene(posobs,ref_geodesique)         "WGS84"
      set confgene(posobs,station_uai)            ""
      set confgene(posobs,observateur,mpc)        ""
      $audace(base).confPosObs.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" \
         -fg $audace(color,textColor)
      set confgene(posobs,observateur,mpcstation) ""
      $audace(base).confPosObs.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" \
         -fg $audace(color,textColor)
      ::confPosObs::Position
   }
}

#
# confirmSaveAlt
# Confirme la sauvegarde des coordonnees GPS en altitude
#
proc ::eventAudeGPS::confirmSaveAlt { } {
  variable private
   global audace caption confgene

   set choix [ tk_messageBox -type yesno -icon warning -title "$caption(eventaude_gps,maj_alt-)" \
      -message "$caption(eventaude_gps,confirm)" ]
   if { $choix == "yes" } {
      #--- Mise en forme et sauvegarde de l'altitude
      set confgene(posobs,altitude)               [ string trimleft [ format "%5.0f" $private(alt_GPS_Observateur) ] " " ]

      #--- Mise a jour de champs de la boite Position de l'observateur
      set confgene(posobs,ref_geodesique)         "WGS84"
      set confgene(posobs,station_uai)            ""
      set confgene(posobs,observateur,mpc)        ""
      $audace(base).confPosObs.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" \
         -fg $audace(color,textColor)
      set confgene(posobs,observateur,mpcstation) ""
      $audace(base).confPosObs.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" \
         -fg $audace(color,textColor)
      ::confPosObs::Position
   }
}


#
## @file confgene.tcl
#  @brief Configuration générale d'AudeLA et d'Aud'ACE
#  @details langage, éditeurs, répertoires, position de l'observateur,
#  temps (heure système ou TU), fichiers image, alarme sonore de fin de pose,
#  type de fenêtre, la fenêtre A propos de ...
#  et une fenêtre de configuration générique
#  @author Robert DELMAS
#  $Id: confgene.tcl 14460 2018-08-09 17:23:53Z alainklotz $
#

## namespace confPosObs
#  @brief Position de l'observateur

namespace eval ::confPosObs {

   #------------------------------------------------------------
   #  brief crée la fenêtre définissant la position de l'observateur
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      ::confPosObs::createDialog
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK"
   #  pour appliquer la position de l'observateur
   #
   proc ok { } {
      ::confPosObs::appliquer
      ::confPosObs::fermer
   }

   #------------------------------------------------------------
   ## @brief brief commande associée au bouton "Appliquer"
   #  pour mémoriser et appliquer la position de l'observateur
   #
   proc appliquer { } {
      ::confPosObs::MPC
      ::confPosObs::Position
      ::confPosObs::widgetToConf
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1050position.htm"
   }

   #------------------------------------------------------------
   ## @brief commande asscoiée au bouton "Fermer"
   #
   proc fermer { } {
      variable This
      global conf confgene

      set confgene(posobs,nom_organisation)        $conf(posobs,nom_organisation)
      set confgene(posobs,nom_observateur)         $conf(posobs,nom_observateur)
      set confgene(posobs,nom_observatoire)        $conf(posobs,nom_observatoire)
      set confgene(posobs,estouest)                $conf(posobs,estouest)
      set confgene(posobs,long)                    $conf(posobs,long)
      set confgene(posobs,nordsud)                 $conf(posobs,nordsud)
      set confgene(posobs,lat)                     $conf(posobs,lat)
      set confgene(posobs,altitude)                $conf(posobs,altitude)
      set confgene(posobs,ref_geodesique)          $conf(posobs,ref_geodesique)
      set confgene(posobs,observateur,gps)         $conf(posobs,observateur,gps)
      set confgene(posobs,station_uai)             $conf(posobs,station_uai)
      set confgene(posobs,fichier_station_uai)     $conf(posobs,fichier_station_uai)
      set confgene(posobs,observateur,mpc)         $conf(posobs,observateur,mpc)
      set confgene(posobs,observateur,mpcstation)  $conf(posobs,observateur,mpcstation)

      #--- je recupere la geometrie de la fenetre
      ::confPosObs::recupPosDim

      destroy $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre "Position de l'observateur"
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(posobs,nom_organisation) définit le nom de l'organisation
   #  - conf(posobs,nom_observateur)  définit le ou les noms des observateurs
   #  - conf(posobs,nom_observatoire) définit le nom de l'observatoire
   #  - conf(posobs,ref_geodesique)   définit le système géodésique de référence des coordonnées de l'observateur
   #  - conf(posobs,station_uai)      définit la référence UAI de l'observatoire
   #  - conf(posobs,estouest)         définit si l'observateur est à l'est ou à l'ouest du méridien de Greenwich
   #  - conf(posobs,long)             définit la longitude de l'observateur
   #  - conf(posobs,nordsud)          définit si l'observateur est dans l'hémisphère nord ou sud
   #  - conf(posobs,lat)              définit la latitude de l'observateur
   #  - conf(posobs,altitude)         définit l'altitude de l'observateur
   #  - conf(posobs,observateur,gps)  définit les coordonnées GPS de l'observateur
   #  - conf(posobs,estouest_long)    définit la longitude est ou ouest de l'observateur
   #  - conf(posobs,nordsud_lat)      définit la latitude nord ou sud de l'observateur
   #
   proc initConf { } {
      global audace conf

      #--- Initialisation indispensable de variables
      if { ! [ info exists conf(posobs,geometry) ] }         { set conf(posobs,geometry)         "448x545+180+50" }
      if { ! [ info exists conf(posobs,nom_organisation) ] } { set conf(posobs,nom_organisation) "" }
      if { ! [ info exists conf(posobs,nom_observateur) ] }  { set conf(posobs,nom_observateur)  "" }
      if { ! [ info exists conf(posobs,nom_observatoire) ] } { set conf(posobs,nom_observatoire) "Pic du Midi" }
      if { ! [ info exists conf(posobs,ref_geodesique) ] }   { set conf(posobs,ref_geodesique)   "WGS84" }
      if { ! [ info exists conf(posobs,station_uai) ] }      { set conf(posobs,station_uai)      "586" }

      #--- Observatoire du Pic du Midi
      if { ! [ info exists conf(posobs,estouest) ] }         { set conf(posobs,estouest)         "E" }
      if { ! [ info exists conf(posobs,long) ] }             { set conf(posobs,long)             "0d8m32s2" }
      if { ! [ info exists conf(posobs,nordsud) ] }          { set conf(posobs,nordsud)          "N" }
      if { ! [ info exists conf(posobs,lat) ] }              { set conf(posobs,lat)              "42d56m11s9" }
      if { ! [ info exists conf(posobs,altitude) ] }         { set conf(posobs,altitude)         "2890.5" }
      if { ! [ info exists conf(posobs,observateur,gps) ] }  { set conf(posobs,observateur,gps)  "GPS 0.142300 E 42.936639 2890.5" }

      #--- Concatenation de variables pour l'en-tete FITS
      set conf(posobs,estouest_long) $conf(posobs,estouest)$conf(posobs,long)
      set conf(posobs,nordsud_lat)   $conf(posobs,nordsud)$conf(posobs,lat)

      #--- Variable audace
      set audace(posobs,observateur,gps) $conf(posobs,observateur,gps)
   }

   #------------------------------------------------------------
   ## @brief initialise d'autres paramètres de la position de l'observateur
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(posobs,fichier_station_uai)    définit le nom du fichier contenant les référence UAI de tous les observatoires
   #  - conf(posobs,observateur,mpc)        définit les coordonnées au format MPC d'un observatoire référencé par l'UAI
   #  - conf(posobs,observateur,mpcstation) définit les coordonnées au format MPCSTATION d'un observatoire référencé par l'UAI
   #  - conf(posobs,config_observatoire,0)  définit les coordonnées GPS de l'observatoire numéro 0
   #  - conf(posobs,config_observatoire,1)  définit les coordonnées GPS de l'observatoire numéro 1
   #  - conf(posobs,config_observatoire,2)  définit les coordonnées GPS de l'observatoire numéro 2
   #  - conf(posobs,config_observatoire,3)  définit les coordonnées GPS de l'observatoire numéro 3
   #  - conf(posobs,config_observatoire,4)  définit les coordonnées GPS de l'observatoire numéro 4
   #  - conf(posobs,config_observatoire,5)  définit les coordonnées GPS de l'observatoire numéro 5
   #  - conf(posobs,config_observatoire,6)  définit les coordonnées GPS de l'observatoire numéro 6
   #  - conf(posobs,config_observatoire,7)  définit les coordonnées GPS de l'observatoire numéro 7
   #  - conf(posobs,config_observatoire,8)  définit les coordonnées GPS de l'observatoire numéro 8
   #  - conf(posobs,config_observatoire,9)  définit les coordonnées GPS de l'observatoire numéro 9
   #
   proc initConf1 { } {
      global conf

      #--- Initialisation indispensable d'autres variables
      if { ! [ info exists conf(posobs,fichier_station_uai) ] }    { set conf(posobs,fichier_station_uai)    "obscodes.txt" }
      if { ! [ info exists conf(posobs,observateur,mpc) ] }        { set conf(posobs,observateur,mpc)        "" }
      if { ! [ info exists conf(posobs,observateur,mpcstation) ] } { set conf(posobs,observateur,mpcstation) "" }

      #--- Observatoire du Pic du Midi - FRANCE
      if { ! [ info exists conf(posobs,config_observatoire,0) ] } {
         #--- Je prepare un exemple de configuration optique
         array set config_observatoire { }
         set config_observatoire(nom_observatoire) "Pic du Midi"
         set config_observatoire(estouest)         "E"
         set config_observatoire(long)             "0d8m32s2"
         set config_observatoire(nordsud)          "N"
         set config_observatoire(lat)              "42d56m11s9"
         set config_observatoire(altitude)         "2890.5"
         set config_observatoire(ref_geodesique)   "WGS84"
         set config_observatoire(station_uai)      "586"

         set conf(posobs,config_observatoire,0) [ array get config_observatoire ]
      }

      #--- Observatoire de Haute Provence - FRANCE
      if { ! [ info exists conf(posobs,config_observatoire,1) ] } {
         #--- Je prepare un exemple de configuration optique
         array set config_observatoire { }
         set config_observatoire(nom_observatoire) "Haute Provence"
         set config_observatoire(estouest)         "E"
         set config_observatoire(long)             "5d42m56s5"
         set config_observatoire(nordsud)          "N"
         set config_observatoire(lat)              "43d55m54s8"
         set config_observatoire(altitude)         "633.9"
         set config_observatoire(ref_geodesique)   "WGS84"
         set config_observatoire(station_uai)      "511"

         set conf(posobs,config_observatoire,1) [ array get config_observatoire ]
      }

      #---
      if { ! [ info exists conf(posobs,config_observatoire,2) ] } { set conf(posobs,config_observatoire,2) "" }
      if { ! [ info exists conf(posobs,config_observatoire,3) ] } { set conf(posobs,config_observatoire,3) "" }
      if { ! [ info exists conf(posobs,config_observatoire,4) ] } { set conf(posobs,config_observatoire,4) "" }
      if { ! [ info exists conf(posobs,config_observatoire,5) ] } { set conf(posobs,config_observatoire,5) "" }
      if { ! [ info exists conf(posobs,config_observatoire,6) ] } { set conf(posobs,config_observatoire,6) "" }
      if { ! [ info exists conf(posobs,config_observatoire,7) ] } { set conf(posobs,config_observatoire,7) "" }
      if { ! [ info exists conf(posobs,config_observatoire,8) ] } { set conf(posobs,config_observatoire,8) "" }
      if { ! [ info exists conf(posobs,config_observatoire,9) ] } { set conf(posobs,config_observatoire,9) "" }
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la position de l'observateur
   #
   proc createDialog { } {
      variable This
      global audace caption color conf confgene

      #--- initConf
      ::confPosObs::initConf1

      #--- Initialisation d'autres variables
      set confgene(index_del)  "0"
      set confgene(index_copy) "0"

      #--- confToWidget
      ::confPosObs::confToWidget

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Dimensions externes de la fenêtre
      set width 448  ; # largeur de la fenêtre globale et largeur du canvas
      set height 545 ; # hauteur maximale

      toplevel $This
      wm geometry $This "$conf(posobs,geometry)"
      wm maxsize $This $width $height ; #taille normale
      wm minsize $This $width 102     ; #taille minimale
      wm resizable $This 1 1
      wm title $This $caption(confgene,position)
      wm protocol $This WM_DELETE_WINDOW ::confPosObs::fermer

      #--- Dimensions internes
      set cmdheight 40      ; # hauteur du widget des boutons de commande
      set scrollbarwidth 15 ; # largeur de la scrollbar
      set canvasheight [expr { $height-$cmdheight }]     ; # hauteur du canvas
      set framewidth [expr { $width-$scrollbarwidth } ]  ; # largeur d'un frame dans le canvas

      #--- Frame des boutons
      pack [frame $This.frame2 -borderwidth 2 -relief raised -width $width -height $cmdheight] \
         -in $This -side bottom -fill x -expand 0

      #--- Frame contenant le canvas et la scrollbar sauf les boutons de commande
      pack [frame $This.fr]

      #--- Raccourci du canvas
      set canvas $This.fr.frame1
      #--- Création de la scrollbar
      set vscroll [scrollbar  $This.fr.scrlbar1 -orient vertical -width $scrollbarwidth  -command "$canvas yview"]
      #--- Création d'un canvas
      canvas $canvas -relief sunken -width $width -height $canvasheight -yscrollcommand "$vscroll set"
      #--- Pack du canvas et de la scrollbar
      pack $vscroll -side right -fill y
      pack $canvas -side left -fill both -expand 1

      #--- Création de 3 frames contenus dans le canvas
      set xstart 0 ; # position x de départ des frames dans le canvas
      #--- Note : les positions y  et height sont expérimentales
      foreach {fr y height} [list frame2a 14 57 frame2b 71 57 frame2c 293 387] {
         frame $canvas.$fr -borderwidth 1 -relief raised
         $canvas create window $xstart $y -anchor center -width $framewidth -height $height -window $canvas.$fr
      }

      #--- Définition de la zone de scrolling
      $canvas configure -scrollregion [$canvas bbox all]

      #--- Remplissage des widgets

      #--- Nom de l'organisation
      set w $canvas.frame2a
      label $w.lab0 -text "$caption(confgene,nom_organisation)"
      entry $w.nom_organisation -textvariable confgene(posobs,nom_organisation) -width 70
      pack $w.lab0 $w.nom_organisation -in $w -anchor w -side top -padx 10 -pady 5

      #--- Nom de l'observateur
      set w $canvas.frame2b
      label $w.lab0 -text "$caption(confgene,nom_observateur)"
      entry $w.nom_observateur -textvariable confgene(posobs,nom_observateur) -width 70
      pack $w.lab0 $w.nom_observateur  -in $w -anchor w -side top -padx 10 -pady 5

      #--- Caractéristiques de l'observatoire
      #--- raccourci du chemin
      set w $canvas.frame2c

      #--- Création des frames esclaves
      set children_frame2c [list obs change long lat alt geo maj gps uai station mpc mpcstation]
      foreach child $children_frame2c {
         pack [frame $w.$child] -in $w -fill x
      }

      #--- Frame du nom de l'observatoire
      label $w.obs.lab -text "$caption(confgene,nom_observatoire:)"
      ComboBox $w.obs.nom_observatoire \
        -width 42         \
        -height 10        \
        -relief sunken    \
        -borderwidth 2    \
        -editable 0       \
        -textvariable confgene(posobs,nom_observatoire) \
        -modifycmd "::confPosObs::cbCommand $w.obs.nom_observatoire" \
        -values $confgene(posobs,nom_observatoire_liste)

      #--- Gestion des noms d'observatoire
      button $w.change.but_copy_obs -text "$caption(confgene,copier_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::copyObs }
      button $w.change.but_del_obs -text "$caption(confgene,supprimer_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::delObs }
      button $w.change.but_add_obs -text "$caption(confgene,ajouter_observatoire)" -borderwidth 2 \
         -command { ::confPosObs::addObs }

      #--- Longitude observateur
      label $w.long.lab -text "$caption(confgene,position_longitude)" -bd 1
      set list_combobox [ list $caption(confgene,position_est) $caption(confgene,position_ouest) ]
      ComboBox $w.long.estouest \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,estouest) \
         -values $list_combobox
      entry $w.long.long -textvariable confgene(posobs,long) -width 16

      #--- Latitude observateur
      label $w.lat.lab -text "$caption(confgene,position_latitude)"
      set list_combobox [ list $caption(confgene,position_nord) $caption(confgene,position_sud) ]
      ComboBox $w.lat.nordsud \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,nordsud) \
        -values $list_combobox
      entry $w.lat.lat -textvariable confgene(posobs,lat) -width 16

      #--- Altitude observateur
      label $w.alt.lab -text "$caption(confgene,position_altitude)"
      #--- ruse grossière pour alignement
      label $w.alt.lab4 -text "$caption(confgene,position_metre)       "
      entry $w.alt.altitude -textvariable confgene(posobs,altitude) -width 7

      #--- Referentiel geodesique
      label $w.geo.lab -text "$caption(confgene,position_ref_geodesique)"
      set list_combobox [ list $caption(confgene,position_ref_geodesique_ed50) \
         $caption(confgene,position_ref_geodesique,wgs84) ]
      ComboBox $w.geo.ref_geodesique \
         -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
         -height [ llength $list_combobox ] \
         -relief sunken    \
         -borderwidth 1    \
         -editable 0       \
         -textvariable confgene(posobs,ref_geodesique) \
         -values $list_combobox

      #--- Cree le bouton 'Mise a jour du format GPS'
      button $w.maj.but_gps -text "$caption(confgene,position_miseajour_gps)" -borderwidth 2 \
         -command { ::confPosObs::Position }

      #--- Systeme de coordonnees au format GPS
      label $w.gps.lab -text "$caption(confgene,position_gps)"
      label $w.gps.lab7 -text "$conf(posobs,observateur,gps)"

      #--- Numero station UAI
      label $w.uai.lab -text "$caption(confgene,position_station_uai)"
      entry $w.uai.station_uai -textvariable confgene(posobs,station_uai) -width 6
      #--- Cree le bouton 'Mise a jour des formats MPC'
      button $w.uai.but_mpc -text "$caption(confgene,position_miseajour_mpc)" -borderwidth 2 \
         -command { ::confPosObs::MPC }

      #--- Fichier des stations UAI
      label $w.station.lab -text "$caption(confgene,position_fichier_station_uai)"
      entry $w.station.fichier_station_uai -textvariable confgene(posobs,fichier_station_uai) -width 16
      #--- Cree le bouton 'Mise a jour' du fichier des stations UAI
      button $w.station.but_maj -text "$caption(confgene,position_miseajour)" -borderwidth 2 \
         -command { ::confPosObs::MaJ }

      #--- Systeme de coordonnees au format MPC
      label $w.mpc.lab -text "$caption(confgene,position_mpc)"
      label $w.mpc.labURLRed11 -borderwidth 1 -width 30 -anchor w -fg $audace(color,textColor)

      #--- Systeme de coordonnees au format MPCSTATION
      label $w.mpcstation.lab -text "$caption(confgene,position_mpcstation)"
      label $w.mpcstation.labURLRed13 -borderwidth 1 -width 30 -anchor w -fg $audace(color,textColor)

      #--- Gestion des couleurs d'affichage des formats MPC et MPCSTATION
      if { ( $confgene(posobs,observateur,mpc) == "$caption(confgene,position_non_station_uai)" ) && ( $confgene(posobs,observateur,mpcstation) == "$caption(confgene,position_non_station_uai)" ) } {
         set fg $color(red)
      } else {
         set fg $audace(color,textColor)
      }

      #--- Packaging dans frame2c
      #--- Pack de tous les labels
      foreach child $children_frame2c {
         if {[winfo exists $w.$child.lab] eq "1"} {
            pack $w.$child.lab -in $w.$child -anchor e -side left -padx 10 -pady 5
         }
      }

      #--- Pack des autres widgets
      pack $w.obs.nom_observatoire -in $w.obs
      pack $w.change.but_copy_obs $w.change.but_del_obs $w.change.but_add_obs -in $w.change -ipadx 5
      pack $w.long.long $w.long.estouest -in $w.long
      pack $w.lat.lat $w.lat.nordsud -in $w.lat
      pack $w.alt.lab4 $w.alt.altitude -in $w.alt
      pack $w.geo.ref_geodesique -in $w.geo -padx 50
      pack $w.maj.but_gps -in $w.maj
      pack $w.gps.lab7 -in $w.gps -padx 40 -pady 5
      pack $w.uai.but_mpc $w.uai.station_uai -in $w.uai
      pack $w.station.but_maj $w.station.fichier_station_uai -in $w.station
      pack $w.mpc.labURLRed11 -in $w.mpc
      pack $w.mpcstation.labURLRed13 -in $w.mpcstation

      #--- Ancrage w side right
      pack configure $w.obs.nom_observatoire $w.change.but_copy_obs $w.change.but_del_obs $w.change.but_add_obs \
         $w.long.long $w.long.estouest $w.lat.lat $w.lat.nordsud $w.alt.lab4 $w.alt.altitude \
         $w.uai.but_mpc $w.uai.station_uai $w.station.but_maj $w.station.fichier_station_uai \
         $w.mpc.labURLRed11 $w.mpcstation.labURLRed13 \
         -anchor w -side right -padx 10 -pady 5

      #--- Les boutons
      pack configure $w.maj.but_gps $w.uai.but_mpc $w.station.but_maj -anchor center -side right -ipadx 10 -ipady 5 -expand true
      pack configure $w.station.but_maj -ipadx 18

      #--- On utilise les valeurs contenues dans le tableau confgene pour l'initialisation
      $w.mpc.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $fg
      $w.mpcstation.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $fg

      #--- Création des boutons dans le frame2
      set w $This.frame2
      #--- Cree le bouton "OK"
      button $w.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confPosObs::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $w.but_ok -in $w -side left -anchor w -padx 3 -pady 3 -ipady 5
      }
      #--- Cree le bouton "Appliquer"
      button $w.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confPosObs::appliquer }
      pack $w.but_appliquer -in $w -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Fermer"
      button $w.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confPosObs::fermer }
      #--- Cree le bouton "Aide"
      button $w.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confPosObs::afficheAide }
      pack $w.but_fermer $w.but_aide -in $w -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Force la position de la scrollbar sur le début du canvas
      $canvas yview moveto 0

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief ajout d'un observatoire dans la liste
   #
   proc addObs { } {
      ::confPosObs::config::run "add"
   }

   #------------------------------------------------------------
   # brief suppression d'un observatoire dans la liste
   #
   proc delObs { } {
      ::confPosObs::config::run "del"
   }

   #------------------------------------------------------------
   #  brief copie d'un observatoire de la liste
   #
   proc copyObs { } {
      ::confPosObs::config::run "copy"
   }

   ## namespace confPosObs::config
   #  @brief Namespace pour la fenêtre de gestion des noms d'observatoire

   namespace eval ::confPosObs::config {

      #------------------------------------------------------------
      #  brief crée la fenêtre de gestion des noms d'observatoire
      #
      proc run { action } {
         global audace confgene

         set confgene(action) "$action"
         ::confGenerique::run "1" "$audace(base).nameObsSetup" "::confPosObs::config" -modal 0
         set posx_config [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 1 ]
         set posy_config [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 2 ]
         wm geometry $audace(base).nameObsSetup +[ expr $posx_config + 0 ]+[ expr $posy_config + 150 ]
      }

      #------------------------------------------------------------
      #  brief retourne le titre de la fenêtre de gestion des noms d'observatoire
      #
      proc getLabel { } {
         global caption

         return "$caption(confgene,nom_observatoire)"
      }

      #------------------------------------------------------------
      ## @brief commande associée au bouton "Appliquer" pour mémoriser et appliquer la configuration
      #  @param visuNo numéro de la visu
      #
      proc cmdApply { visuNo } {
         global conf confgene

         if { $confgene(action) == "add" } {
            if { $confgene(posobs,new_nom_observatoire) != "" } {
               set confgene(posobs,nom_observatoire) "$confgene(posobs,new_nom_observatoire)"
               #--- Mettre a vide le numero UAI sinon ::MPC va changer les informations
               set confgene(posobs,station_uai)      ""
               #--- Fonction pour la mise a la forme MPC et MPCSTATION
               ::confPosObs::MPC
               #--- Fonction pour la mise a la forme GPS
               ::confPosObs::Position
            }
         } elseif { $confgene(action) == "del" } {
            if { $confgene(posobs,del_nom_observatoire) != "" } {
               set index "$confgene(index_del)"
               set conf(posobs,config_observatoire,$index) ""
               if { $conf(posobs,config_observatoire,[ expr $index + 1 ]) != "" } {
                  for {set i $index} {$i < 9 } {incr i } {
                     set conf(posobs,config_observatoire,$i) $conf(posobs,config_observatoire,[ expr $i + 1 ])
                  }
               }
               #--- Je recupere les attributs de la configuration
               array set config_observatoire $conf(posobs,config_observatoire,0)
               set confgene(posobs,del_nom_observatoire) $config_observatoire(nom_observatoire)
               #--- Je prepare les valeurs de la combobox de configuration des noms d'observatoire
               set confgene(posobs,nom_observatoire_liste) ""
               foreach {key value} [ array get conf posobs,config_observatoire,* ] {
                  if { "$value" == "" } continue
                  #--- Je mets les valeurs dans un array (de-serialisation)
                  array set config_observatoire $value
                  #--- Je prepare la ligne a afficher dans la combobox
                  set line "$config_observatoire(nom_observatoire) $config_observatoire(estouest) $config_observatoire(long) \
                     $config_observatoire(nordsud) $config_observatoire(lat) $config_observatoire(altitude) \
                     $config_observatoire(ref_geodesique) $config_observatoire(station_uai)"
                  #--- Je supprime la ligne
                  lappend confgene(posobs,nom_observatoire_liste) "$line"
               }
               #--- Je mets a jour les combobox
               $confgene(frm).config.nom_observatoire_a_supprimer configure -values $confgene(posobs,nom_observatoire_liste)
               ::confPosObs::majListComboBox
            }
         } elseif { $confgene(action) == "copy" } {
            if { $confgene(posobs,copy_nom_observatoire) != "" } {
               set index "$confgene(index_copy)"
               #--- Je recupere les attributs de la configuration
               array set config_observatoire $conf(posobs,config_observatoire,$index)
               #--- Je copie les valeurs dans les widgets de la configuration choisie
               set confgene(posobs,nom_observatoire) "$confgene(posobs,nom_observatoire_copie)"
               set confgene(posobs,estouest)         "$config_observatoire(estouest)"
               set confgene(posobs,long)             "$config_observatoire(long)"
               set confgene(posobs,nordsud)          "$config_observatoire(nordsud)"
               set confgene(posobs,lat)              "$config_observatoire(lat)"
               set confgene(posobs,altitude)         "$config_observatoire(altitude)"
               set confgene(posobs,ref_geodesique)   "$config_observatoire(ref_geodesique)"
               #--- Mettre a vide le numero UAI sinon ::MPC va changer les informations
               set confgene(posobs,station_uai)      ""
               #--- Fonction pour la mise a la forme MPC et MPCSTATION
               ::confPosObs::MPC
               #--- Fonction pour la mise a la forme GPS
               ::confPosObs::Position
            }
         }
      }

      #------------------------------------------------------------
      ## @brief commande associée au bouton "Fermer" de la fenêtre de gestion des noms d'observatoire
      #  @param visuNo numéro de la visu
      #
      proc cmdClose { visuNo } {
      }

      #------------------------------------------------------------
      #  brief affiche les valeurs dans les widgets pour la configuration choisie
      #  (appelée par la combobox à chaque changement de la sélection)
      #  param cb chemin de la combobox
      #
      proc cbCommand { cb } {
         global conf confgene

         #--- Je recupere l'index de l'element selectionne
         set index [ $cb getvalue ]
         if { "$index" == "" } {
            set index 0
         }

         #--- Je recupere les attributs de la configuration
         array set configuration_observatoire $conf(posobs,config_observatoire,$index)

         #--- Je copie les valeurs dans les widgets de la configuration choisie
         if { $confgene(action) == "del" } {
            set confgene(posobs,del_nom_observatoire) $configuration_observatoire(nom_observatoire)
            set confgene(index_del) "$index"
         } elseif { $confgene(action) == "copy" } {
            set confgene(posobs,copy_nom_observatoire) $configuration_observatoire(nom_observatoire)
            set confgene(index_copy) "$index"
         }
      }

      #------------------------------------------------------------
      #  brief crée l'interface graphique
      #  param frm chemin Tk
      #  param visuNo numéro de la visu
      #
      proc fillConfigPage { frm visuNo } {
         global caption confgene

         #--- Initialisation
         set confgene(frm)                           $frm
         set confgene(posobs,new_nom_observatoire)   ""
         set confgene(posobs,del_nom_observatoire)   "$confgene(posobs,nom_observatoire)"
         set confgene(posobs,copy_nom_observatoire)  "$confgene(posobs,nom_observatoire)"
         set confgene(posobs,nom_observatoire_copie) ""

         #--- Frame de la gestion des noms de configuration
         frame $frm.config -borderwidth 0 -relief raised

            if { $confgene(action) == "add" } {

               label $frm.config.lab1 -text $caption(confgene,observatoire_a_ajouter)
               pack $frm.config.lab1 -anchor nw -side left -padx 10 -pady 10

               entry $frm.config.nom_observatoire_a_ajouter -textvariable confgene(posobs,new_nom_observatoire) -width 42
               pack $frm.config.nom_observatoire_a_ajouter -anchor w -side left -padx 10 -pady 5

            } elseif { $confgene(action) == "del" } {

               label $frm.config.lab2 -text $caption(confgene,observatoire_a_supprimer)
               pack $frm.config.lab2 -anchor nw -side left -padx 10 -pady 10

               ComboBox $frm.config.nom_observatoire_a_supprimer \
                  -width 42         \
                  -height 10        \
                  -relief sunken    \
                  -borderwidth 2    \
                  -editable 0       \
                  -textvariable confgene(posobs,del_nom_observatoire) \
                  -modifycmd "::confPosObs::config::cbCommand $frm.config.nom_observatoire_a_supprimer" \
                  -values $confgene(posobs,nom_observatoire_liste)
               pack $frm.config.nom_observatoire_a_supprimer -anchor w -side right -padx 10 -pady 5

            } elseif { $confgene(action) == "copy" } {

               frame $frm.config.frame1 -borderwidth 0 -relief raised

                  label $frm.config.frame1.lab3 -text $caption(confgene,observatoire_a_copier)
                  pack $frm.config.frame1.lab3 -anchor nw -side left -padx 10 -pady 10

                  ComboBox $frm.config.frame1.nom_observatoire_a_copier \
                     -width 42         \
                     -height 10        \
                     -relief sunken    \
                     -borderwidth 2    \
                     -editable 0       \
                     -textvariable confgene(posobs,copy_nom_observatoire) \
                     -modifycmd "::confPosObs::config::cbCommand $frm.config.frame1.nom_observatoire_a_copier" \
                     -values $confgene(posobs,nom_observatoire_liste)
                  pack $frm.config.frame1.nom_observatoire_a_copier -anchor w -side right -padx 10 -pady 5

               pack $frm.config.frame1 -side top -fill both -expand 1

               frame $frm.config.frame2 -borderwidth 0 -relief raised

                  label $frm.config.frame2.lab4 -text $caption(confgene,nom_observatoire)
                  pack $frm.config.frame2.lab4 -anchor nw -side left -padx 10 -pady 10

                  entry $frm.config.frame2.nom_observatoire_copie -textvariable confgene(posobs,nom_observatoire_copie) -width 42
                  pack $frm.config.frame2.nom_observatoire_copie -anchor w -side left -padx 10 -pady 5

               pack $frm.config.frame2 -side top -fill both -expand 1

            }

         pack $frm.config -side top -fill both -expand 1
      }
   }

   #------------------------------------------------------------
   # brief mise à jour du fichier contenant la liste des observatoires référencés par l'UAI
   #
   proc MaJ { } {
      variable This
      global audace caption confgene

      #--- Chargement du package http
      package require http
      package require tls

      #--- Gestion du bouton de Mise a jour
#RZ      #$This.but_maj configure -relief groove -state disabled
      $This.fr.frame1.frame2c.station.but_maj configure -relief groove -state disabled

      #--- Spécification https
      tls::init -tls1 true -ssl2 false -ssl3 false
      http::register https 443 tls::socket

      #--- Adresse web du catalogue des observatoires UAI
      set url "https://minorplanetcenter.net/iau/lists/ObsCodes.html"

      #--- Lecture du catalogue en ligne
      set err [ catch { ::http::geturl $url } token ]
      if { $err == 0 } {
         upvar #0 $token state
         set html_text [ split $state(body) \n ]
         set lignes ""
         foreach ligne $html_text {
            if { [ string length $ligne ] < 10 } {
               continue
            }
            #--- Traitement des lignes sans espace entre les donnees
            if { [ string range $ligne 13 13 ] != " " } {
               set b [ string replace $ligne 30 30 " [ string range $ligne 30 30 ]" ]
               set c [ string replace $b 21 21 " [ string range $b 21 21 ]" ]
               set ligne [ string replace $c 13 13 " [ string range $c 13 13 ]" ]
            }
            append lignes "$ligne\n"
         }
         #--- Mise a jour du catalogue sur le disque dur
         set mpcfile [ file join $audace(rep_home) $confgene(posobs,fichier_station_uai) ]
         set f [ open $mpcfile w ]
         puts -nonewline $f $lignes
         close $f
         http::unregister https
         ::console::disp "$caption(confgene,maj_fichier_station_uai)\n\n"
      } else {
         #--- Erreur de connexion a Internet
         tk_messageBox -title "$caption(confgene,position_miseajour)" -type ok \
            -message "$caption(confgene,fichier_uai_msg)" -icon error
      }

      #--- Gestion du bouton de Mise a jour
#RZ       #$This.but_maj configure -relief groove -state disabled
      $This.fr.frame1.frame2c.station.but_maj configure -relief raised -state normal
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique pour signifier une erreur
   #
   proc Erreur { } {
      global audace caption

     if [winfo exists $audace(base).erreur] {
         destroy $audace(base).erreur
      }
      toplevel $audace(base).erreur
      wm transient $audace(base).erreur $audace(base).confPosObs
      wm title $audace(base).erreur "$caption(confgene,position_miseajour_mpc)"
      set posx_erreur [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 1 ]
      set posy_erreur [ lindex [ split [ wm geometry $audace(base).confPosObs ] "+" ] 2 ]
      wm geometry $audace(base).erreur +[expr $posx_erreur - 20 ]+[expr $posy_erreur + 120 ]
      wm resizable $audace(base).erreur 0 0

      #--- Cree l'affichage du message
      label $audace(base).erreur.lab1 -text "$caption(confgene,fichier_uai_erreur1)"
      pack $audace(base).erreur.lab1 -padx 10 -pady 2
      label $audace(base).erreur.lab2 -text "$caption(confgene,fichier_uai_erreur2)"
      pack $audace(base).erreur.lab2 -padx 10 -pady 2
      label $audace(base).erreur.lab3 -text "$caption(confgene,fichier_uai_erreur3)"
      pack $audace(base).erreur.lab3 -padx 10 -pady 2

      #--- La nouvelle fenetre est active
      focus $audace(base).erreur

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $audace(base).erreur
   }

   #------------------------------------------------------------
   #  brief fonction pour la mise au format GPS des coordonnées de l'observateur
   #
   proc Position { } {
      variable This
      global caption confgene

      #--- Localisation de l'observateur
      set estouest $confgene(posobs,estouest)
      if { $estouest == $caption(confgene,position_ouest) } {
         set estouest $caption(confgene,caractere_W)
      } elseif { $estouest == $caption(confgene,position_est) } {
         set estouest $caption(confgene,caractere_E)
      }
      set longitude "$confgene(posobs,long)"
      if { $confgene(posobs,nordsud) == $caption(confgene,position_sud) } {
         set signe $caption(confgene,caractere_tiret)
      } else {
         set signe ""
      }
      set latitude "$signe$confgene(posobs,lat)"
      #--- Si un format MPC existe je peux modifier l'altitude du format GPS sans modifier la longitude et la latitude
      if { $confgene(posobs,observateur,mpc) != "" } {
         if { $confgene(posobs,ref_geodesique) == "WGS84" } {
            set altitude $confgene(posobs,altitude)
            ::confPosObs::MPC
            set confgene(posobs,observateur,gps) "GPS [lindex $confgene(posobs,observateur,gps) 1] [lindex $confgene(posobs,observateur,gps) 2] [lindex $confgene(posobs,observateur,gps) 3] $altitude"
            set confgene(posobs,altitude) $altitude
         } elseif { $confgene(posobs,ref_geodesique) == "ED50" } {
            set confgene(posobs,observateur,gps-ed50) "GPS [mc_angle2deg $longitude] $estouest [mc_angle2deg $latitude] $confgene(posobs,altitude)"
            set confgene(posobs,observateur,ed50-wgs84) [mc_home2geosys $confgene(posobs,observateur,gps-ed50) ED50 WGS84]
            set longitude_ed50 [lindex $confgene(posobs,observateur,ed50-wgs84) 0]
            set confgene(posobs,observateur,gps) "GPS [expr abs($longitude_ed50)] [lindex $confgene(posobs,observateur,gps-ed50) 2] [lindex $confgene(posobs,observateur,ed50-wgs84) 1] [lindex $confgene(posobs,observateur,ed50-wgs84) 2]"
         }
      } else {
         if { $confgene(posobs,ref_geodesique) == "WGS84" } {
            set confgene(posobs,observateur,gps) "GPS [mc_angle2deg $longitude] $estouest [mc_angle2deg $latitude] $confgene(posobs,altitude)"
         } elseif { $confgene(posobs,ref_geodesique) == "ED50" } {
            set confgene(posobs,observateur,gps-ed50) "GPS [mc_angle2deg $longitude] $estouest [mc_angle2deg $latitude] $confgene(posobs,altitude)"
            set confgene(posobs,observateur,ed50-wgs84) [mc_home2geosys $confgene(posobs,observateur,gps-ed50) ED50 WGS84]
            set longitude_ed50 [lindex $confgene(posobs,observateur,ed50-wgs84) 0]
            set confgene(posobs,observateur,gps) "GPS [expr abs($longitude_ed50)] [lindex $confgene(posobs,observateur,gps-ed50) 2] [lindex $confgene(posobs,observateur,ed50-wgs84) 1] [lindex $confgene(posobs,observateur,ed50-wgs84) 2]"
         }
      }
      #--- Mise en forme et affichage de la position au format GPS
      set confgene(posobs,observateur,gps) "[lindex $confgene(posobs,observateur,gps) 0]\
         [lindex $confgene(posobs,observateur,gps) 1] [lindex $confgene(posobs,observateur,gps) 2]\
         [lindex $confgene(posobs,observateur,gps) 3] [lindex $confgene(posobs,observateur,gps) 4]"
 #RZ     #$This.lab7 configure -text "$confgene(posobs,observateur,gps)"
      $This.fr.frame1.frame2c.gps.lab7 configure -text "$confgene(posobs,observateur,gps)"
   }

   #------------------------------------------------------------
   #  brief fonction pour la mise au format MPC et MPCSTATION des coordonnées de l'observateur
   #
   proc MPC { } {
      variable This
      global audace caption color confgene

      #--- Effacement de la fenetre d'alerte
#RZ      #bind $This.station_uai <Enter> { destroy $audace(base).erreur }
      bind $This.fr.frame1.frame2c.station.but_maj <Enter> { destroy $audace(base).erreur }

      #--- Traitement sur le numero de la station uai
      if { $confgene(posobs,station_uai) == "" } {
         set confgene(posobs,observateur,mpc) ""
#RZ         #$This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $color(red)
         $This.fr.frame1.frame2c.mpc.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $color(red)
         set confgene(posobs,observateur,mpcstation) ""
#RZ         #$This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $color(red)
         $This.fr.frame1.frame2c.mpcstation.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $color(red)

      } else {
         if {[string length $confgene(posobs,station_uai)]<"3"} {
            ::confPosObs::Erreur
         } else {
         #--- Ouverture du fichier des stations UAI
         set f [open [file join $audace(rep_home) $confgene(posobs,fichier_station_uai)] r]
         #--- Creation d'une liste des stations UAI
         set mpc [split [read $f] "\n"]
         #--- Determine le nombre d'elements de la liste
         set long [llength $mpc]
         #--- Recherche le numero de la premiere ligne significative --> le site uai '000'
         for {set j 0} {$j <= $long} {incr j} {
            set ligne_station_mpc [lindex $mpc $j]
            if { [string compare [lindex $ligne_station_mpc 0] "000"] == "0" } {
               break
            }
         }
         #--- Supprime les (j-1) lignes de commentaires non significatifs
         set mpc [lreplace $mpc 0 [expr $j-1]]
         #--- Recherche et traitement du site uai demande
         for {set i 0} {$i <= $long} {incr i} {
            set ligne_station_mpc [lindex $mpc $i]
            if { [string compare [lindex $ligne_station_mpc 0] $confgene(posobs,station_uai)] == "0" } {
               #--- Formatage du nom de l'observatoire (c'est une textvariable)
               set nom ""
               for {set i 4} {$i <= [ llength $ligne_station_mpc ]} {incr i} {
                  set nom "$nom[lindex $ligne_station_mpc $i] "
               }
               set confgene(posobs,nom_observatoire) "$nom"
               #--- Formatage MPC
               set confgene(posobs,observateur,mpc) "MPC [lindex $ligne_station_mpc 1] [lindex $ligne_station_mpc 2] [lindex $ligne_station_mpc 3]"
#RZ               #$This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $audace(color,textColor)
               $This.fr.frame1.frame2c.mpc.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $audace(color,textColor)
               #--- Formatage MPCSTATION
               set confgene(posobs,observateur,mpcstation) "MPCSTATION $confgene(posobs,station_uai) $confgene(posobs,fichier_station_uai)"
#RZ               #$This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $audace(color,textColor)
               $This.fr.frame1.frame2c.mpcstation.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $audace(color,textColor)
               #--- Formatage GPS et mise a jour du 'frame' GPS
               #--- Longitude avec mise en forme
               set confgene(posobs,observateur,gps) [mc_home2gps $confgene(posobs,observateur,mpc)]
               set confgene(posobs,observateur,gps) "[lindex $confgene(posobs,observateur,gps) 0]\
                  [lindex $confgene(posobs,observateur,gps) 1] [lindex $confgene(posobs,observateur,gps) 2]\
                  [lindex $confgene(posobs,observateur,gps) 3] [lindex $confgene(posobs,observateur,gps) 4]"
#RZ               #$This.lab7 configure -text "$confgene(posobs,observateur,gps)"
               $This.fr.frame1.frame2c.gps.lab7 configure -text "$confgene(posobs,observateur,gps)"
               set confgene(posobs,long) [lindex $confgene(posobs,observateur,gps) 1]
               set confgene(posobs,long) [mc_angle2dms $confgene(posobs,long) 180 nozero 1 auto string]
               set confgene(posobs,estouest) [lindex $confgene(posobs,observateur,gps) 2]
               if { $confgene(posobs,estouest) == "W" } {
                  set confgene(posobs,estouest) "$caption(confgene,position_ouest)"
               } elseif { $confgene(posobs,estouest) == "E" } {
                  set confgene(posobs,estouest) $caption(confgene,position_est)
               }
               #--- Latitude
               set confgene(posobs,lat) [lindex $confgene(posobs,observateur,gps) 3]
               if { $confgene(posobs,lat) < 0 } {
                  set confgene(posobs,nordsud) "$caption(confgene,position_sud)"
                  set confgene(posobs,lat)     "[expr abs($confgene(posobs,lat))]"
               } else {
                  set confgene(posobs,nordsud) "$caption(confgene,position_nord)"
                  set confgene(posobs,lat)     "$confgene(posobs,lat)"
               }
               set confgene(posobs,lat) [mc_angle2dms $confgene(posobs,lat) 90 nozero 1 auto string]
               #--- Altitude
               set confgene(posobs,altitude) [lindex $confgene(posobs,observateur,gps) 4]
               #--- Referentiel geodesique pour le calcul du format GPS
               set confgene(posobs,ref_geodesique) "WGS84"
               break
            } else {
               set confgene(posobs,observateur,mpc) "$caption(confgene,position_non_station_uai)"
#RZ              #$This.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $color(red)
               $This.fr.frame1.frame2c.mpc.labURLRed11 configure -text "$confgene(posobs,observateur,mpc)" -fg $color(red)
               set confgene(posobs,observateur,mpcstation) "$caption(confgene,position_non_station_uai)"
#RZ              #$This.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $color(red)
               $This.fr.frame1.frame2c.mpcstation.labURLRed13 configure -text "$confgene(posobs,observateur,mpcstation)" -fg $color(red)
            }
         }
         #--- Ferme le fichier des stations UAI
         close $f
         }
      }
   }

   #------------------------------------------------------------
   #  brief commande associée à la combobox
   #  (appelée par la combobox à chaque changement de la sélection)
   #  details affiche les valeurs dans les widgets pour la configuration choisie
   #  param cb chemin de la combobox
   #
   proc cbCommand { cb } {
      global conf confgene

      #--- Je recupere l'index de l'element selectionne
      set index [ $cb getvalue ]
      if { "$index" == "" } {
         set index 0
      }

      #--- Je recupere les attributs de la configuration
      array set config_observatoire $conf(posobs,config_observatoire,$index)

      #--- Je copie les valeurs dans les widgets de la configuration choisie
      set confgene(posobs,nom_observatoire) $config_observatoire(nom_observatoire)
      set confgene(posobs,estouest)         $config_observatoire(estouest)
      set confgene(posobs,long)             $config_observatoire(long)
      set confgene(posobs,nordsud)          $config_observatoire(nordsud)
      set confgene(posobs,lat)              $config_observatoire(lat)
      set confgene(posobs,altitude)         $config_observatoire(altitude)
      set confgene(posobs,ref_geodesique)   $config_observatoire(ref_geodesique)
      set confgene(posobs,station_uai)      $config_observatoire(station_uai)

      #--- Fonction pour la mise a la forme MPC et MPCSTATION
      ::confPosObs::MPC

      #--- Fonction pour la mise a la forme GPS
      ::confPosObs::Position
   }

   #------------------------------------------------------------
   #  brief copie les variables du tableau conf(...) dans des variables locales
   #
   proc confToWidget { } {
      global conf confgene

      #--- confToWidget
      set confgene(posobs,geometry)                $conf(posobs,geometry)
      set confgene(posobs,nom_organisation)        $conf(posobs,nom_organisation)
      set confgene(posobs,nom_observateur)         $conf(posobs,nom_observateur)
      set confgene(posobs,nom_observatoire)        $conf(posobs,nom_observatoire)
      set confgene(posobs,estouest)                $conf(posobs,estouest)
      set confgene(posobs,long)                    $conf(posobs,long)
      set confgene(posobs,nordsud)                 $conf(posobs,nordsud)
      set confgene(posobs,lat)                     $conf(posobs,lat)
      set confgene(posobs,altitude)                $conf(posobs,altitude)
      set confgene(posobs,ref_geodesique)          $conf(posobs,ref_geodesique)
      set confgene(posobs,observateur,gps)         $conf(posobs,observateur,gps)
      set confgene(posobs,station_uai)             $conf(posobs,station_uai)
      set confgene(posobs,fichier_station_uai)     $conf(posobs,fichier_station_uai)
      set confgene(posobs,observateur,mpc)         $conf(posobs,observateur,mpc)
      set confgene(posobs,observateur,mpcstation)  $conf(posobs,observateur,mpcstation)

      #--- Je prepare les valeurs de la combobox de configuration des noms d'observatoire
      set confgene(posobs,nom_observatoire_liste) ""
      foreach {key value} [ array get conf posobs,config_observatoire,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set config_observatoire $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$config_observatoire(nom_observatoire) $config_observatoire(estouest) $config_observatoire(long) \
            $config_observatoire(nordsud) $config_observatoire(lat) $config_observatoire(altitude) \
            $config_observatoire(ref_geodesique) $config_observatoire(station_uai)"
         #--- J'ajoute la ligne
         lappend confgene(posobs,nom_observatoire_liste) "$line"
      }
   }

   #------------------------------------------------------------
   #  brief acquisition de la configuration, c'est à dire isolation
   #  des différentes variables locales dans le tableau conf(...)
   #
   proc widgetToConf { } {
      variable This
      global audace conf confgene

      #--- J'ajoute l'observatoire en tete dans le tableau des observatoires precedents s'il n'y est pas deja
      array set config_observatoire { }
      set config_observatoire(nom_observatoire) [ string trimright $confgene(posobs,nom_observatoire) " " ]
      set config_observatoire(estouest)         $confgene(posobs,estouest)
      set config_observatoire(long)             $confgene(posobs,long)
      set config_observatoire(nordsud)          $confgene(posobs,nordsud)
      set config_observatoire(lat)              $confgene(posobs,lat)
      set config_observatoire(altitude)         $confgene(posobs,altitude)
      set config_observatoire(ref_geodesique)   $confgene(posobs,ref_geodesique)
      set config_observatoire(station_uai)      $confgene(posobs,station_uai)

      #--- Je copie conf dans templist en mettant l'observatoire courant en premier
      array set templist { }
      set templist(0) [ array get config_observatoire ]
      set j "1"
      foreach {key value} [ array get conf posobs,config_observatoire,* ] {
         if { "$value" == "" } {
            set templist($j) ""
            incr j
         } else {
            array set temp1 $value
            if { "$temp1(nom_observatoire)" != "$config_observatoire(nom_observatoire)" } {
               set templist($j) [ array get temp1 ]
               incr j
            }
         }
      }

      #--- Je copie templist dans conf
      for {set i 0} {$i < 10 } {incr i } {
         set conf(posobs,config_observatoire,$i) $templist($i)
      }

      #--- Je mets a jour les valeurs dans la combobox
      set confgene(posobs,nom_observatoire_liste) ""
      foreach {key value} [ array get conf posobs,config_observatoire,* ] {
         if { "$value" == "" } continue
         #--- Je mets les valeurs dans un array (de-serialisation)
         array set config_observatoire $value
         #--- Je prepare la ligne a afficher dans la combobox
         set line "$config_observatoire(nom_observatoire) $config_observatoire(estouest) $config_observatoire(long) \
            $config_observatoire(nordsud) $config_observatoire(lat) $config_observatoire(altitude) \
            $config_observatoire(ref_geodesique) $config_observatoire(station_uai)"
         #--- J'ajoute la ligne
         lappend confgene(posobs,nom_observatoire_liste) "$line"
      }
      $This.fr.frame1.frame2c.obs.nom_observatoire configure -values $confgene(posobs,nom_observatoire_liste)

      #---
      set conf(posobs,geometry)               $confgene(posobs,geometry)
      set conf(posobs,nom_organisation)       $confgene(posobs,nom_organisation)
      set conf(posobs,nom_observateur)        $confgene(posobs,nom_observateur)
      set conf(posobs,nom_observatoire)       [ string trimright $confgene(posobs,nom_observatoire) " " ]
      set conf(posobs,estouest)               $confgene(posobs,estouest)
      set conf(posobs,long)                   $confgene(posobs,long)
      set conf(posobs,nordsud)                $confgene(posobs,nordsud)
      set conf(posobs,lat)                    $confgene(posobs,lat)
      set conf(posobs,altitude)               $confgene(posobs,altitude)
      set conf(posobs,ref_geodesique)         $confgene(posobs,ref_geodesique)
      set conf(posobs,observateur,gps)        $confgene(posobs,observateur,gps)
      set conf(posobs,fichier_station_uai)    $confgene(posobs,fichier_station_uai)
      set conf(posobs,station_uai)            $confgene(posobs,station_uai)
      set conf(posobs,observateur,mpc)        $confgene(posobs,observateur,mpc)
      set conf(posobs,observateur,mpcstation) $confgene(posobs,observateur,mpcstation)

      #---
      set audace(posobs,observateur,gps)      $conf(posobs,observateur,gps)

      #--- Concatenation de variables pour l'en-tete FITS
      set conf(posobs,estouest_long)          $conf(posobs,estouest)$conf(posobs,long)
      set conf(posobs,nordsud_lat)            $conf(posobs,nordsud)$conf(posobs,lat)
   }

   #------------------------------------------------------------------------------
   #  brief récupère et sauvegarde les dimensions et la position de la fenêtre
   #
   proc recupPosDim { } {
      variable This
      global confgene

      set confgene(posobs,geometry) [ wm geometry $This ]
      set ::conf(posobs,geometry) $confgene(posobs,geometry)
   }

   #------------------------------------------------------------
   #  brief mise à jour de la liste de la combobox des observatoires
   #
   proc majListComboBox { } {
      variable This
      global audace conf confgene

      #--- Je configure la combobox des observatoires
      $This.nom_observatoire configure -values $confgene(posobs,nom_observatoire_liste)
      #--- Cas particulier du premier de la liste
      if { $confgene(index_del) == "0" } {
         #--- Je recupere le nouvel index 0
         set index 0
         #--- Je recupere les attributs de la configuration
         array set config_observatoire $conf(posobs,config_observatoire,$index)
         #--- Je copie les valeurs dans les widgets de la configuration choisie
         set confgene(posobs,nom_observatoire) $config_observatoire(nom_observatoire)
         set confgene(posobs,estouest)         $config_observatoire(estouest)
         set confgene(posobs,long)             $config_observatoire(long)
         set confgene(posobs,nordsud)          $config_observatoire(nordsud)
         set confgene(posobs,lat)              $config_observatoire(lat)
         set confgene(posobs,altitude)         $config_observatoire(altitude)
         set confgene(posobs,ref_geodesique)   $config_observatoire(ref_geodesique)
         set confgene(posobs,station_uai)      $config_observatoire(station_uai)
         #--- Fonction pour la mise a la forme MPC et MPCSTATION
         ::confPosObs::MPC
         #--- Fonction pour la mise a la forme GPS
         ::confPosObs::Position
         #--- Je copie les valeurs dans les variables de configuration
         set conf(posobs,nom_observatoire)       $confgene(posobs,nom_observatoire)
         set conf(posobs,estouest)               $confgene(posobs,estouest)
         set conf(posobs,long)                   $confgene(posobs,long)
         set conf(posobs,nordsud)                $confgene(posobs,nordsud)
         set conf(posobs,lat)                    $confgene(posobs,lat)
         set conf(posobs,altitude)               $confgene(posobs,altitude)
         set conf(posobs,ref_geodesique)         $confgene(posobs,ref_geodesique)
         set conf(posobs,observateur,gps)        $confgene(posobs,observateur,gps)
         set conf(posobs,station_uai)            $confgene(posobs,station_uai)
         set conf(posobs,observateur,mpc)        $confgene(posobs,observateur,mpc)
         set conf(posobs,observateur,mpcstation) $confgene(posobs,observateur,mpcstation)
         #---
         set audace(posobs,observateur,gps)      $conf(posobs,observateur,gps)
         #--- Concatenation de variables pour l'en-tete FITS
         set conf(posobs,estouest_long)          $conf(posobs,estouest)$conf(posobs,long)
         set conf(posobs,nordsud_lat)            $conf(posobs,nordsud)$conf(posobs,lat)
      }
   }

   #------------------------------------------------------------
   #  brief ajoute une procédure à appeler si on change un paramètre
   #
   proc addPosObsListener { cmd } {
      trace add variable "::conf(posobs,nom_organisation)" write $cmd
      trace add variable "::conf(posobs,nom_observateur)" write $cmd
      trace add variable "::conf(posobs,nom_observatoire)" write $cmd
  }

   #------------------------------------------------------------
   #  brief supprime une procédure à appeler si on change un paramètre
   #
   proc removePosObsListener { cmd } {
      trace remove variable "::conf(posobs,nom_observatoire)" write $cmd
      trace remove variable "::conf(posobs,nom_observateur)" write $cmd
      trace remove variable "::conf(posobs,nom_organisation)" write $cmd
   }
}

#----------------------------------------------------------------------

## namespace confTemps
#  @brief Configuration du temps (heure système ou TU)

namespace eval ::confTemps {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration du temps
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   #  brief commande asscoiée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1040temps.htm"
   }

   #------------------------------------------------------------
   ## @brief commande asscoiée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration du temps
   #
   proc createDialog { } {
      variable This
      global audace caption conf confgene

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,temps)
      wm protocol $This WM_DELETE_WINDOW ::confTemps::fermer

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame3 -side left -fill both -expand 1

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in $This.frame3 -side left -fill both -expand 1

      #--- Temps sideral local
      label $This.lab1 -text "$caption(confgene,temps_tsl)"
      pack $This.lab1 -in $This.frame4 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab2 -borderwidth 1 -textvariable "audace(tsl,format,hmsint)" -width 12 -anchor w
      pack $This.lab2 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      #--- Temps universel
      label $This.lab3 -text "$caption(confgene,temps_tu)"
      pack $This.lab3 -in $This.frame4 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab4 -borderwidth 1 -textvariable "audace(tu,format,hmsint)" -width 12 -anchor w
      pack $This.lab4 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      #--- Temps local
      label $This.lab5 -text "$caption(confgene,temps_hl)"
      pack $This.lab5 -in $This.frame4 -anchor w -side bottom -padx 10 -pady 5

      label $This.lab6 -borderwidth 1 -textvariable "audace(hl,format,hmsint)" -width 12 -anchor w
      pack $This.lab6 -in $This.frame5 -anchor w -side bottom -padx 10 -pady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confTemps::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confTemps::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

#----------------------------------------------------------------------

## namespace confFichierIma
#  @brief Configuration des fichiers image

namespace eval ::confFichierIma {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration des fichiers image
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" pour appliquer la configuration
   #  et fermer la fenêtre de configuration des fichiers image
   #
   proc ok { } {
      appliquer
      fermer
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" pour mémoriser et appliquer la configuration
   #
   proc appliquer { } {
      variable This
      global audace confgene

      #--- Mises a jour pour tous les buffers disponibles
      foreach visuNo [ ::visu::list ] {
         set bufNo [ visu$visuNo buf ]
         #--- Extension par defaut associee au buffer
         buf$bufNo extension $confgene(extension,new)
         #--- Fichiers FITS compresses ou non
         if { $confgene(fichier,compres) == "0" } {
            buf$bufNo compress "none"
         } else {
            buf$bufNo compress "gzip"
         }
         #--- Format des fichiers image (entier ou flottant)
         if { $confgene(fichier,format) == "0" } {
            buf$bufNo bitpix ushort
         } else {
            buf$bufNo bitpix float
         }
      }

      #--- Mise a jour des widgets
      $This.labURL2 configure -text "$confgene(extension,new)"
      $This.labURL5 configure -text "$confgene(jpegquality,new)"

      #--- Mise a jour de la liste des extensions
      set listExtensionFile ""
      if { ( $confgene(extension,new) != ".fit" ) && ( $confgene(extension,new) != ".fts" ) &&
         ( $confgene(extension,new) != ".fits" ) } {
         set listExtensionFile "$confgene(extension,new) $confgene(extension,new).gz"
      }
      set listExtensionFile "$listExtensionFile .fit .fit.gz .fts .fts.gz .fits .fits.gz .jpg"
      set confgene(fichier,list_extension) $listExtensionFile

      #--- Sauvegarde de la configuration
      widgetToConf
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1060fichier_image.htm"
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre "Fichiers images..."
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(save_seuils_visu)     définit si les images sont sauvegardées en conservant les seuils de visu
   #  - conf(format_fichier_image) définit si les images sont sauvegardées en entier (16 bits) ou en flottant (32 bits)
   #  - conf(extension,defaut)     définit l'extension par défaut des fichiers FITS
   #  - conf(fichier,compress)     définit si les images sont sauvegardées en mode compressé ou non
   #  - conf(jpegquality,defaut)   définit la qualité par défaut des images sauvegardées au format JPEG
   #  - conf(extension,new)        définit l'extension des fichiers FITS
   #  - conf(jpegquality,new)      définit la qualité des images sauvegardées au format JPEG
   #
   proc initConf { } {
      global conf

      #--- Initialisation indispensable de 3 variables dans aud.tcl (::audace::loadSetup)
      if { ! [ info exists conf(save_seuils_visu) ] }          { set conf(save_seuils_visu)          "1" }
      if { ! [ info exists conf(format_fichier_image) ] }      { set conf(format_fichier_image)      "0" }
      if { ! [ info exists conf(extension,defaut) ] }          { set conf(extension,defaut)          ".fit" }
      if { ! [ info exists conf(fichier,compres) ] }           { set conf(fichier,compres)           "0" }
      if { ! [ info exists conf(jpegquality,defaut) ] }        { set conf(jpegquality,defaut)        "80" }

      #--- Initialisation de la liste des extensions
      set ::audace(extensionList) ".fit .fit.gz .fts .fts.gz .fits .fits.gz .jpg"

      #--- Recopie de variables
      set conf(extension,new)   $conf(extension,defaut)
      set conf(jpegquality,new) $conf(jpegquality,defaut)
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration des fichiers image
   #
   proc createDialog { } {
      variable This
      global audace caption color conf confgene

      #--- confToWidget
      set confgene(fichier,save_seuils_visu)          $conf(save_seuils_visu)
      set confgene(fichier,format)                    $conf(format_fichier_image)
      set confgene(extension,new)                     $conf(extension,new)
      set confgene(fichier,compres)                   $conf(fichier,compres)
      set confgene(jpegquality,new)                   $conf(jpegquality,new)
      set confgene(fichier,list_extension)            $::audace(extensionList)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Destruction de la fenetre Selection d'images si elle existe
      if [winfo exists $audace(base).select] {
         destroy $audace(base).select
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,fichier_image)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      TitleFrame $This.frame3 -borderwidth 2 -relief ridge -text "$caption(confgene,fichier_image_fits)"
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1 -padx 2 -pady 2

      TitleFrame $This.frame4 -borderwidth 2 -relief ridge -text "$caption(confgene,fichier_image_jpg)"
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1 -padx 2 -pady 2

      frame $This.frame5 -borderwidth 0 -relief raised
      pack $This.frame5 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame6 -borderwidth 0 -relief raised
      pack $This.frame6 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame6 -side left -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame6 -side left -fill both -expand 1

      frame $This.frame9 -borderwidth 0 -relief raised
      pack $This.frame9 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame10 -borderwidth 0 -relief raised
      pack $This.frame10 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame11 -borderwidth 0 -relief raised
      pack $This.frame11 -in [ $This.frame3 getframe ] -side top -fill both -expand 1

      frame $This.frame12 -borderwidth 0 -relief raised
      pack $This.frame12 -in [ $This.frame4 getframe ] -side top -fill both -expand 1

      frame $This.frame13 -borderwidth 0 -relief raised
      pack $This.frame13 -in [ $This.frame4 getframe ] -side top -fill both -expand 1

      frame $This.frame14 -borderwidth 0 -relief raised
      pack $This.frame14 -in [ $This.frame4 getframe ] -side top -fill both -expand 1

      #--- Enregistrer une image en conservant ou non les seuils de la visu
      checkbutton $This.save_seuils_visu -text "$caption(confgene,fichier_images_seuils_visu)" \
         -highlightthickness 0 -variable confgene(fichier,save_seuils_visu)
      pack $This.save_seuils_visu -in $This.frame5 -anchor center -side left -padx 10 -pady 5

      #--- Enregistrer une image en choisissant le format
      label $This.lab2 -text "$caption(confgene,fichier_images_choix_format)"
      pack $This.lab2 -in $This.frame7 -anchor ne -side left -padx 10 -pady 5

      #--- Radio-bouton pour le format entier
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 \
         -text "$caption(confgene,fichier_images_entier)" -value 0 -variable confgene(fichier,format)
      pack $This.rad1 -in $This.frame8 -anchor w -side top -padx 5 -pady 5

      #--- Radio-bouton pour le format flottant
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 \
         -text "$caption(confgene,fichier_images_flottant)" -value 1 -variable confgene(fichier,format)
      pack $This.rad2 -in $This.frame8 -anchor w -side top -padx 5 -pady 5

      #--- Rappelle l'extension par defaut des fichiers image
      label $This.lab1 -text "$caption(confgene,fichier_image_ext_defaut)"
      pack $This.lab1 -in $This.frame9 -anchor center -side left -padx 10 -pady 5

      label $This.labURL2 -text "$conf(extension,defaut)" -fg $color(blue)
      pack $This.labURL2 -in $This.frame9 -anchor center -side right -padx 20 -pady 5

      #--- Cree la zone a renseigner de la nouvelle extension par defaut
      label $This.lab3 -text "$caption(confgene,fichier_image_new_ext)"
      pack $This.lab3 -in $This.frame10 -anchor center -side left -padx 10 -pady 5

      entry $This.newext -textvariable confgene(extension,new) -width 5 -justify center \
         -validate all -validatecommand { ::confFichierIma::extensionProhibited %W %V %P %s extension } \
         -invcmd bell
      pack $This.newext -in $This.frame10 -anchor center -side right -padx 10 -pady 5

      #--- Ouvre le choix aux fichiers compresses
      checkbutton $This.compress -text "$caption(confgene,fichier_image_compres)" \
         -highlightthickness 0 -variable confgene(fichier,compres)
      pack $This.compress -in $This.frame11 -anchor center -side left -padx 10 -pady 5

      #--- Rappelle le taux de qualite d'enregistrement par defaut des fichiers Jpeg
      label $This.lab4 -text "$caption(confgene,fichier_image_jpeg_quality)"
      pack $This.lab4 -in $This.frame12 -anchor center -side left -padx 10 -pady 5

      label $This.labURL5 -text "$conf(jpegquality,defaut)" -fg $color(blue)
      pack $This.labURL5 -in $This.frame12 -anchor center -side right -padx 20 -pady 5

      #--- Cree la glissiere de reglage pour la nouvelle valeur de qualite par defaut
      label $This.lab6 -text "$caption(confgene,fichier_image_jpeg_newquality)"
      pack $This.lab6 -in $This.frame13 -anchor center -side left -padx 10 -pady 5

      scale $This.efficacite_variant -from 5 -to 100 -length 300 -orient horizontal \
         -showvalue true -tickinterval 10 -resolution 1 -borderwidth 2 -relief groove \
         -variable confgene(jpegquality,new) -width 10
      pack $This.efficacite_variant -in $This.frame14 -side top -padx 10 -pady 5

      #--- Cree le bouton "OK"
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confFichierIma::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confFichierIma::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confFichierIma::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confFichierIma::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief acquisition de la configuration, c'est à dire isolation
   #  des différentes variables locales dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(save_seuils_visu)          $confgene(fichier,save_seuils_visu)
      set conf(format_fichier_image)      $confgene(fichier,format)
      set conf(extension,defaut)          $confgene(extension,new)
      set conf(extension,new)             $confgene(extension,new)
      set conf(fichier,compres)           $confgene(fichier,compres)
      set conf(jpegquality,defaut)        $confgene(jpegquality,new)
      set conf(jpegquality,new)           $confgene(jpegquality,new)
      set ::audace(extensionList)         $confgene(fichier,list_extension)
   }

   #------------------------------------------------------------
   ## @brief contrôle la saisie au clavier de la nouvelle extension FITS
   #  émet un bip quand l'extension FITS choisie utilise une extension réservée
   #  (.crw, .CRW, .cr2, .CR2, .nef, .NEF, .dng, .DNG, .jpg, .jpeg, .bmp, .gif,
   #  .tif, .tiff, .png, .ps, .pdf, .txt, .htm, .html, .tcl, .cap et .jar)
   #  @param win           inutilsé
   #  @param event         définit l'événement Tk à surveiller
   #  @param newValue      définit la nouvelle valeur de l'extension FITS
   #  @param oldValue      définit l'ancienne valeur de l'extension FITS
   #  @param class         inutilsé
   #  @param errorVariable inutilsé (paramètre optionnel)
   #
   proc extensionProhibited { win event newValue oldValue class { errorVariable "" } } {
      set result 0
      if { $event == "key" || $event == "focusout" || $event == "forced" } {
         set ctrl [ string range $newValue 0 0 ]
         if { $ctrl == "." } {
            set result 1
            if {  ( $newValue == ".crw" ) || ( $newValue == ".CRW" ) \
               || ( $newValue == ".cr2" ) || ( $newValue == ".CR2" ) \
               || ( $newValue == ".nef" ) || ( $newValue == ".NEF" ) \
               || ( $newValue == ".dng" ) || ( $newValue == ".DNG" ) \
               || ( $newValue == ".jpg" ) || ( $newValue == ".jpeg" ) \
               || ( $newValue == ".bmp" ) || ( $newValue == ".gif" ) \
               || ( $newValue == ".tif" ) || ( $newValue == ".tiff" ) \
               || ( $newValue == ".png" ) || ( $newValue == ".ps" ) \
               || ( $newValue == ".pdf" ) || ( $newValue == ".txt" ) \
               || ( $newValue == ".htm" ) || ( $newValue == ".html" ) \
               || ( $newValue == ".tcl" ) || ( $newValue == ".cap" ) \
               || ( $newValue == ".jar" ) } {
               set result 0
            } else {
               set result 1
            }
         } else {
            set result 0
         }
         if { $result == 1 } {
            #--- j'accepte cette nouvelle extension
         } else {
            #--- je refuse cette nouvelle extension
            bell
         }
      } else {
         #--- je ne traite pas l'evenement
         set result 1
      }
      return $result
   }
}

#----------------------------------------------------------------------

#
## namespace confAlarmeFinPose
# @brief Configuration de l'alarme de fin de pose
#

namespace eval ::confAlarmeFinPose {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration de l'alarme de fin de pose
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" pour appliquer la configuration
   #  et fermer la fenêtre de configuration de l'alarme de fin de pose
   #
   proc ok { } {
      appliquer
      fermer
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" de la fenêtre de configuration de l'alarme de fin de pose
   #  pour mémoriser et appliquer la configuration
   #
   proc appliquer { } {
      global conf confgene

      if { $confgene(alarme,active) == "0" } {
         set conf(acq,bell) "-1"
      } else {
         set conf(acq,bell) $confgene(alarme,delai)
      }
      widgetToConf
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1070alarme.htm"
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre "Alarme de fin de pose..."
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(acq,bell)      définit le délai actionnant une alarme x secondes avant la fin de l'acquisition
   #  - conf(alarme,active) définit si l'alarme de fin d'acquisition est active ou non
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(acq,bell) ] }      { set conf(acq,bell)      "2" }
      if { ! [ info exists conf(alarme,active) ] } { set conf(alarme,active) "1" }
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration de l'alarme de fin de pose
   #
   proc createDialog { } {
      variable This
      global caption conf confgene

      #--- initConf
      initConf

      #--- confToWidget
      set confgene(alarme,delai)  $conf(acq,bell)
      set confgene(alarme,active) $conf(alarme,active)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,alarme)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      #--- Ouvre le choix a l'utilisation ou non de l'alarme sonore
      checkbutton $This.alarme -text "$caption(confgene,alarme_active)" -highlightthickness 0 \
         -variable confgene(alarme,active)
      pack $This.alarme -in $This.frame3 -anchor w -side left -padx 10 -pady 3

      #--- Cree la zone a renseigner du delai pour l'alarme de fin de pose
      entry $This.delai -textvariable confgene(alarme,delai) -width 3 -justify center
      pack $This.delai -in $This.frame4 -anchor w -side left -padx 20 -pady 3

      label $This.lab1 -text "$caption(confgene,alarme_delai)"
      pack $This.lab1 -in $This.frame4 -anchor w -side left -padx 0 -pady 3

      #--- Cree le bouton "OK"
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confAlarmeFinPose::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confAlarmeFinPose::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label "Invisible" pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confAlarmeFinPose::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confAlarmeFinPose::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief acquisition de la configuration, c'est à dire isolation
   #  des différentes variables locales dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(acq,bell)      $confgene(alarme,delai)
      set conf(alarme,active) $confgene(alarme,active)
   }
}

#----------------------------------------------------------------------

#
## namespace confNbreDecimales
# @brief Configuration du nombre de décimales à afficher
#

namespace eval ::confNbreDecimales {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration du choix du nombre de décimales
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" pour appliquer la configuration
   #  et fermer la fenêtre de configuration du choix du nombre de décimales
   #
   proc ok { } {
      appliquer
      fermer
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" pour mémoriser et appliquer
   #  la configuration de la fenêtre de configuration du choix du nombre de décimales
   #
   proc appliquer { } {
      global conf confgene

      if { $confgene(nbreDecimales) == "12" } {
         set ::tcl_precision 12
      } else {
         set ::tcl_precision 17
      }
      widgetToConf
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1120nbredecimales.htm"
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre "Nombre de décimales..."
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(nbreDecimales) définit le nombre de décimales à appliquer lors des calculs Tcl
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(nbreDecimales) ] } { set conf(nbreDecimales) "12" }
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration du choix du nombre de décimales
   #
   proc createDialog { } {
      variable This
      global caption conf confgene

      #--- Initialisation indispensable de la variable pour le nombre de decimales dans aud.tcl (::audace::loadSetup)
      #--- initConf

      #--- confToWidget
      set confgene(nbreDecimales) $conf(nbreDecimales)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,nbreDecimales)

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

      #--- Affichage de l'action
      label $This.lab1 -text "$caption(confgene,choixNbreDecimales)"
      pack $This.lab1 -in $This.frame3 -anchor w -side left -padx 10 -pady 3

      #--- Ouvre le choix au nombre de decimales
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -value 12 \
         -text "$caption(confgene,12decimales)" -variable confgene(nbreDecimales)
      pack $This.rad1 -in $This.frame4 -anchor center -side top -fill x -padx 40 -pady 5

      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -value 17 \
         -text "$caption(confgene,17decimales)" -variable confgene(nbreDecimales)
      pack $This.rad2 -in $This.frame5 -anchor center -side top -fill x -padx 40 -pady 5

      #--- Cree le bouton "OK"
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confNbreDecimales::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confNbreDecimales::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label "Invisible" pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confNbreDecimales::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confNbreDecimales::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief acquisition de la configuration, c'est à dire isolation
   #  des différentes variables locales dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(nbreDecimales) $confgene(nbreDecimales)
   }
}

#----------------------------------------------------------------------

#
## namespace confProxyInternet
#  @brief Configuration d'un Proxy pour Internet
#

namespace eval ::confProxyInternet {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration du Proxy pour Internet
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" pour appliquer la configuration
   #  et fermer la fenêtre de configuration du choix Proxy pour Internet
   #
   proc ok { } {
      appliquer
      fermer
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" pour mémoriser et appliquer
   #  la configuration de la fenêtre de configuration du Proxy pour Internet
   #
   proc appliquer { } {
      widgetToConf
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1110proxy.htm"
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre "Internet (Proxy)..."
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(proxy,host)     définit le nom du serveur ou l'adresse du Proxy
   #  - conf(proxy,port)     définit le port du Proxy
   #  - conf(proxy,user)     définit le nom de l'utilisateur du Proxy
   #  - conf(proxy,password) définit le mot de passe du Proxy
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(proxy,host) ] }     { set conf(proxy,host)     "NomServeurProxy_ou_IP" }
      if { ! [ info exists conf(proxy,port) ] }     { set conf(proxy,port)     "8080" }
      if { ! [ info exists conf(proxy,user) ] }     { set conf(proxy,user)     "user_du_proxy" }
      if { ! [ info exists conf(proxy,password) ] } { set conf(proxy,password) "password_du_proxy" }
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration du Proxy pour Internet
   #
   proc createDialog { } {
      variable This
      global caption conf confgene

      #--- initConf
      initConf

      #--- confToWidget
      set confgene(proxy,host)     $conf(proxy,host)
      set confgene(proxy,port)     $conf(proxy,port)
      set confgene(proxy,user)     $conf(proxy,user)
      set confgene(proxy,password) $conf(proxy,password)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,proxy)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0 -relief raised
      pack $This.frame3 -in $This.frame1 -side left -fill x

      frame $This.frame4 -borderwidth 0 -relief raised
      pack $This.frame4 -in $This.frame1 -side left -fill x

      #--- Proxy : Nom
      label $This.labelNom -text $caption(confgene,nom)
      pack $This.labelNom -in $This.frame3 -side top -anchor w -padx 5

      entry $This.entryNom -textvariable confgene(proxy,host) -width 30
      pack $This.entryNom -in $This.frame4 -side top

      #--- Proxy : Port
      label $This.labelPort -text $caption(confgene,port)
      pack $This.labelPort -in $This.frame3 -side top -anchor w -padx 5

      entry $This.entryPort -textvariable confgene(proxy,port) -width 30 \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
      pack $This.entryPort -in $This.frame4 -side top

      #--- Proxy : Utilisateur
      label $This.labelUtilisateur -text $caption(confgene,user)
      pack $This.labelUtilisateur -in $This.frame3 -side top -anchor w -padx 5

      entry $This.entryUtilisateur -textvariable confgene(proxy,user) -width 30
      pack $This.entryUtilisateur -in $This.frame4 -side top

      #--- Proxy : Mot de passe
      label $This.labelMotDePasse -text $caption(confgene,password)
      pack $This.labelMotDePasse -in $This.frame3 -side top -anchor w -padx 5

      entry $This.entryMotDePasse -textvariable confgene(proxy,password) -width 30
      pack $This.entryMotDePasse -in $This.frame4 -side top

      #--- Cree le bouton "OK"
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confProxyInternet::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confProxyInternet::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un label "Invisible" pour simuler un espacement
      label $This.lab_invisible -width 10
      pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confProxyInternet::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confProxyInternet::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief acquisition de la configuration, c'est à dire isolation
   #  des différentes variables locales dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(proxy,host)     $confgene(proxy,host)
      set conf(proxy,port)     $confgene(proxy,port)
      set conf(proxy,user)     $confgene(proxy,user)
      set conf(proxy,password) $confgene(proxy,password)
   }
}

#----------------------------------------------------------------------

#
## namespace confTypeFenetre
#  @brief Configuration du type de fenêtre du menu 'Configuration'
#

namespace eval ::confTypeFenetre {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration du type de fenetre
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "OK" pour appliquer la configuration
   #  et fermer la fenêtre de configuration du type de fenetre
   #
   proc ok { } {
      appliquer
      fermer
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Appliquer" pour mémoriser et appliquer
   #  la configuration de la fenêtre de configuration du type de fenetre
   #
   proc appliquer { } {
      widgetToConf
      rafraichissement
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1080type_fenetre.htm"
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   #  brief rafraîchissement de l'affichage graphique de la fenêtre de configuration du type de fenetre
   #
   proc rafraichissement { } {
      variable This
      global audace

      fermer
      ::confTypeFenetre::run "$audace(base).confTypeFenetre"
      focus $This
   }

   #------------------------------------------------------------
   ## @brief initialise les paramètres de la fenêtre "Type de fenêtre..."
   #  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
   #  - conf(ok+appliquer) définit si on affiche 1 bouton "Appliquer" (0) ou 2 boutons "OK" et "Appliquer" (1) dans les fenêtres de configuration
   #
   proc initConf { } {
      global conf

      if { ! [ info exists conf(ok+appliquer) ] } { set conf(ok+appliquer) "1" }
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration du type de fenetre
   #
   proc createDialog { } {
      variable This
      global caption conf confgene

      #--- Initialisation indispensable de la variable du type de fenetre dans aud.tcl (::audace::loadSetup)
      #--- initConf

      #--- confToWidget
      set confgene(TypeFenetre,ok+appliquer) $conf(ok+appliquer)

      #---
      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,type_fenetre)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side bottom -fill x

      frame $This.frame3 -borderwidth 1 -relief raised
      pack $This.frame3 -in $This.frame1 -side left -fill y

      frame $This.frame4 -borderwidth 1 -relief raised
      pack $This.frame4 -in $This.frame1 -side top -fill x

      frame $This.frame5 -borderwidth 1 -relief raised
      pack $This.frame5 -in $This.frame1 -side top -fill x

      #--- Cree le bouton "OK"
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command { ::confTypeFenetre::ok }
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }

      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
         -command { ::confTypeFenetre::appliquer }
      pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confTypeFenetre::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command { ::confTypeFenetre::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree un frame pour y mettre les radio-boutons de choix
      #--- Type OK + Appliquer + Annuler
      radiobutton $This.rad1 -anchor nw -highlightthickness 0 -value 0 \
         -variable confgene(TypeFenetre,ok+appliquer)
      pack $This.rad1 -in $This.frame3 -anchor center -side top -fill x -padx 5 -pady 5
      #--- Type Appliquer + Annuler
      radiobutton $This.rad2 -anchor nw -highlightthickness 0 -value 1 \
         -variable confgene(TypeFenetre,ok+appliquer)
      pack $This.rad2 -in $This.frame3 -anchor center -side bottom -fill x -padx 5 -pady 5

      #--- Affichage des boutons "Appliquer" + "Aide" + "Fermer"
      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer_1 -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2
      pack $This.but_appliquer_1 -in $This.frame4 -side left -anchor w -padx 3 -pady 3  -ipady 5
      #--- Cree le bouton "Fermer"
      button $This.but_fermer_1 -text "$caption(confgene,fermer)" -width 7 -borderwidth 2
      pack $This.but_fermer_1 -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree le bouton "Aide"
      button $This.but_aide_1 -text "$caption(confgene,aide)" -width 7 -borderwidth 2
      pack $This.but_aide_1 -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Affichage des boutons "OK" + "Appliquer" + "Aide" + "Fermer"
      #--- Cree le bouton "OK"
      button $This.but_ok_2 -text "$caption(confgene,ok)" -width 7 -borderwidth 2
      pack $This.but_ok_2 -in $This.frame5 -side left -anchor w -padx 3 -pady 3  -ipady 5
      #--- Cree le bouton "Appliquer"
      button $This.but_appliquer_2 -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2
      pack $This.but_appliquer_2 -in $This.frame5 -side left -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree un label "Invisible" pour simuler un espacement
      label $This.lab_invisible_2 -width 10
      pack $This.lab_invisible_2 -in $This.frame5 -side left -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree le bouton "Fermer"
      button $This.but_fermer_2 -text "$caption(confgene,fermer)" -width 7 -borderwidth 2
      pack $This.but_fermer_2 -in $This.frame5 -side right -anchor w -padx 3 -pady 3 -ipady 5
      #--- Cree le bouton "Aide"
      button $This.but_aide_2 -text "$caption(confgene,aide)" -width 7 -borderwidth 2
      pack $This.but_aide_2 -in $This.frame5 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   #  brief acquisition de la configuration, c'est à dire isolation
   #  des différentes variables locales dans le tableau conf(...)
   #
   proc widgetToConf { } {
      global conf confgene

      set conf(ok+appliquer) $confgene(TypeFenetre,ok+appliquer)
   }
}

#----------------------------------------------------------------------

#
## namespace confLangue
#  @brief Configuration pour le choix des langues
#

namespace eval ::confLangue {

   #------------------------------------------------------------
   #  brief crée la fenêtre de configuration du choix de la langue
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      for { set i 1 } { $i < 8 } { incr i } {
         image delete imageflag$i
      }
      destroy $This
   }

   #------------------------------------------------------------
   #  brief commande associée au bouton "Aide"
   #
   proc afficheAide { } {
      global help

      #---
      ::audace::showHelpItem "$help(dir,config)" "1010langue.htm"
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre de configuration du choix de la langue
   #
   proc createDialog { } {
      variable This
      global caption

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+50
      wm resizable $This 0 0
      wm title $This $caption(confgene,langue_titre)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      frame $This.frame3 -borderwidth 0
      pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame4 -borderwidth 0
      pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

      frame $This.frame5 -borderwidth 0
      pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

      #--- Cree le label pour le commentaire
      label $This.lab1 -text "$caption(confgene,langue_selection)"
      pack $This.lab1 -in $This.frame3 -side top -anchor w -padx 5 -pady 5

      #--- Drapeau French
      image create photo imageflag1
      imageflag1 configure -file [ file join $::audela_start_dir fr.gif ] -format gif
      button $This.french -image imageflag1 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue french }
      pack $This.french -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Italian
      image create photo imageflag2
      imageflag2 configure -file [ file join $::audela_start_dir it.gif ] -format gif
      button $This.italian -image imageflag2 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue italian }
      pack $This.italian -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Spanish
      image create photo imageflag3
      imageflag3 configure -file [ file join $::audela_start_dir sp.gif ] -format gif
      button $This.spanish -image imageflag3 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue spanish }
      pack $This.spanish -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau German
      image create photo imageflag4
      imageflag4 configure -file [ file join $::audela_start_dir de.gif ] -format gif
      button $This.german -image imageflag4 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue german }
      pack $This.german -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Portuguese
      image create photo imageflag5
      imageflag5 configure -file [ file join $::audela_start_dir pt.gif ] -format gif
      button $This.portuguese -image imageflag5 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue portuguese }
      pack $This.portuguese -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Danish
      image create photo imageflag6
      imageflag6 configure -file [ file join $::audela_start_dir da.gif ] -format gif
      button $This.danish -image imageflag6 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue danish }
      pack $This.danish -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Ukrainian
      image create photo imageflag7
      imageflag7 configure -file [ file join $::audela_start_dir ua.gif ] -format gif
      button $This.ukrainian -image imageflag7 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue ukrainian }
      pack $This.ukrainian -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau Russian
      image create photo imageflag8
      imageflag8 configure -file [ file join $::audela_start_dir ru.gif ] -format gif
      button $This.russian -image imageflag8 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue russian }
      pack $This.russian -in $This.frame4 -side left -padx 5 -pady 5

      #--- Drapeau English
      image create photo imageflag9
      imageflag9 configure -file [ file join $::audela_start_dir gb.gif ] -format gif
      button $This.english -image imageflag9 -relief solid -borderwidth 0 \
         -command { ::confLangue::choisirLangue english }
      pack $This.english -in $This.frame4 -side left -padx 5 -pady 5

      #--- Visualise la langue pre-selectionnee
      $This.$::langage configure -borderwidth 3

      #--- Cree le label pour le commentaire
      label $This.lab2 -text "$caption(confgene,langue_texte)"
      pack $This.lab2 -in $This.frame5 -side top -anchor w -padx 5 -pady 5

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confLangue::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton "Aide"
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
        -command { ::confLangue::afficheAide }
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #------------------------------------------------------------
   ## @brief sélectionner un drapeau pour changer de langue
   #  @param langue drapeau choisit par l'utilisateur
   #
   proc choisirLangue { langue } {
      variable This
      global audace caption

      #--- Mise a jour du drapeau selectionne et de la langue
      $This.$::langage configure -borderwidth 0
      set ::langage $langue
      $This.$langue configure -borderwidth 3
      set f [open [ file join $::audace(rep_home) langage.ini ] w]
      puts $f "set langage \"$langue\""
      close $f

      #--- Recharge confgene.cap pour que les textes soient dans la langue du drapeau selectionne
      source [ file join $audace(rep_caption) confgene.cap ]

      #--- Mise a jour des textes de la fenetre
      wm title $This $caption(confgene,langue_titre)
      $This.lab1 configure -text "$caption(confgene,langue_selection)"
      $This.lab2 configure -text "$caption(confgene,langue_texte)"

      #--- Mise a jour des boutons de la fenetre
      .audace.confLangue.but_fermer configure -text "$caption(confgene,fermer)"
      .audace.confLangue.but_aide configure -text "$caption(confgene,aide)" -state disabled
   }
}

#----------------------------------------------------------------------

#
## namespace confVersion
#  @brief Version du logiciel du menu "A propos de ..."
#

namespace eval ::confVersion {

   #------------------------------------------------------------
   #  brief crée la fenêtre définissant la version du logiciel
   #  param this chemin de la fenêtre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #------------------------------------------------------------
   ## @brief commande associée au bouton "Fermer"
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #------------------------------------------------------------
   #  brief crée l'interface graphique de la fenêtre définissant la version du logiciel
   #
   proc createDialog { } {
      variable This
      global audela caption color

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This
         return
      }

      #--- Cree la fenetre $This de niveau le plus haut
      toplevel $This -class Toplevel
      wm geometry $This +180+0
      wm resizable $This 0 0
      wm title $This $caption(en-tete,a_propos_de)

      #--- Creation des differents frames
      frame $This.frame1 -borderwidth 1 -relief raised
      pack $This.frame1 -side top -fill both -expand 1

      frame $This.frame2 -borderwidth 1 -relief raised
      pack $This.frame2 -side top -fill x

      #--- Nom du logiciel, sa version et la version svn
      if { [ info exists ::audela(revision) ] == 1 } {
         if { $::audela(revision) != "" } {
            label $This.lab1 -text "[ ::audela::getPluginTitle ] $audela(version) \
               ($caption(en-tete,a_propos_de_version_SVN) $::audela(revision))"
         } else {
            label $This.lab1 -text "[ ::audela::getPluginTitle ] $audela(version)"
         }
      } else {
         label $This.lab1 -text "[ ::audela::getPluginTitle ] $audela(version)"
      }
      pack $This.lab1 -in $This.frame1 -padx 30 -pady 2

      #--- Version Tcl/Tk utilisee
      label $This.lab2 -text "$caption(en-tete,a_propos_de_version_Tcl/Tk)[ info patchlevel ] multithread"
      pack $This.lab2 -in $This.frame1 -padx 30 -pady 2

      #--- Date de la mise a jour
      label $This.labURL2 -text "$caption(en-tete,a_propos_de_maj) $audela(date)." -fg $color(red)
      pack $This.labURL2 -in $This.frame1 -padx 30 -pady 2

      #--- Logiciel libre et gratuit
      label $This.lab3 -text "$caption(en-tete,a_propos_de_libre)"
      pack $This.lab3 -in $This.frame1 -padx 30 -pady 2

      #--- Site web officiel
      label $This.labURL4 -text "$caption(en-tete,a_propos_de_site)" -fg $color(blue)
      pack $This.labURL4 -in $This.frame1 -padx 30 -pady 2

      #--- Copyright
      label $This.lab5 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright1)"
      pack $This.lab5 -in $This.frame1 -padx 30 -pady 2

      label $This.lab6 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright2)"
      pack $This.lab6 -in $This.frame1 -padx 30 -pady 2

      label $This.lab7 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright3)"
      pack $This.lab7 -in $This.frame1 -padx 30 -pady 2

      label $This.lab8 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright4)"
      pack $This.lab8 -in $This.frame1 -padx 30 -pady 2

      label $This.lab9 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright5)"
      pack $This.lab9 -in $This.frame1 -padx 30 -pady 2

      label $This.lab10 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright6)"
      pack $This.lab10 -in $This.frame1 -padx 30 -pady 2

      label $This.lab11 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright7)"
      pack $This.lab11 -in $This.frame1 -padx 30 -pady 2

      label $This.lab12 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright8)"
      pack $This.lab12 -in $This.frame1 -padx 30 -pady 2

      label $This.lab13 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright9)"
      pack $This.lab13 -in $This.frame1 -padx 30 -pady 2

      label $This.lab14 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright10)"
      pack $This.lab14 -in $This.frame1 -padx 30 -pady 2

      label $This.lab15 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright11)"
      pack $This.lab15 -in $This.frame1 -padx 30 -pady 2

      label $This.lab16 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright12)"
      pack $This.lab16 -in $This.frame1 -padx 30 -pady 2

      label $This.lab17 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright13)"
      pack $This.lab17 -in $This.frame1 -padx 30 -pady 2

      label $This.lab18 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright14)"
      pack $This.lab18 -in $This.frame1 -padx 30 -pady 2

      label $This.lab19 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright15)"
      pack $This.lab19 -in $This.frame1 -padx 30 -pady 2

      label $This.lab20 -borderwidth 1 -anchor w -text "$caption(en-tete,a_propos_de_copyright16)"
      pack $This.lab20 -in $This.frame1 -padx 30 -pady 2

      #--- Cree le bouton "Fermer"
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command { ::confVersion::fermer }
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

      #--- Creation du lien avec le navigateur web et changement de sa couleur
      bind $This.labURL4 <ButtonPress-1> {
         set filename "$caption(en-tete,a_propos_de_site)"
         ::audace::Lance_Site_htm $filename
      }
      bind $This.labURL4 <Enter> {
         $::confVersion::This.labURL4 configure -fg $color(purple)
      }
      bind $This.labURL4 <Leave> {
         $::confVersion::This.labURL4 configure -fg $color(blue)
      }
   }
}

#----------------------------------------------------------------------

#
## namespace confGenerique
#  @brief céé une fenêtre de configuration générique
#  @details cette fenêtre appelle les fonctions spécifiques du namespace passé en paramètre
#  - namespace::cmdApply         pour le bouton "Appliquer" ou "Ok"
#  - namespace::cmdClose         pour le bouton "Fermer" ou "OK"
#  - namespace::getLabel         retourne le titre de la fenêtre
#  - namespace::fillConfigPage   pour la création des widgets dans la fenêtre
#  - namespace::showHelp         pour le bouton d'aide
#

namespace eval ::confGenerique {
}

#------------------------------------------------------------
## @brief crée la fenêtre de configuration générique
#  @param args liste d'arguments
#  - visuNo    : numéro de la visu courante
#  - tkName    : chemin TK de la fenêtre
#  - namespace : namespace des fonctions spécifiques
#  paramètres optionnels :
#  - modal 0|1 : 1=modal (attend la fermeture de la fenêtre) ou 0=non modal (retourne immediatement)
#                valeur par défaut = 1
#  - geometry 200x100+180+50 : taille et position relative de la fenetre
#              valeur par défaut = 200x100+180+50
#  - resizable 0|1 : 1=redimmensionnement possible ou 0=redimensionnement interdit
#              valeur par defaut = 1
#  - close 0|1 : 1=fermeture de la fenêtre possible ou 0=fermeture de la fenêtre interdite
#              valeur par defaut = 1
# @return
#  si modal=0 confGenerique::run retourne 0 immédiatement
#  si modal=1 confGenerique::run reste bloquée tant que la fenêtre reste ouverte
#     Quand la fenêtre est fermée par l'utilisateur, confGenerique::run se débloque et retourne :
#      - 1 si la fenêtre a été fermée avec le bouton OK
#      - 0 si la fenêtre a été fermée avec le bouton Fermer
#
proc ::confGenerique::run { args } {
   variable private

   set visuNo   [lindex $args 0]
   set This     [lindex $args 1]
   set NameSpace [lindex $args 2]
   set options  [lrange $args 3 end]

   #--- valeur par defaut des options
   set private($visuNo,$NameSpace,modal)     "1"
   set private($visuNo,$NameSpace,geometry)  "+180+50"
   set private($visuNo,$NameSpace,resizable) "0"
   set private($visuNo,$NameSpace,close)     "1"
   set private($visuNo,$NameSpace,this)      $This

   #--- je traite les options
   while {[llength $options] > 0} {
      set arg [lindex $options 0]
      switch -- "$arg" {
         "-modal" {
            set private($visuNo,$NameSpace,modal) [lindex $options 1]
         }
         "-geometry" {
            set private($visuNo,$NameSpace,geometry) [lindex $options 1]
         }
         "-resizable" {
            set private($visuNo,$NameSpace,resizable) [lindex $options 1]
         }
         "-close" {
            set private($visuNo,$NameSpace,close) [lindex $options 1]
         }
      }
      set options [lrange $options 2 end]
   }

   createDialog $visuNo $NameSpace

   set private($visuNo,$NameSpace,modalResult) "0"
   if { $private($visuNo,$NameSpace,modal) == "1" } {
      #--- j'attends la fermeture de la fenetre avant de terminer
      tkwait window $private($visuNo,$NameSpace,this)
      return $private($visuNo,$NameSpace,modalResult)
   } else {
      return "0"
   }
}

#------------------------------------------------------------
#  brief commande associée au bouton "OK" pour appliquer la configuration
#  et fermer la fenêtre de configuration générique
#  param visuNo    numéro de la visu
#  param NameSpace nom du namespace
#
proc ::confGenerique::ok { visuNo NameSpace } {
   variable private

   set private($visuNo,$NameSpace,modalResult) "1"
   ::confGenerique::cmdApply $visuNo $NameSpace
   ::confGenerique::cmdClose $visuNo $NameSpace
}

#------------------------------------------------------------
## @brief commande associée au bouton "Appliquer" pour mémoriser et appliquer
#  la configuration de la fenêtre de configuration générique
#  @param visuNo    numéro de la visu
#  @param NameSpace nom du namespace
#
proc ::confGenerique::cmdApply { visuNo NameSpace } {
   #--- je copie le resultat de la procedure
   $NameSpace\:\:cmdApply $visuNo
}

#------------------------------------------------------------
#  brief commande associée au bouton "Aide"
#  param visuNo    numéro de la visu
#  param NameSpace nom du namespace
#
proc ::confGenerique::showHelp { visuNo NameSpace } {
   set result [ catch { $NameSpace\:\:showHelp } msg ]
   if { $result == "1" } {
      ::console::affiche_erreur "$msg\n"
      tk_messageBox -title "$NameSpace" -type ok -message "$msg" -icon error
      return
   }
}

#------------------------------------------------------------
## @brief commande associée au bouton "Fermer"
#  @details ferme la fenêtre si la procédure namepace::cmdClose retourne une valeur différente de "0"
#  @param visuNo    numéro de la visu
#  @param NameSpace nom du namespace
#
proc ::confGenerique::cmdClose { visuNo NameSpace } {
   variable private

   if { $private($visuNo,$NameSpace,close) == "1" } {
      if { [winfo exists $private($visuNo,$NameSpace,this)] } {
         if { [info procs $NameSpace\:\:cmdClose ] != "" } {
            #--- appelle la procedure "cmdClose"
            set result [$NameSpace\:\:cmdClose $visuNo]
            if { $result == "0" } {
               return
            }
         }
         #--- supprime la fenetre
         destroy $private($visuNo,$NameSpace,this)
      }
     ### array unset private $visuNo,$NameSpace,*
   }
   return
}

#------------------------------------------------------------
#  brief crée l'interface graphique de la fenêtre de configuration générique
#  param visuNo    numéro de la visu
#  param NameSpace nom du namespace
#
proc ::confGenerique::createDialog { visuNo NameSpace } {
   variable private
   global caption conf

   if { [winfo exists $private($visuNo,$NameSpace,this)] } {
      wm withdraw $private($visuNo,$NameSpace,this)
      wm deiconify $private($visuNo,$NameSpace,this)
      focus $private($visuNo,$NameSpace,this)
      return
   }

   #--- Cree la fenetre private($visuNo,$NameSpace,this) de niveau le plus haut
   set This $private($visuNo,$NameSpace,this)
   toplevel $This -class Toplevel
   wm geometry $This $private($visuNo,$NameSpace,geometry)
   wm resizable $This $private($visuNo,$NameSpace,resizable) $private($visuNo,$NameSpace,resizable)
   wm title $This "[$NameSpace\:\:getLabel] (visu$visuNo)"
   wm protocol $This WM_DELETE_WINDOW "::confGenerique::cmdClose $visuNo $NameSpace"

   #--- Frame des boutons OK, Appliquer et Fermer
   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side bottom -fill x

   #--- Frame des parametres a configurer
   frame $This.frame1 -borderwidth 1 -relief raised
   $NameSpace\:\:fillConfigPage $This.frame1 $visuNo
   pack $This.frame1 -side top -fill both -expand 1

   #--- Si elle est modale, je fais apparaitre la fenetre toujours au dessus de
   #--- la fenetre parent
   if { $private($visuNo,$NameSpace,modal) == 1 } {
      wm transient $This [winfo parent $This]
   }

   if { [info commands "$NameSpace\::cmdApply"] !=  "" } {
      #--- Cree le bouton "OK" si la procedure NameSpace::cmdApply existe
      button $This.but_ok -text "$caption(confgene,ok)" -width 7 -borderwidth 2 \
         -command "::confGenerique::ok $visuNo $NameSpace"
      if { $conf(ok+appliquer) == "1" } {
         pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3  -ipady 5
      }

      if { $private($visuNo,$NameSpace,modal) == "0" } {
         #--- Cree le bouton "Appliquer" si la procedure NameSpace::cmdApply existe
         button $This.but_appliquer -text "$caption(confgene,appliquer)" -width 8 -borderwidth 2 \
            -command "::confGenerique::cmdApply $visuNo $NameSpace "
         pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
      }
   }
   #--- Cree un label "Invisible" pour simuler un espacement
   label $This.lab_invisible -width 10
   pack $This.lab_invisible -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton "Fermer"
   if { [info commands "$NameSpace\::cmdClose"] !=  "" } {
      button $This.but_fermer -text "$caption(confgene,fermer)" -width 7 -borderwidth 2 \
         -command "::confGenerique::cmdClose $visuNo $NameSpace"
      pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Raccourci qui ferme la fenetre avec la touche ESCAPE
      bind $This <Key-Escape> "::confGenerique::cmdClose $visuNo $NameSpace"
   }

   #--- Cree le bouton "Aide"
   if { [info commands "$NameSpace\::showHelp"] !=  "" } {
      button $This.but_aide -text "$caption(confgene,aide)" -width 7 -borderwidth 2 \
         -command "::confGenerique::showHelp $visuNo $NameSpace"
      pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5
   }

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}


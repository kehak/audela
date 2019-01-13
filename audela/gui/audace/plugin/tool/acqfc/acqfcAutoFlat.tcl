#
# Fichier : acqfcAutoFlat.tcl
# Description : Acquisition de flat sur le ciel
# Auteur : Frédéric Vachier
# Mise à jour $Id: acqfcAutoFlat.tcl 9824 2013-07-22 21:37:08Z robertdelmas $
#

namespace eval ::acqfcAutoFlat {

   #--- Chargement des captions
   source [ file join $::audace(rep_plugin) tool acqfc acqfcAutoFlat.cap ]

   #------------------------------------------------------------
   # run
   #    Lancement de l'interface d'acquisition des flats auto
   #------------------------------------------------------------
   proc run { visuNo } {
      variable private

      #--- Initialisation de variables de configuration
      if { ! [ info exists ::conf(acqfc,acqAutoFlat,position) ] } { set ::conf(acqfc,acqAutoFlat,position) "+650+120" }
      if { ! [ info exists ::conf(acqfc,avancement1,position) ] } { set ::conf(acqfc,avancement1,position) "+700+300" }

      if { [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] } {
         wm withdraw $::panneau(acqfc,$visuNo,This).autoFlat
         wm deiconify $::panneau(acqfc,$visuNo,This).autoFlat
         focus $::panneau(acqfc,$visuNo,This).autoFlat
      } else {
         ::acqfcAutoFlat::createDialog $visuNo
      }
      return
   }

   #------------------------------------------------------------
   # createDialog
   #    Creation de l'interface graphique
   #------------------------------------------------------------
   proc createDialog { visuNo } {
      set err [ ::acqfcAutoFlat::Initialisation $visuNo ]

      if {$err == 0} {
         ::acqfcAutoFlat::acqAutoFlat $visuNo
      }
      return
   }

   #------------------------------------------------------------
   # Initialisation
   #    Initialisation de variables
   #------------------------------------------------------------
   proc Initialisation { visuNo } {
      variable private

      # Activation du programme dans des conditions de test hors crepuscule : private(testprog) = 1
      # Activation du programme dans les conditions d'observation           : private(testprog) = 0
      set private(testprog) 0
     ### set private(testprog) 1

      # Par defaut : On fait les flats en debut de nuit
      set private(sensnuit) 0

      # Raccourcis pratiques lies a la camera
      set private($visuNo,camItem) [ ::confVisu::getCamItem $visuNo ]
      set private($visuNo,camNo)   [ ::confCam::getCamNo $private($visuNo,camItem) ]
      set private($visuNo,camera)  cam$private($visuNo,camNo)

      # Teste la presence d'une camera connectee
      set err [catch {$private($visuNo,camera) info} msg]
      if { $err == 1 } {
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,pasCamera)\n\n"
         set choix [ tk_messageBox -title $::caption(acqfcAutoFlat,pb) -type ok \
            -message $::caption(acqfcAutoFlat,selcam) ]
         set integre non
         if { $choix == "ok" } {
            #--- Ouverture de la fenetre de selection des cameras
            ::confCam::run
         }
         return 1
      }

      # Attente entre les mesures du ciel si c'est trop tot
      set private(attente) 30

      # % de dynamique
      set private(mydynamique) 0.5

      # Temps d'exposition maximum
      set private(limitexptime) 35

      # Temps d'exposition minimum
      set private(exptimemini) 5

      # Initialisation du binning (identique a celui de l'interface principale)
      set private(mybin) $::panneau(acqfc,$visuNo,binning)

      # Initialisation du nombre de flats
      set private(mynbflat) 10

      # Initialisation du carre d'analyse pour la dynamique du flat
      set private(mysquare) 50

      # Initialisation du nombre de photosites
      set private(nbcells) [$private($visuNo,camera) nbcells]

      # Initialisation de la dynamique maximale
      set private(maxdyn) [format "%6.f" [$private($visuNo,camera) maxdyn]]

      # Initialisation des listes
      set private(binning)   {"1x1" "2x2" "3x3" "4x4"}
      set private(nbflat)    {1 2 3 4 5 6 7 8 9 10 50 100}
      set private(square)    {10 20 30 40 50 60 70 80 90 100 200 300}
      set private(dynamique) {0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9}

      # Initialisation du repertoire
      set private(rep_images) [ file join $::audace(rep_images) "CALIB" ]
      if { [file exists $private(rep_images)]==0} {
         if { [ catch {file mkdir $private(rep_images)} msg] } {
             ::console::affiche_erreur "$::caption(acqfcAutoFlat,msgRepertoire) $private(rep_images)/n"
         }
      }

      # Initialisation des variables de surveillance
      set private(pose_en_cours) 0
      set private(demande_stop)  0

      # Initialisation des variables de gestion de l'avancement
      set private(avancement_acq)       1
      set private(dispTimeAfterId)      ""
      set private(avancement1,position) $::conf(acqfc,avancement1,position)
      set private(acqfc,acqAutoFlat)    $::conf(acqfc,acqAutoFlat,position)

      return 0
   }

   #------------------------------------------------------------
   # arretAcqFlat
   #    Arret de l'acquisition des flats
   #------------------------------------------------------------
   proc arretAcqFlat { visuNo } {
      variable private

      #--- Je positionne l'indicateur d'arret de la pose
      set private(demande_stop) 1

      #--- Arret de la capture de l'image
      ::camera::stopAcquisition $private($visuNo,camItem)
      #--- J'attends la fin de l'acquisition
      vwait ::acqfcAutoFlat::private(finAquisition)

      # Initialisation de la camera (image pleine trame et obturateur synchro)
      $private($visuNo,camera) window [list 1 1 [lindex $private(nbcells) 0] [lindex $private(nbcells) 1] ]
      $private($visuNo,camera) shutter synchro

      #--- Message
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,arretDemande)\n"
   }

   #------------------------------------------------------------
   # pushSensNuit
   #    Configuration des boutons (debut/fin de nuit)
   #------------------------------------------------------------
   proc pushSensNuit { visuNo i } {
      variable private

      if {$i == 0} {
         $::panneau(acqfc,$visuNo,This).autoFlat.nuit.deb configure -bg $::audace(color,disabledTextColor)
         $::panneau(acqfc,$visuNo,This).autoFlat.nuit.fin configure -bg $::audace(color,backColor2)
         set private(sensnuit) 0
         set info_sens_nuit $::caption(acqfcAutoFlat,butDebutNuit)
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,debutNuit)\n"
      } else {
         $::panneau(acqfc,$visuNo,This).autoFlat.nuit.deb configure -bg $::audace(color,backColor2)
         $::panneau(acqfc,$visuNo,This).autoFlat.nuit.fin configure -bg $::audace(color,disabledTextColor)
         set private(sensnuit) 1
         set info_sens_nuit $::caption(acqfcAutoFlat,butFinNuit)
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,finNuit)\n"
      }
      if { [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat.g.sens ] } {
         $::panneau(acqfc,$visuNo,This).autoFlat.g.sens configure -text $info_sens_nuit
      }
   }

   #------------------------------------------------------------
   # changeBin
   #    Changement du binning
   #------------------------------------------------------------
   proc changeBin { visuNo mybin } {
      variable private

      set mybin $::panneau(acqfc,$visuNo,binning)

      $private($visuNo,camera) bin [list [lindex [split $mybin "x"] 0] [lindex [split $mybin "x"] 1]]
      set nbpix [$private($visuNo,camera) nbpix]
      $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb4 configure -text $nbpix

      set binning [$private($visuNo,camera) bin]
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,tailleImage) $nbpix\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,binning) $binning\n"
   }

   #------------------------------------------------------------
   # majBouton
   #    Mise a jour du bouton GOCCD
   #------------------------------------------------------------
   proc majBouton { visuNo fin } {
      variable private

      if { [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] } {
         $::panneau(acqfc,$visuNo,This).autoFlat.goccd.go configure -bg $::audace(color,backColor2) \
            -text "$::caption(acqfcAutoFlat,goFlatsAuto) - $::caption(acqfcAutoFlat,nbre) = $private(numeroFlat)"
         if {$fin == 1} {
            $::panneau(acqfc,$visuNo,This).autoFlat.goccd.go configure -bg $::audace(color,disabledTextColor)
         }
      }
   }

   #------------------------------------------------------------
   # acqAutoFlat
   #    Interface graphique de la fenetre d'acquisition des flats
   #------------------------------------------------------------
   proc acqAutoFlat { visuNo } {
      variable private

      if { [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] } {
         destroy $::panneau(acqfc,$visuNo,This).autoFlat
      }

      if { [ info exists private(geometryAcqAutoFlat) ] } {
         set deb [ expr 1 + [ string first + $private(geometryAcqAutoFlat) ] ]
         set fin [ string length $private(geometryAcqAutoFlat) ]
         set private(acqfc,acqAutoFlat) "+[string range $private(geometryAcqAutoFlat) $deb $fin]"
      }

      toplevel $::panneau(acqfc,$visuNo,This).autoFlat -class Toplevel -borderwidth 2 -relief groove
      wm geometry $::panneau(acqfc,$visuNo,This).autoFlat 530x330$private(acqfc,acqAutoFlat)
      wm resizable $::panneau(acqfc,$visuNo,This).autoFlat 1 1
      wm title $::panneau(acqfc,$visuNo,This).autoFlat $::caption(acqfcAutoFlat,acqAutoFlat)
      wm transient $::panneau(acqfc,$visuNo,This).autoFlat .audace
      wm protocol $::panneau(acqfc,$visuNo,This).autoFlat WM_DELETE_WINDOW "::acqfcAutoFlat::fermerAcqAutoFlat $visuNo"

      if {$private(sensnuit) == 0} {
         set info_sens_nuit $::caption(acqfcAutoFlat,butDebutNuit)
      } else {
         set info_sens_nuit $::caption(acqfcAutoFlat,butFinNuit)
      }

      set info [$private($visuNo,camera) info]
      set size [$private($visuNo,camera) nbcells]
      set nbcells [$private($visuNo,camera) nbcells]
      set gain [format "%4.2f" [$private($visuNo,camera) gain]]
      set temperature [format "%4.1f" [$private($visuNo,camera) temperature]]
      $private($visuNo,camera) bin [list [lindex [split $::panneau(acqfc,$visuNo,binning) "x"] 0] [lindex [split $::panneau(acqfc,$visuNo,binning) "x"] 1]]
      set nbpix [$private($visuNo,camera) nbpix]

      set info0 "$::caption(acqfcAutoFlat,camera) [$private($visuNo,camera) info]"
      set info1 "$::caption(acqfcAutoFlat,nbPixelsMax) $nbcells / $::caption(acqfcAutoFlat,ADAmax) $private(maxdyn) / $::caption(acqfcAutoFlat,gain) $gain / $::caption(acqfcAutoFlat,temperature) $temperature"

      frame $::panneau(acqfc,$visuNo,This).autoFlat.a0 -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.a0 -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top -expand 0 \
         -fill both -padx 3 -pady 0

         label $::panneau(acqfc,$visuNo,This).autoFlat.a0.camval -text $info0 -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.a0.camval -in $::panneau(acqfc,$visuNo,This).autoFlat.a0 -side left -anchor w \
            -padx 4 -pady 4 -expand 0

      frame $::panneau(acqfc,$visuNo,This).autoFlat.ae2 -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.ae2 -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top -expand 0 \
         -fill both -padx 3 -pady 0

         label $::panneau(acqfc,$visuNo,This).autoFlat.ae2.repimg -text "$::caption(acqfcAutoFlat,repImages) $private(rep_images)" \
            -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.ae2.repimg -in $::panneau(acqfc,$visuNo,This).autoFlat.ae2 -side left -anchor w \
            -padx 4 -pady 4 -expand 0

      frame $::panneau(acqfc,$visuNo,This).autoFlat.a1 -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.a1 -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top -expand 0 \
         -fill both -padx 3 -pady 0

         label $::panneau(acqfc,$visuNo,This).autoFlat.a1.camval -text $info1 -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.a1.camval -in $::panneau(acqfc,$visuNo,This).autoFlat.a1 -side left -anchor w \
            -padx 4 -pady 4 -expand 0

      frame $::panneau(acqfc,$visuNo,This).autoFlat.b -borderwidth 0 -relief solid
      pack $::panneau(acqfc,$visuNo,This).autoFlat.b -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top -expand 0 \
         -fill both -padx 3 -pady 0

         #--- Trame du binning
         menubutton $::panneau(acqfc,$visuNo,This).autoFlat.b.binning -text $::caption(acqfcAutoFlat,bin) \
            -menu $::panneau(acqfc,$visuNo,This).autoFlat.b.binning.menu -relief raised
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b.binning  -side left
         set m [ menu $::panneau(acqfc,$visuNo,This).autoFlat.b.binning.menu -tearoff 0 ]
         foreach valbin [ ::confCam::getPluginProperty [ ::confVisu::getCamItem $visuNo ] binningList ] {
            $m add radiobutton -label "$valbin" \
               -indicatoron "1" \
              -value "$valbin" \
               -variable ::panneau(acqfc,$visuNo,binning) \
               -command "::acqfcAutoFlat::changeBin $visuNo $::panneau(acqfc,$visuNo,binning)"
         }
         #--- Ligne de saisie
         entry $::panneau(acqfc,$visuNo,This).autoFlat.b.binningLab -width 10 -relief groove \
            -textvariable ::panneau(acqfc,$visuNo,binning) -justify center \
            -validate all -validatecommand { ::tkutil::validateString %W %V %P %s binning 1 5 }
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b.binningLab -side left -fill y

         #--- Nombre de Flat
         menubutton $::panneau(acqfc,$visuNo,This).autoFlat.b.nbi -text $::caption(acqfcAutoFlat,nbFlats) -relief raised \
            -menu $::panneau(acqfc,$visuNo,This).autoFlat.b.nbi.menu
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b.nbi -side left
         set m [menu $::panneau(acqfc,$visuNo,This).autoFlat.b.nbi.menu -tearoff 0]
         foreach n $private(nbflat) {
            $m add radiobutton -label "$n" \
               -indicatoron "1" \
               -value "$n" \
               -variable ::acqfcAutoFlat::private(mynbflat) \
               -command {::console::affiche_resultat "$::caption(acqfcAutoFlat,nbFlatDemande) $::acqfcAutoFlat::private(mynbflat)\n" }
         }
         #--- Ligne de saisie
         entry $::panneau(acqfc,$visuNo,This).autoFlat.b.nbival -width 4 -textvariable ::acqfcAutoFlat::private(mynbflat) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b.nbival -side left -fill y

         #--- Carre de mesure de l'intensite pour le calcul du temps de pose
         menubutton $::panneau(acqfc,$visuNo,This).autoFlat.b.sqr -text $::caption(acqfcAutoFlat,mysquare1) -relief raised \
            -menu $::panneau(acqfc,$visuNo,This).autoFlat.b.sqr.menu
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b.sqr -side left
         set m [menu $::panneau(acqfc,$visuNo,This).autoFlat.b.sqr.menu -tearoff 0]
         foreach n $private(square) {
            $m add radiobutton -label "$n" \
               -indicatoron "1" \
               -value "$n" \
               -variable ::acqfcAutoFlat::private(mysquare) \
               -command { ::console::affiche_resultat "$::caption(acqfcAutoFlat,mysquare) $::acqfcAutoFlat::private(mysquare)\n" }
         }
         #--- Ligne de saisie
         entry $::panneau(acqfc,$visuNo,This).autoFlat.b.sqrval -width 4 -textvariable ::acqfcAutoFlat::private(mysquare) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b.sqrval -side left -fill y

      frame $::panneau(acqfc,$visuNo,This).autoFlat.b1 -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.b1 -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top -expand 0 \
         -fill both -padx 3 -pady 0

         #--- Dynamique maxi des flats
         menubutton $::panneau(acqfc,$visuNo,This).autoFlat.b1.menudynflat -text $::caption(acqfcAutoFlat,dynflat) -relief raised \
            -menu $::panneau(acqfc,$visuNo,This).autoFlat.b1.menudynflat.menu
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b1.menudynflat -side left
         set m [menu $::panneau(acqfc,$visuNo,This).autoFlat.b1.menudynflat.menu -tearoff 0]
         foreach n $private(dynamique) {
            $m add radiobutton -label "$n" \
               -indicatoron "1" \
               -value "$n" \
               -variable ::acqfcAutoFlat::private(mydynamique) \
               -command {::console::affiche_resultat "$::caption(acqfcAutoFlat,fondflat1) $::acqfcAutoFlat::private(mydynamique)\n" }
         }
         #--- Ligne de saisie
         entry $::panneau(acqfc,$visuNo,This).autoFlat.b1.entdynflat -width 4 -textvariable ::acqfcAutoFlat::private(mydynamique) \
            -relief groove -justify center \
            -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
         pack $::panneau(acqfc,$visuNo,This).autoFlat.b1.entdynflat -side left -fill y

      frame $::panneau(acqfc,$visuNo,This).autoFlat.a2 -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.a2 -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top -expand 0 \
         -fill both -padx 3 -pady 0

         #--- Obturateur et nombre de pixels
         label $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb1 -text $::caption(acqfcAutoFlat,obturateur) -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb1 -in $::panneau(acqfc,$visuNo,This).autoFlat.a2 -side left -anchor w \
            -padx 4 -pady 4 -expand 0
         label $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb2 -text [$private($visuNo,camera) shutter] -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb2 -in $::panneau(acqfc,$visuNo,This).autoFlat.a2 -side left -anchor w \
            -padx 4 -pady 4 -expand 0
         label $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb3 -text "           $::caption(acqfcAutoFlat,nbPixels)" \
            -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb3 -in $::panneau(acqfc,$visuNo,This).autoFlat.a2 -side left \
            -anchor e -padx 4 -pady 4 -expand 0
         label $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb4 -text $nbpix -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb4 -in $::panneau(acqfc,$visuNo,This).autoFlat.a2 -side left \
            -anchor e -padx 4 -pady 4 -expand 0

      frame $::panneau(acqfc,$visuNo,This).autoFlat.nuit -borderwidth 0 -relief solid
      pack $::panneau(acqfc,$visuNo,This).autoFlat.nuit -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center -side top \
         -expand 0 -fill both -padx 3 -pady 0

         button $::panneau(acqfc,$visuNo,This).autoFlat.nuit.deb -text $::caption(acqfcAutoFlat,butDebutNuit) \
            -command "::acqfcAutoFlat::pushSensNuit $visuNo 0" -bg $::audace(color,disabledTextColor)
         pack $::panneau(acqfc,$visuNo,This).autoFlat.nuit.deb -in $::panneau(acqfc,$visuNo,This).autoFlat.nuit \
            -anchor center -side left -fill x -padx 4 -pady 4 -ipadx 30 -expand 1
         button $::panneau(acqfc,$visuNo,This).autoFlat.nuit.fin -text $::caption(acqfcAutoFlat,butFinNuit) \
            -command "::acqfcAutoFlat::pushSensNuit $visuNo 1" -bg $::audace(color,backColor2)
         pack $::panneau(acqfc,$visuNo,This).autoFlat.nuit.fin -in $::panneau(acqfc,$visuNo,This).autoFlat.nuit \
            -anchor center -side left -fill x -padx 4 -pady 4 -ipadx 30 -expand 1

      frame $::panneau(acqfc,$visuNo,This).autoFlat.goccd -borderwidth 0 -relief solid
      pack $::panneau(acqfc,$visuNo,This).autoFlat.goccd -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor center \
         -side top -expand 0 -fill both -padx 3 -pady 0

         button $::panneau(acqfc,$visuNo,This).autoFlat.goccd.go -text $::caption(acqfcAutoFlat,goFlatsAuto) \
            -command "::acqfcAutoFlat::acqFlat $visuNo" -bg $::audace(color,backColor2)
         pack $::panneau(acqfc,$visuNo,This).autoFlat.goccd.go -in $::panneau(acqfc,$visuNo,This).autoFlat.goccd -anchor center \
            -side top -fill x -padx 4 -pady 4 -expand 1

      frame $::panneau(acqfc,$visuNo,This).autoFlat.f -borderwidth 0 -relief solid
      pack $::panneau(acqfc,$visuNo,This).autoFlat.f -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor s -side top -expand 0 \
         -fill both -padx 3 -pady 0

         button $::panneau(acqfc,$visuNo,This).autoFlat.f.fin -text $::caption(acqfcAutoFlat,stop) \
            -command "::acqfcAutoFlat::arretAcqFlat $visuNo" -bg $::audace(color,backColor2) -state disabled
         pack $::panneau(acqfc,$visuNo,This).autoFlat.f.fin -in $::panneau(acqfc,$visuNo,This).autoFlat.f -anchor center \
            -side top -fill x -padx 4 -pady 4 -expand 1

      frame $::panneau(acqfc,$visuNo,This).autoFlat.h -borderwidth 0 -relief solid
      pack $::panneau(acqfc,$visuNo,This).autoFlat.h -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor s -side top -expand 0 \
         -fill both -padx 3 -pady 0

         button $::panneau(acqfc,$visuNo,This).autoFlat.h.fin -text $::caption(acqfcAutoFlat,fermer) \
            -command "::acqfcAutoFlat::fermerAcqAutoFlat $visuNo" -bg $::audace(color,backColor2)
         pack $::panneau(acqfc,$visuNo,This).autoFlat.h.fin -in $::panneau(acqfc,$visuNo,This).autoFlat.h -anchor center \
            -side top -fill x -padx 4 -pady 4 -expand 1

      frame $::panneau(acqfc,$visuNo,This).autoFlat.g -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.g -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor s -side top \
         -expand 0 -fill both -padx 3 -pady 0

         label $::panneau(acqfc,$visuNo,This).autoFlat.g.sens -text $info_sens_nuit -borderwidth 0 -relief flat
         pack $::panneau(acqfc,$visuNo,This).autoFlat.g.sens -in $::panneau(acqfc,$visuNo,This).autoFlat.g -anchor w \
            -side left -expand 0 -fill both -padx 4 -pady 4

      frame $::panneau(acqfc,$visuNo,This).autoFlat.j -borderwidth 0 -relief ridge
      pack $::panneau(acqfc,$visuNo,This).autoFlat.j -in $::panneau(acqfc,$visuNo,This).autoFlat -anchor s \
         -side top -expand 0 -fill both -padx 3 -pady 0

         checkbutton $::panneau(acqfc,$visuNo,This).autoFlat.j.check -highlightthickness 0 \
            -text $::caption(acqfcAutoFlat,avancement_acq) -variable ::acqfcAutoFlat::private(avancement_acq)
         pack $::panneau(acqfc,$visuNo,This).autoFlat.j.check -in $::panneau(acqfc,$visuNo,This).autoFlat.j -anchor w \
            -side left -expand 0 -fill both -padx 3 -pady 0

      focus $::panneau(acqfc,$visuNo,This).autoFlat

      ::confColor::applyColor $::panneau(acqfc,$visuNo,This).autoFlat
   }

   #------------------------------------------------------------
   # fermerAcqAutoFlat
   #    Ferme la fenetre acqAutoFlat
   #------------------------------------------------------------
   proc fermerAcqAutoFlat { visuNo } {
      variable private

      set ::conf(acqfc,avancement1,position) $private(avancement1,position)
      ::acqfcAutoFlat::recupPositionAcqAutoFlat $visuNo
      destroy $::panneau(acqfc,$visuNo,This).autoFlat
   }

   #------------------------------------------------------------
   # recupPositionAcqAutoFlat
   #    Recupere la position de la fenetre acqAutoFlat
   #------------------------------------------------------------
   proc recupPositionAcqAutoFlat { visuNo } {
      variable private

      set private(geometryAcqAutoFlat) [ wm geometry $::panneau(acqfc,$visuNo,This).autoFlat ]
      set deb [ expr 1 + [ string first + $private(geometryAcqAutoFlat) ] ]
      set fin [ string length $private(geometryAcqAutoFlat) ]
      set ::conf(acqfc,acqAutoFlat,position) "+[string range $private(geometryAcqAutoFlat) $deb $fin]"
   }

   #------------------------------------------------------------
   # acqFlat
   #    Acquisition des flats en automatique
   #------------------------------------------------------------
   proc acqFlat { visuNo } {
      variable private

      set attentems [expr $private(attente) * 1000]

      set nbpix    [$private($visuNo,camera) nbpix]
      set binning  [$private($visuNo,camera) bin]
      set xcent    [expr [lindex $nbpix 0]/2]
      set ycent    [expr [lindex $nbpix 1]/2]
      set xmin     [expr $xcent - $private(mysquare) / 2]
      set ymin     [expr $ycent - $private(mysquare) / 2]
      set xmax     [expr $xcent + $private(mysquare) / 2]
      set ymax     [expr $ycent + $private(mysquare) / 2]
      set fondflat [expr $private(maxdyn) * $private(mydynamique)]

      ::console::affiche_saut "\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,debutAcq)\n"

      ::console::affiche_resultat "$::caption(acqfcAutoFlat,tailleImage) $nbpix\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,binning) $binning\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,nbFlatDemande) $private(mynbflat)\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,tailleFenetre) $private(mysquare)\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,limitexptime) $private(limitexptime)\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,exptimemini) $private(exptimemini)\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,fondflat1) $fondflat\n"

      set buffer buf[ ::confVisu::getBufNo $visuNo ]

      # Dark (obturateur closed)
      set exptime 1
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,mesureDark)\n"
      $private($visuNo,camera) window [list $xmin $ymin $xmax $ymax]
      $private($visuNo,camera) shutter closed
      if [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] {
         $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb2 configure -text [$private($visuNo,camera) shutter]
      }
      #--- Declenchement de l'acquisition
      ::camera::acquisition $private($visuNo,camItem) "::acqfcAutoFlat::attendImage $visuNo" $exptime
      #--- J'attends la fin de l'acquisition
      vwait ::acqfcAutoFlat::private(finAquisition)
      $buffer save "mesurefond"

      set stat  [$buffer stat]
      set dark  [lindex $stat 4]
      set stdev [lindex $stat 5]
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,fluxMoyen) $dark\n"
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,ecartType) $stdev\n"

      # Image (obturateur synchro)
      $private($visuNo,camera) shutter synchro
      if [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] {
         $::panneau(acqfc,$visuNo,This).autoFlat.a2.lb2 configure -text [$private($visuNo,camera) shutter]
      }

      # Boucle sur les images
      set num 1

      # Initialisation a 1 pour le premier flat
      set private(numeroFlat) 1

      for {set id 0} {$id<$private(mynbflat)} {incr id} {

         #--- Initialisation d'une variable
         set private(finAquisition) ""

         #--- Pose en cours
         set private(pose_en_cours) 1

         set exptime 1

         if {$private(testprog) == 0} {

            while {$exptime > 0} {

               # Fond du ciel
               set exptime 1
               ::console::affiche_resultat "$::caption(acqfcAutoFlat,mesureCiel)\n"
               $private($visuNo,camera) window [list $xmin $ymin $xmax $ymax]
               #--- Declenchement de l'acquisition
               ::camera::acquisition $private($visuNo,camItem) "::acqfcAutoFlat::attendImage $visuNo" $exptime
               #--- J'attends la fin de l'acquisition
               vwait ::acqfcAutoFlat::private(finAquisition)
               $buffer save "mesurefond"

               set stat  [$buffer stat]
               set ciel  [lindex $stat 4]
               set stdev [lindex $stat 5]
               ::console::affiche_resultat "$::caption(acqfcAutoFlat,fluxMoyen) $ciel\n"
               ::console::affiche_resultat "$::caption(acqfcAutoFlat,ecartType) $stdev\n"

               if {[expr $ciel+$stdev]<$private(maxdyn)} {

                  #--- image non saturee
                  set exptime [expr $fondflat/($ciel - $dark)]
                  if {$exptime<0} {
                     ::console::affiche_resultat "\n\n$::caption(acqfcAutoFlat,probleme)\n"
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,verification)\n"
                     exit
                  }

                  #--- comparaison du temps d'exposition avec les limites mini et maxi
                  if { $exptime > $private(limitexptime) } {
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,estimationExptime)\n"
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,mini) $private(exptimemini) < $::caption(acqfcAutoFlat,maxi) $private(limitexptime) < $exptime\n"
                  } elseif { $exptime > $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,estimationExptime)\n"
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,mini) $private(exptimemini) < $exptime < $::caption(acqfcAutoFlat,maxi) $private(limitexptime)\n"
                  } elseif { $exptime < $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,estimationExptime)\n"
                     ::console::affiche_resultat "$exptime < $::caption(acqfcAutoFlat,mini) $private(exptimemini) < $::caption(acqfcAutoFlat,maxi) $private(limitexptime)\n"
                  }

                  #--- comparaison du temps d'exposition avec les limites mini et maxi
                  if {$exptime>$private(limitexptime)} {
                     set exptime $private(limitexptime)
                     if {$private(sensnuit) == 1} {
                        #--- On fait les flats en fin de nuit
                        #--- il fait trop nuit, donc on attend
                        ::console::affiche_resultat "$::caption(acqfcAutoFlat,tropNuit) $private(attente) $::caption(acqfcAutoFlat,secondes)\n"
                        after $attentems
                     } else {
                        #--- On fait les flats en debut de nuit
                        #--- il fait trop nuit, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(acqfcAutoFlat,tropTard1)\n\n"
                        #--- Pose en cours
                        set private(pose_en_cours) 0
                        return
                     }
                  } elseif {$exptime<$private(exptimemini)} {
                     if {$private(sensnuit) == 1} {
                        #--- On fait les flats en fin de nuit
                        #--- il fait trop jour, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(acqfcAutoFlat,tropTard2)\n\n"
                        #--- Pose en cours
                        set private(pose_en_cours) 0
                        return
                     } else {
                        #--- On fait les flats en debut de nuit
                        #--- il fait trop jour, donc on attend
                        ::console::affiche_resultat "$::caption(acqfcAutoFlat,tropJour) $private(attente) $::caption(acqfcAutoFlat,secondes)\n"
                        after $attentems
                     }
                  } else {
                     #--- image non saturee et temps d'exposition limite non atteint -> OK on y va
                     break
                  }

               } else {

                  #--- Saturation on divise le temps d'exposition par 3
                  set exptime [expr $exptime / 3.]

                  #--- comparaison du temps d'exposition avec les limites mini et maxi
                  if { $exptime > $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,estimationExptime)\n"
                     ::console::affiche_resultat "$exptime > $::caption(acqfcAutoFlat,mini) $private(exptimemini)\n"
                  } elseif { $exptime < $private(exptimemini) } {
                     ::console::affiche_resultat "$::caption(acqfcAutoFlat,estimationExptime)\n"
                     ::console::affiche_resultat "$exptime < $::caption(acqfcAutoFlat,mini) $private(exptimemini)\n"
                  }

                  #--- si le temps d'exposition est trop court
                  if {$exptime<$private(exptimemini)} {
                     if {$private(sensnuit) == 0} {
                        #--- On fait les flats en debut de nuit
                        #--- il fait trop jour, donc on attend
                        set exptime $private(exptimemini)
                        ::console::affiche_resultat "$::caption(acqfcAutoFlat,tropJour) $private(attente) $::caption(acqfcAutoFlat,secondes)\n"
                        after $attentems
                     } else {
                        #--- On fait les flats en fin de nuit
                        #--- il fait trop jour, donc c'est foutu
                        ::console::affiche_resultat "\n\n$::caption(acqfcAutoFlat,tropTard2)\n\n"
                        #--- Pose en cours
                        set private(pose_en_cours) 0
                        return
                     }
                  }

               }

            }

         }

         # Comptage des flats
         ::acqfcAutoFlat::majBouton $visuNo 0

         #--- Bouton Stop Auto Flats actif
         if [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] {
            $::panneau(acqfc,$visuNo,This).autoFlat.f.fin configure -state normal
         }

         # Flat :
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,parti) ([expr $id+1]/$private(mynbflat))\n"
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,prochainExptime) $exptime $::caption(acqfcAutoFlat,secondes)\n"
         $private($visuNo,camera) window [list 1 1 [lindex $private(nbcells) 0] [lindex $private(nbcells) 1] ]
         $private($visuNo,camera) shutter synchro
         #--- Declenchement de l'acquisition
         ::camera::acquisition $private($visuNo,camItem) "::acqfcAutoFlat::attendImage $visuNo" $exptime
         #--- Je lance la boucle d'affichage de l'avancement
         after 10 ::acqfcAutoFlat::dispTime $visuNo $exptime
         #--- J'attends la fin de l'acquisition
         vwait ::acqfcAutoFlat::private(finAquisition)

         set stat   [$buffer stat]
         set pixmin [lindex $stat 3]
         set pixmax [lindex $stat 2]
         set ciel   [lindex $stat 4]
         set stdev  [lindex $stat 5]
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,mesureFlat)\n"
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,fluxMoyen) $ciel\n"
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,ecartType) $stdev\n"
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,pixelMiniMaxi) $pixmax / $pixmin\n"

         set nouv   [expr $ciel / $private(maxdyn)]
         set offset [expr $private(mydynamique) - ($ciel / $private(maxdyn))]

         ::console::affiche_resultat "$::caption(acqfcAutoFlat,offset) $offset\n"
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,nouv) $nouv\n"
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,maxdyn) $private(maxdyn)\n"
         set fondflat [expr $private(maxdyn) * ($fondflat/$private(maxdyn) + $offset)]
         ::console::affiche_resultat "$::caption(acqfcAutoFlat,fondflat2) $fondflat\n"

         set enr 0
         while {$enr == 0} {
            set entete [ mc_date2ymdhms [ ::audace::date_sys2ut now] ]
            set pos  [string first "." [lindex $entete 5]]
            set sec  [string range [lindex $entete 5] 0 [expr $pos-1]]
            set date [ format "%04d%02d%02dT%02d%02d%02d" [lindex $entete 0] [lindex $entete 1] [lindex $entete 2] [lindex $entete 3] [lindex $entete 4] $sec]
            set file [ file join $private(rep_images) "MASTER_${date}_FLAT_$private(mybin)_$num" ]
            if {$private(testprog) == 1} {set file [ file join $private(rep_images) "$entete.TEST_FLAT_$num" ]}
            set filelong "$file$::conf(extension,defaut)"
            if {[file exists $filelong]==0} {
               #--- Rajoute des mots cles dans l'en-tete FITS
               foreach keyword [ ::keyword::getKeywords $visuNo $::conf(acqfc,keywordConfigName) ] {
                  $buffer setkwd $keyword
               }
               #--- Rajoute d'autres mots cles
               $buffer setkwd [list "IMAGETYP" "Flat" string "Image type" "" ]
               $buffer setkwd [list "OBJNAME"  "FLAT" string "" "" ]
               saveima $filelong $visuNo
               ::console::affiche_resultat "$::caption(acqfcAutoFlat,enregistre) $filelong\n"
               set enr 1
               incr num
            } else {
               incr num
            }
         }

         if {$num>$private(mynbflat)} {set num $private(mynbflat)}
         set private(numeroFlat) $num

         #--- Bouton Stop Auto Flats inactif
         if [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] {
            $::panneau(acqfc,$visuNo,This).autoFlat.f.fin configure -state disabled
         }

         #--- Pose en cours
         set private(pose_en_cours) 0

         #--- Effacement de la barre de progression quand la pose est terminee
         ::acqfcAutoFlat::avancementPose $visuNo -1

         #--- Arret de la pose et de la serie
         if {$private(demande_stop) == 1} {
            ::console::affiche_resultat "$::caption(acqfcAutoFlat,arretDemande)\n"
            break
         }

      }

      #--- Je positionne l'indicateur d'arret de la pose
      set private(demande_stop) 0

      ::acqfcAutoFlat::majBouton $visuNo 1
      ::console::affiche_resultat "$::caption(acqfcAutoFlat,finAcq)\n\n"
   }

   #------------------------------------------------------------
   # attendImage
   #    Controle de la thread d'acquisition
   #------------------------------------------------------------
   proc attendImage { visuNo message args } {
      variable private

      switch $message {
         "autovisu" {
            #--- ce message signale que l'image est prete dans le buffer
            #--- on peut l'afficher sans attendre la fin complete de la thread de la camera
            ::confVisu::autovisu $visuNo
         }
         "acquisitionResult" {
            #--- ce message signale que la thread de la camera a termine completement l'acquisition
            #--- je peux traiter l'image
            set private(finAquisition) "acquisitionResult"
         }
         "error" {
            #--- ce message signale qu'une erreur est survenue dans la thread de la camera
            #--- j'affiche l'erreur dans la console
            ::console::affiche_erreur "acqfcAutoFlat::acqFlat error: $args\n"
            set private(finAquisition) "error"
         }
      }
   }

   #------------------------------------------------------------
   # dispTime
   #    Timer de l'exposition
   #------------------------------------------------------------
   proc dispTime { visuNo exptime } {
      variable private

      #--- j'arrete le timer s'il est deja lance
      if { [ info exists private(dispTimeAfterId) ] && $private(dispTimeAfterId)!="" } {
         after cancel $private(dispTimeAfterId)
         set private(dispTimeAfterId) ""
      }

      set private(exptime) $exptime

      set t [ $private($visuNo,camera) timer -1 ]
      #--- je mets a jour le status
      if { $private(pose_en_cours) == 0 } {
         #--- je supprime la fenetre s'il n'y a plus de pose en cours
         set status ""
      } else {
         if { $private(demande_stop) == "0" } {
            if { [expr $t > 0] } {
               set status "[ expr $t ] / [ format "%d" [ expr int($exptime) ] ]"
            } else {
               set status "$::caption(acqfcAutoFlat,lecture)"
            }
         } else {
            set status "$::caption(acqfcAutoFlat,lecture)"
         }
      }
      update

      #--- je mets a jour la fenetre de progression
      ::acqfcAutoFlat::avancementPose $visuNo $t

      if { $t > 0 } {
         #--- je lance l'iteration suivante avec un delai de 1000 millisecondes
         #--- (mode asynchone pour eviter l'empilement des appels recursifs)
         set private(dispTimeAfterId) [ after 1000 ::acqfcAutoFlat::dispTime $visuNo $exptime ]
      } else {
         #--- je ne relance pas le timer
         set private(dispTimeAfterId) ""
      }
   }

   #------------------------------------------------------------
   # avancementPose
   #    Fenetre pour l'avancement de la pose
   #------------------------------------------------------------
   proc avancementPose { visuNo { t } } {
      variable private

      if { $private(avancement_acq) != "1" } {
         return
      }

      #--- Recuperation de la position de la fenetre
      ::acqfcAutoFlat::recupPositionAvancement $visuNo

      #--- Initialisation de la barre de progression
      set cpt "100"

      #---
      if { [ winfo exists $::audace(base).progress ] != "1" } {

         #--- Cree la fenetre toplevel
         toplevel $::audace(base).progress
         if [ winfo exists $::panneau(acqfc,$visuNo,This).autoFlat ] {
            wm transient $::audace(base).progress $::panneau(acqfc,$visuNo,This).autoFlat
         }
         wm resizable $::audace(base).progress 0 0
         wm title $::audace(base).progress "$::caption(acqfcAutoFlat,en_cours)"
         wm geometry $::audace(base).progress $private(avancement1,position)

         #--- Cree le widget et le label du temps ecoule
         label $::audace(base).progress.lab_status -text "" -justify center
         pack $::audace(base).progress.lab_status -side top -fill x -expand true -pady 5

         #---
         if { $private(demande_stop) == "1" } {
            $::audace(base).progress.lab_status configure -text $::caption(acqfcAutoFlat,lecture)
         } else {
            if { $t < 0 } {
               destroy $::audace(base).progress
            } elseif { $t > 0 } {
               $::audace(base).progress.lab_status configure -text "$t $::caption(acqfcAutoFlat,sec) /\
                  [ format "%d" [ expr int( $private(exptime) ) ] ] $::caption(acqfcAutoFlat,sec)"
               set cpt [ expr $t * 100 / int( $private(exptime) ) ]
               set cpt [ expr 100 - $cpt ]
            } else {
               $::audace(base).progress.lab_status configure -text "$::caption(acqfcAutoFlat,lecture)"
           }
         }

         catch {
            #--- Cree le widget pour la barre de progression
            frame $::audace(base).progress.cadre -width 200 -height 30 -borderwidth 2 -relief groove
            pack $::audace(base).progress.cadre -in $::audace(base).progress -side top \
               -anchor center -fill x -expand true -padx 8 -pady 8

            #--- Affiche de la barre de progression
            frame $::audace(base).progress.cadre.barre_color_invariant -height 26 -bg $::color(blue)
            place $::audace(base).progress.cadre.barre_color_invariant -in $::audace(base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }

         #--- Mise a jour dynamique des couleurs
         if { [ winfo exists $::audace(base).progress ] == "1" } {
            ::confColor::applyColor $::audace(base).progress
         }

      } else {

         if { $private(pose_en_cours) == 0 } {
            #--- je supprime la fenetre s'il n'y a plus de pose en cours
            destroy $::audace(base).progress
         } else {
            if { $private(demande_stop) == "0" } {
               if { $t > 0 } {
                  $::audace(base).progress.lab_status configure -text "[ expr $t ] $::caption(acqfcAutoFlat,sec) /\
                     [ format "%d" [ expr int( $private(exptime) ) ] ] $::caption(acqfcAutoFlat,sec)"
                  set cpt [ expr $t * 100 / int( $private(exptime) ) ]
                 set cpt [ expr 100 - $cpt ]
               } else {
                  $::audace(base).progress.lab_status configure -text "$::caption(acqfcAutoFlat,lecture)"
               }
            } else {
               #--- j'affiche "lecture" des qu'une demande d'arret est demandee
               $::audace(base).progress.lab_status configure -text "$::caption(acqfcAutoFlat,lecture)"
            }
            #--- Met a jour la barre de progression
            place $::audace(base).progress.cadre.barre_color_invariant -in $::audace(base).progress.cadre -x 0 -y 0 \
               -relwidth [ expr $cpt / 100.0 ]
            update
         }

      }

   }

   #------------------------------------------------------------
   # recupPositionAvancement
   #    Recupere la position de la fenetre d'avancement de la pose
   #------------------------------------------------------------
   proc recupPositionAvancement { visuNo } {
      variable private

      if [ winfo exists $::audace(base).progress ] {
         #--- Determination de la position de la fenetre
         set geometry [ wm geometry $::audace(base).progress ]
         set deb [ expr 1 + [ string first + $geometry ] ]
         set fin [ string length $geometry ]
         set private(avancement1,position) "+[ string range $geometry $deb $fin ]"
      }
   }

}


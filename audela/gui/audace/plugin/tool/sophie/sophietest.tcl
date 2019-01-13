#
## @file     sophietest.tcl
#  @brief    Fichier du namespace ::sophie::test
#  @author   Michel PUJOL et Robert DELMAS
#  $Id: sophietest.tcl 13349 2016-03-11 14:45:52Z rzachantke $
#

#-----------------------------------------------------------
## @brief Procédures de test de l'outil sophie et simulation des interfaces externes
#
namespace eval ::sophie::test {
   variable private
   set private(telescopeControl,commandSocket)   ""
   set private(telescopeControl,dataSocket)      ""
   set private(controlThreadId)                  ""
   set private(telescopeControl,ra)              ""
   set private(telescopeControl,dec)             ""
   set private(telescopeControl,raSpeed)         ""
   set private(telescopeControl,decSpeed)        ""
   set private(telescopeControl,slewMode)        ""
   set private(telescopeControl,sideralSpeed)    "15.0"   ; #--- vitesse de 360 degres/jour soit 15 arsec/seconde vers l'ouest
   set private(telescopeControl,lunarSpeed)      "14.375" ; #--- vitesse de (360-15) degrés/jour soit 14.375 arsec/seconde vers l'ouest
   set private(telescopeControl,guidingSpeed)    "3.75"   ; #--- vitesse de correction en centrage (le triple de la vitesse siderale)
   set private(telescopeControl,centeringSpeed)  "45.0"   ; #--- vitesse de correction en guidage (le quart de la vitesse siderale en arcsec/s
   set private(telescopeControl,centering2Speed) "60.0"   ; #--- vitesse de correction en guidage (le quart de la vitesse siderale en arcsec/s
   set private(telescopeControl,gotoSpeed)       "6500.0" ; #--- vitesse de goto (500 fois la vitesse siderale en arcsec/s
   set private(telescopeControl,focusPosition)   "0.0"
   set private(telescopeControl,focusSpeed)      "0"
   set private(clientCoord,socketChannel)        ""

}

#------------------------------------------------------------
# simulHp
#    teste l'envoi des coordonnees toutes les secondes
#------------------------------------------------------------
proc ::sophie::test::simulHp { } {
   variable private

   set private(testhp) 0

   set private(dataNo) 0
   set private(data,0) "02h 06m 47.87s / -13d 44' 28\" / -1d "
   set private(data,1) "02h 07m 47.87s / -00d 44' 28\" / -1d "
   set private(data,2) "02h 08m 47.87s / +10d 44' 28\" / -1d "
   set private(data,2) "02h 08m 47.87s /-310d 44' 28\" / -1d "

   # je lance l'envoi permanent des coordonnees sur le port COM
   set private(writeHpHandle) [open COM7 "r+" ]
   fconfigure $private(writeHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0
console::disp "simulHp writeHpHandle=$private(writeHpHandle)\n"
   # j'ouvre le port de reception des coordonnees
   ###set private(readHpHandle) [open COM8 "r+" ]
   ###fconfigure $private(readHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0

   set private(testhp) 1
   after 3000 ::sophie::test::testWriteHp
   ###after 1500 ::sophie::test::testReadHp

}

#------------------------------------------------------------
# stophp
#    arrete l'envoi des coordonnees
#------------------------------------------------------------
proc ::sophie::test::stopHp { } {
   variable private

   set private(testhp) 0

   if { $private(writeHpHandle) != "" } {
      close $private(writeHpHandle)
      set private(writeHpHandle) ""
   }

  #if { $private(readHpHandle) != "" } {
  #    close $private(readHpHandle)
  #    set private(readHpHandle) ""
  # }

}

#------------------------------------------------------------
# testWriteHp
#    envoie les coordonnees toutes les secondes
#------------------------------------------------------------
proc ::sophie::test::testWriteHp { } {
   variable private

   set data  $private(data,$private(dataNo))
   if { $private(dataNo) < "2" } {
      incr  private(dataNo)
   } else {
      set private(dataNo) 0
   }

   if { $private(testhp) == 1 } {
      puts  $private(writeHpHandle) $data
console::disp "testWriteHp data=$data\n"
     after 5000 ::sophie::test::testWriteHp
   } else {
     if { $private(writeHpHandle) != "" } {
         close $private(writeHpHandle)
         set private(writeHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# testReadCom
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::test::testReadCom { } {
   variable private

   if { $private(testhp) == 1 } {
      set data [read -nonewline $private(readHpHandle)]
      set data [split $data "\n" ]
      set messageNb [llength $data]
      console::disp "\ntestReadHp nb=$messageNb data=$data\n"
      after 3000 ::sophie::test::testReadHp
   } else {
     if { $private(readHpHandle) != "" } {
         close $private(readHpHandle)
         set private(readHpHandle) ""
      }
   }
}

#------------------------------------------------------------
# startReadHp
#    lance la lecture sur le port COM1
#------------------------------------------------------------
proc ::sophie::test::startReadHp { } {
   variable private

   # j'ouvre le port de reception des coordonnees
   set private(readHpHandle) [open COM1 "r+" ]
   fconfigure $private(readHpHandle) -mode "19200,n,8,1" -buffering none -blocking 0
   console::disp "startReadHp  private(readHpHandle)=$private(readHpHandle)\n"
   set private(testhp) 1
   ::sophie::test::testReadHp
}

#------------------------------------------------------------
# stopReadHp
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::test::stopReadHp { } {
   variable private

   set private(testhp) 0

}

#------------------------------------------------------------
# testReadHp
#    lit les coordonnees toutes les 3 secondes
#------------------------------------------------------------
proc ::sophie::test::testReadHp { } {
   variable private

   if { $private(testhp) == 1 } {
      set data [read -nonewline $private(readHpHandle)]
      set data [split $data "\n" ]
      set messageNb [llength $data]
      set data [lindex $data end]
      if { $data != "" } {
         set nbVar [scan $data "%dh %dm %fs / %dd %d' %d'' / %dd" ah am as dd dm ds ba]
         if { $nbVar == 7 } {
            ##set alpha "${ah}h${am}m${as}s"
            set alpha [format "%02dh%02dm%05.2fs" $ah $am $as]
            set delta "${dd}h${dm}m${ds}s"
            console::disp "testReadHp nb=$messageNb data=$data  alpha=$alpha delta=$delta\n"
         } else {
            console::affiche_erreur  "testReadHp nb=$messageNb data=$data nbVar=$nbVar\n"
         }
      } else {
         console::disp "testReadHp nb=$messageNb data=$data\n"
      }
      after 2000 ::sophie::test::testReadHp
   } else {
     if { $private(readHpHandle) != "" } {
         close $private(readHpHandle)
         set private(readHpHandle) ""
      }
   }
}

#============================================================
#
# tests de la fenetre de controle
#
#============================================================

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tc1 { } {
   ### starDetection fiberDetection originX originY starX starY fwhmX fwhmY background maxFlow
   ::sophie::control::setCenterInformation 1 1 750 512 752 514 45 46 100 10000
}

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tsim0 { }  {
   set ::conf(sophie,simulation) 0
   set ::conf(sophie,simulationGenericFileName) "C:/Documents and Settings/michel/Mes documents/astronomie/test/OHP/simulation/centrage_"
   ::console::disp "pas de simulation\n"
}

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tsim1 { }  {
   set ::conf(sophie,simulation) 1
   set ::conf(sophie,simulationGenericFileName) "$::audace(rep_images)/test/OHP/simulation/centrage_"
   ::console::disp "simulation fichiers centrage_*\n"
}

##------------------------------------------------------------
# tests de la fenetre de controle
#------------------------------------------------------------
proc ::sophie::test::tsim2 { }  {
   set ::conf(sophie,simulation) 1
   set ::conf(sophie,simulationGenericFileName) "$::audace(rep_images)/test/OHP/simulation/simuFWHM10px_fibre_"
   ::console::disp "simulation fichiers simuFWHM10px_fibre_*\n"
}

###### Fenetre de configuration de la simulation ######

#------------------------------------------------------------
# simul
#    Creation de la fenetre de configuration de la simulation
#------------------------------------------------------------
proc ::sophie::simul { } {

   ::sophie::test::createDialogSimul
}

#------------------------------------------------------------
# ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour
#    appliquer la configuration et fermer la fenetre
#------------------------------------------------------------
proc ::sophie::test::ok { } {
   variable private

   set ::conf(sophie,simulation)                $private(simulation)
   set ::conf(sophie,simulationGenericFileName) $private(simulationGenericFileName)

   if { $::conf(sophie,simulation) == 1 } {
      ::camera::setParam $::sophie::private(camItem) "simulation" 1
      ::camera::setParam $::sophie::private(camItem) "simulationGenericFileName" $::conf(sophie,simulationGenericFileName)
   } else {
      ::camera::setParam $::sophie::private(camItem) "simulation" 0
   }
   ::sophie::test::fermer
}

#------------------------------------------------------------
# fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer' pour
#    fermer la fenetre
#------------------------------------------------------------
proc ::sophie::test::fermer { } {
   variable private

   #--- je referme la socket du pc de guidage
   ::sophie::test::closeSocketSophie
   set private(geometry) [ wm geometry $private(frm) ]
   set ::conf(sophie,simulation,geometry) $private(geometry)
   destroy $private(frm)
}

#------------------------------------------------------------
# createDialogSimul
#    Creation de l'interface graphique
#------------------------------------------------------------
proc ::sophie::test::createDialogSimul { } {
   variable private

   if { ! [ info exists ::conf(sophie,simulation,geometry) ] } { set ::conf(sophie,simulation,geometry) "540x650+30+30" }

   #--- j'initialise les variables
   set private(host) "localhost"
   set private(pcSophie,socketChannel) ""
   set private(telescopeControl,host) "localhost"
   set private(frm) $::audace(base).configSimul

   set private(sendPulse,enabled) "0"
   set private(sendPulse,pulseDelay) "0.05"
   set private(sendPulse,waitDelay)  "2"
   set private(sendPulse,direction)  "w"

   set frm $private(frm)
   if { [ winfo exists $frm ] } {
      wm withdraw $frm
      wm deiconify $frm
      focus $frm
      return
   }

   #--- Creation de la fenetre $frm de niveau le plus haut
   toplevel $frm -class Toplevel
   wm title $frm $::caption(sophie,simulation)
   wm geometry $frm $::conf(sophie,simulation,geometry)
   wm resizable $frm 1 1
   wm protocol $frm WM_DELETE_WINDOW ::sophie::test::fermer

   #--- On utilise les valeurs contenues dans le tableau conf pour l'initialisation
   set private(simulation)                $::conf(sophie,simulation)
   set private(simulationGenericFileName) $::conf(sophie,simulationGenericFileName)

   #--- Frame pour la simulation des acquisitions
   TitleFrame $frm.simulAcquisition -borderwidth 2 -relief groove -text $::caption(sophie,simulAcquisition)

      #--- Frame pour la simulation
      frame $frm.simulAcquisition.check -borderwidth 0 -relief raised

         #--- Activation ou non de la simulation
         checkbutton $frm.simulAcquisition.check.simul -text $::caption(sophie,modeSimulation) \
            -highlightthickness 0 -variable ::sophie::test::private(simulation)
         pack $frm.simulAcquisition.check.simul -anchor center -side left -padx 5 -pady 5

      pack $frm.simulAcquisition.check -in [ $frm.simulAcquisition getframe ] \
         -side top -fill both -expand 1

      #--- Frame pour les fichiers de simulation
      frame $frm.simulAcquisition.filename -borderwidth 0 -relief raised

         #--- Label
         label $frm.simulAcquisition.filename.label -text $::caption(sophie,simulGenericFileName)
         pack $frm.simulAcquisition.filename.label -anchor center -side left -padx 5 -pady 5

         #--- Entry pour le nom generique des images de simulation
         entry $frm.simulAcquisition.filename.entry -textvariable ::sophie::test::private(simulationGenericFileName) \
            -width 25 -justify left
         pack $frm.simulAcquisition.filename.entry -anchor center -side left -padx 5 -pady 5

         #--- Bouton 'Parcourir'
         button $frm.simulAcquisition.filename.butParcourir -text $::caption(sophie,parcourir) \
            -borderwidth 2 -command "::sophie::test::simulationGenericFileName"
         pack $frm.simulAcquisition.filename.butParcourir -anchor center -side left -padx 5 -pady 5

      pack $frm.simulAcquisition.filename -in [ $frm.simulAcquisition getframe ] \
         -side top -fill both -expand 1

   pack $frm.simulAcquisition -side top -fill x -expand 0

   #--- Frame pour l'interface avec le PC Sophie
   TitleFrame $frm.pcsophie -borderwidth 2 -relief groove -text $::caption(sophie,simulPCSophie)

      #--- host
      label $frm.pcsophie.hostLabel -text $::caption(sophie,host)
      grid $frm.pcsophie.hostLabel -in [ $frm.pcsophie getframe ] -row 0 -column 0 -sticky ens -padx 2
      entry $frm.pcsophie.hostEntry -textvariable ::sophie::test::private(host)
      grid $frm.pcsophie.hostEntry -in [ $frm.pcsophie getframe ] -row 0 -column 1 -sticky ens -padx 2

      #--- Bouton connect et disconnect
      button $frm.pcsophie.connect -text "Démarrer serveur" -command "::sophie::test::connecterPcGuidage"
      grid $frm.pcsophie.connect -in [ $frm.pcsophie getframe ] -row 0 -column 2 -sticky ens -padx 2

      #--- Bouton envoi de commande
      button $frm.pcsophie.clearstat -text "RAZ STAT" -command [list ::sophie::test::sendPcGuidage "RAZ_STAT" ]
      grid $frm.pcsophie.clearstat -in [ $frm.pcsophie getframe ] -row 0 -column 3 -sticky ens -padx 2

      button $frm.pcsophie.staton -text "STAT ON" -command [list ::sophie::test::sendPcGuidage "STAT_ON" ]
      grid $frm.pcsophie.staton -in [ $frm.pcsophie getframe ] -row 1 -column 3 -sticky ens -padx 2

      button $frm.pcsophie.statoff -text "STAT OFF" -command [list ::sophie::test::sendPcGuidage "STAT_OFF" ]
      grid $frm.pcsophie.statoff -in [ $frm.pcsophie getframe ] -row 2 -column 3 -sticky ens -padx 2

      button $frm.pcsophie.getstat -text "GET STAT" -command [list ::sophie::test::sendPcGuidage "GET_STAT" ]
      grid $frm.pcsophie.getstat -in [ $frm.pcsophie getframe ] -row 3 -column 3 -sticky ens -padx 2

      grid columnconfigure [$frm.pcsophie getframe] 0 -weight 1
      grid columnconfigure [$frm.pcsophie getframe] 1 -weight 1
      grid columnconfigure [$frm.pcsophie getframe] 2 -weight 1
      grid columnconfigure [$frm.pcsophie getframe] 3 -weight 1

   pack $frm.pcsophie -in $frm -side top -fill x -expand 0

   #--- Frame pour le test d'impulsion vers le telescope
   TitleFrame $frm.pulse -borderwidth 2 -relief groove -text $::caption(sophie,testImpulsion)

      #--- duree impulsion
      label $frm.pulse.labelPulseDelay -text $::caption(sophie,dureeImpulsion)
      grid $frm.pulse.labelPulseDelay -in [ $frm.pulse getframe ] -row 0 -column 0 -sticky ens -padx 2
      entry $frm.pulse.entryPulseDelay -textvariable ::sophie::test::private(sendPulse,pulseDelay)
      grid $frm.pulse.entryPulseDelay -in [ $frm.pulse getframe ] -row 0 -column 1 -sticky ens -padx 2

      #--- duree attente
      label $frm.pulse.labelWaitDelay -text $::caption(sophie,dureeEntreImpulsion)
      grid $frm.pulse.labelWaitDelay -in [ $frm.pulse getframe ] -row 1 -column 0 -sticky ens -padx 2
      entry $frm.pulse.entryWaitPulse -textvariable ::sophie::test::private(sendPulse,waitDelay)
      grid $frm.pulse.entryWaitPulse -in [ $frm.pulse getframe ] -row 1 -column 1 -sticky ens -padx 2

       #--- direction
      label $frm.pulse.labelDirection -text $::caption(sophie,direction)
      grid $frm.pulse.labelDirection -in [ $frm.pulse getframe ] -row 2 -column 0 -sticky ens -padx 2
      entry $frm.pulse.entryDirection -textvariable ::sophie::test::private(sendPulse,direction)
      grid $frm.pulse.entryDirection -in [ $frm.pulse getframe ] -row 2 -column 1 -sticky ens -padx 2

      #--- Bouton connect et disconnect
      button $frm.pulse.start -text $::caption(sophie,start) -command "after 10 ::sophie::test::startPulse"
      grid $frm.pulse.start -in [ $frm.pulse getframe ] -row 3 -column 0 -sticky ens -padx 2
      button $frm.pulse.stop -text $::caption(sophie,stop) -command "::sophie::test::stopPulse"
      grid $frm.pulse.stop -in [ $frm.pulse getframe ] -row 3 -column 1 -sticky ens -padx 2

      grid columnconfigure [$frm.pulse getframe] 0 -weight 1
      grid columnconfigure [$frm.pulse getframe] 1 -weight 1

   pack $frm.pulse -in $frm -side top -fill x -expand 0

   #--- Frame pour l'interface de controle du T193
   TitleFrame $frm.pccontrol -borderwidth 2 -relief groove -text $::caption(sophie,simul,telescopeControl,title)

      #--- Bouton connect et disconnect
      button $frm.pccontrol.connect -text "Demarrer le simulateur de l'interface de controle" -command "::sophie::test::connectTelescopeControl"
      grid $frm.pccontrol.connect -in [$frm.pccontrol getframe] -row 0 -column 0 -columnspan 4 -sticky "" -padx 2

      #--- affiche les positions et les vitesses  Ra Dec
      label $frm.pccontrol.labelRA -text "RA position"
      grid $frm.pccontrol.labelRA -in [$frm.pccontrol getframe] -row 1 -column 0 -sticky w -padx 0
      label $frm.pccontrol.entryRA   -textvariable ::sophie::test::private(telescopeControl,ra) -relief  ridge
      grid $frm.pccontrol.entryRA -in [$frm.pccontrol getframe] -row 1 -column 1 -sticky ew -padx 2

      label $frm.pccontrol.labelRaSpeed -text "Vitesse (arsec/sec)"
      grid $frm.pccontrol.labelRaSpeed -in [$frm.pccontrol getframe] -row 1 -column 2 -sticky w -padx 0
      label $frm.pccontrol.entryRaSpeed   -textvariable ::sophie::test::private(telescopeControl,raSpeed) -relief  ridge
      grid $frm.pccontrol.entryRaSpeed -in [$frm.pccontrol getframe] -row 1 -column 3 -sticky ew -padx 2

      label $frm.pccontrol.labelDec -text "DEC position"
      grid $frm.pccontrol.labelDec -in [$frm.pccontrol getframe] -row 2 -column 0 -sticky w -padx 0
      label $frm.pccontrol.entryDec   -textvariable ::sophie::test::private(telescopeControl,dec) -relief  ridge
      grid $frm.pccontrol.entryDec -in [$frm.pccontrol getframe] -row 2 -column 1 -sticky ew -padx 2

      label $frm.pccontrol.labelDecSpeed -text "Vitesse (arsec/sec)"
      grid $frm.pccontrol.labelDecSpeed -in [$frm.pccontrol getframe] -row 2 -column 2 -sticky w -padx 0
      label $frm.pccontrol.entryDecSpeed   -textvariable ::sophie::test::private(telescopeControl,decSpeed) -relief  ridge
      grid $frm.pccontrol.entryDecSpeed -in [$frm.pccontrol getframe] -row 2 -column 3 -sticky ew -padx 2

      #--- affiche le mode de suivi
      label $frm.pccontrol.labelSlewMode -text "Suivi Mode"
      grid $frm.pccontrol.labelSlewMode -in [$frm.pccontrol getframe] -row 3 -column 0 -sticky w -padx 0
      label $frm.pccontrol.entrySlewMode   -textvariable ::sophie::test::private(telescopeControl,slewMode) -relief  ridge
      grid $frm.pccontrol.entrySlewMode -in [$frm.pccontrol getframe] -row 3 -column 1 -sticky ew -padx 2

      #--- configuration
      label $frm.pccontrol.labelConfiguration -text "Configuration des vitesses (arsec/sec)"
      grid $frm.pccontrol.labelConfiguration -in [$frm.pccontrol getframe] -row 4 -column 0 -columnspan 4 -sticky w -padx 0

      label $frm.pccontrol.labelGuidingSpeed -text "Vitesse guidage" -justify left
      grid $frm.pccontrol.labelGuidingSpeed -in [$frm.pccontrol getframe] -row 5 -column 0 -sticky w -padx 0
      entry $frm.pccontrol.entryGuidingSpeed -textvariable ::sophie::test::private(telescopeControl,guidingSpeed)
      grid $frm.pccontrol.entryGuidingSpeed -in [$frm.pccontrol getframe] -row 5 -column 1 -sticky w -padx 2

      label $frm.pccontrol.labelCenteringSpeed -text "Vitesse centrage" -justify left
      grid $frm.pccontrol.labelCenteringSpeed -in [$frm.pccontrol getframe] -row 5 -column 2 -sticky w -padx 0
      entry $frm.pccontrol.entryCenteringSpeed -textvariable ::sophie::test::private(telescopeControl,centeringSpeed)
      grid $frm.pccontrol.entryCenteringSpeed -in [$frm.pccontrol getframe] -row 5 -column 3 -sticky w -padx 2

      label $frm.pccontrol.labelCentering2Speed -text "Vitesse centrage2" -justify left
      grid $frm.pccontrol.labelCentering2Speed -in [$frm.pccontrol getframe] -row 6 -column 2 -sticky w -padx 0
      entry $frm.pccontrol.entryCentering2Speed -textvariable ::sophie::test::private(telescopeControl,centering2Speed)
      grid $frm.pccontrol.entryCentering2Speed -in [$frm.pccontrol getframe] -row 6 -column 3 -sticky w -padx 2

      label $frm.pccontrol.labelGotoSpeed -text "Vitesse goto" -justify left
      grid $frm.pccontrol.labelGotoSpeed -in [$frm.pccontrol getframe] -row 6 -column 0 -sticky w -padx 0
      entry $frm.pccontrol.entryGotoSpeed -textvariable ::sophie::test::private(telescopeControl,gotoSpeed)
      grid $frm.pccontrol.entryGotoSpeed -in [$frm.pccontrol getframe] -row 6 -column 1 -sticky w -padx 2

      label $frm.pccontrol.labelSideralSpeed -text "Vitesse siderale"
      grid $frm.pccontrol.labelSideralSpeed -in [$frm.pccontrol getframe] -row 7 -column 0 -sticky w -padx 0
      entry $frm.pccontrol.entrySideralSpeed -textvariable ::sophie::test::private(telescopeControl,sideralSpeed)
      grid $frm.pccontrol.entrySideralSpeed -in [$frm.pccontrol getframe] -row 7 -column 1 -sticky w -padx 2

      label $frm.pccontrol.labelLunarSpeed -text "Vitesse lunaire"
      grid $frm.pccontrol.labelLunarSpeed -in [$frm.pccontrol getframe] -row 7 -column 2 -sticky w -padx 0
      entry $frm.pccontrol.entryLunarSpeed -textvariable ::sophie::test::private(telescopeControl,lunarSpeed)
      grid $frm.pccontrol.entryLunarSpeed -in [$frm.pccontrol getframe] -row 7 -column 3 -sticky w -padx 2

      label $frm.pccontrol.labelFocusPosition -text "Focus position (%) " -justify left
      grid $frm.pccontrol.labelFocusPosition -in [$frm.pccontrol getframe] -row 8 -column 0 -sticky w -padx 0
      entry $frm.pccontrol.entryFocusPosition -textvariable ::sophie::test::private(telescopeControl,focusPosition)
      grid $frm.pccontrol.entryFocusPosition -in [$frm.pccontrol getframe] -row 8 -column 1 -sticky w -padx 2

      label $frm.pccontrol.labelFocusSpeed -text "Vitesse (%/s)" -justify left
      grid $frm.pccontrol.labelFocusSpeed -in [$frm.pccontrol getframe] -row 8 -column 2 -sticky w -padx 0
      entry $frm.pccontrol.entryFocusSpeed -textvariable ::sophie::test::private(telescopeControl,focusSpeed)
      grid $frm.pccontrol.entryFocusSpeed -in [$frm.pccontrol getframe] -row 8 -column 3 -sticky w -padx 2

      button $frm.pccontrol.validate -text "Enregistrer" -command "::sophie::test::configure"
      grid $frm.pccontrol.validate -in [$frm.pccontrol getframe] -row 9 -column 0 -columnspan 4 -sticky nw -padx 2

      grid columnconfigure [$frm.pccontrol getframe] 0 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 1 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 2 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 3 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 4 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 5 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 6 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 7 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 8 -weight 1
      grid columnconfigure [$frm.pccontrol getframe] 9 -weight 1

      pack $frm.pccontrol -in $frm -side top -anchor w -fill x -expand 0

   #--- Frame pour les boutons
   frame $frm.frameButton -borderwidth 1 -relief raised

      #--- Bouton 'OK'
      button $frm.butOk -text $::caption(sophie,ok) -borderwidth 2 \
         -command "::sophie::test::ok"
      pack $frm.butOk -in $frm.frameButton -anchor center -side left -padx 5 -pady 5 -ipadx 10 -ipady 5

      #--- Bouton 'Fermer'
      button $frm.butFermer -text $::caption(sophie,fermer) -borderwidth 2 \
         -command "::sophie::test::fermer"
      pack $frm.butFermer -in $frm.frameButton -anchor center -side right -padx 5 -pady 5 -ipadx 10 -ipady 5

   pack $frm.frameButton -side bottom -fill x -expand 0

   #--- La fenetre est active
   focus $frm

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $frm <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
# simulationGenericFileName
#    Ouvre le navigateur pour choisir les images de simulation
#------------------------------------------------------------
proc ::sophie::test::simulationGenericFileName { } {
   variable private

   #--- Ouvre la fenetre de choix des images
   set filename [ ::tkutil::box_load $private(frm) $::audace(rep_images) $::audace(bufNo) "1" ]
   #--- Nom generique avec le chemin
   if { $filename != "" } {
      set private(simulationGenericFileName) [ file join [ lindex [ decomp $filename ] 0 ] [ lindex [ decomp $filename ] 1 ] ]
      #--- Il faut un fichier
      if { $private(simulationGenericFileName) == "" } {
         return
      }
   } else {
      return
   }
}

#============================================================
#
# SIMULATION DU PC SOPHIE
#
#============================================================

#------------------------------------------------------------
# openSocketSophie
#   ouvre une socket en ecriture pour simuler l'envoi des donnees du PC Sophie
#
# @param host adress IP ou nom DNS du PC de guidage (parametre optionel, valeur par defaut= localhost)
#------------------------------------------------------------
proc ::sophie::test::openSocketSophie { } {
   variable private

   set private(pcSophie,socketChannel) [socket $private(host) $::conf(sophie,socketPort) ]
   #---  -translation binary -encoding binary
   fconfigure $private(pcSophie,socketChannel) -buffering line -blocking true -translation binary -encoding binary
   fileevent $private(pcSophie,socketChannel) readable [list ::sophie::test::readSocketSophie ]

}

#------------------------------------------------------------
# closeSocketSophie
#   ferme la socket
#
#------------------------------------------------------------
proc ::sophie::test::closeSocketSophie { } {
   variable private
   if { $private(pcSophie,socketChannel) != "" } {
      close $private(pcSophie,socketChannel)
      set private(pcSophie,socketChannel) ""
   }
}

#------------------------------------------------------------
# readSocketSophie
#   envoie des donnes vers le PC de guidage
#
#------------------------------------------------------------
proc ::sophie::test::readSocketSophie {  } {
   variable private

   set private(pcSophie,socketResponse) [gets $private(pcSophie,socketChannel) ]
   return $private(pcSophie,socketResponse)
}

#------------------------------------------------------------
# writeSocketSophie
#   envoie des donnes vers le PC de guidage
#
# @param data : donnees a envoyer
#------------------------------------------------------------
proc ::sophie::test::writeSocketSophie { data } {
   variable private

   console::disp "::sophie::test::writeSocketSophie data=$data\n"
   puts $private(pcSophie,socketChannel) $data

}

#------------------------------------------------------------
# connecterPcGuidage
#    connecter/deconnecter au PC de guidage
#------------------------------------------------------------
proc ::sophie::test::connecterPcGuidage { } {
   variable private

   set catchError [ catch {
      if { $private(pcSophie,socketChannel) == "" } {
         ::sophie::test::openSocketSophie
         $private(frm).pcsophie.connect configure -text "déconnecter"
      } else {
         ::sophie::test::closeSocketSophie
         $private(frm).pcsophie.connect configure -text "connecter"
      }
   }]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,simulation)
   }
}

#------------------------------------------------------------
# sendPcGuidage
#    envoie des donnees au PC de guidage
#------------------------------------------------------------
proc ::sophie::test::sendPcGuidage { commandName } {
   variable private

   set catchError [ catch {
      switch $commandName {
         "STAT_ON" {
            ::sophie::test::writeSocketSophie "!STAT_ON@"
         }
         "STAT_OFF" {
            ::sophie::test::writeSocketSophie "!STAT_OFF@"
         }
         "GET_STAT" {
            ::sophie::test::writeSocketSophie "!GET_STAT@"
            set result [::sophie::test::readSocketSophie]
            #--- j'affiche le resultat
            tk_messageBox -title $::caption(sophie,simulation) -type ok -message "statistiques=$result" -icon info
         }
         "RAZ_STAT" {
            ::sophie::test::writeSocketSophie "!RAZ_STAT@"
         }

         default {
            error "invalid commandName=$commandName"
         }
      }
   }]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,simulation)
   }

}

#============================================================
#
# test impulsion telescope par carte NI
#  source audace/plugin/tool/sophie/sophietest.tcl
#============================================================
proc ::sophie::test::startPulse { } {
   variable private

   set private(sendPulse,enabled) 1
   ::sophie::test::sendPulse
}

proc ::sophie::test::stopPulse { } {
   variable private

   set private(sendPulse,enabled) 0
}

proc ::sophie::test::sendPulse { } {
   variable private

   set trace [tel1 radec move $private(sendPulse,direction) 0.1 $private(sendPulse,pulseDelay)]
   console::disp "radec move $private(sendPulse,direction) $private(sendPulse,pulseDelay) trace=$trace\n"

   if { $private(sendPulse,enabled) == 1 } {
      after [expr int($private(sendPulse,waitDelay) * 1000) ] ::sophie::test::sendPulse
   } else {
      ::console::disp "Fin pulse\n"
   }
}

#============================================================
#
# SIMULATION DE L'INTERFACE de CONTROLE DU TELESCOPE
#
#============================================================

#------------------------------------------------------------
# connectTelescopeControl
#    connecter/deconnecter au PC de guidage
#------------------------------------------------------------
proc ::sophie::test::connectTelescopeControl { } {
   variable private

   set catchError [ catch {
      if { $private(controlThreadId) == "" } {

         #--- je charge le programme du simulateur dans un thread dedie
         set private(controlThreadId) [thread::create]
         set sourceFileName [file join $::audace(rep_gui) [file join $::audace(rep_plugin) tool sophie sophietestcontrol.tcl]]
         ::thread::send $private(controlThreadId) [list uplevel #0 source \"$sourceFileName\"]
         ::thread::send $private(controlThreadId) [list ::sophie::testcontrol::init [thread::id] $::conf(t193,telescopeCommandPort) $::conf(t193,telescopeNotificationPort) ]
         ::sophie::test::configure
         #--- j'ouvre la socket de commande en attente de la connexion d'un client
         ::thread::send $private(controlThreadId)  [list ::sophie::testcontrol::openTelescopeControlSocket ]
         $private(frm).pccontrol.connect configure -text "ARRETER le simulateur de l'interface de controle"
      } else {
         #--- je referme les sockets et j'arrete le thread
         closeTelescopeControl
         $private(frm).pccontrol.connect configure -text "Demarrer le simulateur de l'interface de controle"
      }
   }]

   if { $catchError != 0 } {
      #--- j'affiche et je trace le message d'erreur
      ::tkutil::displayErrorInfo $::caption(sophie,simulation)
   }
}

#------------------------------------------------------------
# closeTelescopeControl
#    arrete le simulateur
#------------------------------------------------------------
proc ::sophie::test::closeTelescopeControl { } {
   variable private
   if { $private(controlThreadId) != "" } {
      ::thread::send $private(controlThreadId)  [list ::sophie::testcontrol::closeTelescopeControlSocket ]
      thread::release $private(controlThreadId)
      set private(controlThreadId) ""
   }
}

#------------------------------------------------------------
# updateGui
#    met a jour l'affichage des coordonnees RADEC
#   cette procedure est appelee par le thread du simulteur chaque fois que le teslescope change de position
#------------------------------------------------------------
proc ::sophie::test::updateGui { ra dec raSpeed decSpeed slewMode slewSpeed focusPosition focusSpeed } {
   variable private
   set private(telescopeControl,ra)        [format "%8.4f" $ra]
   set private(telescopeControl,raSpeed)   $raSpeed
   set private(telescopeControl,dec)       [format "%8.4f" $dec]
   set private(telescopeControl,decSpeed)  $decSpeed
   set private(telescopeControl,slewMode)  $slewMode
   set private(telescopeControl,slewSpeed) $slewSpeed
   set private(telescopeControl,focusPosition) $focusPosition
   set private(telescopeControl,focusSpeed) $focusSpeed

}

#------------------------------------------------------------
# configure
#   envoi les parametres de configuration au thread de simulation
#   cette procedure est appelee par le thread du simulteur chaque fois que le teslescope change de position
#------------------------------------------------------------
proc ::sophie::test::configure { } {
   variable private
   ::thread::send -async $private(controlThreadId) [list ::sophie::testcontrol::configure \
         $private(telescopeControl,sideralSpeed) $private(telescopeControl,lunarSpeed) \
         $private(telescopeControl,guidingSpeed) $private(telescopeControl,centeringSpeed) \
         $private(telescopeControl,centering2Speed) $private(telescopeControl,gotoSpeed) \
         $::audace(posobs,observateur,gps)]
}

#============================================================
#
# SIMULATION D'UN AFFICHEUR DE COORDONNEES
#
#============================================================

#------------------------------------------------------------
# openSocketCoord
#   ouvre une socket en ecriture pour simuler
#
# @param host adress IP ou nom DNS du PC de guidage (parametre optionel, valeur par defaut= localhost)
#------------------------------------------------------------
proc ::sophie::test::openSocketCoord { } {
   variable private

   set private(clientCoord,socketChannel) [socket "localhost" "5028" ]
   #---  -translation binary -encoding binary
   fconfigure $private(clientCoord,socketChannel) -buffering line -blocking true -translation binary -encoding binary
   ###fconfigure $private(clientCoord,socketChannel) -buffering line -blocking true
   fileevent $private(clientCoord,socketChannel) readable [list ::sophie::test::readSocketCoord ]

}

#------------------------------------------------------------
# closeSocketCoord
#   ferme la socket
#
#------------------------------------------------------------
proc ::sophie::test::closeSocketCoord { } {
   variable private
   if { $private(clientCoord,socketChannel) != "" } {
      close $private(clientCoord,socketChannel)
      set private(clientCoord,socketChannel) ""
   }
}

#------------------------------------------------------------
# readSocketSophie
#   envoie des donnes vers le PC de guidage
#
#------------------------------------------------------------
proc ::sophie::test::readSocketCoord {  } {
   variable private

   if {[eof $private(clientCoord,socketChannel)] } {
      ::sophie::test::closeSocketCoord
      console::disp "readSocketCoord close socket\n"
   } else {
      set response [gets $private(clientCoord,socketChannel) ]
      console::disp "readSocketCoord $response\n"
   }
}

#--- demarrage du contexte pour les tests
#::sophie::simul
#::sophie::test::connectTelescopeControl
#set ::conf(telescope) "t193"
#set ::confTel::private(mountName) $::conf(telescope)
#::confTel::configureMonture
#  source audace/plugin/tool/sophie/sophietest.tcl


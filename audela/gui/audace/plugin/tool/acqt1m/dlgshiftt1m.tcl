#
# Fichier : dlgshiftt1m.tcl
# Description : Fenetre de dialogue pour saisir les parametres de deplacement entre 2 images
# Auteur : Michel PUJOL
# Mise à jour $Id: dlgshiftt1m.tcl 8477 2012-07-23 14:03:00Z robertdelmas  $
#

namespace eval ::DlgShiftt1m {

   #------------------------------------------------------------
   #  init
   #      load configuration file
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqt1m dlgshiftt1m.cap ]
   }

   #------------------------------------------------------------
   #  initToConf
   #------------------------------------------------------------
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,buttonShift) ] }      { set ::acqt1m::parametres(acqt1m,$visuNo,buttonShift)      "0" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,geometry) ] }         { set ::acqt1m::parametres(acqt1m,$visuNo,geometry)         "278x182+657+251" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,position) ] }         { set ::acqt1m::parametres(acqt1m,$visuNo,position)         "+657+251" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,shiftSpeed) ] }       { set ::acqt1m::parametres(acqt1m,$visuNo,shiftSpeed)       "x5" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection) ] }  { set ::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection)  "O" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection1) ] } { set ::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection1) "w" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,xShiftTime) ] }       { set ::acqt1m::parametres(acqt1m,$visuNo,xShiftTime)       "2" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection) ] }  { set ::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection)  "N" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection1) ] } { set ::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection1) "n" }
      if { ! [ info exists ::acqt1m::parametres(acqt1m,$visuNo,yShiftTime) ] }       { set ::acqt1m::parametres(acqt1m,$visuNo,yShiftTime)       "2" }
   }

   #------------------------------------------------------------
   #  confToWidget
   #------------------------------------------------------------
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(DlgShiftt1m,buttonShift)      $::acqt1m::parametres(acqt1m,$visuNo,buttonShift)
      set panneau(DlgShiftt1m,geometry)         $::acqt1m::parametres(acqt1m,$visuNo,geometry)
      set panneau(DlgShiftt1m,position)         $::acqt1m::parametres(acqt1m,$visuNo,position)
      set panneau(DlgShiftt1m,shiftSpeed)       $::acqt1m::parametres(acqt1m,$visuNo,shiftSpeed)
      set panneau(DlgShiftt1m,xShiftDirection)  $::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection)
      set panneau(DlgShiftt1m,xShiftDirection1) $::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection1)
      set panneau(DlgShiftt1m,xShiftTime)       $::acqt1m::parametres(acqt1m,$visuNo,xShiftTime)
      set panneau(DlgShiftt1m,yShiftDirection)  $::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection)
      set panneau(DlgShiftt1m,yShiftDirection1) $::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection1)
      set panneau(DlgShiftt1m,yShiftTime)       $::acqt1m::parametres(acqt1m,$visuNo,yShiftTime)
   }

   #------------------------------------------------------------
   #  run
   #      display dialog
   #------------------------------------------------------------
   proc run { visuNo this } {
      variable This

      set This $this
      ::DlgShiftt1m::createDialog $visuNo
      tkwait window $This
      return
   }

   #------------------------------------------------------------
   #  cmdSave
   #------------------------------------------------------------
   proc cmdSave { visuNo } {
      variable parametres
      global panneau

      #---
      ::DlgShiftt1m::recupPosition

      #---
      set ::acqt1m::parametres(acqt1m,$visuNo,buttonShift)      $panneau(DlgShiftt1m,buttonShift)
      set ::acqt1m::parametres(acqt1m,$visuNo,geometry)         $panneau(DlgShiftt1m,geometry)
      set ::acqt1m::parametres(acqt1m,$visuNo,position)         $panneau(DlgShiftt1m,position)
      set ::acqt1m::parametres(acqt1m,$visuNo,shiftSpeed)       $panneau(DlgShiftt1m,shiftSpeed)
      set ::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection)  $panneau(DlgShiftt1m,xShiftDirection)
      set ::acqt1m::parametres(acqt1m,$visuNo,xShiftDirection1) $panneau(DlgShiftt1m,xShiftDirection1)
      set ::acqt1m::parametres(acqt1m,$visuNo,xShiftTime)       $panneau(DlgShiftt1m,xShiftTime)
      set ::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection)  $panneau(DlgShiftt1m,yShiftDirection)
      set ::acqt1m::parametres(acqt1m,$visuNo,yShiftDirection1) $panneau(DlgShiftt1m,yShiftDirection1)
      set ::acqt1m::parametres(acqt1m,$visuNo,yShiftTime)       $panneau(DlgShiftt1m,yShiftTime)

      #--- close the dialog window
      ::DlgShiftt1m::closeDialog
   }

   #------------------------------------------------------------
   #  cmdCancel
   #      close dialog without saving
   #------------------------------------------------------------
   proc cmdCancel { } {
      #--- close the dialog window
      ::DlgShiftt1m::closeDialog
   }

   #------------------------------------------------------------
   #  closeDialog
   #      close dialog
   #------------------------------------------------------------
   proc closeDialog { } {
      variable This

      #--- close and destroy the dialog window
      destroy $This
      unset This
   }

   #------------------------------------------------------------
   #  decalageTelescope
   #      decalage du telescope pendant une serie d'images
   #------------------------------------------------------------
   proc decalageTelescope { } {
      global caption panneau

      #--- Deplacement du télescope
      if { $panneau(DlgShiftt1m,buttonShift) == "1" } {
         if { ( $panneau(DlgShiftt1m,xShiftDirection) != "" ) || ( $panneau(DlgShiftt1m,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshiftt1m,labelTelescope)\n"
         }

         ::console::affiche_prompt "::telescope::setSpeed $panneau(DlgShiftt1m,shiftSpeed) \n"
         ::telescope::decodeSpeedDlgShift DlgShiftt1m

         #--- Sur l'axe est/ouest
         if { $panneau(DlgShiftt1m,xShiftDirection) != "" } {
            if { $panneau(DlgShiftt1m,xShiftDirection) == "$caption(dlgshiftt1m,est)" } {
               set panneau(DlgShiftt1m,xShiftDirection1) "e"
            } elseif { $panneau(DlgShiftt1m,xShiftDirection) == "$caption(dlgshiftt1m,ouest)" } {
               set panneau(DlgShiftt1m,xShiftDirection1) "w"
            }
            ::telescope::move $panneau(DlgShiftt1m,xShiftDirection1)
            after [expr $panneau(DlgShiftt1m,xShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShiftt1m,xShiftDirection1)
         }
         #--- Sur l'axe nord/sud
         if { $panneau(DlgShiftt1m,yShiftDirection) != "" } {
            if { $panneau(DlgShiftt1m,yShiftDirection) == "$caption(dlgshiftt1m,nord)" } {
               set panneau(DlgShiftt1m,yShiftDirection1) "n"
            } elseif { $panneau(DlgShiftt1m,yShiftDirection) == "$caption(dlgshiftt1m,sud)" } {
               set panneau(DlgShiftt1m,yShiftDirection1) "s"
            }
            ::telescope::move $panneau(DlgShiftt1m,yShiftDirection1)
            after [expr $panneau(DlgShiftt1m,yShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShiftt1m,yShiftDirection1)
         }
         if { ( $panneau(DlgShiftt1m,xShiftDirection) != "" ) || ( $panneau(DlgShiftt1m,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshiftt1m,labelStop)\n"
         }
      }
   }

   #------------------------------------------------------------
   #  recupPosition
   #      give position window
   #------------------------------------------------------------
   proc recupPosition { } {
      variable This
      global panneau

      set panneau(DlgShiftt1m,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(DlgShiftt1m,geometry) ] ]
      set fin [ string length $panneau(DlgShiftt1m,geometry) ]
      set panneau(DlgShiftt1m,position) "+[string range $panneau(DlgShiftt1m,geometry) $deb $fin]"
   }

   #------------------------------------------------------------
   #  createDialog
   #      display dialog window
   #------------------------------------------------------------
   proc createDialog { visuNo } {
      variable This
      global caption conf panneau

      if { [winfo exists $This] } {
         wm withdraw $This
         wm deiconify $This
         focus $This.frameButton.buttonSave
         return
      }

      #--- confToWidget
      ::DlgShiftt1m::confToWidget $visuNo

      #---
      if { [ info exists panneau(DlgShiftt1m,geometry) ] } {
         set deb [ expr 1 + [ string first + $panneau(DlgShiftt1m,geometry) ] ]
         set fin [ string length $panneau(DlgShiftt1m,geometry) ]
         set panneau(DlgShiftt1m,position) "+[string range $panneau(DlgShiftt1m,geometry) $deb $fin]"
      }

      #--- create toplevel window
      toplevel $This -class Toplevel
      wm geometry $This $panneau(DlgShiftt1m,position)
      wm title $This $caption(dlgshiftt1m,title)

      #--- redirect WM_DELETE_WINDOW message
      wm protocol $This WM_DELETE_WINDOW "::DlgShiftt1m::cmdCancel"

      #--- create frame to display parameters -------------------------------------
      frame $This.frameConfig -borderwidth 1 -relief raised

      label $This.frameConfig.labelTimex -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftt1m,labelTimex)
      grid configure $This.frameConfig.labelTimex -column 0 -row 0 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectionx -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftt1m,labelDirectionx)
      grid configure $This.frameConfig.labelDirectionx -column 0 -row 1 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelTimey -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftt1m,labelTimey)
      grid configure $This.frameConfig.labelTimey -column 0 -row 2 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectiony -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftt1m,labelDirectiony)
      grid configure $This.frameConfig.labelDirectiony -column 0 -row 3 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelSpeed -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftt1m,labelSpeed)
      grid configure $This.frameConfig.labelSpeed -column 0 -row 4 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      #--- entry xShiftTime
      entry $This.frameConfig.xShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShiftt1m,xShiftTime) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      grid configure $This.frameConfig.xShiftTime -column 1 -row 0 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.xShiftDirection -textvariable panneau(DlgShiftt1m,xShiftDirection) \
         -menu $This.frameConfig.xShiftDirection.menu -relief raised
      grid configure $This.frameConfig.xShiftDirection -column 1 -row 1 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.xShiftDirection.menu -tearoff 0]
      foreach xShiftDirection "$caption(dlgshiftt1m,est) $caption(dlgshiftt1m,ouest)" {
         $m add radiobutton -label "$xShiftDirection" \
            -indicatoron "1" \
            -value "$xShiftDirection" \
            -variable panneau(DlgShiftt1m,xShiftDirection) \
            -command { }
      }

      #--- entry yShiftTime
      entry $This.frameConfig.yShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShiftt1m,yShiftTime) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      grid configure $This.frameConfig.yShiftTime -column 1 -row 2 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.yShiftDirection -textvariable panneau(DlgShiftt1m,yShiftDirection) \
         -menu $This.frameConfig.yShiftDirection.menu -relief raised
      grid configure $This.frameConfig.yShiftDirection -column 1 -row 3 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.yShiftDirection.menu -tearoff 0]
      foreach yShiftDirection "$caption(dlgshiftt1m,nord) $caption(dlgshiftt1m,sud)" {
         $m add radiobutton -label "$yShiftDirection" \
            -indicatoron "1" \
            -value "$yShiftDirection" \
            -variable panneau(DlgShiftt1m,yShiftDirection) \
            -command { }
      }

      if { $conf(telescope) == "audecom" } {
         set speed_list "$caption(dlgshiftt1m,x1) $caption(dlgshiftt1m,x5) $caption(dlgshiftt1m,200)"
      } elseif { $conf(telescope) == "temma" } {
         set speed_list "$caption(dlgshiftt1m,NS) $caption(dlgshiftt1m,HS)"
      } else {
         set speed_list "1 2 3 4"
      }

      menubutton $This.frameConfig.shiftSpeed -textvariable panneau(DlgShiftt1m,shiftSpeed) \
         -menu $This.frameConfig.shiftSpeed.menu -relief raised
      grid configure $This.frameConfig.shiftSpeed -column 1 -row 4 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.shiftSpeed.menu -tearoff 0]
      foreach shiftSpeed $speed_list {
         $m add radiobutton -label "$shiftSpeed" \
            -indicatoron "1" \
            -value "$shiftSpeed" \
            -variable panneau(DlgShiftt1m,shiftSpeed) \
            -command { }
      }

      pack $This.frameConfig -side top -fill both -expand 0

      #--- create frame to display buttons -------------------------------------
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- button CANCEL
      button $This.frameButton.buttonCancel -text $caption(dlgshiftt1m,buttonCancel) \
         -borderwidth 2 -command "::DlgShiftt1m::cmdCancel"
      pack   $This.frameButton.buttonCancel -in $This.frameButton -anchor w -fill none -side left \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      #--- button SAVE
      button $This.frameButton.buttonSave -text $caption(dlgshiftt1m,buttonSave) \
         -borderwidth 2  -command "::DlgShiftt1m::cmdSave $visuNo"
      pack   $This.frameButton.buttonSave -in $This.frameButton -anchor e -fill none \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      pack $This.frameButton -side bottom -fill both -expand 0

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

::DlgShiftt1m::init


#
# Fichier : dlgshift.tcl
# Description : Fenetre de dialogue pour saisir les parametres de deplacement entre 2 images
# Auteur : Michel PUJOL
# Mise à jour $Id: dlgshift.tcl 8477 2012-07-23 14:03:00Z robertdelmas  $
#

namespace eval ::DlgShift {

   #------------------------------------------------------------
   #  init
   #      load configuration file
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqfc dlgshift.cap ]
   }

   #------------------------------------------------------------
   #  initToConf
   #------------------------------------------------------------
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,buttonShift) ] }      { set ::acqfc::parametres(acqfc,$visuNo,buttonShift)      "0" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,geometry) ] }         { set ::acqfc::parametres(acqfc,$visuNo,geometry)         "278x182+657+251" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,position) ] }         { set ::acqfc::parametres(acqfc,$visuNo,position)         "+657+251" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,shiftSpeed) ] }       { set ::acqfc::parametres(acqfc,$visuNo,shiftSpeed)       "x5" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,xShiftDirection) ] }  { set ::acqfc::parametres(acqfc,$visuNo,xShiftDirection)  "O" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,xShiftDirection1) ] } { set ::acqfc::parametres(acqfc,$visuNo,xShiftDirection1) "w" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,xShiftTime) ] }       { set ::acqfc::parametres(acqfc,$visuNo,xShiftTime)       "2" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,yShiftDirection) ] }  { set ::acqfc::parametres(acqfc,$visuNo,yShiftDirection)  "N" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,yShiftDirection1) ] } { set ::acqfc::parametres(acqfc,$visuNo,yShiftDirection1) "n" }
      if { ! [ info exists ::acqfc::parametres(acqfc,$visuNo,yShiftTime) ] }       { set ::acqfc::parametres(acqfc,$visuNo,yShiftTime)       "2" }
   }

   #------------------------------------------------------------
   #  confToWidget
   #------------------------------------------------------------
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(DlgShift,buttonShift)      $::acqfc::parametres(acqfc,$visuNo,buttonShift)
      set panneau(DlgShift,geometry)         $::acqfc::parametres(acqfc,$visuNo,geometry)
      set panneau(DlgShift,position)         $::acqfc::parametres(acqfc,$visuNo,position)
      set panneau(DlgShift,shiftSpeed)       $::acqfc::parametres(acqfc,$visuNo,shiftSpeed)
      set panneau(DlgShift,xShiftDirection)  $::acqfc::parametres(acqfc,$visuNo,xShiftDirection)
      set panneau(DlgShift,xShiftDirection1) $::acqfc::parametres(acqfc,$visuNo,xShiftDirection1)
      set panneau(DlgShift,xShiftTime)       $::acqfc::parametres(acqfc,$visuNo,xShiftTime)
      set panneau(DlgShift,yShiftDirection)  $::acqfc::parametres(acqfc,$visuNo,yShiftDirection)
      set panneau(DlgShift,yShiftDirection1) $::acqfc::parametres(acqfc,$visuNo,yShiftDirection1)
      set panneau(DlgShift,yShiftTime)       $::acqfc::parametres(acqfc,$visuNo,yShiftTime)
   }

   #------------------------------------------------------------
   #  run
   #      display dialog
   #------------------------------------------------------------
   proc run { visuNo this } {
      variable This

      set This $this
      ::DlgShift::createDialog $visuNo
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
      ::DlgShift::recupPosition

      #---
      set ::acqfc::parametres(acqfc,$visuNo,buttonShift)      $panneau(DlgShift,buttonShift)
      set ::acqfc::parametres(acqfc,$visuNo,geometry)         $panneau(DlgShift,geometry)
      set ::acqfc::parametres(acqfc,$visuNo,position)         $panneau(DlgShift,position)
      set ::acqfc::parametres(acqfc,$visuNo,shiftSpeed)       $panneau(DlgShift,shiftSpeed)
      set ::acqfc::parametres(acqfc,$visuNo,xShiftDirection)  $panneau(DlgShift,xShiftDirection)
      set ::acqfc::parametres(acqfc,$visuNo,xShiftDirection1) $panneau(DlgShift,xShiftDirection1)
      set ::acqfc::parametres(acqfc,$visuNo,xShiftTime)       $panneau(DlgShift,xShiftTime)
      set ::acqfc::parametres(acqfc,$visuNo,yShiftDirection)  $panneau(DlgShift,yShiftDirection)
      set ::acqfc::parametres(acqfc,$visuNo,yShiftDirection1) $panneau(DlgShift,yShiftDirection1)
      set ::acqfc::parametres(acqfc,$visuNo,yShiftTime)       $panneau(DlgShift,yShiftTime)

      #--- close the dialog window
      ::DlgShift::closeDialog
   }

   #------------------------------------------------------------
   #  cmdCancel
   #      close dialog without saving
   #------------------------------------------------------------
   proc cmdCancel { } {
      #--- close the dialog window
      ::DlgShift::closeDialog
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
      if { $panneau(DlgShift,buttonShift) == "1" } {
         if { ( $panneau(DlgShift,xShiftDirection) != "" ) || ( $panneau(DlgShift,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshift,labelTelescope)\n"
         }

         ::console::affiche_prompt "::telescope::setSpeed $panneau(DlgShift,shiftSpeed) \n"
         ::telescope::decodeSpeedDlgShift DlgShift

         #--- Sur l'axe est/ouest
         if { $panneau(DlgShift,xShiftDirection) != "" } {
            if { $panneau(DlgShift,xShiftDirection) == "$caption(dlgshift,est)" } {
               set panneau(DlgShift,xShiftDirection1) "e"
            } elseif { $panneau(DlgShift,xShiftDirection) == "$caption(dlgshift,ouest)" } {
               set panneau(DlgShift,xShiftDirection1) "w"
            }
            ::telescope::move $panneau(DlgShift,xShiftDirection1)
            after [expr $panneau(DlgShift,xShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShift,xShiftDirection1)
         }
         #--- Sur l'axe nord/sud
         if { $panneau(DlgShift,yShiftDirection) != "" } {
            if { $panneau(DlgShift,yShiftDirection) == "$caption(dlgshift,nord)" } {
               set panneau(DlgShift,yShiftDirection1) "n"
            } elseif { $panneau(DlgShift,yShiftDirection) == "$caption(dlgshift,sud)" } {
               set panneau(DlgShift,yShiftDirection1) "s"
            }
            ::telescope::move $panneau(DlgShift,yShiftDirection1)
            after [expr $panneau(DlgShift,yShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShift,yShiftDirection1)
         }
         if { ( $panneau(DlgShift,xShiftDirection) != "" ) || ( $panneau(DlgShift,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshift,labelStop)\n"
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

      set panneau(DlgShift,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(DlgShift,geometry) ] ]
      set fin [ string length $panneau(DlgShift,geometry) ]
      set panneau(DlgShift,position) "+[string range $panneau(DlgShift,geometry) $deb $fin]"
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
      ::DlgShift::confToWidget $visuNo

      #---
      if { [ info exists panneau(DlgShift,geometry) ] } {
         set deb [ expr 1 + [ string first + $panneau(DlgShift,geometry) ] ]
         set fin [ string length $panneau(DlgShift,geometry) ]
         set panneau(DlgShift,position) "+[string range $panneau(DlgShift,geometry) $deb $fin]"
      }

      #--- create toplevel window
      toplevel $This -class Toplevel
      wm geometry $This $panneau(DlgShift,position)
      wm title $This $caption(dlgshift,title)

      #--- redirect WM_DELETE_WINDOW message
      wm protocol $This WM_DELETE_WINDOW "::DlgShift::cmdCancel"

      #--- create frame to display parameters -------------------------------------
      frame $This.frameConfig -borderwidth 1 -relief raised

      label $This.frameConfig.labelTimex -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelTimex)
      grid configure $This.frameConfig.labelTimex -column 0 -row 0 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectionx -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelDirectionx)
      grid configure $This.frameConfig.labelDirectionx -column 0 -row 1 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelTimey -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelTimey)
      grid configure $This.frameConfig.labelTimey -column 0 -row 2 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectiony -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelDirectiony)
      grid configure $This.frameConfig.labelDirectiony -column 0 -row 3 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelSpeed -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshift,labelSpeed)
      grid configure $This.frameConfig.labelSpeed -column 0 -row 4 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      #--- entry xShiftTime
      entry $This.frameConfig.xShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShift,xShiftTime) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      grid configure $This.frameConfig.xShiftTime -column 1 -row 0 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.xShiftDirection -textvariable panneau(DlgShift,xShiftDirection) \
         -menu $This.frameConfig.xShiftDirection.menu -relief raised
      grid configure $This.frameConfig.xShiftDirection -column 1 -row 1 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.xShiftDirection.menu -tearoff 0]
      foreach xShiftDirection "$caption(dlgshift,est) $caption(dlgshift,ouest)" {
         $m add radiobutton -label "$xShiftDirection" \
            -indicatoron "1" \
            -value "$xShiftDirection" \
            -variable panneau(DlgShift,xShiftDirection) \
            -command { }
      }

      #--- entry yShiftTime
      entry $This.frameConfig.yShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShift,yShiftTime) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      grid configure $This.frameConfig.yShiftTime -column 1 -row 2 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.yShiftDirection -textvariable panneau(DlgShift,yShiftDirection) \
         -menu $This.frameConfig.yShiftDirection.menu -relief raised
      grid configure $This.frameConfig.yShiftDirection -column 1 -row 3 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.yShiftDirection.menu -tearoff 0]
      foreach yShiftDirection "$caption(dlgshift,nord) $caption(dlgshift,sud)" {
         $m add radiobutton -label "$yShiftDirection" \
            -indicatoron "1" \
            -value "$yShiftDirection" \
            -variable panneau(DlgShift,yShiftDirection) \
            -command { }
      }

      if { $conf(telescope) == "audecom" } {
         set speed_list "$caption(dlgshift,x1) $caption(dlgshift,x5) $caption(dlgshift,200)"
      } elseif { $conf(telescope) == "temma" } {
         set speed_list "$caption(dlgshift,NS) $caption(dlgshift,HS)"
      } else {
         set speed_list "1 2 3 4"
      }

      menubutton $This.frameConfig.shiftSpeed -textvariable panneau(DlgShift,shiftSpeed) \
         -menu $This.frameConfig.shiftSpeed.menu -relief raised
      grid configure $This.frameConfig.shiftSpeed -column 1 -row 4 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.shiftSpeed.menu -tearoff 0]
      foreach shiftSpeed $speed_list {
         $m add radiobutton -label "$shiftSpeed" \
            -indicatoron "1" \
            -value "$shiftSpeed" \
            -variable panneau(DlgShift,shiftSpeed) \
            -command { }
      }

      pack $This.frameConfig -side top -fill both -expand 0

      #--- create frame to display buttons -------------------------------------
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- button CANCEL
      button $This.frameButton.buttonCancel -text $caption(dlgshift,buttonCancel) \
         -borderwidth 2 -command "::DlgShift::cmdCancel"
      pack   $This.frameButton.buttonCancel -in $This.frameButton -anchor w -fill none -side left \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      #--- button SAVE
      button $This.frameButton.buttonSave -text $caption(dlgshift,buttonSave) \
         -borderwidth 2  -command "::DlgShift::cmdSave $visuNo"
      pack   $This.frameButton.buttonSave -in $This.frameButton -anchor e -fill none \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      pack $This.frameButton -side bottom -fill both -expand 0

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

::DlgShift::init


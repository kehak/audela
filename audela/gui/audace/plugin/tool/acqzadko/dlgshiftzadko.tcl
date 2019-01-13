#
# Fichier : dlgshiftzadko.tcl
# Description : Fenetre de dialogue pour saisir les parametres de deplacement entre 2 images
# Auteur : Michel PUJOL
# Mise à jour $Id: dlgshiftzadko.tcl 8477 2012-07-23 14:03:00Z robertdelmas  $
#

namespace eval ::DlgShiftZadko {

   #------------------------------------------------------------
   #  init
   #      load configuration file
   #------------------------------------------------------------
   proc init { } {
      global audace

      #--- Chargement des captions
      source [ file join $audace(rep_plugin) tool acqzadko dlgshiftzadko.cap ]
   }

   #------------------------------------------------------------
   #  initToConf
   #------------------------------------------------------------
   proc initToConf { visuNo } {
      variable parametres

      #--- Creation des variables si elles n'existent pas
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,buttonShift) ] }      { set ::acqzadko::parametres(acqzadko,$visuNo,buttonShift)      "0" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,geometry) ] }         { set ::acqzadko::parametres(acqzadko,$visuNo,geometry)         "278x182+657+251" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,position) ] }         { set ::acqzadko::parametres(acqzadko,$visuNo,position)         "+657+251" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,shiftSpeed) ] }       { set ::acqzadko::parametres(acqzadko,$visuNo,shiftSpeed)       "x5" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection) ] }  { set ::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection)  "O" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection1) ] } { set ::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection1) "w" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,xShiftTime) ] }       { set ::acqzadko::parametres(acqzadko,$visuNo,xShiftTime)       "2" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection) ] }  { set ::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection)  "N" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection1) ] } { set ::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection1) "n" }
      if { ! [ info exists ::acqzadko::parametres(acqzadko,$visuNo,yShiftTime) ] }       { set ::acqzadko::parametres(acqzadko,$visuNo,yShiftTime)       "2" }
   }

   #------------------------------------------------------------
   #  confToWidget
   #------------------------------------------------------------
   proc confToWidget { visuNo } {
      variable parametres
      global panneau

      #--- confToWidget
      set panneau(DlgShiftZadko,buttonShift)      $::acqzadko::parametres(acqzadko,$visuNo,buttonShift)
      set panneau(DlgShiftZadko,geometry)         $::acqzadko::parametres(acqzadko,$visuNo,geometry)
      set panneau(DlgShiftZadko,position)         $::acqzadko::parametres(acqzadko,$visuNo,position)
      set panneau(DlgShiftZadko,shiftSpeed)       $::acqzadko::parametres(acqzadko,$visuNo,shiftSpeed)
      set panneau(DlgShiftZadko,xShiftDirection)  $::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection)
      set panneau(DlgShiftZadko,xShiftDirection1) $::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection1)
      set panneau(DlgShiftZadko,xShiftTime)       $::acqzadko::parametres(acqzadko,$visuNo,xShiftTime)
      set panneau(DlgShiftZadko,yShiftDirection)  $::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection)
      set panneau(DlgShiftZadko,yShiftDirection1) $::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection1)
      set panneau(DlgShiftZadko,yShiftTime)       $::acqzadko::parametres(acqzadko,$visuNo,yShiftTime)
   }

   #------------------------------------------------------------
   #  run
   #      display dialog
   #------------------------------------------------------------
   proc run { visuNo this } {
      variable This

      set This $this
      ::DlgShiftZadko::createDialog $visuNo
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
      ::DlgShiftZadko::recupPosition

      #---
      set ::acqzadko::parametres(acqzadko,$visuNo,buttonShift)      $panneau(DlgShiftZadko,buttonShift)
      set ::acqzadko::parametres(acqzadko,$visuNo,geometry)         $panneau(DlgShiftZadko,geometry)
      set ::acqzadko::parametres(acqzadko,$visuNo,position)         $panneau(DlgShiftZadko,position)
      set ::acqzadko::parametres(acqzadko,$visuNo,shiftSpeed)       $panneau(DlgShiftZadko,shiftSpeed)
      set ::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection)  $panneau(DlgShiftZadko,xShiftDirection)
      set ::acqzadko::parametres(acqzadko,$visuNo,xShiftDirection1) $panneau(DlgShiftZadko,xShiftDirection1)
      set ::acqzadko::parametres(acqzadko,$visuNo,xShiftTime)       $panneau(DlgShiftZadko,xShiftTime)
      set ::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection)  $panneau(DlgShiftZadko,yShiftDirection)
      set ::acqzadko::parametres(acqzadko,$visuNo,yShiftDirection1) $panneau(DlgShiftZadko,yShiftDirection1)
      set ::acqzadko::parametres(acqzadko,$visuNo,yShiftTime)       $panneau(DlgShiftZadko,yShiftTime)

      #--- close the dialog window
      ::DlgShiftZadko::closeDialog
   }

   #------------------------------------------------------------
   #  cmdCancel
   #      close dialog without saving
   #------------------------------------------------------------
   proc cmdCancel { } {
      #--- close the dialog window
      ::DlgShiftZadko::closeDialog
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
      if { $panneau(DlgShiftZadko,buttonShift) == "1" } {
         if { ( $panneau(DlgShiftZadko,xShiftDirection) != "" ) || ( $panneau(DlgShiftZadko,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshiftzadko,labelTelescope)\n"
         }

         ::console::affiche_prompt "::telescope::setSpeed $panneau(DlgShiftZadko,shiftSpeed) \n"
         ::telescope::decodeSpeedDlgShift DlgShiftZadko

         #--- Sur l'axe est/ouest
         if { $panneau(DlgShiftZadko,xShiftDirection) != "" } {
            if { $panneau(DlgShiftZadko,xShiftDirection) == "$caption(dlgshiftzadko,est)" } {
               set panneau(DlgShiftZadko,xShiftDirection1) "e"
            } elseif { $panneau(DlgShiftZadko,xShiftDirection) == "$caption(dlgshiftzadko,ouest)" } {
               set panneau(DlgShiftZadko,xShiftDirection1) "w"
            }
            ::telescope::move $panneau(DlgShiftZadko,xShiftDirection1)
            after [expr $panneau(DlgShiftZadko,xShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShiftZadko,xShiftDirection1)
         }
         #--- Sur l'axe nord/sud
         if { $panneau(DlgShiftZadko,yShiftDirection) != "" } {
            if { $panneau(DlgShiftZadko,yShiftDirection) == "$caption(dlgshiftzadko,nord)" } {
               set panneau(DlgShiftZadko,yShiftDirection1) "n"
            } elseif { $panneau(DlgShiftZadko,yShiftDirection) == "$caption(dlgshiftzadko,sud)" } {
               set panneau(DlgShiftZadko,yShiftDirection1) "s"
            }
            ::telescope::move $panneau(DlgShiftZadko,yShiftDirection1)
            after [expr $panneau(DlgShiftZadko,yShiftTime) * 1000]
            ::telescope::stop $panneau(DlgShiftZadko,yShiftDirection1)
         }
         if { ( $panneau(DlgShiftZadko,xShiftDirection) != "" ) || ( $panneau(DlgShiftZadko,yShiftDirection) != "" ) } {
            ::console::affiche_resultat "$caption(dlgshiftzadko,labelStop)\n"
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

      set panneau(DlgShiftZadko,geometry) [ wm geometry $This ]
      set deb [ expr 1 + [ string first + $panneau(DlgShiftZadko,geometry) ] ]
      set fin [ string length $panneau(DlgShiftZadko,geometry) ]
      set panneau(DlgShiftZadko,position) "+[string range $panneau(DlgShiftZadko,geometry) $deb $fin]"
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
      ::DlgShiftZadko::confToWidget $visuNo

      #---
      if { [ info exists panneau(DlgShiftZadko,geometry) ] } {
         set deb [ expr 1 + [ string first + $panneau(DlgShiftZadko,geometry) ] ]
         set fin [ string length $panneau(DlgShiftZadko,geometry) ]
         set panneau(DlgShiftZadko,position) "+[string range $panneau(DlgShiftZadko,geometry) $deb $fin]"
      }

      #--- create toplevel window
      toplevel $This -class Toplevel
      wm geometry $This $panneau(DlgShiftZadko,position)
      wm title $This $caption(dlgshiftzadko,title)

      #--- redirect WM_DELETE_WINDOW message
      wm protocol $This WM_DELETE_WINDOW "::DlgShiftZadko::cmdCancel"

      #--- create frame to display parameters -------------------------------------
      frame $This.frameConfig -borderwidth 1 -relief raised

      label $This.frameConfig.labelTimex -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelTimex)
      grid configure $This.frameConfig.labelTimex -column 0 -row 0 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectionx -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelDirectionx)
      grid configure $This.frameConfig.labelDirectionx -column 0 -row 1 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelTimey -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelTimey)
      grid configure $This.frameConfig.labelTimey -column 0 -row 2 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelDirectiony -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelDirectiony)
      grid configure $This.frameConfig.labelDirectiony -column 0 -row 3 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      label $This.frameConfig.labelSpeed -width 34 -borderwidth 2 -relief groove \
         -text $caption(dlgshiftzadko,labelSpeed)
      grid configure $This.frameConfig.labelSpeed -column 0 -row 4 -sticky we -in $This.frameConfig -ipadx 15 -ipady 5

      #--- entry xShiftTime
      entry $This.frameConfig.xShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShiftZadko,xShiftTime) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      grid configure $This.frameConfig.xShiftTime -column 1 -row 0 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.xShiftDirection -textvariable panneau(DlgShiftZadko,xShiftDirection) \
         -menu $This.frameConfig.xShiftDirection.menu -relief raised
      grid configure $This.frameConfig.xShiftDirection -column 1 -row 1 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.xShiftDirection.menu -tearoff 0]
      foreach xShiftDirection "$caption(dlgshiftzadko,est) $caption(dlgshiftzadko,ouest)" {
         $m add radiobutton -label "$xShiftDirection" \
            -indicatoron "1" \
            -value "$xShiftDirection" \
            -variable panneau(DlgShiftZadko,xShiftDirection) \
            -command { }
      }

      #--- entry yShiftTime
      entry $This.frameConfig.yShiftTime -width 5 -borderwidth 2 -justify center \
         -textvariable panneau(DlgShiftZadko,yShiftTime) \
         -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
      grid configure $This.frameConfig.yShiftTime -column 1 -row 2 -sticky we -in $This.frameConfig -ipady 5

      menubutton $This.frameConfig.yShiftDirection -textvariable panneau(DlgShiftZadko,yShiftDirection) \
         -menu $This.frameConfig.yShiftDirection.menu -relief raised
      grid configure $This.frameConfig.yShiftDirection -column 1 -row 3 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.yShiftDirection.menu -tearoff 0]
      foreach yShiftDirection "$caption(dlgshiftzadko,nord) $caption(dlgshiftzadko,sud)" {
         $m add radiobutton -label "$yShiftDirection" \
            -indicatoron "1" \
            -value "$yShiftDirection" \
            -variable panneau(DlgShiftZadko,yShiftDirection) \
            -command { }
      }

      if { $conf(telescope) == "audecom" } {
         set speed_list "$caption(dlgshiftzadko,x1) $caption(dlgshiftzadko,x5) $caption(dlgshiftzadko,200)"
      } elseif { $conf(telescope) == "temma" } {
         set speed_list "$caption(dlgshiftzadko,NS) $caption(dlgshiftzadko,HS)"
      } else {
         set speed_list "1 2 3 4"
      }

      menubutton $This.frameConfig.shiftSpeed -textvariable panneau(DlgShiftZadko,shiftSpeed) \
         -menu $This.frameConfig.shiftSpeed.menu -relief raised
      grid configure $This.frameConfig.shiftSpeed -column 1 -row 4 -sticky we -in $This.frameConfig
      set m [menu $This.frameConfig.shiftSpeed.menu -tearoff 0]
      foreach shiftSpeed $speed_list {
         $m add radiobutton -label "$shiftSpeed" \
            -indicatoron "1" \
            -value "$shiftSpeed" \
            -variable panneau(DlgShiftZadko,shiftSpeed) \
            -command { }
      }

      pack $This.frameConfig -side top -fill both -expand 0

      #--- create frame to display buttons -------------------------------------
      frame $This.frameButton -borderwidth 1 -relief raised

      #--- button CANCEL
      button $This.frameButton.buttonCancel -text $caption(dlgshiftzadko,buttonCancel) \
         -borderwidth 2 -command "::DlgShiftZadko::cmdCancel"
      pack   $This.frameButton.buttonCancel -in $This.frameButton -anchor w -fill none -side left \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      #--- button SAVE
      button $This.frameButton.buttonSave -text $caption(dlgshiftzadko,buttonSave) \
         -borderwidth 2  -command "::DlgShiftZadko::cmdSave $visuNo"
      pack   $This.frameButton.buttonSave -in $This.frameButton -anchor e -fill none \
         -padx 3 -pady 3 -ipadx 5 -ipady 3

      pack $This.frameButton -side bottom -fill both -expand 0

      #--- La fenetre est active
      focus $This

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }
}

::DlgShiftZadko::init


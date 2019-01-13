#
# Fichier : testaudine.tcl
# Description : Permet d'effectuer les tests d'une Audine lors de sa fabrication
# Auteur : Robert DELMAS
# Mise à jour $Id: testaudine.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::testAudine {
}

#
# testAudine::run this camItem
# Cree la fenetre de tests
# this = chemin de la fenetre
#
proc ::testAudine::run { this camItem } {
   variable This

   set This $this
   createDialog $camItem
   tkwait visibility $This
}

#
# testAudine::fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::testAudine::fermer { } {
   variable This

   destroy $This
}

proc ::testAudine::createDialog { camItem } {
   variable This
   global audace conf caption

   #---
   set camNo [ ::confCam::getCamNo $camItem ]

   #--- initConf
   if { ! [ info exists conf(audine,test) ] }  { set conf(audine,test) "10000" }
   if { ! [ info exists conf(audine,test2) ] } { set conf(audine,test2) "3" }

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) camera audine testaudine.cap ]

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(testaudine,titre)
   set posx_testAudine [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 1 ]
   set posy_testAudine [ lindex [ split [ wm geometry $audace(base).confCam ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_testAudine + 100 ]+[ expr $posy_testAudine + 50 ]
   wm resizable $This 0 0

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

   #--- Test avec un voltmetre
   label $This.lab1 -text "$caption(testaudine,voltm)"
   pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 10 -pady 5

   #--- Cree le bouton 'Set 0' - Mesure de tensions et reglage des potentiometres P1, P3 et P4
   button $This.but_set0 -text "$caption(testaudine,set0)" -width 8 -borderwidth 2 \
      -command "cam$camNo set0"
   pack $This.but_set0 -in $This.frame4 -anchor center -side left -padx 10 -pady 5 -ipady 5

   label $This.lab2 -text "$caption(testaudine,text1)"
   pack $This.lab2 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Cree le bouton 'Set 255' - Mesure de tensions et reglage du potentiometre P2
   button $This.but_set255 -text "$caption(testaudine,set255)" -width 8 -borderwidth 2 \
      -command "cam$camNo set255"
   pack $This.but_set255 -in $This.frame5 -anchor center -side left -padx 10 -pady 5 -ipady 5

   label $This.lab3 -text "$caption(testaudine,text2)"
   pack $This.lab3 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

   #--- Test avec un oscilloscope
   label $This.lab4 -text "$caption(testaudine,oscillo)"
   pack $This.lab4 -in $This.frame6 -anchor center -side left -padx 10 -pady 5

   #--- Cree le bouton 'Test' - Cycle de transfert Zone image / Registre horizontal
   button $This.but_test1 -text "$caption(testaudine,test1)" -width 8 -borderwidth 2 \
      -command "cam$camNo test $conf(audine,test)"
   pack $This.but_test1 -in $This.frame7 -anchor center -side left -padx 10 -pady 5 -ipady 5

   #--- Zone a renseigner pour le nombre de cycles de transfert Zone image / Registre horizontal
   catch {
      entry $This.limp -textvariable conf(audine,test) -width 6 -justify center
      pack $This.limp -in $This.frame7 -anchor center -side left -padx 10 -pady 5
   }

   label $This.lab5 -text "$caption(testaudine,text3)"
   pack $This.lab5 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

   #--- Cree le bouton 'Test 2' - Cycle de lecture rapide
   button $This.but_test2 -text "$caption(testaudine,test2)" -width 8 -borderwidth 2 \
      -command "cam$camNo test2 $conf(audine,test2)"
   pack $This.but_test2 -in $This.frame8 -anchor center -side left -padx 10 -pady 5 -ipady 5

   #--- Zone a renseigner pour le nombre de cycles de lecture rapide
   catch {
      entry $This.maxad -textvariable conf(audine,test2) -width 6 -justify center
      pack $This.maxad -in $This.frame8 -anchor center -side left -padx 10 -pady 5
   }

   label $This.lab6 -text "$caption(testaudine,text4)"
   pack $This.lab6 -in $This.frame8 -anchor center -side left -padx 5 -pady 5

   #--- Cree le bouton 'Fermer'
   button $This.but_fermer -text "$caption(testaudine,fermer)" -width 7 -borderwidth 2 \
      -command "::testAudine::fermer"
   pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}


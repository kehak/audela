#
# Fichier : audecomconfig.tcl
# Description : Configuration et pilotage de la monture AudeCom (Ex-Kauffmann)
# Auteurs : Robert DELMAS et Philippe KAUFFMANN
# Mise à jour $Id: audecomconfig.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

#
# Description : Fenetre de configuration des moteurs AD et Dec pour la monture AudeCom
#

namespace eval ::confAudecomMot {
}

#
# ::confAudecomMot::init
# Initialise les variables caption(...)
#
proc ::confAudecomMot::init { } {
   global audace

   #--- Charge le fichier caption
   source [ file join $audace(rep_plugin) mount audecom audecomconfig.cap ]
}

#
# ::confAudecomMot::run
# Cree la fenetre de configuration des moteurs AD et Dec
#
proc ::confAudecomMot::run { this } {
   variable This

   set This $this
   ::confAudecomMot::createDialog
   tkwait visibility $This
}

#
# ::confAudecomMot::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
# et fermer la fenetre de configuration des moteurs AD et Dec
#
proc ::confAudecomMot::ok { } {
   ::confAudecomMot::appliquer
   ::confAudecomMot::fermer
}

#
# ::confAudecomMot::appliquer
# Fonction 'Appliquer' pour memoriser et appliquer la configuration
#
proc ::confAudecomMot::appliquer { } {
   ::confAudecomMot::widgetToConf
}

#
# ::confAudecomMot::fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::confAudecomMot::fermer { } {
   variable This

   destroy $This
}

#
# ::confAudecomMot::createDialog
# Creation de l'interface graphique
#
proc ::confAudecomMot::createDialog { } {
   variable This
   variable private
   global audace caption conf

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(audecomconfig,para_mot)
   set posx_audecom_para_mot [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_audecom_para_mot [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_audecom_para_mot + 0 ]+[ expr $posy_audecom_para_mot + 70 ]
   wm resizable $This 0 0

   #--- On utilise les valeurs contenues dans le tableau private pour l'initialisation
   ::confAudecomMot::confToWidget

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame2 -borderwidth 1 -relief raised
   pack $This.frame2 -side top -fill x

   frame $This.frame3 -borderwidth 0 -relief raised
   pack $This.frame3 -in $This.frame1 -side top -fill x

   frame $This.frame4 -borderwidth 0 -relief raised
   pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

   frame $This.frame5 -borderwidth 0 -relief raised
   pack $This.frame5 -in $This.frame3 -side left -fill y

   frame $This.frame6 -borderwidth 0 -relief raised
   pack $This.frame6 -in $This.frame3 -side left -fill x

   frame $This.frame7 -borderwidth 0 -relief raised
   pack $This.frame7 -in $This.frame3 -side left -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame9 -borderwidth 0 -relief raised
   pack $This.frame9 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame10 -borderwidth 0 -relief raised
   pack $This.frame10 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame11 -borderwidth 0 -relief raised
   pack $This.frame11 -in $This.frame6 -side top -fill none

   frame $This.frame12 -borderwidth 0 -relief raised
   pack $This.frame12 -in $This.frame6 -side top -fill none

   frame $This.frame13 -borderwidth 0 -relief raised
   pack $This.frame13 -in $This.frame7 -side top -fill both -expand 1

   frame $This.frame14 -borderwidth 0 -relief raised
   pack $This.frame14 -in $This.frame7 -side top -fill both -expand 1

   frame $This.frame15 -borderwidth 0 -relief raised
   pack $This.frame15 -in $This.frame8 -side bottom -fill both -expand 1

   frame $This.frame16 -borderwidth 0 -relief raised
   pack $This.frame16 -in $This.frame8 -side bottom -fill both -expand 1

   frame $This.frame17 -borderwidth 0 -relief raised
   pack $This.frame17 -in $This.frame8 -side bottom -fill both -expand 1

   frame $This.frame18 -borderwidth 0 -relief raised -height 14
   pack $This.frame18 -in $This.frame8 -side bottom -fill both -expand 1

   #--- Cree le bouton 'Aide' du rattrapage des jeux en AD et Dec
   button $This.but_aide0 -text "$caption(audecomconfig,aide)" -height 3 -width 2 -borderwidth 2 \
      -command { ::confAudecomMot::aide0 }
   pack $This.but_aide0 -in $This.frame5 -anchor center -side left -padx 10 -pady 0

   #--- De l'amplitude du rattrapage des jeux en AD
   label $This.lab1 -text "$caption(audecomconfig,rat_jeu_ad)"
   pack $This.lab1 -in $This.frame11 -anchor w -side left -padx 5 -pady 5

   entry $This.rat_ad -textvariable ::confAudecomMot::private(audecom,rat_ad) -width 5 -justify center
   pack $This.rat_ad -in $This.frame13 -anchor w -side left -padx 5 -pady 5

   #--- De l'amplitude du rattrapage des jeux en Dec
   label $This.lab2 -text "$caption(audecomconfig,rat_jeu_dec)"
   pack $This.lab2 -in $This.frame12 -anchor w -side left -padx 5 -pady 5

   entry $This.rat_dec -textvariable ::confAudecomMot::private(audecom,rat_dec) -width 5 -justify center
   pack $This.rat_dec -in $This.frame14 -anchor w -side left -padx 5 -pady 5

   #--- Rappelle les valeurs par defaut programmees dans le microcontroleur
   label $This.lab3 -text "$caption(audecomconfig,val_defaut)"
   pack $This.lab3 -in $This.frame9 -anchor center -side top -padx 0 -pady 5

   #--- De la largeur des impulsions
   label $This.lab4 -text "$conf(audecom,dlimp)"
   pack $This.lab4 -in $This.frame9 -anchor center -side bottom -padx 0 -pady 11

   #--- De la vitesse maxi en Dec
   label $This.lab5 -text "$conf(audecom,dmaxdec)"
   pack $This.lab5 -in $This.frame9 -anchor center -side bottom -padx 0 -pady 11

   #--- De la vitesse maxi en AD
   label $This.lab6 -text "$conf(audecom,dmaxad)"
   pack $This.lab6 -in $This.frame9 -anchor center -side bottom -padx 0 -pady 11

   #--- Rapelle les limites de ces valeurs
   label $This.lab7 -text "$caption(audecomconfig,limites)"
   pack $This.lab7 -in $This.frame10 -anchor center -side top -padx 0 -pady 5

   #--- De la largeur des impulsions
   label $This.lab8 -text "$conf(audecom,dlimpmin) $caption(audecomconfig,a) $conf(audecom,dlimpmax)"
   pack $This.lab8 -in $This.frame10 -anchor center -side bottom -padx 0 -pady 11

   #--- De la vitesse maxi en Dec
   label $This.lab9 -text "$conf(audecom,dmaxdecmin) $caption(audecomconfig,a) $conf(audecom,dmaxdecmax)"
   pack $This.lab9 -in $This.frame10 -anchor center -side bottom -padx 0 -pady 11

   #--- De la vitesse maxi en AD
   label $This.lab10 -text "$conf(audecom,dmaxadmin) $caption(audecomconfig,a) $conf(audecom,dmaxadmax)"
   pack $This.lab10 -in $This.frame10 -anchor center -side bottom -padx 0 -pady 11

   #--- Cree le bouton 'Aide' de la vitesse maxi en AD
   button $This.but_aide1 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomMot::aide1 }
   pack $This.but_aide1 -in $This.frame17 -anchor center -side left -padx 10 -pady 2

   #--- De la vitesse maxi en AD
   label $This.lab11 -text "$caption(audecomconfig,max_AD)"
   pack $This.lab11 -in $This.frame17 -anchor center -side left -padx 0 -pady 2

   entry $This.limp -textvariable ::confAudecomMot::private(audecom,maxad) -width 5 -justify center
   pack $This.limp -in $This.frame17 -anchor center -side right -padx 5 -pady 2

   #--- Cree le bouton 'Aide' de la vitesse maxi en Dec
   button $This.but_aide2 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomMot::aide2 }
   pack $This.but_aide2 -in $This.frame16 -anchor center -side left -padx 10 -pady 2

   #--- De la vitesse maxi en Dec
   label $This.lab12 -text "$caption(audecomconfig,max_Dec)"
   pack $This.lab12 -in $This.frame16 -anchor center -side left -padx 0 -pady 2

   entry $This.maxad -textvariable ::confAudecomMot::private(audecom,maxdec) -width 5 -justify center
   pack $This.maxad -in $This.frame16 -anchor center -side right -padx 5 -pady 2

   #--- Cree le bouton 'Aide' de la largeur des impulsions
   button $This.but_aide3 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomMot::aide3 }
   pack $This.but_aide3 -in $This.frame15 -anchor center -side left -padx 10 -pady 2

   #--- De la largeur des impulsions
   label $This.lab13 -text "$caption(audecomconfig,larg_imp)"
   pack $This.lab13 -in $This.frame15 -anchor center -side left -padx 0 -pady 2

   entry $This.maxdec -textvariable ::confAudecomMot::private(audecom,limp) -width 5 -justify center
  pack $This.maxdec -in $This.frame15 -anchor center -side right -padx 5 -pady 2

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(audecomconfig,ok)" -width 7 -borderwidth 2 \
      -command { ::confAudecomMot::ok }
   pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Annuler'
   button $This.but_cancel -text "$caption(audecomconfig,annuler)" -width 10 -borderwidth 2 \
      -command { ::confAudecomMot::fermer }
   pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree la console texte d'aide
   text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
   pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide01)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide02)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide03)\n"

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# ::confAudecomMot::aide0
# Affiche l'aide pour le choix du rattrapage des jeux en AD et Dec
#
proc ::confAudecomMot::aide0 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide05)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide06)\n"
   $This.lst1 insert end " \n"
   $This.lst1 see insert
}

#
# ::confAudecomMot::aide1
# Affiche l'aide pour le choix de la vitesse maxi en AD
#
proc ::confAudecomMot::aide1 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide11)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide12)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide13)\n"
   $This.lst1 see insert
}

#
# ::confAudecomMot::aide2
# Affiche l'aide pour le choix de la vitesse maxi en Dec
#
proc ::confAudecomMot::aide2 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide11)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide12)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_mot,aide21)\n"
   $This.lst1 see insert
}

#
# ::confAudecomMot::aide3
# Affiche l'aide pour le choix de la largeur de l'impulsion
#
proc ::confAudecomMot::aide3 { } {
   variable This
   global caption conf

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "[eval [concat {format} {$caption(audecomconfig,para_mot,aide31) $conf(audecom,dlimprecouv) \
      $conf(audecom,dlimpmin) $conf(audecom,dlimpmin) $conf(audecom,dlimpmax) $conf(audecom,dlimpmin)}]]"
   $This.lst1 see insert
}

#
# ::confAudecomMot::confToWidget
# Utilisation des valeurs contenues dans le tableau ::audecom::private(...) pour l'initialisation
#
proc ::confAudecomMot::confToWidget { } {
   variable private

   set private(audecom,rat_ad)  $::audecom::private(rat_ad)
   set private(audecom,rat_dec) $::audecom::private(rat_dec)
   set private(audecom,maxad)   $::audecom::private(maxad)
   set private(audecom,maxdec)  $::audecom::private(maxdec)
   set private(audecom,limp)    $::audecom::private(limp)
}

#
# ::confAudecomMot::widgetToConf
# Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
#
proc ::confAudecomMot::widgetToConf { } {
   variable private

   #--- Recherche des virgules dans les nombres decimaux et remplacement par des points
   set private(audecom,rat_ad)     [ ::confAudecomMot::remplaceVirguleParPoint $private(audecom,rat_ad) ]
   set private(audecom,rat_dec)    [ ::confAudecomMot::remplaceVirguleParPoint $private(audecom,rat_dec) ]
   #--- Sauvegarde des variables
   set ::audecom::private(rat_ad)  $private(audecom,rat_ad)
   set ::audecom::private(rat_dec) $private(audecom,rat_dec)
   set ::audecom::private(maxad)   $private(audecom,maxad)
   set ::audecom::private(maxdec)  $private(audecom,maxdec)
   set ::audecom::private(limp)    $private(audecom,limp)
}

#
# ::confAudecomMot::remplaceVirguleParPoint
# Recherche du caractere virgule et remplacement par le caractere point dans un nombre decimal
#
proc ::confAudecomMot::remplaceVirguleParPoint { chaine } {
   if { [ string first "," $chaine ] >= 0 } {
      set index [ string first "," $chaine ]
      set chaine [ string replace $chaine $index $index "." ]
   } else {
      set chaine $chaine
   }
}

###### Fin du namespace confAudecomMot ######

#
# Description : Fenetre de configuration de la focalisation pour la monture AudeCom
#

namespace eval ::confAudecomFoc {
}

#
# ::confAudecomFoc::run
# Cree la fenetre de configuration de la focalisation
#
proc ::confAudecomFoc::run { this } {
   variable This

   set This $this
   ::confAudecomFoc::createDialog
   tkwait visibility $This
}

#
# ::confAudecomFoc::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
# et fermer la fenetre de configuration de la focalisation
#
proc ::confAudecomFoc::ok { } {
   ::confAudecomFoc::appliquer
   ::confAudecomFoc::fermer
}

#
# ::confAudecomFoc::appliquer
# Fonction 'Appliquer' pour memoriser et appliquer la configuration
#
proc ::confAudecomFoc::appliquer { } {
   ::confAudecomFoc::widgetToConf
}

#
# ::confAudecomFoc::fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::confAudecomFoc::fermer { } {
   variable This

   destroy $This
}

#
# ::confAudecomFoc::createDialog
# Creation de l'interface graphique
#
proc ::confAudecomFoc::createDialog { } {
   variable This
   variable private
   global audace caption

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(audecomconfig,para_foc)
   set posx_audecom_para_foc [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_audecom_para_foc [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_audecom_para_foc + 0 ]+[ expr $posy_audecom_para_foc + 70 ]
   wm resizable $This 0 0

   #--- On utilise les valeurs contenues dans le tableau private pour l'initialisation
   ::confAudecomFoc::confToWidget

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

   #--- Cree le bouton 'Aide' de la vitesse du moteur
   button $This.but_aide1 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomFoc::aide1 }
   pack $This.but_aide1 -in $This.frame3 -anchor center -side left -padx 10 -pady 5

   #--- Etiquette vitesse du moteur
   label $This.lab1 -text "$caption(audecomconfig,vit_foc)"
   pack $This.lab1 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

   #--- Cree la zone a renseigner de la vitesse du moteur
   entry $This.vitmotfoc -textvariable ::confAudecomFoc::private(audecom,vitesse) -width 5 -justify center
   pack $This.vitmotfoc -in $This.frame3 -anchor center -side left -padx 5 -pady 5

   #--- Etiquette des limites de la vitesse moteur
   label $This.lab2 -text "$caption(audecomconfig,limite_vit)"
   pack $This.lab2 -in $This.frame3 -anchor center -side left -padx 5 -pady 5

   #--- Cree le bouton 'Aide' de la direction du mouvement
   button $This.but_aide2 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomFoc::aide2 }
   pack $This.but_aide2 -in $This.frame4 -anchor center -side left -padx 10 -pady 5

   #--- Etiquette direction du mouvement
   label $This.lab3 -text "$caption(audecomconfig,direction)"
   pack $This.lab3 -in $This.frame4 -anchor center -side left -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_1 -width 10
   pack $This.lab_invisible_1 -in $This.frame5 -side left -anchor w -padx 10 -pady 5

   #--- Radio-bouton intrafocal
   radiobutton $This.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(audecomconfig,intra_focal)" -value 0 -variable ::confAudecomFoc::private(audecom,intra_extra)
   pack $This.rad1 -in $This.frame5 -anchor center -side left -padx 3 -pady 5

   #--- Radio-bouton extrafocal
   radiobutton $This.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(audecomconfig,extra_focal)" -value 1 -variable ::confAudecomFoc::private(audecom,intra_extra)
   pack $This.rad2 -in $This.frame5 -anchor center -side left -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_2 -width 10 -borderwidth 0
   pack $This.lab_invisible_2 -in $This.frame6 -side left -anchor w -padx 10 -pady 5

   #--- Inversion du sens de rotation du moteur
   checkbutton $This.invrot -text "$caption(audecomconfig,inversion_rot)" -highlightthickness 0 \
      -variable ::confAudecomFoc::private(audecom,inv_rot)
   pack $This.invrot -in $This.frame6 -anchor center -side left -padx 5 -pady 5

   #--- Cree le bouton 'Aide' de la consigne pour le rattrapage des jeux
   button $This.but_aide3 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomFoc::aide3 }
   pack $This.but_aide3 -in $This.frame7 -anchor center -side left -padx 10 -pady 5

   #--- Etiquette consigne pour le rattrapage des jeux
   label $This.lab4 -text "$caption(audecomconfig,valeur_dep)"
   pack $This.lab4 -in $This.frame7 -anchor center -side left -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_3 -width 11 -borderwidth 0
   pack $This.lab_invisible_3 -in $This.frame8 -side left -anchor w -padx 10 -pady 5

   #--- Cree la zone a renseigner de la consigne du rattrapage des jeux
   entry $This.depval -textvariable ::confAudecomFoc::private(audecom,dep_val) -width 5 -justify center
   pack $This.depval -in $This.frame8 -anchor center -side left -padx 5 -pady 5

   #--- Etiquette de l'unite (pas) pour la consigne
   label $This.lab5 -text "$caption(audecomconfig,pas)"
   pack $This.lab5 -in $This.frame8 -anchor center -side left -padx 5 -pady 5

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(audecomconfig,ok)" -width 7 -borderwidth 2 \
      -command { ::confAudecomFoc::ok }
   pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Annuler'
   button $This.but_cancel -text "$caption(audecomconfig,annuler)" -width 10 -borderwidth 2 \
      -command { ::confAudecomFoc::fermer }
   pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree la console texte d'aide
   text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
   pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_foc,aide01)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_foc,aide02)\n"
   $This.lst1 insert end "$caption(audecomconfig,para_foc,aide03)\n"

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# ::confAudecomFoc::aide1
# Affiche l'aide pour le choix de la vitesse du moteur
#
proc ::confAudecomFoc::aide1 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_foc,aide1)\n"
   $This.lst1 see insert
}

#
# ::confAudecomFoc::aide2
# Affiche l'aide pour le choix de la direction du mouvement
#
proc ::confAudecomFoc::aide2 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_foc,aide2)\n"
   $This.lst1 see insert
}

#
# ::confAudecomFoc::aide3
# Affiche l'aide pour le choix de la consigne du rattrapage des jeux
#
proc ::confAudecomFoc::aide3 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_foc,aide3)\n"
   $This.lst1 see insert
}

#
# ::confAudecomFoc::confToWidget
# Utilisation des valeurs contenues dans le tableau ::audecom::private(...) pour l'initialisation
#
proc ::confAudecomFoc::confToWidget { } {
   variable private

   set private(audecom,vitesse)     $::audecom::private(vitesse)
   set private(audecom,intra_extra) $::audecom::private(intra_extra)
   set private(audecom,inv_rot)     $::audecom::private(inv_rot)
   set private(audecom,dep_val)     $::audecom::private(dep_val)
}

#
# ::confAudecomFoc::widgetToConf
# Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
#
proc ::confAudecomFoc::widgetToConf { } {
   variable private

   set ::audecom::private(vitesse)     $private(audecom,vitesse)
   set ::audecom::private(intra_extra) $private(audecom,intra_extra)
   set ::audecom::private(inv_rot)     $private(audecom,inv_rot)
   set ::audecom::private(dep_val)     $private(audecom,dep_val)
}

###### Fin du namespace confAudecomFoc ######

#
# Description : Fenetre de configuration du PEC pour la monture AudeCom
#

namespace eval ::confAudecomPec {
}

#
# ::confAudecomPec::run
# Cree la fenetre de configuration du Pec
#
proc ::confAudecomPec::run { this } {
   variable This

   set This $this
   ::confAudecomPec::createDialog
   tkwait visibility $This
}

#
# ::confAudecomPec::ok
# Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
# et fermer la fenetre de configuration du PEC
#
proc ::confAudecomPec::ok { } {
   ::confAudecomPec::appliquer
   ::confAudecomPec::fermer
}

#
# ::confAudecomPec::appliquer
# Fonction 'Appliquer' pour memoriser et appliquer la configuration
#
proc ::confAudecomPec::appliquer { } {
   ::confAudecomPec::widgetToConf
}

#
# ::confAudecomPec::fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::confAudecomPec::fermer { } {
   variable This

   destroy $This
}

#
# ::confAudecomPec::createDialog
# Creation de l'interface graphique
#
proc ::confAudecomPec::createDialog { } {
   variable This
   variable private
   global audace caption color conf

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(audecomconfig,prog_pec)
   set posx_audecom_prog_pec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_audecom_prog_pec [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_audecom_prog_pec + 0 ]+[ expr $posy_audecom_prog_pec + 70 ]
   wm resizable $This 0 0

   #--- On utilise les valeurs contenues dans le tableau private pour l'initialisation
   ::confAudecomPec::confToWidget

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
   pack $This.frame5 -in $This.frame3 -side left -fill both -expand 1

   frame $This.frame6 -borderwidth 0 -relief raised
   pack $This.frame6 -in $This.frame3 -side left -fill both -expand 1

   frame $This.frame7 -borderwidth 0 -relief raised
   pack $This.frame7 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame9 -borderwidth 0 -relief raised
   pack $This.frame9 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame10 -borderwidth 0 -relief raised
   pack $This.frame10 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame11 -borderwidth 0 -relief raised
   pack $This.frame11 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame12 -borderwidth 0 -relief raised
   pack $This.frame12 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame13 -borderwidth 0 -relief raised
   pack $This.frame13 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame14 -borderwidth 0 -relief raised
   pack $This.frame14 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame15 -borderwidth 0 -relief raised
   pack $This.frame15 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame16 -borderwidth 0 -relief raised
   pack $This.frame16 -in $This.frame5 -side top -fill both -expand 1

   frame $This.frame17 -borderwidth 0 -relief raised
   pack $This.frame17 -in $This.frame5 -side top -fill both -expand 1

   frame $This.frame18 -borderwidth 0 -relief raised
   pack $This.frame18 -in $This.frame15 -side top -fill both -expand 1

   frame $This.frame19 -borderwidth 0 -relief raised
   pack $This.frame19 -in $This.frame15 -side top -fill both -expand 1

   #--- Cree le bouton 'Aide' de la vitesse de suivi nominale
   button $This.but_aide1 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomPec::aide1 }
   pack $This.but_aide1 -in $This.frame16 -anchor center -side left -padx 10 -pady 5

   #--- Rappelle la vitesse de suivi nominale
   label $This.lab1 -text "$caption(audecomconfig,vit_suiv_nom)"
   pack $This.lab1 -in $This.frame16 -anchor center -side left -padx 5 -pady 5

   label $This.labURL2 -text "$conf(audecom,dsuivinom)" -fg $color(blue)
   pack $This.labURL2 -in $This.frame16 -anchor center -side left -padx 0 -pady 5

   #--- Cree le bouton 'Aide' de l'intervalle de choix de la vitesse de suivi
   button $This.but_aide2 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomPec::aide2 }
   pack $This.but_aide2 -in $This.frame17 -anchor center -side left -padx 10 -pady 5

   #--- Rappelle les limites des corrections et la reduction
   label $This.lab3 -text "$caption(audecomconfig,compris_entre) $conf(audecom,dsuivinommin)\
      $caption(audecomconfig,et) $conf(audecom,dsuivinommax)"
   pack $This.lab3 -in $This.frame17 -anchor center -side left -padx 5 -pady 5

   #--- Affiche la moyenne des correction
   label $This.lab4 -text "$caption(audecomconfig,somme_ti)"
   pack $This.lab4 -in $This.frame6 -anchor center -side top -padx 10 -pady 9

   label $This.labURL5 -text "$caption(audecomconfig,non_calcul)" -relief groove -fg $color(blue) -width 13
   pack $This.labURL5 -in $This.frame6 -anchor center -side top -padx 10 -pady 9

   #--- Cree la zone a renseigner t0
   label $This.lab6 -text "$caption(audecomconfig,t0)"
   pack $This.lab6 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

   entry $This.t0 -textvariable ::confAudecomPec::private(audecom,t0) -width 5 -justify center
   pack $This.t0 -in $This.frame8 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t1
   label $This.lab7 -text "$caption(audecomconfig,t1)"
   pack $This.lab7 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

   entry $This.t1 -textvariable ::confAudecomPec::private(audecom,t1) -width 5 -justify center
   pack $This.t1 -in $This.frame8 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t2
   label $This.lab8 -text "$caption(audecomconfig,t2)"
   pack $This.lab8 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

   entry $This.t2 -textvariable ::confAudecomPec::private(audecom,t2) -width 5 -justify center
   pack $This.t2 -in $This.frame8 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t3
   label $This.lab9 -text "$caption(audecomconfig,t3)"
   pack $This.lab9 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

   entry $This.t3 -textvariable ::confAudecomPec::private(audecom,t3) -width 5 -justify center
   pack $This.t3 -in $This.frame8 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t4
   label $This.lab10 -text "$caption(audecomconfig,t4)"
   pack $This.lab10 -in $This.frame7 -anchor center -side top -padx 5 -pady 5

   entry $This.t4 -textvariable ::confAudecomPec::private(audecom,t4) -width 5 -justify center
   pack $This.t4 -in $This.frame8 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t5
   label $This.lab11 -text "$caption(audecomconfig,t5)"
   pack $This.lab11 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

   entry $This.t5 -textvariable ::confAudecomPec::private(audecom,t5) -width 5 -justify center
   pack $This.t5 -in $This.frame10 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t6
   label $This.lab12 -text "$caption(audecomconfig,t6)"
   pack $This.lab12 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

   entry $This.t6 -textvariable ::confAudecomPec::private(audecom,t6) -width 5 -justify center
   pack $This.t6 -in $This.frame10 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t7
   label $This.lab13 -text "$caption(audecomconfig,t7)"
   pack $This.lab13 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

   entry $This.t7 -textvariable ::confAudecomPec::private(audecom,t7) -width 5 -justify center
   pack $This.t7 -in $This.frame10 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t8
   label $This.lab14 -text "$caption(audecomconfig,t8)"
   pack $This.lab14 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

   entry $This.t8 -textvariable ::confAudecomPec::private(audecom,t8) -width 5 -justify center
   pack $This.t8 -in $This.frame10 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t9
   label $This.lab15 -text "$caption(audecomconfig,t9)"
   pack $This.lab15 -in $This.frame9 -anchor center -side top -padx 5 -pady 5

   entry $This.t9 -textvariable ::confAudecomPec::private(audecom,t9) -width 5 -justify center
   pack $This.t9 -in $This.frame10 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t10
   label $This.lab16 -text "$caption(audecomconfig,t10)"
   pack $This.lab16 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

   entry $This.t10 -textvariable ::confAudecomPec::private(audecom,t10) -width 5 -justify center
   pack $This.t10 -in $This.frame12 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t11
   label $This.lab17 -text "$caption(audecomconfig,t11)"
   pack $This.lab17 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

   entry $This.t11 -textvariable ::confAudecomPec::private(audecom,t11) -width 5 -justify center
   pack $This.t11 -in $This.frame12 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t12
   label $This.lab18 -text "$caption(audecomconfig,t12)"
   pack $This.lab18 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

   entry $This.t12 -textvariable ::confAudecomPec::private(audecom,t12) -width 5 -justify center
   pack $This.t12 -in $This.frame12 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t13
   label $This.lab19 -text "$caption(audecomconfig,t13)"
   pack $This.lab19 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

   entry $This.t13 -textvariable ::confAudecomPec::private(audecom,t13) -width 5 -justify center
   pack $This.t13 -in $This.frame12 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t14
   label $This.lab20 -text "$caption(audecomconfig,t14)"
   pack $This.lab20 -in $This.frame11 -anchor center -side top -padx 5 -pady 5

   entry $This.t14 -textvariable ::confAudecomPec::private(audecom,t14) -width 5 -justify center
   pack $This.t14 -in $This.frame12 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t15
   label $This.lab21 -text "$caption(audecomconfig,t15)"
   pack $This.lab21 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

   entry $This.t15 -textvariable ::confAudecomPec::private(audecom,t15) -width 5 -justify center
   pack $This.t15 -in $This.frame14 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t16
   label $This.lab22 -text "$caption(audecomconfig,t16)"
   pack $This.lab22 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

   entry $This.t16 -textvariable ::confAudecomPec::private(audecom,t16) -width 5 -justify center
   pack $This.t16 -in $This.frame14 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t17
   label $This.lab23 -text "$caption(audecomconfig,t17)"
   pack $This.lab23 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

   entry $This.t17 -textvariable ::confAudecomPec::private(audecom,t17) -width 5 -justify center
   pack $This.t17 -in $This.frame14 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t18
   label $This.lab24 -text "$caption(audecomconfig,t18)"
   pack $This.lab24 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

   entry $This.t18 -textvariable ::confAudecomPec::private(audecom,t18) -width 5 -justify center
   pack $This.t18 -in $This.frame14 -anchor center -side top -padx 5 -pady 5

   #--- Cree la zone a renseigner t19
   label $This.lab25 -text "$caption(audecomconfig,t19)"
   pack $This.lab25 -in $This.frame13 -anchor center -side top -padx 5 -pady 5

   entry $This.t19 -textvariable ::confAudecomPec::private(audecom,t19) -width 5 -justify center
   pack $This.t19 -in $This.frame14 -anchor center -side top -padx 5 -pady 5

   #--- Cree le bouton 'Calculer' la moyenne de la somme de t1 a t19
   button $This.but_calculer -text "$caption(audecomconfig,calculer)" -borderwidth 2 \
      -command { ::confAudecomPec::moyti }
   pack $This.but_calculer -in $This.frame18 -anchor center -side top -pady 9 -ipadx 10 -ipady 5 -expand true

   #--- Cree le bouton 'Aide' pour la periodicite du PEC
   button $This.but_aide3 -text "$caption(audecomconfig,aide)" -width 2 -borderwidth 2 \
      -command { ::confAudecomPec::aide3 }
   pack $This.but_aide3 -in $This.frame19 -anchor center -side left -padx 10 -pady 9

   #--- Cree la zone a renseigner (r)
   label $This.lab26 -text "$caption(audecomconfig,r)"
   pack $This.lab26 -in $This.frame19 -anchor center -side left -padx 10 -pady 9

   entry $This.rpec -textvariable ::confAudecomPec::private(audecom,rpec) -width 5 -justify center
   pack $This.rpec -in $This.frame19 -anchor center -side left -padx 10 -pady 9

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(audecomconfig,ok)" -width 7 -borderwidth 2 \
      -command { ::confAudecomPec::ok }
   pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Annuler'
   button $This.but_cancel -text "$caption(audecomconfig,annuler)" -width 10 -borderwidth 2 \
      -command { ::confAudecomPec::fermer }
   pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree la console texte d'aide
   text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
   pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,aide01)\n"
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,aide02)\n"
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,aide03)\n"

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# ::confAudecomPec::aide1
# Affiche l'aide de la vitesse de suivi nominale
#
proc ::confAudecomPec::aide1 { } {
   variable This
   global conf
   global caption

   $This.lst1 delete 1.0 end
   set conf(audecom,dsuivinomxt0) [ expr $conf(audecom,dsuivinom) * $conf(audecom,internom) / 1000 ]
   $This.lst1 insert end "[eval [concat {format} {$caption(audecomconfig,prog_pec,aide11) $conf(audecom,dsuivinom) \
      $conf(audecom,dsuivinom) $conf(audecom,dsuivinomxt0) $conf(audecom,internom)}]]"
   $This.lst1 see insert
}

#
# ::confAudecomPec::aide2
# Affiche l'aide de l'intervalle de choix de la vitesse de suivi
#
proc ::confAudecomPec::aide2 { } {
   variable This
   global conf
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "[eval [concat {format} {$caption(audecomconfig,prog_pec,aide21) $conf(audecom,dsuivinommin) \
      $conf(audecom,dsuivinommax) $conf(audecom,dsuivinom) $conf(audecom,dsuivinom)}]]"
   $This.lst1 see insert
}

#
# ::confAudecomPec::aide3
# Affiche l'aide pour le choix de la periodicite du PEC
#
proc ::confAudecomPec::aide3 { } {
   variable This
   global caption

   $This.lst1 delete 1.0 end
   $This.lst1 insert end "\n"
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,aide31)\n"
   $This.lst1 insert end "\n"
   $This.lst1 see insert
}

#
# ::confAudecomPec::analyse1
# Affiche un commentaire sur l'analyse des corrections (correct)
#
proc ::confAudecomPec::analyse1 { } {
   variable This
   global conf
   global caption
   global color

   $This.lst1 delete 1.0 end
   $This.lst1 tag configure style_correct -foreground $color(blue)
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse11)\n" style_correct
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse12)\n" style_correct
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse13)\
      $conf(audecom,dsuivinom)$caption(audecomconfig,point)\n" style_correct
   $This.lst1 insert end "\n"
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse14)\n" style_correct
   $This.lst1 insert end ""
   $This.lst1 see insert
}

#
# ::confAudecomPec::analyse2
# Affiche un commentaire sur l'analyse des corrections (diverge)
#
proc ::confAudecomPec::analyse2 { } {
   variable This
   global conf
   global caption
   global color

   $This.lst1 delete 1.0 end
   $This.lst1 tag configure style_diverge -foreground $color(red)
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse21)\n" style_diverge
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse22)\n" style_diverge
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse23)\
      $conf(audecom,dsuivinom)$caption(audecomconfig,point)\n" style_diverge
   $This.lst1 insert end "\n"
   $This.lst1 insert end "$caption(audecomconfig,prog_pec,analyse24)\n" style_diverge
   $This.lst1 insert end ""
   $This.lst1 see insert
}

#
# ::confAudecomPec::moyti
# Calcule la moyenne de t1 a t19
#
proc ::confAudecomPec::moyti { } {
   variable This
   variable private
   global conf
   global color

   set private(t) 0
   for {set i 0} {$i <= 19} {incr i} {
      set private(t) [ expr $private(t) + $private(audecom,t$i) ]
   }
   set private(moyti) [ expr $private(t) / 20.0 ]
   if { $private(moyti) == "$conf(audecom,dsuivinom)" } {
      set fg $color(blue)
      analyse1
   } else {
      set fg $color(red)
      analyse2
   }
   $This.labURL5 configure -textvariable ::confAudecomPec::private(moyti) -fg $fg -width 11
}

#
# ::confAudecomPec::confToWidget
# Utilisation des valeurs contenues dans le tableau ::audecom::private(...) pour l'initialisation
#
proc ::confAudecomPec::confToWidget { } {
   variable private

   set private(audecom,t0)   $::audecom::private(t0)
   set private(audecom,t1)   $::audecom::private(t1)
   set private(audecom,t2)   $::audecom::private(t2)
   set private(audecom,t3)   $::audecom::private(t3)
   set private(audecom,t4)   $::audecom::private(t4)
   set private(audecom,t5)   $::audecom::private(t5)
   set private(audecom,t6)   $::audecom::private(t6)
   set private(audecom,t7)   $::audecom::private(t7)
   set private(audecom,t8)   $::audecom::private(t8)
   set private(audecom,t9)   $::audecom::private(t9)
   set private(audecom,t10)  $::audecom::private(t10)
   set private(audecom,t11)  $::audecom::private(t11)
   set private(audecom,t12)  $::audecom::private(t12)
   set private(audecom,t13)  $::audecom::private(t13)
   set private(audecom,t14)  $::audecom::private(t14)
   set private(audecom,t15)  $::audecom::private(t15)
   set private(audecom,t16)  $::audecom::private(t16)
   set private(audecom,t17)  $::audecom::private(t17)
   set private(audecom,t18)  $::audecom::private(t18)
   set private(audecom,t19)  $::audecom::private(t19)
   set private(audecom,rpec) $::audecom::private(rpec)
}

#
# ::confAudecomPec::widgetToConf
# Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
#
proc ::confAudecomPec::widgetToConf { } {
   variable private

   set ::audecom::private(t0)   $private(audecom,t0)
   set ::audecom::private(t1)   $private(audecom,t1)
   set ::audecom::private(t2)   $private(audecom,t2)
   set ::audecom::private(t3)   $private(audecom,t3)
   set ::audecom::private(t4)   $private(audecom,t4)
   set ::audecom::private(t5)   $private(audecom,t5)
   set ::audecom::private(t6)   $private(audecom,t6)
   set ::audecom::private(t7)   $private(audecom,t7)
   set ::audecom::private(t8)   $private(audecom,t8)
   set ::audecom::private(t9)   $private(audecom,t9)
   set ::audecom::private(t10)  $private(audecom,t10)
   set ::audecom::private(t11)  $private(audecom,t11)
   set ::audecom::private(t12)  $private(audecom,t12)
   set ::audecom::private(t13)  $private(audecom,t13)
   set ::audecom::private(t14)  $private(audecom,t14)
   set ::audecom::private(t15)  $private(audecom,t15)
   set ::audecom::private(t16)  $private(audecom,t16)
   set ::audecom::private(t17)  $private(audecom,t17)
   set ::audecom::private(t18)  $private(audecom,t18)
   set ::audecom::private(t19)  $private(audecom,t19)
   set ::audecom::private(rpec) $private(audecom,rpec)
}

###### Fin du namespace confAudecomPec ######

#
# Description : Fenetre d'affichage de la vitesse de King pour la monture AudeCom
#

namespace eval ::confAudecomKing {
}

#
# ::confAudecomKing::run
# Cree la fenetre de controle de la vitesse de King
#
proc ::confAudecomKing::run { this } {
   variable This
   variable private
   global audace

   if { $audace(telNo) == "0" } {
      return
   }

   set This $this
   set frm $::audecom::private(frm)
   $frm.ctlking configure -relief groove -state disabled
   ::confAudecomKing::createDialog
   tkwait visibility $This
   ::confAudecomKing::Clock_et_King
}

#
# ::confAudecomKing::fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::confAudecomKing::fermer { } {
   variable This
   variable private
   global audace

   if { [ winfo exists $audace(base).confTel ] } {
      set frm $::audecom::private(frm)
      $frm.ctlking configure -relief raised -state normal
   }
   destroy $This
}

#
# ::confAudecomKing::createDialog
# Creation de l'interface graphique
#
proc ::confAudecomKing::createDialog { } {
   variable This
   variable private
   global audace caption conf confgene

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Initialisation de variables
   set confgene(posobs,altitude) $conf(posobs,altitude)
   set confgene(posobs,nordsud)  $conf(posobs,nordsud)
   set confgene(posobs,lat)      $conf(posobs,lat)
   set confgene(posobs,estouest) $conf(posobs,estouest)
   set confgene(posobs,long)     $conf(posobs,long)

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(audecomconfig,ctrl_king)
   set posx_audecom_ctrl_king [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_audecom_ctrl_king [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_audecom_ctrl_king + 150 ]+[ expr $posy_audecom_ctrl_king + 0 ]
   wm resizable $This 0 0
   wm protocol $This WM_DELETE_WINDOW ::confAudecomKing::fermer

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
   pack $This.frame7 -in $This.frame3 -side left -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame3 -side left -fill none

   frame $This.frame9 -borderwidth 0 -relief raised
   pack $This.frame9 -in $This.frame4 -side left -fill both -expand 1

   frame $This.frame10 -borderwidth 0 -relief raised
   pack $This.frame10 -in $This.frame4 -side left -fill none

   frame $This.frame11 -borderwidth 0 -relief raised
   pack $This.frame11 -in $This.frame5 -side left -fill both -expand 1

   frame $This.frame12 -borderwidth 0 -relief raised
   pack $This.frame12 -in $This.frame5 -side left -fill none

   frame $This.frame13 -borderwidth 0 -relief raised
   pack $This.frame13 -in $This.frame6 -side left -fill both -expand 1

   frame $This.frame14 -borderwidth 0 -relief raised
   pack $This.frame14 -in $This.frame6 -side left -fill none

   #--- Position de l'observateur
   label $This.lab1 -text "$caption(audecomconfig,pos_obs)"
   pack $This.lab1 -in $This.frame7 -anchor w -side top -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_1 -text " "
   pack $This.lab_invisible_1 -in $This.frame8 -anchor w -side top -padx 5 -pady 5

   #--- Longitude observateur
   label $This.lab2 -text "$caption(audecomconfig,longitude)"
   pack $This.lab2 -in $This.frame7 -anchor w -side top -padx 25 -pady 0

   #--- Cree le label de la longitude
   label $This.lab3 -borderwidth 1 -width 14 -anchor w
   pack $This.lab3 -in $This.frame8 -anchor w -side top -padx 5 -pady 1

   #--- Latitude observateur
   label $This.lab4 -text "$caption(audecomconfig,latitude)"
   pack $This.lab4 -in $This.frame7 -anchor w -side top -padx 25 -pady 0

   #--- Cree le label de la latitude
   label $This.lab5 -borderwidth 1 -width 14 -anchor w
   pack $This.lab5 -in $This.frame8 -anchor w -side top -padx 5 -pady 1

   #--- Altitude observateur
   label $This.lab6 -text "$caption(audecomconfig,altitude)"
   pack $This.lab6 -in $This.frame7 -anchor w -side top -padx 25 -pady 0

   #--- Cree le label de l'altitude
   label $This.lab7 -borderwidth 1 -width 14 -anchor w
   pack $This.lab7 -in $This.frame8 -anchor w -side top -padx 5 -pady 1

   #--- Position du telescope
   label $This.lab8 -text "$caption(audecomconfig,pos_tel)"
   pack $This.lab8 -in $This.frame9 -anchor w -side top -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_2 -text " "
   pack $This.lab_invisible_2 -in $This.frame10 -anchor w -side top -padx 5 -pady 5

   #--- Azimut
   label $This.lab9 -text "$caption(audecomconfig,azimut)"
   pack $This.lab9 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

   label $This.lab10 -borderwidth 1 -textvariable ::confAudecomKing::private(azimut) -width 14 -anchor w
   pack $This.lab10 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

   #--- Hauteur
   label $This.lab11 -text "$caption(audecomconfig,hauteur)"
   pack $This.lab11 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

   label $This.lab12 -borderwidth 1 -textvariable ::confAudecomKing::private(hauteur) -width 14 -anchor w
   pack $This.lab12 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

   #--- Ascension droite
   label $This.lab13 -text "$caption(audecomconfig,ad)"
   pack $This.lab13 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

   label $This.lab14 -borderwidth 1 -textvariable ::confAudecomKing::private(ascension1) -width 14 -anchor w
   pack $This.lab14 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

   #--- Declinaison
   label $This.lab15 -text "$caption(audecomconfig,dec)"
   pack $This.lab15 -in $This.frame9 -anchor w -side top -padx 25 -pady 0

   label $This.lab16 -borderwidth 1 -textvariable ::confAudecomKing::private(declinaison1) -width 14 -anchor w
   pack $This.lab16 -in $This.frame10 -anchor w -side top -padx 5 -pady 1

   #--- Parametres lies au temps
   label $This.lab17 -text "$caption(audecomconfig,temps)"
   pack $This.lab17 -in $This.frame11 -anchor w -side top -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_3 -text " "
   pack $This.lab_invisible_3 -in $This.frame12 -anchor w -side top -padx 5 -pady 5

   #--- Angle horaire
   label $This.lab18 -text "$caption(audecomconfig,angle_horaire)"
   pack $This.lab18 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

   label $This.lab19 -borderwidth 1 -textvariable ::confAudecomKing::private(anglehoraire) -width 14 -anchor w
   pack $This.lab19 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

   #--- Temps sideral local
   label $This.lab20 -text "$caption(audecomconfig,tsl)"
   pack $This.lab20 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

   label $This.lab21 -borderwidth 1 -textvariable audace(tsl,format,hmsint) -width 14 -anchor w
   pack $This.lab21 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

   #--- Temps universel
   label $This.lab22 -text "$caption(audecomconfig,tu)"
   pack $This.lab22 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

   label $This.lab23 -borderwidth 1 -textvariable audace(tu,format,hmsint) -width 14 -anchor w
   pack $This.lab23 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

   #--- Heure legale
   label $This.lab24 -text "$caption(audecomconfig,hl)"
   pack $This.lab24 -in $This.frame11 -anchor w -side bottom -padx 25 -pady 0

   label $This.lab25 -borderwidth 1 -textvariable audace(hl,format,hmsint) -width 14 -anchor w
   pack $This.lab25 -in $This.frame12 -anchor w -side bottom -padx 5 -pady 1

   #--- Coefficient de King
   label $This.lab26 -text "$caption(audecomconfig,coef_king)"
   pack $This.lab26 -in $This.frame13 -anchor w -side top -padx 5 -pady 5

   #--- Cree un widget 'Invisible' pour simuler un espacement
   label $This.lab_invisible_4 -text " "
   pack $This.lab_invisible_4 -in $This.frame14 -anchor w -side top -padx 5 -pady 5

   #--- Coefficient k
   label $This.lab27 -text "$caption(audecomconfig,coef_k)"
   pack $This.lab27 -in $This.frame13 -anchor w -side top -padx 25 -pady 0

   label $This.lab28 -borderwidth 1 -textvariable ::confAudecomKing::private(coefking) -width 14 -anchor w
   pack $This.lab28 -in $This.frame14 -anchor w -side top -padx 5 -pady 1

   #--- Cree le bouton 'Fermer'
   button $This.but_close -text "$caption(audecomconfig,fermer)" -width 7 -borderwidth 2 \
      -command { ::confAudecomKing::fermer }
   pack $This.but_close -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# ::confAudecomKing::Clock_et_King
# Fonction qui met a jour TU, TSL, .... Cette fonction se re-appelle au bout d'une seconde
#
proc ::confAudecomKing::Clock_et_King { } {
   variable This
   variable private
   global audace caption conf confgene

   if { [ winfo exists $This ] } {
      #--- Cree le label de la longitude
      set confgene(posobs,long1) [ lindex [ mc_angle2dms $confgene(posobs,long) 180 ] 0 ]
      $This.lab3 configure -text "$confgene(posobs,estouest) [ expr int($confgene(posobs,long1)) ]° [ lindex [ mc_angle2dms $confgene(posobs,long) 180 ] 1 ]' [ format "%03.1f" [ lindex [ mc_angle2dms $confgene(posobs,long) 180 ] 2 ] ]''"
      #--- Cree le label de la latitude
      set confgene(posobs,lat1) [lindex [ mc_angle2dms $confgene(posobs,lat) 90 ] 0]
      $This.lab5 configure -text "$confgene(posobs,nordsud) [ expr int($confgene(posobs,lat1)) ]° [ lindex [ mc_angle2dms $confgene(posobs,lat) 90 ] 1 ]' [ format "%03.1f" [ lindex [ mc_angle2dms $confgene(posobs,lat) 90 ] 2 ] ]''"
      #--- Cree le label de l'altitude
      $This.lab7 configure -text "$confgene(posobs,altitude) $caption(audecomconfig,metre)"
      #--- Affichage heure tu et heure tsl
      #--- Preparation et affichage ascension droite et declinaison
      #--- Lecture de la position du telescope
      set addec [ tel$audace(telNo) radec coord -equinox J2000.0 ]
      #--- Ascension droite
      set ascension [ lindex $addec 0 ]
      if { $ascension == "+" } {
         set private(ascension1) "00h 00m 00s"
         set ascension2 "00h00m00s"
      } else {
         set private(ascension1) "[ string range $ascension  0 1 ]h [ string range $ascension 3 4 ]m [ string range $ascension 6 7 ]s"
         set ascension2 $ascension
      }
      #--- Declinaison
      set declinaison [ lindex $addec 1 ]
      if { $declinaison == "" } {
         set private(declinaison1) "00° 00' 00''"
         set declinaison2 "00d00m00s"
      } else {
         set private(declinaison1) "[ string range $declinaison 0 2 ]° [ string range $declinaison 4 5 ]' [ string range $declinaison 7 8 ]''"
         set declinaison2 $declinaison
      }
      #--- Preparation affichage azimut, hauteur et angle horaire
      set pos [ mc_radec2altaz $ascension2 $declinaison2 $audace(posobs,observateur,gps) [ ::audace::date_sys2ut now ] ]
      #--- Azimut
      set private(azimut) [ format "%05.2f" [ lindex $pos 0 ] ]$caption(audecomconfig,degre)
      #--- Hauteur
      set private(hauteur) [ format "%05.2f" [ lindex $pos 1 ] ]$caption(audecomconfig,degre)
      #--- Angle horaire
      set anglehoraire [ lindex $pos 2 ]
      set anglehoraire [ mc_angle2hms $anglehoraire 360 ]
      set anglehorairesec [ lindex $anglehoraire 2 ]
      set private(anglehoraire) [ format "%02dh %02dm %02ds" [ lindex $anglehoraire 0 ] [ lindex $anglehoraire 1 ] [ expr int($anglehorairesec) ] ]
      #--- Preparation affichage du coefficient de King
      #--- Latitude en radians
      set latitude [ lindex $audace(posobs,observateur,gps) 3 ]
      set latrad [ mc_angle2rad $latitude ]
      #--- Declinaison en radians
      set decrad [ mc_angle2rad $declinaison2 ]
      #--- Angle horaire en radians
      set anghorad [ mc_angle2rad [ lindex $pos 2 ] ]
      #--- Vitesse de king
      set num1 [ expr cos($latrad)*cos($decrad)+sin($latrad)*sin($decrad)*cos($anghorad) ]
      set denom1 [ expr pow(sin($latrad)*sin($decrad)+cos($latrad)*cos($decrad)*cos($anghorad),2) ]
      set exp1 [ expr $num1/$denom1 ]
      set exp2 [ expr ($exp1*cos($latrad)/cos($decrad))-(tan($decrad)*cos($anghorad)/tan($latrad)) ]
      set vitking [ expr 1436.07+0.40*$exp2 ]
      #--- Coefficient de king
      set private(coefking) [ format "%01.8f" [ expr $vitking/1436.07 ] ]
      #--- Active ou non le suivi a la vitesse de King
      if { $conf(audecom,king) == "1" } {
         set corking [ expr $conf(audecom,dsuivinom) / ( 1 - $private(coefking) ) ]
         set corking [ expr round($corking) ]
         if { $corking > "99999999" } { set corking "99999999" }
         if { $corking < "-99999999" } { set corking "-99999999" }
         tel$audace(telNo) king $corking
      } else {
         tel$audace(telNo) king "99999999"
      }
      after 1000 ::confAudecomKing::Clock_et_King
   }
}

###### Fin du namespace confAudecomKing ######

#
# Description : Fenetre de configuration du suivi d'objets mobiles pour la monture AudeCom
#

namespace eval ::confAudecomMobile {
}

#
# ::confAudecomMobile::init
# Initialise la variable private(...)
#
proc ::confAudecomMobile::init { } {
   variable private

   #--- Initialisation d'une variable
   set private(fenetre,mobile,valider) "0"
}

#
# ::confAudecomMobile::run
# Cree la fenetre de configuration du suivi
#
proc ::confAudecomMobile::run { this } {
   variable This

   set This $this
   createDialog
   tkwait visibility $This
}

#
# ::confAudecomMobile::ok
# Fonction appelee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
# et fermer la fenetre de configuration du suivi
#
proc ::confAudecomMobile::ok { } {
   variable private

   set private(fenetre,mobile,valider) "1"
   ::confAudecomMobile::appliquer
   ::confAudecomMobile::fermer
}

#
# ::confAudecomMobile::appliquer
# Fonction 'Appliquer' pour memoriser et appliquer la configuration
#
proc ::confAudecomMobile::appliquer { } {
   ::confAudecomMobile::widgetToConf
}

#
# ::confAudecomMobile::fermer
# Fonction appellee lors de l'appui sur le bouton 'Annuler'
#
proc ::confAudecomMobile::fermer { } {
   variable This

   destroy $This
}

#
# ::confAudecomMobile::griser
# Fonction destinee a inhiber l'affichage de la derive
#
proc ::confAudecomMobile::griser { } {
   variable This

   $This.vitmotad configure -state disabled
   $This.vitmotdec configure -state disabled
}

#
# ::confAudecomMobile::activer
# Fonction destinee a activer l'affichage de la derive
#
proc ::confAudecomMobile::activer { } {
   variable This

   $This.vitmotad configure -state normal
   $This.vitmotdec configure -state normal
}

#
# ::confAudecomMobile::createDialog
# Creation de l'interface graphique
#
proc ::confAudecomMobile::createDialog { } {
   variable This
   variable private
   global audace caption

   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm title $This $caption(audecomconfig,para_mobile)
   set posx_audecom_para_mobile [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
   set posy_audecom_para_mobile [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_audecom_para_mobile + 0 ]+[ expr $posy_audecom_para_mobile + 70 ]
   wm resizable $This 0 0

   #--- On utilise les valeurs contenues dans le tableau private pour l'initialisation
   ::confAudecomMobile::confToWidget

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
   pack $This.frame6 -in $This.frame5 -side left -fill both -expand 1

   frame $This.frame7 -borderwidth 0 -relief raised
   pack $This.frame7 -in $This.frame5 -side left -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame7 -side top -fill both -expand 1

   frame $This.frame9 -borderwidth 0 -relief raised
   pack $This.frame9 -in $This.frame7 -side top -fill both -expand 1

   #--- Radio-bouton Lune
   radiobutton $This.rad1 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(audecomconfig,para_mobile_lune)" \
      -value 0 -variable ::confAudecomMobile::private(audecom,type) \
      -command { ::confAudecomMobile::griser }
   pack $This.rad1 -in $This.frame3 -anchor center -side left -padx 10 -pady 5

   #--- Radio-bouton Soleil
   radiobutton $This.rad2 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(audecomconfig,para_mobile_soleil)" \
      -value 1 -variable ::confAudecomMobile::private(audecom,type) \
      -command { ::confAudecomMobile::griser }
   pack $This.rad2 -in $This.frame4 -anchor center -side left -padx 10 -pady 5

   #--- Radio-bouton comete, etc.
   radiobutton $This.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
      -text "$caption(audecomconfig,para_mobile_comete)" \
      -value 2 -variable ::confAudecomMobile::private(audecom,type) \
      -command { ::confAudecomMobile::activer }
   pack $This.rad3 -in $This.frame6 -anchor n -side left -padx 10 -pady 5

   #--- Cree la zone a renseigner de la vitesse en asension droite
   entry $This.vitmotad -textvariable ::confAudecomMobile::private(audecom,ad) -width 10 -justify center
   pack $This.vitmotad -in $This.frame8 -anchor n -side left -padx 5 -pady 5

   #--- Etiquette vitesse d'ascension droite
   label $This.lab1 -text "$caption(audecomconfig,para_mobile_ad)"
   pack $This.lab1 -in $This.frame8 -anchor n -side left -padx 10 -pady 5

   #--- Cree la zone a renseigner de la vitesse en declinaison
   entry $This.vitmotdec -textvariable ::confAudecomMobile::private(audecom,dec) -width 10 -justify center
   pack $This.vitmotdec -in $This.frame9 -anchor n -side left -padx 5 -pady 5

   #--- Etiquette vitesse de declinaison
   label $This.lab2 -text "$caption(audecomconfig,para_mobile_dec)"
   pack $This.lab2 -in $This.frame9 -anchor n -side left -padx 10 -pady 5

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(audecomconfig,ok)" -width 7 -borderwidth 2 \
      -command { ::confAudecomMobile::ok }
   pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Annuler'
   button $This.but_cancel -text "$caption(audecomconfig,annuler)" -width 10 -borderwidth 2 \
      -command { ::confAudecomMobile::fermer }
   pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree la console texte d'aide
   text $This.lst1 -height 6 -borderwidth 1 -relief sunken -wrap word
   pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
   $This.lst1 insert end " \n"
   $This.lst1 insert end "$caption(audecomconfig,para_mobile,aide0)\n"

   #--- Entry actives ou non
   if { $private(audecom,type) != "2" } {
      ::confAudecomMobile::griser
   } else {
      ::confAudecomMobile::activer
   }

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#
# ::confAudecomMobile::confToWidget
# Utilisation des valeurs contenues dans le tableau ::audecom::private(...) pour l'initialisation
#
proc ::confAudecomMobile::confToWidget { } {
   variable private

   set private(audecom,ad)   $::audecom::private(ad)
   set private(audecom,dec)  $::audecom::private(dec)
   set private(audecom,type) $::audecom::private(type)
}

#
# ::confAudecomMobile::widgetToConf
# Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau conf(...)
#
proc ::confAudecomMobile::widgetToConf { } {
   variable private

   set ::audecom::private(ad)   $private(audecom,ad)
   set ::audecom::private(dec)  $private(audecom,dec)
   set ::audecom::private(type) $private(audecom,type)
}

###### Fin du namespace confAudecomMobile ######

#--- Chargements au demarrage
::confAudecomMot::init
::confAudecomMobile::init


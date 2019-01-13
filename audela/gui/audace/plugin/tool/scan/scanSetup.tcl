#
# Fichier : scanSetup.tcl
# Description : Configuration de la temporisation entre l'arret du moteur d'AD et le debut de la pose du scan
# Auteur : Robert DELMAS
# Mise à jour $Id: scanSetup.tcl 6795 2011-02-26 16:05:27Z michelpujol $
#

namespace eval ::scanSetup {
}

#------------------------------------------------------------
# init
#    Chargement des captions
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::init { } {
   global audace

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) tool scan scanSetup.cap ]
}

#------------------------------------------------------------
# initToConf
#    Initialisation des variables de configuration
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::initToConf { } {
   variable parametres

   #--- Creation des variables de la boite de configuration si elles n'existent pas
   if { ! [ info exists ::scan::parametres(scan,delai) ] }  { set ::scan::parametres(scan,delai)   "3" }
   if { ! [ info exists ::scan::parametres(scan,active) ] } { set ::scan::parametres(scan,active)  "1" }
}

#------------------------------------------------------------
# confToWidget
#    Charge la configuration dans des variables locales
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::confToWidget { } {
   variable parametres
   global panneau

   #--- confToWidget
   set panneau(scan,delai)  $::scan::parametres(scan,delai)
   set panneau(scan,active) $::scan::parametres(scan,active)
}

#------------------------------------------------------------
# run
#    Cree la fenetre de configuration
#
# Parametres :
#    this = Chemin de la fenetre
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::run { this } {
   variable This

   set This $this
   createDialog
   tkwait visibility $This
}

#------------------------------------------------------------
# ok
#    Fonction appellee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
#    et fermer la fenetre de configuration
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::ok { } {
   appliquer
   fermer
}

#------------------------------------------------------------
# appliquer
#    Fonction 'Appliquer' pour memoriser et appliquer la configuration
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::appliquer { } {
   widgetToConf
}

#------------------------------------------------------------
# afficheAide
#    Fonction appellee lors de l'appui sur le bouton 'Aide'
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::afficheAide { } {
   ::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::scan::getPluginType ] ] \
      [ ::scan::getPluginDirectory ] scanSetup.htm
}

#------------------------------------------------------------
# fermer
#    Fonction appellee lors de l'appui sur le bouton 'Fermer'
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::fermer { } {
   variable This

   #--- Je detruis la fenetre
   destroy $This
}

#------------------------------------------------------------
# createDialog
#    Creation de l'interface graphique
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::createDialog { } {
   variable This
   global audace caption conf panneau

   #---
   if { [winfo exists $This] } {
      wm withdraw $This
      wm deiconify $This
      focus $This
      return
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   set posx_config [ lindex [ split [ wm geometry $audace(base) ] "+" ] 1 ]
   set posy_config [ lindex [ split [ wm geometry $audace(base) ] "+" ] 2 ]
   wm geometry $This +[ expr $posx_config + 145 ]+[ expr $posy_config + 60 ]
   wm resizable $This 0 0
   wm title $This $caption(scanSetup,configuration)
   wm protocol $This WM_DELETE_WINDOW ::scanSetup::fermer

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
   pack $This.frame6 -in $This.frame3 -side top -fill both -expand 1

   #--- Label de l'en-tete FITS
   label $This.lab -text "$caption(scanSetup,en-tete_fits)"
   pack $This.lab -in $This.frame6 -side left -padx 6

   #--- Bouton d'acces aux mots cles
   button $This.but1 -text "$caption(scanSetup,mots_cles)" \
      -command "::keyword::run $audace(visuNo) ::conf(scan,keywordConfigName)"
   pack $This.but1 -in $This.frame6 -side left -padx 6 -pady 10 -ipadx 20

   #--- Label du nom de la configuration de l'en-tete FITS
   entry $This.labNom -textvariable ::conf(scan,keywordConfigName) \
      -state readonly -takefocus 0 -justify center
   pack $This.labNom -in $This.frame6 -side left -padx 6

   #--- Commentaire sur la temporisation
   label $This.lab1 -text "$caption(scanSetup,titre)"
   pack $This.lab1 -in $This.frame3 -anchor w -side top -padx 10 -pady 3

   #--- Radio-bouton 'sans temporisation'
   radiobutton $This.rad1 -anchor nw -highlightthickness 0 \
      -text "$caption(scanSetup,sans_scan)" -value 0 -variable panneau(scan,active)
   pack $This.rad1 -in $This.frame4 -anchor w -side top -padx 30 -pady 3

   #--- Radio-bouton 'avec temporisation'
   radiobutton $This.rad2 -anchor nw -highlightthickness 0 \
      -text "$caption(scanSetup,avec_scan)" -value 1 -variable panneau(scan,active)
   pack $This.rad2 -in $This.frame4 -anchor w -side top -padx 30 -pady 3

   #--- Cree la zone a renseigner du delai entre l'arret du moteur d'A.D. et le debut de la pose
   label $This.lab3 -text "$caption(scanSetup,delai)"
   pack $This.lab3 -in $This.frame5 -anchor w -side left -padx 10 -pady 3

   entry $This.delai -textvariable panneau(scan,delai) -width 3 -justify center
   pack $This.delai -in $This.frame5 -anchor w -side left -padx 0 -pady 2

   label $This.lab4 -text "$caption(scanSetup,seconde)"
   pack $This.lab4 -in $This.frame5 -anchor w -side left -padx 0 -pady 3

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(scanSetup,ok)" -width 7 -borderwidth 2 \
      -command { ::scanSetup::ok }
   if { $conf(ok+appliquer) == "1" } {
      pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5
   }

   #--- Cree le bouton 'Appliquer'
   button $This.but_appliquer -text "$caption(scanSetup,appliquer)" -width 8 -borderwidth 2 \
      -command { ::scanSetup::appliquer }
   pack $This.but_appliquer -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Fermer'
   button $This.but_fermer -text "$caption(scanSetup,fermer)" -width 7 -borderwidth 2 \
      -command { ::scanSetup::fermer }
   pack $This.but_fermer -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Aide'
   button $This.but_aide -text "$caption(scanSetup,aide)" -width 7 -borderwidth 2 \
      -command { ::scanSetup::afficheAide }
   pack $This.but_aide -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#------------------------------------------------------------
# widgetToConf
#    Acquisition de la configuration
#
# Parametres :
#    Aucun
# Return :
#    Rien
#------------------------------------------------------------
proc ::scanSetup::widgetToConf { } {
   variable parametres
   global panneau

   set ::scan::parametres(scan,delai)  $panneau(scan,delai)
   set ::scan::parametres(scan,active) $panneau(scan,active)
}

#--- Initialisation au demarrage
::scanSetup::init


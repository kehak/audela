#
# Fichier : temmaconfig.tcl
# Description : Fenetre de configuration pour le parametrage du suivi d'objets mobiles pour le telescope Temma
# Auteur : Robert DELMAS
# Mise à jour $Id: temmaconfig.tcl 13482 2016-03-23 21:32:15Z rzachantke $
#

namespace eval ::confTemmaMobile {

   #
   # ::confTemmaMobile::init (est lance automatiquement au chargement de ce fichier tcl)
   # Initialise les variables caption(...)
   #
   proc init { } {
      global audace

      #--- Charge le fichier caption
      source [ file join $audace(rep_plugin) mount temma temmaconfig.cap ]
   }

   #
   # ::confTemmaMobile::run this args
   # Cree la fenetre de configuration des parametres de suivi
   # this = chemin de la fenetre
   #
   proc run { this } {
      variable This

      set This $this
      createDialog
      tkwait visibility $This
   }

   #
   # ::confTemmaMobile::ok
   # Fonction appelee lors de l'appui sur le bouton 'OK' pour appliquer la configuration
   # et fermer la fenetre des parametres
   #
   proc ok { } {
      appliquer
      fermer
   }

   #
   # ::confTemmaMobile::appliquer
   # Fonction 'Appliquer' pour memoriser et appliquer la configuration
   #
   proc appliquer { } {
      widgetToConf
   }

   #
   # ::confTemmaMobile::fermer
   # Fonction appellee lors de l'appui sur le bouton 'Annuler'
   #
   proc fermer { } {
      variable This

      destroy $This
   }

   #
   # ::confTemmaMobile::griser
   # Fonction destinee a inhiber l'affichage de derive
   #
   proc griser { this } {
      variable This

      set This $this
      $This.suivi_ad configure -state disabled
      $This.suivi_dec configure -state disabled

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

   #
   # ::confTemmaMobile::activer
   # Fonction destinee a activer l'affichage de derive
   #
   proc activer { this } {
      variable This

      set This $this
      $This.suivi_ad configure -state normal
      $This.suivi_dec configure -state normal

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This
   }

  proc createDialog { } {
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
      wm title $This $caption(temmaconfig,para_mobile)
      set posx_temma_para_mobile [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 1 ]
      set posy_temma_para_mobile [ lindex [ split [ wm geometry $audace(base).confTel ] "+" ] 2 ]
      wm geometry $This +[ expr $posx_temma_para_mobile - 30 ]+[ expr $posy_temma_para_mobile + 70 ]
      wm resizable $This 0 0

      #--- On utilise les valeurs contenues dans le tableau ::temma::private pour l'initialisation
      set private(temma,suivi_ad)  $::temma::private(suivi_ad)
      set private(temma,suivi_dec) $::temma::private(suivi_dec)
      set private(temma,type)      $::temma::private(type)

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
      pack $This.frame6 -in $This.frame5 -side right -fill both -expand 1

      frame $This.frame7 -borderwidth 0 -relief raised
      pack $This.frame7 -in $This.frame6 -side top -fill both -expand 1

      frame $This.frame8 -borderwidth 0 -relief raised
      pack $This.frame8 -in $This.frame6 -side top -fill both -expand 1

      #--- Radio-bouton etoile (suivi sideral)
      radiobutton $This.rad4 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(temmaconfig,para_mobile_etoile)" \
         -value 0 -variable ::confTemmaMobile::private(temma,type) \
         -command {
            ::confTemmaMobile::griser "$audace(base).confTemmaMobile"
         }
      pack $This.rad4 -in $This.frame3 -anchor s -side left -padx 10 -pady 5

      #--- Radio-bouton Soleil (suivi solaire)
      radiobutton $This.rad3a -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(temmaconfig,para_mobile_soleil)" \
         -value 2 -variable ::confTemmaMobile::private(temma,type) \
         -command {
            ::confTemmaMobile::griser "$audace(base).confTemmaMobile"
         }
      pack $This.rad3a -in $This.frame4 -anchor s -side left -padx 10 -pady 5

      #--- Radio-bouton comete, etc. (suivi cometaire)
      radiobutton $This.rad3 -anchor nw -highlightthickness 0 -padx 0 -pady 0 \
         -text "$caption(temmaconfig,para_mobile_comete)" \
         -value 1 -variable ::confTemmaMobile::private(temma,type) \
         -command {
            ::confTemmaMobile::activer "$audace(base).confTemmaMobile"
         }
      pack $This.rad3 -in $This.frame5 -anchor n -side left -padx 10 -pady 5

      #--- Cree la zone a renseigner de la vitesse en ascension droite
      entry $This.suivi_ad -textvariable ::confTemmaMobile::private(temma,suivi_ad) -width 10 -justify center
      pack $This.suivi_ad -in $This.frame7 -anchor n -side left -padx 5 -pady 5

      #--- Etiquette vitesse d'ascension droite
      label $This.lab_1 -text "$caption(temmaconfig,para_mobile_ad)"
      pack $This.lab_1 -in $This.frame7 -anchor n -side left -padx 10 -pady 5

      #--- Cree la zone a renseigner de la vitesse en declinaison
      entry $This.suivi_dec -textvariable ::confTemmaMobile::private(temma,suivi_dec) -width 10 -justify center
      pack $This.suivi_dec -in $This.frame8 -anchor n -side left -padx 5 -pady 5

      #--- Etiquette vitesse de declinaison
      label $This.lab_2 -text "$caption(temmaconfig,para_mobile_dec)"
      pack $This.lab_2 -in $This.frame8 -anchor n -side left -padx 10 -pady 5

      #--- Cree le bouton 'OK'
      button $This.but_ok -text "$caption(temmaconfig,ok)" -width 7 -borderwidth 2 \
         -command { ::confTemmaMobile::ok }
      pack $This.but_ok -in $This.frame2 -side left -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree le bouton 'Annuler'
      button $This.but_cancel -text "$caption(temmaconfig,annuler)" -width 10 -borderwidth 2 \
         -command { ::confTemmaMobile::fermer }
      pack $This.but_cancel -in $This.frame2 -side right -anchor w -padx 3 -pady 3 -ipady 5

      #--- Cree la console texte d'aide
      text $This.lst1 -height 14 -borderwidth 1 -relief sunken -wrap word
      pack $This.lst1 -in $This -fill x -side bottom -padx 3 -pady 3
      $This.lst1 insert end "$caption(temmaconfig,para_mobile,aide0)\n"

      #--- Entry actives ou non
      if { $private(temma,type) == "0" } {
         ::confTemmaMobile::griser "$audace(base).confTemmaMobile"
      } else {
         ::confTemmaMobile::activer "$audace(base).confTemmaMobile"
      }

      #--- La fenetre est active
      focus $This

      #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
      bind $This <Key-F1> { ::console::GiveFocus }

      #--- Mise a jour dynamique des couleurs
      ::confColor::applyColor $This

   }

   #
   # ::confTemmaMobile::widgetToConf
   # Acquisition de la configuration, c'est a dire isolation des differentes variables dans le tableau ::temma::private(...)
   #
   proc widgetToConf { } {
      variable This
      variable private

      #--- Bornage de la correction
      if { $private(temma,suivi_ad) > "21541" } {
         set private(temma,suivi_ad) "21541"
         $This.suivi_ad configure -textvariable ::confTemmaMobile::private(temma,suivi_ad)
      }
      if { $private(temma,suivi_ad) < "-21541" } {
         set private(temma,suivi_ad) "-21541"
         $This.suivi_ad configure -textvariable ::confTemmaMobile::private(temma,suivi_ad)
      }
      if { $private(temma,suivi_dec) > "600" } {
         set private(temma,suivi_dec) "600"
         $This.suivi_dec configure -textvariable ::confTemmaMobile::private(temma,suivi_dec)
      }
      if { $private(temma,suivi_dec) < "-600" } {
         set private(temma,suivi_dec) "-600"
         $This.suivi_dec configure -textvariable ::confTemmaMobile::private(temma,suivi_dec)
      }

      #--- Transposition de variables
      set ::temma::private(suivi_ad)  $private(temma,suivi_ad)
      set ::temma::private(suivi_dec) $private(temma,suivi_dec)
      set ::temma::private(type)      $private(temma,type)
   }
}

#--- Chargement au demarrage
::confTemmaMobile::init


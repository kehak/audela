#
# Fichier : obtu_pierre.tcl
# Description : Permet le parametrage de l'obturateur a base de servo pour modelisme
# Auteurs : Pierre Thierry et Robert DELMAS
# Mise à jour $Id: obtu_pierre.tcl 13301 2016-03-05 10:00:49Z robertdelmas $
#

namespace eval ::Obtu_Pierre {
}

#
# Obtu_Pierre::run camNo
# Lance le parametrage de l'obturateur
#
proc ::Obtu_Pierre::run { camNo } {
   variable This
   variable parametres
   global confcolor

   #--- Chargement du fichier de configuration
   ::Obtu_Pierre::Chargement_Var

   #--- Initialisation des variables
   set confcolor(obtu,vala)    "$parametres(obtu,vala)"
   set confcolor(obtu,valb)    "$parametres(obtu,valb)"
   set confcolor(obtu,valc)    "$parametres(obtu,valc)"
   set confcolor(obtu,vald)    "0"
   set confcolor(obtu,vale)    "$parametres(obtu,vale)"
   set confcolor(obtu,valt)    "$parametres(obtu,valt)"
   set confcolor(obtu,valflag) "$parametres(obtu,valflag)"

   #--- Creation de la fenetre de configuration
   createDialog $camNo
   tkwait visibility $This
}

#
# Obtu_Pierre::valider camNo
# Fonction appellee lors de l'appui sur le bouton Valider
#
proc ::Obtu_Pierre::valider { camNo } {
   global confcolor

   #---
   if { $confcolor(obtu,vald) == "1" } {
      catch {
         cam$camNo obtupierre $confcolor(obtu,vala) $confcolor(obtu,valb) $confcolor(obtu,valc) \
            $confcolor(obtu,vald) $confcolor(obtu,vale) $confcolor(obtu,valt) $confcolor(obtu,valflag)
      }
   } elseif { $confcolor(obtu,vald) == "2" } {
      catch {
         cam$camNo obtupierre $confcolor(obtu,valb) $confcolor(obtu,valb) $confcolor(obtu,valb) \
            $confcolor(obtu,vald) $confcolor(obtu,vale) $confcolor(obtu,valt) $confcolor(obtu,valflag)
      }
   } elseif { $confcolor(obtu,vald) == "3" } {
      catch {
         cam$camNo obtupierre $confcolor(obtu,vala) $confcolor(obtu,vala) $confcolor(obtu,vala) \
            $confcolor(obtu,vald) $confcolor(obtu,vale) $confcolor(obtu,valt) $confcolor(obtu,valflag)
      }
   }
   ::Obtu_Pierre::Enregistrement_Var
   ::Obtu_Pierre::fermer
}

#
# Obtu_Pierre::fermer
# Fonction appellee lors de l'appui sur la croix en haut a droite
#
proc ::Obtu_Pierre::fermer { } {
   variable This

   destroy $This
}

#
# Obtu_Pierre::Chargement_Var
# Chargement des variables de configuration
#
proc ::Obtu_Pierre::Chargement_Var { } {
   variable parametres
   global confcolor

   #--- Ouverture du fichier de parametres
   if { $confcolor(obtu_pierre) == "0" } {
      set fichier [ file join $::audace(rep_home) obtu_pierre_color.ini ]
   } elseif { $confcolor(obtu_pierre) == "1" } {
      set fichier [ file join $::audace(rep_home) obtu_pierre_nb.ini ]
   }
   if { [ file exists $fichier ] } {
      source $fichier
   }
   if { ! [ info exists parametres(obtu,vala) ] }    { set parametres(obtu,vala)    "1070" }
   if { ! [ info exists parametres(obtu,valb) ] }    { set parametres(obtu,valb)    "1175" }
   if { ! [ info exists parametres(obtu,valc) ] }    { set parametres(obtu,valc)    "1280" }
   if { ! [ info exists parametres(obtu,vale) ] }    { set parametres(obtu,vale)    "0" }
   if { ! [ info exists parametres(obtu,valt) ] }    { set parametres(obtu,valt)    "15" }
   if { ! [ info exists parametres(obtu,valflag) ] } { set parametres(obtu,valflag) "1" }
}

#
# Obtu_Pierre::Enregistrement_Var
# Enregistrement des variables de configuration
#
proc ::Obtu_Pierre::Enregistrement_Var { } {
   variable parametres
   global confcolor

   set parametres(obtu,vala)    "$confcolor(obtu,vala)"
   set parametres(obtu,valb)    "$confcolor(obtu,valb)"
   set parametres(obtu,valc)    "$confcolor(obtu,valc)"
   set parametres(obtu,vale)    "$confcolor(obtu,vale)"
   set parametres(obtu,valt)    "$confcolor(obtu,valt)"
   set parametres(obtu,valflag) "$confcolor(obtu,valflag)"

   #--- Sauvegarde des parametres
   catch {
      if { $confcolor(obtu_pierre) == "0" } {
         set nom_fichier [ file join $::audace(rep_home) obtu_pierre_color.ini ]
      } elseif { $confcolor(obtu_pierre) == "1" } {
         set nom_fichier [ file join $::audace(rep_home) obtu_pierre_nb.ini ]
      }
      if [ catch { open $nom_fichier w } fichier ] {
         #---
      } else {
         foreach { a b } [ array get parametres ] {
            puts $fichier "set parametres($a) \"$b\""
      }
         close $fichier
      }
   }
}

#
# Obtu_Pierre::createDialog
# Cree la fenetre de parametrage de l'obturateur
#
proc ::Obtu_Pierre::createDialog { camNo } {
   variable This
   global audace caption confcolor

   #---
   set This "$audace(base).obtu_pierre"

   #---
   if { [ winfo exists $This ] } {
      wm withdraw $This
      wm deiconify $This
      $This.frame2.ent configure -state disabled
      $This.frame3.ent configure -state disabled
      $This.frame4.ent configure -state disabled
      focus $This
      return
   }

   #--- Chargement des captions
   source [ file join $audace(rep_plugin) camera audine obtu_pierre.cap ]

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class toplevel
   wm geometry $This +450+100
   wm resizable $This 0 0
   wm title $This $caption(obtu_pierre,title)

   #--- La nouvelle fenetre est active
   focus $This

   #--- Cree un frame pour les canvas d'affichage
   frame $This.frame0 \
      -borderwidth 0 -cursor arrow
   pack $This.frame0 \
      -in $This -anchor nw -side top -expand 0 -fill x

      #--- Cree le label du titre
      label $This.frame0.lab \
         -text "$caption(obtu_pierre,title_pth)"
      pack $This.frame0.lab \
         -in $This.frame0 -side top -anchor center \
         -padx 3 -pady 3

   #--- Cree un frame
   frame $This.frame1 \
      -borderwidth 0 -cursor arrow
   pack $This.frame1 \
      -in $This -anchor center -side top -expand 0 -fill x

      radiobutton $This.frame1.rad1 -anchor nw -highlightthickness 0 -text "$caption(obtu_pierre,synchro)" \
         -value 1 -variable confcolor(obtu,vald) -padx 0 -pady 0 \
         -command {
            if { $confcolor(obtu,vald) == "1" } {
               $::Obtu_Pierre::This.frame2.ent configure -state normal
               $::Obtu_Pierre::This.frame3.ent configure -state normal
               $::Obtu_Pierre::This.frame4.ent configure -state normal
               pack $::Obtu_Pierre::This.button.but_valid \
                  -in $::Obtu_Pierre::This.button -side left -anchor center \
                  -padx 30 -pady 10 -ipadx 5 -ipady 5
            }
         }
      pack $This.frame1.rad1 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
      radiobutton $This.frame1.rad2 -anchor nw -highlightthickness 0 -text "$caption(obtu_pierre,ouvert)" \
         -value 2 -variable confcolor(obtu,vald) -padx 0 -pady 0 \
         -command {
            if { $confcolor(obtu,vald) == "2" } {
               $::Obtu_Pierre::This.frame2.ent configure -state disabled
               $::Obtu_Pierre::This.frame3.ent configure -state normal
               $::Obtu_Pierre::This.frame4.ent configure -state disabled
               pack $::Obtu_Pierre::This.button.but_valid \
                  -in $::Obtu_Pierre::This.button -side left -anchor center \
                  -padx 30 -pady 10 -ipadx 5 -ipady 5
            }
         }
      pack $This.frame1.rad2 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3
      radiobutton $This.frame1.rad3 -anchor nw -highlightthickness 0 -text "$caption(obtu_pierre,ferme)" \
         -value 3 -variable confcolor(obtu,vald) -padx 0 -pady 0 \
         -command {
            if { $confcolor(obtu,vald) == "3" } {
               $::Obtu_Pierre::This.frame2.ent configure -state normal
               $::Obtu_Pierre::This.frame3.ent configure -state disabled
               $::Obtu_Pierre::This.frame4.ent configure -state disabled
               pack $::Obtu_Pierre::This.button.but_valid \
                  -in $::Obtu_Pierre::This.button -side left -anchor center \
                  -padx 30 -pady 10 -ipadx 5 -ipady 5
            }
         }
      pack $This.frame1.rad3 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.frame2 \
      -borderwidth 0 -cursor arrow
   pack $This.frame2 \
      -in $This -anchor center -side top -expand 0 -fill x

      #--- Cree le label
      label $This.frame2.lab \
         -text "$caption(obtu_pierre,a)"
      pack $This.frame2.lab \
         -in $This.frame2 -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree l'entry
      entry $This.frame2.ent \
         -textvariable confcolor(obtu,vala) -state disabled
      pack $This.frame2.ent \
         -in $This.frame2 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.frame3 \
      -borderwidth 0 -cursor arrow
   pack $This.frame3 \
      -in $This -anchor center -side top -expand 0 -fill x

      #--- Cree le label
      label $This.frame3.lab \
         -text "$caption(obtu_pierre,b)"
      pack $This.frame3.lab \
         -in $This.frame3 -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree l'entry
      entry $This.frame3.ent \
         -textvariable confcolor(obtu,valb) -state disabled
      pack $This.frame3.ent \
         -in $This.frame3 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.frame4 \
      -borderwidth 0 -cursor arrow
   pack $This.frame4 \
      -in $This -anchor center -side top -expand 0 -fill x

      #--- Cree le label
      label $This.frame4.lab \
         -text "$caption(obtu_pierre,c)"
      pack $This.frame4.lab \
         -in $This.frame4 -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree l'entry
      entry $This.frame4.ent \
         -textvariable confcolor(obtu,valc) -state disabled
      pack $This.frame4.ent \
         -in $This.frame4 -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.frame5 \
      -borderwidth 0 -cursor arrow
   pack $This.frame5 \
      -in $This -anchor center -side top -expand 0 -fill x

      #--- Cree le label
      label $This.frame5.lab \
         -text "$caption(obtu_pierre,e)"
      pack $This.frame5.lab \
         -in $This.frame5 -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree l'entry
      entry $This.frame5.ent \
         -textvariable confcolor(obtu,vale) -width 50
      pack $This.frame5.ent \
         -in $This.frame5 -side left -anchor center -expand 1 \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.framet \
      -borderwidth 0 -cursor arrow
   pack $This.framet \
      -in $This -anchor center -side top -expand 0 -fill x

      #--- Cree le label
      label $This.framet.lab \
         -text "$caption(obtu_pierre,t)"
      pack $This.framet.lab \
         -in $This.framet -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree l'entry
      entry $This.framet.ent \
         -textvariable confcolor(obtu,valt)
      pack $This.framet.ent \
         -in $This.framet -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.frameflag \
      -borderwidth 0 -cursor arrow
   pack $This.frameflag \
      -in $This -anchor center -side top -expand 0 -fill x

      #--- Cree le label
      label $This.frameflag.lab \
         -text "$caption(obtu_pierre,flag)"
      pack $This.frameflag.lab \
         -in $This.frameflag -side left -anchor center \
         -padx 3 -pady 3

      #--- Cree l'entry
      entry $This.frameflag.ent \
         -textvariable confcolor(obtu,valflag)
      pack $This.frameflag.ent \
         -in $This.frameflag -side left -anchor center -expand 1 -fill x \
         -padx 10 -pady 3

   #--- Cree un frame
   frame $This.button \
      -borderwidth 0 -cursor arrow
   pack $This.button \
      -in $This -anchor center -side bottom -expand 0 -fill x

      #--- Cree le bouton 'Valider ces valeurs'
      button $This.button.but_valid \
         -text "$caption(obtu_pierre,valider)" -borderwidth 2 \
         -command "::Obtu_Pierre::valider $camNo"
      if { $confcolor(obtu,vald) != "0" } {
         pack $This.button.but_valid \
            -in $This.button -side left -anchor center \
            -padx 30 -pady 10 -ipadx 5 -ipady 5
      }

      #--- Cree le bouton 'Fermer'
      button $This.button.but_fermer \
         -text "$caption(obtu_pierre,fermer)" -borderwidth 2 \
         -command { ::Obtu_Pierre::fermer }
      pack $This.button.but_fermer \
         -in $This.button -side right -anchor center \
         -padx 30 -pady 10 -ipadx 5 -ipady 5

   #--- Detruit la fenetre avec la croix en haut a droite
   bind $This <Destroy> { ::Obtu_Pierre::fermer }

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}


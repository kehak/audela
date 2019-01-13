#
# Fichier : lhires.tcl
# Description : Gere un focuser sur port parallele ou quickremote
# Auteur : Michel PUJOL
# Mise à jour $Id: lhires.tcl 12382 2015-12-17 18:39:01Z robertdelmas $
#

namespace eval ::lhires {
   package provide lhires 1.0

   #--- Charge le fichier caption pour recuperer le titre utilise par getPluginTitle
   source [ file join [file dirname [info script]] lhires.cap ]
}

#------------------------------------------------------------
#  ::lhires::getPluginTitle
#     retourne le titre du plugin dans la langue de l'utilisateur
#
#  return "Titre du plugin"
#------------------------------------------------------------
proc ::lhires::getPluginTitle { } {
   global caption

   return "$caption(lhires,label)"
}

#------------------------------------------------------------
#  ::lhires::getPluginType
#     retourne le type de plugin
#
#  return "equipment"
#------------------------------------------------------------
proc ::lhires::getPluginType { } {
   return "spectroscope"
}

#------------------------------------------------------------
#  ::lhires::getPluginOS
#     retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::lhires::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
#  ::lhires::getPluginProperty
#     retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete , ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::lhires::getPluginProperty { propertyName } {
   switch $propertyName {
      function { return "acquisition" }
   }
}

#------------------------------------------------------------
#  ::lhires::initPlugin (est lance automatiquement au chargement de ce fichier tcl)
#     initialise le plugin
#------------------------------------------------------------
proc ::lhires::initPlugin { } {
   variable private
   global conf

   #--- Cree les variables dans conf(...) si elles n'existent pas
   if { ! [ info exists conf(lhires,link) ] }        { set conf(lhires,link)       "" }
   if { ! [ info exists conf(lhires,bitLampOn) ] }   { set conf(lhires,bitLampOn)  "6" }
   if { ! [ info exists conf(lhires,bitLampOff) ] }  { set conf(lhires,bitLampOff) "7" }
   if { ! [ info exists conf(lhires,start) ] }       { set conf(lhires,start)      "0" }

   #--- variables locales
   set private(linkNo) "0"
}

#------------------------------------------------------------
#  ::lhires::getPluginHelp
#     retourne la documentation du equipement
#
#  return "nom_equipement.htm"
#------------------------------------------------------------
proc ::lhires::getPluginHelp { } {
   return "lhires.htm"
}

#------------------------------------------------------------
#  ::lhires::getStartFlag
#     retourne l'indicateur de lancement au demarrage de Audela
#
#  return 0 ou 1
#------------------------------------------------------------
proc ::lhires::getStartFlag { } {
   return $::conf(lhires,start)
}

#------------------------------------------------------------
#  ::lhires::fillConfigPage
#     affiche la frame configuration du focuseur
#
#  return rien
#------------------------------------------------------------
proc ::lhires::fillConfigPage { frm } {
   variable widget
   global caption conf

   #--- je copie les donnees de conf(...) dans les variables widget(...)
   set widget(link)         $conf(lhires,link)
   set widget(bitLampOn)     $conf(lhires,bitLampOn)
   set widget(bitLampOff) $conf(lhires,bitLampOff)

   #--- Je constitue la liste des liaisons pour le focuser
   set linkList [ ::confLink::getLinkLabels {"parallelport" "quickremote"} ]

   #--- Je verifie le contenu de la liste
   if { [llength $linkList ] > 0 } {
      #--- si la liste n'est pas vide,
      #--- je verifie que la valeur par defaut existe dans la liste
      if { [lsearch -exact $linkList $widget(link)] == -1 } {
         #--- si la valeur par defaut n'existe pas dans la liste,
         #--- je la remplace par le premier item de la liste
         set widget(link) [lindex $linkList 0]
      }
   } else {
      #--- si la liste est vide
      #--- je desactive l'option focuser
      set widget(link) ""
   }

   #--- Creation des differents frames
   frame $frm.frame1 -borderwidth 0 -relief raised

      #--- Label de la liaison
      label $frm.frame1.labelLink -text "$caption(lhires,link)"
      grid $frm.frame1.labelLink -row 0 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix de la liaison
      ComboBox $frm.frame1.link \
         -width 13              \
         -height [ llength $linkList ] \
         -relief sunken         \
         -borderwidth 1         \
         -editable 0            \
         -textvariable ::lhires::widget(link) \
         -values $linkList
      grid $frm.frame1.link -row 0 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Bouton de configuration de la liaison
      button $frm.frame1.configure -text "$caption(lhires,configure)" -relief raised \
         -command {
            ::confLink::run ::lhires::widget(link) {"parallelport" "quickremote"} $caption(lhires,label)
         }
      grid $frm.frame1.configure -row 0 -column 2 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix du numero du bit pour le demarrage du moteur
      label $frm.frame1.bitDecrLabel -text "$caption(lhires,bitLampOn)"
      grid $frm.frame1.bitDecrLabel -row 1 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

     set bitList [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.frame1.bitStart \
         -width 7                   \
         -height [ llength $bitList ] \
         -relief sunken             \
         -borderwidth 1             \
         -textvariable ::lhires::widget(bitLampOn) \
         -editable 0                \
         -values $bitList
      grid $frm.frame1.bitStart -row 1 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

      #--- Choix du numero du bit pour le sens de rotation du moteur
      label $frm.frame1.bitIncrLabel -text "$caption(lhires,bitLampOff)"
      grid $frm.frame1.bitIncrLabel -row 2 -column 0 -columnspan 1 -rowspan 1 -sticky ewns

      set bitList [ list 0 1 2 3 4 5 6 7 ]
      ComboBox $frm.frame1.bitLampOff \
         -width 7                       \
         -height [ llength $bitList ]   \
         -relief sunken                 \
         -borderwidth 1                 \
         -textvariable ::lhires::widget(bitLampOff) \
         -editable 0                    \
         -values $bitList
      grid $frm.frame1.bitLampOff -row 2 -column 1 -columnspan 1 -rowspan 1 -sticky ewns

   pack $frm.frame1 -side top -fill x

   frame $frm.test -borderwidth 1 -relief raised
      button $frm.test.lampDown -text "$caption(lhires,lampDown)" -relief raised \
         -command "::lhires::move 1"
      button $frm.test.lampUp -text "$caption(lhires,lampUp)" -relief raised \
         -command "::lhires::move 0"
      pack $frm.test.lampDown -side top -padx 3 -pady 3 -fill x
      pack $frm.test.lampUp -side top -padx 3 -pady 3 -fill x
   pack $frm.test -side top -fill none -pady 10

   #--- Frame du checkbutton creer au demarrage
   frame $frm.start -borderwidth 0 -relief flat

     #--- Bouton Arreter
      button $frm.start.stop -text "$caption(lhires,arreter)" -relief raised \
         -command { ::lhires::deletePlugin }
      pack $frm.start.stop -side left -padx 10 -pady 3 -ipadx 10 -expand 1

      checkbutton $frm.start.chk -text "$caption(lhires,creer_au_demarrage)" \
         -highlightthickness 0 -variable conf(lhires,start)
      pack $frm.start.chk -side top -padx 3 -pady 3 -fill x

   pack $frm.start -side bottom -fill x

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $frm
}

#------------------------------------------------------------
#  ::lhires::configurePlugin
#     configure le plugin
#
#  return nothing
#------------------------------------------------------------
proc ::lhires::configurePlugin { } {
   variable widget
   global conf

   #--- copie les variables des widgets dans le tableau conf()
   set conf(lhires,link)         $widget(link)
   set conf(lhires,bitLampOn)    $widget(bitLampOn)
   set conf(lhires,bitLampOff)   $widget(bitLampOff)
}

#------------------------------------------------------------
#  ::lhires::createPlugin
#     demarrerle plugin
#
#  return nothing
#------------------------------------------------------------
proc ::lhires::createPlugin { } {
   variable private
   global conf

   #--- je cree la liaison du focuser
   set private(linkNo) [::confLink::create $conf(lhires,link) [getPluginType] \
     [getPluginTitle] "bits $conf(lhires,bitLampOn),$conf(lhires,bitLampOff)"]

   #--- j'intialise les bits a zero
   link$private(linkNo) bit $conf(lhires,bitLampOff) "0"
   link$private(linkNo) bit $conf(lhires,bitLampOn)  "0"
}

#------------------------------------------------------------
#  ::lhires::deletePlugin
#     arrete le plugin et libere les ressources occupees
#
#  return nothing
#------------------------------------------------------------
proc ::lhires::deletePlugin { } {
   variable private
   global conf

   #--- je ferme la liaison du focuser
   ::confLink::delete $conf(lhires,link) [getPluginType] [getPluginTitle]
   set private(linkNo) "0"
   return
}

#------------------------------------------------------------
#  ::lhires::isReady
#     informe de l'etat de fonctionnement du plugin
#
#  return 1 (ready) , 0 (not ready)
#------------------------------------------------------------
proc ::lhires::isReady { } {
   variable private

   if { $private(linkNo) != "0" } {
      return 1
   } else {
      return 0
   }
}

#==============================================================
# ::lhires::Procedures specifiques du plugin
#==============================================================

#------------------------------------------------------------
#  ::lhires::move
#     si command = "1" , abaisse et allume  la lampe neon
#     si command = "0" , releve et eteint la lampe  neon
#  return
#     0 no error
#     -1  equipment is not ready
#------------------------------------------------------------
proc ::lhires::move { command } {
   variable private
   global conf

   if { [isReady] == 0 } {
      return -1
   }

   switch $command {
      "0" {
         link$private(linkNo) bit $conf(lhires,bitLampOn) "0"
         #--- j'attends au moins 500 ms entre deux commandes (cas du quickremote sous Linux)
         after 500
         link$private(linkNo) bit $conf(lhires,bitLampOff) "1"
         #--- j'attends que le basculement de la lampe soit termine
         after 2000
         #---- je coupe l'alimentation du moteur
         link$private(linkNo) bit $conf(lhires,bitLampOff) "0"
      }
      "1" {
         link$private(linkNo) bit $conf(lhires,bitLampOn) "1"
      }
   }
   return 0
}


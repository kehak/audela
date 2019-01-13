#
## @file foc.tcl
#  @brief Outil pour le contrôle de la focalisation, pour protocoles LX200 et AudeCom et USB_FOCUS
#  @author Alain KLOTZ, Robert DELMAS et Raymond ZACHANTKE
#  $Id: foc.tcl 13610 2016-04-04 14:37:59Z rzachantke $
#

#============================================================
# Declaration du namespace foc
#    initialise le namespace
#============================================================

## @namespace foc
#  @brief Outil pour le contrôle de la focalisation, pour protocoles LX200 et AudeCom et USB_FOCUS
namespace eval ::foc {
   package provide foc 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] foc.cap ]
}

#------------------------------------------------------------
# brief  retourne le titre du plugin dans la langue de l'utilisateur
# return titre du plugin
#
proc ::foc::getPluginTitle { } {
   global caption

   return "$caption(foc,focalisation)"
}

#------------------------------------------------------------
# brief  retourne le nom du fichier d'aide principal
# return nom du fichier d'aide principal
#
proc ::foc::getPluginHelp { } {
   return "foc.htm"
}

#------------------------------------------------------------
# brief  retourne le type de plugin
# return type de plugin
#
proc ::foc::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief  retourne le nom du répertoire du plugin
# return nom du r该rtoire du plugin : "satelupdate"
#
proc ::foc::getPluginDirectory { } {
   return "foc"
}

#------------------------------------------------------------
## @brief  retourne le ou les OS de fonctionnement du plugin
#  @return liste des OS : "Windows Linux Darwin"
#
proc ::foc::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief  retourne les propriétés de l'outil
#
#cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#
#  @param propertyName nom de la propriété
#  @return valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::foc::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "acquisition" }
      subfunction1 { return "focusing" }
      display      { return "panel" }
      default      { return "" }
   }
 }

#------------------------------------------------------------
## @brief  créé une nouvelle instance de l'outil
#  @param base base tk
#  @param visuNo numéro de la visu
#  @return chemin de la fenêtre
#
proc ::foc::createPluginInstance { base { visuNo 1 } } {
   variable private
   variable This

   package require BLT

   source [ file join $::audace(rep_plugin) tool foc foc_HFD.tcl ]
   source [ file join $::audace(rep_plugin) tool foc foc_focuser.tcl ]
   source [ file join $::audace(rep_plugin) tool foc foc_cam.tcl ]
   source [ file join $::audace(rep_plugin) tool foc foc_graph.tcl ]
   source [ file join $::audace(rep_plugin) tool foc foc_sim.tcl ]

   set This $base.foc
   #--   declaration du chemin des fenetres annexes
   set private(panel)         $This
   set private(visufoc)       $This.visufoc           ; # les graphiques
   set private(parafoc)       $This.parafoc           ; # petite fenêtre
   set private(hfd)           $This.hfd               ; # fenêtre HFD
   set private(progress_pose) $This.progress_pose     ; # barre de progression de la pose

   createPanel

   focBuildIF

   return $This
}

#------------------------------------------------------------
## @brief  suppprime l'instance du plugin
#  @param  visuNo numéro de la visu
#
proc ::foc::deletePluginInstance { visuNo } {
   variable This

   #-- Fait par stopTTool ?
   #--  ferme le graphique, la petite fenêtre et la fenêtre HFD en sauvant les positions
   #::foc::closeAllWindows

   if {[winfo exists $This] ==1} {
      destroy $This
   }
}

#------------------------------------------------------------
## @brief  démarre les fonctions de surveillance et d'adaptation
#  @param visuNo numéro de la visu
#
proc ::foc::startTool { visuNo } {

   trace add variable ::conf(telescope) write ::foc::adaptOutilFoc
   trace add variable ::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
   ::foc::adaptOutilFoc
}

#------------------------------------------------------------
## @brief masque le panneau
#  @param visuNo numéro de la visu
#
proc ::foc::stopTool { visuNo } {
   variable This
   global panneau

   #--- Je verifie si une operation est en cours
   if { $panneau(foc,pose_en_cours) == "1" } {
      return -1
   }

   #--- Initialisation du fenetrage
   set camItem [ ::confVisu::getCamItem $::audace(visuNo) ]
   if { [ ::confCam::isReady $camItem ] == "1" } {
      set n1n2 [ cam$::audace(camNo) nbcells ]
      cam$::audace(camNo) window [ list 1 1 [ lindex $n1n2 0 ] [ lindex $n1n2 1 ] ]
   }

   #--- Initialisation des variables et fermeture des fenetres auxiliaires
   set panneau(foc,compteur) "0"
   ::foc::closeAllWindows

   #--- Arret de la surveillance de la variable conf(telescope)
   trace remove variable :::confEqt::private(variablePluginName) write ::foc::adaptOutilFoc
   trace remove variable ::conf(telescope) write ::foc::adaptOutilFoc
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Focalisation"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(foc,graphPosition) définit la position de la fenêtre "Aud'ACE : Focalisation"
#  - conf(foc,hfdPosition)   définit la position de la fenêtre "Focalisation HFD"
#  - conf(foc,position)      définit la position de la fenêtre "Focalisation"
#  - conf(foc,attente)       définit le délai de stabilisation
#
proc ::foc::initConf { } {
   global conf

   if { ! [ info exists conf(foc,graphPosition) ] } { set conf(foc,graphPosition) "+200+0"  }
   if { ! [ info exists conf(foc,hfdPosition) ] }   { set conf(foc,hfdPosition)   "+500+75" }
   if { ! [ info exists conf(foc,position) ] }      { set conf(foc,position)      "+120+315" }
   if { ! [ info exists conf(foc,attente) ] }       { set conf(foc,attente)       "500" }
}

#------------------------------------------------------------
#  brief  prépare la création de la fenêtre de l'outil
#
proc ::foc::createPanel {  } {
   global conf caption panneau

   ::foc::initConf

   #--- Initialisation de variables
   set panneau(foc,menu)              "$caption(foc,centrage)"
   set panneau(foc,centrage_fenetre)  "1"
   set panneau(foc,compteur)          "0"
   set panneau(foc,bin)               "1"
   set panneau(foc,exptime)           "2"
   set panneau(foc,go)                "$caption(foc,go)"
   set panneau(foc,stop)              "$caption(foc,stop)"
   set panneau(foc,raz)               "$caption(foc,raz)"
   set panneau(foc,trouve)            "$caption(foc,se_trouve)"
   set panneau(foc,pas)               "$caption(foc,pas)"
   set panneau(foc,deplace)           "$caption(foc,aller_a)"
   set panneau(foc,initialise)        "$caption(foc,init)"
   set panneau(foc,dispTimeAfterId)   ""
   set panneau(foc,window)            ""
   set panneau(foc,box)               ""
   set panneau(foc,pose_en_cours)     "0"
   set panneau(foc,demande_arret)     "0"
   set panneau(foc,avancement_acq)    "1"
   set panneau(foc,fichier)           "${caption(foc,intensite)}\t${caption(foc,fwhm__x)}\t${caption(foc,fwhm__y)}\t${caption(foc,contraste)}\t"
   set panneau(foc,hasWindow)         "0"
   set panneau(foc,start)             "0"
   set panneau(foc,end)               "65535"
   set panneau(foc,step)              "4000"
   set panneau(foc,repeat)            "1"
   set panneau(foc,seeing)            "24"
   set panneau(foc,simulation)        "0"

   #--   on copie le nom du focuser selectionne dans le pad
   if { $conf(confPad) != "" && $conf($conf(confPad),focuserLabel) != "" } {
      set panneau(foc,focuser)        "$conf($conf(confPad),focuserLabel)"
      if { [ ::focus::possedeControleEtendu $panneau(foc,focuser) ] == "1"} {
         set panneau(foc,typefocuser) "1"
      } else {
         set panneau(foc,typefocuser) "0"
      }
   } else {
      set panneau(foc,focuser)        "$caption(foc,pas_focuser)"
      set panneau(foc,typefocuser)    "0"
   }
}

#------------------------------------------------------------
#  brief adapte automatiquement l'interface graphique de l'outil au focuser sélectionné
#  param a (facultatif)
#  param b (facultatif)
#  param c (facultatif)
#
proc ::foc::adaptOutilFoc { { a "" } { b "" } { c "" } } {
   variable This
   global caption panneau

   #--   A chaque changement de focuser
   #--   fermeture des fenetres annexes
   ::foc::closeAllWindows
   #--   Reinitialise les variables
   set panneau(foc,repeat)   "1"
   set panneau(foc,compteur) "0"

   ::confEqt::activeFocuser $This.fra3.focuser.configure ::panneau(foc,focuser)
   if {$panneau(foc,focuser) eq ""} {
      set panneau(foc,focuser) "$caption(foc,pas_focuser)"
   }

   if { $panneau(foc,focuser) == "$caption(foc,pas_focuser)" } {

      #--   absence de focuser
      set panneau(foc,typefocuser) 0
      #--   masque tout sauf la liste des focuser
      pack forget $This.fra4 ; #-- masque le frame de la raquette du focuser
      pack forget $This.fra5 ; #-- masque frame position focus
      pack forget $This.fra6 ; #-- masque frame programation

   } else {

      #--   tous les focuser reels
      #-- demasque le frame de la raquette du focuser commun a tous les focuser
      pack $This.fra4 -after $This.fra3 -side top -fill x

      set panneau(foc,typefocuser) [ ::focus::possedeControleEtendu $panneau(foc,focuser) ]

      if {$panneau(foc,typefocuser) == "1"} {

         #--   focuseraudecom et usb_focus
         #--   modifie les valeurs debut et fin
         lassign [::foc::getLimits $panneau(foc,focuser)] limite1 limite2
         set panneau(foc,start) "$limite1"
         set panneau(foc,end)   "$limite2"
         pack $This.fra5 -after $This.fra4 -side top -fill x ; #-- demasque frame position focus
         $This.fra5.but2 configure -command { ::foc::cmdFocusGoto }
         $This.fra5.target configure -helptext [format $caption(foc,formatfoc) $limite1 $limite2] \
            -validatecommand [list ::tkutil::validateNumber %W %V %P %s integer $limite1 $limite2]
         pack $This.fra6 -after $This.fra5 -side top -fill x ; #-- demasque frame programmation
         $This.fra6.start configure -helptext [format $caption(foc,hlpstart) $limite1]
         $This.fra6.end configure -helptext [format $caption(foc,hlpend) $limite2]

         if {$panneau(foc,focuser) eq "usb_focus"} {
            #--   usb_focus
            pack forget $This.fra5.but0
            pack forget $This.fra5.but1
            ::focus::displayCurrentPosition $::panneau(foc,focuser)
         } else {
            #--   focuseraudecom
            $This.fra4.we.labPoliceInvariant configure -text $::audace(focus,labelspeed)
         }
      } else {
         #--   tous les focuser sans controle etendu
         pack forget $This.fra5 ; #-- masque frame position focus
         pack forget $This.fra6 ; #-- masque frame proogrammation
      }
   }
   update
}

#------------------------------------------------------------
#  brief   créé l'interface graphique
#
proc ::foc::focBuildIF { } {
   variable This
   global audace caption panneau

   frame $This -borderwidth 2 -relief groove

      #--- Frame du titre
      frame $This.fra1 -borderwidth 2 -relief groove

         #--- Bouton du titre
         Button $This.fra1.but -borderwidth 1 \
            -text "$caption(foc,help_titre1)\n$caption(foc,focalisation)" \
            -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::foc::getPluginType ] ] \
               [ ::foc::getPluginDirectory ] [ ::foc::getPluginHelp ]"
         pack $This.fra1.but -anchor center -expand 1 -fill both -side top -ipadx 5
         DynamicHelp::add $This.fra1.but -text $caption(foc,help_titre)

      pack $This.fra1 -side top -fill x

      #--- Frame du centrage/pointage
      frame $This.fra2 -borderwidth 1 -relief groove

         #--- Label pour acquistion
         label $This.fra2.lab1 -text $caption(foc,acquisition) -relief flat
         pack $This.fra2.lab1 -anchor center -fill none -padx 4 -pady 1

         #--- Menu
         menubutton $This.fra2.optionmenu1 -textvariable panneau(foc,menu) \
            -menu $This.fra2.optionmenu1.menu -borderwidth 2 -relief raised
         pack $This.fra2.optionmenu1 -anchor center -fill x -padx 5 -pady 2 -ipady 1
         set m [ menu $This.fra2.optionmenu1.menu -tearoff 0 ]
         $m add radiobutton -label "$caption(foc,centrage)" \
            -indicatoron "1" \
            -value "1" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,centrage)" ; set panneau(foc,centrage_fenetre) "1" }
         $m add radiobutton -label "$caption(foc,fenetre_man)" \
            -indicatoron "1" \
            -value "2" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,fenetre_man)" ; set panneau(foc,centrage_fenetre) "2" }
         $m add radiobutton -label "$caption(foc,fenetre_auto)" \
            -indicatoron "1" \
            -value "3" \
            -variable panneau(foc,centrage_fenetre) \
            -command { set panneau(foc,menu) "$caption(foc,fenetre_auto)" ; set panneau(foc,centrage_fenetre) "3" }

         #--- Frame des entry & label
         frame $This.fra2.fra1 -borderwidth 1 -relief flat

            #--- Entry pour exptime
            entry $This.fra2.fra1.ent1 -textvariable panneau(foc,exptime) \
               -relief groove -width 6 -justify center \
               -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }

            pack $This.fra2.fra1.ent1 -side left -fill none -padx 4 -pady 2
            #--- Label secondes
            label $This.fra2.fra1.lab1 -text $caption(foc,seconde) -relief flat
            pack $This.fra2.fra1.lab1 -side left -fill none -padx 4 -pady 2

         pack $This.fra2.fra1 -anchor center -fill none

         #--- Bouton GO
         button $This.fra2.but1 -borderwidth 2 -text $panneau(foc,go) -command { ::foc::cmdGo }
         pack $This.fra2.but1 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

         #--- Bouton STOP/RAZ
         button $This.fra2.but2 -borderwidth 2 -text $panneau(foc,raz) -command { ::foc::cmdStop }
         pack $This.fra2.but2 -in $This.fra2 -anchor center -fill x -padx 5 -pady 2 -ipadx 15 -ipady 1

      pack $This.fra2 -side top -fill x

      #--- Frame de la configuration
      frame $This.fra3 -borderwidth 1 -relief groove

         #--- Frame focuser
         ::confEqt::createFrameFocuserTool $This.fra3.focuser ::panneau(foc,focuser)
         pack $This.fra3.focuser -in $This.fra3 -anchor nw -side top -padx 4 -pady 1

         #--   je lis la configuration de la commande de la combobox
         set oldCmd [$This.fra3.focuser.list configure -modifycmd]
         #--   je lis la commande ecrite par la proc ::confEqt::createFrameFocuserTool
         set cmd [lindex $oldCmd 4]
         #--   j'ajoute l'instruction ::foc::adaptOutilFoc
         append cmd "; ::foc::adaptOutilFoc"
         #--   je modifie la commande de la combobox
         $This.fra3.focuser.list configure -modifycmd $cmd

      pack $This.fra3 -side top -fill x

      #--- Frame des boutons manuels
      frame $This.fra4 -borderwidth 1 -relief groove

         #--- Label pour moteur focus
         label $This.fra4.lab1 -text $caption(foc,moteur_focus) -relief flat
         pack $This.fra4.lab1 -in $This.fra4 -anchor center -fill none -padx 4 -pady 1

         #--- Create the buttons '- +'
         frame $This.fra4.we -width 27 -borderwidth 0 -relief flat
         pack $This.fra4.we -in $This.fra4 -side top -fill x

         #--- Button '-'
         button $This.fra4.we.canv1PoliceInvariant -borderwidth 2 \
            -text "-" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv1PoliceInvariant -in $This.fra4.we -expand 0 -side left -padx 2 -pady 2

         #--- Write the label of speed for LX200 and compatibles
         label $This.fra4.we.labPoliceInvariant \
            -textvariable ::audace(focus,labelspeed) -width 2 -borderwidth 0 -relief flat
         pack $This.fra4.we.labPoliceInvariant -in $This.fra4.we -expand 1 -side left

         #--- Button '+'
         button $This.fra4.we.canv2PoliceInvariant -borderwidth 2 \
            -text "+" \
            -width 2  \
            -anchor center \
            -relief ridge
         pack $This.fra4.we.canv2PoliceInvariant -in $This.fra4.we -expand 0 -side right -padx 2 -pady 2

         set zone(moins) $This.fra4.we.canv1PoliceInvariant
         set zone(plus)  $This.fra4.we.canv2PoliceInvariant

      pack $This.fra4 -side top -fill x

      #--- Speed
      bind $This.fra4.we.labPoliceInvariant <ButtonPress-1> { ::foc::cmdSpeed }

      #--- Cardinal moves
      bind $zone(moins) <ButtonPress-1>   { ::foc::cmdFocus - }
      bind $zone(moins) <ButtonRelease-1> { ::foc::cmdFocus stop }
      bind $zone(plus)  <ButtonPress-1>   { ::foc::cmdFocus + }
      bind $zone(plus)  <ButtonRelease-1> { ::foc::cmdFocus stop }

      LabelEntry $This.fra4.delai \
         -label $caption(foc,delai) -labeljustify left -labelwidth 12 \
         -textvariable conf(foc,attente) -width 6 -justify center \
         -helptext $caption(foc,hlpdelai)
      pack $This.fra4.delai -side top -fill x -padx 2 -pady 2
      bind $This.fra4.delai <Leave> { ::foc::analyseAuto attente }

      #--- Frame de la position focus
      frame $This.fra5 -borderwidth 1 -relief groove

         #--- Bouton "Initialisation"
         button $This.fra5.but0 -borderwidth 2 -text $panneau(foc,initialise) -command { ::foc::cmdInitFoc }
         pack $This.fra5.but0 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Bouton "Se trouve à"
         button $This.fra5.but1 -borderwidth 2 -text $panneau(foc,trouve) -command { ::foc::cmdSeTrouveA }
         pack $This.fra5.but1 -anchor center -fill x -padx 5 -pady 2 -ipadx 15

         #--- Frame des labels
         LabelEntry $This.fra5.current \
            -label $caption(foc,pos_focus) -labeljustify left -labelwidth 12 \
            -textvariable ::audace(focus,currentFocus) -width 6 -justify center \
            -state disabled
         pack $This.fra5.current -side top -fill x -padx 4 -pady 2

         #--- Bouton "Aller à"
         button $This.fra5.but2 -borderwidth 2 -text $panneau(foc,deplace) -command { cmdFocusGoto }
         pack $This.fra5.but2 -anchor center -fill x -padx 5 -pady 5 -ipadx 15

         #--- Frame des entry & label
         LabelEntry $This.fra5.target \
            -label $caption(foc,target) -labeljustify left -labelwidth 12 \
            -textvariable ::audace(focus,targetFocus) -width 6 -justify center
         pack $This.fra5.target -side top -fill x -padx 4 -pady 2

      pack $This.fra5 -side top -fill x

      frame $This.fra6 -borderwidth 2 -relief ridge

         LabelEntry $This.fra6.start \
            -label $caption(foc,start) -labeljustify left -labelwidth 12 \
            -textvariable panneau(foc,start) -width 6 -justify center \
            -helptext [format $caption(foc,hlpstart) 0]
         pack $This.fra6.start -side top -fill x -padx 4 -pady 2
         bind $This.fra6.start <Leave> { ::foc::analyseAuto start }

         LabelEntry $This.fra6.end \
            -label $caption(foc,end) -labeljustify left -labelwidth 12 \
            -textvariable panneau(foc,end) -width 6 -justify center \
            -helptext [format $caption(foc,hlpend) 0 65535]
         pack $This.fra6.end -side top -fill x -padx 4 -pady 2
         bind $This.fra6.end <Leave> { ::foc::analyseAuto end }

         LabelEntry $This.fra6.step \
            -label $caption(foc,step) -labeljustify left -labelwidth 12 \
            -textvariable panneau(foc,step) -width 6 -justify center \
            -helptext $caption(foc,hlpstep)
         pack $This.fra6.step -side top -fill x -padx 4 -pady 2
         bind $This.fra6.step <Leave> { ::foc::analyseAuto step }

         LabelEntry $This.fra6.repeat \
            -label $caption(foc,repeat) -labeljustify left -labelwidth 12\
            -textvariable panneau(foc,repeat) -width 6 -justify center \
            -helptext $caption(foc,hlprepeat)
         pack $This.fra6.repeat -side top -fill x -padx 4 -pady 2
         bind $This.fra6.repeat <Leave> { ::foc::analyseAuto repeat }

      pack $This.fra6 -in $This -after $This.fra5 -fill x

      #--- Frame pour l'affichage de l'avancement de l'acquisition
      frame $This.fra7 -borderwidth 2 -relief ridge

        #--- Checkbutton pour l'affichage de l'avancement de l'acqusition
        checkbutton $This.fra7.avancement_acq -highlightthickness 0 \
           -text $caption(foc,avancement_acq) -variable panneau(foc,avancement_acq)
        pack $This.fra7.avancement_acq -side left -fill x

     pack $This.fra7 -fill x

     #--- Frame pour la simulation
     frame $This.fra8 -borderwidth 2 -relief ridge

        #--- Checkbutton pour la simulation
        checkbutton $This.fra8.simul -highlightthickness 0 \
           -text $caption(foc,simulation) -variable panneau(foc,simulation) \
           -onvalue 1 -offvalue 0
        pack $This.fra8.simul -side left -fill x

     pack $This.fra8 -fill x

     #--- Mise a jour dynamique des couleurs
     ::confColor::applyColor $This
}

#-----------------------------------
#  brief ferme le graphique, la petite fenêtre et la fenêtre HFD
# en sauvant les positions
#
proc ::foc::closeAllWindows { } {
   variable private

   if {[winfo exists $private(parafoc)]} {
      ::foc::closeQualiteFoc
   }
   if {[winfo exists $private(visufoc)]} {
      ::foc::closeGraph
   }
   if {[winfo exists $private(hfd)]} {
      ::foc::closeHFDGraphe
   }
}


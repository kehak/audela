#
## @file getdss.tcl
#  @brief Récuperation d'images du DSS (Digital Sky Survey)
#  @author Guillaume SPITZER
#  $Id: getdss.tcl 13610 2016-04-04 14:37:59Z rzachantke $
#

#============================================================
# Declaration du namespace getdss
#    initialise le namespace
#============================================================

## @namespace getdss
#  @brief Récuperation d'images du DSS (Digital Sky Survey)
namespace eval ::getdss {
   package provide getdss 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] getdss.cap ]
}

#------------------------------------------------------------
# brief     retourne le titre du plugin dans la langue de l'utilisateur
# return    titre du plugin
#
proc ::getdss::getPluginTitle { } {
   global caption

   return "$caption(getdss,menu)"
}

#------------------------------------------------------------
# brief     retourne le nom du fichier d'aide principal
# return    nom du fichier d'aide principal
#
proc ::getdss::getPluginHelp { } {
   return "getdss.htm"
}

#------------------------------------------------------------
# brief     retourne le type de plugin
# return    type de plugin
#
proc ::getdss::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief     retourne le nom du répertoire du plugin
# return    nom du répertoire du plugin : "getdss"
#
proc ::getdss::getPluginDirectory { } {
   return "getdss"
}

#------------------------------------------------------------
## @brief    retourne le ou les OS de fonctionnement du plugin
#  @return   liste des OS : "Windows Linux Darwin"
#
proc ::getdss::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::getdss::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "file" }
      subfunction1 { return "getdss" }
      display      { return "window" }
      multivisu    { return 1 }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin de la fenêtre
#
proc ::getdss::createPluginInstance { base { visuNo 1 } } {
   variable private

   package require http

   #--- Pour le cryptage des nom et password
   package require base64

   #--- Initialisation du nom de la fenetre
   set private($visuNo,This) $base.getdss

   #--- J'ouvre la fenetre
   ::getdss::createPanel $visuNo

   #---
   return $private($visuNo,This)
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin
#  @param   visuNo numéro de la visu
#
proc ::getdss::deletePluginInstance { visuNo } {
   variable private

   if { [ winfo exists $private($visuNo,This) ] } {
      #--- je ferme la fenetre si l'utilisateur ne l'a pas deja fait
      ::getdss::cmdClose $visuNo
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Récupération d'images du DSS"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(getdss,$visuNo,geometry) définit les dimensions et la position de la fenêtre
#
proc ::getdss::initConf { visuNo } {
   global conf

   if { ! [ info exists conf(getdss,$visuNo,geometry) ] } { set conf(getdss,$visuNo,geometry) "500x552+135+60" }
}

#------------------------------------------------------------
#  brief   charge les variables de configuration dans des variables locales
#
proc ::getdss::confToWidget { visuNo } {
   variable widget

   ::getdss::initConf $visuNo

   set widget(getdss,$visuNo,geometry) "$::conf(getdss,$visuNo,geometry)"
}

#------------------------------------------------------------
#  brief   charge les variables locales dans des variables de configuration
#
proc ::getdss::widgetToConf { visuNo } {
   variable widget

   set ::conf(getdss,$visuNo,geometry) "$widget(getdss,$visuNo,geometry)"
}

#------------------------------------------------------------
#  brief   créé l'interface graphique
#
proc ::getdss::createPanel { visuNo } {
   variable widget
   variable private
   global caption

   #--- Initialisation de variables
   set private($visuNo,NomObjet)  M
   set private($visuNo,debut)     ""
   set private($visuNo,fin)       ""
   set private($visuNo,adh)       "3"
   set private($visuNo,adm)       "42"
   set private($visuNo,ads)       "53"
   set private($visuNo,adss)      "5"
   set private($visuNo,decd)      "-12"
   set private($visuNo,decm)      "9"
   set private($visuNo,decs)      "14"
   set private($visuNo,decss)     "3"
   set private($visuNo,ad)        ""
   set private($visuNo,dec)       ""
   set private($visuNo,hauteur)   20.0
   set private($visuNo,largeur)   30.0
   set private($visuNo,catalogue) ""
   set private($visuNo,rep)       [ file join $::audace(rep_images) @@IMAGES-DSS ]

   #--- Si la connexion internet passe par un proxy, mettre a yes sinon a no
   set private($visuNo,proxy) no

   # --- Initialisation
   ::getdss::confToWidget $visuNo

   #--- Construction de l'interface
   toplevel $private($visuNo,This)
   wm geometry $private($visuNo,This) $widget(getdss,$visuNo,geometry)
   wm resizable $private($visuNo,This) 1 1
   wm deiconify $private($visuNo,This)
   wm title $private($visuNo,This) "$caption(getdss,menu) (visu$visuNo)"
   wm protocol $private($visuNo,This) WM_DELETE_WINDOW "::getdss::cmdClose $visuNo"

   #--- Boutons
   frame $private($visuNo,This).f00 -borderwidth 5
   pack $private($visuNo,This).f00 -side top -fill x

   button $private($visuNo,This).f00.ouvrir -text $caption(getdss,ouvrir) -command "::getdss::ouvrir $visuNo"
   pack $private($visuNo,This).f00.ouvrir -side left -padx 10 -ipadx 5 -fill x -expand 1

   button $private($visuNo,This).f00.enregistrer -text $caption(getdss,enregistrer) -command ::getdss::enregistrer
   pack $private($visuNo,This).f00.enregistrer -side left -padx 10 -ipadx 5 -fill x -expand 1

   #--- Radio boutons
   frame $private($visuNo,This).f0 -borderwidth 5
   pack $private($visuNo,This).f0 -side top -fill x

   radiobutton $private($visuNo,This).f0.but1 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,messier) -value M
   pack $private($visuNo,This).f0.but1 -side left

   radiobutton $private($visuNo,This).f0.but2 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,ngc) -value NGC
   pack $private($visuNo,This).f0.but2 -side left

   radiobutton $private($visuNo,This).f0.but3 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,ic) -value IC
   pack $private($visuNo,This).f0.but3 -side left

   radiobutton $private($visuNo,This).f0.but4 -variable ::getdss::private($visuNo,NomObjet) -text $caption(getdss,coord) -value Coord
   pack $private($visuNo,This).f0.but4 -side left

   $private($visuNo,This).f0.but1 configure -command "::getdss::activeObjet $visuNo"
   $private($visuNo,This).f0.but2 configure -command "::getdss::activeObjet $visuNo"
   $private($visuNo,This).f0.but3 configure -command "::getdss::activeObjet $visuNo"
   $private($visuNo,This).f0.but4 configure -command "::getdss::activeObjet $visuNo"

   #--- Indices de debut et de fin de recherche
   frame $private($visuNo,This).f01 -borderwidth 5
   pack $private($visuNo,This).f01 -side top -fill x

   #--- Entry pour l'indice de debut
   label $private($visuNo,This).f01.l1 -text $caption(getdss,debut)
   pack $private($visuNo,This).f01.l1 -side left

   entry $private($visuNo,This).f01.e1 -textvariable ::getdss::private($visuNo,debut) -width 6 -justify center \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
   pack $private($visuNo,This).f01.e1 -side left -fill x -padx 5

   bind $private($visuNo,This).f01.e1 <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f01.e1 <Leave> "::getdss::activeObjet $visuNo"

   #--- Entry pour l'indice de fin
   label $private($visuNo,This).f01.l2 -text $caption(getdss,fin)
   pack $private($visuNo,This).f01.l2 -side left

   entry $private($visuNo,This).f01.e2 -textvariable ::getdss::private($visuNo,fin) -width 6 -justify center \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 1 9999 }
   pack $private($visuNo,This).f01.e2 -side left -fill x -padx 5

   bind $private($visuNo,This).f01.e2 <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f01.e2 <Leave> "::getdss::activeObjet $visuNo"

   #--- Entry pour les coordonnees
   frame $private($visuNo,This).f001 -borderwidth 5
   pack $private($visuNo,This).f001 -side top -fill x

   frame $private($visuNo,This).f001.addec
   pack $private($visuNo,This).f001.addec -side left -fill x

   frame $private($visuNo,This).f001.addec.ad
   pack $private($visuNo,This).f001.addec.ad -side top -fill x -pady 5

   frame $private($visuNo,This).f001.addec.dec
   pack $private($visuNo,This).f001.addec.dec -side top -fill x -pady 5

   frame $private($visuNo,This).f001.but
   pack $private($visuNo,This).f001.but -side right -fill x

   #--- Entry pour l'AD
   label $private($visuNo,This).f001.addec.ad.lAD -text $caption(getdss,ad)
   pack $private($visuNo,This).f001.addec.ad.lAD -side left -anchor w

   entry $private($visuNo,This).f001.addec.ad.eADh -textvariable ::getdss::private($visuNo,adh) -width 3 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 23 }
   pack $private($visuNo,This).f001.addec.ad.eADh -side left -padx 2

   label $private($visuNo,This).f001.addec.ad.lADh -text "h"
   pack $private($visuNo,This).f001.addec.ad.lADh -side left -anchor w

   entry $private($visuNo,This).f001.addec.ad.eADm -textvariable ::getdss::private($visuNo,adm) -width 3 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 59 }
   pack $private($visuNo,This).f001.addec.ad.eADm -side left -padx 2

   label $private($visuNo,This).f001.addec.ad.lADm -text "m"
   pack $private($visuNo,This).f001.addec.ad.lADm -side left -anchor w

   entry $private($visuNo,This).f001.addec.ad.eADs -textvariable ::getdss::private($visuNo,ads) -width 3 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 59 }
   pack $private($visuNo,This).f001.addec.ad.eADs -side left -padx 2

   label $private($visuNo,This).f001.addec.ad.lADpoint -text "."
   pack $private($visuNo,This).f001.addec.ad.lADpoint -side left -anchor w

   entry $private($visuNo,This).f001.addec.ad.eADss -textvariable ::getdss::private($visuNo,adss) -width 2 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 9 }
   pack $private($visuNo,This).f001.addec.ad.eADss -side left -padx 2

   label $private($visuNo,This).f001.addec.ad.lADs -text "s"
   pack $private($visuNo,This).f001.addec.ad.lADs -side left -anchor w

   bind $private($visuNo,This).f001.addec.ad.eADh  <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADh  <Leave> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADm  <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADm  <Leave> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADs  <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADs  <Leave> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADss <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.ad.eADss <Leave> "::getdss::activeObjet $visuNo"

   #--- Entry la Dec.
   label $private($visuNo,This).f001.addec.dec.lDec -text $caption(getdss,dec)
   pack $private($visuNo,This).f001.addec.dec.lDec -side left -anchor w

   entry $private($visuNo,This).f001.addec.dec.eDecd -textvariable ::getdss::private($visuNo,decd) -width 3 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer -90 90 }
   pack $private($visuNo,This).f001.addec.dec.eDecd -side left -padx 2

   label $private($visuNo,This).f001.addec.dec.lDecd -text "°"
   pack $private($visuNo,This).f001.addec.dec.lDecd -side left -anchor w

   entry $private($visuNo,This).f001.addec.dec.eDecm -textvariable ::getdss::private($visuNo,decm) -width 3 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 59 }
   pack $private($visuNo,This).f001.addec.dec.eDecm -side left -padx 2

   label $private($visuNo,This).f001.addec.dec.lDecm -text "'"
   pack $private($visuNo,This).f001.addec.dec.lDecm -side left -anchor w

   entry $private($visuNo,This).f001.addec.dec.eDecs -textvariable ::getdss::private($visuNo,decs) -width 3 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 59 }
   pack $private($visuNo,This).f001.addec.dec.eDecs -side left -padx 2

   label $private($visuNo,This).f001.addec.dec.lDecs -text "."
   pack $private($visuNo,This).f001.addec.dec.lDecs -side left -anchor w

   entry $private($visuNo,This).f001.addec.dec.eDecss -textvariable ::getdss::private($visuNo,decss) -width 2 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s integer 0 9 }
   pack $private($visuNo,This).f001.addec.dec.eDecss -side left -padx 2

   label $private($visuNo,This).f001.addec.dec.lDecss -text "''"
   pack $private($visuNo,This).f001.addec.dec.lDecss -side left -anchor w

   bind $private($visuNo,This).f001.addec.dec.eDecd  <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecd  <Leave> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecm  <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecm  <Leave> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecs  <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecs  <Leave> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecss <Enter> "::getdss::activeObjet $visuNo"
   bind $private($visuNo,This).f001.addec.dec.eDecss <Leave> "::getdss::activeObjet $visuNo"

   #--- Boutons pour la recuperation des donnees
   button $private($visuNo,This).f001.but.butTlscp -text $caption(getdss,telescope) -command "::getdss::cmdTakeTlscpCoord $visuNo"
   pack $private($visuNo,This).f001.but.butTlscp -side top -padx 3 -ipadx 5 -ipady 0 -fill x

   button $private($visuNo,This).f001.but.butFits1 -text $caption(getdss,imageFits1) -command "::getdss::cmdTakeFITS1Keywords $visuNo"
   pack $private($visuNo,This).f001.but.butFits1 -side top -padx 3 -ipadx 5 -ipady 0 -fill x

   button $private($visuNo,This).f001.but.butFits2 -text $caption(getdss,imageFits2) -command "::getdss::cmdTakeFITS2Keywords $visuNo"
   pack $private($visuNo,This).f001.but.butFits2 -side top -padx 3 -ipadx 5 -ipady 0 -fill x

   #--- Texte de rappel de la recherche
   frame $private($visuNo,This).f02 -borderwidth 5
   pack $private($visuNo,This).f02 -side top -fill x

   label $private($visuNo,This).f02.l1
   pack $private($visuNo,This).f02.l1 -side left

   #--- Choix du catalogue dans lequel on recupere l'image
   frame $private($visuNo,This).lb -borderwidth 5
   pack $private($visuNo,This).lb -side top -fill x

   label $private($visuNo,This).lb.l1 -text $caption(getdss,catalogue)
   pack $private($visuNo,This).lb.l1 -side left

   listbox   $private($visuNo,This).lb.lb1 -width 25 -height 8 -borderwidth 2 -relief sunken -yscrollcommand [list $private($visuNo,This).lb.scrollbar set]
   pack      $private($visuNo,This).lb.lb1 -side left -anchor nw

   scrollbar $private($visuNo,This).lb.scrollbar -orient vertical -command [list $private($visuNo,This).lb.lb1 yview]
   pack      $private($visuNo,This).lb.scrollbar -side left -fill y

   $private($visuNo,This).lb.lb1 insert end "POSS2/UKSTU Red"
   $private($visuNo,This).lb.lb1 insert end "POSS2/UKSTU Blue"
   $private($visuNo,This).lb.lb1 insert end "POSS2/UKSTU IR"
   $private($visuNo,This).lb.lb1 insert end "POSS1 Red"
   $private($visuNo,This).lb.lb1 insert end "POSS1 Blue"
   $private($visuNo,This).lb.lb1 insert end "Quick-V"
   $private($visuNo,This).lb.lb1 insert end "HST Phase 2 (GSC2)"
   $private($visuNo,This).lb.lb1 insert end "HST Phase 2 (GSC1)"

   #--- Largeur de l'image
   frame $private($visuNo,This).f1 -borderwidth 5
   pack $private($visuNo,This).f1 -side top -fill x

   label $private($visuNo,This).f1.l1 -text $caption(getdss,largeur)
   pack $private($visuNo,This).f1.l1 -side left

   entry $private($visuNo,This).f1.e1 -textvariable ::getdss::private($visuNo,largeur) -width 10 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
   pack $private($visuNo,This).f1.e1 -side left -padx 5

   #--- Hauteur de l'image
   frame $private($visuNo,This).f2 -borderwidth 5
   pack $private($visuNo,This).f2 -side top -fill x

   label $private($visuNo,This).f2.l2 -text $caption(getdss,hauteur)
   pack $private($visuNo,This).f2.l2 -side left

   entry $private($visuNo,This).f2.e2 -textvariable ::getdss::private($visuNo,hauteur) -width 10 \
      -validate all -validatecommand { ::tkutil::validateNumber %W %V %P %s double 0 9999 }
   pack $private($visuNo,This).f2.e2 -side left -padx 5

   #--- Repertoire de sauvegarde de l'image
   frame $private($visuNo,This).f3 -borderwidth 5
   pack $private($visuNo,This).f3 -side top -fill x

   label $private($visuNo,This).f3.l3 -text $caption(getdss,repertoire)
   pack $private($visuNo,This).f3.l3 -side left

   entry $private($visuNo,This).f3.e3 -textvariable ::getdss::private($visuNo,rep) -width 40
   pack $private($visuNo,This).f3.e3 -side left -padx 5
   $private($visuNo,This).f3.e3 xview end

   button $private($visuNo,This).f3.b3 -text $caption(getdss,parcourir) -command "::getdss::getDir $visuNo"
   pack $private($visuNo,This).f3.b3 -side left

   #--- Compresser le fichier
   frame $private($visuNo,This).f4 -borderwidth 5
   pack $private($visuNo,This).f4 -side top -fill x

   checkbutton $private($visuNo,This).f4.cbcompresse -text $caption(getdss,compression) \
      -variable ::getdss::private($visuNo,compresse) -onvalue yes -offvalue no
   pack $private($visuNo,This).f4.cbcompresse -side left

   #--- Proxy
   frame $private($visuNo,This).f5 -borderwidth 5
   pack $private($visuNo,This).f5 -side top -fill x

   checkbutton $private($visuNo,This).f5.cbproxy -text $caption(getdss,proxy) \
      -variable ::getdss::private($visuNo,proxy) -onvalue yes -offvalue no \
      -command "::confProxyInternet::run $::audace(base).confProxyInternet"
   pack $private($visuNo,This).f5.cbproxy -side left
   set private($visuNo,proxy) no

   #--- Boutons
   frame $private($visuNo,This).f9 -borderwidth 5
   pack $private($visuNo,This).f9 -side bottom -fill x

   button $private($visuNo,This).f9.b1 -text $caption(getdss,lancer) -command "::getdss::cmdApply $visuNo"
   pack $private($visuNo,This).f9.b1 -side left -padx 3 -ipadx 5 -ipady 5

   button $private($visuNo,This).f9.b2 -text $caption(getdss,fermer) -command "::getdss::cmdClose $visuNo"
   pack $private($visuNo,This).f9.b2 -side right -padx 3 -ipadx 5 -ipady 5

   button $private($visuNo,This).f9.b3 -text $caption(getdss,aide) -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::getdss::getPluginType ] ] \
   [ ::getdss::getPluginDirectory ] [ ::getdss::getPluginHelp ]"
   pack $private($visuNo,This).f9.b3 -side right -padx 3 -ipadx 5 -ipady 5

   bind $private($visuNo,This) <Key-Escape> "::getdss::cmdClose $visuNo"

   #--- La fenetre est active
   focus $private($visuNo,This)

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $private($visuNo,This) <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $private($visuNo,This)

   #--- Creation de la fenetre qui servira a l'affichage des messages d'attente
   toplevel .dialog($visuNo)
   label .dialog($visuNo).l1 -text "" -width 50
   pack .dialog($visuNo).l1 -side top
   pack forget .dialog($visuNo)

   wm withdraw .dialog($visuNo)

   #--- Fenetre centree
   set x [expr {([winfo screenwidth .]-[winfo width .dialog($visuNo)])/2}]
   set y [expr {([winfo screenheight .]-[winfo height .dialog($visuNo)])/2}]
   wm geometry  .dialog($visuNo) +$x+$y
   wm resizable .dialog($visuNo) 1 1
   wm title     .dialog($visuNo) $caption(getdss,imagerecup)
   wm protocol  .dialog($visuNo) WM_DELETE_WINDOW "::getdss::cmdClose $visuNo"

   ::getdss::activeObjet $visuNo

   #--- Cache la fenetre wish par defaut
   wm withdraw .
   #--- Met le focus sur le bouton 'Lancer'
   focus -force $private($visuNo,This).f9.b1
}

#------------------------------------------------------------
#  brief  génère la ligne d'authentification qui sera renvoyée au proxy
#  param u
#  param p
proc ::getdss::buildProxyHeaders { u p } {
   variable private

   if { $private($visuNo,proxy) == "yes" } {
      return [list "Proxy-Authorization" [concat "Basic" [base64::encode $u:$p]]]
   } else {
      return ""
   }
}

#------------------------------------------------------------
#  brief procédure de récuperation d'une image dont les coordonnées sont obtenues par SIMBAD
#  param visuNo numéro de la visu
#  param objet objet
#
#  objet peut être M27 IC434 NGC15
#
proc ::getdss::chargeObjetSIMBAD { visuNo objet } {
   variable private
   global audace ferreur

   #--- Gestion d'un proxy
   #--- Identification du browser, pas indispensable
   ::http::config -useragent "Mozilla/4.75 (X11; U; Linux 2.2.17; i586; Nav)"
   if { $private($visuNo,proxy) == "yes" } {
      ::http::config -proxyhost $::conf(proxy,host) -proxyport $::conf(proxy,port)
      ::http::ProxyRequired $::conf(proxy,host)
   } else {
      ::http::ProxyRequired ""
   }

   #--- URL de la requete CGI 1 permettant de transformer le nom en coordonnees
   set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_form/

   if { $private($visuNo,NomObjet) != "Coord" } {

      #--- Creation de la requete CGI 1
      #--- Format : nom_du_champs   valeur_du_champ, etc ... (repete n fois)
      #--- On a besoin que du champs 'target' dont on precise la valeur $objet
      set query [::http::formatQuery target $objet]

      #--- Lance la requete 1
      if { $private($visuNo,proxy) == "yes" } {
         set token1 [::http::geturl $BASE_URL -query $query -headers [::getdss::buildProxyHeaders $::conf(proxy,user) $::conf(proxy,password)] ]
      } else {
         set token1 [::http::geturl $BASE_URL -query $query]
      }

      set data1 [::http::data $token1]

      ::http::cleanup $token1

      update

      #--- Recherche les chaines qui contiennent les coordonnees retournees par la requete
      #--- set res [regexp -inline {(<a href="/dss/dss_help.html#coordinates">RA</a> <input name=r value=")([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 ]
      #--- syntaxe de regexp :
      #---  - entre {} l'ensemble de la chaine non ambigue a reperer
      #---  - entre () les differentes parties a isoler pour etre mis dans des variables distinctes
      #---    Le plus dur est de trouver une maniere sans ambiguite pour identifier le champs
      #---    que l'on desire isoler
      set ra ""
      set dec ""
      regexp -all {([0-9]+ [0-9]+ [0-9]+[[:punct:]][0-9]+)(" >)} $data1 match ra filler2
      regexp -all {([+-][0-9]+ [0-9]+ [[:punct:]]?[0-9]+[[:punct:]][0-9])(">)} $data1 match dec filler2

   } else {

      set ra  "$private($visuNo,adh) $private($visuNo,adm) $private($visuNo,ads).$private($visuNo,adss)"
      set dec "$private($visuNo,decd) $private($visuNo,decm) $private($visuNo,decs).$private($visuNo,decss)"

      set private($visuNo,ad)  "$private($visuNo,adh)h$private($visuNo,adm)m$private($visuNo,ads).$private($visuNo,adss)s"
      set private($visuNo,dec) "$private($visuNo,decd)d$private($visuNo,decm)m$private($visuNo,decs).$private($visuNo,decss)s"

   }

   #--- Ici, $ra et $dec contiennent les coordonnees de l'objet

   #--- Format de la ligne de la 2eme requete html :
   #--- http://stdatu.stsci.edu/cgi-bin/dss_search?v=poss2ukstu&r=16+41+41.44&d=%2B36+27+36.9&e=J2000&h=15.0&w=15.0&f=gif&c=none&fov=NONE&v3=
   #--- URL de la requete CGI 2
   set BASE_URL http://stdatu.stsci.edu/cgi-bin/dss_search/

   #--- Creation de la requete 2 (Obtention de l'image)
   #--- Ici, plusieurs parametres composent la requete CGI donc le parametre de ::http::formatQuery
   #--- comporte plusieurs couple champs - valeur_du_champs
   #--- Ici, les champs sont : v, r, d, e, h, w, f, c, fov, v3
   #--- v=poss2ukstu_red&r=00+31+45.00&d=-05+09+11.0&e=J2000&h=15.0&w=15.0&f=gif&c=none&fov=NONE&v3=
   #--- set query [::http::formatQuery v poss2ukstu_red r 00+31+45.00 d -05+09+11.0 e J2000 h 15.0 w 15.0 f fits c none fov NONE v3 ""]
   if { [catch {set a $ra}] } { set ra "" }
   if { [catch {set a $dec}] } { set dec "" }

   if { ($ra != "") && ($dec != "") } {

      set private($visuNo,catalogue) [$private($visuNo,This).lb.lb1 get [$private($visuNo,This).lb.lb1 curselection]]

      switch -exact -- $private($visuNo,catalogue) {
         "POSS2/UKSTU Red" { set catal poss2ukstu_red }
         "POSS2/UKSTU Blue" { set catal poss2ukstu_blue }
         "POSS2/UKSTU IR" { set catal poss2ukstu_ir }
         "POSS1 Red" { set catal poss1_red }
         "POSS1 Blue" { set catal poss1_blue }
         "Quick-V" { set catal quickv }
         "HST Phase 2 (GSC2)" { set catal phase2_gsc2 }
         "HST Phase 2 (GSC1)" { set catal phase2_gsc1 }
         default { set catal poss2ukstu_red }
      }

      set query [::http::formatQuery v $catal r $ra d $dec e J2000 h $private($visuNo,hauteur) w $private($visuNo,largeur) f fits c none fov NONE v3 ""]

      #--- Lance la requete 2
      if { $private($visuNo,proxy) == "yes" } {
         set token2 [::http::geturl ${BASE_URL} -query $query -headers [::getdss::buildProxyHeaders $::conf(proxy,user) $::conf(proxy,password)] ]
      } else {
         set token2 [::http::geturl ${BASE_URL} -query $query]
      }

      #--- Recuperation dans $html de l'image proprement dite
     set html  [::http::data $token2]
      ::http::cleanup $token2

      update

      #--- Enregistrement de l'image (en memoire) dans un fichier
      if { $private($visuNo,NomObjet) != "Coord" } {
         set fichier_objet ${objet}.fit
      } else {
         set fichier_objet ${objet}.AD$private($visuNo,ad).DEC$private($visuNo,dec).fit
      }
      set fp [open $fichier_objet w]
      fconfigure $fp -translation binary
      puts -nonewline $fp $html
      close $fp

      #--- Si on demande un format .gz, alors on charge l'image en memoire et on sauve avec l'option .gz
      #--- Les catch permettent de trapper certaines erreurs dues au serveur d'images
      #--- (pas bien compris pourquoi) afin de ne pas planter le script et permettre de charger les images suivantes
      if { $private($visuNo,compresse) == "yes" } {
         catch { buf[ ::confVisu::getBufNo $visuNo ] load $fichier_objet }
         catch { buf[ ::confVisu::getBufNo $visuNo ] compress gzip }
         catch { buf[ ::confVisu::getBufNo $visuNo ] save $fichier_objet }
      }
   } else {
      set ligne ""
      if { $private($visuNo,NomObjet) != "Coord" } {
         append ligne [ format $caption(getdss,texte1c) $objet ]
      } else {
         append ligne [ format $caption(getdss,texte1d) $objet ]
      }
      puts $ferreur $ligne
      puts $ferreur "-------------------------------------------------"
      flush $ferreur
   }
}

#------------------------------------------------------------
##  @brief  commande du bouton "Lancer"
#
#  on passe en paramètre à la fonction chargeObjetSIMBAD le nom que l'on met normalement sur la page WEB
#  @param visuNo numéro de la visu
#
proc ::getdss::cmdApply { visuNo } {
   variable private
   global caption old_rep ferreur

   #--- Test sur les indices de debut et de fin
   if { $private($visuNo,NomObjet) != "Coord" } {
      if { $private($visuNo,debut) == "" } {
         tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte3)
         return
      }
      if { $private($visuNo,fin) == "" } {
         tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte4)
         return
      }
   }

   #--- Creation du repertoire si inexistant et si creat vaut 'y'
   if { $private($visuNo,rep) != "" } {
      if { ! [file isdirectory $private($visuNo,rep)] } {
         set chx [ tk_messageBox -type yesno -title $caption(getdss,repinexistant) \
            -message $caption(getdss,nouveaurep) ]
         if { $chx == "yes" } {
            file mkdir $private($visuNo,rep)
         }
      }
   }

   if { [file isdirectory $private($visuNo,rep)] } {
      #--- Bouton Lancer inactif
      $private($visuNo,This).f9.b1 configure -state disabled

      #--- Sauvegarde le repertoire de base
      set old_rep [pwd]
      cd $private($visuNo,rep)

      #--- Ouverture du fichier des erreurs
      set ferreur [open notloaded.txt a]

      set ligne "[clock format [clock seconds] -format "20%y %m %d - %X"] - "
      if { $private($visuNo,NomObjet) != "Coord" } {
         append ligne [ format $caption(getdss,texte1a) $private($visuNo,NomObjet)$private($visuNo,debut) $private($visuNo,NomObjet)$private($visuNo,fin) ]
      } else {
         append ligne [ format $caption(getdss,texte1b) $private($visuNo,ad) $private($visuNo,dec) ]
      }
      puts $ferreur $ligne
      flush $ferreur

      #--- Recuperation des objets choisis
      if { $private($visuNo,NomObjet) != "Coord" } {
         for {set x $private($visuNo,debut)} {$x <= $private($visuNo,fin)} {incr x} {
            .dialog($visuNo).l1 configure -text [ format $caption(getdss,chargement) $private($visuNo,NomObjet)$x ]
            update
            wm deiconify .dialog($visuNo)

            set catchError [ catch { ::getdss::chargeObjetSIMBAD $visuNo $private($visuNo,NomObjet)$x } ]
            if { $catchError != "0" } {
               wm iconify .dialog($visuNo)
               set ligne ""
               if { $private($visuNo,catalogue) == "" } {
                  append ligne $caption(getdss,texte7)
                  puts $ferreur $ligne
                  puts $ferreur "-------------------------------------------------"
                  flush $ferreur
                  tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte2)
                  $private($visuNo,This).f9.b1 configure -state normal
                  return
               } else {
                  append ligne [ format $caption(getdss,texte1c) $private($visuNo,NomObjet)$x ]
                  puts $ferreur $ligne
                  flush $ferreur
               }
            }

            wm iconify .dialog($visuNo)
            focus -force $private($visuNo,This).f9.b1
            update
         }
      } else {
         .dialog($visuNo).l1 configure -text [ format $caption(getdss,chargement1) $private($visuNo,ad) $private($visuNo,dec) ]
         update
         wm deiconify .dialog($visuNo)

         set catchError [ catch { ::getdss::chargeObjetSIMBAD $visuNo $private($visuNo,NomObjet) } ]
         if { $catchError != "0" } {
            wm iconify .dialog($visuNo)
            set ligne ""
            if { $private($visuNo,catalogue) == "" } {
               append ligne $caption(getdss,texte7)
               puts $ferreur $ligne
               puts $ferreur "-------------------------------------------------"
               flush $ferreur
               tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte2)
               $private($visuNo,This).f9.b1 configure -state normal
               return
            } else {
               append ligne [ format $caption(getdss,texte1d) $private($visuNo,NomObjet) ]
               puts $ferreur $ligne
               flush $ferreur
            }
         }

         wm iconify .dialog($visuNo)
         focus -force $private($visuNo,This).f9.b1
         update
      }

      wm withdraw .dialog($visuNo)

      #--- Fermeture du fichier des erreurs
      puts $ferreur "-------------------------------------------------"
      close $ferreur

      #--- Restaure le repertoire de base
      cd $old_rep

      #--- Message de fin de traitement
      tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,fintraitement)

      #--- Bouton Lancer inactif
      $private($visuNo,This).f9.b1 configure -state normal
   }

   focus -force $private($visuNo,This).f9.b1
}

#------------------------------------------------------------
#  brief active/désactive les widgets des indices et des coordonnées ; active la mise à jour du rappel de recherche
#  param visuNo numéro de la visu
#
proc ::getdss::activeObjet { visuNo } {
   variable private
   global caption

   if { $private($visuNo,NomObjet) == "Coord" } {
      $private($visuNo,This).f01.e1 configure -state disabled
      $private($visuNo,This).f01.e2 configure -state disabled
      $private($visuNo,This).f001.addec.ad.eADh configure -state normal
      $private($visuNo,This).f001.addec.ad.eADm configure -state normal
      $private($visuNo,This).f001.addec.ad.eADs configure -state normal
      $private($visuNo,This).f001.addec.ad.eADss configure -state normal
      $private($visuNo,This).f001.addec.dec.eDecd configure -state normal
      $private($visuNo,This).f001.addec.dec.eDecm configure -state normal
      $private($visuNo,This).f001.addec.dec.eDecs configure -state normal
      $private($visuNo,This).f001.addec.dec.eDecss configure -state normal
      $private($visuNo,This).f001.but.butTlscp configure -state normal
      $private($visuNo,This).f001.but.butFits1 configure -state normal
      $private($visuNo,This).f001.but.butFits2 configure -state normal
   } else {
      $private($visuNo,This).f01.e1 configure -state normal
      $private($visuNo,This).f01.e2 configure -state normal
      $private($visuNo,This).f001.addec.ad.eADh configure -state disabled
      $private($visuNo,This).f001.addec.ad.eADm configure -state disabled
      $private($visuNo,This).f001.addec.ad.eADs configure -state disabled
      $private($visuNo,This).f001.addec.ad.eADss configure -state disabled
      $private($visuNo,This).f001.addec.dec.eDecd configure -state disabled
      $private($visuNo,This).f001.addec.dec.eDecm configure -state disabled
      $private($visuNo,This).f001.addec.dec.eDecs configure -state disabled
      $private($visuNo,This).f001.addec.dec.eDecss configure -state disabled
      $private($visuNo,This).f001.but.butTlscp configure -state disabled
      $private($visuNo,This).f001.but.butFits1 configure -state disabled
      $private($visuNo,This).f001.but.butFits2 configure -state disabled
   }

   set private($visuNo,ad)  "$private($visuNo,adh)h$private($visuNo,adm)m$private($visuNo,ads).$private($visuNo,adss)s"
   set private($visuNo,dec) "$private($visuNo,decd)d$private($visuNo,decm)m$private($visuNo,decs).$private($visuNo,decss)s"

   if { $private($visuNo,NomObjet) == "M" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,Messier) $private($visuNo,debut) $private($visuNo,fin) ]
    }
   if { $private($visuNo,NomObjet) == "NGC" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,NGC) $private($visuNo,debut) $private($visuNo,fin) ]
    }
   if { $private($visuNo,NomObjet) == "IC" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,IC) $private($visuNo,debut) $private($visuNo,fin) ]
    }
   if { $private($visuNo,NomObjet) == "Coord" } {
      $private($visuNo,This).f02.l1 configure -text [ format $caption(getdss,champ) $private($visuNo,ad) $private($visuNo,dec) ]
    }

   return 1
}

#------------------------------------------------------------
#  brief récupère les coordonnées AD et Dec. de l'image FITS dans les mots clés RA et DEC
#  param visuNo numéro de la visu
#
proc ::getdss::cmdTakeFITS1Keywords { visuNo } {
   variable private
   global audace caption

   if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
      #--- Recuperation des coordonnees de l'image affichee
      if { [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd RA ] 0 ] == "RA" && [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd DEC ] 0 ] == "DEC" } {
         set ra  [ mc_angle2hms [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd RA ] 1 ] ]
         set dec [ mc_angle2dms [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd DEC ] 1 ] 90 ]
         #--- Traitement de l'affichage
         set private($visuNo,adh)   [ lindex $ra 0 ]
         set private($visuNo,adm)   [ lindex $ra 1 ]
         set private($visuNo,ads)   [ expr int([ lindex $ra 2 ]) ]
         set private($visuNo,adss)  [ expr int( 10 * ( [ lindex $ra 2 ] - int([ lindex $ra 2 ]) ) ) ]
         set private($visuNo,decd)  [ string trimleft [ lindex $dec 0 ] "+" ]
         set private($visuNo,decm)  [ lindex $dec 1 ]
         set private($visuNo,decs)  [ expr int([ lindex $dec 2 ]) ]
         set private($visuNo,decss) [ expr int( 10 * ( [ lindex $dec 2 ] - int([ lindex $dec 2 ]) ) ) ]
         set private($visuNo,ad)    "$private($visuNo,adh)h$private($visuNo,adm)m$private($visuNo,ads).$private($visuNo,adss)s"
         set private($visuNo,dec)   "$private($visuNo,decd)d$private($visuNo,decm)m$private($visuNo,decs).$private($visuNo,decss)s"
         #--- Rafraichissement du rappel
         ::getdss::activeObjet $visuNo
      } else {
         #--- Traitement de l'affichage
         set private($visuNo,adh)   ""
         set private($visuNo,adm)   ""
         set private($visuNo,ads)   ""
         set private($visuNo,adss)  ""
         set private($visuNo,decd)  ""
         set private($visuNo,decm)  ""
         set private($visuNo,decs)  ""
         set private($visuNo,decss) ""
         set private($visuNo,ad)    ""
         set private($visuNo,dec)   ""
         #--- Rafraichissement du rappel
         ::getdss::activeObjet $visuNo
         #--- Affichage de l'alerte
         tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte5)
      }
   } else {
      ::audace::charger $visuNo
   }
}

#------------------------------------------------------------
#  brief récupère les coordonnées AD et Dec. de l'image FITS dans les mots clés CRVAL1 et CRVAL2
#  param visuNo numéro de la visu
#
proc ::getdss::cmdTakeFITS2Keywords { visuNo } {
   variable private
   global audace caption

   if { [ buf[ ::confVisu::getBufNo $visuNo ] imageready ] == "1" } {
      #--- Recuperation des coordonnees de l'image affichee
      if { [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd CRVAL1 ] 0 ] == "CRVAL1" && [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd CRVAL2 ] 0 ] == "CRVAL2" } {
         set ra  [ mc_angle2hms [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd CRVAL1 ] 1 ] ]
         set dec [ mc_angle2dms [ lindex [ buf[ ::confVisu::getBufNo $visuNo ] getkwd CRVAL2 ] 1 ] 90 ]
         #--- Traitement de l'affichage
         set private($visuNo,adh)   [ lindex $ra 0 ]
         set private($visuNo,adm)   [ lindex $ra 1 ]
         set private($visuNo,ads)   [ expr int([ lindex $ra 2 ]) ]
         set private($visuNo,adss)  [ expr int( 10 * ( [ lindex $ra 2 ] - int([ lindex $ra 2 ]) ) ) ]
         set private($visuNo,decd)  [ string trimleft [ lindex $dec 0 ] "+" ]
         set private($visuNo,decm)  [ lindex $dec 1 ]
         set private($visuNo,decs)  [ expr int([ lindex $dec 2 ]) ]
         set private($visuNo,decss) [ expr int( 10 * ( [ lindex $dec 2 ] - int([ lindex $dec 2 ]) ) ) ]
         set private($visuNo,ad)    "$private($visuNo,adh)h$private($visuNo,adm)m$private($visuNo,ads).$private($visuNo,adss)s"
         set private($visuNo,dec)   "$private($visuNo,decd)d$private($visuNo,decm)m$private($visuNo,decs).$private($visuNo,decss)s"
         #--- Rafraichissement du rappel
         ::getdss::activeObjet $visuNo
      } else {
         #--- Traitement de l'affichage
         set private($visuNo,adh)   ""
         set private($visuNo,adm)   ""
         set private($visuNo,ads)   ""
         set private($visuNo,adss)  ""
         set private($visuNo,decd)  ""
         set private($visuNo,decm)  ""
         set private($visuNo,decs)  ""
         set private($visuNo,decss) ""
         set private($visuNo,ad)    ""
         set private($visuNo,dec)   ""
         #--- Rafraichissement du rappel
         ::getdss::activeObjet $visuNo
         #--- Affichage de l'alerte
         tk_messageBox -title $caption(getdss,attention) -message $caption(getdss,texte6)
      }
   } else {
      ::audace::charger $visuNo
   }
}

#------------------------------------------------------------
#  brief récupère les coordonnées AD et Dec. du télescope
#  param visuNo numéro de la visu
#
proc ::getdss::cmdTakeTlscpCoord { visuNo } {
   variable private

   if { [ ::tel::list ] != "" } {
      #--- Recuperation des coordonnees de la montre
      set ra  [ mc_angle2hms $::audace(telescope,getra) ]
      set dec [ mc_angle2dms $::audace(telescope,getdec) 90 ]
      #--- Traitement de l'affichage
      set private($visuNo,adh)   [ lindex $ra 0 ]
      set private($visuNo,adm)   [ lindex $ra 1 ]
      set private($visuNo,ads)   [ expr int([ lindex $ra 2 ]) ]
      set private($visuNo,adss)  [ expr int( 10 * ( [ lindex $ra 2 ] - int([ lindex $ra 2 ]) ) ) ]
      set private($visuNo,decd)  [ string trimleft [ lindex $dec 0 ] "+" ]
      set private($visuNo,decm)  [ lindex $dec 1 ]
      set private($visuNo,decs)  [ expr int([ lindex $dec 2 ]) ]
      set private($visuNo,decss) [ expr int( 10 * ( [ lindex $dec 2 ] - int([ lindex $dec 2 ]) ) ) ]
      set private($visuNo,ad)    "$private($visuNo,adh)h$private($visuNo,adm)m$private($visuNo,ads).$private($visuNo,adss)s"
      set private($visuNo,dec)   "$private($visuNo,decd)d$private($visuNo,decm)m$private($visuNo,decs).$private($visuNo,decss)s"
      #--- Rafraichissement du rappel
      ::getdss::activeObjet $visuNo
   } else {
      ::confTel::run
   }
}

#------------------------------------------------------------
#  brief ajoute l'extension .ini au fichier de configuration
#  param fic fichier
#
proc ::getdss::ajoutExtension { fic } {
   if { [file extension $fic] != ".ini" } {
      return "${fic}.ini"
   } else {
      return ${fic}
   }
}

#------------------------------------------------------------
#  brief ouvre le fichier de configuration
#  param visuNo numéro de la visu
#
proc ::getdss::ouvrir { visuNo } {
   variable private
   global caption

   set filetypes [ list [ list "$caption(getdss,fichierparam)" ".ini" ] ]
   set fichier [tk_getOpenFile -title $caption(getdss,ouvrirconfig) \
      -filetypes $filetypes \
      -initialdir "$::audace(rep_home)" ]

   #--- Creation d'un interpreteur
   set tmpinterp [interp create]

   #--- Interprete le fichier de configuration
   catch {interp eval $tmpinterp "source \"$fichier\""}

   #--- Charge dans le tableau private_temp les donnees de l'interpreteur temporaire
   array set private_temp [interp eval $tmpinterp "array get private"]

   #--- Supprime l'interpreteur temporaire
   interp delete $tmpinterp

   #--- Charge dans private de l'interpreteur courant les valeur du private_temp
   array set private [array get private_temp]
}

#------------------------------------------------------------
#  brief enregistre le fichier de configuration
#
proc ::getdss::enregistrer { } {
   variable private
   global caption

   set filetypes [ list [ list "$caption(getdss,fichierparam)" ".ini" ] ]
   set fichier [tk_getSaveFile -title $caption(getdss,sauveconfig) \
      -filetypes $filetypes \
      -initialdir "$::audace(rep_home)" ]

   set fp [open [::getdss::ajoutExtension ${fichier}] w]
   foreach a [array names private] {
      puts $fp "set private($a) \"[lindex [array get private $a] 1]\""
   }
   close $fp
}

#------------------------------------------------------------
#  brief  navigateur de répertoire
#  param creat valeur par défaut y
#
proc ::getdss::getDirname { { creat y } } {
   global caption

   set dirname [tk_chooseDirectory -title $caption(getdss,selectrep) \
      -initialdir $::audace(rep_images)]

   #--- Creation du repertoire si inexistant et si creat vaut 'y'
   if { $dirname != "" } {
      if { $creat == "y" } {
         if { ! [file isdirectory $dirname] } {
            file mkdir $dirname
         }
      }
   }

   return $dirname
}

#------------------------------------------------------------
#  brief  fournit le répertoire
#  param  visuNo numéro de la visu
#
proc ::getdss::getDir { visuNo } {
   variable private

   set old_dir $private($visuNo,rep)

   set rep [ ::getdss::getDirname ]
   if { $rep != "" } {
      set private($visuNo,rep) $rep
   }
}

#------------------------------------------------------------
#  brief  récupère la position de la fenêtre
#  param  visuNo numéro de la visu
#
proc ::getdss::recupPosition { visuNo } {
   variable private
   variable widget

   set widget(getdss,$visuNo,geometry) [ wm geometry $private($visuNo,This) ]
   ::getdss::widgetToConf $visuNo
}

#------------------------------------------------------------
## @brief  commande du bouton "Fermer"
#  @param  visuNo numéro de la visu
#
proc ::getdss::cmdClose { visuNo } {
   variable private
   global old_rep

   #--- Recupere la position de la fenetre
   ::getdss::recupPosition $visuNo

   #--- Restaure le repertoire initial
   catch {cd $old_rep}

   destroy .dialog($visuNo)
   destroy $private($visuNo,This)
}


#
# Fichier : afrho.tcl
# Description : Calcule le parametre Af[Rho] pour une comete
#               Caracterise le taux de production de poussieres des cometes
# Auteurs : Alain KLOTZ, Laurent JORDA et Jean-Francois COLIAC
# Mise à jour $Id: afrho.tcl 12645 2016-01-14 17:47:54Z robertdelmas $
#

#============================================================
# Declaration du namespace afrho
#    initialise le namespace
#============================================================
namespace eval ::afrho {
   package provide afrho 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] afrho.cap ]
}

#------------------------------------------------------------
# getPluginTitle
#    retourne le titre du plugin dans la langue de l'utilisateur
#------------------------------------------------------------
proc ::afrho::getPluginTitle { } {
   global caption

   return "$caption(afrho,afrho)"
}

#------------------------------------------------------------
# getPluginHelp
#    retourne le nom du fichier d'aide principal
#------------------------------------------------------------
proc ::afrho::getPluginHelp { } {
   return "afrho.htm"
}

#------------------------------------------------------------
# getPluginType
#    retourne le type de plugin
#------------------------------------------------------------
proc ::afrho::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# getPluginDirectory
#    retourne le nom du repertoire du plugin
#------------------------------------------------------------
proc ::afrho::getPluginDirectory { } {
   return "afrho"
}

#------------------------------------------------------------
# getPluginOS
#    retourne le ou les OS de fonctionnement du plugin
#------------------------------------------------------------
proc ::afrho::getPluginOS { } {
   return [ list Windows ]
}

#------------------------------------------------------------
# getPluginProperty
#    retourne la valeur de la propriete
#
# parametre :
#    propertyName : nom de la propriete
# return : valeur de la propriete ou "" si la propriete n'existe pas
#------------------------------------------------------------
proc ::afrho::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "comet" }
      display      { return "window" }
   }
}

#------------------------------------------------------------
# createPluginInstance
#    cree une nouvelle instance de l'outil
#------------------------------------------------------------
proc ::afrho::createPluginInstance { base { visuNo 1 } } {
   variable This
   variable widget
   global audace

   #---
   set This "$base.afrho"
   ::afrho::confToWidget
   #--- J'ouvre la fenetre
   ::afrho::createDialog
   #---
   return $This
}

#------------------------------------------------------------
# deletePluginInstance
#    suppprime l'instance du plugin
#------------------------------------------------------------
proc ::afrho::deletePluginInstance { visuNo } {
   variable This

   if [ winfo exists $This ] {
      #--- Je ferme la fenetre si l'utilisateur ne l'a pas deja fait
      ::afrho::cmdClose
   }
}

#------------------------------------------------------------
# confToWidget
#    Charge les variables de configuration dans des variables locales
#------------------------------------------------------------
proc ::afrho::confToWidget { } {
   variable widget
   global caption conf

   #--- Inititalisation de variables de configuration
   if { ! [ info exists conf(afrho,position) ] } { set conf(afrho,position) "+20+20" }
   if { ! [ info exists conf(afrho,verbose) ] }  { set conf(afrho,verbose)  "$caption(afrho,on)" }
   if { ! [ info exists conf(afrho,debug) ] }    { set conf(afrho,debug)    "$caption(afrho,off)" }

   #--- Inititalisation des variables locales en accord avec l'image tempel1_IC.fit
   set widget(filename)       ""
   set widget(centerx)        "193.48"
   set widget(centery)        "125.51"
   set widget(radius1)        "0.0"
   set widget(radius2)        "60.0"
   set widget(rstep)          "1.0"
   set widget(astep)          "1.0"
   set widget(geodist)        "0.726"
   set widget(heliodist)      "1.579"
   set widget(pixelsize)      "0.960"
   set widget(exptime)        "1080.0"
   set widget(airmass)        "1.23"
   set widget(zeropoint)      "17.11"
   set widget(extcoef)        "0.110"
   set widget(fluxzero)       "1.20"
   set widget(solarirr)       "0.101"
   set widget(type)           "1"
   set widget(angle1)         "1"
   set widget(angle2)         "360"
   set widget(nangle)         "100"
   set widget(iterate)        "3"
   set widget(threshold)      "1.0"
   set widget(radfit1)        "12"
   set widget(radfit2)        "60"

   #--- Charge les variables de configuration dans des variables locales
   set widget(afrho,position) "$conf(afrho,position)"
   set widget(afrho,verbose)  "$conf(afrho,verbose)"
   set widget(afrho,debug)    "$conf(afrho,debug)"
}

#------------------------------------------------------------
# widgetToConf
#    Charge les variables locales dans des variables de configuration
#------------------------------------------------------------
proc ::afrho::widgetToConf { } {
   variable widget
   global conf

   set conf(afrho,position) "$widget(afrho,position)"
   set conf(afrho,verbose)  "$widget(afrho,verbose)"
   set conf(afrho,debug)    "$widget(afrho,debug)"
}

#------------------------------------------------------------
# recupPosition
#    Recupere la position de la fenetre
#------------------------------------------------------------
proc ::afrho::recupPosition { } {
   variable This
   variable widget

   set widget(geometry) [wm geometry $This]
   set deb [ expr 1 + [ string first + $widget(geometry) ] ]
   set fin [ string length $widget(geometry) ]
   set widget(afrho,position) "+[string range $widget(geometry) $deb $fin]"
   #---
   ::afrho::widgetToConf
}

#------------------------------------------------------------
# createDialog
#    Creation de l'interface graphique
#------------------------------------------------------------
proc ::afrho::createDialog { } {
   variable This
   variable widget
   global audace caption conf

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This
   wm resizable $This 0 0
   wm deiconify $This
   wm title $This "$caption(afrho,titre)"
   wm geometry $This $widget(afrho,position)
   wm protocol $This WM_DELETE_WINDOW ::afrho::cmdClose

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame2 -borderwidth 0 -relief raised
   pack $This.frame2 -in $This.frame1 -side top -expand 0

   frame $This.frame3 -borderwidth 0 -relief raised
   pack $This.frame3 -in $This.frame1 -side bottom -fill both -expand 1

   frame $This.frame1g -borderwidth 0
   pack $This.frame1g -in $This.frame1 -side left -fill both -expand 1

   frame $This.frame1d -borderwidth 0
   pack $This.frame1d -in $This.frame1 -side right -fill both -expand 1

   frame $This.frame4 -borderwidth 1 -relief raised
   pack $This.frame4 -side top -fill x

   frame $This.frame5 -borderwidth 0 -relief raised
   pack $This.frame5 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame6 -borderwidth 0 -relief raised
   pack $This.frame6 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame7 -borderwidth 0 -relief raised
   pack $This.frame7 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame8 -borderwidth 0 -relief raised
   pack $This.frame8 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame9 -borderwidth 0 -relief raised
   pack $This.frame9 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame10 -borderwidth 0 -relief raised
   pack $This.frame10 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame11 -borderwidth 0 -relief raised
   pack $This.frame11 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame12 -borderwidth 0 -relief raised
   pack $This.frame12 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame13 -borderwidth 0 -relief raised
   pack $This.frame13 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame14 -borderwidth 0 -relief raised
   pack $This.frame14 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame15 -borderwidth 0 -relief raised
   pack $This.frame15 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame16 -borderwidth 0 -relief raised
   pack $This.frame16 -in $This.frame1g -side top -fill both -expand 1

   frame $This.frame17 -borderwidth 0 -relief raised
   pack $This.frame17 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame18 -borderwidth 0 -relief raised
   pack $This.frame18 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame19 -borderwidth 0 -relief raised
   pack $This.frame19 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame20 -borderwidth 0 -relief raised
   pack $This.frame20 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame21 -borderwidth 0 -relief raised
   pack $This.frame21 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame22 -borderwidth 0 -relief raised
   pack $This.frame22 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame23 -borderwidth 0 -relief raised
   pack $This.frame23 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame24 -borderwidth 0 -relief raised
   pack $This.frame24 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame25 -borderwidth 0 -relief raised
   pack $This.frame25 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame26 -borderwidth 0 -relief raised
   pack $This.frame26 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame27 -borderwidth 0 -relief raised
   pack $This.frame27 -in $This.frame1d -side top -fill both -expand 1

   frame $This.frame28 -borderwidth 0 -relief raised
   pack $This.frame28 -in $This.frame1d -side top -fill both -expand 1

   #--- Cree la zone a renseigner du nom de l'image a analyser
   label $This.filename -text "$caption(afrho,image_comete)"
   pack $This.filename -in $This.frame2 -anchor w -side left -padx 10 -pady 3

   entry $This.entryfilename -textvariable ::afrho::widget(filename) -width 30 -state disabled
   pack $This.entryfilename -in $This.frame2 -anchor w -side left -padx 0 -pady 2

   button $This.explore -text "$caption(afrho,parcourir)" -width 1 \
      -command { ::afrho::parcourir }
   pack $This.explore -in $This.frame2 -anchor w -side left -padx 10 -pady 3

   #--- Cree la zone a renseigner center
   label $This.center -text "$caption(afrho,center)"
   pack $This.center -in $This.frame5 -anchor w -side left -padx 10 -pady 3

   entry $This.entrycentery -textvariable ::afrho::widget(centery) -width 8
   pack $This.entrycentery -in $This.frame5 -anchor w -side right -padx 10 -pady 2

   label $This.centery -text "y"
   pack $This.centery -in $This.frame5 -anchor w -side right -padx 0 -pady 2

   entry $This.entrycenterx -textvariable ::afrho::widget(centerx) -width 8
   pack $This.entrycenterx -in $This.frame5 -anchor w -side right -padx 10 -pady 2

   label $This.centerx -text "x"
   pack $This.centerx -in $This.frame5 -anchor w -side right -padx 0 -pady 2

   #--- Cree la zone a renseigner radius1
   label $This.radius1 -text "$caption(afrho,radius1)"
   pack $This.radius1 -in $This.frame6 -anchor w -side left -padx 10 -pady 3

   entry $This.entryradius1 -textvariable ::afrho::widget(radius1) -width 8
   pack $This.entryradius1 -in $This.frame6 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner radius2
   label $This.radius2 -text "$caption(afrho,radius2)"
   pack $This.radius2 -in $This.frame7 -anchor w -side left -padx 10 -pady 3

   entry $This.entryradius2 -textvariable ::afrho::widget(radius2) -width 8
   pack $This.entryradius2 -in $This.frame7 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner rstep
   label $This.rstep -text "$caption(afrho,rstep)"
   pack $This.rstep -in $This.frame8 -anchor w -side left -padx 10 -pady 3

   entry $This.entryrstep -textvariable ::afrho::widget(rstep) -width 8
   pack $This.entryrstep -in $This.frame8 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner astep
   label $This.astep -text "$caption(afrho,astep)"
   pack $This.astep -in $This.frame9 -anchor w -side left -padx 10 -pady 3

   entry $This.entryastep -textvariable ::afrho::widget(astep) -width 8
   pack $This.entryastep -in $This.frame9 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner geodist
   label $This.geodist -text "$caption(afrho,geodist)"
   pack $This.geodist -in $This.frame10 -anchor w -side left -padx 10 -pady 3

   entry $This.entrygeodist -textvariable ::afrho::widget(geodist) -width 8
   pack $This.entrygeodist -in $This.frame10 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner heliodist
   label $This.heliodist -text "$caption(afrho,heliodist)"
   pack $This.heliodist -in $This.frame11 -anchor w -side left -padx 10 -pady 3

   entry $This.entryheliodist -textvariable ::afrho::widget(heliodist) -width 8
   pack $This.entryheliodist -in $This.frame11 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner pixelsize
   label $This.pixelsize -text "$caption(afrho,pixelsize)"
   pack $This.pixelsize -in $This.frame12 -anchor w -side left -padx 10 -pady 3

   entry $This.entrypixelsize -textvariable ::afrho::widget(pixelsize) -width 8
   pack $This.entrypixelsize -in $This.frame12 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner exptime
   label $This.exptime -text "$caption(afrho,exptime)"
   pack $This.exptime -in $This.frame13 -anchor w -side left -padx 10 -pady 3

   entry $This.entryexptime -textvariable ::afrho::widget(exptime) -width 8
   pack $This.entryexptime -in $This.frame13 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner airmass
   label $This.airmass -text "$caption(afrho,airmass)"
   pack $This.airmass -in $This.frame14 -anchor w -side left -padx 10 -pady 3

   entry $This.entryairmass -textvariable ::afrho::widget(airmass) -width 8
   pack $This.entryairmass -in $This.frame14 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner zeropoint
   label $This.zeropoint -text "$caption(afrho,zeropoint)"
   pack $This.zeropoint -in $This.frame15 -anchor w -side left -padx 10 -pady 3

   entry $This.entryzeropoint -textvariable ::afrho::widget(zeropoint) -width 8
   pack $This.entryzeropoint -in $This.frame15 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner extcoef
   label $This.extcoef -text "$caption(afrho,extcoef)"
   pack $This.extcoef -in $This.frame16 -anchor w -side left -padx 10 -pady 3

   entry $This.entryextcoef -textvariable ::afrho::widget(extcoef) -width 8
   pack $This.entryextcoef -in $This.frame16 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner fluxzero
   label $This.fluxzero -text "$caption(afrho,fluxzero)"
   pack $This.fluxzero -in $This.frame17 -anchor w -side left -padx 10 -pady 3

   entry $This.entryfluxzero -textvariable ::afrho::widget(fluxzero) -width 8
   pack $This.entryfluxzero -in $This.frame17 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner solarirr
   label $This.solarirr -text "$caption(afrho,solarirr)"
   pack $This.solarirr -in $This.frame18 -anchor w -side left -padx 10 -pady 3

   entry $This.entrysolarirr -textvariable ::afrho::widget(solarirr) -width 8
   pack $This.entrysolarirr -in $This.frame18 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner type
   label $This.type -text "$caption(afrho,type)"
   pack $This.type -in $This.frame19 -anchor w -side left -padx 10 -pady 3

   entry $This.entrytype -textvariable ::afrho::widget(type) -width 8
   pack $This.entrytype -in $This.frame19 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner angle1
   label $This.angle1 -text "$caption(afrho,angle1)"
   pack $This.angle1 -in $This.frame20 -anchor w -side left -padx 10 -pady 3

   entry $This.entryangle1 -textvariable ::afrho::widget(angle1) -width 8
   pack $This.entryangle1 -in $This.frame20 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner angle2
   label $This.angle2 -text "$caption(afrho,angle2)"
   pack $This.angle2 -in $This.frame21 -anchor w -side left -padx 10 -pady 3

   entry $This.entryangle2 -textvariable ::afrho::widget(angle2) -width 8
   pack $This.entryangle2 -in $This.frame21 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner nangle
   label $This.nangle -text "$caption(afrho,nangle)"
   pack $This.nangle -in $This.frame22 -anchor w -side left -padx 10 -pady 3

   entry $This.entrynangle -textvariable ::afrho::widget(nangle) -width 8
   pack $This.entrynangle -in $This.frame22 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner iterate
   label $This.iterate -text "$caption(afrho,iterate)"
   pack $This.iterate -in $This.frame23 -anchor w -side left -padx 10 -pady 3

   entry $This.entryiterate -textvariable ::afrho::widget(iterate) -width 8
   pack $This.entryiterate -in $This.frame23 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner threshold
   label $This.threshold -text "$caption(afrho,threshold)"
   pack $This.threshold -in $This.frame24 -anchor w -side left -padx 10 -pady 3

   entry $This.entrythreshold -textvariable ::afrho::widget(threshold) -width 8
   pack $This.entrythreshold -in $This.frame24 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner radfit1
   label $This.radfit1 -text "$caption(afrho,radfit1)"
   pack $This.radfit1 -in $This.frame25 -anchor w -side left -padx 10 -pady 3

   entry $This.entryradfit1 -textvariable ::afrho::widget(radfit1) -width 8
   pack $This.entryradfit1 -in $This.frame25 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner radfit2
   label $This.radfit2 -text "$caption(afrho,radfit2)"
   pack $This.radfit2 -in $This.frame26 -anchor w -side left -padx 10 -pady 3

   entry $This.entryradfit2 -textvariable ::afrho::widget(radfit2) -width 8
   pack $This.entryradfit2 -in $This.frame26 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner verbose
   label $This.verbose -text "$caption(afrho,verbose)"
   pack $This.verbose -in $This.frame27 -anchor w -side left -padx 10 -pady 3

   set list_combobox [ list $caption(afrho,on) $caption(afrho,off) ]
   ComboBox $This.entryverbose \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken \
      -borderwidth 1 \
      -editable 0    \
      -textvariable ::afrho::widget(afrho,verbose) \
      -values $list_combobox
   pack $This.entryverbose -in $This.frame27 -anchor w -side right -padx 10 -pady 2

   #--- Cree la zone a renseigner debug
   label $This.debug -text "$caption(afrho,debug)"
   pack $This.debug -in $This.frame28 -anchor w -side left -padx 10 -pady 3

   ComboBox $This.entrydebug \
      -width [ ::tkutil::lgEntryComboBox $list_combobox ] \
      -height [ llength $list_combobox ] \
      -relief sunken \
      -borderwidth 1 \
      -editable 0    \
      -textvariable ::afrho::widget(afrho,debug) \
      -values $list_combobox
   pack $This.entrydebug -in $This.frame28 -anchor w -side right -padx 10 -pady 2

   #--- Frame du site web expliquant le parametre afrho
   label $This.label -text "$caption(afrho,site_web)"
   pack $This.label -in $This.frame3 -side top -fill x -pady 2

   set labelName [ ::afrho::createUrlLabel $This.frame3 "$caption(afrho,site_web_ref)" \
      "$caption(afrho,site_web_ref)" ]
   pack $labelName -in $This.frame3 -side top -fill x -pady 2

   #--- Cree le bouton 'OK'
   button $This.but_ok -text "$caption(afrho,ok)" -width 7 -borderwidth 2 \
      -command "::afrho::ok"
   if { $conf(ok+appliquer) == "1" } {
      pack $This.but_ok -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5
   }

   #--- Cree le bouton 'Appliquer'
   button $This.but_appliquer -text "$caption(afrho,appliquer)" -width 8 -borderwidth 2 \
      -command "::afrho::cmdApply"
   pack $This.but_appliquer -in $This.frame4 -side left -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Fermer'
   button $This.but_fermer -text "$caption(afrho,fermer)" -width 7 -borderwidth 2 \
      -command "::afrho::cmdClose"
   pack $This.but_fermer -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- Cree le bouton 'Aide'
   button $This.but_aide -text "$caption(afrho,aide)" -width 7 -borderwidth 2 \
      -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::afrho::getPluginType ] ] \
         [ ::afrho::getPluginDirectory ] [ ::afrho::getPluginHelp ]"
   pack $This.but_aide -in $This.frame4 -side right -anchor w -padx 3 -pady 3 -ipady 5

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#------------------------------------------------------------
# createUrlLabel
#    Gestion du site web
#------------------------------------------------------------
proc ::afrho::createUrlLabel { tkparent title url } {
   global color

   label $tkparent.labURL -text "$title" -fg $color(blue)
   if { $url != "" } {
      bind $tkparent.labURL <ButtonPress-1> "::audace::Lance_Site_htm $url"
   }
   bind $tkparent.labURL <Enter> "$tkparent.labURL configure -fg $color(purple)"
   bind $tkparent.labURL <Leave> "$tkparent.labURL configure -fg $color(blue)"
   return $tkparent.labURL
}

#------------------------------------------------------------
# gestionErreur
#    Surveille si l'image appartient au repertoire des images
#------------------------------------------------------------
proc ::afrho::gestionErreur { filename } {
   global audace caption

   #--- Initialisation
   set error "0"
   #--- Verifie que le fichier selectionne appartient au repertoire des images
   if { [ file dirname $filename ] != $audace(rep_images) } {
      tk_messageBox -title "$caption(afrho,attention)" -icon error \
         -message "$caption(afrho,rep-images)"
      set error "1"
      return $error
   }
   return $error
}

#------------------------------------------------------------
# parcourir
#    Ouvre un explorateur pour choisir un fichier
#------------------------------------------------------------
proc ::afrho::parcourir { } {
   variable This
   variable widget
   global audace

   #--- Fenetre parent
   set fenetre "$This"
   #--- Ouvre la fenetre de choix des images et selectionne l'image
   set filename [ ::tkutil::box_load $fenetre $audace(rep_images) $audace(bufNo) "1" ]
   if { $filename != "" } {
      set error [ ::afrho::gestionErreur $filename ]
      if { $error == "1" } {
         return
      }
   }
   set widget(filename) [ file rootname [ file tail $filename ] ]
}

#------------------------------------------------------------
# ok
#    Procedure correspondant a l'appui sur le bouton OK
#------------------------------------------------------------
proc ::afrho::ok { } {
   ::afrho::cmdApply
   ::afrho::cmdClose
}

#------------------------------------------------------------
# cmdApply
#    Procedure correspondant a l'appui sur le bouton Appliquer
#------------------------------------------------------------
proc ::afrho::cmdApply { } {
   variable widget
   global audace caption

   #--- Gestion d'erreur
   if { $widget(filename) == "" } {
      return
   }

   #--- Initialisation de l'image a analyser
   set cometfilename "$widget(filename)"

   #--- Analyse de l'image de la comete
   catch {unset afrho}
   set afrho(params,1,FILEIN)    [list ${cometfilename}.fit        " Ajout KLOTZ"]
   set afrho(params,1,FILEOUT)   [list ${cometfilename}.fts        " Ajout KLOTZ"]
   set afrho(params,1,CENTER)    [list $widget(centerx),$widget(centery)               " position of opto-center (pixels)"]
   set afrho(params,1,RADIUS1)   [list $widget(radius1)                         " first radius (pixels)"]
   set afrho(params,1,RADIUS2)   [list $widget(radius2)                        " last radius (pixels)"]
   set afrho(params,1,RSTEP)     [list $widget(rstep)                         " pixel size along radius (pixels)"]
   set afrho(params,1,ASTEP)     [list $widget(astep)                         " pixel size along azimuth (degrees)"]

   set afrho(params,2,GEODIST)   [list $widget(geodist)                       " geocentric distance (AU)"]
   set afrho(params,2,HELIODIST) [list $widget(heliodist)                       " heliocentric distance (AU)"]

   set afrho(params,3,PIXELSIZE) [list $widget(pixelsize)                       " pixel scale (arcsec/pixel)"]
   set afrho(params,3,EXPTIME)   [list $widget(exptime)                      " exposure time (sec)"]
   set afrho(params,3,AIRMASS)   [list $widget(airmass)                        " airmass of image"]
   set afrho(params,3,ZEROPOINT) [list $widget(zeropoint)                       " zero-point for filter"]
   set afrho(params,3,EXTCOEFF)  [list $widget(extcoef)                       " extinction coefficient (mag/airmass)"]
   set afrho(params,3,FLUXZERO)  [list $widget(fluxzero)                        " flux for zero magnitude for filter"]
   set afrho(params,3,SOLARIRR)  [list $widget(solarirr)                       " solar irradiance in filter (W/m2/A)"]

   set afrho(params,4,TYPE)      [list $widget(type)                           " type of profile"]
   set afrho(params,4,ANGLE1)    [list $widget(angle1)                           " first angle for AVERAGE/CLIPPING"]
   set afrho(params,4,ANGLE2)    [list $widget(angle2)                         " last angle for AVERAGE/CLIPPING"]
   set afrho(params,4,NANGLE)    [list $widget(nangle)                         " number of angles for MINIMUM/MAXIMUM"]
   set afrho(params,4,ITERATE)   [list $widget(iterate)                           " number of iterations for CLIPPING"]
   set afrho(params,4,THRESHOLD) [list $widget(threshold)                         " threshold (RMS units) for CLIPPING"]
   set afrho(params,4,RADFIT1)   [list $widget(radfit1)                          " first radius taken into account"]
   set afrho(params,4,RADFIT2)   [list $widget(radfit2)                          " last radius taken into account"]
   set afrho(params,4,RPFILE)    [list ${cometfilename}.out        " Ajout KLOTZ"]

   set afrho(params,5,VERBOSE)   [list $widget(afrho,verbose)                          " "]
   set afrho(params,5,DEBUG)     [list $widget(afrho,debug)                          " "]

   set t ""
   append t "################################################################################\n"
   append t "#\n"
   append t "# CONFIGURATION FILE FOR THE PROGRAM CAL_AFR.FOR\n"
   append t "#\n"
   append t "# VERSION 0.01 -- 14-NOV-2003 (L. JORDA -- LAM, MARSEILLE, FRANCE)\n"
   append t "#\n"
   append t "################################################################################\n"
   append t "\n"
   append t "################################################################################\n"
   append t "# Cartesian-to-polar image conversion\n"
   append t "# ===================================\n"
   append t "#\n"
   append t "# FILEIN       : Name of the input image of the comet -- FITS format (in ADU)\n"
   append t "# FILEOUT    : Name of the output image of the comet in polar coordinates -- FITS format (in ADU)\n"
   append t "# CENTER     : Position of the comet optocenter on the image (in pixels)\n"
   append t "#                   -- center of bottom left pixel is (1,1)\n"
   append t "# RADIUS1   : First radius of polar image (in pixels) -- usually set to 0.0\n"
   append t "# RADIUS2   : Last radius of polar image (in pixels) -- must be <= smallest\n"
   append t "#                    distance from the optocenter to the edges of the CCD\n"
   append t "# RSTEP       : Pixel size of polar image along Y (distance from optocenter,\n"
   append t "#                    in pixels) -- usually set to 1.0\n"
   append t "# ASTEP       : Pixel size of polar image along X (azimuth, in degrees) -- usually\n"
   append t "#                    set to 1.0 degree\n"
   append t "#\n"
   append t "################################################################################\n"
   append t "\n"
   set n 1
   set names [lsort [array names afrho]]
   foreach name $names {
      set k   [string range $name [expr 1+[string first , $name]] [expr [string last , $name]-1]]
      set key [string range $name [expr 1+[string last , $name]] end]
      if {$k==$n} {
         set val [lindex $afrho(params,$k,$key) 0]
         set com [lindex $afrho(params,$k,$key) 1]
         set key [string range ${key}[string repeat " " 10] 0 9]
         set val [string range ${val}[string repeat " " 26] 0 26]
         append t "${key}= $val \#$com\n"
      }
   }
   append t "\n"
   append t "################################################################################\n"
   append t "# Geometric comet parameters\n"
   append t "# ==========================\n"
   append t "#\n"
   append t "# GEODIST   : Geocentric distance of the comet at the time of the observation\n"
   append t "#                    (in AU) -- deduced from the ephemeris of the comet\n"
   append t "# HELIODIS  : Heliocentric distance of the comet at the time of the\n"
   append t "#                    observation (in AU) -- deduced from the ephemeris of the comet\n"
   append t "#\n"
   append t "################################################################################\n"
   append t "\n"
   set n 2
   set names [lsort [array names afrho]]
   foreach name $names {
      set k   [string range $name [expr 1+[string first , $name]] [expr [string last , $name]-1]]
      set key [string range $name [expr 1+[string last , $name]] end]
      if {$k==$n} {
         set val [lindex $afrho(params,$k,$key) 0]
         set com [lindex $afrho(params,$k,$key) 1]
         set key [string range ${key}[string repeat " " 10] 0 9]
         set val [string range ${val}[string repeat " " 26] 0 26]
         append t "${key}= $val \#$com\n"
      }
   }
   append t "\n"
   append t "################################################################################\n"
   append t "# Instrument characteristics\n"
   append t "# ==========================\n"
   append t "#\n"
   append t "# PIXELSIZE  : Size of the pixels of the image (in arcsec/pixel)\n"
   append t "# EXPTIME     : Total exposure time of the image (in sec)\n"
   append t "# AIRMASS    : Airmass at the time of the observations of the comet -- if the\n"
   append t "#                     atmospheric extinction is unknown (keyword EXTCOEFF), set its\n"
   append t "#                     value to 1.0 (zenith)\n"
   append t "# ZEROPOINT : Zero-point of the filter/CCD/telescope combination -- this must\n"
   append t "#                     be computed from the absolute calibration of the instrument\n"
   append t "#                     using standard stars of known magnitude\n"
   append t "# EXTCOEFF   : Atmospheric extinction (in mag/airmass) -- this must be computed\n"
   append t "#                     from the observation of standard star(s) at different airmasses.\n"
   append t "#                     If it cannot be computed, set its value to 0.0 (no extinction)\n"
   append t "# FLUXZERO   : Flux corresponding to a magnitude = 0 (in E-12 W/m^2/A) -- values\n"
   append t "#                     for standard Bessel filters are given below:\n"
   append t "#\n"
   append t "#               U(BESSEL) -> 4.19\n"
   append t "#               B(BESSEL) -> 6.60\n"
   append t "#               V(BESSEL) -> 3.61\n"
   append t "#               R(BESSEL) -> 2.25\n"
   append t "#               I(BESSEL) -> 1.20\n"
   append t "#\n"
   append t "# SOLARIRR   : Mean solar irradiance for the filter/CCD combination (in W/m^2/A)\n"
   append t "#                     -- values for standard Bessel filters are given below:\n"
   append t "#\n"
   append t "#               U(BESSEL) -> 0.11\n"
   append t "#               B(BESSEL) -> 0.19\n"
   append t "#               V(BESSEL) -> 0.18\n"
   append t "#               R(BESSEL) -> 0.16\n"
   append t "#               I(BESSEL) -> 0.10\n"
   append t "#\n"
   append t "################################################################################\n"
   append t "\n"
   set n 3
   set names [lsort [array names afrho]]
   foreach name $names {
      set k   [string range $name [expr 1+[string first , $name]] [expr [string last , $name]-1]]
      set key [string range $name [expr 1+[string last , $name]] end]
      if {$k==$n} {
         set val [lindex $afrho(params,$k,$key) 0]
         set com [lindex $afrho(params,$k,$key) 1]
         set key [string range ${key}[string repeat " " 10] 0 9]
         set val [string range ${val}[string repeat " " 26] 0 26]
         append t "${key}= $val \#$com\n"
      }
   }
   append t "\n"
   append t "################################################################################\n"
   append t "# Radial profile calculation\n"
   append t "# ==========================\n"
   append t "#\n"
   append t "# TYPE      : Type of radial profile to be computed (number in the range 1-4):\n"
   append t "#\n"
   append t "#               /1/Average radial profile computed from pixels ANGLE1 to ANGLE2\n"
   append t "#                  of the image in polar coordinates\n"
   append t "#               /2/Minimum radial profile computed by averaging the NANGLE\n"
   append t "#                  lowest pixel values at a given radius from the optocenter\n"
   append t "#               /3/Maximum radial profile computed by averaging the NANGLE\n"
   append t "#                  highest pixel values at a given radius from the optocenter\n"
   append t "#               /4/Radial profile obtained by a sigma-clipping of the pixel\n"
   append t "#                  values between ANGLE1 and ANGLE2 in the image in polar\n"
   append t "#                  coordinate using threshold THRESHOLD and a number of\n"
   append t "#                  iterations given by the keyword ITERATE\n"
   append t "#\n"
   append t "#             The value must be set to 1 unless bright stars contribute to\n"
   append t "#             the radial profile. In that case, set this parameter to either\n"
   append t "#             2 or 4.\n"
   append t "# ANGLE1       : Index of the first pixel to be used to compute the radial profile\n"
   append t "#                      -- set to 1 if all azimuths (X) pixels of the image in polar\n"
   append t "#                      coordinates are to be used, relevant if TYPE=1 or TYPE=4\n"
   append t "# ANGLE2       : Index of the last pixel to be used to compute the radial profile\n"
   append t "#                      -- set to 360 if all azimuths (X) pixels of the image in polar\n"
   append t "#                      coordinates are to be used, relevant if TYPE=1 or TYPE=4\n"
   append t "# NANGLE       : Number of pixels (angles) to be used to compute the radial\n"
   append t "#                      profile -- set it to about 100 to 300 depending on the maximum\n"
   append t "#                      number of pixels contaminated by field star(s) in the image in\n"
   append t "#                      polar coordinates, relevant if TYPE=2 or TYPE=3\n"
   append t "# ITERATE      : Number of iterations used in the sigma-clipping -- set its value\n"
   append t "#                      to 3 to 4, relevant only if TYPE=4\n"
   append t "# THRESHOLD : Threshold to be used in the sigma-clipping -- set its value to\n"
   append t "#                      1.5 to 3.0, relevant only if TYPE=4\n"
   append t "# RADFIT1      : Minimum radius (in pixels of the image in polar coordinates)\n"
   append t "#                      used to compute the Af\[Rho\] parameter -- set this value to the\n"
   append t "#                      FWHM (seeing) of point-like sources (e.g., stars) in pixels\n"
   append t "# RADFIT2      : Maximum radius (in pixels of the image in polar coordinates)\n"
   append t "#                      used to compute the Af\[Rho\] parameter -- set this value to the\n"
   append t "#                      maximum distance from the optocenter (in pixels) at which the\n"
   append t "#                      coma of the comet is still detected\n"
   append t "# RPFILE         : Name of the output file containing the radial profiles:\n"
   append t "#\n"
   append t "#               Column 1 -> Radial distance (in pixels)\n"
   append t "#               Column 2 -> Measured radial profile (in E-20 W/m^2/A)\n"
   append t "#               Column 3 -> Associated error (in E-20 W/m^2/A)\n"
   append t "#               Column 4 -> Fitted radial profile (in E-20 W/m^2/A)\n"
   append t "#\n"
   append t "#             Plot (Column1,Column3) is to be compared to (Column1,Column4).\n"
   append t "#\n"
   append t "################################################################################\n"
   append t "\n"
   set n 4
   set names [lsort [array names afrho]]
   foreach name $names {
      set k   [string range $name [expr 1+[string first , $name]] [expr [string last , $name]-1]]
      set key [string range $name [expr 1+[string last , $name]] end]
      if {$k==$n} {
         set val [lindex $afrho(params,$k,$key) 0]
         set com [lindex $afrho(params,$k,$key) 1]
         set key [string range ${key}[string repeat " " 10] 0 9]
         set val [string range ${val}[string repeat " " 26] 0 26]
         append t "${key}= $val \#$com\n"
      }
   }
   append t "\n"
   append t "################################################################################\n"
   append t "# General options\n"
   append t "# ===============\n"
   append t "#\n"
   append t "# VERBOSE   : Set verbose mode /ON/OFF/ -- recommended: ON\n"
   append t "# DEBUG       : Set debug mode /ON/OFF/ -- recommended: OFF\n"
   append t "#\n"
   append t "################################################################################\n"
   append t "\n"
   set n 5
   set names [lsort [array names afrho]]
   foreach name $names {
      set k   [string range $name [expr 1+[string first , $name]] [expr [string last , $name]-1]]
      set key [string range $name [expr 1+[string last , $name]] end]
      if {$k==$n} {
         set val [lindex $afrho(params,$k,$key) 0]
         set com [lindex $afrho(params,$k,$key) 1]
         set key [string range ${key}[string repeat " " 10] 0 9]
         set val [string range ${val}[string repeat " " 26] 0 26]
         append t "${key}= $val \#$com\n"
      }
   }
   ::console::affiche_resultat_bis "$t\n"

   set pathpwd $audace(rep_travail)
   set pathimg $audace(rep_images)

   set cometfilename [file rootname [lindex $afrho(params,1,FILEIN) 0]]

   set f [open [ file join ${pathimg} ${cometfilename}.cfg ] w]
   puts -nonewline $f $t
   close $f

   #--- Initialisation de la variable de gestion des erreurs
   set catchError "0"

   if { $pathpwd != $pathimg } {
   #--- Cas ou les repertoires de travail et des images sont differents

      file copy -force [ file join ${pathimg} ${cometfilename}.cfg ] [ file join ${pathpwd} cal_afr.cfg ]
      file copy -force [ file join ${pathimg} [lindex $afrho(params,1,FILEIN) 0] ] [ file join ${pathpwd} [lindex $afrho(params,1,FILEIN) 0] ]

      set catchError [catch {exec cal_afr.exe} msgs]
      ::console::affiche_resultat_bis "$msgs\n\n"

      if { $catchError == "0" } {
         file copy -force [ file join ${pathpwd} [lindex $afrho(params,1,FILEOUT) 0] ] [ file join ${pathimg} [lindex $afrho(params,1,FILEOUT) 0] ]
         file copy -force [ file join ${pathpwd} [lindex $afrho(params,4,RPFILE) 0] ] [ file join ${pathimg} [lindex $afrho(params,4,RPFILE) 0] ]
      }

   } elseif { $pathpwd == $pathimg } {
   #--- Cas ou les repertoires de travail et des images sont identiques

      file copy -force [ file join ${pathimg} ${cometfilename}.cfg ] [ file join ${pathimg} cal_afr.cfg ]

      set catchError [catch {exec cal_afr.exe} msgs]
      ::console::affiche_resultat_bis "$msgs\n\n"

   }

   if { $catchError == "0" } {
      set fileout [ file join ${pathimg} [lindex $afrho(params,4,RPFILE) 0] ]
      set f [open $fileout r]
      set lignes [split [read $f] \n]
      close $f
      set fileoutname [ file tail $fileout ]
   }

   #--- Suppression des fichiers temporaires
   if { [ file exists [ file join "$pathpwd" cal_afr.cfg ] ] } {
      file delete [ file join "$pathpwd" cal_afr.cfg ]
   }
   if { $pathpwd != $pathimg } {
      if { [ file exists [ file join "$pathpwd" [lindex $afrho(params,1,FILEIN) 0] ] ] } {
         file delete [ file join "$pathpwd" [lindex $afrho(params,1,FILEIN) 0] ]
      }
   }
   if { [ file exists [ file join "$pathpwd" [lindex $afrho(params,1,FILEOUT) 0] ] ] } {
      file delete [ file join "$pathpwd" [lindex $afrho(params,1,FILEOUT) 0] ]
   }
   if { [ file exists [ file join "$pathpwd" [lindex $afrho(params,4,RPFILE) 0] ] ] } {
      file delete [ file join "$pathpwd" [lindex $afrho(params,4,RPFILE) 0] ]
   }
   if { [ file exists [ file join "$pathimg" $cometfilename.cfg ] ] } {
      file delete [ file join "$pathimg" $cometfilename.cfg ]
   }
   if { [ file exists [ file join "$pathimg" [lindex $afrho(params,1,FILEOUT) 0] ] ] } {
      file delete [ file join "$pathimg" [lindex $afrho(params,1,FILEOUT) 0] ]
   }
   if { [ file exists [ file join "$pathimg" [lindex $afrho(params,4,RPFILE) 0] ] ] } {
      file delete [ file join "$pathimg" [lindex $afrho(params,4,RPFILE) 0] ]
   }

   if { $catchError == "0" } {

      set n      [expr [llength $lignes]-2]
      set lignes [lrange $lignes 0 $n]
      set res    [gsl_mtranspose $lignes]

      set x  [lindex $res 0]
      set y1 [lindex $res 1]
      set y2 [lindex $res 2]
      set y3 [lindex $res 3]

      #--- Graphique
      ::plotxy::figure AfRho
      ::plotxy::title "$fileoutname"
      ::plotxy::plotbackground #FFFFFF
      ::plotxy::plot $x $y1 r- 0
      ::plotxy::hold on
      ::plotxy::plot $x $y2 r: 0
      ::plotxy::plot $x $y3 b 0
      ::plotxy::position {40 40 600 600}
      ::plotxy::xlabel "Radial distance (in pixels)"
      ::plotxy::ylabel "Profile (in E-20 W/m^2/A)"

   } else {

      tk_messageBox -icon info -message "$caption(afrho,erreurCalAfr) $msgs" -title $caption(afrho,attention) -type ok

   }

   #--- Recupere la position de la fenetre
   ::afrho::recupPosition
}

#------------------------------------------------------------
# cmdClose
#    Procedure correspondant a l'appui sur le bouton Fermer
#------------------------------------------------------------
proc ::afrho::cmdClose { } {
   variable This

   #--- Recupere la position de la fenetre
   ::afrho::recupPosition
   #--- Detruit la fenetre
   destroy $This
}


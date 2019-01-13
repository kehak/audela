#
## @file catalogexplorer.tcl
#  @brief Gère la fenêtre pour catalogexplorer
#  @author Raymond Zachantke
#  $Id: catalogexplorer.tcl 14523 2018-10-25 14:59:39Z rzachantke $
#

#============================================================
# Declaration du namespace catalogexplorer
#    initialise le namespace
#============================================================

## @namespace catalogexplorer
#  @brief Gère la fenêtre pour catalogexplorer
namespace eval ::catalogexplorer {
   package provide catalogexplorer 1.0

   #--- Chargement des captions pour recuperer le titre utilise par getPluginLabel
   source [ file join [file dirname [info script]] catalogexplorer.cap ]
}

#------------------------------------------------------------
# brief      retourne le titre du plugin dans la langue de l'utilisateur
# return     titre du plugin
#
proc ::catalogexplorer::getPluginTitle { } {
   global caption

   return "$caption(catalogexplorer,titre)"
}

#------------------------------------------------------------
# brief      retourne le nom du fichier d'aide principal
# return     nom du fichier d'aide principal
#
proc ::catalogexplorer::getPluginHelp { } {
   return "catalogexplorer.htm"
}

#------------------------------------------------------------
# brief      retourne le type de plugin
# return     type de plugin
#
proc ::catalogexplorer::getPluginType { } {
   return "tool"
}

#------------------------------------------------------------
# brief      retourne le nom du répertoire du plugin
# return     nom du répertoire du plugin : "catalogexplorer"
#
proc ::catalogexplorer::getPluginDirectory { } {
   return "catalogexplorer"
}

#------------------------------------------------------------
## @brief     retourne le ou les OS de fonctionnement du plugin
#  @return    liste des OS : "Windows Linux Darwin"
#
proc ::catalogexplorer::getPluginOS { } {
   return [ list Windows Linux Darwin ]
}

#------------------------------------------------------------
## @brief    retourne les propriétés de l'outil
#
#            cet outil s'ouvre dans une fenêtre indépendante à partir du menu Analyse
#  @param    propertyName nom de la propriété
#  @return   valeur de la propriété ou "" si la propriété n'existe pas
#
proc ::catalogexplorer::getPluginProperty { propertyName } {
   switch $propertyName {
      function     { return "analysis" }
      subfunction1 { return "catalog" }
      display      { return "window" }
      default      { return "" }
   }
}

#------------------------------------------------------------
## @brief   créé une nouvelle instance de l'outil
#  @param   base   base tk
#  @param   visuNo numéro de la visu
#  @return  chemin de la fenêtre
#
proc ::catalogexplorer::createPluginInstance { base { visuNo 1 } } {
   variable This
   variable widget
   global audace conf caption

   package require BLT 2.4
   package require struct::matrix

   #--- Chargement de la partie svg et html
   source [ file join $audace(rep_plugin) tool catalogexplorer catalogexplorer_svg.tcl ]
   #--- Chargement des procs de lecture des catalogues
   source [ file join $audace(rep_plugin) tool catalogexplorer catalogexplorer_tech.tcl ]
   #--- Chargement des procs d'evaluation du type spectral
   source [ file join $audace(rep_plugin) tool catalogexplorer catalogexplorer_typesp.tcl ]
   #--- Chargement des procs pour consulter VizieR pour le type spectral et photometrie
   source [ file join $audace(rep_plugin) tool catalogexplorer catalogexplorer_vizier.tcl ]

   #--- Inititalisation du nom de la fenetre
   set This "$base.catalogexplorer"

   #--- Charge les variables de configuration dans des variables locales
   ::catalogexplorer::confToWidget

   #--- Initialisation des variables
   set widget(catalogexplorer,listCatalog) "[list 2MASS BMK GAIA1 GAIA2 LONEOS NOMAD1 PPMX PPMXL TYCHO2_FAST UCAC2 UCAC3 UCAC4 URAT1 USNOA2 AAVSO I/280B B/wds]"
   set widget(catalogexplorer,listZoom) [list 1.5 1.4 1.3 1.2 1.1 1.0 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1 0.05]
   set widget(catalogexplorer,fov_deg) "0.0"

   #--- Inititalisation au zenith
   lassign [coordofzenith] widget(catalogexplorer,crval1) widget(catalogexplorer,crval2)

   ::catalogexplorer::createDialog

   return $This
}

#------------------------------------------------------------
## @brief   suppprime l'instance du plugin si l'utilisateur ne l'a pas deja fait
#  @param   visuNo numéro de la visu
#
proc ::catalogexplorer::deletePluginInstance { { visuNo 1 } } {
   variable This

   if { [ winfo exists $This ] } {
      ::catalogexplorer::cmdClose
   }
}

#------------------------------------------------------------
## @brief initialise les paramètres de l'outil "Explorateur de catalogues"
#  @details les variables conf(...) suivantes sont sauvegardées dans le fichier de configuration "audace.ini" :
#  - conf(catalogexplorer,position) définit la position de la fenêtre
#  - conf(catalogexplorer,options) définit les options affichées au démarrage
#
proc ::catalogexplorer::initConf { } {
   global conf

   if {[info exists conf(catalogexplorer,position)] ==0} {
      set conf(catalogexplorer,position) "+350+50"
   }
   if {[info exists conf(catalogexplorer,options)] ==0} {
      set conf(catalogexplorer,options) [list USNOA2 \
         640 480 8.0 8.0 0.025 0.00 6.00 -2.00 0.7 ]
   }
}


#------------------------------------------------------------
#  brief   charge les variables de configuration dans des variables locales
#
proc ::catalogexplorer::confToWidget { } {
   variable widget
   global conf

   #--- Initialisation de variables de configuration
   ::catalogexplorer::initConf

  set widget(catalogexplorer,position) "$conf(catalogexplorer,position)"
  lassign $conf(catalogexplorer,options) widget(catalogexplorer,catalog) \
      widget(catalogexplorer,naxis1) widget(catalogexplorer,naxis2) \
      widget(catalogexplorer,pixsize1) widget(catalogexplorer,pixsize2) \
      widget(catalogexplorer,foclen) widget(catalogexplorer,crota2) \
      widget(catalogexplorer,mag_faint) widget(catalogexplorer,mag_bright) \
      widget(catalogexplorer,zoom) ]
}

#------------------------------------------------------------
#  brief   charge les variables locales dans des variables de configuration
#
proc ::catalogexplorer::widgetToConf { } {
   variable This
   variable widget
   global conf

   set widget(geometry) [ wm geometry $This ]
   set deb [ expr 1 + [ string first + $widget(geometry) ] ]
   set fin [ string length $widget(geometry) ]
   set conf(catalogexplorer,position) "+[string range $widget(geometry) $deb $fin]"

   set conf(catalogexplorer,options) [list $widget(catalogexplorer,catalog) \
      $widget(catalogexplorer,naxis1) $widget(catalogexplorer,naxis2) \
      $widget(catalogexplorer,pixsize1) $widget(catalogexplorer,pixsize2) \
      $widget(catalogexplorer,foclen) $widget(catalogexplorer,crota2) \
      $widget(catalogexplorer,mag_faint) $widget(catalogexplorer,mag_bright) \
      $widget(catalogexplorer,zoom)]
}

#------------------------------------------------------------
#  brief   créé l'interface graphique
#
proc ::catalogexplorer::createDialog { } {
   variable This
   variable widget
   global caption

   if {[winfo exists $This] ==1} {
      wm deiconify $This
   }

   #--- Cree la fenetre $This de niveau le plus haut
   toplevel $This -class Toplevel
   wm resizable $This 0 0
   wm deiconify $This
   wm title $This "$caption(catalogexplorer,titre)"
   wm geometry $This $widget(catalogexplorer,position)
   wm protocol $This WM_DELETE_WINDOW ::catalogexplorer::cmdClose

   #--- Creation des differents frames
   frame $This.frame1 -borderwidth 1 -relief raised
   pack $This.frame1 -side top -fill both -expand 1

   frame $This.frame20 -borderwidth 1 -relief raised
   pack $This.frame20 -side top -fill x

   #--- Naxis1
   frame $This.frame2 -borderwidth 0
      label $This.labnaxis -text "$caption(catalogexplorer,naxis)"
      pack $This.labnaxis -in $This.frame2 -side left -anchor w -padx 5 -pady 5
      entry $This.naxis2 -textvariable ::catalogexplorer::widget(catalogexplorer,naxis2) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.naxis2 -in $This.frame2 -side right -padx 5 -pady 5 -ipady 5
      entry $This.naxis1 -textvariable ::catalogexplorer::widget(catalogexplorer,naxis1) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.naxis1 -in $This.frame2 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame2 -in $This.frame1 -side top -fill both -expand 1

   #--- Taille des pixels
   frame $This.frame3 -borderwidth 0
      label $This.labpixsize -text "$caption(catalogexplorer,pixsize)"
      pack $This.labpixsize -in $This.frame3 -side left -anchor w -padx 5 -pady 5
      entry $This.pixsize2 -textvariable ::catalogexplorer::widget(catalogexplorer,pixsize2) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.pixsize2 -in $This.frame3 -side right -padx 5 -pady 5 -ipady 5
      entry $This.pixsize1 -textvariable ::catalogexplorer::widget(catalogexplorer,pixsize1) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.pixsize1 -in $This.frame3 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame3 -in $This.frame1 -side top -fill both -expand 1

   #--- Longueur focale
   frame $This.frame4 -borderwidth 0
      label $This.labfoclen -text "$caption(catalogexplorer,foclen)"
      pack $This.labfoclen -in $This.frame4 -side left -anchor w -padx 5 -pady 5
      entry $This.foclen -textvariable ::catalogexplorer::widget(catalogexplorer,foclen) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.foclen -in $This.frame4 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame4 -in $This.frame1 -side top -fill both -expand 1

   #--- Champ
   frame $This.frame5 -borderwidth 0
      label $This.labfov -text "$caption(catalogexplorer,fov)"
      pack $This.labfov -in $This.frame5 -side left -anchor w -padx 5 -pady 5
      entry $This.fov -textvariable ::catalogexplorer::widget(catalogexplorer,fov_deg) \
         -justify center -width 6 -relief groove -borderwidth 1 -state readonly
      pack $This.fov -in $This.frame5 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame5 -in $This.frame1 -side top -fill both -expand 1

   #--- Angle de rotation
   frame $This.frame6 -borderwidth 0
      label $This.labrot -text "$caption(catalogexplorer,crota2)"
      pack $This.labrot -in $This.frame6 -side left -anchor w -padx 5 -pady 5
      entry $This.crota2 -textvariable ::catalogexplorer::widget(catalogexplorer,crota2) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.crota2 -in $This.frame6 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame6 -in $This.frame1 -side top -fill both -expand 1

   #--- AD du centre
   frame $This.frame7 -borderwidth 0
      label $This.labad -text "$caption(catalogexplorer,ad_centre)"
      pack $This.labad -in $This.frame7 -anchor w -side left -padx 5 -pady 5
      entry $This.ad -textvariable ::catalogexplorer::widget(catalogexplorer,crval1) \
         -justify center -width 14 -relief groove -borderwidth 1
      pack $This.ad -in $This.frame7 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame7 -in $This.frame1 -side top -fill both -expand 1

   #--- DEC du centre
   frame $This.frame8 -borderwidth 0
      label $This.labdec -text "$caption(catalogexplorer,dec_centre)"
      pack $This.labdec -in $This.frame8 -anchor w -side left -padx 5 -pady 5
      entry $This.dec -textvariable ::catalogexplorer::widget(catalogexplorer,crval2) \
         -justify center -width 14 -relief groove -borderwidth 1
      pack $This.dec -in $This.frame8 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame8 -in $This.frame1 -side top -fill both -expand 1

   #--- Magnitudes
   frame $This.frame9 -borderwidth 0
      label $This.labmag_faint -text "$caption(catalogexplorer,mag)"
      pack $This.labmag_faint -in $This.frame9 -side left -anchor w -padx 5 -pady 5
      entry $This.mag_faint -textvariable ::catalogexplorer::widget(catalogexplorer,mag_faint) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.mag_faint -in $This.frame9 -side right -padx 5 -pady 5 -ipady 5
      entry $This.mag_bright -textvariable ::catalogexplorer::widget(catalogexplorer,mag_bright) \
         -justify center -width 6 -relief groove -borderwidth 1
      pack $This.mag_bright -in $This.frame9 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame9 -in $This.frame1 -side top -fill both -expand 1

   #---  Catalogues
   frame $This.frame10 -borderwidth 0
      label $This.labcata -text "$caption(catalogexplorer,catalog)"
      pack $This.labcata -in $This.frame10 -anchor w -side left -padx 5 -pady 5
      set width [::tkutil::lgEntryComboBox $widget(catalogexplorer,listCatalog)]
      ComboBox $This.catalog -textvariable ::catalogexplorer::widget(catalogexplorer,catalog) \
         -values $widget(catalogexplorer,listCatalog) \
         -state normal -relief sunken -width $width -height [llength $widget(catalogexplorer,listCatalog)] \
         -modifycmd "::catalogexplorer::displayaavso"
      pack $This.catalog -in $This.frame10 -side right -padx 5 -pady 5 -ipady 5
   pack $This.frame10 -in $This.frame1 -side top -fill both -expand 1

   #---  Zoom
   frame $This.frame11 -borderwidth 0
      label $This.zoomlabel -text "$caption(catalogexplorer,zoom)"
      pack $This.zoomlabel -in $This.frame11 -side left -anchor w -padx 5 -pady 5
      ComboBox $This.zoom -textvariable ::catalogexplorer::widget(catalogexplorer,zoom) \
         -values $widget(catalogexplorer,listZoom) \
         -state normal -relief sunken -width 5 -height [llength $widget(catalogexplorer,listZoom)]
      pack $This.zoom -in $This.frame11 -side left -anchor w -padx 5 -pady 5
   pack $This.frame11 -in $This.frame1 -side top -fill both -expand 1

   #--- Creation du frame des boutons
   frame $This.frame21 -borderwidth 0

      #--- Creation du bouton 'Appliqer'
      button $This.appliquer -text "$caption(catalogexplorer,appliquer)" -width 8 \
            -command "::catalogexplorer::cmdApply"
      pack $This.appliquer -in $This.frame21 -side left -padx 5 -pady 5 -ipady 5 -fill x

      #--- Creation du bouton 'Fermer'
      button $This.fermer -text "$caption(catalogexplorer,fermer)" -width 7 -borderwidth 2 \
         -command "::catalogexplorer::cmdClose"
      pack $This.fermer -in $This.frame21 -side right -anchor w -padx 5 -pady 5 -ipady 5

      #--- Creation du bouton 'Aide'
      button $This.aide -text "$caption(catalogexplorer,aide)" -width 7 -borderwidth 2 \
         -command "::audace::showHelpPlugin [ ::audace::getPluginTypeDirectory [ ::catalogexplorer::getPluginType ] ] \
            [ ::catalogexplorer::getPluginDirectory ] [ ::catalogexplorer::getPluginHelp ]"
      pack $This.aide -in $This.frame21 -side right -anchor w -padx 5 -pady 5 -ipady 5

   pack $This.frame21 -in $This.frame20 -side top -fill both -expand 1

   ::catalogexplorer::displayaavso

   #--- bindings
   bind $This.naxis1 <Leave> "::catalogexplorer::computeRadius"
   bind $This.naxis2 <Leave> "::catalogexplorer::computeRadius"
   bind $This.pixsize1 <Leave> "::catalogexplorer::computeRadius"
   bind $This.pixsize2 <Leave> "::catalogexplorer::computeRadius"
   bind $This.foclen <Leave> "::catalogexplorer::computeRadius"

   ::catalogexplorer::computeRadius

   #--- La fenetre est active
   focus $This

   #--- Raccourci qui donne le focus a la Console et positionne le curseur dans la ligne de commande
   bind $This <Key-F1> { ::console::GiveFocus }

   #--- Mise a jour dynamique des couleurs
   ::confColor::applyColor $This
}

#------------------------------------------------------------
## @brief  commande du bouton "Appliquer"
#
proc ::catalogexplorer::cmdApply { } {
   variable widget

   #--   securite
   ::catalogexplorer::computeRadius

   #--   raccourcis
   foreach item [list catalog naxis1 naxis2 pixsize1 pixsize2 foclen crota2 \
      crval1 crval2 mag_bright mag_faint zoom fov_deg radius_arcmin] {
      set $item $widget(catalogexplorer,$item)
   }

   set catalogPath " " ; # pour "B/mk", "B/wds"
   switch -exact $catalog {
      2MASS        {  set catalogPath $::audace(rep_userCatalog2mass) }
      BMK          {  set catalogPath $::audace(rep_userCatalogBmk) }
      GAIA1        {  set catalogPath $::audace(rep_userCatalogGaia1) }
	  GAIA2        {  set catalogPath $::audace(rep_userCatalogGaia2) }
      LONEOS       {  set catalogPath $::audace(rep_userCatalogLoneos) }
      NOMAD1       {  set catalogPath $::audace(rep_userCatalogNomad1) }
      PPMX         {  set catalogPath $::audace(rep_userCatalogPpmx) }
      PPMXL        {  set catalogPath $::audace(rep_userCatalogPpmxl) }
      TYCHO2_FAST  {  set catalogPath $::audace(rep_userCatalogTycho2_fast) }
      UCAC2        {  set catalogPath $::audace(rep_userCatalogUcac2) }
      UCAC3        {  set catalogPath $::audace(rep_userCatalogUcac3) }
      UCAC4        {  set catalogPath $::audace(rep_userCatalogUcac4) }
      URAT1        {  set catalogPath $::audace(rep_userCatalogUrat1) }
      USNOA2       {  set catalogPath $::audace(rep_userCatalogUsnoa2) }
      AAVSO        {  set type aavso
                      set catalogPath [::catalogexplorer::getFileName $type]
                      if {$catalogPath ne ""} {
                        #--   Extrait les coordonnees du centre de l'image du titre du fichier
                        #--   ce peut etre des coordonnes en angles ou en HMS/DMS
                        lassign [split $catalogPath "_"] -> widget(catalogexplorer,crval1) widget(catalogexplorer,crval2)
                      }
                   }
   }

  if {$catalogPath eq ""} { return }

   #--   Substitue les angles aux valeurs HMS et DMS
   set crval1 [mc_angle2deg $crval1]
   set crval2 [mc_angle2deg $crval2 90]

   #--   verifie les entrees
   set listDat [list $naxis1 $naxis2 $pixsize1 $pixsize2 $crval1 $crval2 \
      $foclen $crota2 $mag_bright $mag_faint ]
   if {[::catalogexplorer::testValues $listDat] ==1} { return }

   #--   Definit field
   set field [list OPTIC NAXIS1 $naxis1 NAXIS2 $naxis2 FOCLEN $foclen \
      PIXSIZE1 [expr { $pixsize1*1e-6 }] PIXSIZE1 [expr { $pixsize2*1e-6 }] \
      CROTA2 $crota2 RA $crval1 DEC $crval2]

   #--   Cree la variable de donnees commune aux procs
   set widget(catalogexplorer,data) [list $catalog "$catalogPath" $naxis1 $naxis2 \
      $crval1 $crval2 $mag_bright $mag_faint $radius_arcmin "$field" $zoom]

   ::catalogexplorer::setWindowState disabled
   ::catalogexplorer::getStars
   ::catalogexplorer::setWindowState normal
}

#------------------------------------------------------------
## @brief  commande du bouton "Fermer"
#
proc ::catalogexplorer::cmdClose { } {
   variable This
   variable sptypeMatrix

   #--   Détruit les matrices si elles existent
   catch { sptypeMatrix destroy }

   ::catalogexplorer::widgetToConf
   destroy $This
}

#------------------------------------------------------------
# brief   gère l'etat des widgets
# param   state {normal|disabled}
#
proc ::catalogexplorer::setWindowState { state } {
   variable This
   global audace

   foreach child [ list naxis1 naxis2 pixsize1 pixsize2 ad dec crota2 foclen \
      mag_bright mag_faint catalog zoom appliquer aide fermer] {
      $This.$child configure -state "$state"
   }
   update
}

#------------------------------------------------------------
# brief   actualise les crval avec le titre de apass_xxx
#
proc ::catalogexplorer::displayaavso { } {
   variable widget

   set catalogName $widget(catalogexplorer,catalog)
   if {[regexp -all {(apass).+} $catalogName] ==1} {
      lassign [split $catalogName "_"] -> \
         widget(catalogexplorer,crval1) \
         widget(catalogexplorer,crval2) \
         radiusdeg
   }
}

#------------------------------------------------------------
# brief   capture le nom d'un répertoire aavso.csv ou vizieR.tsv
#
proc ::catalogexplorer::getFileName { type } {
   variable This
   global audace caption

   if {$type eq "aavso"} {

      set filename [tk_getOpenFile -parent $This -initialdir $audace(rep_userCatalog) \
         -title "$caption(catalogexplorer,select)" -defaultextension .csv]
      set shortname [file tail $filename]

     if {$type eq "aavso" && [regexp -all {(apass).+} $shortname] ==0} {
        tk_messageBox -message [format $caption(catalogexplorer,err_file) $filename] \
            -icon error -title "$caption(catalogexplorer,erreur)"
         return ""
      } else {
         return "$filename"
     }
   }
}

#------------------------------------------------------------
#  brief   teste les valeurs numériques et émet des messages d'erreur s'il y a lieu
#  param   data liste des paramètres
#  return  0= pas d'erreur | 1= erreur
#
proc ::catalogexplorer::testValues { data } {
   global caption

   set res 0

   lassign $data naxis1 naxis2 pixsize1 pixsize2 crval1 crval2 foclen crota2 mag_bright mag_faint

   #--   Verifie que les naxis sont des entiers
   foreach {var val} [list naxis1 $naxis1 naxis2 $naxis2] {
      if {[string is integer -strict $val] ==0} {
         tk_messageBox -message [format $caption(catalogexplorer,err_type) $var integer] \
            -icon error -title "$caption(catalogexplorer,erreur)"
         set res 1
      }
   }

   #--   Verifie que les autres valeurs sont des entiers ou decimaux signes
   set pattern {^([-+]?[0-9]*\.?[0-9]+)$} ; #--    entier ou decimal
   foreach {var val} [list pixsize1 $pixsize1 pixsize2 $pixsize2 crval1 $crval1 \
      crval2 $crval2 foclen $foclen crota2 $crota2 mag_bright $mag_bright mag_faint $mag_faint] {
      if {[regexp -all $pattern $val] !=1} {
         tk_messageBox -message [format $caption(catalogexplorer,err_type) $var double] \
            -icon error -title "$caption(catalogexplorer,erreur)"
         set res 1
      }
   }

   return $res
}

